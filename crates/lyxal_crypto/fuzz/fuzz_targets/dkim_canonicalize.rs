#![no_main]
//! Hostile message bytes for DKIM canonicalization: no panic, bounded signed data, and a body
//! hash that does not depend on how the body is cut into chunks.
//! Input: first byte = options (canonicalizations, chunk size, `l=`), then the bytes, split at
//! the first 0x00 into a header part (name, ':', value; lines separated by 0x0a) and a body.
use libfuzzer_sys::fuzz_target;
use lyxal_crypto::*;

fn canonicalization(bit: bool) -> DkimCanonicalization {
    if bit {
        DkimCanonicalization::Relaxed
    } else {
        DkimCanonicalization::Simple
    }
}

fuzz_target!(|data: &[u8]| {
    let Some((&options, rest)) = data.split_first() else {
        return;
    };
    let (head, body) = match rest.iter().position(|&b| b == 0) {
        Some(split) => (&rest[..split], &rest[split + 1..]),
        None => (rest, &[][..]),
    };
    let body_canon = canonicalization(options & 1 != 0);
    let limit = (options & 2 != 0).then(|| u64::from(options >> 4) * 7);
    let chunk = usize::from((options >> 2) & 0x0f) + 1;

    let mut whole = DkimBodyHasher::new(body_canon, limit);
    whole.update(body);
    let whole = whole.finish();
    let mut pieces = DkimBodyHasher::new(body_canon, limit);
    for part in body.chunks(chunk) {
        pieces.update(part);
    }
    assert_eq!(pieces.finish(), whole);

    let mut headers = DkimHeaderCanonicalizer::new(canonicalization(options & 0x80 != 0));
    let mut lines = head.split(|&b| b == b'\n').peekable();
    while let Some(line) = lines.next() {
        let (name, value) = match line.iter().position(|&b| b == b':') {
            Some(colon) => (&line[..colon], &line[colon + 1..]),
            None => (line, &[][..]),
        };
        if lines.peek().is_none() {
            if let Ok(signed) = headers.finish(name, value) {
                assert!(signed.as_bytes().len() <= DKIM_MAX_SIGNED_DATA_BYTES);
            }
            return;
        }
        if headers.push_header(name, value).is_err() {
            return;
        }
    }
});
