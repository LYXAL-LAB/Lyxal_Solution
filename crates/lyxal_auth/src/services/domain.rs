//! Vérification des domaines d'une organisation par enregistrement DNS TXT.
//!
//! Le jeton de défi (32 octets de `OsRng`, Base64 URL) est remis à l'administrateur, qui le
//! publie en TXT sur `_lyxal-challenge.<domaine>` ; la base n'en connaît que l'empreinte BLAKE3.
//! À la vérification, les enregistrements TXT sont lus en Rust et seules leurs empreintes sont
//! transmises à `fn::auth_organization_domain_verify`.

use async_trait::async_trait;
use lyxal_crypto::{blake3_hex, SecretString};

use crate::error::{AuthError, AuthResult};
use crate::models::{
    DomainAddParams, DomainVerifyParams, OrganizationDomain, OrganizationDomainCreated,
};
use crate::services::invitation::generate_token;
use crate::store::AuthStore;

/// Préfixe du nom de l'enregistrement TXT de défi.
pub const CHALLENGE_PREFIX: &str = "_lyxal-challenge.";
/// Nombre maximal d'enregistrements TXT pris en compte.
const MAX_TXT_RECORDS: usize = 32;

/// Lecture des enregistrements TXT d'un nom (implémentation réelle : `HickoryTxtLookup`).
#[async_trait]
pub trait TxtLookup: Send + Sync {
    /// Valeurs TXT du nom ; aucun enregistrement = liste vide (pas une erreur).
    async fn txt(&self, name: &str) -> AuthResult<Vec<String>>;
}

/// Lecture TXT par `hickory-resolver` avec la configuration DNS du système.
pub struct HickoryTxtLookup {
    resolver: hickory_resolver::TokioResolver,
}

impl HickoryTxtLookup {
    /// Résolveur configuré depuis le système (`/etc/resolv.conf`).
    pub fn from_system() -> AuthResult<Self> {
        let resolver = hickory_resolver::Resolver::builder_tokio()
            .map_err(|e| AuthError::Dns(e.to_string()))?
            .build();
        Ok(Self { resolver })
    }
}

#[async_trait]
impl TxtLookup for HickoryTxtLookup {
    async fn txt(&self, name: &str) -> AuthResult<Vec<String>> {
        match self.resolver.txt_lookup(name).await {
            Ok(lookup) => Ok(lookup
                .iter()
                .take(MAX_TXT_RECORDS)
                .map(|record| {
                    record
                        .txt_data()
                        .iter()
                        .map(|part| String::from_utf8_lossy(part).into_owned())
                        .collect::<String>()
                })
                .collect()),
            Err(error) if error.is_no_records_found() => Ok(Vec::new()),
            Err(error) => Err(AuthError::Dns(error.to_string())),
        }
    }
}

/// Domaine déclaré, avec le jeton à publier.
pub struct DomainChallenge {
    /// Domaine enregistré.
    pub domain: OrganizationDomainCreated,
    /// Valeur TXT à publier sur `domain.txt_record` (publique une fois en DNS).
    pub txt_value: SecretString,
}

impl std::fmt::Debug for DomainChallenge {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("DomainChallenge")
            .field("domain", &self.domain)
            .field("txt_value", &"[REDACTED]")
            .finish()
    }
}

/// Service de vérification des domaines.
pub struct DomainVerifier<L: TxtLookup> {
    store: AuthStore,
    lookup: L,
}

impl<L: TxtLookup> DomainVerifier<L> {
    /// Service sur la session de l'appelant et un lecteur TXT.
    pub fn new(store: AuthStore, lookup: L) -> Self {
        Self { store, lookup }
    }

    /// Déclare un domaine : jeton de défi, empreinte, `fn::auth_organization_domain_add`.
    pub async fn declare(&self, organization: &str, domain: &str) -> AuthResult<DomainChallenge> {
        let token = generate_token()?;
        let created = self
            .store
            .domain_add(DomainAddParams {
                organization: organization.to_string(),
                domain: domain.to_string(),
                challenge_hash: blake3_hex(token.expose_secret().as_bytes()),
            })
            .await?;
        Ok(DomainChallenge {
            domain: created,
            txt_value: token,
        })
    }

    /// Vérifie un domaine (`domain_id` : texte `auth_organization_domain:<clé>`, `domain` : son
    /// nom) : lecture des TXT de `_lyxal-challenge.<domaine>`, empreintes transmises à la base.
    pub async fn verify(&self, domain_id: &str, domain: &str) -> AuthResult<OrganizationDomain> {
        let records = self
            .lookup
            .txt(&format!("{CHALLENGE_PREFIX}{domain}"))
            .await?;
        let observed_hashes = records
            .iter()
            .map(|value| blake3_hex(value.trim().as_bytes()))
            .collect();
        Ok(self
            .store
            .domain_verify(DomainVerifyParams {
                domain: domain_id.to_string(),
                observed_hashes,
            })
            .await?)
    }
}
