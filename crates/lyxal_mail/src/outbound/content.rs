// SPDX-License-Identifier: AGPL-3.0-only

//! Contenu d'un envoi en file (décision E29) : fichier chiffré du bucket `lyxal-mail` de
//! l'organisation, lu en flux par `lyxal_storage` (déchiffrement par segments de 64 Kio) sous la
//! session système de l'hôte. Un segment altéré met fin au flux par une erreur, jamais par une
//! fin normale.

use bytes::Bytes;
use futures::stream::BoxStream;
use futures::StreamExt;
use lyxal_storage::models::ObjectGetParams;
use lyxal_storage::StorageService;

use crate::error::{MailError, MailResult};

/// Flux des octets d'un contenu.
pub type ContentStream = BoxStream<'static, MailResult<Bytes>>;

/// Ouvre le fichier `object` (`storage_object:<clé>`) en flux.
pub async fn open(storage: &StorageService, object: &str) -> MailResult<ContentStream> {
    if !storage.encryption_available() {
        return Err(MailError::Unavailable(
            "service de clés des fichiers absent (clé maîtresse du coffre-fort)".to_string(),
        ));
    }
    let opened = storage
        .open(ObjectGetParams::by_id(object.to_string()), None)
        .await?;
    Ok(opened
        .content
        .map(|chunk| chunk.map_err(MailError::from))
        .boxed())
}

/// En-tête d'un message : octets jusqu'à la ligne vide comprise (`\r\n\r\n`), puis le reste du
/// premier morceau qui la contient. `max` octets d'en-tête au plus.
pub struct Head {
    /// En-tête, ligne vide comprise.
    pub header: Vec<u8>,
    /// Début du corps déjà lu.
    pub body_start: Vec<u8>,
    /// La ligne vide a été trouvée (sinon : en-tête trop long, ou message sans corps).
    pub complete: bool,
}

/// Lit l'en-tête de `stream` (au plus `max` octets).
pub async fn read_head(stream: &mut ContentStream, max: usize) -> MailResult<Head> {
    let mut header: Vec<u8> = Vec::new();
    while let Some(chunk) = stream.next().await {
        let chunk = chunk?;
        let start = header.len().saturating_sub(3);
        header.extend_from_slice(&chunk);
        if let Some(position) = header[start..]
            .windows(4)
            .position(|window| window == b"\r\n\r\n")
        {
            let end = start + position + 4;
            let body_start = header.split_off(end);
            return Ok(Head {
                header,
                body_start,
                complete: true,
            });
        }
        if header.len() > max {
            return Ok(Head {
                header,
                body_start: Vec::new(),
                complete: false,
            });
        }
    }
    Ok(Head {
        header,
        body_start: Vec::new(),
        complete: false,
    })
}
