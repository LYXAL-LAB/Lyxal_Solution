use std::sync::Arc;
use std::time::Duration;
use tokio::time::sleep;
use lyxal_net::config::{SyncConfig, StaticConfig};
use lyxal_net::provider::SyncProvider;
use lyxal_net::surreal_store::SurrealStore;
use lyxal_net::identity::NodeIdentity;
use surrealkv::TreeBuilder;
use tempfile::tempdir;

#[tokio::main]
async fn main() -> Result<(), anyhow::Error> {
    // Enable logging
    let _ = tracing_subscriber::fmt()
        .with_env_filter(tracing_subscriber::EnvFilter::from_default_env())
        .try_init();

    // Enable TOFU mode for dynamic test network
    unsafe {
        std::env::set_var("LYXAL_TRUST_MODE", "TOFU");
    }
    
    // Initialize global metrics to prevent panic (shared across all in-process nodes)
    lyxal_net::metrics::init_metrics(0);
    println!("=== P20.8 SECURITY & GOSSIP TORTURE MATRIX ===");

    let tmp = tempdir()?;
    let realm_1_id: u128 = 0xDEADC0DE_0000_0000_0000_0000_0000_0001;
    let realm_2_id: u128 = 0xDEADC0DE_0000_0000_0000_0000_0000_0002;

    // --- SCENARIO 1: GOSSIP PROPAGATION ---
    println!("--- TEST 1: Gossip Propagation ---");
    
    // Node A (Seed)
    let node_a = spawn_node("NodeA", 9110, realm_1_id, vec![]).await?;
    // Node B (Connects to A)
    let node_b = spawn_node("NodeB", 9111, realm_1_id, vec!["127.0.0.1:9110".to_string()]).await?;
    // Node C (Connects to B)
    let node_c = spawn_node("NodeC", 9112, realm_1_id, vec!["127.0.0.1:9111".to_string()]).await?;

    println!("[INFO] Waiting for gossip hints to propagate...");
    // A learns about B (direct)
    // B learns about A (direct) and C (direct)
    // C learns about B (direct)
    // Through gossip, A should learn about C from B.
    
    let mut success = false;
    for i in 0..15 {
        sleep(Duration::from_secs(2)).await;
        let peers_a = node_a.peers_map().await;
        let peer_ids: Vec<String> = peers_a.keys().map(|id| format!("{:x}", id)).collect();
        println!("[NodeA] Connected peers: {:?}", peer_ids);
        
        // Check if node_c's identity is known by A
        let node_c_id = node_c.identity.node_id;
        if peers_a.contains_key(&node_c_id) {
            println!("[SUCCESS] Node A discovered Node C via gossip!");
            success = true;
            break;
        }
        println!("[WAIT] Node A still only knows {}/2 peers. (Attempt {})", peers_a.len(), i);
    }

    if !success {
        anyhow::bail!("Gossip propagation failed: Node A did not discover Node C");
    }

    // --- SCENARIO 2: REALM ISOLATION ---
    println!("--- TEST 2: Realm Isolation (Anti-Mixup) ---");
    // Node D is in Realm 2, pointing to Node A (Realm 1)
    let node_d = spawn_node("NodeD", 9113, realm_2_id, vec!["127.0.0.1:9110".to_string()]).await?;
    
    sleep(Duration::from_secs(3)).await;
    let peers_a = node_a.peers_map().await;
    let node_d_id = node_d.identity.node_id;
    if peers_a.contains_key(&node_d_id) {
        anyhow::bail!("SECURITY BREACH: Node A (R1) accepted connection from Node D (R2)!");
    }
    println!("[SUCCESS] Node A correctly ignored Node D due to Realm mismatch.");

    println!("=== P20.8 SECURITY & GOSSIP COMPLETED SUCCESSFULLY ===");
    Ok(())
}

async fn spawn_node(name: &str, port: u16, realm_id: u128, seeds: Vec<String>) -> Result<Arc<SyncProvider>, anyhow::Error> {
    let tmp = tempdir()?;
    let data_dir = tmp.path().to_path_buf();
    std::fs::create_dir_all(&data_dir)?;

    let identity_path = data_dir.join("identity.pem");
    let identity = NodeIdentity::load_or_generate(&identity_path)?;
    
    let trust_path = data_dir.join("trusted_peers.toml");
    // For simplicity in this test, we skip strict trust configuration (empty TOML)
    // We rely on LYXAL_TRUST_MODE=TOFU
    std::fs::write(&trust_path, "")?;

    let config = SyncConfig {
        static_cfg: StaticConfig {
            node_id: identity.node_id,
            realm_id,
            bind_addr: format!("127.0.0.1:{}", port),
            identity_path,
            trust_store_path: trust_path,
            seeds,
            max_outbound_peers: 5,
            max_concurrent_dials: 2,
            dial_timeout_ms: 1000,
            bootstrap_interval_secs: 2,
            ..Default::default()
        },
        dynamic_cfg: Default::default(),
    };

    let tree = TreeBuilder::new().with_path(data_dir.join("store")).build()?;
    let store = Arc::new(SurrealStore::new(Arc::new(tree), identity.node_id));
    
    let provider = SyncProvider::start(config, store).await?;
    println!("[{}] Started on port {} (Realm: {:x}, ID: {:x})", name, port, realm_id, identity.node_id);
    
    Ok(provider)
}
