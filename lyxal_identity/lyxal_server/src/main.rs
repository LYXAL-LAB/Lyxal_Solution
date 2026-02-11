use axum::{
    routing::{get, post},
    Extension, Router,
};
use lyxal_auth::{router as auth_router, AuthState};
use lyxal_core::{config::Config, database::Database, LyxalConfig};
use lyxal_iam::{
    handlers::{application_admin, tenant_admin, user_admin, IamState},
    services::{ApplicationService, TenantService, UserService},
};
use lyxal_mfa::{router as mfa_router, MfaState};
use lyxal_oauth::{router as oauth_router, OAuthConfig, OAuthState};
use lyxal_rbac::{
    repository::{PermissionRepository, RoleRepository},
    services::{PermissionService, RoleService},
};
use lyxal_session::{
    middleware::{optional_auth, require_auth, AuthContext},
    SessionConfig, SessionStore,
};
use std::sync::Arc;
use tokio::net::TcpListener;
use tower::ServiceBuilder;
use tower_sessions::{Expiration, SessionManagerLayer};
use utoipa::{
    openapi::security::{HttpAuthScheme, HttpBuilder, SecurityScheme},
    Modify, OpenApi,
};
use utoipa_swagger_ui::SwaggerUi;

#[tokio::main]
async fn main() -> lyxal_core::Result<()> {
    // 1. Load Configuration
    let config = Arc::new(LyxalConfig::from_env()?);

    // 2. Setup Tracing (Logging)
    tracing_subscriber::fmt()
        .with_env_filter(
            tracing_subscriber::EnvFilter::new(&config.server.log_level).add_directive(
                "sqlx=info"
                    .parse()
                    .expect("Failed to parse sqlx log level directive"),
            ),
        )
        .init();

    tracing::info!("Starting Lyxal Identity Server...");

    // 3. Initialize Database
    let db = Database::new(&config.database.url).await?;
    db.health_check().await?;
    db.migrate().await?; // Run pending migrations

    // 4. Initialize Core Services (shared across modules)
    let user_service = Arc::new(UserService::new(db.pool().clone()));
    let tenant_service = Arc::new(TenantService::new(db.pool().clone()));
    let application_service = Arc::new(ApplicationService::new(db.pool().clone()));

    let role_repository = Arc::new(RoleRepository::new(db.pool().clone()));
    let permission_repository = Arc::new(PermissionRepository::new(db.pool().clone()));
    let role_service = Arc::new(RoleService::new(role_repository.clone()));
    let permission_service = Arc::new(PermissionService::new(permission_repository.clone()));

    // 5. Initialize Session Store and Middleware
    let session_store = SessionStore::new(db.pool().clone()).await?.inner();
    let session_layer = SessionManagerLayer::new(session_store)
        .with_secure(config.server.host.contains("https")) // Use secure cookies in production
        .with_expiry(Expiration::OnInactivity(
            std::time::Duration::from_hours(config.security.token_expiration_hours as u64),
        ))
        .with_same_site(tower_sessions::cookie::SameSite::Lax);

    // 6. Initialize Module States and Routers
    // IAM Admin State
    let iam_state = Arc::new(IamState {
        user_service: user_service.clone(),
        tenant_service: tenant_service.clone(),
        application_service: application_service.clone(),
    });

    // Auth State
    let auth_service = lyxal_auth::AuthService::new(user_service.clone());
    let auth_state = AuthState {
        auth_service,
        user_service: user_service.clone(),
        config: config.clone(),
    };

    // MFA State
    let webauthn_service = if let Some(rp_id) = &config.security.webauthn_rp_id {
        Some(lyxal_mfa::WebAuthnService::new(rp_id, &config.server.host)?)
    } else {
        None
    };
    let mfa_service = lyxal_mfa::MfaService::new(user_service.clone(), webauthn_service);
    let mfa_state = MfaState {
        mfa_service,
        config: config.clone(),
    };

    // OAuth State
    let oauth_config = Arc::new(OAuthConfig {
        issuer: config.security.oauth_issuer.clone(),
        jwks_uri: format!("{}/oidc/jwks", config.security.oauth_issuer),
        authorization_endpoint: format!("{}/oidc/auth", config.security.oauth_issuer),
        token_endpoint: format!("{}/oidc/token", config.security.oauth_issuer),
        userinfo_endpoint: format!("{}/oidc/me", config.security.oauth_issuer),
    });
    let jwt_service = lyxal_oauth::JwtService::new(
        &config.security.secret_key,
        &oauth_config.issuer,
    );
    let oauth_state = OAuthState {
        jwt_service,
        config: config.clone(),
        oauth_config: oauth_config.clone(),
    };

    // 7. OpenAPI Documentation
    #[derive(OpenApi)]
    #[openapi(
        paths(
            lyxal_iam::handlers::user_admin::create_user,
            lyxal_iam::handlers::user_admin::get_user,
            lyxal_iam::handlers::user_admin::list_users,
            lyxal_iam::handlers::user_admin::update_user,
            lyxal_iam::handlers::user_admin::delete_user,
            lyxal_iam::handlers::tenant_admin::create_tenant,
            lyxal_iam::handlers::tenant_admin::get_tenant,
            lyxal_iam::handlers::tenant_admin::list_tenants,
            lyxal_iam::handlers::tenant_admin::update_tenant,
            lyxal_iam::handlers::tenant_admin::delete_tenant,
            lyxal_iam::handlers::application_admin::create_application,
            lyxal_iam::handlers::application_admin::get_application,
            lyxal_iam::handlers::application_admin::list_applications,
            lyxal_iam::handlers::application_admin::update_application,
            lyxal_iam::handlers::application_admin::rotate_secret,
            lyxal_iam::handlers::application_admin::delete_application,
            lyxal_auth::handlers::login,
            lyxal_auth::handlers::register,
            lyxal_auth::handlers::logout,
            lyxal_auth::handlers::me,
            lyxal_mfa::handlers::setup_totp,
            lyxal_mfa::handlers::verify_setup,
            lyxal_mfa::handlers::generate_backup_codes,
            lyxal_mfa::handlers::verify_mfa_login,
            lyxal_mfa::handlers::start_webauthn_reg,
            lyxal_mfa::handlers::finish_webauthn_reg,
            lyxal_mfa::handlers::start_webauthn_auth,
            lyxal_mfa::handlers::finish_webauthn_auth,
            lyxal_oauth::discovery::get_discovery,
            lyxal_oauth::endpoints::jwks,
            lyxal_oauth::endpoints::authorize,
            lyxal_oauth::endpoints::token,
            lyxal_oauth::endpoints::userinfo,
            lyxal_oauth::endpoints::introspect,
            lyxal_oauth::endpoints::revoke,
        ),
        components(
            schemas(
                lyxal_schema::User,
                lyxal_schema::Application,
                lyxal_schema::Tenant,
                lyxal_schema::Role,
                lyxal_schema::Permission,
                lyxal_schema::ApplicationType,
                lyxal_iam::handlers::user_admin::CreateUserRequest,
                lyxal_iam::handlers::user_admin::UpdateUserRequest,
                lyxal_iam::handlers::tenant_admin::CreateTenantRequest,
                lyxal_iam::handlers::tenant_admin::UpdateTenantRequest,
                lyxal_iam::handlers::application_admin::CreateApplicationRequest,
                lyxal_iam::handlers::application_admin::UpdateApplicationRequest,
                lyxal_auth::handlers::LoginRequest,
                lyxal_auth::handlers::RegisterRequest,
                lyxal_auth::handlers::AuthResponse,
                lyxal_mfa::handlers::TotpSetupResponse,
                lyxal_mfa::handlers::TotpVerifyRequest,
                lyxal_mfa::handlers::MfaLoginRequest,
                lyxal_mfa::MfaMethod,
                lyxal_oauth::endpoints::AuthorizeRequest,
                lyxal_oauth::endpoints::TokenRequest,
                lyxal_oauth::endpoints::TokenResponse,
                lyxal_oauth::discovery::DiscoveryResponse,
            )
        ),
        tags(
            (name = "Authentication", description = "User authentication and session management"),
            (name = "IAM - Users", description = "Identity & Access Management - User administration"),
            (name = "IAM - Tenants", description = "Identity & Access Management - Tenant (Organization) administration"),
            (name = "IAM - Applications", description = "Identity & Access Management - OAuth2 Application administration"),
            (name = "MFA", description = "Multi-Factor Authentication (TOTP, Passkeys, Backup Codes)"),
            (name = "OAuth2 / OIDC", description = "OpenID Connect and OAuth2 protocol endpoints"),
        ),
        modifiers(&SecurityAddon)
    )]
    struct ApiDoc;

    struct SecurityAddon;

    impl Modify for SecurityAddon {
        fn modify(&self, openapi: &mut OpenApi) {
            let components = openapi.components.as_mut().unwrap();
            components.add_security_scheme(
                "session_cookie",
                SecurityScheme::Http(
                    HttpBuilder::new()
                        .scheme(HttpAuthScheme::Bearer)
                        .bearer_format("JWT")
                        .description(Some("Session cookie for API authentication".to_string()))
                        .build(),
                ),
            );
            components.add_security_scheme(
                "bearer_auth",
                SecurityScheme::Http(
                    HttpBuilder::new()
                        .scheme(HttpAuthScheme::Bearer)
                        .bearer_format("JWT")
                        .description(Some("OAuth2 Access Token for API authentication".to_string()))
                        .build(),
                ),
            );
        }
    }

    // 8. Build Axum Router
    let app = Router::new()
        // Public Auth routes
        .nest("/api/auth", auth_router(auth_state))
        // OAuth / OIDC public routes
        .nest("/oidc", oauth_router(oauth_state))
        // MFA setup and verification routes (some public, some authenticated)
        .nest("/api/mfa", mfa_router(mfa_state))
        // Swagger UI
        .merge(SwaggerUi::new("/swagger-ui").url("/api-doc/openapi.json", ApiDoc::openapi()))
        // Administrative APIs (require authentication and potentially RBAC)
        .nest("/api/admin", {
            Router::new()
                .nest("/iam", lyxal_iam::handlers::router(iam_state.clone()))
                // Add more admin routes here (e.g., /admin/rbac, /admin/connectors)
                // .layer(axum::middleware::from_fn(lyxal_rbac::middleware::require_permission)) // Example RBAC protection
                .route_layer(axum::middleware::from_fn(require_auth)) // All admin routes require session
        })
        .layer(session_layer)
        .layer(axum::middleware::from_fn(optional_auth)) // Inject AuthContext into requests
        .layer(Extension(db))
        .layer(Extension(config.clone()));

    // 9. Start Server
    let addr = format!("{}:{}", config.server.host, config.server.port);
    tracing::info!("Lyxal Identity Server listening on {}", addr);
    let listener = TcpListener::bind(&addr).await?;
    axum::serve(listener, app.into_make_service()).await?;

    Ok(())
}
