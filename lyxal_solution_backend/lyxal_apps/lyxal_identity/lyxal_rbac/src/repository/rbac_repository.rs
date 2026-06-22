use sqlx::PgPool;
use std::sync::Arc;

pub struct RoleRepository {
    pool: PgPool,
}

impl RoleRepository {
    pub fn new(pool: PgPool) -> Self {
        Self { pool }
    }

    pub async fn find_default_roles(&self, tenant_id: &str) -> Result<Vec<String>, sqlx::Error> {
        let roles = sqlx::query!(
            "SELECT id FROM roles WHERE tenant_id = $1 AND is_default = TRUE",
            tenant_id
        )
        .fetch_all(&self.pool)
        .await?;

        Ok(roles.into_iter().map(|r| r.id).collect())
    }
}
