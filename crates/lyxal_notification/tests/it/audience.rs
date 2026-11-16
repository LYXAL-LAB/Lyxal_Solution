//! Destinataires et préférences de bout en bout : lien de désabonnement reçu puis utilisé (plus
//! d'e-mail de la catégorie, un parcours critique passe toujours), jeton modifié refusé, heures
//! calmes qui reportent un envoi, diffusion à un sujet de 1 200 abonnés par le worker.

use lyxal_crypto::SecretBytes;
use lyxal_notification::models::{
    Channels, PreferenceSetParams, QuietHours, QuietRange, SubscriberImportParams, SubscriberInput,
    TopicSaveParams, TopicSubscribeParams, TriggerKind, TriggerParams, TriggerResult,
    TriggerStatus, TriggerTarget,
};
use lyxal_notification::{
    BroadcastWorkerSettings, JobOutcome, NotificationBroadcastWorker, NotificationError,
    NotificationStore, UnsubscribeLinks,
};
use lyxal_runtime::worker::CancellationToken;
use std::sync::Arc;
use surrealdb::engine::any::Any;
use surrealdb::Surreal;

use crate::flow::{decoded, worker};
use crate::smtp_server::TestSmtpServer;
use crate::support::{crypto, installed_client};

const ALPHA: &str = "auth_organization:alpha";

/// Organisation Alpha, catégorie « actualités », parcours « lettre » (rangé dans la catégorie) et
/// « alerte » (critique), chacun avec un gabarit qui affiche le lien de désabonnement s'il y en a un.
async fn alpha(client: &Surreal<Any>) {
    client
        .query(
            r#"
            CREATE auth_organization:alpha CONTENT { slug: "alpha", name: "Alpha BTP" };
            CREATE notification_category:actualites CONTENT { tenant: auth_organization:alpha, key: "actualites", name: "Actualités" };
            CREATE notification_workflow:lettre CONTENT { tenant: auth_organization:alpha, key: "lettre", name: "Lettre", status: "active", category: notification_category:actualites, steps: [{ key: "email", type: "email" }] };
            CREATE notification_workflow:alerte CONTENT { tenant: auth_organization:alpha, key: "alerte", name: "Alerte", status: "active", critical: true, steps: [{ key: "email", type: "email" }] };
            FOR $w IN [notification_workflow:lettre, notification_workflow:alerte] {
                CREATE notification_template CONTENT {
                    workflow: $w, step_key: "email", keys: [],
                    subject: "Message {{ payload.n }}",
                    html_body: "<p>Message {{ payload.n }}</p>{% if unsubscribe_url %}<p><a href=\"{{ unsubscribe_url }}\">Se désabonner</a></p>{% endif %}",
                    text_body: "Message {{ payload.n }}{% if unsubscribe_url %} - {{ unsubscribe_url }}{% endif %}"
                };
            };
            "#,
        )
        .await
        .expect("préparation")
        .check()
        .expect("préparation acceptée");
}

fn links() -> Arc<UnsubscribeLinks> {
    Arc::new(
        UnsubscribeLinks::new(
            "https://lyxal.test",
            &SecretBytes::new(vec![0x5a; 32]).expect("clé applicative"),
        )
        .expect("liens"),
    )
}

async fn trigger(
    store: &NotificationStore,
    workflow: &str,
    key: &str,
    to: TriggerTarget,
) -> TriggerResult {
    store
        .trigger(TriggerParams {
            tenant: Some(ALPHA.to_string()),
            workflow_key: Some(workflow.to_string()),
            trigger_event: None,
            idempotency_key: key.to_string(),
            event_id: None,
            to,
            actor: Some("m-0000".to_string()),
            exclude_actor: None,
            overrides: None,
            payload: serde_json::json!({ "n": key }),
            secret: None,
            expires_at: None,
        })
        .await
        .expect("déclenchement")
}

fn claire() -> TriggerTarget {
    TriggerTarget::Subscriber(SubscriberInput {
        subscriber_id: "client-1".into(),
        email: Some("claire@exemple.fr".into()),
        locale: Some("fr".into()),
        first_name: Some("Claire".into()),
        ..SubscriberInput::default()
    })
}

async fn count(client: &Surreal<Any>, query: &str) -> i64 {
    let mut response = client.query(query).await.expect("lecture");
    let value: Option<i64> = response.take(0).expect("nombre");
    value.unwrap_or_default()
}

/// En-tête d'un message reçu (valeur sur une ligne).
fn header<'a>(data: &'a str, name: &str) -> Option<&'a str> {
    data.lines()
        .find_map(|line| line.strip_prefix(name)?.strip_prefix(": "))
        .map(str::trim)
}

#[tokio::test]
async fn an_unsubscribe_link_is_received_then_used() {
    let client = installed_client().await;
    alpha(&client).await;
    let engine = crypto();
    let store = NotificationStore::new(client.clone());
    let server = TestSmtpServer::start().await;
    let links = links();
    let worker = worker(&client, &engine, &server).with_unsubscribe_links(links.clone());

    let first = trigger(&store, "lettre", "lettre-1", claire()).await;
    assert_eq!(
        (first.kind, first.status),
        (TriggerKind::Subscriber, Some(TriggerStatus::Created))
    );
    assert_eq!(
        worker
            .run_once(&CancellationToken::new())
            .await
            .expect("envoi"),
        vec![JobOutcome::Sent]
    );
    let received = server.received();
    assert_eq!(received.len(), 1);
    let data = &received[0].data;
    let link = header(data, "List-Unsubscribe")
        .and_then(|value| value.strip_prefix('<')?.strip_suffix('>'))
        .expect("en-tête List-Unsubscribe");
    assert!(link.starts_with("https://lyxal.test/api/v1/notification/unsubscribe?t="));
    assert_eq!(
        header(data, "List-Unsubscribe-Post"),
        Some("List-Unsubscribe=One-Click")
    );
    assert!(
        decoded(data).contains("Se désabonner"),
        "lien dans le corps"
    );
    let token = link.rsplit("?t=").next().expect("jeton");

    // Jeton modifié : refusé avant toute lecture de la base
    let mut tampered = token.to_string();
    let last = tampered.pop().expect("caractère");
    tampered.push(if last == 'A' { 'B' } else { 'A' });
    assert!(matches!(
        links.verify(&tampered),
        Err(NotificationError::Unsubscribe)
    ));

    // Lien utilisé (comme le fait la route de l'hôte) : e-mail coupé pour la catégorie
    let params = links.verify(token).expect("jeton valide");
    assert_eq!(
        params.category.as_deref(),
        Some("notification_category:actualites")
    );
    let done = store.unsubscribe(params.clone()).await.expect("désabonné");
    assert_eq!(done.level, "subscriber_category");
    // Rejouable (double clic, client de messagerie)
    store.unsubscribe(params).await.expect("rejeu");

    // Plus d'e-mail de la catégorie
    let second = trigger(&store, "lettre", "lettre-2", claire()).await;
    assert_eq!(second.status, Some(TriggerStatus::Skipped));
    assert_eq!(
        second.skip_reason.as_deref(),
        Some("preference:subscriber_category")
    );
    // Un parcours critique passe toujours, sans lien de désabonnement
    trigger(&store, "alerte", "alerte-1", claire()).await;
    assert_eq!(
        worker
            .run_once(&CancellationToken::new())
            .await
            .expect("envoi"),
        vec![JobOutcome::Sent]
    );
    let received = server.received();
    assert_eq!(received.len(), 2);
    assert!(decoded(&received[1].data).contains("Message alerte-1"));
    assert_eq!(header(&received[1].data, "List-Unsubscribe"), None);
    assert!(!decoded(&received[1].data).contains("Se désabonner"));
}

#[tokio::test]
async fn quiet_hours_postpone_a_message_without_counting_an_attempt() {
    let client = installed_client().await;
    alpha(&client).await;
    let engine = crypto();
    let store = NotificationStore::new(client.clone());
    let server = TestSmtpServer::start().await;
    trigger(&store, "lettre", "calme-0", claire()).await;
    // Heures calmes toute la journée, chaque jour
    store
        .preference_set(PreferenceSetParams {
            tenant: Some(ALPHA.to_string()),
            level: "subscriber_global".into(),
            subscriber_id: Some("client-1".into()),
            workflow: None,
            category: None,
            channels: Some(Channels {
                email: Some(true),
                ..Channels::default()
            }),
            quiet_hours: Some(QuietHours {
                ranges: vec![QuietRange {
                    days: (1..=7).collect(),
                    start: 0,
                    end: 0,
                }],
            }),
        })
        .await
        .expect("heures calmes");
    let worker = worker(&client, &engine, &server);
    assert_eq!(
        worker
            .run_once(&CancellationToken::new())
            .await
            .expect("tour"),
        vec![JobOutcome::Deferred]
    );
    assert!(server.received().is_empty());
    assert_eq!(
        count(&client, "RETURN count(SELECT id FROM notification_job WHERE status = 'queued' AND attempts = 0 AND next_retry_at > time::now() + 23h)").await,
        1
    );
    // Parcours critique : pas d'heures calmes
    trigger(&store, "alerte", "calme-1", claire()).await;
    assert_eq!(
        worker
            .run_once(&CancellationToken::new())
            .await
            .expect("tour"),
        vec![JobOutcome::Sent]
    );
}

#[tokio::test(flavor = "multi_thread", worker_threads = 4)]
async fn a_topic_of_1200_subscribers_is_broadcast_in_batches_of_500() {
    let client = installed_client().await;
    alpha(&client).await;
    let store = NotificationStore::new(client.clone());
    store
        .topic_create(TopicSaveParams {
            tenant: Some(ALPHA.to_string()),
            key: "chantier".into(),
            name: Some("Chantier".into()),
            description: None,
            data: None,
        })
        .await
        .expect("sujet");
    // 1 200 abonnés importés puis abonnés au sujet, par lots de 100 traités en parallèle
    let ids: Vec<String> = (0..1200).map(|i| format!("m-{i:04}")).collect();
    let mut batches = tokio::task::JoinSet::new();
    for chunk in ids.chunks(100) {
        let (store, chunk) = (store.clone(), chunk.to_vec());
        batches.spawn(async move {
            let imported = store
                .subscriber_import(SubscriberImportParams {
                    tenant: Some(ALPHA.to_string()),
                    subscribers: chunk
                        .iter()
                        .map(|id| SubscriberInput {
                            subscriber_id: id.clone(),
                            email: Some(format!("{id}@exemple.fr")),
                            ..SubscriberInput::default()
                        })
                        .collect(),
                })
                .await
                .expect("import");
            let subscribed = store
                .topic_subscribe(TopicSubscribeParams {
                    tenant: Some(ALPHA.to_string()),
                    key: "chantier".into(),
                    subscribers: chunk,
                    condition: None,
                })
                .await
                .expect("abonnement");
            (imported.created, imported.rejected.len(), subscribed.added)
        });
    }
    while let Some(batch) = batches.join_next().await {
        assert_eq!(batch.expect("lot"), (100, 0, 100));
    }

    // Diffusion enregistrée (l'auteur m-0000 est exclu), traitée par le worker
    let triggered = trigger(
        &store,
        "lettre",
        "annonce-1",
        TriggerTarget::Topic {
            topic: "chantier".into(),
        },
    )
    .await;
    assert_eq!(triggered.kind, TriggerKind::Broadcast);
    assert!(triggered.broadcast_id.is_some());
    let worker =
        NotificationBroadcastWorker::new(store.clone(), BroadcastWorkerSettings::default())
            .expect("worker");
    let outcome = worker
        .run_once(&CancellationToken::new())
        .await
        .expect("diffusion")
        .expect("diffusion réservée");
    assert_eq!(
        (
            outcome.batches,
            outcome.processed,
            outcome.created,
            outcome.completed
        ),
        (3, 1200, 1199, true)
    );
    assert_eq!(
        count(
            &client,
            "RETURN count(SELECT id FROM notification_run WHERE broadcast IS NOT NONE)"
        )
        .await,
        1199
    );
    assert_eq!(
        count(
            &client,
            "RETURN count(SELECT id FROM notification_job WHERE status = 'queued')"
        )
        .await,
        1199
    );
    assert_eq!(
        count(&client, "RETURN count(SELECT id FROM notification_run WHERE subscriber.subscriber_id = 'm-0000')").await,
        0
    );
    // Rien de plus à diffuser ; une diffusion rejouée ne crée rien
    assert!(worker
        .run_once(&CancellationToken::new())
        .await
        .expect("tour")
        .is_none());
    let again = trigger(
        &store,
        "lettre",
        "annonce-1",
        TriggerTarget::Topic {
            topic: "chantier".into(),
        },
    )
    .await;
    assert_eq!(again.status, Some(TriggerStatus::Duplicate));
    // Annulé avant le premier paquet : rien n'est traité, la diffusion attend sa reprise
    trigger(
        &store,
        "lettre",
        "annonce-2",
        TriggerTarget::All { all: true },
    )
    .await;
    let cancelled = CancellationToken::new();
    cancelled.cancel();
    let paused = worker
        .run_once(&cancelled)
        .await
        .expect("tour")
        .expect("diffusion réservée");
    assert_eq!((paused.batches, paused.completed), (0, false));
}
