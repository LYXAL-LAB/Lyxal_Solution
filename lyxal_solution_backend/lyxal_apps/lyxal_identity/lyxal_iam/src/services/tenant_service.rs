use crate::Result;
use lyxal_schema::Tenant;
use sqlx::{PgPool, query_as};

#[derive(Clone)]
pub struct TenantService {
    pool: PgPool,
}

impl TenantService {
    pub fn new(pool: PgPool) -> Self {
        Self { pool }
    }

    pub async fn create_tenant(&self, name: String, tag: String) -> Result<Tenant> {
        let id = uuid::Uuid::new_4().to_string();
        let now = chrono::Utc::now().timestamp_millis();
        let tenant = query_as!(
            Tenant,
            "INSERT INTO tenants (id, name, tag, created_at) VALUES ($1, $2, $3, $4) RETURNING id, name, tag, created_at",
            id, name, tag, now
        )
        .fetch_one(&self.pool)
        .await
        .map_err(|e| lyxal_core::error::CoreError::Database(e.to_string()))?;
        Ok(tenant)
    }

    pub async fn get_tenant_by_id(&self, id: String) -> Result<Tenant> {
        query_as!(Tenant, "SELECT id, name, tag, created_at FROM tenants WHERE id = $1", id)
            .fetch_one(&self.pool)
            .await
            .map_err(|_| lyxal_core::error::CoreError::NotFound)
    }

    pub async fn list_tenants(&self) -> Result<Vec<Tenant>> {
        let tenants = query_as!(Tenant, "SELECT id, name, tag, created_at FROM tenants")
            .fetch_all(&self.pool)
            .await
            .map_err(|e| lyxal_core::error::CoreError::Database(e.to_string()))?;
        Ok(tenants)
    }

    pub async fn update_tenant(&self, id: String, name: String) -> Result<Tenant> {
        let tenant = query_as!(
            Tenant,
            "UPDATE tenants SET name = $1 WHERE id = $2 RETURNING id, name, tag, created_at",
            name, id
        )
        .fetch_one(&self.pool)
        .await
        .map_err(|_| lyxal_core::error::CoreError::NotFound)?;
        Ok(tenant)
    }

    pub async fn delete_tenant(&self, id: String) -> Result<()> {
        sqlx::query!("DELETE FROM tenants WHERE id = $1", id)
            .execute(&self.pool)
            .await
            .map_err(|e| lyxal_core::error::CoreError::Database(e.to_string()))?;
        Ok(())
    }
}
