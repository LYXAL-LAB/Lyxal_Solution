use lyxal_os::kernel::Kernel;
use lyxal_net::boot::BootContext;
use lyxal_net::config::{StaticConfig, SyncConfig, DynamicConfig};
use lyxal_net::paths::PathLayout;
use lyxal_net::quotas::RealmQuota;
use lyxal_os::transactions::{Transaction, TransactionKind};
use lyxal_net::identity::NodeIdentity;
use std::time::Duration;
use tempfile::TempDir;

#[tokio::test]
async fn test_e2e_transaction_sync_flow() -> anyhow::Result<()> {
    // 1. Setup Environment
    let temp_dir = TempDir::new()?;
    let data_dir = temp_dir.path().to_path_buf();
    let config_dir = data_dir.join("config");
    std::fs::create_dir_all(&config_dir)?;

    // Generate Identity
    let identity_path = data_dir.join("identity.pem");
    let identity = NodeIdentity::load_or_generate(&identity_path)?;

    // Create BootContext
    // Note: BootContext wants PathLayout which is usually resolved from env or root
    // We construct it manually for test if possible, or use struct literal if fields are pub
    
    let mut static_cfg = StaticConfig::new(lyxal_net::config::Profile::Dev);
    static_cfg.node_id = identity.node_id;
    static_cfg.identity_path = identity_path.clone();
    
    let paths = PathLayout {
        data_dir: data_dir.clone(),
        log_dir: data_dir.join("logs"),
        config_dir: config_dir.clone(),
        trust_store_path: config_dir.join("trusted.toml"),
        identity_path: identity_path.clone(),
    };

    let boot_ctx = BootContext {
        paths,
        config: SyncConfig {
            static_cfg,
            dynamic_cfg: DynamicConfig::default(),
        },
        quota: RealmQuota::default(),
        stats: None,
        observer: None,
    };

    // 2. Initialize Kernel
    let kernel = Kernel::new(boot_ctx);
    
    // 3. Hijack the Sync Channel (The "Pump")
    // Note: We need to register a fake SyncService or just grab the RX if exposed.
    // The Kernel initializes the channel in new(), so we can grab it immediately using our test helper.
    let mut ledger_rx = kernel.get_ledger_rx_for_test()
        .ok_or_else(|| anyhow::anyhow!("Failed to grab ledger channel"))?;

    // 4. Create & Commit a Transaction
    let tx_id = 12345u128;
    let tx = Transaction {
        id: tx_id,
        ts_ns: 1000,
        kind: TransactionKind::Credit,
        from: None,
        to: Some(999),
        amount: 5000,
        currency: 0,
        reason: "E2E Test".into(),
        idempotency_key: [1u8; 32],
        signature: vec![],
        receipt: None,
    };

    println!("Committing Transaction {}...", tx_id);
    
    // Simulate what handle_billing_tx does internally: append to store
    // Since we need to use the store that has the channel injected
    kernel.tx_store.append(tx).await?;

    println!("Transaction Committed. Waiting for Sync Pump...");

    // 5. Verify Propagation
    // We expect a LogWireItem to appear on the channel
    let received = tokio::time::timeout(Duration::from_secs(2), ledger_rx.recv())
        .await
        .map_err(|_| anyhow::anyhow!("Timeout waiting for sync event"))?
        .ok_or_else(|| anyhow::anyhow!("Channel closed unexpectedly"))?;

    println!("Received Sync Event!");
    
    // 6. Assertions
    // Key should be _ledger/tx/{id}
    let expected_key_suffix = tx_id.to_be_bytes();
    assert!(received.key.ends_with(&expected_key_suffix), "Key mismatch");
    
    // Envelope check
    assert_eq!(received.envelope.node_id, identity.node_id, "Origin Node ID mismatch");
    assert_eq!(received.envelope.timestamp, 1000, "Timestamp mismatch");
    
    // Payload check (Deserialize back to Transaction)
    let deserialized_tx: Transaction = bincode::deserialize(&received.envelope.payload)?;
    assert_eq!(deserialized_tx.id, tx_id);
    assert_eq!(deserialized_tx.amount, 5000);

    println!("E2E Test Passed: Transaction -> Store -> Pump -> Network Channel");

    Ok(())
}
