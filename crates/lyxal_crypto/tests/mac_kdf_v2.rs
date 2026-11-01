use lyxal_crypto::*;
#[test]
fn hmac_has_a_distinct_key_and_strict_tag_encoding() {
    let key = HmacKey::import(SecretBytes::new(vec![0x0b; 32]).unwrap()).unwrap();
    let tag = sign_hmac_sha256(&key, b"data").unwrap();
    assert!(verify_hmac_sha256(&key, b"data", &tag).unwrap());
    assert!(!verify_hmac_sha256(&key, b"other", &tag).unwrap());
    assert!(matches!(
        verify_hmac_sha256(&key, b"data", &tag[..31]),
        Err(CryptoError::InvalidTagEncoding)
    ));
    let encoded = sign_hmac_sha256_hex(&key, b"data").unwrap();
    assert!(verify_hmac_sha256_hex(&key, b"data", &encoded).unwrap());
    assert!(verify_hmac_sha256_hex(&key, b"data", &format!(" {encoded}")).is_err());
    assert!(verify_hmac_sha256_hex(&key, b"data", &"a".repeat(100_000)).is_err());
}
#[test]
fn hkdf_rfc5869_and_output_bounds() {
    let ikm = SecretBytes::new(vec![0x0b; 22]).unwrap();
    let salt: Vec<u8> = (0..13).collect();
    let info: Vec<u8> = (0xf0..=0xf9).collect();
    let out = hkdf_sha256(&ikm, Some(&salt), &info, 42).unwrap();
    assert_eq!(
        hex::encode(out.expose_secret()),
        "3cb25f25faacd57a90434f64d0362f2a2d2d0a90cf1a5a4c5db02d56ecc4c5bf34007208d5b887185865"
    );
    assert_eq!(
        hkdf_sha256(&ikm, Some(&salt), &info, 32)
            .unwrap()
            .expose_secret(),
        &out.expose_secret()[..32]
    );
    assert!(hkdf_sha256(&ikm, None, &info, 8160).is_ok());
    assert!(hkdf_sha256(&ikm, None, &info, 8161).is_err());
    assert!(hkdf_sha256(&ikm, None, &[], 32).is_err());
    assert!(hkdf_sha256(&ikm, None, &info, 0).is_err());
}

#[test]
fn domain_info_boundary_is_enforced() {
    let ikm = SecretBytes::new(vec![1; 32]).unwrap();
    assert!(hkdf_sha256(&ikm, None, &vec![1; 1024], 32).is_ok());
    assert!(hkdf_sha256(&ikm, None, &vec![1; 1025], 32).is_err());
}
