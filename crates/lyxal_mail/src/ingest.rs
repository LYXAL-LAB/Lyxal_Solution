// SPDX-License-Identifier: AGPL-3.0-only

//! Dépôt d'un message brut (RFC 5322) dans un compte : les deux chemins d'écriture d'un message.
//!
//! **Dépôt par un titulaire** ([`MailIngest::deliver`], plan du lot 4, §3 ; `APPEND`, lot 8) :
//!
//! 1. lecture MIME (`lyxal_mail_proto`), en mémoire réservée sur le budget des dépôts ;
//! 2. `fn::mail_content_begin` sous la session de l'appelant (droits, taille, quota) ;
//! 3. écriture chiffrée du fichier par `lyxal_storage` sous la session système de l'hôte, dans
//!    le bucket chiffré `lyxal-mail` de l'organisation (créé à la première écriture) ;
//! 4. `fn::mail_content_attach` sous la session système ;
//! 5. `fn::mail_message_create` sous la session de l'appelant.
//!
//! **Remise d'un message reçu par SMTP** ([`MailIngest::receive`], plan du lot 5, §9 et §10.3),
//! sous la session système de l'hôte, en quatre allers-retours par compte au lieu de six :
//!
//! 1. lecture MIME, en mémoire réservée ;
//! 2. `fn::mail_delivery_begin` (compte, taille, quota, idempotence) : un message déjà remis à
//!    ce compte s'arrête ici, sans rien écrire ;
//! 3. écriture chiffrée du fichier par `lyxal_storage` ;
//! 4. `fn::mail_delivery_commit`, à son tour dans l'ordre du compte et groupée avec les remises
//!    qui attendent ([`AccountQueue`]) : lien du fichier, inscription, fiche d'idempotence,
//!    événement `mail.message.received`, en une transaction.
//!
//! Le chiffrement est obligatoire (décision M1) : sans service de clés ni support, rien n'est
//! réservé ni écrit (`MAIL_CONTENT_UNAVAILABLE`, à réessayer), jamais en clair. Atomicité en cas
//! d'échec (aucun octet en clair n'est jamais rangé) :
//!
//! * écriture du fichier en échec : `lyxal_storage` retire ses octets et sa fiche ;
//! * refus du lien (dépôt, étape 4) ou de l'élément du lot (remise, étape 4) : le fichier, que
//!   rien ne référence, est supprimé aussitôt (ses octets chiffrés et sa clé scellée sont retirés
//!   par le nettoyage du stockage) ;
//! * refus de l'inscription (dépôt, étape 5) : le contenu lié au fichier reste sans lecteur ; la
//!   maintenance le retire avec son fichier, dans la même transaction, à la fin de son délai
//!   d'une heure (`fn::mail_content_expire`). Le fichier ne peut pas être supprimé avant : il est
//!   référencé par le contenu (`STORAGE_OBJECT_IN_USE`) ;
//! * contenu réservé sans fichier : retiré par la maintenance à la fin de son délai.
//!
//! Une panne dont on ne sait pas si l'écriture a eu lieu (transport) ne fait rien supprimer :
//! la maintenance tranche (un contenu inscrit a un lecteur et reste). Une écriture refusée pour
//! conflit de transaction est rejouée, trois fois au plus.

use bytes::Bytes;
use lyxal_mail_proto::mime::{parse, MimeLimits, ParsedMessage};
use lyxal_storage::models::{Bucket, BucketCreateParams, BucketListParams};
use lyxal_storage::{PutRequest, StorageService};
use lyxal_surreal::{LyxalSurrealError, ToSql};
use std::collections::HashMap;
use std::convert::Infallible;
use std::future::Future;
use std::sync::atomic::{AtomicU64, Ordering};
use std::sync::{Arc, Mutex, PoisonError};
use std::time::Duration;

use crate::delivery::{AccountQueue, DeliveryOutcome, QueueStats};
use crate::error::{MailError, MailResult};
use crate::mime::{delivery_item, message_params, DeliveryFlags};
use crate::models::{
    ContentAttachParams, ContentBeginParams, DeliveryBeginParams, DeliveryReservation,
    DeliveryRole, MailDatetime, MailRecordId, Message, Reception,
};
use crate::net::{MemoryBudget, MemoryClass, MemoryReservation};
use crate::store::MailStore;

/// Nom du bucket chiffré du courrier dans chaque organisation.
pub const MAIL_BUCKET: &str = "lyxal-mail";
/// Nom de fichier d'un message dans le stockage (sans donnée personnelle).
const FILE_NAME: &str = "message.eml";
/// Type annoncé d'un message.
const CONTENT_TYPE: &str = "message/rfc822";
/// Essais d'une écriture refusée pour conflit de transaction (le premier compris).
const CONFLICT_ATTEMPTS: u32 = 4;
/// Buckets lus par page dans une organisation pour trouver celui du courrier.
const BUCKET_PAGE: i64 = 1_000;
/// Organisations dont le bucket du courrier est gardé en mémoire (au-delà : table vidée).
const KNOWN_BUCKETS: usize = 4_096;

/// Appel rejoué tant qu'il échoue sur un conflit de transaction (annulé par la base, sans
/// effet), trois fois au plus ; toute autre erreur est rendue telle quelle.
pub(crate) async fn retry_conflicts<T, F, Fut>(call: F) -> Result<T, LyxalSurrealError>
where
    F: FnMut() -> Fut,
    Fut: Future<Output = Result<T, LyxalSurrealError>>,
{
    retry_conflicts_counted(&AtomicU64::new(0), call).await
}

/// Comme [`retry_conflicts`] ; chaque conflit rejoué est compté dans `conflicts` (mesures).
pub(crate) async fn retry_conflicts_counted<T, F, Fut>(
    conflicts: &AtomicU64,
    mut call: F,
) -> Result<T, LyxalSurrealError>
where
    F: FnMut() -> Fut,
    Fut: Future<Output = Result<T, LyxalSurrealError>>,
{
    let mut attempt = 1;
    loop {
        match call().await {
            Err(error) if attempt < CONFLICT_ATTEMPTS && error.is_transient_conflict() => {
                conflicts.fetch_add(1, Ordering::Relaxed);
                tokio::time::sleep(Duration::from_millis(u64::from(attempt) * 15)).await;
                attempt += 1;
            }
            other => return other,
        }
    }
}

/// Message à déposer par son titulaire.
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

/// Message reçu par SMTP, à remettre à un compte destinataire.
#[derive(Debug, Clone)]
pub struct ReceivedDelivery {
    /// Compte destinataire (`mail_account:<clé>`, rendu par `fn::mail_recipient_resolve`).
    pub account: String,
    /// Organisation du compte (rendue par `fn::mail_recipient_resolve`).
    pub tenant: MailRecordId,
    /// Dossier de remise.
    pub role: DeliveryRole,
    /// Message brut à ranger (RFC 5322, nos en-têtes de réception compris).
    pub raw: Bytes,
    /// Date interne (absente : maintenant).
    pub received_at: Option<MailDatetime>,
    /// Empreinte d'idempotence ([`crate::delivery_key`]).
    pub delivery_key: String,
    /// Résultats des contrôles à la réception.
    pub reception: Reception,
}

/// Service de dépôt des messages.
#[derive(Clone)]
pub struct MailIngest {
    system: MailStore,
    storage: StorageService,
    backend: String,
    limits: MimeLimits,
    memory: Option<MemoryBudget>,
    queue: Arc<AccountQueue>,
    buckets: Arc<Mutex<HashMap<String, String>>>,
}

impl MailIngest {
    /// Dépôt sur la session système de l'hôte (`system`) et le stockage de l'hôte (`storage` :
    /// session système, supports et service de clés des buckets chiffrés). Le bucket du courrier
    /// d'une organisation est créé sur le support `backend` à sa première écriture.
    pub fn new(system: MailStore, storage: StorageService, backend: impl Into<String>) -> Self {
        Self {
            queue: Arc::new(AccountQueue::new(system.clone())),
            system,
            storage,
            backend: backend.into(),
            limits: MimeLimits::default(),
            memory: None,
            buckets: Arc::new(Mutex::new(HashMap::new())),
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

    /// Relevé de l'ordre des inscriptions des remises (lots, conflits rejoués).
    pub fn delivery_stats(&self) -> QueueStats {
        self.queue.stats()
    }

    /// Dépose un message au nom de l'appelant (`caller` : sa session, qui détermine ses droits)
    /// et rend le message inscrit.
    pub async fn deliver(&self, caller: &MailStore, delivery: Delivery) -> MailResult<Message> {
        let (size, declared, _reservation) = self.admit(&delivery.raw)?;
        let parsed = parse(&delivery.raw, &self.limits)?;
        let begin = ContentBeginParams {
            account: delivery.account.clone(),
            size: declared,
            protection: None,
        };
        let reserved = retry_conflicts(|| caller.content_begin(begin.clone())).await?;
        let object_id = self
            .write_file(
                &reserved.tenant,
                &reserved.bucket_name,
                &reserved.key,
                delivery.raw.clone(),
                size,
            )
            .await?;
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

    /// Remet un message reçu par SMTP à un compte, sous la session système : inscrit à son tour
    /// dans l'ordre du compte, avec les remises du même compte qui attendent. Un message déjà
    /// remis à ce compte (même empreinte) n'est ni écrit ni inscrit à nouveau.
    pub async fn receive(&self, delivery: ReceivedDelivery) -> MailResult<DeliveryOutcome> {
        let (size, declared, _reservation) = self.admit(&delivery.raw)?;
        let parsed = parse(&delivery.raw, &self.limits)?;
        self.receive_parsed(&parsed, size, declared, delivery).await
    }

    async fn receive_parsed(
        &self,
        parsed: &ParsedMessage,
        size: u64,
        declared: i64,
        delivery: ReceivedDelivery,
    ) -> MailResult<DeliveryOutcome> {
        let begin = DeliveryBeginParams {
            account: delivery.account.clone(),
            size: declared,
            delivery_key: delivery.delivery_key.clone(),
        };
        let (content, storage_key) =
            match retry_conflicts(|| self.system.delivery_begin(begin.clone())).await? {
                DeliveryReservation::Duplicate { message } => {
                    return Ok(DeliveryOutcome::Duplicate { message })
                }
                DeliveryReservation::Reserved {
                    content,
                    storage_key,
                } => (content, storage_key),
            };
        let object_id = self
            .write_file(
                &delivery.tenant,
                MAIL_BUCKET,
                &storage_key,
                delivery.raw.clone(),
                size,
            )
            .await?;
        let mut item = delivery_item(
            parsed,
            delivery.received_at.unwrap_or_else(MailDatetime::now),
            delivery.role,
            delivery.delivery_key,
            delivery.reception,
        );
        item.content = content.to_sql();
        item.object = object_id.clone();
        match self.queue.commit(&delivery.account, item).await {
            Ok(outcome) => Ok(outcome),
            Err(error) => Err(self.abandon(&object_id, error).await),
        }
    }

    /// Contrôles avant tout dépôt : support et service de clés présents, mémoire du message
    /// réservée sur le budget. Rend la taille du message et sa réservation.
    fn admit(&self, raw: &Bytes) -> MailResult<(u64, i64, Option<MemoryReservation>)> {
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
        let too_large = |_| MailError::Unavailable("message trop grand".to_string());
        let size = u64::try_from(raw.len()).map_err(too_large)?;
        let declared = i64::try_from(size).map_err(too_large)?;
        let reservation = match &self.memory {
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
        Ok((size, declared, reservation))
    }

    /// Écrit le fichier chiffré d'un message à la clé réservée, dans le bucket du courrier de
    /// l'organisation ; rend sa fiche (`storage_object:<clé>`). Un refus du stockage fait
    /// oublier le bucket gardé en mémoire (retiré ou remplacé entre-temps : relu au dépôt suivant).
    async fn write_file(
        &self,
        tenant: &MailRecordId,
        bucket_name: &str,
        key: &str,
        raw: Bytes,
        size: u64,
    ) -> MailResult<String> {
        let scope = tenant.to_sql();
        let bucket = self.bucket(&scope, bucket_name).await?;
        let written = self
            .storage
            .put(
                PutRequest {
                    bucket,
                    key: key.to_string(),
                    filename: FILE_NAME.to_string(),
                    content_type: Some(CONTENT_TYPE.to_string()),
                    size: Some(size),
                },
                futures::stream::iter([Ok::<Bytes, Infallible>(raw)]),
            )
            .await;
        match written {
            Ok(object) => Ok(object.id.to_sql()),
            Err(error) => {
                if error.is_business() {
                    self.known_buckets().remove(&scope);
                }
                Err(error.into())
            }
        }
    }

    /// Lien ou inscription refusés : sur un refus de la base (l'écriture n'a pas eu lieu), le
    /// fichier, que rien ne référence, est supprimé ; sur une panne, il est laissé à la
    /// maintenance. Rend l'erreur d'origine ; un échec de la suppression est journalisé.
    async fn abandon(&self, object: &str, error: MailError) -> MailError {
        if error.is_business() {
            if let Err(removal) = self.storage.delete(object).await {
                tracing::warn!(object, code = %removal.code(), "fichier d'un dépôt refusé non supprimé : retiré par la maintenance");
            }
        }
        error
    }

    fn known_buckets(&self) -> std::sync::MutexGuard<'_, HashMap<String, String>> {
        self.buckets.lock().unwrap_or_else(PoisonError::into_inner)
    }

    /// Bucket chiffré du courrier d'une organisation (`tenant` : `auth_organization:<clé>`),
    /// créé s'il n'existe pas ; gardé en mémoire du nœud après sa première lecture (un
    /// aller-retour de moins par dépôt). Un bucket de ce nom trouvé en clair (créé par ailleurs :
    /// le chiffrement est absent par défaut) fait refuser le dépôt avant toute écriture
    /// (`MAIL_CONTENT_UNAVAILABLE`) : aucun octet de message n'est jamais rangé en clair, et
    /// l'inscription vérifie à nouveau le bucket du fichier.
    async fn bucket(&self, tenant: &str, name: &str) -> MailResult<String> {
        if let Some(known) = self.known_buckets().get(tenant) {
            return Ok(known.clone());
        }
        let scope = Some(tenant.to_string());
        let bucket = match self.find_bucket(&scope, name).await? {
            Some(found) => encrypted_bucket(found)?,
            None => {
                let params = BucketCreateParams {
                    encrypted: true,
                    // Le courrier publie ses propres événements (`mail.message.*`), sans donnée
                    // personnelle : aucun `storage.object.*` pour ses fichiers (décision S14)
                    emit_events: false,
                    backend: self.backend.clone(),
                    description: Some("Messages du courrier (lyxal_mail)".to_string()),
                    ..BucketCreateParams::named(scope.clone(), name.to_string())
                };
                // Deux premiers dépôts simultanés d'une organisation : l'un crée le bucket,
                // l'autre, refusé pour conflit puis rejoué, le trouve déjà créé
                let created =
                    retry_conflicts(|| self.storage.store().bucket_create(params.clone())).await;
                match created {
                    Ok(bucket) => encrypted_bucket(bucket)?,
                    // Créé au même moment par un autre dépôt, ou par un autre appelant
                    Err(error) if is_code(&error, "STORAGE_BUCKET_EXISTS") => {
                        match self.find_bucket(&scope, name).await? {
                            Some(found) => encrypted_bucket(found)?,
                            None => return Err(error.into()),
                        }
                    }
                    Err(error) => return Err(error.into()),
                }
            }
        };
        let mut known = self.known_buckets();
        if known.len() >= KNOWN_BUCKETS {
            known.clear();
        }
        known.insert(tenant.to_string(), bucket.clone());
        Ok(bucket)
    }

    /// Bucket de ce nom dans la portée, cherché page par page jusqu'à la fin de la liste
    /// (`total` relu à chaque page ; une page vide arrête la lecture).
    async fn find_bucket(&self, tenant: &Option<String>, name: &str) -> MailResult<Option<Bucket>> {
        let mut start = 0;
        loop {
            let page = self
                .storage
                .store()
                .bucket_list(BucketListParams {
                    tenant: tenant.clone(),
                    limit: BUCKET_PAGE,
                    start,
                })
                .await?;
            let read = page.items.len();
            if let Some(found) = page.items.into_iter().find(|bucket| bucket.name == name) {
                return Ok(Some(found));
            }
            start += i64::try_from(read).unwrap_or(BUCKET_PAGE);
            if read == 0 || start >= page.total {
                return Ok(None);
            }
        }
    }
}

/// Identifiant du bucket du courrier s'il est chiffré ; un bucket en clair fait refuser le
/// dépôt (`MAIL_CONTENT_UNAVAILABLE`) avant toute écriture.
fn encrypted_bucket(bucket: Bucket) -> MailResult<String> {
    if bucket.encrypted {
        Ok(bucket.id.to_sql())
    } else {
        Err(MailError::Unavailable(
            "bucket du courrier de l'organisation non chiffré".to_string(),
        ))
    }
}

fn is_code(error: &LyxalSurrealError, code: &str) -> bool {
    matches!(error, LyxalSurrealError::Call(lyxal_surreal::LyxalCallError::Business(business)) if business.code == code)
}
