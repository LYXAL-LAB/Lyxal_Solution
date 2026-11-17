//! Chaque fournisseur HTTP contre un faux fournisseur local : requête attendue (adresse fixe,
//! authentification, corps, en-têtes `List-Unsubscribe`), réponse acceptée (identifiant du
//! message), refus définitif (400, 401, 403, 422), échec temporaire (429, 5xx), redirection
//! jamais suivie, réponse trop grande, fournisseur injoignable ; relais SMTP d'une organisation
//! dont le nom se résout en adresse privée refusé avant toute connexion.

use base64::engine::general_purpose::STANDARD;
use base64::Engine;
use lyxal_crypto::SecretBytes;
use lyxal_notification::models::{FailureClass, IntegrationSettings};
use lyxal_notification::{
    Credentials, EmailMessage, EmailProviders, IntegrationScope, Provider, RenderedEmail,
    StaticResolver,
};
use std::sync::Arc;

use crate::fake_provider::{FakeProviders, Reply};

fn message(unsubscribe: bool) -> EmailMessage {
    EmailMessage {
        to: "claire@exemple.fr".into(),
        to_name: Some("Claire \"C\" Dupont".into()),
        list_unsubscribe: unsubscribe
            .then(|| "https://lyxal.test/api/v1/notification/unsubscribe?t=abc.def".into()),
        content: RenderedEmail {
            subject: "Devis D-42".into(),
            html: "<p>Votre devis</p>".into(),
            text: "Votre devis".into(),
        },
    }
}

fn settings() -> IntegrationSettings {
    IntegrationSettings {
        from_address: Some("devis@alpha.test".into()),
        from_name: Some("Alpha BTP".into()),
        reply_to: Some("contact@alpha.test".into()),
        ..IntegrationSettings::default()
    }
}

fn key(value: &str) -> Credentials {
    Credentials::parse(
        Provider::Brevo,
        &SecretBytes::new(format!(r#"{{"api_key":"{value}"}}"#).into_bytes()).expect("valeur"),
    )
    .expect("identifiants")
}

#[tokio::test]
async fn each_provider_sends_the_expected_request() {
    let fake = FakeProviders::start().await;
    let providers = EmailProviders::for_local_tests(&fake.base).expect("fournisseurs");
    let unsubscribe = "<https://lyxal.test/api/v1/notification/unsubscribe?t=abc.def>";

    // Brevo : en-tête api-key, JSON sender / to / headers
    let receipt = providers
        .send(
            Provider::Brevo,
            IntegrationScope::Organization,
            &settings(),
            &message(true),
            &key("xkeysib-brevo"),
        )
        .await
        .expect("Brevo");
    assert_eq!(
        receipt.message_id.as_deref(),
        Some("br-1@smtp-relay.brevo.test")
    );
    let request = &fake.requests_to("brevo")[0];
    assert_eq!(
        (request.method.as_str(), request.path.as_str()),
        ("POST", "/brevo/v3/smtp/email")
    );
    assert_eq!(request.header("api-key"), Some("xkeysib-brevo"));
    let body = request.json();
    assert_eq!(
        body["sender"],
        serde_json::json!({ "email": "devis@alpha.test", "name": "Alpha BTP" })
    );
    assert_eq!(
        body["to"],
        serde_json::json!([{ "email": "claire@exemple.fr", "name": "Claire \"C\" Dupont" }])
    );
    assert_eq!(body["replyTo"]["email"], "contact@alpha.test");
    assert_eq!(
        (body["subject"].as_str(), body["textContent"].as_str()),
        (Some("Devis D-42"), Some("Votre devis"))
    );
    assert_eq!(body["headers"]["List-Unsubscribe"], unsubscribe);
    assert_eq!(
        body["headers"]["List-Unsubscribe-Post"],
        "List-Unsubscribe=One-Click"
    );

    // Mailgun : authentification api:<clé>, formulaire, domaine en segment de chemin, région eu
    let mut mailgun = settings();
    mailgun.domain = Some("mg.lyxal.test".into());
    let receipt = providers
        .send(
            Provider::Mailgun,
            IntegrationScope::Organization,
            &mailgun,
            &message(true),
            &key("key-mailgun"),
        )
        .await
        .expect("Mailgun us");
    assert_eq!(receipt.message_id.as_deref(), Some("mg-1@mg.lyxal.test"));
    let request = &fake.requests_to("mailgun-us")[0];
    assert_eq!(request.path, "/mailgun-us/v3/mg.lyxal.test/messages");
    assert_eq!(
        request.header("authorization"),
        Some(format!("Basic {}", STANDARD.encode("api:key-mailgun")).as_str())
    );
    let form = request.form();
    let field = |name: &str| form.iter().find(|(k, _)| k == name).map(|(_, v)| v.clone());
    assert_eq!(
        field("from").as_deref(),
        Some("\"Alpha BTP\" <devis@alpha.test>")
    );
    assert_eq!(
        field("to").as_deref(),
        Some("\"Claire \\\"C\\\" Dupont\" <claire@exemple.fr>")
    );
    assert_eq!(field("h:Reply-To").as_deref(), Some("contact@alpha.test"));
    assert_eq!(field("h:List-Unsubscribe").as_deref(), Some(unsubscribe));
    assert_eq!(
        field("h:List-Unsubscribe-Post").as_deref(),
        Some("List-Unsubscribe=One-Click")
    );
    mailgun.region = Some("eu".into());
    mailgun.domain = Some("mg.lyxal.test/../../autre".into());
    providers
        .send(
            Provider::Mailgun,
            IntegrationScope::Organization,
            &mailgun,
            &message(false),
            &key("key-mailgun"),
        )
        .await
        .expect("Mailgun eu");
    // Un domaine piégé reste un seul segment encodé, jamais un autre chemin ni un autre hôte
    assert_eq!(
        fake.requests_to("mailgun-eu")[0].path,
        "/mailgun-eu/v3/mg.lyxal.test%2F..%2F..%2Fautre/messages"
    );

    // Postmark : en-tête X-Postmark-Server-Token, champs en majuscules, en-têtes en liste
    let receipt = providers
        .send(
            Provider::Postmark,
            IntegrationScope::Organization,
            &settings(),
            &message(true),
            &key("pm-token"),
        )
        .await
        .expect("Postmark");
    assert_eq!(receipt.message_id.as_deref(), Some("pm-1"));
    let request = &fake.requests_to("postmark")[0];
    assert_eq!(request.path, "/postmark/email");
    assert_eq!(request.header("x-postmark-server-token"), Some("pm-token"));
    let body = request.json();
    assert_eq!(body["From"], "\"Alpha BTP\" <devis@alpha.test>");
    assert_eq!(body["MessageStream"], "outbound");
    assert_eq!(
        body["Headers"],
        serde_json::json!([
            { "Name": "List-Unsubscribe", "Value": unsubscribe },
            { "Name": "List-Unsubscribe-Post", "Value": "List-Unsubscribe=One-Click" }
        ])
    );

    // Resend : Authorization Bearer ; parcours critique : aucun en-tête de désabonnement
    let receipt = providers
        .send(
            Provider::Resend,
            IntegrationScope::Organization,
            &settings(),
            &message(false),
            &key("re_secret"),
        )
        .await
        .expect("Resend");
    assert_eq!(receipt.message_id.as_deref(), Some("re-1"));
    let request = &fake.requests_to("resend")[0];
    assert_eq!(request.path, "/resend/emails");
    assert_eq!(request.header("authorization"), Some("Bearer re_secret"));
    let body = request.json();
    assert_eq!(
        body["to"],
        serde_json::json!(["\"Claire \\\"C\\\" Dupont\" <claire@exemple.fr>"])
    );
    assert_eq!(body["reply_to"], "contact@alpha.test");
    assert!(body.get("headers").is_none());
}

#[tokio::test]
async fn responses_are_classified_without_following_redirects() {
    let fake = FakeProviders::start().await;
    let providers = EmailProviders::for_local_tests(&fake.base).expect("fournisseurs");
    let cases: Vec<(Reply, Option<FailureClass>)> = vec![
        (Reply::status(400), Some(FailureClass::Permanent)),
        (Reply::status(401), Some(FailureClass::Permanent)),
        (Reply::status(403), Some(FailureClass::Permanent)),
        (
            Reply::json(422, serde_json::json!({ "ErrorCode": 300 })),
            Some(FailureClass::Permanent),
        ),
        (Reply::status(429), Some(FailureClass::Transient)),
        (Reply::status(500), Some(FailureClass::Transient)),
        (Reply::status(503), Some(FailureClass::Transient)),
        (
            Reply {
                status: 302,
                headers: vec![("location", format!("{}/resend/emails", fake.base))],
                body: String::new(),
            },
            Some(FailureClass::Permanent),
        ),
        // Accepté avec une réponse de plus de 64 Kio : parti, sans identifiant lisible
        (
            Reply::json(
                200,
                serde_json::json!({ "MessageID": "x".repeat(70 * 1024) }),
            ),
            None,
        ),
    ];
    fake.script(
        "postmark",
        cases.iter().map(|(reply, _)| reply.clone()).collect(),
    );
    for (index, (_, expected)) in cases.iter().enumerate() {
        let result = providers
            .send(
                Provider::Postmark,
                IntegrationScope::Organization,
                &settings(),
                &message(false),
                &key("pm-token"),
            )
            .await;
        match expected {
            Some(class) => {
                let error = result.expect_err("refus");
                assert_eq!(error.class, *class, "cas {index}");
                assert!(error.detail.starts_with("HTTP "), "{error:?}");
                assert!(!error.detail.contains("pm-token"));
            }
            None => assert_eq!(result.expect("accepté").message_id, None, "cas {index}"),
        }
    }
    // Une requête par cas : la redirection n'a pas été suivie
    assert_eq!(fake.requests_to("postmark").len(), cases.len());
    assert!(fake.requests_to("resend").is_empty());
}

#[tokio::test]
async fn an_unreachable_provider_is_a_transient_failure() {
    // Port fermé de la boucle locale
    let listener = std::net::TcpListener::bind("127.0.0.1:0").expect("port");
    let port = listener.local_addr().expect("adresse").port();
    drop(listener);
    let providers =
        EmailProviders::for_local_tests(&format!("http://127.0.0.1:{port}")).expect("fournisseurs");
    let error = providers
        .send(
            Provider::Resend,
            IntegrationScope::Organization,
            &settings(),
            &message(false),
            &key("re_secret"),
        )
        .await
        .expect_err("injoignable");
    assert_eq!(
        (error.class, error.code.as_str()),
        (FailureClass::Transient, "NOTIFICATION_PROVIDER_UNAVAILABLE")
    );
    // Clé d'API attendue : des identifiants SMTP sont refusés sans rien en dire
    let login = Credentials::parse(
        Provider::Smtp,
        &SecretBytes::new(br#"{"username":"u","password":"p"}"#.to_vec()).expect("valeur"),
    )
    .expect("identifiants");
    let error = providers
        .send(
            Provider::Brevo,
            IntegrationScope::Organization,
            &settings(),
            &message(false),
            &login,
        )
        .await
        .expect_err("forme");
    assert_eq!(error.code, "NOTIFICATION_INTEGRATION_SECRET_INVALID");
}

#[tokio::test]
async fn an_organization_smtp_relay_resolving_to_a_private_address_is_refused() {
    let resolver = StaticResolver::new()
        .with(
            "smtp.interne.test",
            "10.0.0.1:587".parse().expect("adresse"),
        )
        .with(
            "metadonnees.test",
            "169.254.169.254:25".parse().expect("adresse"),
        );
    let providers = EmailProviders::for_local_tests("http://127.0.0.1:9")
        .expect("fournisseurs")
        .with_resolver(Arc::new(resolver));
    let login = Credentials::parse(
        Provider::Smtp,
        &SecretBytes::new(br#"{"username":"u","password":"p"}"#.to_vec()).expect("valeur"),
    )
    .expect("identifiants");
    for (host, port, security) in [
        ("smtp.interne.test", 587, "starttls"),
        ("metadonnees.test", 25, "tls"),
    ] {
        let relay = IntegrationSettings {
            host: Some(host.into()),
            port: Some(port),
            security: Some(security.into()),
            ..settings()
        };
        let error = providers
            .send(
                Provider::Smtp,
                IntegrationScope::Organization,
                &relay,
                &message(false),
                &login,
            )
            .await
            .expect_err("relais interne refusé");
        assert_eq!(
            (error.class, error.code.as_str()),
            (
                FailureClass::Permanent,
                "NOTIFICATION_DESTINATION_FORBIDDEN"
            ),
            "{host}"
        );
    }
}
