//! Routes push de `lyxal_notification` (lot 6, décisions G1, G2) : inscription des appareils par
//! la personne connectée, clé publique VAPID donnée aux navigateurs, paire VAPID neuve rangée dans
//! le coffre-fort.
//!
//! `POST /api/v1/notification/my/devices` (jeton d'accès de la personne) : corps
//! `{ tenant, provider : webpush, subscription : { endpoint, keys : { p256dh, auth } }, name }`
//! (l'abonnement tel que le donne `PushSubscription.toJSON()` du navigateur) ou
//! `{ tenant, provider : fcm | apns, platform, token, name }`. L'hôte calcule l'empreinte du jeton
//! (SHA-256, `lyxal_crypto`), **scelle** le jeton et les clés du navigateur (`enc:v2`, clé
//! applicative, contexte lié à l'organisation et à l'empreinte) puis appelle
//! `fn::notification_my_device_register` au nom de la personne (valeurs en clair contrôlées par
//! `lyxal_core`, jamais enregistrées). Réponse `201` (nouvel appareil) ou `200` (inscription
//! renvoyée : appareil existant mis à jour) et `{ created, device }`, sans jeton ni clé.
//!
//! `GET /api/v1/notification/push/vapid-key?tenant=<organisation>` (jeton d'accès) : clé publique
//! VAPID (`applicationServerKey` du navigateur, Base64url) de l'intégration Web Push de
//! l'organisation active de la personne, sinon de l'installation ; la personne est vérifiée dans
//! sa session (`fn::notification_my_device_list`), la clé lue par la session système
//! (`fn::notification_push_vapid_key`).
//!
//! `POST /api/v1/notification/integrations/{intégration}/vapid` (droit de gestion) : paire VAPID
//! P-256 neuve tirée par `lyxal_crypto` (aléa du système), clé privée rangée **directement** dans
//! le secret des identifiants de l'intégration (`{ "private_key": "<PKCS#8 PEM>" }`, nouvelle
//! version au nom de l'appelant : droits du coffre-fort), jamais montrée ; clé publique notée
//! dans les réglages (`vapid_public_key`, `fn::notification_integration_update` au nom de
//! l'appelant). Réponse `{ public_key }`. Les abonnements des navigateurs faits avec l'ancienne
//! clé ne servent plus : ils sont retirés au premier envoi refusé.

use super::auth::{self, ApiError};
use crate::context::AppContext;
use crate::error::ServerError;
use axum::body::Bytes;
use axum::extract::{DefaultBodyLimit, Path, Query, State};
use axum::http::{HeaderMap, StatusCode};
use axum::response::Response;
use axum::routing::{get, post};
use axum::Router;
use base64::engine::general_purpose::STANDARD;
use base64::Engine;
use lyxal_crypto::{EcdsaP256SigningKey, SecretBytes};
use lyxal_notification::models::{
    Device, DeviceRegisterParams, IntegrationGetParams, IntegrationSaveParams, MyDeviceListParams,
    VapidKeyParams,
};
use lyxal_notification::{device_fingerprint, DeviceField, NotificationError, NotificationStore};
use lyxal_secrets::models::{SecretGetParams, Stage};
use lyxal_secrets::{PutValue, SecretsStore};
use lyxal_surreal::ToSql;
use serde::Deserialize;
use serde_json::{json, Value};
use std::collections::HashMap;
use zeroize::Zeroizing;

/// Taille maximale du corps d'une inscription d'appareil.
const DEVICE_BODY_LIMIT: usize = 8 * 1024;
/// Taille maximale du corps d'une demande de paire VAPID.
const VAPID_BODY_LIMIT: usize = 1024;

/// Routes push de `/notification/*`.
pub fn routes() -> Router<AppContext> {
    Router::new()
        .route(
            "/my/devices",
            post(device_register).layer(DefaultBodyLimit::max(DEVICE_BODY_LIMIT)),
        )
        .route("/push/vapid-key", get(vapid_key))
        .route(
            "/integrations/:integration/vapid",
            post(vapid_generate).layer(DefaultBodyLimit::max(VAPID_BODY_LIMIT)),
        )
}

fn invalid(message: &str) -> ApiError {
    ApiError::Server(ServerError::InvalidRequest {
        message: message.to_string(),
    })
}

fn unavailable(what: &str) -> ApiError {
    ApiError::Notification(NotificationError::Configuration(format!(
        "{what} indisponible (clé applicative ou clé maîtresse du coffre-fort absente)"
    )))
}

/// Clés d'un abonnement Web Push.
#[derive(Deserialize)]
struct SubscriptionKeys {
    p256dh: String,
    auth: String,
}

/// Abonnement Web Push tel que le donne le navigateur (`PushSubscription.toJSON()`).
#[derive(Deserialize)]
struct Subscription {
    endpoint: String,
    keys: SubscriptionKeys,
}

/// Corps d'une inscription d'appareil.
#[derive(Deserialize)]
#[serde(deny_unknown_fields)]
struct DeviceBody {
    tenant: Option<String>,
    provider: String,
    platform: Option<String>,
    name: Option<String>,
    token: Option<String>,
    subscription: Option<Subscription>,
}

/// Vue d'un appareil dans une réponse : jamais le jeton, les clés ni l'empreinte.
fn device_json(device: &Device) -> Value {
    json!({
        "id": device.id.to_sql(),
        "provider": device.provider,
        "platform": device.platform,
        "name": device.name,
        "host": device.host,
        "active": device.active,
    })
}

/// Clé Base64url d'un navigateur, sans remplissage.
fn unpadded(key: &str) -> String {
    key.trim().trim_end_matches('=').to_string()
}

/// `POST /my/devices` : appareil de la personne connectée, jeton et clés scellés par l'hôte.
async fn device_register(
    State(context): State<AppContext>,
    headers: HeaderMap,
    body: Bytes,
) -> Response {
    let result = async {
        let (_, session) = auth::caller_session(&context, &headers).await?;
        let body: DeviceBody = serde_json::from_slice(&body).map_err(|_| {
            invalid("corps de l'appareil : { tenant, provider, subscription | token, platform, name } attendu")
        })?;
        let codec = context
            .notification
            .as_ref()
            .and_then(|host| host.codec.as_ref())
            .ok_or_else(|| unavailable("scellement des appareils"))?;
        let tenant = super::notification::tenant_key(body.tenant.as_deref())?;
        // Jeton de l'appareil : adresse du service push (Web Push) ou jeton FCM / APNs
        let (token, keys, url) = match (body.subscription, body.token) {
            (Some(subscription), None) => {
                let token = Zeroizing::new(subscription.endpoint);
                let keys = (
                    unpadded(&subscription.keys.p256dh),
                    unpadded(&subscription.keys.auth),
                );
                (token.clone(), Some(keys), Some(token))
            }
            (None, Some(token)) => (Zeroizing::new(token), None, None),
            _ => return Err(invalid("subscription (Web Push) ou token (FCM, APNs) attendu")),
        };
        let fingerprint = device_fingerprint(&token);
        let seal = |field: DeviceField, value: &str| {
            codec.seal_device_value(
                tenant.as_deref(),
                &fingerprint,
                field,
                &SecretBytes::new(value.as_bytes().to_vec())?,
            )
        };
        let sealed_token = seal(DeviceField::Token, &token)?;
        let (p256dh, auth, sealed_p256dh, sealed_auth) = match &keys {
            Some((p256dh, auth)) => (
                Some(p256dh.clone()),
                Some(auth.clone()),
                Some(seal(DeviceField::P256dh, p256dh)?),
                Some(seal(DeviceField::Auth, auth)?),
            ),
            None => (None, None, None, None),
        };
        let web = url.is_some();
        let registered = NotificationStore::new(session)
            .my_device_register(DeviceRegisterParams {
                tenant: body.tenant,
                device: Some(uuid::Uuid::now_v7().to_string()),
                provider: body.provider,
                platform: body.platform,
                name: body.name,
                url: url.map(|url| url.to_string()),
                token: if web { None } else { Some(token.to_string()) },
                p256dh,
                auth,
                fingerprint,
                sealed_token,
                sealed_p256dh,
                sealed_auth,
            })
            .await
            .map_err(NotificationError::from)?;
        auth::ok(
            if registered.created {
                StatusCode::CREATED
            } else {
                StatusCode::OK
            },
            json!({ "created": registered.created, "device": device_json(&registered.device) }),
        )
    }
    .await;
    auth::respond(&context, &headers, result).await
}

/// `GET /push/vapid-key?tenant=` : clé publique VAPID de la portée de la personne.
async fn vapid_key(
    State(context): State<AppContext>,
    Query(query): Query<HashMap<String, String>>,
    headers: HeaderMap,
) -> Response {
    let result = async {
        let (_, session) = auth::caller_session(&context, &headers).await?;
        let host = context
            .notification
            .as_ref()
            .ok_or_else(|| unavailable("notifications"))?;
        let tenant = query.get("tenant").cloned();
        super::notification::tenant_key(tenant.as_deref())?;
        // La personne et son organisation active, vérifiées dans sa session
        NotificationStore::new(session)
            .my_device_list(MyDeviceListParams {
                tenant: tenant.clone(),
            })
            .await
            .map_err(NotificationError::from)?;
        let key = host
            .store
            .push_vapid_key(VapidKeyParams { tenant })
            .await
            .map_err(NotificationError::from)?;
        auth::ok(StatusCode::OK, json!({ "public_key": key.public_key }))
    }
    .await;
    auth::respond(&context, &headers, result).await
}

/// PEM `PRIVATE KEY` d'une clé PKCS#8 (lignes de 64 caractères).
fn pem(der: &SecretBytes) -> Zeroizing<String> {
    let encoded = Zeroizing::new(STANDARD.encode(der.expose_secret()));
    let mut text = Zeroizing::new(String::from("-----BEGIN PRIVATE KEY-----\n"));
    for line in encoded.as_bytes().chunks(64) {
        text.push_str(&String::from_utf8_lossy(line));
        text.push('\n');
    }
    text.push_str("-----END PRIVATE KEY-----\n");
    text
}

/// `POST /integrations/{integration}/vapid` : paire VAPID neuve, clé privée rangée dans le
/// coffre-fort au nom de l'appelant.
async fn vapid_generate(
    State(context): State<AppContext>,
    Path(key): Path<String>,
    headers: HeaderMap,
) -> Response {
    let result = async {
        let (_, session) = auth::caller_session(&context, &headers).await?;
        let integration = super::notification::integration_id(&key)
            .ok_or_else(|| invalid("intégration : identifiant invalide"))?;
        let secrets = context
            .secrets
            .as_ref()
            .ok_or_else(|| unavailable("coffre-fort"))?;
        let store = NotificationStore::new(session.clone());
        let current = store
            .integration_get(IntegrationGetParams { integration })
            .await
            .map_err(NotificationError::from)?;
        let path = match (
            current.channel.as_str(),
            current.provider.as_str(),
            &current.credentials_path,
        ) {
            ("push", "webpush", Some(path)) => path.clone(),
            _ => {
                return Err(invalid(
                    "intégration Web Push (canal push, fournisseur webpush) attendue",
                ))
            }
        };
        let tenant = current.tenant.as_ref().map(ToSql::to_sql);
        let pair = EcdsaP256SigningKey::generate().map_err(NotificationError::from)?;
        let public_key =
            base64::engine::general_purpose::URL_SAFE_NO_PAD.encode(pair.public_key_uncompressed());
        let private = pem(&pair.export_pkcs8());
        let value = Zeroizing::new(json!({ "private_key": private.as_str() }).to_string());
        // Clé publique notée d'abord : `integration_update` vérifie tous les droits de
        // l'appelant (gestion, lecture du secret) avant que la clé privée ne change ; un refus
        // laisse la paire en place intacte.
        let mut settings = current.settings.clone();
        settings.vapid_public_key = Some(public_key.clone());
        let save = |settings| IntegrationSaveParams {
            tenant: tenant.clone(),
            key: current.key.clone(),
            settings: Some(settings),
            ..IntegrationSaveParams::default()
        };
        store
            .integration_update(save(settings))
            .await
            .map_err(NotificationError::from)?;
        // Clé privée rangée au nom de l'appelant : droits d'écriture du coffre-fort. Échec :
        // l'ancienne clé publique est remise, accordée à la clé privée restée en place.
        let vault = secrets.service(SecretsStore::new(session));
        let stored = async {
            let secret = vault
                .store()
                .secret_get(SecretGetParams::by_path(tenant.clone(), path))
                .await
                .map_err(lyxal_secrets::SecretsError::from)?;
            vault
                .put(PutValue {
                    secret: secret.id.to_sql(),
                    value: SecretBytes::new(value.as_bytes().to_vec())
                        .map_err(NotificationError::from)?,
                    expected_version: None,
                    stage: Stage::Current,
                })
                .await?;
            Ok::<_, ApiError>(())
        }
        .await;
        if let Err(error) = stored {
            store
                .integration_update(save(current.settings.clone()))
                .await
                .map_err(NotificationError::from)?;
            return Err(error);
        }
        auth::ok(
            StatusCode::OK,
            json!({ "integration": current.id.to_sql(), "public_key": public_key }),
        )
    }
    .await;
    auth::respond(&context, &headers, result).await
}
