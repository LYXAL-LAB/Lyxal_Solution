//! Abonnés (`fn::notification_subscriber_*`). Les adresses, téléphones et noms sont masqués dans
//! `Debug` (aucune donnée personnelle dans les journaux).

use lyxal_surreal::SurrealValue;

use super::types::{NotificationDatetime, NotificationRecordId};

/// Abonné reçu : création ou mise à jour (seuls les champs fournis changent).
#[derive(Clone, Default, SurrealValue)]
pub struct SubscriberInput {
    /// Identifiant stable choisi par l'application (`auth:<identité>`, `email:<adresse>`…).
    pub subscriber_id: String,
    /// Adresse e-mail.
    pub email: Option<String>,
    /// Téléphone au format E.164.
    pub phone: Option<String>,
    /// Prénom.
    pub first_name: Option<String>,
    /// Nom.
    pub last_name: Option<String>,
    /// Langue (BCP 47).
    pub locale: Option<String>,
    /// Fuseau horaire IANA.
    pub timezone: Option<String>,
    /// Données libres (objet JSON, 8 Kio au plus).
    pub data: Option<serde_json::Value>,
    /// Compte lié (`auth_identity:<clé>`) : `subscriber_id` vaut alors `auth:<clé>`.
    pub identity: Option<String>,
}

impl SubscriberInput {
    /// Abonné désigné par son seul identifiant (il doit exister).
    pub fn id(subscriber_id: impl Into<String>) -> Self {
        Self {
            subscriber_id: subscriber_id.into(),
            ..Self::default()
        }
    }
}

impl std::fmt::Debug for SubscriberInput {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("SubscriberInput")
            .field("locale", &self.locale)
            .field("timezone", &self.timezone)
            .field("identity", &self.identity)
            .finish_non_exhaustive()
    }
}

/// Abonné enregistré.
#[derive(Clone, PartialEq, SurrealValue)]
pub struct Subscriber {
    /// Enregistrement (clé aléatoire).
    pub id: NotificationRecordId,
    /// Organisation (absente pour l'installation).
    pub tenant: Option<NotificationRecordId>,
    /// Portée (`installation` ou clé de l'organisation).
    pub scope_key: String,
    /// Identifiant stable.
    pub subscriber_id: String,
    /// Compte lié.
    pub identity: Option<NotificationRecordId>,
    /// Adresse e-mail normalisée.
    pub email: Option<String>,
    /// Téléphone (E.164).
    pub phone: Option<String>,
    /// Prénom.
    pub first_name: Option<String>,
    /// Nom.
    pub last_name: Option<String>,
    /// Langue.
    pub locale: Option<String>,
    /// Fuseau horaire.
    pub timezone: Option<String>,
    /// Données libres.
    pub data: serde_json::Value,
    /// Clés des sujets (lecture d'un abonné seulement).
    #[surreal(default)]
    pub topics: Vec<String>,
    /// Création.
    pub created_at: NotificationDatetime,
    /// Dernière modification.
    pub updated_at: NotificationDatetime,
}

impl std::fmt::Debug for Subscriber {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("Subscriber")
            .field("id", &self.id)
            .field("tenant", &self.tenant)
            .field("identity", &self.identity)
            .field("locale", &self.locale)
            .finish_non_exhaustive()
    }
}

/// Paramètres de `fn::notification_subscriber_upsert` ; leur `Debug` ne montre aucune donnée
/// personnelle.
#[derive(Clone, SurrealValue)]
pub struct SubscriberUpsertParams {
    /// Organisation (`auth_organization:<clé>`), absente pour l'installation.
    pub tenant: Option<String>,
    /// Identifiant stable.
    pub subscriber_id: String,
    /// Adresse e-mail.
    pub email: Option<String>,
    /// Téléphone (E.164).
    pub phone: Option<String>,
    /// Prénom.
    pub first_name: Option<String>,
    /// Nom.
    pub last_name: Option<String>,
    /// Langue.
    pub locale: Option<String>,
    /// Fuseau horaire.
    pub timezone: Option<String>,
    /// Données libres.
    pub data: Option<serde_json::Value>,
    /// Compte lié.
    pub identity: Option<String>,
}

impl std::fmt::Debug for SubscriberUpsertParams {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("SubscriberUpsertParams")
            .field("tenant", &self.tenant)
            .field("subscriber_id", &self.subscriber_id)
            .field("locale", &self.locale)
            .field("timezone", &self.timezone)
            .field("identity", &self.identity)
            .finish_non_exhaustive()
    }
}

/// Résultat de `fn::notification_subscriber_upsert`.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct SubscriberUpsertResult {
    /// Abonné.
    pub subscriber: Subscriber,
    /// Créé par cet appel.
    pub created: bool,
    /// Modifié par cet appel.
    pub changed: bool,
}

/// Abonné désigné dans une portée (`fn::notification_subscriber_get`, `_delete`).
#[derive(Debug, Clone, SurrealValue)]
pub struct SubscriberRefParams {
    /// Organisation, absente pour l'installation.
    pub tenant: Option<String>,
    /// Identifiant stable.
    pub subscriber_id: String,
}

/// Paramètres de `fn::notification_subscriber_list`.
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct SubscriberListParams {
    /// Organisation, absente pour l'installation.
    pub tenant: Option<String>,
    /// Recherche dans l'identifiant, l'adresse ou le nom.
    pub search: Option<String>,
    /// Abonnés au plus (1 à 1000).
    pub limit: Option<i64>,
    /// Décalage.
    pub start: Option<i64>,
}

/// Enregistrement supprimé.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct Deleted {
    /// Enregistrement.
    pub deleted: NotificationRecordId,
}

/// Paramètres de `fn::notification_subscriber_import`.
#[derive(Debug, Clone, SurrealValue)]
pub struct SubscriberImportParams {
    /// Organisation, absente pour l'installation.
    pub tenant: Option<String>,
    /// Abonnés (500 au plus).
    pub subscribers: Vec<SubscriberInput>,
}

/// Ligne refusée d'un import.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct ImportRejection {
    /// Rang de la ligne (à partir de 0).
    pub index: i64,
    /// Code `NOTIFICATION_*`.
    pub code: String,
    /// Codes `lyxal_core` par champ.
    pub fields: Option<serde_json::Value>,
}

/// Résultat de `fn::notification_subscriber_import`.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct SubscriberImportResult {
    /// Abonnés créés.
    pub created: i64,
    /// Abonnés modifiés.
    pub updated: i64,
    /// Abonnés inchangés.
    pub unchanged: i64,
    /// Lignes refusées.
    pub rejected: Vec<ImportRejection>,
}
