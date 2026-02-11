use crate::repository::rbac_repository::RbacRepository;
use chrono::Utc;
use lyxal_core::{CoreError, Result};
use lyxal_schema::Role;
use uuid::Uuid;

/// Service handling business logic for RBAC Roles.
/// Roles can be global (tenant_id is None) or specific to a tenant.
#[derive(Clone)]
pub struct RoleService {
    repository: RbacRepository,
}

impl RoleService {
    /// Creates a new instance of RoleService.
    pub fn new(repository: RbacRepository) -> Self {
        Self { repository }
    }

    /// Creates a new role.
    ///
    /// # Arguments
    /// * `tenant_id` - Optional Uuid of the tenant. If None, the role is global.
    /// * `name` - Unique name for the role within its scope.
    /// * `description` - Optional description of the role's purpose.
    pub async fn create_role(
        &self,
        tenant_id: Option<Uuid>,
        name: String,
        description: Option<String>,
        is_default: bool,
    ) -> Result<Role> {
        if name.trim().is_empty() {
            return Err(CoreError::Validation("Role name cannot be empty".to_string()));
        }

        // Check for existing role with same name in same scope
        if let Some(_) = self.repository.find_role_by_name(tenant_id, &name).await? {
            return Err(CoreError::Conflict(format!(
                "Role with name '{}' already exists in this scope",
                name
            )));
        }

        let now = Utc::now();
        let role = Role {
            id: Uuid::new_v4(),
            tenant_id,
            name,
            description,
            is_default,
            created_at: now,
            updated_at: now,
        };

        self.repository.create_role(role).await
    }

    /// Retrieves a role by its ID.
    pub async fn get_role_by_id(&self, id: Uuid) -> Result<Role> {
        self.repository
            .find_role_by_id(id)
            .await?
            .ok_or_else(|| CoreError::NotFound(format!("Role with ID {} not found", id)))
    }

    /// Assigns a role to a user within a tenant.
    pub async fn assign_role_to_user(
        &self,
        user_id: Uuid,
        role_id: Uuid,
        tenant_id: Option<Uuid>,
    ) -> Result<()> {
        // Verify role exists
        let _ = self.get_role_by_id(role_id).await?;

        self.repository
            .assign_role_to_user(user_id, role_id, tenant_id)
            .await
    }
}
