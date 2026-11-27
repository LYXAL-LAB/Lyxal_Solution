// SPDX-License-Identifier: AGPL-3.0-only

//! Avis de non-remise (lot 6, plan §3.3) : écriture, relecture par la lecture MIME du lot 4,
//! variante internationale, avis réels mal formés, limites. Les cas de Mox
//! (`dsn/dsn_test.go`, `TestDSN`, MIT, avis `LICENSES/MIT-Mox.txt`) sont transposés.

use lyxal_mail_proto::dsn::{
    parse_dsn, DeliveryReport, DsnAction, DsnAddress, DsnBuildError, DsnBuilder, DsnDiagnostic,
    DsnParseError, DsnRecipient, MAX_DSN_RECIPIENTS, MAX_REPORT_BYTES, MAX_RETURNED_BYTES,
};
use lyxal_mail_proto::mime::{parse, BodyPart, MimeLimits, PartBody};
use lyxal_mail_proto::smtp::{DsnRet, EnhancedStatus, Mailbox};
use proptest::prelude::*;
use time::macros::datetime;
use time::OffsetDateTime;

fn mailbox(value: &str) -> Mailbox {
    Mailbox::parse(value).expect("boîte")
}

fn status(value: &str) -> EnhancedStatus {
    EnhancedStatus::parse(value).expect("code étendu")
}

fn address(value: &str) -> DsnAddress {
    DsnAddress::for_mailbox(&mailbox(value))
}

fn read(raw: &[u8]) -> Result<DeliveryReport, DsnParseError> {
    let parsed = parse(raw, &MimeLimits::default()).expect("lecture MIME");
    parse_dsn(raw, &parsed)
}

fn failed(final_recipient: &str) -> DsnRecipient {
    DsnRecipient {
        original_recipient: None,
        final_recipient: address(final_recipient),
        action: DsnAction::Failed,
        status: status("5.0.0"),
        remote_mta: None,
        diagnostic: None,
        last_attempt_date: Some(datetime!(2026-11-27 10:00:00 +01:00)),
        will_retry_until: None,
    }
}

struct Fixture {
    from: Mailbox,
    to: Mailbox,
    recipients: Vec<DsnRecipient>,
    original: Vec<u8>,
}

impl Fixture {
    fn builder(&self, international: bool, ret: DsnRet) -> DsnBuilder<'_> {
        DsnBuilder {
            reporting_mta: "mox.example",
            from: &self.from,
            to: &self.to,
            message_id: "test@localhost",
            date: datetime!(2026-11-27 10:05:00 +01:00),
            original_message_id: Some("orig@remote.example"),
            international,
            original_envelope_id: None,
            arrival_date: datetime!(2026-11-27 09:59:00 +01:00),
            recipients: &self.recipients,
            ret,
            original: &self.original,
        }
    }
}

/// Types des parties : (type, sous-type, codage).
fn part_types(raw: &[u8]) -> Vec<(String, String, Option<String>)> {
    let parsed = parse(raw, &MimeLimits::default()).expect("lecture MIME");
    assert_eq!(parsed.structure.media_type, "multipart");
    assert_eq!(parsed.structure.media_subtype, "report");
    assert!(parsed.is_report);
    let report_type = parsed
        .structure
        .parameters
        .iter()
        .find(|p| p.name == "report-type")
        .map(|p| p.value.clone());
    assert_eq!(report_type.as_deref(), Some("delivery-status"));
    match &parsed.structure.body {
        PartBody::Multipart(parts) => parts
            .iter()
            .map(|part: &BodyPart| {
                (
                    part.media_type.clone(),
                    part.media_subtype.clone(),
                    part.transfer_encoding.clone(),
                )
            })
            .collect(),
        other => panic!("{other:?}"),
    }
}

fn types(list: &[(&str, &str, &str)]) -> Vec<(String, String, Option<String>)> {
    list.iter()
        .map(|(t, s, e)| (t.to_string(), s.to_string(), Some(e.to_string())))
        .collect()
}

/// Mox `TestDSN`, message ASCII : trois parties, relu à l'identique.
#[test]
fn mox_ascii_dsn() {
    let fixture = Fixture {
        from: mailbox("postmaster@mox.example"),
        to: mailbox("mjl@remote.example"),
        recipients: vec![failed("mjl@remote.example")],
        original: b"Subject: test\r\n".to_vec(),
    };
    let raw = fixture
        .builder(false, DsnRet::Headers)
        .build()
        .expect("avis");
    assert!(raw.is_ascii());
    assert_eq!(
        part_types(&raw),
        types(&[
            ("text", "plain", "quoted-printable"),
            ("message", "delivery-status", "7bit"),
            ("text", "rfc822-headers", "7bit"),
        ])
    );
    let report = read(&raw).expect("relu");
    assert!(!report.international);
    assert_eq!(report.reporting_mta.as_deref(), Some("mox.example"));
    assert_eq!(
        report.arrival_date,
        Some(datetime!(2026-11-27 09:59:00 +01:00))
    );
    assert_eq!(report.recipients, fixture.recipients);
    assert_eq!(report.ignored_recipients, 0);
    let text = String::from_utf8(raw).expect("ASCII");
    assert!(text.contains("\r\nSubject: test\r\n"));
    assert!(text.contains("From: Mail Delivery System <postmaster@mox.example>\r\n"));
    assert!(text.contains("To: <mjl@remote.example>\r\n"));
    assert!(text.contains("In-Reply-To: <orig@remote.example>\r\n"));
    assert!(text.contains("Auto-Submitted: auto-replied\r\n"));
    assert!(text.contains("Subject: Avis de non-remise / Delivery Status Notification (Failure)"));
}

/// Mox `TestDSN`, message UTF-8 : variante internationale (RFC 6533), et forme ASCII seule
/// des adresses quand l'avis n'est pas international.
#[test]
fn mox_utf8_dsn() {
    let fixture = Fixture {
        from: mailbox("postmæster@møx.example"),
        to: mailbox("møx@remøte.example"),
        recipients: vec![failed("møx@remøte.example")],
        original: "Subject: tést\r\n".as_bytes().to_vec(),
    };
    let raw = fixture
        .builder(true, DsnRet::Headers)
        .build()
        .expect("avis");
    assert_eq!(
        part_types(&raw),
        types(&[
            ("text", "plain", "quoted-printable"),
            ("message", "global-delivery-status", "8bit"),
            ("message", "global-headers", "8bit"),
        ])
    );
    let report = read(&raw).expect("relu");
    assert!(report.international);
    assert_eq!(report.recipients, fixture.recipients);
    assert_eq!(report.recipients[0].final_recipient.address_type, "utf-8");
    let text = String::from_utf8(raw.clone()).expect("UTF-8");
    assert!(text.contains("Final-Recipient: utf-8; møx@remøte.example\r\n"));

    // Avis non international pour des adresses non ASCII : expéditeur et destinataire de
    // l'avis refusés…
    assert_eq!(
        fixture.builder(false, DsnRet::Headers).build(),
        Err(DsnBuildError::NonAsciiAddress)
    );
    // … destinataires du rapport écrits en utf-8-addr-xtext, relus décodés.
    let ascii = Fixture {
        from: mailbox("postmaster@mox.example"),
        to: mailbox("mjl@remote.example"),
        recipients: vec![failed("møx@remøte.example")],
        original: Vec::new(),
    };
    let raw = ascii.builder(false, DsnRet::Headers).build().expect("avis");
    assert!(raw.is_ascii());
    let text = String::from_utf8(raw.clone()).expect("ASCII");
    assert!(text.contains("Final-Recipient: utf-8; m\\x{F8}x@rem\\x{F8}te.example\r\n"));
    assert_eq!(read(&raw).expect("relu").recipients, ascii.recipients);
    // Sans message d'origine : deux parties (Mox, « message without 3rd multipart »).
    assert_eq!(part_types(&raw).len(), 2);
}

#[test]
fn all_fields_and_actions() {
    let recipients = vec![
        DsnRecipient {
            original_recipient: Some(DsnAddress {
                address_type: "rfc822".to_owned(),
                address: "Bob+Tag@Example.ORG".to_owned(),
            }),
            final_recipient: address("bob@example.org"),
            action: DsnAction::Failed,
            status: status("5.1.1"),
            remote_mta: Some("mx.example.org".to_owned()),
            diagnostic: Some(DsnDiagnostic::smtp(
                "550 5.1.1 <bob@example.org>: User unknown",
            )),
            last_attempt_date: Some(datetime!(2026-11-27 10:00:00 UTC)),
            will_retry_until: None,
        },
        DsnRecipient {
            original_recipient: None,
            final_recipient: address("carol@example.net"),
            action: DsnAction::Delayed,
            status: status("4.4.1"),
            remote_mta: Some("mx.example.net".to_owned()),
            diagnostic: Some(DsnDiagnostic::smtp("421 4.4.1 Connection timed out")),
            last_attempt_date: Some(datetime!(2026-11-27 10:00:00 UTC)),
            will_retry_until: Some(datetime!(2026-12-02 10:00:00 UTC)),
        },
        DsnRecipient {
            action: DsnAction::Relayed,
            status: status("2.0.0"),
            ..failed("dave@example.com")
        },
        DsnRecipient {
            action: DsnAction::Delivered,
            status: status("2.0.0"),
            ..failed("erin@lyxal.example")
        },
    ];
    let from = mailbox("MAILER-DAEMON@smtp.lyxal.example");
    let to = mailbox("alice@lyxal.example");
    let builder = DsnBuilder {
        reporting_mta: "smtp.lyxal.example",
        from: &from,
        to: &to,
        message_id: "dsn.1@smtp.lyxal.example",
        date: datetime!(2026-11-27 10:00:05 UTC),
        original_message_id: None,
        international: false,
        original_envelope_id: Some("QQ314159+1"),
        arrival_date: datetime!(2026-11-27 09:00:00 UTC),
        recipients: &recipients,
        ret: DsnRet::Headers,
        original: b"From: alice@lyxal.example\r\nSubject: hi\r\n\r\nBody\r\n",
    };
    let raw = builder.build().expect("avis");
    let report = read(&raw).expect("relu");
    assert_eq!(report.original_envelope_id.as_deref(), Some("QQ314159+1"));
    assert_eq!(report.recipients, recipients);
    let text = String::from_utf8(raw).expect("ASCII");
    // En-têtes seuls : le corps n'est pas joint.
    assert!(!text.contains("\r\nBody\r\n"));
    assert!(text.contains("Original-Recipient: rfc822; Bob+Tag@Example.ORG\r\n"));
    assert!(text.contains("Diagnostic-Code: smtp; 550 5.1.1 <bob@example.org>: User unknown\r\n"));
    assert!(text.contains("Will-Retry-Until: Wed, 2 Dec 2026 10:00:00 +0000\r\n"));
    // Le texte lisible ne reprend aucun texte distant.
    let human = text
        .split("Content-Type: message/delivery-status")
        .next()
        .expect("texte");
    assert!(!human.contains("User unknown") && !human.contains("timed out"));
    assert!(human.contains("pas pu =C3=AAtre remis") || human.contains("pas pu =\r\n"));
    assert!(human.contains("could not be delivered"));
}

#[test]
fn returned_content() {
    let small = format!("Subject: x\r\n\r\n{}\r\n", "y".repeat(1000)).into_bytes();
    let fixture = Fixture {
        from: mailbox("MAILER-DAEMON@mx.example"),
        to: mailbox("a@example.org"),
        recipients: vec![failed("b@example.org")],
        original: small.clone(),
    };
    let raw = fixture.builder(false, DsnRet::Full).build().expect("avis");
    assert_eq!(part_types(&raw)[2].1, "rfc822");
    let start = memchr::memmem::find(&raw, &small).expect("message joint entier");
    // Octets exacts : la frontière suit immédiatement.
    assert!(raw[start + small.len()..].starts_with(b"\r\n--"));
    let raw_intl = fixture.builder(true, DsnRet::Full).build().expect("avis");
    assert_eq!(part_types(&raw_intl)[2].1, "global");

    let big = Fixture {
        original: format!("Subject: x\r\n\r\n{}", "z".repeat(MAX_RETURNED_BYTES)).into_bytes(),
        ..fixture
    };
    let raw = big.builder(false, DsnRet::Full).build().expect("avis");
    assert_eq!(part_types(&raw)[2].1, "rfc822-headers");
    assert!(raw.len() < 8_192);
}

#[test]
fn remote_text_is_sanitized() {
    let recipient = DsnRecipient {
        remote_mta: Some("mx.evil\r\nAction: delivered".to_owned()),
        diagnostic: Some(DsnDiagnostic::smtp(format!(
            "550 5.7.1 bad\r\n\r\nFinal-Recipient: rfc822; x@y\r\n{}",
            "long ".repeat(2000)
        ))),
        ..failed("victim@example.org")
    };
    let recipients = [recipient];
    let from = mailbox("MAILER-DAEMON@mx.example");
    let to = mailbox("a@example.org");
    let raw = DsnBuilder {
        reporting_mta: "mx.example",
        from: &from,
        to: &to,
        message_id: "x@mx.example",
        date: OffsetDateTime::UNIX_EPOCH,
        original_message_id: None,
        international: false,
        original_envelope_id: None,
        arrival_date: OffsetDateTime::UNIX_EPOCH,
        recipients: &recipients,
        ret: DsnRet::Headers,
        original: b"",
    }
    .build()
    .expect("avis");
    let report = read(&raw).expect("relu");
    assert_eq!(report.recipients.len(), 1);
    assert_eq!(report.recipients[0].action, DsnAction::Failed);
    assert_eq!(
        report.recipients[0].remote_mta.as_deref(),
        Some("mx.evilAction: delivered")
    );
    let diagnostic = report.recipients[0]
        .diagnostic
        .as_ref()
        .expect("diagnostic");
    assert!(diagnostic.text.len() <= 4_096);
    for line in raw.split(|&b| b == b'\n') {
        assert!(line.len() <= 1_000);
    }
}

#[test]
fn build_refusals() {
    let fixture = Fixture {
        from: mailbox("MAILER-DAEMON@mx.example"),
        to: mailbox("a@example.org"),
        recipients: Vec::new(),
        original: Vec::new(),
    };
    assert_eq!(
        fixture.builder(false, DsnRet::Headers).build(),
        Err(DsnBuildError::NoRecipient)
    );
    let many = Fixture {
        recipients: vec![failed("b@example.org"); MAX_DSN_RECIPIENTS + 1],
        ..fixture
    };
    assert_eq!(
        many.builder(false, DsnRet::Headers).build(),
        Err(DsnBuildError::TooManyRecipients)
    );
    let one = Fixture {
        recipients: vec![failed("b@example.org")],
        ..many
    };
    let mut builder = one.builder(false, DsnRet::Headers);
    builder.reporting_mta = "mx example";
    assert_eq!(builder.build(), Err(DsnBuildError::InvalidReportingMta));
    let mut builder = one.builder(false, DsnRet::Headers);
    builder.message_id = "a>b";
    assert_eq!(builder.build(), Err(DsnBuildError::InvalidMessageId));
    let mut builder = one.builder(false, DsnRet::Headers);
    builder.original_message_id = Some("a b");
    assert_eq!(builder.build(), Err(DsnBuildError::InvalidMessageId));
    let mut builder = one.builder(false, DsnRet::Headers);
    builder.original_envelope_id = Some("a\r\nb");
    assert_eq!(builder.build(), Err(DsnBuildError::InvalidEnvelopeId));
}

/// Avis de type Postfix : partie du message, deux destinataires, commentaires, `Status` avec
/// texte, `Remote-MTA` et `Diagnostic-Code` repliés.
const POSTFIX: &str = "From: MAILER-DAEMON@mail.example.com (Mail Delivery System)\r
To: sender@example.org\r
Subject: Undelivered Mail Returned to Sender\r
MIME-Version: 1.0\r
Content-Type: multipart/report; report-type=delivery-status;\r
\tboundary=\"ABC/mail.example.com\"\r
\r
This is a MIME-encapsulated message.\r
\r
--ABC/mail.example.com\r
Content-Description: Notification\r
Content-Type: text/plain; charset=us-ascii\r
\r
I'm sorry to have to inform you that your message could not be delivered.\r
\r
--ABC/mail.example.com\r
Content-Description: Delivery report\r
Content-Type: message/delivery-status\r
\r
Reporting-MTA: dns; mail.example.com\r
X-Postfix-Queue-ID: 4ABCD\r
X-Postfix-Sender: rfc822; sender@example.org\r
Arrival-Date: Thu, 26 Nov 2026 09:58:03 +0100 (CET)\r
\r
Final-Recipient: rfc822; nobody@example.net\r
Original-Recipient: rfc822;Nobody@Example.NET\r
Action: failed\r
Status: 5.1.1 (bad destination mailbox address)\r
Remote-MTA: dns; mx.example.net (ignored comment)\r
Diagnostic-Code: smtp; 550 5.1.1 <nobody@example.net>: Recipient address\r
    rejected: User unknown in virtual mailbox table\r
\r
Final-Recipient: RFC822; <slow@example.net>\r
ACTION: Delayed (comment)\r
status: 4.4.1\r
Will-Retry-Until: Tue, 1 Dec 2026 09:58:03 +0100\r
\r
--ABC/mail.example.com\r
Content-Description: Undelivered Message Headers\r
Content-Type: text/rfc822-headers\r
\r
Subject: hello\r
\r
--ABC/mail.example.com--\r
";

#[test]
fn postfix_like_report() {
    let report = read(POSTFIX.as_bytes()).expect("avis");
    assert_eq!(report.reporting_mta.as_deref(), Some("mail.example.com"));
    assert_eq!(
        report.arrival_date,
        Some(datetime!(2026-11-26 09:58:03 +01:00))
    );
    assert_eq!(report.recipients.len(), 2);
    let first = &report.recipients[0];
    assert_eq!(first.final_recipient.address, "nobody@example.net");
    assert_eq!(
        first
            .original_recipient
            .as_ref()
            .map(|a| a.address.as_str()),
        Some("Nobody@Example.NET")
    );
    assert_eq!(first.action, DsnAction::Failed);
    assert_eq!(first.status, status("5.1.1"));
    assert_eq!(first.remote_mta.as_deref(), Some("mx.example.net"));
    assert_eq!(
        first.diagnostic,
        Some(DsnDiagnostic::smtp(
            "550 5.1.1 <nobody@example.net>: Recipient address    rejected: User unknown in \
             virtual mailbox table"
        ))
    );
    let second = &report.recipients[1];
    assert_eq!(second.final_recipient.address_type, "rfc822");
    assert_eq!(second.final_recipient.address, "slow@example.net");
    assert_eq!(second.action, DsnAction::Delayed);
    assert_eq!(
        second.will_retry_until,
        Some(datetime!(2026-12-01 09:58:03 +01:00))
    );
}

#[test]
fn tolerant_reading() {
    // LF seuls, aucun groupe du message, `Status` absent, rapport codé en Base64 et placé dans
    // un `multipart/mixed`, un groupe sans `Final-Recipient`, un autre à l'action inconnue.
    let status_part = "Final-Recipient: rfc822;a@example.org\n\
                       Action: failed\n\
                       \n\
                       Action: failed\n\
                       Status: 5.0.0\n\
                       \n\
                       Final-Recipient: rfc822;b@example.org\n\
                       Action: bounced\n";
    let encoded = base64_lines(status_part.as_bytes());
    let raw = format!(
        "From: x@example.org\r\nMIME-Version: 1.0\r\nContent-Type: multipart/mixed; boundary=b\r\n\r\n\
         --b\r\nContent-Type: text/plain\r\n\r\nhello\r\n\
         --b\r\nContent-Type: message/delivery-status\r\nContent-Transfer-Encoding: base64\r\n\r\n\
         {encoded}--b--\r\n"
    );
    let report = read(raw.as_bytes()).expect("avis");
    assert_eq!(report.reporting_mta, None);
    assert_eq!(report.recipients.len(), 1);
    assert_eq!(
        report.recipients[0].final_recipient.address,
        "a@example.org"
    );
    assert_eq!(report.recipients[0].status, status("5.0.0"));
    assert_eq!(report.ignored_recipients, 2);

    // Quoted-printable et adresse utf-8 codée.
    let raw = "From: x@example.org\r\nMIME-Version: 1.0\r\n\
               Content-Type: multipart/report; report-type=delivery-status; boundary=b\r\n\r\n\
               --b\r\n\r\ntext\r\n\
               --b\r\nContent-Type: message/delivery-status\r\n\
               Content-Transfer-Encoding: quoted-printable\r\n\r\n\
               Reporting-MTA: dns; mx.example\r\n\r\n\
               Final-Recipient: utf-8; j\\x{F6}ran@example.org\r\n\
               Action: =\r\nfailed\r\nStatus: 5.2.2\r\n--b--\r\n";
    let report = read(raw.as_bytes()).expect("avis");
    assert_eq!(
        report.recipients[0].final_recipient.address,
        "jöran@example.org"
    );
    assert_eq!(report.recipients[0].status, status("5.2.2"));
}

fn base64_lines(bytes: &[u8]) -> String {
    use base64::Engine as _;
    let encoded = base64::engine::general_purpose::STANDARD.encode(bytes);
    encoded
        .as_bytes()
        .chunks(76)
        .map(|line| format!("{}\r\n", std::str::from_utf8(line).expect("ASCII")))
        .collect()
}

#[test]
fn read_refusals() {
    let not_report = b"From: a@example.org\r\nSubject: hi\r\n\r\nbody\r\n";
    assert_eq!(read(not_report), Err(DsnParseError::NotAReport));

    let wrap = |status: &str| {
        format!(
            "From: x@example.org\r\nMIME-Version: 1.0\r\n\
             Content-Type: multipart/report; report-type=delivery-status; boundary=b\r\n\r\n\
             --b\r\n\r\ntext\r\n--b\r\nContent-Type: message/delivery-status\r\n\r\n\
             {status}\r\n--b--\r\n"
        )
    };
    let too_many = format!(
        "Reporting-MTA: dns; mx.example\r\n\r\n{}",
        "Final-Recipient: rfc822; a@example.org\r\nAction: failed\r\n\r\n"
            .repeat(MAX_DSN_RECIPIENTS + 1)
    );
    assert_eq!(
        read(wrap(&too_many).as_bytes()),
        Err(DsnParseError::TooManyRecipients)
    );
    let most = format!(
        "Reporting-MTA: dns; mx.example\r\n\r\n{}",
        "Final-Recipient: rfc822; a@example.org\r\nAction: failed\r\n\r\n"
            .repeat(MAX_DSN_RECIPIENTS)
    );
    assert_eq!(
        read(wrap(&most).as_bytes()).expect("avis").recipients.len(),
        MAX_DSN_RECIPIENTS
    );
    let large = format!(
        "Reporting-MTA: dns; mx.example\r\nX-Pad: {}\r\n",
        "p".repeat(MAX_REPORT_BYTES)
    );
    assert_eq!(read(wrap(&large).as_bytes()), Err(DsnParseError::TooLarge));
    let none = "Reporting-MTA: dns; mx.example\r\n\r\nAction: failed\r\n";
    assert_eq!(read(wrap(none).as_bytes()), Err(DsnParseError::NoRecipient));
    let raw = "From: x@example.org\r\nMIME-Version: 1.0\r\n\
               Content-Type: multipart/report; report-type=delivery-status; boundary=b\r\n\r\n\
               --b\r\nContent-Type: message/delivery-status\r\n\
               Content-Transfer-Encoding: base64\r\n\r\n!!!!\r\n--b--\r\n";
    assert_eq!(read(raw.as_bytes()), Err(DsnParseError::InvalidEncoding));
}

fn recipient_strategy() -> impl Strategy<Value = DsnRecipient> {
    let address = "[a-z0-9.+_-]{1,20}@[a-z0-9-]{1,10}\\.[a-z]{2,6}";
    let action = prop_oneof![
        Just(DsnAction::Failed),
        Just(DsnAction::Delayed),
        Just(DsnAction::Delivered),
        Just(DsnAction::Relayed),
        Just(DsnAction::Expanded),
    ];
    let date = (0i64..4_000_000_000, -12i8..=14).prop_map(|(seconds, hours)| {
        OffsetDateTime::from_unix_timestamp(seconds)
            .expect("date")
            .to_offset(time::UtcOffset::from_hms(hours, 0, 0).expect("décalage"))
    });
    (
        prop::option::of(address),
        address,
        action,
        (2u8..=5, 0u16..=7, 0u16..=30),
        prop::option::of("[a-z0-9-]{1,12}(\\.[a-z0-9-]{1,12}){0,3}"),
        prop::option::of("[!-~]{1,20}( [!-~]{1,20}){0,40}"),
        prop::option::of(date.clone()),
        prop::option::of(date),
    )
        .prop_filter_map(
            "classe de statut",
            |(
                original,
                last,
                action,
                (class, subject, detail),
                remote,
                diagnostic,
                attempt,
                until,
            )| {
                let status =
                    EnhancedStatus::new(if class == 3 { 2 } else { class }, subject, detail)?;
                Some(DsnRecipient {
                    original_recipient: original.map(|a| DsnAddress {
                        address_type: "rfc822".to_owned(),
                        address: a,
                    }),
                    final_recipient: DsnAddress {
                        address_type: "rfc822".to_owned(),
                        address: last,
                    },
                    action,
                    status,
                    remote_mta: remote,
                    diagnostic: diagnostic.map(DsnDiagnostic::smtp),
                    last_attempt_date: attempt,
                    will_retry_until: until,
                })
            },
        )
}

proptest! {
    #![proptest_config(ProptestConfig::with_cases(64))]

    /// Un avis écrit est relu à l'identique.
    #[test]
    fn written_dsn_reads_back(
        recipients in prop::collection::vec(recipient_strategy(), 1..8),
        envid in prop::option::of("[!-~]{1,40}"),
        international in any::<bool>(),
        full in any::<bool>(),
    ) {
        let from = mailbox("MAILER-DAEMON@smtp.lyxal.example");
        let to = mailbox("alice@lyxal.example");
        let raw = DsnBuilder {
            reporting_mta: "smtp.lyxal.example",
            from: &from,
            to: &to,
            message_id: "p@smtp.lyxal.example",
            date: OffsetDateTime::UNIX_EPOCH,
            original_message_id: Some("o@lyxal.example"),
            international,
            original_envelope_id: envid.as_deref(),
            arrival_date: datetime!(2026-11-27 10:00:00 UTC),
            recipients: &recipients,
            ret: if full { DsnRet::Full } else { DsnRet::Headers },
            original: b"Subject: x\r\n\r\nbody\r\n",
        }
        .build()
        .expect("avis");
        let report = read(&raw).expect("relu");
        prop_assert_eq!(report.international, international);
        prop_assert_eq!(report.original_envelope_id.as_deref(), envid.as_deref());
        prop_assert_eq!(report.recipients, recipients);
    }

    /// Aucune entrée ne fait paniquer la lecture.
    #[test]
    fn parse_never_panics(body in prop::collection::vec(any::<u8>(), 0..2048)) {
        let mut raw = b"From: x@example.org\r\nMIME-Version: 1.0\r\n\
            Content-Type: multipart/report; report-type=delivery-status; boundary=b\r\n\r\n\
            --b\r\nContent-Type: message/delivery-status\r\n\r\n".to_vec();
        raw.extend_from_slice(&body);
        raw.extend_from_slice(b"\r\n--b--\r\n");
        if let Ok(parsed) = parse(&raw, &MimeLimits::default()) {
            let _ = parse_dsn(&raw, &parsed);
        }
    }
}

#[test]
fn quoted_local_part_and_envelope_id_spaces_read_back() {
    // Parenthèses d'une partie locale entre guillemets : pas un commentaire. Espaces de bord
    // d'un `Original-Envelope-Id` : gardées (RFC 3464 §2.2.1).
    let recipients = vec![failed("\"a(b)\"@example.org")];
    let from = mailbox("MAILER-DAEMON@smtp.lyxal.example");
    let to = mailbox("alice@lyxal.example");
    for envid in ["  id  ", " "] {
        let raw = DsnBuilder {
            reporting_mta: "smtp.lyxal.example",
            from: &from,
            to: &to,
            message_id: "dsn.2@smtp.lyxal.example",
            date: datetime!(2026-11-27 10:00:05 UTC),
            original_message_id: None,
            international: false,
            original_envelope_id: Some(envid),
            arrival_date: datetime!(2026-11-27 09:00:00 UTC),
            recipients: &recipients,
            ret: DsnRet::Headers,
            original: b"From: alice@lyxal.example\r\nSubject: hi\r\n\r\nBody\r\n",
        }
        .build()
        .expect("avis");
        let report = read(&raw).expect("relu");
        assert_eq!(report.original_envelope_id.as_deref(), Some(envid));
        assert_eq!(report.recipients, recipients);
    }
}
