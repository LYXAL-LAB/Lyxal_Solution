//! Outils communs des essais : configuration, base embarquée, écoutes lancées sans runtime,
//! protocoles d'essai, client TCP.

use async_trait::async_trait;
use lyxal_groupware::config::GroupwareConfig;
use lyxal_groupware::net::bind::bind_listeners;
use lyxal_groupware::net::MailNet;
use lyxal_mail::net::{MailProtocol, Session, SessionEnd, SessionHandler};
use lyxal_runtime::worker::{CancellationToken, WorkerContext};
use lyxal_runtime::{ModuleContext, RuntimeError};
use std::fs;
use std::net::SocketAddr;
use std::sync::Arc;
use std::time::Duration;
use surrealdb::engine::any::{connect, Any};
use surrealdb::Surreal;
use tokio::io::{AsyncReadExt, AsyncWriteExt};
use tokio::net::TcpStream;
use tokio::task::JoinSet;

/// Configuration de base des essais (base `mem://`, port HTTP libre), complétée par `extra`.
pub fn toml(database: &str, extra: &str) -> String {
    format!(
        r#"
[application]
name = "Lyxal Groupware Test"
environment = "test"

[http]
bind = "127.0.0.1:0"
graceful_shutdown_seconds = 5

[database]
endpoint = "mem://"
namespace = "lyxal_test"
database = "{database}"
connect_timeout_seconds = 5

[runtime]
module_install_timeout_seconds = 60
module_start_timeout_seconds = 10
module_stop_timeout_seconds = 45

[observability]
log_filter = "info"
json_logs = false
include_target = false
include_thread_ids = false
{extra}
"#
    )
}

/// Configuration chargée depuis un dossier temporaire (`default.toml` = [`toml`]).
pub fn config(database: &str, extra: &str) -> GroupwareConfig {
    try_config(&toml(database, extra)).expect("configuration valide")
}

/// Configuration `text` chargée et validée.
pub fn try_config(text: &str) -> Result<GroupwareConfig, lyxal_groupware::error::GroupwareError> {
    let directory = tempfile::tempdir().expect("tempdir");
    fs::write(directory.path().join("default.toml"), text).expect("default.toml");
    GroupwareConfig::load_with_environment(directory.path(), Some(Default::default()))
}

/// Écoute SMTP en clair sur un port libre de `127.0.0.1`.
pub fn smtp_listener(id: &str, extra: &str) -> String {
    format!(
        "\n[[listeners]]\nid = \"{id}\"\nprotocol = \"smtp\"\nbind = [\"127.0.0.1:0\"]\ntls = \"none\"\n{extra}\n"
    )
}

pub async fn database(name: &str) -> Surreal<Any> {
    let db = connect("mem://").await.expect("connexion");
    db.use_ns("lyxal_test").use_db(name).await.expect("ns/db");
    db
}

/// Écoutes de `config` liées et prêtes, avec la session `handler` pour tout protocole.
pub fn mail_net(config: &GroupwareConfig, handler: Arc<dyn SessionHandler>) -> MailNet {
    let bound = bind_listeners(config).expect("liaison");
    MailNet::new(config, bound, &move |_| handler.clone())
}

/// Workers des écoutes lancés hors runtime ; annuler le jeton les arrête.
pub struct Running {
    pub cancel: CancellationToken,
    pub tasks: JoinSet<Result<(), RuntimeError>>,
}

impl Running {
    pub async fn stop(mut self) {
        self.cancel.cancel();
        while let Some(result) = self.tasks.join_next().await {
            result.expect("tâche").expect("worker");
        }
    }
}

pub fn run_workers(net: &MailNet) -> Running {
    let cancel = CancellationToken::new();
    let mut tasks = JoinSet::new();
    for worker in net.workers().expect("workers") {
        let descriptor = worker.descriptor().clone();
        let ctx = WorkerContext::new(
            descriptor.module_id.clone(),
            descriptor.id.clone(),
            ModuleContext::new(lyxal_mail::MODULE_ID),
            cancel.child_token(),
        );
        tasks.spawn(async move { worker.run(ctx).await });
    }
    Running { cancel, tasks }
}

/// Protocole d'essai : salue (`220 hold`), puis attend la fermeture par le client ou l'arrêt du
/// nœud, auquel il répond `421 bye`.
pub struct HoldHandler(pub MailProtocol);

#[async_trait]
impl SessionHandler for HoldHandler {
    fn protocol(&self) -> MailProtocol {
        self.0
    }

    async fn handle(&self, mut session: Session) -> SessionEnd {
        let shutdown = session.shutdown.clone();
        let stream = session.stream();
        if stream.write_all(b"220 hold\r\n").await.is_err() {
            return SessionEnd::Closed;
        }
        let mut buffer = [0u8; 256];
        loop {
            tokio::select! {
                read = stream.read(&mut buffer) => match read {
                    Ok(0) | Err(_) => return SessionEnd::Closed,
                    Ok(_) => {}
                },
                () = shutdown.cancelled() => {
                    let _ = stream.write_all(b"421 bye\r\n").await;
                    let _ = stream.shutdown().await;
                    return SessionEnd::ClosedOnShutdown;
                }
            }
        }
    }
}

/// Protocole d'essai qui ignore l'arrêt du nœud : salue, puis ne rend jamais la main.
pub struct StubbornHandler;

#[async_trait]
impl SessionHandler for StubbornHandler {
    fn protocol(&self) -> MailProtocol {
        MailProtocol::Smtp
    }

    async fn handle(&self, mut session: Session) -> SessionEnd {
        let _ = session.stream().write_all(b"220 stubborn\r\n").await;
        std::future::pending::<()>().await;
        SessionEnd::Closed
    }
}

/// Première ligne reçue (sans CRLF), ou chaîne vide si la connexion est fermée sans rien dire.
pub async fn first_line(stream: &mut TcpStream) -> String {
    let mut received = Vec::new();
    let mut byte = [0u8; 1];
    let read = tokio::time::timeout(Duration::from_secs(5), async {
        loop {
            match stream.read(&mut byte).await {
                Ok(0) | Err(_) => break,
                Ok(_) => {
                    received.push(byte[0]);
                    if received.ends_with(b"\r\n") {
                        break;
                    }
                }
            }
        }
    })
    .await;
    assert!(read.is_ok(), "aucune réponse dans le délai");
    String::from_utf8(received)
        .expect("ligne ASCII")
        .trim_end()
        .to_string()
}

/// Connexion au serveur, et sa première ligne.
pub async fn greeting(address: SocketAddr) -> (TcpStream, String) {
    let mut stream = TcpStream::connect(address).await.expect("connexion");
    let line = first_line(&mut stream).await;
    (stream, line)
}

/// Attend que `condition` devienne vraie (5 s au plus).
pub async fn eventually(what: &str, mut condition: impl FnMut() -> bool) {
    let deadline = tokio::time::Instant::now() + Duration::from_secs(5);
    while !condition() {
        assert!(tokio::time::Instant::now() < deadline, "{what}");
        tokio::time::sleep(Duration::from_millis(20)).await;
    }
}
