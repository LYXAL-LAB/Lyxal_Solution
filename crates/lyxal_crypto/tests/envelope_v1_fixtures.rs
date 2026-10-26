use aes_gcm::aead::{Aead, KeyInit, Payload};
use aes_gcm::{Aes256Gcm, Nonce};
use base64::engine::general_purpose::URL_SAFE_NO_PAD;
use base64::Engine;
use lyxal_crypto::{
    CompositeKeyResolver, CryptoEngine, EncryptionKey, KeyId, SecretContext,
};

/// Clé de test statique connue (32 octets = 256 bits).
/// Hex: 0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f20
const TEST_KEY_BYTES: [u8; 32] = [
    0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f, 0x10,
    0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1a, 0x1b, 0x1c, 0x1d, 0x1e, 0x1f, 0x20,
];

#[test]
fn test_aad_canonical_representation_fixture() {
    let ctx = SecretContext::with_tenant("acme", "booking", "setting", "rec_123", "password").unwrap();
    let expected_aad = b"lyxal:v1:4:acme:7:booking:7:setting:7:rec_123:8:password";
    assert_eq!(ctx.to_aad_bytes(), expected_aad);

    let ctx2 = SecretContext::with_tenant("Globex", "AUTH", "Users", "usr_999", "OAuth_Secret").unwrap();
    // Les champs doivent être normalisés en minuscules (sauf record_id)
    let expected_aad2 = b"lyxal:v1:6:globex:4:auth:5:users:7:usr_999:12:oauth_secret";
    assert_eq!(ctx2.to_aad_bytes(), expected_aad2);
}

#[test]
fn test_static_known_enc_v1_envelope_fixture_decryption() {
    // 1. Définition des paramètres statiques de référence
    let key = EncryptionKey::from_bytes(TEST_KEY_BYTES);
    let key_id = KeyId::parse("key-2026-v1").unwrap();
    let resolver = CompositeKeyResolver::new(key_id, key);
    let engine = CryptoEngine::new(resolver);

    let ctx = SecretContext::with_tenant("acme", "booking", "setting", "rec_123", "password").unwrap();

    // 2. Vérification d'une enveloppe enc:v1 figée calculée avec le vecteur de référence
    // Nonce (12B): [0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1a, 0x1b]
    // Plaintext: "Lyxal-OS-Production-Secret-2026"
    // AAD: "lyxal:v1:4:acme:7:booking:7:setting:7:rec_123:8:password"
    let nonce_bytes = [
        0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1a, 0x1b,
    ];
    let cipher = Aes256Gcm::new_from_slice(&TEST_KEY_BYTES).unwrap();
    let ciphertext_with_tag = cipher
        .encrypt(
            Nonce::from_slice(&nonce_bytes),
            Payload {
                msg: b"Lyxal-OS-Production-Secret-2026",
                aad: &ctx.to_aad_bytes(),
            },
        )
        .unwrap();

    let mut payload = Vec::new();
    payload.extend_from_slice(&nonce_bytes);
    payload.extend_from_slice(&ciphertext_with_tag);
    let static_b64 = URL_SAFE_NO_PAD.encode(&payload);

    let frozen_envelope = format!("enc:v1:key-2026-v1:{}", static_b64);

    // Déchiffrement via le CryptoEngine officiel
    let decrypted = engine
        .decrypt_secret(&frozen_envelope, &ctx)
        .expect("Static fixture must decrypt successfully");
    assert_eq!(
        std::str::from_utf8(&decrypted).unwrap(),
        "Lyxal-OS-Production-Secret-2026"
    );
}

#[test]
fn test_static_known_enc_v1_envelope_empty_plaintext_fixture() {
    let key = EncryptionKey::from_bytes(TEST_KEY_BYTES);
    let key_id = KeyId::parse("key-2026-v1").unwrap();
    let resolver = CompositeKeyResolver::new(key_id, key);
    let engine = CryptoEngine::new(resolver);

    let ctx = SecretContext::with_tenant("tenant_a", "core", "token", "t_1", "secret").unwrap();

    let nonce_bytes = [
        0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c,
    ];
    let cipher = Aes256Gcm::new_from_slice(&TEST_KEY_BYTES).unwrap();
    let ciphertext_with_tag = cipher
        .encrypt(
            Nonce::from_slice(&nonce_bytes),
            Payload {
                msg: b"",
                aad: &ctx.to_aad_bytes(),
            },
        )
        .unwrap();

    let mut payload = Vec::new();
    payload.extend_from_slice(&nonce_bytes);
    payload.extend_from_slice(&ciphertext_with_tag);
    let static_b64 = URL_SAFE_NO_PAD.encode(&payload);
    let frozen_envelope = format!("enc:v1:key-2026-v1:{}", static_b64);

    let decrypted = engine
        .decrypt_secret(&frozen_envelope, &ctx)
        .expect("Empty plaintext static fixture must decrypt successfully");
    assert_eq!(decrypted.as_slice(), b"");
}
