//! Streaming file encryption (STREAM_FORMAT_V1.md): round trips at segment boundaries, range
//! reads, sealed file keys and every tampering rule of the specification.
use lyxal_crypto::*;
use std::sync::Arc;

pub(crate) const SEGMENT: usize = STREAM_SEGMENT_BYTES;
pub(crate) const SEGMENT_CT: usize = STREAM_SEGMENT_BYTES + STREAM_TAG_BYTES;

pub(crate) fn context() -> SecretContext {
    SecretContext::with_tenant("Acme", "storage", "file", "file_01", "content").unwrap()
}

pub(crate) fn data(len: usize) -> Vec<u8> {
    (0..len)
        .map(|i| (i.wrapping_mul(31) ^ (i >> 8)) as u8)
        .collect()
}

/// Encrypt `plaintext` fed in chunks of `chunk` bytes; returns the whole encrypted file.
pub(crate) fn encrypt(
    key: &StreamKey,
    ctx: &SecretContext,
    plaintext: &[u8],
    chunk: usize,
) -> Vec<u8> {
    let (mut encryptor, header) = StreamEncryptor::new(key, ctx).unwrap();
    let mut out = header.to_vec();
    for piece in plaintext.chunks(chunk.max(1)) {
        encryptor.update(piece, &mut out).unwrap();
    }
    assert_eq!(encryptor.finish(&mut out).unwrap(), plaintext.len() as u64);
    out
}

/// Decrypt a whole file segment by segment; the first failure is returned.
pub(crate) fn decrypt(
    key: &StreamKey,
    ctx: &SecretContext,
    file: &[u8],
) -> Result<Vec<u8>, CryptoError> {
    let header = &file[..file.len().min(STREAM_HEADER_BYTES)];
    let decryptor = StreamDecryptor::new(key, ctx, header, file.len() as u64)?;
    let span = decryptor.plan_range(0..decryptor.plaintext_len())?;
    let mut clear = Vec::new();
    let mut offset = span.ciphertext.start as usize;
    for index in span.first_segment..=span.last_segment {
        let end = (offset + SEGMENT_CT).min(file.len());
        let segment = decryptor.decrypt_segment(index, &file[offset..end])?;
        clear.extend_from_slice(segment.expose_secret());
        offset = end;
    }
    Ok(clear)
}

/// Read a plaintext range through `plan_range`, as an IMAP partial fetch or an HTTP range would.
pub(crate) fn read_range(
    key: &StreamKey,
    ctx: &SecretContext,
    file: &[u8],
    range: std::ops::Range<u64>,
) -> Result<Vec<u8>, CryptoError> {
    let decryptor =
        StreamDecryptor::new(key, ctx, &file[..STREAM_HEADER_BYTES], file.len() as u64)?;
    let span = decryptor.plan_range(range)?;
    let bytes = &file[span.ciphertext.start as usize..span.ciphertext.end as usize];
    let mut clear = Vec::new();
    for (position, index) in (span.first_segment..=span.last_segment).enumerate() {
        let start = position * SEGMENT_CT;
        let end = (start + SEGMENT_CT).min(bytes.len());
        clear.extend_from_slice(
            decryptor
                .decrypt_segment(index, &bytes[start..end])?
                .expose_secret(),
        );
    }
    Ok(clear[span.skip_in_first..span.skip_in_first + span.take as usize].to_vec())
}

#[test]
fn round_trips_at_segment_boundaries() {
    let key = StreamKey::generate().unwrap();
    let ctx = context();
    for len in [
        0,
        1,
        SEGMENT - 1,
        SEGMENT,
        SEGMENT + 1,
        2 * SEGMENT,
        3 * SEGMENT - 1,
        5 * 1024 * 1024 + 123,
    ] {
        let plaintext = data(len);
        for chunk in [1usize << 20, SEGMENT, 4093] {
            let file = encrypt(&key, &ctx, &plaintext, chunk);
            assert_eq!(
                file.len() as u64,
                stream_ciphertext_len(len as u64).unwrap(),
                "{len}"
            );
            assert_eq!(decrypt(&key, &ctx, &file).unwrap(), plaintext, "{len}");
        }
    }
}

#[test]
fn sizes_and_limits() {
    assert_eq!(stream_ciphertext_len(0).unwrap(), 63);
    assert_eq!(stream_ciphertext_len(1).unwrap(), 64);
    assert_eq!(stream_ciphertext_len(65_536).unwrap(), 47 + 65_552);
    assert_eq!(stream_ciphertext_len(65_537).unwrap(), 47 + 65_552 + 17);
    let max = 1u64 << 48;
    assert_eq!(
        stream_ciphertext_len(max).unwrap(),
        47 + max + 16 * (1u64 << 32)
    );
    assert_eq!(
        stream_ciphertext_len(max + 1).unwrap_err(),
        CryptoError::InputTooLarge
    );
    // The largest valid size is accepted by the reader, one segment more is not.
    let key = StreamKey::generate().unwrap();
    let file = encrypt(&key, &context(), b"", 1);
    let header = &file[..STREAM_HEADER_BYTES];
    let decryptor = StreamDecryptor::new(
        &key,
        &context(),
        header,
        stream_ciphertext_len(max).unwrap(),
    )
    .unwrap();
    assert_eq!(decryptor.segment_count(), 1u64 << 32);
    assert_eq!(decryptor.plaintext_len(), max);
    assert_eq!(
        StreamDecryptor::new(
            &key,
            &context(),
            header,
            stream_ciphertext_len(max).unwrap() + 17
        )
        .unwrap_err(),
        CryptoError::InvalidStreamHeader
    );
}

#[test]
fn incoherent_sizes_and_headers_are_refused_before_decryption() {
    let key = StreamKey::generate().unwrap();
    let ctx = context();
    let file = encrypt(&key, &ctx, &data(SEGMENT + 1), 4096);
    let header = &file[..STREAM_HEADER_BYTES];
    for len in [
        0u64,
        46,
        47,
        62,
        47 + 65_552 + 1,
        47 + 65_552 + 15,
        47 + 65_552 + 16,
    ] {
        assert_eq!(
            StreamDecryptor::new(&key, &ctx, header, len).unwrap_err(),
            CryptoError::InvalidStreamHeader,
            "{len}"
        );
    }
    assert_eq!(
        StreamDecryptor::new(&key, &ctx, &header[..46], file.len() as u64).unwrap_err(),
        CryptoError::InvalidStreamHeader
    );
    let mut longer = header.to_vec();
    longer.push(0);
    assert_eq!(
        StreamDecryptor::new(&key, &ctx, &longer, file.len() as u64).unwrap_err(),
        CryptoError::InvalidStreamHeader
    );
    for (position, value, expected) in [
        (0, b'X', CryptoError::InvalidStreamHeader),
        (3, b'2', CryptoError::InvalidStreamHeader),
        (4, 2, CryptoError::UnsupportedVersion),
        (4, 0, CryptoError::UnsupportedVersion),
        (5, 2, CryptoError::InvalidStreamHeader),
        (6, 0x11, CryptoError::InvalidStreamHeader),
        (7, 1, CryptoError::InvalidStreamHeader),
    ] {
        let mut bad = header.to_vec();
        bad[position] = value;
        assert_eq!(
            StreamDecryptor::new(&key, &ctx, &bad, file.len() as u64).unwrap_err(),
            expected,
            "{position}"
        );
    }
    let decryptor = StreamDecryptor::new(&key, &ctx, header, file.len() as u64).unwrap();
    assert_eq!(
        decryptor.decrypt_segment(2, &file[47..]).unwrap_err(),
        CryptoError::InvalidStreamHeader
    );
    assert_eq!(
        decryptor
            .decrypt_segment(0, &file[47..47 + SEGMENT_CT - 1])
            .unwrap_err(),
        CryptoError::InvalidStreamHeader
    );
}

#[test]
fn range_reads_match_the_plaintext() {
    let key = StreamKey::generate().unwrap();
    let ctx = context();
    let plaintext = data(3 * SEGMENT + 1000);
    let file = encrypt(&key, &ctx, &plaintext, 10_000);
    let len = plaintext.len() as u64;
    let s = SEGMENT as u64;
    for range in [
        0..len,
        0..1,
        s - 1..s + 1,
        s..2 * s,
        1_000..1_010,
        2 * s + 5..3 * s + 999,
        len - 1..len,
        0..0,
        s..s,
        len..len,
    ] {
        assert_eq!(
            read_range(&key, &ctx, &file, range.clone()).unwrap(),
            plaintext[range.start as usize..range.end as usize],
            "{range:?}"
        );
    }
    let decryptor = StreamDecryptor::new(&key, &ctx, &file[..47], file.len() as u64).unwrap();
    let span = decryptor.plan_range(s - 1..s + 1).unwrap();
    assert_eq!(
        span,
        StreamSpan {
            first_segment: 0,
            last_segment: 1,
            ciphertext: 47..47 + 2 * SEGMENT_CT as u64,
            skip_in_first: SEGMENT - 1,
            take: 2,
        }
    );
    // Only the segments of the range are read: 1 000..1 010 needs the first segment alone.
    let span = decryptor.plan_range(1_000..1_010).unwrap();
    assert_eq!(span.ciphertext, 47..47 + SEGMENT_CT as u64);
    let last = decryptor.plan_range(len - 1..len).unwrap();
    assert_eq!(
        last.ciphertext,
        47 + 3 * SEGMENT_CT as u64..file.len() as u64
    );
    #[allow(clippy::reversed_empty_ranges)]
    let inverted = 5..4;
    for bad in [inverted, 0..len + 1, len + 1..len + 1] {
        assert_eq!(
            decryptor.plan_range(bad).unwrap_err(),
            CryptoError::InputTooLarge
        );
    }
    // Empty file: one segment holding the tag only.
    let empty = encrypt(&key, &ctx, b"", 1);
    assert_eq!(read_range(&key, &ctx, &empty, 0..0).unwrap(), b"");
}

#[test]
fn tampering_is_detected_at_the_segment_concerned() {
    let key = StreamKey::generate().unwrap();
    let ctx = context();
    let plaintext = data(3 * SEGMENT + 77);
    let file = encrypt(&key, &ctx, &plaintext, SEGMENT);
    let failed = |bytes: &[u8]| decrypt(&key, &ctx, bytes).unwrap_err();
    // Flipped bit in a segment body, in a tag, in the salt and in the nonce prefix.
    for position in [
        47,
        47 + SEGMENT_CT + 5,
        47 + SEGMENT_CT - 1,
        file.len() - 1,
        8,
        46,
    ] {
        let mut bad = file.clone();
        bad[position] ^= 0x01;
        assert_eq!(
            failed(&bad),
            CryptoError::AuthenticationFailed,
            "{position}"
        );
    }
    // Truncations: inside the last segment, at every segment boundary, one byte short.
    for len in [
        file.len() - 1,
        file.len() - 20,
        47 + 3 * SEGMENT_CT,
        47 + 2 * SEGMENT_CT,
        47 + SEGMENT_CT,
    ] {
        let error = failed(&file[..len]);
        assert!(
            matches!(
                error,
                CryptoError::AuthenticationFailed | CryptoError::InvalidStreamHeader
            ),
            "{len}: {error:?}"
        );
    }
    assert_eq!(
        failed(&file[..47 + SEGMENT_CT]),
        CryptoError::AuthenticationFailed
    );
    // Two segments swapped.
    let mut swapped = file.clone();
    let (a, b) = (47..47 + SEGMENT_CT, 47 + SEGMENT_CT..47 + 2 * SEGMENT_CT);
    let first = file[a.clone()].to_vec();
    swapped[a].copy_from_slice(&file[b.clone()]);
    swapped[b].copy_from_slice(&first);
    assert_eq!(failed(&swapped), CryptoError::AuthenticationFailed);
    // Segment duplicated in place of another, segment appended after the last one.
    let mut duplicated = file.clone();
    duplicated.copy_within(47..47 + SEGMENT_CT, 47 + SEGMENT_CT);
    assert_eq!(failed(&duplicated), CryptoError::AuthenticationFailed);
    let mut extended = file.clone();
    extended.extend_from_slice(&file[file.len() - 93..]);
    assert_eq!(failed(&extended), CryptoError::AuthenticationFailed);
    // Exactly full last segment then one more full segment appended.
    let full = encrypt(&key, &ctx, &data(2 * SEGMENT), SEGMENT);
    let mut appended = full.clone();
    appended.extend_from_slice(&full[47..47 + SEGMENT_CT]);
    assert_eq!(failed(&appended), CryptoError::AuthenticationFailed);
    // Segment taken from another file encrypted with the same key and context.
    let other = encrypt(&key, &ctx, &plaintext, SEGMENT);
    let mut mixed = file.clone();
    mixed[47..47 + SEGMENT_CT].copy_from_slice(&other[47..47 + SEGMENT_CT]);
    assert_eq!(failed(&mixed), CryptoError::AuthenticationFailed);
    // Header of another file.
    let mut header_swapped = file.clone();
    header_swapped[..47].copy_from_slice(&other[..47]);
    assert_eq!(failed(&header_swapped), CryptoError::AuthenticationFailed);
    // Wrong context (another record, organisation or mode) and wrong key.
    for wrong in [
        SecretContext::with_tenant("Acme", "storage", "file", "file_02", "content").unwrap(),
        SecretContext::with_tenant("acme", "storage", "file", "file_01", "content").unwrap(),
        SecretContext::global("storage.content").unwrap(),
    ] {
        assert_eq!(
            decrypt(&key, &wrong, &file).unwrap_err(),
            CryptoError::AuthenticationFailed
        );
    }
    assert_eq!(
        decrypt(&StreamKey::generate().unwrap(), &ctx, &file).unwrap_err(),
        CryptoError::AuthenticationFailed
    );
    // The untouched file still opens; earlier segments of a file altered further on are returned.
    assert_eq!(decrypt(&key, &ctx, &file).unwrap(), plaintext);
    let mut late = file.clone();
    let last = late.len() - 1;
    late[last] ^= 1;
    assert_eq!(
        read_range(&key, &ctx, &late, 0..10).unwrap(),
        plaintext[..10]
    );
}

#[test]
fn every_file_has_fresh_header_parameters() {
    let key = StreamKey::generate().unwrap();
    let ctx = context();
    let a = encrypt(&key, &ctx, b"same content", 4);
    let b = encrypt(&key, &ctx, b"same content", 4);
    assert_eq!(&a[..8], b"LXS1\x01\x01\x10\x00");
    assert_ne!(a[8..47], b[8..47]);
    assert_ne!(a[47..], b[47..]);
}

#[test]
fn file_keys_are_sealed_by_enc_v2() {
    let mut builder = KeyRingBuilder::new();
    builder
        .insert(
            KeyId::parse("org-2026").unwrap(),
            EncryptionKey::generate().unwrap(),
            KeyUse::Active,
        )
        .unwrap();
    let engine = CryptoEngine::new(StaticKeyResolver::new(Arc::new(builder.build().unwrap())));
    let ctx = context();
    let key = StreamKey::generate().unwrap();
    let file = encrypt(&key, &ctx, &data(70_000), 8192);
    let sealed = key.seal(&engine, &ctx).unwrap();
    let stored = sealed.encode();
    assert!(stored.starts_with("enc:v2:org-2026:"));
    let reopened =
        StreamKey::open(&engine, &EncryptedEnvelope::parse(&stored).unwrap(), &ctx).unwrap();
    assert_eq!(decrypt(&reopened, &ctx, &file).unwrap(), data(70_000));
    let other =
        SecretContext::with_tenant("Acme", "storage", "file", "file_02", "content").unwrap();
    assert_eq!(
        StreamKey::open(&engine, &sealed, &other).unwrap_err(),
        CryptoError::AuthenticationFailed
    );
    let not_a_key = engine
        .seal(&SecretBytes::new(vec![7; 31]).unwrap(), &ctx)
        .unwrap();
    assert_eq!(
        StreamKey::open(&engine, &not_a_key, &ctx).unwrap_err(),
        CryptoError::InvalidKeyLength
    );
}

#[test]
fn diagnostics_are_redacted() {
    let key = StreamKey::generate().unwrap();
    let ctx = context();
    let (encryptor, header) = StreamEncryptor::new(&key, &ctx).unwrap();
    let decryptor = StreamDecryptor::new(&key, &ctx, &header, 63).unwrap();
    assert_eq!(format!("{key:?}"), "StreamKey([REDACTED])");
    assert_eq!(format!("{encryptor:?}"), "StreamEncryptor([REDACTED])");
    assert_eq!(format!("{decryptor:?}"), "StreamDecryptor([REDACTED])");
    assert_eq!(
        CryptoError::InvalidStreamHeader.to_string(),
        "invalid stream header or ciphertext length"
    );
}
