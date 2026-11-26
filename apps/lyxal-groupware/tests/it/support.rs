//! Outils communs des essais : configuration, base embarquée, écoutes lancées sans runtime,
//! protocoles d'essai, client TCP.

use async_trait::async_trait;
use lyxal_groupware::config::GroupwareConfig;
use lyxal_groupware::net::bind::bind_listeners;
use lyxal_groupware::net::certificates::Certificates;
use lyxal_groupware::net::MailNet;
use lyxal_mail::net::{ConnectionInfo, MailProtocol, Session, SessionEnd, SessionHandler};
use lyxal_runtime::worker::{CancellationToken, WorkerContext};
use lyxal_runtime::{ModuleContext, RuntimeError};
use std::fs;
use std::net::SocketAddr;
use std::path::{Path, PathBuf};
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

[smtp]
hostname = "mx.lyxal.test"
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

/// Serveur DNS d'essai sur un port UDP libre de `127.0.0.1` : répond « n'existe pas »
/// (`NXDOMAIN`) à toute question, sans jamais interroger le vrai DNS. Rend la section `[dns]`
/// qui le désigne.
pub async fn fake_dns() -> String {
    let socket = tokio::net::UdpSocket::bind("127.0.0.1:0")
        .await
        .expect("socket DNS");
    let address = socket.local_addr().expect("adresse DNS");
    tokio::spawn(async move {
        let mut buffer = [0u8; 512];
        while let Ok((read, peer)) = socket.recv_from(&mut buffer).await {
            if read < 12 {
                continue;
            }
            // En-tête et question seulement (la section additionnelle EDNS est retirée)
            let mut end = 12;
            while end < read && buffer[end] != 0 {
                end += usize::from(buffer[end]) + 1;
            }
            let end = (end + 5).min(read);
            let mut answer = buffer[..end].to_vec();
            // QR = 1, opcode et RD repris, RA = 1, RCODE = 3 (NXDOMAIN) ; aucune réponse
            answer[2] = 0x80 | (buffer[2] & 0x79);
            answer[3] = 0x80 | 0x03;
            answer[6..12].fill(0);
            let _ = socket.send_to(&answer, peer).await;
        }
    });
    format!("\n[dns]\nservers = [\"{address}\"]\ntimeout_seconds = 1\nattempts = 1\n")
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
    MailNet::new(config, bound, None, &move |_| handler.clone()).expect("écoutes")
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

/// Certificats d'essai de `lyxal_crypto` (`crates/lyxal_crypto/tests/fixtures/tls_test_only/`,
/// réservés aux tests, commandes de génération dans le `README.md` de ce dossier), copiés dans
/// un dossier temporaire avec des clés en mode 0600 : `p256` et `p256_next` couvrent
/// `mail.example.test`, `default` couvre `default.example.test`, `ca.pem` est leur autorité.
pub struct TestCertificates {
    directory: tempfile::TempDir,
}

impl TestCertificates {
    pub fn new() -> Self {
        let source = Path::new(env!("CARGO_MANIFEST_DIR"))
            .join("../../crates/lyxal_crypto/tests/fixtures/tls_test_only");
        let directory = tempfile::tempdir().expect("tempdir");
        for name in ["p256", "p256_next", "default"] {
            for kind in ["chain", "key"] {
                let file = format!("{name}.{kind}.pem");
                fs::copy(source.join(&file), directory.path().join(&file)).expect("copie");
            }
        }
        fs::copy(source.join("ca.pem"), directory.path().join("ca.pem")).expect("ca.pem");
        let certificates = Self { directory };
        for name in ["p256", "p256_next", "default"] {
            certificates.set_mode(&format!("{name}.key.pem"), 0o600);
        }
        certificates.serve("p256");
        certificates
    }

    pub fn path(&self, file: &str) -> PathBuf {
        self.directory.path().join(file)
    }

    #[cfg(unix)]
    pub fn set_mode(&self, file: &str, mode: u32) {
        use std::os::unix::fs::PermissionsExt;
        fs::set_permissions(self.path(file), fs::Permissions::from_mode(mode)).expect("droits");
    }

    #[cfg(not(unix))]
    pub fn set_mode(&self, _file: &str, _mode: u32) {}

    /// Section `[tls]` : `default` par défaut, `mail.example.test` servi depuis les fichiers
    /// `served.*` (copie de `p256`, remplaçable par les essais de rechargement).
    pub fn tls_section(&self) -> String {
        format!(
            "[tls]\nhandshake_timeout_seconds = 2\ndefault = {{ certificate = {:?}, private_key = {:?} }}\n\n[[tls.certificates]]\nnames = [\"mail.example.test\"]\ncertificate = {:?}\nprivate_key = {:?}\n",
            self.path("default.chain.pem"),
            self.path("default.key.pem"),
            self.path("served.chain.pem"),
            self.path("served.key.pem"),
        )
    }

    /// Sert le couple `name` pour `mail.example.test` (fichiers `served.*`, clé en 0600).
    pub fn serve(&self, name: &str) {
        for kind in ["chain", "key"] {
            fs::copy(
                self.path(&format!("{name}.{kind}.pem")),
                self.path(&format!("served.{kind}.pem")),
            )
            .expect("copie");
        }
        self.set_mode("served.key.pem", 0o600);
    }
}

/// Écoutes de `config` liées, servies avec ses certificats.
pub fn tls_net(config: &GroupwareConfig, handler: Arc<dyn SessionHandler>) -> MailNet {
    let certificates = Certificates::load(&config.tls).expect("certificats");
    let bound = bind_listeners(config).expect("liaison");
    MailNet::new(config, bound, certificates, &move |_| handler.clone()).expect("écoutes")
}

/// Écoute de protocole `protocol` sur un port libre de `127.0.0.1`, en mode `tls`.
pub fn listener(id: &str, protocol: &str, tls: &str, extra: &str) -> String {
    format!(
        "\n[[listeners]]\nid = \"{id}\"\nprotocol = \"{protocol}\"\nbind = [\"127.0.0.1:0\"]\ntls = \"{tls}\"\n{extra}\n"
    )
}

/// Résultat d'un client `openssl s_client`.
#[derive(Debug)]
pub struct SClient {
    /// Vrai si le client a terminé sans erreur (poignée de main et vérification réussies).
    pub success: bool,
    /// Données reçues du serveur.
    pub stdout: String,
    /// Paramètres de la connexion (`-brief`) et erreurs.
    pub stderr: String,
}

impl SClient {
    /// Valeur d'une ligne `Clé: valeur` de la sortie `-brief`.
    pub fn field(&self, key: &str) -> Option<&str> {
        self.stderr
            .lines()
            .find_map(|line| line.strip_prefix(key)?.strip_prefix(':'))
            .map(str::trim)
    }

    /// Sujet du certificat du serveur, écrit `CN=nom` quelle que soit la version d'OpenSSL
    /// (`CN = nom` en 3.0, `CN=nom` à partir de 3.2).
    pub fn peer_certificate(&self) -> Option<String> {
        self.field("Peer certificate")
            .map(|subject| subject.replace(" = ", "="))
    }
}

/// Date de vérification des certificats d'essai, indépendante de l'horloge (1er janvier 2027).
const VERIFY_AT: &str = "1798761600";

/// Client TLS d'essai : `openssl s_client`. La configuration `rustls` d'un client ne se construit
/// pas hors de `lyxal_crypto` (garde-fou C12, `scripts/ci/check_crypto_dependencies.py`) : les
/// essais passent par l'outil OpenSSL, qui vérifie la chaîne contre l'autorité d'essai. Envoie
/// `input`, puis attend la fermeture par le serveur.
pub async fn s_client(
    address: SocketAddr,
    certificates: &TestCertificates,
    args: &[&str],
    input: &[u8],
) -> SClient {
    let mut child = s_client_process(address, certificates, args);
    let mut stdin = child.stdin.take().expect("stdin");
    stdin.write_all(input).await.expect("entrée");
    drop(stdin);
    let output = tokio::time::timeout(Duration::from_secs(20), child.wait_with_output())
        .await
        .expect("openssl s_client hors délai")
        .expect("openssl s_client");
    SClient {
        success: output.status.success(),
        stdout: String::from_utf8_lossy(&output.stdout).into_owned(),
        stderr: String::from_utf8_lossy(&output.stderr).into_owned(),
    }
}

/// `openssl s_client` lancé, entrée et sorties en tubes.
pub fn s_client_process(
    address: SocketAddr,
    certificates: &TestCertificates,
    args: &[&str],
) -> tokio::process::Child {
    tokio::process::Command::new("openssl")
        .args(["s_client", "-connect", &address.to_string(), "-brief"])
        .args(["-CAfile", &certificates.path("ca.pem").to_string_lossy()])
        .args(["-attime", VERIFY_AT, "-verify_return_error", "-ign_eof"])
        .args(args)
        .stdin(std::process::Stdio::piped())
        .stdout(std::process::Stdio::piped())
        .stderr(std::process::Stdio::piped())
        .kill_on_drop(true)
        .spawn()
        .expect("openssl introuvable : l'outil OpenSSL est requis par les essais TLS")
}

/// Protocole d'essai : enregistre ce que la session sait de sa connexion, salue par
/// `220 session <numéro>`, puis ferme.
#[derive(Clone, Default)]
pub struct RecordingHandler {
    pub seen: Arc<std::sync::Mutex<Vec<ConnectionInfo>>>,
}

impl RecordingHandler {
    pub fn last(&self) -> ConnectionInfo {
        self.seen
            .lock()
            .unwrap()
            .last()
            .cloned()
            .expect("aucune session")
    }
}

#[async_trait]
impl SessionHandler for RecordingHandler {
    fn protocol(&self) -> MailProtocol {
        MailProtocol::Imap
    }

    async fn handle(&self, mut session: Session) -> SessionEnd {
        self.seen.lock().unwrap().push(session.info.clone());
        let greeting = format!("220 session {}\r\n", session.info.session_id);
        let stream = session.stream();
        let _ = stream.write_all(greeting.as_bytes()).await;
        let _ = stream.shutdown().await;
        SessionEnd::Closed
    }
}

/// Journal du fil courant capturé dans un tampon, tant que la garde vit.
#[derive(Clone, Default)]
pub struct Captured(Arc<std::sync::Mutex<Vec<u8>>>);

impl std::io::Write for Captured {
    fn write(&mut self, bytes: &[u8]) -> std::io::Result<usize> {
        self.0.lock().unwrap().extend_from_slice(bytes);
        Ok(bytes.len())
    }

    fn flush(&mut self) -> std::io::Result<()> {
        Ok(())
    }
}

impl Captured {
    /// Texte capturé.
    pub fn text(&self) -> String {
        String::from_utf8(self.0.lock().unwrap().clone()).unwrap()
    }
}

/// Gardes de la capture : abonné du fil courant et second abonné vivant.
pub struct LogGuard {
    _default: tracing::subscriber::DefaultGuard,
    _other: tracing::Dispatch,
}

/// Capture le journal (niveau `info` et au-dessus) du fil courant. Essai sur un seul fil
/// (`current_thread`) : les tâches des écoutes y écrivent aussi. Un second abonné reste vivant :
/// avec un seul abonné inscrit, `tracing` calcule l'intérêt d'un point de journal d'après le fil
/// qui le rencontre le premier (un autre essai, sans abonné) et le tiendrait pour muet ici.
pub fn capture_logs() -> (Captured, LogGuard) {
    let captured = Captured::default();
    let writer = captured.clone();
    let subscriber = tracing_subscriber::fmt()
        .with_max_level(tracing::Level::INFO)
        .with_ansi(false)
        .with_writer(move || writer.clone())
        .finish();
    let default = tracing::subscriber::set_default(subscriber);
    let other = tracing::Dispatch::new(tracing::subscriber::NoSubscriber::default());
    (
        captured,
        LogGuard {
            _default: default,
            _other: other,
        },
    )
}
