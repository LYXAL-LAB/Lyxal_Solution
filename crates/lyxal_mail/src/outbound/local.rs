// SPDX-License-Identifier: AGPL-3.0-only

//! Route locale : courrier vers un domaine de courrier actif de l'installation, quelle que soit
//! son organisation (plan du lot 6, §7 ; décision E24, écart X5).
//!
//! Le destinataire passe par la file comme les autres (limites, signature, tentatives, avis),
//! puis il est remis par le **chemin de réception commun avec le port 25** ([`Reception`] :
//! une analyse antivirus, chaîne du lot 5 — filtres, dossier, chiffrement,
//! `fn::mail_delivery_begin` / `_commit`, événement `mail.message.received` —, avis reçus,
//! transferts d'alias), sans connexion réseau. Résolution par `fn::mail_recipient_resolve` au
//! moment de la remise : inconnu, désactivé → échec définitif (`5.1.1`, `5.2.1`) ; quota plein →
//! nouvel essai (`4.2.2`), comme un serveur extérieur. Résultats de réception : `dkim` vérifié
//! par le vérificateur du lot 5 contre les clés actives du domaine expéditeur (servies depuis le
//! coffre-fort, sans DNS), `dmarc` calculé sur ce résultat (enregistrement DMARC lu par le
//! résolveur du nœud), `spf` et `iprev` `none`, `tls` vrai. Idempotence : l'empreinte de remise
//! du lot 5 (adresse inscrite, expéditeur, octets) rend une remise reprise sans doublon.
//!
//! * **Alias à cibles extérieures** (`forward_to`) : après la remise aux comptes de l'alias, le
//!   transfert est mis en file comme au port 25 (limite `forward_messages_per_day`, adresse de
//!   retour à jeton, clé d'idempotence : une remise reprise ne transfère pas deux fois).
//!   Réception d'origine gardée pour l'avis : adresse d'enveloppe de l'envoi (adresse de retour
//!   `rp=` tirée par notre worker), `spf` `none` (aucun contrôle SPF sur la route locale, comme
//!   dans `Authentication-Results`), `envelope_dkim` **vrai** : l'expéditeur est authentifié par
//!   l'installation elle-même (envoi déposé chez nous sous son adresse de retour), preuve au moins
//!   aussi forte qu'une signature DKIM de son domaine. `fn::mail_queue_dsn_wanted` rend donc l'avis
//!   d'un transfert en échec dû à l'expéditeur local ; expéditeur vide (avis) : aucun avis.
//! * **Adresse de retour** `rp=` d'un de nos envois (avis d'un transfert ci-dessus) : lue par
//!   [`crate::dsn::BounceProcessor`] comme au port 25 (avis inscrit, remis dans la boîte du
//!   compte expéditeur d'un dépôt authentifié), jamais réexpédiée.

use async_trait::async_trait;
use bytes::Bytes;
use std::collections::HashMap;
use std::net::{IpAddr, Ipv4Addr, Ipv6Addr};
use std::sync::Arc;
use std::time::SystemTime;

use crate::auth::{
    AuthenticationResults, DkimVerifier, DmarcDisposition, DmarcOutput, DmarcVerifier,
    MessageHeaders, OrganizationalDomain, SpfIdentity, SpfOutput, SpfResult,
};
use crate::delivery::{
    DeliveryPipeline, ForwardTarget, InboundMessage, ReceivedMessage, Reception, ReceptionResult,
    RecipientTarget,
};
use crate::dns::{Answer, DnsResult, MailResolver, MxRecord};
use crate::dsn::ReturnTarget;
use crate::models::{
    AttemptStage, ForwardReception, MailDatetime, RecipientKind, RecipientResolveParams,
};
use crate::outbound::OutboundMetrics;
use crate::smtp::{dkim_summary, dmarc_summary, rfc5322_date};
use crate::store::MailStore;
use lyxal_surreal::{LyxalCallError, LyxalSurrealError};

/// Issue de la route locale pour un destinataire.
#[derive(Clone, Debug, PartialEq, Eq)]
pub enum LocalOutcome {
    /// Remis (ou déjà remis).
    Delivered,
    /// Non remis.
    Failed {
        /// Échec définitif.
        permanent: bool,
        /// Code SMTP équivalent.
        code: u16,
        /// Code étendu.
        enhanced: &'static str,
    },
}

impl LocalOutcome {
    fn failed(permanent: bool, code: u16, enhanced: &'static str) -> Self {
        Self::Failed {
            permanent,
            code,
            enhanced,
        }
    }
}

/// Résolveur qui sert les enregistrements des clés DKIM connues, et le DNS du nœud pour le reste.
struct KnownKeys {
    records: HashMap<String, String>,
    inner: Arc<dyn MailResolver>,
}

#[async_trait]
impl MailResolver for KnownKeys {
    async fn txt(&self, name: &str) -> DnsResult<String> {
        let key = name.trim_end_matches('.').to_ascii_lowercase();
        match self.records.get(&key) {
            Some(record) => Ok(Answer {
                records: vec![record.clone()],
            }),
            None => self.inner.txt(name).await,
        }
    }
    async fn mx(&self, name: &str) -> DnsResult<MxRecord> {
        self.inner.mx(name).await
    }
    async fn ipv4(&self, name: &str) -> DnsResult<Ipv4Addr> {
        self.inner.ipv4(name).await
    }
    async fn ipv6(&self, name: &str) -> DnsResult<Ipv6Addr> {
        self.inner.ipv6(name).await
    }
    async fn ptr(&self, ip: IpAddr) -> DnsResult<String> {
        self.inner.ptr(ip).await
    }
}

/// Route locale du worker d'envoi.
#[derive(Clone)]
pub struct LocalRoute {
    store: MailStore,
    reception: Reception,
    metrics: Arc<OutboundMetrics>,
    resolver: Arc<dyn MailResolver>,
    organizational: Arc<dyn OrganizationalDomain>,
    hostname: String,
}

/// Message à remettre par la route locale.
pub struct LocalMessage<'a> {
    /// Envoi (identifiant, en-tête `Received`).
    pub submission: &'a str,
    /// Expéditeur de l'enveloppe (adresse de retour, vide pour `<>`).
    pub envelope_from: &'a str,
    /// Octets tels qu'envoyés (préfixe puis fichier).
    pub bytes: Bytes,
    /// L'envoi exige `SMTPUTF8` (repris par un transfert).
    pub smtputf8: bool,
    /// Enregistrements TXT des clés DKIM actives des domaines d'auteur
    /// (`<sélecteur>._domainkey.<domaine>` → `v=DKIM1; k=…; p=…`).
    pub dkim_records: HashMap<String, String>,
}

fn business_code(error: &LyxalSurrealError) -> Option<&str> {
    match error {
        LyxalSurrealError::Call(LyxalCallError::Business(business)) => Some(&business.code),
        _ => None,
    }
}

impl LocalRoute {
    /// Route sur la session système (`store`), la chaîne de remise du nœud, le résolveur du nœud
    /// et la liste des suffixes publics (DMARC) ; transferts et avis reçus comptés dans `metrics`.
    pub fn new(
        store: MailStore,
        pipeline: DeliveryPipeline,
        resolver: Arc<dyn MailResolver>,
        organizational: Arc<dyn OrganizationalDomain>,
        hostname: impl Into<String>,
        metrics: Arc<OutboundMetrics>,
    ) -> Self {
        Self {
            reception: Reception::new(store.clone(), pipeline),
            store,
            metrics,
            resolver,
            organizational,
            hostname: hostname.into(),
        }
    }

    /// Étape d'un résultat de la route locale.
    pub const STAGE: AttemptStage = AttemptStage::Local;

    /// Remet `message` aux destinataires `addresses` ; une issue par adresse, dans l'ordre.
    pub async fn deliver(
        &self,
        message: LocalMessage<'_>,
        addresses: &[String],
    ) -> Vec<LocalOutcome> {
        let size = message.bytes.len() as u64;
        let mut outcomes: Vec<Option<LocalOutcome>> = vec![None; addresses.len()];
        let mut targets: Vec<(usize, RecipientTarget)> = Vec::new();
        let mut returns: Vec<(usize, ReturnTarget)> = Vec::new();
        let mut forwards: Vec<ForwardTarget> = Vec::new();
        for (index, address) in addresses.iter().enumerate() {
            let resolved = self
                .store
                .recipient_resolve(RecipientResolveParams {
                    address: address.clone(),
                })
                .await;
            outcomes[index] = match resolved {
                Ok(resolved) if u64::try_from(resolved.max_message_bytes).unwrap_or(0) < size => {
                    Some(LocalOutcome::failed(true, 552, "5.3.4"))
                }
                Ok(resolved) if resolved.kind == RecipientKind::Return => {
                    match (resolved.submission, resolved.origin) {
                        (Some(submission), Some(origin)) => {
                            returns.push((
                                index,
                                ReturnTarget {
                                    address: resolved.address,
                                    tenant: resolved.tenant,
                                    submission,
                                    origin,
                                    account: resolved.account,
                                },
                            ));
                            None
                        }
                        _ => Some(LocalOutcome::failed(true, 550, "5.1.1")),
                    }
                }
                Ok(resolved) if resolved.accounts.iter().any(|account| account.quota_full) => {
                    Some(LocalOutcome::failed(false, 452, "4.2.2"))
                }
                Ok(resolved) => {
                    if !resolved.forward_to.is_empty()
                        && !forwards.iter().any(|known| known.alias == resolved.address)
                    {
                        forwards.push(ForwardTarget {
                            alias: resolved.address.clone(),
                            to: resolved.forward_to.clone(),
                        });
                    }
                    targets.push((
                        index,
                        RecipientTarget {
                            address: resolved.address,
                            tenant: resolved.tenant,
                            accounts: resolved.accounts.into_iter().map(|a| a.account).collect(),
                        },
                    ));
                    None
                }
                Err(error) => Some(match business_code(&error) {
                    Some("MAIL_RECIPIENT_UNKNOWN" | "MAIL_INVALID_PARAMETERS") => {
                        LocalOutcome::failed(true, 550, "5.1.1")
                    }
                    Some("MAIL_RECIPIENT_DISABLED") => LocalOutcome::failed(true, 550, "5.2.1"),
                    // Domaine retiré ou désactivé depuis la mise en file : réessayé
                    Some("MAIL_RELAY_DENIED") => LocalOutcome::failed(false, 451, "4.4.0"),
                    _ => LocalOutcome::failed(false, 451, "4.3.0"),
                }),
            };
        }
        if !targets.is_empty() || !returns.is_empty() {
            let returned: Vec<ReturnTarget> = returns.iter().map(|(_, r)| r.clone()).collect();
            let verdict = self
                .remit(
                    &message,
                    targets.iter().map(|(_, t)| t.clone()).collect(),
                    &returned,
                    &forwards,
                )
                .await;
            for index in targets
                .iter()
                .map(|(i, _)| i)
                .chain(returns.iter().map(|(i, _)| i))
            {
                outcomes[*index] = Some(verdict.clone());
            }
        }
        outcomes
            .into_iter()
            .map(|outcome| outcome.unwrap_or_else(|| LocalOutcome::failed(false, 451, "4.3.0")))
            .collect()
    }

    async fn remit(
        &self,
        message: &LocalMessage<'_>,
        targets: Vec<RecipientTarget>,
        returns: &[ReturnTarget],
        forwards: &[ForwardTarget],
    ) -> LocalOutcome {
        let Ok(headers) = MessageHeaders::parse(&message.bytes) else {
            return LocalOutcome::failed(true, 554, "5.6.0");
        };
        let Ok(parsed) = lyxal_mail_proto::mime::parse(
            &message.bytes,
            &lyxal_mail_proto::mime::MimeLimits::default(),
        ) else {
            return LocalOutcome::failed(true, 554, "5.6.0");
        };
        let resolver = KnownKeys {
            records: message.dkim_records.clone(),
            inner: self.resolver.clone(),
        };
        let dkim = DkimVerifier::new(&resolver).verify_headers(&headers).await;
        let domains = crate::auth::author_domains(&parsed.envelope);
        let spf = SpfOutput {
            result: SpfResult::None,
            identity: SpfIdentity::MailFrom,
            domain: None,
        };
        let dmarc = DmarcVerifier::new(&resolver, self.organizational.as_ref())
            .verify(&domains, &spf, &dkim)
            .await;
        drop(headers);
        // Politique DMARC du domaine destinataire appliquée comme pour un message reçu
        let disposition =
            DmarcOutput::combined_disposition(&dmarc, true, crate::auth::sample_roll());
        if disposition == DmarcDisposition::Reject {
            return LocalOutcome::failed(true, 550, "5.7.1");
        }
        let mut results = AuthenticationResults::new(&self.hostname);
        results.spf(&spf).dkim(&dkim).dmarc(&dmarc);
        let mut header = String::new();
        header.push_str(&format!("Return-Path: <{}>\r\n", message.envelope_from));
        header.push_str(&format!(
            "Received: by {} with LOCAL id {};\r\n\t{}\r\n",
            self.hostname,
            message.submission.trim_start_matches("mail_submission:"),
            rfc5322_date(SystemTime::now())
        ));
        header.push_str(&results.to_header());
        let mut stored = Vec::with_capacity(header.len() + message.bytes.len());
        stored.extend_from_slice(header.as_bytes());
        stored.extend_from_slice(&message.bytes);
        let received = ReceivedMessage {
            received: message.bytes.clone(),
            stored: Bytes::from(stored),
            sender: message.envelope_from.to_string(),
            recipients: targets,
            authentication: [
                SpfResult::None.as_str().to_string(),
                dkim_summary(&dkim),
                dmarc_summary(&dmarc),
                "none".to_string(),
            ],
            quarantine: disposition == DmarcDisposition::Quarantine,
            tls: true,
            received_at: MailDatetime::now(),
        };
        // Expéditeur de notre installation (adresse de retour de l'envoi) : authentifié
        let authenticated = !message.envelope_from.is_empty();
        let origin = ForwardReception {
            envelope_from: authenticated.then(|| message.envelope_from.to_string()),
            spf: SpfResult::None.as_str().to_string(),
            envelope_dkim: authenticated,
        };
        let result = self
            .reception
            .receive(InboundMessage {
                message: &received,
                parsed: &parsed,
                returns,
                forwards,
                origin,
                smtputf8: message.smtputf8,
            })
            .await;
        match result {
            ReceptionResult::Accepted {
                returns, forwards, ..
            } => {
                for _ in &returns {
                    self.metrics.returned();
                }
                for forward in forwards {
                    self.metrics.forwarded(forward);
                }
                LocalOutcome::Delivered
            }
            ReceptionResult::Rejected { .. } => LocalOutcome::failed(true, 554, "5.7.1"),
            ReceptionResult::TempFail { code, .. } if code == "MAIL_MESSAGE_TOO_LARGE" => {
                LocalOutcome::failed(true, 552, "5.3.4")
            }
            ReceptionResult::TempFail { code, served } => {
                tracing::info!(code = %code, served, "route locale : remise incomplète, nouvel essai");
                LocalOutcome::failed(false, 451, "4.3.0")
            }
        }
    }
}
