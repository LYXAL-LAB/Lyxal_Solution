// SPDX-License-Identifier: AGPL-3.0-only

//! Dépôt d'un message brut (RFC 5322) dans un dossier : le seul chemin d'écriture d'un message
//! (plan du lot 4, §3), utilisé tel quel par la remise SMTP (lot 5) et par `APPEND` (lot 8).
//!
//! 1. lecture MIME (`lyxal_mail_proto`), en mémoire réservée sur le budget des dépôts ;
//! 2. `fn::mail_content_begin` sous la session de l'appelant (droits, taille, quota) ;
//! 3. écriture chiffrée du fichier par `lyxal_storage` sous la session système de l'hôte, dans
//!    le bucket chiffré `lyxal-mail` de l'organisation (créé à la première écriture) ;
//! 4. `fn::mail_content_attach` sous la session système ;
//! 5. `fn::mail_message_create` sous la session de l'appelant.
//!
//! Le chiffrement est obligatoire (décision M1) : sans service de clés ni support, rien n'est
//! réservé ni écrit (`MAIL_CONTENT_UNAVAILABLE`, à réessayer), jamais en clair. Atomicité en cas
//! d'échec (aucun octet en clair n'est jamais rangé) :
//!
//! * écriture du fichier en échec (étape 3) : `lyxal_storage` retire ses octets et sa fiche ;
//! * refus du lien (étape 4) : le fichier, que rien ne référence, est supprimé aussitôt (ses
//!   octets chiffrés et sa clé scellée sont retirés par le nettoyage du stockage) ;
//! * refus de l'inscription (étape 5) : le contenu lié au fichier reste sans lecteur ; la
//!   maintenance le retire avec son fichier, dans la même transaction, à la fin de son délai
//!   d'une heure (`fn::mail_content_expire`). Le fichier ne peut pas être supprimé avant : il est
//!   référencé par le contenu (`STORAGE_OBJECT_IN_USE`) ;
//! * contenu réservé sans fichier : retiré par la maintenance à la fin de son délai.
//!
//! Une panne dont on ne sait pas si l'écriture a eu lieu (transport) ne fait rien supprimer :
//! la maintenance tranche (un contenu inscrit a un lecteur et reste). Une écriture refusée pour
//! conflit de transaction est rejouée, trois fois au plus.

use bytes::Bytes;
use lyxal_mail_proto::mime::{parse, MimeLimits};
use lyxal_storage::models::{BucketCreateParams, BucketListParams};
use lyxal_storage::{PutRequest, StorageService};
use lyxal_surreal::{LyxalSurrealError, ToSql};
use std::convert::Infallible;
use std::future::Future;
use std::time::Duration;

use crate::error::{MailError, MailResult};
use crate::mime::{message_params, DeliveryFlags};
use crate::models::{
    ContentAttachParams, ContentBeginParams, ContentReservation, MailDatetime, Message,
};
use crate::net::{MemoryBudget, MemoryClass};
use crate::store::MailStore;

/// Nom du bucket chiffré du courrier dans chaque organisation.
pub const MAIL_BUCKET: &str = "lyxal-mail";
/// Nom de fichier d'un message dans le stockage (sans donnée personnelle).
const FILE_NAME: &str = "message.eml";
/// Type annoncé d'un message.
const CONTENT_TYPE: &str = "message/rfc822";
/// Essais d'une écriture refusée pour conflit de transaction (le premier compris).
const CONFLICT_ATTEMPTS: u32 = 4;
/// Buckets lus au plus dans une organisation pour trouver celui du courrier.
const BUCKET_PAGE: i64 = 1_000;

/// Appel rejoué tant qu'il échoue sur un conflit de transaction (annulé par la base, sans
/// effet), trois fois au plus ; toute autre erreur est rendue telle quelle.
pub(crate) async fn retry_conflicts<T, F, Fut>(mut call: F) -> Result<T, LyxalSurrealError>
where
    F: FnMut() -> Fut,
    Fut: Future<Output = Result<T, LyxalSurrealError>>,
{
    let mut attempt = 1;
    loop {
        match call().await {
            Err(error) if attempt < CONFLICT_ATTEMPTS && error.is_transient_conflict() => {
                tokio::time::sleep(Duration::from_millis(u64::from(attempt) * 15)).await;
                attempt += 1;
            }
            other => return other,
        }
    }
}

/// Message à déposer.
#[derive(Debug, Clone)]
pub struct Delivery {
    /// Compte (`mail_account:<clé>`).
    pub account: String,
    /// Dossier du compte (`mail_mailbox:<clé>`).
    pub mailbox: String,
    /// Message brut (RFC 5322).
    pub raw: Bytes,
    /// Date interne (absente : maintenant).
    pub received_at: Option<MailDatetime>,
    /// Drapeaux et mots-clés.
    pub flags: DeliveryFlags,
}

/// Service de dépôt des messages.
#[derive(Clone)]
pub struct MailIngest {
    system: MailStore,
    storage: StorageService,
    backend: String,
    limits: MimeLimits,
    memory: Option<MemoryBudget>,
}

impl MailIngest {
    /// Dépôt sur la session système de l'hôte (`system`) et le stockage de l'hôte (`storage` :
    /// session système, supports et service de clés des buckets chiffrés). Le bucket du courrier
    /// d'une organisation est créé sur le support `backend` à sa première écriture.
    pub fn new(system: MailStore, storage: StorageService, backend: impl Into<String>) -> Self {
        Self {
            system,
            storage,
            backend: backend.into(),
            limits: MimeLimits::default(),
            memory: None,
        }
    }

    /// Limites de la lecture MIME (par défaut : 20 niveaux, 1 000 parties, 1 000 adresses).
    pub fn with_limits(mut self, limits: MimeLimits) -> Self {
        self.limits = limits;
        self
    }

    /// Réserve la mémoire de chaque dépôt (taille du message) sur ce budget ; un budget épuisé
    /// fait refuser le dépôt (`MAIL_CONTENT_UNAVAILABLE`, à réessayer).
    pub fn with_memory(mut self, budget: MemoryBudget) -> Self {
        self.memory = Some(budget);
        self
    }

    /// Vrai si un dépôt peut aboutir : au moins un support et le service de clés des fichiers.
    pub fn is_available(&self) -> bool {
        self.storage.is_configured() && self.storage.encryption_available()
    }

    /// Dépose un message au nom de l'appelant (`caller` : sa session, qui détermine ses droits)
    /// et rend le message inscrit.
    pub async fn deliver(&self, caller: &MailStore, delivery: Delivery) -> MailResult<Message> {
        if !self.storage.is_configured() {
            return Err(MailError::Unavailable(
                "aucun support de stockage configuré".to_string(),
            ));
        }
        if !self.storage.encryption_available() {
            return Err(MailError::Unavailable(
                "service de clés des fichiers absent (clé maîtresse du coffre-fort)".to_string(),
            ));
        }
        let size = u64::try_from(delivery.raw.len())
            .map_err(|_| MailError::Unavailable("message trop grand".to_string()))?;
        let _reservation = match &self.memory {
            Some(budget) => {
                let mut reservation = budget.reservation(MemoryClass::SmtpInbound, size);
                if reservation.try_reserve_within_limit(size).is_err() {
                    return Err(MailError::Unavailable(
                        "mémoire des dépôts épuisée".to_string(),
                    ));
                }
                Some(reservation)
            }
            None => None,
        };
        let parsed = parse(&delivery.raw, &self.limits)?;
        let declared = i64::try_from(size)
            .map_err(|_| MailError::Unavailable("message trop grand".to_string()))?;
        let begin = ContentBeginParams {
            account: delivery.account.clone(),
            size: declared,
            protection: None,
        };
        let reserved = retry_conflicts(|| caller.content_begin(begin.clone())).await?;
        let bucket = self.bucket(&reserved).await?;
        let raw = delivery.raw.clone();
        let object = self
            .storage
            .put(
                PutRequest {
                    bucket,
                    key: reserved.key.clone(),
                    filename: FILE_NAME.to_string(),
                    content_type: Some(CONTENT_TYPE.to_string()),
                    size: Some(size),
                },
                futures::stream::iter([Ok::<Bytes, Infallible>(raw)]),
            )
            .await?;
        let object_id = object.id.to_sql();
        let attach = ContentAttachParams {
            content: reserved.content.to_sql(),
            object: object_id.clone(),
        };
        if let Err(error) = retry_conflicts(|| self.system.content_attach(attach.clone())).await {
            return Err(self.abandon(&object_id, error.into()).await);
        }
        let params = message_params(
            &parsed,
            reserved.content.to_sql(),
            delivery.mailbox,
            delivery.received_at.unwrap_or_else(MailDatetime::now),
            delivery.flags,
        );
        // Inscription refusée : contenu et fichier retirés ensemble par la maintenance
        Ok(retry_conflicts(|| caller.message_create(params.clone())).await?)
    }

    /// Lien du fichier refusé : sur un refus de la base (le lien n'a pas eu lieu), le fichier,
    /// que rien ne référence, est supprimé ; sur une panne, il est laissé à la maintenance. Rend
    /// l'erreur d'origine ; un échec de la suppression est journalisé.
    async fn abandon(&self, object: &str, error: MailError) -> MailError {
        if error.is_business() {
            if let Err(removal) = self.storage.delete(object).await {
                tracing::warn!(object, code = %removal.code(), "fichier d'un dépôt refusé non supprimé : retiré par la maintenance");
            }
        }
        error
    }

    /// Bucket chiffré du courrier de l'organisation du contenu réservé, créé s'il n'existe pas.
    async fn bucket(&self, reserved: &ContentReservation) -> MailResult<String> {
        let tenant = Some(reserved.tenant.to_sql());
        if let Some(found) = self.find_bucket(&tenant, &reserved.bucket_name).await? {
            return Ok(found);
        }
        let created = self
            .storage
            .store()
            .bucket_create(BucketCreateParams {
                encrypted: true,
                backend: self.backend.clone(),
                description: Some("Messages du courrier (lyxal_mail)".to_string()),
                ..BucketCreateParams::named(tenant.clone(), reserved.bucket_name.clone())
            })
            .await;
        match created {
            Ok(bucket) => Ok(bucket.id.to_sql()),
            // Créé au même moment par un autre dépôt
            Err(error) if is_code(&error, "STORAGE_BUCKET_EXISTS") => self
                .find_bucket(&tenant, &reserved.bucket_name)
                .await?
                .ok_or_else(|| MailError::from(error)),
            Err(error) => Err(error.into()),
        }
    }

    async fn find_bucket(&self, tenant: &Option<String>, name: &str) -> MailResult<Option<String>> {
        let list = self
            .storage
            .store()
            .bucket_list(BucketListParams {
                tenant: tenant.clone(),
                limit: BUCKET_PAGE,
                start: 0,
            })
            .await?;
        Ok(list
            .items
            .into_iter()
            .find(|bucket| bucket.name == name)
            .map(|bucket| bucket.id.to_sql()))
    }
}

fn is_code(error: &LyxalSurrealError, code: &str) -> bool {
    matches!(error, LyxalSurrealError::Call(lyxal_surreal::LyxalCallError::Business(business)) if business.code == code)
}
