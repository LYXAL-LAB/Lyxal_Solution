//! Enregistrements voulus : contrat public des modules (`fn::infra_records_*`) et administration
//! (`fn::infra_record_*`).

use lyxal_surreal::SurrealValue;

use super::types::{InfraDatetime, InfraRecordId, RecordMode, RecordState, RecordType};

/// Enregistrement d'une déclaration.
#[derive(Debug, Clone, PartialEq, Eq, SurrealValue)]
pub struct DeclaredRecord {
    /// Nom complet (tiret bas permis : `_dmarc.exemple.fr`).
    pub fqdn: String,
    /// Type.
    pub r#type: RecordType,
    /// Valeurs (1 à 20), mises en forme canonique par la fonction.
    pub values: Vec<String>,
    /// Durée de vie, en secondes (défaut des réglages).
    pub ttl: Option<i64>,
    /// Cohabitation.
    pub mode: RecordMode,
    /// TXT partagé : préfixe unique (`v=spf1`, `v=DMARC1`…).
    pub singleton_prefix: Option<String>,
}

/// Paramètres de `fn::infra_records_declare` : remplace tout l'ensemble (owner, subject).
#[derive(Debug, Clone, SurrealValue)]
pub struct RecordsDeclareParams {
    /// Propriétaire : identifiant de module (`lyxal_mail`) ou `manual`.
    pub owner: String,
    /// Sujet : clé opaque, sans nom de domaine ni adresse.
    pub subject: String,
    /// Organisation (`auth_organization:<clé>`), absente pour l'installation.
    pub tenant: Option<String>,
    /// Enregistrements voulus (50 au plus ; vide : tout est retiré).
    pub records: Vec<DeclaredRecord>,
    /// Langue des messages d'erreur.
    pub language: Option<String>,
}

/// Enregistrement d'une déclaration acceptée.
#[derive(Debug, Clone, SurrealValue)]
pub struct DeclaredItem {
    /// Enregistrement voulu.
    pub record: InfraRecordId,
    /// Nom complet.
    pub fqdn: String,
    /// Type.
    pub r#type: RecordType,
    /// État.
    pub state: RecordState,
    /// Une zone rattachée couvre le nom.
    pub managed: bool,
}

/// Résultat de `fn::infra_records_declare`.
#[derive(Debug, Clone, SurrealValue)]
pub struct RecordsDeclareResult {
    /// Enregistrements déclarés.
    pub items: Vec<DeclaredItem>,
    /// Faux : déclaration identique, rien n'a été écrit.
    pub changed: bool,
    /// Passes mises en file.
    pub queued: i64,
}

/// Paramètres de `fn::infra_records_release`.
#[derive(Debug, Clone, SurrealValue)]
pub struct RecordsReleaseParams {
    /// Propriétaire.
    pub owner: String,
    /// Sujet.
    pub subject: String,
    /// Laisser chez le fournisseur ce que Lyxal a écrit (oubli simple).
    pub keep_at_provider: bool,
    /// Langue des messages d'erreur.
    pub language: Option<String>,
}

/// Résultat de `fn::infra_records_release`.
#[derive(Debug, Clone, PartialEq, Eq, SurrealValue)]
pub struct RecordsReleaseResult {
    /// Enregistrements oubliés.
    pub released: i64,
    /// Enregistrements à supprimer chez le fournisseur à la passe suivante.
    pub releasing: i64,
    /// Passes mises en file.
    pub queued: i64,
}

/// Paramètres de `fn::infra_records_status`.
#[derive(Debug, Clone, SurrealValue)]
pub struct RecordsStatusParams {
    /// Propriétaire.
    pub owner: String,
    /// Sujets (1 à 500).
    pub subjects: Vec<String>,
    /// Langue des messages d'erreur.
    pub language: Option<String>,
}

/// État d'un enregistrement pour son propriétaire.
#[derive(Debug, Clone, SurrealValue)]
pub struct RecordStatus {
    /// Sujet.
    pub subject: String,
    /// Enregistrement voulu.
    pub record: InfraRecordId,
    /// Nom complet.
    pub fqdn: String,
    /// Type.
    pub r#type: RecordType,
    /// État.
    pub state: RecordState,
    /// Une zone rattachée couvre le nom.
    pub managed: bool,
    /// Cause du conflit en cours.
    pub conflict_reason: Option<String>,
    /// Publication constatée.
    pub published_at: Option<InfraDatetime>,
    /// Code de la dernière erreur.
    pub error_code: Option<String>,
}

/// Résultat de `fn::infra_records_status`.
#[derive(Debug, Clone, SurrealValue)]
pub struct RecordsStatusResult {
    /// États, par sujet, nom et type.
    pub items: Vec<RecordStatus>,
}

/// Paramètres de `fn::infra_records_subjects`.
#[derive(Debug, Clone, SurrealValue)]
pub struct RecordsSubjectsParams {
    /// Propriétaire.
    pub owner: String,
    /// Sujet après lequel commence la page.
    pub after: Option<String>,
    /// Taille de page (1 à 1 000, 100 par défaut).
    pub limit: Option<i64>,
    /// Langue des messages d'erreur.
    pub language: Option<String>,
}

/// Résultat de `fn::infra_records_subjects`.
#[derive(Debug, Clone, SurrealValue)]
pub struct RecordsSubjectsResult {
    /// Sujets, par ordre croissant.
    pub subjects: Vec<String>,
    /// `after` de la page suivante (absent à la fin).
    pub next: Option<String>,
}

/// Conflit en cours d'un enregistrement.
#[derive(Debug, Clone, SurrealValue)]
pub struct RecordConflict {
    /// Cause.
    pub reason: String,
    /// Valeurs observées en cause.
    pub observed: Vec<String>,
    /// Entrée en conflit.
    pub at: InfraDatetime,
}

/// Décision humaine sur le dernier conflit.
#[derive(Debug, Clone, SurrealValue)]
pub struct RecordResolution {
    /// `take_over` ou `yield`.
    pub action: String,
    /// Auteur.
    pub actor: String,
    /// Date.
    pub at: InfraDatetime,
    /// `take_over` : application chez l'hébergeur.
    pub applied_at: Option<InfraDatetime>,
}

/// Dernière erreur d'un enregistrement.
#[derive(Debug, Clone, SurrealValue)]
pub struct RecordError {
    /// Code `INFRA_*`.
    pub code: String,
    /// Date.
    pub at: InfraDatetime,
}

/// Valeur observée chez le fournisseur pour un enregistrement.
#[derive(Debug, Clone, SurrealValue)]
pub struct ObservedValue {
    /// Identifiant chez le fournisseur.
    pub provider_id: String,
    /// Valeur canonique.
    pub value: String,
    /// Durée de vie, en secondes.
    pub ttl: i64,
    /// Écrite par Lyxal.
    pub lyxal: bool,
}

/// Enregistrement voulu, vue d'administration.
#[derive(Debug, Clone, SurrealValue)]
pub struct RecordResult {
    /// Enregistrement voulu.
    pub id: InfraRecordId,
    /// Propriétaire.
    pub owner: String,
    /// Sujet.
    pub subject: String,
    /// Organisation.
    pub tenant: Option<InfraRecordId>,
    /// Zone.
    pub zone: Option<InfraRecordId>,
    /// Nom complet.
    pub fqdn: String,
    /// Type.
    pub r#type: RecordType,
    /// Valeurs voulues.
    pub values: Vec<String>,
    /// Durée de vie, en secondes.
    pub ttl: i64,
    /// Cohabitation.
    pub mode: RecordMode,
    /// Préfixe unique.
    pub singleton_prefix: Option<String>,
    /// État.
    pub state: RecordState,
    /// Conflit en cours.
    pub conflict: Option<RecordConflict>,
    /// Décision humaine sur le dernier conflit.
    pub resolution: Option<RecordResolution>,
    /// Valeurs écrites par Lyxal.
    pub applied_values: Vec<String>,
    /// Dernière écriture complète.
    pub written_at: Option<InfraDatetime>,
    /// Publication constatée.
    pub published_at: Option<InfraDatetime>,
    /// Vérifications faites depuis l'écriture.
    pub verify_attempts: i64,
    /// Prochaine vérification.
    pub next_verify_at: Option<InfraDatetime>,
    /// Dernière erreur.
    pub error: Option<RecordError>,
    /// Dernière déclaration qui l'a changé.
    pub declared_at: InfraDatetime,
    /// Dernière modification.
    pub updated_at: InfraDatetime,
    /// Valeurs observées chez le fournisseur (`fn::infra_record_get`).
    pub observed: Option<Vec<ObservedValue>>,
    /// Passes mises en file (`fn::infra_record_conflict_resolve`).
    pub queued: Option<i64>,
}

/// Paramètres de `fn::infra_record_list`.
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct RecordListParams {
    /// Filtre sur la zone.
    pub zone: Option<String>,
    /// Filtre sur l'état.
    pub state: Option<RecordState>,
    /// Filtre sur le propriétaire.
    pub owner: Option<String>,
    /// Taille de page (500 au plus).
    pub limit: Option<i64>,
    /// Début de la page.
    pub start: Option<i64>,
    /// Langue des messages d'erreur.
    pub language: Option<String>,
}

/// Résultat de `fn::infra_record_list`.
#[derive(Debug, Clone, SurrealValue)]
pub struct RecordListResult {
    /// Enregistrements de la page.
    pub items: Vec<RecordResult>,
    /// Nombre total.
    pub total: i64,
}

/// Paramètres de `fn::infra_record_get`.
#[derive(Debug, Clone, SurrealValue)]
pub struct RecordRefParams {
    /// Enregistrement voulu (`infra_record:<clé>`).
    pub record: String,
    /// Langue des messages d'erreur.
    pub language: Option<String>,
}

/// Décision sur un conflit.
#[derive(Debug, Clone, Copy, PartialEq, Eq, SurrealValue)]
#[surreal(untagged, rename_all = "snake_case")]
pub enum ConflictAction {
    /// Remplacer la valeur étrangère (une fois).
    TakeOver,
    /// Laisser la valeur humaine.
    Yield,
}

/// Paramètres de `fn::infra_record_conflict_resolve`.
#[derive(Debug, Clone, SurrealValue)]
pub struct ConflictResolveParams {
    /// Enregistrement en conflit (`infra_record:<clé>`).
    pub record: String,
    /// Décision.
    pub action: ConflictAction,
    /// Langue des messages d'erreur.
    pub language: Option<String>,
}
