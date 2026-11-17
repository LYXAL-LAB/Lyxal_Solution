//! Fil dans l'application sur le moteur embarqué. Déclenchement → worker du canal
//! `in_app` (sans fournisseur ni clé) → message du fil rendu (variables échappées, liens et
//! boutons), trace d'envoi sans contenu ; lien rendu dangereux (variable qui fait d'un chemin
//! un « // ») refusé à la livraison : échec définitif, aucun message ; contenu du message en
//! lecture seule, même pour la session système (titre, texte, abonné, compte : écritures
//! refusées), états modifiables.

use lyxal_crypto::StaticKeyResolver;
use lyxal_notification::models::FailureClass;
use lyxal_notification::{
    JobOutcome, NotificationChannelWorker, NotificationStore, SendWorkerSettings,
};
use lyxal_runtime::worker::CancellationToken;
use serde_json::Value;
use surrealdb::engine::any::Any;
use surrealdb::Surreal;

use crate::support::installed_client;

async fn rows(client: &Surreal<Any>, query: &str) -> Vec<Value> {
    let mut response = client.query(query).await.expect("requête");
    response.take(0).expect("lignes")
}

async fn run(client: &Surreal<Any>, query: &str) {
    client
        .query(query)
        .await
        .expect("requête")
        .check()
        .expect("requête acceptée");
}

async fn prepared() -> Surreal<Any> {
    let client = installed_client().await;
    run(
        &client,
        r#"
        CREATE auth_organization:alpha CONTENT { slug: "alpha", name: "Alpha & Fils" };
        CREATE auth_identity:personne CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "personne@lyxal.test", locale: "fr" } };
        CREATE auth_identity:autre CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "autre@lyxal.test", locale: "fr" } };
        fn::notification_subscriber_save({ tenant: auth_organization:alpha, input: { subscriber_id: "auth:personne", identity: auth_identity:personne, locale: "fr" }, must_exist: false });
        CREATE notification_workflow:devis CONTENT { tenant: auth_organization:alpha, key: "devis", name: "Devis", status: "active", tags: ["devis"], severity: "high", steps: [{ key: "fil", type: "in_app" }] };
        CREATE notification_template:devis_fil CONTENT { tenant: auth_organization:alpha, workflow: notification_workflow:devis, step_key: "fil",
            subject: "Devis {{ payload.n }}", text_body: "Le devis **{{ payload.n }}** de {{ organization.name }} est prêt",
            redirect: "/devis/{{ payload.id }}", actions: [{ kind: "primary", label: "Valider {{ payload.n }}", url: "/devis/{{ payload.id }}/valider" }],
            data: { devis: "{{ payload.id }}" } };
        "#,
    )
    .await;
    client
}

fn worker(client: &Surreal<Any>) -> NotificationChannelWorker<StaticKeyResolver> {
    NotificationChannelWorker::in_app(
        NotificationStore::new(client.clone()),
        SendWorkerSettings::default(),
    )
    .expect("worker du fil")
}

async fn trigger(client: &Surreal<Any>, key: &str, payload: Value) {
    let mut response = client
        .query("RETURN fn::notification_trigger({ tenant: 'auth_organization:alpha', workflow_key: 'devis', idempotency_key: $key, to: { subscriber_id: 'auth:personne' }, payload: $payload })")
        .bind(("key", key.to_string()))
        .bind(("payload", payload))
        .await
        .expect("déclenchement");
    let result: Option<Value> = response.take(0).expect("résultat");
    assert_eq!(
        result.as_ref().and_then(|r| r["ok"].as_bool()),
        Some(true),
        "{result:?}"
    );
}

#[tokio::test]
async fn an_in_app_step_is_rendered_escaped_and_delivered_to_the_feed() {
    let client = prepared().await;
    trigger(
        &client,
        "devis-1",
        serde_json::json!({ "n": "<script>x()</script>", "id": "42" }),
    )
    .await;
    let outcomes = worker(&client)
        .run_once(&CancellationToken::new())
        .await
        .expect("tour du worker");
    assert_eq!(outcomes, vec![JobOutcome::Sent]);
    let items = rows(&client, "SELECT * FROM notification_inbox").await;
    assert_eq!(items.len(), 1);
    let item = &items[0];
    // Titre et texte : variables échappées, Markdown du gabarit gardé
    assert_eq!(item["title"], "Devis &lt;script&gt;x()&lt;&#x2f;script&gt;");
    assert_eq!(
        item["text"],
        "Le devis **&lt;script&gt;x()&lt;&#x2f;script&gt;** de Alpha &amp; Fils est prêt"
    );
    assert_eq!(item["redirect"], "/devis/42");
    assert_eq!(item["actions"][0]["url"], "/devis/42/valider");
    assert_eq!(
        item["actions"][0]["label"],
        "Valider &lt;script&gt;x()&lt;&#x2f;script&gt;"
    );
    assert_eq!(item["data"], serde_json::json!({ "devis": "42" }));
    assert_eq!(
        (item["severity"].as_str(), item["tags"].clone()),
        (Some("high"), serde_json::json!(["devis"]))
    );
    // Trace d'envoi pour le journal : l'abonné, jamais le contenu
    let messages = rows(
        &client,
        "SELECT channel, to, subject FROM notification_message",
    )
    .await;
    assert_eq!(
        messages,
        vec![serde_json::json!({ "channel": "in_app", "to": "auth:personne", "subject": null })]
    );
    let runs = rows(&client, "SELECT VALUE status FROM notification_run").await;
    assert_eq!(runs, vec![serde_json::json!("completed")]);
    // Événement : identifiants seulement
    let events = rows(
        &client,
        "SELECT VALUE payload FROM event_outbox WHERE event_type = 'notification.inbox.delivered'",
    )
    .await;
    assert_eq!(events.len(), 1);
    assert!(!events[0].to_string().contains("script"));
}

#[tokio::test]
async fn a_rendered_link_made_dangerous_by_a_variable_is_refused_at_delivery() {
    let client = prepared().await;
    // « /devis/ » suivi de « /pirate.test » : la partie fixe était sûre, le lien rendu ne l'est pas
    run(
        &client,
        "UPDATE notification_template:devis_fil SET redirect = '/{{ payload.id }}', actions = NONE",
    )
    .await;
    trigger(
        &client,
        "devis-pirate",
        serde_json::json!({ "n": "D-1", "id": "/pirate.test" }),
    )
    .await;
    let outcomes = worker(&client)
        .run_once(&CancellationToken::new())
        .await
        .expect("tour du worker");
    assert_eq!(outcomes, vec![JobOutcome::Failed(FailureClass::Permanent)]);
    assert!(rows(&client, "SELECT * FROM notification_inbox")
        .await
        .is_empty());
    let jobs = rows(
        &client,
        "SELECT status, last_error.code AS code FROM notification_job",
    )
    .await;
    assert_eq!(
        jobs,
        vec![serde_json::json!({ "status": "failed", "code": "NOTIFICATION_INVALID_INPUT" })]
    );
}

#[tokio::test]
async fn the_content_of_a_feed_message_is_read_only_its_states_are_not() {
    let client = prepared().await;
    trigger(
        &client,
        "devis-2",
        serde_json::json!({ "n": "D-2", "id": "7" }),
    )
    .await;
    worker(&client)
        .run_once(&CancellationToken::new())
        .await
        .expect("tour du worker");
    let id = rows(&client, "SELECT VALUE id FROM notification_inbox").await[0]
        .as_str()
        .expect("identifiant")
        .to_string();
    for change in [
        "title = 'Autre titre'",
        "text = 'Autre texte'",
        "redirect = '/ailleurs'",
        "identity = auth_identity:autre",
        "subscriber = notification_subscriber:autre",
        "tenant = NONE",
        "data = { devis: '8' }",
        "actions = []",
    ] {
        let refused = client
            .query(format!("UPDATE {id} SET {change}"))
            .await
            .and_then(|response| response.check());
        assert!(refused.is_err(), "{change} : écriture acceptée");
    }
    let item = &rows(&client, &format!("SELECT * FROM {id}")).await[0];
    assert_eq!(
        (item["title"].as_str(), item["identity"].as_str()),
        (Some("Devis D-2"), Some("auth_identity:personne"))
    );
    run(
        &client,
        &format!("UPDATE {id} SET read_at = time::now(), action_status.primary = 'done'"),
    )
    .await;
    let item = &rows(&client, &format!("SELECT * FROM {id}")).await[0];
    assert!(item["read_at"].is_string());
    assert_eq!(item["action_status"]["primary"], "done");
}
