//! Alias des types natifs SurrealDB et états partagés par les modèles de `lyxal_infra`.

use lyxal_surreal::SurrealValue;

/// Identifiant d'enregistrement SurrealDB.
pub type InfraRecordId = lyxal_surreal::RecordId;
/// Horodatage SurrealDB.
pub type InfraDatetime = lyxal_surreal::Datetime;
/// UUID natif SurrealDB (projet et organisation Scaleway).
pub type InfraUuid = surrealdb::types::Uuid;

/// Type d'un enregistrement DNS voulu (V1).
#[derive(Debug, Clone, Copy, PartialEq, Eq, SurrealValue)]
#[surreal(untagged, rename_all = "UPPERCASE")]
pub enum RecordType {
    /// Adresse IPv4.
    A,
    /// Adresse IPv6.
    Aaaa,
    /// Alias.
    Cname,
    /// Serveur de courrier.
    Mx,
    /// Texte.
    Txt,
    /// Service.
    Srv,
    /// Autorités de certification.
    Caa,
}

/// Cohabitation d'un enregistrement voulu avec les valeurs d'autrui (jeu nom, type).
#[derive(Debug, Clone, Copy, PartialEq, Eq, SurrealValue)]
#[surreal(untagged, rename_all = "snake_case")]
pub enum RecordMode {
    /// Lyxal veut tout le jeu.
    Exclusive,
    /// Lyxal n'ajoute que ses valeurs.
    Shared,
}

/// État d'un enregistrement voulu.
#[derive(Debug, Clone, Copy, PartialEq, Eq, SurrealValue)]
#[surreal(untagged, rename_all = "snake_case")]
pub enum RecordState {
    /// Aucune zone rattachée ne couvre le nom.
    Unmanaged,
    /// À écrire chez l'hébergeur.
    Pending,
    /// Écrit chez l'hébergeur, publication à vérifier.
    Written,
    /// Servi par tous les serveurs faisant autorité.
    Published,
    /// En conflit avec une valeur humaine (décision attendue).
    Conflict,
    /// Valeur humaine laissée (en sommeil).
    Yielded,
    /// En échec.
    Failed,
    /// À retirer de chez l'hébergeur.
    Releasing,
    /// Retiré.
    Released,
}

/// Action d'un changement du plan ou d'une entrée du journal.
#[derive(Debug, Clone, Copy, PartialEq, Eq, SurrealValue)]
#[surreal(untagged, rename_all = "snake_case")]
pub enum ChangeAction {
    /// Ajout chez l'hébergeur.
    Add,
    /// Modification par identifiant.
    Set,
    /// Suppression par identifiant.
    Delete,
    /// Conflit constaté.
    Conflict,
    /// Conflit levé par une personne.
    Resolve,
    /// Plan bloqué approuvé.
    Approve,
    /// Écriture de Lyxal supprimée par une personne (recréée).
    DriftDeleted,
    /// Zone rattachée.
    Attach,
    /// Zone détachée.
    Detach,
    /// Mode d'une zone changé.
    Mode,
}
