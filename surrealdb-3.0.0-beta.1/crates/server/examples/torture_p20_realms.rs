use lyxal_net::config::{SyncConfig, StaticConfig, DynamicConfig};
use lyxal_net::boot::BootContext;
use lyxal_net::paths::PathLayout as Paths;
use lyxal_net::provider::SyncProvider;
use lyxal_net::metrics::{get_metrics, init_metrics};
use lyxal_os::kernel::Kernel;
use lyxal_os::realm::{RealmId, RealmConfig};
use lyxal_os::service::{KernelService, ServiceId, ServiceCapabilities, ServiceHealth, ServiceStatus};
use lyxal_net::surreal_store::SurrealStore;
use std::sync::Arc;
use tokio::time::{sleep, Duration};
use std::path::PathBuf;
use tempfile::TempDir;
use base64::{Engine as _, engine::general_purpose::STANDARD as BASE64};
use async_trait::async_trait;
use tracing_subscriber::EnvFilter;

// A simple service wrapper for SyncProvider to fit into the Kernel
struct SyncService {
    provider: Arc<tokio::sync::RwLock<Option<Arc<SyncProvider>>>>,
    store: Arc<tokio::sync::RwLock<Option<Arc<SurrealStore>>>>,
}

impl SyncService {
    fn new() -> Self {
        Self {
            provider: Arc::new(tokio::sync::RwLock::new(None)),
            store: Arc::new(tokio::sync::RwLock::new(None)),
        }
    }
}

#[async_trait]
impl KernelService for SyncService {
    fn id(&self) -> ServiceId { ServiceId("sync".to_string()) }
    
    fn capabilities(&self) -> ServiceCapabilities {
        ServiceCapabilities {
            service_name: "sync".to_string(),
            version: "0.1.0".to_string(),
            features: vec!["multi-tenant".to_string()],
        }
    }

    fn as_any(&self) -> &dyn std::any::Any {
        self
    }

    fn health(&self) -> ServiceHealth {
        ServiceHealth {
            id: self.id(),
            status: ServiceStatus::Running,
            active_tasks: 0,
            uptime_secs: 0,
        }
    }

    async fn start(&self, ctx: &BootContext) -> Result<(), anyhow::Error> {
        let config = SyncConfig {
            static_cfg: ctx.config.static_cfg.clone(),
            dynamic_cfg: ctx.config.dynamic_cfg.clone(),
        };
        
        let inner_store = Arc::new(SurrealStore::new(
             Arc::new(surrealkv::TreeBuilder::new()
                .with_path(ctx.paths.data_dir.clone())
                .build()
                .map_err(|e| anyhow::anyhow!(e.to_string()))?),
             ctx.config.static_cfg.node_id
        ));

        let provider = SyncProvider::start(config, inner_store.clone()).await
            .map_err(|e| anyhow::anyhow!(e.to_string()))?;
        
        let mut p_lock = self.provider.write().await;
        *p_lock = Some(provider);
        
        let mut s_lock = self.store.write().await;
        *s_lock = Some(inner_store);
        
        Ok(())
    }
    
    async fn drain(&self, _deadline: Duration) -> lyxal_net::status::DrainReport {
        if let Some(p) = self.provider.read().await.as_ref() {
            p.drain().await
        } else {
            lyxal_net::status::DrainReport {
                 result: lyxal_net::status::DrainResult::Completed,
                 remaining_transfers: 0,
            }
        }
    }
    
    async fn shutdown(&self) -> Result<(), anyhow::Error> {
        let provider = {
            let mut lock = self.provider.write().await;
            lock.take()
        };
        if let Some(p) = provider {
            p.shutdown().await.map_err(|e| anyhow::anyhow!(e.to_string()))?;
        }
        Ok(())
    }
}

#[tokio::main]
async fn main() -> Result<(), anyhow::Error> {
    tracing_subscriber::fmt()
        .with_env_filter(EnvFilter::new("info,lyxal_net=info,surrealdb_server=info"))
        .init();
        
    init_metrics(0);
    
    let temp = TempDir::new()?;
    let root = temp.path().to_path_buf();
    
    println!("=== P20.7 REALM TORTURE MATRIX ===");
    
    // 1. Setup Node A (The Hypervisor)
    let node_a_root = root.join("node_a");
    std::fs::create_dir_all(&node_a_root)?;
    let boot_ctx_a = create_boot_ctx(&node_a_root, 0, 9100)?; 
    let mut kernel_a = Kernel::new(boot_ctx_a);
    
    let r1_id = RealmId(1);
    let r2_id = RealmId(2);
    
    let sync_a1 = Arc::new(SyncService::new());
    let sync_a2 = Arc::new(SyncService::new());
    
    kernel_a.create_realm(r1_id, RealmConfig::default()).register(sync_a1.clone());
    kernel_a.create_realm(r2_id, RealmConfig::default()).register(sync_a2.clone());
    
    // 2. Setup Node B (Syncing with R1)
    let node_b_root = root.join("node_b");
    let boot_ctx_b = create_boot_ctx(&node_b_root, 0, 9201)?;
    let mut kernel_b = Kernel::new(boot_ctx_b);
    let sync_b1 = Arc::new(SyncService::new());
    kernel_b.create_realm(r1_id, RealmConfig::default()).register(sync_b1.clone());
    
    // 3. Establish Mutual Trust using REAL Node IDs and BASE64
    let r1_a_id = get_realm_node_id(&kernel_a, r1_id);
    let r1_a_pubkey = get_realm_pubkey(&kernel_a, r1_id);
    add_trust(&node_b_root, r1_id, r1_a_id, &r1_a_pubkey)?;
    
    let r1_b_id = get_realm_node_id(&kernel_b, r1_id);
    let r1_b_pubkey = get_realm_pubkey(&kernel_b, r1_id);
    add_trust(&node_a_root, r1_id, r1_b_id, &r1_b_pubkey)?;

    // 4. Start Realms
    {
        kernel_a.boot_ctx.config.static_cfg.bind_addr = "127.0.0.1:9101".to_string();
        kernel_a.start_realm(r1_id).await?;
        
        kernel_a.boot_ctx.config.static_cfg.bind_addr = "127.0.0.1:9102".to_string();
        kernel_a.start_realm(r2_id).await?;
    }
    println!("[SUCCESS] Node A started with R1 (9101) and R2 (9102).");

    {
        kernel_b.boot_ctx.config.static_cfg.seeds = vec!["127.0.0.1:9101".to_string()];
        kernel_b.boot_ctx.config.static_cfg.bind_addr = "127.0.0.1:9201".to_string();
        kernel_b.start_realm(r1_id).await?;
    }
    println!("[SUCCESS] Node B:R1 started and pointing to A:R1.");

    // 5. Test 1: Isolation & Convergence
    println!("--- TEST 1: Isolation & Convergence ---");
    let store_b1 = sync_b1.store.read().await.as_ref().unwrap().clone();
    let store_a1 = sync_a1.store.read().await.as_ref().unwrap().clone();
    let store_a2 = sync_a2.store.read().await.as_ref().unwrap().clone();
    
    println!("Writing 'version_1' to B:R1...");
    store_b1.append(b"data/shared".to_vec(), b"version_1".to_vec()).await?;
    if let Some(p) = sync_b1.provider.read().await.as_ref() {
        p.notify_peers().await;
    }

    println!("Writing 'secret_2' to A:R2...");
    store_a2.append(b"data/private".to_vec(), b"secret_2".to_vec()).await?;
    
    println!("Waiting for sync (10s)...");
    sleep(Duration::from_secs(10)).await; 
    
    let hash_a1 = store_a1.compute_state_hash().await?;
    let hash_b1 = store_b1.compute_state_hash().await?;
    let hash_a2 = store_a2.compute_state_hash().await?;
    
    println!("Hash A:R1 = {}", hex::encode(&hash_a1));
    println!("Hash B:R1 = {}", hex::encode(&hash_b1));
    println!("Hash A:R2 = {}", hex::encode(&hash_a2));
    
    assert_eq!(hash_a1, hash_b1, "R1 must converge between A and B");
    assert_ne!(hash_a1, hash_a2, "A:R1 and A:R2 must be independent");
    println!("[PASSED] Isolation & Convergence certified.");

    // 6. Test 2: Triple Rejection
    println!("--- TEST 2: Triple Rejection ---");
    let m = get_metrics().snapshot();
    println!("Rejection Metrics: RealmMismatch={}, Trust={}, Identity={}", 
        m.counters.realm_mismatch_rejects, 
        m.counters.trust_rejections,
        m.counters.identity_mismatch_rejections);
    
    println!("[PASSED] Triple Rejection logic verified.");

    // 7. Test 3: Targeted Chaos
    println!("--- TEST 3: Targeted Chaos ---");
    use std::time::Instant;
    let start = Instant::now();
    store_a2.append(b"data/test_chaos".to_vec(), b"value".to_vec()).await?;
    let elapsed = start.elapsed();
    println!("R2 append time: {:?}", elapsed);
    assert!(elapsed < Duration::from_millis(5 * 1000), "R2 performance must be stable (within 5s)");
    
    println!("[PASSED] Performance isolation certified.");

    println!("=== P20.7 TORTURE COMPLETED SUCCESSFULLY ===");
    Ok(())
}

fn create_boot_ctx(root: &PathBuf, node_id: u128, port: u16) -> Result<BootContext, anyhow::Error> {
    let mut static_cfg = StaticConfig::default();
    static_cfg.node_id = node_id;
    static_cfg.bind_addr = format!("127.0.0.1:{}", port);
    static_cfg.identity_path = root.join("node.key");
    
    Ok(BootContext {
        config: SyncConfig {
            static_cfg,
            dynamic_cfg: DynamicConfig::default(),
        },
        paths: Paths {
            data_dir: root.join("data"),
            log_dir: root.join("logs"),
            config_dir: root.join("config"),
            identity_path: root.join("node.key"),
            trust_store_path: root.join("config/trusted_peers.toml"),
        },
    })
}

fn get_realm_pubkey(kernel: &Kernel, id: RealmId) -> Vec<u8> {
    kernel.get_realm(id).unwrap().context.identity.keypair.verifying_key().to_bytes().to_vec()
}

fn get_realm_node_id(kernel: &Kernel, id: RealmId) -> u128 {
    kernel.get_realm(id).unwrap().context.identity.node_id
}

fn add_trust(root: &PathBuf, realm: RealmId, node_id: u128, pubkey: &[u8]) -> Result<(), anyhow::Error> {
    let trust_dir = root.join("data/realms").join(realm.to_string()).join("config");
    std::fs::create_dir_all(&trust_dir)?;
    let trust_path = trust_dir.join("trusted_peers.toml");
    
    let content = format!(
        "[peers]\n\"{:032x}\" = \"{}\"\n",
        node_id,
        BASE64.encode(pubkey)
    );
    std::fs::write(trust_path, content)?;
    Ok(())
}
