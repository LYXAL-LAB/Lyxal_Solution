// SPDX-License-Identifier: AGPL-3.0-only

//! Worker d'envoi de bout en bout (sous-lot 6d) contre un **faux MX** : serveur SMTP d'essai
//! scripté sur une vraie socket locale (réponses programmables par destinataire, `PIPELINING`,
//! `STARTTLS` par un TLS d'essai sans chiffrement : le vrai TLS est essayé par l'hôte, seul
//! détenteur de `tokio-rustls`). Signature DKIM vérifiée par notre propre vérificateur (lot 5),
//! refus temporaire puis nouvel essai, refus définitif et avis dans la boîte de l'expéditeur,
//! MX nul, arrêt brutal puis reprise sans perte, route locale entre deux organisations. Aucun
//! service réel : résolveur `StaticResolver`, base embarquée.

use async_trait::async_trait;
use bytes::Bytes;
use lyxal_crypto::{EncryptionKey, KeyId, ResolvedKey, TlsPeerInfo, TlsServerVerification};
use lyxal_mail::auth::{DkimResult, DkimVerifier, EmbeddedSuffixList};
use lyxal_mail::dkim::{DkimKeyCache, DkimProvisioner};
use lyxal_mail::dns::{MailResolver, StaticResolver};
use lyxal_mail::models::{
    DkimPendingParams, DomainUpdateParams, DsnNotify, RecipientState, SubmissionBeginParams,
    SubmissionCommitParams, SubmissionOrigin, SubmissionRecipient, SubmissionRefParams,
};
use lyxal_mail::net::{BoxedStream, NetError};
use lyxal_mail::outbound::{
    OutboundConfig, OutboundDispatcher, OutboundServices, TlsConnectorProvider,
};
use lyxal_mail::{DeliveryPipeline, MailStore, MAIL_BUCKET};
use lyxal_runtime::worker::{CancellationToken, LyxalWorker, WorkerContext};
use lyxal_runtime::ModuleContext;
use lyxal_secrets::{MasterKeys, SecretsClient, SecretsStore};
use lyxal_storage::models::BucketCreateParams;
use lyxal_storage::PutRequest;
use lyxal_surreal::ToSql;
use std::collections::HashMap;
use std::convert::Infallible;
use std::net::IpAddr;
use std::sync::{Arc, Mutex};
use std::time::Duration;
use tokio::io::{AsyncReadExt, AsyncWriteExt};
use tokio::net::TcpListener;
use tokio::task::JoinSet;

use crate::support::{bench, token, Bench};

// ------------------------------------------------------------------------------------------
// Faux MX
// ------------------------------------------------------------------------------------------

/// Réponse programmée du faux MX à un `RCPT TO` (par partie locale du destinataire).
#[derive(Clone)]
enum RcptRule {
    Accept,
    /// Refus temporaire `n` fois, puis accepté.
    TempFail(u32),
    Reject,
}

/// Comportement du faux MX.
#[derive(Clone)]
struct MxScript {
    pipelining: bool,
    starttls: bool,
    dsn: bool,
    rules: HashMap<String, RcptRule>,
    /// Ne répond jamais à la fin des données (arrêt brutal pendant l'envoi).
    hang_on_data: bool,
}

impl Default for MxScript {
    fn default() -> Self {
        Self {
            pipelining: true,
            starttls: false,
            dsn: false,
            rules: HashMap::new(),
            hang_on_data: false,
        }
    }
}

/// Ce que le faux MX a reçu.
#[derive(Default)]
struct MxLog {
    /// Messages reçus : (expéditeur, destinataires, octets après bourrage retiré).
    messages: Vec<(String, Vec<String>, Vec<u8>)>,
    /// Lots de commandes reçus en une lecture contenant `MAIL`, `RCPT` et `DATA`.
    pipelined_batches: usize,
    starttls: usize,
    connections: usize,
    temp_counts: HashMap<String, u32>,
}

struct FakeMx {
    port: u16,
    log: Arc<Mutex<MxLog>>,
    script: Arc<Mutex<MxScript>>,
    _tasks: JoinSet<()>,
}

impl FakeMx {
    async fn start(script: MxScript) -> Self {
        let listener = TcpListener::bind("127.0.0.1:0").await.unwrap();
        let port = listener.local_addr().unwrap().port();
        let log = Arc::new(Mutex::new(MxLog::default()));
        let script = Arc::new(Mutex::new(script));
        let mut tasks = JoinSet::new();
        let (l, s) = (log.clone(), script.clone());
        tasks.spawn(async move {
            let mut sessions = JoinSet::new();
            while let Ok((stream, _)) = listener.accept().await {
                let (l, s) = (l.clone(), s.clone());
                sessions.spawn(async move { session(stream, l, s).await });
            }
        });
        Self {
            port,
            log,
            script,
            _tasks: tasks,
        }
    }

    fn messages(&self) -> Vec<(String, Vec<String>, Vec<u8>)> {
        self.log.lock().unwrap().messages.clone()
    }
}

async fn session(
    mut stream: tokio::net::TcpStream,
    log: Arc<Mutex<MxLog>>,
    script: Arc<Mutex<MxScript>>,
) {
    log.lock().unwrap().connections += 1;
    let _ = stream
        .write_all(b"220 mx.ailleurs.test ESMTP faux\r\n")
        .await;
    let mut buffer: Vec<u8> = Vec::new();
    let mut from = String::new();
    let mut recipients: Vec<String> = Vec::new();
    let mut data = false;
    let mut message: Vec<u8> = Vec::new();
    loop {
        let mut chunk = [0u8; 16 * 1024];
        let read = match stream.read(&mut chunk).await {
            Ok(0) | Err(_) => return,
            Ok(read) => read,
        };
        buffer.extend_from_slice(&chunk[..read]);
        if !data {
            let text = String::from_utf8_lossy(&buffer).to_string();
            if text.contains("MAIL FROM") && text.contains("RCPT TO") && text.contains("DATA\r\n") {
                log.lock().unwrap().pipelined_batches += 1;
            }
        }
        let mut replies = String::new();
        loop {
            if data {
                if let Some(end) = find(&buffer, b"\r\n.\r\n") {
                    message.extend_from_slice(&buffer[..end + 2]);
                    buffer.drain(..end + 5);
                    data = false;
                    let hang = script.lock().unwrap().hang_on_data;
                    if hang {
                        tokio::time::sleep(Duration::from_secs(3600)).await;
                        return;
                    }
                    let unstuffed = unstuff(&message);
                    log.lock().unwrap().messages.push((
                        from.clone(),
                        recipients.clone(),
                        unstuffed,
                    ));
                    message.clear();
                    replies.push_str("250 2.0.0 queued\r\n");
                    continue;
                }
                break;
            }
            let Some(end) = find(&buffer, b"\r\n") else {
                break;
            };
            let line = String::from_utf8_lossy(&buffer[..end]).to_string();
            buffer.drain(..end + 2);
            let upper = line.to_ascii_uppercase();
            let s = script.lock().unwrap().clone();
            if upper.starts_with("EHLO") {
                replies.push_str("250-mx.ailleurs.test\r\n");
                if s.pipelining {
                    replies.push_str("250-PIPELINING\r\n");
                }
                if s.starttls {
                    replies.push_str("250-STARTTLS\r\n");
                }
                if s.dsn {
                    replies.push_str("250-DSN\r\n");
                }
                replies
                    .push_str("250-8BITMIME\r\n250-SIZE 10000000\r\n250 ENHANCEDSTATUSCODES\r\n");
            } else if upper.starts_with("STARTTLS") {
                log.lock().unwrap().starttls += 1;
                replies.push_str("220 2.0.0 go ahead\r\n");
            } else if upper.starts_with("MAIL FROM:") {
                from = line[10..].split(' ').next().unwrap_or_default().to_string();
                recipients.clear();
                replies.push_str("250 2.1.0 ok\r\n");
            } else if upper.starts_with("RCPT TO:") {
                let address = line[8..]
                    .split(' ')
                    .next()
                    .unwrap_or_default()
                    .trim_matches(['<', '>'])
                    .to_string();
                let local = address.split('@').next().unwrap_or_default().to_string();
                match s.rules.get(&local).cloned().unwrap_or(RcptRule::Accept) {
                    RcptRule::Accept => {
                        recipients.push(address);
                        replies.push_str("250 2.1.5 ok\r\n");
                    }
                    RcptRule::Reject => replies.push_str("550 5.1.1 no such user\r\n"),
                    RcptRule::TempFail(times) => {
                        let mut guard = log.lock().unwrap();
                        let count = guard.temp_counts.entry(local).or_insert(0);
                        if *count < times {
                            *count += 1;
                            replies.push_str("450 4.2.0 try again later\r\n");
                        } else {
                            recipients.push(address);
                            replies.push_str("250 2.1.5 ok\r\n");
                        }
                    }
                }
            } else if upper.starts_with("DATA") {
                if recipients.is_empty() {
                    replies.push_str("554 5.5.1 no valid recipients\r\n");
                } else {
                    data = true;
                    replies.push_str("354 go\r\n");
                }
            } else if upper.starts_with("RSET") {
                recipients.clear();
                replies.push_str("250 2.0.0 ok\r\n");
            } else if upper.starts_with("QUIT") {
                let _ = stream.write_all(b"221 2.0.0 bye\r\n").await;
                return;
            } else {
                replies.push_str("500 5.5.1 unknown\r\n");
            }
        }
        if !replies.is_empty() && stream.write_all(replies.as_bytes()).await.is_err() {
            return;
        }
    }
}

fn find(haystack: &[u8], needle: &[u8]) -> Option<usize> {
    haystack
        .windows(needle.len())
        .position(|window| window == needle)
}

/// Retire le bourrage du point (`..` en début de ligne).
fn unstuff(data: &[u8]) -> Vec<u8> {
    let mut out = Vec::with_capacity(data.len());
    let mut start = true;
    let mut index = 0;
    while index < data.len() {
        if start && data[index] == b'.' {
            index += 1;
        }
        let byte = data[index];
        out.push(byte);
        start = byte == b'\n';
        index += 1;
    }
    out
}

/// TLS d'essai : aucune poignée de main, flux rendu tel quel (le vrai TLS est essayé par
/// l'hôte) ; `fail` simule une poignée de main ratée.
struct TestTls {
    fail: bool,
}

#[async_trait]
impl TlsConnectorProvider for TestTls {
    async fn connect(
        &self,
        stream: BoxedStream,
        _server_name: &str,
        verification: TlsServerVerification,
        _timeout: Duration,
    ) -> Result<(BoxedStream, TlsPeerInfo), NetError> {
        if self.fail {
            return Err(NetError::TlsHandshake("essai".into()));
        }
        Ok((
            stream,
            TlsPeerInfo {
                version: "TLSv1.3",
                cipher_suite: "TLS13_AES_128_GCM_SHA256",
                verified: verification == TlsServerVerification::WebPki,
            },
        ))
    }
}

// ------------------------------------------------------------------------------------------
// Banc de l'envoi
// ------------------------------------------------------------------------------------------

const MESSAGE: &str = "From: Alpha <noreply@alpha.test>\r\n\
To: <paul@ailleurs.test>\r\n\
Subject: =?utf-8?q?Devis_n=C2=B0_42?=\r\n\
Content-Type: text/plain; charset=utf-8\r\n\
\r\n\
Bonjour,\r\n\
.ligne qui commence par un point\r\n\
\r\n\
Cordialement.\r\n";

fn master() -> MasterKeys {
    MasterKeys::from_keys(
        ResolvedKey::new(
            KeyId::parse("vault-dkim").unwrap(),
            Arc::new(EncryptionKey::generate().unwrap()),
        ),
        None,
    )
    .unwrap()
}

struct Outbound {
    bench: Bench,
    domain: String,
    bucket: String,
    secrets: SecretsClient,
    keys: Arc<DkimKeyCache>,
}

async fn outbound() -> Outbound {
    let bench = bench().await;
    let domain = bench.domain("alpha").await;
    bench
        .system
        .domain_update(DomainUpdateParams {
            domain: domain.clone(),
            state: None,
            subaddress_separator: None,
            catch_all: None,
            postmaster: None,
            module_senders: Some(vec!["noreply".into()]),
            backscatter_protection: None,
            clear: Vec::new(),
        })
        .await
        .unwrap();
    let bucket = mail_bucket(&bench, "alpha").await;
    let secrets = SecretsClient::new(
        SecretsStore::new(bench.client.clone()),
        Some(master()),
        lyxal_mail::MODULE_ID,
    );
    Outbound {
        bench,
        domain,
        bucket,
        secrets,
        keys: Arc::new(DkimKeyCache::new()),
    }
}

async fn mail_bucket(bench: &Bench, organization: &str) -> String {
    let mut params = BucketCreateParams::named(
        Some(format!("auth_organization:{organization}")),
        MAIL_BUCKET,
    );
    params.encrypted = true;
    params.emit_events = false;
    bench
        .storage_store
        .bucket_create(params)
        .await
        .unwrap()
        .id
        .to_sql()
}

fn resolver(port_host: &str, domains: &[&str]) -> StaticResolver {
    let mut resolver = StaticResolver::new();
    for domain in domains {
        resolver
            .set_mx(domain, &[(10, port_host)])
            .set_ips(port_host, &["127.0.0.1".parse::<IpAddr>().unwrap()]);
    }
    resolver.set_mx("nul.test", &[(0, ".")]);
    resolver
}

impl Outbound {
    fn worker(
        &self,
        mx: &FakeMx,
        resolver: Arc<dyn MailResolver>,
        tls: Option<Arc<dyn TlsConnectorProvider>>,
    ) -> OutboundDispatcher {
        let mut config = OutboundConfig::new("mx.lyxal.test", "n1");
        config.smtp_port = mx.port;
        config.allow_private_networks = true;
        config.timeouts.data_end = Duration::from_secs(5);
        config.drain_timeout = Duration::from_secs(1);
        config.lease = Duration::from_secs(60);
        OutboundDispatcher::new(
            config,
            OutboundServices {
                store: self.bench.system.clone(),
                storage: self.bench.storage.clone(),
                resolver,
                tls,
                secrets: Some(self.secrets.clone()),
                pipeline: DeliveryPipeline::new(self.bench.ingest.clone()),
                organizational: Arc::new(EmbeddedSuffixList),
                keys: self.keys.clone(),
            },
        )
        .unwrap()
    }

    /// Envoi d'un module (contrat public), clos : identifiant.
    async fn module_send(&self, recipients: &[&str], raw: &str) -> String {
        self.send(
            &self.bench.system,
            SubmissionOrigin::Module,
            "noreply@alpha.test",
            recipients,
            raw,
        )
        .await
    }

    async fn send(
        &self,
        caller: &MailStore,
        origin: SubmissionOrigin,
        from: &str,
        recipients: &[&str],
        raw: &str,
    ) -> String {
        let reserved = caller
            .submission_begin(SubmissionBeginParams {
                origin: Some(origin),
                from: from.to_string(),
                header_from: vec![from.to_string()],
                recipients: recipients
                    .iter()
                    .map(|address| SubmissionRecipient {
                        address: address.to_string(),
                        notify: None,
                        orcpt: None,
                    })
                    .collect(),
                size: raw.len() as i64,
                smtputf8: None,
                eight_bit: None,
                dsn: None,
                client_reference: (origin == SubmissionOrigin::Module)
                    .then(|| "job_42".to_string()),
                return_token: None,
                prefix: None,
                forward: None,
                tenant: None,
            })
            .await
            .expect("dépôt ouvert");
        let content = futures::stream::iter([Ok::<Bytes, Infallible>(Bytes::copy_from_slice(
            raw.as_bytes(),
        ))]);
        let object = self
            .bench
            .storage
            .put(
                PutRequest {
                    bucket: self.bucket.clone(),
                    key: reserved.key.clone(),
                    filename: "message.eml".into(),
                    content_type: Some("message/rfc822".into()),
                    size: Some(raw.len() as u64),
                },
                content,
            )
            .await
            .expect("fichier écrit")
            .id
            .to_sql();
        self.bench
            .system
            .submission_commit(SubmissionCommitParams {
                submission: reserved.submission.to_sql(),
                object,
            })
            .await
            .expect("mise en file");
        reserved.submission.to_sql()
    }

    async fn states(&self, submission: &str) -> Vec<(String, RecipientState, Option<String>)> {
        self.bench
            .system
            .submission_get(SubmissionRefParams {
                submission: submission.to_string(),
            })
            .await
            .unwrap()
            .recipients
            .into_iter()
            .map(|r| (r.address, r.state, r.last_result.and_then(|l| l.enhanced)))
            .collect()
    }

    /// Attend que tous les destinataires de l'envoi soient dans un état final.
    async fn wait_final(&self, submission: &str) -> Vec<(String, RecipientState, Option<String>)> {
        self.wait_final_for(submission, 300).await
    }

    async fn wait_final_for(
        &self,
        submission: &str,
        rounds: u32,
    ) -> Vec<(String, RecipientState, Option<String>)> {
        for _ in 0..rounds {
            let states = self.states(submission).await;
            if states.iter().all(|(_, state, _)| {
                !matches!(state, RecipientState::Scheduled | RecipientState::Running)
            }) {
                return states;
            }
            tokio::time::sleep(Duration::from_millis(100)).await;
        }
        panic!("envoi non fini : {:?}", self.states(submission).await);
    }

    /// Clés DKIM créées puis activées (enregistrements publiés dans le résolveur rendu).
    async fn provision(&self, mut resolver: StaticResolver) -> StaticResolver {
        let empty: Arc<dyn MailResolver> = Arc::new(StaticResolver::new());
        let provisioner = DkimProvisioner::new(
            self.bench.system.clone(),
            SecretsStore::new(self.bench.client.clone()),
            self.secrets.clone(),
            empty,
            100,
        );
        let created = provisioner.run().await.expect("clés créées");
        assert_eq!(created.created % 2, 0, "RSA et Ed25519 par domaine");
        assert!(created.created >= 2);
        let pending = self
            .bench
            .system
            .dkim_pending(DkimPendingParams { limit: None })
            .await
            .unwrap();
        assert!(pending.missing.is_empty());
        for key in &pending.pending {
            let k = if key.selector.ends_with('r') {
                "rsa"
            } else {
                "ed25519"
            };
            resolver.set_txt(
                &format!("{}._domainkey.{}", key.selector, key.name),
                &[&format!("v=DKIM1; k={k}; p={}", key.public_key)],
            );
        }
        let published: Arc<dyn MailResolver> = Arc::new(clone_resolver(&pending.pending));
        let activated = DkimProvisioner::new(
            self.bench.system.clone(),
            SecretsStore::new(self.bench.client.clone()),
            self.secrets.clone(),
            published,
            100,
        )
        .run()
        .await
        .unwrap();
        assert_eq!(activated.activated, created.created);
        resolver
    }
}

fn clone_resolver(keys: &[lyxal_mail::models::DkimPendingKey]) -> StaticResolver {
    let mut resolver = StaticResolver::new();
    for key in keys {
        let k = if key.selector.ends_with('r') {
            "rsa"
        } else {
            "ed25519"
        };
        resolver.set_txt(
            &format!("{}._domainkey.{}", key.selector, key.name),
            &[&format!("v=DKIM1; k={k}; p={}", key.public_key)],
        );
    }
    resolver
}

struct Running {
    cancel: CancellationToken,
    tasks: JoinSet<Result<(), lyxal_runtime::RuntimeError>>,
}

fn run(worker: OutboundDispatcher) -> Running {
    let cancel = CancellationToken::new();
    let descriptor = worker.descriptor().clone();
    let ctx = WorkerContext::new(
        descriptor.module_id.clone(),
        descriptor.id.clone(),
        ModuleContext::new(lyxal_mail::MODULE_ID),
        cancel.child_token(),
    );
    let mut tasks = JoinSet::new();
    tasks.spawn(async move { worker.run(ctx).await });
    Running { cancel, tasks }
}

impl Running {
    async fn stop(mut self) {
        self.cancel.cancel();
        while let Some(result) = self.tasks.join_next().await {
            result.unwrap().unwrap();
        }
    }

    /// Arrêt brutal : la tâche est abandonnée sans rien écrire ni rendre.
    async fn kill(mut self) {
        self.tasks.abort_all();
        while self.tasks.join_next().await.is_some() {}
    }
}

// ------------------------------------------------------------------------------------------
// Essais
// ------------------------------------------------------------------------------------------

#[tokio::test]
async fn a_signed_message_is_delivered_to_the_fake_mx_with_pipelining() {
    let out = outbound().await;
    let mx = FakeMx::start(MxScript::default()).await;
    let resolver = out
        .provision(resolver("mx.ailleurs.test", &["ailleurs.test"]))
        .await;
    let resolver: Arc<dyn MailResolver> = Arc::new(resolver);
    let submission = out
        .module_send(&["paul@ailleurs.test", "anne@ailleurs.test"], MESSAGE)
        .await;
    let running = run(out.worker(&mx, resolver.clone(), None));
    let states = out.wait_final(&submission).await;
    running.stop().await;
    assert!(
        states
            .iter()
            .all(|(_, state, _)| *state == RecipientState::Delivered),
        "{states:?}"
    );

    let messages = mx.messages();
    assert_eq!(
        messages.len(),
        1,
        "une transaction pour les deux destinataires du domaine"
    );
    let (from, recipients, bytes) = &messages[0];
    assert!(
        from.starts_with("<rp=") && from.ends_with("@alpha.test>"),
        "adresse de retour à jeton"
    );
    assert_eq!(recipients.len(), 2);
    assert!(
        mx.log.lock().unwrap().pipelined_batches >= 1,
        "MAIL, RCPT et DATA en une écriture"
    );
    let text = String::from_utf8_lossy(bytes);
    assert_eq!(text.matches("DKIM-Signature:").count(), 2, "RSA et Ed25519");
    assert!(
        text.ends_with(MESSAGE),
        "fichier transmis à l'identique, point du corps rendu"
    );
    assert!(text.contains("Message-ID: <"), "Message-ID ajouté");
    assert!(text.contains("Date: "), "Date ajoutée");

    // Notre propre vérificateur (lot 5) : les deux signatures passent
    let outputs = DkimVerifier::new(resolver.as_ref()).verify(bytes).await;
    assert_eq!(outputs.len(), 2);
    assert!(
        outputs.iter().all(|o| o.result == DkimResult::Pass),
        "{outputs:?}"
    );
    // Un en-tête sur-signé ajouté en chemin casse la signature
    let mut tampered = b"Subject: autre\r\n".to_vec();
    tampered.extend_from_slice(bytes);
    let outputs = DkimVerifier::new(resolver.as_ref()).verify(&tampered).await;
    assert!(
        outputs.iter().all(|o| o.result == DkimResult::Fail),
        "{outputs:?}"
    );
}

#[tokio::test]
async fn starttls_is_used_when_offered_and_a_failed_handshake_falls_back_to_plain() {
    let out = outbound().await;
    let mx = FakeMx::start(MxScript {
        starttls: true,
        pipelining: false,
        ..MxScript::default()
    })
    .await;
    let resolver: Arc<dyn MailResolver> =
        Arc::new(resolver("mx.ailleurs.test", &["ailleurs.test"]));
    let first = out.module_send(&["paul@ailleurs.test"], MESSAGE).await;
    let running = run(out.worker(
        &mx,
        resolver.clone(),
        Some(Arc::new(TestTls { fail: false })),
    ));
    out.wait_final(&first).await;
    running.stop().await;
    assert_eq!(mx.log.lock().unwrap().starttls, 1);
    assert_eq!(
        mx.log.lock().unwrap().pipelined_batches,
        0,
        "sans PIPELINING : une commande à la fois"
    );
    let tls = out
        .bench
        .system
        .submission_get(SubmissionRefParams {
            submission: first.clone(),
        })
        .await
        .unwrap()
        .recipients[0]
        .last_result
        .clone()
        .and_then(|r| r.tls)
        .expect("TLS noté");
    assert_eq!(
        (tls.version.as_deref(), tls.verified),
        (Some("TLSv1.3"), false)
    );

    // Poignée de main ratée : une reconnexion en clair au même hôte
    let second = out.module_send(&["anne@ailleurs.test"], MESSAGE).await;
    let worker = out.worker(&mx, resolver, Some(Arc::new(TestTls { fail: true })));
    let metrics = worker.metrics();
    let running = run(worker);
    let states = out.wait_final(&second).await;
    running.stop().await;
    assert_eq!(states[0].1, RecipientState::Delivered);
    assert_eq!(metrics.snapshot()["tls_fallbacks"], 1);
    assert_eq!(mx.messages().len(), 2);
}

#[tokio::test]
async fn temporary_refusal_is_retried_and_permanent_refusal_deposits_a_dsn_in_the_sender_inbox() {
    let _ = tracing_subscriber::fmt().with_test_writer().try_init();
    let out = outbound().await;
    let jean = out.bench.person("jean", "alpha", &out.domain).await;
    let user = out.bench.client.clone();
    user.authenticate(token(
        "auth_session:jean",
        &["mail.mailbox.access", "mail.send"],
    ))
    .await
    .unwrap();
    let jean_sends = MailStore::new(user);
    let mut rules = HashMap::new();
    rules.insert("lent".to_string(), RcptRule::TempFail(1));
    rules.insert("absent".to_string(), RcptRule::Reject);
    let mx = FakeMx::start(MxScript {
        rules,
        ..MxScript::default()
    })
    .await;
    let resolver: Arc<dyn MailResolver> =
        Arc::new(resolver("mx.ailleurs.test", &["ailleurs.test"]));
    let raw = MESSAGE.replace("noreply@alpha.test", "jean@alpha.test");
    let submission = out
        .send(
            &jean_sends,
            SubmissionOrigin::Submission,
            "jean@alpha.test",
            &["lent@ailleurs.test", "absent@ailleurs.test"],
            &raw,
        )
        .await;
    let worker = out.worker(&mx, resolver, None);
    let waker = worker.waker();
    let running = run(worker);
    // Premier passage : refus temporaire de lent, refus définitif d'absent
    for _ in 0..100 {
        let states = out.states(&submission).await;
        if states.iter().any(|(_, s, _)| *s == RecipientState::Failed)
            && states
                .iter()
                .any(|(_, s, _)| *s == RecipientState::Scheduled)
        {
            break;
        }
        tokio::time::sleep(Duration::from_millis(100)).await;
    }
    let states = out.states(&submission).await;
    assert_eq!(states[1].1, RecipientState::Failed);
    assert_eq!(states[1].2.as_deref(), Some("5.1.1"));
    // Échéance du nouvel essai avancée (5 min en vrai), puis réveil
    out.bench
        .run(&format!(
            "UPDATE mail_queue_recipient SET next_attempt_at = time::now() WHERE submission = {submission} AND state = 'scheduled';"
        ))
        .await;
    waker.notify_one();
    let states = out.wait_final(&submission).await;
    running.stop().await;
    assert_eq!(states[0].1, RecipientState::Delivered);

    // Avis de non-remise dans la boîte de réception de jean, jamais sur Internet
    assert!(mx.messages().iter().all(|(from, _, _)| from != "<>"));
    let rows: Vec<lyxal_surreal::Value> = out
        .bench
        .values(&format!(
            "SELECT VALUE id FROM mail_message WHERE mailbox = {};",
            jean.inbox
        ))
        .await;
    assert_eq!(rows.len(), 1, "un avis pour l'échec définitif");
    let opened = out
        .bench
        .content
        .read(&out.bench.system, &rows[0].to_sql(), None)
        .await
        .unwrap();
    let parsed =
        lyxal_mail_proto::mime::parse(&opened, &lyxal_mail_proto::mime::MimeLimits::default())
            .unwrap();
    let report = lyxal_mail_proto::dsn::parse_dsn(&opened, &parsed).expect("avis lisible");
    assert_eq!(report.recipients.len(), 1);
    assert_eq!(
        report.recipients[0].final_recipient.address,
        "absent@ailleurs.test"
    );
    assert_eq!(report.recipients[0].status.to_string(), "5.1.1");
}

#[tokio::test]
async fn a_null_mx_fails_permanently_and_a_module_gets_no_dsn() {
    let out = outbound().await;
    let mx = FakeMx::start(MxScript::default()).await;
    let resolver: Arc<dyn MailResolver> = Arc::new(resolver("mx.ailleurs.test", &[]));
    let submission = out.module_send(&["x@nul.test"], MESSAGE).await;
    let running = run(out.worker(&mx, resolver, None));
    let states = out.wait_final(&submission).await;
    running.stop().await;
    assert_eq!(states[0].1, RecipientState::Failed);
    assert_eq!(states[0].2.as_deref(), Some("5.1.10"));
    assert_eq!(mx.log.lock().unwrap().connections, 0);
}

#[tokio::test]
async fn a_crash_during_delivery_is_resumed_without_loss() {
    let out = outbound().await;
    let mx = FakeMx::start(MxScript {
        hang_on_data: true,
        ..MxScript::default()
    })
    .await;
    let resolver: Arc<dyn MailResolver> =
        Arc::new(resolver("mx.ailleurs.test", &["ailleurs.test"]));
    let submission = out.module_send(&["paul@ailleurs.test"], MESSAGE).await;
    let running = run(out.worker(&mx, resolver.clone(), None));
    // L'envoi est en cours (fin des données sans réponse) : arrêt brutal du nœud
    for _ in 0..100 {
        if out.states(&submission).await[0].1 == RecipientState::Running
            && mx.log.lock().unwrap().connections > 0
        {
            break;
        }
        tokio::time::sleep(Duration::from_millis(100)).await;
    }
    tokio::time::sleep(Duration::from_millis(300)).await;
    running.kill().await;
    assert_eq!(
        out.states(&submission).await[0].1,
        RecipientState::Running,
        "rien n'a été écrit"
    );
    // Le bail expire ; un autre nœud reprend le destinataire, sans essai compté
    out.bench
        .run(&format!("UPDATE mail_queue_recipient SET locked_until = time::now() - 1s WHERE submission = {submission};"))
        .await;
    mx.script.lock().unwrap().hang_on_data = false;
    let running = run(out.worker(&mx, resolver, None));
    let states = out.wait_final(&submission).await;
    running.stop().await;
    assert_eq!(states[0].1, RecipientState::Delivered, "aucune perte");
    assert_eq!(mx.messages().len(), 1);
}

#[tokio::test]
async fn the_local_route_delivers_into_another_organisation_with_dkim_verified() {
    let out = outbound().await;
    let beta = out.bench.domain("beta").await;
    let marie = out.bench.person("marie", "beta", &beta).await;
    let mx = FakeMx::start(MxScript::default()).await;
    let resolver = out.provision(StaticResolver::new()).await;
    let resolver: Arc<dyn MailResolver> = Arc::new(resolver);
    let submission = out.module_send(&["marie@beta.test"], MESSAGE).await;
    let running = run(out.worker(&mx, resolver, None));
    let states = out.wait_final(&submission).await;
    running.stop().await;
    assert_eq!(states[0].1, RecipientState::Delivered);
    assert_eq!(
        mx.log.lock().unwrap().connections,
        0,
        "aucune connexion réseau"
    );
    let reception: Vec<lyxal_surreal::Value> = out
        .bench
        .values(&format!(
            "SELECT VALUE reception.dkim FROM mail_message WHERE mailbox = {};",
            marie.inbox
        ))
        .await;
    assert_eq!(reception.len(), 1);
    assert_eq!(
        reception[0].to_sql(),
        "'pass'",
        "DKIM vérifié contre la clé enregistrée"
    );
}

#[tokio::test]
async fn notify_success_to_a_server_without_dsn_is_relayed() {
    let out = outbound().await;
    let mx = FakeMx::start(MxScript::default()).await;
    let resolver: Arc<dyn MailResolver> =
        Arc::new(resolver("mx.ailleurs.test", &["ailleurs.test"]));
    let reserved = out
        .bench
        .system
        .submission_begin(SubmissionBeginParams {
            origin: Some(SubmissionOrigin::Module),
            from: "noreply@alpha.test".into(),
            header_from: vec!["noreply@alpha.test".into()],
            recipients: vec![SubmissionRecipient {
                address: "paul@ailleurs.test".into(),
                notify: Some(vec![DsnNotify::Success]),
                orcpt: None,
            }],
            size: MESSAGE.len() as i64,
            smtputf8: None,
            eight_bit: None,
            dsn: None,
            client_reference: None,
            return_token: None,
            prefix: None,
            forward: None,
            tenant: None,
        })
        .await
        .unwrap();
    let content = futures::stream::iter([Ok::<Bytes, Infallible>(Bytes::from_static(
        MESSAGE.as_bytes(),
    ))]);
    let object = out
        .bench
        .storage
        .put(
            PutRequest {
                bucket: out.bucket.clone(),
                key: reserved.key.clone(),
                filename: "message.eml".into(),
                content_type: None,
                size: Some(MESSAGE.len() as u64),
            },
            content,
        )
        .await
        .unwrap()
        .id
        .to_sql();
    out.bench
        .system
        .submission_commit(SubmissionCommitParams {
            submission: reserved.submission.to_sql(),
            object,
        })
        .await
        .unwrap();
    let running = run(out.worker(&mx, resolver, None));
    let states = out.wait_final(&reserved.submission.to_sql()).await;
    running.stop().await;
    assert_eq!(states[0].1, RecipientState::Relayed);
}

// ------------------------------------------------------------------------------------------
// Mesures (hors CI) :
// cargo test -p lyxal_mail --release --test it -- --ignored --nocapture --test-threads 1 outbound::measure
// ------------------------------------------------------------------------------------------

fn percentile(values: &mut [f64], p: f64) -> f64 {
    values.sort_by(|a, b| a.total_cmp(b));
    let index = ((values.len() as f64 - 1.0) * p).round() as usize;
    values[index.min(values.len() - 1)]
}

#[tokio::test(flavor = "multi_thread", worker_threads = 4)]
#[ignore = "mesure, hors CI"]
async fn measure_throughput_to_the_fake_mx() {
    let out = outbound().await;
    let mx = FakeMx::start(MxScript::default()).await;
    let domains: Vec<String> = (0..100).map(|i| format!("d{i}.test")).collect();
    let names: Vec<&str> = domains.iter().map(String::as_str).collect();
    let resolver: Arc<dyn MailResolver> = Arc::new(resolver("mx.ailleurs.test", &names));
    let body = format!("{MESSAGE}{}\r\n", "x".repeat(10 * 1024));
    let total = std::env::var("LYXAL_MEASURE_RECIPIENTS")
        .ok()
        .and_then(|v| v.parse::<usize>().ok())
        .unwrap_or(2_000);
    let mut submissions = Vec::new();
    for n in 0..total / 100 {
        let recipients: Vec<String> = (0..100).map(|i| format!("r{n}_{i}@d{i}.test")).collect();
        let refs: Vec<&str> = recipients.iter().map(String::as_str).collect();
        submissions.push(out.module_send(&refs, &body).await);
    }
    let started = std::time::Instant::now();
    let running = run(out.worker(&mx, resolver, None));
    for submission in &submissions {
        out.wait_final_for(submission, 36_000).await;
    }
    let seconds = started.elapsed().as_secs_f64();
    running.stop().await;
    let delivered = mx.messages().iter().map(|(_, r, _)| r.len()).sum::<usize>();
    println!(
        "envoi : {delivered} destinataires de 10 Kio vers 100 domaines en {seconds:.1} s, {:.0} par seconde (base embarquée, faux MX local)",
        delivered as f64 / seconds
    );
}

#[tokio::test(flavor = "multi_thread", worker_threads = 4)]
#[ignore = "mesure, hors CI"]
async fn measure_claim_in_a_large_queue() {
    let out = outbound().await;
    let pending = std::env::var("LYXAL_MEASURE_PENDING")
        .ok()
        .and_then(|v| v.parse::<usize>().ok())
        .unwrap_or(10_000);
    for n in 0..pending / 100 {
        let recipients: Vec<String> = (0..100).map(|i| format!("p{n}_{i}@d{i}.test")).collect();
        let refs: Vec<&str> = recipients.iter().map(String::as_str).collect();
        out.module_send(&refs, MESSAGE).await;
        out.bench
            .run("UPDATE mail_queue_recipient SET next_attempt_at = time::now() + 1d WHERE state = 'scheduled' AND next_attempt_at < time::now() + 1h;")
            .await;
    }
    // Secondes vides laissées par le chargement retirées, comme par la maintenance
    for _ in 0..20 {
        out.bench
            .system
            .queue_purge(lyxal_mail::models::QueuePurgeParams { limit: Some(1_000) })
            .await
            .unwrap();
    }
    for n in 0..5 {
        let recipients: Vec<String> = (0..100).map(|i| format!("e{n}_{i}@e{i}.test")).collect();
        let refs: Vec<&str> = recipients.iter().map(String::as_str).collect();
        out.module_send(&refs, MESSAGE).await;
    }
    for limit in [50_i64, 500] {
        let mut times = Vec::new();
        for _ in 0..20 {
            let started = std::time::Instant::now();
            let claimed = out
                .bench
                .system
                .queue_claim(lyxal_mail::models::QueueClaimParams {
                    node: "mesure".into(),
                    limit: Some(limit),
                    lease_seconds: None,
                    exclude_domains: Vec::new(),
                })
                .await
                .unwrap();
            times.push(started.elapsed().as_secs_f64() * 1000.0);
            let recipients: Vec<String> =
                claimed.items.iter().map(|i| i.recipient.to_sql()).collect();
            if let Some(claim) = claimed.claim {
                out.bench
                    .system
                    .queue_release(lyxal_mail::models::QueueReleaseParams {
                        claim,
                        recipients,
                        not_before: None,
                    })
                    .await
                    .unwrap();
            }
        }
        println!(
            "réservation de {limit} parmi {pending} en attente : médiane {:.1} ms, p95 {:.1} ms (base embarquée)",
            percentile(&mut times.clone(), 0.5),
            percentile(&mut times, 0.95)
        );
    }
}
