# Lyxal Server

The server implementation crate for Lyxal, containing HTTP/WebSocket server functionality, CLI tooling, and
server-specific features.
This crate should not be used outside of Lyxal itself.
For a stable interface to the Lyxal library see [the Rust SDK](https://crates.io/crates/lyxal)

`lyxal-server` is the server-side component of Lyxal that provides:

- **HTTP and WebSocket server endpoints** for database operations
- **Command-line interface (CLI)** for managing and running Lyxal instances
- **Network layer** including authentication, routing, and middleware
- **Server utilities** for configuration, logging, and monitoring
- **Integration layer** between the core database engine and external interfaces