// SPDX-License-Identifier: AGPL-3.0-only

//! Découpage des lignes de commande : CRLF strict, limites de longueur sans croissance de la
//! mémoire, `PIPELINING` sans lecture au-delà de `STARTTLS`, `DATA` et `BDAT`.

mod smtp_support;

use lyxal_mail_proto::smtp::{
    BdatReceiver, CommandReceiver, DataReceiver, Request, SmtpError, SmtpLimits,
};
use smtp_support::commands;

#[test]
fn strict_line_endings() {
    for (input, expected) in [
        (&b"QUIT\n"[..], SmtpError::BareLf),
        (b"QU\rIT\r\n", SmtpError::BareCr),
        (b"QUIT\r\r\n", SmtpError::BareCr),
        (b"\rQUIT\r\n", SmtpError::BareCr),
        (b"QU\0IT\r\n", SmtpError::NulByte),
        (b"MAIL FROM:<a@b.c>\0\r\n", SmtpError::NulByte),
        (b"\n", SmtpError::BareLf),
    ] {
        let (results, partial) = commands(input, 3);
        assert_eq!(results, vec![Err(expected)], "{input:?}");
        assert!(!partial);
    }
    // Une ligne refusée est entièrement consommée : la suivante est lue normalement.
    let (results, partial) = commands(b"RSET\nQUIT\r\n", usize::MAX);
    assert_eq!(results, vec![Err(SmtpError::BareLf), Ok(Request::Quit)]);
    assert!(!partial);
    // CR isolé en fin d'entrée : la ligne attend son LF.
    let (results, partial) = commands(b"QUIT\r", usize::MAX);
    assert!(results.is_empty());
    assert!(partial);
}

#[test]
fn every_split_point_gives_the_same_commands() {
    let stream: &[u8] = b"EHLO client.example\r\nMAIL FROM:<a@b.example> SIZE=10\r\n\
RCPT TO:<x@y.example>\r\nRCPT TO:<Postmaster>\r\nBAD\nNOOP\r\nRSET\r\nQUIT\r\n";
    let (reference, _) = commands(stream, usize::MAX);
    assert_eq!(reference.len(), 8);
    for chunk in 1..stream.len() {
        let (results, partial) = commands(stream, chunk);
        assert_eq!(results, reference, "morceaux de {chunk}");
        assert!(!partial);
    }
}

#[test]
fn line_length_limit() {
    let limits = SmtpLimits::new(512, 1 << 20).expect("limites");
    let fits = format!("NOOP {}\r\n", "x".repeat(512 - 7));
    assert_eq!(fits.len(), 512);
    let too_long = format!("NOOP {}\r\n", "x".repeat(512 - 6));

    let mut receiver = CommandReceiver::new(&limits);
    let ingested = receiver.ingest(fits.as_bytes());
    assert_eq!(ingested.item, Some(Ok(Request::Noop)));

    for chunk in [1, 7, 100, 511, 512, 513, usize::MAX] {
        let mut receiver = CommandReceiver::new(&limits);
        let mut results = Vec::new();
        let input = format!("{too_long}QUIT\r\n");
        let mut rest = input.as_bytes();
        while !rest.is_empty() {
            let take = rest.len().min(chunk);
            let ingested = receiver.ingest(&rest[..take]);
            rest = &rest[ingested.consumed..];
            results.extend(ingested.item);
        }
        assert_eq!(
            results,
            vec![Err(SmtpError::LineTooLong), Ok(Request::Quit)],
            "morceaux de {chunk}"
        );
    }
}

#[test]
fn overlong_line_does_not_grow_memory() {
    // 64 Mio sans LF : rien n'est gardé au-delà de la limite (la mémoire du récepteur reste
    // bornée par max_line_bytes ; vérifié indirectement par has_partial_line et la reprise).
    let limits = SmtpLimits::default();
    let mut receiver = CommandReceiver::new(&limits);
    let block = vec![b'A'; 1 << 20];
    for _ in 0..64 {
        let ingested = receiver.ingest(&block);
        assert_eq!(ingested.consumed, block.len());
        assert!(ingested.item.is_none());
        assert!(receiver.has_partial_line());
    }
    let ingested = receiver.ingest(b"\r\nQUIT\r\n");
    assert_eq!(ingested.consumed, 2);
    assert_eq!(ingested.item, Some(Err(SmtpError::LineTooLong)));
    assert!(!receiver.has_partial_line());
    let ingested = receiver.ingest(b"QUIT\r\n");
    assert_eq!(ingested.item, Some(Ok(Request::Quit)));
}

#[test]
fn limits_bounds() {
    assert!(SmtpLimits::new(511, 1 << 20).is_err());
    assert!(SmtpLimits::new(65_537, 1 << 20).is_err());
    assert!(SmtpLimits::new(4096, (1 << 20) - 1).is_err());
    assert!(SmtpLimits::new(4096, (1 << 30) + 1).is_err());
    let limits = SmtpLimits::new(65_536, 1 << 30).expect("bornes hautes");
    assert_eq!(limits.max_line_bytes(), 65_536);
    let default = SmtpLimits::default();
    assert_eq!(default.max_line_bytes(), 4096);
    assert_eq!(default.max_message_bytes(), 50 * 1024 * 1024);
}

/// Groupe en `PIPELINING` (RFC 2920 §3.1, exemple « pipelined ») lu une commande à la fois.
#[test]
fn pipelining_one_command_at_a_time() {
    let group = b"MAIL FROM:<mrose@dbc.mtview.ca.us>\r\nRCPT TO:<ned@innosoft.com>\r\n\
RCPT TO:<dan@innosoft.com>\r\nRCPT TO:<kvc@innosoft.com>\r\nDATA\r\n";
    let mut receiver = CommandReceiver::new(&SmtpLimits::default());
    let mut rest = &group[..];
    let mut names = Vec::new();
    while !rest.is_empty() {
        let ingested = receiver.ingest(rest);
        rest = &rest[ingested.consumed..];
        let request = ingested.item.expect("ligne complète").expect("commande");
        names.push(request.name());
    }
    assert_eq!(names, ["MAIL", "RCPT", "RCPT", "RCPT", "DATA"]);
}

/// Après `STARTTLS`, les octets envoyés en clair à la suite (injection, CVE-2011-0411) ne sont
/// pas consommés : la session les voit et ferme la connexion.
#[test]
fn starttls_does_not_read_ahead() {
    let input = b"STARTTLS\r\nRSET\r\nMAIL FROM:<evil@x.example>\r\n";
    let mut receiver = CommandReceiver::new(&SmtpLimits::default());
    let ingested = receiver.ingest(input);
    assert_eq!(ingested.item, Some(Ok(Request::StartTls)));
    assert_eq!(ingested.consumed, b"STARTTLS\r\n".len());
    let request = Request::StartTls;
    assert!(request.forbids_pipelined_input());
    assert!(
        ingested.consumed < input.len(),
        "reste à refuser par la session"
    );
    assert!(!receiver.has_partial_line());

    // Une ligne commencée dans un paquet précédent est aussi visible.
    let mut receiver = CommandReceiver::new(&SmtpLimits::default());
    assert!(receiver.ingest(b"RSE").item.is_none());
    assert!(receiver.has_partial_line());
    receiver.reset();
    assert!(!receiver.has_partial_line());
}

/// `DATA` puis le message dans le même paquet : la commande seule est consommée ; la session
/// voit les octets envoyés avant `354` (interdit, `554 5.5.0`).
#[test]
fn data_does_not_read_ahead() {
    let input = b"DATA\r\nSubject: early\r\n\r\nbody\r\n.\r\n";
    let mut receiver = CommandReceiver::new(&SmtpLimits::default());
    let ingested = receiver.ingest(input);
    assert_eq!(ingested.item, Some(Ok(Request::Data)));
    assert_eq!(ingested.consumed, 6);
}

/// `BDAT` en `PIPELINING` (RFC 3030 §4.2) : commande, morceau, commande, morceau dans un même
/// flux ; le morceau n'est jamais lu comme une commande, même s'il ressemble à une commande.
#[test]
fn bdat_pipelined_chunks() {
    let stream = b"BDAT 12\r\nQUIT\r\nRSET\r\nBDAT 6 LAST\r\nDATA\r\nRSET\r\n";
    let limits = SmtpLimits::default();
    let mut commands_rx = CommandReceiver::new(&limits);
    let mut bdat = BdatReceiver::new(&limits);
    let mut out = Vec::new();
    let mut rest = &stream[..];
    let mut seen = Vec::new();
    let mut in_chunk = false;
    let mut outcome = None;
    while !rest.is_empty() {
        if in_chunk {
            let ingested = bdat.ingest(rest, &mut out);
            rest = &rest[ingested.consumed..];
            if let Some(end) = ingested.item {
                in_chunk = false;
                outcome = end;
            }
            continue;
        }
        let ingested = commands_rx.ingest(rest);
        rest = &rest[ingested.consumed..];
        let request = ingested.item.expect("ligne").expect("commande");
        seen.push(request.name());
        if let Request::Bdat { size, last } = request {
            bdat.start_chunk(size, last).expect("ordre");
            in_chunk = true;
        }
    }
    assert_eq!(seen, ["BDAT", "BDAT", "RSET"]);
    assert_eq!(out, b"QUIT\r\nRSET\r\nDATA\r\n");
    let outcome = outcome.expect("dernier morceau");
    assert_eq!(outcome.size, 18);
    assert_eq!(outcome.line_ending_error(), None);
}

/// Le récepteur de `DATA` s'arrête à la fin du message : la commande suivante du même paquet
/// revient au récepteur de commandes.
#[test]
fn data_end_then_next_command() {
    let input = b"Subject: x\r\n\r\nbody\r\n.\r\nQUIT\r\n";
    let limits = SmtpLimits::default();
    let mut data = DataReceiver::new(&limits);
    let mut out = Vec::new();
    let ingested = data.ingest(input, &mut out);
    assert!(ingested.item.is_some());
    let rest = &input[ingested.consumed..];
    assert_eq!(rest, b"QUIT\r\n");
    let mut receiver = CommandReceiver::new(&limits);
    assert_eq!(receiver.ingest(rest).item, Some(Ok(Request::Quit)));
}
