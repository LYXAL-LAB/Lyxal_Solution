// SPDX-License-Identifier: AGPL-3.0-only

//! `AUTH` côté serveur (lot 6, plan §3.2) : commande, échange `PLAIN` et `LOGIN`, refus,
//! masquage des secrets ; paramètres `AUTH=` et `REQUIRETLS` de `MAIL FROM`.

mod smtp_support;

use lyxal_mail_proto::smtp::{
    AuthError, AuthExchange, AuthStep, CommandReceiver, Credentials, Request, SaslData,
    SaslMechanism, SmtpError, SmtpLimits, MAX_SASL_ELEMENT_BYTES,
};
use smtp_support::command;

fn auth(line: &str) -> (String, Option<SaslData>) {
    match command(line) {
        Ok(Request::Auth { mechanism, initial }) => (mechanism, initial),
        other => panic!("{line:?} : {other:?}"),
    }
}

fn data(value: &str) -> SaslData {
    SaslData::new(value.as_bytes().to_vec())
}

fn credentials(step: AuthStep) -> Credentials {
    match step {
        AuthStep::Credentials(credentials) => credentials,
        AuthStep::Challenge(challenge) => panic!("défi inattendu : {challenge:?}"),
    }
}

fn challenge(step: &AuthStep) -> String {
    match step {
        AuthStep::Challenge(response) => String::from_utf8(response.to_bytes()).expect("ASCII"),
        AuthStep::Credentials(_) => panic!("identifiants inattendus"),
    }
}

#[test]
fn auth_command() {
    let (mechanism, initial) = auth("AUTH PLAIN dGVzdAB0ZXN0AHRlc3Q=\r\n");
    assert_eq!(mechanism, "PLAIN");
    assert_eq!(
        initial.expect("réponse initiale").as_bytes(),
        b"dGVzdAB0ZXN0AHRlc3Q="
    );
    let (mechanism, initial) = auth("auth login\r\n");
    assert_eq!((mechanism.as_str(), initial), ("LOGIN", None));
    let (mechanism, initial) = auth("AUTH SCRAM-SHA-256 =\r\n");
    assert_eq!(mechanism, "SCRAM-SHA-256");
    assert_eq!(initial.expect("vide").as_bytes(), b"=");
    for line in [
        "AUTH\r\n",
        "AUTH \r\n",
        "AUTH PL*AIN\r\n",
        "AUTH ABCDEFGHIJKLMNOPQRSTU\r\n",
        "AUTH PLAIN abc def\r\n",
        "AUTH PLAIN a-b\r\n",
    ] {
        assert_eq!(command(line), Err(SmtpError::Syntax("AUTH")), "{line:?}");
    }
    // Le `Debug` de la commande ne montre jamais la réponse initiale.
    let debug = format!("{:?}", command("AUTH PLAIN AGFsaWNlAHMzY3JldA==\r\n"));
    assert!(!debug.contains("AGFsaWNlAHMzY3JldA"), "{debug}");
    assert!(Request::Auth {
        mechanism: "PLAIN".to_owned(),
        initial: None
    }
    .ends_pipeline_group());
}

#[test]
fn plain_with_initial_response() {
    // "\0alice\0s3cret"
    let (_, step) =
        AuthExchange::start("PLAIN", Some(&data("AGFsaWNlAHMzY3JldA=="))).expect("PLAIN");
    let credentials = credentials(step);
    assert_eq!(credentials.authcid(), "alice");
    assert_eq!(credentials.password(), b"s3cret");
    let debug = format!("{credentials:?}");
    assert!(
        debug.contains("alice") && !debug.contains("s3cret"),
        "{debug}"
    );
    // Sans remplissage, comme certains logiciels.
    let (_, step) = AuthExchange::start("plain", Some(&data("AGFsaWNlAHMzY3JldA"))).expect("PLAIN");
    assert_eq!(credentials_of(step).password(), b"s3cret");
    // authzid égal à authcid : permis. "alice\0alice\0pw"
    let (_, step) =
        AuthExchange::start("PLAIN", Some(&data("YWxpY2UAYWxpY2UAcHc="))).expect("PLAIN");
    assert_eq!(credentials_of(step).authcid(), "alice");
}

fn credentials_of(step: AuthStep) -> Credentials {
    credentials(step)
}

#[test]
fn plain_with_challenge() {
    let (mut exchange, step) = AuthExchange::start("PLAIN", None).expect("PLAIN");
    assert_eq!(challenge(&step), "334 \r\n");
    let credentials = credentials(exchange.step(&data("AGFsaWNlAHMzY3JldA==")).expect("étape"));
    assert_eq!(credentials.authcid(), "alice");
    assert_eq!(
        exchange.step(&data("AGFsaWNlAHMzY3JldA==")),
        Err(AuthError::Finished)
    );
}

#[test]
fn login_exchange() {
    let (mut exchange, step) = AuthExchange::start("LOGIN", None).expect("LOGIN");
    assert_eq!(challenge(&step), "334 VXNlcm5hbWU6\r\n");
    let step = exchange
        .step(&data("Ym9iQGV4YW1wbGUub3Jn"))
        .expect("identifiant");
    assert_eq!(challenge(&step), "334 UGFzc3dvcmQ6\r\n");
    let read = credentials(exchange.step(&data("cMOkc3M=")).expect("mot de passe"));
    assert_eq!(read.authcid(), "bob@example.org");
    assert_eq!(read.password(), "päss".as_bytes());

    // Identifiant en réponse initiale (anciens Outlook).
    let (mut exchange, step) =
        AuthExchange::start("LOGIN", Some(&data("Ym9iQGV4YW1wbGUub3Jn"))).expect("LOGIN");
    assert_eq!(challenge(&step), "334 UGFzc3dvcmQ6\r\n");
    assert_eq!(
        credentials(exchange.step(&data("cHc=")).expect("pw")).password(),
        b"pw"
    );
}

#[test]
fn refusals() {
    assert_eq!(
        AuthExchange::start("CRAM-MD5", None).err(),
        Some(AuthError::UnsupportedMechanism)
    );
    // authzid différent : aucune connexion « au nom de ». "admin\0alice\0pw"
    assert_eq!(
        AuthExchange::start("PLAIN", Some(&data("YWRtaW4AYWxpY2UAcHc="))).err(),
        Some(AuthError::AuthzidRefused)
    );
    for (initial, error) in [
        ("=", AuthError::Malformed),
        ("*", AuthError::Cancelled),
        ("!!!", AuthError::InvalidBase64),
        ("YWxpY2U=", AuthError::Malformed), // "alice" : aucun NUL
        ("AGFsaWNlAA==", AuthError::Malformed), // "\0alice\0" : mot de passe vide
        ("AABwdw==", AuthError::Malformed), // "\0\0pw" : identifiant vide
        ("AP8AcHc=", AuthError::Malformed), // "\0\xff\0pw" : UTF-8 invalide
        ("AGEAYgBj", AuthError::Malformed), // "\0a\0b\0c" : NUL dans le mot de passe
    ] {
        assert_eq!(
            AuthExchange::start("PLAIN", Some(&data(initial))).err(),
            Some(error),
            "{initial:?}"
        );
    }
    let long = "A".repeat(MAX_SASL_ELEMENT_BYTES + 4);
    assert_eq!(
        AuthExchange::start("PLAIN", Some(&data(&long))).err(),
        Some(AuthError::TooLong)
    );
    let (mut exchange, _) = AuthExchange::start("LOGIN", None).expect("LOGIN");
    assert_eq!(exchange.step(&data("*")), Err(AuthError::Cancelled));
    assert_eq!(exchange.step(&data("cHc=")), Err(AuthError::Finished));
    let (mut exchange, _) = AuthExchange::start("LOGIN", None).expect("LOGIN");
    exchange.step(&data("Ym9i")).expect("identifiant");
    assert_eq!(exchange.step(&data("=")), Err(AuthError::Malformed));

    for (error, code, status) in [
        (AuthError::UnsupportedMechanism, 504, "5.5.4"),
        (AuthError::Cancelled, 501, "5.0.0"),
        (AuthError::TooLong, 500, "5.5.6"),
        (AuthError::InvalidBase64, 501, "5.5.2"),
        (AuthError::Malformed, 501, "5.5.2"),
        (AuthError::AuthzidRefused, 535, "5.7.8"),
        (AuthError::Finished, 503, "5.5.1"),
    ] {
        let response = error.response();
        assert_eq!(response.code(), code, "{error:?}");
        assert_eq!(
            response.status().map(|s| s.to_string()).as_deref(),
            Some(status)
        );
        smtp_support::parse_reply(&response.to_bytes());
    }
    assert_eq!(
        SaslMechanism::from_name("login"),
        Some(SaslMechanism::Login)
    );
    assert_eq!(SaslMechanism::Plain.name(), "PLAIN");
}

/// Ligne de réponse lue par le récepteur de commandes, mêmes contrôles qu'une commande.
#[test]
fn response_lines() {
    let mut receiver = CommandReceiver::new(&SmtpLimits::default());
    let ingested = receiver.ingest_line(b"cHc=\r\nMAIL");
    assert_eq!(ingested.consumed, 6);
    let line = ingested.item.expect("ligne").expect("lisible");
    assert_eq!(line.as_bytes(), b"cHc=");
    assert_eq!(format!("{line:?}"), "SaslData([REDACTED])");
    assert!(receiver
        .ingest_line(b"*\r\n")
        .item
        .expect("ligne")
        .expect("ok")
        .is_cancel());
    assert_eq!(
        receiver.ingest_line(b"cHc=\n").item.expect("ligne"),
        Err(SmtpError::BareLf)
    );
    assert_eq!(
        receiver.ingest_line(b"c\rHc=\r\n").item.expect("ligne"),
        Err(SmtpError::BareCr)
    );
    let partial = receiver.ingest_line(b"cH");
    assert!(partial.item.is_none() && receiver.has_partial_line());
    let rest = receiver.ingest_line(b"c=\r\n");
    assert_eq!(rest.item.expect("ligne").expect("ok").as_bytes(), b"cHc=");
    assert!(!receiver.has_partial_line());
}

#[test]
fn mail_auth_parameter() {
    let mail = match command("MAIL FROM:<a@example.org> AUTH=<>\r\n") {
        Ok(Request::Mail(mail)) => mail,
        other => panic!("{other:?}"),
    };
    assert_eq!(mail.auth.as_deref(), Some("<>"));
    assert!(mail.uses_auth() && !mail.uses_dsn());
    let mail = match command("MAIL FROM:<a@example.org> AUTH=e+2Bx@example.org\r\n") {
        Ok(Request::Mail(mail)) => mail,
        other => panic!("{other:?}"),
    };
    assert_eq!(mail.auth.as_deref(), Some("e+2Bx@example.org"));
    assert_eq!(
        command("MAIL FROM:<a@example.org> AUTH=a+zz\r\n"),
        Err(SmtpError::InvalidParameter("AUTH"))
    );
    assert_eq!(
        command("MAIL FROM:<a@example.org> AUTH=<> AUTH=<>\r\n"),
        Err(SmtpError::DuplicateParameter("AUTH"))
    );
    // REQUIRETLS (RFC 8689) : lu et refusé (décision E26).
    let refused = command("MAIL FROM:<a@example.org> REQUIRETLS\r\n");
    assert_eq!(refused, Err(SmtpError::UnsupportedParameter));
    let response = SmtpError::UnsupportedParameter.response();
    assert_eq!(response.code(), 555);
    assert_eq!(
        response.status().map(|s| s.to_string()).as_deref(),
        Some("5.5.4")
    );
}

#[test]
fn envid_decoding() {
    let mail = match command("MAIL FROM:<a@example.org> ENVID=QQ314159+2B1\r\n") {
        Ok(Request::Mail(mail)) => mail,
        other => panic!("{other:?}"),
    };
    assert_eq!(mail.decoded_envid().as_deref(), Some("QQ314159+1"));
    let control = match command("MAIL FROM:<a@example.org> ENVID=a+0Ab\r\n") {
        Ok(Request::Mail(mail)) => mail,
        other => panic!("{other:?}"),
    };
    assert_eq!(control.decoded_envid(), None);
}
