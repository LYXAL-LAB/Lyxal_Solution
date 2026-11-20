// Literal vectors of STREAM_FORMAT_V1.md (computed by OpenSSL, never recomputed here) and
// Wycheproof AES-GCM vectors of the segment primitive. Fixed salt and nonce prefix are only
// reachable from these private tests.
use super::*;
use crate::key::tests::FailedRandom;
use std::collections::HashMap;

const SPEC: &str = include_str!("../STREAM_FORMAT_V1.md");

fn vectors() -> Vec<HashMap<&'static str, &'static str>> {
    SPEC.split("```text\n")
        .skip(1)
        .filter_map(|block| block.split("\n```").next())
        .filter(|block| block.starts_with("VECTOR="))
        .map(|block| block.lines().filter_map(|line| line.split_once('=')).collect())
        .collect()
}

fn array<const N: usize>(hex_text: &str) -> [u8; N] {
    hex::decode(hex_text).unwrap().try_into().unwrap()
}

fn context(text: &str) -> SecretContext {
    let fields: Vec<&str> = text.split('|').collect();
    match fields.as_slice() {
        ["tenant", tenant, module, resource, record, field] => {
            SecretContext::with_tenant(tenant, module, resource, record, field).unwrap()
        }
        ["global", purpose] => SecretContext::global(purpose).unwrap(),
        _ => panic!("unknown context"),
    }
}

fn plaintext(len: usize) -> Vec<u8> {
    (0..len).map(|i| (i % 251) as u8).collect()
}

/// Encrypt with the vector parameters, in irregular chunks (the result must not depend on them).
fn encrypt(vector: &HashMap<&str, &str>) -> (StreamKey, SecretContext, Vec<u8>, Vec<u8>) {
    let key = StreamKey::from_test_bytes(array(vector["KEY_HEX"]));
    let ctx = context(vector["CONTEXT"]);
    let data = plaintext(vector["PLAINTEXT_LENGTH"].parse().unwrap());
    let (mut encryptor, header) = StreamEncryptor::with_parameters(
        &key,
        &ctx,
        &array(vector["SALT_HEX"]),
        &array(vector["NONCE_PREFIX_HEX"]),
    )
    .unwrap();
    assert_eq!(hex::encode(header), vector["HEADER_HEX"]);
    assert_eq!(hex::encode(*encryptor.cipher.key), vector["SEGMENT_KEY_HEX"]);
    assert_eq!(hex::encode(&encryptor.cipher.aad), vector["AAD_HEX"]);
    let mut out = header.to_vec();
    for chunk in data.chunks(7919) {
        encryptor.update(chunk, &mut out).unwrap();
    }
    assert_eq!(encryptor.finish(&mut out).unwrap(), data.len() as u64);
    (key, ctx, data, out)
}

#[test]
fn literal_vectors_of_the_specification() {
    let all = vectors();
    let names: Vec<&str> = all.iter().map(|v| v["VECTOR"]).collect();
    assert_eq!(
        names,
        ["S0", "S1", "S65535", "S65536", "S65537", "S200000", "G1"]
    );
    for vector in &all {
        let (key, ctx, data, out) = encrypt(vector);
        assert_eq!(out.len().to_string(), vector["CIPHERTEXT_LENGTH"]);
        assert_eq!(
            stream_ciphertext_len(data.len() as u64).unwrap(),
            out.len() as u64
        );
        assert_eq!(crate::sha256_hex(&out), vector["CIPHERTEXT_SHA256"]);
        if let Some(full) = vector.get("CIPHERTEXT_HEX") {
            assert_eq!(hex::encode(&out), *full);
        }
        let decryptor = StreamDecryptor::new(&key, &ctx, &out[..47], out.len() as u64).unwrap();
        assert_eq!(decryptor.segment_count().to_string(), vector["SEGMENTS"]);
        assert_eq!(decryptor.plaintext_len(), data.len() as u64);
        let mut tags = Vec::new();
        let mut clear = Vec::new();
        for index in 0..decryptor.segment_count() {
            let span = decryptor
                .plan_range(index * SEGMENT..((index + 1) * SEGMENT).min(data.len() as u64))
                .unwrap();
            let range = span.ciphertext.start as usize..span.ciphertext.end as usize;
            tags.push(hex::encode(&out[range.end - 16..range.end]));
            let segment = decryptor.decrypt_segment(index, &out[range]).unwrap();
            clear.extend_from_slice(segment.expose_secret());
        }
        assert_eq!(tags.join(","), vector["TAGS_HEX"]);
        assert_eq!(clear, data);
    }
}

#[test]
fn rejection_vectors_of_the_specification() {
    let all = vectors();
    let vector = all.iter().find(|v| v["VECTOR"] == "S65537").unwrap();
    let (key, ctx, _, out) = encrypt(vector);
    let first = 47..47 + 65_552;
    // Truncated after the first segment: segment 0 is now read as the last one.
    let truncated = StreamDecryptor::new(&key, &ctx, &out[..47], 47 + 65_552).unwrap();
    assert_eq!(
        truncated.decrypt_segment(0, &out[first.clone()]).unwrap_err(),
        CryptoError::AuthenticationFailed
    );
    // Salt or nonce prefix modified in the header.
    for position in [8, 39, 40, 46] {
        let mut header = out[..47].to_vec();
        header[position] ^= 1;
        let decryptor = StreamDecryptor::new(&key, &ctx, &header, out.len() as u64).unwrap();
        assert_eq!(
            decryptor
                .decrypt_segment(0, &out[first.clone()])
                .unwrap_err(),
            CryptoError::AuthenticationFailed
        );
    }
    // Other contexts.
    for other in [
        "tenant|acme|storage|file|file_01|content",
        "global|storage.test",
    ] {
        let decryptor =
            StreamDecryptor::new(&key, &context(other), &out[..47], out.len() as u64).unwrap();
        assert_eq!(
            decryptor
                .decrypt_segment(0, &out[first.clone()])
                .unwrap_err(),
            CryptoError::AuthenticationFailed
        );
    }
    // Segment 1 (one byte) read in place of segment 0 is refused by length, then by its tag.
    let decryptor = StreamDecryptor::new(&key, &ctx, &out[..47], out.len() as u64).unwrap();
    assert_eq!(
        decryptor.decrypt_segment(0, &out[first.end..]).unwrap_err(),
        CryptoError::InvalidStreamHeader
    );
    assert_eq!(
        decryptor
            .decrypt_segment(1, &out[first.end - 17..first.end])
            .unwrap_err(),
        CryptoError::AuthenticationFailed
    );
}

#[test]
fn aad_identity_extends_the_enc_v2_encoding_without_key_id() {
    let ctx = context("tenant|Acme|storage|file|file_01|content");
    let aad = ctx.aad(&crate::KeyId::parse("k1").unwrap());
    // enc:v2 prefix (32) || mode || LP("k1") || fields, versus mode || fields.
    let mut expected = vec![aad[32]];
    expected.extend_from_slice(&aad[32 + 1 + 4 + 2..]);
    assert_eq!(ctx.identity(), expected);
}

#[test]
fn randomness_failure_has_no_fallback() {
    assert_eq!(
        StreamKey::generate_with(&mut FailedRandom).unwrap_err(),
        CryptoError::RandomUnavailable
    );
    let key = StreamKey::from_test_bytes([7; 32]);
    let ctx = context("global|storage.test");
    assert_eq!(
        StreamEncryptor::new_with(&key, &ctx, &mut FailedRandom).unwrap_err(),
        CryptoError::RandomUnavailable
    );
}

#[test]
fn wycheproof_aes_256_gcm_segment_primitive() {
    let suite: serde_json::Value = serde_json::from_str(include_str!(
        "../tests/fixtures/wycheproof/aes_gcm_test.json"
    ))
    .unwrap();
    let mut checked = 0;
    for group in suite["testGroups"].as_array().unwrap() {
        if group["keySize"] != 256 || group["ivSize"] != 96 || group["tagSize"] != 128 {
            continue;
        }
        for case in group["tests"].as_array().unwrap() {
            let field = |name: &str| hex::decode(case[name].as_str().unwrap()).unwrap();
            let key: [u8; 32] = field("key").try_into().unwrap();
            let nonce: [u8; 12] = field("iv").try_into().unwrap();
            let (aad, msg, ct) = (field("aad"), field("msg"), field("ct"));
            let tag: [u8; 16] = field("tag").try_into().unwrap();
            let mut buffer = ct.clone();
            let opened = open_segment(&key, &nonce, &aad, &mut buffer, &tag);
            match case["result"].as_str().unwrap() {
                "valid" => {
                    opened.unwrap();
                    assert_eq!(buffer, msg);
                    let mut sealed = msg.clone();
                    assert_eq!(seal_segment(&key, &nonce, &aad, &mut sealed).unwrap(), tag);
                    assert_eq!(sealed, ct);
                }
                "invalid" => assert_eq!(opened, Err(CryptoError::AuthenticationFailed)),
                other => panic!("unexpected result {other}"),
            }
            checked += 1;
        }
    }
    assert_eq!(checked, 66);
}
