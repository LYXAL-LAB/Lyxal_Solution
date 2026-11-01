use lyxal_crypto::{CryptoError, EncryptionKey, HmacKey, KeyId, SecretBytes, SecretString};

#[test]
fn diagnostics_never_expose_secrets() {
    let text = SecretString::new("AUDIT-SENTINEL".to_owned()).unwrap();
    let bytes = SecretBytes::new(b"AUDIT-SENTINEL".to_vec()).unwrap();
    assert_eq!(format!("{text:?}"), "SecretString([REDACTED])");
    assert_eq!(format!("{bytes:#?}"), "SecretBytes([REDACTED])");
    let key = EncryptionKey::import(SecretBytes::new(vec![0x41; 32]).unwrap()).unwrap();
    let hmac = HmacKey::import(SecretBytes::new(vec![0x41; 32]).unwrap()).unwrap();
    assert_eq!(format!("{key:?}"), "EncryptionKey([REDACTED])");
    assert_eq!(format!("{hmac:?}"), "HmacKey([REDACTED])");
    assert!(!format!("{text:?} {bytes:?} {key:?} {hmac:?}").contains("AUDIT-SENTINEL"));
}

#[test]
fn conversions_preserve_allocation_and_reject_invalid_utf8() {
    let bytes = SecretBytes::new("é".as_bytes().to_vec()).unwrap();
    let pointer = bytes.expose_secret().as_ptr();
    let text = bytes.into_utf8().unwrap();
    assert_eq!(text.expose_secret().as_ptr(), pointer);
    let bytes = text.into_bytes();
    assert_eq!(bytes.expose_secret().as_ptr(), pointer);
    assert!(matches!(
        SecretBytes::new(vec![255]).unwrap().into_utf8(),
        Err(CryptoError::InvalidUtf8)
    ));
}

#[test]
fn key_lengths_context_free_ids_and_capacities_are_strict() {
    for length in [0, 31, 33] {
        assert!(matches!(
            EncryptionKey::import(SecretBytes::new(vec![0; length]).unwrap()),
            Err(CryptoError::InvalidKeyLength)
        ));
    }
    assert!(EncryptionKey::generate().is_ok());
    assert!(HmacKey::generate().is_ok());
    assert!(KeyId::parse(" main").is_err());
    assert!(KeyId::parse("main ").is_err());
    assert!(KeyId::parse("FAKE-SECRET\nFORGED").is_err());
    assert!(
        !format!("{}", KeyId::parse("FAKE-SECRET\nFORGED").unwrap_err()).contains("FAKE-SECRET")
    );
    assert!(SecretBytes::new(Vec::with_capacity(1_048_577)).is_err());
    assert!(SecretString::new(String::with_capacity(1_048_577)).is_err());
    assert!(SecretBytes::new(vec![0; 1_048_576]).is_ok());
}
