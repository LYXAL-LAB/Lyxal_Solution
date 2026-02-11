use axum::response::{Json};
use axum::http::{StatusCode, HeaderMap};
use axum::routing::{get, post};
use axum::{Extension, Router};
use std::collections::HashMap;
use serde::{Deserialize, Serialize};
use lyxal_os::service::ServiceStatus;
use lyxal_os::policy::{self, EvalContext, Decision};
use lyxal_os::registry::DesiredState;

use super::AppState;

use axum::extract::Path;
use base64::Engine as _;
use std::sync::Arc;
use lyxal_net::crypto::NodeIdentity;
use lyxal_os::settlement::{ProviderId, PaymentKind, ExternalPayment, ApplyState, PaymentStatus};
const BASE64: base64::engine::general_purpose::GeneralPurpose = base64::engine::general_purpose::STANDARD;

// === DTOs ===

#[derive(Deserialize)]
struct BillingTxRequest {
    kind: String, // String to avoid serde enum issues
    from: Option<String>, // Account ID as Hex
    to: Option<String>,   // Account ID as Hex
    amount: i64,
    reason: String,
    idempotency_key: String, // Hex
}

#[derive(Deserialize)]
struct VerifyReceiptRequest {
    receipt: lyxal_os::transactions::KernelReceipt,
}

#[derive(Serialize)]
struct StatusResponse {
    state: String,
    node_id: u128,
}

#[derive(Serialize)]
struct PeerDto {
    addr: String,
    health: String,
}

#[derive(Deserialize)]
struct ConfigRequest {
    // Placeholder
}

#[derive(Deserialize)]
struct CreateRealmRequest {
    realm_id: String,
}

#[derive(Deserialize)]
struct DrainRequest {
    #[allow(dead_code)]
    timeout_ms: Option<u64>,
}

#[derive(Deserialize)]
struct SettlementDepositRequest {
    provider: String,
    external_id: String,
    account_id: String, // Hex
    amount_micros: i64,
}

#[derive(Deserialize)]
struct SettlementWithdrawalRequest {
    account_id: String, // Hex
    amount_micros: i64,
}

// === Router ===

pub(super) fn router<S>() -> Router<S>
where
    S: Clone + Send + Sync + 'static,
{
    Router::new()
        .route("/lyxal/sync/status", get(status))
        .route("/lyxal/sync/peers", get(peers))
        .route("/lyxal/sync/realms", get(list_realms).post(create_realm))
        .route("/lyxal/sync/realms/:id", get(get_realm_status).delete(delete_realm))
        .route("/lyxal/sync/realms/:id/start", post(start_realm))
        .route("/lyxal/sync/realms/:id/stop", post(stop_realm))
        .route("/lyxal/sync/realms/:id/drain", post(drain_realm))
        .route("/lyxal/sync/config", post(config))
        // P24 Declarative Control Plane
        .route("/lyxal/os/apply", post(apply_manifest))
        .route("/lyxal/os/desired", get(get_desired_state))
        .route("/lyxal/os/observed", get(get_observed_state))
        .route("/lyxal/os/drift", get(get_drift))
        .route("/lyxal/os/rollback", post(rollback_manifest))
        // P26 Billing
        .route("/lyxal/billing/realms/:id", get(get_billing))
        .route("/lyxal/billing/export", post(export_billing))
        // P28 Transactions
        .route("/lyxal/billing/tx", post(handle_post_tx))
        .route("/lyxal/billing/tx/:id", get(get_transaction))
        .route("/lyxal/billing/account/:id/ledger", get(get_account_ledger))
        .route("/lyxal/billing/verify", post(verify_receipt))
        // P29 Billing Endpoints
        .route("/lyxal/billing/plans", get(list_pricing_plans))
        .route("/lyxal/billing/accounts/:id", get(get_billing_account))
        .route("/lyxal/billing/invoices/:account_id", get(list_account_invoices))
        .route("/lyxal/billing/invoice/:period_id", get(get_invoice))
        .route("/lyxal/billing/run_cycle", post(run_billing_cycle))
        // P30bis DX & Economic Ops (READ-ONLY)
        .route("/lyxal/billing/accounts", get(p30bis_list_accounts))
        // P32 Settlement
        .route("/lyxal/settlement/deposits/mock", post(ingest_mock_deposit))
        .route("/lyxal/settlement/withdrawals/request", post(request_withdrawal))
        .route("/lyxal/settlement/payments/:provider/:external_id", get(get_settlement_payment))
        .route("/lyxal/billing/accounts/:id/usage", get(p30bis_get_usage))
        .route("/lyxal/billing/accounts/:id/ledger", get(p30bis_get_ledger))
        .route("/lyxal/billing/accounts/:id/forecast", get(p30bis_get_forecast))
        .route("/lyxal/billing/accounts/:id/health", get(p30bis_get_health))
        .route("/lyxal/billing/simulate", post(p30bis_simulate))
        .route("/lyxal/billing/invoices/:id/render", get(p30bis_render_invoice))
        .route("/lyxal/billing/metrics", get(p30bis_get_metrics))
        // P31 Safety Ops
        .route("/lyxal/safety/accounts/:id/status", get(p31_get_status))
        .route("/lyxal/safety/accounts/:id/freeze", post(p31_freeze))
        .route("/lyxal/safety/accounts/:id/unfreeze", post(p31_unfreeze))
        .route("/lyxal/safety/tx/:id/dispute", post(p31_dispute))
        .route("/lyxal/safety/audit/:id", get(p31_get_audit))
}

// === Auth Helper ===

fn is_admin(headers: &HeaderMap) -> bool {
    if let Some(token) = std::env::var_os("LYXAL_SYNC_ADMIN_TOKEN") {
        if let Some(header_val) = headers.get("Authorization") {
            if let Ok(val) = header_val.to_str() {
                return val == token.to_str().unwrap_or("");
            }
        }
    }
    false
}

fn check_auth(headers: &HeaderMap, _realm_id: Option<u128>) -> Result<(), StatusCode> {
    if is_admin(headers) {
        return Ok(());
    }
    Ok(())
}

async fn policy_check(
    kernel: &lyxal_os::kernel::Kernel,
    headers: &HeaderMap,
    action: &'static str,
    realm_id: Option<u128>,
    resource: String,
) -> Result<(), (StatusCode, Json<serde_json::Value>)> {
    if is_admin(headers) && action == policy::ACTION_DS_APPLY {
        return Ok(());
    }

    let manifest_opt = kernel.consensus.store.load_manifest().await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, Json(serde_json::json!({"error": e.to_string()}))))?;
    
    let policies = if let Some(m) = manifest_opt { m.policies } else { vec![] };
    
    let ctx = EvalContext {
        principal: kernel.consensus.node_id, 
        realm_id,
        service: Some("api"),
        action,
        resource: resource.clone(),
    };
    
    let decision = policy::evaluate(&ctx, &policies);
    if decision.decision == Decision::Deny {
        let body = serde_json::json!({
            "error": "POLICY_DENIED",
            "action": action,
            "resource": resource,
            "matched_policy_ids": decision.matched
        });
        return Err((StatusCode::FORBIDDEN, Json(body)));
    }
    
    Ok(())
}

// === Helper ===

async fn ensure_leader(kernel: &lyxal_os::kernel::Kernel) -> Result<(), (StatusCode, Json<serde_json::Value>)> {
    if !kernel.consensus.is_leader().await {
        let hint_tuple = kernel.consensus.get_leader_hint();
        let hint_val = if let Some((term, leader)) = hint_tuple {
            serde_json::json!({ "term": term, "leader_id": leader })
        } else {
            serde_json::json!(null)
        };

        let body = serde_json::json!({
            "error": "NOT_LEADER",
            "leader_hint": hint_val
        });
        return Err((StatusCode::CONFLICT, Json(body)));
    }
    Ok(())
}

// === Handlers ===

async fn status(Extension(state): Extension<AppState>) -> Result<Json<StatusResponse>, StatusCode> {
    let kernel_lock = state.kernel.as_ref().ok_or(StatusCode::SERVICE_UNAVAILABLE)?;
    let kernel = kernel_lock.read().await;
    
    Ok(Json(StatusResponse {
        state: "Running".into(),
        node_id: kernel.consensus.node_id,
    }))
}

async fn peers(Extension(_state): Extension<AppState>) -> Result<Json<Vec<PeerDto>>, StatusCode> {
    // Placeholder for peer list
    Ok(Json(vec![])) 
}

async fn config(Extension(_state): Extension<AppState>, Json(_req): Json<ConfigRequest>) -> Result<StatusCode, StatusCode> {
    Ok(StatusCode::OK)
}

async fn list_realms(
    Extension(state): Extension<AppState>,
    headers: HeaderMap,
) -> Result<Json<Vec<lyxal_os::realm::RealmStatus>>, StatusCode> {
    check_auth(&headers, None)?;

    let kernel_lock = state.kernel.as_ref().ok_or(StatusCode::SERVICE_UNAVAILABLE)?;
    let kernel = kernel_lock.read().await;
    let list = kernel.list_realms();
    
    Ok(Json(list))
}

async fn get_realm_status(
    axum::extract::Path(id_hex): axum::extract::Path<String>,
    Extension(state): Extension<AppState>,
    headers: HeaderMap,
) -> Result<Json<lyxal_os::realm::RealmStatus>, StatusCode> {
    let realm_id_val = u128::from_str_radix(&id_hex, 16).map_err(|_| StatusCode::BAD_REQUEST)?;
    let realm_id = lyxal_os::realm::RealmId(realm_id_val);
    
    check_auth(&headers, Some(realm_id_val))?;

    let kernel_lock = state.kernel.as_ref().ok_or(StatusCode::SERVICE_UNAVAILABLE)?;
    let kernel = kernel_lock.read().await;
    
    if let Some(handle) = kernel.get_realm(realm_id) {
        Ok(Json(handle.get_status()))
    } else {
        Err(StatusCode::NOT_FOUND)
    }
}

async fn create_realm(
    Extension(state): Extension<AppState>,
    headers: HeaderMap,
    Json(req): Json<CreateRealmRequest>,
) -> Result<(StatusCode, Json<serde_json::Value>), (StatusCode, Json<serde_json::Value>)> {
    if let Err(c) = check_auth(&headers, None) { return Err((c, Json(serde_json::json!({"error": "Auth Failed"})))); }

    let realm_id_val = u128::from_str_radix(&req.realm_id, 16).map_err(|_| (StatusCode::BAD_REQUEST, Json(serde_json::json!({"error": "Invalid ID"}))))?;
    
    let kernel_lock = state.kernel.as_ref().ok_or((StatusCode::SERVICE_UNAVAILABLE, Json(serde_json::json!({"error": "Service Unavailable"}))))?;
    let kernel = kernel_lock.read().await;
    
    ensure_leader(&kernel).await?;
    policy_check(&kernel, &headers, policy::ACTION_REALM_CREATE, Some(realm_id_val), format!("realm:{}", realm_id_val)).await?;

    let command_id = std::time::SystemTime::now().duration_since(std::time::UNIX_EPOCH).unwrap().as_nanos() as u128;

    let desired = lyxal_os::consensus::DesiredRealmState {
        target: lyxal_os::consensus::TargetStatus::Stopped,
        config_hash: String::new(),
        updated_at_ms: command_id as u64 / 1_000_000,
        updated_by: 0,
        last_command_id: command_id,
    };
    
    if let Err(e) = kernel.consensus.store.set_desired(realm_id_val, desired).await {
        return Err((StatusCode::INTERNAL_SERVER_ERROR, Json(serde_json::json!({"error": e.to_string()}))));
    }

    Ok((StatusCode::ACCEPTED, Json(serde_json::json!({"command_id": command_id}))))
}

async fn start_realm(
    axum::extract::Path(id_hex): axum::extract::Path<String>,
    Extension(state): Extension<AppState>,
    headers: HeaderMap,
) -> Result<(StatusCode, Json<serde_json::Value>), (StatusCode, Json<serde_json::Value>)> {
    let realm_id_val = u128::from_str_radix(&id_hex, 16).map_err(|_| (StatusCode::BAD_REQUEST, Json(serde_json::json!({"error": "Invalid ID"}))))?;
    if let Err(c) = check_auth(&headers, Some(realm_id_val)) { return Err((c, Json(serde_json::json!({"error": "Auth Failed"})))); }
    
    let kernel_lock = state.kernel.as_ref().ok_or((StatusCode::SERVICE_UNAVAILABLE, Json(serde_json::json!({"error": "Service Unavailable"}))))?;
    let kernel = kernel_lock.read().await;

    ensure_leader(&kernel).await?;
    policy_check(&kernel, &headers, policy::ACTION_REALM_START, Some(realm_id_val), format!("realm:{}", realm_id_val)).await?;
    
    let store = &kernel.consensus.store;
    let mut desired = store.get_desired(realm_id_val).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, Json(serde_json::json!({"error": e.to_string()}))))?
        .ok_or((StatusCode::NOT_FOUND, Json(serde_json::json!({"error": "Realm not found in desired state"}))))?;
    
    let command_id = std::time::SystemTime::now().duration_since(std::time::UNIX_EPOCH).unwrap().as_nanos() as u128;
    desired.target = lyxal_os::consensus::TargetStatus::Running;
    desired.last_command_id = command_id;
    desired.updated_at_ms = command_id as u64 / 1_000_000;
    
    store.set_desired(realm_id_val, desired).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, Json(serde_json::json!({"error": e.to_string()}))))?;
    
    Ok((StatusCode::ACCEPTED, Json(serde_json::json!({"command_id": command_id}))))
}

async fn stop_realm(
    axum::extract::Path(id_hex): axum::extract::Path<String>,
    Extension(state): Extension<AppState>,
    headers: HeaderMap,
) -> Result<(StatusCode, Json<serde_json::Value>), (StatusCode, Json<serde_json::Value>)> {
    let realm_id_val = u128::from_str_radix(&id_hex, 16).map_err(|_| (StatusCode::BAD_REQUEST, Json(serde_json::json!({"error": "Invalid ID"}))))?;
    if let Err(c) = check_auth(&headers, Some(realm_id_val)) { return Err((c, Json(serde_json::json!({"error": "Auth Failed"})))); }
    
    let kernel_lock = state.kernel.as_ref().ok_or((StatusCode::SERVICE_UNAVAILABLE, Json(serde_json::json!({"error": "Service Unavailable"}))))?;
    let kernel = kernel_lock.read().await;

    ensure_leader(&kernel).await?;
    policy_check(&kernel, &headers, policy::ACTION_REALM_STOP, Some(realm_id_val), format!("realm:{}", realm_id_val)).await?;
    
    let store = &kernel.consensus.store;
    let mut desired = store.get_desired(realm_id_val).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, Json(serde_json::json!({"error": e.to_string()}))))?
        .ok_or((StatusCode::NOT_FOUND, Json(serde_json::json!({"error": "Realm not found in desired state"}))))?;
    
    let command_id = std::time::SystemTime::now().duration_since(std::time::UNIX_EPOCH).unwrap().as_nanos() as u128;
    desired.target = lyxal_os::consensus::TargetStatus::Stopped;
    desired.last_command_id = command_id;
    desired.updated_at_ms = command_id as u64 / 1_000_000;
    
    store.set_desired(realm_id_val, desired).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, Json(serde_json::json!({"error": e.to_string()}))))?;
    
    Ok((StatusCode::ACCEPTED, Json(serde_json::json!({"command_id": command_id}))))
}

async fn delete_realm(
    axum::extract::Path(id_hex): axum::extract::Path<String>,
    axum::extract::Query(_params): axum::extract::Query<HashMap<String, String>>,
    Extension(state): Extension<AppState>,
    headers: HeaderMap,
) -> Result<(StatusCode, Json<serde_json::Value>), (StatusCode, Json<serde_json::Value>)> {
    let realm_id_val = u128::from_str_radix(&id_hex, 16).map_err(|_| (StatusCode::BAD_REQUEST, Json(serde_json::json!({"error": "Invalid ID"}))))?;
    if let Err(c) = check_auth(&headers, None) { return Err((c, Json(serde_json::json!({"error": "Auth Failed"})))); }

    let kernel_lock = state.kernel.as_ref().ok_or((StatusCode::SERVICE_UNAVAILABLE, Json(serde_json::json!({"error": "Service Unavailable"}))))?;
    let kernel = kernel_lock.read().await;

    ensure_leader(&kernel).await?;
    policy_check(&kernel, &headers, policy::ACTION_REALM_DELETE, Some(realm_id_val), format!("realm:{}", realm_id_val)).await?;
    
    let store = &kernel.consensus.store;
    let command_id = std::time::SystemTime::now().duration_since(std::time::UNIX_EPOCH).unwrap().as_nanos() as u128;
    
    let desired = lyxal_os::consensus::DesiredRealmState {
        target: lyxal_os::consensus::TargetStatus::Deleted,
        config_hash: String::new(),
        updated_at_ms: command_id as u64 / 1_000_000,
        updated_by: 0,
        last_command_id: command_id,
    };
    
    store.set_desired(realm_id_val, desired).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, Json(serde_json::json!({"error": e.to_string()}))))?;
    
    Ok((StatusCode::ACCEPTED, Json(serde_json::json!({"command_id": command_id}))))
}

async fn drain_realm(
    axum::extract::Path(id_hex): axum::extract::Path<String>,
    Extension(_state): Extension<AppState>,
    headers: HeaderMap,
    Json(_req): Json<DrainRequest>,
) -> Result<(StatusCode, Json<serde_json::Value>), (StatusCode, Json<serde_json::Value>)> {
    Err((StatusCode::NOT_IMPLEMENTED, Json(serde_json::json!({"error": "Not Implemented"}))))
}

// === P24 Declarative Handlers ===

async fn apply_manifest(
    Extension(state): Extension<AppState>,
    headers: HeaderMap,
    Json(manifest): Json<lyxal_os::registry::DesiredState>,
) -> Result<(StatusCode, Json<serde_json::Value>), (StatusCode, Json<serde_json::Value>)> {
    if let Err(c) = check_auth(&headers, None) { return Err((c, Json(serde_json::json!({"error": "Auth Failed"})))); }

    let kernel_lock = state.kernel.as_ref().ok_or((StatusCode::SERVICE_UNAVAILABLE, Json(serde_json::json!({"error": "Service Unavailable"}))))?;
    let kernel = kernel_lock.read().await;

    ensure_leader(&kernel).await?;
    policy_check(&kernel, &headers, policy::ACTION_DS_APPLY, None, "*".into()).await?;

    let store = &kernel.consensus.store;
    let current_opt = store.load_manifest().await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, Json(serde_json::json!({"error": e.to_string()}))))?;
    
    if let Some(current) = current_opt {
        if manifest.version <= current.version {
             return Err((StatusCode::CONFLICT, Json(serde_json::json!({
                 "error": "Version Conflict",
                 "current_version": current.version,
                 "proposed_version": manifest.version
             }))));
        }
    }

    store.save_manifest(&manifest).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, Json(serde_json::json!({"error": e.to_string()}))))?;

    // Return Success with Hash
    let hash = manifest.hash();
    Ok((StatusCode::ACCEPTED, Json(serde_json::json!({
        "version": manifest.version,
        "hash": hash,
        "status": "Applied"
    }))))
}

async fn get_desired_state(
    Extension(state): Extension<AppState>,
    headers: HeaderMap,
) -> Result<Json<Option<lyxal_os::registry::DesiredState>>, StatusCode> {
    check_auth(&headers, None)?;
    let kernel_lock = state.kernel.as_ref().ok_or(StatusCode::SERVICE_UNAVAILABLE)?;
    let kernel = kernel_lock.read().await;
    let store = &kernel.consensus.store;
    let manifest = store.load_manifest().await.map_err(|_| StatusCode::INTERNAL_SERVER_ERROR)?;
    Ok(Json(manifest))
}

async fn get_observed_state(
    Extension(state): Extension<AppState>,
    headers: HeaderMap,
) -> Result<Json<Vec<lyxal_os::realm::RealmStatus>>, StatusCode> {
    check_auth(&headers, None)?;
    let kernel_lock = state.kernel.as_ref().ok_or(StatusCode::SERVICE_UNAVAILABLE)?;
    let kernel = kernel_lock.read().await;
    Ok(Json(kernel.list_realms()))
}

async fn get_drift(
    Extension(state): Extension<AppState>,
    headers: HeaderMap,
) -> Result<Json<serde_json::Value>, StatusCode> {
    check_auth(&headers, None)?;
    let kernel_lock = state.kernel.as_ref().ok_or(StatusCode::SERVICE_UNAVAILABLE)?;
    let kernel = kernel_lock.read().await;
    
    let desired_opt = kernel.consensus.store.load_manifest().await.map_err(|_| StatusCode::INTERNAL_SERVER_ERROR)?;
    let observed = kernel.list_realms();
    
    let mut drift = Vec::new();

    if let Some(desired) = desired_opt {
        for (realm_id, desired_realm) in desired.realms {
            let obs_realm = observed.iter().find(|r| r.realm_id == realm_id);
            if let Some(obs) = obs_realm {
                let obs_status = match obs.state {
                     lyxal_os::realm::RealmState::Running => lyxal_os::registry::TargetStatus::Running,
                     lyxal_os::realm::RealmState::Stopped => lyxal_os::registry::TargetStatus::Stopped,
                     _ => lyxal_os::registry::TargetStatus::Running,
                };
                if obs_status != desired_realm.target_status {
                    drift.push(serde_json::json!({ "realm_id": realm_id, "field": "status", "expected": desired_realm.target_status, "actual": obs.state }));
                }
            } else {
                 if desired_realm.target_status != lyxal_os::registry::TargetStatus::Deleted {
                     drift.push(serde_json::json!({ "realm_id": realm_id, "error": "Missing in Observed" }));
                 }
            }
        }
    }

    Ok(Json(serde_json::json!({ "drift_count": drift.len(), "drift": drift })))
}

async fn rollback_manifest(
    Extension(_state): Extension<AppState>,
    _headers: HeaderMap,
) -> Result<StatusCode, StatusCode> {
    Err(StatusCode::NOT_IMPLEMENTED)
}

// === P26 Billing Endpoints ===

#[derive(Serialize)]
struct SignedBillingExport {
    pub ts_ns: u64,
    pub realm_id: Option<u128>,
    pub usage: HashMap<u128, lyxal_os::ledger::RealmLedgerView>,
    pub signature: String, // Base64
}

async fn get_billing(
    Extension(state): Extension<Arc<AppState>>,
    headers: HeaderMap,
    axum::extract::Path(id_str): axum::extract::Path<String>,
) -> Result<Json<lyxal_os::ledger::RealmLedgerView>, (StatusCode, Json<serde_json::Value>)> {
    let id = id_str.parse::<u128>().map_err(|_| (StatusCode::BAD_REQUEST, Json(serde_json::json!({"error": "invalid realm id"}))))?;
    
    if !is_admin(&headers) {
         return Err((StatusCode::FORBIDDEN, Json(serde_json::json!({"error": "Admin required for billing access"}))));
    }

    let kernel_lock = state.kernel.as_ref().ok_or((StatusCode::SERVICE_UNAVAILABLE, Json(serde_json::json!({"error": "Kernel not available"}))))?;
    let kernel = kernel_lock.read().await;
    let view = kernel.ledger.get_view(id);
    Ok(Json(view))
}

async fn export_billing(
    Extension(state): Extension<AppState>,
    headers: HeaderMap,
) -> Result<Json<SignedBillingExport>, (StatusCode, Json<serde_json::Value>)> {
    if !is_admin(&headers) {
         return Err((StatusCode::FORBIDDEN, Json(serde_json::json!({"error": "Admin required for export"}))));
    }

    let kernel_lock = state.kernel.as_ref().ok_or((StatusCode::SERVICE_UNAVAILABLE, Json(serde_json::json!({"error": "Kernel not available"}))))?;
    let kernel = kernel_lock.read().await;
    
    // Aggregate for all realms or a specific subset? Let's do all currently in ledger.
    // We need to extend ledger to list all realms with usage.
    // For now, let's take all realms currently managed by kernel.
    let mut usage = HashMap::new();
    for realm_id in kernel.realms.keys() {
        usage.insert(realm_id.0, kernel.ledger.get_view(realm_id.0));
    }

    let ts = std::time::SystemTime::now().duration_since(std::time::UNIX_EPOCH).unwrap().as_nanos() as u64;
    
    let export_data = serde_json::json!({
        "ts_ns": ts,
        "usage": usage,
    });
    
    let canonical = serde_json::to_vec(&export_data).map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, Json(serde_json::json!({"error": e.to_string()}))))?;
    
    // Sign with Kernel Identity (P16 Identity is persistent)
    let signature_bytes = kernel.boot_ctx.stats.as_ref().unwrap().realm_id; // Wait, stats.realm_id is not identity.
    // The Kernel Identity is in boot_ctx or we need to access it via identity module.
    // Actually, each realm has its identity, but the GLOBAL kernel might have one too.
    // If we use the root realm (0) identity for global billing:
    let root_realm = kernel.realms.get(&lyxal_os::realm::RealmId(0));
    let sig_str = if let Some(r) = root_realm {
         let sig = r.context.identity.sign(&canonical);
         base64::encode(sig.to_bytes())
    } else {
        "no-root-identity".to_string()
    };

    Ok(Json(SignedBillingExport {
        ts_ns: ts,
        realm_id: None,
        usage,
        signature: sig_str,
    }))
}

async fn handle_post_tx(
    Extension(state): Extension<AppState>,
    headers: HeaderMap,
    Json(req): Json<BillingTxRequest>,
) -> impl axum::response::IntoResponse {
    // 1. Extract Headers
    let account_id_str = headers.get("X-Lyxal-Account-Id")
        .and_then(|h| h.to_str().ok())
        .ok_or((StatusCode::BAD_REQUEST, Json(serde_json::json!({"error": "Missing X-Lyxal-Account-Id"}))))?;
    let account_id = u128::from_str_radix(account_id_str, 16)
        .map_err(|_| (StatusCode::BAD_REQUEST, Json(serde_json::json!({"error": "Invalid X-Lyxal-Account-Id"}))))?;

    let nonce = headers.get("X-Lyxal-Nonce")
        .and_then(|h| h.to_str().ok())
        .and_then(|s| s.parse::<u64>().ok())
        .ok_or((StatusCode::BAD_REQUEST, Json(serde_json::json!({"error": "Missing or invalid X-Lyxal-Nonce"}))))?;

    let sig_str = headers.get("X-Lyxal-Signature")
        .and_then(|h| h.to_str().ok())
        .ok_or((StatusCode::BAD_REQUEST, Json(serde_json::json!({"error": "Missing X-Lyxal-Signature"}))))?;
    let sig = BASE64.decode(sig_str)
        .map_err(|_| (StatusCode::BAD_REQUEST, Json(serde_json::json!({"error": "Invalid base64 signature"}))))?;

    // 2. Prepare TransactionRequest
    let from = req.from.as_ref().and_then(|s| u128::from_str_radix(s, 16).ok());
    let to = req.to.as_ref().and_then(|s| u128::from_str_radix(s, 16).ok());
    
    let mut idem_bytes = [0u8; 32];
    hex::decode_to_slice(&req.idempotency_key, &mut idem_bytes)
        .map_err(|_| (StatusCode::BAD_REQUEST, Json(serde_json::json!({"error": "Invalid idempotency_key hex"}))))?;

    let tx_kind = match req.kind.as_str() {
        "Credit" => lyxal_os::transactions::TransactionKind::Credit,
        "Debit" => lyxal_os::transactions::TransactionKind::Debit,
        "Transfer" => lyxal_os::transactions::TransactionKind::Transfer,
        "Refund" => lyxal_os::transactions::TransactionKind::Refund,
        "Adjustment" => lyxal_os::transactions::TransactionKind::Adjustment,
        _ => return Err((StatusCode::BAD_REQUEST, Json(serde_json::json!({"error": "Invalid transaction kind"})))),
    };

    let tx_req = lyxal_os::transactions::TransactionRequest {
        kind: tx_kind,
        from,
        to,
        amount: req.amount,
        reason: req.reason,
        idempotency_key: idem_bytes,
    };

    // 3. Call Kernel
    let kernel_lock = state.kernel.as_ref().ok_or((StatusCode::SERVICE_UNAVAILABLE, Json(serde_json::json!({"error": "Kernel not available"}))))?;
    let kernel = kernel_lock.read().await;

    match kernel.handle_billing_tx(account_id, nonce, sig, tx_req).await {
        Ok((tx, receipt)) => {
            Ok((StatusCode::CREATED, Json(serde_json::json!({
                "tx": tx,
                "receipt": receipt
            }))))
        }
        Err(e) if e.to_string() == "ErrNotLeader" => {
            // ensure_leader(&kernel).await?;
            Err((StatusCode::CONFLICT, Json(serde_json::json!({"error": "Not Leader"}))))
        }
        Err(e) => {
            Err((StatusCode::BAD_REQUEST, Json(serde_json::json!({"error": e.to_string()}))))
        }
    }
}

async fn get_transaction(
    Path(id_hex): Path<String>,
    Extension(state): Extension<AppState>,
    _headers: HeaderMap,
) -> Result<Json<lyxal_os::transactions::Transaction>, StatusCode> {
    let id = u128::from_str_radix(&id_hex, 16).map_err(|_| StatusCode::BAD_REQUEST)?;
    
    let kernel_lock = state.kernel.as_ref().ok_or(StatusCode::SERVICE_UNAVAILABLE)?;
    let kernel = kernel_lock.read().await;
    
    if let Some(tx) = kernel.tx_store.get(id) {
        Ok(Json(tx.clone()))
    } else {
        Err(StatusCode::NOT_FOUND)
    }
}

async fn get_account_ledger(
    Path(id_hex): Path<String>,
    Extension(state): Extension<AppState>,
    _headers: HeaderMap,
) -> Result<Json<serde_json::Value>, StatusCode> {
    let account_id = u128::from_str_radix(&id_hex, 16).map_err(|_| StatusCode::BAD_REQUEST)?;
    
    let kernel_lock = state.kernel.as_ref().ok_or(StatusCode::SERVICE_UNAVAILABLE)?;
    let kernel = kernel_lock.read().await;
    
    let acc_opt = kernel.accounts.read().get(account_id);
    let history = kernel.tx_store.list_for_account(account_id);
    let digest = kernel.tx_store.get_state_digest();
    
    if let Some(acc) = acc_opt {
        Ok(Json(serde_json::json!({
            "account": acc,
            "history": history,
            "digest": hex::encode(digest)
        })))
    } else {
        Err(StatusCode::NOT_FOUND)
    }
}

async fn verify_receipt(
    Extension(state): Extension<AppState>,
    Json(req): Json<VerifyReceiptRequest>,
) -> Result<Json<serde_json::Value>, (StatusCode, Json<serde_json::Value>)> {
    let kernel_lock = state.kernel.as_ref().ok_or((StatusCode::SERVICE_UNAVAILABLE, Json(serde_json::json!({"error": "Kernel not available"}))))?;
    let kernel = kernel_lock.read().await;
    
    // 1. Verify Kernel Signature on receipt
    let receipt_bytes = bincode::serialize(&req.receipt)
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, Json(serde_json::json!({"error": e.to_string()}))))?;
    
    // We need Kernel's Public Key. We can load it from Identity.
    let identity = NodeIdentity::load_or_create(&kernel.boot_ctx.paths.identity_path)
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, Json(serde_json::json!({"error": e.to_string()}))))?;
    
    let vk = identity.keypair.verifying_key();
    let sig = ed25519_dalek::Signature::from_slice(&req.receipt.kernel_sig)
        .map_err(|_| (StatusCode::BAD_REQUEST, Json(serde_json::json!({"error": "Invalid receipt signature format"}))))?;
    
    use ed25519_dalek::Verifier;
    let valid = vk.verify(&receipt_bytes, &sig).is_ok();
    
    Ok(Json(serde_json::json!({
        "valid": valid,
        "receipt": req.receipt
    })))
}
// === P29 Billing Handlers ===

async fn list_pricing_plans(
    Extension(state): Extension<AppState>,
) -> Result<Json<HashMap<String, lyxal_os::registry_new::PricingPlan>>, (StatusCode, Json<serde_json::Value>)> {
    let kernel_lock = state.kernel.as_ref().ok_or((StatusCode::SERVICE_UNAVAILABLE, Json(serde_json::json!({"error": "Kernel not available"}))))?;
    let kernel = kernel_lock.read().await;
    
    let manifest = kernel.consensus.store.load_manifest().await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, Json(serde_json::json!({"error": e.to_string()}))))?
        .ok_or((StatusCode::NOT_FOUND, Json(serde_json::json!({"error": "Manifest not found"}))))?;
    
    Ok(Json(manifest.pricing_plans.into_iter().collect()))
}

async fn get_billing_account(
    Path(id_hex): Path<String>,
    Extension(state): Extension<AppState>,
) -> Result<Json<serde_json::Value>, (StatusCode, Json<serde_json::Value>)> {
    let account_id = u128::from_str_radix(&id_hex, 16).map_err(|_| (StatusCode::BAD_REQUEST, Json(serde_json::json!({"error": "Invalid ID"}))))?;
    
    let kernel_lock = state.kernel.as_ref().ok_or((StatusCode::SERVICE_UNAVAILABLE, Json(serde_json::json!({"error": "Kernel not available"}))))?;
    let kernel = kernel_lock.read().await;
    
    let reg = kernel.accounts.read();
    let acc = reg.get(account_id).ok_or((StatusCode::NOT_FOUND, Json(serde_json::json!({"error": "Account not found"}))))?;
    
    Ok(Json(serde_json::json!({
        "account_id": id_hex,
        "balance": acc.balance,
        "credit_limit": acc.credit_limit,
        "pricing_plan_id": acc.pricing_plan_id,
        "cursor_seq": acc.billing_cursor_seq,
    })))
}

async fn list_account_invoices(
    Path(id_hex): Path<String>,
    Extension(state): Extension<AppState>,
) -> Result<Json<Vec<lyxal_os::invoice::Invoice>>, (StatusCode, Json<serde_json::Value>)> {
    let account_id = u128::from_str_radix(&id_hex, 16).map_err(|_| (StatusCode::BAD_REQUEST, Json(serde_json::json!({"error": "Invalid ID"}))))?;
    
    let kernel_lock = state.kernel.as_ref().ok_or((StatusCode::SERVICE_UNAVAILABLE, Json(serde_json::json!({"error": "Kernel not available"}))))?;
    let kernel = kernel_lock.read().await;
    
    let invoices = kernel.invoice_store.list_for_account(account_id)
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, Json(serde_json::json!({"error": e.to_string()}))))?;
    Ok(Json(invoices))
}

async fn get_invoice(
    Path(period_id_hex): Path<String>,
    Extension(state): Extension<AppState>,
) -> Result<Json<lyxal_os::invoice::Invoice>, (StatusCode, Json<serde_json::Value>)> {
    let mut period_id = [0u8; 32];
    hex::decode_to_slice(&period_id_hex, &mut period_id)
        .map_err(|_| (StatusCode::BAD_REQUEST, Json(serde_json::json!({"error": "Invalid period_id hex"}))))?;
    
    let kernel_lock = state.kernel.as_ref().ok_or((StatusCode::SERVICE_UNAVAILABLE, Json(serde_json::json!({"error": "Kernel not available"}))))?;
    let kernel = kernel_lock.read().await;
    
    let inv = kernel.invoice_store.get(&period_id)
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, Json(serde_json::json!({"error": e.to_string()}))))?
        .ok_or((StatusCode::NOT_FOUND, Json(serde_json::json!({"error": "Invoice not found"}))))?;
        
    Ok(Json(inv))
}

async fn run_billing_cycle(
    headers: HeaderMap,
    Extension(state): Extension<AppState>,
) -> Result<Json<serde_json::Value>, (StatusCode, Json<serde_json::Value>)> {
    if !is_admin(&headers) {
        return Err((StatusCode::FORBIDDEN, Json(serde_json::json!({"error": "Admin required"}))));
    }

    let kernel_lock = state.kernel.as_ref().ok_or((StatusCode::SERVICE_UNAVAILABLE, Json(serde_json::json!({"error": "Kernel not available"}))))?;
    let mut kernel = kernel_lock.write().await;
    
    ensure_leader(&kernel).await?;
    
    kernel.reconcile_billing().await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, Json(serde_json::json!({"error": e.to_string()}))))?;
    
    Ok(Json(serde_json::json!({"status": "Billing cycle executed"})))
}

// ============================================================================
// P30bis - DX & Economic Ops (READ-ONLY)
// ============================================================================

use super::billing_api::{
    AccountHealth, AccountSummary, BillingMetrics, ForecastResponse, 
    LedgerEvent, RenderedInvoice, SimulationRequest, SimulationResponse, UsageResponse,
    calculate_health, calculate_forecast, format_micros_to_currency, render_invoice, simulate_pricing,
};

/// GET /lyxal/billing/accounts - List all accounts with health status
async fn p30bis_list_accounts(
    Extension(state): Extension<AppState>,
) -> Result<Json<Vec<AccountSummary>>, (StatusCode, Json<serde_json::Value>)> {
    let kernel_lock = state.kernel.as_ref()
        .ok_or((StatusCode::SERVICE_UNAVAILABLE, Json(serde_json::json!({"error": "Kernel not available"}))))?;
    let kernel = kernel_lock.read().await;
    
    let reg = kernel.accounts.read();
    let accounts = reg.list_accounts();
    
    let summaries: Vec<AccountSummary> = accounts.iter().map(|acc| {
        AccountSummary {
            id: format!("{:032x}", acc.id),
            balance_micros: acc.balance,
            credit_limit_micros: acc.credit_limit,
            pricing_plan_id: acc.pricing_plan_id.clone(),
            health: calculate_health(acc.balance, acc.credit_limit),
            realm_count: acc.realms.len() as u32,
        }
    }).collect();
    
    Ok(Json(summaries))
}

/// GET /lyxal/billing/accounts/:id/usage - Aggregated usage by meter
async fn p30bis_get_usage(
    Path(id_hex): Path<String>,
    Extension(state): Extension<AppState>,
) -> Result<Json<UsageResponse>, (StatusCode, Json<serde_json::Value>)> {
    let account_id = u128::from_str_radix(&id_hex, 16)
        .map_err(|_| (StatusCode::BAD_REQUEST, Json(serde_json::json!({"error": "Invalid account ID"}))))?;
    
    let kernel_lock = state.kernel.as_ref()
        .ok_or((StatusCode::SERVICE_UNAVAILABLE, Json(serde_json::json!({"error": "Kernel not available"}))))?;
    let kernel = kernel_lock.read().await;
    
    // Verify account exists
    {
        let reg = kernel.accounts.read();
        reg.get(account_id)
            .ok_or((StatusCode::NOT_FOUND, Json(serde_json::json!({"error": "Account not found"}))))?;
    }
    
    // Aggregate events by meter_id (read-only from accounting engine)
    let events = kernel.accounting.get_events_for_account(account_id);
    let mut meter_map: std::collections::HashMap<String, (i64, u64)> = std::collections::HashMap::new();
    
    for event in &events {
        let entry = meter_map.entry(event.meter_id.clone()).or_insert((0, 0));
        entry.0 += event.units;
        entry.1 += 1;
    }
    
    let meters: Vec<super::billing_api::MeterUsage> = meter_map.into_iter().map(|(meter_id, (total_units, count))| {
        super::billing_api::MeterUsage {
            meter_id,
            total_units,
            event_count: count,
        }
    }).collect();
    
    Ok(Json(UsageResponse {
        account_id: id_hex,
        meters,
        total_events: events.len() as u64,
    }))
}

/// GET /lyxal/billing/accounts/:id/ledger - Raw ledger events
async fn p30bis_get_ledger(
    Path(id_hex): Path<String>,
    Extension(state): Extension<AppState>,
) -> Result<Json<Vec<LedgerEvent>>, (StatusCode, Json<serde_json::Value>)> {
    let account_id = u128::from_str_radix(&id_hex, 16)
        .map_err(|_| (StatusCode::BAD_REQUEST, Json(serde_json::json!({"error": "Invalid account ID"}))))?;
    
    let kernel_lock = state.kernel.as_ref()
        .ok_or((StatusCode::SERVICE_UNAVAILABLE, Json(serde_json::json!({"error": "Kernel not available"}))))?;
    let kernel = kernel_lock.read().await;
    
    // Verify account exists
    {
        let reg = kernel.accounts.read();
        reg.get(account_id)
            .ok_or((StatusCode::NOT_FOUND, Json(serde_json::json!({"error": "Account not found"}))))?;
    }
    
    let events = kernel.accounting.get_events_for_account(account_id);
    let ledger_events: Vec<LedgerEvent> = events.iter().map(|e| {
        LedgerEvent {
            seq: e.seq,
            ts_ns: e.ts_ns,
            meter_id: e.meter_id.clone(),
            units: e.units,
            realm_id: format!("{:032x}", e.realm_id),
        }
    }).collect();
    
    Ok(Json(ledger_events))
}

/// GET /lyxal/billing/accounts/:id/forecast - Usage projection
async fn p30bis_get_forecast(
    Path(id_hex): Path<String>,
    Extension(state): Extension<AppState>,
) -> Result<Json<ForecastResponse>, (StatusCode, Json<serde_json::Value>)> {
    let account_id = u128::from_str_radix(&id_hex, 16)
        .map_err(|_| (StatusCode::BAD_REQUEST, Json(serde_json::json!({"error": "Invalid account ID"}))))?;
    
    let kernel_lock = state.kernel.as_ref()
        .ok_or((StatusCode::SERVICE_UNAVAILABLE, Json(serde_json::json!({"error": "Kernel not available"}))))?;
    let kernel = kernel_lock.read().await;
    
    let (balance, credit_limit) = {
        let reg = kernel.accounts.read();
        let acc = reg.get(account_id)
            .ok_or((StatusCode::NOT_FOUND, Json(serde_json::json!({"error": "Account not found"}))))?;
        (acc.balance, acc.credit_limit)
    };
    
    // Calculate average daily usage from recent events (last 7 days approximation)
    let events = kernel.accounting.get_events_for_account(account_id);
    let now_ns = std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .unwrap_or_default()
        .as_nanos() as u64;
    let seven_days_ns = 7 * 24 * 60 * 60 * 1_000_000_000u64;
    
    let recent_events: Vec<_> = events.iter()
        .filter(|e| now_ns.saturating_sub(e.ts_ns) < seven_days_ns)
        .collect();
    
    // Simple projection: total usage / 7 days (in micros - need to get from invoices or use unit cost)
    // For now, just count events and estimate
    let daily_usage_micros = if recent_events.is_empty() {
        0
    } else {
        // Rough estimate: assume each unit = 1 micro for projection
        let total_units: i64 = recent_events.iter().map(|e| e.units).sum();
        total_units / 7
    };
    
    Ok(Json(calculate_forecast(balance, credit_limit, daily_usage_micros)))
}

/// GET /lyxal/billing/accounts/:id/health - Account health status
async fn p30bis_get_health(
    Path(id_hex): Path<String>,
    Extension(state): Extension<AppState>,
) -> Result<Json<serde_json::Value>, (StatusCode, Json<serde_json::Value>)> {
    let account_id = u128::from_str_radix(&id_hex, 16)
        .map_err(|_| (StatusCode::BAD_REQUEST, Json(serde_json::json!({"error": "Invalid account ID"}))))?;
    
    let kernel_lock = state.kernel.as_ref()
        .ok_or((StatusCode::SERVICE_UNAVAILABLE, Json(serde_json::json!({"error": "Kernel not available"}))))?;
    let kernel = kernel_lock.read().await;
    
    let (balance, credit_limit) = {
        let reg = kernel.accounts.read();
        let acc = reg.get(account_id)
            .ok_or((StatusCode::NOT_FOUND, Json(serde_json::json!({"error": "Account not found"}))))?;
        (acc.balance, acc.credit_limit)
    };
    
    let health = calculate_health(balance, credit_limit);
    let available = balance + credit_limit;
    
    Ok(Json(serde_json::json!({
        "health": health,
        "balance_micros": balance,
        "credit_limit_micros": credit_limit,
        "available_micros": available,
        "balance_formatted": format_micros_to_currency(balance),
        "available_formatted": format_micros_to_currency(available),
    })))
}

/// POST /lyxal/billing/simulate - Dry-run pricing calculation
async fn p30bis_simulate(
    headers: HeaderMap,
    Extension(state): Extension<AppState>,
    Json(req): Json<SimulationRequest>,
) -> Result<Json<SimulationResponse>, (StatusCode, Json<serde_json::Value>)> {
    // Require admin token for simulation
    if !is_admin(&headers) {
        return Err((StatusCode::FORBIDDEN, Json(serde_json::json!({"error": "Admin token required"}))));
    }
    
    let kernel_lock = state.kernel.as_ref()
        .ok_or((StatusCode::SERVICE_UNAVAILABLE, Json(serde_json::json!({"error": "Kernel not available"}))))?;
    let kernel = kernel_lock.read().await;
    
    // Get pricing plan from manifest
    let manifest = kernel.consensus.store.load_manifest().await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, Json(serde_json::json!({"error": e.to_string()}))))?
        .ok_or((StatusCode::NOT_FOUND, Json(serde_json::json!({"error": "No manifest configured"}))))?;
    
    let plan = manifest.pricing_plans.get(&req.plan_id)
        .ok_or((StatusCode::BAD_REQUEST, Json(serde_json::json!({"error": "Unknown plan_id"}))))?;
    
    // Validate meter IDs
    let plan_meter_ids: std::collections::HashSet<_> = plan.meters.iter().map(|m| &m.id).collect();
    for event in &req.events {
        if !plan_meter_ids.contains(&event.meter_id) {
            return Err((StatusCode::BAD_REQUEST, Json(serde_json::json!({
                "error": format!("Unknown meter_id: {}", event.meter_id)
            }))));
        }
    }
    
    let result = simulate_pricing(plan, &req.events);
    Ok(Json(result))
}

/// GET /lyxal/billing/invoices/:id/render - Human-readable invoice
async fn p30bis_render_invoice(
    Path(period_id_hex): Path<String>,
    Extension(state): Extension<AppState>,
) -> Result<Json<RenderedInvoice>, (StatusCode, Json<serde_json::Value>)> {
    let mut period_id = [0u8; 32];
    hex::decode_to_slice(&period_id_hex, &mut period_id)
        .map_err(|_| (StatusCode::BAD_REQUEST, Json(serde_json::json!({"error": "Invalid period_id hex"}))))?;
    
    let kernel_lock = state.kernel.as_ref()
        .ok_or((StatusCode::SERVICE_UNAVAILABLE, Json(serde_json::json!({"error": "Kernel not available"}))))?;
    let kernel = kernel_lock.read().await;
    
    let invoice = kernel.invoice_store.get(&period_id)
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, Json(serde_json::json!({"error": e.to_string()}))))?
        .ok_or((StatusCode::NOT_FOUND, Json(serde_json::json!({"error": "Invoice not found"}))))?;
    
    // Get plan if available
    let manifest = kernel.consensus.store.load_manifest().await.ok().flatten();
    let plan = manifest.as_ref().and_then(|m| {
        // Try to find plan by account's pricing_plan_id
        let reg = kernel.accounts.read();
        reg.get(invoice.account_id)
            .and_then(|acc| m.pricing_plans.get(&acc.pricing_plan_id))
    });
    
    Ok(Json(render_invoice(&invoice, plan)))
}

/// GET /lyxal/billing/metrics - Economic observability snapshot
async fn p30bis_get_metrics(
    Extension(state): Extension<AppState>,
) -> Result<Json<BillingMetrics>, (StatusCode, Json<serde_json::Value>)> {
    let kernel_lock = state.kernel.as_ref()
        .ok_or((StatusCode::SERVICE_UNAVAILABLE, Json(serde_json::json!({"error": "Kernel not available"}))))?;
    let kernel = kernel_lock.read().await;
    
    let reg = kernel.accounts.read();
    let accounts = reg.list_accounts();
    
    let mut total_accounts = 0u64;
    let mut blocked_accounts = 0u64;
    let mut near_limit_accounts = 0u64;
    let mut total_balance_micros: i64 = 0;
    
    for acc in &accounts {
        total_accounts += 1;
        total_balance_micros = total_balance_micros.saturating_add(acc.balance);
        
        let health = calculate_health(acc.balance, acc.credit_limit);
        match health {
            AccountHealth::Blocked => blocked_accounts += 1,
            AccountHealth::NearLimit => near_limit_accounts += 1,
            _ => {}
        }
    }
    
    // Get total invoiced from invoice store
    let all_invoices = kernel.invoice_store.list_all()
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, Json(serde_json::json!({"error": e.to_string()}))))?;
    let total_invoiced_micros: i64 = all_invoices.iter()
        .map(|inv| inv.total_micros)
        .sum();
    
    Ok(Json(BillingMetrics {
        total_accounts,
        blocked_accounts,
        near_limit_accounts,
        total_balance_micros,
        total_invoiced_micros,
        outstanding_balance_micros: total_invoiced_micros.saturating_sub(total_balance_micros),
    }))
}

// === P31 Safety Handlers ===

async fn p31_get_status(
    Extension(state): Extension<AppState>,
    axum::extract::Path(account_id_hex): axum::extract::Path<String>,
) -> Result<Json<serde_json::Value>, (StatusCode, Json<serde_json::Value>)> {
    let account_id = u128::from_str_radix(&account_id_hex, 16).map_err(|_| (StatusCode::BAD_REQUEST, Json(serde_json::json!({"error": "Invalid ID"}))))?;
    let kernel_lock = state.kernel.as_ref().ok_or((StatusCode::SERVICE_UNAVAILABLE, Json(serde_json::json!({"error": "Kernel unavailable"}))))?;
    let kernel = kernel_lock.read().await;

    let status = kernel.safety.governance.read().get_status(account_id);
    let held = kernel.safety.governance.read().get_held_balance(account_id);

    Ok(Json(serde_json::json!({
        "account_id": account_id_hex,
        "status": status,
        "held_micros": held
    })))
}

async fn p31_freeze(
    Extension(state): Extension<AppState>,
    headers: HeaderMap,
    axum::extract::Path(account_id_hex): axum::extract::Path<String>,
    Json(body): Json<serde_json::Value>,
) -> Result<Json<serde_json::Value>, (StatusCode, Json<serde_json::Value>)> {
    if !is_admin(&headers) {
        return Err((StatusCode::FORBIDDEN, Json(serde_json::json!({"error": "Admin only"}))));
    }
    let account_id = u128::from_str_radix(&account_id_hex, 16).map_err(|_| (StatusCode::BAD_REQUEST, Json(serde_json::json!({"error": "Invalid ID"}))))?;
    let reason = body.get("reason").and_then(|s| s.as_str()).unwrap_or("Admin Freeze").to_string();

    let kernel_lock = state.kernel.as_ref().ok_or((StatusCode::SERVICE_UNAVAILABLE, Json(serde_json::json!({"error": "Kernel unavailable"}))))?;
    let kernel = kernel_lock.read().await;

    kernel.safety.governance.write().freeze(account_id, reason.clone(), "admin".into())
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, Json(serde_json::json!({"error": e.to_string()}))))?;
    
    let _ = kernel.safety.audit.write().log(0, account_id, "admin".into(), 0, lyxal_os::safety::audit::SafetyAction::AdminFreeze, lyxal_os::safety::audit::SafetyDecision::Frozen, 0);

    Ok(Json(serde_json::json!({"status": "frozen", "account_id": account_id_hex})))
}

async fn p31_unfreeze(
    Extension(state): Extension<AppState>,
    headers: HeaderMap,
    axum::extract::Path(account_id_hex): axum::extract::Path<String>,
) -> Result<Json<serde_json::Value>, (StatusCode, Json<serde_json::Value>)> {
    if !is_admin(&headers) {
        return Err((StatusCode::FORBIDDEN, Json(serde_json::json!({"error": "Admin only"}))));
    }
    let account_id = u128::from_str_radix(&account_id_hex, 16).map_err(|_| (StatusCode::BAD_REQUEST, Json(serde_json::json!({"error": "Invalid ID"}))))?;

    let kernel_lock = state.kernel.as_ref().ok_or((StatusCode::SERVICE_UNAVAILABLE, Json(serde_json::json!({"error": "Kernel unavailable"}))))?;
    let kernel = kernel_lock.read().await;

    kernel.safety.governance.write().unfreeze(account_id)
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, Json(serde_json::json!({"error": e.to_string()}))))?;
    
    let _ = kernel.safety.audit.write().log(0, account_id, "admin".into(), 0, lyxal_os::safety::audit::SafetyAction::AdminUnfreeze, lyxal_os::safety::audit::SafetyDecision::Allow, 0);

    Ok(Json(serde_json::json!({"status": "active", "account_id": account_id_hex})))
}

async fn p31_dispute(
    Extension(state): Extension<AppState>,
    headers: HeaderMap,
    axum::extract::Path(tx_id_str): axum::extract::Path<String>,
    Json(body): Json<serde_json::Value>,
) -> Result<Json<serde_json::Value>, (StatusCode, Json<serde_json::Value>)> {
    if !is_admin(&headers) {
        return Err((StatusCode::FORBIDDEN, Json(serde_json::json!({"error": "Admin only"}))));
    }
    let tx_id = u128::from_str_radix(&tx_id_str, 16).map_err(|_| (StatusCode::BAD_REQUEST, Json(serde_json::json!({"error": "Invalid Tx ID"}))))?;
    
    let account_id_str = body.get("account_id").and_then(|s| s.as_str()).ok_or((StatusCode::BAD_REQUEST, Json(serde_json::json!({"error": "Missing account_id"}))))?;
    let account_id = u128::from_str_radix(account_id_str, 16).map_err(|_| (StatusCode::BAD_REQUEST, Json(serde_json::json!({"error": "Invalid account_id"}))))?;
    
    let amount = body.get("amount").and_then(|v| v.as_i64()).ok_or((StatusCode::BAD_REQUEST, Json(serde_json::json!({"error": "Missing amount"}))))?;
    let reason = body.get("reason").and_then(|s| s.as_str()).unwrap_or("Dispute").to_string();

    let kernel_lock = state.kernel.as_ref().ok_or((StatusCode::SERVICE_UNAVAILABLE, Json(serde_json::json!({"error": "Kernel unavailable"}))))?;
    let kernel = kernel_lock.read().await;

    kernel.safety.governance.write().dispute_tx(account_id, tx_id, amount, reason)
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, Json(serde_json::json!({"error": e.to_string()}))))?;

    let _ = kernel.safety.audit.write().log(0, account_id, "admin".into(), tx_id, lyxal_os::safety::audit::SafetyAction::AdminDispute, lyxal_os::safety::audit::SafetyDecision::Disputed, 0);

    Ok(Json(serde_json::json!({"status": "disputed", "held_amount": amount})))
}

async fn p31_get_audit(
    Extension(state): Extension<AppState>,
    headers: HeaderMap,
    axum::extract::Path(account_id_hex): axum::extract::Path<String>,
) -> Result<Json<serde_json::Value>, (StatusCode, Json<serde_json::Value>)> {
     if !is_admin(&headers) {
           return Err((StatusCode::FORBIDDEN, Json(serde_json::json!({"error": "Admin only"}))));
     }
     let account_id = u128::from_str_radix(&account_id_hex, 16).map_err(|_| (StatusCode::BAD_REQUEST, Json(serde_json::json!({"error": "Invalid ID"}))))?;
     
     let kernel_lock = state.kernel.as_ref().ok_or((StatusCode::SERVICE_UNAVAILABLE, Json(serde_json::json!({"error": "Kernel unavailable"}))))?;
     let kernel = kernel_lock.read().await;

     let entries = kernel.safety.audit.read().read_entries(Some(account_id), 100)
         .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, Json(serde_json::json!({"error": e.to_string()}))))?;

     Ok(Json(serde_json::json!(entries)))
}

// === P32 Settlement Handlers ===

async fn ingest_mock_deposit(
    Extension(state): Extension<AppState>,
    headers: HeaderMap,
    Json(body): Json<SettlementDepositRequest>,
) -> Result<Json<serde_json::Value>, (StatusCode, Json<serde_json::Value>)> {
    if !is_admin(&headers) {
        return Err((StatusCode::FORBIDDEN, Json(serde_json::json!({"error": "Admin only"}))));
    }

    let account_id = u128::from_str_radix(&body.account_id, 16)
        .map_err(|_| (StatusCode::BAD_REQUEST, Json(serde_json::json!({"error": "Invalid account_id"}))))?;

    let kernel_lock = state.kernel.as_ref().ok_or((StatusCode::SERVICE_UNAVAILABLE, Json(serde_json::json!({"error": "Kernel unavailable"}))))?;
    let kernel = kernel_lock.read().await;

    // Create a mock external payment
    let payment = ExternalPayment {
        provider: ProviderId::Mock,
        external_id: body.external_id,
        account_id,
        realm_id: None,
        kind: PaymentKind::Deposit,
        amount_micros: body.amount_micros,
        status: PaymentStatus::Succeeded,
        observed_at_ns: std::time::SystemTime::now().duration_since(std::time::UNIX_EPOCH).unwrap().as_nanos() as u64,
        idempotency_key: [0u8; 32], // Simplified for mock
        raw_digest: [0u8; 32],
        tx_id: None,
        apply_state: ApplyState::Recorded,
    };

    let result = kernel.settlement.ingest_deposit(payment).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, Json(serde_json::json!({"error": e.to_string()}))))?;

    Ok(Json(serde_json::json!(result)))
}

async fn request_withdrawal(
    Extension(state): Extension<AppState>,
    headers: HeaderMap,
    Json(body): Json<SettlementWithdrawalRequest>,
) -> Result<Json<serde_json::Value>, (StatusCode, Json<serde_json::Value>)> {
    if !is_admin(&headers) {
        return Err((StatusCode::FORBIDDEN, Json(serde_json::json!({"error": "Admin only"}))));
    }

    let account_id = u128::from_str_radix(&body.account_id, 16)
        .map_err(|_| (StatusCode::BAD_REQUEST, Json(serde_json::json!({"error": "Invalid account_id"}))))?;

    let kernel_lock = state.kernel.as_ref().ok_or((StatusCode::SERVICE_UNAVAILABLE, Json(serde_json::json!({"error": "Kernel unavailable"}))))?;
    let kernel = kernel_lock.read().await;

    // Create an external withdrawal payment
    let payment = ExternalPayment {
        provider: ProviderId::Mock, // Default to mock for now
        external_id: format!("with_{}", uuid::Uuid::new_v4()),
        account_id,
        realm_id: None,
        kind: PaymentKind::Withdrawal,
        amount_micros: body.amount_micros,
        status: PaymentStatus::Pending,
        observed_at_ns: std::time::SystemTime::now().duration_since(std::time::UNIX_EPOCH).unwrap().as_nanos() as u64,
        idempotency_key: [0u8; 32], 
        raw_digest: [0u8; 32],
        tx_id: None,
        apply_state: ApplyState::Recorded,
    };

    let result = kernel.settlement.initiate_withdrawal(payment).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, Json(serde_json::json!({"error": e.to_string()}))))?;

    Ok(Json(serde_json::json!(result)))
}

async fn get_settlement_payment(
    Extension(state): Extension<AppState>,
    axum::extract::Path((provider_str, id)): axum::extract::Path<(String, String)>,
) -> Result<Json<serde_json::Value>, (StatusCode, Json<serde_json::Value>)> {
    let provider = match provider_str.to_lowercase().as_str() {
        "mock" => ProviderId::Mock,
        "stripe" => ProviderId::Stripe,
        _ => return Err((StatusCode::BAD_REQUEST, Json(serde_json::json!({"error": "Invalid provider"})))),
    };

    let kernel_lock = state.kernel.as_ref().ok_or((StatusCode::SERVICE_UNAVAILABLE, Json(serde_json::json!({"error": "Kernel unavailable"}))))?;
    let kernel = kernel_lock.read().await;

    let payment = kernel.settlement.get_payment(provider, &id).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, Json(serde_json::json!({"error": e.to_string()}))))?
        .ok_or((StatusCode::NOT_FOUND, Json(serde_json::json!({"error": "Payment not found"}))))?;

    Ok(Json(serde_json::json!(payment)))
}
