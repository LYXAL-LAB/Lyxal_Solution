//! Bounded PHC contracts, Argon2id v19, and an explicitly wiped Argon2 workspace.
use crate::{CryptoError, SecretString};
use argon2::{Algorithm, Argon2, Block, Params, Version};
use base64::{engine::general_purpose::STANDARD_NO_PAD, Engine};
use rand_core::{CryptoRng, OsRng, RngCore};
use std::fmt::{self, Write};
use subtle::ConstantTimeEq;
use zeroize::{ZeroizeOnDrop, Zeroizing};
/// Password admission limit in UTF-8 bytes; minimum length remains a host policy.
pub const MAX_PASSWORD_BYTES: usize = 1024;
/// Maximum parsed PHC length before any parsing/copy/allocation.
pub const MAX_PHC_BYTES: usize = 512;
#[derive(Clone, Copy)]
struct Costs {
    m: u32,
    t: u32,
    p: u32,
}
struct Parsed {
    costs: Costs,
    salt: Zeroizing<[u8; 32]>,
    salt_len: usize,
    digest: Zeroizing<[u8; 32]>,
}
/// An opaque validated PHC. Borrowed input copies remain the host's responsibility.
///
/// ```compile_fail
/// use lyxal_crypto::PasswordHash;
/// fn disclose(hash: &PasswordHash) { println!("{}", hash); }
/// ```
pub struct PasswordHash {
    phc: SecretString,
    costs: Costs,
}
impl PasswordHash {
    /// Validate algorithm/version, fields, salt/digest and costs WITHOUT running Argon2.
    pub fn parse(encoded: &str) -> Result<Self, CryptoError> {
        let parsed = parse_phc(encoded)?;
        Ok(Self {
            phc: SecretString::new(encoded.to_owned())?,
            costs: parsed.costs,
        })
    }
    /// Explicit borrowed export for persistence; no implicit Display/serialization exists.
    pub fn expose_phc(&self) -> &str {
        self.phc.expose_secret()
    }
    /// Upgrade weaker or incomparable accepted costs; do not automatically downgrade stronger costs.
    pub fn needs_rehash(&self) -> bool {
        self.costs.m < 65536 || self.costs.t < 3 || self.costs.p < 1
    }
}
impl fmt::Debug for PasswordHash {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str("PasswordHash([REDACTED])")
    }
}
impl ZeroizeOnDrop for PasswordHash {}
/// Verification result without plaintext or PHC diagnostics.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum PasswordVerification {
    /// A valid, bounded hash did not match this password.
    Mismatch,
    /// Password matched; any rehash is a separate host persistence operation.
    Verified {
        /// Whether the matching hash should be upgraded by the host.
        needs_rehash: bool,
    },
}
fn number(raw: &str) -> Result<u32, CryptoError> {
    if raw.is_empty()
        || raw.len() > 10
        || (raw.len() > 1 && raw.starts_with('0'))
        || !raw.bytes().all(|b| b.is_ascii_digit())
    {
        return Err(CryptoError::InvalidPasswordHash);
    }
    raw.parse().map_err(|_| CryptoError::InvalidPasswordHash)
}
fn parse_phc(encoded: &str) -> Result<Parsed, CryptoError> {
    if encoded.len() > MAX_PHC_BYTES {
        return Err(CryptoError::InputTooLarge);
    }
    let mut parts = encoded.split('$');
    let (
        Some(""),
        Some("argon2id"),
        Some("v=19"),
        Some(costs),
        Some(salt_b64),
        Some(digest_b64),
        None,
    ) = (
        parts.next(),
        parts.next(),
        parts.next(),
        parts.next(),
        parts.next(),
        parts.next(),
        parts.next(),
    )
    else {
        return Err(CryptoError::InvalidPasswordHash);
    };
    let mut m = None;
    let mut t = None;
    let mut p = None;
    let mut count = 0;
    for pair in costs.split(',') {
        count += 1;
        let (label, value) = pair
            .split_once('=')
            .ok_or(CryptoError::InvalidPasswordHash)?;
        let slot = match label {
            "m" => &mut m,
            "t" => &mut t,
            "p" => &mut p,
            _ => return Err(CryptoError::InvalidPasswordHash),
        };
        if slot.is_some() {
            return Err(CryptoError::InvalidPasswordHash);
        }
        *slot = Some(number(value)?);
    }
    if count != 3 {
        return Err(CryptoError::InvalidPasswordHash);
    }
    let costs = Costs {
        m: m.ok_or(CryptoError::InvalidPasswordHash)?,
        t: t.ok_or(CryptoError::InvalidPasswordHash)?,
        p: p.ok_or(CryptoError::InvalidPasswordHash)?,
    };
    if costs.m > 131072 || costs.t > 5 || costs.p > 4 {
        return Err(CryptoError::PasswordCostExceeded);
    }
    if costs.p == 0 || costs.t == 0 || costs.m < 8 * costs.p {
        return Err(CryptoError::InvalidPasswordHash);
    }
    Params::new(costs.m, costs.t, costs.p, Some(32))
        .map_err(|_| CryptoError::InvalidPasswordHash)?;
    if !(22..=43).contains(&salt_b64.len()) || digest_b64.len() != 43 {
        return Err(CryptoError::InvalidPasswordHash);
    }
    let mut salt = Zeroizing::new([0; 32]);
    let salt_len = STANDARD_NO_PAD
        .decode_slice(salt_b64, &mut salt[..])
        .map_err(|_| CryptoError::InvalidPasswordHash)?;
    if !(16..=32).contains(&salt_len) {
        return Err(CryptoError::InvalidPasswordHash);
    }
    let mut digest = Zeroizing::new([0; 32]);
    let n = STANDARD_NO_PAD
        .decode_slice(digest_b64, &mut digest[..])
        .map_err(|_| CryptoError::InvalidPasswordHash)?;
    if n != 32 {
        return Err(CryptoError::InvalidPasswordHash);
    }
    Ok(Parsed {
        costs,
        salt,
        salt_len,
        digest,
    })
}
#[cfg(test)]
std::thread_local! { static WORKSPACE_CALLS: std::cell::Cell<usize> = const { std::cell::Cell::new(0) }; }
fn calculate(
    password: &SecretString,
    costs: Costs,
    salt: &[u8],
) -> Result<Zeroizing<[u8; 32]>, CryptoError> {
    if password.len() > MAX_PASSWORD_BYTES {
        return Err(CryptoError::InputTooLarge);
    }
    let params = Params::new(costs.m, costs.t, costs.p, Some(32))
        .map_err(|_| CryptoError::InvalidPasswordHash)?;
    #[cfg(test)]
    WORKSPACE_CALLS.with(|calls| calls.set(calls.get() + 1));
    let mut workspace = Zeroizing::new(Vec::<Block>::new());
    workspace
        .try_reserve_exact(params.block_count())
        .map_err(|_| CryptoError::AllocationFailed)?;
    workspace.resize(params.block_count(), Block::default());
    let mut digest = Zeroizing::new([0; 32]);
    Argon2::new(Algorithm::Argon2id, Version::V0x13, params)
        .hash_password_into_with_memory(
            password.expose_secret().as_bytes(),
            salt,
            &mut digest[..],
            &mut workspace[..],
        )
        .map_err(|_| CryptoError::PasswordHashFailed)?;
    Ok(digest)
}
fn hash_with_rng(
    password: &SecretString,
    rng: &mut (impl RngCore + CryptoRng),
) -> Result<PasswordHash, CryptoError> {
    if password.len() > MAX_PASSWORD_BYTES {
        return Err(CryptoError::InputTooLarge);
    }
    let mut salt = Zeroizing::new([0u8; 16]);
    rng.try_fill_bytes(&mut salt[..])
        .map_err(|_| CryptoError::RandomUnavailable)?;
    let costs = Costs {
        m: 65536,
        t: 3,
        p: 1,
    };
    let digest = calculate(password, costs, &salt[..])?;
    let mut salt_text = Zeroizing::new([0; 22]);
    STANDARD_NO_PAD
        .encode_slice(&salt[..], &mut salt_text[..])
        .map_err(|_| CryptoError::PasswordHashFailed)?;
    let mut digest_text = Zeroizing::new([0; 43]);
    STANDARD_NO_PAD
        .encode_slice(&digest[..], &mut digest_text[..])
        .map_err(|_| CryptoError::PasswordHashFailed)?;
    let mut phc = Zeroizing::new(String::new());
    phc.try_reserve_exact(MAX_PHC_BYTES)
        .map_err(|_| CryptoError::AllocationFailed)?;
    write!(
        &mut *phc,
        "$argon2id$v=19$m=65536,t=3,p=1${}${}",
        std::str::from_utf8(&salt_text[..]).map_err(|_| CryptoError::PasswordHashFailed)?,
        std::str::from_utf8(&digest_text[..]).map_err(|_| CryptoError::PasswordHashFailed)?
    )
    .map_err(|_| CryptoError::PasswordHashFailed)?;
    // Validate our own format before publishing; both allocations stay protected.
    PasswordHash::parse(&phc)
}
/// Create an Argon2id v19 PHC (64 MiB, t=3, p=1, salt=16, digest=32).
/// Synchronous; concurrency admission and async dispatch belong to the host.
pub fn hash_password(password: &SecretString) -> Result<PasswordHash, CryptoError> {
    hash_with_rng(password, &mut OsRng)
}
/// Verify a strictly validated bounded PHC using a wiped workspace and constant-time digest comparison.
pub fn verify_password(
    password: &SecretString,
    hash: &PasswordHash,
) -> Result<PasswordVerification, CryptoError> {
    if password.len() > MAX_PASSWORD_BYTES {
        return Err(CryptoError::InputTooLarge);
    }
    let parsed = parse_phc(hash.expose_phc())?;
    let actual = calculate(password, parsed.costs, &parsed.salt[..parsed.salt_len])?;
    if bool::from(actual[..].ct_eq(&parsed.digest[..])) {
        Ok(PasswordVerification::Verified {
            needs_rehash: hash.needs_rehash(),
        })
    } else {
        Ok(PasswordVerification::Mismatch)
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn rejected_input_never_enters_workspace_allocation() {
        let before = WORKSPACE_CALLS.with(|calls| calls.get());
        for params in [
            "m=4294967295,t=3,p=1",
            "m=65536,t=4294967295,p=1",
            "m=65536,t=3,p=4294967295",
        ] {
            assert!(PasswordHash::parse(&format!("$argon2id$v=19${params}$AAAAAAAAAAAAAAAAAAAAAA$AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")).is_err());
        }
        let hash=PasswordHash::parse("$argon2id$v=19$m=8,t=1,p=1$AAAAAAAAAAAAAAAAAAAAAA$AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA").unwrap();
        let oversized = SecretString::new("x".repeat(1025)).unwrap();
        assert!(verify_password(&oversized, &hash).is_err());
        assert!(hash_password(&oversized).is_err());
        assert_eq!(WORKSPACE_CALLS.with(|calls| calls.get()), before);
        let small = SecretString::new("fixture".into()).unwrap();
        let _ = verify_password(&small, &hash).unwrap();
        assert_eq!(WORKSPACE_CALLS.with(|calls| calls.get()), before + 1);
    }
    #[test]
    fn salt_rng_failure_precedes_expensive_hashing() {
        let p = SecretString::new("synthetic".into()).unwrap();
        assert!(matches!(
            hash_with_rng(&p, &mut crate::key::tests::FailedRandom),
            Err(CryptoError::RandomUnavailable)
        ));
    }
    #[test]
    fn phc_cost_boundaries_and_duplicates_are_strict() {
        for params in [
            "m=7,t=1,p=1",
            "m=8,t=0,p=1",
            "m=8,t=1,p=0",
            "m=08,t=1,p=1",
            "m=8,t=1,p=1,data=x",
            "m=8,t=1,t=1",
        ] {
            assert!(parse_phc(&format!("$argon2id$v=19${params}$AAAAAAAAAAAAAAAAAAAAAA$AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")).is_err());
        }
        for params in ["m=8,t=1,p=1", "m=131072,t=5,p=4", "p=1,t=1,m=8"] {
            assert!(parse_phc(&format!("$argon2id$v=19${params}$AAAAAAAAAAAAAAAAAAAAAA$AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")).is_ok());
        }
    }
}
