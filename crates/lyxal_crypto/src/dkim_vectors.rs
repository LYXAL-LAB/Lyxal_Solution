// Canonicalization tests. The cases of `dkim_canonicalize`, of the body hasher and of
// `relaxed_body_*` are those of `mail-auth` 0.16.0 (`src/dkim/canonicalize.rs`, Apache-2.0 OR MIT,
// see SOURCES.md), adapted to this API (header values without their final CRLF; `l=` counted on
// canonicalized octets). The relaxed reference is the line-based reading of RFC 6376 §3.4.4.
use super::canonicalize::strip_signature_value;
use super::*;
use base64::engine::general_purpose::STANDARD;
use base64::Engine;

/// Test-only split of a message into headers (name before the first `:`, value after it, without
/// the final CRLF; folded lines joined) and body (after the first empty line).
type Headers = Vec<(Vec<u8>, Vec<u8>)>;

fn split(message: &[u8]) -> (Headers, Vec<u8>) {
    let mut headers: Vec<Vec<u8>> = Vec::new();
    let mut rest = message;
    loop {
        let end = rest
            .windows(2)
            .position(|w| w == b"\r\n")
            .unwrap_or(rest.len());
        let line = &rest[..end];
        rest = rest.get(end + 2..).unwrap_or_default();
        if line.is_empty() {
            break;
        }
        match headers.last_mut() {
            Some(last) if matches!(line[0], b' ' | b'\t') => {
                last.extend_from_slice(b"\r\n");
                last.extend_from_slice(line);
            }
            _ => headers.push(line.to_vec()),
        }
        if rest.is_empty() {
            break;
        }
    }
    let headers = headers
        .into_iter()
        .map(|header| {
            let colon = header.iter().position(|&c| c == b':').unwrap();
            (header[..colon].to_vec(), header[colon + 1..].to_vec())
        })
        .collect();
    (headers, rest.to_vec())
}

fn canonical_headers(message: &str, canonicalization: DkimCanonicalization) -> String {
    let (headers, _) = split(message.as_bytes());
    let mut out = Vec::new();
    for (name, value) in &headers {
        match canonicalization {
            DkimCanonicalization::Simple => {
                canonicalize::write_simple_header(name, value, &mut out)
            }
            DkimCanonicalization::Relaxed => {
                canonicalize::write_relaxed_name(name, &mut out);
                canonicalize::write_relaxed_value(value, &mut out);
            }
        }
        out.extend_from_slice(b"\r\n");
    }
    String::from_utf8(out).unwrap()
}

fn canonical_body(body: &[u8], canonicalization: DkimCanonicalization) -> Vec<u8> {
    let mut out = Vec::new();
    let mut state = BodyState::new();
    state.write(canonicalization.is_relaxed(), body, &mut out);
    state.finish(canonicalization.is_relaxed(), &mut out);
    out
}

fn body_hash(body: &[u8], canonicalization: DkimCanonicalization, chunk: usize) -> DkimBodyHash {
    let mut hasher = DkimBodyHasher::new(canonicalization, None);
    for part in body.chunks(chunk.max(1)) {
        hasher.update(part);
    }
    if body.is_empty() {
        hasher.update(b"");
    }
    hasher.finish()
}

#[test]
fn dkim_canonicalize() {
    for (message, (relaxed_headers, relaxed_body), (simple_headers, simple_body)) in [
        (
            concat!(
                "A: X\r\n",
                "B : Y\t\r\n",
                "\tZ  \r\n",
                "\r\n",
                " C \r\n",
                "D \t E\r\n"
            ),
            (
                concat!("a:X\r\n", "b:Y Z\r\n"),
                concat!(" C\r\n", "D E\r\n"),
            ),
            ("A: X\r\nB : Y\t\r\n\tZ  \r\n", " C \r\nD \t E\r\n"),
        ),
        (
            concat!(
                "  From : John\tdoe <jdoe@domain.com>\t\r\n",
                "SUB JECT:\ttest  \t  \r\n\r\n",
                " body \t   \r\n",
                "\r\n",
                "\r\n",
            ),
            (
                concat!("from:John doe <jdoe@domain.com>\r\n", "subject:test\r\n"),
                " body\r\n",
            ),
            (
                concat!(
                    "  From : John\tdoe <jdoe@domain.com>\t\r\n",
                    "SUB JECT:\ttest  \t  \r\n"
                ),
                " body \t   \r\n",
            ),
        ),
        (
            "H: value\t\r\n\r\n",
            ("h:value\r\n", ""),
            ("H: value\t\r\n", "\r\n"),
        ),
        (
            "\tx\t: \t\t\tz\r\n\r\nabc",
            ("x:z\r\n", "abc\r\n"),
            ("\tx\t: \t\t\tz\r\n", "abc\r\n"),
        ),
        (
            "Subject: hello\r\n\r\n\r\n",
            ("subject:hello\r\n", ""),
            ("Subject: hello\r\n", "\r\n"),
        ),
    ] {
        let (_, body) = split(message.as_bytes());
        for (canonicalization, expected_headers, expected_body) in [
            (DkimCanonicalization::Relaxed, relaxed_headers, relaxed_body),
            (DkimCanonicalization::Simple, simple_headers, simple_body),
        ] {
            assert_eq!(
                canonical_headers(message, canonicalization),
                expected_headers
            );
            assert_eq!(
                String::from_utf8(canonical_body(&body, canonicalization)).unwrap(),
                expected_body
            );
            // Same digest through the public streaming hasher, whatever the chunk size
            for chunk in [1, 2, 3, 5, 7, 64] {
                let hash = body_hash(&body, canonicalization, chunk);
                assert_eq!(hash.digest, sha256(expected_body.as_bytes()));
                assert_eq!(hash.canonical_length, expected_body.len() as u64);
            }
        }
    }
}

#[test]
fn empty_body_hashes() {
    // RFC 6376 §3.4.3 and §3.4.4: simple hashes one CRLF, relaxed hashes nothing
    for (canonicalization, hash) in [
        (
            DkimCanonicalization::Relaxed,
            "47DEQpj8HBSa+/TImW+5JCeuQeRkm5NMpJWZG3hSuFU=",
        ),
        (
            DkimCanonicalization::Simple,
            "frcCV1k9oG9oKj3dpUqdJg1PxRT2RSN/XKdLCPjaYaY=",
        ),
    ] {
        for body in ["\r\n", ""] {
            let digest = body_hash(body.as_bytes(), canonicalization, 64).digest;
            assert_eq!(STANDARD.encode(digest), hash);
        }
    }
}

#[test]
fn body_hasher_split_crlf_and_length_limit() {
    for canonicalization in [DkimCanonicalization::Relaxed, DkimCanonicalization::Simple] {
        let single = body_hash(b"Line1\r\nLine2\r\n", canonicalization, 64);
        let mut split = DkimBodyHasher::new(canonicalization, None);
        split.update(b"Line1\r");
        split.update(b"\nLine2\r");
        split.update(b"\n");
        assert_eq!(split.finish(), single);

        // l= counts canonicalized octets: the first 10 of the canonical body are hashed, all are
        // counted
        let body = b"Hello World! This is a test body.\r\n";
        let canonical = canonical_body(body, canonicalization);
        let mut limited = DkimBodyHasher::new(canonicalization, Some(10));
        for part in body.chunks(3) {
            limited.update(part);
        }
        let limited = limited.finish();
        assert_eq!(limited.digest, sha256(&canonical[..10]));
        assert_eq!(limited.canonical_length, canonical.len() as u64);
        // l=0 hashes nothing; a limit above the length hashes everything
        let mut zero = DkimBodyHasher::new(canonicalization, Some(0));
        zero.update(body);
        assert_eq!(zero.finish().digest, sha256(b""));
        let mut large = DkimBodyHasher::new(canonicalization, Some(u64::MAX));
        large.update(body);
        assert_eq!(large.finish(), body_hash(body, canonicalization, 64));
    }
}

#[test]
fn relaxed_body_whitespace_only_trailing_lines() {
    for (body, expected) in [
        ("</html>\r\n    \r\n", "</html>\r\n"),
        ("</html>\r\n\t\r\n", "</html>\r\n"),
        ("</html>\r\n \t \t\r\n", "</html>\r\n"),
        ("a\r\n  \r\n\t\r\n \t \r\n", "a\r\n"),
        ("a\r\n  \r\n\r\n  \r\n\r\n", "a\r\n"),
        ("a \t \r\n \r\n", "a\r\n"),
        ("a\r\n  b \r\n  \r\n", "a\r\n b\r\n"),
        ("a\r\n  ", "a\r\n"),
        ("   \r\n", ""),
        (" \t \r\n\r\n\t\r\n", ""),
        ("a\r\n  \r\nb\r\n", "a\r\n\r\nb\r\n"),
        ("a\r\n \r\n b\r\n", "a\r\n\r\n b\r\n"),
        ("\r\n  \r\nX", "\r\n\r\nX\r\n"),
    ] {
        assert_relaxed_body(body.as_bytes(), expected.as_bytes());
    }
}

#[test]
fn relaxed_body_hash_of_mail_auth_issue_62() {
    // bh= computed by dkimpy for this body (mail-auth issue #62)
    let body = concat!(
        "<!DOCTYPE html>\r\n",
        "<html>\r\n",
        "  <head>\r\n",
        "    <meta charset=\"UTF-8\">\r\n",
        "    <title>Your order has shipped</title>\r\n",
        "  </head>\r\n",
        "  <body>\r\n",
        "    <p>Hello World</a></p>\r\n",
        "    <p>Kind regards,<br>Example Shop</p>\r\n",
        "  </body>\r\n",
        "</html>\r\n",
        "    \r\n",
    );
    assert_eq!(
        STANDARD.encode(body_hash(body.as_bytes(), DkimCanonicalization::Relaxed, 64).digest),
        "mthm2ruDPxvVp7DFDs/wRVXW+DzuZhdraVTNDuO1+N0="
    );
}

#[test]
fn relaxed_body_matches_reference() {
    const TOKENS: [&[u8]; 4] = [b"a", b" ", b"\t", b"\r\n"];
    const MAX_TOKENS: u32 = 7;
    let mut body = Vec::new();
    for len in 0..=MAX_TOKENS {
        for mut index in 0..TOKENS.len().pow(len) {
            body.clear();
            for _ in 0..len {
                body.extend_from_slice(TOKENS[index % TOKENS.len()]);
                index /= TOKENS.len();
            }
            assert_relaxed_body(&body, &reference_relaxed_body(&body));
        }
    }
}

fn reference_relaxed_body(body: &[u8]) -> Vec<u8> {
    let mut out = Vec::new();
    let mut lines = body.split(|&ch| ch == b'\n').peekable();
    while let Some(line) = lines.next() {
        let line = line.strip_suffix(b"\r").unwrap_or(line);
        if lines.peek().is_none() && line.is_empty() {
            break;
        }
        let mut in_wsp = false;
        for &ch in line {
            if matches!(ch, b' ' | b'\t') {
                in_wsp = true;
            } else {
                if in_wsp {
                    out.push(b' ');
                    in_wsp = false;
                }
                out.push(ch);
            }
        }
        out.extend_from_slice(b"\r\n");
    }
    while out.ends_with(b"\r\n\r\n") {
        out.truncate(out.len() - 2);
    }
    if out == b"\r\n" {
        out.clear();
    }
    out
}

fn assert_relaxed_body(body: &[u8], expected: &[u8]) {
    assert_eq!(
        canonical_body(body, DkimCanonicalization::Relaxed),
        expected,
        "canonical body mismatch for {body:?}"
    );
    for chunk_size in 1..=body.len().max(1) {
        let hash = body_hash(body, DkimCanonicalization::Relaxed, chunk_size);
        assert_eq!(
            hash.digest,
            sha256(expected),
            "chunk size {chunk_size}, {body:?}"
        );
        assert_eq!(hash.canonical_length, expected.len() as u64);
    }
}

#[test]
fn bare_line_endings() {
    // Bare LF counts as a line end, bare CR is dropped (mail-auth behaviour, both algorithms)
    for canonicalization in [DkimCanonicalization::Relaxed, DkimCanonicalization::Simple] {
        assert_eq!(canonical_body(b"a\nb", canonicalization), b"a\r\nb\r\n");
        assert_eq!(canonical_body(b"a\rb\r\n", canonicalization), b"ab\r\n");
    }
}

#[test]
fn strip_b_value() {
    for (value, stripped) in [
        // mail-auth cases, values given without their final CRLF
        ("b=abc;h=From", "b=;h=From"),
        ("bh=B64b=;h=From;b=abc", "bh=B64b=;h=From;b="),
        ("h=From; b = abc\r\ndef\r\n; v=1", "h=From; b =; v=1"),
        // Tag names are case-sensitive (RFC 6376 §3.2): B= is not b= (mail-auth strips it)
        ("B\r\n=abc;v=1", "B\r\n=abc;v=1"),
        // Folded b= value with whitespace, trailing semicolon, no b= at all
        (
            " v=1; a=ed25519-sha256;\r\n b=/gCr\r\n Fa3b==; d=x",
            " v=1; a=ed25519-sha256;\r\n b=; d=x",
        ),
        ("v=1; b=abc;", "v=1; b=;"),
        ("v=1; bh=abc", "v=1; bh=abc"),
        ("", ""),
        ("b", "b"),
        ("b=", "b="),
        (";;", ";;"),
    ] {
        let mut out = Vec::new();
        strip_signature_value(value.as_bytes(), &mut out);
        assert_eq!(String::from_utf8(out).unwrap(), stripped, "{value:?}");
    }
}

#[test]
fn signed_data_layout_and_bound() {
    let mut relaxed = DkimHeaderCanonicalizer::new(DkimCanonicalization::Relaxed);
    relaxed
        .push_header(b"From", b" Joe <joe@example.com>")
        .unwrap();
    let data = relaxed
        .finish(b"DKIM-Signature", b" v=1; a=rsa-sha256; bh=xyz;\r\n b=abc")
        .unwrap();
    assert_eq!(
        data.as_bytes(),
        b"from:Joe <joe@example.com>\r\ndkim-signature:v=1; a=rsa-sha256; bh=xyz; b="
    );
    let mut simple = DkimHeaderCanonicalizer::new(DkimCanonicalization::Simple);
    simple.push_header(b"From", b" Joe").unwrap();
    let data = simple.finish(b"DKIM-Signature", b" b=abc; v=1").unwrap();
    assert_eq!(data.as_bytes(), b"From: Joe\r\nDKIM-Signature: b=; v=1");

    let mut big = DkimHeaderCanonicalizer::new(DkimCanonicalization::Simple);
    let value = vec![b'x'; DKIM_MAX_SIGNED_DATA_BYTES / 2];
    big.push_header(b"A", &value).unwrap();
    assert_eq!(
        big.push_header(b"B", &value).unwrap_err(),
        CryptoError::InputTooLarge
    );
    assert_eq!(
        big.finish(b"DKIM-Signature", &value).unwrap_err(),
        CryptoError::InputTooLarge
    );
}

#[test]
fn algorithm_tags() {
    assert_eq!(DkimAlgorithm::RsaSha256.as_tag(), "rsa-sha256");
    assert_eq!(DkimAlgorithm::Ed25519Sha256.as_tag(), "ed25519-sha256");
    assert_eq!(
        DkimAlgorithm::from_tag("rsa-sha256"),
        Some(DkimAlgorithm::RsaSha256)
    );
    assert_eq!(
        DkimAlgorithm::from_tag("ED25519-SHA256"),
        Some(DkimAlgorithm::Ed25519Sha256)
    );
    assert_eq!(DkimAlgorithm::from_tag("rsa-sha1"), None);
    assert_eq!(DkimAlgorithm::from_tag(""), None);
}
