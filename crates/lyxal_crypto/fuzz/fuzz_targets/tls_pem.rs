#![no_main]
//! Hostile certificate chains, private keys and server names: no panic, bounded inputs.
//! Input: chain bytes, a 0x00 separator, then key bytes (the remainder is also used as a name).
use libfuzzer_sys::fuzz_target;
use lyxal_crypto::*;
use std::sync::{Arc, OnceLock};

const CHAIN: &[u8] = include_bytes!("../../tests/fixtures/tls_test_only/p256.chain.pem");
const KEY: &[u8] = include_bytes!("../../tests/fixtures/tls_test_only/p256.key.pem");

fn store() -> &'static Arc<TlsCertificateStore> {
    static STORE: OnceLock<Arc<TlsCertificateStore>> = OnceLock::new();
    STORE.get_or_init(|| TlsCertificateStore::new(None))
}

fuzz_target!(|data: &[u8]| {
    let (chain, key) = match data.iter().position(|&b| b == 0) {
        Some(split) => (&data[..split], &data[split + 1..]),
        None => (data, &[][..]),
    };
    if let Ok(secret) = SecretBytes::new(key.to_vec()) {
        let _ = TlsCertifiedKey::from_pem(chain, secret);
    }
    if let Ok(secret) = SecretBytes::new(key.to_vec()) {
        let _ = TlsCertifiedKey::from_der(vec![chain.to_vec()], secret);
    }
    // Hostile chain with the valid key, valid chain with the hostile key.
    let _ = TlsCertifiedKey::from_pem(chain, SecretBytes::new(KEY.to_vec()).unwrap());
    if let Ok(secret) = SecretBytes::new(key.to_vec()) {
        let _ = TlsCertifiedKey::from_pem(CHAIN, secret);
    }
    // Hostile names against a valid certificate: only mail.example.test may be accepted.
    if let Ok(name) = std::str::from_utf8(key) {
        let certified =
            TlsCertifiedKey::from_pem(CHAIN, SecretBytes::new(KEY.to_vec()).unwrap()).unwrap();
        if store().insert(name, certified).is_ok() {
            assert!(name.eq_ignore_ascii_case("mail.example.test"));
            assert!(store().remove(name));
        }
    }
});
