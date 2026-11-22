// SPDX-License-Identifier: AGPL-3.0-only

//! Lecture de `DATA` et de `BDAT` : bourrage, fin `CRLF.CRLF` seule, fins de ligne isolées et
//! variantes de contrebande SMTP (décision S7), taille maximale, octet nul.

mod smtp_support;

use lyxal_mail_proto::smtp::{BdatReceiver, BdatStateError, DataOutcome, SmtpError, SmtpLimits};
use smtp_support::{bdat, data};

fn read_all(input: &[u8]) -> (Vec<u8>, DataOutcome, usize) {
    let limits = SmtpLimits::default();
    let (reference, outcome, consumed) = data(input, usize::MAX, &limits);
    let outcome = outcome.unwrap_or_else(|| panic!("fin non reconnue : {input:?}"));
    // Même résultat quel que soit le découpage.
    for chunk in 1..=input.len().min(64) {
        let (out, other, used) = data(input, chunk, &limits);
        assert_eq!(out, reference, "morceaux de {chunk}");
        assert_eq!(other, Some(outcome), "morceaux de {chunk}");
        assert_eq!(used, consumed, "morceaux de {chunk}");
    }
    (reference, outcome, consumed)
}

fn not_ended(input: &[u8]) {
    for chunk in 1..=input.len().max(1) {
        let (_, outcome, consumed) = data(input, chunk, &SmtpLimits::default());
        assert_eq!(outcome, None, "{input:?}");
        assert_eq!(consumed, input.len());
    }
}

#[test]
fn simple_message() {
    let input = b"From: a@b.example\r\nSubject: test\r\n\r\nHello\r\n.\r\n";
    let (out, outcome, consumed) = read_all(input);
    assert_eq!(out, b"From: a@b.example\r\nSubject: test\r\n\r\nHello\r\n");
    assert_eq!(consumed, input.len());
    assert_eq!(outcome.size, out.len() as u64);
    assert!(!outcome.oversized);
    assert_eq!(outcome.line_ending_error(), None);
    assert!(!outcome.nul_byte);
}

#[test]
fn empty_message() {
    // La fin suit directement le CRLF de la commande DATA.
    let (out, outcome, consumed) = read_all(b".\r\n");
    assert!(out.is_empty());
    assert_eq!(outcome.size, 0);
    assert_eq!(consumed, 3);
}

#[test]
fn dot_unstuffing() {
    let (out, outcome, _) = read_all(b"..leading\r\n...\r\nmid.dle\r\n.x\r\n..\r\n.\r\n");
    assert_eq!(out, b".leading\r\n..\r\nmid.dle\r\nx\r\n.\r\n");
    assert_eq!(outcome.line_ending_error(), None);
    let (out, _, _) = read_all(b"..\r\n.\r\n");
    assert_eq!(out, b".\r\n");
}

#[test]
fn stops_at_first_end() {
    let input = b"a\r\n.\r\nMAIL FROM:<x@y.z>\r\n";
    let (out, _, consumed) = read_all(input);
    assert_eq!(out, b"a\r\n");
    assert_eq!(consumed, 6);
}

/// Variantes de contrebande SMTP (décembre 2023) : aucune n'est une fin, toutes sont signalées.
#[test]
fn smuggling_variants_are_not_ends() {
    let variants: &[(&[u8], Option<SmtpError>)] = &[
        (b"\n.\n", Some(SmtpError::BareLf)),
        (b"\n.\r\n", Some(SmtpError::BareLf)),
        (b"\r\n.\n", Some(SmtpError::BareLf)),
        (b"\r.\r", Some(SmtpError::BareCr)),
        (b"\r\n.\r", Some(SmtpError::BareCr)),
        (b"\r.\r\n", Some(SmtpError::BareCr)),
        (b"\r\n.\r\r\n", Some(SmtpError::BareCr)),
        // Octet nul avant ou après le point : pas une fin ; signalé par `nul_byte`.
        (b"\r\n\0.\r\n", None),
        (b"\r\n.\0\r\n", None),
    ];
    let smuggled = b"MAIL FROM:<evil@x.example>\r\nRCPT TO:<victim@y.example>\r\nDATA\r\n";
    for (fake_end, error) in variants {
        let mut input = b"Subject: hi\r\n\r\nbody".to_vec();
        input.extend_from_slice(fake_end);
        input.extend_from_slice(smuggled);
        not_ended(&input);
        input.extend_from_slice(b".\r\n");
        let (out, outcome, consumed) = read_all(&input);
        assert_eq!(consumed, input.len(), "{fake_end:?}");
        assert_eq!(outcome.line_ending_error(), *error, "{fake_end:?}");
        if error.is_none() {
            assert!(outcome.nul_byte, "{fake_end:?}");
        }
        assert!(out.ends_with(b"DATA\r\n"), "{fake_end:?}");
    }
}

#[test]
fn smuggling_flags() {
    let (_, outcome, _) = read_all(b"a\n.\nb\r\n.\r\n");
    assert!(outcome.bare_lf);
    assert!(!outcome.bare_cr);
    assert_eq!(outcome.line_ending_error(), Some(SmtpError::BareLf));

    let (_, outcome, _) = read_all(b"a\r.\rb\r\n.\r\n");
    assert!(outcome.bare_cr);
    assert_eq!(outcome.line_ending_error(), Some(SmtpError::BareCr));

    let (out, outcome, _) = read_all(b"a\r\n\0.\r\nb\r\n.\r\n");
    assert!(outcome.nul_byte);
    assert_eq!(outcome.line_ending_error(), None);
    assert_eq!(out, b"a\r\n\0.\r\nb\r\n");

    // Un LF isolé loin d'un point est aussi refusé (décision S7, plus strict que Mox).
    let (out, outcome, _) = read_all(b"line one\nline two\r\n.\r\n");
    assert!(outcome.bare_lf);
    assert_eq!(out, b"line one\nline two\r\n");

    // Point en début de ligne suivi d'un CR isolé : bourrage retiré, CR gardé et signalé.
    let (out, outcome, _) = read_all(b".\rx\r\n.\r\n");
    assert!(outcome.bare_cr);
    assert_eq!(out, b"\rx\r\n");
    let (out, outcome, _) = read_all(b".\r\r\n.\r\n");
    assert!(outcome.bare_cr);
    assert_eq!(out, b"\r\r\n");
    let (_, outcome, _) = read_all(b"x\r\r\r\n.\r\n");
    assert!(outcome.bare_cr);
}

#[test]
fn incomplete_ends() {
    for input in [
        &b"a\r\n."[..],
        b"a\r\n.\r",
        b"a\r\n",
        b"",
        b"a\n.\n",
        b"\r\n.\n",
        b"a.\r\n",
    ] {
        not_ended(input);
    }
}

#[test]
fn oversized_message_is_read_but_not_kept() {
    let limits = SmtpLimits::new(4096, 1 << 20).expect("limites");
    let line = vec![b'x'; 998];
    let mut input = Vec::new();
    while input.len() < (3 << 20) {
        input.extend_from_slice(&line);
        input.extend_from_slice(b"\r\n");
    }
    let body_len = input.len() as u64;
    input.extend_from_slice(b".\r\nQUIT\r\n");
    let (out, outcome, consumed) = data(&input, 65_536, &limits);
    let outcome = outcome.expect("fin");
    assert!(outcome.oversized);
    assert_eq!(outcome.size, body_len);
    assert!(out.len() as u64 <= 1 << 20);
    assert_eq!(consumed, input.len() - 6);
}

#[test]
fn exact_limit_is_kept() {
    let limits = SmtpLimits::new(4096, 1 << 20).expect("limites");
    let mut body = vec![b'y'; (1 << 20) - 2];
    body.extend_from_slice(b"\r\n");
    let mut input = body.clone();
    input.extend_from_slice(b".\r\n");
    let (out, outcome, _) = data(&input, 4096, &limits);
    let outcome = outcome.expect("fin");
    assert!(!outcome.oversized);
    assert_eq!(out, body);
}

#[test]
fn bdat_chunks() {
    let (out, outcome) = bdat(&[(b"Subject: x\r\n\r\n", false), (b"body\r\n", true)], 3);
    assert_eq!(out, b"Subject: x\r\n\r\nbody\r\n");
    assert_eq!(outcome.size, out.len() as u64);
    assert_eq!(outcome.line_ending_error(), None);

    // Pas de bourrage en BDAT : un point en tête est gardé, "CRLF.CRLF" n'est pas une fin.
    let (out, outcome) = bdat(&[(b"a\r\n.\r\nb\r\n", true)], 1);
    assert_eq!(out, b"a\r\n.\r\nb\r\n");
    assert_eq!(outcome.line_ending_error(), None);

    // CRLF coupé entre deux morceaux : valide.
    let (_, outcome) = bdat(&[(b"a\r", false), (b"\nb\r\n", true)], 1);
    assert_eq!(outcome.line_ending_error(), None);

    // Fins isolées, y compris aux frontières de morceaux et à la toute fin.
    for chunks in [
        vec![(&b"a\nb\r\n"[..], true)],
        vec![(&b"a\r"[..], false), (&b"b\r\n"[..], true)],
        vec![(&b"a\r\n"[..], false), (&b"\n"[..], true)],
        vec![(&b"a\r\nb\r"[..], true)],
        vec![(&b"a\r"[..], false), (&b""[..], true)],
    ] {
        let (_, outcome) = bdat(&chunks, 1);
        assert!(outcome.line_ending_error().is_some(), "{chunks:?}");
    }

    // BDAT 0 LAST après des morceaux.
    let (out, outcome) = bdat(&[(b"x\r\n", false), (b"", true)], 2);
    assert_eq!(out, b"x\r\n");
    assert_eq!(outcome.size, 3);

    // Octet nul relevé.
    let (_, outcome) = bdat(&[(b"a\0b\r\n", true)], 2);
    assert!(outcome.nul_byte);
}

#[test]
fn bdat_order_and_limits() {
    let limits = SmtpLimits::new(4096, 1 << 20).expect("limites");
    let mut receiver = BdatReceiver::new(&limits);
    receiver.start_chunk(10, false).expect("premier morceau");
    assert_eq!(
        receiver.start_chunk(5, false),
        Err(BdatStateError::ChunkInProgress)
    );
    let mut out = Vec::new();
    let ingested = receiver.ingest(b"0123456789REST", &mut out);
    assert_eq!(ingested.consumed, 10);
    assert_eq!(ingested.item, Some(None));
    receiver
        .start_chunk((2 << 20) as u64, true)
        .expect("dernier");
    let block = vec![b'z'; 1 << 16];
    let mut outcome = None;
    for _ in 0..32 {
        let ingested = receiver.ingest(&block, &mut out);
        assert_eq!(ingested.consumed, block.len());
        if let Some(item) = ingested.item {
            outcome = item;
        }
    }
    let outcome = outcome.expect("fin");
    assert!(outcome.oversized);
    assert_eq!(outcome.size, 10 + (2 << 20));
    assert!(out.len() as u64 <= 1 << 20);
    assert_eq!(
        receiver.start_chunk(1, true),
        Err(BdatStateError::MessageFinished)
    );
    // Toute entrée après la fin est laissée à l'appelant.
    let ingested = receiver.ingest(b"QUIT\r\n", &mut out);
    assert_eq!(ingested.consumed, 0);
}

/// Cas de Mox `smtp/data_test.go` (`TestDataReader`, MIT), transposés. Écart voulu : Mox
/// accepte un LF isolé loin d'un point (`..test\ntest.\n`) ; la décision S7 le refuse.
#[test]
fn mox_data_reader_cases() {
    for (input, expected) in [
        (&b"test\r\n.\r\n"[..], &b"test\r\n"[..]),
        (b".\r\n", b""),
        (b".test\r\n.\r\n", b"test\r\n"),
        (b"..test\r\n.\r\n", b".test\r\n"),
    ] {
        let (out, outcome, _) = read_all(input);
        assert_eq!(out, expected, "{input:?}");
        assert_eq!(outcome.line_ending_error(), None, "{input:?}");
    }
    let (out, outcome, _) = read_all(b"..test\ntest.\n\r\n.\r\n");
    assert_eq!(out, b".test\ntest.\n\r\n");
    assert_eq!(outcome.line_ending_error(), Some(SmtpError::BareLf));
    not_ended(b"..test\ntest\n");
    not_ended(b"no end");

    for input in [
        &b"bare \r is rejected\r\n.\r\n"[..],
        b"bad:\r.\ris rejected\r\n.\r\n",
        b"bad:\r.\nis rejected\r\n.\r\n",
        b"bad:\n.\nis rejected\r\n.\r\n",
        b"bad:\n.\r\nis rejected\r\n.\r\n",
        b"bad:\r\n.\nis rejected\r\n.\r\n",
        b".\ris rejected\r\n.\r\n",
        b".\nis rejected\r\n.\r\n",
        b"\n.\ris rejected\r\n.\r\n",
        b"\r.\ris rejected\r\n.\r\n",
        b"\n.\nis rejected\r\n.\r\n",
        b"\r.\nis rejected\r\n.\r\n",
        b"\r.\r\nis rejected\r\n.\r\n",
        b"\n.\r\nis rejected\r\n.\r\n",
        b"\r\n.\ris rejected\r\n.\r\n",
        b"\r\n.\nis rejected\r\n.\r\n",
    ] {
        let (_, outcome, consumed) = read_all(input);
        assert_eq!(consumed, input.len(), "{input:?}");
        assert!(outcome.line_ending_error().is_some(), "{input:?}");
    }
}
