use serde::Deserialize;
use std::env;
use crate::error::Result;

/// Configuration structure for the Lyxal Identity system.
/// It aggregates configuration for all modules and can be loaded from
/// environment variables or a configuration file.
#[derive(Debug, Deserialize, Clone)]
pub struct Config {
    pub server: ServerConfig,
    pub database: DatabaseConfig,
    pub security: SecurityConfig,
}

#[derive(Debug, Deserialize, Clone)]
pub struct ServerConfig {
    pub host: String,
    pub port: u16,
    pub log_level: String,
}

#[derive(Debug, Deserialize, Clone)]
pub struct DatabaseConfig {
    pub url: String,
    pub max_connections: u32,
}

#[derive(Debug, Deserialize, Clone)]
pub struct SecurityConfig {
    pub secret_key: String,
    pub token_expiration_hours: i64,
}

impl Config {
    /// Load configuration from environment variables.
    /// This follows the 12-factor app methodology.
    pub fn from_env() -> Result<Self> {
        dotenvy::dotenv().ok(); // Load .env file if it exists

        Ok(Config {
            server: ServerConfig {
                host: env::var("LYXAL_HOST").unwrap_or_else(|_| "0.0.0.0".to_string()),
                port: env::var("LYXAL_PORT")
                    .unwrap_or_else(|_| "3000".to_string())
                    .parse()
                    .map_err(|_| crate::CoreError::Validation("Invalid port number".to_string()))?,
                log_level: env::var("LYXAL_LOG_LEVEL").unwrap_or_else(|_| "info".to_string()),
            },
            database: DatabaseConfig {
                url: env::var("DATABASE_URL").map_err(|_| {
                    crate::CoreError::Validation("DATABASE_URL must be set".to_string())
                })?,
                max_connections: env::var("DATABASE_MAX_CONNECTIONS")
                    .unwrap_or_else(|_| "5".to_string())
                    .parse()
                    .unwrap_or(5),
            },
            security: SecurityConfig {
                secret_key: env::var("LYXAL_SECRET_KEY").map_err(|_| {
                    crate::CoreError::Validation("LYXAL_SECRET_KEY must be set".to_string())
                })?,
                token_expiration_hours: env::var("TOKEN_EXPIRATION_HOURS")
                    .unwrap_or_else(|_| "24".to_string())
                    .parse()
                    .unwrap_or(24),
            },
        })
    }
}
