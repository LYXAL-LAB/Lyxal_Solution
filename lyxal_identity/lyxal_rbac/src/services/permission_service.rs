use crate::repository::rbac_repository::RbacRepository;
use chrono::Utc;
use lyxal_core::{CoreError, Result};
use lyxal_schema::Permission;
use uuid::Uuid;

/// Service handling business logic for RBAC Permissions.
/// Permissions define what actions can be performed on which resources.
#[derive(Clone)]
pub struct PermissionService {
    repository: RbacRepository,
}

impl PermissionService {
    /// Creates a new instance of PermissionService.
    pub fn new(repository: RbacRepository) -> Self {
        Self { repository }
    }

    /// Creates a new permission.
    ///
    /// # Arguments
    /// * `resource_id` - The identifier of the resource (e.g., "users", "api:v1:orders").
    /// * `action` - The action allowed on the resource (e.g., "read", "write", "delete").
    /// * `description` - Optional human-readable description.
    pub async fn create_permission(
        &self,
        resource_id: String,
        action: String,
        description: Option<String>,
    ) -> Result<Permission> {
        if resource_id.trim().is_empty() || action.trim().is_empty() {
            return Err(CoreError::Validation(
                "Resource ID and Action cannot be empty".to_string(),
            ));
        }

        // Canonical name for the permission (e.g., "users:read")
        let name = format!("{}:{}", resource_id.to_lowercase(), action.to_lowercase());

        // Check if permission already exists
        if self.repository.find_permission_by_name(&name).await?.is_some() {
            return Err(CoreError::Conflict(format!(
                "Permission '{}' already exists",
                name
            )));
        }

        let permission = Permission {
            id: Uuid::new_v4(),
            name,
            description,
            resource_id,
            action,
            created_at: Utc::now(),
        };

        self.repository.create_permission(permission).await
    }

    /// Retrieves a permission by its name (e.g., "users:write").
    pub async fn get_permission_by_name(&self, name: &str) -> Result<Permission> {
        self.repository
            .find_permission_by_name(name)
            .await?
            .ok_or_else(|| CoreError::NotFound(format!("Permission '{}' not found", name)))
    }
}
