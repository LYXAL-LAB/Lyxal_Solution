use std::sync::Arc;
use lyxal_os::kernel::{Kernel};
use lyxal_net::boot::BootContext;
use lyxal_net::StaticConfig;
use lyxal_os::transactions::{TransactionRequest, TransactionKind};
use lyxal_os::account::{AccountId, Account};
use ed25519_dalek::{SigningKey, Signer};
use rand::rngs::OsRng;

async fn setup_kernel() -> Arc<Kernel> {
    unsafe { std::env::set_var("LYXAL_USE_MOCK_CONSENSUS", "1"); }
    let temp_dir = tempfile::tempdir().unwrap();
    let root = temp_dir.into_path(); // This "leaks" it or transfers ownership to us, and it won't be deleted on drop.
    let mut config = StaticConfig::default();
    config.node_id = 1;
    let boot_ctx = BootContext::new(config, root);
    let kernel = Arc::new(Kernel::new(boot_ctx));
    kernel.consensus.force_leadership().await.unwrap();
    kernel
}

fn to_id_key(s: &str) -> [u8; 32] {
    *blake3::hash(s.as_bytes()).as_bytes()
}

#[tokio::test]
async fn test_p31_s1_velocity_attack() {
    let kernel = setup_kernel().await;
    let account_id = 0x1111;
    let mut csprng = OsRng;
    let signing_key = SigningKey::generate(&mut csprng);
    
    // Create account with tight velocity limit
    {
        let mut reg = kernel.accounts.write();
        let mut acc = Account::new(account_id, signing_key.verifying_key().to_bytes());
        acc.balance = 1000000;
        reg.insert(acc);
    }
    
    // Attempt 15 transactions
    for i in 0..15 {
        let req = TransactionRequest {
             kind: TransactionKind::Debit,
             from: Some(account_id),
             to: Some(0x9999),
             amount: 1,
             reason: "test".into(),
             idempotency_key: to_id_key(&format!("velocity_test_{}", i)),
        };
        // Signature
        let nonce = (i + 1) as u64;
        let body_bytes = bincode::serialize(&req).unwrap();
        let mut hasher = blake3::Hasher::new();
        hasher.update(b"POST");
        hasher.update(b"/lyxal/billing/tx");
        hasher.update(&nonce.to_be_bytes());
        hasher.update(blake3::hash(&body_bytes).as_bytes());
        hasher.update(&req.idempotency_key);
        let msg = hasher.finalize();
        let sig = signing_key.sign(msg.as_bytes()).to_bytes().to_vec();

        let res = kernel.handle_billing_tx(account_id, nonce, sig, req).await;
        if i < 10 {
            assert!(res.is_ok(), "Tx {} should pass, but got error: {:?}", i, res.err());
        } else {
            assert!(res.is_err(), "Tx {} should be blocked by velocity", i);
            let err = res.unwrap_err().to_string();
            assert!(err.contains("Velocity limit"), "Error should mention velocity: {}", err);
        }
    }
}

#[tokio::test]
async fn test_p31_s2_whale_tx() {
    let kernel = setup_kernel().await;
    let account_id = 0x2222;
    let mut csprng = OsRng;
    let signing_key = SigningKey::generate(&mut csprng);
    
    {
        let mut reg = kernel.accounts.write();
        reg.insert(Account::new(account_id, signing_key.verifying_key().to_bytes()));
    }

    let req = TransactionRequest {
         kind: TransactionKind::Debit,
         from: Some(account_id),
         to: Some(0x9999),
         amount: 2_000_000_000, // Above default 1B limit
         reason: "whale".into(),
         idempotency_key: to_id_key("whale"),
    };
    
    let nonce: u64 = 1;
    let mut hasher = blake3::Hasher::new();
    hasher.update(b"POST");
    hasher.update(b"/lyxal/billing/tx");
    hasher.update(&nonce.to_be_bytes());
    hasher.update(blake3::hash(&bincode::serialize(&req).unwrap()).as_bytes());
    hasher.update(&req.idempotency_key);
    let msg = hasher.finalize();
    let sig = signing_key.sign(msg.as_bytes()).to_bytes().to_vec();

    let res = kernel.handle_billing_tx(account_id, nonce, sig, req).await;
    assert!(res.is_err(), "Whale Tx should fail, but got Ok");
    let err = res.unwrap_err().to_string();
    assert!(err.contains("exceeds max"), "Error should mention 'exceeds max', but got: {}", err);
}

#[tokio::test]
async fn test_p31_s4_freeze() {
    let kernel = setup_kernel().await;
    let account_id = 0x4444;
    let mut csprng = OsRng;
    let signing_key = SigningKey::generate(&mut csprng);
    
    {
        let mut reg = kernel.accounts.write();
        let mut acc = Account::new(account_id, signing_key.verifying_key().to_bytes());
        acc.balance = 1000;
        reg.insert(acc);
    }

    // 1. Freeze
    kernel.safety.governance.write().freeze(account_id, "Abuse suspected".into(), "admin".into()).expect("Freeze failed");

    // 2. Attempt Tx
    let req = TransactionRequest {
         kind: TransactionKind::Debit,
         from: Some(account_id),
         to: Some(0x9999),
         amount: 10,
         reason: "after_freeze".into(),
         idempotency_key: to_id_key("after_freeze"),
    };
    let nonce: u64 = 1;
    let mut hasher = blake3::Hasher::new();
    hasher.update(b"POST");
    hasher.update(b"/lyxal/billing/tx");
    hasher.update(&nonce.to_be_bytes());
    hasher.update(blake3::hash(&bincode::serialize(&req).unwrap()).as_bytes());
    hasher.update(&req.idempotency_key);
    let msg = hasher.finalize();
    let sig = signing_key.sign(msg.as_bytes()).to_bytes().to_vec();

    let res = kernel.handle_billing_tx(account_id, nonce, sig, req).await;
    assert!(res.is_err());
    assert!(res.unwrap_err().to_string().contains("Account Frozen"));

    // 3. Admin Audit
    let logs = kernel.safety.audit.read().read_entries(Some(account_id), 10).unwrap();
    assert!(logs.iter().any(|e| e.decision == lyxal_os::safety::audit::SafetyDecision::Frozen));
}

#[tokio::test]
async fn test_p31_s4_dispute() {
    let kernel = setup_kernel().await;
    let account_id = 0x5555;
    let mut csprng = OsRng;
    let signing_key = SigningKey::generate(&mut csprng);
    
    {
        let mut reg = kernel.accounts.write();
        let mut acc = Account::new(account_id, signing_key.verifying_key().to_bytes());
        acc.balance = 1000;
        acc.credit_limit = 0; // Strict balance
        reg.insert(acc);
    }

    // 1. Dispute a Tx or just hold 800 credits
    kernel.safety.governance.write().dispute_tx(account_id, 0x999, 800, "Suspected fraud".into()).expect("Dispute failed");

    // 2. Attempt to spend 300 (Available = 1000 - 800 = 200)
    let req = TransactionRequest {
         kind: TransactionKind::Debit,
         from: Some(account_id),
         to: Some(0x9999),
         amount: 300,
         reason: "spend_under_dispute".into(),
         idempotency_key: to_id_key("spend_under_dispute"),
    };
    let nonce: u64 = 1;
    let mut hasher = blake3::Hasher::new();
    hasher.update(b"POST");
    hasher.update(b"/lyxal/billing/tx");
    hasher.update(&nonce.to_be_bytes());
    hasher.update(blake3::hash(&bincode::serialize(&req).unwrap()).as_bytes());
    hasher.update(&req.idempotency_key);
    let msg = hasher.finalize();
    let sig = signing_key.sign(msg.as_bytes()).to_bytes().to_vec();

    let res = kernel.handle_billing_tx(account_id, nonce, sig, req).await;
    assert!(res.is_err(), "Should fail due to held funds");
    assert!(res.unwrap_err().to_string().contains("Insufficient available funds"));

    // 3. Audit
    let logs = kernel.safety.audit.read().read_entries(Some(account_id), 10).unwrap();
    assert!(logs.iter().any(|e| e.decision == lyxal_os::safety::audit::SafetyDecision::Disputed));
}

#[tokio::test]
async fn test_p31_s5_audit_tamper() {
    let kernel = setup_kernel().await;
    
    // Log something
    kernel.safety.audit.write().log(0, 0x123, "test".into(), 0xabc, lyxal_os::safety::audit::SafetyAction::SystemStart, lyxal_os::safety::audit::SafetyDecision::Allow, 0).expect("Log failed");
    
    // Valid
    assert!(kernel.safety.audit.read().verify_integrity().unwrap());

    // Corrupt file
    let path = kernel.boot_ctx.paths.data_dir.join("audit.bin");
    let mut data = std::fs::read(&path).unwrap();
    // Flip one byte in the middle
    let len = data.len();
    data[len / 2] ^= 0xFF;
    std::fs::write(&path, data).unwrap();

    // Should fail
    assert!(!kernel.safety.audit.read().verify_integrity().unwrap());
}
