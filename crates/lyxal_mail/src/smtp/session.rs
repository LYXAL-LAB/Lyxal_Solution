// SPDX-License-Identifier: AGPL-3.0-only

//! Session SMTP entrante (plan du lot 5, §7) : machine d'états, extensions annoncées, résolution
//! des destinataires, lecture de `DATA` et de `BDAT`, contrôles du message, politique de refus,
//! remise par la chaîne de remise, limites, délais, recherche d'adresses et bannissement.
//!
//! Écrit pour Lyxal OS sur le modèle de Stalwart (`smtp/src/inbound/` : `session.rs`,
//! `ehlo.rs`, `mail.rs`, `rcpt.rs`, `data.rs`, `vrfy.rs`) et de Mox (`smtpserver/server.go` :
//! fins de ligne isolées, données avant `354`, refus après `DATA`), sans code repris. La
//! syntaxe vient de `lyxal_mail_proto::smtp`.
//!
//! Les réponses sont écrites en attente et envoyées dès que la session doit lire la suite
//! (`PIPELINING`, RFC 2920 : réponses dans l'ordre des commandes). Aucune réponse ne reprend
//! une donnée du client ; aucune adresse n'est journalisée au-delà du niveau `debug`.

use bytes::Bytes;
use lyxal_mail_proto::mime::{parse as parse_mime, MimeLimits};
use lyxal_mail_proto::smtp::{
    ehlo_response, BdatReceiver, Body, CommandReceiver, DataOutcome, DataReceiver, Domain,
    Extensions, ForwardPath, MailFrom, RcptTo, Request, Response, ReversePath, SmtpError,
};
use std::net::IpAddr;
use std::sync::Arc;
use std::time::{Duration, Instant, SystemTime, UNIX_EPOCH};
use tokio::io::{AsyncReadExt, AsyncWriteExt};

use super::block::{Network, Offence};
use super::checks::Checks;
use super::handler::{Inbound, Mode, Shared};
use super::metrics::RefusedReason;
use crate::auth::{
    author_domains, is_valid_domain, sample_roll, strip_forged_results, to_ascii_domain,
    AuthenticationResults, DkimOutput, DkimResult, DkimVerifier, DmarcDisposition, DmarcOutput,
    DmarcResult, DmarcVerifier, Iprev, IprevResult, MessageHeaders, SpfIdentity, SpfOutput,
    SpfResult, SpfVerifier, MAX_AUTHOR_DOMAINS,
};
use crate::delivery::{PipelineResult, ReceivedMessage, RecipientTarget, RejectReason};
use crate::models::{
    DsnRequest, MailDatetime, RecipientKind, RecipientResolveParams, ResolvedRecipient,
    SubmissionRecipient,
};
use crate::net::{MemoryClass, MemoryReservation, NetError, Session, SessionEnd, TlsState};
use crate::submission::SubmissionUser;
use crate::MailError;
use lyxal_surreal::{LyxalCallError, LyxalSurrealError};

mod returns;
mod submission;

use returns::{Authenticity, ForwardTarget};

/// Octets lus au plus par lecture sur la connexion.
const READ_CHUNK: usize = 16 * 1024;
/// Destinataires refusés au-delà desquels chaque refus est retardé (recherche d'adresses).
const HARVEST_DELAY_FROM: u32 = 5;
/// Retard d'un refus de destinataire pendant une recherche d'adresses.
const HARVEST_DELAY: Duration = Duration::from_secs(1);
/// Destinataires refusés qui ferment la session (recherche d'adresses).
const HARVEST_CLOSE_AT: u32 = 20;
/// En-têtes `Received` au-delà desquels le message est tenu pour une boucle (RFC 5321 §6.3).
const MAX_RECEIVED_HEADERS: usize = 50;
/// Durée de lecture des données au-delà de laquelle le débit minimal est contrôlé.
const SLOW_DATA_GRACE: Duration = Duration::from_secs(30);

/// État de la session (plan §7.1).
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
enum Phase {
    /// Avant `EHLO` / `HELO`.
    Greeting,
    /// Après `EHLO` / `HELO`, hors transaction.
    Ready,
    /// Transaction ouverte par `MAIL FROM`.
    Transaction,
}

/// Morceaux `BDAT` en cours.
struct Chunks {
    receiver: BdatReceiver,
}

/// Transaction ouverte par `MAIL FROM`.
struct Transaction {
    /// Expéditeur de l'enveloppe (vide pour `<>`), forme de l'enveloppe.
    sender: String,
    smtputf8: bool,
    declared_size: Option<u64>,
    recipients: Vec<RecipientTarget>,
    /// Réception : adresses de retour de nos envois (avis reçus, §10.3).
    returns: Vec<crate::dsn::ReturnTarget>,
    /// Réception : alias qui transfèrent aussi le message vers l'extérieur (§13).
    forwards: Vec<ForwardTarget>,
    /// Réception : un destinataire ordinaire est sur un domaine protégé contre la
    /// rétrodiffusion (§11).
    backscatter: bool,
    /// Dépôt authentifié : destinataires de l'envoi, dans l'ordre, sans doublon.
    outbound: Vec<SubmissionRecipient>,
    /// Dépôt authentifié : demande d'avis (`RET`, `ENVID`).
    dsn: Option<DsnRequest>,
    /// `RCPT TO` acceptés (une adresse répétée compte à chaque fois).
    accepted: usize,
    /// Plus petite taille maximale des organisations des destinataires.
    max_bytes: u64,
    chunks: Option<Chunks>,
    message: Vec<u8>,
    memory: Option<MemoryReservation>,
    memory_exhausted: bool,
}

/// Fin de la session demandée par une commande.
enum Flow {
    Continue,
    Close,
    Fail(NetError),
}

/// Issue d'une attente de données du client.
enum Fill {
    Data,
    Eof,
    Timeout,
    Shutdown,
}

/// Connexion : flux, entrée lue non consommée, réponses en attente.
struct Io {
    session: Session,
    input: Vec<u8>,
    pos: usize,
    out: Vec<u8>,
}

impl Io {
    fn pending(&self) -> &[u8] {
        &self.input[self.pos..]
    }

    fn consume(&mut self, count: usize) {
        self.pos = (self.pos + count).min(self.input.len());
        if self.pos == self.input.len() {
            self.input.clear();
            self.pos = 0;
        }
    }

    fn reply(&mut self, code: u16, status: &str, text: &str) {
        self.out
            .extend_from_slice(format!("{code} {status} {text}\r\n").as_bytes());
    }

    fn response(&mut self, response: &Response) {
        response.write_to(&mut self.out);
    }

    async fn flush(&mut self) -> Result<(), NetError> {
        if self.out.is_empty() {
            return Ok(());
        }
        let stream = self.session.stream();
        stream.write_all(&self.out).await?;
        stream.flush().await?;
        self.out.clear();
        Ok(())
    }

    /// Lit la suite de l'entrée (réponses en attente envoyées d'abord), en avançant les
    /// contrôles en cours ; `shutdown` : l'arrêt du nœud interrompt l'attente.
    async fn fill(
        &mut self,
        checks: &mut Checks,
        deadline: tokio::time::Instant,
        shutdown: bool,
    ) -> Result<Fill, NetError> {
        self.flush().await?;
        let cancel = self.session.shutdown.clone();
        let mut buffer = [0u8; READ_CHUNK];
        loop {
            let stream = self.session.stream();
            tokio::select! {
                biased;
                () = cancel.cancelled(), if shutdown => return Ok(Fill::Shutdown),
                read = tokio::time::timeout_at(deadline, stream.read(&mut buffer)) => {
                    return match read {
                        Err(_) => Ok(Fill::Timeout),
                        Ok(Ok(0)) => Ok(Fill::Eof),
                        Ok(Ok(count)) => {
                            self.input.extend_from_slice(&buffer[..count]);
                            Ok(Fill::Data)
                        }
                        Ok(Err(error)) => Err(error.into()),
                    };
                }
                () = checks.progress(), if checks.running() => {}
            }
        }
    }
}

/// Une session SMTP.
pub(crate) struct SmtpSession {
    shared: Arc<Shared>,
    io: Io,
    receiver: CommandReceiver,
    checks: Checks,
    phase: Phase,
    helo: Option<String>,
    transaction: Option<Transaction>,
    errors: u32,
    refused_recipients: u32,
    messages: u32,
    ip: IpAddr,
    started: Instant,
    /// Dépôt authentifié : utilisateur authentifié par `AUTH`.
    user: Option<Box<dyn SubmissionUser>>,
    /// Dépôt authentifié : échecs de `AUTH` dans la session.
    auth_failures: u32,
}

impl SmtpSession {
    pub(crate) fn new(shared: Arc<Shared>, session: Session) -> Self {
        let ip = session.info.remote.ip();
        let receiver = CommandReceiver::new(&shared.limits);
        Self {
            shared,
            io: Io {
                session,
                input: Vec::new(),
                pos: 0,
                out: Vec::new(),
            },
            receiver,
            checks: Checks::new(),
            phase: Phase::Greeting,
            helo: None,
            transaction: None,
            errors: 0,
            refused_recipients: 0,
            messages: 0,
            ip,
            started: Instant::now(),
            user: None,
            auth_failures: 0,
        }
    }

    fn session_deadline(&self) -> tokio::time::Instant {
        tokio::time::Instant::from_std(self.started + self.shared.config.session_max)
    }

    fn command_deadline(&self) -> tokio::time::Instant {
        (tokio::time::Instant::now() + self.shared.config.command_timeout)
            .min(self.session_deadline())
    }

    fn data_deadline(&self) -> tokio::time::Instant {
        (tokio::time::Instant::now() + self.shared.config.data_timeout).min(self.session_deadline())
    }

    fn session_label(&self) -> String {
        format!("{:x}", self.io.session.info.session_id)
    }

    /// Réception du port 25 : ses contrôles et sa chaîne de remise ; `None` pour le dépôt.
    fn inbound(&self) -> Option<&Inbound> {
        match &self.shared.mode {
            Mode::Inbound(inbound) => Some(inbound),
            Mode::Submission(_) => None,
        }
    }

    /// Faute comptée pour le bannissement du réseau (réception seulement : aucun bannissement
    /// réseau sur le dépôt authentifié, où un bureau entier partage souvent une adresse).
    async fn offence(&mut self, offence: Offence) {
        if self.inbound().is_some() {
            self.shared
                .blocks
                .record_offence(&self.shared.store, self.ip, offence)
                .await;
        }
    }

    /// Sert la connexion jusqu'à sa fin.
    pub(crate) async fn run(mut self) -> SessionEnd {
        self.shared.metrics.session();
        if let Some(inbound) = self.inbound() {
            let resolver = inbound.resolver.clone();
            let ip = self.ip;
            self.checks
                .iprev
                .start(async move { Iprev::new(resolver.as_ref()).check(ip).await });
        }
        match Response::greeting(&self.shared.config.hostname) {
            Ok(greeting) => self.io.response(&greeting),
            Err(_) => self.io.reply(421, "4.3.2", "Service not available"),
        }
        let end = self.serve().await;
        // Réponses en attente (421, 221) envoyées avant de fermer
        let flushed = self.io.flush().await;
        let _ = self.io.session.stream().shutdown().await;
        match (end, flushed) {
            (Flow::Fail(error), _) => SessionEnd::Failed(error),
            (_, Err(error)) => SessionEnd::Failed(error),
            (_, Ok(())) if self.io.session.shutdown.is_cancelled() => SessionEnd::ClosedOnShutdown,
            _ => SessionEnd::Closed,
        }
    }

    async fn serve(&mut self) -> Flow {
        loop {
            let ingested = self.receiver.ingest(self.io.pending());
            self.io.consume(ingested.consumed);
            let Some(read) = ingested.item else {
                let deadline = self.command_deadline();
                match self.io.fill(&mut self.checks, deadline, true).await {
                    Ok(Fill::Data) => continue,
                    Ok(Fill::Eof) => return Flow::Close,
                    Ok(Fill::Timeout) => {
                        self.io.reply(421, "4.4.2", "Timeout, closing connection");
                        return Flow::Close;
                    }
                    Ok(Fill::Shutdown) => {
                        self.io
                            .reply(421, "4.3.2", "Service shutting down, try again later");
                        return Flow::Close;
                    }
                    Err(error) => return Flow::Fail(error),
                }
            };
            let flow = match read {
                Ok(request) => self.command(request).await,
                Err(error) => {
                    self.io.response(&error.response());
                    self.error();
                    Flow::Continue
                }
            };
            if !matches!(flow, Flow::Continue) {
                return flow;
            }
            if self.errors >= self.shared.config.max_errors {
                self.io
                    .reply(421, "4.7.0", "Too many errors, closing connection");
                self.shared.metrics.refused(RefusedReason::Limits);
                self.offence(Offence::Errors).await;
                return Flow::Close;
            }
        }
    }

    fn error(&mut self) {
        self.errors = self.errors.saturating_add(1);
    }

    fn bad_sequence(&mut self, text: &str) -> Flow {
        self.io.reply(503, "5.5.1", text);
        self.error();
        Flow::Continue
    }

    fn not_implemented(&mut self) -> Flow {
        self.io.reply(502, "5.5.1", "Command not implemented");
        self.error();
        Flow::Continue
    }

    async fn command(&mut self, request: Request) -> Flow {
        match request {
            Request::Ehlo { host } => self.hello(host, true),
            Request::Helo { host } => self.hello(host, false),
            Request::Quit => {
                self.io.reply(221, "2.0.0", "Bye");
                Flow::Close
            }
            Request::Noop => {
                self.io.reply(250, "2.0.0", "Ok");
                Flow::Continue
            }
            Request::Rset => {
                self.reset_transaction();
                self.io.reply(250, "2.0.0", "Ok");
                Flow::Continue
            }
            Request::Help => {
                self.io.reply(214, "2.0.0", "See RFC 5321");
                Flow::Continue
            }
            _ if self.phase == Phase::Greeting => self.bad_sequence("Send EHLO or HELO first"),
            Request::Mail(mail) => self.mail(mail).await,
            Request::Rcpt(rcpt) => self.rcpt(rcpt).await,
            Request::Data => self.data().await,
            Request::Bdat { size, last } => self.bdat(size, last).await,
            Request::StartTls => self.start_tls().await,
            Request::Auth { mechanism, initial } => self.auth(&mechanism, initial).await,
            Request::Vrfy => {
                self.io.reply(
                    252,
                    "2.5.0",
                    "Cannot VRFY user, but will accept message and attempt delivery",
                );
                Flow::Continue
            }
            Request::Expn | Request::Lhlo | Request::Etrn | Request::Atrn | Request::Burl => {
                self.not_implemented()
            }
        }
    }

    fn hello(&mut self, host: Domain, extended: bool) -> Flow {
        let name = match &host {
            Domain::Name(name) => match to_ascii_domain(name) {
                Some(ascii) if is_valid_domain(&ascii, false) => ascii,
                _ => {
                    self.io.reply(501, "5.5.4", "Invalid domain name");
                    self.error();
                    return Flow::Continue;
                }
            },
            literal => literal.to_string(),
        };
        self.reset_transaction();
        let resolver = self.inbound().map(|inbound| inbound.resolver.clone());
        if let Some(resolver) = resolver.filter(|_| self.helo.as_deref() != Some(name.as_str())) {
            if matches!(host, Domain::Name(_)) {
                let (ip, helo) = (self.ip, name.clone());
                self.checks.helo_spf.start(async move {
                    SpfVerifier::new(resolver.as_ref())
                        .check_helo(ip, &helo)
                        .await
                });
            } else {
                self.checks.helo_spf.clear();
            }
        }
        self.helo = Some(name);
        self.phase = Phase::Ready;
        let hostname = &self.shared.config.hostname;
        let response = if extended {
            let max = self.shared.config.max_message_bytes;
            let starttls = self.io.session.can_start_tls();
            let extensions = match &self.shared.mode {
                Mode::Inbound(_) => Extensions::inbound(max, starttls),
                // `AUTH` annoncé seulement sous TLS (RFC 4954 §4, plan §8.1)
                Mode::Submission(_) => {
                    Extensions::submission(max, starttls, self.io.session.info.tls.is_tls())
                }
            };
            ehlo_response(hostname, &extensions)
        } else {
            lyxal_mail_proto::smtp::helo_response(hostname)
        };
        match response {
            Ok(response) => self.io.response(&response),
            Err(_) => self.io.reply(250, "2.0.0", "Ok"),
        }
        Flow::Continue
    }

    fn reset_transaction(&mut self) {
        self.transaction = None;
        self.checks.mail_spf.clear();
        if self.phase == Phase::Transaction {
            self.phase = Phase::Ready;
        }
    }

    async fn mail(&mut self, mail: MailFrom) -> Flow {
        let Some(resolver) = self.inbound().map(|inbound| inbound.resolver.clone()) else {
            return self.submission_mail(mail).await;
        };
        if self.transaction.is_some() {
            return self.bad_sequence("Nested MAIL command");
        }
        let config = &self.shared.config;
        if mail.uses_dsn() || mail.uses_auth() || mail.body == Some(Body::BinaryMime) {
            self.io
                .response(&SmtpError::UnsupportedParameter.response());
            self.error();
            return Flow::Continue;
        }
        if mail
            .size
            .is_some_and(|size| size > config.max_message_bytes)
        {
            self.io.reply(
                552,
                "5.3.4",
                "Message size exceeds fixed maximum message size",
            );
            self.shared.metrics.refused(RefusedReason::Size);
            return Flow::Continue;
        }
        if self.messages >= config.max_messages_per_session {
            self.io
                .reply(421, "4.7.0", "Too many messages in this session");
            self.shared.metrics.refused(RefusedReason::Limits);
            return Flow::Close;
        }
        if !self.shared.message_rate.try_add(self.ip, Instant::now(), 1) {
            self.io.reply(
                450,
                "4.7.1",
                "Too many messages from your network, try again later",
            );
            self.shared.metrics.refused(RefusedReason::Limits);
            return Flow::Continue;
        }
        let sender = match &mail.reverse_path {
            ReversePath::Null => String::new(),
            ReversePath::Mailbox(mailbox) => mailbox.to_string(),
        };
        let (ip, helo, identity) = (
            self.ip,
            self.helo.clone().unwrap_or_default(),
            sender.clone(),
        );
        self.checks.mail_spf.start(async move {
            SpfVerifier::new(resolver.as_ref())
                .check_mail_from(ip, &helo, &identity)
                .await
        });
        self.transaction = Some(Transaction {
            sender,
            smtputf8: mail.smtputf8,
            declared_size: mail.size,
            recipients: Vec::new(),
            returns: Vec::new(),
            forwards: Vec::new(),
            backscatter: false,
            outbound: Vec::new(),
            dsn: None,
            accepted: 0,
            max_bytes: config.max_message_bytes,
            chunks: None,
            message: Vec::new(),
            memory: None,
            memory_exhausted: false,
        });
        self.phase = Phase::Transaction;
        self.io.reply(250, "2.1.0", "Sender OK");
        Flow::Continue
    }

    async fn rcpt(&mut self, rcpt: RcptTo) -> Flow {
        if self.inbound().is_none() {
            return self.submission_rcpt(rcpt).await;
        }
        let Some(transaction) = &self.transaction else {
            return self.bad_sequence("Send MAIL first");
        };
        if transaction.accepted >= self.shared.config.max_recipients {
            self.io.reply(452, "4.5.3", "Too many recipients");
            self.shared.metrics.recipient_refused(RefusedReason::Limits);
            return Flow::Continue;
        }
        if rcpt.uses_dsn() {
            self.io
                .response(&SmtpError::UnsupportedParameter.response());
            self.error();
            return Flow::Continue;
        }
        if !rcpt.forward_path.is_ascii() && !transaction.smtputf8 {
            self.io.response(&SmtpError::Utf8WithoutSmtpUtf8.response());
            self.error();
            return Flow::Continue;
        }
        let declared = transaction.declared_size;
        let address = match &rcpt.forward_path {
            _ if rcpt.source_route => None,
            ForwardPath::Postmaster => Some(Ok("postmaster".to_string())),
            ForwardPath::Mailbox(mailbox) => match mailbox.domain() {
                // Domaine converti en forme ASCII (A-label, S16) ; inconvertible : aucun relais
                Domain::Name(name) if mailbox.local_part().is_ascii() => to_ascii_domain(name)
                    .map(|domain| Ok(format!("{}@{domain}", mailbox.smtp_local_part()))),
                // Partie locale UTF-8 : aucune adresse de Lyxal ne peut correspondre (S16)
                Domain::Name(_) => Some(Err(RefusedReason::Unknown)),
                Domain::Ipv4(_) | Domain::Ipv6(_) => None,
            },
        };
        let address = match address {
            None => return self.refuse_recipient(RefusedReason::Relay).await,
            Some(Err(reason)) => return self.refuse_recipient(reason).await,
            Some(Ok(address)) => address,
        };
        let resolved = self
            .shared
            .store
            .recipient_resolve(RecipientResolveParams { address })
            .await;
        match resolved {
            // Adresse de retour d'un envoi (lot 6, §11) : avis reçus et réponses automatiques
            Ok(resolved) if resolved.kind == RecipientKind::Return => {
                self.accept_return(resolved, declared).await
            }
            Ok(resolved) => self.accept_recipient(resolved, declared).await,
            Err(error) => match business_code(&error) {
                Some("MAIL_RELAY_DENIED") => self.refuse_recipient(RefusedReason::Relay).await,
                Some("MAIL_RECIPIENT_UNKNOWN" | "MAIL_INVALID_PARAMETERS") => {
                    self.refuse_recipient(RefusedReason::Unknown).await
                }
                Some("MAIL_RECIPIENT_DISABLED") => {
                    self.refuse_recipient(RefusedReason::Disabled).await
                }
                _ => {
                    tracing::warn!(code = %MailError::from(error).code(), "résolution d'un destinataire en échec");
                    self.io
                        .reply(451, "4.3.0", "Temporary failure, try again later");
                    self.shared
                        .metrics
                        .recipient_refused(RefusedReason::Temporary);
                    Flow::Continue
                }
            },
        }
    }

    async fn accept_recipient(
        &mut self,
        resolved: ResolvedRecipient,
        declared: Option<u64>,
    ) -> Flow {
        let max = u64::try_from(resolved.max_message_bytes).unwrap_or(0);
        if declared.is_some_and(|size| size > max) {
            self.io.reply(
                552,
                "5.3.4",
                "Message size exceeds the recipient's maximum message size",
            );
            self.shared.metrics.recipient_refused(RefusedReason::Size);
            return Flow::Continue;
        }
        if resolved.accounts.iter().any(|account| account.quota_full) {
            self.io.reply(452, "4.2.2", "Mailbox full, try again later");
            self.shared.metrics.recipient_refused(RefusedReason::Quota);
            return Flow::Continue;
        }
        let Some(transaction) = self.transaction.as_mut() else {
            return Flow::Continue;
        };
        transaction.backscatter |= resolved.backscatter_protection;
        if !resolved.forward_to.is_empty()
            && !transaction
                .forwards
                .iter()
                .any(|known| known.alias == resolved.address)
        {
            transaction.forwards.push(ForwardTarget {
                alias: resolved.address.clone(),
                to: resolved.forward_to.clone(),
            });
        }
        if !transaction
            .recipients
            .iter()
            .any(|known| known.address == resolved.address)
        {
            transaction.max_bytes = transaction.max_bytes.min(max);
            transaction.recipients.push(RecipientTarget {
                address: resolved.address,
                tenant: resolved.tenant,
                accounts: resolved
                    .accounts
                    .into_iter()
                    .map(|account| account.account)
                    .collect(),
            });
        }
        transaction.accepted += 1;
        self.shared.metrics.recipient_accepted();
        self.io.reply(250, "2.1.5", "Recipient OK");
        Flow::Continue
    }

    async fn refuse_recipient(&mut self, reason: RefusedReason) -> Flow {
        self.refused_recipients = self.refused_recipients.saturating_add(1);
        self.shared.metrics.recipient_refused(reason);
        if self.refused_recipients >= HARVEST_CLOSE_AT {
            self.io.reply(
                421,
                "4.7.0",
                "Too many invalid recipients, closing connection",
            );
            self.offence(Offence::Harvest).await;
            return Flow::Close;
        }
        if self.refused_recipients >= HARVEST_DELAY_FROM {
            if let Err(error) = self.io.flush().await {
                return Flow::Fail(error);
            }
            tokio::time::sleep(HARVEST_DELAY).await;
        }
        match reason {
            RefusedReason::Relay => self.io.reply(550, "5.7.1", "Relaying denied"),
            RefusedReason::Disabled => self.io.reply(550, "5.2.1", "Mailbox disabled"),
            _ => self.io.reply(550, "5.1.1", "No such user"),
        }
        Flow::Continue
    }

    /// Vrai si la transaction peut recevoir des données ; sinon la réponse est écrite.
    fn ready_for_data(&mut self) -> bool {
        match &self.transaction {
            None => {
                self.bad_sequence("Send MAIL first");
                false
            }
            Some(transaction) if transaction.accepted == 0 => {
                self.io.reply(554, "5.5.1", "No valid recipients");
                self.error();
                false
            }
            Some(_) => true,
        }
    }

    async fn data(&mut self) -> Flow {
        if self
            .transaction
            .as_ref()
            .is_some_and(|transaction| transaction.chunks.is_some())
        {
            return self.bad_sequence("DATA not allowed after BDAT");
        }
        if !self.ready_for_data() {
            return Flow::Continue;
        }
        // Données envoyées avant `354` (RFC 2920 §3.1) : refus, la suite ne peut plus être lue
        // comme des commandes
        if !self.io.pending().is_empty() || self.receiver.has_partial_line() {
            self.io
                .reply(554, "5.5.0", "No data allowed before 354 response");
            self.shared.metrics.refused(RefusedReason::Malformed);
            return Flow::Close;
        }
        self.io
            .out
            .extend_from_slice(b"354 Start mail input; end with <CRLF>.<CRLF>\r\n");
        let mut receiver = DataReceiver::new(&self.shared.limits);
        let started = Instant::now();
        let mut total = 0usize;
        let mut chunk = Vec::new();
        let outcome = loop {
            let ingested = receiver.ingest(self.io.pending(), &mut chunk);
            self.io.consume(ingested.consumed);
            total += ingested.consumed;
            self.keep(&mut chunk);
            if let Some(outcome) = ingested.item {
                break outcome;
            }
            if let Some(flow) = self.wait_data(started, total).await {
                return flow;
            }
        };
        self.finish_message(outcome).await
    }

    async fn bdat(&mut self, size: u64, last: bool) -> Flow {
        let usable = self
            .transaction
            .as_ref()
            .is_some_and(|transaction| transaction.accepted > 0);
        if !usable {
            // Le morceau suit la commande : il est lu puis oublié (RFC 3030 §2)
            if let Some(flow) = self.discard(size).await {
                return flow;
            }
            self.ready_for_data();
            return Flow::Continue;
        }
        let limits = self.shared.limits;
        let Some(transaction) = self.transaction.as_mut() else {
            return Flow::Continue;
        };
        let chunks = transaction.chunks.get_or_insert_with(|| Chunks {
            receiver: BdatReceiver::new(&limits),
        });
        if chunks.receiver.start_chunk(size, last).is_err() {
            return self.bad_sequence("Bad BDAT sequence");
        }
        let started = Instant::now();
        let mut total = 0usize;
        let mut chunk = Vec::new();
        let outcome = loop {
            let Some(chunks) = self
                .transaction
                .as_mut()
                .and_then(|transaction| transaction.chunks.as_mut())
            else {
                return Flow::Continue;
            };
            let ingested = chunks.receiver.ingest(self.io.pending(), &mut chunk);
            self.io.consume(ingested.consumed);
            total += ingested.consumed;
            self.keep(&mut chunk);
            if let Some(done) = ingested.item {
                break done;
            }
            if let Some(flow) = self.wait_data(started, total).await {
                return flow;
            }
        };
        match outcome {
            None => {
                self.io
                    .reply(250, "2.0.0", &format!("{size} octets received"));
                Flow::Continue
            }
            Some(outcome) => self.finish_message(outcome).await,
        }
    }

    /// Lit et oublie `size` octets (morceau `BDAT` refusé).
    async fn discard(&mut self, size: u64) -> Option<Flow> {
        if size > self.shared.config.max_message_bytes {
            self.io.reply(
                552,
                "5.3.4",
                "Message size exceeds fixed maximum message size",
            );
            return Some(Flow::Close);
        }
        let mut remaining = size;
        let started = Instant::now();
        let mut total = 0usize;
        while remaining > 0 {
            let available = self.io.pending().len();
            let take = usize::try_from(remaining).map_or(available, |r| r.min(available));
            self.io.consume(take);
            remaining -= take as u64;
            total += take;
            if remaining > 0 {
                if let Some(flow) = self.wait_data(started, total).await {
                    return Some(flow);
                }
            }
        }
        None
    }

    /// Ajoute les octets lus au message, dans la mémoire réservée par pas de 64 Kio (classe
    /// « réception SMTP ») ; budget épuisé : le message n'est plus gardé (refus `452 4.3.1` à la
    /// fin).
    fn keep(&mut self, chunk: &mut Vec<u8>) {
        let budget = &self.shared.budget;
        // Message reçu, puis sa copie à ranger avec nos en-têtes (`check_and_deliver`)
        let limit = self
            .shared
            .config
            .max_message_bytes
            .saturating_mul(2)
            .saturating_add(crate::net::MEMORY_GRANULE * 2);
        if let Some(transaction) = self.transaction.as_mut() {
            if !transaction.memory_exhausted && !chunk.is_empty() {
                let needed = (transaction.message.len() + chunk.len()) as u64;
                let memory = transaction
                    .memory
                    .get_or_insert_with(|| budget.reservation(MemoryClass::SmtpInbound, limit));
                if memory.try_reserve_within_limit(needed).is_ok() {
                    transaction.message.extend_from_slice(chunk);
                } else {
                    transaction.memory_exhausted = true;
                    transaction.message = Vec::new();
                    transaction.memory = None;
                }
            }
        }
        chunk.clear();
    }

    /// Attend la suite des données ; `Some` : la session doit finir (délai, débit trop lent,
    /// fermeture par le client).
    async fn wait_data(&mut self, started: Instant, total: usize) -> Option<Flow> {
        let elapsed = started.elapsed();
        let minimum = self.shared.config.data_min_bytes_per_second;
        if minimum > 0
            && elapsed > SLOW_DATA_GRACE
            && (total as u64) < minimum.saturating_mul(elapsed.as_secs())
        {
            self.io
                .reply(421, "4.4.2", "Data too slow, closing connection");
            self.shared.metrics.refused(RefusedReason::Limits);
            return Some(Flow::Close);
        }
        let deadline = self.data_deadline();
        match self.io.fill(&mut self.checks, deadline, false).await {
            Ok(Fill::Data) => None,
            Ok(Fill::Eof) => Some(Flow::Close),
            Ok(Fill::Timeout) => {
                self.io.reply(421, "4.4.2", "Timeout, closing connection");
                self.shared.metrics.refused(RefusedReason::Limits);
                Some(Flow::Close)
            }
            Ok(Fill::Shutdown) => Some(Flow::Close),
            Err(error) => Some(Flow::Fail(error)),
        }
    }

    async fn start_tls(&mut self) -> Flow {
        if self.phase == Phase::Transaction {
            return self.bad_sequence("STARTTLS not allowed during a transaction");
        }
        if !self.io.session.can_start_tls() {
            return self.not_implemented();
        }
        self.io.reply(220, "2.0.0", "Ready to start TLS");
        if let Err(error) = self.io.flush().await {
            return Flow::Fail(error);
        }
        let mut pipelined = self.io.pending().to_vec();
        if self.receiver.has_partial_line() && pipelined.is_empty() {
            pipelined.push(0);
        }
        match self.io.session.start_tls(&pipelined).await {
            Ok(()) => {
                // RFC 3207 §4.2 : tout ce qui précède la mise à niveau est oublié
                self.receiver.reset();
                self.io.input.clear();
                self.io.pos = 0;
                self.phase = Phase::Greeting;
                self.helo = None;
                self.reset_transaction();
                Flow::Continue
            }
            Err(NetError::PipelinedBeforeTls) => {
                tracing::info!(
                    session = %self.session_label(),
                    network = %Network::masked(self.ip),
                    "données reçues avant la mise à niveau TLS : connexion fermée"
                );
                Flow::Close
            }
            Err(error) => Flow::Fail(error),
        }
    }

    /// Fin des données : contrôles, politique, chaîne de remise, réponse unique.
    async fn finish_message(&mut self, outcome: DataOutcome) -> Flow {
        let Some(mut transaction) = self.transaction.take() else {
            return Flow::Continue;
        };
        self.phase = Phase::Ready;
        let flow = self.judge(&mut transaction, outcome).await;
        self.checks.mail_spf.clear();
        flow
    }

    async fn judge(&mut self, transaction: &mut Transaction, outcome: DataOutcome) -> Flow {
        if let Some(error) = outcome.line_ending_error() {
            self.io.response(&error.response());
            self.error();
            self.refuse(RefusedReason::Smuggling, outcome.size, 500);
            self.offence(Offence::Smuggling).await;
            return Flow::Continue;
        }
        if outcome.oversized || outcome.size > transaction.max_bytes {
            self.io.reply(
                552,
                "5.3.4",
                "Message size exceeds fixed maximum message size",
            );
            self.refuse(RefusedReason::Size, outcome.size, 552);
            return Flow::Continue;
        }
        if outcome.nul_byte {
            self.io.reply(554, "5.6.0", "NUL byte not allowed");
            self.refuse(RefusedReason::Malformed, outcome.size, 554);
            return Flow::Continue;
        }
        if transaction.memory_exhausted {
            self.io
                .reply(452, "4.3.1", "Insufficient system storage, try again later");
            self.refuse(RefusedReason::Limits, outcome.size, 452);
            return Flow::Continue;
        }
        // La réservation couvre le message reçu jusqu'à la réponse : authentification, puis
        // remise, qui garde aussi la copie à ranger (réservée avant d'être faite)
        let received = Bytes::from(std::mem::take(&mut transaction.message));
        let memory = transaction.memory.take();
        if self.inbound().is_none() {
            return self.submit(transaction, received, memory).await;
        }
        self.check_and_deliver(transaction, received, memory).await
    }

    fn refuse(&self, reason: RefusedReason, size: u64, code: u16) {
        self.shared.metrics.refused(reason);
        tracing::info!(
            session = %self.session_label(),
            network = %Network::masked(self.ip),
            size,
            decision = reason.as_str(),
            code,
            "message refusé"
        );
    }

    async fn check_and_deliver(
        &mut self,
        transaction: &Transaction,
        received: Bytes,
        mut memory: Option<MemoryReservation>,
    ) -> Flow {
        let size = received.len() as u64;
        let Ok(parsed) = parse_mime(&received, &MimeLimits::default()) else {
            self.io.reply(554, "5.6.0", "Malformed message");
            self.refuse(RefusedReason::Malformed, size, 554);
            return Flow::Continue;
        };
        let Ok(headers) = MessageHeaders::parse(&received) else {
            self.io.reply(554, "5.6.0", "Malformed message header");
            self.refuse(RefusedReason::Malformed, size, 554);
            return Flow::Continue;
        };
        if headers.count("From") != 1 {
            self.io
                .reply(550, "5.6.0", "Message must have exactly one From header");
            self.refuse(RefusedReason::Policy, size, 550);
            return Flow::Continue;
        }
        // Au-delà de MAX_AUTHOR_DOMAINS domaines d'auteur, un domaine ne serait pas évalué par
        // DMARC : le message est refusé plutôt que jugé sur une partie de ses auteurs.
        let domains = author_domains(&parsed.envelope);
        if domains.len() > MAX_AUTHOR_DOMAINS {
            self.io
                .reply(550, "5.7.1", "Too many author domains in From");
            self.refuse(RefusedReason::Policy, size, 550);
            return Flow::Continue;
        }
        if headers.count("Received") > MAX_RECEIVED_HEADERS {
            self.io.reply(
                554,
                "5.4.6",
                "Too many Received headers, possible mail loop",
            );
            self.refuse(RefusedReason::Policy, size, 554);
            return Flow::Continue;
        }
        // Rétrodiffusion (§11, décision E21) : nos envois n'ont jamais une adresse ordinaire en
        // enveloppe ; un rapport `delivery-status` à expéditeur vide adressé à une adresse
        // ordinaire d'un domaine protégé est forgé (avis d'un spam qui a usurpé le domaine)
        if transaction.sender.is_empty()
            && transaction.backscatter
            && crate::dsn::is_delivery_report(&received, &parsed)
        {
            self.io.reply(
                550,
                "5.7.1",
                "Delivery status notification refused: no message was sent from this address",
            );
            self.refuse(RefusedReason::Backscatter, size, 550);
            return Flow::Continue;
        }

        // Contrôles d'authenticité : SPF et nom inverse déjà lancés, DKIM et DMARC sur le message
        let Some(inbound) = self.inbound() else {
            return Flow::Continue;
        };
        let (resolver, organizational, pipeline) = (
            inbound.resolver.clone(),
            inbound.organizational.clone(),
            inbound.pipeline.clone(),
        );
        let spf = match self.checks.mail_spf.result().await {
            Some(output) => output.clone(),
            None => SpfOutput {
                result: SpfResult::None,
                identity: SpfIdentity::MailFrom,
                domain: None,
            },
        };
        let helo_spf = self.checks.helo_spf.result().await.cloned();
        let iprev = self.checks.iprev.result().await.cloned();
        let dkim = DkimVerifier::new(resolver.as_ref())
            .verify_headers(&headers)
            .await;
        let dmarc = DmarcVerifier::new(resolver.as_ref(), organizational.as_ref())
            .verify(&domains, &spf, &dkim)
            .await;
        drop(headers);
        let dkim_word = dkim_summary(&dkim);
        let dmarc_word = dmarc_summary(&dmarc);
        let iprev_word = iprev
            .as_ref()
            .map_or(IprevResult::TempError, |output| output.result);
        self.shared.metrics.authentication(
            spf.result.as_str(),
            &dkim.iter().map(|o| o.result.as_str()).collect::<Vec<_>>(),
            &dmarc.iter().map(|o| o.result.as_str()).collect::<Vec<_>>(),
        );
        let disposition = DmarcOutput::combined_disposition(
            &dmarc,
            self.shared.config.dmarc_enforce,
            sample_roll(),
        );
        let log = TransactionLog {
            session: self.session_label(),
            network: Network::masked(self.ip),
            spf: spf.result.as_str(),
            dkim: dkim_word.clone(),
            dmarc: dmarc_word.clone(),
            iprev: iprev_word.as_str(),
            recipients: transaction.recipients.len() + transaction.returns.len(),
            size,
        };
        match disposition {
            DmarcDisposition::Reject => {
                self.io
                    .reply(550, "5.7.1", "Message rejected due to DMARC policy");
                self.shared.metrics.refused(RefusedReason::Dmarc);
                log.emit("dmarc", 550);
                return Flow::Continue;
            }
            DmarcDisposition::TempFail => {
                self.io
                    .reply(451, "4.7.5", "DMARC temporary error, try again later");
                self.shared.metrics.refused(RefusedReason::Temporary);
                log.emit("dmarc_temporary", 451);
                return Flow::Continue;
            }
            DmarcDisposition::Accept | DmarcDisposition::Quarantine => {}
        }

        let hostname = &self.shared.config.hostname;
        self.messages = self.messages.saturating_add(1);
        let id = format!("{}.{}", self.session_label(), self.messages);
        let mut results = AuthenticationResults::new(hostname);
        results.spf(&spf);
        if let Some(helo) = &helo_spf {
            results.spf(helo);
        }
        results.dkim(&dkim).dmarc(&dmarc);
        if let Some(iprev) = &iprev {
            results.iprev(iprev);
        }
        let tls = self.io.session.info.tls.clone();
        let mut header = String::new();
        header.push_str(&format!("Return-Path: <{}>\r\n", transaction.sender));
        header.push_str(&received_header(
            self.helo.as_deref().unwrap_or("unknown"),
            iprev.as_ref().and_then(|output| match output.result {
                IprevResult::Pass => output.name.as_deref(),
                _ => None,
            }),
            self.ip,
            hostname,
            &tls,
            transaction.smtputf8,
            &id,
        ));
        header.push_str(&results.to_header());
        // Copie à ranger (nos en-têtes, puis le message sans les `Authentication-Results`
        // falsifiés) : réservée dans le budget avant d'être faite, gardée jusqu'à la réponse
        let needed = size.saturating_mul(2).saturating_add(header.len() as u64);
        let reserved = memory
            .get_or_insert_with(|| {
                self.shared
                    .budget
                    .reservation(MemoryClass::SmtpInbound, needed)
            })
            .try_reserve_within_limit(needed);
        if reserved.is_err() {
            self.io
                .reply(452, "4.3.1", "Insufficient system storage, try again later");
            self.shared.metrics.refused(RefusedReason::Limits);
            log.emit("memory", 452);
            return Flow::Continue;
        }
        let Ok(stored) = strip_forged_results(&received, hostname, header.as_bytes()) else {
            self.io.reply(554, "5.6.0", "Malformed message header");
            self.refuse(RefusedReason::Malformed, size, 554);
            return Flow::Continue;
        };

        let message = ReceivedMessage {
            received,
            stored: Bytes::from(stored),
            sender: transaction.sender.clone(),
            recipients: transaction.recipients.clone(),
            authentication: [
                spf.result.as_str().to_string(),
                dkim_word.clone(),
                dmarc_word.clone(),
                iprev_word.as_str().to_string(),
            ],
            quarantine: disposition == DmarcDisposition::Quarantine,
            tls: tls.is_tls(),
            received_at: MailDatetime::now(),
        };
        let started = Instant::now();
        // Seulement des adresses de retour : rien à remettre aux boîtes ordinaires
        let result = if message.recipients.is_empty() {
            PipelineResult::Delivered {
                outcomes: Vec::new(),
            }
        } else {
            pipeline.deliver(&message).await
        };
        self.shared
            .metrics
            .delivery_time(u64::try_from(started.elapsed().as_millis()).unwrap_or(u64::MAX));
        match result {
            PipelineResult::Delivered { outcomes } => {
                for served in &outcomes {
                    if matches!(served.outcome, crate::DeliveryOutcome::Duplicate { .. }) {
                        self.shared.metrics.duplicate();
                    }
                }
                let checks = Authenticity {
                    spf: &spf,
                    dkim: &dkim,
                };
                if let Some(flow) = self
                    .after_delivery(transaction, &message, &parsed, checks, &log)
                    .await
                {
                    return flow;
                }
                self.shared.metrics.accepted();
                log.emit(
                    if disposition == DmarcDisposition::Quarantine {
                        "junk"
                    } else {
                        "delivered"
                    },
                    250,
                );
                self.io.reply(250, "2.0.0", &format!("Ok {id}"));
            }
            PipelineResult::Rejected {
                reason: RejectReason::Infected,
            } => {
                self.io
                    .reply(554, "5.7.1", "Message rejected: virus detected");
                self.shared.metrics.refused(RefusedReason::Antivirus);
                log.emit("infected", 554);
            }
            // Nos en-têtes ont fait passer le message au-delà de la taille de l'organisation :
            // refus définitif, comme à la fin des données (un `451` ferait réessayer sans fin)
            PipelineResult::TempFail { code, served } if code == "MAIL_MESSAGE_TOO_LARGE" => {
                self.io.reply(
                    552,
                    "5.3.4",
                    "Message size exceeds fixed maximum message size",
                );
                self.shared.metrics.refused(RefusedReason::Size);
                tracing::info!(session = %self.session_label(), served, "taille de l'organisation dépassée par les en-têtes de réception");
                log.emit("size", 552);
            }
            PipelineResult::TempFail { code, served } => {
                self.io
                    .reply(451, "4.3.0", "Temporary failure, try again later");
                self.shared.metrics.refused(RefusedReason::Temporary);
                tracing::info!(session = %self.session_label(), code = %code, served, "remise incomplète : refus temporaire");
                log.emit("temporary", 451);
            }
        }
        Flow::Continue
    }
}

/// Ligne du journal d'une transaction : identifiant de session, réseau masqué, résultats des
/// contrôles, nombre de destinataires, taille, décision, code SMTP ; ni adresse, ni sujet, ni
/// contenu.
struct TransactionLog {
    session: String,
    network: Network,
    spf: &'static str,
    dkim: String,
    dmarc: String,
    iprev: &'static str,
    recipients: usize,
    size: u64,
}

impl TransactionLog {
    fn emit(&self, decision: &str, code: u16) {
        tracing::info!(
            session = %self.session,
            network = %self.network,
            spf = self.spf,
            dkim = %self.dkim,
            dmarc = %self.dmarc,
            iprev = self.iprev,
            recipients = self.recipients,
            size = self.size,
            decision,
            code,
            "transaction SMTP"
        );
    }
}

/// Code métier d'un refus de fonction SurrealQL.
fn business_code(error: &LyxalSurrealError) -> Option<&str> {
    match error {
        LyxalSurrealError::Call(LyxalCallError::Business(business)) => Some(business.code.as_str()),
        _ => None,
    }
}

/// Mot DKIM du message : `pass` si une signature réussit, sinon le résultat de la première.
pub(crate) fn dkim_summary(outputs: &[DkimOutput]) -> String {
    if outputs
        .iter()
        .any(|output| output.result == DkimResult::Pass)
    {
        return "pass".to_string();
    }
    outputs
        .first()
        .map_or("none", |output| output.result.as_str())
        .to_string()
}

/// Mot DMARC du message : le plus défavorable de ses domaines d'auteur.
pub(crate) fn dmarc_summary(outputs: &[DmarcOutput]) -> String {
    let rank = |result: DmarcResult| match result {
        DmarcResult::Fail => 4,
        DmarcResult::TempError => 3,
        DmarcResult::PermError => 2,
        DmarcResult::None => 1,
        DmarcResult::Pass => 0,
    };
    outputs
        .iter()
        .map(|output| output.result)
        .max_by_key(|result| rank(*result))
        .map_or("none", |result| result.as_str())
        .to_string()
}

/// En-tête `Received` (RFC 5321 §4.4) : nom annoncé, nom inverse confirmé, adresse, notre nom,
/// protocole (RFC 3848, RFC 6531 §3.7.3), identifiant, version et suite TLS, date. Aucun
/// destinataire nommé ; le nom annoncé a déjà été contrôlé (`EHLO`).
fn received_header(
    helo: &str,
    reverse: Option<&str>,
    ip: IpAddr,
    hostname: &str,
    tls: &TlsState,
    smtputf8: bool,
    id: &str,
) -> String {
    let reverse = reverse
        .filter(|name| is_valid_domain(name, true))
        .map(|name| format!("{name} "))
        .unwrap_or_default();
    let address = match ip {
        IpAddr::V4(v4) => v4.to_string(),
        IpAddr::V6(v6) => format!("IPv6:{v6}"),
    };
    let protocol = match (smtputf8, tls.is_tls()) {
        (false, false) => "ESMTP",
        (false, true) => "ESMTPS",
        (true, false) => "UTF8SMTP",
        (true, true) => "UTF8SMTPS",
    };
    let tls_comment = match tls {
        TlsState::Plain => String::new(),
        TlsState::Implicit(info) | TlsState::Upgraded(info) => {
            format!("\r\n\t(version={} cipher={})", info.version, info.cipher)
        }
    };
    format!(
        "Received: from {helo} ({reverse}[{address}])\r\n\tby {hostname} with {protocol} id {id}{tls_comment};\r\n\t{}\r\n",
        rfc5322_date(SystemTime::now())
    )
}

/// Date RFC 5322 en temps universel (`Thu, 26 Nov 2026 17:27:54 +0000`).
pub(crate) fn rfc5322_date(time: SystemTime) -> String {
    let seconds = time
        .duration_since(UNIX_EPOCH)
        .map(|elapsed| elapsed.as_secs())
        .unwrap_or_default();
    let days = i64::try_from(seconds / 86_400).unwrap_or_default();
    let rest = seconds % 86_400;
    // Jours depuis 1970 → date civile (algorithme de H. Hinnant)
    let z = days + 719_468;
    let era = z.div_euclid(146_097);
    let doe = z - era * 146_097;
    let yoe = (doe - doe / 1_460 + doe / 36_524 - doe / 146_096) / 365;
    let doy = doe - (365 * yoe + yoe / 4 - yoe / 100);
    let mp = (5 * doy + 2) / 153;
    let day = doy - (153 * mp + 2) / 5 + 1;
    let month = if mp < 10 { mp + 3 } else { mp - 9 };
    let year = yoe + era * 400 + i64::from(month <= 2);
    const WEEKDAYS: [&str; 7] = ["Thu", "Fri", "Sat", "Sun", "Mon", "Tue", "Wed"];
    const MONTHS: [&str; 12] = [
        "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec",
    ];
    let weekday = WEEKDAYS[usize::try_from(days.rem_euclid(7)).unwrap_or(0)];
    let month_name = MONTHS[usize::try_from(month - 1).unwrap_or(0).min(11)];
    format!(
        "{weekday}, {day} {month_name} {year} {:02}:{:02}:{:02} +0000",
        rest / 3_600,
        (rest % 3_600) / 60,
        rest % 60
    )
}

#[cfg(test)]
#[allow(clippy::unwrap_used)]
mod tests {
    use super::*;
    use crate::net::TlsInfo;

    #[test]
    fn dates_follow_rfc_5322() {
        assert_eq!(rfc5322_date(UNIX_EPOCH), "Thu, 1 Jan 1970 00:00:00 +0000");
        let time = UNIX_EPOCH + Duration::from_secs(1_795_714_074);
        assert_eq!(rfc5322_date(time), "Thu, 26 Nov 2026 17:27:54 +0000");
        let leap = UNIX_EPOCH + Duration::from_secs(951_782_400);
        assert_eq!(rfc5322_date(leap), "Tue, 29 Feb 2000 00:00:00 +0000");
    }

    #[test]
    fn the_received_header_names_no_recipient_and_injects_nothing() {
        let header = received_header(
            "mx.ailleurs.test",
            Some("mail.ailleurs.test\r\nX-Injecte: oui"),
            "192.0.2.7".parse().unwrap(),
            "mx.alpha.test",
            &TlsState::Upgraded(TlsInfo {
                version: "TLSv1_3",
                cipher: "TLS13_AES_128_GCM_SHA256",
                server_name: None,
                alpn: None,
            }),
            false,
            "1f.1",
        );
        assert!(header.starts_with("Received: from mx.ailleurs.test ([192.0.2.7])\r\n\tby mx.alpha.test with ESMTPS id 1f.1\r\n\t(version=TLSv1_3 cipher=TLS13_AES_128_GCM_SHA256);\r\n\t"));
        assert!(!header.contains("X-Injecte"));
        let plain = received_header(
            "[192.0.2.7]",
            Some("mail.ailleurs.test"),
            "2001:db8::1".parse().unwrap(),
            "mx.alpha.test",
            &TlsState::Plain,
            true,
            "2.1",
        );
        assert!(plain.starts_with(
            "Received: from [192.0.2.7] (mail.ailleurs.test [IPv6:2001:db8::1])\r\n\tby mx.alpha.test with UTF8SMTP id 2.1;"
        ));
    }

    #[test]
    fn summaries_keep_the_most_telling_result() {
        let dkim = |result| DkimOutput {
            result,
            domain: None,
            selector: None,
            signature_prefix: None,
            testing: false,
        };
        assert_eq!(dkim_summary(&[]), "none");
        assert_eq!(
            dkim_summary(&[dkim(DkimResult::Fail), dkim(DkimResult::Pass)]),
            "pass"
        );
        assert_eq!(dkim_summary(&[dkim(DkimResult::PermError)]), "permerror");
        let dmarc = |result| DmarcOutput {
            result,
            from_domain: "a.test".into(),
            record_domain: None,
            policy: None,
            percentage: 100,
            spf_aligned: false,
            dkim_aligned: false,
        };
        assert_eq!(dmarc_summary(&[]), "none");
        assert_eq!(
            dmarc_summary(&[dmarc(DmarcResult::Pass), dmarc(DmarcResult::Fail)]),
            "fail"
        );
    }
}
