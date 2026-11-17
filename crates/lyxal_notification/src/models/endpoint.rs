//! Adresses des abonnés pour la messagerie d'équipe et l'appel d'une adresse web
//! (`fn::notification_endpoint_*`, `fn::notification_my_endpoint_*`) et appareils push
//! (`fn::notification_my_device_*`, `fn::notification_device_*`). L'adresse complète, la clé de
//! signature, le jeton d'un appareil et les clés d'un navigateur n'entrent en base que scellés
//! (`enc:v2`) et ne sont lus que par le worker ; les vues ne portent que l'hôte (adresses) ou le
//! type d'appareil.

use lyxal_surreal::SurrealValue;

use super::integration::ClaimedIntegration;
use super::types::{NotificationDatetime, NotificationRecordId};

/// Adresse remise au worker avec l'intégration de son service.
#[derive(Clone, PartialEq, SurrealValue)]
pub struct ClaimedEndpoint {
    /// Adresse.
    pub id: NotificationRecordId,
    /// Clé de l'organisation de l'adresse (contexte de scellement), absente pour l'installation.
    pub tenant_key: Option<String>,
    /// Service : `slack`, `teams`, `discord`, `mattermost`, `google_chat`, `telegram`, `webhook`.
    pub provider: String,
    /// Hôte de l'adresse.
    pub host: String,
    /// Adresse complète scellée (`enc:v2`), absente pour Telegram.
    pub url: Option<String>,
    /// Telegram : identifiant du salon.
    pub chat_id: Option<String>,
    /// Adresse web : clé de signature scellée (`enc:v2`).
    pub signing_secret: Option<String>,
    /// Appareil push : plateforme (`web`, `android`, `ios`).
    #[surreal(default)]
    pub platform: Option<String>,
    /// Appareil push : empreinte SHA-256 du jeton (contexte de scellement).
    #[surreal(default)]
    pub fingerprint: Option<String>,
    /// Appareil push : jeton scellé (Web Push : adresse du service push).
    #[surreal(default)]
    pub token: Option<String>,
    /// Web Push : clé publique du navigateur scellée.
    #[surreal(default)]
    pub p256dh: Option<String>,
    /// Web Push : secret d'authentification du navigateur scellé.
    #[surreal(default)]
    pub auth: Option<String>,
    /// Intégration de l'envoi pour ce service.
    pub integration: ClaimedIntegration,
}

impl std::fmt::Debug for ClaimedEndpoint {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("ClaimedEndpoint")
            .field("id", &self.id)
            .field("provider", &self.provider)
            .field("host", &self.host)
            .field("url", &self.url.as_ref().map(|_| "[REDACTED]"))
            .field(
                "signing_secret",
                &self.signing_secret.as_ref().map(|_| "[REDACTED]"),
            )
            .field("platform", &self.platform)
            .field("token", &self.token.as_ref().map(|_| "[REDACTED]"))
            .field("p256dh", &self.p256dh.as_ref().map(|_| "[REDACTED]"))
            .field("auth", &self.auth.as_ref().map(|_| "[REDACTED]"))
            .field("integration", &self.integration.id)
            .finish_non_exhaustive()
    }
}

/// Issue d'une adresse servie, remise à `fn::notification_job_complete` ou `_fail`.
#[derive(Debug, Clone, PartialEq, Eq, SurrealValue)]
pub struct EndpointOutcome {
    /// Adresse (texte `notification_endpoint:<clé>`).
    pub endpoint: String,
    /// Intégration de l'appel (texte `notification_integration:<clé>`).
    pub integration: String,
    /// Appel accepté par le service.
    pub ok: bool,
    /// Code d'erreur (`NOTIFICATION_*`) d'un appel refusé.
    pub code: Option<String>,
    /// Identifiant du message chez le service.
    pub provider_message_id: Option<String>,
    /// Code HTTP de la réponse.
    pub response_code: Option<i64>,
}

/// Dernier appel d'une adresse.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct EndpointResult {
    /// Date.
    pub at: NotificationDatetime,
    /// Appel accepté.
    pub ok: bool,
    /// Code d'erreur.
    pub code: Option<String>,
}

/// Adresse telle que la rendent les fonctions de gestion : hôte, jamais l'adresse complète ni la
/// clé de signature.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct Endpoint {
    /// Adresse.
    pub id: NotificationRecordId,
    /// Organisation (absente pour l'installation).
    pub tenant: Option<NotificationRecordId>,
    /// Abonné.
    pub subscriber: NotificationRecordId,
    /// Canal (`chat`, `webhook`).
    pub channel: String,
    /// Service.
    pub provider: String,
    /// Nom.
    pub name: String,
    /// Hôte.
    pub host: String,
    /// Telegram : identifiant du salon.
    pub chat_id: Option<String>,
    /// Active.
    pub active: bool,
    /// Adresse web : clé de signature en place.
    pub signed: bool,
    /// Adresse web : date de la clé de signature en cours.
    pub secret_rotated_at: Option<NotificationDatetime>,
    /// Dernier appel.
    pub last_result: Option<EndpointResult>,
}

/// Paramètres de `fn::notification_endpoint_create` (hôte, après scellement).
#[derive(Debug, Clone, SurrealValue)]
pub struct EndpointCreateParams {
    /// Organisation (texte), installation si absente.
    pub tenant: Option<String>,
    /// Abonné (identifiant de l'application).
    pub subscriber_id: String,
    /// Clé de l'adresse (UUID v7), celle du contexte de scellement.
    pub endpoint: Option<String>,
    /// Canal (`chat`, `webhook`).
    pub channel: String,
    /// Service.
    pub provider: String,
    /// Nom.
    pub name: String,
    /// Adresse en clair, contrôlée par `lyxal_core` et jamais enregistrée.
    pub url: Option<String>,
    /// Adresse scellée (`enc:v2`).
    pub sealed_url: Option<String>,
    /// Adresse web : clé de signature scellée (`enc:v2`).
    pub signing_secret: Option<String>,
    /// Telegram : identifiant du salon.
    pub chat_id: Option<String>,
    /// Active.
    pub active: Option<bool>,
}

/// Paramètres de `fn::notification_my_endpoint_create` (personne connectée, hôte).
#[derive(Debug, Clone, SurrealValue)]
pub struct MyEndpointCreateParams {
    /// Organisation active de la personne, installation si absente.
    pub tenant: Option<String>,
    /// Clé de l'adresse (UUID v7).
    pub endpoint: Option<String>,
    /// Canal.
    pub channel: String,
    /// Service.
    pub provider: String,
    /// Nom.
    pub name: String,
    /// Adresse en clair, contrôlée et jamais enregistrée.
    pub url: Option<String>,
    /// Adresse scellée.
    pub sealed_url: Option<String>,
    /// Clé de signature scellée.
    pub signing_secret: Option<String>,
    /// Telegram : identifiant du salon.
    pub chat_id: Option<String>,
    /// Active.
    pub active: Option<bool>,
}

/// Paramètres de `fn::notification_endpoint_update` et `fn::notification_my_endpoint_update`.
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct EndpointUpdateParams {
    /// Organisation (texte), installation si absente.
    pub tenant: Option<String>,
    /// Adresse (texte `notification_endpoint:<clé>`).
    pub endpoint: String,
    /// Nom.
    pub name: Option<String>,
    /// Active.
    pub active: Option<bool>,
    /// Telegram : identifiant du salon.
    pub chat_id: Option<String>,
}

/// Paramètres de `fn::notification_endpoint_delete` et `fn::notification_my_endpoint_delete`.
#[derive(Debug, Clone, SurrealValue)]
pub struct EndpointRefParams {
    /// Organisation (texte), installation si absente.
    pub tenant: Option<String>,
    /// Adresse (texte `notification_endpoint:<clé>`).
    pub endpoint: String,
}

/// Paramètres de `fn::notification_endpoint_rotate_secret` et `_my_endpoint_rotate_secret`.
#[derive(Debug, Clone, SurrealValue)]
pub struct EndpointRotateParams {
    /// Organisation (texte), installation si absente.
    pub tenant: Option<String>,
    /// Adresse web (texte `notification_endpoint:<clé>`).
    pub endpoint: String,
    /// Nouvelle clé de signature scellée par l'hôte.
    pub signing_secret: String,
}

/// Paramètres de `fn::notification_endpoint_list`.
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct EndpointListParams {
    /// Organisation (texte), installation si absente.
    pub tenant: Option<String>,
    /// Abonné.
    pub subscriber_id: Option<String>,
    /// Canal.
    pub channel: Option<String>,
}

/// Paramètres de `fn::notification_my_endpoint_list`.
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct MyEndpointListParams {
    /// Organisation active, installation si absente.
    pub tenant: Option<String>,
    /// Canal.
    pub channel: Option<String>,
}

/// Paramètres de `fn::notification_my_device_register` (hôte, après scellement) : valeurs en
/// clair pour le contrôle seulement, valeurs scellées seules enregistrées.
#[derive(Clone, Default, SurrealValue)]
pub struct DeviceRegisterParams {
    /// Organisation active de la personne, installation si absente.
    pub tenant: Option<String>,
    /// Clé de l'appareil (UUID v7) s'il est nouveau.
    pub device: Option<String>,
    /// Service : `webpush`, `fcm`, `apns`.
    pub provider: String,
    /// Plateforme (`web`, `android`, `ios`) ; déduite du service si absente.
    pub platform: Option<String>,
    /// Nom donné par la personne.
    pub name: Option<String>,
    /// Web Push : adresse du service push (contrôlée, jamais enregistrée en clair).
    pub url: Option<String>,
    /// FCM, APNs : jeton (contrôlé, jamais enregistré en clair).
    pub token: Option<String>,
    /// Web Push : clé publique du navigateur (Base64url, contrôlée).
    pub p256dh: Option<String>,
    /// Web Push : secret d'authentification du navigateur (Base64url, contrôlé).
    pub auth: Option<String>,
    /// Empreinte SHA-256 du jeton (hexadécimal).
    pub fingerprint: String,
    /// Jeton scellé.
    pub sealed_token: String,
    /// Web Push : clé publique du navigateur scellée.
    pub sealed_p256dh: Option<String>,
    /// Web Push : secret d'authentification scellé.
    pub sealed_auth: Option<String>,
}

impl std::fmt::Debug for DeviceRegisterParams {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("DeviceRegisterParams")
            .field("tenant", &self.tenant)
            .field("provider", &self.provider)
            .field("platform", &self.platform)
            .finish_non_exhaustive()
    }
}

/// Appareil push vu par la personne : jamais le jeton, les clés ni l'empreinte.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct Device {
    /// Appareil.
    pub id: NotificationRecordId,
    /// Service (`webpush`, `fcm`, `apns`).
    pub provider: String,
    /// Plateforme (`web`, `android`, `ios`).
    pub platform: String,
    /// Nom.
    pub name: String,
    /// Hôte du service push.
    pub host: String,
    /// Actif.
    pub active: bool,
    /// Dernière inscription.
    pub registered_at: Option<NotificationDatetime>,
    /// Dernier envoi.
    pub last_result: Option<EndpointResult>,
}

/// Résultat de `fn::notification_my_device_register`.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct DeviceRegistered {
    /// Appareil créé (faux : inscription renvoyée, appareil existant mis à jour).
    pub created: bool,
    /// Appareil.
    pub device: Device,
}

/// Appareil push vu par un gestionnaire : type et date d'inscription seulement.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct DeviceSummary {
    /// Appareil.
    pub id: NotificationRecordId,
    /// Service.
    pub provider: String,
    /// Plateforme.
    pub platform: String,
    /// Dernière inscription.
    pub registered_at: Option<NotificationDatetime>,
}

/// Paramètres de `fn::notification_my_device_list` (personne connectée).
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct MyDeviceListParams {
    /// Organisation active de la personne, installation si absente.
    pub tenant: Option<String>,
}

/// Paramètres de `fn::notification_device_list` (gestion).
#[derive(Debug, Clone, SurrealValue)]
pub struct DeviceListParams {
    /// Organisation (texte), installation si absente.
    pub tenant: Option<String>,
    /// Abonné.
    pub subscriber_id: String,
}

/// Paramètres de `fn::notification_device_remove` (worker, décision G5).
#[derive(Debug, Clone, SurrealValue)]
pub struct DeviceRemoveParams {
    /// Appareil (texte `notification_endpoint:<clé>`).
    pub endpoint: String,
    /// Motif : `expired` (désinscrit, expiré) ou `invalid` (jeton refusé par le service).
    pub reason: String,
}

/// Résultat de `fn::notification_device_remove`.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct DeviceRemoved {
    /// Appareil retiré.
    pub removed: NotificationRecordId,
    /// Motif.
    pub reason: String,
}

/// Paramètres de `fn::notification_push_vapid_key` (hôte).
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct VapidKeyParams {
    /// Organisation active de la personne, installation si absente.
    pub tenant: Option<String>,
}

/// Résultat de `fn::notification_push_vapid_key`.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct VapidKey {
    /// Clé publique VAPID (Base64url).
    pub public_key: String,
    /// Intégration Web Push.
    pub integration: NotificationRecordId,
}

/// Paramètres de `fn::notification_push_links_check` (worker) : liens rendus d'un message push.
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct PushLinksParams {
    /// Lien de redirection rendu.
    pub link: Option<String>,
    /// Icône rendue.
    pub icon: Option<String>,
}

/// Résultat de `fn::notification_push_links_check` : liens refusés (`link`, `icon`).
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct PushLinksChecked {
    /// Champs refusés.
    pub refused: Vec<String>,
}

/// Paramètres de `fn::notification_endpoint_resolve` (hôte : essai d'une intégration).
#[derive(Debug, Clone, SurrealValue)]
pub struct EndpointResolveParams {
    /// Intégration (texte).
    pub integration: String,
    /// Adresse (texte).
    pub endpoint: String,
}
