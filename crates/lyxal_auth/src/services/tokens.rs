//! Jetons : jeton d'accès JWT HS256 (vérifié par l'accès SurrealDB `lyxal_auth_<emplacement>`),
//! jetons opaques (renouvellement, liens, secrets client, clés d'API) en empreinte BLAKE3.

use base64::engine::general_purpose::URL_SAFE_NO_PAD;
use base64::Engine;
use lyxal_crypto::{blake3_hex, sign_hmac_sha256, verify_hmac_sha256, SecretString};
use lyxal_surreal::ToSql;
use std::time::{SystemTime, UNIX_EPOCH};

use crate::error::{AuthError, AuthResult};
use crate::models::SessionIssued;
use crate::services::keys::{access_name, random_bytes, ActiveSigningKey};

/// Émetteur (`iss`) des jetons d'accès.
pub const ACCESS_TOKEN_ISSUER: &str = "lyxal_auth";
/// Audience (`aud`) des jetons d'accès : la base de l'installation.
pub const ACCESS_TOKEN_AUDIENCE: &str = "lyxal";

/// Jetons remis au client. Aucune valeur n'est conservée en clair par Lyxal.
pub struct IssuedTokens {
    /// Jeton d'accès (JWT).
    pub access_token: SecretString,
    /// Jeton de renouvellement (sessions interactives seulement).
    pub refresh_token: Option<SecretString>,
    /// Durée de validité du jeton d'accès (secondes).
    pub expires_in: i64,
    /// Session ouverte.
    pub session: SessionIssued,
}

impl std::fmt::Debug for IssuedTokens {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("IssuedTokens")
            .field("access_token", &"[REDACTED]")
            .field(
                "refresh_token",
                &self.refresh_token.as_ref().map(|_| "[REDACTED]"),
            )
            .field("expires_in", &self.expires_in)
            .field("session", &self.session.session)
            .finish()
    }
}

/// Jeton opaque et son empreinte.
pub struct OpaqueToken {
    /// Valeur remise une seule fois (préfixe compris).
    pub value: SecretString,
    /// Empreinte BLAKE3 (hex) conservée en base.
    pub hash: String,
    /// Huit premiers caractères, pour reconnaître le jeton.
    pub prefix: String,
}

/// Jeton opaque de 32 octets (`OsRng`), Base64 URL sans remplissage, précédé de `prefix`.
pub fn opaque_token(prefix: &str) -> AuthResult<OpaqueToken> {
    let raw = random_bytes(32)?;
    let value = format!("{prefix}{}", URL_SAFE_NO_PAD.encode(raw.expose_secret()));
    let hash = blake3_hex(value.as_bytes());
    let shown: String = value.chars().take(8).collect();
    Ok(OpaqueToken {
        value: SecretString::new(value)?,
        hash,
        prefix: shown,
    })
}

/// Empreinte BLAKE3 d'un jeton présenté.
pub fn token_hash(token: &SecretString) -> String {
    blake3_hex(token.expose_secret().as_bytes())
}

/// Émet le jeton d'accès d'une session : claims lus par `fn::auth_session_valid` et
/// `fn::auth_has_permission` (`id`, `pv`, `permissions`), signés avec la clé de l'accès actif.
pub fn access_token(
    key: &ActiveSigningKey,
    namespace: &str,
    database: &str,
    issued: &SessionIssued,
) -> AuthResult<SecretString> {
    let now = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .map_err(|_| AuthError::Rejected("AUTH_SIGNING_KEY_UNAVAILABLE"))?
        .as_secs() as i64;
    let subject = issued
        .identity
        .as_ref()
        .or(issued.application.as_ref())
        .map(|id| id.to_sql());
    let claims = serde_json::json!({
        "iss": ACCESS_TOKEN_ISSUER,
        "aud": ACCESS_TOKEN_AUDIENCE,
        "ns": namespace,
        "db": database,
        "ac": access_name(&key.slot),
        "id": issued.session.to_sql(),
        "sub": subject,
        "tenant": issued.organization.as_ref().map(|id| id.to_sql()),
        "kind": issued.kind,
        "permissions": issued.permissions,
        "pv": issued.version,
        "aal": issued.aal,
        "jti": uuid::Uuid::now_v7().to_string(),
        "iat": now,
        "nbf": now,
        "exp": now + issued.access_seconds,
    });
    let header = URL_SAFE_NO_PAD.encode(br#"{"alg":"HS256","typ":"JWT"}"#);
    let payload = URL_SAFE_NO_PAD.encode(claims.to_string().as_bytes());
    let signing_input = format!("{header}.{payload}");
    let signature = sign_hmac_sha256(&key.hmac_key()?, signing_input.as_bytes())?;
    Ok(SecretString::new(format!(
        "{signing_input}.{}",
        URL_SAFE_NO_PAD.encode(signature)
    ))?)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn opaque_tokens_are_random_prefixed_and_hashed() {
        let a = opaque_token("lyxk_").expect("jeton");
        let b = opaque_token("lyxk_").expect("jeton");
        assert!(a.value.expose_secret().starts_with("lyxk_"));
        assert_eq!(a.prefix.len(), 8);
        assert_eq!(a.hash.len(), 64);
        assert_ne!(a.hash, b.hash);
        assert_eq!(token_hash(&a.value), a.hash);
    }
}

/// Claims d'un jeton d'accès dont la signature et l'expiration ont été vérifiées.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct VerifiedClaims {
    /// Emplacement de la clé (`a`, `b`).
    pub slot: String,
    /// Session (texte `auth_session:<clé>`).
    pub session: String,
    /// Version des droits portée par le jeton.
    pub pv: i64,
    /// Permissions portées par le jeton.
    pub permissions: Vec<String>,
}

/// Lit l'emplacement (`ac`) d'un jeton sans rien lui accorder (pour choisir la clé).
pub fn token_slot(token: &SecretString) -> AuthResult<String> {
    let claims = decode_claims(token)?;
    claims["ac"]
        .as_str()
        .and_then(|ac| ac.strip_prefix("lyxal_auth_"))
        .filter(|slot| *slot == "a" || *slot == "b")
        .map(str::to_string)
        .ok_or(AuthError::Rejected("AUTH_SESSION_REQUIRED"))
}

/// Vérifie la signature HS256 (temps constant), l'en-tête, l'émetteur, l'audience, l'espace de
/// noms, la base, la période de validité et la forme des revendications d'un jeton d'accès.
pub fn verify_access_token(
    key: &ActiveSigningKey,
    token: &SecretString,
    namespace: &str,
    database: &str,
) -> AuthResult<VerifiedClaims> {
    let refused = || AuthError::Rejected("AUTH_SESSION_REQUIRED");
    let mut parts = token.expose_secret().split('.');
    let (Some(header), Some(payload), Some(signature), None) =
        (parts.next(), parts.next(), parts.next(), parts.next())
    else {
        return Err(refused());
    };
    let header: serde_json::Value =
        serde_json::from_slice(&URL_SAFE_NO_PAD.decode(header).map_err(|_| refused())?)
            .map_err(|_| refused())?;
    if header["alg"] != "HS256" {
        return Err(refused());
    }
    let signature = URL_SAFE_NO_PAD.decode(signature).map_err(|_| refused())?;
    let signing_input = format!(
        "{}.{payload}",
        token.expose_secret().split('.').next().unwrap_or_default()
    );
    if !verify_hmac_sha256(&key.hmac_key()?, signing_input.as_bytes(), &signature)? {
        return Err(refused());
    }
    let claims = decode_claims(token)?;
    let now = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .map_err(|_| refused())?
        .as_secs() as i64;
    let exp = claims["exp"].as_i64().ok_or_else(refused)?;
    let nbf = claims["nbf"].as_i64().unwrap_or(0);
    if claims["iss"] != ACCESS_TOKEN_ISSUER || claims["aud"] != ACCESS_TOKEN_AUDIENCE {
        return Err(refused());
    }
    if exp <= now
        || nbf > now + 60
        || claims["ns"] != namespace
        || claims["db"] != database
        || claims["ac"] != access_name(&key.slot)
    {
        return Err(AuthError::Rejected("AUTH_SESSION_EXPIRED"));
    }
    Ok(VerifiedClaims {
        slot: key.slot.clone(),
        session: claims["id"].as_str().ok_or_else(refused)?.to_string(),
        pv: claims["pv"].as_i64().ok_or_else(refused)?,
        // Revendication signée par Lyxal : un tableau de chaînes, sinon le jeton est refusé
        permissions: claims["permissions"]
            .as_array()
            .ok_or_else(refused)?
            .iter()
            .map(|p| p.as_str().map(str::to_string).ok_or_else(refused))
            .collect::<AuthResult<Vec<String>>>()?,
    })
}

fn decode_claims(token: &SecretString) -> AuthResult<serde_json::Value> {
    let payload = token
        .expose_secret()
        .split('.')
        .nth(1)
        .ok_or(AuthError::Rejected("AUTH_SESSION_REQUIRED"))?;
    let bytes = URL_SAFE_NO_PAD
        .decode(payload)
        .map_err(|_| AuthError::Rejected("AUTH_SESSION_REQUIRED"))?;
    serde_json::from_slice(&bytes).map_err(|_| AuthError::Rejected("AUTH_SESSION_REQUIRED"))
}
