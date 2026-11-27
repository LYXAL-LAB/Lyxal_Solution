// SPDX-License-Identifier: AGPL-3.0-only

//! Outils communs aux essais de la syntaxe SMTP : lecture d'un flux de commandes, lecture des
//! réponses du serveur par le lecteur du client.

#![allow(dead_code)]

use lyxal_mail_proto::smtp::client::ReplyReader;
use lyxal_mail_proto::smtp::{
    BdatReceiver, CommandReceiver, DataOutcome, DataReceiver, Request, Response, SmtpError,
    SmtpLimits,
};

/// Lit toutes les commandes complètes d'un flux, en morceaux de `chunk` octets au plus.
/// Rend les résultats et le nombre d'octets restés dans une ligne inachevée.
pub fn commands(input: &[u8], chunk: usize) -> (Vec<Result<Request, SmtpError>>, bool) {
    let mut receiver = CommandReceiver::new(&SmtpLimits::default());
    let mut results = Vec::new();
    for mut piece in input.chunks(chunk.max(1)) {
        while !piece.is_empty() {
            let ingested = receiver.ingest(piece);
            assert!(ingested.consumed <= piece.len());
            assert!(ingested.consumed > 0);
            piece = &piece[ingested.consumed..];
            if let Some(item) = ingested.item {
                results.push(item);
            }
        }
    }
    (results, receiver.has_partial_line())
}

/// Lit une seule commande complète.
pub fn command(line: &str) -> Result<Request, SmtpError> {
    let (mut results, partial) = commands(line.as_bytes(), usize::MAX);
    assert!(!partial, "ligne inachevée : {line:?}");
    assert_eq!(results.len(), 1, "{line:?}");
    results.remove(0)
}

/// Lit des données `DATA` en morceaux de `chunk` octets ; rend le contenu, le bilan et le nombre
/// d'octets consommés.
pub fn data(
    input: &[u8],
    chunk: usize,
    limits: &SmtpLimits,
) -> (Vec<u8>, Option<DataOutcome>, usize) {
    let mut receiver = DataReceiver::new(limits);
    let mut out = Vec::new();
    let mut consumed = 0;
    for piece in input.chunks(chunk.max(1)) {
        let ingested = receiver.ingest(piece, &mut out);
        assert!(ingested.consumed <= piece.len());
        consumed += ingested.consumed;
        if let Some(outcome) = ingested.item {
            return (out, Some(outcome), consumed);
        }
        assert_eq!(ingested.consumed, piece.len());
    }
    (out, None, consumed)
}

/// Lit des morceaux `BDAT` de tailles données dans un flux.
pub fn bdat(chunks: &[(&[u8], bool)], split: usize) -> (Vec<u8>, DataOutcome) {
    let mut receiver = BdatReceiver::new(&SmtpLimits::default());
    let mut out = Vec::new();
    let mut outcome = None;
    for (bytes, last) in chunks {
        receiver
            .start_chunk(bytes.len() as u64, *last)
            .expect("ordre des morceaux");
        let mut done = false;
        if bytes.is_empty() {
            let ingested = receiver.ingest(&[], &mut out);
            assert_eq!(ingested.consumed, 0);
            outcome = ingested.item.expect("morceau vide terminé");
            done = true;
        }
        for piece in bytes.chunks(split.max(1)) {
            let ingested = receiver.ingest(piece, &mut out);
            assert_eq!(ingested.consumed, piece.len());
            if let Some(item) = ingested.item {
                outcome = item;
                done = true;
            }
        }
        assert!(done);
    }
    (out, outcome.expect("dernier morceau"))
}

/// Lit une réponse complète par le lecteur du client ([`ReplyReader`], codes étendus lus) ;
/// exige que toute l'entrée soit consommée et qu'elle ne contienne que de l'ASCII imprimable et
/// des CRLF.
pub fn parse_reply(bytes: &[u8]) -> Response {
    assert!(
        bytes
            .iter()
            .all(|&b| (0x20..0x7f).contains(&b) || b == b'\r' || b == b'\n'),
        "{bytes:?}"
    );
    let mut reader = ReplyReader::new();
    reader.set_enhanced_status_codes(true);
    let ingested = reader.ingest(bytes);
    assert_eq!(ingested.consumed, bytes.len(), "{bytes:?}");
    ingested
        .item
        .expect("réponse complète")
        .expect("réponse lisible")
}
