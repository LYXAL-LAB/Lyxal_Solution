use aes_gcm::aead::{Aead, KeyInit, Payload};
use aes_gcm::{Aes256Gcm, Nonce};
use lyxal_crypto::cipher::decrypt_aes_gcm;
use lyxal_crypto::key::EncryptionKey;

#[test]
fn test_nist_sp800_38d_aes256_gcm_vector_13() {
    // NIST SP 800-38D Test Case 13: PT empty, AAD empty
    let key_bytes =
        hex::decode("0000000000000000000000000000000000000000000000000000000000000000").unwrap();
    let iv_bytes = hex::decode("000000000000000000000000").unwrap();
    let tag_bytes = hex::decode("530f8afbc74536b9a963b4f1c4cb738b").unwrap();

    let cipher = Aes256Gcm::new_from_slice(&key_bytes).unwrap();
    let nonce = Nonce::from_slice(&iv_bytes);
    let payload = Payload { msg: b"", aad: b"" };

    let ciphertext = cipher.encrypt(nonce, payload).unwrap();
    assert_eq!(hex::encode(&ciphertext), hex::encode(&tag_bytes));

    let key = EncryptionKey::try_from_slice(&key_bytes).unwrap();
    let mut wrapped_payload = Vec::new();
    wrapped_payload.extend_from_slice(&iv_bytes);
    wrapped_payload.extend_from_slice(&ciphertext);

    let decrypted = decrypt_aes_gcm(&key, &wrapped_payload, b"").unwrap();
    assert_eq!(&*decrypted, b"");
}

#[test]
fn test_nist_sp800_38d_aes256_gcm_vector_14() {
    // NIST SP 800-38D Test Case 14: PT 128-bit (16B), AAD empty
    let key_bytes =
        hex::decode("0000000000000000000000000000000000000000000000000000000000000000").unwrap();
    let iv_bytes = hex::decode("000000000000000000000000").unwrap();
    let pt_bytes = hex::decode("00000000000000000000000000000000").unwrap();
    let expected_ct = "cea7403d4d606b6e074ec5d3baf39d18";
    let expected_tag = "d0d1c8a799996bf0265b98b5d48ab919";

    let cipher = Aes256Gcm::new_from_slice(&key_bytes).unwrap();
    let nonce = Nonce::from_slice(&iv_bytes);
    let payload = Payload {
        msg: &pt_bytes,
        aad: b"",
    };

    let encrypted = cipher.encrypt(nonce, payload).unwrap();
    let (ct, tag) = encrypted.split_at(pt_bytes.len());
    assert_eq!(hex::encode(ct), expected_ct);
    assert_eq!(hex::encode(tag), expected_tag);

    let key = EncryptionKey::try_from_slice(&key_bytes).unwrap();
    let mut wrapped = Vec::new();
    wrapped.extend_from_slice(&iv_bytes);
    wrapped.extend_from_slice(&encrypted);

    let decrypted = decrypt_aes_gcm(&key, &wrapped, b"").unwrap();
    assert_eq!(&*decrypted, &pt_bytes);
}

#[test]
fn test_nist_sp800_38d_aes256_gcm_vector_15() {
    // NIST SP 800-38D Test Case 15: PT 512-bit (64B), AAD empty
    let key_bytes =
        hex::decode("feffe9928665731c6d6a8f9467308308feffe9928665731c6d6a8f9467308308").unwrap();
    let iv_bytes = hex::decode("cafebabefacedbaddecaf888").unwrap();
    let pt_bytes = hex::decode("d9313225f88406e5a55909c5aff5269a86a7a9531534f7da2e4c303d8a318a721c3c0c95956809532fcf0e2449a6b525b16aedf5aa0de657ba637b391aafd255").unwrap();
    let expected_ct = "522dc1f099567d07f47f37a32a84427d643a8cdcbfe5c0c97598a2bd2555d1aa8cb08e48590dbb3da7b08b1056828838c5f61e6393ba7a0abcc9f662898015ad";
    let expected_tag = "b094dac5d93471bdec1a502270e3cc6c";

    let cipher = Aes256Gcm::new_from_slice(&key_bytes).unwrap();
    let nonce = Nonce::from_slice(&iv_bytes);
    let payload = Payload {
        msg: &pt_bytes,
        aad: b"",
    };

    let encrypted = cipher.encrypt(nonce, payload).unwrap();
    let (ct, tag) = encrypted.split_at(pt_bytes.len());
    assert_eq!(hex::encode(ct), expected_ct);
    assert_eq!(hex::encode(tag), expected_tag);

    let key = EncryptionKey::try_from_slice(&key_bytes).unwrap();
    let mut wrapped = Vec::new();
    wrapped.extend_from_slice(&iv_bytes);
    wrapped.extend_from_slice(&encrypted);

    let decrypted = decrypt_aes_gcm(&key, &wrapped, b"").unwrap();
    assert_eq!(&*decrypted, &pt_bytes);
}

#[test]
fn test_nist_sp800_38d_aes256_gcm_vector_16() {
    // NIST SP 800-38D Test Case 16: PT 512-bit (64B), AAD 160-bit (20B)
    let key_bytes =
        hex::decode("feffe9928665731c6d6a8f9467308308feffe9928665731c6d6a8f9467308308").unwrap();
    let iv_bytes = hex::decode("cafebabefacedbaddecaf888").unwrap();
    let pt_bytes = hex::decode("d9313225f88406e5a55909c5aff5269a86a7a9531534f7da2e4c303d8a318a721c3c0c95956809532fcf0e2449a6b525b16aedf5aa0de657ba637b391aafd255").unwrap();
    let aad_bytes = hex::decode("feedfacedeadbeeffeedfacedeadbeefabaddad2").unwrap();
    let expected_ct = "522dc1f099567d07f47f37a32a84427d643a8cdcbfe5c0c97598a2bd2555d1aa8cb08e48590dbb3da7b08b1056828838c5f61e6393ba7a0abcc9f662898015ad";
    let expected_tag = "2df7cd675b4f09163b41ebf980a7f638";

    let cipher = Aes256Gcm::new_from_slice(&key_bytes).unwrap();
    let nonce = Nonce::from_slice(&iv_bytes);
    let payload = Payload {
        msg: &pt_bytes,
        aad: &aad_bytes,
    };

    let encrypted = cipher.encrypt(nonce, payload).unwrap();
    let (ct, tag) = encrypted.split_at(pt_bytes.len());
    assert_eq!(hex::encode(ct), expected_ct);
    assert_eq!(hex::encode(tag), expected_tag);

    let key = EncryptionKey::try_from_slice(&key_bytes).unwrap();
    let mut wrapped = Vec::new();
    wrapped.extend_from_slice(&iv_bytes);
    wrapped.extend_from_slice(&encrypted);

    let decrypted = decrypt_aes_gcm(&key, &wrapped, &aad_bytes).unwrap();
    assert_eq!(&*decrypted, &pt_bytes);
}
