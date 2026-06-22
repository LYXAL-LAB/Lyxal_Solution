use chrono::Utc;
use lyxal_core::Result;
use lyxal_schema::Tenant;
use sqlx::{PgPool, Row};
use uuid::Uuid;

/// Repository for handling Tenant (Organization) related database operations.
/// Tenants are the top-level containers for users, roles, and applications.
/// Uses runtime SQL queries to allow development without an active database connection.
#[derive(Clone)]
pub struct TenantRepository {
    pool: PgPool,
}

impl TenantRepository {
    /// Creates a new TenantRepository instance.
    pub fn new(pool: PgPool) -> Self {
        Self { pool }
    }

    /// Finds a tenant by its unique ID.
    pub async fn find_by_id(&self, id: Uuid) -> Result<Option<Tenant>> {
        let tenant = sqlx::query_as::<_, Tenant>(
            r#"
            SELECT
                id, name, slug, logo, created_at, updated_at
            FROM tenants
            WHERE id = $1
            "#,
        )
        .bind(id)
        .fetch_optional(&self.pool)
        .await?;

        Ok(tenant)
    }

    /// Finds a tenant by its unique slug.
    pub async fn find_by_slug(&self, slug: &str) -> Result<Option<Tenant>> {
        let tenant = sqlx::query_as::<_, Tenant>(
            r#"
            SELECT
                id, name, slug, logo, created_at, updated_at
            FROM tenants
            WHERE slug = $1
            "#,
        )
        .bind(slug)
        .fetch_optional(&self.pool)
        .await?;

        Ok(tenant)
    }

    /// Creates a new tenant in the database.
    pub async fn create(&self, tenant: Tenant) -> Result<Tenant> {
        let now = Utc::now();
        let created_tenant = sqlx::query_as::<_, Tenant>(
            r#"
            INSERT INTO tenants (id, name, slug, logo, created_at, updated_at)
            VALUES ($1, $2, $3, $4, $5, $6)
            RETURNING id, name, slug, logo, created_at, updated_at
            "#,
        )
        .bind(tenant.id)
        .bind(tenant.name)
        .bind(tenant.slug)
        .bind(tenant.logo)
        .bind(now)
        .bind(now)
        .fetch_one(&self.pool)
        .await?;

        Ok(created_tenant)
    }

    /// Updates an existing tenant's information.
    pub async fn update(&self, tenant: Tenant) -> Result<Tenant> {
        let now = Utc::now();
        let updated_tenant = sqlx::query_as::<_, Tenant>(
            r#"
            UPDATE tenants SET
                name = $2,
                slug = $3,
                logo = $4,
                updated_at = $5
            WHERE id = $1
            RETURNING id, name, slug, logo, created_at, updated_at
            "#,
        )
        .bind(tenant.name)
        .bind(tenant.slug)
        .bind(tenant.logo)
        .bind(now)
        .bind(tenant.id)
        .fetch_one(&self.pool)
        .await?;

        Ok(updated_tenant)
    }

    /// Deletes a tenant by its ID.
    pub async fn delete(&self, id: Uuid) -> Result<()> {
        sqlx::query("DELETE FROM tenants WHERE id = $1")
            .bind(id)
            .execute(&self.pool)
            .await?;
        Ok(())
    }

    /// Lists tenants with pagination.
    pub async fn list(&self, limit: i64, offset: i64) -> Result<Vec<Tenant>> {
        let tenants = sqlx::query_as::<_, Tenant>(
            r#"
            SELECT
                id, name, slug, logo, created_at, updated_at
            FROM tenants
            ORDER BY created_at DESC
            LIMIT $1 OFFSET $2
            "#,
        )
        .bind(limit)
        .bind(offset)
        .fetch_all(&self.pool)
        .await?;

        Ok(tenants)
    }
}
