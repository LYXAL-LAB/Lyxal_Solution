use chrono::Utc;
use lyxal_core::Result;
use lyxal_schema::{Permission, Role};
use sqlx::PgPool;
use uuid::Uuid;

/// Repository for handling RBAC-related database operations.
/// This includes management of roles, permissions, and their assignments.
/// Uses runtime SQL queries for flexible development.
#[derive(Clone)]
pub struct RbacRepository {
    pool: PgPool,
}

impl RbacRepository {
    /// Creates a new RbacRepository instance.
    pub fn new(pool: PgPool) -> Self {
        Self { pool }
    }

    /// Returns a reference to the database pool.
    pub fn pool(&self) -> &PgPool {
        &self.pool
    }

    // --- Role Operations ---

    /// Finds a role by its unique ID.
    pub async fn find_role_by_id(&self, id: Uuid) -> Result<Option<Role>> {
        let role = sqlx::query_as::<_, Role>(
            r#"
            SELECT id, tenant_id, name, description, is_default, created_at, updated_at
            FROM roles
            WHERE id = $1
            "#,
        )
        .bind(id)
        .fetch_optional(&self.pool)
        .await?;

        Ok(role)
    }

    /// Finds a role by name within a tenant (or global).
    pub async fn find_role_by_name(
        &self,
        tenant_id: Option<Uuid>,
        name: &str,
    ) -> Result<Option<Role>> {
        let role = sqlx::query_as::<_, Role>(
            r#"
            SELECT id, tenant_id, name, description, is_default, created_at, updated_at
            FROM roles
            WHERE (tenant_id IS NOT DISTINCT FROM $1) AND name = $2
            "#,
        )
        .bind(tenant_id)
        .bind(name)
        .fetch_optional(&self.pool)
        .await?;

        Ok(role)
    }

    /// Creates a new role.
    pub async fn create_role(&self, role: Role) -> Result<Role> {
        let now = Utc::now();
        let created_role = sqlx::query_as::<_, Role>(
            r#"
            INSERT INTO roles (id, tenant_id, name, description, is_default, created_at, updated_at)
            VALUES ($1, $2, $3, $4, $5, $6, $7)
            RETURNING id, tenant_id, name, description, is_default, created_at, updated_at
            "#,
        )
        .bind(role.id)
        .bind(role.tenant_id)
        .bind(role.name)
        .bind(role.description)
        .bind(role.is_default)
        .bind(now)
        .bind(now)
        .fetch_one(&self.pool)
        .await?;

        Ok(created_role)
    }

    // --- Permission Operations ---

    /// Finds a permission by its unique name (e.g. "users:read").
    pub async fn find_permission_by_name(&self, name: &str) -> Result<Option<Permission>> {
        let permission = sqlx::query_as::<_, Permission>(
            r#"
            SELECT id, name, description, resource_id, action, created_at
            FROM permissions
            WHERE name = $1
            "#,
        )
        .bind(name)
        .fetch_optional(&self.pool)
        .await?;

        Ok(permission)
    }

    /// Creates a new permission.
    pub async fn create_permission(&self, permission: Permission) -> Result<Permission> {
        let created_permission = sqlx::query_as::<_, Permission>(
            r#"
            INSERT INTO permissions (id, name, description, resource_id, action, created_at)
            VALUES ($1, $2, $3, $4, $5, $6)
            RETURNING id, name, description, resource_id, action, created_at
            "#,
        )
        .bind(permission.id)
        .bind(permission.name)
        .bind(permission.description)
        .bind(permission.resource_id)
        .bind(permission.action)
        .bind(permission.created_at)
        .fetch_one(&self.pool)
        .await?;

        Ok(created_permission)
    }

    // --- Assignment Operations ---

    /// Assigns a role to a user in a specific tenant context.
    pub async fn assign_role_to_user(
        &self,
        user_id: Uuid,
        role_id: Uuid,
        tenant_id: Option<Uuid>,
    ) -> Result<()> {
        sqlx::query(
            r#"
            INSERT INTO user_roles (user_id, role_id, tenant_id)
            VALUES ($1, $2, $3)
            ON CONFLICT DO NOTHING
            "#,
        )
        .bind(user_id)
        .bind(role_id)
        .bind(tenant_id)
        .execute(&self.pool)
        .await?;

        Ok(())
    }

    /// Links a permission to a role.
    pub async fn add_permission_to_role(&self, role_id: Uuid, permission_id: Uuid) -> Result<()> {
        sqlx::query(
            r#"
            INSERT INTO role_permissions (role_id, permission_id)
            VALUES ($1, $2)
            ON CONFLICT DO NOTHING
            "#,
        )
        .bind(role_id)
        .bind(permission_id)
        .execute(&self.pool)
        .await?;

        Ok(())
    }

    /// Checks if a user has a specific permission in a tenant context.
    pub async fn check_user_permission(
        &self,
        user_id: Uuid,
        tenant_id: Option<Uuid>,
        permission_name: &str,
    ) -> Result<bool> {
        let row: (bool,) = sqlx::query_as(
            r#"
            SELECT EXISTS (
                SELECT 1
                FROM user_roles ur
                JOIN role_permissions rp ON ur.role_id = rp.role_id
                JOIN permissions p ON rp.permission_id = p.id
                WHERE ur.user_id = $1
                  AND (ur.tenant_id IS NOT DISTINCT FROM $2)
                  AND p.name = $3
            )
            "#,
        )
        .bind(user_id)
        .bind(tenant_id)
        .bind(permission_name)
        .fetch_one(&self.pool)
        .await?;

        Ok(row.0)
    }
}
