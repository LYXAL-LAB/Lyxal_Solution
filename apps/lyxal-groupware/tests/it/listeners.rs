//! Écoutes sur de vraies sockets (`127.0.0.1`, port libre), lancées hors runtime : refus poli
//! par protocole tant qu'aucun protocole n'existe, plafond de l'écoute, mesures et sonde,
//! journal sans adresse complète.

use crate::support::{
    capture_logs, config, eventually, first_line, greeting, mail_net, run_workers, smtp_listener,
    HoldHandler,
};
use lyxal_groupware::net::bind::bind_listeners;
use lyxal_groupware::net::MailNet;
use lyxal_groupware::runtime::unavailable;
use lyxal_mail::net::{refusal_line, MailProtocol, RefusalReason};
use lyxal_runtime::health::{HealthStatus, ModuleHealthCheck};
use lyxal_runtime::ModuleContext;
use std::sync::Arc;
use tokio::net::TcpStream;

const LIMITS: &str = "[limits]\ndrain_seconds = 2\n";

fn line(protocol: MailProtocol, reason: RefusalReason) -> String {
    String::from_utf8(refusal_line(protocol, reason).to_vec())
        .unwrap()
        .trim_end()
        .to_string()
}

#[tokio::test]
async fn every_protocol_answers_a_polite_unavailable_line() {
    // Les autres protocoles exigent TLS (G7) : ils sont posés en clair directement sur des
    // écoutes d'essai, pour lire leur ligne de refus
    let mut config = config(
        "listeners",
        &format!("{LIMITS}{}", smtp_listener("smtp", "")),
    );
    let template = config.listeners[0].clone();
    for (id, protocol) in [
        ("submission", MailProtocol::Submission),
        ("imap", MailProtocol::Imap),
        ("pop3", MailProtocol::Pop3),
        ("managesieve", MailProtocol::ManageSieve),
    ] {
        let mut listener = template.clone();
        listener.id = id.into();
        listener.protocol = protocol;
        config.listeners.push(listener);
    }
    let bound = bind_listeners(&config).expect("liaison");
    let net = MailNet::new(&config, bound, None, &unavailable).expect("écoutes");
    let running = run_workers(&net);

    for (id, protocol) in [
        ("smtp", MailProtocol::Smtp),
        ("submission", MailProtocol::Submission),
        ("imap", MailProtocol::Imap),
        ("pop3", MailProtocol::Pop3),
        ("managesieve", MailProtocol::ManageSieve),
    ] {
        let address = net.local_addrs(id)[0];
        let (mut stream, reply) = greeting(address).await;
        assert_eq!(reply, line(protocol, RefusalReason::Unavailable), "{id}");
        // Puis fermeture
        assert_eq!(first_line(&mut stream).await, "", "{id}");
    }
    let snapshot = net.snapshot();
    assert_eq!(snapshot.listeners["imap"].accepted, 1);
    assert_eq!(snapshot.listeners["imap"].protocol, "imap");
    eventually("connexions refermées", || {
        net.snapshot().listeners.values().all(|l| l.active == 0)
    })
    .await;
    assert_eq!(net.snapshot().memory.used_bytes, 0);
    running.stop().await;
}

#[tokio::test]
async fn listener_cap_closes_without_a_word_and_degrades_the_probe() {
    let config = config(
        "listeners",
        &format!("{LIMITS}{}", smtp_listener("smtp", "max_connections = 1")),
    );
    let net = mail_net(&config, Arc::new(HoldHandler(MailProtocol::Smtp)));
    let running = run_workers(&net);
    let address = net.local_addrs("smtp")[0];
    let probe = net.health_check();
    let ctx = ModuleContext::new(lyxal_mail::MODULE_ID);
    assert_eq!(
        probe.check(&ctx).await.unwrap().status,
        HealthStatus::Healthy
    );

    let (first, reply) = greeting(address).await;
    assert_eq!(reply, "220 hold");
    // Plafond atteint : fermeture immédiate, aucune ligne
    let (_second, reply) = greeting(address).await;
    assert_eq!(reply, "");
    let snapshot = net.snapshot();
    assert_eq!(snapshot.listeners["smtp"].active, 1);
    assert_eq!(snapshot.listeners["smtp"].refused["listener_full"], 1);
    // Une écoute à plus de 90 % de son plafond rend la sonde « dégradé »
    assert_eq!(
        probe.check(&ctx).await.unwrap().status,
        HealthStatus::Degraded
    );

    // Place rendue à la fermeture
    drop(first);
    eventually("place rendue", || {
        net.snapshot().listeners["smtp"].active == 0
    })
    .await;
    let (_third, reply) = greeting(address).await;
    assert_eq!(reply, "220 hold");
    running.stop().await;
}

#[tokio::test]
async fn refusals_are_logged_with_the_masked_network_only() {
    let (captured, _logs) = capture_logs();

    let config = config(
        "listeners",
        &format!(
            "[limits]\ndrain_seconds = 2\ndeny_networks = [\"127.0.0.0/8\"]\n{}",
            smtp_listener("smtp", "")
        ),
    );
    let net = mail_net(&config, Arc::new(HoldHandler(MailProtocol::Smtp)));
    let running = run_workers(&net);
    let (_stream, reply) = greeting(net.local_addrs("smtp")[0]).await;
    assert_eq!(reply, line(MailProtocol::Smtp, RefusalReason::Blocked));
    running.stop().await;

    let log = captured.text();
    // L'adresse locale de l'écoute figure au démarrage ; la ligne du refus ne porte que le
    // réseau du client
    let refusal: Vec<&str> = log
        .lines()
        .filter(|line| line.contains("connexion refusée"))
        .collect();
    assert_eq!(refusal.len(), 1, "{log}");
    assert!(refusal[0].contains("blocked"), "{log}");
    assert!(refusal[0].contains("127.0.0.0/24"), "{log}");
    assert!(
        !refusal[0].contains("127.0.0.1"),
        "adresse complète au journal : {log}"
    );
}

#[tokio::test]
async fn a_connection_reset_by_the_client_does_not_stop_the_listener() {
    let config = config(
        "listeners",
        &format!("{LIMITS}{}", smtp_listener("smtp", "")),
    );
    let net = mail_net(&config, unavailable(MailProtocol::Smtp));
    let running = run_workers(&net);
    let address = net.local_addrs("smtp")[0];
    for _ in 0..20 {
        // Connexion ouverte puis abandonnée aussitôt
        drop(TcpStream::connect(address).await.unwrap());
    }
    let (_stream, reply) = greeting(address).await;
    assert_eq!(reply, line(MailProtocol::Smtp, RefusalReason::Unavailable));
    running.stop().await;
}

#[tokio::test]
async fn a_listener_stopped_then_started_again_keeps_its_port() {
    // Arrêt puis redémarrage d'une écoute par le runtime (`stop_worker` puis `start_worker`) :
    // les sockets liées au démarrage de l'hôte restent ouvertes et la reprise sert le même port
    let config = config(
        "listeners",
        &format!("{LIMITS}{}", smtp_listener("smtp", "")),
    );
    let bound = bind_listeners(&config).expect("liaison");
    let net = MailNet::new(&config, bound, None, &unavailable).expect("écoutes");
    let address = net.local_addrs("smtp")[0];

    run_workers(&net).stop().await;
    let running = run_workers(&net);
    let (_stream, reply) = greeting(address).await;
    assert_eq!(reply, line(MailProtocol::Smtp, RefusalReason::Unavailable));
    running.stop().await;
}
