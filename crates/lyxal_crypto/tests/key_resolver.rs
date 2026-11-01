use lyxal_crypto::*;
use std::sync::Arc;
#[cfg(unix)]
#[test]
fn non_unicode_environment_errors_are_redacted_and_invalid_names_fail() {
    use std::{ffi::OsString, os::unix::ffi::OsStringExt};
    let name = format!("LYXAL_CRYPTO_NONUNICODE_TEST_{}", std::process::id());
    std::env::set_var(&name, OsString::from_vec(b"FAKE-SECRET\xff".to_vec()));
    let result = EnvironmentKeyProvider::load(&name, KeyId::parse("env").unwrap());
    std::env::remove_var(&name);
    let error = result.unwrap_err();
    assert!(matches!(error, CryptoError::KeyUnavailable));
    assert!(!format!("{error:?} {error}").contains("FAKE-SECRET"));
    for name in ["", "INVALID=NAME", "INVALID\0NAME"] {
        assert!(matches!(
            EnvironmentKeyProvider::load(name, KeyId::parse("env").unwrap()),
            Err(CryptoError::KeyUnavailable)
        ));
    }
}
#[test]
fn environment_loading_is_explicit_canonical_and_redacted() {
    let name = format!("LYXAL_CRYPTO_TEST_ONLY_{}", std::process::id());
    let id = KeyId::parse("env").unwrap();
    std::env::remove_var(&name);
    assert!(matches!(
        EnvironmentKeyProvider::load(&name, id.clone()),
        Err(CryptoError::KeyUnavailable)
    ));
    for value in [
        "FAKE-SECRET",
        " AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=",
        "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=\n",
        "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAB=",
    ] {
        std::env::set_var(&name, value);
        let error = EnvironmentKeyProvider::load(&name, id.clone()).unwrap_err();
        assert!(!format!("{error:?} {error}").contains("FAKE-SECRET"));
    }
    std::env::set_var(&name, "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=");
    let key = EnvironmentKeyProvider::load(&name, id).unwrap();
    std::env::remove_var(&name);
    let mut b = KeyRingBuilder::new();
    b.insert_resolved(key, KeyUse::Active).unwrap();
    let e = CryptoEngine::new(StaticKeyResolver::new(Arc::new(b.build().unwrap())));
    let ctx = SecretContext::global("env.test").unwrap();
    let secret = SecretBytes::new(vec![8]).unwrap();
    let ciphertext = e.seal(&secret, &ctx).unwrap();
    assert_eq!(e.open(&ciphertext, &ctx).unwrap().expose_secret(), &[8]);
}
