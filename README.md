# Gleam Web Server

A modern, lightweight web server built with Gleam, using the Wisp web framework and Mist HTTP server.

## Features

- 🚀 Fast and efficient HTTP server
- 🛣️  Clean routing system
- 📝 Request logging middleware
- 🎨 Beautiful HTML home page with **Nakai** templates
- 🔌 RESTful API endpoints
- ✅ Health check endpoint
- 🎯 Type-safe HTML generation with Nakai

## Prerequisites

- [Gleam](https://gleam.run/) >= 1.0.0
- [Erlang/OTP](https://www.erlang.org/) >= 26.0

## Installation

1. Install dependencies:
```bash
gleam deps download
```

2. Build the project:
```bash
gleam build
```

## Running the Server

Start the web server:
```bash
gleam run
```

The server will start on `http://localhost:8000`

## Available Endpoints

### Web Pages

- **GET /** - Home page with server documentation

### API Endpoints

- **GET /api/hello** - Simple JSON greeting
  ```bash
  curl http://localhost:8000/api/hello
  ```
  Response: `{"message": "Hello from Gleam!"}`

- **GET /api/greet/:name** - Personalized greeting
  ```bash
  curl http://localhost:8000/api/greet/Alice
  ```
  Response: `{"message": "Hello, Alice!"}`

- **POST /api/echo** - Echo back JSON body
  ```bash
  curl -X POST \
    -H "Content-Type: application/json" \
    -d '{"message": "Hello World"}' \
    http://localhost:8000/api/echo
  ```
  Response: `{"message": "Hello World"}`

- **GET /health** - Health check
  ```bash
  curl http://localhost:8000/health
  ```
  Response: `{"status": "healthy", "service": "gleam_web_server"}`

## Project Structure

```
gleam-web-server/
├── gleam.toml                 # Project configuration
├── src/
│   ├── gleam_web_server.gleam # Main application & routing
│   └── templates.gleam        # Nakai HTML templates
└── README.md                  # This file
```

## Using Nakai Templates

This project uses **Nakai** for type-safe HTML templating. Templates are organized in the `src/templates.gleam` module.

### Example: Creating a New Template

```gleam
import nakai
import nakai/html
import nakai/html/attrs
import gleam/string_builder.{type StringBuilder}

pub fn my_page(name: String) -> StringBuilder {
  nakai.html([], [
    html.Head([
      html.meta([attrs.charset("utf-8")]),
      html.title("My Page"),
    ]),
    html.Body([
      html.h1([], [html.Text("Hello, " <> name <> "!")]),
      html.p([attrs.class("greeting")], [
        html.Text("Welcome to my Gleam web server"),
      ]),
    ]),
  ])
  |> nakai.to_string_builder()
}
```

### Using Templates in Handlers

```gleam
import templates
import wisp
import gleam/http/response

fn my_handler(req: Request) -> Response(wisp.Body) {
  let html = templates.my_page("Alice")
  
  response.new(200)
  |> response.set_body(wisp.html_body(html))
}
```

## Development

### Running Tests
```bash
gleam test
```

### Type Checking
```bash
gleam check
```

### Formatting
```bash
gleam format
```

## Building for Production

Compile an optimized build:
```bash
gleam build --target erlang
```

## Tech Stack

- **[Gleam](https://gleam.run/)** - A friendly language for building type-safe systems
- **[Wisp](https://hexdocs.pm/wisp/)** - A practical web framework for Gleam
- **[Mist](https://hexdocs.pm/mist/)** - A fast HTTP server for Gleam
- **[Nakai](https://hexdocs.pm/nakai/)** - Type-safe HTML generation library

## Extending the Server

To add new endpoints, modify the `handle_request` function in `src/gleam_web_server.gleam`:

```gleam
pub fn handle_request(req: Request) -> Response(wisp.Body) {
  use _req <- middleware(req)

  case wisp.path_segments(req) {
    ["your", "new", "path"] -> your_handler(req)
    _ -> wisp.not_found()
  }
}
```

## License

MIT

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

