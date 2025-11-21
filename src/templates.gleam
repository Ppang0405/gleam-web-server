import gleam/string_builder.{type StringBuilder}
import nakai
import nakai/html.{type Node}
import nakai/attr

/// Renders a complete HTML page with a title and body content
/// 
/// Parameters:
///   - title: The page title
///   - body_content: List of HTML nodes for the body
pub fn layout(title: String, body_content: List(Node)) -> StringBuilder {
  html.Html([], [
    html.Head([
      html.meta([attr.charset("utf-8")]),
      html.meta([
        attr.name("viewport"),
        attr.content("width=device-width, initial-scale=1"),
      ]),
      html.title(title),
      html.Element("style", [], [html.Text(base_styles())]),
    ]),
    html.Body([], body_content),
  ])
  |> nakai.to_string_builder()
}

/// Renders the home page with API documentation
/// 
/// Displays a welcome message and lists all available endpoints.
pub fn home_page() -> StringBuilder {
  layout("Gleam Web Server", [
    html.div([attr.class("container")], [
      html.h1([], [html.Text("🚀 Gleam Web Server")]),
      html.p([], [
        html.Text("Welcome! Your Gleam web server is running successfully."),
      ]),
      html.h2([], [html.Text("Available Endpoints:")]),
      endpoint_card("GET", "/", "This home page"),
      endpoint_card("GET", "/api/hello", "Returns a simple JSON greeting"),
      endpoint_card(
        "GET",
        "/api/greet/:name",
        "Returns a personalized greeting (e.g., /api/greet/Alice)",
      ),
      endpoint_card("POST", "/api/echo", "Echoes back the JSON body you send"),
      endpoint_card("GET", "/health", "Health check endpoint"),
      examples_section(),
    ]),
  ])
}

/// Renders an endpoint documentation card
/// 
/// Parameters:
///   - method: HTTP method (GET, POST, etc.)
///   - path: The endpoint path
///   - description: Description of what the endpoint does
fn endpoint_card(method: String, path: String, description: String) -> Node {
  let method_class = case method {
    "GET" -> "method get"
    "POST" -> "method post"
    "PUT" -> "method put"
    "DELETE" -> "method delete"
    _ -> "method"
  }

  html.div([attr.class("endpoint")], [
    html.span([attr.class(method_class)], [html.Text(method)]),
    html.Element("code", [], [html.Text(path)]),
    html.p([], [html.Text(description)]),
  ])
}

/// Renders the examples section with curl commands
/// 
/// Displays code examples showing how to interact with the API.
fn examples_section() -> Node {
  html.div([], [
    html.h3([], [html.Text("Try it out:")]),
    html.div([attr.class("examples")], [
      code_example("curl http://localhost:8000/api/hello"),
      code_example("curl http://localhost:8000/api/greet/World"),
      code_example(
        "curl -X POST -H \"Content-Type: application/json\" -d '{\"message\":\"Hello\"}' http://localhost:8000/api/echo",
      ),
    ]),
  ])
}

/// Renders a code example block
/// 
/// Parameters:
///   - code: The code string to display
fn code_example(code: String) -> Node {
  html.div([attr.class("code-example")], [
    html.Element("code", [], [html.Text(code)]),
  ])
}

/// Returns base CSS styles for all pages
/// 
/// Contains styling for layout, typography, endpoint cards, and code examples.
fn base_styles() -> String {
  "
    * {
      box-sizing: border-box;
      margin: 0;
      padding: 0;
    }
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
      line-height: 1.6;
      color: #2d3748;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      min-height: 100vh;
      padding: 20px;
    }
    .container {
      max-width: 800px;
      margin: 50px auto;
      background: white;
      border-radius: 12px;
      padding: 40px;
      box-shadow: 0 10px 40px rgba(0,0,0,0.2);
    }
    h1 { 
      color: #667eea;
      margin-bottom: 15px;
      font-size: 2.5em;
    }
    h2 { 
      color: #4a5568;
      margin-top: 30px;
      margin-bottom: 15px;
      font-size: 1.8em;
    }
    h3 { 
      color: #4a5568;
      margin-top: 25px;
      margin-bottom: 15px;
      font-size: 1.4em;
    }
    p {
      margin-bottom: 10px;
      color: #4a5568;
    }
    .endpoint {
      background: #f7fafc;
      border-left: 4px solid #667eea;
      padding: 15px;
      margin: 15px 0;
      border-radius: 4px;
      transition: transform 0.2s;
    }
    .endpoint:hover {
      transform: translateX(5px);
    }
    .endpoint p {
      margin: 8px 0 0 0;
    }
    code {
      background: #edf2f7;
      padding: 2px 6px;
      border-radius: 3px;
      font-family: 'Monaco', 'Courier New', monospace;
      font-size: 14px;
    }
    .method {
      display: inline-block;
      padding: 4px 10px;
      border-radius: 4px;
      font-weight: bold;
      font-size: 11px;
      margin-right: 8px;
      text-transform: uppercase;
      letter-spacing: 0.5px;
    }
    .get { background: #48bb78; color: white; }
    .post { background: #4299e1; color: white; }
    .put { background: #ed8936; color: white; }
    .delete { background: #f56565; color: white; }
    .examples { 
      margin-top: 15px;
    }
    .code-example {
      background: #2d3748;
      color: #e2e8f0;
      padding: 15px;
      border-radius: 6px;
      margin: 10px 0;
      overflow-x: auto;
    }
    .code-example code {
      background: transparent;
      color: #68d391;
      padding: 0;
      font-size: 13px;
    }
    @media (max-width: 768px) {
      .container {
        padding: 20px;
        margin: 20px auto;
      }
      h1 { font-size: 2em; }
      h2 { font-size: 1.5em; }
    }
  "
}

