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
    AccessRequest, AuditDeniedParams, ChangeOperation, KeyPurpose, ReadBeginParams, ReadTicketRef,
    RequestChangeParams, RotationBeginParams, RotationCheckParams, RotationCheckResult,
    RotationClaimParams, RotationGetParams, RotationRecord, SecretGetParams, SecretRecord,
    SettingsGetParams, Stage, TenantKeyCreated, TenantRef, VersionAddParams, VersionAdded,
};
use crate::rotation::{RotationOutcome, RotationRunner, RotatorRegistry};
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

/// Nouvelle valeur proposée pour un secret protégé : demande de changement à faire approuver.
#[derive(Debug)]
pub struct ProposeRequest {
    /// Secret (`secrets_secret:<clé>`).
    pub secret: String,
    /// Valeur (effacée de la mémoire à la libération).
    pub value: SecretBytes,
    /// Motif de la demande (512 caractères au plus).
    pub reason: String,
}

/// Valeur proposée : version écrite (étiquette `proposed`) et demande de changement ouverte.
#[derive(Debug, Clone)]
pub struct ProposedChange {
    /// Version proposée, pas encore en service.
    pub version: VersionAdded,
    /// Demande de changement (`value`) en attente des approbations.
    pub request: AccessRequest,
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

/// Rotation demandée maintenant.
#[derive(Debug, Clone)]
pub struct RotateRequest {
    /// Secret (`secrets_secret:<clé>`).
    pub secret: String,
    /// Urgence (fuite soupçonnée) : la version en service est désactivée aussitôt.
    pub emergency: bool,
    /// Motif (512 caractères au plus).
    pub reason: Option<String>,
}

/// Service des valeurs : session de l'appelant et session système de l'hôte.
#[derive(Clone)]
pub struct SecretsService {
    pub(crate) caller: SecretsStore,
    pub(crate) keys: TenantKeys,
    rotators: RotatorRegistry,
}

impl SecretsService {
    /// Service pour un appelant (`caller` : sa session), avec la session système de l'hôte
    /// (`system`) et le trousseau maître du coffre-fort (absent : aucune valeur n'est écrite ni
    /// lue, `SECRETS_CRYPTO_UNAVAILABLE`).
    pub fn new(caller: SecretsStore, system: SecretsStore, master: Option<MasterKeys>) -> Self {
        Self {
            caller,
            keys: TenantKeys::new(system, master, KeyPurpose::Secrets),
            rotators: RotatorRegistry::default(),
        }
    }

    /// Service qui fait tourner les secrets par ces rotateurs (aucun par défaut).
    pub fn with_rotators(mut self, rotators: RotatorRegistry) -> Self {
        self.rotators = rotators;
        self
    }

    /// Rotateurs inscrits.
    pub fn rotators(&self) -> &RotatorRegistry {
        &self.rotators
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
        let mut ring = self.keys.active_ring(&scope).await?;

        // Conflit de version : rejoué seulement sans numéro attendu (écriture conditionnelle).
        // Clé devenue inactive entre-temps (rotation) : trousseau relu et valeur rescellée.
        let mut attempt = 0;
        loop {
            attempt += 1;
            let latest = request.expected_version.unwrap_or(secret.latest_version);
            let number = latest + 1;
            let envelope =
                ring.seal(&request.value, &scope.version_context(&secret.id, number)?)?;
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
                Err(error) if attempt < PUT_ATTEMPTS => {
                    let error = SecretsError::from(error);
                    if error.is_code("SECRETS_TENANT_KEY_CONFLICT") {
                        ring = self.keys.active_ring(&scope).await?;
                    } else if request.expected_version.is_none()
                        && error.is_conflict("SECRETS_VERSION_CONFLICT")
                    {
                        secret = self.reload(&secret).await?;
                    } else {
                        return Err(error);
                    }
                }
                other => return Ok(other?),
            }
        }
    }

    /// Propose une nouvelle valeur pour un secret protégé : la valeur est scellée et écrite comme
    /// par [`SecretsService::put`] (même chemin, mêmes nouveaux essais en cas de conflit), en
    /// version étiquetée `proposed`, sans mise en service ; puis une demande de changement
    /// (`value`, pour ce numéro) est ouverte avec les droits de l'appelant. Une fois la demande
    /// approuvée, son auteur l'applique (`SecretsStore::request_apply`) et la version passe en
    /// service.
    ///
    /// Si la demande est refusée par la base (`SECRETS_CHANGE_IN_PROGRESS` : une demande est
    /// déjà ouverte sur le secret ; `SECRETS_POLICY_NOT_FOUND` : la valeur du secret n'est pas
    /// protégée…), l'erreur est rendue, mais **la version proposée reste écrite**, sans
    /// étiquette `current` : elle n'est jamais servie par défaut (seulement par son numéro ou
    /// l'étiquette `proposed`, avec le droit de lecture).
    pub async fn propose(&self, request: ProposeRequest) -> SecretsResult<ProposedChange> {
        let version = self
            .put(PutValue {
                secret: request.secret,
                value: request.value,
                expected_version: None,
                stage: Stage::Proposed,
            })
            .await?;
        let request = self
            .caller
            .request_change(RequestChangeParams {
                secret: version.version.secret.to_sql(),
                operation: ChangeOperation::Value,
                number: Some(version.version.number),
                reason: request.reason,
            })
            .await?;
        Ok(ProposedChange { version, request })
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
    /// personne qui détient le droit de réglage ; la maintenance rescelle ensuite les versions (R3).
    pub async fn rotate_tenant_key(
        &self,
        tenant: Option<String>,
    ) -> SecretsResult<TenantKeyCreated> {
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

    /// Rotation demandée maintenant, avec les droits de l'appelant (écriture ; urgence : double
    /// facteur récent pour une personne). Avec un rotateur pour le secret, la rotation est
    /// réservée (son jeton sert à chaque étape) et déroulée aussitôt (rendue réussie, en échec,
    /// ou en attente d'un nouvel essai que la maintenance reprendra). Sans rotateur : `SECRETS_ROTATOR_UNAVAILABLE` et rien ne
    /// démarre, sauf en urgence où la version en service est coupée et la rotation échoue
    /// aussitôt (`SECRETS_ROTATOR_UNAVAILABLE`) : une personne écrira la nouvelle valeur.
    pub async fn rotate_now(&self, request: RotateRequest) -> SecretsResult<RotationRecord> {
        let secret = self
            .caller
            .secret_get(SecretGetParams::by_id(request.secret.clone()))
            .await?;
        let rotator = self.rotators.find(&secret);
        if rotator.is_none() && !request.emergency {
            return Err(SecretsError::RotatorUnavailable);
        }
        let rotation = self
            .caller
            .rotation_begin(RotationBeginParams {
                secret: secret.id.to_sql(),
                emergency: Some(request.emergency),
                reason: request.reason,
            })
            .await?;
        // Réservée pour cet appel ; sans rotateur, l'avancée l'enregistre en échec définitif
        let system = self.keys.system();
        let claimed = system
            .rotation_claim(RotationClaimParams {
                rotation: Some(rotation.id.to_sql()),
                ..RotationClaimParams::default()
            })
            .await?;
        let Some(claimed) = claimed.items.into_iter().next() else {
            // Déjà réservée par la maintenance : elle la déroule
            return Ok(rotation);
        };
        match self.runner().advance(claimed).await? {
            RotationOutcome::Advanced(done) => Ok(*done),
            // Reprise par la maintenance entre-temps : son état actuel
            RotationOutcome::LeaseLost => Ok(system
                .rotation_get(RotationGetParams {
                    secret: secret.id.to_sql(),
                    limit: None,
                })
                .await?
                .items
                .into_iter()
                .find(|item| item.id == rotation.id)
                .unwrap_or(rotation)),
        }
    }

    /// Essai sans bascule : le rotateur teste la valeur en service auprès du service extérieur,
    /// sans rien changer ; le résultat est enregistré sur la fiche, journalisé et publié.
    ///
    /// Outil de la maintenance : tout le chemin passe par la **session système** du service (fiche,
    /// lecture tracée de la valeur, le rotateur annoncé comme consommateur, puis
    /// `fn::secrets_rotation_check_record`), quelle que soit la session de l'appelant. Il n'est
    /// exposé par aucune route : l'hôte ne l'appelle que pour la maintenance. Sans rotateur :
    /// `SECRETS_ROTATOR_UNAVAILABLE`, sans lecture.
    pub async fn check_rotation(&self, secret: &str) -> SecretsResult<RotationCheckResult> {
        let system = self.as_system();
        let record = system
            .caller
            .secret_get(SecretGetParams::by_id(secret.to_string()))
            .await?;
        let rotator = system
            .rotators
            .find(&record)
            .ok_or(SecretsError::RotatorUnavailable)?;
        let current = system
            .reveal_as(
                RevealRequest {
                    secret: record.id.to_sql(),
                    label: None,
                    number: None,
                },
                Some(rotator.name().to_string()),
            )
            .await?;
        let tested = rotator.test(&record, &current.value).await;
        drop(current);
        Ok(system
            .caller
            .rotation_check_record(RotationCheckParams {
                secret: record.id.to_sql(),
                ok: tested.is_ok(),
                code: tested.err().map(|error| error.code),
            })
            .await?)
    }

    /// Exécutant des rotations sur la session système, avec les mêmes clés et rotateurs.
    pub(crate) fn runner(&self) -> RotationRunner {
        RotationRunner::from_system(self.as_system())
    }

    /// Même service, sur la session système de l'hôte.
    fn as_system(&self) -> Self {
        Self {
            caller: self.keys.system().clone(),
            keys: self.keys.clone(),
            rotators: self.rotators.clone(),
        }
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

/// Noms des clés gardés au plus (`fn::secrets_version_add` refuse au-delà).
const MAX_JSON_KEYS: usize = 200;
/// Longueur d'un nom de clé gardé, en caractères (1 à 128).
const MAX_JSON_KEY_CHARS: usize = 128;

/// Noms des clés d'une valeur JSON objet (R4) ; les valeurs ne sont jamais copiées. `None` si
/// la valeur n'est pas un objet JSON, ou si les noms sortent des bornes de la base (200 clés
/// au plus, chacune de 1 à 128 caractères) : la valeur est alors écrite sans noms de clés,
/// jamais refusée pour eux.
fn json_keys(value: &SecretBytes) -> Option<Vec<String>> {
    let object =
        serde_json::from_slice::<BTreeMap<String, IgnoredAny>>(value.expose_secret()).ok()?;
    let in_bounds = object.len() <= MAX_JSON_KEYS
        && object.keys().all(|key| {
            let chars = key.chars().count();
            (1..=MAX_JSON_KEY_CHARS).contains(&chars)
        });
    in_bounds.then(|| object.into_keys().collect())
}

#[cfg(test)]
#[allow(clippy::expect_used)]
mod tests {
    use super::json_keys;
    use lyxal_crypto::SecretBytes;

    fn keys(json: &str) -> Option<Vec<String>> {
        json_keys(&SecretBytes::new(json.as_bytes().to_vec()).expect("valeur"))
    }

    #[test]
    fn json_key_names_are_kept_within_bounds_only() {
        assert_eq!(
            keys(r#"{"user":"u","password":"p"}"#),
            Some(vec!["password".to_string(), "user".to_string()])
        );
        assert_eq!(keys("pas du JSON"), None);
        assert_eq!(keys(r#"{"":"vide"}"#), None);
        assert_eq!(keys(&format!(r#"{{"{}":1}}"#, "k".repeat(129))), None);
        assert!(keys(&format!(r#"{{"{}":1}}"#, "é".repeat(128))).is_some());
        let many = |n: usize| {
            let fields: Vec<String> = (0..n).map(|i| format!(r#""k{i}":{i}"#)).collect();
            format!("{{{}}}", fields.join(","))
        };
        assert_eq!(keys(&many(200)).map(|names| names.len()), Some(200));
        assert_eq!(keys(&many(201)), None);
    }
}
