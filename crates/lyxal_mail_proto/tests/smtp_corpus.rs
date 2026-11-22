// SPDX-License-Identifier: AGPL-3.0-only

//! Corpus de dialogues tirés des exemples des RFC (`tests/corpus/smtp/`) : chaque flux du
//! client est lu de bout en bout (commandes, `DATA`, morceaux `BDAT`) sous plusieurs découpages,
//! et chaque réponse du serveur des exemples est relue par le lecteur de réponses des essais.
//!
//! Format des fichiers : `C:` ou `P:` ligne de commande (`P:` : envoyée en `PIPELINING`),
//! `D:` ligne de données après `DATA`, `B:` ligne d'un morceau `BDAT` (CRLF compris),
//! `S:` ligne de réponse du serveur, `#` commentaire.

mod smtp_support;

use std::fs;
use std::path::Path;

use lyxal_mail_proto::smtp::{BdatReceiver, CommandReceiver, DataReceiver, Request, SmtpLimits};
use smtp_support::parse_reply;

struct Transcript {
    stream: Vec<u8>,
    verbs: Vec<String>,
    replies: Vec<Vec<u8>>,
}

fn load(path: &Path) -> Transcript {
    let text = fs::read_to_string(path).expect("lecture du corpus");
    let mut transcript = Transcript {
        stream: Vec::new(),
        verbs: Vec::new(),
        replies: Vec::new(),
    };
    let mut reply = Vec::new();
    for line in text.lines() {
        let (tag, content) = match line.split_once(':') {
            Some((tag, rest)) if tag.len() == 1 => (tag, rest.strip_prefix(' ').unwrap_or(rest)),
            _ => {
                assert!(line.starts_with('#') || line.is_empty(), "{line:?}");
                continue;
            }
        };
        if tag != "S" && !reply.is_empty() {
            transcript.replies.push(std::mem::take(&mut reply));
        }
        match tag {
            "C" | "P" => {
                let verb = content.split(' ').next().unwrap_or("").to_ascii_uppercase();
                transcript.verbs.push(verb);
                transcript.stream.extend_from_slice(content.as_bytes());
                transcript.stream.extend_from_slice(b"\r\n");
            }
            "D" | "B" => {
                transcript.stream.extend_from_slice(content.as_bytes());
                transcript.stream.extend_from_slice(b"\r\n");
            }
            "S" => {
                reply.extend_from_slice(content.as_bytes());
                reply.extend_from_slice(b"\r\n");
                // Une ligne « ddd » ou « ddd texte » clôt la réponse.
                if content.as_bytes().get(3) != Some(&b'-') {
                    transcript.replies.push(std::mem::take(&mut reply));
                }
            }
            other => panic!("étiquette inconnue {other:?} dans {}", path.display()),
        }
    }
    assert!(
        reply.is_empty(),
        "réponse inachevée dans {}",
        path.display()
    );
    transcript
}

enum Phase {
    Commands,
    Data(DataReceiver),
    Bdat,
}

/// Lit le flux du client en morceaux de `chunk` octets ; rend les verbes lus.
fn replay(stream: &[u8], chunk: usize) -> Vec<String> {
    let limits = SmtpLimits::default();
    let mut commands = CommandReceiver::new(&limits);
    let mut bdat = BdatReceiver::new(&limits);
    let mut phase = Phase::Commands;
    let mut verbs = Vec::new();
    let mut out = Vec::new();
    for mut piece in stream.chunks(chunk) {
        while !piece.is_empty() {
            match &mut phase {
                Phase::Commands => {
                    let ingested = commands.ingest(piece);
                    piece = &piece[ingested.consumed..];
                    let Some(result) = ingested.item else {
                        continue;
                    };
                    let request =
                        result.unwrap_or_else(|error| panic!("{error:?} après {verbs:?}"));
                    verbs.push(request.name().to_owned());
                    match request {
                        Request::Data => phase = Phase::Data(DataReceiver::new(&limits)),
                        Request::Bdat { size, last } => {
                            bdat.start_chunk(size, last).expect("ordre des morceaux");
                            phase = Phase::Bdat;
                        }
                        // Dans les exemples, STARTTLS termine le flux en clair.
                        Request::StartTls => assert!(stream.ends_with(b"STARTTLS\r\n")),
                        _ => {}
                    }
                }
                Phase::Data(receiver) => {
                    let ingested = receiver.ingest(piece, &mut out);
                    piece = &piece[ingested.consumed..];
                    if let Some(outcome) = ingested.item {
                        assert_eq!(outcome.line_ending_error(), None);
                        assert!(!outcome.oversized);
                        out.clear();
                        phase = Phase::Commands;
                    }
                }
                Phase::Bdat => {
                    let ingested = bdat.ingest(piece, &mut out);
                    piece = &piece[ingested.consumed..];
                    if let Some(end) = ingested.item {
                        if let Some(outcome) = end {
                            assert_eq!(outcome.line_ending_error(), None);
                            bdat = BdatReceiver::new(&limits);
                            out.clear();
                        }
                        phase = Phase::Commands;
                    }
                }
            }
        }
    }
    assert!(matches!(phase, Phase::Commands), "flux inachevé");
    assert!(!commands.has_partial_line());
    verbs
}

#[test]
fn rfc_transcripts() {
    let dir = Path::new(env!("CARGO_MANIFEST_DIR")).join("tests/corpus/smtp");
    let mut entries: Vec<_> = fs::read_dir(&dir)
        .expect("dossier du corpus")
        .map(|entry| entry.expect("entrée").path())
        .collect();
    entries.sort();
    assert!(entries.len() >= 10, "{entries:?}");
    let mut commands = 0;
    for path in entries {
        let transcript = load(&path);
        for chunk in [1, 2, 7, 64, usize::MAX] {
            let verbs = replay(&transcript.stream, chunk);
            assert_eq!(
                verbs,
                transcript.verbs,
                "{} en morceaux de {chunk}",
                path.display()
            );
        }
        commands += transcript.verbs.len();
        for reply in &transcript.replies {
            let lines = parse_reply(reply);
            assert!(
                lines.iter().all(|line| line.code == lines[0].code),
                "{}",
                path.display()
            );
        }
    }
    assert!(commands >= 60, "{commands}");
}

#[test]
fn rfc3030_chunk_is_86_octets() {
    let path = Path::new(env!("CARGO_MANIFEST_DIR")).join("tests/corpus/smtp/rfc3030-chunking.txt");
    let transcript = load(&path);
    let start = transcript
        .stream
        .windows(14)
        .position(|window| window == b"BDAT 86 LAST\r\n")
        .expect("BDAT 86")
        + 14;
    let chunk = &transcript.stream[start..start + 86];
    assert!(chunk.starts_with(b"To: Susan@random.com\r\n"));
    assert!(chunk.ends_with(b"bodyless test message\r\n"));
    assert_eq!(&transcript.stream[start + 86..start + 92], b"QUIT\r\n");
}
