// SPDX-License-Identifier: AGPL-3.0-only

//! Lecture des commandes SMTP : toutes les commandes, paramètres, adresses et refus.

mod smtp_support;

use std::net::{Ipv4Addr, Ipv6Addr};

use lyxal_mail_proto::smtp::{
    Body, Domain, DsnNotify, DsnRet, ForwardPath, MailFrom, RcptTo, Request, ReversePath, SmtpError,
};
use smtp_support::command;

fn mail(line: &str) -> MailFrom {
    match command(line) {
        Ok(Request::Mail(mail)) => mail,
        other => panic!("{line:?} : {other:?}"),
    }
}

fn rcpt(line: &str) -> RcptTo {
    match command(line) {
        Ok(Request::Rcpt(rcpt)) => rcpt,
        other => panic!("{line:?} : {other:?}"),
    }
}

fn mailbox_of(path: &ReversePath) -> (String, Domain) {
    match path {
        ReversePath::Mailbox(mailbox) => {
            (mailbox.local_part().to_owned(), mailbox.domain().clone())
        }
        ReversePath::Null => panic!("chemin vide"),
    }
}

fn name(value: &str) -> Domain {
    Domain::Name(value.to_owned())
}

#[test]
fn simple_commands() {
    for (line, expected) in [
        ("DATA\r\n", Request::Data),
        ("data\r\n", Request::Data),
        ("RSET\r\n", Request::Rset),
        ("QUIT\r\n", Request::Quit),
        ("qUiT  \t\r\n", Request::Quit),
        ("STARTTLS\r\n", Request::StartTls),
        ("NOOP\r\n", Request::Noop),
        ("NOOP anything goes\r\n", Request::Noop),
        ("HELP\r\n", Request::Help),
        ("HELP MAIL\r\n", Request::Help),
        ("VRFY postmaster\r\n", Request::Vrfy),
        ("EXPN staff\r\n", Request::Expn),
        ("LHLO client.example\r\n", Request::Lhlo),
        ("AUTH PLAIN dGVzdAB0ZXN0AHRlc3Q=\r\n", Request::Auth),
        ("ETRN example.com\r\n", Request::Etrn),
        ("ATRN example.com\r\n", Request::Atrn),
        ("BURL imap://x LAST\r\n", Request::Burl),
    ] {
        assert_eq!(command(line), Ok(expected), "{line:?}");
    }
}

#[test]
fn commands_without_arguments_refuse_arguments() {
    for (line, name) in [
        ("DATA x\r\n", "DATA"),
        ("RSET now\r\n", "RSET"),
        ("QUIT bye\r\n", "QUIT"),
        ("STARTTLS please\r\n", "STARTTLS"),
    ] {
        assert_eq!(command(line), Err(SmtpError::Syntax(name)), "{line:?}");
    }
    assert_eq!(command("VRFY\r\n"), Err(SmtpError::Syntax("VRFY")));
    assert_eq!(command("EXPN \r\n"), Err(SmtpError::Syntax("EXPN")));
}

#[test]
fn unknown_commands() {
    for line in [
        "\r\n",
        " \r\n",
        "FOO\r\n",
        "MAILFROM:<a@b.c>\r\n",
        "TURN\r\n",
        "EHLO\tclient.example\r\n",
        "VERYLONGVERB x\r\n",
        "ÉHLO x\r\n",
    ] {
        assert_eq!(command(line), Err(SmtpError::UnknownCommand), "{line:?}");
    }
}

#[test]
fn hello() {
    assert_eq!(
        command("EHLO client.example.org\r\n"),
        Ok(Request::Ehlo {
            host: name("client.example.org")
        })
    );
    assert_eq!(
        command("helo localhost\r\n"),
        Ok(Request::Helo {
            host: name("localhost")
        })
    );
    assert_eq!(
        command("EHLO [192.0.2.1]\r\n"),
        Ok(Request::Ehlo {
            host: Domain::Ipv4(Ipv4Addr::new(192, 0, 2, 1))
        })
    );
    assert_eq!(
        command("EHLO [IPv6:2001:db8::1]\r\n"),
        Ok(Request::Ehlo {
            host: Domain::Ipv6("2001:db8::1".parse::<Ipv6Addr>().expect("ip"))
        })
    );
    // Texte toléré après une adresse littérale (RFC 5321 §4.1.4).
    assert!(command("EHLO [192.0.2.1] mail.example\r\n").is_ok());
    // Espaces en fin de ligne tolérées.
    assert!(command("EHLO client.example  \r\n").is_ok());
    // Domaine Unicode (U-label), converti en A-label par lyxal_mail.
    assert_eq!(
        command("EHLO bücher.example\r\n"),
        Ok(Request::Ehlo {
            host: name("bücher.example")
        })
    );
    for line in [
        "EHLO\r\n",
        "EHLO \r\n",
        "EHLO client..example\r\n",
        "EHLO -client.example\r\n",
        "EHLO client-.example\r\n",
        "EHLO client.example.\r\n",
        "EHLO my_pc\r\n",
        "EHLO client.example extra\r\n",
        "EHLO [300.0.0.1]\r\n",
        "EHLO [2001:db8::1]\r\n",
        "EHLO [IPv6:192.0.2.1]\r\n",
        "EHLO [192.0.2.1\r\n",
        "HELO [192.0.2.1] extra\r\n",
    ] {
        let name = if line.starts_with("HELO") {
            "HELO"
        } else {
            "EHLO"
        };
        assert_eq!(command(line), Err(SmtpError::Syntax(name)), "{line:?}");
    }
    let long_label = format!("EHLO {}.example\r\n", "a".repeat(64));
    assert_eq!(command(&long_label), Err(SmtpError::Syntax("EHLO")));
    let long_domain = format!("EHLO {}a\r\n", "a.".repeat(128));
    assert_eq!(command(&long_domain), Err(SmtpError::Syntax("EHLO")));
}

#[test]
fn mail_from_paths() {
    let null = mail("MAIL FROM:<>\r\n");
    assert_eq!(null.reverse_path, ReversePath::Null);
    assert!(!null.source_route);

    let plain = mail("MAIL FROM:<Smith@bar.com>\r\n");
    assert_eq!(
        mailbox_of(&plain.reverse_path),
        ("Smith".to_owned(), name("bar.com"))
    );

    // Casse des mots-clés, espaces après les deux-points (tolérance Mox).
    let spaced = mail("mail from: <a.b+c@x.example>\r\n");
    assert_eq!(
        mailbox_of(&spaced.reverse_path),
        ("a.b+c".to_owned(), name("x.example"))
    );

    // Partie locale entre guillemets : décodée, réécrite entre guillemets.
    let quoted = mail("MAIL FROM:<\"John \\\"Q\\\" Public\"@example.com>\r\n");
    let (local, _) = mailbox_of(&quoted.reverse_path);
    assert_eq!(local, "John \"Q\" Public");
    if let ReversePath::Mailbox(mailbox) = &quoted.reverse_path {
        assert_eq!(mailbox.to_string(), "\"John \\\"Q\\\" Public\"@example.com");
    }
    let quoted_gt = mail("MAIL FROM:<\"a>b\"@example.com> SIZE=10\r\n");
    assert_eq!(quoted_gt.size, Some(10));

    // Adresses littérales.
    let literal = mail("MAIL FROM:<user@[192.0.2.7]>\r\n");
    assert_eq!(
        mailbox_of(&literal.reverse_path).1,
        Domain::Ipv4(Ipv4Addr::new(192, 0, 2, 7))
    );
    let literal6 = mail("MAIL FROM:<user@[ipv6:2001:db8::7]>\r\n");
    assert!(matches!(
        mailbox_of(&literal6.reverse_path).1,
        Domain::Ipv6(_)
    ));

    // Route source lue puis ignorée, signalée.
    let routed = mail("MAIL FROM:<@a.example,@b.example:user@c.example>\r\n");
    assert!(routed.source_route);
    assert_eq!(
        mailbox_of(&routed.reverse_path),
        ("user".to_owned(), name("c.example"))
    );
}

#[test]
fn mail_from_refusals() {
    for line in [
        "MAIL\r\n",
        "MAIL FROM\r\n",
        "MAIL TO:<a@b.c>\r\n",
        "MAIL FROM:a@b.c\r\n",
        "MAIL FROM a@b.c\r\n",
        "MAIL FROM:<a@b.c>SIZE=1\r\n",
        "MAIL FROM:<a@b.c> =1\r\n",
        "MAIL FROM:<a@b.c> SIZE==1\r\n",
        "MAIL FROM:<a@b.c> -X=1\r\n",
    ] {
        assert_eq!(command(line), Err(SmtpError::Syntax("MAIL")), "{line:?}");
    }
    for line in [
        "MAIL FROM:<a@b.c\r\n",
        "MAIL FROM:<@b.c>\r\n",
        "MAIL FROM:<a@>\r\n",
        "MAIL FROM:<a>\r\n",
        "MAIL FROM:<Postmaster>\r\n",
        "MAIL FROM:<.a@b.c>\r\n",
        "MAIL FROM:<a.@b.c>\r\n",
        "MAIL FROM:<a..b@b.c>\r\n",
        "MAIL FROM:<a b@b.c>\r\n",
        "MAIL FROM:<a@b@c.d>\r\n",
        "MAIL FROM:<a@b..c>\r\n",
        "MAIL FROM:<a@[1.2.3]>\r\n",
        "MAIL FROM:<a@[tag:content]>\r\n",
        "MAIL FROM:<\"unterminated@b.c>\r\n",
        "MAIL FROM:<\"tab\tinside\"@b.c>\r\n",
        "MAIL FROM:<@a.example:@b.example:x@c.example>\r\n",
        "MAIL FROM:<@a.example,b.example:x@c.example>\r\n",
    ] {
        assert_eq!(command(line), Err(SmtpError::InvalidSender), "{line:?}");
    }
    // Longueurs : chemin de 256 octets au plus, partie locale de 128.
    let local = "a".repeat(129);
    assert_eq!(
        command(&format!("MAIL FROM:<{local}@b.example>\r\n")),
        Err(SmtpError::InvalidSender)
    );
    let ok_local = "a".repeat(128);
    assert!(command(&format!("MAIL FROM:<{ok_local}@b.example>\r\n")).is_ok());
    let domain = format!("{}.example", ["abcdefghij"; 12].join("."));
    let path = format!("{ok_local}@{domain}");
    assert!(path.len() + 2 > 256);
    assert_eq!(
        command(&format!("MAIL FROM:<{path}>\r\n")),
        Err(SmtpError::InvalidSender)
    );
}

#[test]
fn mail_from_parameters() {
    let full = mail("MAIL FROM:<a@b.example> SIZE=1048576 BODY=8BITMIME SMTPUTF8\r\n");
    assert_eq!(full.size, Some(1_048_576));
    assert_eq!(full.body, Some(Body::EightBitMime));
    assert!(full.smtputf8);
    assert!(!full.uses_dsn());

    let lower = mail("MAIL FROM:<a@b.example>  size=0   body=7bit  \r\n");
    assert_eq!(lower.size, Some(0));
    assert_eq!(lower.body, Some(Body::SevenBit));

    assert_eq!(
        mail("MAIL FROM:<a@b.example> BODY=BINARYMIME\r\n").body,
        Some(Body::BinaryMime)
    );
    assert_eq!(
        mail("MAIL FROM:<a@b.example> SIZE=18446744073709551615\r\n").size,
        Some(u64::MAX)
    );

    let dsn = mail("MAIL FROM:<a@b.example> RET=HDRS ENVID=QQ314159+2B1\r\n");
    assert_eq!(dsn.dsn_ret, Some(DsnRet::Headers));
    assert_eq!(dsn.dsn_envid.as_deref(), Some("QQ314159+2B1"));
    assert!(dsn.uses_dsn());
    assert_eq!(
        mail("MAIL FROM:<> RET=FULL\r\n").dsn_ret,
        Some(DsnRet::Full)
    );

    for (line, error) in [
        (
            "MAIL FROM:<a@b.c> SIZE\r\n",
            SmtpError::InvalidParameter("SIZE"),
        ),
        (
            "MAIL FROM:<a@b.c> SIZE=-1\r\n",
            SmtpError::InvalidParameter("SIZE"),
        ),
        (
            "MAIL FROM:<a@b.c> SIZE=1k\r\n",
            SmtpError::InvalidParameter("SIZE"),
        ),
        (
            "MAIL FROM:<a@b.c> SIZE=123456789012345678901\r\n",
            SmtpError::InvalidParameter("SIZE"),
        ),
        (
            "MAIL FROM:<a@b.c> SIZE=18446744073709551616\r\n",
            SmtpError::InvalidParameter("SIZE"),
        ),
        (
            "MAIL FROM:<a@b.c> BODY=9BIT\r\n",
            SmtpError::InvalidParameter("BODY"),
        ),
        (
            "MAIL FROM:<a@b.c> BODY\r\n",
            SmtpError::InvalidParameter("BODY"),
        ),
        (
            "MAIL FROM:<a@b.c> SMTPUTF8=yes\r\n",
            SmtpError::InvalidParameter("SMTPUTF8"),
        ),
        (
            "MAIL FROM:<a@b.c> RET=ALL\r\n",
            SmtpError::InvalidParameter("RET"),
        ),
        (
            "MAIL FROM:<a@b.c> ENVID=a+zz\r\n",
            SmtpError::InvalidParameter("ENVID"),
        ),
        (
            "MAIL FROM:<a@b.c> SIZE=1 SIZE=2\r\n",
            SmtpError::DuplicateParameter("SIZE"),
        ),
        (
            "MAIL FROM:<a@b.c> BODY=7BIT body=8bitmime\r\n",
            SmtpError::DuplicateParameter("BODY"),
        ),
        (
            "MAIL FROM:<a@b.c> SMTPUTF8 SMTPUTF8\r\n",
            SmtpError::DuplicateParameter("SMTPUTF8"),
        ),
        (
            "MAIL FROM:<a@b.c> AUTH=<>\r\n",
            SmtpError::UnsupportedParameter,
        ),
        (
            "MAIL FROM:<a@b.c> REQUIRETLS\r\n",
            SmtpError::UnsupportedParameter,
        ),
        (
            "MAIL FROM:<a@b.c> HOLDFOR=10\r\n",
            SmtpError::UnsupportedParameter,
        ),
        (
            "MAIL FROM:<a@b.c> MT-PRIORITY=3\r\n",
            SmtpError::UnsupportedParameter,
        ),
        (
            "MAIL FROM:<a@b.c> XFOO\r\n",
            SmtpError::UnsupportedParameter,
        ),
    ] {
        assert_eq!(command(line), Err(error), "{line:?}");
    }
    let envid = format!("MAIL FROM:<a@b.c> ENVID={}\r\n", "x".repeat(101));
    assert_eq!(command(&envid), Err(SmtpError::InvalidParameter("ENVID")));
}

#[test]
fn smtputf8_addresses() {
    let utf8 = mail("MAIL FROM:<用户@例子.广告> SMTPUTF8\r\n");
    assert!(!utf8.reverse_path.is_ascii());
    assert_eq!(
        mailbox_of(&utf8.reverse_path),
        ("用户".to_owned(), name("例子.广告"))
    );
    assert_eq!(
        command("MAIL FROM:<用户@例子.广告>\r\n"),
        Err(SmtpError::Utf8WithoutSmtpUtf8)
    );
    assert_eq!(
        command("MAIL FROM:<jörg@example.com> BODY=8BITMIME\r\n"),
        Err(SmtpError::Utf8WithoutSmtpUtf8)
    );
    assert!(mail("MAIL FROM:<\"jörg doe\"@exämple.com> SMTPUTF8\r\n").smtputf8);
    // Destinataire non ASCII : lu, contrôlé par la session selon la transaction.
    let to = rcpt("RCPT TO:<δοκιμή@παράδειγμα.δοκιμή>\r\n");
    assert!(!to.forward_path.is_ascii());
    // UTF-8 invalide : refusé, jamais converti avec perte.
    let (results, _) = smtp_support::commands(b"MAIL FROM:<a\xff@b.c> SMTPUTF8\r\n", 64);
    assert_eq!(results, vec![Err(SmtpError::InvalidUtf8)]);
    // Caractère de commande Unicode refusé.
    assert_eq!(
        command("MAIL FROM:<a\u{0085}b@c.d> SMTPUTF8\r\n"),
        Err(SmtpError::InvalidSender)
    );
}

#[test]
fn rcpt_to() {
    let to = rcpt("RCPT TO:<Jones@XYZ.COM>\r\n");
    match &to.forward_path {
        ForwardPath::Mailbox(mailbox) => {
            assert_eq!(mailbox.local_part(), "Jones");
            assert_eq!(mailbox.domain(), &name("XYZ.COM"));
        }
        ForwardPath::Postmaster => panic!("boîte attendue"),
    }
    assert!(!to.source_route);
    assert!(!to.uses_dsn());

    for line in [
        "RCPT TO:<Postmaster>\r\n",
        "rcpt to:<postmaster>\r\n",
        "RCPT TO: <POSTMASTER>\r\n",
    ] {
        assert_eq!(rcpt(line).forward_path, ForwardPath::Postmaster, "{line:?}");
    }
    assert!(matches!(
        rcpt("RCPT TO:<postmaster@example.com>\r\n").forward_path,
        ForwardPath::Mailbox(_)
    ));

    let routed = rcpt("RCPT TO:<@hosta.int,@jkl.org:userc@d.bar.org>\r\n");
    assert!(routed.source_route);

    // Adresses de relais : lues telles quelles, la session refuse (plan §7.3).
    let percent = rcpt("RCPT TO:<user%other@example.com>\r\n");
    if let ForwardPath::Mailbox(mailbox) = &percent.forward_path {
        assert_eq!(mailbox.local_part(), "user%other");
    }
    let literal = rcpt("RCPT TO:<x@[127.0.0.1]>\r\n");
    if let ForwardPath::Mailbox(mailbox) = &literal.forward_path {
        assert!(mailbox.domain().is_address_literal());
    }

    let dsn =
        rcpt("RCPT TO:<a@b.example> NOTIFY=SUCCESS,FAILURE ORCPT=rfc822;Bob+40Example.COM\r\n");
    assert_eq!(
        dsn.dsn_notify,
        Some(DsnNotify {
            never: false,
            success: true,
            failure: true,
            delay: false
        })
    );
    let orcpt = dsn.dsn_orcpt.as_ref().expect("orcpt");
    assert_eq!(orcpt.address_type, "rfc822");
    assert_eq!(orcpt.address, "Bob+40Example.COM");
    assert!(dsn.uses_dsn());
    assert!(rcpt("RCPT TO:<a@b.example> NOTIFY=never\r\n")
        .dsn_notify
        .is_some_and(|n| n.never));

    for (line, error) in [
        ("RCPT\r\n", SmtpError::Syntax("RCPT")),
        ("RCPT TO\r\n", SmtpError::Syntax("RCPT")),
        ("RCPT FROM:<a@b.c>\r\n", SmtpError::Syntax("RCPT")),
        ("RCPT TO:a@b.c\r\n", SmtpError::Syntax("RCPT")),
        ("RCPT TO:<>\r\n", SmtpError::InvalidRecipient),
        ("RCPT TO:<a>\r\n", SmtpError::InvalidRecipient),
        ("RCPT TO:<postmaster@>\r\n", SmtpError::InvalidRecipient),
        (
            "RCPT TO:<a@b.c> NOTIFY=NEVER,DELAY\r\n",
            SmtpError::InvalidParameter("NOTIFY"),
        ),
        (
            "RCPT TO:<a@b.c> NOTIFY=SUCCESS,SUCCESS\r\n",
            SmtpError::InvalidParameter("NOTIFY"),
        ),
        (
            "RCPT TO:<a@b.c> NOTIFY=SOMETIMES\r\n",
            SmtpError::InvalidParameter("NOTIFY"),
        ),
        (
            "RCPT TO:<a@b.c> ORCPT=rfc822\r\n",
            SmtpError::InvalidParameter("ORCPT"),
        ),
        (
            "RCPT TO:<a@b.c> ORCPT=;a@b.c\r\n",
            SmtpError::InvalidParameter("ORCPT"),
        ),
        (
            "RCPT TO:<a@b.c> NOTIFY=DELAY NOTIFY=DELAY\r\n",
            SmtpError::DuplicateParameter("NOTIFY"),
        ),
        (
            "RCPT TO:<a@b.c> SIZE=1\r\n",
            SmtpError::UnsupportedParameter,
        ),
        (
            "RCPT TO:<a@b.c> RRVS=2026-01-01T00:00:00Z\r\n",
            SmtpError::UnsupportedParameter,
        ),
    ] {
        assert_eq!(command(line), Err(error), "{line:?}");
    }
}

#[test]
fn bdat() {
    assert_eq!(
        command("BDAT 86 LAST\r\n"),
        Ok(Request::Bdat {
            size: 86,
            last: true
        })
    );
    assert_eq!(
        command("bdat 0 last\r\n"),
        Ok(Request::Bdat {
            size: 0,
            last: true
        })
    );
    assert_eq!(
        command("BDAT 100000\r\n"),
        Ok(Request::Bdat {
            size: 100_000,
            last: false
        })
    );
    assert_eq!(
        command("BDAT 18446744073709551615 LAST\r\n"),
        Ok(Request::Bdat {
            size: u64::MAX,
            last: true
        })
    );
    for line in [
        "BDAT\r\n",
        "BDAT LAST\r\n",
        "BDAT -1\r\n",
        "BDAT 1e3\r\n",
        "BDAT 10 FIRST\r\n",
        "BDAT 10 LAST more\r\n",
        "BDAT 18446744073709551616\r\n",
        "BDAT 123456789012345678901\r\n",
    ] {
        assert_eq!(command(line), Err(SmtpError::Syntax("BDAT")), "{line:?}");
    }
}

#[test]
fn request_properties() {
    let group_end = [
        "EHLO a.example\r\n",
        "HELO a.example\r\n",
        "DATA\r\n",
        "VRFY x\r\n",
        "EXPN x\r\n",
        "QUIT\r\n",
        "NOOP\r\n",
        "STARTTLS\r\n",
        "AUTH PLAIN\r\n",
        "LHLO a\r\n",
    ];
    for line in group_end {
        let request = command(line).expect("commande");
        assert!(request.ends_pipeline_group(), "{line:?}");
    }
    for line in [
        "MAIL FROM:<>\r\n",
        "RCPT TO:<a@b.c>\r\n",
        "RSET\r\n",
        "BDAT 1\r\n",
        "HELP\r\n",
    ] {
        let request = command(line).expect("commande");
        assert!(!request.ends_pipeline_group(), "{line:?}");
        assert!(!request.forbids_pipelined_input(), "{line:?}");
    }
    assert!(Request::StartTls.forbids_pipelined_input());
    assert!(Request::Data.forbids_pipelined_input());
    assert_eq!(Request::StartTls.name(), "STARTTLS");
    assert_eq!(
        Request::Bdat {
            size: 1,
            last: false
        }
        .name(),
        "BDAT"
    );
}

#[test]
fn error_responses_are_well_formed() {
    let errors = [
        SmtpError::UnknownCommand,
        SmtpError::Syntax("MAIL"),
        SmtpError::InvalidSender,
        SmtpError::InvalidRecipient,
        SmtpError::InvalidParameter("SIZE"),
        SmtpError::DuplicateParameter("SIZE"),
        SmtpError::UnsupportedParameter,
        SmtpError::Utf8WithoutSmtpUtf8,
        SmtpError::LineTooLong,
        SmtpError::BareCr,
        SmtpError::BareLf,
        SmtpError::NulByte,
        SmtpError::InvalidUtf8,
    ];
    for error in errors {
        let response = error.response();
        assert!(response.is_permanent(), "{error:?}");
        let status = response.status().expect("code étendu");
        assert_eq!(u16::from(status.class()), response.code() / 100);
        let lines = smtp_support::parse_reply(&response.to_bytes());
        assert_eq!(lines.len(), 1);
        assert!(lines[0].text.starts_with(&status.to_string()));
    }
    let smuggling = SmtpError::BareLf.response();
    assert_eq!(smuggling.code(), 500);
    assert_eq!(
        smuggling.status().map(|s| s.to_string()).as_deref(),
        Some("5.5.2")
    );
    assert_eq!(SmtpError::UnsupportedParameter.response().code(), 555);
    assert_eq!(SmtpError::Utf8WithoutSmtpUtf8.response().code(), 553);
}
