//! Liens de désabonnement en un clic (décisions B6 et K9, RFC 8058).
//!
//! Le jeton porte la portée, l'abonné, la catégorie du parcours (sinon le parcours) et le canal,
//! en JSON encodé en Base64url, suivi de sa signature HMAC-SHA256 (`lyxal_crypto`). La clé de
//! signature est dérivée de la clé applicative par HKDF-SHA256 (`lyxal_crypto::hkdf_sha256`,
//! domaine propre au désabonnement) : aucune clé à conserver en base. Le jeton n'expire pas et
//! n'ouvre aucun compte ; la vérification compare la signature en temps constant
//! (`verify_hmac_sha256`) avant de lire le contenu. Aucun jeton n'est fait pour un parcours
//! critique.

use base64::engine::general_purpose::URL_SAFE_NO_PAD;
use base64::Engine;
use lyxal_crypto::{hkdf_sha256, sign_hmac_sha256, verify_hmac_sha256, HmacKey, SecretBytes};
use lyxal_surreal::ToSql;
use serde::{Deserialize, Serialize};

use crate::error::{NotificationError, NotificationResult};
use crate::models::{UnsubscribeParams, UnsubscribeTarget};

/// Chemin des routes de désabonnement de l'hôte.
pub const UNSUBSCRIBE_PATH: &str = "/api/v1/notification/unsubscribe";
/// Domaine de la dérivation de clé (HKDF `info`).
const KEY_INFO: &[u8] = b"lyxal_notification/unsubscribe/v1";
/// Préfixe signé avec le contenu (séparation des usages de la clé).
const SIGNED_PREFIX: &str = "lyxal_notification.unsubscribe.v1.";
/// Longueur maximale d'un jeton accepté.
const MAX_TOKEN_LEN: usize = 1024;

/// Contenu signé d'un jeton.
#[derive(Debug, Serialize, Deserialize, PartialEq, Eq)]
#[serde(deny_unknown_fields)]
struct Claims {
    /// Version du format.
    v: u8,
    /// Portée (`installation` ou clé de l'organisation).
    sc: String,
    /// Abonné (`notification_subscriber:<clé>`).
    su: String,
    /// Catégorie (`notification_category:<clé>`).
    #[serde(default, skip_serializing_if = "Option::is_none")]
    ca: Option<String>,
    /// Parcours (`notification_workflow:<clé>`) sans catégorie.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    wf: Option<String>,
    /// Canal.
    ch: String,
}

/// Fabrique et vérifie les liens de désabonnement d'une installation.
pub struct UnsubscribeLinks {
    endpoint: String,
    key: HmacKey,
}

impl std::fmt::Debug for UnsubscribeLinks {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("UnsubscribeLinks")
            .field("endpoint", &self.endpoint)
            .field("key", &"[REDACTED]")
            .finish()
    }
}

impl UnsubscribeLinks {
    /// Liens servis par l'hôte à `public_url` (`https://…`, sans requête ni fragment), signés
    /// par une clé dérivée de la clé applicative (`application_key`, 32 octets).
    pub fn new(public_url: &str, application_key: &SecretBytes) -> NotificationResult<Self> {
        let base = public_url.trim().trim_end_matches('/');
        let valid = (base.starts_with("https://") || base.starts_with("http://"))
            && base.len() > "https://".len()
            && !base.contains(['?', '#', ' ', '"', '<', '>']);
        if !valid {
            return Err(NotificationError::Configuration(
                "notification.public_url : adresse http(s) sans requête ni fragment attendue"
                    .to_string(),
            ));
        }
        let derived = hkdf_sha256(application_key, None, KEY_INFO, 32)?;
        Ok(Self {
            endpoint: format!("{base}{UNSUBSCRIBE_PATH}"),
            key: HmacKey::import(derived)?,
        })
    }

    /// Jeton signé pour une cible.
    pub fn token(&self, target: &UnsubscribeTarget) -> NotificationResult<String> {
        let claims = Claims {
            v: 1,
            sc: target.scope.clone(),
            su: target.subscriber.to_sql(),
            ca: target.category.as_ref().map(ToSql::to_sql),
            wf: if target.category.is_some() {
                None
            } else {
                target.workflow.as_ref().map(ToSql::to_sql)
            },
            ch: target.channel.clone(),
        };
        let json = serde_json::to_vec(&claims)
            .map_err(|_| NotificationError::Configuration("jeton illisible".to_string()))?;
        let payload = URL_SAFE_NO_PAD.encode(json);
        let tag = sign_hmac_sha256(&self.key, signed(&payload).as_bytes())?;
        Ok(format!("{payload}.{}", URL_SAFE_NO_PAD.encode(tag)))
    }

    /// Adresse du lien (`{public_url}/api/v1/notification/unsubscribe?t=<jeton>`), pour l'en-tête
    /// `List-Unsubscribe` et la variable `unsubscribe_url` des gabarits.
    pub fn url(&self, target: &UnsubscribeTarget) -> NotificationResult<String> {
        Ok(format!("{}?t={}", self.endpoint, self.token(target)?))
    }

    /// Vérifie un jeton (signature en temps constant, puis contenu) et rend les paramètres de
    /// `fn::notification_unsubscribe`. Toute anomalie : `NotificationError::Unsubscribe`.
    pub fn verify(&self, token: &str) -> NotificationResult<UnsubscribeParams> {
        let refused = || NotificationError::Unsubscribe;
        if token.is_empty() || token.len() > MAX_TOKEN_LEN {
            return Err(refused());
        }
        let (payload, tag) = token.split_once('.').ok_or_else(refused)?;
        let tag = URL_SAFE_NO_PAD.decode(tag).map_err(|_| refused())?;
        if !verify_hmac_sha256(&self.key, signed(payload).as_bytes(), &tag)
            .map_err(|_| refused())?
        {
            return Err(refused());
        }
        let json = URL_SAFE_NO_PAD.decode(payload).map_err(|_| refused())?;
        let claims: Claims = serde_json::from_slice(&json).map_err(|_| refused())?;
        let record = |value: &str, table: &str| {
            value
                .strip_prefix(table)
                .and_then(|key| key.strip_prefix(':'))
                .is_some_and(|key| !key.is_empty() && !key.contains(':'))
        };
        let target_ok = match (&claims.ca, &claims.wf) {
            (Some(category), None) => record(category, "notification_category"),
            (None, Some(workflow)) => record(workflow, "notification_workflow"),
            _ => false,
        };
        if claims.v != 1 || !record(&claims.su, "notification_subscriber") || !target_ok {
            return Err(refused());
        }
        Ok(UnsubscribeParams {
            subscriber: claims.su,
            category: claims.ca,
            workflow: claims.wf,
            channel: claims.ch,
        })
    }
}

fn signed(payload: &str) -> String {
    format!("{SIGNED_PREFIX}{payload}")
}

#[cfg(test)]
mod tests {
    use super::*;
    use lyxal_surreal::RecordId;

    fn links(seed: u8) -> UnsubscribeLinks {
        UnsubscribeLinks::new(
            "https://lyxal.test/",
            &SecretBytes::new(vec![seed; 32]).expect("clé"),
        )
        .expect("liens")
    }

    fn target(category: bool) -> UnsubscribeTarget {
        UnsubscribeTarget {
            scope: "alpha".into(),
            subscriber: RecordId::new("notification_subscriber", "abc"),
            category: category.then(|| RecordId::new("notification_category", "actualites")),
            workflow: Some(RecordId::new("notification_workflow", "lettre")),
            channel: "email".into(),
        }
    }

    #[test]
    fn a_token_round_trips_to_the_category_or_the_workflow() {
        let links = links(7);
        let url = links.url(&target(true)).expect("lien");
        assert!(url.starts_with("https://lyxal.test/api/v1/notification/unsubscribe?t="));
        let token = url.rsplit("?t=").next().expect("jeton");
        assert_eq!(
            links.verify(token).expect("vérifié"),
            UnsubscribeParams {
                subscriber: "notification_subscriber:abc".into(),
                category: Some("notification_category:actualites".into()),
                workflow: None,
                channel: "email".into(),
            }
        );
        let token = links.token(&target(false)).expect("jeton");
        let params = links.verify(&token).expect("vérifié");
        assert_eq!(
            (params.category, params.workflow.as_deref()),
            (None, Some("notification_workflow:lettre"))
        );
    }

    #[test]
    fn a_tampered_or_foreign_token_is_refused() {
        let links = links(7);
        let token = links.token(&target(true)).expect("jeton");
        let (payload, tag) = token.split_once('.').expect("forme");
        // Contenu modifié (autre abonné), signature d'origine
        let forged = URL_SAFE_NO_PAD.encode(
            String::from_utf8(URL_SAFE_NO_PAD.decode(payload).expect("b64"))
                .expect("utf8")
                .replace("abc", "abd"),
        );
        for bad in [
            format!("{forged}.{tag}"),
            format!("{payload}.{}", URL_SAFE_NO_PAD.encode([0u8; 32])),
            payload.to_string(),
            String::new(),
            "a".repeat(2000),
        ] {
            assert!(matches!(
                links.verify(&bad),
                Err(NotificationError::Unsubscribe)
            ));
        }
        // Jeton signé par une autre clé applicative
        assert!(super::UnsubscribeLinks::verify(&self::links(8), &token).is_err());
    }

    #[test]
    fn the_public_url_must_be_a_plain_http_address() {
        let key = SecretBytes::new(vec![1; 32]).expect("clé");
        for bad in [
            "lyxal.test",
            "https://",
            "https://lyxal.test/?x=1",
            "ftp://lyxal.test",
        ] {
            assert!(UnsubscribeLinks::new(bad, &key).is_err(), "{bad}");
        }
        assert!(!format!("{:?}", links(3)).contains("3, 3"));
    }
}
