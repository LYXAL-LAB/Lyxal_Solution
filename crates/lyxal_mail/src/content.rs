// SPDX-License-Identifier: AGPL-3.0-only

//! Lecture du contenu d'un message, en entier ou par plage d'octets du message brut (une partie
//! MIME par ses positions, IMAP `BODY[...]<début.taille>`).
//!
//! `fn::mail_content_open` contrôle les droits de l'appelant (titulaire du compte, compte de
//! service) et désigne le fichier ; `lyxal_storage` le lit ensuite sous la session système de
//! l'hôte et ne déchiffre que les segments de la plage demandée. Un segment altéré met fin au
//! flux par une erreur (`STORAGE_INTEGRITY_FAILED`) que l'appelant ne doit jamais présenter
//! comme une fin normale (il ferme la connexion).

use bytes::Bytes;
use futures::stream::BoxStream;
use futures::StreamExt;
use lyxal_storage::models::ObjectGetParams;
use lyxal_storage::{ByteRange, StorageService};
use lyxal_surreal::ToSql;
use std::ops::Range;

use crate::error::{MailError, MailResult};
use crate::models::{ContentLocation, MessageRefParams};
use crate::store::MailStore;

/// Contenu ouvert : ce que dit la base du fichier, la plage servie et ses octets en clair.
pub struct OpenedContent {
    /// Fichier, taille et protection du contenu.
    pub location: ContentLocation,
    /// Plage d'octets servie (dans le message en clair).
    pub range: Range<u64>,
    /// Octets de la plage ; une erreur met fin au flux (jamais une fin normale).
    pub content: BoxStream<'static, MailResult<Bytes>>,
}

/// Service de lecture des messages.
#[derive(Clone)]
pub struct MailContent {
    storage: StorageService,
}

impl MailContent {
    /// Lecture par le stockage de l'hôte (`storage` : session système, supports et service de
    /// clés des buckets chiffrés).
    pub fn new(storage: StorageService) -> Self {
        Self { storage }
    }

    /// Ouvre le contenu d'un message (`message` : `mail_message:<clé>`) au nom de l'appelant
    /// (`caller`), en entier ou sur la plage `range`.
    pub async fn open(
        &self,
        caller: &MailStore,
        message: &str,
        range: Option<ByteRange>,
    ) -> MailResult<OpenedContent> {
        let location = caller
            .content_open(MessageRefParams {
                message: message.to_string(),
            })
            .await?;
        if !self.storage.encryption_available() {
            return Err(MailError::Unavailable(
                "service de clés des fichiers absent (clé maîtresse du coffre-fort)".to_string(),
            ));
        }
        let opened = self
            .storage
            .open(ObjectGetParams::by_id(location.object.to_sql()), range)
            .await?;
        Ok(OpenedContent {
            location,
            range: opened.range,
            content: opened
                .content
                .map(|chunk| chunk.map_err(MailError::from))
                .boxed(),
        })
    }

    /// Lit tout le contenu d'un message (ou la plage `range`) en mémoire. Pour un petit
    /// message ou une partie ; un grand message se lit en flux (`open`).
    pub async fn read(
        &self,
        caller: &MailStore,
        message: &str,
        range: Option<ByteRange>,
    ) -> MailResult<Vec<u8>> {
        let mut opened = self.open(caller, message, range).await?;
        let mut bytes = Vec::new();
        while let Some(chunk) = opened.content.next().await {
            bytes.extend_from_slice(&chunk?);
        }
        Ok(bytes)
    }
}
