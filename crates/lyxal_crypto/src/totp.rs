//! TOTP (RFC 6238) for authenticator applications: shared secrets, codes, verification and
//! enrolment URIs. HMAC-SHA1 is used only here, as required by RFC 6238 and authenticator apps.
use crate::hmac::sign_bytes;
use crate::{CryptoError, SecretBytes, SecretString};
use hmac::{Hmac, Mac};
use rand_core::{OsRng, RngCore};
use sha1::Sha1;
use std::fmt;
use subtle::{ConditionallySelectable, ConstantTimeEq};
use zeroize::{ZeroizeOnDrop, Zeroizing};

/// Smallest imported secret (128 bits, RFC 4226 §4 R6).
pub const MIN_TOTP_SECRET_BYTES: usize = 16;
/// Largest imported secret.
pub const MAX_TOTP_SECRET_BYTES: usize = 64;
/// Largest accepted verification window, in steps on each side of the current step.
pub const MAX_TOTP_WINDOW: u8 = 2;
/// Largest issuer or account name accepted in an enrolment URI, in UTF-8 bytes.
pub const MAX_TOTP_LABEL_BYTES: usize = 256;

/// HMAC algorithm of a TOTP (RFC 6238 §1.2).
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum TotpAlgorithm {
    /// HMAC-SHA1, the setting every authenticator application supports.
    Sha1,
    /// HMAC-SHA256.
    Sha256,
}
impl TotpAlgorithm {
    fn uri_name(self) -> &'static str {
        match self {
            Self::Sha1 => "SHA1",
            Self::Sha256 => "SHA256",
        }
    }
    fn generated_secret_bytes(self) -> usize {
        match self {
            Self::Sha1 => 20,
            Self::Sha256 => 32,
        }
    }
}

/// TOTP settings. `Default` is SHA-1, 6 digits, 30-second steps (authenticator applications).
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct TotpConfig {
    /// HMAC algorithm.
    pub algorithm: TotpAlgorithm,
    /// Code length, 6 to 8 digits.
    pub digits: u8,
    /// Step length, 15 to 120 seconds.
    pub step_seconds: u32,
}
impl Default for TotpConfig {
    fn default() -> Self {
        Self {
            algorithm: TotpAlgorithm::Sha1,
            digits: 6,
            step_seconds: 30,
        }
    }
}
impl TotpConfig {
    fn validate(&self) -> Result<(), CryptoError> {
        if !(6..=8).contains(&self.digits) || !(15..=120).contains(&self.step_seconds) {
            return Err(CryptoError::InvalidTotpParameter);
        }
        Ok(())
    }
}

/// Shared TOTP secret: wiped on drop, redacted `Debug`, raw access only via `expose_secret`.
pub struct TotpSecret {
    bytes: SecretBytes,
}
impl TotpSecret {
    /// Fresh secret from the OS generator: 20 bytes for SHA-1, 32 for SHA-256.
    pub fn generate(config: &TotpConfig) -> Result<Self, CryptoError> {
        config.validate()?;
        Self::generate_with(config, &mut OsRng)
    }
    fn generate_with(config: &TotpConfig, rng: &mut impl RngCore) -> Result<Self, CryptoError> {
        let mut bytes = SecretBytes::zeroed(config.algorithm.generated_secret_bytes())?;
        rng.try_fill_bytes(&mut bytes.inner)
            .map_err(|_| CryptoError::RandomUnavailable)?;
        Ok(Self { bytes })
    }
    /// Adopt a stored secret of 16 to 64 bytes.
    pub fn import(bytes: SecretBytes) -> Result<Self, CryptoError> {
        if !(MIN_TOTP_SECRET_BYTES..=MAX_TOTP_SECRET_BYTES).contains(&bytes.len()) {
            return Err(CryptoError::InvalidTotpParameter);
        }
        Ok(Self { bytes })
    }
    /// Deliberate raw access, to store the secret encrypted (`CryptoEngine::seal`).
    pub fn expose_secret(&self) -> &[u8] {
        self.bytes.expose_secret()
    }
    /// Unpadded uppercase RFC 4648 Base32, as shown to the user and placed in the QR code.
    pub fn to_base32(&self) -> SecretString {
        SecretString {
            inner: base32(self.bytes.expose_secret()),
        }
    }
}
impl fmt::Debug for TotpSecret {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str("TotpSecret([REDACTED])")
    }
}
impl ZeroizeOnDrop for TotpSecret {}

/// Expected code at `unix_seconds` (tests and display).
pub fn totp_generate(
    secret: &TotpSecret,
    config: &TotpConfig,
    unix_seconds: u64,
) -> Result<SecretString, CryptoError> {
    config.validate()?;
    let code = hotp(
        secret,
        config,
        unix_seconds / u64::from(config.step_seconds),
    )?;
    Ok(SecretString { inner: code })
}

/// Checks `code` within ±`window` steps (0 to 2) of the step at `unix_seconds`.
///
/// Returns the accepted step number, which the caller stores to refuse reuse of the same step,
/// or `None` on mismatch. A code of the wrong length or with non-digit characters is a mismatch.
/// Every candidate step is computed and compared in constant time.
pub fn totp_verify(
    secret: &TotpSecret,
    config: &TotpConfig,
    code: &str,
    unix_seconds: u64,
    window: u8,
) -> Result<Option<u64>, CryptoError> {
    config.validate()?;
    if window > MAX_TOTP_WINDOW {
        return Err(CryptoError::InvalidTotpParameter);
    }
    if code.len() != usize::from(config.digits) || !code.bytes().all(|b| b.is_ascii_digit()) {
        return Ok(None);
    }
    let current = unix_seconds / u64::from(config.step_seconds);
    let window = u64::from(window);
    let mut found = subtle::Choice::from(0u8);
    let mut accepted = 0u64;
    for step in current.saturating_sub(window)..=current.saturating_add(window) {
        let expected = hotp(secret, config, step)?;
        let matches = expected.as_bytes().ct_eq(code.as_bytes()) & !found;
        accepted.conditional_assign(&step, matches);
        found |= matches;
    }
    Ok(bool::from(found).then_some(accepted))
}

/// `otpauth://totp/...` enrolment URI (Key URI Format), issuer and account percent-encoded.
///
/// Issuer and account: 1 to 256 bytes, no `:` and no control characters.
pub fn totp_uri(
    secret: &TotpSecret,
    config: &TotpConfig,
    issuer: &str,
    account: &str,
) -> Result<SecretString, CryptoError> {
    config.validate()?;
    check_label(issuer)?;
    check_label(account)?;
    let encoded_secret = base32(secret.expose_secret());
    let mut uri = Zeroizing::new(String::new());
    uri.try_reserve_exact(64 + encoded_secret.len() + 9 * (issuer.len() + account.len()))
        .map_err(|_| CryptoError::AllocationFailed)?;
    uri.push_str("otpauth://totp/");
    percent_encode(issuer, &mut uri);
    uri.push(':');
    percent_encode(account, &mut uri);
    uri.push_str("?secret=");
    uri.push_str(&encoded_secret);
    uri.push_str("&issuer=");
    percent_encode(issuer, &mut uri);
    uri.push_str("&algorithm=");
    uri.push_str(config.algorithm.uri_name());
    uri.push_str("&digits=");
    uri.push_str(&config.digits.to_string());
    uri.push_str("&period=");
    uri.push_str(&config.step_seconds.to_string());
    Ok(SecretString { inner: uri })
}

/// HOTP value (RFC 4226 §5.3) for one counter, zero-padded to `digits`.
fn hotp(
    secret: &TotpSecret,
    config: &TotpConfig,
    counter: u64,
) -> Result<Zeroizing<String>, CryptoError> {
    let message = counter.to_be_bytes();
    let key = secret.expose_secret();
    let mac: Zeroizing<Vec<u8>> = Zeroizing::new(match config.algorithm {
        TotpAlgorithm::Sha1 => {
            let mut mac =
                Hmac::<Sha1>::new_from_slice(key).map_err(|_| CryptoError::EncryptionFailed)?;
            mac.update(&message);
            mac.finalize().into_bytes().to_vec()
        }
        TotpAlgorithm::Sha256 => sign_bytes(key, &message)?.to_vec(),
    });
    let offset = usize::from(mac[mac.len() - 1] & 0x0f);
    let binary = (u32::from(mac[offset] & 0x7f) << 24)
        | (u32::from(mac[offset + 1]) << 16)
        | (u32::from(mac[offset + 2]) << 8)
        | u32::from(mac[offset + 3]);
    let value = binary % 10u32.pow(u32::from(config.digits));
    let digits = usize::from(config.digits);
    let mut code = Zeroizing::new(String::with_capacity(digits));
    let mut divisor = 10u32.pow(u32::from(config.digits) - 1);
    while divisor > 0 {
        code.push(char::from(b'0' + ((value / divisor) % 10) as u8));
        divisor /= 10;
    }
    Ok(code)
}

fn check_label(label: &str) -> Result<(), CryptoError> {
    if label.is_empty()
        || label.len() > MAX_TOTP_LABEL_BYTES
        || label.chars().any(|c| c == ':' || c.is_control())
    {
        return Err(CryptoError::InvalidTotpParameter);
    }
    Ok(())
}

/// Percent-encodes every byte except RFC 3986 unreserved characters.
fn percent_encode(text: &str, out: &mut String) {
    const HEX: &[u8; 16] = b"0123456789ABCDEF";
    for byte in text.bytes() {
        if byte.is_ascii_alphanumeric() || matches!(byte, b'-' | b'.' | b'_' | b'~') {
            out.push(char::from(byte));
        } else {
            out.push('%');
            out.push(char::from(HEX[usize::from(byte >> 4)]));
            out.push(char::from(HEX[usize::from(byte & 0x0f)]));
        }
    }
}

/// Unpadded uppercase RFC 4648 Base32.
fn base32(bytes: &[u8]) -> Zeroizing<String> {
    const ALPHABET: &[u8; 32] = b"ABCDEFGHIJKLMNOPQRSTUVWXYZ234567";
    let mut out = Zeroizing::new(String::with_capacity(bytes.len().div_ceil(5) * 8));
    let mut buffer = 0u16;
    let mut bits = 0u8;
    for &byte in bytes {
        buffer = (buffer << 8) | u16::from(byte);
        bits += 8;
        while bits >= 5 {
            bits -= 5;
            out.push(char::from(ALPHABET[usize::from((buffer >> bits) & 0x1f)]));
        }
        buffer &= (1 << bits) - 1;
    }
    if bits > 0 {
        out.push(char::from(
            ALPHABET[usize::from((buffer << (5 - bits)) & 0x1f)],
        ));
    }
    out
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn base32_matches_rfc4648_vectors() {
        let cases: [(&[u8], &str); 7] = [
            (b"", ""),
            (b"f", "MY"),
            (b"fo", "MZXQ"),
            (b"foo", "MZXW6"),
            (b"foob", "MZXW6YQ"),
            (b"fooba", "MZXW6YTB"),
            (b"foobar", "MZXW6YTBOI"),
        ];
        for (input, expected) in cases {
            assert_eq!(base32(input).as_str(), expected);
        }
    }

    #[test]
    fn generation_fails_closed_when_randomness_is_unavailable() {
        struct Failing;
        impl RngCore for Failing {
            fn next_u32(&mut self) -> u32 {
                0
            }
            fn next_u64(&mut self) -> u64 {
                0
            }
            fn fill_bytes(&mut self, _: &mut [u8]) {}
            fn try_fill_bytes(&mut self, bytes: &mut [u8]) -> Result<(), rand_core::Error> {
                bytes.fill(0x41);
                Err(rand_core::Error::from(
                    std::num::NonZeroU32::new(rand_core::Error::CUSTOM_START).unwrap(),
                ))
            }
        }
        assert!(matches!(
            TotpSecret::generate_with(&TotpConfig::default(), &mut Failing),
            Err(CryptoError::RandomUnavailable)
        ));
    }
}
