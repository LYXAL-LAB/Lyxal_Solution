// SPDX-License-Identifier: AGPL-3.0-only

//! Client SMTP vers un serveur distant (plan du lot 6, §6.2 à §6.4 ; décisions E9, E10, E13).
//!
//! Écrit pour Lyxal OS sur le modèle de Mox (`smtpclient/client.go` : accueil, `EHLO` puis repli
//! `HELO`, `STARTTLS` puis nouvel `EHLO`, `PIPELINING` de `MAIL`, des `RCPT` et de `DATA`,
//! `RSET` quand aucun destinataire n'est accepté) sur la syntaxe de `lyxal_mail_proto::smtp::
//! client`. Chaque lecture et chaque écriture a son délai ; une réponse illisible, un délai ou
//! une coupure rendent la connexion inutilisable. Le contenu est écrit au fil de sa lecture
//! (préfixe en base puis fichier déchiffré par `lyxal_storage`) à travers le bourrage du point ;
//! un morceau illisible arrête l'envoi avant la fin des données (le `.` final n'est jamais
//! écrit : le serveur ne peut pas accepter un message tronqué).
//!
//! Le TLS est négocié par l'hôte ([`TlsConnectorProvider`], seul détenteur de `tokio-rustls`,
//! règle 10 du §11.3) sur une configuration de `lyxal_crypto::tls_client_config`.

use async_trait::async_trait;
use bytes::Bytes;
use futures::stream::BoxStream;
use futures::StreamExt;
use lyxal_crypto::{TlsPeerInfo, TlsServerVerification};
use lyxal_mail_proto::smtp::client::{
    ClientCommand, DotStuffer, MailCommand, RcptCommand, ReplyReader, ServerExtensions,
};
use lyxal_mail_proto::smtp::{
    Body, Domain, DsnNotify, DsnOrcpt, DsnRet, ForwardPath, Response, ReversePath,
};
use std::net::{IpAddr, SocketAddr};
use std::time::{Duration, Instant};
use tokio::io::{AsyncReadExt, AsyncWriteExt};
use tokio::net::TcpSocket;

use crate::error::MailError;
use crate::models::AttemptStage;
use crate::net::{BoxedStream, NetError};
use crate::outbound::config::Timeouts;

/// Taille d'une lecture sur la connexion.
const READ_CHUNK: usize = 8 * 1024;

/// Poignée de main TLS côté client, fournie par l'hôte (`tokio_rustls::TlsConnector` sur une
/// configuration de `lyxal_crypto::tls_client_config`).
#[async_trait]
pub trait TlsConnectorProvider: Send + Sync {
    /// Poignée de main sur `stream` vers `server_name` (SNI ; jamais une adresse IP), dans le
    /// mode `verification`, sous le délai `timeout` ; rend le flux chiffré et ce qui a été
    /// négocié. En cas d'échec, le flux est perdu.
    async fn connect(
        &self,
        stream: BoxedStream,
        server_name: &str,
        verification: TlsServerVerification,
        timeout: Duration,
    ) -> Result<(BoxedStream, TlsPeerInfo), NetError>;
}

/// TLS demandé pour une connexion.
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
pub enum TargetTls {
    /// STARTTLS s'il est annoncé, certificat non vérifié.
    Opportunistic,
    /// En clair (réglage d'essai, ou repli après une poignée de main ratée).
    Plain,
    /// STARTTLS exigé, certificat vérifié (relais).
    RequiredStartTls,
    /// TLS dès la connexion, certificat vérifié (relais, port 465).
    Implicit,
}

impl TargetTls {
    /// Nom court (clé du pool, mesures).
    pub fn as_str(self) -> &'static str {
        match self {
            Self::Opportunistic => "opportunistic",
            Self::Plain => "plain",
            Self::RequiredStartTls => "starttls",
            Self::Implicit => "implicit",
        }
    }
}

/// Serveur à joindre.
#[derive(Clone, Debug)]
pub struct ConnectTarget {
    /// Nom du serveur (SNI, vérification du certificat du relais).
    pub host: String,
    /// Adresse.
    pub ip: IpAddr,
    /// Port.
    pub port: u16,
    /// TLS demandé.
    pub tls: TargetTls,
    /// Adresse source de la connexion, s'il y en a une pour cette famille.
    pub source: Option<IpAddr>,
}

/// Identifiants `AUTH PLAIN` du relais. Le `Debug` masque le mot de passe.
pub struct RelayCredentials {
    /// Identifiant.
    pub username: String,
    /// Mot de passe (effacé de la mémoire à la libération).
    pub password: zeroize::Zeroizing<Vec<u8>>,
}

impl std::fmt::Debug for RelayCredentials {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("RelayCredentials")
            .field("username", &"[REDACTED]")
            .field("password", &"[REDACTED]")
            .finish()
    }
}

/// Ouverture d'une connexion en échec.
#[derive(Debug)]
pub struct OpenFailure {
    /// Étape.
    pub stage: AttemptStage,
    /// Réponse du serveur, s'il en a donné une.
    pub reply: Option<Response>,
    /// La poignée de main TLS (STARTTLS opportuniste) a échoué : une reconnexion en clair est
    /// permise (décision E9).
    pub tls_failed: bool,
}

impl OpenFailure {
    fn new(stage: AttemptStage) -> Self {
        Self {
            stage,
            reply: None,
            tls_failed: false,
        }
    }

    fn reply(stage: AttemptStage, reply: Response) -> Self {
        Self {
            stage,
            reply: Some(reply),
            tls_failed: false,
        }
    }

    /// Le serveur a répondu `220` puis refusé autrement que par `421` : il est joignable.
    pub fn answered(&self) -> bool {
        self.reply.as_ref().is_some_and(|reply| reply.code() != 421)
            && self.stage != AttemptStage::Connect
    }
}

/// Destinataire d'une transaction.
#[derive(Clone, Debug)]
pub struct RcptPlan {
    /// Chemin.
    pub path: ForwardPath,
    /// `NOTIFY` (transmis si le serveur annonce `DSN`).
    pub notify: Option<DsnNotify>,
    /// `ORCPT` (transmis si le serveur annonce `DSN`).
    pub orcpt: Option<DsnOrcpt>,
}

/// Enveloppe d'une transaction.
#[derive(Clone, Debug)]
pub struct Envelope {
    /// Chemin de retour (adresse de retour à jeton, ou `<>`).
    pub from: ReversePath,
    /// Destinataires (`recipients_per_transaction` au plus).
    pub recipients: Vec<RcptPlan>,
    /// Taille du message (préfixe compris).
    pub size: u64,
    /// Octets 8 bits.
    pub eight_bit: bool,
    /// `SMTPUTF8` exigé.
    pub smtputf8: bool,
    /// `RET` (si `DSN`).
    pub ret: Option<DsnRet>,
    /// `ENVID` décodé (si `DSN`).
    pub envid: Option<String>,
}

/// Issue d'un destinataire d'une transaction.
#[derive(Clone, Debug)]
pub enum RecipientOutcome {
    /// Accepté à la fin des données (ou relayé : serveur sans `DSN`).
    Accepted {
        /// Réponse à la fin des données.
        reply: Response,
    },
    /// Refusé ou non servi.
    Refused {
        /// Étape.
        stage: AttemptStage,
        /// Réponse du serveur, s'il y en a une.
        reply: Option<Response>,
        /// Échec définitif.
        permanent: bool,
        /// Code étendu (celui de la réponse, ou celui que nous posons).
        enhanced: Option<String>,
    },
}

/// Résultat d'une transaction.
#[derive(Debug)]
pub struct TransactionResult {
    /// Une issue par destinataire, dans l'ordre de l'enveloppe.
    pub recipients: Vec<RecipientOutcome>,
    /// La connexion reste utilisable pour une autre transaction.
    pub reusable: bool,
    /// Le contenu n'a pas pu être lu (fichier altéré, stockage indisponible).
    pub content_failed: bool,
}

/// Connexion SMTP ouverte, prête pour une transaction.
pub struct SmtpConnection {
    stream: BoxedStream,
    input: Vec<u8>,
    reader: ReplyReader,
    /// Extensions annoncées.
    pub extensions: ServerExtensions,
    /// TLS négocié, s'il l'est.
    pub tls: Option<TlsPeerInfo>,
    /// Serveur.
    pub host: String,
    /// Adresse du serveur.
    pub ip: IpAddr,
    /// Transactions faites sur la connexion.
    pub messages: u32,
    /// Fin de la dernière transaction.
    pub idle_since: Instant,
    timeouts: Timeouts,
}

impl std::fmt::Debug for SmtpConnection {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("SmtpConnection")
            .field("messages", &self.messages)
            .field("tls", &self.tls.map(|tls| tls.version))
            .finish_non_exhaustive()
    }
}

fn io_error() -> NetError {
    NetError::Io(std::io::Error::new(
        std::io::ErrorKind::UnexpectedEof,
        "connexion fermée par le serveur",
    ))
}

/// Lit la prochaine réponse du serveur sous délai.
async fn read_reply(
    stream: &mut BoxedStream,
    input: &mut Vec<u8>,
    reader: &mut ReplyReader,
    timeout: Duration,
) -> Result<Response, NetError> {
    let deadline = tokio::time::Instant::now() + timeout;
    loop {
        if !input.is_empty() {
            let ingested = reader.ingest(input);
            input.drain(..ingested.consumed);
            if let Some(reply) = ingested.item {
                return reply.map_err(|error| NetError::Protocol(error.to_string()));
            }
        }
        let mut chunk = [0u8; READ_CHUNK];
        let read = tokio::time::timeout_at(deadline, stream.read(&mut chunk))
            .await
            .map_err(|_| NetError::Timeout)??;
        if read == 0 {
            return Err(io_error());
        }
        input.extend_from_slice(&chunk[..read]);
    }
}

async fn write_all(
    stream: &mut BoxedStream,
    bytes: &[u8],
    timeout: Duration,
) -> Result<(), NetError> {
    tokio::time::timeout(timeout, async {
        stream.write_all(bytes).await?;
        stream.flush().await
    })
    .await
    .map_err(|_| NetError::Timeout)?
    .map_err(NetError::Io)
}

fn command_bytes(command: ClientCommand<'_>) -> Result<Vec<u8>, NetError> {
    let mut out = Vec::new();
    command
        .write_to(&mut out)
        .map_err(|error| NetError::Protocol(error.to_string()))?;
    Ok(out)
}

/// Échange `EHLO` (repli `HELO` sur `500` / `502`).
async fn hello(
    stream: &mut BoxedStream,
    input: &mut Vec<u8>,
    reader: &mut ReplyReader,
    name: &Domain,
    timeouts: &Timeouts,
) -> Result<ServerExtensions, OpenFailure> {
    let failure = |_| OpenFailure::new(AttemptStage::Greeting);
    reader.set_enhanced_status_codes(false);
    let ehlo = command_bytes(ClientCommand::Ehlo(name)).map_err(failure)?;
    write_all(stream, &ehlo, timeouts.ehlo)
        .await
        .map_err(failure)?;
    let reply = read_reply(stream, input, reader, timeouts.ehlo)
        .await
        .map_err(failure)?;
    if let Some(extensions) = ServerExtensions::from_ehlo(&reply) {
        reader.set_enhanced_status_codes(extensions.enhanced_status_codes);
        return Ok(extensions);
    }
    if !matches!(reply.code(), 500 | 502) {
        return Err(OpenFailure::reply(AttemptStage::Greeting, reply));
    }
    let helo = command_bytes(ClientCommand::Helo(name)).map_err(failure)?;
    write_all(stream, &helo, timeouts.ehlo)
        .await
        .map_err(failure)?;
    let reply = read_reply(stream, input, reader, timeouts.ehlo)
        .await
        .map_err(failure)?;
    if reply.code() != 250 {
        return Err(OpenFailure::reply(AttemptStage::Greeting, reply));
    }
    Ok(ServerExtensions {
        hostname: reply
            .lines()
            .first()
            .and_then(|line| line.split(' ').next())
            .unwrap_or_default()
            .to_owned(),
        ..ServerExtensions::default()
    })
}

impl SmtpConnection {
    /// Ouvre une connexion : TCP, TLS implicite (relais), accueil, `EHLO`, `STARTTLS`
    /// (opportuniste ou exigé) puis nouvel `EHLO`, `AUTH PLAIN` (relais).
    pub async fn open(
        target: &ConnectTarget,
        ehlo_name: &Domain,
        tls: Option<&dyn TlsConnectorProvider>,
        credentials: Option<&RelayCredentials>,
        timeouts: &Timeouts,
    ) -> Result<Self, OpenFailure> {
        let address = SocketAddr::new(target.ip, target.port);
        let socket = match target.ip {
            IpAddr::V4(_) => TcpSocket::new_v4(),
            IpAddr::V6(_) => TcpSocket::new_v6(),
        }
        .map_err(|_| OpenFailure::new(AttemptStage::Connect))?;
        if let Some(source) = target.source {
            socket
                .bind(SocketAddr::new(source, 0))
                .map_err(|_| OpenFailure::new(AttemptStage::Connect))?;
        }
        let tcp = tokio::time::timeout(timeouts.connect, socket.connect(address))
            .await
            .map_err(|_| OpenFailure::new(AttemptStage::Connect))?
            .map_err(|_| OpenFailure::new(AttemptStage::Connect))?;
        let _ = tcp.set_nodelay(true);
        let mut stream: BoxedStream = Box::new(tcp);
        let mut negotiated = None;
        if target.tls == TargetTls::Implicit {
            let provider = tls.ok_or_else(|| OpenFailure::new(AttemptStage::Tls))?;
            let (secured, info) = provider
                .connect(
                    stream,
                    &target.host,
                    TlsServerVerification::WebPki,
                    timeouts.starttls,
                )
                .await
                .map_err(|_| OpenFailure::new(AttemptStage::Tls))?;
            stream = secured;
            negotiated = Some(info);
        }
        let mut input = Vec::new();
        let mut reader = ReplyReader::new();
        let greeting = read_reply(&mut stream, &mut input, &mut reader, timeouts.greeting)
            .await
            .map_err(|_| OpenFailure::new(AttemptStage::Greeting))?;
        if greeting.code() != 220 {
            return Err(OpenFailure::reply(AttemptStage::Greeting, greeting));
        }
        let mut extensions =
            hello(&mut stream, &mut input, &mut reader, ehlo_name, timeouts).await?;
        let wants_starttls = match target.tls {
            TargetTls::Opportunistic => extensions.starttls,
            TargetTls::RequiredStartTls => true,
            TargetTls::Plain | TargetTls::Implicit => false,
        };
        if wants_starttls {
            if !extensions.starttls {
                // Relais : STARTTLS exigé et non annoncé
                return Err(OpenFailure::new(AttemptStage::Tls));
            }
            let provider = tls.ok_or_else(|| OpenFailure::new(AttemptStage::Tls))?;
            let tls_failure = |_| OpenFailure::new(AttemptStage::Tls);
            let command = command_bytes(ClientCommand::StartTls).map_err(tls_failure)?;
            write_all(&mut stream, &command, timeouts.starttls)
                .await
                .map_err(tls_failure)?;
            let reply = read_reply(&mut stream, &mut input, &mut reader, timeouts.starttls)
                .await
                .map_err(tls_failure)?;
            if reply.code() != 220 {
                return Err(OpenFailure {
                    stage: AttemptStage::Tls,
                    reply: Some(reply),
                    tls_failed: target.tls == TargetTls::Opportunistic,
                });
            }
            // Octets reçus avant la mise à niveau : injection en clair (RFC 3207 §4.2)
            if !input.is_empty() || reader.has_partial_reply() {
                return Err(OpenFailure::new(AttemptStage::Tls));
            }
            let verification = if target.tls == TargetTls::Opportunistic {
                TlsServerVerification::Opportunistic
            } else {
                TlsServerVerification::WebPki
            };
            match provider
                .connect(stream, &target.host, verification, timeouts.starttls)
                .await
            {
                Ok((secured, info)) => {
                    stream = secured;
                    negotiated = Some(info);
                }
                Err(_) => {
                    return Err(OpenFailure {
                        stage: AttemptStage::Tls,
                        reply: None,
                        tls_failed: target.tls == TargetTls::Opportunistic,
                    })
                }
            }
            reader = ReplyReader::new();
            extensions = hello(&mut stream, &mut input, &mut reader, ehlo_name, timeouts).await?;
        }
        if let Some(credentials) = credentials {
            let auth_failure = |_| OpenFailure::new(AttemptStage::Greeting);
            let mut command = command_bytes(ClientCommand::AuthPlain {
                authcid: &credentials.username,
                password: &credentials.password,
            })
            .map_err(auth_failure)?;
            let written = write_all(&mut stream, &command, timeouts.ehlo).await;
            zeroize::Zeroize::zeroize(&mut command);
            written.map_err(auth_failure)?;
            let reply = read_reply(&mut stream, &mut input, &mut reader, timeouts.ehlo)
                .await
                .map_err(auth_failure)?;
            if reply.code() != 235 {
                return Err(OpenFailure::reply(AttemptStage::Greeting, reply));
            }
        }
        Ok(Self {
            stream,
            input,
            reader,
            extensions,
            tls: negotiated,
            host: target.host.clone(),
            ip: target.ip,
            messages: 0,
            idle_since: Instant::now(),
            timeouts: *timeouts,
        })
    }

    async fn command(
        &mut self,
        command: ClientCommand<'_>,
        timeout: Duration,
    ) -> Result<Response, NetError> {
        let bytes = command_bytes(command)?;
        write_all(&mut self.stream, &bytes, timeout).await?;
        self.reply(timeout).await
    }

    async fn reply(&mut self, timeout: Duration) -> Result<Response, NetError> {
        read_reply(&mut self.stream, &mut self.input, &mut self.reader, timeout).await
    }

    /// `RSET` avant une nouvelle transaction (après un échec seulement).
    pub async fn reset(&mut self) -> bool {
        matches!(self.command(ClientCommand::Rset, self.timeouts.mail).await, Ok(reply) if reply.code() == 250)
    }

    /// `QUIT`, sans attendre plus de 5 s.
    pub async fn quit(mut self) {
        let timeout = Duration::from_secs(5);
        let _ = self.command(ClientCommand::Quit, timeout).await;
        let _ = tokio::time::timeout(timeout, self.stream.shutdown()).await;
    }

    /// Contrôles faits avant d'envoyer : taille annoncée, 8 bits, UTF-8.
    fn precheck(&self, envelope: &Envelope) -> Option<(&'static str, &'static str)> {
        if self
            .extensions
            .max_message_size()
            .is_some_and(|max| envelope.size > max)
        {
            return Some(("5.3.4", "message larger than the server accepts"));
        }
        if envelope.eight_bit && !self.extensions.eight_bit_mime {
            return Some(("5.6.3", "server does not accept 8-bit content"));
        }
        if envelope.smtputf8 && !self.extensions.smtputf8 {
            return Some(("5.6.7", "server does not accept SMTPUTF8"));
        }
        None
    }

    /// Une transaction : `MAIL`, `RCPT`, `DATA` (en une écriture avec `PIPELINING`), contenu,
    /// fin des données. `prefix` puis `content` forment le message.
    pub async fn send(
        &mut self,
        envelope: &Envelope,
        prefix: &[u8],
        content: BoxStream<'static, Result<Bytes, MailError>>,
    ) -> TransactionResult {
        self.messages = self.messages.saturating_add(1);
        let count = envelope.recipients.len();
        let all = |outcome: RecipientOutcome| vec![outcome; count];
        if let Some((enhanced, _)) = self.precheck(envelope) {
            return TransactionResult {
                recipients: all(RecipientOutcome::Refused {
                    stage: AttemptStage::Mail,
                    reply: None,
                    permanent: true,
                    enhanced: Some(enhanced.to_string()),
                }),
                reusable: true,
                content_failed: false,
            };
        }
        let dsn = self.extensions.dsn;
        let mail = MailCommand {
            reverse_path: envelope.from.clone(),
            size: self.extensions.size.map(|_| envelope.size),
            body: (envelope.eight_bit && self.extensions.eight_bit_mime)
                .then_some(Body::EightBitMime),
            smtputf8: envelope.smtputf8,
            ret: if dsn { envelope.ret } else { None },
            envid: if dsn { envelope.envid.clone() } else { None },
        };
        let rcpts: Vec<RcptCommand> = envelope
            .recipients
            .iter()
            .map(|rcpt| RcptCommand {
                forward_path: rcpt.path.clone(),
                notify: if dsn { rcpt.notify } else { None },
                orcpt: if dsn { rcpt.orcpt.clone() } else { None },
                smtputf8: envelope.smtputf8,
            })
            .collect();
        match self.dialogue(&mail, &rcpts, prefix, content).await {
            Ok(result) => result,
            Err((stage, error)) => {
                tracing::debug!(%error, "transaction interrompue");
                TransactionResult {
                    recipients: all(RecipientOutcome::Refused {
                        stage,
                        reply: None,
                        permanent: false,
                        enhanced: None,
                    }),
                    reusable: false,
                    content_failed: false,
                }
            }
        }
    }

    async fn dialogue(
        &mut self,
        mail: &MailCommand,
        rcpts: &[RcptCommand],
        prefix: &[u8],
        content: BoxStream<'static, Result<Bytes, MailError>>,
    ) -> Result<TransactionResult, (AttemptStage, NetError)> {
        let t = self.timeouts;
        let encode =
            |command: ClientCommand<'_>, stage| command_bytes(command).map_err(|e| (stage, e));
        let mut rcpt_replies = Vec::with_capacity(rcpts.len());
        let (mail_reply, data_reply) = if self.extensions.pipelining {
            let mut batch = encode(ClientCommand::Mail(mail), AttemptStage::Mail)?;
            for rcpt in rcpts {
                batch.extend(encode(ClientCommand::Rcpt(rcpt), AttemptStage::Rcpt)?);
            }
            batch.extend(encode(ClientCommand::Data, AttemptStage::Data)?);
            write_all(&mut self.stream, &batch, t.mail)
                .await
                .map_err(|e| (AttemptStage::Mail, e))?;
            let mail_reply = self
                .reply(t.mail)
                .await
                .map_err(|e| (AttemptStage::Mail, e))?;
            for _ in rcpts {
                rcpt_replies.push(
                    self.reply(t.rcpt)
                        .await
                        .map_err(|e| (AttemptStage::Rcpt, e))?,
                );
            }
            let data_reply = Some(
                self.reply(t.data)
                    .await
                    .map_err(|e| (AttemptStage::Data, e))?,
            );
            (mail_reply, data_reply)
        } else {
            let mail_reply = self
                .command(ClientCommand::Mail(mail), t.mail)
                .await
                .map_err(|e| (AttemptStage::Mail, e))?;
            if mail_reply.code() == 250 {
                for rcpt in rcpts {
                    rcpt_replies.push(
                        self.command(ClientCommand::Rcpt(rcpt), t.rcpt)
                            .await
                            .map_err(|e| (AttemptStage::Rcpt, e))?,
                    );
                }
            }
            let data_reply = if rcpt_replies.iter().any(|reply| reply.code() / 100 == 2) {
                Some(
                    self.command(ClientCommand::Data, t.data)
                        .await
                        .map_err(|e| (AttemptStage::Data, e))?,
                )
            } else {
                None
            };
            (mail_reply, data_reply)
        };
        let refused = |stage, reply: &Response| RecipientOutcome::Refused {
            stage,
            reply: Some(reply.clone()),
            permanent: reply.is_permanent(),
            enhanced: reply.status().map(|status| status.to_string()),
        };
        if mail_reply.code() != 250 {
            let outcome = refused(AttemptStage::Mail, &mail_reply);
            let reusable = self.finish_without_data(data_reply.as_ref()).await;
            return Ok(TransactionResult {
                recipients: vec![outcome; rcpts.len()],
                reusable,
                content_failed: false,
            });
        }
        let accepted: Vec<bool> = rcpt_replies
            .iter()
            .map(|reply| reply.code() / 100 == 2)
            .collect();
        let data_ok = data_reply.as_ref().is_some_and(|reply| reply.code() == 354);
        if !accepted.iter().any(|ok| *ok) || !data_ok {
            let data_refusal = data_reply
                .as_ref()
                .filter(|reply| reply.code() != 354)
                .cloned();
            let reusable = self.finish_without_data(data_reply.as_ref()).await;
            let recipients = rcpt_replies
                .iter()
                .map(|reply| match (&data_refusal, reply.code() / 100 == 2) {
                    (Some(data), true) => refused(AttemptStage::Data, data),
                    _ => refused(AttemptStage::Rcpt, reply),
                })
                .collect();
            return Ok(TransactionResult {
                recipients,
                reusable,
                content_failed: false,
            });
        }
        // Contenu : préfixe puis fichier, bourrés au fil de la lecture
        let mut stuffer = DotStuffer::new();
        let mut out = Vec::with_capacity(64 * 1024 + 1024);
        let content_error = |stage| (stage, NetError::Protocol("contenu illisible".into()));
        stuffer
            .encode(prefix, &mut out)
            .map_err(|_| content_error(AttemptStage::Data))?;
        let mut content = content;
        let mut content_failed = false;
        while let Some(chunk) = content.next().await {
            match chunk {
                Ok(chunk) => {
                    if stuffer.encode(&chunk, &mut out).is_err() {
                        content_failed = true;
                        break;
                    }
                }
                Err(error) => {
                    tracing::warn!(code = %error.code(), "contenu d'un envoi illisible : envoi arrêté avant la fin des données");
                    content_failed = true;
                    break;
                }
            }
            if out.len() >= 64 * 1024 {
                write_all(&mut self.stream, &out, t.data_block)
                    .await
                    .map_err(|e| (AttemptStage::Data, e))?;
                out.clear();
            }
        }
        if content_failed {
            // Connexion fermée sans `.` : le serveur ne peut pas accepter un message tronqué
            let _ = tokio::time::timeout(Duration::from_secs(5), self.stream.shutdown()).await;
            return Ok(TransactionResult {
                recipients: vec![
                    RecipientOutcome::Refused {
                        stage: AttemptStage::Content,
                        reply: None,
                        permanent: false,
                        enhanced: None,
                    };
                    rcpts.len()
                ],
                reusable: false,
                content_failed: true,
            });
        }
        stuffer
            .finish(&mut out)
            .map_err(|_| content_error(AttemptStage::Data))?;
        write_all(&mut self.stream, &out, t.data_block)
            .await
            .map_err(|e| (AttemptStage::Data, e))?;
        let end = self
            .reply(t.data_end)
            .await
            .map_err(|e| (AttemptStage::Data, e))?;
        let recipients = rcpt_replies
            .iter()
            .map(|reply| {
                if reply.code() / 100 != 2 {
                    refused(AttemptStage::Rcpt, reply)
                } else if end.code() / 100 == 2 {
                    RecipientOutcome::Accepted { reply: end.clone() }
                } else {
                    refused(AttemptStage::Data, &end)
                }
            })
            .collect();
        let reusable = end.code() / 100 == 2 || self.reset().await;
        self.idle_since = Instant::now();
        Ok(TransactionResult {
            recipients,
            reusable,
            content_failed: false,
        })
    }

    /// Fin d'une transaction sans contenu : un `354` reçu malgré tout (destinataires refusés en
    /// `PIPELINING`) est clos par un message vide, puis `RSET`.
    async fn finish_without_data(&mut self, data_reply: Option<&Response>) -> bool {
        if data_reply.is_some_and(|reply| reply.code() == 354) {
            let ended = write_all(&mut self.stream, b".\r\n", self.timeouts.data_block)
                .await
                .is_ok()
                && self.reply(self.timeouts.data_end).await.is_ok();
            if !ended {
                return false;
            }
        }
        self.idle_since = Instant::now();
        self.reset().await
    }
}
