//! Literal vectors computed independently with OpenSSL, never generated as expectations here.
use lyxal_crypto::*;
use std::sync::Arc;
fn engine() -> CryptoEngine<StaticKeyResolver> {
    let mut b = KeyRingBuilder::new();
    for (id, use_) in [("k1", KeyUse::Active), ("k2", KeyUse::DecryptOnly)] {
        b.insert(
            KeyId::parse(id).unwrap(),
            EncryptionKey::import(SecretBytes::new((0u8..32).collect()).unwrap()).unwrap(),
            use_,
        )
        .unwrap();
    }
    CryptoEngine::new(StaticKeyResolver::new(Arc::new(b.build().unwrap())))
}
const T1: &str = "enc:v2:k1:AAECAwQFBgcICQoLC3uueqnFlClTwVU7Dryh6oMwUo0yPNeV";
const T0: &str = "enc:v2:k1:DA0ODxAREhMUFRYXhF7HI-45YFCT5iV2BQo7Vw";
const G1: &str = "enc:v2:k1:GBkaGxwdHh8gISIjX2Y4cbdpM339Sh5p7xr0CSDVxUWPzT7-";
#[test]
fn three_independent_literal_envelopes_open_exactly() {
    let e = engine();
    let tenant =
        SecretContext::with_tenant("Acme", "booking", "setting", "rec_é", "password").unwrap();
    let global = SecretContext::global("smtp.password").unwrap();
    for (text, ctx, plain) in [
        (T1, &tenant, b"Lyxal V2".as_slice()),
        (T0, &tenant, b"".as_slice()),
        (G1, &global, b"Lyxal V2".as_slice()),
    ] {
        let env = EncryptedEnvelope::parse(text).unwrap();
        assert_eq!(env.encode(), text);
        assert_eq!(e.open(&env, ctx).unwrap().expose_secret(), plain);
    }
}
#[test]
fn changing_routing_metadata_is_detected_even_with_identical_key_material() {
    let e = engine();
    let ctx =
        SecretContext::with_tenant("Acme", "booking", "setting", "rec_é", "password").unwrap();
    assert!(matches!(
        e.open(
            &EncryptedEnvelope::parse(&T1.replace(":k1:", ":k2:")).unwrap(),
            &ctx
        ),
        Err(CryptoError::AuthenticationFailed)
    ));
    let unknown = EncryptedEnvelope::parse(&T1.replace(":k1:", ":missing:")).unwrap();
    assert!(matches!(
        e.open(&unknown, &ctx),
        Err(CryptoError::KeyUnavailable)
    ));
    assert!(matches!(
        e.reencrypt_if_needed(&unknown, &ctx),
        Err(CryptoError::KeyUnavailable)
    ));
    assert!(matches!(
        EncryptedEnvelope::parse(&T1.replace(":v2:", ":v1:")),
        Err(CryptoError::UnsupportedVersion)
    ));
}
