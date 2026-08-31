use anyhow::Result;
use serde::Serialize;
use surrealdb::RecordId;

use crate::contracts::auth::{AuthenticatedAdmin, AuthenticatedUser};
use crate::contracts::users::{
    DeleteUserResponse, InviteUserRequest, InviteUserResponse, UpdateTimezoneRequest,
    UpdateTimezoneResponse, UpdateUserProfileRequest, UserProfileResponse, UserResponse,
};
use lyxal_surreal::LyxalSurrealCall;
use crate::db::SurrealBookingStore;

#[derive(Debug, Clone, Serialize)]
struct GetUserProfileParams {
    user_id: RecordId,
}

#[derive(Debug, Clone, Serialize)]
struct UpdateUserProfileParams {
    user_id: RecordId,
    name: Option<String>,
    booking_email: Option<String>,
}

#[derive(Debug, Clone, Serialize)]
struct UpdateTimezoneParams {
    user_id: RecordId,
    time_zone: String,
}

#[derive(Debug, Clone, Serialize)]
struct InviteUserParams {
    email: String,
    role: String,
}

#[derive(Debug, Clone, Serialize)]
struct DeleteUserAccountParams {
    #[serde(rename = "target_id")]
    target_user_id: RecordId,
    #[serde(rename = "requester_id")]
    requester_user_id: RecordId,
    language: String,
}

#[derive(Debug, Clone, serde::Deserialize)]
struct DeletedUserResult {
    deleted: bool,
    user_id: RecordId,
    avatar_path: Option<String>,
}

#[derive(Debug, Clone, serde::Deserialize)]
struct UserProfileRow {
    id: String,
    user_id: String,
    name: String,
    email: String,
    booking_email: Option<String>,
    time_zone: String,
    avatar_path: Option<String>,
    role: String,
    enabled: bool,
}

/// Récupère le profil de l'utilisateur authentifié.
pub async fn get_user_profile(
    store: &SurrealBookingStore,
    auth: &AuthenticatedUser,
) -> Result<UserProfileResponse> {
    let auth_rec = RecordId::from(("booking_account", auth.user_id.as_str()));
    let params = GetUserProfileParams { user_id: auth_rec };
    let row: UserProfileRow = store
        .call_fn("booking_get_user_profile", params)
        .await?;

    Ok(UserProfileResponse {
        id: row.id,
        user_id: row.user_id,
        name: row.name,
        email: row.email,
        booking_email: row.booking_email,
        time_zone: row.time_zone,
        avatar_path: row.avatar_path,
        role: row.role,
        enabled: row.enabled,
    })
}

/// Met à jour le profil de l'utilisateur authentifié (nom, email de réservation).
pub async fn update_user_profile(
    store: &SurrealBookingStore,
    auth: &AuthenticatedUser,
    request: &UpdateUserProfileRequest,
) -> Result<UserProfileResponse> {
    let auth_rec = RecordId::from(("booking_account", auth.user_id.as_str()));
    let params = UpdateUserProfileParams {
        user_id: auth_rec,
        name: request.name.clone(),
        booking_email: request.booking_email.clone(),
    };
    let row: UserProfileRow = store
        .call_fn("booking_update_user_profile", params)
        .await?;

    Ok(UserProfileResponse {
        id: row.id,
        user_id: row.user_id,
        name: row.name,
        email: row.email,
        booking_email: row.booking_email,
        time_zone: row.time_zone,
        avatar_path: row.avatar_path,
        role: row.role,
        enabled: row.enabled,
    })
}

/// Met à jour le fuseau horaire IANA par défaut de l'utilisateur authentifié.
pub async fn update_user_timezone(
    store: &SurrealBookingStore,
    auth: &AuthenticatedUser,
    request: &UpdateTimezoneRequest,
) -> Result<UpdateTimezoneResponse> {
    let auth_rec = RecordId::from(("booking_account", auth.user_id.as_str()));
    let params = UpdateTimezoneParams {
        user_id: auth_rec,
        time_zone: request.time_zone.clone(),
    };
    let response: UpdateTimezoneResponse = store
        .call_fn("booking_update_user_timezone", params)
        .await?;
    Ok(response)
}

pub async fn invite_user(
    store: &SurrealBookingStore,
    request: &InviteUserRequest,
) -> Result<InviteUserResponse> {
    let role = request.role.as_deref().unwrap_or("user").to_string();
    let params = InviteUserParams {
        email: request.email.clone(),
        role,
    };
    let invitation: InviteUserResponse = store
        .call_fn("booking_create_user_invitation", params)
        .await?;

    Ok(invitation)
}

/// Liste l'ensemble des utilisateurs actifs (exécuté avec vérification administrateur).
pub async fn list_users(
    store: &SurrealBookingStore,
    _admin: &AuthenticatedAdmin,
) -> Result<Vec<UserResponse>> {
    let mut response = store
        .client()
        .query("RETURN fn::booking_get_all_enabled_users();")
        .await?;
    let raw: Option<lyxal_error::LyxalResult<Vec<UserResponse>>> = response.take(0)?;
    match raw {
        Some(res) => Ok(res.into_result("booking_get_all_enabled_users")?),
        None => Ok(Vec::new()),
    }
}

/// Supprime un compte utilisateur de manière sécurisée (avec vérification administrateur).
pub async fn delete_user(
    store: &SurrealBookingStore,
    admin: &AuthenticatedAdmin,
    target_id_str: &str,
) -> Result<DeleteUserResponse> {
    let target_rec = RecordId::from(("booking_account", target_id_str));
    let requester_rec = RecordId::from(("booking_account", admin.user_id.as_str()));
    let params = DeleteUserAccountParams {
        target_user_id: target_rec,
        requester_user_id: requester_rec,
        language: "fr".to_string(),
    };
    let res: DeletedUserResult = store
        .call_fn("booking_delete_user", params)
        .await?;

    Ok(DeleteUserResponse {
        deleted: res.deleted,
    })
}

// --- Algorithmes de Bulk Invites (Bloc 15) ---

#[derive(Debug, Default, PartialEq, Eq)]
pub struct BulkInviteResult {
    pub sent: Vec<String>,
    pub invalid: Vec<String>,
    pub duplicates: Vec<String>,
    pub failed: Vec<String>,
    pub over_limit: bool,
}

pub fn is_plausible_email(s: &str) -> bool {
    if s.chars().any(char::is_whitespace) {
        return false;
    }
    if s.len() > 254 {
        return false;
    }
    let mut parts = s.splitn(2, '@');
    let local = parts.next().unwrap_or("");
    let domain = parts.next().unwrap_or("");
    !local.is_empty() && domain.contains('.') && domain.len() >= 3 && !domain.starts_with('.')
}

pub fn derive_name_from_email(email: &str) -> String {
    let local = email.split('@').next().unwrap_or(email);
    let parts: Vec<String> = local
        .split(['.', '_', '-', '+'])
        .filter(|s| !s.is_empty())
        .map(|s| {
            let mut chars = s.chars();
            match chars.next() {
                Some(first) => first.to_uppercase().collect::<String>() + chars.as_str(),
                None => String::new(),
            }
        })
        .collect();
    if parts.is_empty() {
        local.to_string()
    } else {
        parts.join(" ")
    }
}

pub fn parse_bulk_recipients(input: &str, max: usize) -> (Vec<(String, String)>, BulkInviteResult) {
    let mut valid: Vec<(String, String)> = Vec::new();
    let mut result = BulkInviteResult::default();
    let mut seen: std::collections::HashSet<String> = std::collections::HashSet::new();

    for raw in input.lines() {
        let line = raw.trim();
        if line.is_empty() {
            continue;
        }
        if valid.len() + result.invalid.len() + result.duplicates.len() >= max {
            result.over_limit = true;
            break;
        }
        if !is_plausible_email(line) {
            result.invalid.push(line.to_string());
            continue;
        }
        let key = line.to_ascii_lowercase();
        if !seen.insert(key) {
            result.duplicates.push(line.to_string());
            continue;
        }
        let name = derive_name_from_email(line);
        valid.push((line.to_string(), name));
    }
    (valid, result)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn bulk_invite_parses_valid_emails() {
        let (valid, result) = parse_bulk_recipients("alice@example.com\nbob@example.org\n", 100);
        assert_eq!(valid.len(), 2);
        assert_eq!(valid[0].0, "alice@example.com");
        assert_eq!(valid[0].1, "Alice");
        assert_eq!(valid[1].0, "bob@example.org");
        assert_eq!(valid[1].1, "Bob");
        assert!(result.invalid.is_empty());
        assert!(result.duplicates.is_empty());
        assert!(!result.over_limit);
    }

    #[test]
    fn bulk_invite_skips_blank_lines_and_trims() {
        let (valid, _) = parse_bulk_recipients("\n  alice@example.com  \n\n", 100);
        assert_eq!(valid.len(), 1);
        assert_eq!(valid[0].0, "alice@example.com");
    }

    #[test]
    fn bulk_invite_rejects_malformed_rows() {
        let (valid, result) = parse_bulk_recipients(
            "alice@example.com\nnot-an-email\n@nope.com\nfoo@\nfoo@bar\nok@x.io",
            100,
        );
        assert_eq!(valid.len(), 2);
        assert_eq!(result.invalid.len(), 4);
    }

    #[test]
    fn bulk_invite_dedupes_case_insensitively() {
        let (valid, result) = parse_bulk_recipients("Alice@Example.com\nalice@example.com\n", 100);
        assert_eq!(valid.len(), 1);
        assert_eq!(result.duplicates, vec!["alice@example.com".to_string()]);
    }

    #[test]
    fn bulk_invite_caps_at_max() {
        let mut input = String::new();
        for i in 0..10 {
            input.push_str(&format!("user{}@example.com\n", i));
        }
        let (valid, result) = parse_bulk_recipients(&input, 3);
        assert_eq!(valid.len(), 3);
        assert!(result.over_limit);
    }

    #[test]
    fn bulk_invite_derives_pretty_names() {
        assert_eq!(derive_name_from_email("john.doe@example.com"), "John Doe");
        assert_eq!(
            derive_name_from_email("mary_smith@example.com"),
            "Mary Smith"
        );
        assert_eq!(derive_name_from_email("alice@example.com"), "Alice");
    }
}
