//! Fonctions du worker (`lyxal_scheduler`, lot 1b) : essais des comptes, passes de
//! réconciliation d'une zone (réservation, lecture, plan, écriture, fin), vérification de la
//! publication, purge et sonde de santé.

use lyxal_surreal::SurrealValue;

use super::account::{AccountState, DiscoveredZone, ScalewaySettings};
use super::types::{ChangeAction, InfraDatetime, InfraRecordId, RecordState, RecordType};
use super::zone::{PlannedChange, PlannedConflict, ZoneMode, ZoneState};

/// Paramètres des listes du worker (`fn::infra_account_due`, `fn::infra_zone_due`,
/// `fn::infra_records_to_verify`, `fn::infra_purge`).
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct WorkerBatchParams {
    /// Taille du lot.
    pub limit: Option<i64>,
    /// Langue des messages d'erreur.
    pub language: Option<String>,
}

/// Compte dont un essai est demandé.
#[derive(Debug, Clone, SurrealValue)]
pub struct AccountDue {
    /// Compte.
    pub account: InfraRecordId,
    /// Fournisseur.
    pub provider: String,
    /// Chemin du secret dans `lyxal_secrets` (lu par la session système).
    pub credentials_path: String,
    /// Réglages du fournisseur.
    pub settings: ScalewaySettings,
}

/// Résultat de `fn::infra_account_due`.
#[derive(Debug, Clone, SurrealValue)]
pub struct AccountDueList {
    /// Comptes à essayer, le plus ancien d'abord.
    pub items: Vec<AccountDue>,
}

/// Paramètres de `fn::infra_account_test_result`.
#[derive(Debug, Clone, SurrealValue)]
pub struct AccountTestResultParams {
    /// Compte (`infra_account:<clé>`).
    pub account: String,
    /// Clé acceptée et zones lues.
    pub ok: bool,
    /// Code `INFRA_PROVIDER_*` ou `INFRA_CREDENTIALS_UNAVAILABLE` si `ok` est faux.
    pub code: Option<String>,
    /// Zones visibles (1 000 au plus).
    pub zones: Vec<DiscoveredZone>,
    /// Langue des messages d'erreur.
    pub language: Option<String>,
}

/// Résultat de `fn::infra_account_test_result`.
#[derive(Debug, Clone, SurrealValue)]
pub struct AccountTestOutcome {
    /// Compte.
    pub account: InfraRecordId,
    /// Nouvel état.
    pub state: AccountState,
    /// Zones visibles enregistrées.
    pub zones: i64,
}

/// Zone à réconcilier.
#[derive(Debug, Clone, SurrealValue)]
pub struct ZoneDue {
    /// Zone.
    pub zone: InfraRecordId,
    /// Compte d'hébergeur.
    pub account: InfraRecordId,
}

/// Résultat de `fn::infra_zone_due`.
#[derive(Debug, Clone, SurrealValue)]
pub struct ZoneDueList {
    /// Zones échues.
    pub items: Vec<ZoneDue>,
}

/// Paramètres de `fn::infra_zone_claim`.
#[derive(Debug, Clone, SurrealValue)]
pub struct ZoneClaimParams {
    /// Zone (`infra_zone:<clé>`).
    pub zone: String,
    /// Durée de la réservation (60 à 900 s, 300 par défaut).
    pub ttl_seconds: Option<i64>,
    /// Langue des messages d'erreur.
    pub language: Option<String>,
}

/// Compte d'une zone réservée : de quoi appeler l'hébergeur.
#[derive(Debug, Clone, SurrealValue)]
pub struct ClaimedAccount {
    /// Compte.
    pub account: InfraRecordId,
    /// Fournisseur.
    pub provider: String,
    /// Chemin du secret dans `lyxal_secrets`.
    pub credentials_path: String,
    /// Réglages du fournisseur.
    pub settings: ScalewaySettings,
    /// État du compte.
    pub state: AccountState,
}

/// Résultat de `fn::infra_zone_claim` : réservation d'une zone pour une passe.
#[derive(Debug, Clone, SurrealValue)]
pub struct ZoneClaim {
    /// Zone.
    pub zone: InfraRecordId,
    /// Jeton de la réservation (UUID v7), exigé par toute écriture de la passe.
    pub claim: String,
    /// Fin de la réservation.
    pub locked_until: InfraDatetime,
    /// Nom de la zone.
    pub name: String,
    /// Nom chez le fournisseur.
    pub provider_ref: String,
    /// Mode.
    pub mode: ZoneMode,
    /// Serveurs de noms observés.
    pub nameservers: Vec<String>,
    /// Compte d'hébergeur.
    pub account: ClaimedAccount,
}

/// Paramètres de `fn::infra_zone_renew`.
#[derive(Debug, Clone, SurrealValue)]
pub struct ZoneRenewParams {
    /// Zone (`infra_zone:<clé>`).
    pub zone: String,
    /// Jeton de la réservation.
    pub claim: String,
    /// Nouvelle durée (60 à 900 s).
    pub ttl_seconds: Option<i64>,
    /// Langue des messages d'erreur.
    pub language: Option<String>,
}

/// Résultat de `fn::infra_zone_renew`.
#[derive(Debug, Clone, SurrealValue)]
pub struct ZoneRenewed {
    /// Zone.
    pub zone: InfraRecordId,
    /// Nouvelle fin de la réservation.
    pub locked_until: InfraDatetime,
}

/// Ligne lue chez le fournisseur, en forme canonique (adaptateur du lot 1b).
#[derive(Debug, Clone, PartialEq, Eq, SurrealValue)]
pub struct ObservedRecord {
    /// Identifiant chez le fournisseur.
    pub provider_id: String,
    /// Nom complet (minuscules, sans point final).
    pub fqdn: String,
    /// Type (tous les types de la zone : `NS`, `SOA`…).
    pub r#type: String,
    /// Valeur canonique.
    pub value: String,
    /// Durée de vie, en secondes.
    pub ttl: i64,
    /// Commentaire (marque `lyxal:<clé>` des écritures de Lyxal).
    pub comment: Option<String>,
}

/// Statut d'une zone chez le fournisseur.
#[derive(Debug, Clone, Copy, PartialEq, Eq, SurrealValue)]
#[surreal(untagged, rename_all = "snake_case")]
pub enum ProviderZoneStatus {
    /// Active.
    Active,
    /// Pas encore active.
    Pending,
    /// En erreur.
    Error,
    /// Verrouillée.
    Locked,
}

/// Paramètres de `fn::infra_zone_observe`.
#[derive(Debug, Clone, SurrealValue)]
pub struct ZoneObserveParams {
    /// Zone (`infra_zone:<clé>`).
    pub zone: String,
    /// Jeton de la réservation.
    pub claim: String,
    /// Statut de la zone chez le fournisseur.
    pub status: ProviderZoneStatus,
    /// Serveurs de noms de la zone.
    pub nameservers: Vec<String>,
    /// Rattachement vérifié chez la zone parente (absent : non vérifié).
    pub delegated: Option<bool>,
    /// Toutes les lignes de la zone (20 000 au plus).
    pub records: Vec<ObservedRecord>,
    /// Langue des messages d'erreur.
    pub language: Option<String>,
}

/// Résultat de `fn::infra_zone_observe`.
#[derive(Debug, Clone, SurrealValue)]
pub struct ZoneObserved {
    /// Zone.
    pub zone: InfraRecordId,
    /// Lignes lues.
    pub total: i64,
    /// Lignes nouvelles ou changées, écrites.
    pub written: i64,
    /// Lignes disparues, supprimées.
    pub removed: i64,
    /// Lignes rattachées à un enregistrement de Lyxal.
    pub owned: i64,
    /// Nouvel état de la zone.
    pub state: ZoneState,
    /// Empreinte de la photo.
    pub hash: String,
}

/// Paramètres des fonctions d'une passe qui ne prennent que la zone et le jeton
/// (`fn::infra_zone_plan`).
#[derive(Debug, Clone, SurrealValue)]
pub struct ZoneClaimRefParams {
    /// Zone (`infra_zone:<clé>`).
    pub zone: String,
    /// Jeton de la réservation.
    pub claim: String,
    /// Langue des messages d'erreur.
    pub language: Option<String>,
}

/// Issue d'un plan.
#[derive(Debug, Clone, Copy, PartialEq, Eq, SurrealValue)]
#[surreal(untagged, rename_all = "snake_case")]
pub enum PlanReason {
    /// Zone en observation : rien n'est écrit.
    Observe,
    /// Seuils de prudence dépassés : zone bloquée jusqu'à l'approbation.
    Blocked,
    /// Aucun changement.
    Noop,
    /// Changements à écrire.
    Apply,
}

/// États des enregistrements mis à jour par un plan d'une zone gérée.
#[derive(Debug, Clone, PartialEq, Eq, SurrealValue)]
pub struct PlanStates {
    /// Conflits.
    pub conflicts: i64,
    /// Satisfaits (aucun changement, vérification de la publication).
    pub satisfied: i64,
    /// Avec des changements à écrire.
    pub pending: i64,
    /// Retirés sans suppression à faire.
    pub released: i64,
}

/// Résultat de `fn::infra_zone_plan`.
#[derive(Debug, Clone, SurrealValue)]
pub struct ZonePlanResult {
    /// Zone.
    pub zone: InfraRecordId,
    /// Changements à écrire.
    pub apply: bool,
    /// Issue.
    pub reason: PlanReason,
    /// Empreinte du plan (à passer à `fn::infra_zone_apply_begin`).
    pub hash: String,
    /// Changements.
    pub changes: Vec<PlannedChange>,
    /// Conflits.
    pub conflicts: Vec<PlannedConflict>,
    /// Suppressions.
    pub deletions: i64,
    /// Enregistrements de Lyxal observés.
    pub owned: i64,
    /// États mis à jour (zone gérée seulement).
    pub records: Option<PlanStates>,
}

/// Paramètres de `fn::infra_zone_apply_begin`.
#[derive(Debug, Clone, SurrealValue)]
pub struct ApplyBeginParams {
    /// Zone (`infra_zone:<clé>`).
    pub zone: String,
    /// Jeton de la réservation.
    pub claim: String,
    /// Empreinte du plan rangé.
    pub plan_hash: String,
    /// Langue des messages d'erreur.
    pub language: Option<String>,
}

/// Changement noté au journal avant l'appel : à envoyer au fournisseur.
#[derive(Debug, Clone, SurrealValue)]
pub struct SentChange {
    /// Entrée `sent` du journal (à rendre dans `ApplyOutcome::change`).
    pub change: InfraRecordId,
    /// `Add`, `Set` ou `Delete`.
    pub action: ChangeAction,
    /// Enregistrement voulu.
    pub record: InfraRecordId,
    /// Identifiant chez le fournisseur (`Set`, `Delete`).
    pub provider_id: Option<String>,
    /// Nom complet.
    pub fqdn: String,
    /// Type.
    pub r#type: String,
    /// Valeur canonique.
    pub value: String,
    /// Durée de vie, en secondes.
    pub ttl: i64,
    /// Marque `lyxal:<clé>` à écrire dans le commentaire du fournisseur.
    pub comment: String,
}

/// Résultat de `fn::infra_zone_apply_begin`.
#[derive(Debug, Clone, SurrealValue)]
pub struct ApplyBegun {
    /// Zone.
    pub zone: InfraRecordId,
    /// Changements à envoyer, en une requête.
    pub changes: Vec<SentChange>,
}

/// Issue d'un changement chez le fournisseur.
#[derive(Debug, Clone, SurrealValue)]
pub struct ApplyOutcome {
    /// Entrée `sent` du journal (`infra_change:<clé>`).
    pub change: String,
    /// Écriture faite.
    pub ok: bool,
    /// Identifiant attribué à un ajout.
    pub provider_id: Option<String>,
    /// Statut HTTP.
    pub provider_status: Option<i64>,
    /// Code `INFRA_PROVIDER_*` si `ok` est faux.
    pub code: Option<String>,
    /// Échec passager (la passe sera reprise).
    pub retryable: bool,
}

/// Paramètres de `fn::infra_zone_apply_result`.
#[derive(Debug, Clone, SurrealValue)]
pub struct ApplyResultParams {
    /// Zone (`infra_zone:<clé>`).
    pub zone: String,
    /// Jeton de la réservation.
    pub claim: String,
    /// Issues (5 000 au plus).
    pub results: Vec<ApplyOutcome>,
    /// Langue des messages d'erreur.
    pub language: Option<String>,
}

/// État d'un enregistrement après l'écriture.
#[derive(Debug, Clone, SurrealValue)]
pub struct RecordOutcome {
    /// Enregistrement voulu.
    pub record: InfraRecordId,
    /// Nouvel état.
    pub state: RecordState,
}

/// Résultat de `fn::infra_zone_apply_result`.
#[derive(Debug, Clone, SurrealValue)]
pub struct ApplyResult {
    /// Zone.
    pub zone: InfraRecordId,
    /// Écritures faites.
    pub done: i64,
    /// Écritures refusées.
    pub failed: i64,
    /// États des enregistrements.
    pub records: Vec<RecordOutcome>,
}

/// Issue d'une passe.
#[derive(Debug, Clone, Copy, PartialEq, Eq, SurrealValue)]
#[surreal(untagged, rename_all = "snake_case")]
pub enum PassOutcome {
    /// Aucun changement.
    Noop,
    /// Changements écrits.
    Applied,
    /// Zone en observation.
    Observed,
    /// Plan bloqué.
    Blocked,
    /// Passe en échec (`code` exigé).
    Failed,
}

/// Paramètres de `fn::infra_zone_release`.
#[derive(Debug, Clone, SurrealValue)]
pub struct ZoneReleaseParams {
    /// Zone (`infra_zone:<clé>`).
    pub zone: String,
    /// Jeton de la réservation.
    pub claim: String,
    /// Issue de la passe.
    pub outcome: PassOutcome,
    /// Code `INFRA_*` d'une passe en échec.
    pub code: Option<String>,
    /// Langue des messages d'erreur.
    pub language: Option<String>,
}

/// Résultat de `fn::infra_zone_release`.
#[derive(Debug, Clone, SurrealValue)]
pub struct ZoneReleased {
    /// Zone.
    pub zone: InfraRecordId,
    /// Nouvel état.
    pub state: ZoneState,
    /// Prochaine passe périodique.
    pub next_reconcile_at: InfraDatetime,
}

/// Enregistrement dont la publication est à vérifier.
#[derive(Debug, Clone, SurrealValue)]
pub struct VerifyItem {
    /// Enregistrement voulu.
    pub record: InfraRecordId,
    /// Zone.
    pub zone: InfraRecordId,
    /// Nom de la zone.
    pub zone_name: String,
    /// Serveurs de noms de la zone.
    pub nameservers: Vec<String>,
    /// Nom complet.
    pub fqdn: String,
    /// Type.
    pub r#type: RecordType,
    /// Valeurs attendues.
    pub values: Vec<String>,
    /// Écriture vérifiée (à rendre dans `VerifyResultParams::written_at`).
    pub written_at: InfraDatetime,
}

/// Résultat de `fn::infra_records_to_verify`.
#[derive(Debug, Clone, SurrealValue)]
pub struct VerifyList {
    /// Vérifications dues, la plus ancienne d'abord.
    pub items: Vec<VerifyItem>,
}

/// Paramètres de `fn::infra_record_verify_result`.
#[derive(Debug, Clone, SurrealValue)]
pub struct VerifyResultParams {
    /// Enregistrement voulu (`infra_record:<clé>`).
    pub record: String,
    /// Écriture vérifiée.
    pub written_at: InfraDatetime,
    /// Servi par tous les serveurs faisant autorité.
    pub published: bool,
    /// `INFRA_DNS_UNAVAILABLE` si les serveurs ne répondent pas.
    pub code: Option<String>,
    /// Langue des messages d'erreur.
    pub language: Option<String>,
}

/// Résultat de `fn::infra_record_verify_result`.
#[derive(Debug, Clone, SurrealValue)]
pub struct VerifyOutcome {
    /// Enregistrement voulu.
    pub record: InfraRecordId,
    /// État.
    pub state: RecordState,
    /// Réponse ignorée (enregistrement changé depuis la question).
    pub skipped: bool,
    /// Prochaine vérification.
    pub next_verify_at: Option<InfraDatetime>,
}

/// Résultat de `fn::infra_purge`.
#[derive(Debug, Clone, PartialEq, Eq, SurrealValue)]
pub struct PurgeResult {
    /// Entrées du journal retirées.
    pub changes: i64,
    /// Enregistrements retirés supprimés.
    pub records: i64,
    /// Il en reste au-delà du lot.
    pub more: bool,
}

/// Paramètres de `fn::infra_health`.
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct HealthParams {
    /// Langue des messages d'erreur.
    pub language: Option<String>,
}

/// État général rendu par la sonde.
#[derive(Debug, Clone, Copy, PartialEq, Eq, SurrealValue)]
#[surreal(untagged, rename_all = "snake_case")]
pub enum HealthStatus {
    /// Sain.
    Healthy,
    /// Dégradé (au moins un cas compté).
    Degraded,
    /// Malade (réglages absents).
    Unhealthy,
}

/// Résultat de `fn::infra_health` : nombres, jamais de nom.
#[derive(Debug, Clone, SurrealValue)]
pub struct HealthResult {
    /// État général.
    pub status: HealthStatus,
    /// Réglages présents.
    pub settings_ok: bool,
    /// Comptes.
    pub accounts: i64,
    /// Comptes en échec.
    pub accounts_failing: i64,
    /// Zones.
    pub zones: i64,
    /// Zones bloquées.
    pub zones_blocked: i64,
    /// Zones non rattachées chez la zone parente.
    pub zones_not_delegated: i64,
    /// Zones en échec.
    pub zones_failing: i64,
    /// Zones dont la passe a plus de 3 intervalles de retard.
    pub zones_late: i64,
    /// Enregistrements en conflit.
    pub records_conflict: i64,
    /// Enregistrements en échec.
    pub records_failed: i64,
    /// Enregistrements écrits depuis plus d'une heure, non publiés.
    pub records_written_late: i64,
}
