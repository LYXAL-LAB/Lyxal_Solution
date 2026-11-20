//! Server-side TLS (lot 2 of the mail programme, P6 a; CTO decisions C3 and C7).
//!
//! `lyxal_crypto` builds the complete `rustls` server configuration; hosts only plug
//! connections (`tokio_rustls::TlsAcceptor`, STARTTLS). Fixed settings: `aws-lc-rs` provider
//! passed explicitly (never `ServerConfig::builder()`, which panics when both `rustls`
//! providers are active, as in the workspace), TLS 1.2 and 1.3 only, no 0-RTT, no client
//! certificate, no key log. Certificates are chosen by name (SNI, one-level wildcard) with an
//! optional default, and replaced atomically: new handshakes see the new certificate, open
//! connections keep the old one. Certificate and key bytes come from the host: this module
//! reads no file.
use crate::{CryptoError, SecretBytes};
use base64::engine::general_purpose::STANDARD;
use base64::Engine;
use rustls::client::verify_server_name;
use rustls::crypto::aws_lc_rs;
use rustls::server::{
    ClientHello, NoServerSessionStorage, ParsedCertificate, ResolvesServerCert,
    ServerSessionMemoryCache,
};
use rustls::sign::CertifiedKey;
use rustls::{NoKeyLog, ServerConfig, SignatureAlgorithm, SignatureScheme};
use rustls_pki_types::pem::PemObject;
use rustls_pki_types::{
    CertificateDer, PrivateKeyDer, PrivatePkcs1KeyDer, PrivatePkcs8KeyDer, PrivateSec1KeyDer,
    ServerName,
};
use std::collections::HashMap;
use std::fmt;
use std::sync::{Arc, RwLock};
use zeroize::Zeroizing;

/// Largest certificate chain accepted (PEM or total DER), in bytes.
const MAX_CHAIN_BYTES: usize = 64 * 1024;
/// Largest number of certificates in a chain (leaf first).
const MAX_CHAIN_CERTIFICATES: usize = 10;
/// Largest private key accepted (PEM or DER), in bytes: an RSA-4096 PEM is about 3.3 KiB.
const MAX_KEY_BYTES: usize = 16 * 1024;
/// ALPN bounds: 0 to 8 protocol names of 1 to 255 bytes.
const MAX_ALPN_PROTOCOLS: usize = 8;
/// Session cache bound (0 disables resumption by session ID and TLS 1.3 tickets).
const MAX_SESSION_CACHE_ENTRIES: usize = 65_536;
/// Label used to check that a wildcard certificate covers `*.<domain>` (any first label).
const WILDCARD_PROBE_LABEL: &str = "lyxal-wildcard-probe";

/// Handshake signature schemes accepted for the server key: RSA (2048 bits or more, enforced by
/// AWS-LC), ECDSA P-256 and P-384, Ed25519. P-521 and post-quantum keys are refused.
const ALLOWED_SCHEMES: &[SignatureScheme] = &[
    SignatureScheme::RSA_PSS_SHA512,
    SignatureScheme::RSA_PSS_SHA384,
    SignatureScheme::RSA_PSS_SHA256,
    SignatureScheme::RSA_PKCS1_SHA512,
    SignatureScheme::RSA_PKCS1_SHA384,
    SignatureScheme::RSA_PKCS1_SHA256,
    SignatureScheme::ECDSA_NISTP256_SHA256,
    SignatureScheme::ECDSA_NISTP384_SHA384,
    SignatureScheme::ED25519,
];

/// Certificate chain and private key of a server, checked together.
///
/// The private key is handed to `rustls` / `aws-lc-rs`, which keep it in C memory (not wiped
/// by this crate, SECURITY.md); every Rust copy made here is wiped. `Debug` is redacted; no
/// `Clone`, no export.
///
/// ```compile_fail
/// fn duplicate(key: &lyxal_crypto::TlsCertifiedKey) -> lyxal_crypto::TlsCertifiedKey {
///     key.clone()
/// }
/// ```
pub struct TlsCertifiedKey {
    inner: Arc<CertifiedKey>,
}

impl TlsCertifiedKey {
    /// Chain in PEM (`CERTIFICATE` blocks, leaf first, 10 at most, 64 KiB at most; other blocks
    /// ignored) and private key in PEM: `PRIVATE KEY` (PKCS#8), `RSA PRIVATE KEY` (PKCS#1) or
    /// `EC PRIVATE KEY` (SEC1; an `EC PARAMETERS` block is ignored), exactly one, 16 KiB at
    /// most. RSA 2048 bits or more, ECDSA P-256 / P-384, Ed25519; encrypted key refused.
    ///
    /// Errors: oversized input `InputTooLarge`; unreadable, empty or too long chain
    /// `InvalidCertificate`; unreadable, encrypted, weak or unsupported key
    /// `InvalidKeyEncoding`; key of another certificate `CertificateKeyMismatch`.
    pub fn from_pem(chain_pem: &[u8], private_key_pem: SecretBytes) -> Result<Self, CryptoError> {
        if chain_pem.len() > MAX_CHAIN_BYTES || private_key_pem.len() > MAX_KEY_BYTES {
            return Err(CryptoError::InputTooLarge);
        }
        let mut chain = Vec::new();
        for certificate in CertificateDer::pem_slice_iter(chain_pem) {
            if chain.len() == MAX_CHAIN_CERTIFICATES {
                return Err(CryptoError::InvalidCertificate);
            }
            chain.push(certificate.map_err(|_| CryptoError::InvalidCertificate)?);
        }
        let (kind, der) = private_key_der(&private_key_pem)?;
        drop(private_key_pem);
        let key = match kind {
            KeyKind::Pkcs8 => PrivateKeyDer::Pkcs8(PrivatePkcs8KeyDer::from(der.as_slice())),
            KeyKind::Pkcs1 => PrivateKeyDer::Pkcs1(PrivatePkcs1KeyDer::from(der.as_slice())),
            KeyKind::Sec1 => PrivateKeyDer::Sec1(PrivateSec1KeyDer::from(der.as_slice())),
        };
        Self::build(chain, &key)
    }

    /// Chain in DER (leaf first, 10 at most, 64 KiB in total) and private key in PKCS#8 DER
    /// (16 KiB at most). Same keys and errors as [`TlsCertifiedKey::from_pem`].
    pub fn from_der(
        chain: Vec<Vec<u8>>,
        private_key_pkcs8_der: SecretBytes,
    ) -> Result<Self, CryptoError> {
        let total = chain
            .iter()
            .try_fold(0usize, |sum, cert| sum.checked_add(cert.len()));
        if total.is_none_or(|total| total > MAX_CHAIN_BYTES)
            || private_key_pkcs8_der.len() > MAX_KEY_BYTES
        {
            return Err(CryptoError::InputTooLarge);
        }
        if chain.len() > MAX_CHAIN_CERTIFICATES {
            return Err(CryptoError::InvalidCertificate);
        }
        let chain = chain.into_iter().map(CertificateDer::from).collect();
        let key = PrivateKeyDer::Pkcs8(PrivatePkcs8KeyDer::from(
            private_key_pkcs8_der.expose_secret(),
        ));
        Self::build(chain, &key)
    }

    fn build(
        chain: Vec<CertificateDer<'static>>,
        key: &PrivateKeyDer<'_>,
    ) -> Result<Self, CryptoError> {
        let leaf = chain.first().ok_or(CryptoError::InvalidCertificate)?;
        ParsedCertificate::try_from(leaf).map_err(|_| CryptoError::InvalidCertificate)?;
        let signing_key = aws_lc_rs::sign::any_supported_type(key)
            .map_err(|_| CryptoError::InvalidKeyEncoding)?;
        let supported = matches!(
            signing_key.algorithm(),
            SignatureAlgorithm::RSA | SignatureAlgorithm::ECDSA | SignatureAlgorithm::ED25519
        ) && signing_key.choose_scheme(ALLOWED_SCHEMES).is_some();
        if !supported {
            return Err(CryptoError::InvalidKeyEncoding);
        }
        let certified = CertifiedKey::new(chain, signing_key);
        // A key whose public half cannot be compared is refused too (strict).
        certified
            .keys_match()
            .map_err(|_| CryptoError::CertificateKeyMismatch)?;
        Ok(Self {
            inner: Arc::new(certified),
        })
    }

    fn covers(&self, name: &str) -> bool {
        let Some(leaf) = self.inner.cert.first() else {
            return false;
        };
        let (Ok(parsed), Ok(server_name)) = (
            ParsedCertificate::try_from(leaf),
            ServerName::try_from(name),
        ) else {
            return false;
        };
        verify_server_name(&parsed, &server_name).is_ok()
    }
}
impl fmt::Debug for TlsCertifiedKey {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str("TlsCertifiedKey([REDACTED])")
    }
}

#[derive(Clone, Copy)]
enum KeyKind {
    Pkcs8,
    Pkcs1,
    Sec1,
}

/// The single private key block of a PEM input, decoded into a wiped buffer whose capacity is
/// reserved first (no reallocation leaves an unwiped copy behind).
fn private_key_der(secret: &SecretBytes) -> Result<(KeyKind, Zeroizing<Vec<u8>>), CryptoError> {
    let text =
        std::str::from_utf8(secret.expose_secret()).map_err(|_| CryptoError::InvalidKeyEncoding)?;
    let mut found: Option<(KeyKind, &str)> = None;
    let mut rest = text;
    while let Some(begin) = rest.find("-----BEGIN ") {
        let after = &rest[begin + "-----BEGIN ".len()..];
        let label_end = after.find("-----").ok_or(CryptoError::InvalidKeyEncoding)?;
        let label = &after[..label_end];
        let body_and_rest = &after[label_end + "-----".len()..];
        let end_marker = ["-----END ", label, "-----"].concat();
        let body_end = body_and_rest
            .find(&end_marker)
            .ok_or(CryptoError::InvalidKeyEncoding)?;
        let body = &body_and_rest[..body_end];
        rest = &body_and_rest[body_end + end_marker.len()..];
        let kind = match label {
            "PRIVATE KEY" => KeyKind::Pkcs8,
            "RSA PRIVATE KEY" => KeyKind::Pkcs1,
            "EC PRIVATE KEY" => KeyKind::Sec1,
            // Encrypted keys (PKCS#8 or legacy headers) are refused, never decrypted here.
            "ENCRYPTED PRIVATE KEY" => return Err(CryptoError::InvalidKeyEncoding),
            _ => continue,
        };
        if found.replace((kind, body)).is_some() {
            return Err(CryptoError::InvalidKeyEncoding);
        }
    }
    let (kind, body) = found.ok_or(CryptoError::InvalidKeyEncoding)?;
    // Legacy encrypted PEM carries "Proc-Type:" / "DEK-Info:" headers: refused by the decoder.
    let mut compact = Zeroizing::new(Vec::new());
    compact
        .try_reserve_exact(body.len())
        .map_err(|_| CryptoError::AllocationFailed)?;
    compact.extend(body.bytes().filter(|b| !b.is_ascii_whitespace()));
    let mut der = Zeroizing::new(Vec::new());
    der.try_reserve_exact(compact.len() / 4 * 3 + 3)
        .map_err(|_| CryptoError::AllocationFailed)?;
    STANDARD
        .decode_vec(compact.as_slice(), &mut der)
        .map_err(|_| CryptoError::InvalidKeyEncoding)?;
    if der.is_empty() {
        return Err(CryptoError::InvalidKeyEncoding);
    }
    Ok((kind, der))
}

#[derive(Default)]
struct CertificateTable {
    default: Option<Arc<CertifiedKey>>,
    names: HashMap<String, Arc<CertifiedKey>>,
}

/// Certificates of a server: one per name (SNI; exact name or one-level wildcard
/// `*.domain`) and an optional default (client without SNI, IP address, unknown name).
/// Replacement is atomic: new handshakes see the new certificate, open connections keep the
/// old one. Requested name absent and no default: the handshake fails with a TLS alert.
pub struct TlsCertificateStore {
    table: RwLock<Arc<CertificateTable>>,
}

impl TlsCertificateStore {
    /// New store, with or without a default certificate.
    pub fn new(default: Option<TlsCertifiedKey>) -> Arc<Self> {
        Arc::new(Self {
            table: RwLock::new(Arc::new(CertificateTable {
                default: default.map(|key| key.inner),
                names: HashMap::new(),
            })),
        })
    }
    fn snapshot(&self) -> Arc<CertificateTable> {
        // The lock only guards an Arc swap: a poisoned lock still holds a consistent table.
        match self.table.read() {
            Ok(table) => Arc::clone(&table),
            Err(poisoned) => Arc::clone(&poisoned.into_inner()),
        }
    }
    fn update(&self, change: impl FnOnce(&mut CertificateTable)) {
        let mut guard = match self.table.write() {
            Ok(guard) => guard,
            Err(poisoned) => poisoned.into_inner(),
        };
        let mut next = CertificateTable {
            default: guard.default.clone(),
            names: guard.names.clone(),
        };
        change(&mut next);
        *guard = Arc::new(next);
    }
    /// Replace (or remove, with `None`) the default certificate.
    pub fn set_default(&self, key: Option<TlsCertifiedKey>) {
        self.update(|table| table.default = key.map(|key| key.inner));
    }
    /// Serve `key` for `server_name` (DNS name, ASCII case ignored, or `*.domain` with at least
    /// two labels after the wildcard), replacing any previous certificate of that name.
    /// Invalid name, IP address, or certificate not covering the name: `InvalidCertificate`.
    pub fn insert(&self, server_name: &str, key: TlsCertifiedKey) -> Result<(), CryptoError> {
        let name = normalize_name(server_name)?;
        let covered = match name.strip_prefix("*.") {
            Some(domain) => key.covers(&[WILDCARD_PROBE_LABEL, ".", domain].concat()),
            None => key.covers(&name),
        };
        if !covered {
            return Err(CryptoError::InvalidCertificate);
        }
        self.update(|table| {
            table.names.insert(name, key.inner);
        });
        Ok(())
    }
    /// Stop serving `server_name`; returns whether it was present.
    pub fn remove(&self, server_name: &str) -> bool {
        let Ok(name) = normalize_name(server_name) else {
            return false;
        };
        let mut removed = false;
        self.update(|table| removed = table.names.remove(&name).is_some());
        removed
    }
}
impl fmt::Debug for TlsCertificateStore {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        let table = self.snapshot();
        f.debug_struct("TlsCertificateStore")
            .field("names", &table.names.len())
            .field("default", &table.default.is_some())
            .finish()
    }
}
impl ResolvesServerCert for TlsCertificateStore {
    fn resolve(&self, client_hello: ClientHello<'_>) -> Option<Arc<CertifiedKey>> {
        let table = self.snapshot();
        if let Some(requested) = client_hello.server_name() {
            let requested = requested.to_ascii_lowercase();
            if let Some(key) = table.names.get(&requested) {
                return Some(Arc::clone(key));
            }
            if let Some((_, parent)) = requested.split_once('.') {
                if let Some(key) = table.names.get(&["*.", parent].concat()) {
                    return Some(Arc::clone(key));
                }
            }
        }
        table.default.clone()
    }
}

/// Lowercase DNS name, or `*.` followed by a DNS name of at least two labels.
fn normalize_name(server_name: &str) -> Result<String, CryptoError> {
    let name = server_name.to_ascii_lowercase();
    let (host, wildcard) = match name.strip_prefix("*.") {
        Some(domain) => (domain, true),
        None => (name.as_str(), false),
    };
    let valid = !host.ends_with('.')
        && (!wildcard || host.contains('.'))
        && matches!(ServerName::try_from(host), Ok(ServerName::DnsName(_)));
    if valid {
        Ok(name)
    } else {
        Err(CryptoError::InvalidCertificate)
    }
}

/// Lowest TLS version accepted by the server.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Default)]
pub enum TlsMinVersion {
    /// TLS 1.2 and 1.3 (1.3 preferred).
    #[default]
    Tls12,
    /// TLS 1.3 only.
    Tls13,
}

/// Settings of a server configuration.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct TlsServerOptions {
    /// Lowest version; `Tls12` by default.
    pub min_version: TlsMinVersion,
    /// ALPN names in preference order, 0 to 8 names of 1 to 255 bytes (e.g. `imap`, `h2`,
    /// `acme-tls/1`); empty by default (no ALPN).
    pub alpn_protocols: Vec<Vec<u8>>,
    /// Server-side session cache, 0 to 65 536 entries (0 disables resumption); 4 096 by default.
    pub session_cache_entries: usize,
}
impl Default for TlsServerOptions {
    fn default() -> Self {
        Self {
            min_version: TlsMinVersion::Tls12,
            alpn_protocols: Vec::new(),
            session_cache_entries: 4096,
        }
    }
}

/// `rustls` server configuration ready for `tokio_rustls::TlsAcceptor` (host side): provider
/// `aws-lc-rs` (its cipher suites and key exchange groups, X25519MLKEM768 included), TLS 1.2
/// and 1.3 (or 1.3 only), no 0-RTT, no client certificate, no key log, certificates chosen by
/// `store`. ALPN or cache settings out of bounds: `InputTooLarge`.
pub fn tls_server_config(
    store: Arc<TlsCertificateStore>,
    options: &TlsServerOptions,
) -> Result<Arc<ServerConfig>, CryptoError> {
    if options.alpn_protocols.len() > MAX_ALPN_PROTOCOLS
        || options
            .alpn_protocols
            .iter()
            .any(|name| name.is_empty() || name.len() > 255)
        || options.session_cache_entries > MAX_SESSION_CACHE_ENTRIES
    {
        return Err(CryptoError::InputTooLarge);
    }
    let versions: &[&'static rustls::SupportedProtocolVersion] = match options.min_version {
        TlsMinVersion::Tls12 => &[&rustls::version::TLS13, &rustls::version::TLS12],
        TlsMinVersion::Tls13 => &[&rustls::version::TLS13],
    };
    // Never ServerConfig::builder(): no process-level provider exists when both rustls
    // providers are compiled in (workspace), and that constructor panics.
    let mut config = ServerConfig::builder_with_provider(Arc::new(aws_lc_rs::default_provider()))
        .with_protocol_versions(versions)
        .map_err(|_| CryptoError::EncryptionFailed)?
        .with_no_client_auth()
        .with_cert_resolver(store);
    config.max_early_data_size = 0;
    config.send_half_rtt_data = false;
    config.key_log = Arc::new(NoKeyLog {});
    config.alpn_protocols = options.alpn_protocols.clone();
    if options.session_cache_entries == 0 {
        config.session_storage = Arc::new(NoServerSessionStorage {});
        config.send_tls13_tickets = 0;
    } else {
        config.session_storage = ServerSessionMemoryCache::new(options.session_cache_entries);
    }
    Ok(Arc::new(config))
}
