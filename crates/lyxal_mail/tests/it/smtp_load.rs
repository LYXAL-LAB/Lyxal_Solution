// SPDX-License-Identifier: AGPL-3.0-only

//! Mesures de charge de la réception SMTP (plan du lot 5, §10.5), hors CI : essais `#[ignore]`,
//! à lancer à la main sur un binaire optimisé,
//!
//! ```text
//! cargo test -p lyxal_mail --release --test it -- --ignored --nocapture --test-threads 1 smtp_load
//! ```
//!
//! Chemin complet d'un message reçu : dialogue SMTP sur une vraie socket locale (`EHLO` une fois
//! par connexion, puis `MAIL FROM`, `RCPT TO`, `DATA` par message), contrôles SPF, DKIM, DMARC
//! et nom inverse (résolveur `StaticResolver` : aucun délai de réseau DNS), chaîne de remise,
//! écriture chiffrée et inscription. Base embarquée, ou serveur SurrealDB réel avec
//! `LYXAL_SURREAL_WS_URL` (voir `measures.rs`) ; clients et serveur dans le même processus.
//! Latence : de l'envoi de la fin des données (`CRLF.CRLF`) à la réponse `250`.

use std::sync::atomic::{AtomicUsize, Ordering};
use std::sync::Arc;
use std::time::{Duration, Instant};

use crate::measures::{accounts, mean, message, percentile};
use crate::smtp::{serve, Client, Options};
use crate::support::{measure_bench, Bench};

async fn smtp_load(
    label: &str,
    bench: &Bench,
    addresses: Vec<String>,
    clients: usize,
    total: usize,
) {
    // Limites de la session et de la cadence par réseau levées : tous les clients sont en 127.0.0.1
    let mut options = Options::new();
    options.config.max_messages_per_session = 1_000;
    options.config.messages_per_network_per_minute = [1_000_000; 3];
    let server = serve(bench, options).await;
    let server = Arc::new(server);
    let addresses = Arc::new(addresses);
    let next = Arc::new(AtomicUsize::new(0));
    let refused = Arc::new(AtomicUsize::new(0));
    let started = Instant::now();
    let mut tasks = tokio::task::JoinSet::new();
    for _ in 0..clients {
        let (server, addresses, next, refused) = (
            server.clone(),
            addresses.clone(),
            next.clone(),
            refused.clone(),
        );
        tasks.spawn(async move {
            let mut latencies = Vec::new();
            let (mut client, _) = Client::connect(&server).await;
            client.cmd("EHLO client.ailleurs.test").await;
            loop {
                let index = next.fetch_add(1, Ordering::Relaxed);
                if index >= total {
                    break;
                }
                let recipient = &addresses[index % addresses.len()];
                client
                    .send(
                        format!(
                            "MAIL FROM:<paul@ailleurs.test>\r\nRCPT TO:<{recipient}>\r\nDATA\r\n"
                        )
                        .as_bytes(),
                    )
                    .await;
                let mut ok = true;
                for _ in 0..3 {
                    let reply = client.reply().await;
                    ok &= reply.starts_with('2') || reply.starts_with('3');
                }
                if !ok {
                    refused.fetch_add(1, Ordering::Relaxed);
                    client.cmd("RSET").await;
                    continue;
                }
                let body = message(&format!("charge-{index}"));
                client.send(&body).await;
                let sent = Instant::now();
                client.send(b"\r\n.\r\n").await;
                let reply = client.reply().await;
                latencies.push(sent.elapsed());
                if !reply.starts_with("250") {
                    refused.fetch_add(1, Ordering::Relaxed);
                }
            }
            client.cmd("QUIT").await;
            latencies
        });
    }
    let mut latencies = Vec::new();
    while let Some(done) = tasks.join_next().await {
        latencies.extend(done.expect("client"));
    }
    let elapsed = started.elapsed();
    latencies.sort();
    let snapshot = server.handler.snapshot();
    println!(
        "{label} : {total} messages en {:.1} s, {:.1} par seconde ; fin des données → 250 : moyenne {:.1} ms, p50 {:.1} ms, p95 {:.1} ms ; refusés {} ; lots {} (plus grand {}), conflits rejoués {}, lots repris {}",
        elapsed.as_secs_f64(),
        total as f64 / elapsed.as_secs_f64(),
        mean(&latencies),
        percentile(&latencies, 50),
        percentile(&latencies, 95),
        refused.load(Ordering::Relaxed),
        snapshot["commit_batches"],
        snapshot["commit_largest_batch"],
        snapshot["commit_conflicts_replayed"],
        snapshot["commit_split_batches"],
    );
    assert_eq!(
        snapshot["messages_accepted"] as usize + refused.load(Ordering::Relaxed),
        total
    );
    tokio::time::sleep(Duration::from_millis(10)).await;
}

async fn addresses(bench: &Bench, organization: &str, count: usize) -> Vec<String> {
    accounts(bench, &[organization], count)
        .await
        .into_iter()
        .enumerate()
        .map(|(index, _)| format!("{organization}{index}@{organization}.test"))
        .collect()
}

#[tokio::test(flavor = "multi_thread", worker_threads = 4)]
#[ignore = "mesure, hors CI"]
async fn smtp_load_hundred_accounts_fifty_clients() {
    let (bench, engine) = measure_bench().await;
    let targets = addresses(&bench, "alpha", 100).await;
    let label = format!("SMTP, 100 comptes, 50 clients, {engine}");
    smtp_load(&label, &bench, targets, 50, 3_000).await;
}

#[tokio::test(flavor = "multi_thread", worker_threads = 4)]
#[ignore = "mesure, hors CI"]
async fn smtp_load_one_account_twenty_clients() {
    let (bench, engine) = measure_bench().await;
    let targets = addresses(&bench, "alpha", 1).await;
    let label = format!("SMTP, un compte, 20 clients, {engine}");
    smtp_load(&label, &bench, targets, 20, 1_000).await;
}

#[tokio::test(flavor = "multi_thread", worker_threads = 4)]
#[ignore = "mesure, hors CI"]
async fn smtp_load_single_message_latency() {
    let (bench, engine) = measure_bench().await;
    let targets = addresses(&bench, "alpha", 1).await;
    let label = format!("SMTP, un client, {engine}");
    smtp_load(&label, &bench, targets, 1, 200).await;
}
