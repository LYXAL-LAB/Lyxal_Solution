# Lyxal API Client (Rust)

A high-performance Rust SDK for interacting with the Lyxal Identity Management API. 
Designed with **1:1 parity** with the Logto `@logto/api` package.

## Features

- **M2M Authentication**: Implements the `client_credentials` grant flow.
- **Smart Caching**: Automatic token caching with a 60-second safety buffer for expiration.
- **Type-safe API**: High-level methods for managing users, applications, and tenants.
- **Async First**: Built on top of `tokio` and `reqwest`.

## Installation

Add this to your `Cargo.toml`:

```toml
[dependencies]
lyxal_api_client = { path = "../lyxal_api_client" }
tokio = { version = "1.0", features = ["full"] }
serde_json = "1.0"
```

## Quick Start

```rust
use lyxal_api_client::{ManagementClient, ManagementClientConfig};
use serde_json::json;

#[tokio::main]
async fn main() -> Result<(), String> {
    // 1. Initialize configuration
    let config = ManagementClientConfig {
        base_url: "http://localhost:3000".to_string(),
        client_id: "your_m2m_app_id".to_string(),
        client_secret: "your_m2m_app_secret".to_string(),
        api_indicator: "https://default.lyxal.app/api".to_string(),
    };

    // 2. Create the client
    let client = ManagementClient::new(config);

    // 3. Fetch users (token management is handled automatically)
    let users = client.get_users().await?;
    println!("Users found: {}", users);

    // 4. Create a new user
    let new_user = json!({
        "username": "rust_dev",
        "primaryEmail": "dev@lyxal.com"
    });
    let created = client.create_user(new_user).await?;
    println!("Created User ID: {}", created["id"]);

    Ok(())
}
```

## Advanced Usage

### Manual Token Management
If you need to retrieve the raw access token for other purposes:

```rust
let token = client.get_access_token().await?;
```

### Custom API Calls
Use the generic `request` method for endpoints not yet covered by high-level methods:

```rust
// This is an internal method, but high-level wrappers follow this pattern
// let res = client.request::<serde_json::Value>(Method::DELETE, "/users/123", None).await?;
```

## Parity Note
This SDK is functionally identical to Logto's TypeScript SDK. It uses the same camelCase naming conventions for JSON fields and the same caching logic to minimize calls to the OIDC `/token` endpoint.
