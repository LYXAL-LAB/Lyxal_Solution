//! lyxal-mcp binary: start the MCP server on stdio.
//!
//! Usage (e.g. from Claude Desktop config):
//! ```json
//! {
//!   "mcpServers": {
//!     "croniq": {
//!       "command": "lyxal-mcp",
//!       "args": ["--mutations", "--data-dir", "/var/lib/croniq"]
//!     }
//!   }
//! }
//! ```
//!
//! ## Flags
//!
//! | Flag | Description |
//! |------|-------------|
//! | `--mutations` | Enable write tools (enqueue_job, cancel_execution, job_trigger, dlq_retry) |
//! | `--data-dir <path>` | Open the SQLite store at `<path>/croniq.db` (required for dlq_retry and store-backed operations) |

use std::path::PathBuf;
use std::sync::Arc;

use anyhow::{Context, Result};
use lyxal_mcp::LyxalMcp;
use lyxal_runner::AppState;
use rmcp::ServiceExt;
use tracing_subscriber::{EnvFilter, fmt};

// ─── CLI args ─────────────────────────────────────────────────────────────────

struct Args {
    /// Enable mutation tools.
    mutations: bool,
    /// Path to data directory containing the SQLite database.
    data_dir: Option<PathBuf>,
}

impl Args {
    fn parse() -> Result<Self> {
        let mut mutations = false;
        let mut data_dir: Option<PathBuf> = None;
        let mut args = std::env::args().skip(1);

        while let Some(arg) = args.next() {
            match arg.as_str() {
                "--mutations" => mutations = true,
                "--data-dir" => {
                    let path = args.next().context("--data-dir requires a path argument")?;
                    data_dir = Some(PathBuf::from(path));
                }
                other => {
                    anyhow::bail!(
                        "Unknown argument: {other}. Usage: lyxal-mcp [--mutations] [--data-dir <path>]"
                    );
                }
            }
        }

        Ok(Self {
            mutations,
            data_dir,
        })
    }
}

// ─── Main ─────────────────────────────────────────────────────────────────────

#[tokio::main]
async fn main() -> Result<()> {
    // Log to stderr so stdout remains clean for the MCP stdio transport.
    fmt()
        .with_env_filter(EnvFilter::from_default_env())
        .with_writer(std::io::stderr)
        .without_time()
        .with_ansi(false)
        .init();

    let args = Args::parse()?;

    tracing::info!(
        mutations = args.mutations,
        data_dir = ?args.data_dir,
        "lyxal-mcp starting"
    );

    let state = AppState::new();

    let server = match args.data_dir {
        Some(_data_dir) => {
            let surreal_endpoint = std::env::var("LYXAL_DB")
                .or_else(|_| std::env::var("SURREALDB_URL"))
                .unwrap_or_else(|_| "127.0.0.1:8000".to_string());

            let surreal_ns = std::env::var("SURREALDB_NS").unwrap_or_else(|_| "main".to_string());
            let surreal_db = std::env::var("SURREALDB_DB").unwrap_or_else(|_| "main".to_string());
            let surreal_user = std::env::var("SURREALDB_USER").unwrap_or_else(|_| "root".to_string());
            let surreal_pass = std::env::var("SURREALDB_PASS").unwrap_or_else(|_| "root".to_string());

            tracing::info!(endpoint = %surreal_endpoint, ns = %surreal_ns, db = %surreal_db, "opening SurrealStore for MCP");

            let store: lyxal_mcp::DynStore = Arc::new(
                lyxal_store::surreal::SurrealStore::connect(
                    &surreal_endpoint,
                    &surreal_ns,
                    &surreal_db,
                    &surreal_user,
                    &surreal_pass,
                )
                .await
                .context("Failed to connect SurrealStore for MCP")?,
            );

            LyxalMcp::new_with_store(Arc::clone(&state), store, vec![], args.mutations)
        }
        None if args.mutations => {
            tracing::warn!(
                "--mutations enabled without --data-dir: dlq_retry will not be available"
            );
            LyxalMcp::new_mutations_only(Arc::clone(&state))
        }
        None => LyxalMcp::new(Arc::clone(&state)),
    };

    let service = server
        .serve(rmcp::transport::stdio())
        .await
        .inspect_err(|e| tracing::error!("MCP server error: {e}"))?;

    service.waiting().await?;

    tracing::info!("lyxal-mcp stopped");
    Ok(())
}
