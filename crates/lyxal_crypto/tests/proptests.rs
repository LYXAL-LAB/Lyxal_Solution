use base64::Engine;
use lyxal_crypto::hmac::{sign_hmac_sha256, verify_hmac_sha256};
use lyxal_crypto::*;
use proptest::prelude::*;

fn get_prop_engine() -> CryptoEngine<EnvironmentKeyProvider> {
    let key_bytes = [77u8; 32];
    let b64 = base64::engine::general_purpose::STANDARD.encode(key_bytes);
    std::env::set_var("LYXAL_PROPTEST_KEY", b64);
    let key_id = KeyId::parse("main").unwrap();
    let provider = EnvironmentKeyProvider::new("LYXAL_PROPTEST_KEY", key_id).unwrap();
    CryptoEngine::new(provider)
}

proptest! {
    #[test]
    fn prop_encrypt_decrypt_roundtrip(
        plaintext in proptest::collection::vec(any::<u8>(), 0..4096),
        tenant in "[a-z0-9]{1,16}",
        module in "[a-z0-9]{1,16}",
        resource in "[a-z0-9]{1,16}",
        record_id in "[a-zA-Z0-9_-]{1,32}",
        field in "[a-z0-9]{1,16}",
    ) {
        let engine = get_prop_engine();
        let ctx = SecretContext::with_tenant(&tenant, &module, &resource, &record_id, &field).unwrap();

        let encrypted = engine.encrypt_secret(&plaintext, &ctx).unwrap();
        let decrypted = engine.decrypt_secret(&encrypted, &ctx).unwrap();

        prop_assert_eq!(&*decrypted, &plaintext);
    }

    #[test]
    fn prop_mismatched_context_always_fails(
        plaintext in proptest::collection::vec(any::<u8>(), 1..256),
        tenant1 in "[a-z0-9]{1,8}",
        tenant2 in "[a-z0-9]{9,16}",
        module in "[a-z0-9]{1,16}",
        resource in "[a-z0-9]{1,16}",
        record_id in "[a-zA-Z0-9_-]{1,32}",
        field in "[a-z0-9]{1,16}",
    ) {
        let engine = get_prop_engine();
        let ctx1 = SecretContext::with_tenant(&tenant1, &module, &resource, &record_id, &field).unwrap();
        let ctx2 = SecretContext::with_tenant(&tenant2, &module, &resource, &record_id, &field).unwrap();

        let encrypted = engine.encrypt_secret(&plaintext, &ctx1).unwrap();
        let res = engine.decrypt_secret(&encrypted, &ctx2);

        prop_assert!(res.is_err());
    }

    #[test]
    fn prop_hmac_sha256_roundtrip(
        key in proptest::collection::vec(any::<u8>(), 1..64),
        data in proptest::collection::vec(any::<u8>(), 0..1024),
    ) {
        let tag = sign_hmac_sha256(&key, &data);
        prop_assert!(verify_hmac_sha256(&key, &data, &tag));
    }
}
