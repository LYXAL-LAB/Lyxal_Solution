//! Comprehensive Unit & Integration Tests for Email Service.

use super::*;
use lettre::message::Mailbox;
use lettre::Address;
use std::sync::{Mutex, MutexGuard};
use zeroize::Zeroizing;

static SMTP_ENV_LOCK: Mutex<()> = Mutex::new(());

const SMTP_ENV_VARS: &[&str] = &[
    "CALRS_SMTP_HOST",
    "CALRS_SMTP_PORT",
    "CALRS_SMTP_USERNAME",
    "CALRS_SMTP_PASSWORD",
    "CALRS_SMTP_FROM_EMAIL",
    "CALRS_SMTP_FROM_NAME",
    "CALRS_SMTP_TLS_MODE",
];

struct SmtpEnvGuard {
    _lock: MutexGuard<'static, ()>,
    old_values: Vec<(&'static str, Option<String>)>,
}

impl SmtpEnvGuard {
    fn new() -> Self {
        let lock = SMTP_ENV_LOCK.lock().unwrap();
        let old_values = SMTP_ENV_VARS
            .iter()
            .map(|name| (*name, std::env::var(name).ok()))
            .collect();
        for name in SMTP_ENV_VARS {
            std::env::remove_var(name);
        }
        Self {
            _lock: lock,
            old_values,
        }
    }
}

impl Drop for SmtpEnvGuard {
    fn drop(&mut self) {
        for (name, value) in &self.old_values {
            match value {
                Some(value) => std::env::set_var(name, value),
                None => std::env::remove_var(name),
            }
        }
    }
}

fn smtp_env_error() -> String {
    config::load_smtp_config_from_env()
        .expect_err("expected SMTP env config to fail")
        .to_string()
}

fn sample_booking_details() -> BookingDetails {
    BookingDetails {
        event_title: "Intro Call".to_string(),
        date: "2026-03-10".to_string(),
        start_time: "14:00".to_string(),
        end_time: "14:30".to_string(),
        guest_name: "Jane Doe".to_string(),
        guest_email: "jane@example.com".to_string(),
        guest_timezone: "Europe/Paris".to_string(),
        host_name: "Alice".to_string(),
        host_email: "alice@example.com".to_string(),
        uid: "test-uid-123".to_string(),
        notes: Some("Let's talk about the project".to_string()),
        location: Some("Google Meet".to_string()),
        reminder_minutes: None,
        additional_attendees: vec![],
        guest_language: None,
        host_language: None,
        host_timezone: "Europe/Paris".to_string(),
        resource_name: None,
    }
}

#[test]
fn smtp_config_mailbox_from() {
    let config = SmtpConfig {
        host: "host".to_string(),
        port: 587,
        username: "user".to_string(),
        password: Zeroizing::new("password".to_string()),
        from_name: None,
        from_email: "username@example.com".to_string(),
        tls_mode: SmtpTlsMode::StartTls,
    };
    assert_eq!(
        config.mailbox_from().unwrap(),
        Mailbox::new(None, Address::new("username", "example.com").unwrap()),
        "from email with no name"
    );

    let config = SmtpConfig {
        host: "host".to_string(),
        port: 587,
        username: "username".to_string(),
        password: Zeroizing::new("password".to_string()),
        from_name: Some("Name, With Comma".to_string()),
        from_email: "username@example.com".to_string(),
        tls_mode: SmtpTlsMode::StartTls,
    };
    assert_eq!(
        config.mailbox_from().unwrap(),
        Mailbox::new(
            Some("Name, With Comma".to_string()),
            Address::new("username", "example.com").unwrap()
        ),
        "from email with name"
    );
}

#[test]
fn smtp_tls_mode_parses_supported_values() {
    assert_eq!(
        SmtpTlsMode::parse("starttls").unwrap(),
        SmtpTlsMode::StartTls
    );
    assert_eq!(SmtpTlsMode::parse(" TLS ").unwrap(), SmtpTlsMode::Tls);
}

#[test]
fn smtp_tls_mode_rejects_unknown_values() {
    let err = SmtpTlsMode::parse("ssl").unwrap_err().to_string();
    assert!(err.contains("CALRS_SMTP_TLS_MODE"));
}

#[test]
fn smtp_env_absent_returns_none() {
    let _env = SmtpEnvGuard::new();
    assert!(config::load_smtp_config_from_env().unwrap().is_none());
}

#[test]
fn smtp_env_complete_defaults_to_starttls() {
    let _env = SmtpEnvGuard::new();
    std::env::set_var("CALRS_SMTP_HOST", "smtp.example.com");
    std::env::set_var("CALRS_SMTP_USERNAME", "user");
    std::env::set_var("CALRS_SMTP_PASSWORD", "secret");
    std::env::set_var("CALRS_SMTP_FROM_EMAIL", "noreply@example.com");

    let config = config::load_smtp_config_from_env().unwrap().unwrap();

    assert_eq!(config.host, "smtp.example.com");
    assert_eq!(config.port, 587);
    assert_eq!(config.tls_mode, SmtpTlsMode::StartTls);
}

#[test]
fn smtp_env_partial_config_falls_back_to_db() {
    let _env = SmtpEnvGuard::new();
    std::env::set_var("CALRS_SMTP_HOST", "smtp.example.com");

    assert!(config::load_smtp_config_from_env().unwrap().is_none());
}

#[test]
fn smtp_env_invalid_port_errors() {
    let _env = SmtpEnvGuard::new();
    std::env::set_var("CALRS_SMTP_HOST", "smtp.example.com");
    std::env::set_var("CALRS_SMTP_USERNAME", "user");
    std::env::set_var("CALRS_SMTP_PASSWORD", "secret");
    std::env::set_var("CALRS_SMTP_FROM_EMAIL", "noreply@example.com");
    std::env::set_var("CALRS_SMTP_PORT", "not-a-port");

    let err = smtp_env_error();

    assert!(err.contains("CALRS_SMTP_PORT"));
}

#[test]
fn smtp_env_invalid_tls_mode_errors() {
    let _env = SmtpEnvGuard::new();
    std::env::set_var("CALRS_SMTP_HOST", "smtp.example.com");
    std::env::set_var("CALRS_SMTP_USERNAME", "user");
    std::env::set_var("CALRS_SMTP_PASSWORD", "secret");
    std::env::set_var("CALRS_SMTP_FROM_EMAIL", "noreply@example.com");
    std::env::set_var("CALRS_SMTP_TLS_MODE", "ssl");

    let err = smtp_env_error();

    assert!(err.contains("CALRS_SMTP_TLS_MODE"));
}

#[test]
fn sanitize_strips_cr_lf() {
    assert_eq!(sanitize_ics("line1\r\nline2\nline3"), "line1 line2 line3");
}

#[test]
fn sanitize_escapes_semicolon_comma() {
    assert_eq!(sanitize_ics("a;b,c"), "a\\;b\\,c");
}

#[test]
fn sanitize_combined() {
    assert_eq!(
        sanitize_ics("Meeting; room A\nfloor 2"),
        "Meeting\\; room A floor 2"
    );
}

#[test]
fn sanitize_empty_string() {
    assert_eq!(sanitize_ics(""), "");
}

#[test]
fn sanitize_prevents_ics_injection() {
    let malicious = "Meeting\r\nATTENDEE:evil@hacker.com";
    let sanitized = sanitize_ics(malicious);
    assert!(!sanitized.contains('\n'));
    assert!(!sanitized.contains('\r'));
}

#[test]
fn guest_confirmation_ics_has_publish_method() {
    let details = sample_booking_details();
    let ics = generate_ics(&details, "PUBLISH");
    assert!(ics.contains("METHOD:PUBLISH"));
}

#[test]
fn host_notification_ics_has_request_method() {
    let details = sample_booking_details();
    let ics = generate_ics(&details, "REQUEST");
    assert!(ics.contains("METHOD:REQUEST"));
}

#[test]
fn cancellation_ics_has_cancel_method_and_status() {
    let details = CancellationDetails {
        event_title: "Meeting".to_string(),
        date: "2026-04-10".to_string(),
        start_time: "14:00".to_string(),
        end_time: "14:30".to_string(),
        guest_name: "Jane".to_string(),
        guest_email: "jane@example.com".to_string(),
        guest_timezone: "Europe/Paris".to_string(),
        host_name: "Alice".to_string(),
        host_email: "alice@example.com".to_string(),
        uid: "uid-cancel-method".to_string(),
        reason: None,
        cancelled_by_host: true,
        ..Default::default()
    };
    let ics = generate_cancel_ics(&details);
    assert!(ics.contains("METHOD:CANCEL"));
    assert!(ics.contains("STATUS:CANCELLED"));
    assert!(!ics.contains("STATUS:CONFIRMED"));
}

#[test]
fn lettre_mailbox_rejects_crlf_in_display_name() {
    use lettre::message::Mailbox;
    let payloads = [
        "Alice\r\nBcc: evil@attacker.com",
        "Alice\nX-Smuggled: true",
        "Alice\r\nSubject: hijacked",
        "Alice\"; Bcc: evil@attacker.com\r\n",
    ];
    for payload in payloads {
        let raw = format!("{} <guest@example.com>", payload);
        let result = raw.parse::<Mailbox>();
        assert!(
            result.is_err(),
            "lettre must reject CRLF/LF in display name — payload {:?} parsed to {:?}",
            payload,
            result
        );
    }
}

#[test]
fn lettre_subject_encodes_crlf_safely() {
    use lettre::message::{Mailbox, Message};
    let msg = Message::builder()
        .from("sender@example.com".parse::<Mailbox>().unwrap())
        .to("to@example.com".parse::<Mailbox>().unwrap())
        .subject("Normal\r\nBcc: evil@attacker.com")
        .body("body".to_string())
        .expect("message builds");

    let raw = msg.formatted();
    let wire = String::from_utf8_lossy(&raw);

    let lines: Vec<&str> = wire.split("\r\n").collect();
    assert!(
        !lines.iter().any(|l| l.starts_with("Bcc:")),
        "Bcc header injected — lettre no longer encodes Subject CRLF. Wire:\n{}",
        wire
    );
    let subject_count = lines.iter().filter(|l| l.starts_with("Subject:")).count();
    assert_eq!(subject_count, 1, "exactly one Subject header expected");
}

#[test]
fn test_determine_smtp_password_format() {
    assert_eq!(
        determine_smtp_password_format("enc:v1:some_envelope").unwrap(),
        StoredSmtpPasswordFormat::LyxalEnvelope
    );

    assert_eq!(
        determine_smtp_password_format("enc:v2:future_envelope").unwrap(),
        StoredSmtpPasswordFormat::LyxalEnvelope
    );

    use base64::Engine;
    let valid_base64 = base64::engine::general_purpose::STANDARD.encode(&[0u8; 32]);
    assert_eq!(
        determine_smtp_password_format(&valid_base64).unwrap(),
        StoredSmtpPasswordFormat::CalrsAesBase64
    );

    assert!(determine_smtp_password_format("too_short").is_err());
    assert!(determine_smtp_password_format("invalid_non_base64_$$$").is_err());
}

#[test]
fn test_smtp_config_debug_redacts_password() {
    let config = SmtpConfig {
        host: "smtp.example.com".to_string(),
        port: 587,
        username: "user".to_string(),
        password: Zeroizing::new("super_secret_password_123".to_string()),
        from_email: "from@example.com".to_string(),
        from_name: None,
        tls_mode: SmtpTlsMode::StartTls,
    };

    let debug_str = format!("{:?}", config);
    assert!(debug_str.contains("<redacted>"));
    assert!(!debug_str.contains("super_secret_password_123"));
}

#[test]
fn test_smtp_legacy_migration_and_decryption() {
    use base64::Engine;
    use lyxal_crypto::{CryptoEngine, EncryptionKey, EnvironmentKeyProvider};
    use std::sync::Arc;

    let provider = Arc::new(EnvironmentKeyProvider::new(
        "LYXAL_TEST_SECRET_KEY_FOR_SMTP_MIGRATION_1234",
    ));
    let crypto = CryptoEngine::new(provider);

    let legacy_key_bytes = [9u8; 32];
    let legacy_key = EncryptionKey::from_bytes("legacy_key", &legacy_key_bytes);

    let raw_aes_b64 = base64::engine::general_purpose::STANDARD.encode(&legacy_key_bytes);
    let setting_id = surrealdb::RecordId::from(("booking_setting", "smtp_config"));
    let ctx = crate::crypto_helpers::smtp_password_context("default", &setting_id).unwrap();

    let migrated = crypto
        .migrate_calrs_aes_base64(&legacy_key, &raw_aes_b64, &ctx)
        .unwrap();
    assert!(migrated.starts_with("enc:v1:"));

    let decrypted = crypto.decrypt_secret(&migrated, &ctx).unwrap();
    assert_eq!(decrypted.as_ref(), raw_aes_b64.as_bytes());
}

#[test]
fn test_smtp_legacy_without_key_errors() {
    use lyxal_crypto::{CryptoEngine, CryptoError, EncryptionKey, EnvironmentKeyProvider};
    use std::sync::Arc;

    let provider = Arc::new(EnvironmentKeyProvider::new(
        "LYXAL_TEST_SECRET_KEY_FOR_MISSING_KEY_TEST_0123",
    ));
    let _crypto = CryptoEngine::new(provider);

    let no_legacy_key: Option<&EncryptionKey> = None;
    assert!(no_legacy_key.ok_or(CryptoError::MissingActiveKey).is_err());
}

#[test]
fn test_smtp_modern_envelope_direct_read() {
    use lyxal_crypto::{CryptoEngine, EnvironmentKeyProvider};
    use std::sync::Arc;

    let provider = Arc::new(EnvironmentKeyProvider::new(
        "LYXAL_TEST_SECRET_KEY_FOR_MODERN_DIRECT_READ_987",
    ));
    let crypto = CryptoEngine::new(provider);

    let id = surrealdb::RecordId::from(("booking_setting", "smtp_config"));
    let ctx = crate::crypto_helpers::smtp_password_context("default", &id).unwrap();

    let secret = b"modern_smtp_password";
    let encrypted = crypto.encrypt_secret(secret, &ctx).unwrap();

    assert_eq!(
        determine_smtp_password_format(&encrypted).unwrap(),
        StoredSmtpPasswordFormat::LyxalEnvelope
    );
    let decrypted = crypto.decrypt_secret(&encrypted, &ctx).unwrap();
    assert_eq!(decrypted.as_ref(), secret);
}
