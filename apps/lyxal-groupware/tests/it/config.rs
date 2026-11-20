//! Configuration : fichiers livrés, variables `LYXAL_GROUPWARE__*`, et chaque refus de la
//! validation (§7 du plan du lot 3).

use crate::support::{smtp_listener, toml, try_config};
use lyxal_groupware::config::{GroupwareConfig, LogClientIp};
use lyxal_mail::net::{MailProtocol, TlsMode};
use std::fs;
use std::path::Path;

fn refused(extra: &str) -> String {
    match try_config(&toml("config", extra)) {
        Ok(_) => panic!("configuration acceptée : {extra}"),
        Err(error) => {
            assert_eq!(error.code(), "GROUPWARE_CONFIGURATION_INVALID", "{error}");
            error.to_string()
        }
    }
}

/// Charge les fichiers livrés `default.toml` et `<environment>.toml` (copié en
/// `development.toml`, l'environnement lu par défaut).
fn shipped(environment: &str) -> GroupwareConfig {
    let shipped = Path::new(env!("CARGO_MANIFEST_DIR")).join("config");
    let directory = tempfile::tempdir().expect("tempdir");
    fs::copy(
        shipped.join("default.toml"),
        directory.path().join("default.toml"),
    )
    .expect("default.toml");
    fs::copy(
        shipped.join(format!("{environment}.toml")),
        directory.path().join("development.toml"),
    )
    .expect("fichier d'environnement");
    GroupwareConfig::load_with_environment(directory.path(), Some(Default::default()))
        .expect("configuration livrée valide")
}

#[test]
fn shipped_files_are_valid() {
    let development = shipped("development");
    assert_eq!(development.http.bind.to_string(), "127.0.0.1:8090");
    assert_eq!(development.listeners.len(), 1);
    assert_eq!(development.listeners[0].protocol, MailProtocol::Smtp);
    assert_eq!(development.listeners[0].tls, TlsMode::None);
    assert_eq!(development.limits.connections_per_network, [30, 90, 270]);
    assert_eq!(development.limits.connections_per_minute, [300, 900, 2700]);
    assert_eq!(development.limits.memory_budget_bytes, 512 * 1024 * 1024);

    let production = shipped("production");
    assert!(
        production.listeners.is_empty(),
        "aucune écoute en production"
    );
    assert!(production.observability.json_logs);
    assert_eq!(production.observability.log_client_ip, LogClientIp::Network);
}

#[test]
fn defaults_apply_without_limits_section() {
    let config = try_config(&toml("config", "")).expect("configuration");
    assert!(config.listeners.is_empty());
    assert_eq!(config.limits.max_connections, 4096);
    assert_eq!(config.limits.drain_seconds, 30);
    assert_eq!(config.limits.connection_base_bytes, 64 * 1024);
    assert_eq!(config.limits.max_tracked_networks, 100_000);
    assert_eq!(config.observability.log_client_ip, LogClientIp::Network);
}

#[test]
fn environment_variables_use_the_groupware_prefix() {
    let directory = tempfile::tempdir().expect("tempdir");
    fs::write(
        directory.path().join("default.toml"),
        toml("config", "[limits]\ndrain_seconds = 5\n"),
    )
    .unwrap();
    let variables = [
        ("LYXAL_GROUPWARE__HTTP__BIND", "127.0.0.1:9191"),
        ("LYXAL_GROUPWARE__LIMITS__CONNECTIONS_PER_NETWORK", "3,6,9"),
        (
            "LYXAL_GROUPWARE__LIMITS__DENY_NETWORKS",
            "192.0.2.0/24,2001:db8::/32",
        ),
        ("LYXAL_GROUPWARE__OBSERVABILITY__LOG_CLIENT_IP", "full"),
        // Variable de lyxal-server : sans effet ici
        ("LYXAL__HTTP__BIND", "127.0.0.1:1"),
    ]
    .iter()
    .map(|(k, v)| ((*k).to_string(), (*v).to_string()))
    .collect();
    let config = GroupwareConfig::load_with_environment(directory.path(), Some(variables))
        .expect("configuration");
    assert_eq!(config.http.bind.to_string(), "127.0.0.1:9191");
    assert_eq!(config.limits.connections_per_network, [3, 6, 9]);
    assert_eq!(config.limits.deny_networks.len(), 2);
    assert_eq!(config.observability.log_client_ip, LogClientIp::Full);
}

#[test]
fn database_password_is_refused_in_files() {
    let text = toml("config", "").replace(
        "connect_timeout_seconds = 5",
        "connect_timeout_seconds = 5\npassword = \"secret\"",
    );
    let error = try_config(&text).expect_err("mot de passe dans un fichier");
    assert!(
        error
            .to_string()
            .contains("LYXAL_GROUPWARE__DATABASE__PASSWORD seulement"),
        "{error}"
    );
}

#[test]
fn listener_settings_are_checked() {
    let limits = "[limits]\ndrain_seconds = 5\n";
    let cases: &[(&str, &str)] = &[
        // Identifiant
        (
            "\n[[listeners]]\nid = \"SMTP\"\nprotocol = \"smtp\"\nbind = [\"127.0.0.1:0\"]\ntls = \"none\"\n",
            "invalide",
        ),
        (
            "\n[[listeners]]\nid = \"un_identifiant_beaucoup_trop_long_33\"\nprotocol = \"smtp\"\nbind = [\"127.0.0.1:0\"]\ntls = \"none\"\n",
            "invalide",
        ),
        (
            &format!("{}{}", smtp_listener("smtp", ""), smtp_listener("smtp", "")),
            "déclaré deux fois",
        ),
        // Adresses
        (
            "\n[[listeners]]\nid = \"smtp\"\nprotocol = \"smtp\"\nbind = []\ntls = \"none\"\n",
            "au moins une adresse",
        ),
        (
            "\n[[listeners]]\nid = \"a\"\nprotocol = \"smtp\"\nbind = [\"127.0.0.1:2525\"]\ntls = \"none\"\n\n[[listeners]]\nid = \"b\"\nprotocol = \"smtp\"\nbind = [\"127.0.0.1:2525\"]\ntls = \"none\"\n",
            "liée deux fois",
        ),
        // TLS (lot 3c) et protocole en clair (G7)
        (
            "\n[[listeners]]\nid = \"imaps\"\nprotocol = \"imap\"\nbind = [\"127.0.0.1:0\"]\ntls = \"implicit\"\n",
            "TLS pas encore disponible",
        ),
        (
            "\n[[listeners]]\nid = \"submission\"\nprotocol = \"submission\"\nbind = [\"127.0.0.1:0\"]\ntls = \"starttls\"\n",
            "TLS pas encore disponible",
        ),
        (
            "\n[[listeners]]\nid = \"imap\"\nprotocol = \"imap\"\nbind = [\"127.0.0.1:0\"]\ntls = \"none\"\n",
            "sans TLS refusé",
        ),
        (
            &smtp_listener("smtp", "max_connections = 0"),
            "max_connections",
        ),
        // Valeurs inconnues
        (
            "\n[[listeners]]\nid = \"x\"\nprotocol = \"lmtp\"\nbind = [\"127.0.0.1:0\"]\ntls = \"none\"\n",
            "protocole inconnu",
        ),
        (
            "\n[[listeners]]\nid = \"x\"\nprotocol = \"smtp\"\nbind = [\"127.0.0.1:0\"]\ntls = \"maybe\"\n",
            "mode TLS inconnu",
        ),
        (
            &smtp_listener("smtp", "proxy_networks = []"),
            "unknown field",
        ),
    ];
    for (listeners, expected) in cases {
        let message = refused(&format!("{limits}{listeners}"));
        assert!(message.contains(expected), "{expected} : {message}");
    }
    // Le port HTTP compte comme une adresse liée
    let text =
        toml("config", limits).replace("127.0.0.1:0\"\ngraceful", "127.0.0.1:2525\"\ngraceful");
    let message = match try_config(&format!(
        "{text}\n[[listeners]]\nid = \"smtp\"\nprotocol = \"smtp\"\nbind = [\"127.0.0.1:2525\"]\ntls = \"none\"\n"
    )) {
        Ok(_) => panic!("adresse du port HTTP reprise par une écoute"),
        Err(error) => error.to_string(),
    };
    assert!(message.contains("liée deux fois"), "{message}");
}

#[test]
fn limits_are_bounded() {
    let cases = [
        ("memory_budget_bytes = 1048576", "memory_budget_bytes"),
        ("connection_base_bytes = 1024", "connection_base_bytes"),
        ("max_connections = 70000", "max_connections"),
        (
            "connections_per_network = [0, 90, 270]",
            "connections_per_network",
        ),
        (
            "connections_per_minute = [300, 900, 2000000]",
            "connections_per_minute",
        ),
        ("max_tracked_networks = 10", "max_tracked_networks"),
        ("deny_networks = [\"pas un réseau\"]", "réseau invalide"),
        ("drain_seconds = 0", "drain_seconds"),
        ("drain_seconds = 45", "module_stop_timeout_seconds"),
        ("inconnu = 1", "unknown field"),
    ];
    for (setting, expected) in cases {
        let extra = if setting.starts_with("drain_seconds") {
            format!("[limits]\n{setting}\n")
        } else {
            format!("[limits]\ndrain_seconds = 5\n{setting}\n")
        };
        let message = refused(&extra);
        assert!(message.contains(expected), "{setting} : {message}");
    }
}
