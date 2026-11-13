//! Interface des autres modules de l'hôte : un module lit et écrit les valeurs de ses secrets
//! par la session système, en s'annonçant comme consommateur (la fiche peut restreindre ses
//! consommateurs). Chaque lecture passe par un ticket tracé au journal.

use lyxal_crypto::SecretBytes;
use lyxal_surreal::ToSql;
use std::fmt;

use crate::error::SecretsResult;
use crate::keys::MasterKeys;
use crate::models::{SecretGetParams, Stage, VersionAdded};
use crate::service::{PutValue, RevealRequest, RevealedValue, SecretsService};
use crate::store::SecretsStore;

/// Lecture d'une valeur par un module.
#[derive(Debug, Clone)]
pub struct ClientRead {
    /// Organisation (`auth_organization:<clé>`), absente pour l'installation.
    pub tenant: Option<String>,
    /// Chemin du secret.
    pub path: String,
    /// Étiquette de version (`current` par défaut).
    pub label: Option<String>,
}

/// Écriture d'une valeur par un module.
#[derive(Debug)]
pub struct ClientWrite {
    /// Organisation (`auth_organization:<clé>`), absente pour l'installation.
    pub tenant: Option<String>,
    /// Chemin du secret (la fiche doit exister).
    pub path: String,
    /// Valeur (effacée de la mémoire à la libération).
    pub value: SecretBytes,
    /// Étiquette posée sur la nouvelle version.
    pub stage: Stage,
}

/// Client du coffre-fort pour un module de l'hôte (session système).
#[derive(Clone)]
pub struct SecretsClient {
    service: SecretsService,
    consumer: String,
}

impl SecretsClient {
    /// Client du module `consumer` (son identifiant, ex. `lyxal_notification`), sur la session
    /// système de l'hôte.
    pub fn new(system: SecretsStore, master: Option<MasterKeys>, consumer: impl Into<String>) -> Self {
        Self {
            service: SecretsService::new(system.clone(), system, master),
            consumer: consumer.into(),
        }
    }

    /// Module annoncé comme consommateur.
    pub fn consumer(&self) -> &str {
        &self.consumer
    }

    /// Valeur d'un secret, par organisation et chemin.
    pub async fn read(&self, request: ClientRead) -> SecretsResult<RevealedValue> {
        let secret = self
            .service
            .store()
            .secret_get(SecretGetParams::by_path(request.tenant, request.path))
            .await?;
        self.service
            .reveal_as(
                RevealRequest {
                    secret: secret.id.to_sql(),
                    label: request.label,
                    number: None,
                },
                Some(self.consumer.clone()),
            )
            .await
    }

    /// Nouvelle version d'un secret existant, par organisation et chemin.
    pub async fn write(&self, request: ClientWrite) -> SecretsResult<VersionAdded> {
        let secret = self
            .service
            .store()
            .secret_get(SecretGetParams::by_path(request.tenant, request.path))
            .await?;
        self.service
            .put(PutValue {
                secret: secret.id.to_sql(),
                value: request.value,
                expected_version: None,
                stage: request.stage,
            })
            .await
    }
}

impl fmt::Debug for SecretsClient {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.debug_struct("SecretsClient")
            .field("consumer", &self.consumer)
            .finish()
    }
}
