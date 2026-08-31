//! Authentication engine and handlers for Lyxal OS (Booking Module).
//!
//! Provides password hashing (Argon2), session management, CSRF protection,
//! local user registration/login, OIDC integration, and Axum extractors (`AuthUser`).
//! All SurrealDB queries are executed strictly via SurrealQL functions and `store.call_fn(...)`.

use std::sync::Arc;

use anyhow::{Context, Result};
use argon2::password_hash::SaltString;
use argon2::{Argon2, PasswordHash, PasswordHasher, PasswordVerifier};
use axum::extract::{Form, FromRequestParts, State};
use axum::http::request::Parts;
use axum::http::{HeaderMap, StatusCode};
use axum::response::{Html, IntoResponse, Redirect, Response};
use axum_extra::extract::CookieJar;
use base64::Engine;
use chrono::{Duration, Utc};
use rand::rngs::OsRng;
use serde::{Deserialize, Serialize};

use crate::db::SurrealBookingStore;
use crate::models::{AuthConfig, Session, User};
use crate::web::{csrf_cookie_value, generate_csrf_token, verify_csrf_token, AppState};

// `__Host-` prefix forces browsers to enforce: Secure flag, Path=/, no Domain
// attribute. This prevents cookies from being overwritten by a sibling
// subdomain or downgraded over plaintext HTTP.
const SESSION_COOKIE: &str = "__Host-calrs_session";
const IMPERSONATE_COOKIE: &str = "__Host-calrs_impersonate";
const SESSION_DURATION_DAYS: i64 = 30;

// --- Password hashing ---

pub fn hash_password(password: &str) -> Result<String> {
    let salt = SaltString::generate(&mut OsRng);
    let argon2 = Argon2::default();
    let hash = argon2
        .hash_password(password.as_bytes(), &salt)
        .map_err(|e| anyhow::anyhow!("Failed to hash password: {}", e))?;
    Ok(hash.to_string())
}

pub fn verify_password(password: &str, hash: &str) -> bool {
    let parsed = match PasswordHash::new(hash) {
        Ok(h) => h,
        Err(_) => return false,
    };
    Argon2::default()
        .verify_password(password.as_bytes(), &parsed)
        .is_ok()
}

// Pre-computed Argon2id hash used as a timing dummy when no user is found or hash is corrupted,
// preventing user enumeration via response-time differences.
const DUMMY_HASH: &str = "$argon2id$v=19$m=19456,t=2,p=1$c29tZXNhbHQ$Rzg2ZnZ1WlZ0R1d2VXpWRldWdXpW";

/// Perform uniform password verification against stored hash or fallback dummy hash,
/// ensuring Argon2 is always executed even if account is missing or stored hash is corrupted.
pub fn verify_password_uniform(stored_hash: Option<&str>, password: &str) -> bool {
    let hash = stored_hash
        .filter(|value| PasswordHash::new(value).is_ok())
        .unwrap_or(DUMMY_HASH);
    verify_password(password, hash)
}

#[derive(Debug, serde::Serialize)]
pub struct GetAuthAccountParams<'a> {
    pub email: &'a str,
}

#[derive(Debug, Clone, serde::Deserialize)]
pub struct AuthLookupResult {
    pub account: Option<AuthAccountResult>,
}

#[derive(Debug, Clone, serde::Deserialize)]
pub struct AuthAccountResult {
    pub id: surrealdb::RecordId,
    pub name: String,
    pub email: String,
    pub username: String,
    pub password_hash: String,
    pub role: String,
    pub timezone: String,
    pub language: String,
    pub enabled: bool,
}

#[derive(Debug, Clone, Serialize)]
struct LookupAuthAccountParams {
    email: String,
}

fn invalid_credentials(language: &str) -> lyxal_surreal::LyxalSurrealError {
    lyxal_error::LyxalCallError::business_code(
        "BOOKING_AUTH_INVALID_CREDENTIALS",
        serde_json::json!({ "language": language }),
    )
    .into()
}

/// Authenticate a user while reducing account-enumeration timing differences.
pub async fn authenticate_user(
    store: &SurrealBookingStore,
    email: &str,
    password: &str,
    language: &str,
) -> Result<User, lyxal_surreal::LyxalSurrealError> {
    let params = LookupAuthAccountParams {
        email: email.to_string(),
    };
    let lookup: AuthLookupResult = store
        .call_fn("booking_lookup_auth_account", params)
        .await?;

    let password_valid = verify_password_uniform(
        lookup.account.as_ref().map(|a| a.password_hash.as_str()),
        password,
    );

    let Some(account) = lookup.account else {
        return Err(invalid_credentials(language));
    };

    if !password_valid || !account.enabled {
        return Err(invalid_credentials(language));
    }

    let now = surrealdb::sql::Datetime::from(chrono::Utc::now());
    Ok(User {
        id: account.id,
        email: account.email,
        name: account.name,
        timezone: account.timezone,
        role: account.role,
        auth_provider: "local".to_string(),
        oidc_subject: None,
        enabled: account.enabled,
        created_at: now.clone(),
        updated_at: now,
        username: Some(account.username),
        booking_email: None,
        title: None,
        bio: None,
        avatar_path: None,
        allow_dynamic_group: false,
        language: Some(account.language),
    })
}

// --- Params and Result structs ---

#[derive(Debug, serde::Serialize)]
pub struct CreateSessionParams<'a> {
    pub account_id: &'a str,
    pub language: &'a str,
}

#[derive(Debug, Clone, serde::Deserialize)]
pub struct CreatedSessionResult {
    pub id: String,
    pub account: surrealdb::RecordId,
    pub expires_at: chrono::DateTime<chrono::Utc>,
    pub created_at: chrono::DateTime<chrono::Utc>,
}

#[derive(Debug, serde::Serialize)]
pub struct ValidateSessionParams<'a> {
    pub token: &'a str,
    pub language: &'a str,
}

#[derive(Debug, Clone, serde::Deserialize)]
pub struct ValidatedSessionResult {
    pub user: User,
    pub session: SessionInfo,
}

#[derive(Debug, Clone, serde::Deserialize)]
pub struct SessionInfo {
    pub id: String,
    pub expires_at: chrono::DateTime<chrono::Utc>,
}

#[derive(Debug, serde::Serialize)]
pub struct DeleteSessionParams<'a> {
    pub token: &'a str,
    pub language: &'a str,
}

#[derive(Debug, Clone, serde::Deserialize)]
pub struct DeletedSessionResult {
    pub deleted: bool,
}

#[derive(Debug, serde::Serialize)]
pub struct CleanupSessionsParams;

#[derive(Debug, Clone, serde::Deserialize)]
pub struct CleanupSessionsResult {
    pub cleaned: bool,
}

#[derive(Debug, serde::Serialize)]
pub struct GetAccountByIdParams<'a> {
    pub user_id: &'a str,
    pub language: &'a str,
}

#[derive(Debug, Clone, serde::Deserialize)]
pub struct AccountResult {
    pub id: surrealdb::RecordId,
    pub name: String,
    pub email: String,
    pub username: String,
    pub role: String,
    pub timezone: String,
    pub language: String,
    pub enabled: bool,
}

#[derive(Debug, serde::Serialize)]
pub struct CreateLocalAccountParams<'a> {
    pub name: &'a str,
    pub email: &'a str,
    pub username: &'a str,
    pub password_hash: &'a str,
    pub force_admin: bool,
    pub language: &'a str,
}

#[derive(Debug, Clone, serde::Deserialize)]
pub struct CreatedAccountResult {
    pub id: surrealdb::RecordId,
    pub name: String,
    pub email: String,
    pub username: String,
    pub role: String,
    pub timezone: String,
    pub language: String,
    pub enabled: bool,
}

#[derive(Debug, serde::Serialize)]
pub struct DeleteUserParams<'a> {
    pub target_id: &'a str,
    pub requester_id: &'a str,
    pub language: &'a str,
}

#[derive(Debug, Clone, serde::Deserialize)]
pub struct DeletedUserResult {
    pub deleted: bool,
    pub user_id: surrealdb::RecordId,
    pub avatar_path: Option<String>,
}

#[derive(Debug, serde::Serialize)]
pub struct GetAuthConfigParams;

#[derive(Debug, serde::Serialize)]
pub struct FindOrCreateOidcParams<'a> {
    pub issuer: &'a str,
    pub sub: &'a str,
    pub email: &'a str,
    pub email_verified: bool,
    pub name: &'a str,
    pub title: Option<&'a str>,
    pub auto_register: bool,
    pub language: &'a str,
}

#[derive(Debug, Clone, serde::Deserialize)]
pub struct OidcAccountResult {
    pub id: surrealdb::RecordId,
    pub name: String,
    pub email: String,
    pub username: String,
    pub role: String,
    pub timezone: String,
    pub language: String,
    pub enabled: bool,
}

#[derive(Debug, serde::Serialize)]
pub struct SyncOidcGroupsParams<'a> {
    pub account_id: &'a str,
    pub provider: &'a str,
    pub groups: &'a [String],
    pub language: &'a str,
}

#[derive(Debug, Clone, serde::Deserialize)]
pub struct SyncOidcGroupsResult {
    pub groups_received: usize,
    pub groups_created: usize,
    pub memberships_added: usize,
    pub memberships_removed: usize,
    pub team_memberships_added: usize,
    pub team_memberships_removed: usize,
}

// --- Session & Account Service Wrappers ---

// --- Session & Account Service Wrappers ---

#[derive(Debug, Clone, Serialize)]
struct V1GetCurrentSessionParams {
    token_hash: String,
}

#[derive(Debug, Clone, Serialize)]
struct V1GetAuthAccountParams {
    username: String,
}

#[derive(Debug, Clone, Serialize)]
struct V1CreateSessionParams {
    account_id: String,
    token_hash: String,
    expires_at: String,
}

#[derive(Debug, Clone, Serialize)]
struct V1RevokeSessionParams {
    token_hash: String,
}

#[derive(Debug, Clone, Serialize)]
struct V1RevokeAllSessionsParams {
    user_id: String,
}

pub async fn get_current_session_by_hash(
    store: &SurrealBookingStore,
    token_hash: &str,
) -> Result<crate::contracts::auth::CurrentSessionResponse, lyxal_surreal::LyxalSurrealError> {
    let params = V1GetCurrentSessionParams {
        token_hash: token_hash.to_string(),
    };
    store.call_fn("booking_get_current_session", params).await
}

pub async fn get_auth_account_by_username(
    store: &SurrealBookingStore,
    username: &str,
) -> Result<Option<crate::contracts::auth::AuthAccountRecord>, lyxal_surreal::LyxalSurrealError> {
    let params = V1GetAuthAccountParams {
        username: username.to_string(),
    };
    store.call_fn("booking_get_auth_account", params).await
}

pub async fn create_auth_session(
    store: &SurrealBookingStore,
    account_id: &str,
    token_hash: &str,
    expires_at: &str,
) -> Result<crate::contracts::auth::AuthSessionResponse, lyxal_surreal::LyxalSurrealError> {
    let params = V1CreateSessionParams {
        account_id: account_id.to_string(),
        token_hash: token_hash.to_string(),
        expires_at: expires_at.to_string(),
    };
    store.call_fn("booking_create_session", params).await
}

pub async fn revoke_auth_session(
    store: &SurrealBookingStore,
    token_hash: &str,
) -> Result<crate::contracts::auth::LogoutResponse, lyxal_surreal::LyxalSurrealError> {
    let params = V1RevokeSessionParams {
        token_hash: token_hash.to_string(),
    };
    store.call_fn("booking_revoke_session", params).await
}

pub async fn revoke_all_auth_sessions(
    store: &SurrealBookingStore,
    user_id: &str,
) -> Result<crate::contracts::auth::LogoutResponse, lyxal_surreal::LyxalSurrealError> {
    let params = V1RevokeAllSessionsParams {
        user_id: user_id.to_string(),
    };
    store.call_fn("booking_revoke_all_sessions", params).await
}

#[derive(Debug, Clone, Serialize)]
struct GetAuthAccountByEmailParams {
    email: String,
}

#[derive(Debug, Clone, Serialize)]
struct CreateSessionRecordParams {
    account_id: String,
    language: String,
}

#[derive(Debug, Clone, Serialize)]
struct ValidateSessionTokenParams {
    token: String,
    language: String,
}

#[derive(Debug, Clone, Serialize)]
struct GetAccountByIdRecordParams {
    user_id: String,
    language: String,
}

#[derive(Debug, Clone, Serialize)]
struct DeleteSessionTokenParams {
    token: String,
    language: String,
}

#[derive(Debug, Clone, Serialize)]
struct CleanupSessionsRecordParams {
    language: String,
}

pub async fn create_session(
    store: &SurrealBookingStore,
    account_id: &str,
    language: &str,
) -> Result<CreatedSessionResult, lyxal_surreal::LyxalSurrealError> {
    let params = CreateSessionRecordParams {
        account_id: account_id.to_string(),
        language: language.to_string(),
    };
    store.call_fn("booking_create_session", params).await
}

pub async fn validate_session(
    store: &SurrealBookingStore,
    token: &str,
    language: &str,
) -> Result<ValidatedSessionResult, lyxal_surreal::LyxalSurrealError> {
    let params = ValidateSessionTokenParams {
        token: token.to_string(),
        language: language.to_string(),
    };
    store.call_fn("booking_validate_session", params).await
}

pub async fn get_user_from_session(
    store: &SurrealBookingStore,
    token: &str,
) -> Option<User> {
    match validate_session(store, token, "fr").await {
        Ok(result) => Some(result.user),
        Err(err) if err.is_business_code("BOOKING_SESSION_NOT_FOUND") => None,
        Err(error) => {
            tracing::error!(%error, "session validation database error");
            None
        }
    }
}

pub async fn get_user_by_id(
    store: &SurrealBookingStore,
    user_id: &str,
    language: &str,
) -> Result<User, lyxal_surreal::LyxalSurrealError> {
    let params = GetAccountByIdRecordParams {
        user_id: user_id.to_string(),
        language: language.to_string(),
    };
    let acc: AccountResult = store
        .call_fn("booking_get_account_by_id", params)
        .await?;

    let now = surrealdb::sql::Datetime::from(chrono::Utc::now());
    Ok(User {
        id: acc.id,
        email: acc.email,
        name: acc.name,
        timezone: acc.timezone,
        role: acc.role,
        auth_provider: "local".to_string(),
        oidc_subject: None,
        enabled: acc.enabled,
        created_at: now.clone(),
        updated_at: now,
        username: Some(acc.username),
        booking_email: None,
        title: None,
        bio: None,
        avatar_path: None,
        allow_dynamic_group: false,
        language: Some(acc.language),
    })
}

pub async fn delete_session(
    store: &SurrealBookingStore,
    token: &str,
    language: &str,
) -> Result<DeletedSessionResult, lyxal_surreal::LyxalSurrealError> {
    let params = DeleteSessionTokenParams {
        token: token.to_string(),
        language: language.to_string(),
    };
    store.call_fn("booking_delete_session", params).await
}

pub async fn cleanup_expired_sessions(
    store: &SurrealBookingStore,
    language: &str,
) -> Result<usize, lyxal_surreal::LyxalSurrealError> {
    let params = CleanupSessionsRecordParams {
        language: language.to_string(),
    };
    let res: CleanupSessionsResult = store
        .call_fn("booking_cleanup_expired_sessions", params)
        .await?;
    Ok(if res.cleaned { 1 } else { 0 })
}



// --- User deletion ---

/// Reasons `delete_user` can refuse or fail. The web layer and CLI both
/// match on this to render a user-facing message.
#[derive(Debug)]
pub enum DeleteUserError {
    NotFound,
    LastAdmin,
    SelfDelete,
    HasFutureBookings { count: i64 },
    Db(String),
}

impl std::fmt::Display for DeleteUserError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Self::NotFound => write!(f, "user not found"),
            Self::LastAdmin => write!(
                f,
                "cannot delete the last admin (promote another user first)"
            ),
            Self::SelfDelete => {
                write!(f, "admins cannot delete themselves; ask another admin")
            }
            Self::HasFutureBookings { count } => write!(
                f,
                "user has {} upcoming booking(s) (as host or assigned member); cancel them before deletion",
                count
            ),
            Self::Db(e) => write!(f, "database error: {}", e),
        }
    }
}

impl std::error::Error for DeleteUserError {}

#[derive(Debug, Clone, Serialize)]
struct DeleteUserAccountAuthParams {
    target_id: String,
    requester_id: String,
    language: String,
}

#[derive(Debug, Clone, Default, Serialize)]
struct EmptyAuthParams {}

#[derive(Debug, Clone, Serialize)]
struct CreateLocalAccountAuthParams {
    name: String,
    email: String,
    username: String,
    password_hash: String,
    force_admin: bool,
    language: String,
}

#[derive(Debug, Clone, Serialize)]
struct FindOrCreateOidcAccountAuthParams {
    issuer: String,
    sub: String,
    email: String,
    email_verified: bool,
    name: String,
    title: Option<String>,
    auto_register: bool,
    language: String,
}

#[derive(Debug, Clone, Serialize)]
struct SyncOidcGroupsAuthParams {
    account_id: String,
    provider: String,
    groups: Vec<String>,
    language: String,
}

/// Delete a user and all data uniquely owned by them via fn::booking_delete_user.
pub async fn delete_user(
    store: &SurrealBookingStore,
    target_id: &str,
    requester_id: &str,
    language: &str,
) -> Result<(), DeleteUserError> {
    let params = DeleteUserAccountAuthParams {
        target_id: target_id.to_string(),
        requester_id: requester_id.to_string(),
        language: language.to_string(),
    };
    let res: Result<DeletedUserResult, lyxal_surreal::LyxalSurrealError> = store
        .call_fn("booking_delete_user_account", params)
        .await;

    match res {
        Ok(result) if result.deleted => {
            if let Some(ref path) = result.avatar_path {
                let _ = tokio::fs::remove_file(path).await;
            }
            Ok(())
        }
        Ok(_) => Err(DeleteUserError::NotFound),
        Err(err) if err.is_business_code("BOOKING_ACCOUNT_NOT_FOUND") => {
            Err(DeleteUserError::NotFound)
        }
        Err(err) if err.is_business_code("BOOKING_AUTH_CANNOT_DELETE_SELF") => {
            Err(DeleteUserError::SelfDelete)
        }
        Err(err) if err.is_business_code("BOOKING_AUTH_LAST_ADMIN_DELETE_PROHIBITED") => {
            Err(DeleteUserError::LastAdmin)
        }
        Err(err) if err.is_business_code("BOOKING_AUTH_HAS_FUTURE_BOOKINGS") => {
            let count = match &err {
                lyxal_surreal::LyxalSurrealError::Call(lyxal_error::LyxalCallError::Business(b)) => {
                    b.details.get("count").and_then(|v| v.as_i64()).unwrap_or(1)
                }
                lyxal_surreal::LyxalSurrealError::Call(lyxal_error::LyxalCallError::BusinessCode { details, .. }) => {
                    details.get("count").and_then(|v| v.as_i64()).unwrap_or(1)
                }
                _ => 1,
            };
            Err(DeleteUserError::HasFutureBookings { count })
        }
        Err(error) => Err(DeleteUserError::Db(error.to_string())),
    }
}

pub async fn get_auth_config(
    store: &SurrealBookingStore,
    _language: &str,
) -> Result<AuthConfig, lyxal_surreal::LyxalSurrealError> {
    store
        .call_fn("booking_get_auth_config", EmptyAuthParams::default())
        .await
}

pub fn is_email_allowed(email: &str, allowed_domains: &Option<String>) -> bool {
    let domains = match allowed_domains {
        Some(d) if !d.trim().is_empty() => d,
        _ => return true,
    };

    let email_domain = match email.rsplit_once('@') {
        Some((_, domain)) => domain.to_lowercase(),
        None => return false,
    };

    domains
        .split(',')
        .map(|d| d.trim().to_lowercase())
        .any(|d| d == email_domain)
}

use lyxal_surreal::LyxalSurrealCall;

#[derive(Debug, Clone, serde::Serialize)]
pub struct GenerateUsernameParams {
    pub email: String,
    pub language: String,
}

#[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
pub struct GeneratedUsername {
    pub username: String,
}

/// Generate a unique username from an email address using SurrealDB fn::booking_generate_username.
pub async fn generate_username(
    store: &SurrealBookingStore,
    email: &str,
    language: &str,
) -> Result<GeneratedUsername, lyxal_surreal::LyxalSurrealError> {
    let params = GenerateUsernameParams {
        email: email.to_string(),
        language: language.to_string(),
    };
    store.call_fn("booking_generate_username", params).await
}

/// Insert a local-auth user via fn::booking_create_local_user.
pub(crate) async fn create_local_user(
    store: &SurrealBookingStore,
    email: &str,
    name: &str,
    password_hash: &str,
    username: &str,
    force_admin: bool,
    language: &str,
) -> Result<User, lyxal_surreal::LyxalSurrealError> {
    let params = CreateLocalAccountAuthParams {
        name: name.to_string(),
        email: email.to_string(),
        username: username.to_string(),
        password_hash: password_hash.to_string(),
        force_admin,
        language: language.to_string(),
    };
    let acc: CreatedAccountResult = store
        .call_fn("booking_create_local_account", params)
        .await?;

    let now = surrealdb::sql::Datetime::from(chrono::Utc::now());
    Ok(User {
        id: acc.id,
        email: acc.email,
        name: acc.name,
        timezone: acc.timezone,
        role: acc.role,
        auth_provider: "local".to_string(),
        oidc_subject: None,
        enabled: acc.enabled,
        created_at: now.clone(),
        updated_at: now,
        username: Some(acc.username),
        booking_email: None,
        title: None,
        bio: None,
        avatar_path: None,
        allow_dynamic_group: false,
        language: Some(acc.language),
    })
}

pub async fn find_or_create_oidc_user(
    store: &SurrealBookingStore,
    issuer: &str,
    sub: &str,
    email: &str,
    email_verified: bool,
    name: &str,
    title: Option<&str>,
    auto_register: bool,
    language: &str,
) -> Result<User, lyxal_surreal::LyxalSurrealError> {
    let params = FindOrCreateOidcAccountAuthParams {
        issuer: issuer.to_string(),
        sub: sub.to_string(),
        email: email.to_string(),
        email_verified,
        name: name.to_string(),
        title: title.map(str::to_string),
        auto_register,
        language: language.to_string(),
    };
    let acc: OidcAccountResult = store
        .call_fn("booking_find_or_create_oidc_account", params)
        .await?;

    let now = surrealdb::sql::Datetime::from(chrono::Utc::now());
    Ok(User {
        id: acc.id,
        email: acc.email,
        name: acc.name,
        timezone: acc.timezone,
        role: acc.role,
        auth_provider: "oidc".to_string(),
        oidc_subject: Some(sub.to_string()),
        enabled: acc.enabled,
        created_at: now.clone(),
        updated_at: now,
        username: Some(acc.username),
        booking_email: None,
        title: title.map(str::to_string),
        bio: None,
        avatar_path: None,
        allow_dynamic_group: false,
        language: Some(acc.language),
    })
}

pub async fn sync_user_groups(
    store: &SurrealBookingStore,
    account_id: &str,
    provider: &str,
    groups: &[String],
    language: &str,
) -> Result<SyncOidcGroupsResult, lyxal_surreal::LyxalSurrealError> {
    let params = SyncOidcGroupsAuthParams {
        account_id: account_id.to_string(),
        provider: provider.to_string(),
        groups: groups.to_vec(),
        language: language.to_string(),
    };
    store.call_fn("booking_sync_oidc_groups", params).await
}

// --- Axum extractors ---

#[derive(Clone)]
pub struct ImpersonationInfo {
    pub admin_name: String,
    pub target_name: String,
}

async fn resolve_session_user(
    store: &SurrealBookingStore,
    jar: &CookieJar,
) -> Option<(User, Option<ImpersonationInfo>)> {
    let token = jar.get(SESSION_COOKIE).map(|c| c.value().to_string())?;
    let real_user = get_user_from_session(store, &token).await?;

    if real_user.role == "admin" {
        if let Some(target_id) = jar.get(IMPERSONATE_COOKIE).map(|c| c.value().to_string()) {
            if target_id != real_user.id.to_string() {
                if let Ok(target_user) = get_user_by_id(store, &target_id, "fr").await {
                    let info = ImpersonationInfo {
                        admin_name: real_user.name.clone(),
                        target_name: target_user.name.clone(),
                    };
                    return Some((target_user, Some(info)));
                }
            }
        }
    }

    Some((real_user, None))
}

pub struct AuthUser {
    pub user: User,
    pub impersonation: Option<ImpersonationInfo>,
}

impl FromRequestParts<Arc<AppState>> for AuthUser {
    type Rejection = Response;

    async fn from_request_parts(
        parts: &mut Parts,
        state: &Arc<AppState>,
    ) -> Result<Self, Self::Rejection> {
        let jar = CookieJar::from_headers(&parts.headers);
        match resolve_session_user(&state.store, &jar).await {
            Some((user, impersonation)) => Ok(AuthUser {
                user,
                impersonation,
            }),
            None => Err(Redirect::to("/auth/login").into_response()),
        }
    }
}

pub struct OptionalAuthUser {
    pub user: Option<User>,
    pub impersonation: Option<ImpersonationInfo>,
}

impl FromRequestParts<Arc<AppState>> for OptionalAuthUser {
    type Rejection = std::convert::Infallible;

    async fn from_request_parts(
        parts: &mut Parts,
        state: &Arc<AppState>,
    ) -> Result<Self, Self::Rejection> {
        let jar = CookieJar::from_headers(&parts.headers);
        let (user, impersonation) = match resolve_session_user(&state.store, &jar).await {
            Some((u, info)) => (Some(u), info),
            None => (None, None),
        };
        Ok(OptionalAuthUser {
            user,
            impersonation,
        })
    }
}

pub struct AdminUser(pub User);

impl FromRequestParts<Arc<AppState>> for AdminUser {
    type Rejection = Response;

    async fn from_request_parts(
        parts: &mut Parts,
        state: &Arc<AppState>,
    ) -> Result<Self, Self::Rejection> {
        let jar = CookieJar::from_headers(&parts.headers);
        let token = jar.get(SESSION_COOKIE).map(|c| c.value().to_string());

        let real_user = match token {
            Some(ref t) => get_user_from_session(&state.store, t).await,
            None => None,
        };

        match real_user {
            Some(user) if user.role == "admin" => Ok(AdminUser(user)),
            Some(_) => Err((StatusCode::FORBIDDEN, "Admin access required").into_response()),
            None => Err(Redirect::to("/auth/login").into_response()),
        }
    }
}

// --- Axum router & handlers ---

use axum::routing::{get, post};
use axum::Router;

pub fn auth_router() -> Router<AppState> {
    Router::new()
        .route("/auth/login", get(login_page).post(login_handler))
        .route("/auth/register", get(register_page).post(register_handler))
        .route("/auth/logout", post(logout_handler))
        .route("/auth/oidc/login", get(oidc_login))
        .route("/auth/oidc/callback", get(oidc_callback))
}

#[derive(Deserialize)]
struct CsrfForm {
    _csrf: Option<String>,
}

#[derive(Deserialize)]
pub struct LoginForm {
    pub _csrf: Option<String>,
    pub email: String,
    pub password: String,
}

#[derive(Deserialize)]
pub struct RegisterForm {
    pub _csrf: Option<String>,
    pub name: String,
    pub email: String,
    pub password: String,
}

async fn login_page(State(state): State<AppState>, jar: CookieJar) -> Response {
    if let Some(token) = jar.get(SESSION_COOKIE).map(|c| c.value().to_string()) {
        if get_user_from_session(&state.store, &token).await.is_some() {
            return Redirect::to("/dashboard").into_response();
        }
    }

    let auth_config = get_auth_config(&state.store, "fr").await.ok();
    let oidc_enabled = auth_config
        .as_ref()
        .map(|c| c.oidc_enabled)
        .unwrap_or(false);
    let registration_enabled = auth_config
        .as_ref()
        .map(|c| c.registration_enabled)
        .unwrap_or(true);

    let csrf_token = generate_csrf_token();
    let tmpl = match state.templates.get_template("auth/login.html") {
        Ok(t) => t,
        Err(e) => return crate::web::internal_error_response("template render", &e),
    };

    let body = Html(
        tmpl.render(minijinja::context! { error => "", oidc_enabled => oidc_enabled, registration_enabled => registration_enabled, csrf_token => csrf_token })
            .unwrap_or_default(),
    );
    ([("Set-Cookie", csrf_cookie_value(&csrf_token))], body).into_response()
}

async fn login_handler(
    State(state): State<AppState>,
    headers: HeaderMap,
    jar: CookieJar,
    Form(form): Form<LoginForm>,
) -> Response {
    if let Err(resp) = verify_csrf_token(&headers, &form._csrf) {
        return resp;
    }
    let client_ip = crate::web::client_ip_for_rate_limit(&headers);

    if state.login_limiter.check_limited(&client_ip).await {
        tracing::warn!(ip = %client_ip, "rate limited");
        return render_login_error(&state, "Too many login attempts. Please try again later.");
    }

    let user = match authenticate_user(&state.store, &form.email, &form.password, "fr").await {
        Ok(u) => u,
        Err(err) if err.is_business_code("BOOKING_AUTH_INVALID_CREDENTIALS") => {
            tracing::warn!(email = %form.email, ip = %client_ip, "login failed: invalid credentials");
            return render_login_error(&state, "Invalid email or password");
        }
        Err(_) => return render_login_error(&state, "Internal error"),
    };

    let session = match create_session(&state.store, &user.id.to_string(), "fr").await {
        Ok(s) => s,
        Err(_) => return render_login_error(&state, "Internal error"),
    };

    let cookie = format!(
        "{}={}; HttpOnly; Secure; SameSite=Lax; Path=/; Max-Age={}",
        SESSION_COOKIE,
        session.id,
        SESSION_DURATION_DAYS * 86400
    );

    tracing::info!(email = %form.email, ip = %client_ip, "user login");
    (jar, [("Set-Cookie", cookie)], Redirect::to("/dashboard")).into_response()
}

async fn register_page(State(state): State<AppState>, jar: CookieJar) -> Response {
    if let Some(token) = jar.get(SESSION_COOKIE).map(|c| c.value().to_string()) {
        if get_user_from_session(&state.store, &token).await.is_some() {
            return Redirect::to("/dashboard").into_response();
        }
    }

    let auth_config = match get_auth_config(&state.store, "fr").await {
        Ok(c) => c,
        Err(_) => return Html("Internal error".to_string()).into_response(),
    };
    if !auth_config.registration_enabled {
        return Html("Registration is disabled.".to_string()).into_response();
    }

    let csrf_token = generate_csrf_token();
    let tmpl = match state.templates.get_template("auth/register.html") {
        Ok(t) => t,
        Err(e) => return crate::web::internal_error_response("template render", &e),
    };

    let body = Html(
        tmpl.render(minijinja::context! {
            error => "",
            allowed_domains => auth_config.allowed_email_domains,
            csrf_token => csrf_token,
        })
        .unwrap_or_default(),
    );
    ([("Set-Cookie", csrf_cookie_value(&csrf_token))], body).into_response()
}

async fn register_handler(
    State(state): State<AppState>,
    headers: HeaderMap,
    jar: CookieJar,
    Form(form): Form<RegisterForm>,
) -> Response {
    if let Err(resp) = verify_csrf_token(&headers, &form._csrf) {
        return resp;
    }

    let auth_config = match get_auth_config(&state.store, "fr").await {
        Ok(c) => c,
        Err(_) => return Html("Internal error".to_string()).into_response(),
    };

    if !auth_config.registration_enabled {
        return Html("Registration is disabled.".to_string()).into_response();
    }

    let name = form.name.trim();
    if name.is_empty() || name.len() > 255 {
        return render_register_error(
            &state,
            "Name must be between 1 and 255 characters",
            &auth_config,
        );
    }

    let email = form.email.trim();
    if email.is_empty() || email.len() > 255 {
        return render_register_error(
            &state,
            "Email must be between 1 and 255 characters",
            &auth_config,
        );
    }

    if !email.contains('@') || email.rsplit('@').next().is_none_or(|d| !d.contains('.')) {
        return render_register_error(&state, "Please enter a valid email address", &auth_config);
    }

    if !is_email_allowed(&form.email, &auth_config.allowed_email_domains) {
        return render_register_error(&state, "Email domain not allowed", &auth_config);
    }

    if form.password.len() < 12 {
        return render_register_error(
            &state,
            "Password must be at least 12 characters",
            &auth_config,
        );
    }

    let password_hash = match hash_password(&form.password) {
        Ok(h) => h,
        Err(_) => return render_register_error(&state, "Internal error", &auth_config),
    };

    let username = match generate_username(&state.store, &form.email, "fr").await {
        Ok(u) => u,
        Err(_) => return render_register_error(&state, "Internal error", &auth_config),
    };

    let user = match create_local_user(
        &state.store,
        &form.email,
        &form.name,
        &password_hash,
        &username.username,
        false,
        "fr",
    )
    .await
    {
        Ok(u) => u,
        Err(_) => return render_register_error(&state, "Failed to create account", &auth_config),
    };

    let session = match create_session(&state.store, &user.id.to_string(), "fr").await {
        Ok(s) => s,
        Err(_) => return render_register_error(&state, "Internal error", &auth_config),
    };

    let cookie = format!(
        "{}={}; HttpOnly; Secure; SameSite=Lax; Path=/; Max-Age={}",
        SESSION_COOKIE,
        session.id,
        SESSION_DURATION_DAYS * 86400
    );

    tracing::info!(email = %form.email, "user registered");
    (jar, [("Set-Cookie", cookie)], Redirect::to("/dashboard")).into_response()
}

#[axum::debug_handler]
async fn logout_handler(
    State(state): State<AppState>,
    headers: HeaderMap,
    jar: CookieJar,
    Form(csrf): Form<CsrfForm>,
) -> Response {
    if let Err(resp) = verify_csrf_token(&headers, &csrf._csrf) {
        return resp;
    }
    if let Some(cookie) = jar.get(SESSION_COOKIE) {
        let _ = delete_session(&state.store, cookie.value(), "fr").await;
    }

    tracing::info!("user logout");
    let clear_cookie = format!(
        "{}=; HttpOnly; Secure; SameSite=Lax; Path=/; Max-Age=0",
        SESSION_COOKIE
    );
    ([("Set-Cookie", clear_cookie)], Redirect::to("/auth/login")).into_response()
}

// --- OIDC Handlers & Logic ---

const OIDC_STATE_COOKIE: &str = "calrs_oidc_state";
const OIDC_NONCE_COOKIE: &str = "calrs_oidc_nonce";
const OIDC_PKCE_COOKIE: &str = "calrs_oidc_pkce";

use axum::extract::Query;
use openidconnect::core::{CoreClient, CoreProviderMetadata, CoreResponseType};
use openidconnect::{
    AuthenticationFlow, AuthorizationCode, ClientId, ClientSecret, CsrfToken, EndpointMaybeSet,
    EndpointNotSet, EndpointSet, IssuerUrl, Nonce, PkceCodeChallenge, PkceCodeVerifier,
    RedirectUrl, Scope, TokenResponse,
};

fn build_http_client() -> Result<openidconnect::reqwest::Client> {
    let client = openidconnect::reqwest::ClientBuilder::new()
        .redirect(openidconnect::reqwest::redirect::Policy::none())
        .build()
        .map_err(|e| anyhow::anyhow!("Failed to build HTTP client: {}", e))?;
    Ok(client)
}

async fn build_oidc_client_with_redirect(
    auth_config: &AuthConfig,
    secret_key: &[u8; 32],
) -> Result<
    CoreClient<
        EndpointSet,
        EndpointNotSet,
        EndpointNotSet,
        EndpointNotSet,
        EndpointMaybeSet,
        EndpointMaybeSet,
    >,
> {
    let issuer_url = IssuerUrl::new(
        auth_config
            .oidc_issuer_url
            .as_ref()
            .ok_or_else(|| anyhow::anyhow!("OIDC issuer URL not configured"))?
            .clone(),
    )
    .map_err(|e| anyhow::anyhow!("Invalid issuer URL: {}", e))?;

    let client_id = ClientId::new(
        auth_config
            .oidc_client_id
            .as_ref()
            .ok_or_else(|| anyhow::anyhow!("OIDC client ID not configured"))?
            .clone(),
    );

    let client_secret: Option<ClientSecret> = None;

    let http_client = build_http_client()?;
    let provider_metadata = CoreProviderMetadata::discover_async(issuer_url, &http_client)
        .await
        .map_err(|e| anyhow::anyhow!("OIDC discovery failed: {}", e))?;

    let redirect_url = RedirectUrl::new(format!(
        "{}/auth/oidc/callback",
        crate::settings::base_url().unwrap_or_else(|| "http://localhost:3000".to_string())
    ))
    .map_err(|e| anyhow::anyhow!("Invalid redirect URL: {}", e))?;

    let client = CoreClient::from_provider_metadata(provider_metadata, client_id, client_secret)
        .set_redirect_uri(redirect_url);

    Ok(client)
}

async fn oidc_login(State(state): State<AppState>) -> Response {
    let auth_config = match get_auth_config(&state.store, "fr").await {
        Ok(c) if c.oidc_enabled => c,
        _ => return Html("OIDC is not enabled.".to_string()).into_response(),
    };

    let client = match build_oidc_client_with_redirect(&auth_config, &state.secret_key).await {
        Ok(c) => c,
        Err(e) => return crate::web::oidc_error_response("oidc client build (login)", &e),
    };

    let (pkce_challenge, pkce_verifier) = PkceCodeChallenge::new_random_sha256();
    let (auth_url, csrf_token, nonce) = client
        .authorize_url(
            AuthenticationFlow::<CoreResponseType>::AuthorizationCode,
            CsrfToken::new_random,
            Nonce::new_random,
        )
        .add_scope(Scope::new("openid".to_string()))
        .add_scope(Scope::new("email".to_string()))
        .add_scope(Scope::new("profile".to_string()))
        .set_pkce_challenge(pkce_challenge)
        .url();

    let cookie_opts = "; HttpOnly; Secure; SameSite=Lax; Path=/; Max-Age=600";
    let state_cookie = format!("{}={}{}", OIDC_STATE_COOKIE, csrf_token.secret(), cookie_opts);
    let nonce_cookie = format!("{}={}{}", OIDC_NONCE_COOKIE, nonce.secret(), cookie_opts);
    let pkce_cookie = format!("{}={}{}", OIDC_PKCE_COOKIE, pkce_verifier.secret(), cookie_opts);

    let mut headers = axum::http::HeaderMap::new();
    headers.append(axum::http::header::SET_COOKIE, state_cookie.parse().unwrap());
    headers.append(axum::http::header::SET_COOKIE, nonce_cookie.parse().unwrap());
    headers.append(axum::http::header::SET_COOKIE, pkce_cookie.parse().unwrap());

    (headers, Redirect::to(auth_url.as_str())).into_response()
}

#[derive(Deserialize)]
struct OidcCallbackQuery {
    code: String,
    state: String,
}

#[axum::debug_handler]
async fn oidc_callback(
    State(state): State<AppState>,
    jar: CookieJar,
    Query(query): Query<OidcCallbackQuery>,
) -> Response {
    let auth_config = match get_auth_config(&state.store, "fr").await {
        Ok(c) if c.oidc_enabled => c,
        _ => return Html("OIDC is not enabled.".to_string()).into_response(),
    };

    let stored_state = match jar.get(OIDC_STATE_COOKIE) {
        Some(c) => c.value().to_string(),
        None => return Html("Missing OIDC state. Please try again.".to_string()).into_response(),
    };

    if query.state != stored_state {
        tracing::warn!("OIDC callback failed: state mismatch");
        return Html("Invalid OIDC state. Possible CSRF attack.".to_string()).into_response();
    }

    let stored_nonce = match jar.get(OIDC_NONCE_COOKIE) {
        Some(c) => c.value().to_string(),
        None => return Html("Missing OIDC nonce. Please try again.".to_string()).into_response(),
    };

    let pkce_verifier_secret = match jar.get(OIDC_PKCE_COOKIE) {
        Some(c) => c.value().to_string(),
        None => return Html("Missing PKCE verifier. Please try again.".to_string()).into_response(),
    };

    let client = match build_oidc_client_with_redirect(&auth_config, &state.secret_key).await {
        Ok(c) => c,
        Err(e) => return crate::web::oidc_error_response("oidc client build (callback)", &e),
    };

    let http_client = match build_http_client() {
        Ok(c) => c,
        Err(e) => return crate::web::oidc_error_response("oidc http client", &e),
    };

    let token_request = match client.exchange_code(AuthorizationCode::new(query.code)) {
        Ok(r) => r,
        Err(e) => return crate::web::oidc_error_response("oidc exchange_code", &e),
    };

    let token_response = match token_request
        .set_pkce_verifier(PkceCodeVerifier::new(pkce_verifier_secret))
        .request_async(&http_client)
        .await
    {
        Ok(t) => t,
        Err(e) => return crate::web::oidc_error_response("oidc token exchange", &e),
    };

    let id_token = match token_response.id_token() {
        Some(t) => t,
        None => return Html("No ID token in response.".to_string()).into_response(),
    };

    let verifier = client.id_token_verifier();
    let claims = match id_token.claims(&verifier, &Nonce::new(stored_nonce)) {
        Ok(c) => c,
        Err(e) => return crate::web::oidc_error_response("oidc id_token verify", &e),
    };

    let subject = claims.subject().to_string();
    let email = claims
        .email()
        .map(|e: &openidconnect::EndUserEmail| e.to_string())
        .unwrap_or_default();
    let email_verified = claims.email_verified().unwrap_or(false);
    let name = claims
        .name()
        .and_then(|n: &openidconnect::LocalizedClaim<openidconnect::EndUserName>| {
            n.get(None).map(|v: &openidconnect::EndUserName| v.to_string())
        })
        .unwrap_or_else(|| email.split('@').next().unwrap_or("User").to_string());

    if email.is_empty() {
        tracing::warn!("OIDC callback failed: no email in token");
        return Html("OIDC provider did not return an email address.".to_string()).into_response();
    }

    if !is_email_allowed(&email, &auth_config.allowed_email_domains) {
        tracing::warn!(email = %email, "OIDC callback failed: email domain not allowed");
        return Html("Your email domain is not allowed.".to_string()).into_response();
    }

    let parsed_claims = extract_claims_from_id_token(id_token.to_string().as_str());
    let issuer = auth_config
        .oidc_issuer_url
        .as_deref()
        .unwrap_or("https://oidc.provider");
    let auto_register = auth_config.registration_enabled && auth_config.oidc_auto_register;

    let user = match find_or_create_oidc_user(
        &state.store,
        issuer,
        &subject,
        &email,
        email_verified,
        &name,
        parsed_claims.title.as_deref(),
        auto_register,
        "fr",
    )
    .await
    {
        Ok(u) => u,
        Err(e) => {
            tracing::warn!(email = %email, error = %e, "OIDC callback failed: account error");
            return crate::web::oidc_error_response("oidc account link/create", &e);
        }
    };

    if let Some(groups) = &parsed_claims.groups {
        if let Err(e) = sync_user_groups(&state.store, &user.id.to_string(), "oidc", groups, "fr").await {
            tracing::warn!(error = %e, "failed to sync OIDC groups");
        }
    }

    let session = match create_session(&state.store, &user.id.to_string(), "fr").await {
        Ok(s) => s,
        Err(_) => return Html("Failed to create session.".to_string()).into_response(),
    };

    tracing::info!(email = %email, provider = "oidc", "user login via OIDC");

    let session_cookie = format!(
        "{}={}; HttpOnly; Secure; SameSite=Lax; Path=/; Max-Age={}",
        SESSION_COOKIE,
        session.id,
        SESSION_DURATION_DAYS * 86400
    );

    let clear = "; HttpOnly; Secure; SameSite=Lax; Path=/; Max-Age=0";
    let clear_state = format!("{OIDC_STATE_COOKIE}={clear}");
    let clear_nonce = format!("{OIDC_NONCE_COOKIE}={clear}");
    let clear_pkce = format!("{OIDC_PKCE_COOKIE}={clear}");

    let mut headers = axum::http::HeaderMap::new();
    headers.append(axum::http::header::SET_COOKIE, session_cookie.parse().unwrap());
    headers.append(axum::http::header::SET_COOKIE, clear_state.parse().unwrap());
    headers.append(axum::http::header::SET_COOKIE, clear_nonce.parse().unwrap());
    headers.append(axum::http::header::SET_COOKIE, clear_pkce.parse().unwrap());

    (headers, Redirect::to("/dashboard")).into_response()
}

fn render_login_error(state: &AppState, error: &str) -> Response {
    let oidc_enabled = false;
    let csrf_token = generate_csrf_token();
    let tmpl = match state.templates.get_template("auth/login.html") {
        Ok(t) => t,
        Err(_) => return Html(error.to_string()).into_response(),
    };
    let body = Html(
        tmpl.render(minijinja::context! { error => error, oidc_enabled => oidc_enabled, csrf_token => csrf_token })
            .unwrap_or_else(|_| error.to_string()),
    );
    ([("Set-Cookie", csrf_cookie_value(&csrf_token))], body).into_response()
}

fn render_register_error(state: &AppState, error: &str, auth_config: &AuthConfig) -> Response {
    let csrf_token = generate_csrf_token();
    let tmpl = match state.templates.get_template("auth/register.html") {
        Ok(t) => t,
        Err(_) => return Html(error.to_string()).into_response(),
    };
    let body = Html(
        tmpl.render(minijinja::context! {
            error => error,
            allowed_domains => auth_config.allowed_email_domains,
            csrf_token => csrf_token,
        })
        .unwrap_or_else(|_| error.to_string()),
    );
    ([("Set-Cookie", csrf_cookie_value(&csrf_token))], body).into_response()
}

struct OidcClaims {
    groups: Option<Vec<String>>,
    title: Option<String>,
}

fn extract_claims_from_id_token(raw_token: &str) -> OidcClaims {
    let parts: Vec<&str> = raw_token.split('.').collect();
    if parts.len() != 3 {
        return OidcClaims {
            groups: None,
            title: None,
        };
    }
    let payload_bytes = match base64::engine::general_purpose::URL_SAFE_NO_PAD.decode(parts[1]) {
        Ok(b) => b,
        Err(_) => {
            return OidcClaims {
                groups: None,
                title: None,
            }
        }
    };
    let payload: serde_json::Value = match serde_json::from_slice(&payload_bytes) {
        Ok(v) => v,
        Err(_) => {
            return OidcClaims {
                groups: None,
                title: None,
            }
        }
    };

    let groups = payload.get("groups").and_then(|g| {
        let arr = g.as_array()?;
        let group_strings: Vec<String> = arr
            .iter()
            .filter_map(|v| v.as_str().map(|s| s.strip_prefix('/').unwrap_or(s).to_string()))
            .collect();
        if group_strings.is_empty() {
            None
        } else {
            Some(group_strings)
        }
    });

    let title = payload
        .get("title")
        .and_then(|v| v.as_str())
        .map(|s| s.to_string());
    OidcClaims { groups, title }
}

pub fn generate_group_slug(name: &str) -> String {
    let slug: String = name
        .to_lowercase()
        .chars()
        .map(|c| if c.is_alphanumeric() { c } else { '-' })
        .collect();
    let mut result = String::new();
    let mut prev_dash = true;
    for c in slug.chars() {
        if c == '-' {
            if !prev_dash {
                result.push('-');
            }
            prev_dash = true;
        } else {
            result.push(c);
            prev_dash = false;
        }
    }
    if result.ends_with('-') {
        result.pop();
    }
    if result.is_empty() {
        "group".to_string()
    } else {
        result
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn dummy_password_hash_is_valid() {
        let parsed = PasswordHash::new(DUMMY_HASH);
        assert!(parsed.is_ok(), "DUMMY_HASH must be a valid PHC Argon2 string");
    }

    #[test]
    fn email_allowed_no_restriction() {
        assert!(is_email_allowed("alice@anything.com", &None));
        assert!(is_email_allowed("alice@anything.com", &Some("".to_string())));
        assert!(is_email_allowed("alice@anything.com", &Some("  ".to_string())));
    }

    #[test]
    fn email_allowed_single_domain() {
        let domains = Some("example.com".to_string());
        assert!(is_email_allowed("alice@example.com", &domains));
        assert!(!is_email_allowed("alice@other.com", &domains));
    }

    #[test]
    fn email_allowed_multiple_domains() {
        let domains = Some("example.com, company.org".to_string());
        assert!(is_email_allowed("alice@example.com", &domains));
        assert!(is_email_allowed("bob@company.org", &domains));
        assert!(!is_email_allowed("eve@evil.com", &domains));
    }

    #[test]
    fn email_allowed_case_insensitive() {
        let domains = Some("Example.COM".to_string());
        assert!(is_email_allowed("alice@example.com", &domains));
        assert!(is_email_allowed("alice@EXAMPLE.COM", &domains));
    }

    #[test]
    fn password_hash_roundtrip() {
        let password = "SecureP@ss123";
        let hash = hash_password(password).unwrap();
        assert!(verify_password(password, &hash));
        assert!(!verify_password("wrong-password", &hash));
    }

    #[test]
    fn password_hashes_are_unique() {
        let h1 = hash_password("same-password").unwrap();
        let h2 = hash_password("same-password").unwrap();
        assert_ne!(h1, h2);
        assert!(verify_password("same-password", &h1));
        assert!(verify_password("same-password", &h2));
    }

    #[test]
    fn generate_group_slug_basic() {
        assert_eq!(generate_group_slug("Demo Team"), "demo-team");
        assert_eq!(
            generate_group_slug("engineering/backend"),
            "engineering-backend"
        );
        assert_eq!(generate_group_slug("a - - b"), "a-b");
    }

    #[test]
    fn dummy_password_verification_executes_argon2() {
        let is_valid = verify_password_uniform(None, "dummy_password_123");
        assert!(!is_valid, "Dummy hash verification must always return false");
        let invalid_hash_valid = verify_password_uniform(Some("invalid_phc_hash"), "dummy_password_123");
        assert!(!invalid_hash_valid, "Corrupted hash must fallback to dummy verification and return false");
    }
}