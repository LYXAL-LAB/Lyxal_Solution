//! Enveloppes de `NotificationStore` qu'aucun autre test Rust n'appelle : chacune est appelée
//! une fois sur la base embarquée et son résultat typé relu (abonnés, sujets, catégories,
//! préférences, envoi groupé et d'essai, purge, intégrations, adresses, appareils). Les fonctions
//! de la personne connectée (`my_*`) demandent une session `lyxal_auth` d'une personne : la
//! session système est refusée (`NOTIFICATION_PERMISSION_DENIED`), leur résultat réel est relu par
//! les routes de l'hôte.

use lyxal_crypto::SecretBytes;
use lyxal_notification::models::{
    CategoryRefParams, CategorySaveParams, DeviceListParams, EndpointCreateParams,
    EndpointListParams, EndpointRefParams, EndpointUpdateParams, IntegrationRefParams,
    IntegrationSaveParams, IntegrationSelectParams, IntegrationSettings, MyEndpointListParams,
    MyPreferenceGetParams, MyPreferenceSetParams, PreferenceGetParams, PurgeArgs, PurgeParams,
    ScopeParams, SubscriberInput, SubscriberListParams, SubscriberRefParams,
    SubscriberUpsertParams, TestSendParams, TopicListParams, TopicMembersParams, TopicRefParams,
    TopicSaveParams, TopicSubscribeParams, TopicUnsubscribeParams, TriggerBulkParams,
    TriggerParams, TriggerTarget,
};
use lyxal_notification::{EndpointField, NotificationError, NotificationStore, SecretCodec};
use lyxal_surreal::ToSql;

use crate::support::{crypto, installed_client, integration, put_secret, vault};

const ALPHA: &str = "auth_organization:alpha";

fn alpha() -> Option<String> {
    Some(ALPHA.to_string())
}

fn refused<T: std::fmt::Debug>(result: Result<T, lyxal_surreal::LyxalSurrealError>) -> String {
    NotificationError::from(result.expect_err("refus attendu")).code()
}

#[tokio::test]
async fn every_store_wrapper_reads_its_typed_result() {
    let client = installed_client().await;
    let vault = vault(&client);
    client
        .query(
            r#"
            CREATE auth_organization:alpha CONTENT { slug: "alpha", name: "Alpha BTP" };
            CREATE notification_workflow:devis CONTENT { tenant: auth_organization:alpha, key: "devis", name: "Devis", status: "active", steps: [{ key: "email", type: "email" }] };
            CREATE notification_template:devis_email CONTENT { tenant: auth_organization:alpha, workflow: notification_workflow:devis, step_key: "email", subject: "Devis", html_body: "<p>Devis</p>", text_body: "Devis", keys: [] };
            "#,
        )
        .await
        .expect("préparation")
        .check()
        .expect("préparation acceptée");
    let store = NotificationStore::new(client.clone());

    // Abonnés
    let upserted = store
        .subscriber_upsert(SubscriberUpsertParams {
            tenant: alpha(),
            subscriber_id: "c1".into(),
            email: Some("Client@Exemple.fr".into()),
            phone: None,
            first_name: Some("Claire".into()),
            last_name: None,
            locale: Some("fr".into()),
            timezone: None,
            data: Some(serde_json::json!({ "agence": "nord" })),
            identity: None,
        })
        .await
        .expect("abonné");
    assert!(upserted.created && upserted.changed);
    let reference = || SubscriberRefParams {
        tenant: alpha(),
        subscriber_id: "c1".into(),
    };
    let subscriber = store.subscriber_get(reference()).await.expect("abonné lu");
    assert_eq!(subscriber.id, upserted.subscriber.id);
    let listed = store
        .subscriber_list(SubscriberListParams {
            tenant: alpha(),
            search: Some("c1".into()),
            limit: Some(10),
            start: None,
        })
        .await
        .expect("abonnés");
    assert_eq!(listed.len(), 1);

    // Catégories
    let category = || CategorySaveParams {
        tenant: alpha(),
        key: "actualites".into(),
        name: Some("Actualités".into()),
        description: None,
    };
    store.category_create(category()).await.expect("catégorie");
    let updated = store
        .category_update(CategorySaveParams {
            description: Some("Lettres".into()),
            ..category()
        })
        .await
        .expect("catégorie modifiée");
    assert_eq!(updated.key, "actualites");
    assert_eq!(
        store
            .category_list(ScopeParams { tenant: alpha() })
            .await
            .expect("catégories")
            .len(),
        1
    );

    // Sujets
    let topic = || TopicSaveParams {
        tenant: alpha(),
        key: "chantier".into(),
        name: Some("Chantier".into()),
        description: None,
        data: None,
    };
    store.topic_create(topic()).await.expect("sujet");
    let renamed = store
        .topic_update(TopicSaveParams {
            name: Some("Chantier nord".into()),
            ..topic()
        })
        .await
        .expect("sujet modifié");
    assert_eq!(renamed.key, "chantier");
    store
        .topic_subscribe(TopicSubscribeParams {
            tenant: alpha(),
            key: "chantier".into(),
            subscribers: vec!["c1".into()],
            condition: None,
        })
        .await
        .expect("abonnement");
    let topic_ref = || TopicRefParams {
        tenant: alpha(),
        key: "chantier".into(),
    };
    assert_eq!(
        store.topic_get(topic_ref()).await.expect("sujet lu").key,
        "chantier"
    );
    assert_eq!(
        store
            .topic_list(TopicListParams {
                tenant: alpha(),
                limit: Some(10),
                start: None,
            })
            .await
            .expect("sujets")
            .len(),
        1
    );
    assert_eq!(
        store
            .topic_members(TopicMembersParams {
                tenant: alpha(),
                key: "chantier".into(),
                limit: Some(10),
                start: None,
            })
            .await
            .expect("membres")
            .len(),
        1
    );
    let unsubscribed = store
        .topic_unsubscribe(TopicUnsubscribeParams {
            tenant: alpha(),
            key: "chantier".into(),
            subscribers: vec!["c1".into(), "inconnu".into()],
        })
        .await
        .expect("désabonnement");
    assert_eq!(unsubscribed.removed, 1);

    // Préférences
    store
        .preference_get(PreferenceGetParams {
            tenant: alpha(),
            subscriber_id: Some("c1".into()),
            workflow: None,
        })
        .await
        .expect("préférences");

    // Envoi groupé et envoi d'essai
    let event = TriggerParams {
        tenant: alpha(),
        workflow_key: Some("devis".into()),
        trigger_event: None,
        idempotency_key: "groupe-1".into(),
        event_id: None,
        to: TriggerTarget::Subscriber(SubscriberInput {
            subscriber_id: "c1".into(),
            ..SubscriberInput::default()
        }),
        actor: None,
        exclude_actor: None,
        payload: serde_json::json!({}),
        overrides: None,
        secret: None,
        expires_at: None,
    };
    let bulk = store
        .trigger_bulk(TriggerBulkParams {
            events: vec![event],
        })
        .await
        .expect("envoi groupé");
    assert!(bulk.results.len() == 1 && bulk.results[0].ok, "{bulk:?}");
    let sent = store
        .test_send(TestSendParams {
            tenant: alpha(),
            workflow_key: "devis".into(),
            to: SubscriberInput {
                subscriber_id: "essai".into(),
                email: Some("essai@exemple.fr".into()),
                ..SubscriberInput::default()
            },
            payload: serde_json::json!({}),
        })
        .await
        .expect("envoi d'essai");
    assert!(!sent.job_ids.is_empty());

    // Intégrations : principale, choix pour une étape, suppression
    put_secret(
        &client,
        &vault,
        None,
        "notification/brevo/api",
        r#"{"api_key":"k"}"#,
    )
    .await;
    for key in ["brevo_a", "brevo_b"] {
        integration(
            &client,
            IntegrationSaveParams {
                key: key.into(),
                provider: Some("brevo".into()),
                name: Some(key.into()),
                settings: Some(IntegrationSettings {
                    from_address: Some("noreply@lyxal.test".into()),
                    ..IntegrationSettings::default()
                }),
                credentials_path: Some("notification/brevo/api".into()),
                ..IntegrationSaveParams::default()
            },
        )
        .await;
    }
    let primary = store
        .integration_set_primary(IntegrationRefParams {
            tenant: None,
            key: "brevo_b".into(),
        })
        .await
        .expect("intégration principale");
    assert!(primary.primary);
    let selected = store
        .integration_select(IntegrationSelectParams {
            job_id: sent.job_ids[0].to_sql(),
        })
        .await
        .expect("intégrations de l'étape");
    assert_eq!(selected.first().map(|i| i.key.as_str()), Some("brevo_b"));
    let deleted = store
        .integration_delete(IntegrationRefParams {
            tenant: None,
            key: "brevo_a".into(),
        })
        .await
        .expect("intégration supprimée");
    assert!(deleted
        .deleted
        .to_sql()
        .starts_with("notification_integration:"));

    // Adresses de messagerie et appareils
    integration(
        &client,
        IntegrationSaveParams {
            tenant: alpha(),
            key: "slack".into(),
            channel: Some("chat".into()),
            provider: Some("slack".into()),
            name: Some("Slack".into()),
            ..IntegrationSaveParams::default()
        },
    )
    .await;
    let codec = SecretCodec::new(crypto());
    let key = uuid::Uuid::now_v7();
    let url = "https://hooks.slack.com/services/essai/salon/faux";
    let sealed = codec
        .seal_endpoint_value(
            Some("alpha"),
            &key.simple().to_string(),
            EndpointField::Url,
            &SecretBytes::new(url.as_bytes().to_vec()).expect("valeur"),
        )
        .expect("scellement");
    let endpoint = store
        .endpoint_create(EndpointCreateParams {
            tenant: alpha(),
            subscriber_id: "c1".into(),
            endpoint: Some(key.to_string()),
            channel: "chat".into(),
            provider: "slack".into(),
            name: "Salon".into(),
            url: Some(url.into()),
            sealed_url: Some(sealed),
            signing_secret: None,
            chat_id: None,
            active: None,
        })
        .await
        .expect("adresse");
    let endpoint_id = endpoint.id.to_sql();
    let changed = store
        .endpoint_update(EndpointUpdateParams {
            tenant: alpha(),
            endpoint: endpoint_id.clone(),
            name: Some("Salon nord".into()),
            ..EndpointUpdateParams::default()
        })
        .await
        .expect("adresse modifiée");
    assert_eq!(changed.name, "Salon nord");
    assert_eq!(
        store
            .endpoint_list(EndpointListParams {
                tenant: alpha(),
                subscriber_id: Some("c1".into()),
                channel: None,
            })
            .await
            .expect("adresses")
            .len(),
        1
    );
    assert!(store
        .device_list(DeviceListParams {
            tenant: alpha(),
            subscriber_id: "c1".into(),
        })
        .await
        .expect("appareils")
        .is_empty());

    // Fonctions de la personne connectée : la session système n'est pas une personne
    assert_eq!(
        refused(
            store
                .my_preference_get(MyPreferenceGetParams {
                    tenant: alpha(),
                    workflow: None,
                })
                .await
        ),
        "NOTIFICATION_PERMISSION_DENIED"
    );
    assert_eq!(
        refused(
            store
                .my_preference_set(MyPreferenceSetParams {
                    tenant: alpha(),
                    level: "subscriber_global".into(),
                    workflow: None,
                    category: None,
                    channels: None,
                    quiet_hours: None,
                })
                .await
        ),
        "NOTIFICATION_PERMISSION_DENIED"
    );
    assert_eq!(
        refused(
            store
                .my_endpoint_list(MyEndpointListParams {
                    tenant: alpha(),
                    channel: None,
                })
                .await
        ),
        "NOTIFICATION_PERMISSION_DENIED"
    );
    assert_eq!(
        refused(
            store
                .my_endpoint_update(EndpointUpdateParams {
                    tenant: alpha(),
                    endpoint: endpoint_id.clone(),
                    name: Some("x".into()),
                    ..EndpointUpdateParams::default()
                })
                .await
        ),
        "NOTIFICATION_PERMISSION_DENIED"
    );
    let my_ref = || EndpointRefParams {
        tenant: alpha(),
        endpoint: endpoint_id.clone(),
    };
    assert_eq!(
        refused(store.my_endpoint_delete(my_ref()).await),
        "NOTIFICATION_PERMISSION_DENIED"
    );
    assert_eq!(
        refused(store.my_device_delete(my_ref()).await),
        "NOTIFICATION_PERMISSION_DENIED"
    );
    assert_eq!(
        store
            .endpoint_delete(my_ref())
            .await
            .expect("adresse supprimée")
            .deleted,
        endpoint.id
    );

    // Purge, puis suppressions
    store
        .purge(PurgeParams {
            args: PurgeArgs { limit: Some(10) },
        })
        .await
        .expect("purge");
    store
        .topic_delete(topic_ref())
        .await
        .expect("sujet supprimé");
    store
        .category_delete(CategoryRefParams {
            tenant: alpha(),
            key: "actualites".into(),
        })
        .await
        .expect("catégorie supprimée");
    assert_eq!(
        store
            .subscriber_delete(reference())
            .await
            .expect("abonné supprimé")
            .deleted,
        subscriber.id
    );
}
