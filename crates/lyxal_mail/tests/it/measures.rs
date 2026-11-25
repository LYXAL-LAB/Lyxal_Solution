// SPDX-License-Identifier: AGPL-3.0-only

//! Mesures de la remise (plan du lot 5, §10.4 et §10.5), hors CI : essais `#[ignore]`, à lancer
//! à la main sur un binaire optimisé,
//!
//! ```text
//! cargo test -p lyxal_mail --release --test it -- --ignored --nocapture --test-threads 1 measures
//! ```
//!
//! Base SurrealDB embarquée en mémoire, support disque dans un dossier temporaire, un seul nœud,
//! messages de 10 Kio remis par [`MailIngest::receive`] (le chemin de la session SMTP, sans le
//! dialogue SMTP ni les contrôles d'authenticité, livrés avec la session). Les relevés sont
//! reportés dans `README.md` (« Mesures »).

use bytes::Bytes;
use lyxal_crypto::{SecretContext, StreamKey};
use lyxal_mail::models::{
    AccountCreateParams, DeliveryBeginParams, DeliveryCommitParams, DeliveryItem,
    DeliveryReservation, DeliveryRole, EnvelopeAddress, MailDatetime, MessageEnvelope, Reception,
};
use lyxal_mail::{delivery_key, DeliveryOutcome, MailIngest, QueueStats, ReceivedDelivery};
use lyxal_storage::PutRequest;
use lyxal_surreal::{RecordId, ToSql};
use std::collections::BTreeMap;
use std::convert::Infallible;
use std::sync::atomic::{AtomicUsize, Ordering};
use std::sync::Arc;
use std::time::{Duration, Instant};

use crate::support::{measure_bench, Bench};

/// Taille d'un message d'essai, en octets.
const MESSAGE_BYTES: usize = 10 * 1024;

/// Message de 10 Kio, unique par `id`.
fn message(id: &str) -> Bytes {
    let mut text = format!(
        "Return-Path: <paul@ailleurs.test>\r\n\
         Received: from mx.ailleurs.test by mx.alpha.test with ESMTPS id {id}; Tue, 3 Nov 2026 10:00:01 +0100\r\n\
         From: Paul <paul@ailleurs.test>\r\n\
         To: Jean <jean@alpha.test>, Marie <marie@alpha.test>\r\n\
         Cc: Chantier <chantier@alpha.test>\r\n\
         Subject: Compte rendu de chantier {id}\r\n\
         Date: Tue, 3 Nov 2026 10:00:00 +0100\r\n\
         Message-ID: <{id}@ailleurs.test>\r\n\
         MIME-Version: 1.0\r\n\
         Content-Type: text/plain; charset=utf-8\r\n\
         \r\n"
    );
    while text.len() + 66 <= MESSAGE_BYTES {
        text.push_str("Le coulage de la dalle est prévu mardi ; merci de confirmer.\r\n");
    }
    while text.len() < MESSAGE_BYTES {
        text.push('.');
    }
    Bytes::from(text)
}

fn reception() -> Reception {
    Reception {
        spf: "pass".to_string(),
        dkim: "pass".to_string(),
        dmarc: "pass".to_string(),
        iprev: "pass".to_string(),
        antivirus: "not_scanned".to_string(),
        spam: "none".to_string(),
        tls: true,
    }
}

/// Comptes de courrier créés par la session système : `count` par organisation.
async fn accounts(bench: &Bench, organizations: &[&str], count: usize) -> Vec<(String, String)> {
    let mut created = Vec::new();
    for organization in organizations {
        let domain = bench.domain(organization).await;
        for index in 0..count {
            let name = format!("{organization}{index}");
            bench
                .run(&format!(
                    "CREATE auth_identity:{name} CONTENT {{ schema: auth_identity_schema:default_v1, traits: {{ email: '{name}@lyxal.test' }} }};
                     RELATE auth_identity:{name}->auth_member_of->auth_organization:{organization};"
                ))
                .await;
            let account = bench
                .system
                .account_create(AccountCreateParams {
                    identity: format!("auth_identity:{name}"),
                    domain: domain.clone(),
                    local_part: name,
                    quota_bytes: None,
                })
                .await
                .expect("compte")
                .account
                .id
                .to_sql();
            created.push((account, organization.to_string()));
        }
    }
    created
}

/// Centile d'une série de durées, en millisecondes.
fn percentile(sorted: &[Duration], percent: usize) -> f64 {
    if sorted.is_empty() {
        return 0.0;
    }
    let index = (sorted.len() * percent / 100).min(sorted.len() - 1);
    sorted[index].as_secs_f64() * 1_000.0
}

fn mean(durations: &[Duration]) -> f64 {
    if durations.is_empty() {
        return 0.0;
    }
    durations.iter().map(Duration::as_secs_f64).sum::<f64>() * 1_000.0 / durations.len() as f64
}

/// Remet `total` messages par `clients` clients simultanés, répartis à tour de rôle sur les
/// comptes ; imprime débit, latences, refus et relevé de l'ordre des inscriptions.
async fn load(
    label: &str,
    bench: &Bench,
    targets: Vec<(String, String)>,
    clients: usize,
    total: usize,
    nodes: usize,
) {
    // Nœuds : chacun a son ordre des inscriptions et ses tours d'écriture (même base)
    let mut ingests = vec![bench.ingest.clone()];
    for _ in 1..nodes {
        ingests.push(MailIngest::new(
            bench.system.clone(),
            bench.storage.clone(),
            "default",
        ));
    }
    let stats = |ingests: &[MailIngest]| {
        ingests
            .iter()
            .map(MailIngest::delivery_stats)
            .fold(QueueStats::default(), |sum, one| QueueStats {
                batches: sum.batches + one.batches,
                items: sum.items + one.items,
                largest_batch: sum.largest_batch.max(one.largest_batch),
                conflicts: sum.conflicts + one.conflicts,
                split_batches: sum.split_batches + one.split_batches,
            })
    };
    // Premier dépôt de chaque organisation hors mesure (création du bucket chiffré et de sa clé)
    let mut warmed = Vec::new();
    for (account, organization) in &targets {
        if !warmed.contains(organization) {
            warmed.push(organization.clone());
            deliver(
                &bench.ingest,
                account,
                organization,
                &format!("chauffe-{organization}"),
            )
            .await
            .expect("premier dépôt");
        }
    }
    let before = stats(&ingests);
    let targets = Arc::new(targets);
    let next = Arc::new(AtomicUsize::new(0));
    let started = Instant::now();
    let mut tasks = tokio::task::JoinSet::new();
    for client in 0..clients {
        let ingest = ingests[client % ingests.len()].clone();
        let targets = targets.clone();
        let next = next.clone();
        tasks.spawn(async move {
            let mut latencies = Vec::new();
            let mut refused: BTreeMap<String, usize> = BTreeMap::new();
            loop {
                let index = next.fetch_add(1, Ordering::Relaxed);
                if index >= total {
                    return (latencies, refused);
                }
                let (account, organization) = &targets[index % targets.len()];
                let begun = Instant::now();
                match deliver(&ingest, account, organization, &format!("m{index}")).await {
                    Ok(DeliveryOutcome::Delivered { .. }) => latencies.push(begun.elapsed()),
                    Ok(DeliveryOutcome::Duplicate { .. }) => {
                        *refused.entry("doublon".to_string()).or_default() += 1
                    }
                    Err(error) => *refused.entry(error.code()).or_default() += 1,
                }
            }
        });
    }
    let mut latencies = Vec::new();
    let mut refused: BTreeMap<String, usize> = BTreeMap::new();
    while let Some(done) = tasks.join_next().await {
        let (times, errors) = done.expect("client");
        latencies.extend(times);
        for (code, count) in errors {
            *refused.entry(code).or_default() += count;
        }
    }
    let elapsed = started.elapsed();
    latencies.sort_unstable();
    let after = stats(&ingests);
    let inscribed = bench
        .value::<i64>(
            "RETURN array::len(SELECT VALUE id FROM mail_message WHERE origin = 'delivery');",
        )
        .await;
    println!(
        "MESURE {label} : {} remises en {:.2} s, {:.1} par seconde ; latence p50 {:.1} ms, p95 {:.1} ms ; refusées : {} {:?} ; lots : {} appels pour {} messages (plus grand lot : {}), conflits rejoués : {}, lots repris : {} ; messages inscrits : {}",
        latencies.len(),
        elapsed.as_secs_f64(),
        latencies.len() as f64 / elapsed.as_secs_f64(),
        percentile(&latencies, 50),
        percentile(&latencies, 95),
        refused.values().sum::<usize>(),
        refused,
        after.batches - before.batches,
        after.items - before.items,
        after.largest_batch,
        after.conflicts - before.conflicts,
        after.split_batches - before.split_batches,
        inscribed,
    );
}

async fn deliver(
    ingest: &MailIngest,
    account: &str,
    organization: &str,
    id: &str,
) -> lyxal_mail::MailResult<DeliveryOutcome> {
    let raw = message(id);
    let key = delivery_key(account, "paul@ailleurs.test", &raw);
    ingest
        .receive(ReceivedDelivery {
            account: account.to_string(),
            tenant: RecordId::new("auth_organization", organization),
            role: DeliveryRole::Inbox,
            raw,
            received_at: None,
            delivery_key: key,
            reception: reception(),
        })
        .await
}

#[tokio::test(flavor = "multi_thread", worker_threads = 4)]
#[ignore = "mesure, hors CI"]
async fn measures_one_account_twenty_clients() {
    let (bench, engine) = measure_bench().await;
    let targets = accounts(&bench, &["alpha"], 1).await;
    load(
        &format!("un compte, 20 clients, {engine}"),
        &bench,
        targets,
        20,
        1_000,
        1,
    )
    .await;
}

#[tokio::test(flavor = "multi_thread", worker_threads = 4)]
#[ignore = "mesure, hors CI"]
async fn measures_hundred_accounts_fifty_clients_one_organization() {
    let (bench, engine) = measure_bench().await;
    let targets = accounts(&bench, &["alpha"], 100).await;
    let label = format!("100 comptes d'une organisation, 50 clients, {engine}");
    load(&label, &bench, targets, 50, 3_000, 1).await;
}

#[tokio::test(flavor = "multi_thread", worker_threads = 4)]
#[ignore = "mesure, hors CI"]
async fn measures_hundred_accounts_fifty_clients_two_organizations() {
    let (bench, engine) = measure_bench().await;
    let targets = accounts(&bench, &["alpha", "beta"], 50).await;
    let label = format!("100 comptes de deux organisations, 50 clients, {engine}");
    load(&label, &bench, targets, 50, 3_000, 1).await;
}

/// Deux nœuds simulés dans le processus (deux services de remise sur la même base, chacun avec
/// son ordre des inscriptions) : mesure du repli de la décision S11 (plus de 1 % de remises
/// refusées après rejeu). Sur la base embarquée seulement : un serveur exécute une à une les
/// requêtes d'une même connexion, ce qui cacherait les conflits entre nœuds.
#[tokio::test(flavor = "multi_thread", worker_threads = 4)]
#[ignore = "mesure, hors CI"]
async fn measures_two_nodes_one_account() {
    let (bench, engine) = measure_bench().await;
    let targets = accounts(&bench, &["alpha"], 1).await;
    let label = format!("deux nœuds, un compte, 20 clients, {engine}");
    load(&label, &bench, targets, 20, 1_000, 2).await;
}

/// Temps de chaque étape d'une remise, une à la fois (aucune concurrence), et coût des clés
/// « fichiers » (décision S13) : scellement et ouverture d'une clé de fichier.
#[tokio::test(flavor = "multi_thread", worker_threads = 4)]
#[ignore = "mesure, hors CI"]
async fn measures_steps_and_file_keys() {
    const ROUNDS: usize = 300;
    let (bench, engine) = measure_bench().await;
    let targets = accounts(&bench, &["alpha"], 1).await;
    let (account, _) = &targets[0];
    deliver(&bench.ingest, account, "alpha", "chauffe")
        .await
        .expect("premier dépôt");
    let bucket = bench
        .value::<String>(
            "RETURN <string> (SELECT VALUE id FROM ONLY storage_bucket WHERE name = 'lyxal-mail' LIMIT 1);",
        )
        .await;
    let limits = lyxal_mail_proto::mime::MimeLimits::default();
    let (mut parse, mut begin, mut put, mut commit, mut whole) =
        (Vec::new(), Vec::new(), Vec::new(), Vec::new(), Vec::new());
    for round in 0..ROUNDS {
        let raw = message(&format!("etape-{round}"));
        let key = delivery_key(account, "paul@ailleurs.test", &raw);
        let started = Instant::now();
        let parsed = lyxal_mail_proto::mime::parse(&raw, &limits).expect("lecture MIME");
        parse.push(started.elapsed());
        let step = Instant::now();
        let reserved = bench
            .system
            .delivery_begin(DeliveryBeginParams {
                account: account.clone(),
                size: raw.len() as i64,
                delivery_key: key.clone(),
            })
            .await
            .expect("ouverture");
        begin.push(step.elapsed());
        let DeliveryReservation::Reserved {
            content,
            storage_key,
        } = reserved
        else {
            panic!("contenu réservé attendu");
        };
        let step = Instant::now();
        let object = bench
            .storage
            .put(
                PutRequest {
                    bucket: bucket.clone(),
                    key: storage_key,
                    filename: "message.eml".to_string(),
                    content_type: Some("message/rfc822".to_string()),
                    size: Some(raw.len() as u64),
                },
                futures::stream::iter([Ok::<Bytes, Infallible>(raw.clone())]),
            )
            .await
            .expect("fichier");
        put.push(step.elapsed());
        // Enveloppe de la taille de celle du message d'essai (un expéditeur, trois destinataires)
        let person = |name: &str| EnvelopeAddress {
            name: Some(name.to_string()),
            address: Some(format!("{}@alpha.test", name.to_lowercase())),
            group: None,
        };
        let item = DeliveryItem {
            content: content.to_sql(),
            object: object.id.to_sql(),
            role: DeliveryRole::Inbox,
            received_at: MailDatetime::now(),
            delivery_key: key,
            message_id: Some(format!("etape-{round}@ailleurs.test")),
            in_reply_to: Vec::new(),
            references: Vec::new(),
            base_subject: parsed.base_subject.clone(),
            is_report: false,
            envelope: MessageEnvelope {
                date: Some(MailDatetime::now()),
                subject: Some(format!("Compte rendu de chantier etape-{round}")),
                message_id: Some(format!("etape-{round}@ailleurs.test")),
                from: Some(vec![person("Paul")]),
                to: Some(vec![person("Jean"), person("Marie")]),
                cc: Some(vec![person("Chantier")]),
                ..MessageEnvelope::default()
            },
            structure: lyxal_surreal::Value::Object(Default::default()),
            has_attachment: false,
            reception: reception(),
        };
        let step = Instant::now();
        let done = bench
            .system
            .delivery_commit(DeliveryCommitParams {
                account: account.clone(),
                items: vec![item],
            })
            .await
            .expect("inscription");
        commit.push(step.elapsed());
        assert!(done.items[0].error.is_none());
        whole.push(started.elapsed());
    }
    println!(
        "MESURE étapes d'une remise, {engine} (moyennes sur {ROUNDS}, sans concurrence) : lecture MIME {:.3} ms ; fn::mail_delivery_begin {:.2} ms ; écriture chiffrée du fichier (lyxal_storage) {:.2} ms ; fn::mail_delivery_commit {:.2} ms ; total {:.2} ms",
        mean(&parse), mean(&begin), mean(&put), mean(&commit), mean(&whole),
    );

    // Clés « fichiers » : coût d'un scellement et d'une ouverture, tels que lyxal_storage les
    // demande pour chaque fichier (clé de l'organisation relue et rouverte à chaque appel)
    let tenant = RecordId::new("auth_organization", "alpha");
    let context = SecretContext::with_tenant(
        "alpha",
        "lyxal_storage",
        "storage_object",
        "mesure",
        "content_key",
    )
    .expect("contexte");
    let (mut seal, mut open) = (Vec::new(), Vec::new());
    for _ in 0..ROUNDS {
        let key = StreamKey::generate().expect("clé");
        let step = Instant::now();
        let sealed = bench
            .file_keys
            .seal(Some(&tenant), &key, &context)
            .await
            .expect("scellement");
        seal.push(step.elapsed());
        let step = Instant::now();
        bench
            .file_keys
            .open(Some(&tenant), &sealed, &context)
            .await
            .expect("ouverture");
        open.push(step.elapsed());
    }
    // Part de la lecture du trousseau en base dans ce coût (le reste : ouverture de la clé de
    // l'organisation par la clé maîtresse, scellement ou ouverture de la clé du fichier)
    let mut ring = Vec::new();
    for _ in 0..ROUNDS {
        let step = Instant::now();
        assert!(
            bench
                .value::<bool>(
                    "RETURN fn::secrets_tenant_key_ring({ tenant: 'auth_organization:alpha', purpose: 'files' }).ok;"
                )
                .await
        );
        ring.push(step.elapsed());
    }
    // Avec le cache des clés « fichiers » (ouvertures seulement ; un scellement relit toujours
    // le trousseau en base)
    let cached = bench.file_keys.clone().with_cache();
    let (mut cached_seal, mut cached_open) = (Vec::new(), Vec::new());
    for _ in 0..ROUNDS {
        let key = StreamKey::generate().expect("clé");
        let step = Instant::now();
        let sealed = cached
            .seal(Some(&tenant), &key, &context)
            .await
            .expect("scellement");
        cached_seal.push(step.elapsed());
        let step = Instant::now();
        cached
            .open(Some(&tenant), &sealed, &context)
            .await
            .expect("ouverture");
        cached_open.push(step.elapsed());
    }
    println!(
        "MESURE clés « fichiers » avec cache, {engine} ({ROUNDS} appels) : FileKeys::seal moyenne {:.3} ms ; FileKeys::open moyenne {:.3} ms ; relevé du cache : {:?}",
        mean(&cached_seal),
        mean(&cached_open),
        cached.cache_stats(),
    );
    seal.sort_unstable();
    open.sort_unstable();
    println!(
        "MESURE clés « fichiers », {engine} (décision S13, {ROUNDS} appels) : FileKeys::seal moyenne {:.3} ms, p50 {:.3} ms, p95 {:.3} ms ; FileKeys::open moyenne {:.3} ms, p50 {:.3} ms, p95 {:.3} ms ; dont lecture du trousseau en base (fn::secrets_tenant_key_ring) {:.3} ms ; part du scellement dans une remise : {:.1} %",
        mean(&seal), percentile(&seal, 50), percentile(&seal, 95),
        mean(&open), percentile(&open, 50), percentile(&open, 95),
        mean(&ring),
        mean(&seal) * 100.0 / mean(&whole),
    );
}

/// Règles du moteur de lyxal_core pour un élément de remise : contrôle allégé (décision S12).
const LIGHT_SCHEMA: &str = r#"{ fields: {
    content: { pipeline: [{ rule: "record", options: { expected_table: "mail_content" } }], required: true },
    object: { pipeline: [{ rule: "record", options: { expected_table: "storage_object" } }], required: true },
    role: { pipeline: [{ rule: "enum", options: { allowed: ["inbox", "junk"], case_sensitive: true } }], default: "inbox" },
    received_at: { pipeline: [{ rule: "datetime", options: { min_value: d"1970-01-01T00:00:00Z" } }], required: true },
    delivery_key: { pipeline: [{ rule: "hexadecimal", options: { min_length: 64, max_length: 64, allow_prefix: false } }], required: true },
    message_id: { pipeline: [{ rule: "optional_string", options: { max_length: 2048 } }] },
    in_reply_to: { pipeline: [{ rule: "array_of_strings", options: { allow_empty: true, max_length: 2048 } }, { rule: "array_length", options: { max_length: 100 } }], default: [] },
    references: { pipeline: [{ rule: "array_of_strings", options: { allow_empty: true, max_length: 2048 } }, { rule: "array_length", options: { max_length: 1000 } }], default: [] },
    base_subject: { pipeline: [{ rule: "optional_string", options: { max_length: 16384 } }] },
    is_report: { pipeline: [{ rule: "boolean" }], default: false },
    envelope: { pipeline: [{ rule: "is_object" }, { rule: "max_serialized_length", options: { max_length: 262144 } }], required: true },
    structure: { pipeline: [{ rule: "is_object" }, { rule: "max_serialized_length", options: { max_length: 1048576 } }], required: true },
    has_attachment: { pipeline: [{ rule: "boolean" }], default: false },
    reception: fn::mail_reception_rule()
}, unknown_keys: "reject" }"#;

/// Mêmes règles avec la validation complète de l'enveloppe, comme `fn::mail_message_create`.
const FULL_ENVELOPE: &str = r#"{ pipeline: [{ rule: "is_object" }, { rule: "object", options: { schema: { fields: {
    date: { pipeline: [{ rule: "datetime" }] },
    subject: { pipeline: [{ rule: "optional_string", options: { max_length: 16384 } }] },
    message_id: { pipeline: [{ rule: "optional_string", options: { max_length: 2048 } }] },
    in_reply_to: { pipeline: [{ rule: "array_of_strings", options: { allow_empty: true, max_length: 2048 } }, { rule: "array_length", options: { max_length: 100 } }] },
    references: { pipeline: [{ rule: "array_of_strings", options: { allow_empty: true, max_length: 2048 } }, { rule: "array_length", options: { max_length: 1000 } }] },
    from: $list, sender: $list, reply_to: $list, to: $list, cc: $list, bcc: $list
}, unknown_keys: "reject" } } }], required: true }"#;

const ADDRESS_LIST: &str = r#"{ pipeline: [{ rule: "array_length", options: { max_length: 1000 } }, { rule: "each", options: { pipeline: [{ rule: "is_object" }, { rule: "object", options: { schema: {
    fields: { name: { pipeline: [{ rule: "optional_string", options: { max_length: 2048 } }] }, address: { pipeline: [{ rule: "optional_string", options: { max_length: 2048 } }] }, group: { pipeline: [{ rule: "optional_string", options: { max_length: 2048 } }] } }, unknown_keys: "reject"
} } }] } }] }"#;

/// Coût du contrôle des paramètres d'un élément de remise par le moteur de lyxal_core : contrôle
/// allégé retenu (décision S12) et validation complète de l'enveloppe, sur le même élément.
#[tokio::test(flavor = "multi_thread", worker_threads = 4)]
#[ignore = "mesure, hors CI"]
async fn measures_light_and_full_validation() {
    const ROUNDS: usize = 200;
    let (bench, engine) = measure_bench().await;
    for recipients in [3usize, 50] {
        let people = |count: usize| {
            (0..count)
                .map(|i| format!("{{ name: 'Personne {i}', address: 'personne{i}@alpha.test' }}"))
                .collect::<Vec<_>>()
                .join(", ")
        };
        let item = format!(
            "{{ content: 'mail_content:c', object: 'storage_object:o', received_at: time::now(), delivery_key: string::repeat('a', 64),
                message_id: 'm@ailleurs.test', references: ['a@x', 'b@x', 'c@x'], base_subject: 'compte rendu',
                envelope: {{ date: time::now(), subject: 'Compte rendu', message_id: 'm@ailleurs.test', references: ['a@x', 'b@x', 'c@x'],
                    from: [{{ name: 'Paul', address: 'paul@ailleurs.test' }}], to: [{to}], cc: [{cc}] }},
                structure: {{ type: 'text/plain', size: 10240, lines: 160 }},
                reception: {{ spf: 'pass', dkim: 'pass', dmarc: 'pass', iprev: 'pass', antivirus: 'not_scanned', spam: 'none', tls: true }} }}",
            to = people(recipients),
            cc = people(recipients / 3),
        );
        let light = format!(
            "{{ LET $item = {item}; RETURN fn::validation_object_execute($item, {LIGHT_SCHEMA}, 60).valid; }}"
        );
        let full = format!(
            "{{ LET $item = {item}; LET $list = {ADDRESS_LIST}; LET $schema = {LIGHT_SCHEMA}; RETURN fn::validation_object_execute($item, object::extend($schema, {{ fields: object::extend($schema.fields, {{ envelope: {FULL_ENVELOPE} }}) }}), 60).valid; }}"
        );
        let base = format!("{{ LET $item = {item}; RETURN $item.reception.tls; }}");
        let mut times = Vec::new();
        for query in [&base, &light, &full] {
            let mut durations = Vec::new();
            for _ in 0..ROUNDS {
                let step = Instant::now();
                assert!(bench.value::<bool>(query).await);
                durations.push(step.elapsed());
            }
            times.push(mean(&durations));
        }
        println!(
            "MESURE contrôle d'un élément de remise, {engine} (décision S12), {} adresses dans l'enveloppe, moyennes sur {ROUNDS} : contrôle allégé {:.2} ms ; validation complète de l'enveloppe {:.2} ms (requête sans contrôle déduite : {:.2} ms)",
            1 + recipients + recipients / 3,
            times[1] - times[0],
            times[2] - times[0],
            times[0],
        );
    }
}
