use serde::{Serialize, Deserialize};

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub enum TrustLevel {
    New,      // Strict limits
    Normal,   // Default
    Trusted,  // Higher limits
    VIP,      // No velocity check
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RiskProfile {
    pub max_tx_value_micros: i64,
    pub max_daily_spend_micros: i64,
    pub max_tx_per_minute: u32,
    pub anomaly_ratio_bp: u32, // e.g. 50000 = 500%
    pub trust_level: TrustLevel,
}

impl Default for RiskProfile {
    fn default() -> Self {
        Self {
            max_tx_value_micros: 1_000_000_000, // 1000 credits
            max_daily_spend_micros: 10_000_000_000, // 10k credits
            max_tx_per_minute: 10,
            anomaly_ratio_bp: 50000, // 500%
            trust_level: TrustLevel::Normal,
        }
    }
}

pub struct RiskEngine {
    // In-mem cache of profiles? Or just stateless logic?
    // User said: "Output: RiskDecision (Allow, Deny, PendingReview)"
    // Input: Tx + Account History.
    // We need some state for VelocityWindow.
    // Velocity needs to be tracked.
    // For P31, we might use a simple Hashmap<AccountId, VelocityState>.
    pub velocity_state: std::collections::HashMap<u128, VelocityState>,
}

#[derive(Debug, Clone)]
pub struct VelocityState {
    pub last_bucket_min: u64,
    pub count_min: u32,
    pub daily_spend: i64, // Needs reset logic
    pub last_reset_day: u64,
}

impl RiskEngine {
    pub fn new() -> Self {
        Self {
            velocity_state: std::collections::HashMap::new(),
        }
    }

    pub fn evaluate(&mut self, account_id: u128, amount: i64, profile: &RiskProfile) -> crate::safety::audit::SafetyDecision {
        let now_sec = std::time::SystemTime::now().duration_since(std::time::UNIX_EPOCH).unwrap().as_secs();
        let current_min = now_sec / 60;
        let current_day = now_sec / 86400;

        // 1. Static Limits
        if amount > profile.max_tx_value_micros {
             return crate::safety::audit::SafetyDecision::Deny(format!("Tx amount {} exceeds max {}", amount, profile.max_tx_value_micros));
        }

        // 2. Velocity & Daily
        let state = self.velocity_state.entry(account_id).or_insert(VelocityState {
            last_bucket_min: current_min,
            count_min: 0,
            daily_spend: 0,
            last_reset_day: current_day,
        });

        // Reset counters if needed
        if state.last_bucket_min != current_min {
            state.count_min = 0;
            state.last_bucket_min = current_min;
        }
        if state.last_reset_day != current_day {
            state.daily_spend = 0;
            state.last_reset_day = current_day;
        }

        // Checks
        if state.count_min >= profile.max_tx_per_minute {
             return crate::safety::audit::SafetyDecision::Deny(format!("Velocity limit: > {} tx/min", profile.max_tx_per_minute));
        }

        if state.daily_spend + amount > profile.max_daily_spend_micros {
             return crate::safety::audit::SafetyDecision::Deny(format!("Daily spend limit: > {}", profile.max_daily_spend_micros));
        }

        // Apply
        state.count_min += 1;
        state.daily_spend += amount;

        crate::safety::audit::SafetyDecision::Allow
    }
}
