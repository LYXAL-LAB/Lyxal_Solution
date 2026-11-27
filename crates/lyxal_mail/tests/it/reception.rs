// SPDX-License-Identifier: AGPL-3.0-only

//! Remise d'un message reçu par SMTP, par les services Rust : résolution du destinataire,
//! remise chiffrée et inscrite, nouvel essai sans doublon, alias (un événement par compte),
//! dossier « Junk », élément refusé sans fichier laissé, remises concurrentes dans un compte
//! (UID uniques, compteurs exacts, écriture groupée), remises concurrentes dans plusieurs comptes
//! d'une organisation (aucune refusée, compteurs de volume exacts), lot dont un élément sort du
//! schéma,
//! maintenance des fiches d'idempotence, liste de blocage, attrape-tout et postmaster.

use bytes::Bytes;
use lyxal_mail::auth::{DkimResult, DmarcResult, IprevResult, SpfResult};
use lyxal_mail::models::{
    AccountUpdateParams, AddressCreateParams, BlockActiveParams, BlockCreateParams,
    BlockDeleteParams, BlockListParams, BlockReason, DeliveryBeginParams, DeliveryItem,
    DeliveryReservation, DeliveryRole, DomainUpdateParams, MailDatetime, MailboxRefParams,
    MessageEnvelope, MessageRefParams, Reception, RecipientResolveParams, SettingsSetParams,
};
use lyxal_mail::{
    delivery_key, AccountQueue, DeliveryOutcome, MailError, ReceivedDelivery, MAX_BATCH,
};
use lyxal_runtime::worker::CancellationToken;
use lyxal_storage::models::{ObjectUsageParams, UsageVerifyParams};
use lyxal_storage::PutRequest;
use lyxal_surreal::{ToSql, Value};
use std::convert::Infallible;
use std::sync::Arc;

use crate::support::{bench, code, Bench, Person};

/// Message reçu d'essai (nos en-têtes de réception en tête).
fn raw(subject: &str, id: &str) -> Bytes {
    Bytes::from(format!(
        "Return-Path: <paul@ailleurs.test>\r\n\
         Received: from mx.ailleurs.test by mx.alpha.test with ESMTPS id s1; Tue, 3 Nov 2026 10:00:01 +0100\r\n\
         From: Paul <paul@ailleurs.test>\r\n\
         To: Jean <jean@alpha.test>\r\n\
         Subject: {subject}\r\n\
         Date: Tue, 3 Nov 2026 10:00:00 +0100\r\n\
         Message-ID: <{id}@ailleurs.test>\r\n\
         \r\n\
         Bonjour, voici le devis.\r\n"
    ))
}

fn reception() -> Reception {
    Reception::new(
        SpfResult::Pass,
        DkimResult::Pass,
        DmarcResult::Pass,
        IprevResult::Pass,
        false,
        true,
    )
}

/// Remise d'un message à un compte du banc, dans l'organisation `tenant`.
fn received(account: &str, tenant: &str, message: Bytes, key: String) -> ReceivedDelivery {
    ReceivedDelivery {
        account: account.to_string(),
        tenant: lyxal_surreal::RecordId::new("auth_organization", tenant),
        role: DeliveryRole::Inbox,
        raw: message,
        received_at: None,
        delivery_key: key,
        reception: reception(),
    }
}

async fn count(bench: &Bench, query: &str) -> i64 {
    bench
        .value::<i64>(&format!("RETURN array::len({query});"))
        .await
}

/// Compteurs du compte et de ses dossiers égaux à ses messages ; UID uniques par dossier.
async fn coherent(bench: &Bench, account: &str) -> bool {
    bench
        .value::<bool>(&format!(
            "{{
                LET $id = {account};
                LET $boxes = (SELECT id, total, size, uid_next FROM mail_mailbox WHERE account = $id);
                LET $messages = (SELECT mailbox, size, uid, modseq FROM mail_message WHERE account = $id);
                LET $owner = (SELECT message_count, used_bytes, modseq FROM ONLY $id);
                RETURN $boxes.all(|$b| {{
                    LET $mine = $messages.filter(|$m| $m.mailbox = $b.id);
                    RETURN $b.total == array::len($mine) AND $b.size == math::sum($mine.map(|$m| $m.size))
                        AND $mine.all(|$m| $m.uid < $b.uid_next) AND array::len(array::distinct($mine.uid)) == array::len($mine);
                }}) AND $owner.message_count == array::len($messages) AND $owner.used_bytes == math::sum($messages.map(|$m| $m.size))
                    AND array::len(array::distinct($messages.modseq)) == array::len($messages)
                    AND $messages.all(|$m| $m.modseq <= $owner.modseq)
                    AND array::len(SELECT VALUE id FROM mail_message_date WHERE account = $id) == array::len($messages);
            }}"
        ))
        .await
}

#[tokio::test]
async fn a_received_message_is_resolved_delivered_once_and_published() {
    let bench = bench().await;
    let domain = bench.domain("alpha").await;
    let jean = bench.person("jean", "alpha", &domain).await;

    let resolved = bench
        .system
        .recipient_resolve(RecipientResolveParams {
            address: "Jean+Devis@Alpha.test".to_string(),
        })
        .await
        .expect("résolution");
    assert_eq!(resolved.address, "jean@alpha.test");
    assert_eq!(resolved.domain, "alpha.test");
    assert_eq!(resolved.tenant.to_sql(), "auth_organization:alpha");
    assert_eq!(resolved.max_message_bytes, 52_428_800);
    assert_eq!(resolved.accounts.len(), 1);
    assert_eq!(resolved.accounts[0].account.to_sql(), jean.account);
    assert!(!resolved.accounts[0].quota_full);
    let relay = bench
        .system
        .recipient_resolve(RecipientResolveParams {
            address: "jean@ailleurs.test".to_string(),
        })
        .await;
    assert_eq!(code(relay.map_err(MailError::from)), "MAIL_RELAY_DENIED");

    let message = raw("Devis du chantier", "devis-1");
    let key = delivery_key(&resolved.address, "paul@ailleurs.test", &message);
    let outcome = bench
        .ingest
        .receive(received(
            &jean.account,
            "alpha",
            message.clone(),
            key.clone(),
        ))
        .await
        .expect("remise");
    let DeliveryOutcome::Delivered {
        message: id,
        mailbox,
        uid,
    } = outcome
    else {
        panic!("message inscrit attendu");
    };
    assert_eq!((mailbox.to_sql(), uid), (jean.inbox.clone(), 1));

    // Lu par son titulaire : origine, résultats de réception, contenu déchiffré
    let read = jean
        .store
        .message_get(MessageRefParams {
            message: id.to_sql(),
        })
        .await
        .expect("message");
    assert_eq!(read.origin, "delivery");
    assert_eq!(read.reception, Some(reception()));
    assert!(!read.seen);
    assert_eq!(read.base_subject.as_deref(), Some("Devis du chantier"));
    assert_eq!(read.size, message.len() as i64);
    assert!(read.sent_at.is_some());
    let bytes = bench
        .content
        .read(&jean.store, &id.to_sql(), None)
        .await
        .expect("lecture");
    assert_eq!(bytes, message);

    // Nouvel essai de l'expéditeur : reconnu, ni fichier ni message de plus
    let files = count(&bench, "(SELECT VALUE id FROM storage_object)").await;
    let again = bench
        .ingest
        .receive(received(&jean.account, "alpha", message.clone(), key))
        .await
        .expect("nouvel essai");
    assert_eq!(again, DeliveryOutcome::Duplicate { message: id });
    assert_eq!(
        count(&bench, "(SELECT VALUE id FROM storage_object)").await,
        files
    );
    assert_eq!(
        count(&bench, "(SELECT VALUE id FROM mail_message)").await,
        1
    );

    // Un événement, sans adresse ni sujet ; aucun événement du stockage (décision S14)
    assert_eq!(
        count(
            &bench,
            "(SELECT VALUE id FROM event_outbox WHERE event_type = 'mail.message.received')"
        )
        .await,
        1
    );
    let payload = bench
        .value::<String>(
            "RETURN <string> (SELECT VALUE payload FROM ONLY event_outbox WHERE event_type = 'mail.message.received' LIMIT 1);",
        )
        .await;
    for word in ["@", "Devis", "ailleurs", "alpha.test", "devis-1"] {
        assert!(!payload.contains(word), "{word} dans la charge utile");
    }
    assert_eq!(
        count(
            &bench,
            "(SELECT VALUE id FROM event_outbox WHERE string::starts_with(event_type, 'storage.object'))"
        )
        .await,
        0
    );
    assert!(coherent(&bench, &jean.account).await);
}

#[tokio::test]
async fn an_alias_delivers_to_each_account_and_junk_is_honoured() {
    let bench = bench().await;
    let domain = bench.domain("alpha").await;
    let jean = bench.person("jean", "alpha", &domain).await;
    let marie = bench.person("marie", "alpha", &domain).await;
    bench
        .system
        .address_create(AddressCreateParams {
            domain: domain.clone(),
            local_part: "equipe".to_string(),
            kind: "alias".to_string(),
            account: None,
            targets: Some(vec![jean.account.clone(), marie.account.clone()]),
            senders: None,
            forward_to: None,
        })
        .await
        .expect("alias");
    let resolved = bench
        .system
        .recipient_resolve(RecipientResolveParams {
            address: "equipe@alpha.test".to_string(),
        })
        .await
        .expect("résolution");
    assert_eq!(resolved.accounts.len(), 2);

    let message = raw("Réunion", "reunion-1");
    let key = delivery_key(&resolved.address, "paul@ailleurs.test", &message);
    for target in &resolved.accounts {
        let mut delivery = received(
            &target.account.to_sql(),
            "alpha",
            message.clone(),
            key.clone(),
        );
        delivery.role = DeliveryRole::Junk;
        let outcome = bench.ingest.receive(delivery).await.expect("remise");
        assert!(matches!(outcome, DeliveryOutcome::Delivered { uid: 1, .. }));
    }
    // Un contenu et un événement par compte (décisions M14, S15), dans le dossier « Junk »
    assert_eq!(
        count(&bench, "(SELECT VALUE id FROM mail_content)").await,
        2
    );
    assert_eq!(
        bench
            .values::<String>(
                "SELECT VALUE payload.account FROM event_outbox WHERE event_type = 'mail.message.received' ORDER BY payload.account;"
            )
            .await
            .len(),
        2
    );
    assert_eq!(
        bench
            .values::<String>(
                "SELECT VALUE mailbox.role FROM mail_message WHERE origin = 'delivery';"
            )
            .await,
        vec!["junk".to_string(), "junk".to_string()]
    );
    assert!(coherent(&bench, &jean.account).await);
    assert!(coherent(&bench, &marie.account).await);
}

#[tokio::test]
async fn a_refused_item_leaves_no_file_and_does_not_cancel_its_neighbour() {
    let bench = bench().await;
    let domain = bench.domain("alpha").await;
    let jean = bench.person("jean", "alpha", &domain).await;
    let first = raw("Premier", "quota-1");
    let second = raw("Second", "quota-2");
    // Place pour un seul des deux messages : tous deux passent l'ouverture (rien n'est encore
    // inscrit), le second est refusé à l'inscription
    bench
        .system
        .account_update(AccountUpdateParams {
            account: jean.account.clone(),
            quota_bytes: Some(first.len() as i64 + 10),
            state: None,
            clear: Vec::new(),
        })
        .await
        .expect("quota");
    let (one, two) = tokio::join!(
        bench.ingest.receive(received(
            &jean.account,
            "alpha",
            first.clone(),
            delivery_key("jean@alpha.test", "", &first)
        )),
        bench.ingest.receive(received(
            &jean.account,
            "alpha",
            second.clone(),
            delivery_key("jean@alpha.test", "", &second)
        )),
    );
    let (delivered, refused) = match (one, two) {
        (Ok(done), Err(error)) | (Err(error), Ok(done)) => (done, error),
        other => panic!("une remise inscrite et une refusée attendues : {other:?}"),
    };
    assert!(matches!(
        delivered,
        DeliveryOutcome::Delivered { uid: 1, .. }
    ));
    assert_eq!(refused.code(), "MAIL_QUOTA_EXCEEDED");
    assert!(refused.is_business());
    assert!(!refused.is_retryable());
    // Le fichier du message refusé, que rien ne référence, est supprimé aussitôt
    assert_eq!(
        count(
            &bench,
            "(SELECT VALUE id FROM storage_object WHERE state = 'available')"
        )
        .await,
        1
    );
    assert_eq!(
        count(&bench, "(SELECT VALUE id FROM mail_message)").await,
        1
    );
    assert_eq!(
        count(&bench, "(SELECT VALUE id FROM mail_delivery)").await,
        1
    );
    assert!(coherent(&bench, &jean.account).await);

    // Compte plein : refus dès l'ouverture, rien n'est écrit
    let third = raw("Troisième", "quota-3");
    let files = count(&bench, "(SELECT VALUE id FROM storage_object)").await;
    let full = bench
        .ingest
        .receive(received(
            &jean.account,
            "alpha",
            third.clone(),
            delivery_key("jean@alpha.test", "", &third),
        ))
        .await;
    assert_eq!(code(full), "MAIL_QUOTA_EXCEEDED");
    assert_eq!(
        count(&bench, "(SELECT VALUE id FROM storage_object)").await,
        files
    );
}

#[tokio::test(flavor = "multi_thread", worker_threads = 4)]
async fn concurrent_deliveries_into_one_account_are_ordered_and_grouped() {
    const CLIENTS: usize = 20;
    const EACH: usize = 5;
    let bench = bench().await;
    let domain = bench.domain("alpha").await;
    let jean = bench.person("jean", "alpha", &domain).await;
    let ingest = Arc::new(bench.ingest.clone());
    let mut clients = tokio::task::JoinSet::new();
    for client in 0..CLIENTS {
        let ingest = ingest.clone();
        let account = jean.account.clone();
        clients.spawn(async move {
            let mut uids = Vec::new();
            for index in 0..EACH {
                let message = raw("Lot", &format!("lot-{client}-{index}"));
                let key = delivery_key("jean@alpha.test", "paul@ailleurs.test", &message);
                match ingest
                    .receive(received(&account, "alpha", message, key))
                    .await
                {
                    Ok(DeliveryOutcome::Delivered { uid, .. }) => uids.push(uid),
                    other => panic!("remise refusée : {other:?}"),
                }
            }
            uids
        });
    }
    let mut uids = Vec::new();
    while let Some(done) = clients.join_next().await {
        uids.extend(done.expect("client"));
    }
    uids.sort_unstable();
    let total = (CLIENTS * EACH) as i64;
    assert_eq!(uids, (1..=total).collect::<Vec<_>>());
    assert!(coherent(&bench, &jean.account).await);
    let inbox = jean
        .store
        .mailbox_get(MailboxRefParams {
            mailbox: jean.inbox.clone(),
        })
        .await
        .expect("dossier");
    assert_eq!((inbox.total, inbox.uid_next), (total, total + 1));
    assert_eq!(
        count(
            &bench,
            "(SELECT VALUE id FROM event_outbox WHERE event_type = 'mail.message.received')"
        )
        .await,
        total
    );
    // Ordre dans le nœud : aucun conflit entre remises d'un même compte ; écriture groupée :
    // moins d'appels que de messages, aucun lot au-delà de la limite
    let stats = bench.ingest.delivery_stats();
    assert_eq!(stats.items, total as u64);
    assert_eq!(stats.conflicts, 0);
    assert_eq!(stats.split_batches, 0);
    assert!(stats.batches < stats.items, "{stats:?}");
    assert!(stats.largest_batch > 1 && stats.largest_batch <= MAX_BATCH as u64);
}

/// Les fichiers d'une organisation s'écrivent sans ordre imposé par le nœud : les compteurs de
/// volume de `lyxal_storage` sont répartis sur 64 lignes, et un conflit restant est rejoué par
/// `lyxal_storage`. Vingt clients remettent en même temps dans huit comptes d'une organisation :
/// aucune remise refusée, compteurs des comptes et du stockage égaux aux fiches.
#[tokio::test(flavor = "multi_thread", worker_threads = 4)]
async fn concurrent_deliveries_into_one_organization_are_all_accepted() {
    const CLIENTS: usize = 20;
    const EACH: usize = 10;
    const NAMES: [&str; 8] = ["jean", "marie", "luc", "anne", "paul", "lea", "hugo", "zoe"];
    let bench = bench().await;
    let domain = bench.domain("alpha").await;
    let mut accounts = Vec::new();
    for name in NAMES {
        let person = bench.person(name, "alpha", &domain).await;
        accounts.push((person.account, format!("{name}@alpha.test")));
    }
    let accounts = Arc::new(accounts);
    let ingest = Arc::new(bench.ingest.clone());
    let mut clients = tokio::task::JoinSet::new();
    for client in 0..CLIENTS {
        let ingest = ingest.clone();
        let accounts = accounts.clone();
        clients.spawn(async move {
            for index in 0..EACH {
                let (account, address) = &accounts[(client + index) % accounts.len()];
                let message = raw("Organisation", &format!("org-{client}-{index}"));
                let key = delivery_key(address, "paul@ailleurs.test", &message);
                match ingest
                    .receive(received(account, "alpha", message, key))
                    .await
                {
                    Ok(DeliveryOutcome::Delivered { .. }) => {}
                    other => panic!("remise refusée : {other:?}"),
                }
            }
        });
    }
    while let Some(done) = clients.join_next().await {
        done.expect("client");
    }
    let total = (CLIENTS * EACH) as i64;
    assert_eq!(
        count(
            &bench,
            "(SELECT VALUE id FROM mail_message WHERE origin = 'delivery')"
        )
        .await,
        total
    );
    for (account, _) in accounts.iter() {
        assert!(coherent(&bench, account).await, "{account}");
    }
    // Compteurs de volume : un fichier disponible par message, sommes égales aux fiches
    let usage = bench
        .storage_store
        .object_usage(ObjectUsageParams {
            tenant: Some("auth_organization:alpha".to_string()),
        })
        .await
        .expect("volume");
    assert_eq!((usage.objects, usage.reserved_bytes), (total, 0));
    let report = bench
        .storage_store
        .usage_verify(UsageVerifyParams {
            tenant: Some("auth_organization:alpha".to_string()),
        })
        .await
        .expect("contrôle");
    assert!(report.valid, "{report:?}");
}

/// Élément de lot construit à la main sur un contenu réservé et un fichier écrit.
async fn prepared_item(bench: &Bench, person: &Person, id: &str, subject: String) -> DeliveryItem {
    let message = raw("Essai", id);
    let key = delivery_key("jean@alpha.test", "", &message);
    let begun = bench
        .system
        .delivery_begin(DeliveryBeginParams {
            account: person.account.clone(),
            size: message.len() as i64,
            delivery_key: key.clone(),
        })
        .await
        .expect("ouverture");
    let DeliveryReservation::Reserved {
        content,
        storage_key,
    } = begun
    else {
        panic!("contenu réservé attendu");
    };
    let bucket = bench
        .value::<String>(
            "RETURN <string> (SELECT VALUE id FROM ONLY storage_bucket WHERE name = 'lyxal-mail' LIMIT 1);",
        )
        .await;
    let object = bench
        .storage
        .put(
            PutRequest {
                bucket,
                key: storage_key,
                filename: "message.eml".to_string(),
                content_type: Some("message/rfc822".to_string()),
                size: Some(message.len() as u64),
            },
            futures::stream::iter([Ok::<Bytes, Infallible>(message)]),
        )
        .await
        .expect("fichier");
    DeliveryItem {
        content: content.to_sql(),
        object: object.id.to_sql(),
        role: DeliveryRole::Inbox,
        received_at: MailDatetime::now(),
        delivery_key: key,
        message_id: Some(format!("{id}@ailleurs.test")),
        in_reply_to: Vec::new(),
        references: Vec::new(),
        base_subject: None,
        is_report: false,
        envelope: MessageEnvelope {
            subject: Some(subject),
            ..MessageEnvelope::default()
        },
        structure: Value::Object(Default::default()),
        has_attachment: false,
        reception: reception(),
    }
}

#[tokio::test]
async fn an_item_outside_the_schema_fails_alone_when_its_batch_is_replayed() {
    let bench = bench().await;
    let domain = bench.domain("alpha").await;
    let jean = bench.person("jean", "alpha", &domain).await;
    // Premier dépôt : crée le bucket chiffré du courrier de l'organisation
    let first = raw("Premier", "schema-0");
    bench
        .ingest
        .receive(received(
            &jean.account,
            "alpha",
            first.clone(),
            delivery_key("jean@alpha.test", "", &first),
        ))
        .await
        .expect("premier dépôt");

    let good = prepared_item(&bench, &jean, "schema-1", "Sujet".to_string()).await;
    // Sujet plus long que le schéma de mail_message ne l'accepte : le moteur de lyxal_core ne
    // contrôle que la taille sérialisée de l'enveloppe (décision S12), l'écriture est refusée
    let outside = prepared_item(&bench, &jean, "schema-2", "x".repeat(20_000)).await;
    let other = prepared_item(&bench, &jean, "schema-3", "Sujet".to_string()).await;
    let queue = AccountQueue::new(bench.system.clone());
    let (one, two, three) = tokio::join!(
        queue.commit(&jean.account, good),
        queue.commit(&jean.account, outside),
        queue.commit(&jean.account, other),
    );
    assert!(matches!(one, Ok(DeliveryOutcome::Delivered { uid: 2, .. })));
    assert!(matches!(
        three,
        Ok(DeliveryOutcome::Delivered { uid: 3, .. })
    ));
    let refused = two.expect_err("élément hors schéma refusé");
    // Refus de la base à l'écriture, pas un code MAIL_* : rien n'est inscrit pour cet élément
    assert!(!refused.is_business());
    assert_eq!(refused.code(), "SURREAL_DATABASE_ERROR");
    let stats = queue.stats();
    assert_eq!(stats.split_batches, 1, "{stats:?}");
    assert_eq!(
        count(&bench, "(SELECT VALUE id FROM mail_message)").await,
        3
    );
    assert_eq!(
        count(&bench, "(SELECT VALUE id FROM mail_delivery)").await,
        3
    );
    assert!(coherent(&bench, &jean.account).await);
}

#[tokio::test]
async fn maintenance_purges_expired_delivery_records() {
    let bench = bench().await;
    let domain = bench.domain("alpha").await;
    let jean = bench.person("jean", "alpha", &domain).await;
    let message = raw("Gardé", "purge-1");
    bench
        .ingest
        .receive(received(
            &jean.account,
            "alpha",
            message.clone(),
            delivery_key("jean@alpha.test", "", &message),
        ))
        .await
        .expect("remise");
    bench
        .run(&format!(
            "CREATE mail_delivery:ancien CONTENT {{ tenant: auth_organization:alpha, account: {}, message: mail_message:ancien, expires_at: time::now() - 1h }};",
            jean.account
        ))
        .await;
    let report = bench
        .maintenance
        .run(&CancellationToken::new())
        .await
        .expect("maintenance");
    assert_eq!(report.deliveries, 1);
    assert_eq!(
        count(&bench, "(SELECT VALUE id FROM mail_delivery)").await,
        1
    );
}

#[tokio::test]
async fn the_block_list_and_reception_settings_go_through_typed_calls() {
    let bench = bench().await;
    let domain = bench.domain("alpha").await;
    let jean = bench.person("jean", "alpha", &domain).await;

    // Bannissement automatique (session système), récidive, puis entrée manuelle
    let ban = |reason| BlockCreateParams {
        network: "192.0.2.7/32".to_string(),
        reason: Some(reason),
        expires_at: None,
    };
    let first = bench
        .system
        .block_create(ban(BlockReason::Harvest))
        .await
        .expect("bannissement");
    assert_eq!((first.reason, first.strikes), (BlockReason::Harvest, 1));
    assert!(first.expires_at.is_some() && first.created_by.is_none());
    let second = bench
        .system
        .block_create(ban(BlockReason::Errors))
        .await
        .expect("récidive");
    assert_eq!((second.reason, second.strikes), (BlockReason::Harvest, 2));
    let manual = bench
        .system
        .block_create(BlockCreateParams {
            network: "2001:DB8::/32".to_string(),
            reason: None,
            expires_at: None,
        })
        .await
        .expect("entrée manuelle");
    assert_eq!(manual.network, "2001:db8::/32");
    assert_eq!(manual.reason, BlockReason::Manual);
    assert!(manual.expires_at.is_none());
    let active = bench
        .system
        .block_active(BlockActiveParams::default())
        .await
        .expect("réseaux en vigueur");
    assert_eq!(active.networks, vec!["192.0.2.7/32", "2001:db8::/32"]);
    let page = bench
        .system
        .block_list(BlockListParams {
            after: None,
            limit: Some(1),
        })
        .await
        .expect("liste");
    assert_eq!(page.items.len(), 1);
    assert_eq!(page.next.as_deref(), Some("192.0.2.7/32"));
    let deleted = bench
        .system
        .block_delete(BlockDeleteParams {
            network: "192.0.2.7/32".to_string(),
        })
        .await
        .expect("retrait");
    assert!(deleted.deleted);
    // Un titulaire n'a aucune de ces fonctions
    let denied = jean
        .store
        .block_active(BlockActiveParams::default())
        .await
        .map_err(MailError::from);
    assert_eq!(code(denied), "MAIL_PERMISSION_DENIED");

    // Attrape-tout du domaine et postmaster de l'installation
    let updated = bench
        .system
        .domain_update(DomainUpdateParams {
            domain: domain.clone(),
            catch_all: Some(jean.account.clone()),
            ..DomainUpdateParams::default()
        })
        .await
        .expect("attrape-tout");
    assert_eq!(
        updated.catch_all.map(|account| account.to_sql()),
        Some(jean.account.clone())
    );
    assert!(updated.postmaster.is_none());
    let settings = bench
        .system
        .settings_set(SettingsSetParams {
            postmaster: Some("Jean@alpha.test".to_string()),
            ..SettingsSetParams::default()
        })
        .await
        .expect("réglage");
    assert_eq!(settings.postmaster.as_deref(), Some("jean@alpha.test"));
    for (address, inscribed) in [
        ("inconnu@alpha.test", "inconnu@alpha.test"),
        ("postmaster", "jean@alpha.test"),
    ] {
        let resolved = bench
            .system
            .recipient_resolve(RecipientResolveParams {
                address: address.to_string(),
            })
            .await
            .expect("résolution");
        assert_eq!(resolved.address, inscribed);
        assert_eq!(resolved.accounts[0].account.to_sql(), jean.account);
    }
    let cleared = bench
        .system
        .domain_update(DomainUpdateParams {
            domain,
            clear: vec!["catch_all".to_string()],
            ..DomainUpdateParams::default()
        })
        .await
        .expect("attrape-tout effacé");
    assert!(cleared.catch_all.is_none());
}
