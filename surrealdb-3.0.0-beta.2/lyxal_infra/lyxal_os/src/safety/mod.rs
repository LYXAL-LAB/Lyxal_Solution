pub mod audit;
pub mod governance;
pub mod risk;

use std::sync::Arc;
use parking_lot::RwLock;

// Re-exports
pub use audit::SecureAuditLog;
pub use governance::GovernanceManager;
pub use risk::RiskEngine;

#[derive(Clone)]
pub struct SafetyManager {
    pub audit: Arc<RwLock<SecureAuditLog>>,
    pub risk: Arc<RwLock<RiskEngine>>,
    pub governance: Arc<RwLock<GovernanceManager>>,
}

impl SafetyManager {
    pub fn new(db: Arc<lyxalkv::Tree>, data_dir: std::path::PathBuf) -> Self {
        Self {
            audit: Arc::new(RwLock::new(SecureAuditLog::new(db))),
            risk: Arc::new(RwLock::new(RiskEngine::new())),
            // Governance still uses file for now, pass data_dir
            governance: Arc::new(RwLock::new(GovernanceManager::new(data_dir))),
        }
    }
}
