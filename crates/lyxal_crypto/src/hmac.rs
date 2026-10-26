use hmac::{Hmac, Mac};
use sha2::Sha256;

type HmacSha256 = Hmac<Sha256>;

/// Calcule la signature d'authentification de message HMAC-SHA256 (32 octets).
pub fn sign_hmac_sha256(key: &[u8], data: &[u8]) -> [u8; 32] {
    let mut mac = HmacSha256::new_from_slice(key).expect("HMAC can take key of any size");
    mac.update(data);
    mac.finalize().into_bytes().into()
}

/// Calcule la signature HMAC-SHA256 sous forme de chaîne hexadécimale minuscule (64 caractères).
pub fn sign_hmac_sha256_hex(key: &[u8], data: &[u8]) -> String {
    let tag = sign_hmac_sha256(key, data);
    hex::encode(tag)
}

/// Vérifie une signature HMAC-SHA256 en utilisant l'API native en temps constant de la bibliothèque `hmac`.
///
/// Renvoie `true` si le tag correspond exactement, `false` sinon (sans fuite par canal auxiliaire).
pub fn verify_hmac_sha256(key: &[u8], data: &[u8], expected_tag: &[u8]) -> bool {
    let mut mac = match HmacSha256::new_from_slice(key) {
        Ok(m) => m,
        Err(_) => return false,
    };
    mac.update(data);
    mac.verify_slice(expected_tag).is_ok()
}

/// Vérifie une signature HMAC-SHA256 encodée en hexadécimal en temps constant.
pub fn verify_hmac_sha256_hex(key: &[u8], data: &[u8], expected_hex: &str) -> bool {
    let expected_tag = match hex::decode(expected_hex.trim()) {
        Ok(t) => t,
        Err(_) => return false,
    };
    verify_hmac_sha256(key, data, &expected_tag)
}
