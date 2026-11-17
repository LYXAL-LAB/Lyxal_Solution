//! Notifications push contre de faux services locaux : Web Push (client contrôlé, jeton
//! VAPID, corps chiffré, en-têtes), FCM (jeton du compte de service échangé, jeton d'accès gardé
//! puis renouvelé, API HTTP v1), APNs (HTTP/2, jeton du fournisseur gardé 50 minutes) ; appareils
//! invalides ; de bout en bout : déclenchement → trois appareils (navigateur, Android, iPhone),
//! l'iPhone désinscrit est retiré, les deux autres servis. L'heure des jetons est une horloge
//! injectée : aucun test ne dépend de la vitesse de la machine.

use base64::engine::general_purpose::{STANDARD, URL_SAFE_NO_PAD};
use base64::Engine;
use lyxal_crypto::{EcdsaP256SigningKey, SecretBytes, SecretString};
use lyxal_notification::models::{ClaimedIntegration, IntegrationSaveParams, IntegrationSettings};
use lyxal_notification::{
    device_fingerprint, DeviceField, DeviceRemoval, JobOutcome, NotificationPushWorker,
    NotificationStore, OutboundClient, PushApi, PushClock, PushCredentials, PushDispatcher,
    PushEndpoints, PushMessage, PushService, PushTarget, SecretCodec, SendWorkerSettings,
    StaticResolver,
};
use lyxal_runtime::worker::CancellationToken;
use serde_json::{json, Value};
use std::net::SocketAddr;
use std::sync::atomic::{AtomicI64, Ordering};
use std::sync::Arc;

use crate::fake_apns::FakeApns;
use crate::fake_provider::{FakeProviders, Reply};
use crate::support::{crypto, installed_client, integration, put_secret, vault};

const NOW: i64 = 1_800_000_000;
const WEBPUSH_URL: &str = "https://updates.push.services.mozilla.com/wpush/v2/essai-abonnement";
const FCM_TOKEN: &str = "jeton-fcm-essai-0000000000000000000000000001";
const APNS_TOKEN: &str = "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef";
/// Clé RSA-2048 réservée aux tests de `lyxal_crypto` (générée pour eux, jamais utilisée ailleurs).
const RSA_PKCS8_B64: &str =
    include_str!("../../../lyxal_crypto/tests/fixtures/rsa2048_test_only.pkcs8.b64");

/// Horloge des jetons, avancée par le test.
#[derive(Clone)]
struct Clock(Arc<AtomicI64>);

impl Clock {
    fn new() -> Self {
        Self(Arc::new(AtomicI64::new(NOW)))
    }

    fn advance(&self, seconds: i64) {
        self.0.fetch_add(seconds, Ordering::SeqCst);
    }

    fn push(&self) -> PushClock {
        let inner = self.0.clone();
        Arc::new(move || inner.load(Ordering::SeqCst))
    }
}

fn pem(der: &[u8]) -> String {
    format!(
        "-----BEGIN PRIVATE KEY-----\n{}\n-----END PRIVATE KEY-----\n",
        STANDARD.encode(der)
    )
}

fn rsa_pem() -> String {
    pem(&STANDARD.decode(RSA_PKCS8_B64.trim()).expect("clé de test"))
}

fn secret(text: &str) -> SecretString {
    SecretString::new(text.to_string()).expect("secret")
}

fn value(json: Value) -> SecretBytes {
    SecretBytes::new(json.to_string().into_bytes()).expect("valeur")
}

/// Faux services : Web Push (`/wpush`), échange de jeton FCM (`/fcm-oauth`), FCM (`/fcm`).
async fn services() -> FakeProviders {
    let fake = FakeProviders::start().await;
    fake.set_default("wpush", Reply::status(201));
    fake.set_default(
        "fcm-oauth",
        Reply::json(200, json!({ "access_token": "jeton-acces-essai-1", "expires_in": 3600, "token_type": "Bearer" })),
    );
    fake.set_default(
        "fcm",
        Reply::json(
            200,
            json!({ "name": "projects/lyxal-essai/messages/0:essai" }),
        ),
    );
    fake
}

fn api(fake: &FakeProviders, apns: &FakeApns, clock: &Clock) -> Arc<PushApi> {
    let local: SocketAddr = format!("127.0.0.1:{}", fake.port())
        .parse()
        .expect("adresse");
    let resolver = StaticResolver::new().with("updates.push.services.mozilla.com", local);
    Arc::new(
        PushApi::for_local_tests(
            PushEndpoints::local(&fake.base, &apns.base).expect("adresses"),
            Arc::new(OutboundClient::for_local_tests(resolver)),
            clock.push(),
        )
        .expect("client"),
    )
}

fn claimed(provider: &str, settings: IntegrationSettings) -> ClaimedIntegration {
    ClaimedIntegration {
        id: lyxal_surreal::RecordId::new("notification_integration", provider),
        tenant: None,
        key: provider.to_string(),
        channel: "push".into(),
        provider: provider.into(),
        settings,
        credentials_path: Some(format!("notification/push/{provider}")),
        webhook_path: None,
    }
}

fn message(urgent: bool) -> PushMessage {
    PushMessage {
        title: "Devis 7".into(),
        body: "Votre devis est prêt".into(),
        link: Some("/devis/7".into()),
        icon: Some("https://alpha.test/icone.png".into()),
        data: [("devis".to_string(), json!("7"))].into_iter().collect(),
        urgent,
    }
}

/// En-tête et revendications d'un jeton JWS (la signature est vérifiée par les tests de
/// `lyxal_crypto` ; ici : forme et longueur).
fn jwt(token: &str, signature_len: usize) -> (Value, Value) {
    let parts: Vec<&str> = token.split('.').collect();
    assert_eq!(parts.len(), 3, "jeton compact");
    let decode = |part: &str| -> Value {
        serde_json::from_slice(&URL_SAFE_NO_PAD.decode(part).expect("base64url")).expect("json")
    };
    assert_eq!(
        URL_SAFE_NO_PAD.decode(parts[2]).expect("signature").len(),
        signature_len
    );
    (decode(parts[0]), decode(parts[1]))
}

#[tokio::test]
async fn web_push_sends_an_encrypted_body_with_a_vapid_token() {
    let fake = services().await;
    let apns = FakeApns::start().await;
    let clock = Clock::new();
    let api = api(&fake, &apns, &clock);
    let vapid = EcdsaP256SigningKey::generate().expect("clé VAPID");
    let public = URL_SAFE_NO_PAD.encode(vapid.public_key_uncompressed());
    let credentials = PushCredentials::parse(
        PushService::WebPush,
        &value(json!({ "private_key": pem(vapid.export_pkcs8().expose_secret()) })),
    )
    .expect("identifiants");
    let integration = claimed(
        "webpush",
        IntegrationSettings {
            vapid_subject: Some("mailto:contact@alpha.test".into()),
            vapid_public_key: Some(public.clone()),
            ..IntegrationSettings::default()
        },
    );
    let browser = EcdsaP256SigningKey::generate().expect("clé du navigateur");
    let endpoint = secret(WEBPUSH_URL);
    let target = PushTarget::WebPush {
        endpoint: &endpoint,
        p256dh: browser.public_key_uncompressed(),
        auth: zeroize::Zeroizing::new([7u8; 16]),
    };
    let message = message(false);
    let receipt = api
        .send(&integration, &credentials, &target, &message)
        .await
        .expect("accepté");
    assert_eq!(receipt.code, 201);
    let request = fake.requests_to("wpush").pop().expect("requête");
    assert_eq!(request.method, "POST");
    assert_eq!(request.path, "/wpush/v2/essai-abonnement");
    assert_eq!(request.header("content-encoding"), Some("aes128gcm"));
    assert_eq!(
        request.header("content-type"),
        Some("application/octet-stream")
    );
    assert_eq!(request.header("ttl"), Some("86400"));
    assert_eq!(request.header("urgency"), Some("normal"));
    // Corps chiffré : contenu JSON + en-tête RFC 8188 (86 octets), délimiteur et étiquette
    let plaintext = serde_json::to_vec(&message.content()).expect("json").len();
    assert_eq!(
        request.header("content-length"),
        Some((plaintext + 103).to_string().as_str())
    );
    assert!(!request.body.contains("Votre devis"));
    let authorization = request.header("authorization").expect("autorisation");
    let (token, key) = authorization
        .strip_prefix("vapid t=")
        .and_then(|rest| rest.split_once(", k="))
        .expect("vapid t=…, k=…");
    assert_eq!(key, public);
    let (header, claims) = jwt(token, 64);
    assert_eq!(header, json!({ "typ": "JWT", "alg": "ES256" }));
    assert_eq!(
        claims,
        json!({ "aud": "https://updates.push.services.mozilla.com", "exp": NOW + 12 * 3600, "sub": "mailto:contact@alpha.test" })
    );

    // Abonnement expiré (410, 404) : appareil à retirer ; 429 : temporaire, gardé
    for (status, removal) in [
        (410, Some(DeviceRemoval::Expired)),
        (404, Some(DeviceRemoval::Expired)),
        (429, None),
    ] {
        fake.script("wpush", vec![Reply::status(status)]);
        let failure = api
            .send(&integration, &credentials, &target, &message)
            .await
            .expect_err("refus");
        assert_eq!(failure.removal, removal, "{status}");
    }
    // Service push inconnu : refusé sans appel
    let before = fake.requests_to("wpush").len();
    let pirate = secret("https://push.pirate.test/abonnement");
    let failure = api
        .send(
            &integration,
            &credentials,
            &PushTarget::WebPush {
                endpoint: &pirate,
                p256dh: browser.public_key_uncompressed(),
                auth: zeroize::Zeroizing::new([7u8; 16]),
            },
            &message,
        )
        .await
        .expect_err("refusé");
    assert_eq!(failure.error.code, "NOTIFICATION_DESTINATION_FORBIDDEN");
    // Clé publique des réglages différente de la clé du coffre-fort : refus sans appel
    let mismatched = claimed(
        "webpush",
        IntegrationSettings {
            vapid_subject: Some("mailto:contact@alpha.test".into()),
            vapid_public_key: Some(URL_SAFE_NO_PAD.encode(browser.public_key_uncompressed())),
            ..IntegrationSettings::default()
        },
    );
    let failure = api
        .send(&mismatched, &credentials, &target, &message)
        .await
        .expect_err("clé différente");
    assert_eq!(failure.error.code, "NOTIFICATION_CONFIGURATION_INVALID");
    assert_eq!(fake.requests_to("wpush").len(), before);
}

#[tokio::test]
async fn fcm_exchanges_and_keeps_its_access_token() {
    let fake = services().await;
    let apns = FakeApns::start().await;
    let clock = Clock::new();
    let api = api(&fake, &apns, &clock);
    let credentials = PushCredentials::parse(
        PushService::Fcm,
        &value(json!({
            "type": "service_account",
            "project_id": "lyxal-essai",
            "private_key_id": "cle-essai-1",
            "private_key": rsa_pem(),
            "client_email": "envoi@essai.test",
            "token_uri": "https://ignore.test/token"
        })),
    )
    .expect("compte de service");
    let integration = claimed(
        "fcm",
        IntegrationSettings {
            project_id: Some("lyxal-essai".into()),
            ..IntegrationSettings::default()
        },
    );
    let token = secret(FCM_TOKEN);
    let target = PushTarget::Fcm { token: &token };
    let receipt = api
        .send(&integration, &credentials, &target, &message(true))
        .await
        .expect("accepté");
    assert_eq!(
        receipt.message_id.as_deref(),
        Some("projects/lyxal-essai/messages/0:essai")
    );
    let exchange = fake.requests_to("fcm-oauth").pop().expect("échange");
    let form: std::collections::HashMap<String, String> = exchange.form().into_iter().collect();
    assert_eq!(
        form.get("grant_type").map(String::as_str),
        Some("urn:ietf:params:oauth:grant-type:jwt-bearer")
    );
    let (header, claims) = jwt(form.get("assertion").expect("assertion"), 256);
    assert_eq!(
        header,
        json!({ "alg": "RS256", "typ": "JWT", "kid": "cle-essai-1" })
    );
    assert_eq!(
        claims,
        json!({
            "iss": "envoi@essai.test",
            "scope": "https://www.googleapis.com/auth/firebase.messaging",
            "aud": format!("{}/fcm-oauth/token", fake.base),
            "iat": NOW,
            "exp": NOW + 3600
        })
    );
    let send = fake.requests_to("fcm").pop().expect("envoi");
    assert_eq!(send.path, "/fcm/v1/projects/lyxal-essai/messages:send");
    assert_eq!(
        send.header("authorization"),
        Some("Bearer jeton-acces-essai-1")
    );
    let body = send.json();
    assert_eq!(body["message"]["token"], json!(FCM_TOKEN));
    assert_eq!(
        body["message"]["notification"],
        json!({ "title": "Devis 7", "body": "Votre devis est prêt" })
    );
    assert_eq!(body["message"]["data"]["link"], json!("/devis/7"));
    assert_eq!(body["message"]["android"]["priority"], json!("HIGH"));

    // Jeton d'accès gardé : pas de nouvel échange ; renouvelé à son échéance (horloge avancée)
    api.send(&integration, &credentials, &target, &message(false))
        .await
        .expect("accepté");
    assert_eq!(fake.requests_to("fcm-oauth").len(), 1);
    clock.advance(3600);
    api.send(&integration, &credentials, &target, &message(false))
        .await
        .expect("accepté");
    assert_eq!(fake.requests_to("fcm-oauth").len(), 2);
    // 401 : jeton d'accès oublié, nouvel échange et nouvel envoi aussitôt
    fake.script("fcm", vec![Reply::status(401)]);
    api.send(&integration, &credentials, &target, &message(false))
        .await
        .expect("accepté après un nouveau jeton");
    assert_eq!(fake.requests_to("fcm-oauth").len(), 3);

    // Appareil désinscrit ou jeton invalide : à retirer ; quota : temporaire
    let unregistered = json!({ "error": { "code": 404, "status": "NOT_FOUND", "details": [{ "errorCode": "UNREGISTERED" }] } });
    let invalid = json!({ "error": { "code": 400, "status": "INVALID_ARGUMENT", "message": "The registration token is not a valid FCM registration token" } });
    for (reply, removal) in [
        (Reply::json(404, unregistered), Some(DeviceRemoval::Expired)),
        (Reply::json(400, invalid), Some(DeviceRemoval::Invalid)),
        (Reply::status(503), None),
    ] {
        fake.script("fcm", vec![reply]);
        let failure = api
            .send(&integration, &credentials, &target, &message(false))
            .await
            .expect_err("refus");
        assert_eq!(failure.removal, removal);
    }
    // Échange refusé (clé révoquée) : refus définitif, sans envoi
    clock.advance(3600);
    fake.script(
        "fcm-oauth",
        vec![Reply::json(400, json!({ "error": "invalid_grant" }))],
    );
    let sends = fake.requests_to("fcm").len();
    let failure = api
        .send(&integration, &credentials, &target, &message(false))
        .await
        .expect_err("échange refusé");
    assert_eq!(failure.error.code, "NOTIFICATION_PROVIDER_REJECTED");
    assert_eq!(fake.requests_to("fcm").len(), sends);
}

#[tokio::test]
async fn apns_uses_http2_and_renews_its_provider_token() {
    let fake = services().await;
    let apns = FakeApns::start().await;
    let clock = Clock::new();
    let api = api(&fake, &apns, &clock);
    let p8 = EcdsaP256SigningKey::generate().expect("clé APNs");
    let credentials = PushCredentials::parse(
        PushService::Apns,
        &value(json!({ "key_id": "CLEESSAI01", "private_key": pem(p8.export_pkcs8().expose_secret()) })),
    )
    .expect("clé APNs");
    let integration = claimed(
        "apns",
        IntegrationSettings {
            team_id: Some("EQUIPE0001".into()),
            bundle_id: Some("fr.lyxal.essai".into()),
            environment: Some("sandbox".into()),
            ..IntegrationSettings::default()
        },
    );
    let token = secret(APNS_TOKEN);
    let target = PushTarget::Apns { token: &token };
    let receipt = api
        .send(&integration, &credentials, &target, &message(false))
        .await
        .expect("accepté");
    assert_eq!(
        receipt.message_id.as_deref(),
        Some("0190a5b2-7c3e-7d4a-9b1c-0000000000ff")
    );
    let request = apns.requests().pop().expect("requête");
    assert!(request.http2, "HTTP/2");
    assert_eq!(request.path, format!("/apns-sandbox/3/device/{APNS_TOKEN}"));
    assert_eq!(
        request.headers.get("apns-topic").map(String::as_str),
        Some("fr.lyxal.essai")
    );
    assert_eq!(
        request.headers.get("apns-push-type").map(String::as_str),
        Some("alert")
    );
    assert_eq!(
        request.headers.get("apns-priority").map(String::as_str),
        Some("5")
    );
    assert_eq!(
        request.headers.get("apns-expiration").map(String::as_str),
        Some((NOW + 86_400).to_string().as_str())
    );
    assert_eq!(
        request.body["aps"]["alert"],
        json!({ "title": "Devis 7", "body": "Votre devis est prêt" })
    );
    assert_eq!(request.body["link"], json!("/devis/7"));
    let first = request.headers["authorization"].clone();
    let (header, claims) = jwt(first.strip_prefix("bearer ").expect("bearer"), 64);
    assert_eq!(header, json!({ "alg": "ES256", "kid": "CLEESSAI01" }));
    assert_eq!(claims, json!({ "iss": "EQUIPE0001", "iat": NOW }));

    // Jeton du fournisseur gardé 50 minutes, puis renouvelé
    clock.advance(49 * 60);
    api.send(&integration, &credentials, &target, &message(false))
        .await
        .expect("accepté");
    assert_eq!(
        apns.requests().pop().expect("requête").headers["authorization"],
        first
    );
    clock.advance(2 * 60);
    api.send(&integration, &credentials, &target, &message(false))
        .await
        .expect("accepté");
    let renewed = apns.requests().pop().expect("requête").headers["authorization"].clone();
    assert_ne!(renewed, first);
    let (_, claims) = jwt(renewed.strip_prefix("bearer ").expect("bearer"), 64);
    assert_eq!(claims["iat"], json!(NOW + 51 * 60));

    // Jeton refusé par Apple (expiré) : renouvelé et l'envoi refait une fois
    clock.advance(60);
    apns.script(vec![(403, Some("ExpiredProviderToken"))]);
    let count = apns.requests().len();
    api.send(&integration, &credentials, &target, &message(false))
        .await
        .expect("accepté après un nouveau jeton");
    let requests = apns.requests();
    assert_eq!(requests.len(), count + 2);
    assert_ne!(
        requests[count].headers["authorization"],
        requests[count + 1].headers["authorization"]
    );
    // Appareil désinscrit ou jeton refusé : à retirer ; autre refus : gardé
    for (status, reason, removal) in [
        (410, "Unregistered", Some(DeviceRemoval::Expired)),
        (400, "BadDeviceToken", Some(DeviceRemoval::Invalid)),
        (400, "BadTopic", None),
    ] {
        apns.script(vec![(status, Some(reason))]);
        let failure = api
            .send(&integration, &credentials, &target, &message(false))
            .await
            .expect_err("refus");
        assert_eq!(failure.removal, removal, "{reason}");
    }
}

/// Base, coffre-fort, trois intégrations push de l'organisation Alpha, abonné et trois appareils
/// scellés comme le fait l'hôte, parcours push.
async fn prepared(
    fake: &FakeProviders,
    apns: &FakeApns,
    clock: &Clock,
) -> (
    surrealdb::Surreal<surrealdb::engine::any::Any>,
    NotificationPushWorker<lyxal_crypto::StaticKeyResolver>,
) {
    let client = installed_client().await;
    let vault = vault(&client);
    let codec = SecretCodec::new(crypto());
    client
        .query(
            r#"
            CREATE auth_organization:alpha CONTENT { slug: "alpha", name: "Alpha BTP" };
            CREATE notification_workflow:rappel CONTENT { tenant: auth_organization:alpha, key: "rappel", name: "Rappel", status: "active", steps: [{ key: "push", type: "push" }] };
            CREATE notification_template:rappel CONTENT { tenant: auth_organization:alpha, workflow: notification_workflow:rappel, step_key: "push",
                subject: "Devis {{ payload.n }}", text_body: "Votre devis {{ payload.n }} est prêt", redirect: "/devis/{{ payload.n }}", data: { devis: "{{ payload.n }}" } };
            fn::notification_subscriber_save({ tenant: auth_organization:alpha, input: { subscriber_id: "s1", email: "s1@exemple.fr" }, must_exist: false });
            "#,
        )
        .await
        .expect("préparation")
        .check()
        .expect("préparation acceptée");
    let vapid = EcdsaP256SigningKey::generate().expect("clé VAPID");
    let p8 = EcdsaP256SigningKey::generate().expect("clé APNs");
    let tenant = Some("auth_organization:alpha");
    put_secret(
        &client,
        &vault,
        tenant,
        "notification/push/webpush",
        &json!({ "private_key": pem(vapid.export_pkcs8().expose_secret()) }).to_string(),
    )
    .await;
    put_secret(
        &client,
        &vault,
        tenant,
        "notification/push/fcm",
        &json!({ "client_email": "envoi@essai.test", "private_key": rsa_pem() }).to_string(),
    )
    .await;
    put_secret(
        &client,
        &vault,
        tenant,
        "notification/push/apns",
        &json!({ "key_id": "CLEESSAI01", "private_key": pem(p8.export_pkcs8().expose_secret()) })
            .to_string(),
    )
    .await;
    for (provider, settings) in [
        (
            "webpush",
            IntegrationSettings {
                vapid_subject: Some("mailto:contact@alpha.test".into()),
                vapid_public_key: Some(URL_SAFE_NO_PAD.encode(vapid.public_key_uncompressed())),
                ..IntegrationSettings::default()
            },
        ),
        (
            "fcm",
            IntegrationSettings {
                project_id: Some("lyxal-essai".into()),
                ..IntegrationSettings::default()
            },
        ),
        (
            "apns",
            IntegrationSettings {
                team_id: Some("EQUIPE0001".into()),
                bundle_id: Some("fr.lyxal.essai".into()),
                environment: Some("production".into()),
                ..IntegrationSettings::default()
            },
        ),
    ] {
        integration(
            &client,
            IntegrationSaveParams {
                tenant: Some("auth_organization:alpha".into()),
                key: provider.into(),
                channel: Some("push".into()),
                provider: Some(provider.into()),
                name: Some(provider.into()),
                settings: Some(settings),
                credentials_path: Some(format!("notification/push/{provider}")),
                ..IntegrationSaveParams::default()
            },
        )
        .await;
    }
    // Appareils scellés comme le fait l'hôte : empreinte du jeton, contexte de l'organisation
    let browser = EcdsaP256SigningKey::generate().expect("clé du navigateur");
    let p256dh = URL_SAFE_NO_PAD.encode(browser.public_key_uncompressed());
    let auth = URL_SAFE_NO_PAD.encode([9u8; 16]);
    let seal = |fingerprint: &str, field, text: &str| {
        codec
            .seal_device_value(
                Some("alpha"),
                fingerprint,
                field,
                &SecretBytes::new(text.as_bytes().to_vec()).expect("valeur"),
            )
            .expect("scellement")
    };
    for (key, provider, platform, host, token) in [
        (
            "web",
            "webpush",
            "web",
            "updates.push.services.mozilla.com",
            WEBPUSH_URL,
        ),
        ("android", "fcm", "android", "fcm.googleapis.com", FCM_TOKEN),
        ("iphone", "apns", "ios", "api.push.apple.com", APNS_TOKEN),
    ] {
        let fingerprint = device_fingerprint(token);
        let web = provider == "webpush";
        client
            .query(
                r#"CREATE type::record("notification_endpoint", $key) CONTENT {
                    tenant: auth_organization:alpha,
                    subscriber: (SELECT VALUE id FROM ONLY notification_subscriber WHERE subscriber_id = "s1" LIMIT 1),
                    channel: "push", provider: $provider, platform: $platform, name: $key, host: $host,
                    fingerprint: $fingerprint, token: $sealed_token, p256dh: $p256dh, auth: $browser_auth,
                    registered_at: time::now(), active: true
                }"#,
            )
            .bind(("key", key))
            .bind(("provider", provider))
            .bind(("platform", platform))
            .bind(("host", host))
            .bind(("fingerprint", fingerprint.clone()))
            .bind(("sealed_token", seal(&fingerprint, DeviceField::Token, token)))
            .bind(("p256dh", web.then(|| seal(&fingerprint, DeviceField::P256dh, &p256dh))))
            .bind(("browser_auth", web.then(|| seal(&fingerprint, DeviceField::Auth, &auth))))
            .await
            .expect("appareil")
            .check()
            .expect("appareil accepté");
    }
    let dispatcher = PushDispatcher::new(api(fake, apns, clock), vault.clone());
    let worker = NotificationPushWorker::new(
        NotificationStore::new(client.clone()),
        codec,
        dispatcher,
        SendWorkerSettings::default(),
    )
    .expect("worker");
    (client, worker)
}

async fn json_of(client: &surrealdb::Surreal<surrealdb::engine::any::Any>, query: &str) -> Value {
    let mut response = client.query(query).await.expect("requête");
    let value: surrealdb::types::Value = response.take(0).expect("valeur");
    value.into_json_value()
}

#[tokio::test]
async fn trigger_reaches_three_devices_and_removes_the_unregistered_iphone() {
    let fake = services().await;
    let apns = FakeApns::start().await;
    let clock = Clock::new();
    let (client, worker) = prepared(&fake, &apns, &clock).await;
    apns.script(vec![(410, Some("Unregistered"))]);
    let triggered = json_of(
        &client,
        r#"RETURN fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "rappel", idempotency_key: "rappel-1", to: { subscriber_id: "s1" }, payload: { n: 7 } }).data.status"#,
    )
    .await;
    assert_eq!(triggered, json!("created"));

    // Arrêt avant le tour : rien n'est réservé ni envoyé
    let stopped = CancellationToken::new();
    stopped.cancel();
    assert!(worker.run_once(&stopped).await.expect("tour").is_empty());
    assert!(fake.requests_to("wpush").is_empty());

    let outcomes = worker
        .run_once(&CancellationToken::new())
        .await
        .expect("tour");
    assert_eq!(outcomes, vec![JobOutcome::Sent]);
    // Navigateur et Android servis (contenu rendu, lien et données), iPhone désinscrit
    let web = fake.requests_to("wpush");
    assert_eq!(web.len(), 1);
    assert!(web[0]
        .header("authorization")
        .is_some_and(|a| a.starts_with("vapid t=")));
    let android = fake.requests_to("fcm").pop().expect("FCM");
    assert_eq!(
        android.json()["message"]["notification"],
        json!({ "title": "Devis 7", "body": "Votre devis 7 est prêt" })
    );
    assert_eq!(android.json()["message"]["data"]["link"], json!("/devis/7"));
    assert_eq!(android.json()["message"]["data"]["devis"], json!("7"));
    assert_eq!(apns.requests().len(), 1);
    assert_eq!(
        apns.requests()[0].path,
        format!("/apns/3/device/{APNS_TOKEN}")
    );

    let state = json_of(
        &client,
        r#"RETURN {
            job: (SELECT VALUE status FROM ONLY notification_job LIMIT 1),
            run: (SELECT VALUE status FROM ONLY notification_run LIMIT 1),
            messages: (SELECT VALUE to FROM notification_message ORDER BY to),
            devices: (SELECT VALUE record::id(id) FROM notification_endpoint WHERE channel = "push" ORDER BY name),
            removed: (SELECT VALUE payload FROM event_outbox WHERE event_type = "notification.endpoint.removed")
        }"#,
    )
    .await;
    assert_eq!(state["job"], json!("completed"));
    assert_eq!(state["run"], json!("completed"));
    assert_eq!(state["messages"], json!(["fcm:android", "webpush:web"]));
    assert_eq!(state["devices"], json!(["android", "web"]));
    assert_eq!(
        state["removed"][0]["endpoint_id"],
        json!("notification_endpoint:iphone")
    );
    assert_eq!(
        state["removed"][0].as_object().map(|o| o.len()),
        Some(4),
        "identifiants et canal seulement"
    );
    // Aucun jeton ni clé en clair en base ni dans un événement
    let everything = json_of(
        &client,
        "RETURN [(SELECT * FROM notification_endpoint), (SELECT * FROM notification_message), (SELECT * FROM event_outbox), (SELECT * FROM notification_delivery_log)]",
    )
    .await
    .to_string();
    for clear in [WEBPUSH_URL, "essai-abonnement", FCM_TOKEN, APNS_TOKEN] {
        assert!(!everything.contains(clear), "{clear} en clair");
    }
}

#[tokio::test]
async fn an_only_device_unregistered_fails_the_step_and_is_removed() {
    let fake = services().await;
    let apns = FakeApns::start().await;
    let clock = Clock::new();
    let (client, worker) = prepared(&fake, &apns, &clock).await;
    client
        .query(r#"DELETE notification_endpoint:web, notification_endpoint:android"#)
        .await
        .expect("appareils retirés")
        .check()
        .expect("suppression");
    apns.script(vec![(400, Some("BadDeviceToken"))]);
    json_of(
        &client,
        r#"RETURN fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "rappel", idempotency_key: "rappel-2", to: { subscriber_id: "s1" }, payload: { n: 8 } }).data.status"#,
    )
    .await;
    let outcomes = worker
        .run_once(&CancellationToken::new())
        .await
        .expect("tour");
    assert_eq!(
        outcomes,
        vec![JobOutcome::Failed(
            lyxal_notification::models::FailureClass::Permanent
        )]
    );
    let state = json_of(
        &client,
        r#"RETURN {
            job: (SELECT status, last_error.code AS code FROM ONLY notification_job LIMIT 1),
            devices: count(SELECT id FROM notification_endpoint WHERE channel = "push")
        }"#,
    )
    .await;
    assert_eq!(
        state["job"],
        json!({ "status": "failed", "code": "NOTIFICATION_DEVICE_INVALID" })
    );
    assert_eq!(state["devices"], json!(0));
}
