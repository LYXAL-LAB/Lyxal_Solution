//! Secrets des notifications : ouverture des enveloppes reçues des producteurs, rescellement pour
//! la file, ouverture au moment du rendu. Tout passe par `lyxal_crypto` (`CryptoEngine`,
//! `SecretContext`), jamais d'AAD vide.
//!
//! Contexte d'un producteur (contrat des événements `auth.*`) :
//! `with_tenant(tenant ?? "lyxal_installation", <producteur>, <type d'événement, points remplacés
//! par `_`>, <event_id>, "secret")`. Contexte de la file :
//! `with_tenant(tenant ?? "lyxal_installation", "lyxal_notification", "notification_run",
//! <idempotency_key>, "secret")`. Contexte d'une adresse de messagerie ou web (décision E2) :
//! `with_tenant(tenant ?? "lyxal_installation", "lyxal_notification", "notification_endpoint",
//! <clé de l'adresse>, "url" | "signing_secret")`.

use lyxal_crypto::{
    CryptoEngine, EncryptedEnvelope, HmacKey, KeyResolver, SecretBytes, SecretContext,
};
use rand_core::{OsRng, RngCore};
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
/// Ressource du contexte d'une adresse de messagerie ou web.
pub const ENDPOINT_RESOURCE: &str = "notification_endpoint";

/// Valeur scellée d'une adresse de messagerie ou web.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum EndpointField {
    /// Adresse complète (champ `url`).
    Url,
    /// Clé de signature d'une adresse web (champ `signing_secret`).
    SigningSecret,
}

impl EndpointField {
    /// Nom du champ (contexte de scellement et colonne).
    pub fn as_str(self) -> &'static str {
        match self {
            Self::Url => "url",
            Self::SigningSecret => "signing_secret",
        }
    }
}

/// Clé de signature d'une adresse web (décision E4) : 32 octets tirés par le générateur du
/// système (`rand_core::OsRng`), vérifiés comme clé `HmacKey` de `lyxal_crypto`. Montrée une seule
/// fois (hexadécimal), puis scellée.
pub fn generate_signing_key() -> NotificationResult<SecretBytes> {
    let mut raw = zeroize::Zeroizing::new(vec![0u8; 32]);
    OsRng
        .try_fill_bytes(raw.as_mut_slice())
        .map_err(|_| NotificationError::Secret("générateur aléatoire indisponible".to_string()))?;
    let bytes = SecretBytes::new(raw.to_vec())?;
    // Contrôle : la valeur est une clé HMAC-SHA256 de la plateforme
    HmacKey::import(SecretBytes::new(bytes.expose_secret().to_vec())?)?;
    Ok(bytes)
}

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

    /// Scelle une valeur d'une adresse de messagerie ou web (adresse complète, clé de
    /// signature) avant son entrée en base (route de l'hôte).
    pub fn seal_endpoint_value(
        &self,
        tenant_key: Option<&str>,
        endpoint_key: &str,
        field: EndpointField,
        value: &SecretBytes,
    ) -> NotificationResult<String> {
        let context = endpoint_context(tenant_key, endpoint_key, field)?;
        Ok(self.crypto.seal(value, &context)?.encode())
    }

    /// Ouvre une valeur d'une adresse (worker, en mémoire le temps de l'appel).
    pub fn open_endpoint_value(
        &self,
        envelope: &str,
        tenant_key: Option<&str>,
        endpoint_key: &str,
        field: EndpointField,
    ) -> NotificationResult<SecretBytes> {
        let context = endpoint_context(tenant_key, endpoint_key, field)?;
        let parsed = EncryptedEnvelope::parse(envelope)?;
        Ok(self.crypto.open(&parsed, &context)?)
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

/// Contexte de scellement d'une valeur d'une adresse de messagerie ou web.
pub fn endpoint_context(
    tenant_key: Option<&str>,
    endpoint_key: &str,
    field: EndpointField,
) -> NotificationResult<SecretContext> {
    Ok(SecretContext::with_tenant(
        tenant_key.unwrap_or(INSTALLATION_TENANT),
        QUEUE_MODULE,
        ENDPOINT_RESOURCE,
        endpoint_key,
        field.as_str(),
    )?)
}

/// Contexte de scellement d'un secret de la file.
pub fn queue_context(
    tenant: Option<&str>,
    idempotency_key: &str,
) -> NotificationResult<SecretContext> {
    Ok(SecretContext::with_tenant(
        tenant.unwrap_or(INSTALLATION_TENANT),
        QUEUE_MODULE,
        QUEUE_RESOURCE,
        idempotency_key,
        SECRET_FIELD,
    )?)
}
