// SPDX-License-Identifier: AGPL-3.0-only

//! Réception SMTP de bout en bout, par dialogues scriptés sur une vraie socket (base embarquée,
//! support disque, résolveur `StaticResolver`) : conformité par commande et par état,
//! `PIPELINING`, `BDAT`, `SMTPUTF8`, refus sans relais, contrebande SMTP, politique DMARC,
//! usurpations, antivirus, échec partiel puis nouvel essai sans doublon, limites, recherche
//! d'adresses et bannissement, STARTTLS (mise à niveau d'essai, sans chiffrement : le vrai TLS
//! est essayé par `lyxal-groupware`).

use async_trait::async_trait;
use base64::engine::general_purpose::STANDARD;
use base64::Engine;
use bytes::Bytes;
use lyxal_crypto::{
    DkimBodyHasher, DkimCanonicalization, DkimHeaderCanonicalizer, DkimSigningKey,
    Ed25519SigningKey,
};
use lyxal_mail::dns::StaticResolver;
use lyxal_mail::models::{
    AccountUpdateParams, AddressCreateParams, BlockActiveParams, SettingsSetParams,
};
use lyxal_mail::net::{
    BoxedStream, ConnectionInfo, MailProtocol, MemoryBudget, MemoryClass, NetError, Session,
    SessionHandler, SessionLimits, TlsInfo, TlsState, TlsUpgrade,
};
use lyxal_mail::smtp::{BlockList, SmtpConfig, SmtpInboundHandler, SmtpServices};
use lyxal_mail::DeliveryPipeline;
use lyxal_runtime::worker::CancellationToken;
use lyxal_storage::{ContentScanner, ScanSession, ScanVerdict, StorageError, StorageResult};
use lyxal_surreal::Value;
use std::net::{IpAddr, SocketAddr};
use std::sync::Arc;
use std::time::{Duration, Instant};
use tokio::io::{AsyncBufReadExt, AsyncReadExt, AsyncWriteExt, BufReader};
use tokio::net::tcp::{OwnedReadHalf, OwnedWriteHalf};
use tokio::net::{TcpListener, TcpStream};

use crate::support::{bench, Bench, Person};

pub(crate) const HOSTNAME: &str = "mx.alpha.test";
const LOCALHOST: &str = "127.0.0.1";

/// Résolveur des essais : `ailleurs.test` autorise 127.0.0.1 (SPF) et publie DMARC `reject`,
/// nom inverse confirmé de 127.0.0.1.
pub(crate) fn resolver() -> StaticResolver {
    let ip: IpAddr = LOCALHOST.parse().unwrap();
    let mut resolver = StaticResolver::new();
    resolver
        .set_txt("ailleurs.test", &["v=spf1 ip4:127.0.0.1 -all"])
        .set_txt("_dmarc.ailleurs.test", &["v=DMARC1; p=reject"])
        .set_txt("client.ailleurs.test", &["v=spf1 ip4:127.0.0.1 -all"])
        .set_ptr(ip, &["client.ailleurs.test"])
        .set_ips("client.ailleurs.test", &[ip]);
    resolver
}

/// Mise à niveau d'essai : garde le flux tel quel (aucun chiffrement).
struct EchoUpgrade;

#[async_trait]
impl TlsUpgrade for EchoUpgrade {
    async fn upgrade(&self, stream: BoxedStream) -> Result<(BoxedStream, TlsInfo), NetError> {
        Ok((
            stream,
            TlsInfo {
                version: "TLSv1_3",
                cipher: "TLS13_AES_128_GCM_SHA256",
                server_name: None,
                alpn: None,
            },
        ))
    }
}

/// Antivirus d'essai : reconnaît la signature EICAR, ou ne répond pas.
struct FakeScanner {
    available: bool,
}

struct FakeScan {
    content: Vec<u8>,
}

#[async_trait]
impl ContentScanner for FakeScanner {
    async fn begin(&self) -> StorageResult<Box<dyn ScanSession>> {
        if self.available {
            Ok(Box::new(FakeScan {
                content: Vec::new(),
            }))
        } else {
            Err(StorageError::ScannerUnavailable("essai".to_string()))
        }
    }

    async fn ping(&self) -> StorageResult<()> {
        Ok(())
    }
}

#[async_trait]
impl ScanSession for FakeScan {
    async fn feed(&mut self, chunk: &Bytes) -> StorageResult<()> {
        self.content.extend_from_slice(chunk);
        Ok(())
    }

    async fn finish(self: Box<Self>) -> StorageResult<ScanVerdict> {
        let infected = self
            .content
            .windows(34)
            .any(|window| window == b"EICAR-STANDARD-ANTIVIRUS-TEST-FILE");
        Ok(if infected {
            ScanVerdict::Infected("Eicar-Test-Signature".to_string())
        } else {
            ScanVerdict::Clean
        })
    }
}

/// Serveur SMTP d'essai sur un port libre.
pub(crate) struct Server {
    address: SocketAddr,
    pub(crate) handler: SmtpInboundHandler,
    shutdown: CancellationToken,
}

impl Drop for Server {
    fn drop(&mut self) {
        self.shutdown.cancel();
    }
}

pub(crate) struct Options {
    resolver: StaticResolver,
    pub(crate) config: SmtpConfig,
    scanner: Option<Arc<dyn ContentScanner>>,
    starttls: bool,
}

impl Options {
    pub(crate) fn new() -> Self {
        Self {
            resolver: resolver(),
            config: SmtpConfig::new(HOSTNAME),
            scanner: None,
            starttls: false,
        }
    }
}

pub(crate) async fn serve(bench: &Bench, options: Options) -> Server {
    let mut pipeline = DeliveryPipeline::new(bench.ingest.clone());
    if let Some(scanner) = options.scanner {
        pipeline = pipeline.with_scanner(scanner);
    }
    let budget = MemoryBudget::new(256 << 20);
    let handler = SmtpInboundHandler::new(
        options.config,
        SmtpServices {
            store: bench.system.clone(),
            resolver: Arc::new(options.resolver),
            pipeline,
            budget: budget.clone(),
            blocks: BlockList::new(),
        },
    )
    .expect("réglages");
    let listener = TcpListener::bind("127.0.0.1:0").await.expect("écoute");
    let address = listener.local_addr().expect("adresse");
    let shutdown = CancellationToken::new();
    let serving = handler.clone();
    let stop = shutdown.clone();
    let starttls = options.starttls;
    tokio::spawn(async move {
        let mut next = 1;
        loop {
            let accepted = tokio::select! {
                () = stop.cancelled() => return,
                accepted = listener.accept() => accepted,
            };
            let Ok((stream, remote)) = accepted else {
                continue;
            };
            // Comme l'hôte (`apply_connection_options`) : réponses envoyées sans attendre
            let _ = stream.set_nodelay(true);
            let mut memory = budget.reservation(MemoryClass::Read, budget.limit());
            assert!(memory.reserve_to(64 * 1024));
            let session = Session::new(
                ConnectionInfo {
                    listener_id: "smtp".into(),
                    protocol: MailProtocol::Smtp,
                    session_id: next,
                    local: address,
                    remote,
                    via_proxy: false,
                    tls: TlsState::Plain,
                },
                SessionLimits {
                    idle: Duration::from_secs(300),
                    write_stall: Duration::from_secs(60),
                },
                stop.child_token(),
                memory,
                Box::new(stream),
                starttls.then(|| Arc::new(EchoUpgrade) as Arc<dyn TlsUpgrade>),
            );
            next += 1;
            let handler = serving.clone();
            tokio::spawn(async move { handler.handle(session).await });
        }
    });
    Server {
        address,
        handler,
        shutdown,
    }
}

/// Client SMTP scripté.
pub(crate) struct Client {
    reader: BufReader<OwnedReadHalf>,
    writer: OwnedWriteHalf,
}

impl Client {
    pub(crate) async fn connect(server: &Server) -> (Self, String) {
        let stream = TcpStream::connect(server.address).await.expect("connexion");
        stream.set_nodelay(true).expect("TCP_NODELAY");
        let (read, write) = stream.into_split();
        let mut client = Self {
            reader: BufReader::new(read),
            writer: write,
        };
        let greeting = client.reply().await;
        (client, greeting)
    }

    /// Réponse complète (lignes `code-` puis `code `), lignes séparées par `\n`.
    pub(crate) async fn reply(&mut self) -> String {
        let mut lines = Vec::new();
        loop {
            let mut line = String::new();
            let read =
                tokio::time::timeout(Duration::from_secs(30), self.reader.read_line(&mut line))
                    .await
                    .expect("réponse dans le délai")
                    .expect("lecture");
            if read == 0 {
                return if lines.is_empty() {
                    "fermée".to_string()
                } else {
                    lines.join("\n")
                };
            }
            let line = line.trim_end_matches("\r\n").to_string();
            let last = line.as_bytes().get(3) != Some(&b'-');
            lines.push(line);
            if last {
                return lines.join("\n");
            }
        }
    }

    pub(crate) async fn send(&mut self, bytes: &[u8]) {
        self.writer.write_all(bytes).await.expect("écriture");
    }

    pub(crate) async fn cmd(&mut self, line: &str) -> String {
        self.send(format!("{line}\r\n").as_bytes()).await;
        self.reply().await
    }

    /// Lit jusqu'à la fermeture par le serveur.
    async fn closed(&mut self) -> bool {
        let mut rest = Vec::new();
        tokio::time::timeout(Duration::from_secs(10), self.reader.read_to_end(&mut rest))
            .await
            .map(|read| read.is_ok())
            .unwrap_or(false)
    }

    /// Envoie un message par `DATA` (bourrage des points fait ici) et rend la réponse finale.
    pub(crate) async fn data(&mut self, message: &str) -> String {
        let reply = self.cmd("DATA").await;
        assert!(reply.starts_with("354 "), "{reply}");
        let mut stuffed = String::new();
        for line in message.split_inclusive("\r\n") {
            if line.starts_with('.') {
                stuffed.push('.');
            }
            stuffed.push_str(line);
        }
        stuffed.push_str(".\r\n");
        self.send(stuffed.as_bytes()).await;
        self.reply().await
    }

    /// Transaction complète : `MAIL FROM`, destinataires, `DATA`.
    pub(crate) async fn transaction(&mut self, from: &str, to: &[&str], message: &str) -> String {
        let reply = self.cmd(&format!("MAIL FROM:<{from}>")).await;
        assert!(reply.starts_with("250 "), "{reply}");
        for recipient in to {
            let reply = self.cmd(&format!("RCPT TO:<{recipient}>")).await;
            assert!(reply.starts_with("250 "), "{recipient} : {reply}");
        }
        self.data(message).await
    }
}

fn message(from: &str, subject: &str, body: &str) -> String {
    format!(
        "From: {from}\r\nTo: <jean@alpha.test>\r\nSubject: {subject}\r\nDate: Tue, 3 Nov 2026 10:00:00 +0100\r\nMessage-ID: <{subject}@ailleurs.test>\r\n\r\n{body}\r\n"
    )
}

/// Signe `message` (Ed25519, `relaxed/relaxed`, en-têtes `From` et `Subject`) pour `domain`.
fn sign(message: &str, key: &DkimSigningKey, domain: &str) -> String {
    let (head, body) = message.split_once("\r\n\r\n").unwrap();
    let mut hasher = DkimBodyHasher::new(DkimCanonicalization::Relaxed, None);
    hasher.update(body.as_bytes());
    let body_hash = STANDARD.encode(hasher.finish().digest);
    let value = format!(
        " v=1; a=ed25519-sha256; c=relaxed/relaxed; d={domain}; s=s1; h=from:subject; bh={body_hash};\r\n b="
    );
    let mut canonicalizer = DkimHeaderCanonicalizer::new(DkimCanonicalization::Relaxed);
    for name in ["From", "Subject"] {
        let field = head
            .split("\r\n")
            .find(|line| line.starts_with(&format!("{name}:")))
            .unwrap();
        canonicalizer
            .push_header(name.as_bytes(), &field.as_bytes()[name.len() + 1..])
            .unwrap();
    }
    let signed = canonicalizer
        .finish(b"DKIM-Signature", value.as_bytes())
        .unwrap();
    let signature = STANDARD.encode(key.sign(&signed).unwrap());
    format!("DKIM-Signature:{value}{signature}\r\n{message}")
}

fn key_record(key: &DkimSigningKey) -> String {
    format!(
        "v=DKIM1; k=ed25519; p={}",
        STANDARD.encode(key.public_key_record_bytes())
    )
}

async fn people(bench: &Bench) -> (String, Person, Person) {
    let domain = bench.domain("alpha").await;
    let jean = bench.person("jean", "alpha", &domain).await;
    let marie = bench.person("marie", "alpha", &domain).await;
    (domain, jean, marie)
}

async fn count(bench: &Bench, query: &str) -> i64 {
    bench
        .value::<i64>(&format!("RETURN array::len({query});"))
        .await
}

/// Messages de la boîte de réception d'une personne (identifiants), par la session système.
async fn messages_in(bench: &Bench, mailbox: &str) -> Vec<String> {
    bench
        .values::<String>(&format!(
            "SELECT VALUE <string> id FROM mail_message WHERE mailbox = {mailbox} ORDER BY uid;"
        ))
        .await
}

async fn stored(bench: &Bench, person: &Person, message: &str) -> String {
    let bytes = bench
        .content
        .read(&person.store, message, None)
        .await
        .expect("lecture");
    String::from_utf8(bytes.to_vec()).expect("texte")
}

#[tokio::test]
async fn a_message_is_received_checked_and_delivered() {
    let bench = bench().await;
    let (_, jean, _) = people(&bench).await;
    let key = DkimSigningKey::Ed25519(Ed25519SigningKey::generate().unwrap());
    let mut options = Options::new();
    options
        .resolver
        .set_txt("s1._domainkey.ailleurs.test", &[&key_record(&key)]);
    let server = serve(&bench, options).await;

    let (mut client, greeting) = Client::connect(&server).await;
    assert_eq!(greeting, "220 mx.alpha.test ESMTP");
    let ehlo = client.cmd("EHLO client.ailleurs.test").await;
    let keywords: Vec<&str> = ehlo.lines().map(|line| &line[4..]).collect();
    assert_eq!(
        keywords,
        [
            "mx.alpha.test",
            "PIPELINING",
            "SIZE 52428800",
            "8BITMIME",
            "SMTPUTF8",
            "ENHANCEDSTATUSCODES",
            "CHUNKING"
        ]
    );
    // Un `Authentication-Results` forgé avec notre `authserv-id` est retiré, un autre gardé
    let body = message(
        "Paul <paul@ailleurs.test>",
        "devis",
        "Bonjour,\r\n.ligne qui commence par un point\r\nCordialement.",
    );
    let forged = format!(
        "Authentication-Results: mx.alpha.test; spf=pass smtp.mailfrom=alpha.test\r\nAuthentication-Results: relais.ailleurs.test; spf=pass\r\n{}",
        sign(&body, &key, "ailleurs.test")
    );
    let reply = client
        .transaction("paul@ailleurs.test", &["jean@alpha.test"], &forged)
        .await;
    assert!(reply.starts_with("250 2.0.0 Ok "), "{reply}");
    assert_eq!(client.cmd("QUIT").await, "221 2.0.0 Bye");
    assert!(client.closed().await);

    let ids = messages_in(&bench, &jean.inbox).await;
    assert_eq!(ids.len(), 1);
    let text = stored(&bench, &jean, &ids[0]).await;
    assert!(text.starts_with("Return-Path: <paul@ailleurs.test>\r\nReceived: from client.ailleurs.test (client.ailleurs.test [127.0.0.1])\r\n\tby mx.alpha.test with ESMTP id "), "{text}");
    assert!(text.contains("Authentication-Results: mx.alpha.test;\r\n\tspf=pass smtp.mailfrom=ailleurs.test;\r\n\tspf=pass smtp.helo=client.ailleurs.test;\r\n\tdkim=pass header.d=ailleurs.test header.s=s1"), "{text}");
    assert!(text.contains("dmarc=pass header.from=ailleurs.test policy.dmarc=reject"));
    assert!(text.contains("iprev=pass policy.iprev=127.0.0.1"));
    assert_eq!(
        text.matches("Authentication-Results: mx.alpha.test")
            .count(),
        1
    );
    assert!(text.contains("Authentication-Results: relais.ailleurs.test; spf=pass"));
    assert!(!text.contains("smtp.mailfrom=alpha.test"));
    // Bourrage retiré, contenu intact
    assert!(text.contains("\r\n.ligne qui commence par un point\r\n"));
    assert!(!text.contains("jean@alpha.test>\r\n\tby"));
    let reception = bench
        .value::<Value>(&format!(
            "RETURN (SELECT VALUE reception FROM ONLY {} );",
            ids[0]
        ))
        .await;
    let reception = format!("{reception:?}");
    for expected in ["pass", "not_scanned", "none"] {
        assert!(reception.contains(expected), "{reception}");
    }
    assert_eq!(
        count(
            &bench,
            "(SELECT VALUE id FROM event_outbox WHERE event_type = 'mail.message.received')"
        )
        .await,
        1
    );
    let snapshot = server.handler.snapshot();
    assert_eq!(snapshot["messages_accepted"], 1);
    assert_eq!(snapshot["recipients_accepted"], 1);
    assert_eq!(snapshot["dkim.pass"], 1);
    assert_eq!(snapshot["dmarc.pass"], 1);
    assert!(snapshot["dns_queries"] > 0);
    assert_eq!(snapshot["sessions"], 1);
}

#[tokio::test]
async fn commands_follow_the_state_machine() {
    let bench = bench().await;
    people(&bench).await;
    let mut options = Options::new();
    options.config.max_errors = 100;
    let server = serve(&bench, options).await;
    let (mut client, _) = Client::connect(&server).await;
    for (command, expected) in [
        ("NOOP", "250 2.0.0"),
        ("HELP", "214 2.0.0"),
        ("RSET", "250 2.0.0"),
        ("MAIL FROM:<paul@ailleurs.test>", "503 5.5.1"),
        ("VRFY jean", "503 5.5.1"),
        ("FOO", "500 5.5.1"),
        ("EHLO [127.0.0.1]", "250-mx.alpha.test"),
        ("RCPT TO:<jean@alpha.test>", "503 5.5.1"),
        ("DATA", "503 5.5.1"),
        ("VRFY jean", "252 2.5.0"),
        ("EXPN liste", "502 5.5.1"),
        ("AUTH PLAIN", "502 5.5.1"),
        ("ETRN alpha.test", "502 5.5.1"),
        ("STARTTLS", "502 5.5.1"),
        ("MAIL FROM:<> BODY=BINARYMIME", "555 5.5.4"),
        ("MAIL FROM:<> RET=FULL", "555 5.5.4"),
        ("MAIL FROM:<> SIZE=999999999999", "552 5.3.4"),
        ("MAIL FROM:<>", "250 2.1.0"),
        ("MAIL FROM:<>", "503 5.5.1"),
        ("DATA", "554 5.5.1"),
        ("RCPT TO:<jean@alpha.test> NOTIFY=NEVER", "555 5.5.4"),
        ("RSET", "250 2.0.0"),
        ("RCPT TO:<jean@alpha.test>", "503 5.5.1"),
        ("HELO mauvais_nom", "501 5.5.4"),
        ("HELO client.ailleurs.test", "250 mx.alpha.test"),
    ] {
        let reply = client.cmd(command).await;
        assert!(reply.starts_with(expected), "{command} : {reply}");
    }
    assert_eq!(client.cmd("QUIT").await, "221 2.0.0 Bye");
    // Trop d'erreurs : fermeture
    let mut options = Options::new();
    options.config.max_errors = 2;
    let strict = serve(&bench, options).await;
    let (mut client, _) = Client::connect(&strict).await;
    assert!(client.cmd("FOO").await.starts_with("500 "));
    assert!(client.cmd("BAR").await.starts_with("500 "));
    let reply = client.reply().await;
    assert_eq!(reply, "421 4.7.0 Too many errors, closing connection");
    assert!(client.closed().await);
}

#[tokio::test]
async fn pipelined_commands_are_answered_in_order_and_bdat_delivers() {
    let bench = bench().await;
    let (_, jean, marie) = people(&bench).await;
    let server = serve(&bench, Options::new()).await;
    let (mut client, _) = Client::connect(&server).await;
    client.cmd("EHLO client.ailleurs.test").await;
    client
        .send(b"MAIL FROM:<paul@ailleurs.test>\r\nRCPT TO:<jean@alpha.test>\r\nRCPT TO:<inconnu@alpha.test>\r\nRCPT TO:<marie@alpha.test>\r\nDATA\r\n")
        .await;
    for expected in ["250 2.1.0", "250 2.1.5", "550 5.1.1", "250 2.1.5", "354 "] {
        let reply = client.reply().await;
        assert!(reply.starts_with(expected), "{expected} : {reply}");
    }
    client
        .send(
            format!(
                "{}.\r\n",
                message("<paul@ailleurs.test>", "groupe", "Corps.")
            )
            .as_bytes(),
        )
        .await;
    assert!(client.reply().await.starts_with("250 2.0.0"));

    // BDAT : deux morceaux, le second avec LAST, commandes groupées
    let text = message("<paul@ailleurs.test>", "morceaux", "Corps en morceaux.");
    let (first, second) = text.split_at(40);
    let mut batch = format!(
        "MAIL FROM:<paul@ailleurs.test>\r\nRCPT TO:<jean@alpha.test>\r\nBDAT {}\r\n{first}",
        first.len()
    )
    .into_bytes();
    batch.extend_from_slice(format!("BDAT {} LAST\r\n{second}", second.len()).as_bytes());
    client.send(&batch).await;
    for expected in [
        "250 2.1.0",
        "250 2.1.5",
        "250 2.0.0 40 octets",
        "250 2.0.0 Ok",
    ] {
        let reply = client.reply().await;
        assert!(reply.starts_with(expected), "{expected} : {reply}");
    }
    // DATA après BDAT, BDAT sans destinataire : refusés, morceau lu et oublié
    client.send(b"BDAT 5 LAST\r\nabcde").await;
    assert!(client.reply().await.starts_with("503 5.5.1"));
    assert!(client.cmd("NOOP").await.starts_with("250 "));
    assert_eq!(messages_in(&bench, &jean.inbox).await.len(), 2);
    assert_eq!(messages_in(&bench, &marie.inbox).await.len(), 1);
    let chunked = stored(&bench, &jean, &messages_in(&bench, &jean.inbox).await[1]).await;
    assert!(chunked.ends_with(&text));
}

#[tokio::test]
async fn recipients_are_refused_without_relaying() {
    let bench = bench().await;
    people(&bench).await;
    let mut options = Options::new();
    options.config.max_recipients = 3;
    let server = serve(&bench, options).await;
    let (mut client, _) = Client::connect(&server).await;
    client.cmd("EHLO client.ailleurs.test").await;
    client.cmd("MAIL FROM:<paul@ailleurs.test>").await;
    for (recipient, expected) in [
        ("<x@ailleurs.test>", "550 5.7.1"),
        ("<jean%ailleurs.test@alpha.test>", "550 5.1.1"),
        ("<@relais.test,@autre.test:jean@alpha.test>", "550 5.7.1"),
        ("<jean@[127.0.0.1]>", "550 5.7.1"),
        ("<jéan@alpha.test>", "553 5.6.7"),
        ("<Jean+Devis@ALPHA.test>", "250 2.1.5"),
        ("<Postmaster>", "550 5.1.1"),
    ] {
        let reply = client.cmd(&format!("RCPT TO:{recipient}")).await;
        assert!(reply.starts_with(expected), "{recipient} : {reply}");
    }
    client.cmd("RSET").await;
    client.cmd("MAIL FROM:<paul@ailleurs.test> SMTPUTF8").await;
    // Partie locale UTF-8 : aucune adresse de Lyxal (ASCII) ne peut correspondre
    assert!(client
        .cmd("RCPT TO:<jéan@alpha.test>")
        .await
        .starts_with("550 5.1.1"));
    for _ in 0..3 {
        assert!(client
            .cmd("RCPT TO:<jean@alpha.test>")
            .await
            .starts_with("250 "));
    }
    assert!(client
        .cmd("RCPT TO:<marie@alpha.test>")
        .await
        .starts_with("452 4.5.3"));
    let snapshot = server.handler.snapshot();
    assert_eq!(snapshot["recipients_refused.relay"], 3);
    assert_eq!(snapshot["recipients_refused.unknown"], 3);
    // Aucun relais : rien n'a été remis ni réexpédié
    assert_eq!(
        count(&bench, "(SELECT VALUE id FROM mail_message)").await,
        0
    );
}

#[tokio::test]
async fn smuggling_and_data_before_354_are_refused() {
    let bench = bench().await;
    let (_, jean, _) = people(&bench).await;
    let server = serve(&bench, Options::new()).await;
    let (mut client, _) = Client::connect(&server).await;
    client.cmd("EHLO client.ailleurs.test").await;
    for variant in ["\n.\n", "\n.\r\n", "\r.\r", "\r\n.\r", "\r\n\0.\r\n"] {
        client.cmd("MAIL FROM:<paul@ailleurs.test>").await;
        client.cmd("RCPT TO:<jean@alpha.test>").await;
        assert!(client.cmd("DATA").await.starts_with("354"));
        client
            .send(
                format!(
                    "From: <paul@ailleurs.test>\r\nSubject: x\r\n\r\nA{variant}MAIL FROM:<x@ailleurs.test>\r\n.\r\n"
                )
                .as_bytes(),
            )
            .await;
        let reply = client.reply().await;
        assert!(
            reply.starts_with("500 5.5.2") || reply.starts_with("554 5.6.0"),
            "{variant:?} : {reply}"
        );
        // La session continue, le flux est resté synchronisé
        assert!(client.cmd("NOOP").await.starts_with("250 "));
    }
    assert!(messages_in(&bench, &jean.inbox).await.is_empty());
    assert!(server.handler.snapshot()["messages_refused.smuggling"] >= 4);

    // Données envoyées avant la réponse 354 : refus et fermeture
    let (mut client, _) = Client::connect(&server).await;
    client.cmd("EHLO client.ailleurs.test").await;
    client
        .send(b"MAIL FROM:<paul@ailleurs.test>\r\nRCPT TO:<jean@alpha.test>\r\nDATA\r\nFrom: x\r\n")
        .await;
    assert!(client.reply().await.starts_with("250"));
    assert!(client.reply().await.starts_with("250"));
    assert!(client.reply().await.starts_with("554 5.5.0"));
    assert!(client.closed().await);
}

#[tokio::test]
async fn dmarc_policy_rejects_quarantines_or_reports() {
    let bench = bench().await;
    let (_, jean, _) = people(&bench).await;
    let key = DkimSigningKey::Ed25519(Ed25519SigningKey::generate().unwrap());
    let mut options = Options::new();
    options
        .resolver
        .set_txt("_dmarc.alpha.test", &["v=DMARC1; p=reject"])
        .set_txt("_dmarc.beta.test", &["v=DMARC1; p=quarantine"])
        .set_txt("s1._domainkey.ailleurs.test", &[&key_record(&key)]);
    let server = serve(&bench, options).await;
    let (mut client, _) = Client::connect(&server).await;
    client.cmd("EHLO client.ailleurs.test").await;

    // Notre domaine en `p=reject`, écrit depuis une adresse étrangère sans DKIM : refus
    let spoofed = message(
        "Patron <patron@alpha.test>",
        "virement",
        "Faites le virement.",
    );
    let reply = client
        .transaction("paul@ailleurs.test", &["jean@alpha.test"], &spoofed)
        .await;
    assert!(reply.starts_with("550 5.7.1"), "{reply}");
    // Signature DKIM valide, mais d'un autre domaine que l'auteur : DMARC échoue
    let signed = sign(
        &message(
            "Patron <patron@alpha.test>",
            "virement2",
            "Faites le virement.",
        ),
        &key,
        "ailleurs.test",
    );
    let reply = client
        .transaction("paul@ailleurs.test", &["jean@alpha.test"], &signed)
        .await;
    assert!(reply.starts_with("550 5.7.1"), "{reply}");
    // Plusieurs domaines d'auteur dans un seul From : le plus sévère l'emporte
    let both = message(
        "paul@ailleurs.test, patron@alpha.test",
        "deux-auteurs",
        "Corps.",
    );
    let reply = client
        .transaction("paul@ailleurs.test", &["jean@alpha.test"], &both)
        .await;
    assert!(reply.starts_with("550 5.7.1"), "{reply}");
    // Plus de 10 domaines d'auteur : refus, aucun domaine n'échappe à DMARC
    let authors = (0..11)
        .map(|index| format!("a@d{index}.test"))
        .collect::<Vec<_>>()
        .join(", ");
    let crowded = message(&authors, "onze-auteurs", "Corps.");
    let reply = client
        .transaction("paul@ailleurs.test", &["jean@alpha.test"], &crowded)
        .await;
    assert!(reply.starts_with("550 5.7.1"), "{reply}");
    // Plusieurs champs From : refus
    let double = format!(
        "From: <autre@ailleurs.test>\r\n{}",
        message("<paul@ailleurs.test>", "double", "Corps.")
    );
    let reply = client
        .transaction("paul@ailleurs.test", &["jean@alpha.test"], &double)
        .await;
    assert!(reply.starts_with("550 5.6.0"), "{reply}");
    // Sans From : refus
    let reply = client
        .transaction(
            "paul@ailleurs.test",
            &["jean@alpha.test"],
            "Subject: sans auteur\r\n\r\nCorps.\r\n",
        )
        .await;
    assert!(reply.starts_with("550 5.6.0"), "{reply}");
    // Quarantaine : dossier « Junk »
    let quarantined = message("<qui@beta.test>", "promo", "Offre.");
    let reply = client
        .transaction("qui@beta.test", &["jean@alpha.test"], &quarantined)
        .await;
    assert!(reply.starts_with("250 2.0.0"), "{reply}");
    assert!(messages_in(&bench, &jean.inbox).await.is_empty());
    let junk = bench
        .value::<String>(&format!(
            "RETURN <string> (SELECT VALUE id FROM ONLY mail_mailbox WHERE account = {} AND role = 'junk' LIMIT 1);",
            jean.account
        ))
        .await;
    assert_eq!(messages_in(&bench, &junk).await.len(), 1);
    // Boucle : plus de 50 en-têtes Received
    let looped = format!(
        "{}{}",
        "Received: from a by b; Tue, 3 Nov 2026 10:00:00 +0100\r\n".repeat(51),
        message("<paul@ailleurs.test>", "boucle", "Corps.")
    );
    let reply = client
        .transaction("paul@ailleurs.test", &["jean@alpha.test"], &looped)
        .await;
    assert!(reply.starts_with("554 5.4.6"), "{reply}");
    assert_eq!(server.handler.snapshot()["messages_refused.dmarc"], 3);

    // Mise en service progressive : DMARC sans effet
    let mut options = Options::new();
    options
        .resolver
        .set_txt("_dmarc.alpha.test", &["v=DMARC1; p=reject"]);
    options.config.dmarc_enforce = false;
    let lenient = serve(&bench, options).await;
    let (mut client, _) = Client::connect(&lenient).await;
    client.cmd("EHLO client.ailleurs.test").await;
    let reply = client
        .transaction(
            "paul@ailleurs.test",
            &["jean@alpha.test"],
            &message("<patron@alpha.test>", "souple", "Corps."),
        )
        .await;
    assert!(reply.starts_with("250 2.0.0"), "{reply}");
    let ids = messages_in(&bench, &jean.inbox).await;
    assert_eq!(ids.len(), 1);
    assert!(stored(&bench, &jean, &ids[0])
        .await
        .contains("dmarc=fail header.from=alpha.test policy.dmarc=reject"));
}

#[tokio::test]
async fn antivirus_and_partial_failures_answer_once() {
    let bench = bench().await;
    let (domain, jean, marie) = people(&bench).await;
    let mut options = Options::new();
    options.scanner = Some(Arc::new(FakeScanner { available: true }));
    let server = serve(&bench, options).await;
    let (mut client, _) = Client::connect(&server).await;
    client.cmd("EHLO client.ailleurs.test").await;
    let infected = message(
        "<paul@ailleurs.test>",
        "eicar",
        "X5O!P%@AP[4\\PZX54(P^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H*",
    );
    let reply = client
        .transaction("paul@ailleurs.test", &["jean@alpha.test"], &infected)
        .await;
    assert!(reply.starts_with("554 5.7.1"), "{reply}");
    assert_eq!(
        count(&bench, "(SELECT VALUE id FROM storage_object)").await,
        0
    );

    // Alias vers jean et marie, plus jean directement : une copie par compte
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
    // Quota de marie plus petit que le message : accepté à `RCPT TO`, refusé au dépôt
    bench
        .system
        .account_update(AccountUpdateParams {
            account: marie.account.clone(),
            state: None,
            quota_bytes: Some(100),
            clear: Vec::new(),
        })
        .await
        .expect("quota");
    let clean = message("<paul@ailleurs.test>", "partiel", &"Corps. ".repeat(40));
    let reply = client
        .transaction(
            "paul@ailleurs.test",
            &["equipe@alpha.test", "jean@alpha.test"],
            &clean,
        )
        .await;
    assert!(reply.starts_with("451 4.3.0"), "{reply}");
    assert_eq!(messages_in(&bench, &jean.inbox).await.len(), 1);
    assert!(messages_in(&bench, &marie.inbox).await.is_empty());
    // Nouvel essai de l'expéditeur après le quota relevé, destinataires dans l'ordre inverse :
    // jean n'a pas de doublon (empreinte choisie indépendamment de l'ordre des RCPT TO)
    bench
        .system
        .account_update(AccountUpdateParams {
            account: marie.account.clone(),
            state: None,
            quota_bytes: None,
            clear: vec!["quota_bytes".to_string()],
        })
        .await
        .expect("quota relevé");
    let reply = client
        .transaction(
            "paul@ailleurs.test",
            &["jean@alpha.test", "equipe@alpha.test"],
            &clean,
        )
        .await;
    assert!(reply.starts_with("250 2.0.0"), "{reply}");
    let jean_ids = messages_in(&bench, &jean.inbox).await;
    assert_eq!(jean_ids.len(), 1);
    assert_eq!(messages_in(&bench, &marie.inbox).await.len(), 1);
    assert_eq!(server.handler.snapshot()["duplicates_avoided"], 1);
    assert!(format!(
        "{:?}",
        bench
            .value::<Value>(&format!(
                "RETURN (SELECT VALUE reception.antivirus FROM ONLY {});",
                jean_ids[0]
            ))
            .await
    )
    .contains("clean"));

    // Antivirus injoignable : refus temporaire, rien n'est déposé
    let mut options = Options::new();
    options.scanner = Some(Arc::new(FakeScanner { available: false }));
    let down = serve(&bench, options).await;
    let (mut client, _) = Client::connect(&down).await;
    client.cmd("EHLO client.ailleurs.test").await;
    let reply = client
        .transaction(
            "paul@ailleurs.test",
            &["jean@alpha.test"],
            &message("<paul@ailleurs.test>", "muet", "Corps."),
        )
        .await;
    assert!(reply.starts_with("451 4.3.0"), "{reply}");
    assert_eq!(messages_in(&bench, &jean.inbox).await.len(), 1);
}

#[tokio::test]
async fn limits_close_or_defer_the_session() {
    let bench = bench().await;
    people(&bench).await;
    let mut options = Options::new();
    options.config.max_messages_per_session = 1;
    options.config.max_message_bytes = 1 << 20;
    let server = serve(&bench, options).await;
    let (mut client, _) = Client::connect(&server).await;
    client.cmd("EHLO client.ailleurs.test").await;
    // Message plus grand que la limite : lu jusqu'au bout sans être gardé, puis refusé
    let big = message(
        "<paul@ailleurs.test>",
        "gros",
        &"x".repeat(998).repeat(1_100),
    );
    let reply = client
        .transaction("paul@ailleurs.test", &["jean@alpha.test"], &big)
        .await;
    assert!(reply.starts_with("552 5.3.4"), "{reply}");
    let reply = client
        .transaction(
            "paul@ailleurs.test",
            &["jean@alpha.test"],
            &message("<paul@ailleurs.test>", "petit", "Corps."),
        )
        .await;
    assert!(reply.starts_with("250 2.0.0"), "{reply}");
    let reply = client.cmd("MAIL FROM:<paul@ailleurs.test>").await;
    assert!(reply.starts_with("421 4.7.0"), "{reply}");
    assert!(client.closed().await);

    // Cadence par réseau
    let mut options = Options::new();
    options.config.messages_per_network_per_minute = [1, 10, 10];
    let rated = serve(&bench, options).await;
    let (mut client, _) = Client::connect(&rated).await;
    client.cmd("EHLO client.ailleurs.test").await;
    assert!(client
        .cmd("MAIL FROM:<paul@ailleurs.test>")
        .await
        .starts_with("250"));
    client.cmd("RSET").await;
    assert!(client
        .cmd("MAIL FROM:<paul@ailleurs.test>")
        .await
        .starts_with("450 4.7.1"));
}

#[tokio::test]
async fn repeated_errors_ban_the_address_for_the_installation() {
    let bench = bench().await;
    people(&bench).await;
    let mut options = Options::new();
    options.config.max_errors = 1;
    let server = serve(&bench, options).await;
    for _ in 0..3 {
        let (mut client, _) = Client::connect(&server).await;
        assert!(client.cmd("FOO").await.starts_with("500 "));
        let reply = client.reply().await;
        assert!(reply.contains("421 4.7.0"), "{reply}");
        assert!(client.closed().await);
    }
    assert!(server.handler.blocks().contains(LOCALHOST.parse().unwrap()));
    let active = bench
        .system
        .block_active(BlockActiveParams::default())
        .await
        .expect("liste");
    assert_eq!(active.networks, ["127.0.0.1/32"]);
    let reason = bench
        .value::<String>("RETURN (SELECT VALUE reason FROM ONLY mail_network_block LIMIT 1);")
        .await;
    assert_eq!(reason, "errors");
    // Un second nœud relit la liste de l'installation
    let other = BlockList::new();
    other.refresh(&bench.system).await.expect("relecture");
    assert!(other.contains(LOCALHOST.parse().unwrap()));
    assert_eq!(server.handler.snapshot()["bans_written"], 1);
}

#[tokio::test]
async fn address_harvesting_is_slowed_then_closed() {
    let bench = bench().await;
    people(&bench).await;
    let server = serve(&bench, Options::new()).await;
    let (mut client, _) = Client::connect(&server).await;
    client.cmd("EHLO client.ailleurs.test").await;
    client.cmd("MAIL FROM:<paul@ailleurs.test>").await;
    let started = Instant::now();
    let mut last = String::new();
    for index in 0..20 {
        last = client
            .cmd(&format!("RCPT TO:<essai{index}@alpha.test>"))
            .await;
    }
    assert!(last.starts_with("421 4.7.0"), "{last}");
    assert!(client.closed().await);
    // Retard d'une seconde du 5ᵉ au 19ᵉ refus
    assert!(started.elapsed() >= Duration::from_secs(15));
    assert_eq!(server.handler.snapshot()["recipients_refused.unknown"], 20);
}

#[tokio::test]
async fn starttls_resets_the_session_and_refuses_injection() {
    let bench = bench().await;
    let (_, jean, _) = people(&bench).await;
    let mut options = Options::new();
    options.starttls = true;
    let server = serve(&bench, options).await;

    // Commandes envoyées en clair derrière STARTTLS : fermeture
    let (mut client, _) = Client::connect(&server).await;
    assert!(client
        .cmd("EHLO client.ailleurs.test")
        .await
        .contains("250-STARTTLS"));
    client
        .send(b"STARTTLS\r\nMAIL FROM:<paul@ailleurs.test>\r\n")
        .await;
    assert!(client.reply().await.starts_with("220 2.0.0"));
    assert!(client.closed().await);

    let (mut client, _) = Client::connect(&server).await;
    client.cmd("EHLO client.ailleurs.test").await;
    assert!(client.cmd("STARTTLS").await.starts_with("220 2.0.0"));
    // État remis à zéro (RFC 3207 §4.2), STARTTLS plus annoncé
    assert!(client
        .cmd("MAIL FROM:<paul@ailleurs.test>")
        .await
        .starts_with("503 5.5.1"));
    let ehlo = client.cmd("EHLO client.ailleurs.test").await;
    assert!(!ehlo.contains("STARTTLS"), "{ehlo}");
    let reply = client
        .transaction(
            "paul@ailleurs.test",
            &["jean@alpha.test"],
            &message("<paul@ailleurs.test>", "chiffre", "Corps."),
        )
        .await;
    assert!(reply.starts_with("250 2.0.0"), "{reply}");
    let ids = messages_in(&bench, &jean.inbox).await;
    let text = stored(&bench, &jean, &ids[0]).await;
    assert!(text.contains("with ESMTPS id "), "{text}");
    assert!(text.contains("(version=TLSv1_3 cipher=TLS13_AES_128_GCM_SHA256)"));
    assert!(format!(
        "{:?}",
        bench
            .value::<Value>(&format!(
                "RETURN (SELECT VALUE reception.tls FROM ONLY {});",
                ids[0]
            ))
            .await
    )
    .contains("true"));
}

#[tokio::test]
async fn reception_headers_past_the_organisation_size_are_refused_permanently() {
    let bench = bench().await;
    let (_, jean, _) = people(&bench).await;
    bench
        .system
        .settings_set(SettingsSetParams {
            tenant: Some("auth_organization:alpha".to_string()),
            max_message_bytes: Some(2_048),
            ..SettingsSetParams::default()
        })
        .await
        .expect("taille de l'organisation");
    let server = serve(&bench, Options::new()).await;
    let (mut client, _) = Client::connect(&server).await;
    client.cmd("EHLO client.ailleurs.test").await;
    // Juste sous la taille de l'organisation à la fin des données, au-delà une fois nos
    // en-têtes ajoutés : refus définitif, jamais un `451` qui ferait réessayer sans fin
    let mut text = message("<paul@ailleurs.test>", "limite", "");
    while text.len() < 1_990 {
        text.push_str("Ligne de remplissage du message.\r\n");
    }
    assert!(text.len() <= 2_048);
    let reply = client
        .transaction("paul@ailleurs.test", &["jean@alpha.test"], &text)
        .await;
    assert!(reply.starts_with("552 5.3.4"), "{reply}");
    assert!(messages_in(&bench, &jean.inbox).await.is_empty());
    assert_eq!(server.handler.snapshot()["messages_refused.size"], 1);
}
