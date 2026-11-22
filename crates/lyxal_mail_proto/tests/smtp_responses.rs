// SPDX-License-Identifier: AGPL-3.0-only

//! Réponses du serveur : format sur une et plusieurs lignes, codes étendus (RFC 3463),
//! assainissement du texte, réponse à `EHLO` (extensions de la décision S5).

mod smtp_support;

use lyxal_mail_proto::smtp::{
    ehlo_response, helo_response, EnhancedStatus, Extensions, Response, ResponseError,
    MAX_REPLY_LINE_BYTES,
};
use smtp_support::parse_reply;

fn status(value: &str) -> Option<EnhancedStatus> {
    Some(EnhancedStatus::parse(value).expect("code étendu"))
}

#[test]
fn single_line() {
    let ok = Response::new(250, status("2.1.5"), "OK").expect("réponse");
    assert_eq!(ok.to_bytes(), b"250 2.1.5 OK\r\n");
    assert!(ok.is_positive());

    let start = Response::new(354, None, "End data with <CR><LF>.<CR><LF>").expect("réponse");
    assert_eq!(start.to_bytes(), b"354 End data with <CR><LF>.<CR><LF>\r\n");

    let temp = Response::new(451, status("4.3.0"), "Try again later").expect("réponse");
    assert!(temp.is_transient());
    assert!(!temp.is_permanent());

    let bare = Response::new(250, status("2.0.0"), "").expect("réponse");
    assert_eq!(bare.to_bytes(), b"250 2.0.0\r\n");
    let empty = Response::new(220, None, "").expect("réponse");
    assert_eq!(empty.to_bytes(), b"220 \r\n");
}

#[test]
fn multi_line() {
    let help = Response::with_lines(214, status("2.0.0"), ["Commands:", "EHLO MAIL RCPT", "End"])
        .expect("réponse");
    assert_eq!(
        help.to_bytes(),
        b"214-2.0.0 Commands:\r\n214-2.0.0 EHLO MAIL RCPT\r\n214 2.0.0 End\r\n"
    );
    let lines = parse_reply(&help.to_bytes());
    assert_eq!(lines.len(), 3);
    assert!(lines.iter().all(|line| line.code == 214));
    assert!(lines[2].last);

    let none = Response::with_lines(250, None, Vec::<String>::new()).expect("réponse");
    assert_eq!(none.lines().len(), 1);
}

#[test]
fn invalid_codes() {
    for code in [0, 199, 600, 999, 260, 199, 1000] {
        assert_eq!(
            Response::new(code, None, "x").err(),
            Some(ResponseError::InvalidCode),
            "{code}"
        );
    }
    assert_eq!(
        Response::new(250, status("5.0.0"), "x").err(),
        Some(ResponseError::StatusMismatch)
    );
    assert_eq!(
        Response::new(354, status("2.0.0"), "x").err(),
        Some(ResponseError::StatusMismatch)
    );
    assert_eq!(
        Response::new(550, status("4.2.2"), "x").err(),
        Some(ResponseError::StatusMismatch)
    );
}

#[test]
fn text_is_sanitized() {
    let injected = Response::new(
        550,
        status("5.1.1"),
        "Unknown <x>\r\n250 2.0.0 OK\r\nMAIL FROM:<\0>\tété",
    )
    .expect("réponse");
    let bytes = injected.to_bytes();
    assert_eq!(bytes.iter().filter(|&&b| b == b'\n').count(), 1);
    assert_eq!(bytes.iter().filter(|&&b| b == b'\r').count(), 1);
    let lines = parse_reply(&bytes);
    assert_eq!(lines.len(), 1);
    assert!(lines[0].text.contains("??250 2.0.0 OK??MAIL FROM:<?>??t?"));

    let long = Response::new(550, status("5.7.1"), &"x".repeat(2000)).expect("réponse");
    let bytes = long.to_bytes();
    assert_eq!(bytes.len(), MAX_REPLY_LINE_BYTES);
    parse_reply(&bytes);
    let long_plain = Response::new(220, None, &"y".repeat(2000)).expect("réponse");
    assert_eq!(long_plain.to_bytes().len(), MAX_REPLY_LINE_BYTES);
}

#[test]
fn enhanced_status_codes() {
    let code = EnhancedStatus::parse("5.7.1").expect("code");
    assert_eq!((code.class(), code.subject(), code.detail()), (5, 7, 1));
    assert_eq!(code.to_string(), "5.7.1");
    let wide = EnhancedStatus::parse("4.123.999").expect("code");
    assert_eq!(wide.to_string(), "4.123.999");
    for invalid in [
        "", "5", "5.7", "5.7.", "3.0.0", "1.0.0", "6.0.0", "5.1000.0", "5.0.1000", "5.a.1",
        "5.7.1.2", "55.7.1", " 5.7.1", "+5.7.1",
    ] {
        assert_eq!(EnhancedStatus::parse(invalid), None, "{invalid:?}");
    }
    assert!(EnhancedStatus::new(2, 0, 0).is_some());
    assert!(EnhancedStatus::new(3, 0, 0).is_none());
    assert!(EnhancedStatus::new(5, 1000, 0).is_none());
}

#[test]
fn greeting_and_hello() {
    let greeting = Response::greeting("mx.example.org").expect("accueil");
    assert_eq!(greeting.to_bytes(), b"220 mx.example.org ESMTP\r\n");
    assert_eq!(
        helo_response("mx.example.org").expect("helo").to_bytes(),
        b"250 mx.example.org\r\n"
    );
    for invalid in [
        "",
        "mx example",
        "mx.example.org\r\n250 x",
        "-mx.example",
        "mx..example",
        "é.example",
    ] {
        assert_eq!(
            Response::greeting(invalid).err(),
            Some(ResponseError::InvalidHostname),
            "{invalid:?}"
        );
        assert!(ehlo_response(invalid, &Extensions::default()).is_err());
    }
}

/// Décision S5 : extensions annoncées, dans l'ordre, sans `DSN`, `AUTH`, `BINARYMIME`,
/// `REQUIRETLS` ; aucun code étendu dans la réponse à `EHLO` (RFC 2034 §3).
#[test]
fn ehlo_extensions_s5() {
    let response =
        ehlo_response("mx.example.org", &Extensions::inbound(52_428_800, true)).expect("ehlo");
    assert_eq!(
        String::from_utf8(response.to_bytes()).expect("ascii"),
        "250-mx.example.org\r\n250-PIPELINING\r\n250-SIZE 52428800\r\n250-8BITMIME\r\n\
250-SMTPUTF8\r\n250-ENHANCEDSTATUSCODES\r\n250-STARTTLS\r\n250 CHUNKING\r\n"
    );
    assert_eq!(response.status(), None);

    let plain =
        ehlo_response("mx.example.org", &Extensions::inbound(1 << 20, false)).expect("ehlo");
    let text = String::from_utf8(plain.to_bytes()).expect("ascii");
    assert!(!text.contains("STARTTLS"));
    for absent in ["DSN", "AUTH", "BINARYMIME", "REQUIRETLS", "VRFY", "ETRN"] {
        assert!(!text.contains(absent), "{absent}");
    }

    let bare = ehlo_response("mx.example.org", &Extensions::default()).expect("ehlo");
    assert_eq!(bare.to_bytes(), b"250 mx.example.org\r\n");
}
