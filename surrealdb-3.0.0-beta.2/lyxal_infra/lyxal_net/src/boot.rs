use crate::config::{DynamicConfig, Profile, StaticConfig, SyncConfig};
use crate::error::{NetError, Result};
use crate::paths::PathLayout;
use std::env;
use tracing::{error, info, warn};
use tracing_subscriber::{layer::SubscriberExt, util::SubscriberInitExt};

use crate::quotas::{RealmQuota, RealmRuntimeStats};
use std::sync::Arc;

#[derive(Clone, Default)]
pub struct BootContext {
	pub config: SyncConfig,
	pub paths: PathLayout,
	pub quota: RealmQuota,
	pub stats: Option<Arc<RealmRuntimeStats>>,
	pub observer: Option<Arc<dyn crate::accounting_observer::AccountingObserver>>,
}

impl BootContext {
	pub fn new(static_cfg: StaticConfig, root_dir: std::path::PathBuf) -> Self {
		let paths = crate::paths::PathLayout::resolve(Some(root_dir.to_string_lossy().to_string()))
			.unwrap();
		Self {
			config: crate::config::SyncConfig {
				static_cfg,
				dynamic_cfg: crate::config::DynamicConfig::default(),
			},
			paths,
			..Default::default()
		}
	}
}

pub fn bootstrap() -> Result<BootContext> {
	// 1. Resolve Profile (CLI > ENV > Default)
	// For now, Env var "LYXAL_PROFILE"
	let profile =
		match env::var("LYXAL_PROFILE").unwrap_or_else(|_| "dev".into()).to_lowercase().as_str() {
			"prod" => Profile::Prod,
			"edge" => Profile::Edge,
			_ => Profile::Dev,
		};

	// 2. Resolve Paths
	let env_data = env::var("LYXAL_DATA_DIR").ok();
	let paths = PathLayout::resolve(env_data)?;

	// 3. Init Logging (Strict: tracing only, no println)
	// Only init logging if not already set (SurrealDB handles it in embedded mode)
	let _ = init_logging(profile, &paths);

	// 4. Load/Merge Config
	let mut static_cfg = StaticConfig::new(profile);

	// P25: Enforce Cryptographic Node ID
	// We load the identity key early to ensure the NodeID is derived from crypto,
	// ignoring manual LYXAL_NODE_ID overrides which cause Raft quorum mismatches.
	let identity = crate::identity::NodeIdentity::load_or_generate(&paths.identity_path)
		.map_err(|e| NetError::Generic(format!("Failed to load node identity: {}", e)))?;
	static_cfg.node_id = identity.node_id;

	// 4.5 Initialize Metrics early to avoid panics in embedded mode
	crate::metrics::init_metrics(static_cfg.node_id);

	// Apply Paths
	static_cfg.identity_path = paths.identity_path.clone();
	static_cfg.trust_store_path = paths.trust_store_path.clone();

	// Env Overrides for Critical Params
	if let Ok(seed_str) = env::var("LYXAL_SEEDS") {
		static_cfg.seeds = seed_str.split(',').map(|s| s.trim().to_string()).collect();
	}
	if let Ok(bind) = env::var("LYXAL_BIND_ADDR") {
		static_cfg.bind_addr = bind;
	}

	let dynamic_cfg = DynamicConfig::new(profile);

	let config = SyncConfig {
		static_cfg,
		dynamic_cfg,
	};

	// 5. Guardrails / Sanity Check
	// (Actual identity check happens in SyncProvider::start, but we can pre-check existence here)
	if !paths.identity_path.exists() {
		info!(
			target_os = "guardrail",
			event = "identity_missing",
			path = ?paths.identity_path,
			"Identity file missing, will generate on start."
		);
	}

	// 6. Node Ready Event
	info!(
		event = "node_ready",
		profile = ?profile,
		data_dir = ?paths.data_dir,
		log_dir = ?paths.log_dir,
		version = "lyxal-sync 0.1.0",
		"Lyxal Sync Boot Sequence Complete"
	);

	let quota = RealmQuota::default();
	// For standalone bootstrap (CLI), we behave as Root Realm (0)
	let stats = Arc::new(RealmRuntimeStats::new(0, &quota));

	Ok(BootContext {
		config,
		paths,
		quota,
		stats: Some(stats),
		observer: None,
	})
}

fn init_logging(profile: Profile, paths: &PathLayout) -> Result<()> {
	// Log Rotation: Daily
	let file_appender = tracing_appender::rolling::daily(&paths.log_dir, "lyxal.log");
	let (non_blocking, _guard) = tracing_appender::non_blocking(file_appender);
	// Note: _guard must be kept alive!
	// This function returns Result, stripping guard drops it -> no logs.
	// We need to return the worker guard or leak it.
	// For production daemon, we can maybe leak it or store in global.
	// For this impl, let's leak it (common in main) or Box::leak.
	// Better: We are not returning main, so leaking is acceptable for "Application Lifetime" logger.
	std::mem::forget(_guard);

	let env_filter = tracing_subscriber::EnvFilter::try_from_default_env().unwrap_or_else(|_| {
		match profile {
			Profile::Dev => "debug,lyxal_net=debug",
			Profile::Prod => "info,lyxal_net=info",
			Profile::Edge => "warn,lyxal_net=warn",
		}
		.into()
	});

	let builder = tracing_subscriber::registry().with(env_filter);

	match profile {
		Profile::Prod | Profile::Edge => {
			// JSON Format
			let json_layer = tracing_subscriber::fmt::layer()
				.json()
				.with_writer(non_blocking)
				.with_target(false)
				.with_current_span(false);

			// Also log to stdout? Usually no for daemon, but yes for docker.
			// Let's rely on file for JSON persistence, and maybe stdout for orchestrator?
			// CTO Rule: "Structure Logging + Rotation".
			// Let's add stdout as well if needed, but JSON to file is strict requirement.
			// We use file for rotation.

			builder
				.with(json_layer)
				.try_init()
				.map_err(|e| NetError::Generic(format!("Logger init failed: {}", e)))?;
		}
		Profile::Dev => {
			// Pretty for Dev
			let fmt_layer = tracing_subscriber::fmt::layer().pretty().with_writer(std::io::stdout);

			builder
				.with(fmt_layer)
				.try_init()
				.map_err(|e| NetError::Generic(format!("Logger init failed: {}", e)))?;
		}
	}

	Ok(())
}
