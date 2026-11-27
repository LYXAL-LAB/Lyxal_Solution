// SPDX-License-Identifier: AGPL-3.0-only

//! Réponses d'un serveur distant sur des octets quelconques (lot 6) : aucun arrêt quel que soit
//! le découpage (premier octet : taille des morceaux, bit de poids fort : codes étendus) ;
//! consommation jamais au-delà d'une réponse ; une réponse lue se réécrit puis se relit à
//! l'identique ; extensions de `EHLO` lues sans arrêt. Les octets d'entrée servent aussi de
//! contenu au bourrage de `DATA` : tout contenu accepté se relit par le serveur sans fin de
//! ligne isolée.

#![no_main]

use libfuzzer_sys::fuzz_target;
use lyxal_mail_proto::smtp::client::{DotStuffer, ReplyReader, ServerExtensions};
use lyxal_mail_proto::smtp::{DataReceiver, SmtpLimits};

fuzz_target!(|raw: &[u8]| {
    let Some((&split, input)) = raw.split_first() else {
        return;
    };
    let enhanced = split & 0x80 != 0;
    let chunk = usize::from(split & 0x7f).max(1);
    let mut reader = ReplyReader::new();
    reader.set_enhanced_status_codes(enhanced);
    for mut piece in input.chunks(chunk) {
        while !piece.is_empty() {
            let ingested = reader.ingest(piece);
            assert!(ingested.consumed > 0 && ingested.consumed <= piece.len());
            if let Some(Ok(reply)) = ingested.item {
                assert_eq!(piece[ingested.consumed - 1], b'\n');
                let _ = ServerExtensions::from_ehlo(&reply);
                let mut again = ReplyReader::new();
                again.set_enhanced_status_codes(enhanced && reply.status().is_some());
                let bytes = reply.to_bytes();
                let reread = again.ingest(&bytes);
                assert_eq!(reread.consumed, bytes.len());
                assert_eq!(reread.item, Some(Ok(reply)));
            }
            piece = &piece[ingested.consumed..];
        }
    }

    let mut stuffer = DotStuffer::new();
    let mut stuffed = Vec::new();
    let accepted = input
        .chunks(chunk)
        .all(|piece| stuffer.encode(piece, &mut stuffed).is_ok())
        && stuffer.finish(&mut stuffed).is_ok();
    if accepted {
        let mut receiver = DataReceiver::new(&SmtpLimits::default());
        let mut out = Vec::new();
        let ingested = receiver.ingest(&stuffed, &mut out);
        assert_eq!(ingested.consumed, stuffed.len());
        let outcome = ingested.item.expect("fin des données");
        assert_eq!(outcome.line_ending_error(), None);
        let mut expected = input.to_vec();
        if !expected.is_empty() && !expected.ends_with(b"\r\n") {
            expected.extend_from_slice(b"\r\n");
        }
        if !outcome.oversized {
            assert_eq!(out, expected);
        }
    }
});
