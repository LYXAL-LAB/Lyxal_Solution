//! Lyxal Booking — Engine Native SurrealDB pour la réservation d'agendas.

mod auth;
mod availability;
mod caldav;
mod commands;
mod crypto_helpers;
mod db;
pub mod store {
    pub use crate::db::{SurrealBookingStore, SurrealBookingStore as SurrealStore};
}
mod email;
mod contracts;
mod ews;
mod i18n;
pub mod integrations;
mod models;
mod oauth2_caldav;
mod providers;
mod recurrence;
mod resources;
mod rrule;
pub mod services;
mod settings;
mod utils;
mod web;
pub mod workers;

use anyhow::Result;
use clap::{Parser, Subcommand};
use directories::ProjectDirs;
use lyxal_crypto::{CryptoEngine, EncryptionKey, EnvironmentKeyProvider, FileKeyProvider};
use std::net::IpAddr;
use std::path::{Path, PathBuf};
use std::sync::{Arc, OnceLock};
use tokio_util::sync::CancellationToken;

use crate::crypto_helpers::{BookingCryptoEngine, BookingKeyResolver};
use crate::db::SurrealBookingStore;
use surrealdb::RecordId;

static WARNED_CALRS_DATA_DIR: OnceLock<()> = OnceLock::new();

#[derive(Parser)]
#[command(name = "lyxal-booking", about = "Lyxal Booking engine & scheduling service", version)]
struct Cli {
    /// Custom data directory
    #[arg(long, env = "LYXAL_BOOKING_DATA_DIR", global = true)]
    data_dir: Option<PathBuf>,

    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
    /// Manage CalDAV sources
    Source {
        #[command(subcommand)]
        command: commands::source::SourceCommands,
    },
    /// Pull latest events from CalDAV
    Sync {
        /// Full re-sync (ignore sync tokens)
        #[arg(long)]
        full: bool,
    },
    /// View your calendar
    Calendar {
        #[command(subcommand)]
        command: CalendarCommands,
    },
    /// Manage bookable event types
    EventType {
        #[command(subcommand)]
        command: commands::event_type::EventTypeCommands,
    },
    /// Manage bookings
    Booking {
        #[command(subcommand)]
        command: commands::booking::BookingCommands,
    },
    /// Manage users
    User {
        #[command(subcommand)]
        command: commands::user::UserCommands,
    },
    /// Probe and manage shared resource calendars
    Resource {
        #[command(subcommand)]
        command: commands::resource::ResourceCommands,
    },
    /// Configure runtime settings
    Config {
        #[command(subcommand)]
        command: commands::config::ConfigCommands,
    },
    /// Start the web booking server
    Serve {
        /// Port to listen on
        #[arg(long, default_value = "3000")]
        port: u16,
        /// Address to bind to
        #[arg(long, default_value = "127.0.0.1")]
        host: IpAddr,
    },
}

#[derive(Subcommand)]
enum CalendarCommands {
    /// Show events
    Show {
        /// Start date (YYYY-MM-DD)
        #[arg(long)]
        from: Option<String>,
        /// End date (YYYY-MM-DD)
        #[arg(long)]
        to: Option<String>,
    },
}

/// Resolve data directory with backward-compatible fallback for `CALRS_DATA_DIR`.
fn get_data_dir(custom: Option<PathBuf>) -> Result<PathBuf> {
    if let Some(dir) = custom {
        return Ok(dir);
    }

    if let Ok(legacy_env) = std::env::var("CALRS_DATA_DIR") {
        let trimmed = legacy_env.trim();
        if !trimmed.is_empty() {
            WARNED_CALRS_DATA_DIR.get_or_init(|| {
                tracing::warn!("CALRS_DATA_DIR is deprecated; use LYXAL_BOOKING_DATA_DIR instead");
            });
            return Ok(PathBuf::from(trimmed));
        }
    }

    // Try new Lyxal directory first
    if let Some(proj) = ProjectDirs::from("", "Lyxal", "lyxal-booking") {
        let lyxal_path = proj.data_dir().to_path_buf();
        if lyxal_path.exists() {
            return Ok(lyxal_path);
        }
        // Check if legacy calrs directory exists
        if let Some(legacy_proj) = ProjectDirs::from("", "", "calrs") {
            let legacy_path = legacy_proj.data_dir().to_path_buf();
            if legacy_path.exists() {
                WARNED_CALRS_DATA_DIR.get_or_init(|| {
                    tracing::warn!("Using legacy Cal.rs data directory; consider migrating to Lyxal");
                });
                return Ok(legacy_path);
            }
        }
        return Ok(lyxal_path);
    }

    Err(anyhow::anyhow!("Could not determine data directory"))
}

/// Build the cryptographic engine enforcing explicit provider policy.
fn build_crypto_engine(data_dir: &Path) -> Result<Arc<BookingCryptoEngine>> {
    let provider_name = std::env::var("LYXAL_CRYPTO_PROVIDER").map_err(|_| {
        anyhow::anyhow!(
            "LYXAL_CRYPTO_PROVIDER must be explicitly configured (environment, file-strict, or file-dev)"
        )
    })?;

    let is_prod = std::env::var("LYXAL_ENV")
        .map(|v| v.eq_ignore_ascii_case("production"))
        .unwrap_or(false)
        || std::env::var("APP_ENV")
            .map(|v| v.eq_ignore_ascii_case("production"))
            .unwrap_or(false);

    if is_prod && provider_name == "file-dev" {
        anyhow::bail!("file-dev crypto provider is forbidden in production environment");
    }

    let resolver: BookingKeyResolver = match provider_name.as_str() {
        "environment" => Arc::new(EnvironmentKeyProvider::default_env()?),
        "file-strict" => Arc::new(FileKeyProvider::default_strict(data_dir)?),
        "file-dev" => Arc::new(FileKeyProvider::default_dev(data_dir)?),
        other => return Err(anyhow::anyhow!("Unsupported LYXAL_CRYPTO_PROVIDER: {other}")),
    };

    Ok(Arc::new(CryptoEngine::new(resolver)))
}

/// Listen for shutdown signals (SIGINT / SIGTERM) without panic.
async fn shutdown_signal() -> Result<()> {
    #[cfg(unix)]
    {
        let mut sigterm =
            tokio::signal::unix::signal(tokio::signal::unix::SignalKind::terminate())?;

        tokio::select! {
            res = tokio::signal::ctrl_c() => res?,
            _ = sigterm.recv() => {},
        }
    }
    #[cfg(not(unix))]
    {
        tokio::signal::ctrl_c().await?;
    }
    Ok(())
}

/// Run the web booking server.
async fn run_server(data_dir: PathBuf, host: IpAddr, port: u16) -> Result<()> {
    let store = SurrealBookingStore::connect_from_env().await?;
    settings::load(&store).await?;

    let private_hosts = settings::private_host_allowlist();
    if !private_hosts.is_empty() {
        tracing::warn!(
            allowed_hosts = ?private_hosts,
            from_env = settings::allow_private_hosts_from_env(),
            "SSRF private-host allowlist is active"
        );
    }

    let session_signing_key =
        crypto_helpers::load_or_create_session_signing_key(&data_dir)?;
    let crypto_engine = build_crypto_engine(&data_dir)?;
    let legacy_secret_key =
        crypto_helpers::load_legacy_secret_key_if_configured(&data_dir)?.map(Arc::new);

    let shutdown = CancellationToken::new();

    let reminder_task = tokio::spawn(workers::reminders::run_reminder_loop(
        store.clone(),
        crypto_engine.clone(),
        legacy_secret_key.clone(),
        shutdown.child_token(),
    ));

    let templates = web::templates::create_environment()?;
    let state = web::AppState {
        store: store.clone(),
        templates,
        login_limiter: web::RateLimiter::new(5, 60),
        booking_limiter: web::RateLimiter::new(10, 60),
        data_dir: data_dir.clone(),
        crypto: crypto_engine.clone(),
        legacy_secret_key: legacy_secret_key.clone(),
        secret_key: session_signing_key,
        theme_css: Arc::new(tokio::sync::RwLock::new(String::new())),
        company_link: Arc::new(tokio::sync::RwLock::new(None)),
        captcha_config: Arc::new(tokio::sync::RwLock::new(None)),
        meeting_config: Arc::new(tokio::sync::RwLock::new(Default::default())),
        csp: Arc::new(tokio::sync::RwLock::new(String::new())),
        csp_baseline: String::new(),
    };

    let router = web::create_router(state).await?;

    let addr = std::net::SocketAddr::from((host, port));
    tracing::info!("lyxal-booking server listening on {}", addr);
    let listener = tokio::net::TcpListener::bind(addr).await?;

    let server_result = axum::serve(listener, router)
        .with_graceful_shutdown({
            let shutdown = shutdown.clone();
            async move {
                if let Err(error) = shutdown_signal().await {
                    tracing::error!(%error, "Shutdown signal listener failed");
                }
                shutdown.cancel();
            }
        })
        .await;

    shutdown.cancel();

    let reminder_result = reminder_task.await;

    server_result?;

    match reminder_result {
        Ok(Ok(())) => tracing::info!("Reminder worker task exited normally"),
        Ok(Err(error)) => tracing::error!(%error, "Reminder worker stopped with an error"),
        Err(join_error) => tracing::error!(%join_error, "Reminder worker task panicked or failed"),
    }

    Ok(())
}

/// Run a CLI command.
async fn run_cli_command(data_dir: PathBuf, command: Commands) -> Result<()> {
    let store = SurrealBookingStore::connect_from_env().await?;
    settings::load(&store).await?;
    let crypto_engine = build_crypto_engine(&data_dir)?;
    let tenant = std::env::var("LYXAL_TENANT").unwrap_or_else(|_| "default".to_string());
    let account_id = RecordId::from(("booking_account", "default"));

    let legacy_secret_key =
        crypto_helpers::load_legacy_secret_key_if_configured(&data_dir)?;

    match command {
        Commands::Source { command } => {
            commands::source::run(&store, &crypto_engine, &tenant, &account_id, command).await?
        }
        Commands::Sync { full } => {
            commands::sync::run(
                &store,
                &crypto_engine,
                legacy_secret_key.as_ref(),
                &tenant,
                full,
            )
            .await?
        }
        Commands::Calendar { command } => match command {
            CalendarCommands::Show { from, to } => {
                commands::calendar::run(&store, from, to).await?
            }
        },
        Commands::EventType { command } => commands::event_type::run(&store, command).await?,
        Commands::Booking { command } => {
            commands::booking::run(&store, command).await?
        }
        Commands::User { command } => commands::user::run(&store, &data_dir, command).await?,
        Commands::Resource { command } => commands::resource::run(&store, command).await?,
        Commands::Config { command } => {
            commands::config::run(&store, &crypto_engine, &tenant, command).await?
        }
        Commands::Serve { .. } => unreachable!(),
    }

    Ok(())
}

#[tokio::main]
async fn main() -> Result<()> {
    tracing_subscriber::fmt()
        .with_env_filter(
            tracing_subscriber::EnvFilter::try_from_default_env()
                .unwrap_or_else(|_| "lyxal_booking=info,tower_http=info".into()),
        )
        .init();

    let cli = Cli::parse();
    let data_dir = get_data_dir(cli.data_dir)?;

    match cli.command {
        Commands::Serve { host, port } => run_server(data_dir, host, port).await,
        command => run_cli_command(data_dir, command).await,
    }
}
