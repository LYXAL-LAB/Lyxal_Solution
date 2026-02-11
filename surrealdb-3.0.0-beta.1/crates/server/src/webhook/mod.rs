//! # Lyxal Webhook Server
//!
//! HTTP handlers for webhook endpoints.
//! Provides a single generic endpoint for all webhooks defined via `DEFINE WEBHOOK`.
//!
//! ## Architecture
//!
//! All webhooks are routed through a single catch-all endpoint `/webhook/*path`
//! which resolves the webhook definition from the registry and dispatches accordingly.

pub mod handler;
pub mod router;

pub use router::webhook_router;
