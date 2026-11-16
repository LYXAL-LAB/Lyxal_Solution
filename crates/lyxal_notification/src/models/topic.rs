//! Sujets, abonnements aux sujets et catégories de désabonnement (`fn::notification_topic_*`,
//! `fn::notification_category_*`).

use lyxal_surreal::SurrealValue;

use super::types::{NotificationDatetime, NotificationRecordId};

/// Sujet.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct Topic {
    /// Enregistrement.
    pub id: NotificationRecordId,
    /// Organisation (absente pour l'installation).
    pub tenant: Option<NotificationRecordId>,
    /// Portée.
    pub scope_key: String,
    /// Clé, unique dans sa portée.
    pub key: String,
    /// Nom affiché.
    pub name: String,
    /// Description.
    pub description: Option<String>,
    /// Données libres.
    pub data: serde_json::Value,
    /// Nombre d'abonnés (lecture d'un sujet seulement).
    pub members: Option<i64>,
    /// Création.
    pub created_at: NotificationDatetime,
}

/// Paramètres de `fn::notification_topic_create` et `_update` (clé désignant le sujet pour une
/// modification ; seuls les champs fournis changent).
#[derive(Debug, Clone, SurrealValue)]
pub struct TopicSaveParams {
    /// Organisation, absente pour l'installation.
    pub tenant: Option<String>,
    /// Clé (`snake_case`, 64 caractères au plus).
    pub key: String,
    /// Nom affiché (obligatoire à la création).
    pub name: Option<String>,
    /// Description.
    pub description: Option<String>,
    /// Données libres.
    pub data: Option<serde_json::Value>,
}

/// Sujet désigné par sa clé (`fn::notification_topic_get`, `_delete`).
#[derive(Debug, Clone, SurrealValue)]
pub struct TopicRefParams {
    /// Organisation, absente pour l'installation.
    pub tenant: Option<String>,
    /// Clé du sujet.
    pub key: String,
}

/// Paramètres de `fn::notification_topic_list`.
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct TopicListParams {
    /// Organisation, absente pour l'installation.
    pub tenant: Option<String>,
    /// Sujets au plus (1 à 1000).
    pub limit: Option<i64>,
    /// Décalage.
    pub start: Option<i64>,
}

/// Paramètres de `fn::notification_topic_members`.
#[derive(Debug, Clone, SurrealValue)]
pub struct TopicMembersParams {
    /// Organisation, absente pour l'installation.
    pub tenant: Option<String>,
    /// Clé du sujet.
    pub key: String,
    /// Abonnés au plus (1 à 1000).
    pub limit: Option<i64>,
    /// Décalage.
    pub start: Option<i64>,
}

/// Paramètres de `fn::notification_topic_subscribe`.
#[derive(Debug, Clone, SurrealValue)]
pub struct TopicSubscribeParams {
    /// Organisation, absente pour l'installation.
    pub tenant: Option<String>,
    /// Clé du sujet.
    pub key: String,
    /// Identifiants des abonnés (100 au plus).
    pub subscribers: Vec<String>,
    /// Condition `lyxal_core` sur `{ subscriber, payload }`.
    pub condition: Option<serde_json::Value>,
}

/// Paramètres de `fn::notification_topic_unsubscribe`.
#[derive(Debug, Clone, SurrealValue)]
pub struct TopicUnsubscribeParams {
    /// Organisation, absente pour l'installation.
    pub tenant: Option<String>,
    /// Clé du sujet.
    pub key: String,
    /// Identifiants des abonnés (100 au plus).
    pub subscribers: Vec<String>,
}

/// Résultat de `fn::notification_topic_subscribe`.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct TopicSubscribed {
    /// Abonnements créés.
    pub added: i64,
    /// Conditions remplacées.
    pub updated: i64,
    /// Abonnements inchangés.
    pub unchanged: i64,
    /// Abonnés inconnus.
    pub not_found: Vec<String>,
}

/// Résultat de `fn::notification_topic_unsubscribe`.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct TopicUnsubscribed {
    /// Abonnements retirés.
    pub removed: i64,
    /// Abonnés qui n'étaient pas abonnés.
    pub not_found: Vec<String>,
}

/// Abonné d'un sujet.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct TopicMember {
    /// Identifiant de l'abonné.
    pub subscriber_id: String,
    /// Condition d'abonnement.
    pub condition: Option<serde_json::Value>,
    /// Création.
    pub created_at: NotificationDatetime,
}

/// Catégorie de désabonnement.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct Category {
    /// Enregistrement.
    pub id: NotificationRecordId,
    /// Organisation (absente pour l'installation).
    pub tenant: Option<NotificationRecordId>,
    /// Portée.
    pub scope_key: String,
    /// Clé, unique dans sa portée.
    pub key: String,
    /// Nom affiché.
    pub name: String,
    /// Description.
    pub description: Option<String>,
}

/// Paramètres de `fn::notification_category_create` et `_update`.
#[derive(Debug, Clone, SurrealValue)]
pub struct CategorySaveParams {
    /// Organisation, absente pour l'installation.
    pub tenant: Option<String>,
    /// Clé (`snake_case`).
    pub key: String,
    /// Nom affiché (obligatoire à la création).
    pub name: Option<String>,
    /// Description.
    pub description: Option<String>,
}

/// Catégorie désignée par sa clé (`fn::notification_category_delete`).
#[derive(Debug, Clone, SurrealValue)]
pub struct CategoryRefParams {
    /// Organisation, absente pour l'installation.
    pub tenant: Option<String>,
    /// Clé.
    pub key: String,
}

/// Portée lue (`fn::notification_category_list`).
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct ScopeParams {
    /// Organisation, absente pour l'installation.
    pub tenant: Option<String>,
}
