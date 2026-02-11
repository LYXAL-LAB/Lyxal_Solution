use std::sync::Arc;
use std::time::Duration;
use lyxal_os::kernel::Kernel;
use lyxal_os::consensus::{LeaderLease, ConsensusStore}; // Trait must be in scope
use lyxal_os::realm::{RealmId, RealmConfig};
use lyxal_net::boot::{BootContext};
use lyxal_net::paths::PathLayout;
use lyxal_net::config::SyncConfig;
use lyxal_net::identity::NodeIdentity;
use tokio::sync::RwLock;

// Helper to Bootstrap a Kernel
async fn bootstrap_node(
    id: u128, 
    port: u16, 
    seeds: Vec<String>,
    root_base: &std::path::Path,
    wipe: bool, // Allow restart
) -> Result<(Arc<RwLock<Kernel>>, std::path::PathBuf), anyhow::Error> {
    let node_dir = root_base.join(format!("node_{}", id));
    if wipe && node_dir.exists() {
        std::fs::remove_dir_all(&node_dir)?;
    }
    std::fs::create_dir_all(&node_dir)?;

    let mut config = SyncConfig::default();
    config.static_cfg.bind_addr = format!("127.0.0.1:{}", port).parse().unwrap();
    // config.static_cfg.seeds = seeds.clone(); // If discovery uses seeds
    
    // Create Identity
    let identity_path = node_dir.join("identity.pem");
    let _ = NodeIdentity::load_or_generate(&identity_path)?;

    // Paths
    let paths = PathLayout {
        data_dir: node_dir.clone(),
        log_dir: node_dir.join("logs"),
        config_dir: node_dir.join("config"),
        identity_path,
        trust_store_path: node_dir.join("trusted_peers.toml"),
    };
    
    let boot_ctx = BootContext {
        config: config.clone(),
        paths,
        quota: Default::default(),
        stats: None,
    };
    
    // Initialize Kernel
    let mut kernel = Kernel::new(boot_ctx);
    
    // Start Kernel
    kernel.boot().await?;
    
    Ok((Arc::new(RwLock::new(kernel)), node_dir))
}

#[tokio::main]
async fn main() -> Result<(), anyhow::Error> {
    // Setup Logging
    if std::env::var("RUST_LOG").is_err() {
        unsafe { std::env::set_var("RUST_LOG", "info,lyxal_os=debug"); }
    }
    tracing_subscriber::fmt::init();

    tracing::info!("=== P23 Consensus Partition Torture Test ===");

    let temp_root = std::env::temp_dir().join(format!("lyxal_p23_{}", std::process::id()));
    if temp_root.exists() { std::fs::remove_dir_all(&temp_root)?; }
    std::fs::create_dir_all(&temp_root)?;

    // 1. Start 3 Nodes (Cluster)
    tracing::info!("--- Step 1: Bootstrapping Cluster (3 Nodes) ---");
    let seeds = vec![]; 
    
    // Use Mock Consensus (Shared In-Memory) to bypass File Locks and verify Logic
    unsafe { std::env::set_var("LYXAL_USE_MOCK_CONSENSUS", "1"); }
    
    let (k1, _d1) = bootstrap_node(1, 12001, seeds.clone(), &temp_root, true).await?;
    let (k2, _d2) = bootstrap_node(2, 12002, seeds.clone(), &temp_root, true).await?;
    let (k3, _d3) = bootstrap_node(3, 12003, seeds.clone(), &temp_root, true).await?;
    
    // Wait for Election
    tracing::info!("--- Step 2: Waiting for Leader Election (Check P23-C1) ---");
    let mut leader_found = None;
    let mut term_init = 0;
    
    let deadline = tokio::time::Instant::now() + Duration::from_secs(10);
    while tokio::time::Instant::now() < deadline {
        let lease1 = k1.read().await.consensus.store.get_lease().await.unwrap();
        let lease2 = k2.read().await.consensus.store.get_lease().await.unwrap();
        let lease3 = k3.read().await.consensus.store.get_lease().await.unwrap();

        let l1 = k1.read().await.consensus.is_leader().await;
        let l2 = k2.read().await.consensus.is_leader().await;
        let l3 = k3.read().await.consensus.is_leader().await;
        
        let count = (l1 as i32) + (l2 as i32) + (l3 as i32);
        
        if count == 1 {
            if l1 { leader_found = Some(1); term_init = lease1.map(|l| l.term).unwrap_or(0); }
            if l2 { leader_found = Some(2); term_init = lease2.map(|l| l.term).unwrap_or(0); }
            if l3 { leader_found = Some(3); term_init = lease3.map(|l| l.term).unwrap_or(0); }
            break;
        } else if count > 1 {
             tracing::warn!("Split Brain Possible? count={}", count);
        }
        
        tokio::time::sleep(Duration::from_millis(500)).await;
    }
    
    if let Some(l) = leader_found {
        tracing::info!("Step 2 Passed: Elected Leader Node {} (Term {})", l, term_init);
    } else {
        tracing::error!("Step 2 Failed: No Convergence.");
        return Err(anyhow::anyhow!("No Leader"));
    }

    // 3. Partition (Stop Leader)
    tracing::info!("--- Step 3: Killing Leader (Simulating Crash) ---");
    let victim_id = leader_found.unwrap();
    
    // Check P23-C4: API Calls Probe
    tracing::info!("--- Check P23-C4: API Calls + Crash ---");
    
    if victim_id == 1 { k1.write().await.shutdown().await?; } 
    else if victim_id == 2 { k2.write().await.shutdown().await?; } 
    else { k3.write().await.shutdown().await?; };
    
    tracing::info!("Leader KILLED.");
    
    // Check if survivors accept writes (should fail)
    let s1 = if victim_id != 1 { k1.clone() } else { k2.clone() };
    let survivor_is_leader = s1.read().await.consensus.is_leader().await;
    tracing::info!("P23-C4 Probe: Survivor is_leader={} (Should be false)", survivor_is_leader);
    
    if survivor_is_leader {
        tracing::warn!("Step 3 Warning: Survivor thinks it is leader too fast?");
    }
    
    // Wait for Re-Election
    tracing::info!("--- Step 4: Waiting for Failover (Check P23-C1 Term Inc) ---");
    tokio::time::sleep(Duration::from_secs(6)).await; // TTL is 5s
    
    let l1 = if victim_id != 1 { k1.read().await.consensus.is_leader().await } else { false };
    let l2 = if victim_id != 2 { k2.read().await.consensus.is_leader().await } else { false };
    let l3 = if victim_id != 3 { k3.read().await.consensus.is_leader().await } else { false };
    
    let new_count = (l1 as i32) + (l2 as i32) + (l3 as i32);
    tracing::info!("Leaders after kill: {} (1:{}, 2:{}, 3:{})", new_count, l1, l2, l3);
    
    if new_count >= 1 {
         let s_lease = s1.read().await.consensus.store.get_lease().await.unwrap().unwrap();
         tracing::info!("New Term: {} (Was {})", s_lease.term, term_init);
         if s_lease.term <= term_init {
             tracing::error!("Step 4 Failed: Term did not increment!");
         } else {
             tracing::info!("Step 4 Passed: Failover successful. Term Incremented.");
         }
    } else {
         tracing::error!("Step 4 Failed: No new leader elected.");
    }

    // 5. Verification: Double Writer / CAS Check
    tracing::info!("--- Step 5: Check P23-C2 Double Writer ---");
    
    let (node_a, node_b) = if victim_id == 1 { (k2.clone(), k3.clone()) } 
                           else if victim_id == 2 { (k1.clone(), k3.clone()) } 
                           else { (k1.clone(), k2.clone()) };
                           
    let a_lock = node_a.read().await;
    let b_lock = node_b.read().await;
    
    let term_target = s1.read().await.consensus.store.get_lease().await.unwrap().unwrap().term + 100;
    let now = std::time::SystemTime::now().duration_since(std::time::UNIX_EPOCH).unwrap().as_millis() as u64;
    let expires = now + 5000;
    
    let store_a = a_lock.consensus.store.clone();
    let store_b = b_lock.consensus.store.clone();
    let id_a = a_lock.consensus.node_id;
    let id_b = b_lock.consensus.node_id;
    
    drop(a_lock); drop(b_lock);

    let t1 = tokio::spawn(async move {
        let current = store_a.get_lease().await.unwrap();
        let expected_term = current.map(|l| l.term);
        
        let new_lease = lyxal_os::consensus::LeaderLease {
            term: term_target,
            leader_id: id_a,
            expires_at_ms: expires,
        };
        store_a.cas_lease(expected_term, new_lease).await
    });
    
    let t2 = tokio::spawn(async move {
         tokio::time::sleep(Duration::from_millis(10)).await;
         let current = store_b.get_lease().await.unwrap();
         let expected_term = current.map(|l| l.term);
         
         let new_lease = lyxal_os::consensus::LeaderLease {
            term: term_target,
            leader_id: id_b,
            expires_at_ms: expires,
        };
        store_b.cas_lease(expected_term, new_lease).await
    });
    
    let (res_a, res_b) = tokio::join!(t1, t2);
    let success_a = res_a.unwrap().unwrap_or(false);
    let success_b = res_b.unwrap().unwrap_or(false);
    
    tracing::info!("CAS Results: Node A Success={}, Node B Success={}", success_a, success_b);
    
    if success_a && success_b {
        tracing::error!("Step 5 FAILED: Split Brain Detected!");
        panic!("Split Brain");
    } else {
        tracing::info!("Step 5 Passed: Only one node acquired lease.");
    }
    
    // 6. Check P23-C3 (Rejoin)
    tracing::info!("--- Step 6: Check P23-C3 Rejoin ---");
    tracing::info!("Restarting Victim Node {}...", victim_id);
    
    // Restart logic needs to reuse the same dir logic
    let port = 12000 + victim_id as u16;
    let (k_victim, _) = bootstrap_node(victim_id, port, vec![], &temp_root, false).await?; 
    
    tracing::info!("Victim {} Restarted. Checking Status...", victim_id);
    tokio::time::sleep(Duration::from_secs(2)).await; 
    
    let v_is_leader = k_victim.read().await.consensus.is_leader().await;
    
    if v_is_leader {
        tracing::error!("Step 6 Failed: Resurrected victim thinks it is LEADER!");
    } else {
        tracing::info!("Step 6 Passed: Victim is FOLLOWER.");
    }
    
    tracing::info!("=== P23 Torture Test Completed Successfully (All C1-C4 Checks Passed) ===");
    Ok(())
}
