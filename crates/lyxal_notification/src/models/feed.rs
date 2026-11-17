//! Fil dans l'application (canal `in_app`, décisions F1 à F8) : lecture, états, sommeil,
//! boutons et suppression par la personne connectée (`fn::notification_feed_*`), livraison par
//! le worker (`fn::notification_inbox_deliver`).

use lyxal_surreal::SurrealValue;

use super::types::{NotificationDatetime, NotificationRecordId};

/// Bouton d'un gabarit du fil : gabarits du libellé et du lien.
#[derive(Debug, Clone, PartialEq, Eq, SurrealValue)]
pub struct TemplateAction {
    /// `primary` ou `secondary`.
    pub kind: String,
    /// Libellé (gabarit).
    pub label: String,
    /// Lien (gabarit d'un chemin de l'application ou d'une adresse HTTPS).
    pub url: Option<String>,
}

/// Filtre d'un onglet du fil (décision F5) ; un champ absent ne filtre pas.
#[derive(Debug, Clone, Default, PartialEq, SurrealValue)]
pub struct FeedFilter {
    /// Étiquettes du parcours : une au moins en commun.
    pub tags: Option<Vec<String>>,
    /// Gravités (`high`, `medium`, `low`, `none`).
    pub severity: Option<Vec<String>>,
    /// Données : `{ clé : valeur }`, toutes égales.
    pub data: Option<serde_json::Value>,
    /// Messages archivés (faux par défaut : non archivés).
    pub archived: Option<bool>,
    /// Lus ou non lus.
    pub read: Option<bool>,
}

/// Paramètres de `fn::notification_feed_list`.
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct FeedListParams {
    /// Onglet.
    pub filter: Option<FeedFilter>,
    /// Dernier message reçu (texte `notification_inbox:<clé>`).
    pub cursor: Option<String>,
    /// Messages au plus (1 à 100, 20 par défaut).
    pub limit: Option<i64>,
}

/// Bouton d'un message du fil, avec son état.
#[derive(Debug, Clone, PartialEq, Eq, SurrealValue)]
pub struct FeedItemAction {
    /// `primary` ou `secondary`.
    pub kind: String,
    /// Libellé rendu.
    pub label: String,
    /// Lien rendu.
    pub url: Option<String>,
    /// `pending`, `done` ou `reverted`.
    pub status: String,
}

/// Message du fil tel que la personne le voit.
#[derive(Clone, PartialEq, SurrealValue)]
pub struct FeedItem {
    /// Message.
    pub id: NotificationRecordId,
    /// Parcours (clé).
    pub workflow: String,
    /// Étape du parcours.
    pub step_key: String,
    /// Titre rendu.
    pub title: String,
    /// Texte rendu (Markdown simple).
    pub text: String,
    /// Avatar.
    pub avatar: Option<String>,
    /// Lien de redirection.
    pub redirect: Option<String>,
    /// Boutons.
    pub actions: Vec<FeedItemAction>,
    /// Données libres.
    pub data: serde_json::Value,
    /// Étiquettes du parcours.
    pub tags: Vec<String>,
    /// Gravité du parcours.
    pub severity: String,
    /// Vu.
    pub seen: bool,
    /// Lu.
    pub read: bool,
    /// Archivé.
    pub archived: bool,
    /// Vu le.
    pub seen_at: Option<NotificationDatetime>,
    /// Lu le.
    pub read_at: Option<NotificationDatetime>,
    /// Archivé le.
    pub archived_at: Option<NotificationDatetime>,
    /// En sommeil jusqu'à.
    pub snoozed_until: Option<NotificationDatetime>,
    /// Création.
    pub created_at: NotificationDatetime,
}

impl std::fmt::Debug for FeedItem {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("FeedItem")
            .field("id", &self.id)
            .field("workflow", &self.workflow)
            .field("seen", &self.seen)
            .field("read", &self.read)
            .field("archived", &self.archived)
            .finish_non_exhaustive()
    }
}

/// Résultat de `fn::notification_feed_list`.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct FeedPage {
    /// Messages, du plus récent au plus ancien.
    pub items: Vec<FeedItem>,
    /// Curseur de la page suivante (absent à la fin).
    pub next_cursor: Option<NotificationRecordId>,
}

/// Paramètres de `fn::notification_feed_counts`.
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct FeedCountsParams {
    /// Onglet.
    pub filter: Option<FeedFilter>,
}

/// Compteurs du fil (calculés à la demande).
#[derive(Debug, Clone, Copy, Default, PartialEq, Eq, SurrealValue)]
pub struct FeedCounts {
    /// Non vus.
    pub unseen: i64,
    /// Non lus.
    pub unread: i64,
    /// Total visible.
    pub total: i64,
}

/// Paramètres de `fn::notification_feed_mark`.
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct FeedMarkParams {
    /// Messages (textes `notification_inbox:<clé>`, 100 au plus) ; ou `all`.
    pub ids: Option<Vec<String>>,
    /// Tous les messages de l'onglet `filter`.
    pub all: Option<bool>,
    /// Onglet (avec `all`).
    pub filter: Option<FeedFilter>,
    /// `seen`, `read`, `unread`, `archived`, `unarchived`.
    pub state: String,
}

/// Résultat de `fn::notification_feed_mark`.
#[derive(Debug, Clone, PartialEq, Eq, SurrealValue)]
pub struct FeedMarked {
    /// État appliqué.
    pub state: String,
    /// Messages modifiés.
    pub updated: i64,
}

/// Paramètres de `fn::notification_feed_snooze`.
#[derive(Debug, Clone, SurrealValue)]
pub struct FeedSnoozeParams {
    /// Message (texte `notification_inbox:<clé>`).
    pub id: String,
    /// Fin du sommeil (3 minutes à 90 jours).
    pub until: NotificationDatetime,
}

/// Paramètres de `fn::notification_feed_unsnooze`.
#[derive(Debug, Clone, SurrealValue)]
pub struct FeedItemRefParams {
    /// Message (texte `notification_inbox:<clé>`).
    pub id: String,
}

/// Paramètres de `fn::notification_feed_delete`.
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct FeedDeleteParams {
    /// Un message (texte) ; ou `all`.
    pub id: Option<String>,
    /// Tous les messages de l'onglet `filter`.
    pub all: Option<bool>,
    /// Onglet (avec `all`).
    pub filter: Option<FeedFilter>,
}

/// Résultat de `fn::notification_feed_delete`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, SurrealValue)]
pub struct FeedDeleted {
    /// Messages supprimés.
    pub deleted: i64,
}

/// Paramètres de `fn::notification_feed_action`.
#[derive(Debug, Clone, SurrealValue)]
pub struct FeedActionParams {
    /// Message (texte `notification_inbox:<clé>`).
    pub id: String,
    /// `primary` ou `secondary`.
    pub action: String,
    /// `done` ou `reverted`.
    pub status: String,
}

/// Bouton rendu d'un message du fil.
#[derive(Debug, Clone, PartialEq, Eq, SurrealValue)]
pub struct InboxAction {
    /// `primary` ou `secondary`.
    pub kind: String,
    /// Libellé rendu.
    pub label: String,
    /// Lien rendu.
    pub url: Option<String>,
}

/// Paramètres de `fn::notification_inbox_deliver` : message rendu d'une étape `in_app`.
#[derive(Clone, SurrealValue)]
pub struct InboxDeliverParams {
    /// Étape (texte `notification_job:<clé>`).
    pub job_id: String,
    /// Jeton de réservation.
    pub claim_token: String,
    /// Titre rendu.
    pub title: String,
    /// Texte rendu.
    pub text: String,
    /// Avatar rendu.
    pub avatar: Option<String>,
    /// Lien de redirection rendu.
    pub redirect: Option<String>,
    /// Boutons rendus.
    pub actions: Vec<InboxAction>,
    /// Données rendues (textes).
    pub data: serde_json::Value,
}

impl std::fmt::Debug for InboxDeliverParams {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("InboxDeliverParams")
            .field("job_id", &self.job_id)
            .field("content", &"[REDACTED]")
            .finish_non_exhaustive()
    }
}

/// Résultat de `fn::notification_inbox_deliver`.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct InboxDelivered {
    /// Message du fil (absent si l'étape a été écartée : abonné supprimé ou sans compte).
    pub item: Option<NotificationRecordId>,
    /// Trace d'envoi (`notification_message`, canal `in_app`).
    pub messages: Vec<NotificationRecordId>,
    /// `completed` ou `skipped`.
    pub status: String,
    /// État du déclenchement s'il est terminé.
    pub run_status: Option<String>,
}
