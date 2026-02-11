use crate::repository::rbac_repository::RbacRepository;
use crate::Scope;
use lyxal_core::{CoreError, Result};
use uuid::Uuid;

/// Enforcer is the core engine for making authorization decisions.
/// It checks if a user has the required permissions (scopes) within a given context.
#[derive(Clone)]
pub struct Enforcer {
    repository: RbacRepository,
}

impl Enforcer {
    /// Creates a new Enforcer instance.
    pub fn new(repository: RbacRepository) -> Self {
        Self { repository }
    }

    /// Checks if a user has a specific permission (scope) in a tenant context.
    ///
    /// # Arguments
    /// * `user_id` - The ID of the user being checked.
    /// * `tenant_id` - Optional ID of the tenant. If None, checks for global permissions.
    /// * `required_scope` - The scope required to perform the action (e.g., "users:read").
    ///
    /// # Returns
    /// A Result containing a boolean: true if allowed, false otherwise.
    pub async fn enforce(
        &self,
        user_id: Uuid,
        tenant_id: Option<Uuid>,
        required_scope: &str,
    ) -> Result<bool> {
        // 1. Parse the required scope to ensure validity
        let parts: Vec<&str> = required_scope.split(':').collect();
        if parts.len() != 2 {
            return Err(CoreError::Validation(format!(
                "Invalid scope format: '{}'. Expected 'resource:action'",
                required_scope
            )));
        }

        // 2. Delegate the check to the repository which handles the SQL logic
        self.repository
            .check_user_permission(user_id, tenant_id, required_scope)
            .await
    }

    /// Checks if a user has at least one of the required scopes.
    pub async fn enforce_any(
        &self,
        user_id: Uuid,
        tenant_id: Option<Uuid>,
        required_scopes: Vec<&str>,
    ) -> Result<bool> {
        for scope in required_scopes {
            if self.enforce(user_id, tenant_id, scope).await? {
                return Ok(true);
            }
        }
        Ok(false)
    }
}

/// Helper structure for Scope parsing and validation
impl From<&str> for Scope {
    fn from(s: &str) -> Self {
        let parts: Vec<&str> = s.split(':').collect();
        if parts.len() == 2 {
            Scope {
                resource: parts[0].to_string(),
                action: parts[1].to_string(),
            }
        } else {
            Scope {
                resource: s.to_string(),
                action: "all".to_string(),
            }
        }
    }
}
