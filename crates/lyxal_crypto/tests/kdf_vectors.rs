use lyxal_crypto::kdf::{hkdf_sha256, hkdf_sha256_32};

#[test]
fn test_rfc5869_hkdf_sha256_official_vectors() {
    // RFC 5869 Test Case 1
    let ikm1 = [0x0bu8; 22];
    let salt1 = [
        0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c,
    ];
    let info1 = [0xf0, 0xf1, 0xf2, 0xf3, 0xf4, 0xf5, 0xf6, 0xf7, 0xf8, 0xf9];
    let mut okm1 = [0u8; 42];
    hkdf_sha256(&ikm1, Some(&salt1), &info1, &mut okm1).unwrap();

    let expected1 =
        "3cb25f25faacd57a90434f64d0362f2a2d2d0a90cf1a5a4c5db02d56ecc4c5bf34007208d5b887185865";
    assert_eq!(hex::encode(okm1), expected1);

    // Test Case 1 with 32-byte specialized function
    let okm1_32 = hkdf_sha256_32(&ikm1, Some(&salt1), &info1).unwrap();
    assert_eq!(hex::encode(*okm1_32), &expected1[..64]);
}

#[test]
fn test_rfc5869_hkdf_sha256_no_salt() {
    let ikm = [0x0bu8; 22];
    let info = [0xf0, 0xf1, 0xf2, 0xf3];
    let mut okm = [0u8; 32];
    hkdf_sha256(&ikm, None, &info, &mut okm).unwrap();
    assert_ne!(okm, [0u8; 32]);
}
