use lyxal_crypto::hash::{blake3, blake3_hex, sha256, sha256_hex, Blake3Hasher, Sha256Hasher};

#[test]
fn test_nist_sha256_official_vectors() {
    // NIST Vector 1: Empty string
    assert_eq!(
        sha256_hex(b""),
        "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
    );

    // NIST Vector 2: "abc"
    assert_eq!(
        sha256_hex(b"abc"),
        "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad"
    );

    // NIST Vector 3: 448-bit message (FIPS 180-2)
    let msg = b"abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq";
    assert_eq!(
        sha256_hex(msg),
        "248d6a61d20638b8e5c026930c3e6039a33ce45964ff2167f6ecedd419db06c1"
    );

    // Binary output matches hex
    let bin = sha256(b"abc");
    assert_eq!(hex::encode(bin), sha256_hex(b"abc"));
}

#[test]
fn test_blake3_official_reference_vectors() {
    // Official BLAKE3 Vector 1: Empty string
    assert_eq!(
        blake3_hex(b""),
        "af1349b9f5f9a1a6a0404dea36dcc9499bcb25c9adc112b7cc9a93cae41f3262"
    );

    // Official BLAKE3 Vector 2: "abc"
    assert_eq!(
        blake3_hex(b"abc"),
        "6437b3ac38465133ffb63b75273a8db548c558465d79db03fd359c6cd5bd9d85"
    );

    // Binary output matches hex
    let bin = blake3(b"abc");
    assert_eq!(hex::encode(bin), blake3_hex(b"abc"));
}

#[test]
fn test_streaming_sha256_hasher_matches_oneshot() {
    let part1 = b"hello ";
    let part2 = b"world from ";
    let part3 = b"lyxal runtime";

    let mut full = Vec::new();
    full.extend_from_slice(part1);
    full.extend_from_slice(part2);
    full.extend_from_slice(part3);

    let mut hasher = Sha256Hasher::new();
    hasher.update(part1);
    hasher.update(part2);
    hasher.update(part3);

    assert_eq!(hasher.finalize_hex(), sha256_hex(&full));
}

#[test]
fn test_streaming_blake3_hasher_matches_oneshot() {
    let part1 = b"part1_data_";
    let part2 = b"part2_data_";
    let part3 = b"part3_data";

    let mut full = Vec::new();
    full.extend_from_slice(part1);
    full.extend_from_slice(part2);
    full.extend_from_slice(part3);

    let mut hasher = Blake3Hasher::new();
    hasher.update(part1);
    hasher.update(part2);
    hasher.update(part3);

    assert_eq!(hasher.finalize_hex(), blake3_hex(&full));
}
