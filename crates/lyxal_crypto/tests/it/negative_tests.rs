use lyxal_crypto::*;
#[test]
fn context_boundaries_and_unicode_identity_are_precise() {
    let tenant = "a".repeat(128);
    let field = "a".repeat(64);
    let record = "é".repeat(512);
    assert!(SecretContext::with_tenant(&tenant, &field, &field, &record, &field).is_ok());
    for value in ["", "id\n", "\u{a0}id", "id\u{3000}"] {
        assert!(SecretContext::with_tenant("a", "m", "r", value, "f").is_err());
    }
    let a = SecretContext::with_tenant("a", "m", "r", "é", "f").unwrap();
    let b = SecretContext::with_tenant("a", "m", "r", "e\u{301}", "f").unwrap();
    assert_ne!(a, b);
    assert!(SecretContext::global(&format!("a{}", "x".repeat(127))).is_ok());
    assert!(SecretContext::global(&"a".repeat(129)).is_err());
}
#[test]
fn hostile_input_is_not_reflected_in_diagnostics() {
    for value in [
        "FAKE-SECRET\nFORGED",
        "enc:v999:FAKE-SECRET:AAAA",
        "enc:v02:FAKE-SECRET:AAAA",
    ] {
        if let Err(e) = EncryptedEnvelope::parse(value) {
            assert!(!format!("{e:?} {e}").contains("FAKE-SECRET"));
        }
    }
    assert!(!format!(
        "{:?}",
        SecretContext::with_tenant("FAKE-SECRET ", "m", "r", "id", "f").unwrap_err()
    )
    .contains("FAKE-SECRET"));
}
