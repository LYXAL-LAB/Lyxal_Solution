use serde::{Serialize, Deserialize};
use std::collections::BTreeMap;
use crate::realm::RealmId;

pub type MoneyMicros = i64;
pub const MICROS_PER_UNIT: i64 = 1_000_000;

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
pub enum MeterKind {
    Sum, // Addition of values (e.g. bytes, requests)
    Max, // Peak value on period (e.g. max memory used)
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
pub struct PricingMeter {
    pub id: String, // e.g. "storage.bytes", "sync.snapshot.bytes"
    pub kind: MeterKind,
    pub unit_price_micros: MoneyMicros,
    pub free_allowance: i64,      // free units before charging
    pub hard_cap: Option<i64>,    // absolute limit (clampped or rejected)
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
pub enum CycleKind {
    IntervalSecs(u64), // e.g. 3600 for Hourly
    Manual,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
pub struct BillingCycle {
    pub kind: CycleKind,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
pub enum EnforcementMode {
    HardDeny, // Block mutations immediately
    SoftDeny, // Allow read-only/throttled access
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
pub struct PricingPlan {
    pub id: String,
    pub currency: String, // e.g. "EUR"
    pub meters: Vec<PricingMeter>,
    pub cycle: BillingCycle,
    pub enforcement: EnforcementMode,
    pub credit_limit_micros: MoneyMicros,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
pub struct DesiredState {
    pub version: u64,
    pub realms: BTreeMap<RealmId, DesiredRealm>,
    pub policies: Vec<Policy>,
    pub pricing_plans: BTreeMap<String, PricingPlan>, // P29
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
pub struct Policy {
    pub id: String,
    pub scope: PolicyScope,
    pub rules: Vec<PolicyRule>,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
pub enum PolicyScope {
    Global,
    Realm(u128),
    Service(String),
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
pub struct PolicyRule {
    pub effect: PolicyEffect,
    pub principal: PolicyPrincipal,
    pub action: String,
    pub resource: String,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
pub enum PolicyPrincipal {
    Any,
    Node(u128),
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
pub enum PolicyEffect {
    Allow,
    Deny,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
pub struct DesiredRealm {
    pub owner_id: u128, // P27: AccountId
    pub target_status: TargetStatus,
    pub quota: Option<RealmQuotaSpec>,
    pub seeds: Vec<String>,
    pub config_digest: String,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
pub enum TargetStatus {
    Running,
    Stopped,
    Deleted, 
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
pub struct RealmQuotaSpec {
    pub max_peers: usize,
}

impl DesiredState {
    pub fn new(version: u64) -> Self {
        Self {
            version,
            realms: BTreeMap::new(),
            policies: Vec::new(),
            pricing_plans: BTreeMap::new(),
        }
    }

    pub fn hash(&self) -> String {
        let mut hasher = blake3::Hasher::new();
        // Canonical hashing via JSON serialization
        // Note: Sort-stable JSON would be better but BTreeMap helps for fields.
        let json = serde_json::to_vec(&self).unwrap(); 
        hasher.update(&json);
        hasher.finalize().to_hex().to_string()
    }
}
