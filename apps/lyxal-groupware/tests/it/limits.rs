//! Limites appliquées à l'acceptation, sur de vraies sockets : connexions ouvertes et cadence
//! par réseau (refus `421 4.7.0` en SMTP), réseaux exemptés, listes de refus et d'autorisation,
//! budget mémoire épuisé (`421 4.3.2`). Les compteurs sont partagés par les écoutes du nœud.

use crate::support::{
    config, eventually, greeting, mail_net, run_workers, smtp_listener, HoldHandler,
};
use lyxal_mail::net::{refusal_line, MailProtocol, RefusalReason};
use std::sync::Arc;

fn line(reason: RefusalReason) -> String {
    String::from_utf8(refusal_line(MailProtocol::Smtp, reason).to_vec())
        .unwrap()
        .trim_end()
        .to_string()
}

fn limited(limits: &str, listeners: &str) -> lyxal_groupware::config::GroupwareConfig {
    config(
        "limits",
        &format!("[limits]\ndrain_seconds = 2\n{limits}\n{listeners}"),
    )
}

#[tokio::test]
async fn open_connections_per_network_are_capped_and_shared_by_listeners() {
    let config = limited(
        "connections_per_network = [2, 90, 270]",
        &format!("{}{}", smtp_listener("a", ""), smtp_listener("b", "")),
    );
    let net = mail_net(&config, Arc::new(HoldHandler(MailProtocol::Smtp)));
    let running = run_workers(&net);
    let a = net.local_addrs("a")[0];
    let b = net.local_addrs("b")[0];

    let (first, reply) = greeting(a).await;
    assert_eq!(reply, "220 hold");
    let (_second, reply) = greeting(a).await;
    assert_eq!(reply, "220 hold");
    // Troisième connexion de la même adresse, sur l'autre écoute : refusée
    let (_third, reply) = greeting(b).await;
    assert_eq!(reply, line(RefusalReason::TooManyConnections));
    assert!(reply.starts_with("421 4.7.0 "));
    assert_eq!(
        net.snapshot().listeners["b"].refused["too_many_connections"],
        1
    );

    // Une connexion refermée rend sa place
    drop(first);
    eventually("place rendue", || net.snapshot().listeners["a"].active == 1).await;
    let (_again, reply) = greeting(b).await;
    assert_eq!(reply, "220 hold");
    running.stop().await;
}

#[tokio::test]
async fn new_connections_per_minute_are_capped() {
    let config = limited(
        "connections_per_minute = [2, 900, 2700]",
        &smtp_listener("smtp", ""),
    );
    let net = mail_net(&config, Arc::new(HoldHandler(MailProtocol::Smtp)));
    let running = run_workers(&net);
    let address = net.local_addrs("smtp")[0];
    for _ in 0..2 {
        // Connexions refermées aussitôt : seule la cadence compte
        let (_stream, reply) = greeting(address).await;
        assert_eq!(reply, "220 hold");
    }
    let (_stream, reply) = greeting(address).await;
    assert_eq!(reply, line(RefusalReason::RateLimited));
    assert_eq!(net.snapshot().listeners["smtp"].refused["rate_limited"], 1);
    running.stop().await;
}

#[tokio::test]
async fn exempt_networks_escape_the_network_limits() {
    let config = limited(
        "connections_per_network = [1, 1, 1]\nconnections_per_minute = [1, 1, 1]\nexempt_networks = [\"127.0.0.0/8\"]",
        &smtp_listener("smtp", ""),
    );
    let net = mail_net(&config, Arc::new(HoldHandler(MailProtocol::Smtp)));
    let running = run_workers(&net);
    let address = net.local_addrs("smtp")[0];
    let mut open = Vec::new();
    for _ in 0..5 {
        let (stream, reply) = greeting(address).await;
        assert_eq!(reply, "220 hold");
        open.push(stream);
    }
    assert_eq!(net.snapshot().tracked_networks, 0);
    running.stop().await;
}

#[tokio::test]
async fn deny_and_allow_networks_are_applied() {
    let config = limited(
        "deny_networks = [\"127.0.0.1\"]",
        &smtp_listener("smtp", ""),
    );
    let net = mail_net(&config, Arc::new(HoldHandler(MailProtocol::Smtp)));
    let running = run_workers(&net);
    let (_stream, reply) = greeting(net.local_addrs("smtp")[0]).await;
    assert_eq!(reply, line(RefusalReason::Blocked));
    assert_eq!(net.snapshot().listeners["smtp"].refused["blocked"], 1);
    running.stop().await;

    let config = limited(
        "allow_networks = [\"10.0.0.0/8\"]",
        &smtp_listener("smtp", ""),
    );
    let net = mail_net(&config, Arc::new(HoldHandler(MailProtocol::Smtp)));
    let running = run_workers(&net);
    let (_stream, reply) = greeting(net.local_addrs("smtp")[0]).await;
    assert_eq!(reply, line(RefusalReason::Blocked));
    running.stop().await;

    let config = limited(
        "allow_networks = [\"127.0.0.0/8\"]",
        &smtp_listener("smtp", ""),
    );
    let net = mail_net(&config, Arc::new(HoldHandler(MailProtocol::Smtp)));
    let running = run_workers(&net);
    let (_stream, reply) = greeting(net.local_addrs("smtp")[0]).await;
    assert_eq!(reply, "220 hold");
    running.stop().await;
}

#[tokio::test]
async fn exhausted_memory_budget_refuses_politely() {
    // Budget de 64 Mio : la classe « lecture » en a trois quarts (48 Mio), soit trois connexions
    // de 16 Mio
    let config = limited(
        "memory_budget_bytes = 67108864\nconnection_base_bytes = 16777216",
        &smtp_listener("smtp", ""),
    );
    let net = mail_net(&config, Arc::new(HoldHandler(MailProtocol::Smtp)));
    let running = run_workers(&net);
    let address = net.local_addrs("smtp")[0];
    let mut open = Vec::new();
    for _ in 0..3 {
        let (stream, reply) = greeting(address).await;
        assert_eq!(reply, "220 hold");
        open.push(stream);
    }
    let (_refused, reply) = greeting(address).await;
    assert_eq!(reply, line(RefusalReason::MemoryBudget));
    assert!(reply.starts_with("421 4.3.2 "));
    let snapshot = net.snapshot();
    assert_eq!(snapshot.memory.used_bytes, 48 * 1024 * 1024);
    assert_eq!(snapshot.listeners["smtp"].refused["memory_budget"], 1);

    // Réservations rendues à la fermeture
    drop(open);
    eventually("mémoire rendue", || net.snapshot().memory.used_bytes == 0).await;
    running.stop().await;
}
