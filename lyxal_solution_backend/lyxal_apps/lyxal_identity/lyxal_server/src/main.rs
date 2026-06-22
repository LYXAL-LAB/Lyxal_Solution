use std::sync::Arc;
use tokio::net::TcpListener;
use axum::{Router, Extension};
use lyxal_core::{LyxalConfig, database::Database};
use lyxal_iam::services::{UserService, ApplicationService, TenantService};
use lyxal_telemetry::{init_telemetry, track_exception};

#[tokio::main]
async fn main() -> lyxal_core::Result<()> {
    // 1. Load Environment & Config
    let config = Arc::new(LyxalConfig::from_env()?);
    
    // 2. Initialize Telemetry (1:1 Logto @logto/app-insights)
    init_telemetry("lyxal-identity-core");

    // 3. Setup Database
    let db = match Database::new(&config.database.url).await {
        Ok(db) => db,
        Err(e) => {
            track_exception(&e);

    // 2. Initialize Database
    let db = Database::new(&config.database_url).await?;
    
    // Run migrations
    db.migrate().await?;

    // 3. Initialize services
    let user_service = UserService::new(db.pool().clone());
    let tenant_service = TenantService::new(db.pool().clone());
    let application_service = ApplicationService::new(db.pool().clone());
    let auth_service = AuthService::new(Arc::new(user_service.clone()));

    // 4. Set up routes
    let app = Router::new()
        .nest("/api", lyxal_auth::router(lyxal_auth::AuthState {
            auth_service: lyxal_auth::AuthService::new(Arc::new(user_service.clone())),
            user_service: Arc::new(user_service),
            config: config.clone(),
        }))
        .nest("/oidc", lyxal_oauth::router(()))
        .layer(Extension(db))
        .layer(Extension(config.clone()));

    // 6. Start Server
    let addr = format!("{}:{}", config.server.host, config.server.port);
    tracing::info!("Server listening on {}", addr);
    
    let listener = TcpListener::bind(&addr).await.map_err(|e| {
        track_exception(&e);
        e
    })?;
    
    axum::serve(listener, app.into_make_service()).await.map_err(|e| {
        track_exception(&e);
        e.into()
    })?;

    Ok(())
}
