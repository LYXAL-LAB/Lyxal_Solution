// SPDX-License-Identifier: AGPL-3.0-only

//! Route locale : courrier vers un domaine de courrier actif de l'installation, quelle que soit
//! son organisation (plan du lot 6, §7 ; décision E24, écart X5).
//!
//! Le destinataire passe par la file comme les autres (limites, signature, tentatives, avis),
//! puis il est remis par la **chaîne de réception du lot 5** ([`DeliveryPipeline`] : antivirus,
//! filtres, dossier, chiffrement, `fn::mail_delivery_begin` / `_commit`, événement
//! `mail.message.received`), sans connexion réseau. Résolution par `fn::mail_recipient_resolve`
//! au moment de la remise : inconnu, désactivé → échec définitif (`5.1.1`, `5.2.1`) ; quota
//! plein → nouvel essai (`4.2.2`), comme un serveur extérieur. Résultats de réception : `dkim`
//! vérifié par le vérificateur du lot 5 contre les clés actives du domaine expéditeur (servies
//! depuis le coffre-fort, sans DNS), `dmarc` calculé sur ce résultat (enregistrement DMARC lu
//! par le résolveur du nœud), `spf` et `iprev` `none`, `tls` vrai. Idempotence : l'empreinte de
//! remise du lot 5 (adresse inscrite, expéditeur, octets) rend une remise reprise sans doublon.

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
use crate::delivery::{DeliveryPipeline, PipelineResult, ReceivedMessage, RecipientTarget};
use crate::dns::{Answer, DnsResult, MailResolver, MxRecord};
use crate::models::{AttemptStage, MailDatetime, RecipientKind, RecipientResolveParams};
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
    pipeline: DeliveryPipeline,
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
    /// et la liste des suffixes publics (DMARC).
    pub fn new(
        store: MailStore,
        pipeline: DeliveryPipeline,
        resolver: Arc<dyn MailResolver>,
        organizational: Arc<dyn OrganizationalDomain>,
        hostname: impl Into<String>,
    ) -> Self {
        Self {
            store,
            pipeline,
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
        for (index, address) in addresses.iter().enumerate() {
            let resolved = self
                .store
                .recipient_resolve(RecipientResolveParams {
                    address: address.clone(),
                })
                .await;
            outcomes[index] = match resolved {
                Ok(resolved) if resolved.kind == RecipientKind::Return => {
                    Some(LocalOutcome::failed(true, 550, "5.1.1"))
                }
                Ok(resolved) if u64::try_from(resolved.max_message_bytes).unwrap_or(0) < size => {
                    Some(LocalOutcome::failed(true, 552, "5.3.4"))
                }
                Ok(resolved) if resolved.accounts.iter().any(|account| account.quota_full) => {
                    Some(LocalOutcome::failed(false, 452, "4.2.2"))
                }
                Ok(resolved) => {
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
        if !targets.is_empty() {
            let verdict = self
                .remit(&message, targets.iter().map(|(_, t)| t.clone()).collect())
                .await;
            for (index, _) in &targets {
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
    ) -> LocalOutcome {
        let Ok(headers) = MessageHeaders::parse(&message.bytes) else {
            return LocalOutcome::failed(true, 554, "5.6.0");
        };
        let resolver = KnownKeys {
            records: message.dkim_records.clone(),
            inner: self.resolver.clone(),
        };
        let dkim = DkimVerifier::new(&resolver).verify_headers(&headers).await;
        let domains = lyxal_mail_proto::mime::parse(
            &message.bytes,
            &lyxal_mail_proto::mime::MimeLimits::default(),
        )
        .map(|parsed| crate::auth::author_domains(&parsed.envelope))
        .unwrap_or_default();
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
        match self.pipeline.deliver(&received).await {
            PipelineResult::Delivered { .. } => LocalOutcome::Delivered,
            PipelineResult::Rejected { .. } => LocalOutcome::failed(true, 554, "5.7.1"),
            PipelineResult::TempFail { code, .. } if code == "MAIL_MESSAGE_TOO_LARGE" => {
                LocalOutcome::failed(true, 552, "5.3.4")
            }
            PipelineResult::TempFail { code, served } => {
                tracing::info!(code = %code, served, "route locale : remise incomplète, nouvel essai");
                LocalOutcome::failed(false, 451, "4.3.0")
            }
        }
    }
}
