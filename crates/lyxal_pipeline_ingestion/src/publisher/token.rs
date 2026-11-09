//! Jeton de session du compte de service de synchronisation du catalogue.
//!
//! Le catalogue n'accepte un article maître que d'une session `lyxal_auth` détenant la
//! permission `catalogue.master.write` (rôle `catalogue_sync`). Le compte de service
//! `lyxal-catalogue-sync` est créé par les seeds de ce module ; l'hôte ouvre ses sessions par la
//! session système, sans secret, et fournit le jeton d'accès par [`CatalogueTokenIssuer`].

use async_trait::async_trait;
use lyxal_crypto::SecretString;

use crate::error::IngestionResult;

/// Identifiant client (`client_id`) du compte de service de synchronisation du catalogue.
pub const CATALOGUE_SYNC_CLIENT_ID: &str = "lyxal-catalogue-sync";

/// Fournit un jeton d'accès frais du compte de service à chaque publication.
#[async_trait]
pub trait CatalogueTokenIssuer: Send + Sync {
    /// Jeton d'accès d'une session de service, valable pendant une durée courte.
    async fn issue(&self) -> IngestionResult<SecretString>;
}
