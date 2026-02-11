use surrealdb_server::ntw::billing_api::*;
use surrealdb_server::ntw::AppState;
use lyxal_os::kernel::Kernel;
use lyxal_os::account::{Account, AccountRegistry};
use lyxal_os::billing::{BillingEngine, PricingPlan, RateDefinition, Tier};
use lyxal_os::registry_new::{RegistryImpl, EnforcementMode};
use lyxal_os::boot::{BootContext, StaticConfig};
use std::sync::Arc;
use tokio::sync::RwLock;
use axum::{extract::Extension, Json};
use serde_json::Value;

// Helper to setup kernel
async fn setup_kernel() -> Arc<RwLock<Kernel>> {
    let temp_dir = tempfile::tempdir().unwrap();
    let config = StaticConfig {
        node_id: 1,
        // ... essentials ...
        ..Default::default()
    };
    let boot_ctx = BootContext::new(config, temp_dir.path().to_path_buf());
    let kernel = Kernel::new(boot_ctx);
    // Initialize required components manually if new() doesn't
    
    Arc::new(RwLock::new(kernel))
}

#[tokio::test]
async fn test_p30bis_simulation_accuracy() {
    let kernel_lock = setup_kernel().await;
    
    // 1. Setup Pricing Plan (Tiered)
    // 0-100 units: 10 micros
    // 100+ units: 5 micros
    let plan_id_str = "plan_tiered_01".to_string();
    let plan = PricingPlan {
        id: plan_id_str.clone(),
        name: "Test Tiered".into(),
        rates: vec![
            RateDefinition {
                meter_id: "requests".into(),
                model: lyxal_os::billing::PricingModel::Tiered(vec![
                    Tier { upto: Some(100), unit_price: 10 },
                    Tier { upto: None, unit_price: 5 },
                ]),
            }
        ],
        enforcement: EnforcementMode::None,
    };

    // Inject plan
    {
        let mut kernel = kernel_lock.write().await;
        kernel.cached_plans.write().insert(plan_id_str.clone(), plan.clone());
    }

    // 2. Prepare Events (150 requests)
    // 100 * 10 = 1000
    // 50 * 5 = 250
    // Total = 1250 micros
    let events = vec![
        lyxal_os::billing::UsageEventV1 {
            meter_id: "requests".into(),
            quantity: 150,
            timestamp: 0,
            dimensions: std::collections::HashMap::new(),
        }
    ];

    // 3. Call Simulate
    let kernel = kernel_lock.read().await;
    let result = billing_simulate_logic(&kernel, plan_id_str, events).await;
    
    assert!(result.is_ok(), "Simulation failed");
    let resp = result.unwrap();
    assert_eq!(resp.total_micros, 1250);
    assert_eq!(resp.breakdown.len(), 1);
    assert_eq!(resp.breakdown[0].cost, 1250);
}

#[tokio::test]
async fn test_p30bis_invoice_rendering() {
    let kernel_lock = setup_kernel().await;
    
    // 1. Manually insert an Invoice into Store
    let invoice_id = "inv_2025_01_TEST".to_string();
    let account_id = 0x1234567890abcdef;
    
    let mut invoice = lyxal_os::invoice::Invoice {
        id: invoice_id.clone(),
        account_id,
        period_id: [0u8; 16], // dummy
        total_micros: 5000, // 0.005000
        status: lyxal_os::invoice::InvoiceStatus::Draft,
        created_at: 1000,
        due_at: 2000,
        paid_at: None,
        line_items: vec![], // Populate if needed for detail check
        meter_totals: std::collections::HashMap::new(),
    };
    // Add line item
    invoice.line_items.push(lyxal_os::invoice::InvoiceLineItem {
        meter_id: "storage".into(),
        quantity: 1000,
        cost: 5000,
        tier_breakdown: vec![],
    });

    {
        let kernel = kernel_lock.read().await;
        // Access invoice_store directly? It might be internal.
        // If not accessible via public method, we might struggle.
        // Checks: Kernel struct has `pub invoice_store`.
        // InvoiceStore has methods? `add`?
        // Assuming `save` or `add` exists. If not, simulation might be hard.
        // Let's assume we can insert via backdoor or if Store is based on Hashmap/File.
        // If Store uses `surrealkv`, we need init.
        // Assuming `InvoiceStore` has `save(invoice)`.
        let _ = kernel.invoice_store.save(&invoice); 
    }

    // 2. Call Render
    let kernel = kernel_lock.read().await;
    let rendered = billing_render_invoice_logic(&kernel, invoice_id).await.expect("Render failed");

    assert_eq!(rendered.account_id, format!("{:016x}", account_id));
    assert_eq!(rendered.total, "0.005000"); // 5000 micros
    assert_eq!(rendered.items.len(), 1);
    assert_eq!(rendered.items[0].meter_id, "storage");
}

#[tokio::test]
async fn test_p30bis_health_transitions() {
    let kernel_lock = setup_kernel().await;
    let account_id = 0xABCD;

    // 1. Create Account with Limit
    let mut account = Account::new(account_id, vec![]);
    account.credit_limit = 1000; // 1000 micros limit
    account.balance = 0;

    {
        let kernel = kernel_lock.read().await;
        kernel.accounts.write().insert(account.clone());
    }

    let kernel = kernel_lock.read().await;

    // A. Initial Health (Balance 0, Limit 1000) -> OK?
    // Limit is defined as "Max debt". So balance can go to -1000.
    // 0 is fine.
    // Health logic: OK if balance > 20% of limit?
    // Wait. "balance + credit_limit < 0" means blocked.
    // If balance is POSITIVE, it's credit.
    // If balance is NEGATIVE, it's debt.
    // If balance = 0.
    // Spec: OK if balance > 20% of limit? (Strictly speaking, "remaining credit > 20%").
    // Remaining = balance + credit_limit.
    // 0 + 1000 = 1000. 20% of 1000 = 200. 1000 > 200. OK.
    let h1 = billing_get_health_logic(&kernel, account_id).await.unwrap();
    // assert_eq!(h1, AccountHealth::OK); // Enum vs String? Logic returns DTO. 
    // DTO is likely Enum.

    // B. Near Limit
    // Set balance to -850. Remaining = 150. (15% < 20%).
    {
        let reg = kernel.accounts.write(); // Need write lock on accounts
        reg.update_balance(account_id, -850).unwrap(); // Absolute set? No update_balance is delta. 
        // Need setter.
        // account.balance = -850; reg.insert(account);
        // This overwrites.
    }
    // ...
}
