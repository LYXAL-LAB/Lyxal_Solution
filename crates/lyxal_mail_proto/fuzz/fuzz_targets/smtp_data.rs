// SPDX-License-Identifier: AGPL-3.0-only

//! `DATA` et `BDAT` sur des octets quelconques : aucun arrêt ; la fin de `DATA` n'est reconnue
//! qu'à la première occurrence de `CRLF.CRLF` (le CRLF de la commande compris) ; même résultat
//! quel que soit le découpage (premier octet : taille des morceaux) ; `BDAT` lit exactement la
//! taille annoncée.

#![no_main]

use libfuzzer_sys::fuzz_target;
use lyxal_mail_proto::smtp::{BdatReceiver, DataReceiver, SmtpLimits};

fn first_end(input: &[u8]) -> Option<usize> {
    let mut stream = b"\r\n".to_vec();
    stream.extend_from_slice(input);
    stream
        .windows(5)
        .position(|window| window == b"\r\n.\r\n")
        .map(|index| index + 3)
}

fuzz_target!(|raw: &[u8]| {
    let Some((&split, input)) = raw.split_first() else {
        return;
    };
    let chunk = usize::from(split).max(1);
    let limits = SmtpLimits::new(512, 1 << 20).unwrap_or_default();

    // DATA, en un morceau puis découpé.
    let mut whole = DataReceiver::new(&limits);
    let mut whole_out = Vec::new();
    let ingested = whole.ingest(input, &mut whole_out);
    match first_end(input) {
        Some(end) => {
            assert_eq!(ingested.consumed, end);
            assert!(ingested.item.is_some());
        }
        None => {
            assert_eq!(ingested.consumed, input.len());
            assert!(ingested.item.is_none());
        }
    }
    let mut pieces = DataReceiver::new(&limits);
    let mut pieces_out = Vec::new();
    let mut consumed = 0;
    let mut outcome = None;
    for piece in input.chunks(chunk) {
        let step = pieces.ingest(piece, &mut pieces_out);
        consumed += step.consumed;
        if step.item.is_some() {
            outcome = step.item;
            break;
        }
    }
    assert_eq!(consumed, ingested.consumed);
    assert_eq!(outcome, ingested.item);
    assert_eq!(pieces_out, whole_out);

    // BDAT : deux morceaux de la taille annoncée, suivis d'octets qui ne sont pas lus.
    let first = input.len() / 3;
    let second = input.len() / 3;
    let mut bdat = BdatReceiver::new(&limits);
    let mut out = Vec::new();
    let mut rest = input;
    for (size, last) in [(first, false), (second, true)] {
        assert!(bdat.start_chunk(size as u64, last).is_ok());
        let mut read = 0;
        loop {
            let take = rest.len().min(chunk);
            let step = bdat.ingest(&rest[..take], &mut out);
            read += step.consumed;
            rest = &rest[step.consumed..];
            if step.item.is_some() {
                break;
            }
            assert_eq!(step.consumed, take);
        }
        assert_eq!(read, size);
    }
    // Au-delà de la taille maximale du message, le receveur compte les octets sans les garder :
    // seul le début, jusqu'à cette taille, est rendu.
    let limit = usize::try_from(limits.max_message_bytes()).unwrap_or(usize::MAX);
    let kept = (first + second).min(limit);
    assert_eq!(out, &input[..kept]);
});
