//! Accès avancés (`fn::secrets_grant_*`, `fn::secrets_access_*`, `fn::secrets_policy_*`,
//! `fn::secrets_request_*`) : accès temporaires à un secret ou un dossier, accès d'urgence,
//! protections, demandes d'accès et de changement approuvées. Aucune valeur ne circule ici.

use lyxal_surreal::SurrealValue;

use super::types::{SecretsDatetime, SecretsDuration, SecretsRecordId};

/// Opération permise par un accès temporaire.
#[derive(Debug, Clone, Copy, PartialEq, Eq, SurrealValue)]
#[surreal(untagged, rename_all = "snake_case")]
pub enum AccessAction {
    /// Voir les fiches.
    List,
    /// Lire la valeur.
    ReadValue,
    /// Écrire (fiche et nouvelles versions).
    Write,
    /// Supprimer.
    Delete,
}

/// Accès temporaire, avec son état en cours.
#[derive(Debug, Clone, SurrealValue)]
pub struct Grant {
    /// Identifiant (`secrets_grant:<clé>`).
    pub id: SecretsRecordId,
    /// Organisation.
    pub tenant: SecretsRecordId,
    /// Bénéficiaire : identité.
    pub subject_identity: Option<SecretsRecordId>,
    /// Bénéficiaire : application.
    pub subject_application: Option<SecretsRecordId>,
    /// Chemin d'un secret, ou d'un dossier si `folder`.
    pub path: String,
    /// Dossier : couvre les chemins `<path>/…`.
    pub folder: bool,
    /// Opérations permises.
    pub actions: Vec<AccessAction>,
    /// Début.
    pub starts_at: SecretsDatetime,
    /// Fin.
    pub expires_at: SecretsDatetime,
    /// Motif.
    pub reason: String,
    /// Identité ou application qui l'a accordé (absente : session système).
    pub granted_by: Option<String>,
    /// Demande d'accès approuvée à l'origine de l'accès.
    pub request: Option<SecretsRecordId>,
    /// Accès d'urgence que le bénéficiaire s'est accordé lui-même.
    pub emergency: bool,
    /// Retrait.
    pub revoked_at: Option<SecretsDatetime>,
    /// Identité ou application qui l'a retiré.
    pub revoked_by: Option<String>,
    /// Création.
    pub created_at: SecretsDatetime,
    /// En cours : commencé, ni échu ni retiré.
    pub active: bool,
}

/// Paramètres de `fn::secrets_grant_create` : un seul bénéficiaire, identité **ou** application
/// (constructeurs [`GrantCreateParams::for_identity`] et [`GrantCreateParams::for_application`]).
#[derive(Debug, Clone, SurrealValue)]
pub struct GrantCreateParams {
    /// Organisation (`auth_organization:<clé>`).
    pub tenant: String,
    /// Bénéficiaire : identité membre de l'organisation (`auth_identity:<clé>`).
    pub identity: Option<String>,
    /// Bénéficiaire : application de l'organisation (`auth_application:<clé>`).
    pub application: Option<String>,
    /// Chemin d'un secret, ou d'un dossier si `folder` (sans `/` final).
    pub path: String,
    /// Dossier : couvre les chemins `<path>/…`.
    pub folder: bool,
    /// Opérations permises (au moins une).
    pub actions: Vec<AccessAction>,
    /// Durée (absente : réglage `grant_default_duration` ; bornée par les réglages et la
    /// protection du chemin).
    pub duration: Option<SecretsDuration>,
    /// Motif (512 caractères au plus).
    pub reason: String,
}

impl GrantCreateParams {
    /// Accès d'une identité à un secret (`folder` à faux, durée par défaut).
    pub fn for_identity(
        tenant: impl Into<String>,
        identity: impl Into<String>,
        path: impl Into<String>,
        actions: Vec<AccessAction>,
        reason: impl Into<String>,
    ) -> Self {
        Self {
            tenant: tenant.into(),
            identity: Some(identity.into()),
            application: None,
            path: path.into(),
            folder: false,
            actions,
            duration: None,
            reason: reason.into(),
        }
    }

    /// Accès d'une application à un secret (`folder` à faux, durée par défaut).
    pub fn for_application(
        tenant: impl Into<String>,
        application: impl Into<String>,
        path: impl Into<String>,
        actions: Vec<AccessAction>,
        reason: impl Into<String>,
    ) -> Self {
        Self {
            identity: None,
            application: Some(application.into()),
            ..Self::for_identity(tenant, String::new(), path, actions, reason)
        }
    }
}

/// Paramètres de `fn::secrets_grant_revoke`.
#[derive(Debug, Clone, SurrealValue)]
pub struct GrantRevokeParams {
    /// Accès (`secrets_grant:<clé>`).
    pub grant: String,
}

/// Paramètres de `fn::secrets_grant_list`.
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct GrantListParams {
    /// Organisation (`auth_organization:<clé>`).
    pub tenant: String,
    /// Bénéficiaire : identité.
    pub identity: Option<String>,
    /// Bénéficiaire : application.
    pub application: Option<String>,
    /// Accès en cours seulement (défaut vrai).
    pub active_only: Option<bool>,
    /// Taille de page (100 au plus).
    pub limit: Option<i64>,
    /// Début de page.
    pub start: Option<i64>,
}

/// Résultat de `fn::secrets_grant_list`.
#[derive(Debug, Clone, SurrealValue)]
pub struct GrantList {
    /// Accès de la page, les plus récents d'abord.
    pub items: Vec<Grant>,
    /// Total.
    pub total: i64,
}

/// Paramètres de `fn::secrets_access_emergency` : accès que l'appelant s'accorde lui-même.
#[derive(Debug, Clone, SurrealValue)]
pub struct EmergencyAccessParams {
    /// Organisation (`auth_organization:<clé>`).
    pub tenant: String,
    /// Chemin d'un secret, ou d'un dossier si `folder`.
    pub path: String,
    /// Dossier : couvre les chemins `<path>/…`.
    pub folder: bool,
    /// Opérations permises (au moins une).
    pub actions: Vec<AccessAction>,
    /// Durée (1 heure au plus, défaut 1 heure).
    pub duration: Option<SecretsDuration>,
    /// Motif (obligatoire, 512 caractères au plus).
    pub reason: String,
}

/// Opération d'un secret soumise à une protection, et objet d'une demande de changement.
#[derive(Debug, Clone, Copy, PartialEq, Eq, SurrealValue)]
#[surreal(untagged, rename_all = "lowercase")]
pub enum ChangeOperation {
    /// Mise en service d'une nouvelle valeur (version proposée).
    Value,
    /// Retour à une version antérieure.
    Rollback,
    /// Désactivation du secret.
    Disable,
    /// Suppression du secret.
    Delete,
    /// Destruction d'une version.
    Destroy,
}

/// Protection d'un secret ou d'un dossier.
#[derive(Debug, Clone, SurrealValue)]
pub struct Policy {
    /// Identifiant (`secrets_policy:<clé>`).
    pub id: SecretsRecordId,
    /// Organisation.
    pub tenant: SecretsRecordId,
    /// Chemin d'un secret, ou d'un dossier si `folder`.
    pub path: String,
    /// Dossier : couvre les chemins `<path>/…`.
    pub folder: bool,
    /// Approbations requises (1 à 5).
    pub required_approvals: i64,
    /// Opérations protégées.
    pub operations: Vec<ChangeOperation>,
    /// Durée maximale d'un accès demandé sur ce chemin.
    pub max_grant_duration: Option<SecretsDuration>,
    /// Identité ou application qui a posé la protection.
    pub updated_by: Option<String>,
    /// Dernière modification.
    pub updated_at: SecretsDatetime,
}

/// Paramètres de `fn::secrets_policy_set` : pose ou remplace la protection d'un chemin.
#[derive(Debug, Clone, SurrealValue)]
pub struct PolicySetParams {
    /// Organisation (`auth_organization:<clé>`).
    pub tenant: String,
    /// Chemin d'un secret, ou d'un dossier si `folder`.
    pub path: String,
    /// Dossier : couvre les chemins `<path>/…`.
    pub folder: bool,
    /// Approbations requises (1 à 5, défaut 1).
    pub required_approvals: Option<i64>,
    /// Opérations protégées (absentes : toutes).
    pub operations: Option<Vec<ChangeOperation>>,
    /// Durée maximale d'un accès demandé sur ce chemin (5 minutes à 90 jours).
    pub max_grant_duration: Option<SecretsDuration>,
}

/// Paramètres de `fn::secrets_policy_delete`.
#[derive(Debug, Clone, SurrealValue)]
pub struct PolicyDeleteParams {
    /// Protection (`secrets_policy:<clé>`).
    pub policy: String,
}

/// Résultat de `fn::secrets_policy_delete`.
#[derive(Debug, Clone, SurrealValue)]
pub struct PolicyDeleted {
    /// Protection retirée.
    pub deleted: bool,
    /// Chemin qu'elle protégeait.
    pub path: String,
    /// Dossier.
    pub folder: bool,
}

/// Paramètres de `fn::secrets_policy_list`.
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct PolicyListParams {
    /// Organisation (`auth_organization:<clé>`).
    pub tenant: String,
    /// Chemin dont la protection effective est calculée.
    pub path: Option<String>,
}

/// Protection effective d'un chemin : la plus exigeante de celles qui le couvrent.
#[derive(Debug, Clone, SurrealValue)]
pub struct EffectivePolicy {
    /// Au moins une protection couvre le chemin.
    pub protected: bool,
    /// Approbations requises (0 sans protection).
    pub required_approvals: i64,
    /// Opérations protégées.
    pub operations: Vec<ChangeOperation>,
    /// Durée maximale d'un accès demandé (la plus courte).
    pub max_grant_duration: Option<SecretsDuration>,
}

/// Résultat de `fn::secrets_policy_list`.
#[derive(Debug, Clone, SurrealValue)]
pub struct PolicyList {
    /// Protections de l'organisation, par chemin.
    pub items: Vec<Policy>,
    /// Protection effective du chemin demandé (absente sans chemin).
    pub effective: Option<EffectivePolicy>,
}

/// Type d'une demande.
#[derive(Debug, Clone, Copy, PartialEq, Eq, SurrealValue)]
#[surreal(untagged, rename_all = "lowercase")]
pub enum RequestKind {
    /// Demande d'accès temporaire.
    Access,
    /// Demande de changement d'un secret protégé.
    Change,
}

/// État d'une demande.
#[derive(Debug, Clone, Copy, PartialEq, Eq, SurrealValue)]
#[surreal(untagged, rename_all = "lowercase")]
pub enum RequestState {
    /// En attente des approbations.
    Pending,
    /// Approuvée (accès : l'accès est créé ; changement : à appliquer par son auteur).
    Approved,
    /// Refusée.
    Rejected,
    /// Annulée par son auteur.
    Cancelled,
    /// Échue sans réponse, ou changement approuvé non appliqué à temps.
    Expired,
    /// Changement en cours d'application.
    Applying,
    /// Changement appliqué.
    Applied,
}

impl RequestState {
    /// Vrai si la demande est close.
    pub fn is_closed(self) -> bool {
        matches!(
            self,
            Self::Rejected | Self::Cancelled | Self::Expired | Self::Applied
        )
    }
}

/// Approbation reçue par une demande.
#[derive(Debug, Clone, SurrealValue)]
pub struct Approval {
    /// Identité ou application qui a approuvé.
    pub by: String,
    /// Date.
    pub at: SecretsDatetime,
    /// Commentaire.
    pub comment: Option<String>,
}

/// Demande d'accès ou de changement (jamais de valeur).
#[derive(Debug, Clone, SurrealValue)]
pub struct AccessRequest {
    /// Identifiant (`secrets_request:<clé>`).
    pub id: SecretsRecordId,
    /// Organisation.
    pub tenant: SecretsRecordId,
    /// Type.
    pub kind: RequestKind,
    /// Demandeur : identité.
    pub requested_identity: Option<SecretsRecordId>,
    /// Demandeur : application.
    pub requested_application: Option<SecretsRecordId>,
    /// Chemin demandé (accès) ou chemin du secret (changement).
    pub path: String,
    /// Accès demandé sur un dossier.
    pub folder: bool,
    /// Opérations demandées (accès).
    pub actions: Vec<AccessAction>,
    /// Durée de l'accès demandé.
    pub duration: Option<SecretsDuration>,
    /// Secret à changer (changement).
    pub secret: Option<SecretsRecordId>,
    /// Opération demandée (changement).
    pub operation: Option<ChangeOperation>,
    /// Version visée : proposée (`value`), cible (`rollback`), à détruire (`destroy`).
    pub number: Option<i64>,
    /// Motif.
    pub reason: String,
    /// Approbations requises.
    pub required_approvals: i64,
    /// Approbations reçues.
    pub approvals: Vec<Approval>,
    /// État.
    pub state: RequestState,
    /// Auteur du refus.
    pub decided_by: Option<String>,
    /// Motif du refus ou de l'urgence.
    pub decision_reason: Option<String>,
    /// Accès créé à l'approbation (accès).
    pub grant: Option<SecretsRecordId>,
    /// Changement appliqué en urgence, avant les approbations.
    pub emergency: bool,
    /// Création.
    pub created_at: SecretsDatetime,
    /// Échéance d'une demande sans réponse.
    pub expires_at: SecretsDatetime,
    /// Décision.
    pub decided_at: Option<SecretsDatetime>,
    /// Application du changement.
    pub applied_at: Option<SecretsDatetime>,
}

/// Paramètres de `fn::secrets_request_access` : accès demandé pour soi.
#[derive(Debug, Clone, SurrealValue)]
pub struct RequestAccessParams {
    /// Organisation (`auth_organization:<clé>`), celle de la session.
    pub tenant: String,
    /// Chemin d'un secret, ou d'un dossier si `folder`.
    pub path: String,
    /// Dossier : couvre les chemins `<path>/…`.
    pub folder: bool,
    /// Opérations demandées (au moins une).
    pub actions: Vec<AccessAction>,
    /// Durée (bornée par les réglages et la protection du chemin).
    pub duration: Option<SecretsDuration>,
    /// Motif (512 caractères au plus).
    pub reason: String,
}

/// Paramètres de `fn::secrets_request_change` : changement d'un secret protégé.
#[derive(Debug, Clone, SurrealValue)]
pub struct RequestChangeParams {
    /// Secret (`secrets_secret:<clé>`).
    pub secret: String,
    /// Opération.
    pub operation: ChangeOperation,
    /// Version : proposée par l'appelant (`value`), à remettre en service (`rollback`), à
    /// détruire (`destroy`).
    pub number: Option<i64>,
    /// Motif (512 caractères au plus).
    pub reason: String,
}

/// Paramètres de `fn::secrets_request_approve`.
#[derive(Debug, Clone, SurrealValue)]
pub struct RequestDecisionParams {
    /// Demande (`secrets_request:<clé>`).
    pub request: String,
    /// Commentaire (512 caractères au plus).
    pub comment: Option<String>,
}

/// Paramètres de `fn::secrets_request_reject`.
#[derive(Debug, Clone, SurrealValue)]
pub struct RequestRejectParams {
    /// Demande (`secrets_request:<clé>`).
    pub request: String,
    /// Motif du refus (obligatoire, 512 caractères au plus).
    pub reason: String,
}

/// Paramètres de `fn::secrets_request_cancel` et `fn::secrets_request_get`.
#[derive(Debug, Clone, SurrealValue)]
pub struct RequestRefParams {
    /// Demande (`secrets_request:<clé>`).
    pub request: String,
}

/// Paramètres de `fn::secrets_request_apply`.
#[derive(Debug, Clone, SurrealValue)]
pub struct RequestApplyParams {
    /// Demande de changement (`secrets_request:<clé>`).
    pub request: String,
    /// Urgence : appliquée avant les approbations (droit `secrets.access.emergency`, assurance
    /// la plus haute et récente ; journalisée et publiée).
    pub emergency: bool,
    /// Motif de l'urgence (obligatoire en urgence).
    pub reason: Option<String>,
}

/// Paramètres de `fn::secrets_request_list`.
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct RequestListParams {
    /// Organisation (`auth_organization:<clé>`).
    pub tenant: String,
    /// État.
    pub state: Option<RequestState>,
    /// Type.
    pub kind: Option<RequestKind>,
    /// Ses propres demandes seulement.
    pub mine: bool,
    /// Taille de page (100 au plus).
    pub limit: Option<i64>,
    /// Début de page.
    pub start: Option<i64>,
}

/// Résultat de `fn::secrets_request_list`.
#[derive(Debug, Clone, SurrealValue)]
pub struct RequestList {
    /// Demandes de la page, les plus récentes d'abord.
    pub items: Vec<AccessRequest>,
    /// Total.
    pub total: i64,
}

/// Paramètres de `fn::secrets_access_due` (worker).
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct AccessDueParams {
    /// Demandes expirées au plus (1000 au plus).
    pub limit: Option<i64>,
}

/// Résultat de `fn::secrets_access_due`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, SurrealValue)]
pub struct AccessDueReport {
    /// Demandes expirées.
    pub requests_expired: i64,
    /// Accès finis ou retirés depuis plus de 30 jours, retirés de la table.
    pub grants_removed: i64,
}
