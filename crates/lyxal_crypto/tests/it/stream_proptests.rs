//! Properties of the streaming format: chunking independence, ranges, tampering.
use super::stream_v1::{context, data, decrypt, encrypt, read_range, SEGMENT, SEGMENT_CT};
use lyxal_crypto::*;
use proptest::prelude::*;

/// Sizes around the first two segment boundaries, plus small files.
fn size() -> impl Strategy<Value = usize> {
    prop_oneof![
        0usize..300,
        SEGMENT - 300..SEGMENT + 300,
        2 * SEGMENT - 100..2 * SEGMENT + 100,
    ]
}

proptest! {
    #![proptest_config(ProptestConfig::with_cases(48))]
    #[test]
    fn round_trip_whatever_the_chunking(len in size(), chunk in 1usize..100_000) {
        let key = StreamKey::generate().unwrap();
        let ctx = context();
        let plaintext = data(len);
        let file = encrypt(&key, &ctx, &plaintext, chunk);
        prop_assert_eq!(file.len() as u64, stream_ciphertext_len(len as u64).unwrap());
        prop_assert_eq!(decrypt(&key, &ctx, &file).unwrap(), plaintext);
    }

    #[test]
    fn any_range_equals_the_plaintext_slice(len in size(), a in any::<u64>(), b in any::<u64>()) {
        let key = StreamKey::generate().unwrap();
        let ctx = context();
        let plaintext = data(len);
        let file = encrypt(&key, &ctx, &plaintext, 7000);
        let (start, end) = if len == 0 { (0, 0) } else {
            let (x, y) = (a % (len as u64 + 1), b % (len as u64 + 1));
            (x.min(y), x.max(y))
        };
        prop_assert_eq!(
            read_range(&key, &ctx, &file, start..end).unwrap(),
            plaintext[start as usize..end as usize].to_vec()
        );
    }

    #[test]
    fn any_flipped_bit_fails(len in size(), position in any::<prop::sample::Index>(), bit in 0u8..8) {
        let key = StreamKey::generate().unwrap();
        let ctx = context();
        let mut file = encrypt(&key, &ctx, &data(len), 65_536);
        let position = position.index(file.len());
        file[position] ^= 1 << bit;
        prop_assert!(decrypt(&key, &ctx, &file).is_err());
    }

    #[test]
    fn any_truncation_or_extension_fails(len in size(), cut in any::<prop::sample::Index>(), extra in 1usize..200) {
        let key = StreamKey::generate().unwrap();
        let ctx = context();
        let file = encrypt(&key, &ctx, &data(len), 65_536);
        let cut = cut.index(file.len());
        prop_assert!(decrypt(&key, &ctx, &file[..cut]).is_err());
        let mut longer = file.clone();
        longer.extend(std::iter::repeat_n(0xA5, extra));
        prop_assert!(decrypt(&key, &ctx, &longer).is_err());
    }

    #[test]
    fn swapped_segments_or_other_context_fail(extra in 1usize..SEGMENT, record in "[a-z0-9_]{1,12}") {
        let key = StreamKey::generate().unwrap();
        let ctx = context();
        let file = encrypt(&key, &ctx, &data(2 * SEGMENT + extra), 65_536);
        let mut swapped = file.clone();
        swapped[47..47 + SEGMENT_CT].copy_from_slice(&file[47 + SEGMENT_CT..47 + 2 * SEGMENT_CT]);
        swapped[47 + SEGMENT_CT..47 + 2 * SEGMENT_CT].copy_from_slice(&file[47..47 + SEGMENT_CT]);
        prop_assert_eq!(decrypt(&key, &ctx, &swapped).unwrap_err(), CryptoError::AuthenticationFailed);
        let other = SecretContext::with_tenant("Acme", "storage", "file", &format!("{record}x"), "content").unwrap();
        prop_assert_eq!(decrypt(&key, &other, &file).unwrap_err(), CryptoError::AuthenticationFailed);
    }
}
