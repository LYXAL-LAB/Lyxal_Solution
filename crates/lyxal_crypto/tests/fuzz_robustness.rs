//! Deterministic adversarial corpus, complementary to the coverage-guided fuzz targets.
use base64::{engine::general_purpose::URL_SAFE_NO_PAD, Engine};
use lyxal_crypto::*;
use std::sync::Arc;
#[test]
fn two_thousand_single_bit_mutations_fail_authentication() {
    let mut b = KeyRingBuilder::new();
    b.insert(
        KeyId::parse("test").unwrap(),
        EncryptionKey::generate().unwrap(),
        KeyUse::Active,
    )
    .unwrap();
    let e = CryptoEngine::new(StaticKeyResolver::new(Arc::new(b.build().unwrap())));
    let ctx = SecretContext::global("mutations.test").unwrap();
    let original = e
        .seal(&SecretBytes::new(vec![42; 64]).unwrap(), &ctx)
        .unwrap()
        .encode();
    let raw = URL_SAFE_NO_PAD
        .decode(original.rsplit(':').next().unwrap())
        .unwrap();
    for i in 0..2000 {
        let mut bad = raw.clone();
        let index = i % bad.len();
        bad[index] ^= 1 << ((i / bad.len()) % 8);
        let encoded = format!("enc:v2:test:{}", URL_SAFE_NO_PAD.encode(bad));
        let parsed = EncryptedEnvelope::parse(&encoded).unwrap();
        assert!(matches!(
            e.open(&parsed, &ctx),
            Err(CryptoError::AuthenticationFailed)
        ));
    }
}
#[test]
fn malformed_corpus_is_rejected_without_panics() {
    for input in [
        "",
        "\0",
        "enc",
        "enc:v2",
        "enc:v2::AAAA",
        "enc:v2:key:A",
        "enc:v2:key:====",
        "enc:v2:key:AAAA:extra",
        "enc:v2:key:AAAA\n",
        "enc:v2:key:é",
    ] {
        assert!(EncryptedEnvelope::parse(input).is_err());
    }
    assert!(PasswordHash::parse(&"A".repeat(513)).is_err());
}
