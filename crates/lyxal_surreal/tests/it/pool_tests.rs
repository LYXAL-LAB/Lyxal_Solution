//! `SurrealPool` contre un serveur SurrealDB réel (`LYXAL_SURREAL_BIN`, à défaut `surreal` dans
//! le `PATH`), lancé en mémoire par chaque essai et arrêté à sa fin.
//!
//! Le pool joint le serveur à travers un relais TCP local qui compte, par connexion, les appels
//! de fonction envoyés, et qui peut couper une connexion ou la rendre muette : la répartition
//! des appels et l'effet d'une connexion perdue sont observés sur le fil, pas déduits.

// `LyxalSurrealError` porte l'erreur du SDK : le type `Err` des fonctions d'essai est large
#![allow(clippy::result_large_err)]

use async_trait::async_trait;
use futures::StreamExt;
use lyxal_surreal::{
    LyxalSurrealCall, LyxalSurrealError, PoolProbe, RootCredentials, SecretString,
    SurrealConnectOptions, SurrealPool,
};
use std::num::NonZeroUsize;
use std::sync::atomic::{AtomicBool, AtomicUsize, Ordering};
use std::sync::{Arc, Mutex};
use std::time::{Duration, Instant};
use surrealdb::engine::any::Any;
use surrealdb::types::SurrealValue;
use surrealdb::Surreal;
use tokio::io::{AsyncReadExt, AsyncWriteExt};
use tokio::net::{TcpListener, TcpStream};
use tokio::task::AbortHandle;

const PASSWORD: &str = "root-de-test";
/// Texte présent dans chaque appel de fonction de ces essais (`RETURN fn::pool_…($params);`).
const CALL_MARKER: &[u8] = b"RETURN fn::pool_";

// ---------------------------------------------------------------------------------------------
// Serveur et relais
// ---------------------------------------------------------------------------------------------

/// Serveur SurrealDB réel, arrêté à la fin de l'essai.
struct SurrealServer(std::process::Child);

impl Drop for SurrealServer {
    fn drop(&mut self) {
        let _ = self.0.kill();
        let _ = self.0.wait();
    }
}

async fn surreal_server() -> (SurrealServer, String) {
    let port = std::net::TcpListener::bind("127.0.0.1:0")
        .and_then(|listener| listener.local_addr())
        .expect("port libre")
        .port();
    let address = format!("127.0.0.1:{port}");
    let child = std::process::Command::new(
        std::env::var("LYXAL_SURREAL_BIN").unwrap_or_else(|_| "surreal".into()),
    )
    .args([
        "start", "--log", "error", "--bind", &address, "--user", "root", "--pass", PASSWORD,
        "memory",
    ])
    .stdout(std::process::Stdio::null())
    .stderr(std::process::Stdio::null())
    .spawn()
    .expect("lancer `surreal` (LYXAL_SURREAL_BIN ou PATH)");
    let server = SurrealServer(child);
    let started = Instant::now();
    while TcpStream::connect(&address).await.is_err() {
        assert!(
            started.elapsed() < Duration::from_secs(30),
            "SurrealDB injoignable"
        );
        tokio::time::sleep(Duration::from_millis(100)).await;
    }
    (server, address)
}

/// Connexion relayée : appels de fonction vus du client vers le serveur, coupure, silence.
struct Relayed {
    calls: Arc<AtomicUsize>,
    muted: Arc<AtomicBool>,
    task: AbortHandle,
}

/// Relais TCP entre le pool et le serveur : une entrée de `connections` par connexion acceptée,
/// dans l'ordre d'ouverture.
struct Relay {
    address: String,
    connections: Arc<Mutex<Vec<Relayed>>>,
    acceptor: AbortHandle,
}

impl Drop for Relay {
    fn drop(&mut self) {
        self.acceptor.abort();
        for connection in self.connections.lock().expect("relais").iter() {
            connection.task.abort();
        }
    }
}

impl Relay {
    async fn start(server: String) -> Self {
        let listener = TcpListener::bind("127.0.0.1:0").await.expect("relais");
        let address = listener.local_addr().expect("adresse").to_string();
        let connections: Arc<Mutex<Vec<Relayed>>> = Arc::default();
        let accepted = connections.clone();
        let acceptor = tokio::spawn(async move {
            while let Ok((client, _)) = listener.accept().await {
                let calls = Arc::new(AtomicUsize::new(0));
                let muted = Arc::new(AtomicBool::new(false));
                let task =
                    tokio::spawn(relay(client, server.clone(), calls.clone(), muted.clone()))
                        .abort_handle();
                accepted
                    .lock()
                    .expect("relais")
                    .push(Relayed { calls, muted, task });
            }
        })
        .abort_handle();
        Self {
            address,
            connections,
            acceptor,
        }
    }

    /// Connexions acceptées depuis le démarrage.
    fn opened(&self) -> usize {
        self.connections.lock().expect("relais").len()
    }

    /// Appels de fonction envoyés par chaque connexion, dans l'ordre d'ouverture.
    fn calls(&self) -> Vec<usize> {
        self.connections
            .lock()
            .expect("relais")
            .iter()
            .map(|connection| connection.calls.load(Ordering::SeqCst))
            .collect()
    }

    /// Coupe la connexion `index` : les deux sockets sont fermés.
    fn cut(&self, index: usize) {
        self.connections.lock().expect("relais")[index].task.abort();
    }

    /// Rend la connexion `index` muette : plus rien n'est relayé, sans fermer les sockets.
    fn mute(&self, index: usize) {
        self.connections.lock().expect("relais")[index]
            .muted
            .store(true, Ordering::SeqCst);
    }
}

/// Relaie une connexion dans les deux sens ; compte les messages WebSocket du client qui portent
/// un appel de fonction. Aborter la tâche ferme les deux sockets.
async fn relay(client: TcpStream, server: String, calls: Arc<AtomicUsize>, muted: Arc<AtomicBool>) {
    let Ok(upstream) = TcpStream::connect(server).await else {
        return;
    };
    let (mut client_read, mut client_write) = client.into_split();
    let (mut server_read, mut server_write) = upstream.into_split();
    let silent = muted.clone();
    let outbound = async move {
        let mut frames = FrameCounter::default();
        let mut buffer = vec![0_u8; 16 * 1024];
        loop {
            let read = match client_read.read(&mut buffer).await {
                Ok(0) | Err(_) => return,
                Ok(read) => read,
            };
            if silent.load(Ordering::SeqCst) {
                continue;
            }
            calls.fetch_add(frames.push(&buffer[..read]), Ordering::SeqCst);
            if server_write.write_all(&buffer[..read]).await.is_err() {
                return;
            }
        }
    };
    let inbound = async move {
        let mut buffer = vec![0_u8; 16 * 1024];
        loop {
            let read = match server_read.read(&mut buffer).await {
                Ok(0) | Err(_) => return,
                Ok(read) => read,
            };
            if muted.load(Ordering::SeqCst) {
                continue;
            }
            if client_write.write_all(&buffer[..read]).await.is_err() {
                return;
            }
        }
    };
    tokio::select! {
        () = outbound => {}
        () = inbound => {}
    }
}

/// Lecteur des trames WebSocket d'un client (RFC 6455 §5.2, trames masquées) : compte les
/// messages de données dont le contenu porte [`CALL_MARKER`]. La poignée de main HTTP qui
/// précède les trames est passée telle quelle.
#[derive(Default)]
struct FrameCounter {
    pending: Vec<u8>,
    upgraded: bool,
}

impl FrameCounter {
    fn push(&mut self, bytes: &[u8]) -> usize {
        self.pending.extend_from_slice(bytes);
        if !self.upgraded {
            let Some(end) = find(&self.pending, b"\r\n\r\n") else {
                return 0;
            };
            self.pending.drain(..end + 4);
            self.upgraded = true;
        }
        let mut calls = 0;
        loop {
            let Some((header, length, mask)) = frame_header(&self.pending) else {
                return calls;
            };
            if self.pending.len() < header + length {
                return calls;
            }
            let opcode = self.pending[0] & 0x0f;
            let payload: Vec<u8> = self.pending[header..header + length]
                .iter()
                .enumerate()
                .map(|(index, byte)| byte ^ mask[index % 4])
                .collect();
            if matches!(opcode, 1 | 2) && find(&payload, CALL_MARKER).is_some() {
                calls += 1;
            }
            self.pending.drain(..header + length);
        }
    }
}

/// En-tête d'une trame masquée : taille de l'en-tête, taille du contenu, clé de masquage.
fn frame_header(bytes: &[u8]) -> Option<(usize, usize, [u8; 4])> {
    let short = usize::from(*bytes.get(1)? & 0x7f);
    let (length, mask_at) = match short {
        126 => (
            usize::from(u16::from_be_bytes(bytes.get(2..4)?.try_into().ok()?)),
            4,
        ),
        127 => (
            usize::try_from(u64::from_be_bytes(bytes.get(2..10)?.try_into().ok()?)).ok()?,
            10,
        ),
        short => (short, 2),
    };
    let mask = bytes.get(mask_at..mask_at + 4)?.try_into().ok()?;
    Some((mask_at + 4, length, mask))
}

fn find(haystack: &[u8], needle: &[u8]) -> Option<usize> {
    haystack
        .windows(needle.len())
        .position(|window| window == needle)
}

// ---------------------------------------------------------------------------------------------
// Pool et store d'essai
// ---------------------------------------------------------------------------------------------

async fn pool(address: &str, connections: usize) -> SurrealPool {
    SurrealPool::connect(
        &SurrealConnectOptions {
            endpoint: format!("ws://{address}"),
            credentials: Some(RootCredentials::new(
                "root",
                SecretString::new(PASSWORD.to_owned()).expect("secret"),
            )),
            namespace: "lyxal_test".to_owned(),
            database: "pool".to_owned(),
            connect_timeout: Duration::from_secs(10),
        },
        NonZeroUsize::new(connections).expect("connexions"),
    )
    .await
    .expect("pool")
}

/// Store d'essai sur un pool, comme un store de module.
#[derive(Clone)]
struct PoolStore {
    db: SurrealPool,
}

#[async_trait]
impl LyxalSurrealCall for PoolStore {
    fn surreal_client(&self) -> &Surreal<Any> {
        self.db.client()
    }
}

#[derive(Clone, SurrealValue)]
struct SlowParams {
    /// Durée de l'appel dans la base, en millisecondes.
    ms: i64,
    /// Marque inscrite par l'appel.
    mark: i64,
}

/// Serveur, relais, pool de `connections` connexions à travers le relais, et fonctions d'essai :
/// `fn::pool_slow` attend `ms` millisecondes puis inscrit `mark` ; `fn::pool_echo` rend `mark`.
async fn bench(connections: usize) -> (SurrealServer, Relay, PoolStore) {
    let (server, address) = surreal_server().await;
    let relay = Relay::start(address).await;
    let db = pool(&relay.address, connections).await;
    db.fixed()
        .query(
            "DEFINE TABLE pool_mark SCHEMALESS;
             DEFINE FUNCTION OVERWRITE fn::pool_slow($params: object) {
                 sleep(<duration> (<string> $params.ms + 'ms'));
                 CREATE pool_mark CONTENT { mark: $params.mark };
                 RETURN { ok: true, data: $params.mark, error: NONE };
             };
             DEFINE FUNCTION OVERWRITE fn::pool_echo($params: object) {
                 RETURN { ok: true, data: $params.mark, error: NONE };
             };",
        )
        .await
        .expect("définitions")
        .check()
        .expect("définitions acceptées");
    (server, relay, PoolStore { db })
}

async fn slow(store: &PoolStore, ms: i64, mark: i64) -> Result<i64, LyxalSurrealError> {
    store.call_fn("pool_slow", SlowParams { ms, mark }).await
}

async fn echo(store: &PoolStore, mark: i64) -> Result<i64, LyxalSurrealError> {
    store.call_fn("pool_echo", SlowParams { ms: 0, mark }).await
}

async fn marks(store: &PoolStore) -> Vec<i64> {
    let mut response = store
        .db
        .fixed()
        .query("SELECT VALUE mark FROM pool_mark ORDER BY mark;")
        .await
        .expect("marques");
    response.take(0).expect("lecture")
}

// ---------------------------------------------------------------------------------------------
// Essais
// ---------------------------------------------------------------------------------------------

/// Pool d'un client : une seule connexion ouverte, par laquelle passent tous les appels,
/// successifs ou simultanés, comme pour un store posé sur un client seul.
#[tokio::test(flavor = "multi_thread", worker_threads = 2)]
async fn a_pool_of_one_behaves_as_a_single_client() {
    let (_server, relay, store) = bench(1).await;
    assert_eq!(store.db.size(), 1);
    assert_eq!(relay.opened(), 1);

    for mark in 0..3 {
        assert_eq!(echo(&store, mark).await.expect("appel"), mark);
    }
    assert_eq!(relay.calls(), [3]);
    let results = futures::future::join_all((0..4).map(|mark| slow(&store, 100, mark))).await;
    for (mark, result) in (0..).zip(&results) {
        assert_eq!(result.as_ref().expect("appel"), &mark);
    }
    assert_eq!(relay.calls(), [7]);
    assert_eq!(marks(&store).await, [0, 1, 2, 3]);
    // Le client du tour et la connexion fixe sont le même client
    assert!(std::ptr::eq(store.db.client(), store.db.fixed()));

    // Store posé sur un client seul (`From<Surreal<Any>>`) : même connexion, mêmes résultats
    let single = PoolStore {
        db: SurrealPool::from(store.db.fixed().clone()),
    };
    assert_eq!(single.db.size(), 1);
    assert_eq!(echo(&single, 9).await.expect("client seul"), 9);
    assert_eq!(slow(&single, 0, 4).await.expect("client seul"), 4);
    assert_eq!(relay.opened(), 1);
    assert_eq!(relay.calls(), [9]);
    assert_eq!(marks(&store).await, [0, 1, 2, 3, 4]);
}

/// Pool de plusieurs clients : chaque client est dans le même état de session, et les appels,
/// successifs ou simultanés, sont répartis à tour de rôle sur les connexions.
#[tokio::test(flavor = "multi_thread", worker_threads = 2)]
async fn a_pool_spreads_calls_over_its_connections() {
    let (_server, relay, store) = bench(4).await;
    assert_eq!(store.db.size(), 4);
    assert_eq!(relay.opened(), 4);

    // Même session sur chaque connexion : espace de noms, base, session Root
    for client in store.db.clients() {
        let mut response = client
            .query("RETURN [session::ns(), session::db()]; INFO FOR ROOT;")
            .await
            .expect("session");
        let selected: Vec<String> = response.take(0).expect("lecture");
        assert_eq!(selected, ["lyxal_test", "pool"]);
        assert!(response.check().is_ok(), "session Root attendue");
    }

    // Appels successifs : un par connexion, à tour de rôle
    for mark in 0..12 {
        assert_eq!(echo(&store, mark).await.expect("appel"), mark);
    }
    assert_eq!(relay.calls(), [3, 3, 3, 3]);

    // Appels simultanés : huit appels sur quatre connexions, deux par connexion
    let results = futures::future::join_all((0..8).map(|mark| slow(&store, 100, mark))).await;
    for (mark, result) in (0..).zip(&results) {
        assert_eq!(result.as_ref().expect("appel"), &mark);
    }
    assert_eq!(relay.calls(), [5, 5, 5, 5]);
    assert_eq!(marks(&store).await, [0, 1, 2, 3, 4, 5, 6, 7]);

    // Une écriture faite par une connexion est lue aussitôt par une autre
    for mark in 100..110 {
        slow(&store, 0, mark).await.expect("écriture");
        let mut response = store
            .db
            .client()
            .query("RETURN count(SELECT * FROM pool_mark WHERE mark = $mark);")
            .bind(("mark", mark))
            .await
            .expect("lecture");
        let found: Option<i64> = response.take(0).expect("compte");
        assert_eq!(found, Some(1), "marque {mark}");
    }
}

/// Une connexion coupée ne fait échouer que ses appels en cours : ceux des autres connexions
/// aboutissent, et la connexion coupée est rouverte par le client, sa session rétablie.
#[tokio::test(flavor = "multi_thread", worker_threads = 2)]
async fn a_cut_connection_fails_only_its_calls_in_flight() {
    let (_server, relay, store) = bench(3).await;
    assert_eq!(relay.opened(), 3);

    // Six appels de 1,5 s : deux par connexion (appel `i` sur la connexion `i % 3`)
    let calls = futures::future::join_all((0..6).map(|mark| slow(&store, 1_500, mark)));
    let cut = async {
        tokio::time::sleep(Duration::from_millis(500)).await;
        assert_eq!(relay.calls(), [2, 2, 2], "appels partis avant la coupure");
        relay.cut(1);
    };
    let (results, ()) = tokio::join!(calls, cut);
    for (mark, result) in (0_i64..).zip(&results) {
        if mark % 3 == 1 {
            let error = result.as_ref().expect_err("appel de la connexion coupée");
            assert!(
                matches!(error, LyxalSurrealError::Database(_)),
                "appel {mark} : {error:?}"
            );
        } else {
            assert_eq!(result.as_ref().expect("appel d'une autre connexion"), &mark);
        }
    }

    // La connexion est rouverte par le client (quatrième connexion vue par le relais) et sa
    // session rétablie : tous les appels suivants aboutissent, sur les trois clients
    for mark in 10..19 {
        assert_eq!(
            slow(&store, 0, mark).await.expect("appel après coupure"),
            mark
        );
    }
    assert_eq!(relay.opened(), 4);
    let calls = relay.calls();
    assert_eq!(calls[3], 3, "appels de la connexion rouverte : {calls:?}");
    // Relevé bien après la coupure : les appels de la connexion coupée n'ont rien inscrit (le
    // serveur a abandonné leurs transactions), les autres ont tout inscrit
    assert_eq!(
        marks(&store).await,
        [0, 2, 3, 5, 10, 11, 12, 13, 14, 15, 16, 17, 18]
    );
    assert_eq!(
        store.db.probe(Duration::from_secs(5)).await,
        PoolProbe {
            clients: 3,
            responding: 3,
            error: None
        }
    );
}

/// Sonde : une connexion muette est comptée, la base reste joignable tant qu'une connexion
/// répond ; plus aucune ne répond, la base n'est plus joignable.
#[tokio::test(flavor = "multi_thread", worker_threads = 2)]
async fn the_probe_counts_silent_connections() {
    let (_server, relay, store) = bench(3).await;
    let within = Duration::from_millis(800);
    assert!(store.db.probe(within).await.complete());

    relay.mute(2);
    let started = Instant::now();
    let partial = store.db.probe(within).await;
    assert_eq!((partial.clients, partial.responding), (3, 2));
    assert!(partial.reachable() && !partial.complete());
    assert!(
        partial
            .error
            .as_deref()
            .is_some_and(|e| e.contains("800 ms")),
        "{partial:?}"
    );
    // Sondes simultanées : le délai d'une connexion muette n'est payé qu'une fois
    assert!(started.elapsed() < Duration::from_millis(1_600));

    relay.mute(0);
    relay.mute(1);
    let silent = store.db.probe(within).await;
    assert_eq!((silent.clients, silent.responding), (3, 0));
    assert!(!silent.reachable());
}

/// Une requête `LIVE` tenue sur la connexion fixe reçoit les écritures faites par les autres
/// connexions du pool.
#[tokio::test(flavor = "multi_thread", worker_threads = 2)]
async fn a_live_query_on_the_fixed_connection_sees_writes_from_the_pool() {
    let (_server, relay, store) = bench(3).await;
    #[derive(Debug, SurrealValue)]
    struct Mark {
        mark: i64,
    }
    let mut response = store
        .db
        .fixed()
        .query("LIVE SELECT mark FROM pool_mark;")
        .await
        .expect("requête LIVE");
    let mut stream = response
        .stream::<surrealdb::Notification<Mark>>(0)
        .expect("flux");

    // Trois écritures, une par connexion
    for mark in 0..3 {
        slow(&store, 0, mark).await.expect("écriture");
    }
    assert_eq!(relay.calls(), [1, 1, 1]);
    let mut seen = Vec::new();
    for _ in 0..3 {
        let notification = tokio::time::timeout(Duration::from_secs(10), stream.next())
            .await
            .expect("notification attendue")
            .expect("flux ouvert")
            .expect("notification lisible");
        seen.push(notification.data.mark);
    }
    seen.sort_unstable();
    assert_eq!(seen, [0, 1, 2]);
}
