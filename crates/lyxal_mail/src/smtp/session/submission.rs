// SPDX-License-Identifier: AGPL-3.0-only

//! Rôle « dépôt authentifié » de la session SMTP (plan du lot 6, §8) : `AUTH` sous TLS,
//! `MAIL FROM` et champs d'expéditeur contrôlés par la base au nom de l'utilisateur,
//! destinataires des domaines de l'installation résolus dès `RCPT TO`, paramètres DSN, puis
//! traitement du message et inscription dans la file (`crate::submission`).
//!
//! Écrit pour Lyxal OS sur le modèle de Stalwart (`smtp/src/inbound/auth.rs`, `mail.rs`) et de
//! Mox (`smtpserver/server.go`, `cmdAuth`, `submit`), sans code repris ; RFC 4954, 6409, 8314.

use lyxal_mail_proto::smtp::{AuthError, AuthExchange, AuthStep, Credentials, DsnRet, SaslData};
use lyxal_surreal::ToSql;

use super::*;
use crate::delivery::ScanOutcome;
use crate::models::{
    DsnNotify, DsnReturn, SenderCheckParams, SubmissionBeginParams, SubmissionOrigin,
};
use crate::store::MailStore;
use crate::submission::{
    normalize_address, prepare_message, sender_addresses, submission_received, AuthAttempt,
    AuthRefusal, SenderRefusal, SubmissionMetrics, MAX_AUTH_FAILURES,
};

/// Fin d'un échange `AUTH` sans identifiants à vérifier.
enum SaslEnd {
    /// Échange refusé (réponse écrite) : la session continue.
    Refused(AuthError),
    /// La session doit finir (délai, fermeture, arrêt du nœud).
    Flow(Flow),
}

impl SmtpSession {
    /// Mesures du dépôt ; `None` pour la réception.
    fn submission_metrics(&self) -> Option<Arc<SubmissionMetrics>> {
        match &self.shared.mode {
            Mode::Submission(submission) => Some(submission.metrics.clone()),
            Mode::Inbound(_) => None,
        }
    }

    fn is_tls(&self) -> bool {
        self.io.session.info.tls.is_tls()
    }

    /// `530 5.7.0` : commande refusée avant TLS (RFC 3207 §4, plan §8.1).
    fn tls_required(&mut self, metrics: &SubmissionMetrics) -> Flow {
        metrics.tls_required();
        self.io
            .reply(530, "5.7.0", "Must issue a STARTTLS command first");
        self.error();
        Flow::Continue
    }

    /// `AUTH <mécanisme> [réponse initiale]` (RFC 4954) : refusé hors du dépôt, avant TLS, une
    /// seconde fois ou pendant une transaction ; échange `PLAIN` ou `LOGIN`, puis mot de passe
    /// d'application vérifié par l'hôte.
    pub(super) async fn auth(&mut self, mechanism: &str, initial: Option<SaslData>) -> Flow {
        let (Some(metrics), Mode::Submission(submission)) =
            (self.submission_metrics(), &self.shared.mode)
        else {
            return self.not_implemented();
        };
        let authenticator = submission.authenticator.clone();
        if !self.is_tls() {
            return self.tls_required(&metrics);
        }
        if self.user.is_some() {
            return self.bad_sequence("Already authenticated");
        }
        if self.transaction.is_some() {
            return self.bad_sequence("AUTH not allowed during a transaction");
        }
        let credentials = match self.sasl(mechanism, initial.as_ref()).await {
            Ok(credentials) => credentials,
            Err(SaslEnd::Flow(flow)) => return flow,
            Err(SaslEnd::Refused(error)) => {
                metrics.auth_malformed();
                if error == AuthError::AuthzidRefused {
                    return self.auth_failed(AuthRefusal::Invalid);
                }
                self.io.response(&error.response());
                self.error();
                return Flow::Continue;
            }
        };
        let attempt = AuthAttempt {
            credentials,
            client: self.ip,
        };
        match authenticator.authenticate(attempt).await {
            Ok(user) => {
                self.user = Some(user);
                metrics.auth_succeeded();
                self.auth_log("success");
                self.io.reply(235, "2.7.0", "Authentication successful");
                Flow::Continue
            }
            Err(refusal) => {
                metrics.auth_refused(refusal);
                match refusal {
                    AuthRefusal::Invalid | AuthRefusal::Forbidden => self.auth_failed(refusal),
                    AuthRefusal::Locked => {
                        self.auth_log(refusal.as_str());
                        self.io.reply(
                            421,
                            "4.7.0",
                            "Too many authentication failures, try again later",
                        );
                        Flow::Close
                    }
                    AuthRefusal::Unavailable => {
                        self.auth_log(refusal.as_str());
                        self.io
                            .reply(454, "4.7.0", "Temporary authentication failure");
                        Flow::Continue
                    }
                }
            }
        }
    }

    /// Échec d'authentification compté : `535 5.7.8`, ou `421 4.7.0` et fermeture au troisième.
    /// Aucun bannissement réseau (plan §8.2) : `lyxal_auth` bloque seul l'adresse du client.
    fn auth_failed(&mut self, refusal: AuthRefusal) -> Flow {
        self.auth_failures = self.auth_failures.saturating_add(1);
        self.auth_log(refusal.as_str());
        if self.auth_failures >= MAX_AUTH_FAILURES {
            self.io.reply(
                421,
                "4.7.0",
                "Too many authentication failures, closing connection",
            );
            return Flow::Close;
        }
        self.io
            .reply(535, "5.7.8", "Authentication credentials invalid");
        Flow::Continue
    }

    /// Ligne du journal d'une authentification : session, réseau masqué, issue ; ni identifiant
    /// ni mot de passe.
    fn auth_log(&self, outcome: &str) {
        tracing::info!(
            session = %self.session_label(),
            network = %Network::masked(self.ip),
            outcome,
            failures = self.auth_failures,
            "authentification du dépôt"
        );
    }

    /// Échange SASL : défis `334` et lignes du client jusqu'aux identifiants.
    async fn sasl(
        &mut self,
        mechanism: &str,
        initial: Option<&SaslData>,
    ) -> Result<Credentials, SaslEnd> {
        let (mut exchange, mut step) =
            AuthExchange::start(mechanism, initial).map_err(SaslEnd::Refused)?;
        loop {
            match step {
                AuthStep::Credentials(credentials) => return Ok(credentials),
                AuthStep::Challenge(challenge) => {
                    self.io.response(&challenge);
                    let line = self.sasl_line().await?;
                    step = exchange.step(&line).map_err(SaslEnd::Refused)?;
                }
            }
        }
    }

    /// Ligne suivante du client pendant un échange `AUTH`.
    async fn sasl_line(&mut self) -> Result<SaslData, SaslEnd> {
        loop {
            let ingested = self.receiver.ingest_line(self.io.pending());
            self.io.consume(ingested.consumed);
            match ingested.item {
                Some(Ok(line)) => return Ok(line),
                Some(Err(error)) => {
                    self.io.response(&error.response());
                    self.error();
                    return Err(SaslEnd::Flow(Flow::Continue));
                }
                None => {}
            }
            let deadline = self.command_deadline();
            match self.io.fill(&mut self.checks, deadline, true).await {
                Ok(Fill::Data) => {}
                Ok(Fill::Eof) => return Err(SaslEnd::Flow(Flow::Close)),
                Ok(Fill::Timeout) => {
                    self.io.reply(421, "4.4.2", "Timeout, closing connection");
                    return Err(SaslEnd::Flow(Flow::Close));
                }
                Ok(Fill::Shutdown) => {
                    self.io
                        .reply(421, "4.3.2", "Service shutting down, try again later");
                    return Err(SaslEnd::Flow(Flow::Close));
                }
                Err(error) => return Err(SaslEnd::Flow(Flow::Fail(error))),
            }
        }
    }

    /// Store au nom de l'utilisateur (jeton renouvelé au besoin). Sans utilisateur : `530` ;
    /// session révoquée ou expirée : `421 4.7.0` et fermeture ; panne : `451 4.3.0`.
    async fn user_store(&mut self) -> Result<MailStore, Flow> {
        let Some(user) = self.user.as_mut() else {
            self.io.reply(530, "5.7.0", "Authentication required");
            self.error();
            return Err(Flow::Continue);
        };
        match user.store().await {
            Ok(store) => Ok(store),
            Err(AuthRefusal::Unavailable) => {
                self.io
                    .reply(451, "4.3.0", "Temporary failure, try again later");
                self.shared.metrics.refused(RefusedReason::Temporary);
                Err(Flow::Continue)
            }
            Err(refusal) => {
                self.user = None;
                self.auth_log(refusal.as_str());
                self.io.reply(
                    421,
                    "4.7.0",
                    "Authentication no longer valid, closing connection",
                );
                Err(Flow::Close)
            }
        }
    }

    /// Droit d'envoyer sous `addresses`, décidé par la base au nom de l'utilisateur
    /// (`fn::mail_sender_check`) ; `Some` : réponse écrite, la session suit le flux rendu.
    async fn sender_refused(&mut self, addresses: Vec<String>, size: u64) -> Option<Flow> {
        let store = match self.user_store().await {
            Ok(store) => store,
            Err(flow) => return Some(flow),
        };
        match store.sender_check(SenderCheckParams { addresses }).await {
            Ok(check) if check.allowed => None,
            Ok(_) => Some(self.spoofed(size)),
            Err(error) if business_code(&error) == Some("MAIL_PERMISSION_DENIED") => {
                Some(self.spoofed(size))
            }
            Err(error) => {
                tracing::warn!(code = %MailError::from(error).code(), "droit d'expéditeur illisible");
                self.io
                    .reply(451, "4.3.0", "Temporary failure, try again later");
                self.refuse(RefusedReason::Temporary, size, 451);
                Some(Flow::Continue)
            }
        }
    }

    /// Usurpation refusée (`550 5.7.1`, `MAIL_SENDER_FORBIDDEN`), comptée et journalisée sans
    /// adresse.
    fn spoofed(&mut self, size: u64) -> Flow {
        if let Some(metrics) = self.submission_metrics() {
            metrics.spoofing();
        }
        self.io.reply(550, "5.7.1", "Sender address not allowed");
        self.refuse(RefusedReason::Policy, size, 550);
        Flow::Continue
    }

    /// `MAIL FROM` du dépôt : TLS et `AUTH` exigés, paramètres DSN et `AUTH=` acceptés (annoncés),
    /// taille, messages par session, adresse permise au compte.
    pub(super) async fn submission_mail(&mut self, mail: MailFrom) -> Flow {
        let Some(metrics) = self.submission_metrics() else {
            return self.not_implemented();
        };
        if !self.is_tls() {
            return self.tls_required(&metrics);
        }
        if self.user.is_none() {
            metrics.auth_required();
            self.io.reply(530, "5.7.0", "Authentication required");
            self.error();
            return Flow::Continue;
        }
        if self.transaction.is_some() {
            return self.bad_sequence("Nested MAIL command");
        }
        let config = &self.shared.config;
        if mail.body == Some(Body::BinaryMime) {
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
        let envid = match &mail.dsn_envid {
            None => None,
            Some(_) => match mail.decoded_envid() {
                Some(envid) => Some(envid),
                None => {
                    self.io.reply(501, "5.5.4", "Invalid ENVID parameter");
                    self.error();
                    return Flow::Continue;
                }
            },
        };
        let sender = match &mail.reverse_path {
            ReversePath::Null => String::new(),
            ReversePath::Mailbox(mailbox) => match normalize_address(&mailbox.to_string()) {
                Ok(address) => address,
                Err(_) => return self.spoofed(0),
            },
        };
        if let Some(flow) = self.sender_refused(vec![sender.clone()], 0).await {
            return flow;
        }
        let ret = mail.dsn_ret.map(|ret| match ret {
            DsnRet::Full => DsnReturn::Full,
            DsnRet::Headers => DsnReturn::Hdrs,
        });
        self.transaction = Some(Transaction {
            sender,
            smtputf8: mail.smtputf8,
            declared_size: mail.size,
            recipients: Vec::new(),
            outbound: Vec::new(),
            dsn: (ret.is_some() || envid.is_some()).then_some(DsnRequest { ret, envid }),
            accepted: 0,
            max_bytes: self.shared.config.max_message_bytes,
            chunks: None,
            message: Vec::new(),
            memory: None,
            memory_exhausted: false,
        });
        self.phase = Phase::Transaction;
        self.io.reply(250, "2.1.0", "Sender OK");
        Flow::Continue
    }

    /// `RCPT TO` du dépôt : aucune vérification d'existence pour un domaine extérieur ; un
    /// domaine de l'installation est résolu tout de suite (`550 5.1.1` s'il est inconnu, plan
    /// §8.5) ; `NOTIFY` et `ORCPT` gardés pour les avis.
    pub(super) async fn submission_rcpt(&mut self, rcpt: RcptTo) -> Flow {
        let Some(transaction) = &self.transaction else {
            return self.bad_sequence("Send MAIL first");
        };
        if transaction.accepted >= self.shared.config.max_recipients {
            self.io.reply(452, "4.5.3", "Too many recipients");
            self.shared.metrics.recipient_refused(RefusedReason::Limits);
            return Flow::Continue;
        }
        if !rcpt.forward_path.is_ascii() && !transaction.smtputf8 {
            self.io.response(&SmtpError::Utf8WithoutSmtpUtf8.response());
            self.error();
            return Flow::Continue;
        }
        // Ni route source, ni `postmaster` sans domaine, ni adresse littérale : aucun envoi
        // vers une adresse IP
        let address = match &rcpt.forward_path {
            _ if rcpt.source_route => None,
            ForwardPath::Postmaster => None,
            ForwardPath::Mailbox(mailbox) => match mailbox.domain() {
                // Partie locale gardée sous sa forme d'enveloppe (guillemets, échappements)
                Domain::Name(name) => to_ascii_domain(name)
                    .map(|domain| (mailbox.smtp_local_part(), domain)),
                Domain::Ipv4(_) | Domain::Ipv6(_) => None,
            },
        };
        let Some((local, domain)) = address else {
            self.io.reply(553, "5.1.3", "Invalid recipient address");
            self.shared
                .metrics
                .recipient_refused(RefusedReason::Unknown);
            self.error();
            return Flow::Continue;
        };
        let address = format!("{local}@{domain}");
        // Partie locale UTF-8 : aucune adresse de l'installation ne peut correspondre (S16)
        let resolved = if local.is_ascii() {
            self.shared
                .store
                .recipient_resolve(RecipientResolveParams {
                    address: address.clone(),
                })
                .await
                .map(Some)
        } else {
            Ok(None)
        };
        let address = match resolved {
            Ok(Some(resolved)) if resolved.kind == RecipientKind::Return => {
                return self.refuse_recipient(RefusedReason::Unknown).await
            }
            Ok(Some(resolved)) => resolved.address,
            Ok(None) => address,
            Err(error) => match business_code(&error) {
                // Domaine qui n'est pas celui d'une organisation de l'installation : envoi
                Some("MAIL_RELAY_DENIED") => address,
                Some("MAIL_RECIPIENT_UNKNOWN") => {
                    return self.refuse_recipient(RefusedReason::Unknown).await
                }
                Some("MAIL_RECIPIENT_DISABLED") => {
                    return self.refuse_recipient(RefusedReason::Disabled).await
                }
                Some("MAIL_INVALID_PARAMETERS") => {
                    self.io.reply(553, "5.1.3", "Invalid recipient address");
                    self.shared
                        .metrics
                        .recipient_refused(RefusedReason::Unknown);
                    return Flow::Continue;
                }
                _ => {
                    tracing::warn!(code = %MailError::from(error).code(), "résolution d'un destinataire en échec");
                    self.io
                        .reply(451, "4.3.0", "Temporary failure, try again later");
                    self.shared
                        .metrics
                        .recipient_refused(RefusedReason::Temporary);
                    return Flow::Continue;
                }
            },
        };
        let notify = rcpt.dsn_notify.map(|notify| {
            [
                (notify.never, DsnNotify::Never),
                (notify.success, DsnNotify::Success),
                (notify.failure, DsnNotify::Failure),
                (notify.delay, DsnNotify::Delay),
            ]
            .into_iter()
            .filter_map(|(set, word)| set.then_some(word))
            .collect::<Vec<_>>()
        });
        let orcpt = rcpt
            .dsn_orcpt
            .map(|orcpt| format!("{};{}", orcpt.address_type, orcpt.address));
        let Some(transaction) = self.transaction.as_mut() else {
            return Flow::Continue;
        };
        if !transaction
            .outbound
            .iter()
            .any(|known| known.address == address)
        {
            transaction.outbound.push(SubmissionRecipient {
                address,
                notify,
                orcpt,
            });
        }
        transaction.accepted += 1;
        self.shared.metrics.recipient_accepted();
        self.io.reply(250, "2.1.5", "Recipient OK");
        Flow::Continue
    }

    /// Fin des données du dépôt (plan §8.5) : lecture MIME, champs d'expéditeur permis,
    /// antivirus, `Received`, `Bcc` retiré, `Date` et `Message-ID` ajoutés, inscription dans la
    /// file ; `250` seulement après l'inscription.
    pub(super) async fn submit(
        &mut self,
        transaction: &Transaction,
        received: Bytes,
        mut memory: Option<MemoryReservation>,
    ) -> Flow {
        let Mode::Submission(submission) = &self.shared.mode else {
            return Flow::Continue;
        };
        let (metrics, antivirus, ingest) = (
            submission.metrics.clone(),
            submission.antivirus.clone(),
            submission.ingest.clone(),
        );
        let size = received.len() as u64;
        if parse_mime(&received, &MimeLimits::default()).is_err() {
            self.io.reply(554, "5.6.0", "Malformed message");
            self.refuse(RefusedReason::Malformed, size, 554);
            return Flow::Continue;
        }
        let Ok(headers) = MessageHeaders::parse(&received) else {
            self.io.reply(554, "5.6.0", "Malformed message header");
            self.refuse(RefusedReason::Malformed, size, 554);
            return Flow::Continue;
        };
        let senders = match sender_addresses(&headers) {
            Ok(senders) => senders,
            Err(SenderRefusal::Malformed) => {
                self.io.reply(
                    550,
                    "5.6.0",
                    "Message must have exactly one From header with valid addresses",
                );
                self.refuse(RefusedReason::Policy, size, 550);
                return Flow::Continue;
            }
            Err(SenderRefusal::Forbidden) => return self.spoofed(size),
            Err(SenderRefusal::TooMany) => {
                self.io.reply(550, "5.7.1", "Too many sender addresses");
                self.refuse(RefusedReason::Policy, size, 550);
                return Flow::Continue;
            }
        };
        if let Some(flow) = self.sender_refused(senders.clone(), size).await {
            return flow;
        }
        // Un compte compromis n'envoie pas un fichier infecté (plan §8.5, étape 4)
        match antivirus.scan(&received).await {
            ScanOutcome::Clean | ScanOutcome::NotScanned => {}
            ScanOutcome::Infected => {
                self.io
                    .reply(554, "5.7.1", "Message rejected: virus detected");
                self.refuse(RefusedReason::Antivirus, size, 554);
                return Flow::Continue;
            }
            ScanOutcome::Unavailable(code) => {
                tracing::warn!(code = %code, "antivirus injoignable : dépôt refusé à réessayer");
                self.io
                    .reply(451, "4.3.0", "Temporary failure, try again later");
                self.refuse(RefusedReason::Temporary, size, 451);
                return Flow::Continue;
            }
        }
        let store = match self.user_store().await {
            Ok(store) => store,
            Err(flow) => return flow,
        };
        let hostname = self.shared.config.hostname.clone();
        self.messages = self.messages.saturating_add(1);
        let id = format!("{}.{}", self.session_label(), self.messages);
        let date = rfc5322_date(SystemTime::now());
        let header = submission_received(
            self.helo.as_deref().unwrap_or("unknown"),
            &hostname,
            transaction.smtputf8,
            &id,
            &date,
        );
        // Copie à ranger (nos en-têtes, sans `Bcc`) : réservée avant d'être faite
        let needed = size
            .saturating_mul(2)
            .saturating_add(header.len() as u64 + 256);
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
            self.refuse(RefusedReason::Limits, size, 452);
            return Flow::Continue;
        }
        let prepared = Bytes::from(prepare_message(&headers, &header, &date, &hostname));
        drop(headers);
        let eight_bit = prepared.iter().any(|byte| *byte >= 0x80);
        let recipients = transaction.outbound.len();
        let params = SubmissionBeginParams {
            origin: Some(SubmissionOrigin::Submission),
            from: transaction.sender.clone(),
            header_from: senders,
            recipients: transaction.outbound.clone(),
            size: i64::try_from(prepared.len()).unwrap_or(i64::MAX),
            smtputf8: Some(transaction.smtputf8),
            eight_bit: Some(eight_bit),
            dsn: transaction.dsn.clone(),
            client_reference: None,
            return_token: None,
            prefix: None,
            forward: None,
            tenant: None,
        };
        let started = Instant::now();
        let queued = ingest.queue_submission(&store, params, prepared).await;
        self.shared
            .metrics
            .delivery_time(u64::try_from(started.elapsed().as_millis()).unwrap_or(u64::MAX));
        drop(memory);
        match queued {
            Ok(queued) => {
                metrics.queued(recipients as u64);
                self.shared.metrics.accepted();
                self.submission_log(recipients, size, "queued", 250);
                let identifier = queued.submission.to_sql();
                let identifier = identifier
                    .strip_prefix("mail_submission:")
                    .unwrap_or(&identifier)
                    .to_string();
                self.io
                    .reply(250, "2.0.0", &format!("Ok queued as {identifier}"));
                Flow::Continue
            }
            Err(error) => self.queue_refused(&error, recipients, size),
        }
    }

    /// Refus de l'inscription traduit en code SMTP (plan §8.2 à §8.4) ; toute panne : `451`.
    fn queue_refused(&mut self, error: &MailError, recipients: usize, size: u64) -> Flow {
        let code = error.code();
        let business = error.is_business();
        let (reply, status, text, reason, decision) = match code.as_str() {
            "MAIL_SENDER_FORBIDDEN" if business => {
                if let Some(metrics) = self.submission_metrics() {
                    metrics.spoofing();
                }
                (
                    550,
                    "5.7.1",
                    "Sender address not allowed",
                    RefusedReason::Policy,
                    "sender",
                )
            }
            "MAIL_PERMISSION_DENIED" | "MAIL_ACCOUNT_DISABLED" | "MAIL_ACCOUNT_DELETING"
                if business =>
            {
                (
                    550,
                    "5.7.1",
                    "Sending not allowed for this account",
                    RefusedReason::Policy,
                    "account",
                )
            }
            "MAIL_SEND_LIMIT_EXCEEDED" if business => (
                451,
                "4.7.1",
                "Sending limit exceeded, try again later",
                RefusedReason::Limits,
                "send_limit",
            ),
            "MAIL_SUBMISSION_TOO_MANY_RECIPIENTS" if business => (
                550,
                "5.5.3",
                "Too many recipients for this organization",
                RefusedReason::Limits,
                "recipients",
            ),
            "MAIL_MESSAGE_TOO_LARGE" if business => (
                552,
                "5.3.4",
                "Message size exceeds fixed maximum message size",
                RefusedReason::Size,
                "size",
            ),
            "MAIL_INVALID_PARAMETERS" if business => (
                550,
                "5.5.4",
                "Invalid message parameters",
                RefusedReason::Malformed,
                "parameters",
            ),
            _ => (
                451,
                "4.3.0",
                "Temporary failure, try again later",
                RefusedReason::Temporary,
                "temporary",
            ),
        };
        if reason == RefusedReason::Temporary {
            tracing::warn!(session = %self.session_label(), code = %code, "dépôt non inscrit : refus temporaire");
        }
        self.shared.metrics.refused(reason);
        self.submission_log(recipients, size, decision, reply);
        self.io.reply(reply, status, text);
        Flow::Continue
    }

    /// Ligne du journal d'un dépôt : session, nombre de destinataires, taille, décision, code ;
    /// ni adresse, ni sujet, ni contenu, ni compte.
    fn submission_log(&self, recipients: usize, size: u64, decision: &str, code: u16) {
        tracing::info!(
            session = %self.session_label(),
            network = %Network::masked(self.ip),
            recipients,
            size,
            decision,
            code,
            "dépôt authentifié"
        );
    }
}
