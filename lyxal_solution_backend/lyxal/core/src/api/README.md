# Lyxal Core API

This module contains the internal API abstractions and definitions for the Lyxal Solution core engine. It defines the foundational structures for handling incoming requests and returning appropriate responses before they hit the transport layers (HTTP, WebSocket, etc.).

## Components

- **`ApiRequest`**: Represents an incoming request payload to be processed by the engine. 
- **`ApiResponse`**: The standardized response formatted returned by the system containing execution results or errors.
- **`Error` / `ApiError`**: Error types specific to API request evaluation and processing.
- **`Middleware` & Routing**: Defines common strategies, request manipulation and basic routing behavior useful throughout the database.

## Architecture

Originally a distinct workspace crate, this logic was integrated into `lyxal_core` as `lyxal_core_api` since fundamental database operations (like triggering webhooks and builtin functions) interact directly with these API structures. Being inside `lyxal_core` guarantees zero circular dependencies. 
