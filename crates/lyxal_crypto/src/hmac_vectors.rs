fn sign_hmac_sha256(key: &[u8], data: &[u8]) -> [u8; 32] {
    super::sign_bytes(key, data).unwrap()
}
fn sign_hmac_sha256_hex(key: &[u8], data: &[u8]) -> String {
    hex::encode(sign_hmac_sha256(key, data))
}
fn verify_hmac_sha256(key: &[u8], data: &[u8], tag: &[u8]) -> bool {
    super::verify_bytes(key, data, tag).unwrap_or(false)
}
fn verify_hmac_sha256_hex(key: &[u8], data: &[u8], text: &str) -> bool {
    verify_hmac_sha256(key, data, &hex::decode(text).unwrap())
}
#[test]
fn test_rfc4231_hmac_sha256_official_vectors() {
    // RFC 4231 Test Case 1
    let key1 = [0x0bu8; 20];
    let data1 = b"Hi There";
    let expected1 = "b0344c61d8db38535ca8afceaf0bf12b881dc200c9833da726e9376c2e32cff7";
    assert_eq!(sign_hmac_sha256_hex(&key1, data1), expected1);
    assert!(verify_hmac_sha256_hex(&key1, data1, expected1));
    assert!(verify_hmac_sha256(
        &key1,
        data1,
        &hex::decode(expected1).unwrap()
    ));

    // RFC 4231 Test Case 2
    let key2 = b"Jefe";
    let data2 = b"what do ya want for nothing?";
    let expected2 = "5bdcc146bf60754e6a042426089575c75a003f089d2739839dec58b964ec3843";
    assert_eq!(sign_hmac_sha256_hex(key2, data2), expected2);
    assert!(verify_hmac_sha256_hex(key2, data2, expected2));

    // RFC 4231 Test Case 3
    let key3 = [0xaau8; 20];
    let data3 = [0xddu8; 50];
    let expected3 = "773ea91e36800e46854db8ebd09181a72959098b3ef8c122d9635514ced565fe";
    assert_eq!(sign_hmac_sha256_hex(&key3, &data3), expected3);
    assert!(verify_hmac_sha256_hex(&key3, &data3, expected3));

    // RFC 4231 Test Case 7 (Key larger than SHA-256 block size)
    let key7 = [0xaau8; 131];
    let data7 = b"This is a test using a larger than block-size key and a larger than block-size data. The key needs to be hashed before being used by the HMAC algorithm.";
    let expected7 = "9b09ffa71b942fcb27635fbcd5b0e944bfdc63644f0713938a7f51535c3a35e2";
    assert_eq!(sign_hmac_sha256_hex(&key7, data7), expected7);
    assert!(verify_hmac_sha256_hex(&key7, data7, expected7));
}

#[test]
fn test_verify_hmac_sha256_fails_on_tampering() {
    let key = b"secret-key";
    let data = b"authenticated payload";
    let tag = sign_hmac_sha256(key, data);

    // Mauvais message
    assert!(!verify_hmac_sha256(key, b"corrupted payload", &tag));

    // Mauvaise clé
    assert!(!verify_hmac_sha256(b"wrong-key", data, &tag));

    // Tag altéré
    let mut bad_tag = tag;
    bad_tag[0] ^= 0x01;
    assert!(!verify_hmac_sha256(key, data, &bad_tag));

    // Tag tronqué
    assert!(!verify_hmac_sha256(key, data, &tag[..16]));
}

#[test]
fn supplemental_32_byte_key_vector_is_retained() {
    assert_eq!(
        sign_hmac_sha256_hex(&[0xaa; 32], &[0xdd; 50]),
        "cdcb1220d1ecccea91e53aba3092f962e549fe6ce9ed7fdc43191fbde45c30b0"
    );
}
