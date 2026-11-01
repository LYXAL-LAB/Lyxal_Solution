use lyxal_crypto::{CryptoError, EncryptedEnvelope, SecretContext};

const T0: &str = "enc:v2:k1:DA0ODxAREhMUFRYXhF7HI-45YFCT5iV2BQo7Vw";
#[test]
fn canonical_transport_and_v1_rejection() {
    let envelope = EncryptedEnvelope::parse(T0).unwrap();
    assert_eq!(envelope.encode(), T0);
    assert_eq!(envelope.key_id().as_str(), "k1");
    assert!(matches!(
        EncryptedEnvelope::parse(&T0.replace("v2", "v1")),
        Err(CryptoError::UnsupportedVersion)
    ));
    for bad in [
        format!(" {T0}"),
        format!("{T0}\n"),
        format!("{T0}="),
        T0.replace("v2", "v02"),
        T0.replace("k1", " k1"),
        T0.replace("BQo7Vw", "BQo7Vx"),
        format!("{T0}:extra"),
        "enc:v2:k1:AA".to_owned(),
    ] {
        assert!(
            EncryptedEnvelope::parse(&bad).is_err(),
            "accepted noncanonical input"
        );
    }
}

#[test]
fn exact_contexts_and_explicit_global_domain() {
    let a = SecretContext::with_tenant("Acme", "booking", "setting", "rec_é", "password").unwrap();
    let b = SecretContext::with_tenant("acme", "booking", "setting", "rec_é", "password").unwrap();
    assert_ne!(a, b);
    assert!(SecretContext::with_tenant(" Acme", "booking", "setting", "id", "password").is_err());
    assert!(
        SecretContext::with_tenant("Acme", "booking", "setting", "id\u{a0}", "password").is_err()
    );
    assert!(SecretContext::with_tenant("Acme", "booking", "setting", "id\0", "password").is_err());
    assert!(SecretContext::global("").is_err());
    assert!(!format!("{a:?}").contains("Acme"));
}

#[test]
fn resource_limits_are_checked_before_decoding() {
    assert!(matches!(
        EncryptedEnvelope::parse(&"A".repeat(1_398_212)),
        Err(CryptoError::InputTooLarge)
    ));
    assert!(SecretContext::with_tenant(&"a".repeat(129), "m", "r", "id", "f").is_err());
    assert!(SecretContext::with_tenant("a", "m", "r", &"é".repeat(513), "f").is_err());
}

#[test]
fn maximum_wire_size_and_minimum_empty_payload_are_exact() {
    use base64::{engine::general_purpose::URL_SAFE_NO_PAD, Engine};
    let binary = vec![0; 1_048_604];
    let text = format!(
        "enc:v2:{}:{}",
        "a".repeat(64),
        URL_SAFE_NO_PAD.encode(&binary)
    );
    assert_eq!(text.len(), 1_398_211);
    assert!(EncryptedEnvelope::parse(&text).is_ok());
    assert!(
        EncryptedEnvelope::parse(&format!("enc:v2:a:{}", URL_SAFE_NO_PAD.encode(vec![0; 27])))
            .is_err()
    );
    let minimum = format!("enc:v2:a:{}", URL_SAFE_NO_PAD.encode(vec![0; 28]));
    assert_eq!(minimum.len(), 47);
    assert!(EncryptedEnvelope::parse(&minimum).is_ok());
    assert!(EncryptedEnvelope::parse(&format!(
        "enc:v2:a:{}",
        URL_SAFE_NO_PAD.encode(vec![0; 1_048_605])
    ))
    .is_err());
}
