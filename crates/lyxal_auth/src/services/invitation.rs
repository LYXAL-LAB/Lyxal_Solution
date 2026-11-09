//! Invitations : génération du jeton, empreinte, lien scellé.
//!
//! Le jeton (32 octets de `OsRng`, Base64 URL sans remplissage) n'est jamais enregistré : la base
//! reçoit son empreinte BLAKE3 et le lien d'acceptation scellé (`enc:v2`) sous le contexte du
//! contrat d'événement de `lyxal_notification` (son `README.md` §4) :
//! `SecretContext::with_tenant(<clé de l'organisation>, "lyxal_auth", "auth_invitation_created",
//! <event_id>, "secret")`. L'identifiant d'événement (UUID v7) est alloué avant le scellement et
//! transmis à `fn::auth_invitation_create`, qui publie l'événement avec ce même identifiant.

use base64::engine::general_purpose::URL_SAFE_NO_PAD;
use base64::Engine;
use lyxal_crypto::{
    blake3_hex, CryptoEngine, KeyResolver, SecretBytes, SecretContext, SecretString,
};
use rand_core::{OsRng, RngCore};
use std::sync::Arc;
use zeroize::Zeroizing;

use crate::error::{AuthError, AuthResult};
use crate::models::{
    AuthDatetime, Invitation, InvitationAcceptParams, InvitationAccepted, InvitationCreateParams,
};
use crate::store::AuthStore;

/// Producteur et type d'événement du contrat de scellement.
pub const INVITATION_SEAL_MODULE: &str = "lyxal_auth";
/// Ressource du contexte de scellement : type d'événement, points remplacés par `_`.
pub const INVITATION_SEAL_RESOURCE: &str = "auth_invitation_created";
/// Champ du contexte de scellement.
pub const INVITATION_SEAL_FIELD: &str = "secret";
/// Octets d'aléa d'un jeton d'invitation.
const TOKEN_BYTES: usize = 32;

/// Demande d'invitation.
#[derive(Debug, Clone)]
pub struct InvitationRequest {
    /// Organisation (texte `auth_organization:<clé>`).
    pub organization: String,
    /// Adresse invitée.
    pub email: String,
    /// Rôles d'organisation prévus (textes `auth_role:<clé>`).
    pub roles: Vec<String>,
    /// Fin de validité (défaut : politique).
    pub expires_at: Option<AuthDatetime>,
}

/// Service d'invitation, sur la session SurrealDB de l'appelant et le trousseau de l'hôte.
pub struct InvitationService<R: KeyResolver> {
    store: AuthStore,
    crypto: Arc<CryptoEngine<R>>,
    accept_url: String,
}

impl<R: KeyResolver> InvitationService<R> {
    /// `accept_url` : adresse publique de la page d'acceptation (`https://…`), complétée par
    /// `#token=<jeton>` (fragment : jamais envoyé au serveur ni journalisé).
    pub fn new(
        store: AuthStore,
        crypto: Arc<CryptoEngine<R>>,
        accept_url: impl Into<String>,
    ) -> AuthResult<Self> {
        let accept_url = accept_url.into();
        if !(accept_url.starts_with("https://") || accept_url.starts_with("http://"))
            || accept_url.contains('?')
            || accept_url.contains('#')
            || accept_url
                .chars()
                .any(|c| c.is_whitespace() || c.is_control() || c == '"' || c == '\\')
        {
            return Err(AuthError::InvalidParameter("accept_url"));
        }
        Ok(Self {
            store,
            crypto,
            accept_url,
        })
    }

    /// Crée l'invitation : jeton, empreinte, lien scellé, puis `fn::auth_invitation_create`.
    pub async fn invite(&self, request: InvitationRequest) -> AuthResult<Invitation> {
        let tenant = organization_key(&request.organization)?;
        let event_id = uuid::Uuid::now_v7().to_string();
        let token = generate_token()?;
        let token_hash = blake3_hex(token.expose_secret().as_bytes());
        // Objet JSON { action_url } écrit directement (l'URL et le jeton ne contiennent ni
        // guillemet ni barre oblique inverse) : aucune copie non effaçable du jeton
        let payload = Zeroizing::new(format!(
            "{{\"action_url\":\"{}#token={}\"}}",
            self.accept_url,
            token.expose_secret()
        ));
        let secret = SecretBytes::new(payload.as_bytes().to_vec())?;
        let context = SecretContext::with_tenant(
            tenant,
            INVITATION_SEAL_MODULE,
            INVITATION_SEAL_RESOURCE,
            &event_id,
            INVITATION_SEAL_FIELD,
        )?;
        let sealed = self.crypto.seal(&secret, &context)?;
        let invitation = self
            .store
            .invitation_create(InvitationCreateParams {
                organization: request.organization,
                email: request.email,
                roles: request.roles,
                event_id,
                token_hash,
                secret: sealed.encode(),
                expires_at: request.expires_at,
            })
            .await?;
        Ok(invitation)
    }

    /// Accepte une invitation pour l'identité de la session : empreinte du jeton présenté, puis
    /// `fn::auth_invitation_accept`.
    pub async fn accept(&self, token: &SecretString) -> AuthResult<InvitationAccepted> {
        Ok(self
            .store
            .invitation_accept(InvitationAcceptParams {
                token_hash: blake3_hex(token.expose_secret().as_bytes()),
            })
            .await?)
    }
}

/// Contexte de scellement d'un lien d'invitation (utilisé aussi pour l'ouvrir dans les tests et
/// par `lyxal_notification`).
pub fn invitation_seal_context(
    organization_key: &str,
    event_id: &str,
) -> AuthResult<SecretContext> {
    Ok(SecretContext::with_tenant(
        organization_key,
        INVITATION_SEAL_MODULE,
        INVITATION_SEAL_RESOURCE,
        event_id,
        INVITATION_SEAL_FIELD,
    )?)
}

/// Clé d'une organisation à partir de son identifiant texte `auth_organization:<clé>`.
fn organization_key(organization: &str) -> AuthResult<&str> {
    match organization.split_once(':') {
        Some(("auth_organization", key)) if !key.is_empty() => Ok(key),
        _ => Err(AuthError::InvalidParameter("organization")),
    }
}

/// Jeton aléatoire de 32 octets (`OsRng`), Base64 URL sans remplissage.
pub(crate) fn generate_token() -> AuthResult<SecretString> {
    let mut raw = Zeroizing::new([0u8; TOKEN_BYTES]);
    OsRng
        .try_fill_bytes(raw.as_mut())
        .map_err(|_| AuthError::Crypto(lyxal_crypto::CryptoError::RandomUnavailable))?;
    Ok(SecretString::new(URL_SAFE_NO_PAD.encode(raw.as_ref()))?)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn tokens_are_random_base64url_without_padding() {
        let a = generate_token().expect("jeton");
        let b = generate_token().expect("jeton");
        assert_eq!(a.expose_secret().len(), 43);
        assert_ne!(a.expose_secret(), b.expose_secret());
        assert!(a
            .expose_secret()
            .bytes()
            .all(|c| c.is_ascii_alphanumeric() || c == b'-' || c == b'_'));
        assert_eq!(format!("{a:?}"), "SecretString([REDACTED])");
    }

    #[test]
    fn organization_key_requires_an_organization_record() {
        assert_eq!(
            organization_key("auth_organization:01ab").expect("clé"),
            "01ab"
        );
        for bad in ["auth_organization:", "autre:01ab", "01ab", ""] {
            assert!(organization_key(bad).is_err(), "{bad}");
        }
    }

    #[test]
    fn seal_context_binds_tenant_and_event() {
        let a = invitation_seal_context("org1", "evt-1").expect("contexte");
        let b = invitation_seal_context("org1", "evt-2").expect("contexte");
        assert_ne!(a, b);
        assert!(
            invitation_seal_context("org 1", "evt-1").is_err(),
            "clé d'organisation invalide"
        );
    }

    #[test]
    fn create_params_debug_redacts_secrets() {
        let params = InvitationCreateParams {
            organization: "auth_organization:o".into(),
            email: "a@b.fr".into(),
            roles: vec![],
            event_id: "e".into(),
            token_hash: "deadbeef".into(),
            secret: "enc:v2:k:abc".into(),
            expires_at: None,
        };
        let debug = format!("{params:?}");
        assert!(!debug.contains("deadbeef") && !debug.contains("enc:v2"));
    }
}
