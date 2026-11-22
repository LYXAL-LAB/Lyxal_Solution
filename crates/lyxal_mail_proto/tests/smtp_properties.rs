// SPDX-License-Identifier: AGPL-3.0-only

//! Propriétés de la syntaxe SMTP : aucun arrêt sur des octets quelconques ; une commande par
//! LF, quel que soit le découpage ; la fin de `DATA` n'est reconnue que sur `CRLF.CRLF` et le
//! bilan (contenu, fins isolées) est celui d'un modèle simple ; aller-retour du bourrage ;
//! `BDAT` exact ; limite de ligne. `PROPTEST_CASES` augmente le nombre de cas.

use lyxal_mail_proto::smtp::{
    parse_command, BdatReceiver, CommandReceiver, DataReceiver, SmtpError, SmtpLimits,
};
use proptest::prelude::*;

/// Octets riches en caractères qui comptent pour SMTP.
fn smtp_bytes(max: usize) -> impl Strategy<Value = Vec<u8>> {
    prop::collection::vec(
        prop_oneof![
            4 => prop::sample::select(vec![b'\r', b'\n', b'.', b' ', b'<', b'>', b':', b'@', 0u8]),
            2 => prop::sample::select(b"MAILFROMRCPTDATABDATEHLOquit".to_vec()),
            1 => any::<u8>(),
        ],
        0..max,
    )
}

fn splits(max: usize) -> impl Strategy<Value = Vec<usize>> {
    prop::collection::vec(1usize..max, 1..8)
}

/// Découpe `input` selon les tailles données (cycliquement).
fn pieces<'a>(input: &'a [u8], sizes: &[usize]) -> Vec<&'a [u8]> {
    let mut out = Vec::new();
    let mut rest = input;
    let mut index = 0;
    while !rest.is_empty() {
        let take = sizes[index % sizes.len()].min(rest.len());
        out.push(&rest[..take]);
        rest = &rest[take..];
        index += 1;
    }
    out
}

/// Modèle de `DATA` : première occurrence de `CRLF.CRLF` dans `CRLF + input`.
fn model_end(input: &[u8]) -> Option<usize> {
    let mut stream = b"\r\n".to_vec();
    stream.extend_from_slice(input);
    stream
        .windows(5)
        .position(|window| window == b"\r\n.\r\n")
        .map(|index| index + 3)
}

/// Modèle du contenu : point de tête retiré au début de chaque ligne (après un vrai CRLF).
fn model_unstuff(body: &[u8]) -> Vec<u8> {
    let mut out = Vec::new();
    let mut line_start = true;
    for (index, &byte) in body.iter().enumerate() {
        if !(line_start && byte == b'.') {
            out.push(byte);
        }
        line_start = byte == b'\n' && index > 0 && body[index - 1] == b'\r';
    }
    out
}

fn model_bare(body: &[u8]) -> (bool, bool) {
    let bare_cr = body
        .iter()
        .enumerate()
        .any(|(index, &byte)| byte == b'\r' && body.get(index + 1) != Some(&b'\n'));
    let bare_lf = body
        .iter()
        .enumerate()
        .any(|(index, &byte)| byte == b'\n' && (index == 0 || body[index - 1] != b'\r'));
    (bare_cr, bare_lf)
}

proptest! {
    #[test]
    fn parse_command_never_panics(line in smtp_bytes(600)) {
        let _ = parse_command(&line);
    }

    #[test]
    fn one_result_per_line_whatever_the_split(input in smtp_bytes(2000), sizes in splits(64)) {
        let mut receiver = CommandReceiver::new(&SmtpLimits::default());
        let mut results = Vec::new();
        for mut piece in pieces(&input, &sizes) {
            while !piece.is_empty() {
                let ingested = receiver.ingest(piece);
                prop_assert!(ingested.consumed > 0 && ingested.consumed <= piece.len());
                if ingested.item.is_some() {
                    prop_assert_eq!(piece[ingested.consumed - 1], b'\n');
                }
                piece = &piece[ingested.consumed..];
                results.extend(ingested.item);
            }
        }
        let lines = input.iter().filter(|&&b| b == b'\n').count();
        prop_assert_eq!(results.len(), lines);
        prop_assert_eq!(receiver.has_partial_line(), !input.is_empty() && input.last() != Some(&b'\n'));

        // Même suite de résultats qu'en un seul morceau.
        let mut whole = CommandReceiver::new(&SmtpLimits::default());
        let mut rest = &input[..];
        let mut reference = Vec::new();
        while !rest.is_empty() {
            let ingested = whole.ingest(rest);
            rest = &rest[ingested.consumed..];
            reference.extend(ingested.item);
        }
        prop_assert_eq!(results, reference);
    }

    #[test]
    fn line_limit_is_exact(length in 500usize..700) {
        let limits = SmtpLimits::new(600, 1 << 20).map_err(|e| TestCaseError::fail(e.to_string()))?;
        let mut line = b"NOOP ".to_vec();
        line.resize(length - 2, b'x');
        line.extend_from_slice(b"\r\n");
        let mut receiver = CommandReceiver::new(&limits);
        let mut item = None;
        for piece in line.chunks(97) {
            let ingested = receiver.ingest(piece);
            prop_assert_eq!(ingested.consumed, piece.len());
            item = item.or(ingested.item);
        }
        let result = item.ok_or_else(|| TestCaseError::fail("ligne non terminée"))?;
        prop_assert_eq!(result.is_err(), length > 600);
        if length > 600 {
            prop_assert_eq!(result, Err(SmtpError::LineTooLong));
        }
    }

    #[test]
    fn data_matches_model(input in smtp_bytes(3000), sizes in splits(128)) {
        let mut receiver = DataReceiver::new(&SmtpLimits::default());
        let mut out = Vec::new();
        let mut consumed = 0;
        let mut outcome = None;
        for piece in pieces(&input, &sizes) {
            let ingested = receiver.ingest(piece, &mut out);
            consumed += ingested.consumed;
            if let Some(item) = ingested.item {
                outcome = Some(item);
                break;
            }
            prop_assert_eq!(ingested.consumed, piece.len());
        }
        match model_end(&input) {
            None => {
                prop_assert!(outcome.is_none());
                prop_assert_eq!(consumed, input.len());
            }
            Some(end) => {
                let outcome = outcome.ok_or_else(|| TestCaseError::fail("fin manquée"))?;
                prop_assert_eq!(consumed, end);
                let body = &input[..end - 3];
                prop_assert_eq!(&out, &model_unstuff(body));
                prop_assert_eq!(outcome.size, out.len() as u64);
                let (bare_cr, bare_lf) = model_bare(body);
                prop_assert_eq!(outcome.bare_cr, bare_cr);
                prop_assert_eq!(outcome.bare_lf, bare_lf);
                prop_assert_eq!(outcome.nul_byte, body.contains(&0));
            }
        }
    }

    #[test]
    fn dot_stuffing_round_trip(
        lines in prop::collection::vec(
            prop::collection::vec(
                prop_oneof![
                    1 => Just(b'.'),
                    3 => any::<u8>().prop_map(|b| if b == b'\r' || b == b'\n' { b'.' } else { b }),
                ],
                0..80,
            ),
            0..40,
        ),
        sizes in splits(64),
    ) {
        let mut original = Vec::new();
        let mut wire = Vec::new();
        for line in &lines {
            original.extend_from_slice(line);
            original.extend_from_slice(b"\r\n");
            if line.first() == Some(&b'.') {
                wire.push(b'.');
            }
            wire.extend_from_slice(line);
            wire.extend_from_slice(b"\r\n");
        }
        wire.extend_from_slice(b".\r\n");
        let mut receiver = DataReceiver::new(&SmtpLimits::default());
        let mut out = Vec::new();
        let mut outcome = None;
        let mut consumed = 0;
        for piece in pieces(&wire, &sizes) {
            let ingested = receiver.ingest(piece, &mut out);
            consumed += ingested.consumed;
            if ingested.item.is_some() {
                outcome = ingested.item;
            }
        }
        let outcome = outcome.ok_or_else(|| TestCaseError::fail("fin manquée"))?;
        prop_assert_eq!(consumed, wire.len());
        prop_assert_eq!(&out, &original);
        prop_assert_eq!(outcome.line_ending_error(), None);
    }

    #[test]
    fn bdat_is_exact(
        chunks in prop::collection::vec(smtp_bytes(300), 1..6),
        sizes in splits(64),
        trailer in smtp_bytes(40),
    ) {
        let mut receiver = BdatReceiver::new(&SmtpLimits::default());
        let mut out = Vec::new();
        let mut outcome = None;
        for (index, chunk) in chunks.iter().enumerate() {
            let last = index + 1 == chunks.len();
            receiver.start_chunk(chunk.len() as u64, last).map_err(|e| TestCaseError::fail(e.to_string()))?;
            let mut stream = chunk.clone();
            stream.extend_from_slice(&trailer);
            let mut done = false;
            let mut consumed = 0;
            if chunk.is_empty() {
                let ingested = receiver.ingest(&stream, &mut out);
                prop_assert_eq!(ingested.consumed, 0);
                outcome = ingested.item.flatten().or(outcome);
                done = ingested.item.is_some();
            }
            for piece in pieces(&stream, &sizes) {
                if done {
                    break;
                }
                let ingested = receiver.ingest(piece, &mut out);
                consumed += ingested.consumed;
                if let Some(item) = ingested.item {
                    done = true;
                    outcome = item.or(outcome);
                }
            }
            prop_assert!(done);
            if !chunk.is_empty() {
                prop_assert_eq!(consumed, chunk.len());
            }
        }
        let whole: Vec<u8> = chunks.concat();
        let outcome = outcome.ok_or_else(|| TestCaseError::fail("bilan manquant"))?;
        prop_assert_eq!(&out, &whole);
        prop_assert_eq!(outcome.size, whole.len() as u64);
        let (bare_cr, bare_lf) = model_bare(&whole);
        prop_assert_eq!(outcome.bare_cr, bare_cr);
        prop_assert_eq!(outcome.bare_lf, bare_lf);
    }
}
