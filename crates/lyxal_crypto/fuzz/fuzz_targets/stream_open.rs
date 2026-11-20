#![no_main]
//! Hostile encrypted files (STREAM_FORMAT_V1.md): no panic, no unbounded allocation; and the
//! detection property: a file encrypted here, then altered at fuzzer-chosen positions or cut,
//! never opens, while the untouched file always does.
use libfuzzer_sys::fuzz_target;
use lyxal_crypto::*;
use std::sync::OnceLock;

fn key() -> &'static StreamKey {
    static KEY: OnceLock<StreamKey> = OnceLock::new();
    KEY.get_or_init(|| StreamKey::generate().unwrap())
}

const SEGMENT_CT: usize = STREAM_SEGMENT_BYTES + STREAM_TAG_BYTES;

/// Decrypt a whole file; any error is returned (never a panic).
fn open(ctx: &SecretContext, file: &[u8]) -> Result<Vec<u8>, CryptoError> {
    let header = &file[..file.len().min(STREAM_HEADER_BYTES)];
    let decryptor = StreamDecryptor::new(key(), ctx, header, file.len() as u64)?;
    let mut clear = Vec::new();
    let mut offset = STREAM_HEADER_BYTES;
    for index in 0..decryptor.segment_count() {
        let end = (offset + SEGMENT_CT).min(file.len());
        clear.extend_from_slice(
            decryptor
                .decrypt_segment(index, &file[offset..end])?
                .expose_secret(),
        );
        offset = end;
    }
    assert_eq!(clear.len() as u64, decryptor.plaintext_len());
    Ok(clear)
}

fuzz_target!(|data: &[u8]| {
    let ctx = SecretContext::global("fuzz.stream").unwrap();
    // 1. Raw hostile input read as an encrypted file, with ranges planned from its bytes.
    assert!(open(&ctx, data).is_err());
    if let Ok(decryptor) = StreamDecryptor::new(
        key(),
        &ctx,
        &data[..data.len().min(STREAM_HEADER_BYTES)],
        data.len() as u64,
    ) {
        let len = decryptor.plaintext_len();
        let a = u64::from(data.get(1).copied().unwrap_or(0)) * 997;
        let b = u64::from(data.get(2).copied().unwrap_or(0)) * 1009;
        if let Ok(span) = decryptor.plan_range(a.min(b).min(len)..a.max(b).min(len)) {
            assert!(span.first_segment <= span.last_segment);
            assert!(span.last_segment < decryptor.segment_count());
            assert!(span.ciphertext.end <= data.len() as u64);
        }
    }
    // 2. Round trip of the input, then alterations chosen by its first bytes.
    let (mut encryptor, header) = StreamEncryptor::new(key(), &ctx).unwrap();
    let mut file = header.to_vec();
    let chunk = usize::from(data.first().copied().unwrap_or(1).max(1)) * 257;
    for piece in data.chunks(chunk) {
        encryptor.update(piece, &mut file).unwrap();
    }
    assert_eq!(encryptor.finish(&mut file).unwrap(), data.len() as u64);
    assert_eq!(
        stream_ciphertext_len(data.len() as u64).unwrap(),
        file.len() as u64
    );
    assert_eq!(open(&ctx, &file).unwrap(), data);
    let control = data.get(..8).unwrap_or(&[]);
    if control.len() == 8 {
        let position =
            u32::from_le_bytes([control[0], control[1], control[2], control[3]]) as usize;
        let mut altered = file.clone();
        match control[4] % 3 {
            0 => altered[position % file.len()] ^= control[5] | 1,
            1 => altered.truncate(position % file.len()),
            _ => altered.extend_from_slice(&control[5..]),
        }
        assert!(open(&ctx, &altered).is_err());
    }
});
