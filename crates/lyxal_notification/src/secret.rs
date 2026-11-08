//! Secrets des notifications : ouverture des enveloppes reçues des producteurs, rescellement pour
//! la file, ouverture au moment du rendu. Tout passe par `lyxal_crypto` (`CryptoEngine`,
//! `SecretContext`), jamais d'AAD vide.
//!
//! Contexte d'un producteur (contrat des événements `auth.*`) :
//! `with_tenant(tenant ?? "lyxal_installation", <producteur>, <type d'événement, points remplacés
//! par `_`>, <event_id>, "secret")`. Contexte de la file :
//! `with_tenant(tenant ?? "lyxal_installation", "lyxal_notification", "notification_run",
//! <idempotency_key>, "secret")`.

use lyxal_crypto::{CryptoEngine, EncryptedEnvelope, KeyResolver, SecretBytes, SecretContext};
use std::sync::Arc;

use crate::error::{NotificationError, NotificationResult};

/// Locataire du contexte pour un secret de l'installation.
pub const INSTALLATION_TENANT: &str = "lyxal_installation";
/// Module du contexte de la file.
pub const QUEUE_MODULE: &str = "lyxal_notification";
/// Ressource du contexte de la file.
pub const QUEUE_RESOURCE: &str = "notification_run";
/// Champ des contextes.
pub const SECRET_FIELD: &str = "secret";

/// Variables sensibles ouvertes : objet JSON, effacé de la mémoire à la libération.
pub struct OpenedSecret {
    bytes: SecretBytes,
}

impl OpenedSecret {
    /// Objet JSON des variables (pour le rendu). La copie est la responsabilité de l'appelant.
    pub fn to_json(&self) -> NotificationResult<serde_json::Map<String, serde_json::Value>> {
        match serde_json::from_slice::<serde_json::Value>(self.bytes.expose_secret()) {
            Ok(serde_json::Value::Object(map)) => Ok(map),
            _ => Err(NotificationError::Secret(
                "le secret ouvert n'est pas un objet JSON".to_string(),
            )),
        }
    }
}

impl std::fmt::Debug for OpenedSecret {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.write_str("OpenedSecret([REDACTED])")
    }
}

/// Ouvre et scelle les secrets des notifications avec le trousseau de l'hôte.
pub struct SecretCodec<R: KeyResolver> {
    crypto: Arc<CryptoEngine<R>>,
}

impl<R: KeyResolver> Clone for SecretCodec<R> {
    fn clone(&self) -> Self {
        Self {
            crypto: self.crypto.clone(),
        }
    }
}

impl<R: KeyResolver> SecretCodec<R> {
    /// Codec sur le moteur cryptographique de l'hôte.
    pub fn new(crypto: Arc<CryptoEngine<R>>) -> Self {
        Self { crypto }
    }

    /// Ouvre l'enveloppe d'un événement (contexte du producteur, lié à l'événement).
    pub fn open_event_secret(
        &self,
        envelope: &str,
        tenant: Option<&str>,
        producer: &str,
        event_type: &str,
        event_id: &str,
    ) -> NotificationResult<OpenedSecret> {
        let context = event_context(tenant, producer, event_type, event_id)?;
        self.open(envelope, &context)
    }

    /// Scelle des variables sensibles pour la file (contexte du module, lié au déclenchement).
    pub fn seal_for_queue(
        &self,
        secret: &OpenedSecret,
        tenant: Option<&str>,
        idempotency_key: &str,
    ) -> NotificationResult<String> {
        // Contrôle du contenu avant de l'accepter dans la file
        secret.to_json()?;
        let context = queue_context(tenant, idempotency_key)?;
        Ok(self.crypto.seal(&secret.bytes, &context)?.encode())
    }

    /// Ouvre le secret d'une étape réservée (contexte de la file).
    pub fn open_queue_secret(
        &self,
        envelope: &str,
        tenant: Option<&str>,
        idempotency_key: &str,
    ) -> NotificationResult<OpenedSecret> {
        let context = queue_context(tenant, idempotency_key)?;
        self.open(envelope, &context)
    }

    /// Scelle un objet JSON pour la file (appel direct de `fn::notification_trigger` par un
    /// module de l'hôte).
    pub fn seal_json_for_queue(
        &self,
        variables: &serde_json::Map<String, serde_json::Value>,
        tenant: Option<&str>,
        idempotency_key: &str,
    ) -> NotificationResult<String> {
        let bytes = zeroize::Zeroizing::new(
            serde_json::to_vec(variables).map_err(|e| NotificationError::Secret(e.to_string()))?,
        );
        let secret = OpenedSecret {
            bytes: SecretBytes::new(bytes.to_vec())?,
        };
        self.seal_for_queue(&secret, tenant, idempotency_key)
    }

    fn open(&self, envelope: &str, context: &SecretContext) -> NotificationResult<OpenedSecret> {
        let parsed = EncryptedEnvelope::parse(envelope)?;
        Ok(OpenedSecret {
            bytes: self.crypto.open(&parsed, context)?,
        })
    }
}

/// Contexte de scellement d'un secret d'événement.
pub fn event_context(
    tenant: Option<&str>,
    producer: &str,
    event_type: &str,
    event_id: &str,
) -> NotificationResult<SecretContext> {
    Ok(SecretContext::with_tenant(
        tenant.unwrap_or(INSTALLATION_TENANT),
        producer,
        &event_type.replace('.', "_"),
        event_id,
        SECRET_FIELD,
    )?)
}

/// Contexte de scellement d'un secret de la file.
pub fn queue_context(tenant: Option<&str>, idempotency_key: &str) -> NotificationResult<SecretContext> {
    Ok(SecretContext::with_tenant(
        tenant.unwrap_or(INSTALLATION_TENANT),
        QUEUE_MODULE,
        QUEUE_RESOURCE,
        idempotency_key,
        SECRET_FIELD,
    )?)
}
