use chrono::Utc;
use lyxal_core::Result;
use lyxal_schema::Application;
use sqlx::{PgPool, Row};
use uuid::Uuid;

/// Repository for handling Application-related database operations.
/// Manages the registration and metadata of OAuth2/OIDC clients.
/// Uses runtime SQL queries to allow development without an active database connection.
#[derive(Clone)]
pub struct ApplicationRepository {
    pool: PgPool,
}

impl ApplicationRepository {
    /// Creates a new ApplicationRepository instance.
    pub fn new(pool: PgPool) -> Self {
        Self { pool }
    }

    /// Finds an application by its unique ID.
    pub async fn find_by_id(&self, id: Uuid) -> Result<Option<Application>> {
        let application = sqlx::query_as::<_, Application>(
            r#"
            SELECT
                id, name, secret, description, is_first_party,
                redirect_uris, post_logout_redirect_uris, allowed_cors_origins,
                created_at, updated_at
            FROM applications
            WHERE id = $1
            "#,
        )
        .bind(id)
        .fetch_optional(&self.pool)
        .await?;

        Ok(application)
    }

    /// Creates a new application entry.
    pub async fn create(&self, app: Application) -> Result<Application> {
        let now = Utc::now();
        let created_app = sqlx::query_as::<_, Application>(
            r#"
            INSERT INTO applications (
                id, name, secret, description, is_first_party,
                application_type, redirect_uris, post_logout_redirect_uris,
                allowed_cors_origins, created_at, updated_at
            )
            VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
            RETURNING id, name, secret, description, is_first_party,
                      redirect_uris, post_logout_redirect_uris, allowed_cors_origins,
                      created_at, updated_at
            "#,
        )
        .bind(app.id)
        .bind(app.name)
        .bind(app.secret)
        .bind(app.description)
        .bind(app.is_first_party)
        .bind("web") // Defaulting to web for now
        .bind(&app.redirect_uris)
        .bind(&app.post_logout_redirect_uris)
        .bind(&app.allowed_cors_origins)
        .bind(now)
        .bind(now)
        .fetch_one(&self.pool)
        .await?;

        Ok(created_app)
    }

    /// Updates an existing application's configuration.
    pub async fn update(&self, app: Application) -> Result<Application> {
        let now = Utc::now();
        let updated_app = sqlx::query_as::<_, Application>(
            r#"
            UPDATE applications SET
                name = $2,
                secret = $3,
                description = $4,
                is_first_party = $5,
                redirect_uris = $6,
                post_logout_redirect_uris = $7,
                allowed_cors_origins = $8,
                updated_at = $9
            WHERE id = $1
            RETURNING id, name, secret, description, is_first_party,
                      redirect_uris, post_logout_redirect_uris, allowed_cors_origins,
                      created_at, updated_at
            "#,
        )
        .bind(app.id)
        .bind(app.name)
        .bind(app.secret)
        .bind(app.description)
        .bind(app.is_first_party)
        .bind(&app.redirect_uris)
        .bind(&app.post_logout_redirect_uris)
        .bind(&app.allowed_cors_origins)
        .bind(now)
        .fetch_one(&self.pool)
        .await?;

        Ok(updated_app)
    }

    /// Deletes an application by its ID.
    pub async fn delete(&self, id: Uuid) -> Result<()> {
        sqlx::query("DELETE FROM applications WHERE id = $1")
            .bind(id)
            .execute(&self.pool)
            .await?;
        Ok(())
    }

    /// Lists all registered applications.
    pub async fn list(&self) -> Result<Vec<Application>> {
        let apps = sqlx::query_as::<_, Application>(
            r#"
            SELECT
                id, name, secret, description, is_first_party,
                redirect_uris, post_logout_redirect_uris, allowed_cors_origins,
                created_at, updated_at
            FROM applications
            ORDER BY created_at DESC
            "#,
        )
        .fetch_all(&self.pool)
        .await?;

        Ok(apps)
    }
}
