// SPDX-License-Identifier: AGPL-3.0-only

//! Préparation d'un envoi à sa première réservation (plan du lot 6, §8.5, §12.3 ; décisions
//! E18, E20) : jamais avec les droits de l'utilisateur, sous la garde de la réservation
//! (`fn::mail_queue_prepare`).
//!
//! 1. lecture du fichier en flux : en-tête (256 Kio au plus), empreinte du corps canonisé
//!    `relaxed` (`lyxal_crypto::DkimBodyHasher`) ;
//! 2. contrôles : en-tête lisible, exactement un `From`, adresses du `From` égales à celles
//!    déclarées au dépôt (un module n'écrit jamais au nom d'un autre) ; sinon message illisible
//!    (`malformed` : destinataires en échec `5.6.0`) ;
//! 3. `Message-ID` et `Date` ajoutés s'ils manquent (RFC 6409 §8), dans le préfixe ;
//! 4. signatures DKIM des domaines d'auteur qui ont des clés actives (2 au plus ; sans clé, le
//!    message part non signé, compté) ;
//! 5. jeton de l'adresse de retour tiré par `OsRng` (sauf expéditeur vide).

use futures::StreamExt;
use lyxal_crypto::{DkimBodyHasher, DkimCanonicalization};
use lyxal_mail_proto::mime::{parse as parse_mime, AddressEntry, MimeLimits};
use lyxal_secrets::SecretsClient;
use lyxal_storage::StorageService;
use lyxal_surreal::ToSql;
use std::collections::BTreeSet;
use std::sync::Arc;
use std::time::{SystemTime, UNIX_EPOCH};

use crate::auth::{author_domains, MessageHeaders};
use crate::dkim::{sign_headers, DkimKeyCache, ReturnToken, SigningIdentity};
use crate::error::{MailError, MailResult};
use crate::models::{ClaimedRecipient, DkimSignersParams, DsnDue, QueuePrepareParams};
use crate::outbound::content;
use crate::smtp::rfc5322_date;
use crate::store::MailStore;

/// En-tête lu au plus pour la préparation.
pub const MAX_HEADER_BYTES: usize = 256 * 1024;
/// Domaines d'auteur signés au plus.
const MAX_SIGNED_DOMAINS: usize = 2;

/// Envoi préparé.
#[derive(Debug, Clone)]
pub struct Preparation {
    /// Préfixe rangé (signatures, en-têtes ajoutés), vide s'il n'y en a pas.
    pub prefix: String,
    /// Adresse d'enveloppe posée (adresse de retour), `None` pour `<>`.
    pub envelope_from: Option<String>,
    /// Message illisible : ses destinataires sont en échec.
    pub malformed: bool,
    /// Signatures DKIM posées.
    pub signatures: usize,
    /// Avis dus (message illisible).
    pub dsn: Vec<DsnDue>,
}

/// Préparation des envois.
#[derive(Clone)]
pub struct Preparer {
    store: MailStore,
    storage: StorageService,
    secrets: Option<SecretsClient>,
    keys: Arc<DkimKeyCache>,
    hostname: String,
}

fn addresses(entries: &[AddressEntry]) -> BTreeSet<String> {
    entries
        .iter()
        .flat_map(|entry| match entry {
            AddressEntry::Mailbox(address) => std::slice::from_ref(address).iter(),
            AddressEntry::Group { members, .. } => members.iter(),
        })
        .filter_map(|address| address.address.as_deref())
        .map(str::to_ascii_lowercase)
        .collect()
}

impl Preparer {
    /// Préparation sur la session système (`store`, `storage`), clés DKIM du coffre-fort
    /// `secrets` (absent : aucune clé lisible), cache `keys`, nom `hostname` (`Message-ID`).
    pub fn new(
        store: MailStore,
        storage: StorageService,
        secrets: Option<SecretsClient>,
        keys: Arc<DkimKeyCache>,
        hostname: impl Into<String>,
    ) -> Self {
        Self {
            store,
            storage,
            secrets,
            keys,
            hostname: hostname.into(),
        }
    }

    /// Identités de signature des domaines `domains` (clés actives) de l'organisation `tenant`.
    pub async fn identities(
        &self,
        tenant: &str,
        domains: &[String],
    ) -> MailResult<Vec<SigningIdentity>> {
        if domains.is_empty() {
            return Ok(Vec::new());
        }
        let signers = self
            .store
            .dkim_signers(DkimSignersParams {
                domains: domains.iter().take(MAX_SIGNED_DOMAINS).cloned().collect(),
            })
            .await?;
        if signers.items.is_empty() {
            return Ok(Vec::new());
        }
        let secrets = self.secrets.as_ref().ok_or_else(|| {
            MailError::Unavailable("coffre-fort sans clé maîtresse : clés DKIM illisibles".into())
        })?;
        let mut identities = Vec::with_capacity(signers.items.len());
        for signer in &signers.items {
            identities.push(SigningIdentity {
                domain: signer.domain.clone(),
                selector: signer.selector.clone(),
                key: self.keys.key(secrets, tenant, signer).await?,
            });
        }
        Ok(identities)
    }

    /// Prépare l'envoi de `item` (premier destinataire réservé de l'envoi) sous la réservation
    /// `claim`.
    pub async fn prepare(&self, claim: &str, item: &ClaimedRecipient) -> MailResult<Preparation> {
        let object = item
            .content
            .object
            .as_ref()
            .map(ToSql::to_sql)
            .ok_or_else(|| MailError::Unavailable("contenu d'un envoi non clos".into()))?;
        let mut stream = content::open(&self.storage, &object).await?;
        let head = content::read_head(&mut stream, MAX_HEADER_BYTES).await?;
        let mut hasher = DkimBodyHasher::new(DkimCanonicalization::Relaxed, None);
        hasher.update(&head.body_start);
        while let Some(chunk) = stream.next().await {
            hasher.update(&chunk?);
        }
        let body_hash = hasher.finish().digest;

        let mut malformed = !head.complete;
        let mut extra = String::new();
        let mut domains = Vec::new();
        if !malformed {
            match (
                MessageHeaders::parse(&head.header),
                parse_mime(&head.header, &MimeLimits::default()),
            ) {
                (Ok(headers), Ok(parsed)) => {
                    let declared: BTreeSet<String> = item
                        .header_from
                        .iter()
                        .map(|a| a.to_ascii_lowercase())
                        .collect();
                    if headers.count("From") != 1 || addresses(&parsed.envelope.from) != declared {
                        malformed = true;
                    } else {
                        domains = author_domains(&parsed.envelope);
                        let key = item.submission.to_sql();
                        if headers.count("Message-ID") == 0 {
                            extra.push_str(&format!(
                                "Message-ID: <{}@{}>\r\n",
                                key.trim_start_matches("mail_submission:"),
                                self.hostname
                            ));
                        }
                        if headers.count("Date") == 0 {
                            let created = u64::try_from(item.created_at.timestamp()).unwrap_or(0);
                            extra.push_str(&format!(
                                "Date: {}\r\n",
                                rfc5322_date(UNIX_EPOCH + std::time::Duration::from_secs(created))
                            ));
                        }
                    }
                }
                _ => malformed = true,
            }
        }
        let mut prefix = String::new();
        let mut signatures = 0;
        if !malformed {
            let identities = self.identities(&item.tenant.to_sql(), &domains).await?;
            if !identities.is_empty() {
                let mut combined = extra.clone().into_bytes();
                combined.extend_from_slice(&head.header);
                let headers = MessageHeaders::parse(&combined)
                    .map_err(|_| MailError::Unavailable("en-tête illisible".into()))?;
                let now = SystemTime::now()
                    .duration_since(UNIX_EPOCH)
                    .map(|elapsed| elapsed.as_secs())
                    .unwrap_or_default();
                prefix.push_str(&sign_headers(
                    &identities,
                    &headers.fields,
                    &body_hash,
                    now,
                )?);
                signatures = identities.len();
            }
            prefix.push_str(&extra);
        }
        // Jeton exigé pour tout expéditeur non vide, même d'un message illisible
        let token = match item.sender {
            Some(_) => Some(ReturnToken::generate()?),
            None => None,
        };
        let prepared = self
            .store
            .queue_prepare(QueuePrepareParams {
                claim: claim.to_string(),
                submission: item.submission.to_sql(),
                return_token: token.as_ref().map(|token| token.as_str().to_string()),
                prefix: (!prefix.is_empty()).then(|| prefix.clone()),
                malformed: Some(malformed),
            })
            .await?;
        Ok(Preparation {
            prefix,
            envelope_from: prepared.envelope_from,
            malformed,
            signatures,
            dsn: prepared.dsn,
        })
    }
}
