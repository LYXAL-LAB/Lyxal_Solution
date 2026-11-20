#![no_main]
//! Hostile `p=` values (decoded) and signatures: no panic; a key that reads verifies only
//! with the algorithm of its type, and a signature of the wrong length is a format error.
//! Input: first byte = key type and algorithm, then `p=` bytes, a 0x00 separator, the signature.
use libfuzzer_sys::fuzz_target;
use lyxal_crypto::*;
use std::sync::OnceLock;

fn data() -> &'static DkimSignedData {
    static DATA: OnceLock<DkimSignedData> = OnceLock::new();
    DATA.get_or_init(|| {
        let mut canonicalizer = DkimHeaderCanonicalizer::new(DkimCanonicalization::Relaxed);
        canonicalizer
            .push_header(b"From", b" fuzz@example.test")
            .unwrap();
        canonicalizer
            .finish(b"DKIM-Signature", b" v=1; a=rsa-sha256; b=")
            .unwrap()
    })
}

fuzz_target!(|input: &[u8]| {
    let Some((&options, rest)) = input.split_first() else {
        return;
    };
    let (p, signature) = match rest.iter().position(|&b| b == 0) {
        Some(split) => (&rest[..split], &rest[split + 1..]),
        None => (rest, &[][..]),
    };
    let key_type = if options & 1 == 0 {
        DkimKeyType::Rsa
    } else {
        DkimKeyType::Ed25519
    };
    let algorithm = if options & 2 == 0 {
        DkimAlgorithm::RsaSha256
    } else {
        DkimAlgorithm::Ed25519Sha256
    };
    // Also exercise the generic readers of the same bytes.
    let _ = RsaPublicKey::from_spki_der(p);
    let _ = RsaPublicKey::from_pkcs1_der(p);
    let Ok(key) = DkimPublicKey::from_record(key_type, p) else {
        return;
    };
    assert_eq!(key.key_type(), key_type);
    match key.verify(algorithm, data(), signature) {
        Ok(_) => {}
        Err(CryptoError::AlgorithmMismatch) => {
            assert_ne!(
                matches!(algorithm, DkimAlgorithm::RsaSha256),
                matches!(key_type, DkimKeyType::Rsa)
            );
        }
        Err(CryptoError::InvalidSignatureEncoding) => {}
        Err(other) => panic!("unexpected error {other:?}"),
    }
});
