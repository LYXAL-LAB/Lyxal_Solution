//! Signatures RSA et Ed25519 (P6 b, d) : vecteurs publiés (RFC 8032 §7.1, Wycheproof), clés
//! générées, import et export, découpage des erreurs.
use base64::engine::general_purpose::STANDARD;
use base64::Engine;
use lyxal_crypto::{
    CryptoError, Ed25519PublicKey, Ed25519SigningKey, RsaModulusBits, RsaPublicKey, RsaSigningKey,
    SecretBytes,
};
use serde_json::Value;

const ED25519_WYCHEPROOF: &str = include_str!("../fixtures/wycheproof/ed25519_test.json");
const RSA_WYCHEPROOF: [(&str, u32); 3] = [
    (
        include_str!("../fixtures/wycheproof/rsa_signature_2048_sha256_test.json"),
        2048,
    ),
    (
        include_str!("../fixtures/wycheproof/rsa_signature_3072_sha256_test.json"),
        3072,
    ),
    (
        include_str!("../fixtures/wycheproof/rsa_signature_4096_sha256_test.json"),
        4096,
    ),
];
const ED25519_OPENSSL_PEM: &str = include_str!("../fixtures/tls_test_only/ed25519.key.pem");
const RSA1024_PEM: &str = include_str!("../fixtures/tls_test_only/rsa1024.key.pem");
const RSA2048_PKCS1_PEM: &str = include_str!("../fixtures/tls_test_only/rsa2048.pkcs1.key.pem");
const RSA_PKCS8_B64: &str = include_str!("../fixtures/rsa2048_test_only.pkcs8.b64");
const RSA_PUBLIC_PKCS1_B64: &str = include_str!("../fixtures/rsa2048_test_only.public_pkcs1.b64");

fn secret(bytes: &[u8]) -> SecretBytes {
    SecretBytes::new(bytes.to_vec()).unwrap()
}

/// PKCS#8 v1 (RFC 8410) d'une graine Ed25519.
fn ed25519_pkcs8(seed: &[u8]) -> SecretBytes {
    let mut der = hex::decode("302e020100300506032b657004220420").unwrap();
    der.extend_from_slice(seed);
    SecretBytes::new(der).unwrap()
}

/// RFC 8032 §7.1 : TEST 1, 2, 3, 1024 et SHA(abc). Les clés publiques, messages et signatures
/// de TEST 1 à 1024 sont aussi publiés par Wycheproof (« draft-josefsson-eddsa-ed25519-02 »),
/// d'où ils sont lus ; TEST SHA(abc) est recopié de la RFC.
#[test]
fn rfc8032_test_vectors() {
    let wycheproof: Value = serde_json::from_str(ED25519_WYCHEPROOF).unwrap();
    let mut josefsson = std::collections::HashMap::new();
    for group in wycheproof["testGroups"].as_array().unwrap() {
        for test in group["tests"].as_array().unwrap() {
            let comment = test["comment"].as_str().unwrap();
            if let Some(name) = comment.strip_prefix("draft-josefsson-eddsa-ed25519-02: ") {
                josefsson.insert(
                    name.to_string(),
                    (
                        group["publicKey"]["pk"].as_str().unwrap().to_string(),
                        test["msg"].as_str().unwrap().to_string(),
                        test["sig"].as_str().unwrap().to_string(),
                    ),
                );
            }
        }
    }
    let mut vectors: Vec<(&str, String, String, String)> = [
        (
            "Test 1",
            "9d61b19deffd5a60ba844af492ec2cc44449c5697b326919703bac031cae7f60",
        ),
        (
            "Test 2",
            "4ccd089b28ff96da9db6c346ec114e0f5b8a319f35aba624da8cf6ed4fb8a6fb",
        ),
        (
            "Test 3",
            "c5aa8df43f9f837bedb7442f31dcb7b166d38535076f094b85ce3a2e0b4458f7",
        ),
        (
            "Test 1024",
            "f5e5767cf153319517630f226876b86c8160cc583bc013744c6bf255f5cc0ee5",
        ),
    ]
    .into_iter()
    .map(|(name, seed)| {
        let (public, message, signature) = josefsson[name].clone();
        (seed, public, message, signature)
    })
    .collect();
    vectors.push((
        "833fe62409237b9d62ec77587520911e9a759cec1d19755b7da901b96dca3d42",
        "ec172b93ad5e563bf4932c70e1245034c35467ef2efd4d64ebf819683467e2bf".to_string(),
        "ddaf35a193617abacc417349ae20413112e6fa4e89a97ea20a9eeee64b55d39a\
         2192992a274fc1a836ba3c23a3feebbd454d4423643ce80e2a9ac94fa54ca49f"
            .to_string(),
        "dc2a4459e7369633a52b1bf277839a00201009a3efbf3ecb69bea2186c26b589\
         09351fc9ac90b3ecfdfbc7c66431e0303dca179c138ac17ad9bef1177331a704"
            .to_string(),
    ));
    assert_eq!(vectors.len(), 5);
    for (seed, public, message, signature) in vectors {
        let key =
            Ed25519SigningKey::import_pkcs8(ed25519_pkcs8(&hex::decode(seed).unwrap())).unwrap();
        assert_eq!(hex::encode(key.public_key().as_bytes()), public);
        let message = hex::decode(message).unwrap();
        let signature = hex::decode(signature).unwrap();
        assert_eq!(key.sign(&message).unwrap().to_vec(), signature);
        let verifier = Ed25519PublicKey::from_bytes(&hex::decode(&public).unwrap()).unwrap();
        assert!(verifier.verify(&message, &signature).unwrap());
        let mut wrong = signature.clone();
        wrong[0] ^= 1;
        assert!(!verifier.verify(&message, &wrong).unwrap());
    }
}

/// Wycheproof : « valid » vérifie, « invalid » jamais ; « acceptable » est noté sans exigence.
/// Une signature de longueur fausse est une erreur de format (aucune n'est acceptée).
fn expect(result: &str, verdict: Result<bool, CryptoError>, id: u64) {
    match result {
        "valid" => assert_eq!(verdict, Ok(true), "tcId {id}"),
        "invalid" => assert!(
            matches!(
                verdict,
                Ok(false) | Err(CryptoError::InvalidSignatureEncoding)
            ),
            "tcId {id}: {verdict:?}"
        ),
        "acceptable" => assert!(
            matches!(verdict, Ok(_) | Err(CryptoError::InvalidSignatureEncoding)),
            "tcId {id}: {verdict:?}"
        ),
        other => panic!("unknown result {other}"),
    }
}

#[test]
fn wycheproof_ed25519() {
    let file: Value = serde_json::from_str(ED25519_WYCHEPROOF).unwrap();
    let mut count = 0;
    for group in file["testGroups"].as_array().unwrap() {
        let public = hex::decode(group["publicKey"]["pk"].as_str().unwrap()).unwrap();
        let key = Ed25519PublicKey::from_bytes(&public).unwrap();
        for test in group["tests"].as_array().unwrap() {
            let message = hex::decode(test["msg"].as_str().unwrap()).unwrap();
            let signature = hex::decode(test["sig"].as_str().unwrap()).unwrap();
            expect(
                test["result"].as_str().unwrap(),
                key.verify(&message, &signature),
                test["tcId"].as_u64().unwrap(),
            );
            count += 1;
        }
    }
    assert_eq!(count, file["numberOfTests"].as_u64().unwrap());
}

#[test]
fn wycheproof_rsa_pkcs1_sha256() {
    for (text, bits) in RSA_WYCHEPROOF {
        let file: Value = serde_json::from_str(text).unwrap();
        let mut count = 0;
        for group in file["testGroups"].as_array().unwrap() {
            let pkcs1 = hex::decode(group["publicKeyAsn"].as_str().unwrap()).unwrap();
            let spki = hex::decode(group["publicKeyDer"].as_str().unwrap()).unwrap();
            let key = RsaPublicKey::from_pkcs1_der(&pkcs1).unwrap();
            assert_eq!(RsaPublicKey::from_spki_der(&spki).unwrap(), key);
            assert_eq!(key.to_spki_der(), spki);
            assert_eq!(key.modulus_bits(), bits);
            for test in group["tests"].as_array().unwrap() {
                let message = hex::decode(test["msg"].as_str().unwrap()).unwrap();
                let signature = hex::decode(test["sig"].as_str().unwrap()).unwrap();
                expect(
                    test["result"].as_str().unwrap(),
                    key.verify_rs256(&message, &signature),
                    test["tcId"].as_u64().unwrap(),
                );
                count += 1;
            }
        }
        assert_eq!(count, file["numberOfTests"].as_u64().unwrap());
    }
}

#[test]
fn generated_keys_round_trip() {
    let key = RsaSigningKey::generate(RsaModulusBits::Rsa2048).unwrap();
    assert_eq!(key.modulus_bits(), 2048);
    let public = key.public_key();
    assert_eq!(public.modulus_bits(), 2048);
    let signature = key.sign_rs256(b"data").unwrap();
    assert_eq!(signature.len(), 256);
    assert!(public.verify_rs256(b"data", &signature).unwrap());
    assert!(!public.verify_rs256(b"other", &signature).unwrap());
    // Export pour le coffre-fort, import : même clé, signatures identiques (déterministes)
    let imported = RsaSigningKey::import_pkcs8(key.export_pkcs8()).unwrap();
    assert_eq!(imported.public_key(), public);
    assert_eq!(imported.sign_rs256(b"data").unwrap(), signature);
    assert_eq!(
        RsaPublicKey::from_spki_der(&public.to_spki_der()).unwrap(),
        public
    );
    assert_eq!(format!("{key:?}"), "RsaSigningKey([REDACTED])");

    let ed = Ed25519SigningKey::generate().unwrap();
    let signature = ed.sign(b"data").unwrap();
    assert!(ed.public_key().verify(b"data", &signature).unwrap());
    let imported = Ed25519SigningKey::import_pkcs8(ed.export_pkcs8()).unwrap();
    assert_eq!(imported.public_key(), ed.public_key());
    assert_eq!(imported.sign(b"data").unwrap(), signature);
    assert_ne!(
        Ed25519SigningKey::generate().unwrap().public_key(),
        ed.public_key()
    );
    assert_eq!(format!("{ed:?}"), "Ed25519SigningKey([REDACTED])");
}

#[test]
fn generated_large_rsa_keys() {
    for (bits, expected) in [
        (RsaModulusBits::Rsa3072, 3072),
        (RsaModulusBits::Rsa4096, 4096),
    ] {
        let key = RsaSigningKey::generate(bits).unwrap();
        assert_eq!(key.modulus_bits(), expected);
        let signature = key.sign_rs256(b"data").unwrap();
        assert!(key.public_key().verify_rs256(b"data", &signature).unwrap());
    }
}

#[test]
fn imports_of_foreign_and_weak_keys() {
    // PKCS#8 v1 d'`openssl genpkey -algorithm ED25519`, en PEM
    let key = Ed25519SigningKey::import_pkcs8(secret(ED25519_OPENSSL_PEM.as_bytes())).unwrap();
    // Export en PKCS#8 v2 (avec la clé publique), relu à l'identique
    let again = Ed25519SigningKey::import_pkcs8(key.export_pkcs8()).unwrap();
    assert_eq!(again.public_key(), key.public_key());
    // RSA de 1024 bits : refusée pour signer dès sa lecture par AWS-LC (comme par ring)
    assert_eq!(
        RsaSigningKey::import_pkcs8(secret(RSA1024_PEM.as_bytes())).unwrap_err(),
        CryptoError::InvalidKeyEncoding
    );
    // PKCS#1 (« RSA PRIVATE KEY ») refusé ; clés d'un autre algorithme refusées
    assert_eq!(
        RsaSigningKey::import_pkcs8(secret(RSA2048_PKCS1_PEM.as_bytes())).unwrap_err(),
        CryptoError::InvalidKeyEncoding
    );
    let rsa = STANDARD.decode(RSA_PKCS8_B64.trim()).unwrap();
    assert_eq!(
        Ed25519SigningKey::import_pkcs8(secret(&rsa)).unwrap_err(),
        CryptoError::InvalidKeyEncoding
    );
    assert_eq!(
        RsaSigningKey::import_pkcs8(key.export_pkcs8()).unwrap_err(),
        CryptoError::InvalidKeyEncoding
    );
    // PKCS#8 v2 dont la clé publique ne correspond pas à la graine
    let mut v2 = key.export_pkcs8().expose_secret().to_vec();
    let last = v2.len() - 1;
    v2[last] ^= 1;
    assert_eq!(
        Ed25519SigningKey::import_pkcs8(secret(&v2)).unwrap_err(),
        CryptoError::InvalidKeyEncoding
    );
    for bad in [b"".to_vec(), b"not a key".to_vec(), vec![b'A'; 16 * 1024]] {
        assert_eq!(
            Ed25519SigningKey::import_pkcs8(secret(&bad)).unwrap_err(),
            CryptoError::InvalidKeyEncoding
        );
    }
    assert_eq!(
        Ed25519SigningKey::import_pkcs8(secret(&vec![b'A'; 16 * 1024 + 1])).unwrap_err(),
        CryptoError::InputTooLarge
    );
}

#[test]
fn public_key_forms_and_verification_errors() {
    let pkcs1 = STANDARD.decode(RSA_PUBLIC_PKCS1_B64.trim()).unwrap();
    let key = RsaPublicKey::from_pkcs1_der(&pkcs1).unwrap();
    let spki = key.to_spki_der();
    // Chaque lecture exige sa forme
    assert_eq!(
        RsaPublicKey::from_spki_der(&pkcs1).unwrap_err(),
        CryptoError::InvalidKeyEncoding
    );
    assert_eq!(
        RsaPublicKey::from_pkcs1_der(&spki).unwrap_err(),
        CryptoError::InvalidKeyEncoding
    );
    for bad in [
        &[][..],
        &[0x30][..],
        &[0x30, 0x80][..],
        &spki[..20],
        b"junk",
    ] {
        assert_eq!(
            RsaPublicKey::from_spki_der(bad).unwrap_err(),
            CryptoError::InvalidKeyEncoding
        );
    }
    assert_eq!(
        RsaPublicKey::from_spki_der(&[0x30; 4096]).unwrap_err(),
        CryptoError::InputTooLarge
    );
    // SubjectPublicKeyInfo d'une clé Ed25519 : pas une clé RSA
    let ed_spki = hex::decode(
        "302a300506032b65700321007d4d0e7f6153a69b6242b522abbee685fda4420f8834b108c3bdae369ef549fa",
    )
    .unwrap();
    assert_eq!(
        RsaPublicKey::from_spki_der(&ed_spki).unwrap_err(),
        CryptoError::InvalidKeyEncoding
    );
    // Longueur de signature fausse : erreur ; clé trop courte pour RS256 : KeyTooWeak
    assert_eq!(
        key.verify_rs256(b"data", &[0; 255]).unwrap_err(),
        CryptoError::InvalidSignatureEncoding
    );
    let weak = RsaPublicKey::from_spki_der(
        &hex::decode(include_str!("../fixtures/dkim/rsa768_test_only.spki.hex").trim()).unwrap(),
    )
    .unwrap();
    assert_eq!(weak.modulus_bits(), 768);
    assert_eq!(
        weak.verify_rs256(b"data", &[0; 96]).unwrap_err(),
        CryptoError::KeyTooWeak
    );
    let large = RsaPublicKey::from_spki_der(
        &hex::decode(include_str!("../fixtures/dkim/rsa6144_test_only.spki.hex").trim()).unwrap(),
    )
    .unwrap();
    assert_eq!(large.modulus_bits(), 6144);
    assert_eq!(large.verify_rs256(b"data", &[0; 768]), Ok(false));
    // Ed25519 : clé de 32 octets exactement, signature de 64 octets exactement
    for length in [0, 31, 33] {
        assert_eq!(
            Ed25519PublicKey::from_bytes(&vec![1; length]).unwrap_err(),
            CryptoError::InvalidKeyEncoding
        );
    }
    let ed = Ed25519SigningKey::generate().unwrap().public_key();
    for length in [0, 63, 65] {
        assert_eq!(
            ed.verify(b"data", &vec![0; length]).unwrap_err(),
            CryptoError::InvalidSignatureEncoding
        );
    }
    assert!(!ed.verify(b"data", &[0; 64]).unwrap());
}
