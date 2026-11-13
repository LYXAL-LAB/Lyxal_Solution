//! Écriture et lecture des valeurs.
//!
//! Le service travaille sur deux sessions : celle de l'appelant (droits, ticket de lecture,
//! journal) et la session système de l'hôte (clés d'organisation, enveloppe contre un ticket,
//! refus journalisés). Une valeur n'entre dans la base que scellée, pour un numéro de version
//! précis ; elle n'en sort qu'après un ticket tracé au journal, ouverte en `SecretBytes`.

use lyxal_crypto::SecretBytes;
use lyxal_surreal::ToSql;
use serde::de::IgnoredAny;
use std::collections::BTreeMap;

use crate::error::{SecretsError, SecretsResult};
use crate::keys::{MasterKeys, Scope, TenantKeys};
use crate::models::{
    AuditDeniedParams, ReadBeginParams, ReadTicketRef, SecretGetParams, SecretRecord,
    SettingsGetParams, Stage, TenantKeyCreated, TenantRef, VersionAddParams, VersionAdded,
};
use crate::store::SecretsStore;

/// Essais d'une écriture sans numéro attendu, quand une autre écriture a pris le numéro.
const PUT_ATTEMPTS: usize = 3;

/// Valeur à écrire.
#[derive(Debug)]
pub struct PutValue {
    /// Secret (`secrets_secret:<clé>`).
    pub secret: String,
    /// Valeur (effacée de la mémoire à la libération).
    pub value: SecretBytes,
    /// Écriture conditionnelle : dernier numéro de version connu de l'appelant (0 pour un
    /// secret sans version). Différent de la base : `SECRETS_VERSION_CONFLICT`, sans nouvel
    /// essai. Absent : jusqu'à trois essais sur le numéro suivant.
    pub expected_version: Option<i64>,
    /// Étiquette posée sur la nouvelle version.
    pub stage: Stage,
}

/// Valeur demandée : version par numéro, sinon par étiquette (`current` par défaut).
#[derive(Debug, Clone)]
pub struct RevealRequest {
    /// Secret (`secrets_secret:<clé>`).
    pub secret: String,
    /// Étiquette de version.
    pub label: Option<String>,
    /// Numéro de version.
    pub number: Option<i64>,
}

/// Valeur relue ; `Debug` masque la valeur.
#[derive(Debug)]
pub struct RevealedValue {
    /// Numéro de la version lue.
    pub number: i64,
    /// Valeur (effacée de la mémoire à la libération).
    pub value: SecretBytes,
}

/// Service des valeurs : session de l'appelant et session système de l'hôte.
#[derive(Clone)]
pub struct SecretsService {
    caller: SecretsStore,
    keys: TenantKeys,
}

impl SecretsService {
    /// Service pour un appelant (`caller` : sa session), avec la session système de l'hôte
    /// (`system`) et le trousseau maître du coffre-fort (absent : aucune valeur n'est écrite ni
    /// lue, `SECRETS_CRYPTO_UNAVAILABLE`).
    pub fn new(caller: SecretsStore, system: SecretsStore, master: Option<MasterKeys>) -> Self {
        Self {
            caller,
            keys: TenantKeys::new(system, master),
        }
    }

    /// Store de la session de l'appelant (fiches, versions, journal).
    pub fn store(&self) -> &SecretsStore {
        &self.caller
    }

    /// Écrit une valeur : nouvelle version scellée par la clé de l'organisation (créée à la
    /// première valeur), avec les droits de l'appelant.
    pub async fn put(&self, request: PutValue) -> SecretsResult<VersionAdded> {
        self.keys.master()?;
        let mut secret = self
            .caller
            .secret_get(SecretGetParams::by_id(request.secret.clone()))
            .await?;
        let scope = Scope::from_record(secret.tenant.as_ref())?;
        let max = self
            .keys
            .system()
            .settings_get(SettingsGetParams {
                tenant: scope.tenant().map(str::to_string),
            })
            .await?
            .effective
            .max_value_bytes;
        let size = request.value.len();
        if i64::try_from(size).map_or(true, |size| size > max) {
            return Err(SecretsError::ValueTooLarge { size, max });
        }
        let keys = json_keys(&request.value);
        let ring = self.keys.active_ring(&scope).await?;

        let attempts = if request.expected_version.is_some() {
            1
        } else {
            PUT_ATTEMPTS
        };
        let mut attempt = 0;
        loop {
            attempt += 1;
            let latest = request.expected_version.unwrap_or(secret.latest_version);
            let number = latest + 1;
            let envelope = ring.seal(&request.value, &scope.version_context(&secret.id, number)?)?;
            let added = self
                .caller
                .version_add(VersionAddParams {
                    secret: secret.id.to_sql(),
                    number,
                    envelope: envelope.encode(),
                    key_id: ring.active_id().as_str().to_string(),
                    keys: keys.clone(),
                    stage: request.stage,
                })
                .await;
            match added {
                Err(error) if attempt < attempts => {
                    let error = SecretsError::from(error);
                    if !error.is_code("SECRETS_VERSION_CONFLICT") {
                        return Err(error);
                    }
                    secret = self.reload(&secret).await?;
                }
                other => return Ok(other?),
            }
        }
    }

    /// Lit une valeur : ticket tracé (session de l'appelant), enveloppe (session système),
    /// ouverture par la clé de l'organisation. Un refus est journalisé au nom de l'appelant (R6).
    pub async fn reveal(&self, request: RevealRequest) -> SecretsResult<RevealedValue> {
        self.reveal_as(request, None).await
    }

    /// Lecture, avec le consommateur annoncé (module de l'hôte, session système).
    pub(crate) async fn reveal_as(
        &self,
        request: RevealRequest,
        consumer: Option<String>,
    ) -> SecretsResult<RevealedValue> {
        let denied = |code: String| AuditDeniedParams {
            secret: request.secret.clone(),
            code,
            session_kind: "system".to_string(),
            actor: None,
            application: None,
            session: None,
            consumer: consumer.clone(),
            version: request.number,
        };
        self.keys.master()?;
        let ticket = match self
            .caller
            .read_begin(ReadBeginParams {
                secret: request.secret.clone(),
                label: request.label.clone(),
                number: request.number,
                consumer: consumer.clone(),
            })
            .await
        {
            Ok(ticket) => ticket,
            Err(error) => {
                let error = SecretsError::from(error);
                // Refus de la base : journalisé ; un secret absent ou une demande invalide n'a
                // rien à quoi rattacher l'entrée
                if error.is_business()
                    && !error.is_code("SECRETS_SECRET_NOT_FOUND")
                    && !error.is_code("SECRETS_INVALID_PARAMETERS")
                {
                    self.journal_denied(denied(error.code())).await;
                }
                return Err(error);
            }
        };
        let opened = async {
            let sealed = self
                .keys
                .system()
                .read_envelope(ReadTicketRef {
                    ticket: ticket.ticket.to_sql(),
                })
                .await?;
            let context = &sealed.context;
            let scope = Scope::from_context(&context.tenant)?;
            let expected = scope.version_context(&ticket.secret, sealed.number)?;
            let announced = lyxal_crypto::SecretContext::with_tenant(
                &context.tenant,
                &context.module,
                &context.resource,
                &context.record_id,
                &context.field,
            )?;
            if expected != announced || sealed.number != ticket.number {
                return Err(SecretsError::ValueCorrupted);
            }
            let ring = self.keys.ring(&scope).await?.ok_or_else(|| {
                SecretsError::TenantKeyUnavailable("aucune clé pour cette portée".to_string())
            })?;
            let value = ring.open(&sealed.envelope, &expected)?;
            Ok(RevealedValue {
                number: sealed.number,
                value,
            })
        }
        .await;
        // Enveloppe ou clé illisible : journalisé (la panne de la base, elle, ne l'est pas)
        if let Err(error) = &opened {
            if !matches!(error, SecretsError::Surreal(_)) {
                let mut params = denied(error.code());
                params.version = Some(ticket.number);
                self.journal_denied(params).await;
            }
        }
        opened
    }

    /// Nouvelle clé active pour une organisation (`None` : l'installation), à la demande d'une
    /// personne qui détient le droit de réglage ; le worker rescelle ensuite les versions (R3).
    pub async fn rotate_tenant_key(&self, tenant: Option<String>) -> SecretsResult<TenantKeyCreated> {
        self.keys.master()?;
        let allowed = self
            .caller
            .tenant_key_rotate_allowed(TenantRef {
                tenant: tenant.clone(),
            })
            .await?;
        let scope = Scope::from_text(tenant.as_deref())?;
        self.keys
            .rotate(&scope, allowed.requested_by.as_ref().map(ToSql::to_sql))
            .await
    }

    /// Fiche relue après une écriture concurrente.
    async fn reload(&self, secret: &SecretRecord) -> SecretsResult<SecretRecord> {
        Ok(self
            .caller
            .secret_get(SecretGetParams::by_id(secret.id.to_sql()))
            .await?)
    }

    /// Journalise une lecture refusée au nom de l'appelant (session système). Un échec de
    /// journalisation est signalé, sans masquer le refus rendu à l'appelant.
    async fn journal_denied(&self, mut params: AuditDeniedParams) {
        match self.caller.caller_context().await {
            Ok(context) if !context.system => {
                params.session_kind = context.kind.unwrap_or_else(|| "interactive".to_string());
                params.actor = context.identity.as_ref().map(ToSql::to_sql);
                params.application = context.application.as_ref().map(ToSql::to_sql);
                params.session = context.session.as_ref().map(ToSql::to_sql);
            }
            Ok(_) => {}
            Err(error) => {
                tracing::warn!(error = %error, "appelant d'une lecture refusée inconnu");
            }
        }
        let code = params.code.clone();
        if let Err(error) = self.keys.system().audit_denied(params).await {
            let error = SecretsError::from(error);
            tracing::warn!(code = %code, journal = %error.code(), error = %error, "lecture refusée non journalisée");
        }
    }
}

/// Noms des clés d'une valeur JSON objet (R4) ; les valeurs ne sont jamais copiées. `None` si
/// la valeur n'est pas un objet JSON.
fn json_keys(value: &SecretBytes) -> Option<Vec<String>> {
    serde_json::from_slice::<BTreeMap<String, IgnoredAny>>(value.expose_secret())
        .ok()
        .map(|object| object.into_keys().collect())
}
