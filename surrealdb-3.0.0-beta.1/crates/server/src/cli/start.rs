use std::net::SocketAddr;
use std::path::PathBuf;
use std::sync::Arc;
use std::time::Duration;

#[cfg(feature = "ml")]
use anyhow::Context;
use anyhow::Result;
use clap::Args;
use surrealdb::engine::{any, tasks};
use surrealdb_core::buc::BucketStoreProvider;
use surrealdb_core::kvs::TransactionBuilderFactory;
use surrealdb_core::options::EngineOptions;
use tokio_util::sync::CancellationToken;

use super::config::Config;
use crate::cli::ConfigCheck;
use crate::cnf::LOGO;
use crate::dbs::StartCommandDbsOptions;
use crate::ntw::RouterFactory;
use crate::ntw::client_ip::ClientIp;
use crate::{dbs, env, ntw};

#[derive(Args, Debug)]
pub struct StartCommandArguments {
	#[arg(help = "Database path used for storing data")]
	#[arg(env = "SURREAL_PATH", index = 1)]
	#[arg(default_value = "memory")]
	path: String,
	#[arg(help = "Whether to hide the startup banner")]
	#[arg(env = "SURREAL_NO_BANNER", long)]
	#[arg(default_value_t = false)]
	no_banner: bool,
	#[arg(help = "Encryption key to use for on-disk encryption")]
	#[arg(env = "SURREAL_KEY", short = 'k', long = "key")]
	#[arg(value_parser = super::validator::key_valid)]
	#[arg(hide = true)] // Not currently in use
	key: Option<String>,
	//
	// Tasks
	#[arg(
		help = "The interval at which to refresh node registration information",
		help_heading = "Database"
	)]
	#[arg(env = "SURREAL_NODE_MEMBERSHIP_REFRESH_INTERVAL", long = "node-membership-refresh-interval", value_parser = super::validator::duration)]
	#[arg(default_value = "3s")]
	node_membership_refresh_interval: Duration,
	#[arg(
		help = "The interval at which to process and archive inactive nodes",
		help_heading = "Database"
	)]
	#[arg(env = "SURREAL_NODE_MEMBERSHIP_CHECK_INTERVAL", long = "node-membership-check-interval", value_parser = super::validator::duration)]
	#[arg(default_value = "15s")]
	node_membership_check_interval: Duration,
	#[arg(
		help = "The interval at which to process and cleanup archived nodes",
		help_heading = "Database"
	)]
	#[arg(env = "SURREAL_NODE_MEMBERSHIP_CLEANUP_INTERVAL", long = "node-membership-cleanup-interval", value_parser = super::validator::duration)]
	#[arg(default_value = "300s")]
	node_membership_cleanup_interval: Duration,
	#[arg(
		help = "The interval at which to perform changefeed garbage collection",
		help_heading = "Database"
	)]
	#[arg(env = "SURREAL_CHANGEFEED_GC_INTERVAL", long = "changefeed-gc-interval", value_parser = super::validator::duration)]
	#[arg(default_value = "30s")]
	changefeed_gc_interval: Duration,
	#[arg(env = "SURREAL_INDEX_COMPACTION_INTERVAL", long = "index-compaction-interval", value_parser = super::validator::duration)]
	#[arg(default_value = "5s")]
	index_compaction_interval: Duration,
	//
	// Authentication
	#[arg(
		help = "The username for the initial database root user. Only if no other root user exists",
		help_heading = "Authentication"
	)]
	#[arg(
		env = "SURREAL_USER",
		short = 'u',
		long = "username",
		visible_alias = "user",
		requires = "password"
	)]
	username: Option<String>,
	#[arg(
		help = "The password for the initial database root user. Only if no other root user exists",
		help_heading = "Authentication"
	)]
	#[arg(
		env = "SURREAL_PASS",
		short = 'p',
		long = "password",
		visible_alias = "pass",
		requires = "username"
	)]
	password: Option<String>,
	//
	// Datastore connection
	#[command(next_help_heading = "Datastore connection")]
	#[command(flatten)]
	kvs: Option<StartCommandRemoteTlsOptions>,
	//
	// HTTP Server
	#[command(next_help_heading = "HTTP server")]
	#[command(flatten)]
	web: Option<StartCommandWebTlsOptions>,
	#[arg(help = "The method of detecting the client's IP address")]
	#[arg(env = "SURREAL_CLIENT_IP", long)]
	#[arg(default_value = "socket", value_enum)]
	client_ip: ClientIp,
	#[arg(help = "The hostname or IP address to listen for connections on")]
	#[arg(env = "SURREAL_BIND", short = 'b', long = "bind")]
	#[arg(default_value = "127.0.0.1:8000")]
	listen_addresses: Vec<SocketAddr>,
	#[arg(help = "Whether to suppress the server name and version headers")]
	#[arg(env = "SURREAL_NO_IDENTIFICATION_HEADERS", long)]
	#[arg(default_value_t = false)]
	no_identification_headers: bool,
	//
	// Database options
	#[command(flatten)]
	#[command(next_help_heading = "Database")]
	dbs: StartCommandDbsOptions,
}

#[derive(Args, Debug)]
#[group(requires_all = ["kvs_ca", "kvs_crt", "kvs_key"], multiple = true)]
struct StartCommandRemoteTlsOptions {
	#[arg(help = "Path to the CA file used when connecting to the remote KV store")]
	#[arg(env = "SURREAL_KVS_CA", long = "kvs-ca", value_parser = super::validator::file_exists)]
	kvs_ca: Option<PathBuf>,
	#[arg(help = "Path to the certificate file used when connecting to the remote KV store")]
	#[arg(env = "SURREAL_KVS_CRT", long = "kvs-crt", value_parser = super::validator::file_exists)]
	kvs_crt: Option<PathBuf>,
	#[arg(help = "Path to the private key file used when connecting to the remote KV store")]
	#[arg(env = "SURREAL_KVS_KEY", long = "kvs-key", value_parser = super::validator::file_exists)]
	kvs_key: Option<PathBuf>,
}

#[derive(Args, Debug)]
#[group(requires_all = ["web_crt", "web_key"], multiple = true)]
struct StartCommandWebTlsOptions {
	#[arg(help = "Path to the certificate file for encrypted client connections")]
	#[arg(env = "SURREAL_WEB_CRT", long = "web-crt", value_parser = super::validator::file_exists)]
	web_crt: Option<PathBuf>,
	#[arg(help = "Path to the private key file for encrypted client connections")]
	#[arg(env = "SURREAL_WEB_KEY", long = "web-key", value_parser = super::validator::file_exists)]
	web_key: Option<PathBuf>,
}

/// Start the server.
///
/// Initializes and starts the SurrealDB server with the provided configuration.
///
/// # Parameters
/// - `composer`: A composer implementing the required traits for dependency injection
///
/// # Generic parameters
/// - `C`: A composer type that implements:
///   - `TransactionBuilderFactory` (datastore transaction builder for storage/backend selection)
///   - `RouterFactory` (HTTP router factory for route/middleware customization)
///   - `ConfigCheck` (validates configuration before initialization)
pub async fn init<
	C: TransactionBuilderFactory + RouterFactory + ConfigCheck + BucketStoreProvider,
>(
	mut composer: C,
	StartCommandArguments {
		path,
		username: user,
		password: pass,
		client_ip,
		listen_addresses,
		dbs,
		web,
		node_membership_refresh_interval,
		node_membership_check_interval,
		node_membership_cleanup_interval,
		changefeed_gc_interval,
		index_compaction_interval,
		no_banner,
		no_identification_headers,
		..
	}: StartCommandArguments,
) -> Result<()> {
	// Check the path is valid
	C::path_valid(&path)?;
	// Check if we should output a banner
	if !no_banner {
		println!("{LOGO}");
	}
	// Clean the path
	let endpoint = any::__into_endpoint(path)?;
	let path = if endpoint.path.is_empty() {
		endpoint.url.to_string()
	} else {
		endpoint.path
	};
	// Extract the certificate and key
	let (crt, key) = if let Some(val) = web {
		(val.web_crt, val.web_key)
	} else {
		(None, None)
	};
	// Configure the engine
	let engine = EngineOptions::default()
		.with_node_membership_refresh_interval(node_membership_refresh_interval)
		.with_node_membership_check_interval(node_membership_check_interval)
		.with_node_membership_cleanup_interval(node_membership_cleanup_interval)
		.with_changefeed_gc_interval(changefeed_gc_interval)
		.with_index_compaction_interval(index_compaction_interval);
	// Configure the config
	let Some(bind) = listen_addresses.first().copied() else {
		return Err(anyhow::anyhow!("No listen address provided"));
	};
	let config = Config {
		bind,
		client_ip,
		path,
		user,
		pass,
		no_identification_headers,
		engine,
		crt,
		key,
	};
	composer.check_config(&config).await?;
	// Setup the command-line options
	// Initiate environment
	env::init()?;

	// if ML feature is enabled load the ONNX runtime lib that is embedded
	#[cfg(feature = "ml")]
	crate::core::ml::execution::session::set_environment()
		.context("Failed to initialize ML library")?;

	// Create a token to cancel tasks
	let canceller = CancellationToken::new();
	// Start the datastore
	let datastore = Arc::new(dbs::init::<C>(composer, &config, canceller.clone(), dbs).await?);
    
    // Start the scheduler service
    crate::scheduler::service::start_scheduler_service(datastore.clone(), canceller.clone()).await;

    // === LYXAL OS KERNEL (P19) ===
    info!(target: "lyxal_os", "Booting Lyxal OS Kernel...");
    
    // 1. BootContext (P18/P19: Strict Source of Truth)
    // We let lyxal_net bootstrap itself from Env/Defaults for Identity/Paths.
    // Ideally we would merge Config args here, but for P19 we respect Env strictness.
    let boot_ctx = lyxal_net::boot::bootstrap().unwrap_or_else(|e| {
        error!(target: "lyxal_os", "Bootstrap Failed: {}", e);
        // Fallback to default if env missing (for dev)? Or fail fast?
        // Fail fast is CTO requirement P18.5
        panic!("Lyxal Net Bootstrap Failed: {}", e);
    });

    // 2. Kernel
    let node_id = boot_ctx.config.static_cfg.node_id;
    // Wrapped in Arc<RwLock> for P20.6 API Access
    let kernel = lyxal_os::kernel::Kernel::new(boot_ctx);
    let kernel_arc = Arc::new(tokio::sync::RwLock::new(kernel));

    // 3. Sync Service
    // Registering to kernel requires Write Lock temporarily
    // Wait, registration is usually done at bootstrap.
    // If we lock, we block.
    // But `kernel.register` takes `&mut self`.
    // So we assume `kernel_arc` is the owner of logic now.
    
    let sync_store_arc: Option<std::sync::Arc<dyn lyxal_net::store::SyncStore + Send + Sync>> = if let Some(tree) = datastore.get_kv_tree() {
        Some(std::sync::Arc::new(lyxal_net::LyxalStore::new(std::sync::Arc::new(tree), node_id)))
    } else {
        None
    };
    
    let sync_service = std::sync::Arc::new(lyxal_os::services::sync::SyncService::new(sync_store_arc));
    {
        kernel_arc.write().await.register(sync_service.clone());
    }
    
    // 4. Boot
    {
        if let Err(e) = kernel_arc.write().await.boot().await {
            error!(target: "lyxal_os", "Kernel Boot Failed: {}", e);
            return Err(anyhow::anyhow!("Kernel Boot Failed"));
        }
    }
    
    // 5. Connect Controller
    let sync_controller = sync_service.controller().await;
    if sync_controller.is_some() {
         info!(target: "lyxal_os", "Lyxal Sync Service attached to API.");
    } else {
         warn!(target: "lyxal_os", "Lyxal Sync Service running but Controller unavailable (Mode: Standalone/NoKV?)");
    }

    // 6. Spawn Reconciler Loop (P24)
    {
        let kernel_reconcile = kernel_arc.clone();
        std::thread::spawn(move || {
            let rt = tokio::runtime::Builder::new_current_thread()
                .enable_all()
                .build()
                .expect("Failed to build Reconciler Runtime");
            let local = tokio::task::LocalSet::new();
            local.block_on(&rt, async move {
                info!(target: "lyxal_os", "Reconciler: Loop Started.");
                let mut interval = tokio::time::interval(std::time::Duration::from_millis(1000));
                loop {
                    interval.tick().await;
                    // Acquire Write Lock briefly or long?
                    // Reconcile might do heavy ops (IO). Ideally move IO out of lock or fine-grain.
                    // For P24.0, we lock.
                    let mut k = kernel_reconcile.write().await;
                    if let Err(e) = k.reconcile().await {
                         tracing::error!(target: "lyxal_os", "Reconciler Error: {}", e);
                    }
                }
            });
        });
    }

	// Start the node agent
	let nodetasks = tasks::init(datastore.clone(), canceller.clone(), &config.engine);
	// Build and run the HTTP server using the provided RouterFactory implementation
	// Build and run the HTTP server using the provided RouterFactory implementation
	// Build and run the HTTP server using the provided RouterFactory implementation
	ntw::init::<C>(&config, datastore.clone(), canceller.clone(), sync_controller, Some(kernel_arc.clone())).await?;
	// Shutdown and stop closed tasks
	canceller.cancel();
    
    // === LYXAL OS KERNEL SHUTDOWN ===
    info!(target: "lyxal_os", "Shutdown signal received. Stopping Kernel...");
    if let Err(e) = kernel_arc.write().await.shutdown().await {
         error!(target: "lyxal_os", "Kernel Shutdown Error: {}", e);
    } else {
         info!(target: "lyxal_os", "Kernel Shutdown Complete.");
    }
	// Wait for background tasks to finish
	nodetasks.resolve().await?;
	// Shutdown the datastore
	datastore.shutdown().await?;
	// All ok
	Ok(())
}
