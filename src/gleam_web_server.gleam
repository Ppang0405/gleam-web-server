import database
import gleam/bytes_tree
import gleam/erlang/process
import gleam/http
import gleam/http/response.{type Response}
import gleam/io
import gleam/json
import mist
import templates
import wisp.{type Request}
import wisp/wisp_mist

/// Context to hold application state like database connection
pub type Context {
  Context(db: database.Connection)
}

/// Main entry point for the web server application
pub fn main() {
  // Configure the logger for better debugging
  wisp.configure_logger()

  // Initialize database
  let assert Ok(db) = database.init()

  // Create application context
  let ctx = Context(db: db)

  // Define the secret key base for session management
  let secret_key_base = wisp.random_string(64)

  // Create the handler
  let handler =
    wisp_mist.handler(fn(req) { handle_request(req, ctx) }, secret_key_base)

  // Start the web server on port 8000
  let assert Ok(_) =
    mist.new(handler)
    |> mist.port(8000)
    |> mist.start

  io.println("🚀 Server started on http://localhost:8000")

  // Keep the server running
  process.sleep_forever()
}

/// Main request handler that routes incoming HTTP requests
/// 
/// This function receives all incoming requests and dispatches them
/// to appropriate handlers based on the request path and method.
pub fn handle_request(req: Request, ctx: Context) -> Response(wisp.Body) {
  use _req <- middleware(req)

  case wisp.path_segments(req) {
    // GET /
    [] -> home_page(req, ctx)

    // GET /api/hello
    ["api", "hello"] -> hello_api(req)

    // GET /api/greet/:name
    ["api", "greet", name] -> greet_api(req, name)

    // POST /api/echo
    ["api", "echo"] -> echo_api(req)

    // GET /health
    ["health"] -> health_check(req)

    // 404 Not Found for all other routes
    _ -> wisp.not_found()
  }
}

/// Middleware function to log requests and handle common functionality
/// 
/// This middleware logs incoming requests and can be extended to add
/// authentication, CORS headers, or other cross-cutting concerns.
fn middleware(
  req: Request,
  handle_request: fn(Request) -> Response(wisp.Body),
) -> Response(wisp.Body) {
  // Log the incoming request
  io.println(http.method_to_string(req.method) <> " " <> req.path)

  // Pass the request to the next handler
  handle_request(req)
}

/// Handler for the home page
/// 
/// Returns a simple HTML page welcoming users to the web server.
/// Increments and displays the view count from the database.
fn home_page(_req: Request, ctx: Context) -> Response(wisp.Body) {
  // Increment the view count and get the updated value
  let view_count = case database.increment_view_count(ctx.db, "homepage") {
    Ok(count) -> count
    Error(_) -> 0
  }

  let html = templates.home_page(view_count)

  wisp.html_response(html, 200)
}

/// API endpoint that returns a simple JSON greeting
/// 
/// Returns: {"message": "Hello from Gleam!"}
fn hello_api(req: Request) -> Response(wisp.Body) {
  case req.method {
    http.Get -> {
      let body =
        json.object([#("message", json.string("Hello from Gleam!"))])
        |> json.to_string

      wisp.json_response(body, 200)
    }
    _ -> wisp.method_not_allowed([http.Get])
  }
}

/// API endpoint that returns a personalized greeting
/// 
/// Parameters:
///   - name: The name to greet
/// 
/// Returns: {"message": "Hello, {name}!"}
fn greet_api(req: Request, name: String) -> Response(wisp.Body) {
  case req.method {
    http.Get -> {
      let message = "Hello, " <> name <> "!"
      let body =
        json.object([#("message", json.string(message))])
        |> json.to_string

      wisp.json_response(body, 200)
    }
    _ -> wisp.method_not_allowed([http.Get])
  }
}

/// API endpoint that echoes back the request body
/// 
/// This endpoint accepts JSON and returns it back to the client.
/// Useful for testing POST requests.
fn echo_api(req: Request) -> Response(wisp.Body) {
  case req.method {
    http.Post -> {
      // Read the request body
      use body <- wisp.require_bit_array_body(req)

      // Echo it back
      let res_body = bytes_tree.from_bit_array(body)

      response.new(200)
      |> response.prepend_header("content-type", "application/json")
      |> response.set_body(wisp.Bytes(res_body))
    }
    _ -> wisp.method_not_allowed([http.Post])
  }
}

/// Health check endpoint
/// 
/// Returns a simple status message to indicate the server is running.
/// Useful for monitoring and load balancers.
fn health_check(req: Request) -> Response(wisp.Body) {
  case req.method {
    http.Get -> {
      let body =
        json.object([
          #("status", json.string("healthy")),
          #("service", json.string("gleam_web_server")),
        ])
        |> json.to_string

      wisp.json_response(body, 200)
    }
    _ -> wisp.method_not_allowed([http.Get])
  }
}
