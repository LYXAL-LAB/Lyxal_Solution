// RFC 8291 Appendix A vector, and a round trip decrypted as a browser would (ECDH with the
// browser's private key, then RFC 8291 derivation and RFC 8188 record), written here
// independently of `encrypt_with`.
use super::*;
use base64::engine::general_purpose::URL_SAFE_NO_PAD;
use base64::Engine;
use aws_lc_rs::agreement::PublicKey;

fn b64url(text: &str) -> Vec<u8> {
    URL_SAFE_NO_PAD.decode(text).unwrap()
}

fn array<const N: usize>(bytes: &[u8]) -> [u8; N] {
    bytes.try_into().unwrap()
}

#[test]
fn rfc8291_appendix_a_vector() {
    let plaintext = b64url("V2hlbiBJIGdyb3cgdXAsIEkgd2FudCB0byBiZSBhIHdhdGVybWVsb24");
    assert_eq!(plaintext, b"When I grow up, I want to be a watermelon");
    let as_public = array::<65>(&b64url(
        "BP4z9KsN6nGRTbVYI_c7VJSPQTBtkgcy27mlmlMoZIIgDll6e3vCYLocInmYWAmS6TlzAC8wEqKK6PBru3jl7A8",
    ));
    let ua_public = array::<65>(&b64url(
        "BCVxsr7N_eNgVRqvHtD0zTZsEc6-VV-JvLexhqUzORcxaOzi6-AYWXvTBHm4bjyPjs7Vd8pZGH6SRpkNtoIAiw4",
    ));
    let salt = array::<16>(&b64url("DGv6ra1nlYgDCS1FRnbzlw"));
    let auth = array::<16>(&b64url("BTBZMqHH6r4Tts7J_aSIgg"));
    // ECDH(as_private, ua_public), given by the RFC (the ephemeral private key is injected)
    let ecdh = b64url("kyrL1jIIOHEzg3sM2ZWRHDRB62YACZhhSlknJ672kSs");
    // Intermediate values of the RFC
    let mut ikm = [0u8; 32];
    expand(
        &auth,
        &ecdh,
        &[b"WebPush: info\0", &ua_public, &as_public],
        &mut ikm,
    )
    .unwrap();
    assert_eq!(ikm.to_vec(), b64url("S4lYMb_L0FxCeq0WhDx813KgSYqU26kOyzWUdsXYyrg"));
    let mut cek = [0u8; 16];
    expand(&salt, &ikm, &[b"Content-Encoding: aes128gcm\0"], &mut cek).unwrap();
    assert_eq!(cek.to_vec(), b64url("oIhVW04MRdy2XN9CiKLxTg"));
    let mut nonce = [0u8; 12];
    expand(&salt, &ikm, &[b"Content-Encoding: nonce\0"], &mut nonce).unwrap();
    assert_eq!(nonce.to_vec(), b64url("4h_95klXJ5E_qnoN"));
    // Final message: header then the single record
    let body = encrypt_with(&ecdh, &as_public, &ua_public, &auth, &salt, &plaintext).unwrap();
    assert_eq!(
        URL_SAFE_NO_PAD.encode(&body),
        "DGv6ra1nlYgDCS1FRnbzlwAAEABBBP4z9KsN6nGRTbVYI_c7VJSPQTBtkgcy27mlmlMoZIIgDll6e3vCYLocInmYWAmS6TlzAC8wEqKK6PBru3jl7A_yl95bQpu6cVPTpK4Mqgkf1CXztLVBSt2Ks3oZwbuwXPXLWyouBWLVWGNWQexSgSxsj_Qulcy4a-fN"
    );
    assert_eq!(
        URL_SAFE_NO_PAD.encode(&body[86..]),
        "8pfeW0KbunFT06SuDKoJH9Ql87S1QUrdirN6GcG7sFz1y1sqLgVi1VhjVkHsUoEsbI_0LpXMuGvnzQ"
    );
    assert_eq!(body.len(), plaintext.len() + WEBPUSH_OVERHEAD_BYTES);
}

/// Decryption by the browser: ECDH with its private key and the key id of the header, RFC 8291
/// derivation, AES-128-GCM opening, delimiter `0x02` of the last record.
fn browser_decrypt(ua_private: EphemeralPrivateKey, ua_public: &[u8; 65], auth: &[u8; 16], body: &[u8]) -> Vec<u8> {
    let salt = &body[..16];
    assert_eq!(u32::from_be_bytes(array::<4>(&body[16..20])), 4096);
    assert_eq!(body[20], 65);
    let as_public = array::<65>(&body[21..86]);
    let ecdh = agree_ephemeral(
        ua_private,
        UnparsedPublicKey::new(&ECDH_P256, &as_public),
        (),
        |shared| Ok(shared.to_vec()),
    )
    .unwrap();
    let mut info = b"WebPush: info\0".to_vec();
    info.extend_from_slice(ua_public);
    info.extend_from_slice(&as_public);
    let prk = Salt::new(HKDF_SHA256, auth).extract(&ecdh);
    let mut ikm = [0u8; 32];
    prk.expand(&[&info], Len(32)).unwrap().fill(&mut ikm).unwrap();
    let prk = Salt::new(HKDF_SHA256, salt).extract(&ikm);
    let mut cek = [0u8; 16];
    prk.expand(&[b"Content-Encoding: aes128gcm\0"], Len(16))
        .unwrap()
        .fill(&mut cek)
        .unwrap();
    let mut nonce = [0u8; 12];
    prk.expand(&[b"Content-Encoding: nonce\0"], Len(12))
        .unwrap()
        .fill(&mut nonce)
        .unwrap();
    let key = LessSafeKey::new(UnboundKey::new(&AES_128_GCM, &cek).unwrap());
    let mut record = body[86..].to_vec();
    let opened = key
        .open_in_place(Nonce::assume_unique_for_key(nonce), Aad::empty(), &mut record)
        .unwrap();
    assert_eq!(opened.last(), Some(&0x02));
    opened[..opened.len() - 1].to_vec()
}

fn browser() -> (EphemeralPrivateKey, [u8; 65]) {
    let private = EphemeralPrivateKey::generate(&ECDH_P256, &SystemRandom::new()).unwrap();
    let public: PublicKey = private.compute_public_key().unwrap();
    let public = array::<65>(public.as_ref());
    (private, public)
}

#[test]
fn a_browser_decrypts_the_message() {
    let (private, public) = browser();
    let auth = [7u8; 16];
    let message = br#"{"title":"Devis","body":"Votre devis est pret"}"#;
    let body = webpush_encrypt(&public, &auth, message).unwrap();
    assert_eq!(body.len(), message.len() + WEBPUSH_OVERHEAD_BYTES);
    assert_eq!(browser_decrypt(private, &public, &auth, &body), message);
    // Fresh salt and ephemeral key for every message
    let again = webpush_encrypt(&public, &auth, message).unwrap();
    assert_ne!(body[..86], again[..86]);
}

#[test]
fn bounds_and_invalid_browser_keys() {
    let (private, public) = browser();
    let auth = [1u8; 16];
    let largest = vec![b'a'; WEBPUSH_MAX_PLAINTEXT_BYTES];
    let body = webpush_encrypt(&public, &auth, &largest).unwrap();
    assert_eq!(body.len(), 86 + 4096);
    assert_eq!(browser_decrypt(private, &public, &auth, &body), largest);
    assert_eq!(
        webpush_encrypt(&public, &auth, &vec![0; WEBPUSH_MAX_PLAINTEXT_BYTES + 1]).unwrap_err(),
        CryptoError::InputTooLarge
    );
    // Not a point of the curve, or not an uncompressed point
    let mut off_curve = public;
    off_curve[64] ^= 1;
    assert_eq!(
        webpush_encrypt(&off_curve, &auth, b"x").unwrap_err(),
        CryptoError::InvalidKeyEncoding
    );
    let mut compressed = public;
    compressed[0] = 0x02;
    assert_eq!(
        webpush_encrypt(&compressed, &auth, b"x").unwrap_err(),
        CryptoError::InvalidKeyEncoding
    );
    // Empty message: delimiter and tag only
    assert_eq!(
        webpush_encrypt(&public, &auth, b"").unwrap().len(),
        WEBPUSH_OVERHEAD_BYTES
    );
}
