//! Rotation d'un secret en quatre étapes, sans coupure (modèle AWS).
//!
//! ```text
//! started ─► création : le rotateur produit la nouvelle valeur, écrite en version « pending »
//! created ─► installation : le rotateur l'active chez le service extérieur
//! installed ─► test : le rotateur vérifie qu'elle fonctionne
//! tested ─► bascule : « current » passe sur la nouvelle version, l'ancienne devient « previous »
//!           (elle reste valide chez le service jusqu'au cycle suivant) ; puis retrait, au mieux,
//!           de l'avant-dernière valeur (celle qui était « previous » avant la bascule)
//! ```
//!
//! Le coffre-fort ne connaît pas les services extérieurs : un module qui sait changer un
//! identifiant chez un service inscrit un [`SecretRotator`] dans le [`RotatorRegistry`] de l'hôte.
//! Les règles (ordre des étapes, essais, une seule rotation en cours) vivent dans les fonctions
//! `fn::secrets_rotation_*` ; [`RotationRunner`] fait avancer une rotation réservée. Les valeurs
//! circulent en `SecretBytes`, ne sont jamais journalisées ; les erreurs sont des codes.

use async_trait::async_trait;
use lyxal_crypto::SecretBytes;
use lyxal_surreal::ToSql;
use std::fmt;
use std::sync::Arc;
use thiserror::Error;

use crate::error::{SecretsError, SecretsResult, ROTATOR_UNAVAILABLE};
use crate::keys::MasterKeys;
use crate::models::{
    RotationFailParams, RotationRecord, RotationRefParams, RotationState, RotationStep,
    RotationStepParams, SecretGetParams, SecretRecord, Stage,
};
use crate::service::{PutValue, RevealRequest, SecretsService};
use crate::store::SecretsStore;

/// Code : rotation dans un état qui ne permet pas l'étape (numéro `pending` absent).
const ROTATION_STATE_INVALID: &str = "SECRETS_ROTATION_STATE_INVALID";

/// Échec d'un rotateur : un code stable (`SECRETS_*` ou code propre au rotateur), jamais une
/// valeur ni un message du service extérieur qui pourrait en contenir.
#[derive(Debug, Clone, PartialEq, Eq, Error)]
#[error("rotateur en échec : {code}")]
pub struct RotatorError {
    /// Code de l'erreur (128 caractères au plus), enregistré sur la rotation.
    pub code: String,
    /// Vrai si un nouvel essai peut réussir (service extérieur indisponible…).
    pub retryable: bool,
}

impl RotatorError {
    /// Échec passager : un nouvel essai est planifié.
    pub fn retryable(code: impl Into<String>) -> Self {
        Self {
            code: code.into(),
            retryable: true,
        }
    }

    /// Échec définitif : la rotation échoue sans nouvel essai.
    pub fn terminal(code: impl Into<String>) -> Self {
        Self {
            code: code.into(),
            retryable: false,
        }
    }
}

/// Rotateur : sait changer la valeur d'un type de secret chez un service extérieur.
#[async_trait]
pub trait SecretRotator: Send + Sync {
    /// Nom du rotateur : identifiant du module qui l'inscrit. Il est annoncé comme consommateur
    /// à la lecture des valeurs (une fiche qui restreint ses consommateurs doit le lister).
    fn name(&self) -> &str;

    /// Vrai si ce rotateur gère ce secret (par type, chemin…).
    fn handles(&self, secret: &SecretRecord) -> bool;

    /// Produit la nouvelle valeur ; `current` est la valeur en service si elle est lisible
    /// (absente pour un secret sans version ou après une rotation d'urgence).
    async fn create(
        &self,
        secret: &SecretRecord,
        current: Option<&SecretBytes>,
    ) -> Result<SecretBytes, RotatorError>;

    /// Active la nouvelle valeur chez le service extérieur, sans retirer l'ancienne.
    async fn install(&self, secret: &SecretRecord, new: &SecretBytes) -> Result<(), RotatorError>;

    /// Vérifie qu'une valeur fonctionne auprès du service extérieur, sans rien changer.
    async fn test(&self, secret: &SecretRecord, value: &SecretBytes) -> Result<(), RotatorError>;

    /// Invalide une ancienne valeur chez le service (facultatif) : appelé après la bascule pour
    /// l'avant-dernière valeur ; un échec est journalisé sans faire échouer la rotation.
    async fn retire(&self, _secret: &SecretRecord, _old: &SecretBytes) -> Result<(), RotatorError> {
        Ok(())
    }
}

/// Rotateurs inscrits par l'hôte ; pour un secret, le premier qui le gère.
#[derive(Clone, Default)]
pub struct RotatorRegistry {
    rotators: Vec<Arc<dyn SecretRotator>>,
}

impl RotatorRegistry {
    /// Registre vide.
    pub fn new() -> Self {
        Self::default()
    }

    /// Inscrit un rotateur.
    pub fn register(&mut self, rotator: Arc<dyn SecretRotator>) {
        self.rotators.push(rotator);
    }

    /// Premier rotateur inscrit qui gère ce secret.
    pub fn find(&self, secret: &SecretRecord) -> Option<Arc<dyn SecretRotator>> {
        self.rotators
            .iter()
            .find(|rotator| rotator.handles(secret))
            .cloned()
    }

    /// Vrai si aucun rotateur n'est inscrit.
    pub fn is_empty(&self) -> bool {
        self.rotators.is_empty()
    }
}

impl fmt::Debug for RotatorRegistry {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.debug_list()
            .entries(self.rotators.iter().map(|rotator| rotator.name()))
            .finish()
    }
}

/// Échec d'une étape : code et nouvel essai permis.
struct StepFailure {
    code: String,
    retryable: bool,
}

impl From<RotatorError> for StepFailure {
    fn from(error: RotatorError) -> Self {
        Self {
            code: error.code,
            retryable: error.retryable,
        }
    }
}

impl From<SecretsError> for StepFailure {
    fn from(error: SecretsError) -> Self {
        Self {
            code: error.code(),
            retryable: error.is_retryable(),
        }
    }
}

impl From<lyxal_surreal::LyxalSurrealError> for StepFailure {
    fn from(error: lyxal_surreal::LyxalSurrealError) -> Self {
        SecretsError::from(error).into()
    }
}

/// Fait avancer une rotation réservée (`fn::secrets_rotation_claim`) sur la session système :
/// reprise à l'étape atteinte, chaque étape enregistrée, tout échec enregistré par
/// `fn::secrets_rotation_fail` (nouvel essai ou échec définitif).
#[derive(Clone)]
pub struct RotationRunner {
    service: SecretsService,
}

impl RotationRunner {
    /// Exécutant sur la session système de l'hôte, avec le trousseau maître et les rotateurs.
    pub fn new(
        system: SecretsStore,
        master: Option<MasterKeys>,
        rotators: RotatorRegistry,
    ) -> Self {
        Self {
            service: SecretsService::new(system.clone(), system, master).with_rotators(rotators),
        }
    }

    /// Exécutant d'un service déjà construit sur la session système.
    pub(crate) fn from_system(service: SecretsService) -> Self {
        Self { service }
    }

    /// Rotateurs inscrits.
    pub fn rotators(&self) -> &RotatorRegistry {
        self.service.rotators()
    }

    /// Fait avancer une rotation réservée jusqu'à la bascule, à un échec ou à un nouvel essai
    /// planifié ; rend la rotation dans son dernier état. Sans rotateur pour le secret : échec
    /// définitif `SECRETS_ROTATOR_UNAVAILABLE`. `Err` seulement si l'échec n'a pas pu être
    /// enregistré (la réservation expire et la rotation sera reprise).
    pub async fn advance(&self, rotation: RotationRecord) -> SecretsResult<RotationRecord> {
        if rotation.state.is_terminal() {
            return Ok(rotation);
        }
        let id = rotation.id.to_sql();
        let secret = self
            .service
            .store()
            .secret_get(SecretGetParams::by_id(rotation.secret.to_sql()))
            .await?;
        let Some(rotator) = self.service.rotators().find(&secret) else {
            return self.fail(&id, ROTATOR_UNAVAILABLE, false).await;
        };
        match self.steps(rotator.as_ref(), &secret, rotation).await {
            Ok(done) => Ok(done),
            Err(failure) => self.fail(&id, &failure.code, failure.retryable).await,
        }
    }

    /// Échec enregistré : nouvel essai planifié ou échec définitif.
    pub(crate) async fn fail(
        &self,
        rotation: &str,
        code: &str,
        retry: bool,
    ) -> SecretsResult<RotationRecord> {
        tracing::warn!(rotation = %rotation, code = %code, retry, "étape de rotation en échec");
        Ok(self
            .service
            .store()
            .rotation_fail(RotationFailParams {
                rotation: rotation.to_string(),
                code: code.to_string(),
                retry: Some(retry),
            })
            .await?)
    }

    /// Étapes restantes, depuis l'étape atteinte.
    async fn steps(
        &self,
        rotator: &dyn SecretRotator,
        secret: &SecretRecord,
        mut rotation: RotationRecord,
    ) -> Result<RotationRecord, StepFailure> {
        let store = self.service.store();
        let id = rotation.id.to_sql();
        // Avant-dernière valeur après la bascule : celle qui est « previous » avant
        let retired = secret.labels.get("previous").copied();
        let step = |step: RotationStep, pending_number: Option<i64>| RotationStepParams {
            rotation: id.clone(),
            step,
            pending_number,
        };
        loop {
            rotation = match rotation.state {
                RotationState::Started => {
                    let number = self.create(rotator, secret, &rotation).await?;
                    store
                        .rotation_step(step(RotationStep::Created, Some(number)))
                        .await?
                }
                RotationState::Created => {
                    let new = self.read(rotator, secret, pending(&rotation)?).await?;
                    rotator.install(secret, &new).await?;
                    store
                        .rotation_step(step(RotationStep::Installed, None))
                        .await?
                }
                RotationState::Installed => {
                    let new = self.read(rotator, secret, pending(&rotation)?).await?;
                    rotator.test(secret, &new).await?;
                    store
                        .rotation_step(step(RotationStep::Tested, None))
                        .await?
                }
                RotationState::Tested => {
                    let done = store
                        .rotation_finish(RotationRefParams {
                            rotation: id.clone(),
                        })
                        .await?;
                    if let Some(number) = retired {
                        self.retire(rotator, secret, number).await;
                    }
                    return Ok(done);
                }
                RotationState::Succeeded | RotationState::Failed | RotationState::Cancelled => {
                    return Ok(rotation)
                }
            };
        }
    }

    /// Nouvelle valeur écrite en version `pending` ; une version `pending` déjà écrite par un
    /// essai interrompu de cette rotation est reprise (le démarrage retire toute autre).
    async fn create(
        &self,
        rotator: &dyn SecretRotator,
        secret: &SecretRecord,
        rotation: &RotationRecord,
    ) -> Result<i64, StepFailure> {
        if let Some(number) = secret.labels.get("pending") {
            return Ok(*number);
        }
        // Urgence : la valeur en service est coupée (et compromise), elle n'est pas relue
        let current = match (rotation.emergency, secret.labels.get("current")) {
            (false, Some(&number)) => match self.read(rotator, secret, number).await {
                Ok(value) => Some(value),
                Err(error) if error.is_business() => {
                    tracing::info!(secret = %secret.id.to_sql(), code = %error.code(), "valeur en service illisible : nouvelle valeur créée sans elle");
                    None
                }
                Err(error) => return Err(error.into()),
            },
            _ => None,
        };
        let value = rotator.create(secret, current.as_ref()).await?;
        drop(current);
        let added = self
            .service
            .put(PutValue {
                secret: secret.id.to_sql(),
                value,
                expected_version: None,
                stage: Stage::Pending,
            })
            .await?;
        Ok(added.version.number)
    }

    /// Valeur d'une version, lue par le chemin tracé du service, le rotateur annoncé comme
    /// consommateur.
    async fn read(
        &self,
        rotator: &dyn SecretRotator,
        secret: &SecretRecord,
        number: i64,
    ) -> SecretsResult<SecretBytes> {
        Ok(self
            .service
            .reveal_as(
                RevealRequest {
                    secret: secret.id.to_sql(),
                    label: None,
                    number: Some(number),
                },
                Some(rotator.name().to_string()),
            )
            .await?
            .value)
    }

    /// Retrait de l'avant-dernière valeur chez le service, au mieux : un échec est journalisé
    /// (code seulement) sans faire échouer la rotation réussie.
    async fn retire(&self, rotator: &dyn SecretRotator, secret: &SecretRecord, number: i64) {
        let secret_id = secret.id.to_sql();
        match self.read(rotator, secret, number).await {
            Ok(old) => {
                if let Err(error) = rotator.retire(secret, &old).await {
                    tracing::warn!(secret = %secret_id, number, rotator = %rotator.name(), code = %error.code, "ancienne valeur non retirée chez le service");
                }
            }
            Err(error) => {
                tracing::warn!(secret = %secret_id, number, code = %error.code(), "ancienne valeur illisible : non retirée chez le service");
            }
        }
    }
}

/// Numéro de la version `pending` d'une rotation créée.
fn pending(rotation: &RotationRecord) -> Result<i64, StepFailure> {
    rotation.pending_number.ok_or_else(|| StepFailure {
        code: ROTATION_STATE_INVALID.to_string(),
        retryable: false,
    })
}
