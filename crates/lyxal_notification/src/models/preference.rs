//! Préférences, heures calmes et désabonnement (`fn::notification_preference_*`,
//! `fn::notification_my_preference_*`, `fn::notification_unsubscribe`).

use lyxal_surreal::SurrealValue;

use super::types::NotificationRecordId;

/// Choix par canal d'un niveau : `true`, `false`, ou absent (le niveau ne s'exprime pas).
#[derive(Debug, Clone, Default, PartialEq, Eq, SurrealValue)]
pub struct Channels {
    /// E-mail.
    pub email: Option<bool>,
    /// SMS.
    pub sms: Option<bool>,
    /// Messageries d'équipe.
    pub chat: Option<bool>,
    /// Notifications push.
    pub push: Option<bool>,
    /// Fil dans l'application.
    pub in_app: Option<bool>,
    /// Appel d'une adresse web.
    pub webhook: Option<bool>,
}

/// Plage d'heures calmes : jours de début (1 = lundi … 7 = dimanche), début et fin en minutes
/// depuis minuit ; `end <= start` : la plage passe minuit (`start == end` : 24 heures).
#[derive(Debug, Clone, PartialEq, Eq, SurrealValue)]
pub struct QuietRange {
    /// Jours de début de la plage.
    pub days: Vec<i64>,
    /// Début (0 à 1439).
    pub start: i64,
    /// Fin (0 à 1439).
    pub end: i64,
}

/// Heures calmes enregistrées (niveau `subscriber_global`).
#[derive(Debug, Clone, PartialEq, Eq, SurrealValue)]
pub struct QuietHours {
    /// Plages.
    pub ranges: Vec<QuietRange>,
}

/// Heures calmes applicables à un envoi : plages et fuseau (abonné, sinon réglages, sinon UTC).
#[derive(Debug, Clone, PartialEq, Eq, SurrealValue)]
pub struct QuietHoursRule {
    /// Fuseau horaire IANA.
    pub timezone: String,
    /// Plages.
    pub ranges: Vec<QuietRange>,
}

/// Décision pour un canal : autorisé ou non, et niveau qui a décidé.
#[derive(Debug, Clone, PartialEq, Eq, SurrealValue)]
pub struct ChannelDecision {
    /// Envoi autorisé.
    pub allowed: bool,
    /// `default`, `workflow_default`, `tenant_workflow`, `subscriber_global`,
    /// `subscriber_category` ou `subscriber_workflow`.
    pub level: String,
}

/// Décisions par canal.
#[derive(Debug, Clone, PartialEq, Eq, SurrealValue)]
pub struct ChannelDecisions {
    /// E-mail.
    pub email: ChannelDecision,
    /// SMS.
    pub sms: ChannelDecision,
    /// Messageries d'équipe.
    pub chat: ChannelDecision,
    /// Notifications push.
    pub push: ChannelDecision,
    /// Fil dans l'application.
    pub in_app: ChannelDecision,
    /// Appel d'une adresse web.
    pub webhook: ChannelDecision,
}

/// Préférences calculées pour un parcours (ordre B4).
#[derive(Debug, Clone, PartialEq, Eq, SurrealValue)]
pub struct ResolvedPreferences {
    /// Parcours critique : choix de l'abonné et heures calmes ignorés.
    pub critical: bool,
    /// Décisions par canal.
    pub channels: ChannelDecisions,
    /// Heures calmes applicables.
    pub quiet_hours: Option<QuietHoursRule>,
}

/// Choix global d'un abonné.
#[derive(Debug, Clone, PartialEq, Eq, SurrealValue)]
pub struct GlobalPreference {
    /// Choix par canal.
    pub channels: Channels,
    /// Heures calmes.
    pub quiet_hours: Option<QuietHours>,
}

/// Choix pour une catégorie ou un parcours.
#[derive(Debug, Clone, PartialEq, Eq, SurrealValue)]
pub struct TargetPreference {
    /// Catégorie (niveau `subscriber_category`).
    pub category: Option<NotificationRecordId>,
    /// Parcours (niveaux `tenant_workflow`, `subscriber_workflow`).
    pub workflow: Option<NotificationRecordId>,
    /// Clé de la catégorie ou du parcours.
    pub key: Option<String>,
    /// Choix par canal.
    pub channels: Channels,
}

/// Préférences par niveau : d'un abonné, ou de l'organisation par parcours (sans abonné).
#[derive(Debug, Clone, PartialEq, Eq, SurrealValue)]
pub struct PreferenceOverview {
    /// Identifiant de l'abonné (absent sans abonné).
    pub subscriber_id: Option<String>,
    /// Choix global de l'abonné.
    pub global: Option<GlobalPreference>,
    /// Choix par catégorie.
    #[surreal(default)]
    pub categories: Vec<TargetPreference>,
    /// Choix par parcours.
    #[surreal(default)]
    pub workflows: Vec<TargetPreference>,
    /// Résultat calculé pour le parcours demandé.
    pub resolved: Option<ResolvedPreferences>,
}

/// Paramètres de `fn::notification_preference_get`.
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct PreferenceGetParams {
    /// Organisation, absente pour l'installation.
    pub tenant: Option<String>,
    /// Abonné (sans : réglages de l'organisation par parcours).
    pub subscriber_id: Option<String>,
    /// Parcours (`notification_workflow:<clé>`) dont calculer le résultat.
    pub workflow: Option<String>,
}

/// Paramètres de `fn::notification_preference_set`.
#[derive(Debug, Clone, SurrealValue)]
pub struct PreferenceSetParams {
    /// Organisation, absente pour l'installation.
    pub tenant: Option<String>,
    /// `tenant_workflow`, `subscriber_global`, `subscriber_category` ou `subscriber_workflow`.
    pub level: String,
    /// Abonné (niveaux `subscriber_*`).
    pub subscriber_id: Option<String>,
    /// Parcours (`notification_workflow:<clé>`).
    pub workflow: Option<String>,
    /// Clé de la catégorie.
    pub category: Option<String>,
    /// Canaux fournis (remplacés).
    pub channels: Option<Channels>,
    /// Heures calmes (niveau `subscriber_global`).
    pub quiet_hours: Option<QuietHours>,
}

/// Préférence enregistrée.
#[derive(Debug, Clone, PartialEq, Eq, SurrealValue)]
pub struct Preference {
    /// Enregistrement.
    pub id: NotificationRecordId,
    /// Niveau.
    pub level: String,
    /// Abonné.
    pub subscriber: Option<NotificationRecordId>,
    /// Parcours.
    pub workflow: Option<NotificationRecordId>,
    /// Catégorie.
    pub category: Option<NotificationRecordId>,
    /// Choix par canal.
    pub channels: Channels,
    /// Heures calmes.
    pub quiet_hours: Option<QuietHours>,
}

/// Paramètres de `fn::notification_my_preference_get`.
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct MyPreferenceGetParams {
    /// Organisation active de la personne, absente pour l'installation.
    pub tenant: Option<String>,
    /// Parcours dont calculer le résultat.
    pub workflow: Option<String>,
}

/// Paramètres de `fn::notification_my_preference_set`.
#[derive(Debug, Clone, SurrealValue)]
pub struct MyPreferenceSetParams {
    /// Organisation active de la personne, absente pour l'installation.
    pub tenant: Option<String>,
    /// `subscriber_global`, `subscriber_category` ou `subscriber_workflow`.
    pub level: String,
    /// Parcours.
    pub workflow: Option<String>,
    /// Clé de la catégorie.
    pub category: Option<String>,
    /// Canaux fournis (remplacés).
    pub channels: Option<Channels>,
    /// Heures calmes (niveau `subscriber_global`).
    pub quiet_hours: Option<QuietHours>,
}

/// Paramètres de `fn::notification_unsubscribe` (lien vérifié par l'hôte).
#[derive(Debug, Clone, PartialEq, Eq, SurrealValue)]
pub struct UnsubscribeParams {
    /// Abonné (`notification_subscriber:<clé>`).
    pub subscriber: String,
    /// Catégorie (`notification_category:<clé>`), ou
    pub category: Option<String>,
    /// parcours (`notification_workflow:<clé>`) sans catégorie.
    pub workflow: Option<String>,
    /// Canal coupé.
    pub channel: String,
}

/// Résultat de `fn::notification_unsubscribe`.
#[derive(Debug, Clone, PartialEq, Eq, SurrealValue)]
pub struct Unsubscribed {
    /// Abonné.
    pub subscriber: NotificationRecordId,
    /// Niveau écrit (`subscriber_category` ou `subscriber_workflow`).
    pub level: String,
    /// Canal coupé.
    pub channel: String,
}
