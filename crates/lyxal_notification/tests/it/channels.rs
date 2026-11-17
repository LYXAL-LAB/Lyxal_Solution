//! SMS, messageries d'équipe et adresses web contre de faux services locaux. Chaque
//! fournisseur de SMS (requête, identifiants, refus classés) ; chaque messagerie (corps, chemin,
//! jeton Telegram) ; contrôles SSRF du client sortant (adresse privée IPv4 et IPv6, nom qui se
//! résout en adresse privée, HTTP, adresse IP, redirection non suivie, liste d'hôtes) ; appel
//! d'une adresse web vérifiable par son destinataire ; de bout en bout : déclenchement → SMS
//! (Twilio) + messagerie (Slack) + adresse web, adresses scellées jamais en clair en base, retour
//! Twilio signé → numéro supprimé ; SMS rendu trop long refusé sans envoi.

use lyxal_crypto::{verify_hmac_sha256_hex, HmacKey, SecretBytes, SecretString};
use lyxal_notification::models::{
    EndpointCreateParams, FailureClass, IntegrationSaveParams, IntegrationSettings,
};
use lyxal_notification::{
    generate_signing_key, ChannelDispatcher, ChatSender, ChatService, ChatTarget, EndpointField,
    JobOutcome, NotificationChannelWorker, NotificationStore, OutboundClient, SecretCodec,
    SendWorkerSettings, SmsApi, SmsCredentials, SmsMessage, SmsProvider, StaticResolver,
    TextChannel, WebhookRequest,
};
use lyxal_runtime::worker::CancellationToken;
use lyxal_surreal::ToSql;
use std::net::SocketAddr;
use std::sync::Arc;
use surrealdb::engine::any::Any;
use surrealdb::Surreal;

use crate::fake_provider::{FakeProviders, Reply};
use crate::support::{crypto, installed_client, integration, put_secret, vault};

const TELEGRAM_TOKEN: &str = "123:essai_jeton";

/// Faux services : SMS, messageries et adresse web sous des préfixes de chemin.
async fn services() -> FakeProviders {
    let fake = FakeProviders::start().await;
    for (prefix, reply) in [
        (
            "brevo-sms",
            Reply::json(
                201,
                serde_json::json!({ "reference": "essai", "messageId": 1_511_882_900_176_220_i64 }),
            ),
        ),
        (
            "twilio",
            Reply::json(
                201,
                serde_json::json!({ "sid": "SMessai0001", "status": "queued" }),
            ),
        ),
        (
            "vonage",
            Reply::json(
                200,
                serde_json::json!({ "message-count": "1", "messages": [{ "status": "0", "message-id": "0A00essai" }] }),
            ),
        ),
        (
            "services",
            Reply {
                status: 200,
                headers: Vec::new(),
                body: "ok".to_string(),
            },
        ),
        ("webhookb2", Reply::status(202)),
        ("api", Reply::status(204)),
        (
            "hooks",
            Reply {
                status: 200,
                headers: Vec::new(),
                body: "ok".to_string(),
            },
        ),
        (
            "v1",
            Reply::json(
                200,
                serde_json::json!({ "name": "spaces/essai/messages/m1" }),
            ),
        ),
        (
            &format!("bot{TELEGRAM_TOKEN}"),
            Reply::json(
                200,
                serde_json::json!({ "ok": true, "result": { "message_id": 57 } }),
            ),
        ),
        ("lyxal-hook", Reply::status(204)),
    ] {
        fake.set_default(prefix, reply);
    }
    fake
}

fn local(fake: &FakeProviders) -> SocketAddr {
    SocketAddr::from(([127, 0, 0, 1], fake.port()))
}

/// Table de résolution : hôtes officiels et publics vers le faux service local ; noms privés.
fn resolver(fake: &FakeProviders) -> StaticResolver {
    let mut table = StaticResolver::new();
    for host in [
        "hooks.slack.com",
        "alpha.webhook.office.com",
        "discord.com",
        "chat.exemple.fr",
        "chat.googleapis.com",
        "api.telegram.org",
        "crm.exemple.fr",
        "hooks.exemple.fr",
    ] {
        table = table.with(host, local(fake));
    }
    table
        .with(
            "prive4.exemple.fr",
            "10.0.0.8:443".parse().expect("adresse"),
        )
        .with(
            "prive6.exemple.fr",
            "[fd00::1]:443".parse().expect("adresse"),
        )
        .with(
            "mappe.exemple.fr",
            "[::ffff:192.168.1.10]:443".parse().expect("adresse"),
        )
        .with(
            "metadonnees.exemple.fr",
            "169.254.169.254:443".parse().expect("adresse"),
        )
        // Un nom qui mêle une adresse publique et une adresse privée est refusé en entier
        .with(
            "melange.exemple.fr",
            "8.8.8.8:443".parse().expect("adresse"),
        )
        .with(
            "melange.exemple.fr",
            "10.0.0.9:443".parse().expect("adresse"),
        )
}

fn secret(text: &str) -> SecretString {
    SecretString::new(text.to_string()).expect("secret")
}

fn sender(fake: &FakeProviders) -> ChatSender {
    ChatSender::new(OutboundClient::for_local_tests(resolver(fake))).expect("client")
}

#[tokio::test]
async fn sms_providers_send_to_their_api_and_classify_refusals() {
    let fake = services().await;
    let api = SmsApi::for_local_tests(&fake.base).expect("faux fournisseurs");
    let settings = IntegrationSettings {
        sender: Some("Alpha".into()),
        ..IntegrationSettings::default()
    };
    let message = |text: &str, unicode: bool| SmsMessage {
        to: "+33612345678".into(),
        text: text.into(),
        unicode,
        status_callback: Some("https://lyxal.exemple.fr/api/v1/notification/webhooks/i1".into()),
    };
    let bytes = |text: &str| SecretBytes::new(text.as_bytes().to_vec()).expect("valeur");

    // Brevo : JSON, en-tête api-key, numéro sans « + », Unicode signalé
    let brevo = SmsCredentials::parse(
        SmsProvider::Brevo,
        &bytes(r#"{"api_key":"essai_cle_brevo"}"#),
    )
    .expect("identifiants");
    let receipt = api
        .send(
            SmsProvider::Brevo,
            &settings,
            &message("Devis prêt", true),
            &brevo,
        )
        .await
        .expect("accepté");
    assert_eq!(receipt.message_id.as_deref(), Some("1511882900176220"));
    let request = &fake.requests_to("brevo-sms")[0];
    assert_eq!(request.path, "/brevo-sms/v3/transactionalSMS/sms");
    assert_eq!(request.header("api-key"), Some("essai_cle_brevo"));
    let body = request.json();
    assert_eq!(body["recipient"], "33612345678");
    assert_eq!(body["sender"], "Alpha");
    assert_eq!(body["content"], "Devis prêt");
    assert_eq!(body["unicodeEnabled"], true);
    assert_eq!(
        body["webUrl"],
        "https://lyxal.exemple.fr/api/v1/notification/webhooks/i1"
    );

    // Twilio : formulaire, Basic (compte, jeton), compte dans le chemin, StatusCallback
    let twilio = SmsCredentials::parse(
        SmsProvider::Twilio,
        &bytes(r#"{"account_sid":"essai_compte","auth_token":"essai_jeton_twilio"}"#),
    )
    .expect("identifiants");
    let receipt = api
        .send(
            SmsProvider::Twilio,
            &settings,
            &message("Devis pret", false),
            &twilio,
        )
        .await
        .expect("accepté");
    assert_eq!(receipt.message_id.as_deref(), Some("SMessai0001"));
    let request = &fake.requests_to("twilio")[0];
    assert_eq!(
        request.path,
        "/twilio/2010-04-01/Accounts/essai_compte/Messages.json"
    );
    assert!(request
        .header("authorization")
        .is_some_and(|h| h.starts_with("Basic ")));
    let form = request.form();
    let field = |name: &str| form.iter().find(|(k, _)| k == name).map(|(_, v)| v.clone());
    assert_eq!(field("To").as_deref(), Some("+33612345678"));
    assert_eq!(field("From").as_deref(), Some("Alpha"));
    assert_eq!(field("Body").as_deref(), Some("Devis pret"));
    assert!(field("StatusCallback").is_some());

    // Vonage : formulaire avec clé et secret, numéro sans « + », type unicode
    let vonage = SmsCredentials::parse(
        SmsProvider::Vonage,
        &bytes(r#"{"api_key":"essai_cle","api_secret":"essai_secret"}"#),
    )
    .expect("identifiants");
    let receipt = api
        .send(
            SmsProvider::Vonage,
            &settings,
            &message("Être là", true),
            &vonage,
        )
        .await
        .expect("accepté");
    assert_eq!(receipt.message_id.as_deref(), Some("0A00essai"));
    let form = fake.requests_to("vonage")[0].form();
    let field = |name: &str| form.iter().find(|(k, _)| k == name).map(|(_, v)| v.clone());
    assert_eq!(field("to").as_deref(), Some("33612345678"));
    assert_eq!(field("type").as_deref(), Some("unicode"));
    assert_eq!(field("api_secret").as_deref(), Some("essai_secret"));

    // Refus classés : numéro invalide, désinscrit (STOP), numéro bloqué, panne, redirection
    fake.script(
        "twilio",
        vec![
            Reply::json(
                400,
                serde_json::json!({ "code": 21211, "message": "invalid To" }),
            ),
            Reply::json(
                400,
                serde_json::json!({ "code": 21610, "message": "unsubscribed" }),
            ),
            Reply::redirect("http://127.0.0.1:9/ailleurs"),
        ],
    );
    let send = |provider, credentials| {
        let api = &api;
        let settings = &settings;
        async move {
            api.send(provider, settings, &message("Code", false), credentials)
                .await
        }
    };
    assert_eq!(
        send(SmsProvider::Twilio, &twilio)
            .await
            .map_err(|e| e.class),
        Err(FailureClass::RecipientRejected)
    );
    assert_eq!(
        send(SmsProvider::Twilio, &twilio)
            .await
            .map_err(|e| e.class),
        Err(FailureClass::RecipientOptedOut)
    );
    assert_eq!(
        send(SmsProvider::Twilio, &twilio)
            .await
            .map_err(|e| e.class),
        Err(FailureClass::Permanent)
    );
    fake.script(
        "vonage",
        vec![Reply::json(
            200,
            serde_json::json!({ "messages": [{ "status": "7" }] }),
        )],
    );
    assert_eq!(
        send(SmsProvider::Vonage, &vonage)
            .await
            .map_err(|e| e.class),
        Err(FailureClass::RecipientOptedOut)
    );
    fake.script("brevo-sms", vec![Reply::status(503), Reply::status(429)]);
    assert_eq!(
        send(SmsProvider::Brevo, &brevo).await.map_err(|e| e.class),
        Err(FailureClass::Transient)
    );
    assert_eq!(
        send(SmsProvider::Brevo, &brevo).await.map_err(|e| e.class),
        Err(FailureClass::Transient)
    );
    // Identifiants d'un autre fournisseur : refus avant tout appel
    let before = fake.requests().len();
    assert!(send(SmsProvider::Brevo, &twilio).await.is_err());
    assert_eq!(fake.requests().len(), before);
    // Redirection jamais suivie : aucune requête vers la cible
    assert!(fake.requests().iter().all(|r| !r.path.contains("ailleurs")));
}

#[tokio::test]
async fn chat_services_receive_their_own_body() {
    let fake = services().await;
    let chat = sender(&fake);
    let cases = [
        (
            ChatService::Slack,
            "https://hooks.slack.com/services/essai/salon/faux",
            "/services/essai/salon/faux",
        ),
        (
            ChatService::Teams,
            "https://alpha.webhook.office.com/webhookb2/essai",
            "/webhookb2/essai",
        ),
        (
            ChatService::Discord,
            "https://discord.com/api/webhooks/1/essai",
            "/api/webhooks/1/essai",
        ),
        (
            ChatService::Mattermost,
            "https://chat.exemple.fr/hooks/essai",
            "/hooks/essai",
        ),
        (
            ChatService::GoogleChat,
            "https://chat.googleapis.com/v1/spaces/essai/messages?key=essai",
            "/v1/spaces/essai/messages?key=essai",
        ),
    ];
    for (service, url, path) in cases {
        let url = secret(url);
        chat.send_chat(
            service,
            ChatTarget::Webhook(&url),
            Some("Devis"),
            "Prêt",
            &[],
        )
        .await
        .unwrap_or_else(|e| panic!("{service:?} : {e:?}"));
        let request = fake.requests().into_iter().last().expect("requête");
        assert_eq!(request.path, path, "{service:?}");
        assert_eq!(request.method, "POST");
        assert_eq!(request.header("content-type"), Some("application/json"));
    }
    let requests = fake.requests();
    assert_eq!(
        requests[0].json(),
        serde_json::json!({ "text": "*Devis*\nPrêt" })
    );
    assert_eq!(
        requests[1].json()["attachments"][0]["content"]["type"],
        "AdaptiveCard"
    );
    assert_eq!(
        requests[2].json()["allowed_mentions"],
        serde_json::json!({ "parse": [] })
    );
    // Google Chat : identifiant du message
    let url = secret("https://chat.googleapis.com/v1/spaces/essai/messages?key=essai");
    let receipt = chat
        .send_chat(
            ChatService::GoogleChat,
            ChatTarget::Webhook(&url),
            None,
            "x",
            &[],
        )
        .await
        .expect("accepté");
    assert_eq!(
        receipt.message_id.as_deref(),
        Some("spaces/essai/messages/m1")
    );
    // Telegram : jeton du robot dans le chemin, salon dans le corps
    let token = secret(TELEGRAM_TOKEN);
    let receipt = chat
        .send_chat(
            ChatService::Telegram,
            ChatTarget::Telegram {
                bot_token: &token,
                chat_id: "-1001234567890",
            },
            Some("Devis"),
            "Prêt",
            &[],
        )
        .await
        .expect("accepté");
    assert_eq!(receipt.message_id.as_deref(), Some("-1001234567890:57"));
    let request = fake.requests().into_iter().last().expect("requête");
    assert_eq!(request.path, format!("/bot{TELEGRAM_TOKEN}/sendMessage"));
    assert_eq!(
        request.json(),
        serde_json::json!({ "chat_id": "-1001234567890", "text": "Devis\nPrêt" })
    );
    // Refus du service : 4xx définitif, 429 temporaire
    fake.set_default("services", Reply::status(404));
    let url = secret("https://hooks.slack.com/services/essai/salon/supprime");
    let refused = chat
        .send_chat(
            ChatService::Slack,
            ChatTarget::Webhook(&url),
            None,
            "x",
            &[],
        )
        .await;
    assert_eq!(refused.map_err(|e| e.class), Err(FailureClass::Permanent));
    fake.set_default("services", Reply::status(429));
    let busy = chat
        .send_chat(
            ChatService::Slack,
            ChatTarget::Webhook(&url),
            None,
            "x",
            &[],
        )
        .await;
    assert_eq!(busy.map_err(|e| e.class), Err(FailureClass::Transient));
}

#[tokio::test]
async fn outbound_calls_refuse_private_and_unsafe_destinations() {
    let fake = services().await;
    let chat = sender(&fake);
    let key = HmacKey::import(generate_signing_key().expect("clé")).expect("clé");
    let body = serde_json::json!({ "id": "essai" });
    let before = fake.requests().len();
    let forbidden = |result: Result<_, lyxal_notification::ProviderError>, case: &str| {
        let error = result.expect_err(case);
        assert_eq!(error.code, "NOTIFICATION_DESTINATION_FORBIDDEN", "{case}");
        assert_eq!(error.class, FailureClass::Permanent, "{case}");
    };
    for (url, case) in [
        ("https://prive4.exemple.fr/hook", "adresse IPv4 privée"),
        (
            "https://prive6.exemple.fr/hook",
            "adresse IPv6 locale unique",
        ),
        (
            "https://mappe.exemple.fr/hook",
            "adresse IPv4 privée mappée en IPv6",
        ),
        (
            "https://metadonnees.exemple.fr/hook",
            "métadonnées de la plateforme (lien local)",
        ),
        (
            "https://melange.exemple.fr/hook",
            "nom qui mêle adresse publique et privée",
        ),
        ("http://crm.exemple.fr/lyxal-hook", "HTTP"),
        ("https://10.0.0.5/lyxal-hook", "adresse IP littérale"),
        ("https://[fd00::1]/lyxal-hook", "adresse IPv6 littérale"),
        (
            "https://essai:secret@crm.exemple.fr/lyxal-hook",
            "identifiants dans l'adresse",
        ),
    ] {
        forbidden(
            chat.call_webhook(&secret(url), &key, "d1", &body, &[], 1)
                .await,
            case,
        );
    }
    // Liste d'hôtes de l'installation : un hôte public hors de la liste est refusé
    let allowed = vec!["hooks.exemple.fr".to_string()];
    forbidden(
        chat.call_webhook(
            &secret("https://crm.exemple.fr/lyxal-hook"),
            &key,
            "d1",
            &body,
            &allowed,
            1,
        )
        .await,
        "hors liste",
    );
    // Messagerie : Mattermost sur un nom qui se résout en adresse privée ; Slack hors hôte officiel
    forbidden(
        chat.send_chat(
            ChatService::Mattermost,
            ChatTarget::Webhook(&secret("https://prive4.exemple.fr/hooks/x")),
            None,
            "x",
            &[],
        )
        .await,
        "Mattermost privé",
    );
    forbidden(
        chat.send_chat(
            ChatService::Slack,
            ChatTarget::Webhook(&secret("https://crm.exemple.fr/services/x")),
            None,
            "x",
            &[],
        )
        .await,
        "Slack hors hôte officiel",
    );
    assert_eq!(fake.requests().len(), before, "aucune requête n'est partie");
    // Hôte de la liste : appelé
    chat.call_webhook(
        &secret("https://hooks.exemple.fr/lyxal-hook"),
        &key,
        "d1",
        &body,
        &allowed,
        1,
    )
    .await
    .expect("hôte autorisé");
    // Redirection jamais suivie : adresse web → nouvel essai ; messagerie → refus définitif
    fake.script(
        "lyxal-hook",
        vec![Reply::redirect("https://prive4.exemple.fr/vol")],
    );
    let redirected = chat
        .call_webhook(
            &secret("https://crm.exemple.fr/lyxal-hook"),
            &key,
            "d2",
            &body,
            &[],
            1,
        )
        .await;
    assert_eq!(
        redirected.map_err(|e| e.class),
        Err(FailureClass::Transient)
    );
    fake.script(
        "services",
        vec![Reply::redirect("https://prive4.exemple.fr/vol")],
    );
    let redirected = chat
        .send_chat(
            ChatService::Slack,
            ChatTarget::Webhook(&secret("https://hooks.slack.com/services/x")),
            None,
            "x",
            &[],
        )
        .await;
    assert_eq!(
        redirected.map_err(|e| e.class),
        Err(FailureClass::Permanent)
    );
    assert!(fake.requests().iter().all(|r| !r.path.contains("vol")));
    // Réponse de l'adresse web : 4xx définitif sauf 408 et 429
    fake.script(
        "lyxal-hook",
        vec![Reply::status(410), Reply::status(408), Reply::status(500)],
    );
    let url = secret("https://crm.exemple.fr/lyxal-hook");
    for expected in [
        FailureClass::Permanent,
        FailureClass::Transient,
        FailureClass::Transient,
    ] {
        let result = chat.call_webhook(&url, &key, "d3", &body, &[], 1).await;
        assert_eq!(result.map_err(|e| e.class), Err(expected));
    }
}

/// Vérification faite par le destinataire d'un appel : clé montrée une fois (hexadécimal),
/// `Lyxal-Signature: t=<t>,v1=<hex>` sur `<t>.<corps>`.
fn verify_as_recipient(shown_key: &str, header: &str, body: &str) -> bool {
    let raw: Vec<u8> = (0..shown_key.len())
        .step_by(2)
        .map(|i| u8::from_str_radix(&shown_key[i..i + 2], 16).expect("hexadécimal"))
        .collect();
    let key = HmacKey::import(SecretBytes::new(raw).expect("clé")).expect("clé");
    let (t, v1) = header
        .split_once(",v1=")
        .and_then(|(t, v1)| Some((t.strip_prefix("t=")?, v1)))
        .expect("en-tête");
    verify_hmac_sha256_hex(&key, format!("{t}.{body}").as_bytes(), v1).expect("vérification")
}

fn hex(bytes: &[u8]) -> String {
    bytes.iter().map(|b| format!("{b:02x}")).collect()
}

#[tokio::test]
async fn webhook_calls_are_verifiable_by_their_recipient() {
    let fake = services().await;
    let chat = sender(&fake);
    let raw = generate_signing_key().expect("clé");
    let shown = hex(raw.expose_secret());
    assert_eq!(shown.len(), 64);
    let key = HmacKey::import(raw).expect("clé");
    let body =
        serde_json::json!({ "id": "j1.e1", "type": "notification.message", "text": "Devis" });
    chat.call_webhook(
        &secret("https://crm.exemple.fr/lyxal-hook/essai?jeton=essai"),
        &key,
        "j1.e1",
        &body,
        &[],
        1_700_000_000,
    )
    .await
    .expect("accepté");
    let request = fake
        .requests_to("lyxal-hook")
        .into_iter()
        .last()
        .expect("requête");
    let header = request.header("lyxal-signature").expect("signature");
    assert!(header.starts_with("t=1700000000,v1="));
    assert_eq!(request.header("lyxal-delivery"), Some("j1.e1"));
    assert!(verify_as_recipient(&shown, header, &request.body));
    // Corps modifié ou autre clé : refusés par le destinataire
    assert!(!verify_as_recipient(
        &shown,
        header,
        &request.body.replace("Devis", "Autre")
    ));
    assert!(!verify_as_recipient(
        &"00".repeat(32),
        header,
        &request.body
    ));
}

/// Base, coffre-fort, parcours SMS + messagerie + adresse web, abonné, intégrations (Twilio de
/// clé d'enregistrement fixe, Slack, adresse web) et adresses scellées.
async fn prepared(
    fake: &FakeProviders,
) -> (
    Surreal<Any>,
    ChannelDispatcher,
    SecretCodec<lyxal_crypto::StaticKeyResolver>,
    String,
) {
    let client = installed_client().await;
    let vault = vault(&client);
    let codec = SecretCodec::new(crypto());
    client
        .query(
            r#"
            CREATE auth_organization:alpha CONTENT { slug: "alpha", name: "Alpha BTP" };
            CREATE notification_workflow:multi CONTENT { tenant: auth_organization:alpha, key: "multi", name: "Multi", status: "active",
                steps: [{ key: "sms", type: "sms" }, { key: "salon", type: "chat" }, { key: "web", type: "webhook" }] };
            CREATE notification_template:multi_sms CONTENT { tenant: auth_organization:alpha, workflow: notification_workflow:multi, step_key: "sms", text_body: "Devis {{ payload.n }} prêt" };
            CREATE notification_template:multi_salon CONTENT { tenant: auth_organization:alpha, workflow: notification_workflow:multi, step_key: "salon", subject: "Devis", text_body: "Devis {{ payload.n }}" };
            CREATE notification_template:multi_web CONTENT { tenant: auth_organization:alpha, workflow: notification_workflow:multi, step_key: "web", text_body: "Devis {{ payload.n }}" };
            CREATE notification_workflow:sms_seul CONTENT { tenant: auth_organization:alpha, key: "sms_seul", name: "SMS", status: "active", steps: [{ key: "sms", type: "sms" }] };
            CREATE notification_template:sms_seul CONTENT { tenant: auth_organization:alpha, workflow: notification_workflow:sms_seul, step_key: "sms", text_body: "{{ payload.n }}" };
            fn::notification_subscriber_save({ tenant: auth_organization:alpha, input: { subscriber_id: "s1", phone: "+33612345678" }, must_exist: false });
            "#,
        )
        .await
        .expect("préparation")
        .check()
        .expect("préparation acceptée");
    put_secret(
        &client,
        &vault,
        Some("auth_organization:alpha"),
        "notification/twilio/api",
        r#"{"account_sid":"essai_compte","auth_token":"essai_jeton_twilio"}"#,
    )
    .await;
    put_secret(
        &client,
        &vault,
        Some("auth_organization:alpha"),
        "notification/twilio/webhook",
        r#"{"auth_token":"essai_jeton_twilio"}"#,
    )
    .await;
    // Twilio de clé d'enregistrement fixe : l'adresse des retours signée est connue d'avance
    client
        .query(r#"CREATE notification_integration:twilio_essai CONTENT { tenant: auth_organization:alpha, key: "twilio", channel: "sms", provider: "twilio", name: "Twilio", primary: true, settings: { sender: "+33700000000" }, credentials_path: "notification/twilio/api", webhook_path: "notification/twilio/webhook" }"#)
        .await
        .expect("intégration")
        .check()
        .expect("intégration acceptée");
    for (key, channel, provider) in [("slack", "chat", "slack"), ("web", "webhook", "webhook")] {
        integration(
            &client,
            IntegrationSaveParams {
                tenant: Some("auth_organization:alpha".into()),
                key: key.into(),
                channel: Some(channel.into()),
                provider: Some(provider.into()),
                name: Some(key.into()),
                ..IntegrationSaveParams::default()
            },
        )
        .await;
    }
    // Adresses scellées comme le fait l'hôte : clé de l'adresse, adresse, clé de signature
    let store = NotificationStore::new(client.clone());
    let seal = |key: &str, field, value: &[u8]| {
        codec
            .seal_endpoint_value(
                Some("alpha"),
                key,
                field,
                &SecretBytes::new(value.to_vec()).expect("valeur"),
            )
            .expect("scellement")
    };
    let slack_key = uuid::Uuid::now_v7();
    let slack_url = "https://hooks.slack.com/services/essai/salon/faux";
    store
        .endpoint_create(EndpointCreateParams {
            tenant: Some("auth_organization:alpha".into()),
            subscriber_id: "s1".into(),
            endpoint: Some(slack_key.to_string()),
            channel: "chat".into(),
            provider: "slack".into(),
            name: "Salon".into(),
            url: Some(slack_url.into()),
            sealed_url: Some(seal(
                &slack_key.simple().to_string(),
                EndpointField::Url,
                slack_url.as_bytes(),
            )),
            signing_secret: None,
            chat_id: None,
            active: None,
        })
        .await
        .expect("adresse Slack");
    let web_key = uuid::Uuid::now_v7();
    let web_url = "https://crm.exemple.fr/lyxal-hook/essai?jeton=essai";
    let signing = generate_signing_key().expect("clé");
    let shown = hex(signing.expose_secret());
    store
        .endpoint_create(EndpointCreateParams {
            tenant: Some("auth_organization:alpha".into()),
            subscriber_id: "s1".into(),
            endpoint: Some(web_key.to_string()),
            channel: "webhook".into(),
            provider: "webhook".into(),
            name: "CRM".into(),
            url: Some(web_url.into()),
            sealed_url: Some(seal(
                &web_key.simple().to_string(),
                EndpointField::Url,
                web_url.as_bytes(),
            )),
            signing_secret: Some(seal(
                &web_key.simple().to_string(),
                EndpointField::SigningSecret,
                signing.expose_secret(),
            )),
            chat_id: None,
            active: None,
        })
        .await
        .expect("adresse web");
    let dispatcher = ChannelDispatcher::new(
        Arc::new(SmsApi::for_local_tests(&fake.base).expect("faux fournisseurs")),
        Arc::new(sender(fake)),
        vault,
        Some("https://lyxal.exemple.fr/"),
    );
    (client, dispatcher, codec, shown)
}

/// Valeur d'une expression SurrealQL (`RETURN <expression>`).
async fn scalar(client: &Surreal<Any>, query: &str) -> serde_json::Value {
    let expression = query.trim_start_matches("RETURN ");
    let mut response = client
        .query(format!("RETURN {{ v: ({expression}) }}"))
        .await
        .expect("requête");
    let value: Option<serde_json::Value> = response.take(0).expect("valeur");
    value
        .and_then(|v| v.get("v").cloned())
        .unwrap_or(serde_json::Value::Null)
}

#[tokio::test]
async fn trigger_sends_sms_chat_and_signed_webhook_end_to_end() {
    let fake = services().await;
    let (client, dispatcher, codec, shown) = prepared(&fake).await;
    let store = NotificationStore::new(client.clone());
    let worker = |channel| {
        NotificationChannelWorker::new(
            channel,
            store.clone(),
            codec.clone(),
            dispatcher.clone(),
            SendWorkerSettings::default(),
        )
        .expect("worker")
    };
    client
        .query("RETURN fn::notification_trigger({ tenant: 'auth_organization:alpha', workflow_key: 'multi', idempotency_key: 'multi-1', to: { subscriber_id: 's1' }, payload: { n: 7 } })")
        .await
        .expect("déclenchement")
        .check()
        .expect("déclenchement accepté");
    let cancel = CancellationToken::new();
    // Étapes dans l'ordre : SMS, messagerie, adresse web
    assert_eq!(
        worker(TextChannel::Chat)
            .run_once(&cancel)
            .await
            .expect("tour"),
        Vec::<JobOutcome>::new()
    );
    let sent = worker(TextChannel::Sms)
        .run_once(&cancel)
        .await
        .expect("tour");
    assert_eq!(
        sent,
        vec![JobOutcome::Sent],
        "{}",
        scalar(
            &client,
            "RETURN (SELECT VALUE last_error FROM notification_job)"
        )
        .await
    );
    let sms = &fake.requests_to("twilio")[0];
    let form = sms.form();
    let field = |name: &str| form.iter().find(|(k, _)| k == name).map(|(_, v)| v.clone());
    assert_eq!(field("To").as_deref(), Some("+33612345678"));
    assert_eq!(field("From").as_deref(), Some("+33700000000"));
    assert_eq!(field("Body").as_deref(), Some("Devis 7 prêt"));
    assert_eq!(
        field("StatusCallback").as_deref(),
        Some("https://lyxal.exemple.fr/api/v1/notification/webhooks/twilio_essai")
    );
    assert_eq!(
        worker(TextChannel::Chat)
            .run_once(&cancel)
            .await
            .expect("tour"),
        vec![JobOutcome::Sent]
    );
    let chat = fake
        .requests_to("services")
        .into_iter()
        .last()
        .expect("Slack");
    assert_eq!(chat.path, "/services/essai/salon/faux");
    assert_eq!(
        chat.json(),
        serde_json::json!({ "text": "*Devis*\nDevis 7" })
    );
    assert_eq!(
        worker(TextChannel::Webhook)
            .run_once(&cancel)
            .await
            .expect("tour"),
        vec![JobOutcome::Sent]
    );
    let call = fake
        .requests_to("lyxal-hook")
        .into_iter()
        .last()
        .expect("adresse web");
    assert!(verify_as_recipient(
        &shown,
        call.header("lyxal-signature").expect("signature"),
        &call.body
    ));
    let body = call.json();
    assert_eq!(body["type"], "notification.message");
    assert_eq!(
        (
            body["workflow"].as_str(),
            body["step"].as_str(),
            body["subscriber_id"].as_str(),
            body["text"].as_str()
        ),
        (Some("multi"), Some("web"), Some("s1"), Some("Devis 7"))
    );
    assert_eq!(body["payload"], serde_json::json!({ "n": 7 }));
    assert_eq!(call.header("lyxal-delivery"), body["id"].as_str());
    // Déclenchement terminé ; trois messages : téléphone, hôtes (jamais l'adresse complète)
    assert_eq!(scalar(&client, "RETURN (SELECT VALUE status FROM ONLY notification_run WHERE idempotency_key = 'multi-1' LIMIT 1)").await, "completed");
    assert_eq!(
        scalar(
            &client,
            "RETURN (SELECT VALUE [channel, to, parts] FROM notification_message ORDER BY sent_at)"
        )
        .await,
        serde_json::json!([
            ["sms", "+33612345678", 1],
            ["chat", "hooks.slack.com", null],
            ["webhook", "crm.exemple.fr", null]
        ])
    );
    // Aucune adresse en clair en base ; l'adresse ne voyage dans aucun événement
    assert_eq!(
        scalar(
            &client,
            "RETURN (SELECT VALUE string::starts_with(url, 'enc:v2:') FROM notification_endpoint)"
        )
        .await,
        serde_json::json!([true, true])
    );
    for query in [
        "RETURN (SELECT * FROM notification_endpoint)",
        "RETURN (SELECT * FROM event_outbox)",
        "RETURN (SELECT * FROM notification_message)",
        "RETURN (SELECT * FROM notification_delivery_log)",
    ] {
        let dump = scalar(&client, query).await.to_string();
        assert!(
            !dump.contains("salon/faux") && !dump.contains("jeton=essai") && !dump.contains(&shown),
            "{query}"
        );
    }
    // Retour Twilio signé (numéro inexistant) : message rejeté, numéro supprimé
    let integration = store
        .integration_get(lyxal_notification::models::IntegrationGetParams {
            integration: "notification_integration:twilio_essai".into(),
        })
        .await
        .expect("intégration");
    let body = b"MessageSid=SMessai0001&MessageStatus=undelivered&ErrorCode=30005&AccountSid=essai_compte&To=%2B33612345678&From=%2B33700000000";
    let request = WebhookRequest {
        twilio_signature: Some("I8mBN8PSNl9BeI5t7qfuh2EB7xg="),
        url: Some("https://lyxal.exemple.fr/api/v1/notification/webhooks/twilio_essai"),
        body,
        ..Default::default()
    };
    let events = dispatcher
        .verify_webhook(&integration, &request, 0)
        .await
        .expect("retour vérifié");
    for event in events {
        store
            .provider_event_record(event.record_params(integration.id.to_sql()))
            .await
            .expect("retour enregistré");
    }
    assert_eq!(scalar(&client, "RETURN (SELECT VALUE status FROM ONLY notification_message WHERE channel = 'sms' LIMIT 1)").await, "bounced");
    assert_eq!(
        scalar(
            &client,
            "RETURN (SELECT VALUE [channel, address, reason] FROM notification_suppression)"
        )
        .await,
        serde_json::json!([["sms", "+33612345678", "hard_bounce"]])
    );
    // Signature fausse : refusée
    let forged = WebhookRequest {
        twilio_signature: Some("J8mBN8PSNl9BeI5t7qfuh2EB7xg="),
        ..request
    };
    assert!(dispatcher
        .verify_webhook(&integration, &forged, 0)
        .await
        .is_err());
}

#[tokio::test]
async fn rendered_sms_beyond_ten_parts_is_refused_without_sending() {
    let fake = services().await;
    let (client, dispatcher, codec, _) = prepared(&fake).await;
    let store = NotificationStore::new(client.clone());
    client
        .query("RETURN fn::notification_trigger({ tenant: 'auth_organization:alpha', workflow_key: 'sms_seul', idempotency_key: 'long-1', to: { subscriber_id: 's1' }, payload: { n: array::join(array::repeat('a', 1531), '') } })")
        .await
        .expect("déclenchement")
        .check()
        .expect("déclenchement accepté");
    let worker = NotificationChannelWorker::new(
        TextChannel::Sms,
        store,
        codec,
        dispatcher,
        SendWorkerSettings::default(),
    )
    .expect("worker");
    assert_eq!(
        worker
            .run_once(&CancellationToken::new())
            .await
            .expect("tour"),
        vec![JobOutcome::Failed(FailureClass::Permanent)]
    );
    assert!(fake.requests_to("twilio").is_empty());
    assert_eq!(
        scalar(&client, "RETURN (SELECT VALUE [status, last_error.code] FROM ONLY notification_job WHERE run.idempotency_key = 'long-1' LIMIT 1)").await,
        serde_json::json!(["failed", "NOTIFICATION_SMS_TOO_LONG"])
    );
}
