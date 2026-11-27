// SPDX-License-Identifier: AGPL-3.0-only

//! Syntaxe du client SMTP (lot 6, plan §3.1) : lecture des réponses, extensions de `EHLO`,
//! commandes écrites, bourrage de `DATA`. Les cas de Mox (`smtpclient/client_test.go`,
//! `TestClient` et `TestErrors`, MIT, avis `LICENSES/MIT-Mox.txt`) sont transposés ici : la
//! partie « réponse lue » de chaque dialogue.

mod smtp_support;

use lyxal_mail_proto::smtp::client::{
    ClientCommand, ClientCommandError, DotStuffer, MailCommand, RcptCommand, ReplyError,
    ReplyReader, ServerExtensions, StuffError, MAX_REPLY_LINES,
};
use lyxal_mail_proto::smtp::{
    Body, DataReceiver, Domain, DsnNotify, DsnOrcpt, DsnRet, EnhancedStatus, ForwardPath, Mailbox,
    Response, ReversePath, SmtpLimits, MAX_REPLY_LINE_BYTES,
};
use proptest::prelude::*;

/// Lit toutes les réponses d'un flux en morceaux de `chunk` octets.
fn replies(input: &[u8], chunk: usize, enhanced: bool) -> Vec<Result<Response, ReplyError>> {
    let mut reader = ReplyReader::new();
    reader.set_enhanced_status_codes(enhanced);
    let mut out = Vec::new();
    for mut piece in input.chunks(chunk.max(1)) {
        while !piece.is_empty() {
            let ingested = reader.ingest(piece);
            assert!(ingested.consumed <= piece.len());
            piece = &piece[ingested.consumed..];
            if let Some(item) = ingested.item {
                out.push(item);
            } else {
                assert!(piece.is_empty());
            }
        }
    }
    out
}

fn reply(input: &str, enhanced: bool) -> Result<Response, ReplyError> {
    let mut all = replies(input.as_bytes(), usize::MAX, enhanced);
    assert_eq!(all.len(), 1, "{input:?}");
    all.remove(0)
}

fn status(value: &str) -> EnhancedStatus {
    EnhancedStatus::parse(value).expect("code étendu")
}

fn mailbox(value: &str) -> Mailbox {
    Mailbox::parse(value).expect("boîte")
}

fn write(command: ClientCommand<'_>) -> Result<String, ClientCommandError> {
    let mut out = Vec::new();
    command.write_to(&mut out)?;
    Ok(String::from_utf8(out).expect("UTF-8"))
}

#[test]
fn single_and_multi_line_replies() {
    let ok = reply("250 2.1.0 Sender OK\r\n", true).expect("réponse");
    assert_eq!(ok.code(), 250);
    assert_eq!(ok.status(), Some(status("2.1.0")));
    assert_eq!(ok.lines(), ["Sender OK"]);

    let multi = reply(
        "550-5.1.1 No such user\r\n550-5.1.1 here\r\n550 5.1.1 Bye\r\n",
        true,
    )
    .expect("réponse");
    assert_eq!(multi.status(), Some(status("5.1.1")));
    assert_eq!(multi.lines(), ["No such user", "here", "Bye"]);
    assert_eq!(multi.diagnostic(), "550 5.1.1 No such user here Bye");

    // Sans `ENHANCEDSTATUSCODES` : le code étendu reste dans le texte.
    let plain = reply("250 2.1.0 Sender OK\r\n", false).expect("réponse");
    assert_eq!(plain.status(), None);
    assert_eq!(plain.lines(), ["2.1.0 Sender OK"]);

    // Classe du code étendu différente du code : texte (Mox `parseEcode`).
    let mismatch = reply("550 4.2.2 Mailbox full\r\n", true).expect("réponse");
    assert_eq!(mismatch.status(), None);
    assert_eq!(mismatch.lines(), ["4.2.2 Mailbox full"]);

    // Code seul, sans espace ni texte (RFC 5321 §4.2, Mox).
    let bare = reply("451\r\n", true).expect("réponse");
    assert_eq!((bare.code(), bare.lines()), (451, &[String::new()][..]));
    let bare_status = reply("250 2.0.0\r\n", true).expect("réponse");
    assert_eq!(bare_status.status(), Some(status("2.0.0")));
    assert_eq!(bare_status.lines(), [""]);

    // Texte non ASCII ou de commande assaini.
    let dirty = reply("554 bloqué\ttab\r\n", false).expect("réponse");
    assert_eq!(dirty.lines(), ["bloqu??tab"]);
}

/// Mox `TestErrors` : accueils et réponses invalides (erreur de protocole), refus définitifs et
/// temporaires (code et code étendu lus).
#[test]
fn mox_error_cases() {
    assert_eq!(reply("bogus\r\n", false), Err(ReplyError::InvalidCode));
    assert_eq!(
        reply("2200 mox.example\r\n", false),
        Err(ReplyError::InvalidSeparator)
    );
    assert_eq!(
        reply("250-mox.example\r\n500 different code\r\n", false),
        Err(ReplyError::CodeMismatch)
    );
    let refused = reply("521 not accepting connections\r\n", false).expect("réponse");
    assert!(refused.is_permanent());
    let sender = reply("550 5.7.0 not allowed\r\n", true).expect("réponse");
    assert!(sender.is_permanent());
    assert_eq!(sender.status(), Some(status("5.7.0")));
    assert!(reply("451 bad sender\r\n", true)
        .expect("réponse")
        .is_transient());
    assert!(reply("451\r\n", true).expect("réponse").is_transient());
    let blocked = reply("554 5.7.0 Blocked\r\n", true).expect("réponse");
    assert_eq!(
        (blocked.code(), blocked.status()),
        (554, Some(status("5.7.0")))
    );
    assert_eq!(
        reply("502 command not implemented\r\n", false)
            .expect("réponse")
            .code(),
        502
    );
}

#[test]
fn invalid_replies() {
    for (input, error) in [
        ("250 OK\n", ReplyError::BareLf),
        ("250 O\rK\r\n", ReplyError::BareCr),
        ("199 x\r\n", ReplyError::InvalidCode),
        ("600 x\r\n", ReplyError::InvalidCode),
        ("260 x\r\n", ReplyError::InvalidCode),
        ("25 x\r\n", ReplyError::InvalidCode),
        ("2a0 x\r\n", ReplyError::InvalidCode),
        ("250_x\r\n", ReplyError::InvalidSeparator),
        ("250-a\r\n251 b\r\n", ReplyError::CodeMismatch),
    ] {
        assert_eq!(reply(input, true), Err(error), "{input:?}");
    }
    let long = format!("250 {}\r\n", "x".repeat(MAX_REPLY_LINE_BYTES));
    assert_eq!(reply(&long, false), Err(ReplyError::LineTooLong));
    let exact = format!("250 {}\r\n", "x".repeat(MAX_REPLY_LINE_BYTES - 6));
    assert!(reply(&exact, false).is_ok());
    // Ligne sans fin, jamais gardée au-delà de la limite.
    let mut reader = ReplyReader::new();
    let endless = vec![b'x'; MAX_REPLY_LINE_BYTES];
    let ingested = reader.ingest(&endless);
    assert_eq!(ingested.item, Some(Err(ReplyError::LineTooLong)));
    assert!(!reader.has_partial_reply());

    let many = "250-x\r\n".repeat(MAX_REPLY_LINES) + "250 x\r\n";
    assert_eq!(reply(&many, false), Err(ReplyError::TooManyLines));
    let most = "250-x\r\n".repeat(MAX_REPLY_LINES - 1) + "250 x\r\n";
    assert_eq!(
        reply(&most, false).expect("réponse").lines().len(),
        MAX_REPLY_LINES
    );
}

/// Réponses en `PIPELINING` lues une à une, dans l'ordre ; le lecteur ne consomme jamais au-delà
/// d'une réponse (octets après le `220` de `STARTTLS` visibles par l'appelant).
#[test]
fn one_reply_at_a_time() {
    let stream = b"250 2.1.0 OK\r\n250 2.1.5 OK\r\n550 5.1.1 Unknown\r\n354 Go ahead\r\n";
    for chunk in [1, 2, 5, 13, usize::MAX] {
        let all = replies(stream, chunk, true);
        let codes: Vec<u16> = all
            .iter()
            .map(|r| r.as_ref().expect("réponse").code())
            .collect();
        assert_eq!(codes, [250, 250, 550, 354], "morceaux de {chunk}");
    }
    let mut reader = ReplyReader::new();
    let input = b"220 2.0.0 Ready\r\n\x16\x03\x01injected";
    let ingested = reader.ingest(input);
    assert_eq!(ingested.consumed, 17);
    assert_eq!(
        ingested.item.expect("réponse").expect("lisible").code(),
        220
    );
    assert!(!reader.has_partial_reply());
    let partial = reader.ingest(b"250-a\r\n");
    assert!(partial.item.is_none());
    assert!(reader.has_partial_reply());
}

/// Mox `TestClient` : réponse à `EHLO` avec toutes les extensions, `LIMITS` et un mot inconnu
/// ignorés.
#[test]
fn ehlo_extensions_mox() {
    let input = "250-mox.example\r\n250-PIPELINING\r\n250-SIZE 52428800\r\n\
                 250-ENHANCEDSTATUSCODES\r\n250-STARTTLS\r\n250-8BITMIME\r\n250-SMTPUTF8\r\n\
                 250-REQUIRETLS\r\n250-AUTH SCRAM-SHA-256-PLUS SCRAM-SHA-256 PLAIN\r\n\
                 250-LIMITS MAILMAX=10 RCPTMAX=100 RCPTDOMAINMAX=1\r\n250 UNKNOWN\r\n";
    let extensions =
        ServerExtensions::from_ehlo(&reply(input, false).expect("réponse")).expect("EHLO");
    assert_eq!(
        extensions,
        ServerExtensions {
            hostname: "mox.example".to_owned(),
            pipelining: true,
            size: Some(52_428_800),
            eight_bit_mime: true,
            smtputf8: true,
            starttls: true,
            dsn: false,
            enhanced_status_codes: true,
            chunking: false,
            requiretls: true,
            auth: vec![
                "SCRAM-SHA-256-PLUS".to_owned(),
                "SCRAM-SHA-256".to_owned(),
                "PLAIN".to_owned()
            ],
        }
    );
    assert_eq!(extensions.max_message_size(), Some(52_428_800));
    assert!(extensions.supports_auth("plain"));
    assert!(!extensions.supports_auth("LOGIN"));

    // Serveur minimal (`250 mox.example`) : aucune extension.
    let minimal =
        ServerExtensions::from_ehlo(&reply("250 mox.example\r\n", false).expect("réponse"))
            .expect("EHLO");
    assert_eq!(minimal.hostname, "mox.example");
    assert!(!minimal.pipelining && minimal.size.is_none() && minimal.auth.is_empty());

    // `500` à `EHLO` : pas d'extensions, repli `HELO` décidé par l'appelant.
    assert!(
        ServerExtensions::from_ehlo(&reply("500 bad syntax\r\n", false).expect("réponse"))
            .is_none()
    );
}

#[test]
fn ehlo_extension_variants() {
    let input = "250-mx.example.net Hello [192.0.2.1]\r\n250-size\r\n250-dsn\r\n\
                 250-AUTH=LOGIN PLAIN\r\n250-AUTH PLAIN login CRAM-MD5\r\n250-SMTPUTF8 x\r\n\
                 250-AUTH bad*mech\r\n250 CHUNKING\r\n";
    let extensions =
        ServerExtensions::from_ehlo(&reply(input, false).expect("réponse")).expect("EHLO");
    assert_eq!(extensions.hostname, "mx.example.net");
    assert_eq!(extensions.size, Some(0));
    assert_eq!(extensions.max_message_size(), None);
    assert!(extensions.dsn && extensions.smtputf8 && extensions.chunking);
    assert_eq!(extensions.auth, ["LOGIN", "PLAIN", "CRAM-MD5"]);
    let zero =
        ServerExtensions::from_ehlo(&reply("250-x\r\n250 SIZE 0\r\n", false).expect("réponse"))
            .expect("EHLO");
    assert_eq!((zero.size, zero.max_message_size()), (Some(0), None));
    let many_mechanisms = format!(
        "250-x\r\n250 AUTH {}\r\n",
        (0..100)
            .map(|n| format!("M{n}"))
            .collect::<Vec<_>>()
            .join(" ")
    );
    let capped = ServerExtensions::from_ehlo(&reply(&many_mechanisms, false).expect("réponse"))
        .expect("EHLO");
    assert_eq!(capped.auth.len(), 32);
}

#[test]
fn hello_and_simple_commands() {
    let host = Domain::parse("mail.example.org").expect("domaine");
    assert_eq!(
        write(ClientCommand::Ehlo(&host)),
        Ok("EHLO mail.example.org\r\n".to_owned())
    );
    assert_eq!(
        write(ClientCommand::Helo(&host)),
        Ok("HELO mail.example.org\r\n".to_owned())
    );
    let literal = Domain::parse("[IPv6:2001:db8::1]").expect("adresse");
    assert_eq!(
        write(ClientCommand::Ehlo(&literal)),
        Ok("EHLO [IPv6:2001:db8::1]\r\n".to_owned())
    );
    for (command, line) in [
        (ClientCommand::StartTls, "STARTTLS\r\n"),
        (ClientCommand::Data, "DATA\r\n"),
        (ClientCommand::Rset, "RSET\r\n"),
        (ClientCommand::Noop, "NOOP\r\n"),
        (ClientCommand::Quit, "QUIT\r\n"),
    ] {
        assert_eq!(write(command), Ok(line.to_owned()));
    }
    // Un nom construit à la main ne peut pas injecter de commande.
    for invalid in ["x.example\r\nRCPT TO:<a@b>", "exämple.org", "a b", ""] {
        let host = Domain::Name(invalid.to_owned());
        assert_eq!(
            write(ClientCommand::Ehlo(&host)),
            Err(ClientCommandError::InvalidHost)
        );
    }
}

#[test]
fn mail_from() {
    let mut mail = MailCommand {
        reverse_path: ReversePath::Mailbox(mailbox("rp=abc@lyxal.example")),
        size: Some(12_345),
        body: Some(Body::EightBitMime),
        smtputf8: false,
        ret: Some(DsnRet::Headers),
        envid: Some("QQ314159+1 =x".to_owned()),
    };
    assert_eq!(
        write(ClientCommand::Mail(&mail)),
        Ok(
            "MAIL FROM:<rp=abc@lyxal.example> SIZE=12345 BODY=8BITMIME RET=HDRS \
            ENVID=QQ314159+2B1+20+3Dx\r\n"
                .to_owned()
        )
    );
    mail.ret = Some(DsnRet::Full);
    mail.envid = None;
    mail.body = Some(Body::SevenBit);
    mail.size = None;
    assert_eq!(
        write(ClientCommand::Mail(&mail)),
        Ok("MAIL FROM:<rp=abc@lyxal.example> BODY=7BIT RET=FULL\r\n".to_owned())
    );
    let null = MailCommand {
        reverse_path: ReversePath::Null,
        size: None,
        body: None,
        smtputf8: false,
        ret: None,
        envid: None,
    };
    assert_eq!(
        write(ClientCommand::Mail(&null)),
        Ok("MAIL FROM:<>\r\n".to_owned())
    );

    let mut utf8 = null.clone();
    utf8.reverse_path = ReversePath::Mailbox(mailbox("jöran@exämple.org"));
    assert_eq!(
        write(ClientCommand::Mail(&utf8)),
        Err(ClientCommandError::Utf8WithoutSmtpUtf8)
    );
    utf8.smtputf8 = true;
    assert_eq!(
        write(ClientCommand::Mail(&utf8)),
        Ok("MAIL FROM:<jöran@exämple.org> SMTPUTF8\r\n".to_owned())
    );

    for envid in ["", "a\r\nRCPT", "é", &"x".repeat(101), &"+".repeat(34)] {
        let mut bad = null.clone();
        bad.envid = Some(envid.to_owned());
        assert_eq!(
            write(ClientCommand::Mail(&bad)),
            Err(ClientCommandError::InvalidEnvid),
            "{envid:?}"
        );
    }
    let mut binary = null.clone();
    binary.body = Some(Body::BinaryMime);
    assert_eq!(
        write(ClientCommand::Mail(&binary)),
        Err(ClientCommandError::UnsupportedBody)
    );

    // Partie locale entre guillemets réécrite telle que l'enveloppe l'exige.
    let quoted = MailCommand {
        reverse_path: ReversePath::Mailbox(mailbox("\"a b\\\"c\"@example.org")),
        ..null
    };
    assert_eq!(
        write(ClientCommand::Mail(&quoted)),
        Ok("MAIL FROM:<\"a b\\\"c\"@example.org>\r\n".to_owned())
    );
}

#[test]
fn rcpt_to() {
    let notify = DsnNotify {
        never: false,
        success: true,
        failure: true,
        delay: true,
    };
    let mut rcpt = RcptCommand {
        forward_path: ForwardPath::Mailbox(mailbox("bob+tag@example.net")),
        notify: Some(notify),
        orcpt: Some(DsnOrcpt::for_mailbox(&mailbox("bob+tag@example.net"))),
        smtputf8: false,
    };
    assert_eq!(
        write(ClientCommand::Rcpt(&rcpt)),
        Ok(
            "RCPT TO:<bob+tag@example.net> NOTIFY=SUCCESS,FAILURE,DELAY \
            ORCPT=rfc822;bob+2Btag@example.net\r\n"
                .to_owned()
        )
    );
    rcpt.notify = Some(DsnNotify {
        never: true,
        ..DsnNotify::default()
    });
    rcpt.orcpt = None;
    assert_eq!(
        write(ClientCommand::Rcpt(&rcpt)),
        Ok("RCPT TO:<bob+tag@example.net> NOTIFY=NEVER\r\n".to_owned())
    );
    for notify in [
        DsnNotify::default(),
        DsnNotify {
            never: true,
            failure: true,
            ..DsnNotify::default()
        },
    ] {
        rcpt.notify = Some(notify);
        assert_eq!(
            write(ClientCommand::Rcpt(&rcpt)),
            Err(ClientCommandError::InvalidNotify)
        );
    }
    rcpt.notify = None;
    for (address_type, address) in [
        ("rfc822", "a b@x"),
        ("rfc822", "a\r\nb"),
        ("", "a@x"),
        ("rfc 822", "a@x"),
        ("rfc822", "a+2b@x"),
        ("rfc822", ""),
    ] {
        rcpt.orcpt = Some(DsnOrcpt {
            address_type: address_type.to_owned(),
            address: address.to_owned(),
        });
        assert_eq!(
            write(ClientCommand::Rcpt(&rcpt)),
            Err(ClientCommandError::InvalidOrcpt),
            "{address_type:?} {address:?}"
        );
    }

    let postmaster = RcptCommand {
        forward_path: ForwardPath::Postmaster,
        notify: None,
        orcpt: None,
        smtputf8: false,
    };
    assert_eq!(
        write(ClientCommand::Rcpt(&postmaster)),
        Ok("RCPT TO:<Postmaster>\r\n".to_owned())
    );

    let international = mailbox("jöran@exämple.org");
    let mut utf8 = RcptCommand {
        forward_path: ForwardPath::Mailbox(international.clone()),
        notify: None,
        orcpt: Some(DsnOrcpt::for_mailbox(&international)),
        smtputf8: false,
    };
    assert_eq!(
        write(ClientCommand::Rcpt(&utf8)),
        Err(ClientCommandError::Utf8WithoutSmtpUtf8)
    );
    utf8.smtputf8 = true;
    assert_eq!(
        write(ClientCommand::Rcpt(&utf8)),
        Ok("RCPT TO:<jöran@exämple.org> ORCPT=utf-8;j\\x{F6}ran@ex\\x{E4}mple.org\r\n".to_owned())
    );
}

/// `ORCPT` reçu par le serveur, relayé tel quel puis décodé pour l'avis (RFC 3461 §5.2.1).
#[test]
fn orcpt_pass_through_and_decode() {
    let line = "RCPT TO:<x@example.org> ORCPT=rfc822;Bob+2BTag@Example.ORG\r\n";
    let received = match smtp_support::command(line) {
        Ok(lyxal_mail_proto::smtp::Request::Rcpt(rcpt)) => rcpt.dsn_orcpt.expect("orcpt"),
        other => panic!("{other:?}"),
    };
    let relayed = RcptCommand {
        forward_path: ForwardPath::Mailbox(mailbox("x@example.org")),
        notify: None,
        orcpt: Some(received.clone()),
        smtputf8: false,
    };
    assert_eq!(write(ClientCommand::Rcpt(&relayed)), Ok(line.to_owned()));
    let decoded = received.decode().expect("décodé");
    assert_eq!(
        (decoded.address_type.as_str(), decoded.address.as_str()),
        ("rfc822", "Bob+Tag@Example.ORG")
    );
    let international = DsnOrcpt::for_mailbox(&mailbox("jöran@exämple.org"));
    assert_eq!(
        international.decode().expect("décodé").address,
        "jöran@exämple.org"
    );
    assert_eq!(
        DsnOrcpt {
            address_type: "rfc822".to_owned(),
            address: "a+ZZ".to_owned()
        }
        .decode(),
        None
    );
}

#[test]
fn auth_plain_command() {
    let mut out = zeroize::Zeroizing::new(Vec::new());
    ClientCommand::AuthPlain {
        authcid: "relay-user",
        password: b"s3cr\xc3\xa9t",
    }
    .write_to(&mut out)
    .expect("AUTH PLAIN");
    assert_eq!(
        out.as_slice(),
        b"AUTH PLAIN AHJlbGF5LXVzZXIAczNjcsOpdA==\r\n"
    );
    for (authcid, password) in [("", &b"x"[..]), ("a", b""), ("a\0b", b"x"), ("a", b"x\0y")] {
        let mut out = Vec::new();
        assert_eq!(
            ClientCommand::AuthPlain { authcid, password }.write_to(&mut out),
            Err(ClientCommandError::InvalidCredentials)
        );
        assert!(out.is_empty());
    }
    let debug = format!(
        "{:?}",
        ClientCommand::AuthPlain {
            authcid: "relay-user",
            password: b"hunter2",
        }
    );
    assert!(
        !debug.contains("hunter2") && !debug.contains("104"),
        "{debug}"
    );
    assert!(debug.contains("REDACTED"));
}

fn stuff(content: &[u8], split: usize) -> Result<Vec<u8>, StuffError> {
    let mut stuffer = DotStuffer::new();
    let mut out = Vec::new();
    for piece in content.chunks(split.max(1)) {
        stuffer.encode(piece, &mut out)?;
    }
    stuffer.finish(&mut out)?;
    assert_eq!(stuffer.written(), out.len() as u64);
    Ok(out)
}

#[test]
fn dot_stuffing() {
    for split in [1, 2, 3, usize::MAX] {
        assert_eq!(stuff(b"", split), Ok(b".\r\n".to_vec()));
        assert_eq!(stuff(b"a\r\n", split), Ok(b"a\r\n.\r\n".to_vec()));
        assert_eq!(stuff(b"a", split), Ok(b"a\r\n.\r\n".to_vec()));
        assert_eq!(stuff(b".", split), Ok(b"..\r\n.\r\n".to_vec()));
        assert_eq!(
            stuff(b".a\r\n..b\r\n.\r\nc.d\r\n", split),
            Ok(b"..a\r\n...b\r\n..\r\nc.d\r\n.\r\n".to_vec())
        );
        assert_eq!(stuff(b"a\nb", split), Err(StuffError::BareLf));
        assert_eq!(stuff(b"\n", split), Err(StuffError::BareLf));
        assert_eq!(stuff(b"a\rb\r\n", split), Err(StuffError::BareCr));
        assert_eq!(stuff(b"a\r", split), Err(StuffError::BareCr));
        // Contrebande SMTP : `LF.LF` et `CR.CR` ne passent jamais.
        assert_eq!(
            stuff(b"x\n.\nMAIL FROM:<a@b>\r\n", split),
            Err(StuffError::BareLf)
        );
        assert_eq!(stuff(b"x\r.\rDATA\r\n", split), Err(StuffError::BareCr));
    }
    let mut stuffer = DotStuffer::new();
    let mut out = Vec::new();
    assert_eq!(stuffer.encode(b"a\nb", &mut out), Err(StuffError::BareLf));
    assert_eq!(stuffer.encode(b"c", &mut out), Err(StuffError::Finished));
    assert_eq!(stuffer.finish(&mut out), Err(StuffError::Finished));
    let mut done = DotStuffer::default();
    done.finish(&mut Vec::new()).expect("fin");
    assert_eq!(done.encode(b"", &mut Vec::new()), Err(StuffError::Finished));
}

/// Contenu à fins de ligne CRLF strictes, riche en points de tête.
fn crlf_content() -> impl Strategy<Value = Vec<u8>> {
    prop::collection::vec(
        prop_oneof![
            Just(b"\r\n".to_vec()),
            Just(b".".to_vec()),
            Just(b"..".to_vec()),
            Just(b"a".to_vec()),
            Just(vec![0xc3, 0xa9]),
            Just(b" \t".to_vec()),
        ],
        0..64,
    )
    .prop_map(|pieces| pieces.concat())
}

fn response_strategy() -> impl Strategy<Value = Response> {
    (
        2u16..=5,
        0u16..=5,
        0u16..=9,
        prop::option::of((0u16..=7, 0u16..=20)),
        prop::collection::vec("[ -~]{0,40}", 1..5),
    )
        .prop_map(|(class, second, third, status, lines)| {
            let code = class * 100 + second * 10 + third;
            let status = status.and_then(|(subject, detail)| {
                (class != 3)
                    .then(|| EnhancedStatus::new(class as u8, subject, detail))
                    .flatten()
            });
            Response::with_lines(code, status, lines).expect("réponse")
        })
}

proptest! {
    /// Bourrer puis lire par le `DataReceiver` du serveur (lot 5) redonne le contenu (terminé
    /// par CRLF s'il ne l'était pas), en morceaux quelconques.
    #[test]
    fn stuffed_content_reads_back(content in crlf_content(), split in 1usize..17) {
        let stuffed = stuff(&content, split).expect("bourrage");
        let (read, outcome, consumed) =
            smtp_support::data(&stuffed, split, &SmtpLimits::default());
        let outcome = outcome.expect("fin des données");
        prop_assert_eq!(consumed, stuffed.len());
        prop_assert_eq!(outcome.line_ending_error(), None);
        let mut expected = content.clone();
        if !expected.is_empty() && !expected.ends_with(b"\r\n") {
            expected.extend_from_slice(b"\r\n");
        }
        prop_assert_eq!(read, expected);
    }

    /// Le bourrage ne laisse jamais passer de fin isolée : il refuse, ou le serveur relit sans
    /// erreur de fin de ligne.
    #[test]
    fn stuffing_never_smuggles(content in prop::collection::vec(
        prop_oneof![Just(b'\r'), Just(b'\n'), Just(b'.'), Just(b'a')], 0..32)) {
        if let Ok(stuffed) = stuff(&content, 3) {
            let mut receiver = DataReceiver::new(&SmtpLimits::default());
            let mut out = Vec::new();
            let ingested = receiver.ingest(&stuffed, &mut out);
            prop_assert_eq!(ingested.consumed, stuffed.len());
            let outcome = ingested.item.expect("fin");
            prop_assert_eq!(outcome.line_ending_error(), None);
        }
    }

    /// Une réponse écrite par `Response::write_to` est relue à l'identique.
    #[test]
    fn written_reply_reads_back(response in response_strategy(), split in 1usize..9) {
        let bytes = response.to_bytes();
        let all = replies(&bytes, split, response.status().is_some());
        prop_assert_eq!(all.len(), 1);
        prop_assert_eq!(all[0].as_ref().expect("réponse"), &response);
    }

    /// Aucune entrée ne fait paniquer le lecteur ; il consomme toujours de quoi avancer.
    #[test]
    fn reply_reader_never_panics(input in prop::collection::vec(any::<u8>(), 0..2048)) {
        let mut reader = ReplyReader::new();
        reader.set_enhanced_status_codes(true);
        let mut rest = &input[..];
        while !rest.is_empty() {
            let ingested = reader.ingest(rest);
            prop_assert!(ingested.consumed > 0);
            rest = &rest[ingested.consumed..];
        }
    }
}
