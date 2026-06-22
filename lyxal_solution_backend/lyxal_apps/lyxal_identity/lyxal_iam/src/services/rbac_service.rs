use crate::Result;
use lyxal_schema::{Role, RoleType, Scope};
use sqlx::{PgPool, query_as};

#[derive(Clone)]
pub struct RbacService {
    pool: PgPool,
}

impl RbacService {
    pub fn new(pool: PgPool) -> Self {
        Self { pool }
    }

    // Role Management
    pub async fn create_role(&self, name: String, r#type: RoleType, description: Option<String>) -> Result<Role> {
        let id = uuid::Uuid::new_v4().to_string();
        let now = chrono::Utc::now().timestamp_millis();

        let role = query_as!(
            Role,
            r#"
            INSERT INTO roles (id, name, type, description, created_at, updated_at)
            VALUES ($1, $2, $3, $4, $5, $6)
            RETURNING id, name, type as "type: _", description, created_at, updated_at
            "#,
            id, name, r#type as _, description, now, now
        )
        .fetch_one(&self.pool)
        .await
        .map_err(|e| lyxal_core::error::CoreError::Database(e.to_string()))?;

        Ok(role)
    }

    pub async fn get_role_by_id(&self, id: String) -> Result<Role> {
        query_as!(
            Role,
            r#"SELECT id, name, type as "type: _", description, created_at, updated_at FROM roles WHERE id = $1"#,
            id
        )
        .fetch_one(&self.pool)
        .await
        .map_err(|_| lyxal_core::error::CoreError::NotFound)
    }

    // Scope Management
    pub async fn create_scope(&self, resource_id: String, name: String, description: Option<String>) -> Result<Scope> {
        let id = uuid::Uuid::new_v4().to_string();
        let now = chrono::Utc::now().timestamp_millis();

        let scope = query_as!(
            Scope,
            r#"
            INSERT INTO scopes (id, resource_id, name, description, created_at, updated_at)
            VALUES ($1, $2, $3, $4, $5, $6)
            RETURNING id, resource_id, name, description, created_at, updated_at
            "#,
            id, resource_id, name, description, now, now
        )
        .fetch_one(&self.pool)
        .await
        .map_err(|e| lyxal_core::error::CoreError::Database(e.to_string()))?;

        Ok(scope)
    }

    // Assignment Logic (Simplified Logto Parity)
    pub async fn assign_role_to_user(&self, user_id: String, role_id: String) -> Result<()> {
        sqlx::query!(
            "INSERT INTO users_roles (user_id, role_id) VALUES ($1, $2) ON CONFLICT DO NOTHING",
            user_id, role_id
        )
        .execute(&self.pool)
        .await
        .map_err(|e| lyxal_core::error::CoreError::Database(e.to_string()))?;
        Ok(())
    }

    pub async fn get_user_roles(&self, user_id: String) -> Result<Vec<Role>> {
        let roles = query_as!(
            Role,
            r#"
            SELECT r.id, r.name, r.type as "type: _", r.description, r.created_at, r.updated_at
            FROM roles r
            JOIN users_roles ur ON r.id = ur.role_id
            WHERE ur.user_id = $1
            "#,
            user_id
        )
        .fetch_all(&self.pool)
        .await
        .map_err(|e| lyxal_core::error::CoreError::Database(e.to_string()))?;
        Ok(roles)
    }
}
