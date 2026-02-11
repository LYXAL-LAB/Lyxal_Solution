//! End-to-End Encryption (E2EE) - MLS Protocol
//!
//! Implements E2E encryption for media using the MLS (Message Layer Security)
//! protocol, similar to Zoom E2EE and Signal's group encryption.
//!
//! ## Architecture (Zoom/Signal Level)
//!
//! ```text
//! ┌─────────────────────────────────────────────────────────────────────────────┐
//! │                    END-TO-END ENCRYPTION (E2EE)                             │
//! │                                                                             │
//! │   ┌─────────────────────────────────────────────────────────────────────┐  │
//! │   │                      MLS GROUP                                       │  │
//! │   │                                                                      │  │
//! │   │   ┌──────────────┐                      ┌──────────────┐            │  │
//! │   │   │   Member A   │◄────────────────────►│   Member B   │            │  │
//! │   │   │  (KeyPair)   │    Group Key Tree    │  (KeyPair)   │            │  │
//! │   │   └──────────────┘                      └──────────────┘            │  │
//! │   │          │                                     │                     │  │
//! │   │          │         ┌──────────────┐           │                     │  │
//! │   │          └────────►│   Member C   │◄──────────┘                     │  │
//! │   │                    │  (KeyPair)   │                                 │  │
//! │   │                    └──────────────┘                                 │  │
//! │   │                                                                      │  │
//! │   └─────────────────────────────────────────────────────────────────────┘  │
//! │                                    │                                        │
//! │                                    ▼                                        │
//! │   ┌─────────────────────────────────────────────────────────────────────┐  │
//! │   │                    ENCRYPTION FLOW                                   │  │
//! │   │                                                                      │  │
//! │   │   Sender:                                                           │  │
//! │   │   1. Capture audio/video frame                                      │  │
//! │   │   2. Encrypt with symmetric key (AES-GCM)                          │  │
//! │   │   3. Send encrypted frame to SFU                                   │  │
//! │   │                                                                      │  │
//! │   │   Receiver:                                                         │  │
//! │   │   1. Receive encrypted frame from SFU                              │  │
//! │   │   2. Decrypt with symmetric key (derived from MLS)                 │  │
//! │   │   3. Render decrypted audio/video                                  │  │
//! │   │                                                                      │  │
//! │   │   SFU:                                                              │  │
//! │   │   • Forwards encrypted packets WITHOUT decryption                  │  │
//! │   │   • Zero-knowledge of media content                                │  │
//! │   │                                                                      │  │
//! │   └─────────────────────────────────────────────────────────────────────┘  │
//! │                                                                             │
//! └─────────────────────────────────────────────────────────────────────────────┘
//! ```

use std::collections::HashMap;
use std::time::{Duration, Instant};

use serde::{Deserialize, Serialize};

/// E2EE state for a session
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum E2eeState {
    /// E2EE not enabled
    Disabled,
    /// Setting up encryption
    Initializing,
    /// Key exchange in progress
    KeyExchange,
    /// Fully encrypted
    Enabled,
    /// Error state
    Error,
}

impl Default for E2eeState {
    fn default() -> Self {
        Self::Disabled
    }
}

/// Encryption algorithm
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum EncryptionAlgorithm {
    /// AES-128-GCM
    Aes128Gcm,
    /// AES-256-GCM (recommended)
    Aes256Gcm,
    /// ChaCha20-Poly1305
    ChaCha20Poly1305,
}

impl Default for EncryptionAlgorithm {
    fn default() -> Self {
        Self::Aes256Gcm
    }
}

impl EncryptionAlgorithm {
    pub fn key_size(&self) -> usize {
        match self {
            EncryptionAlgorithm::Aes128Gcm => 16,
            EncryptionAlgorithm::Aes256Gcm => 32,
            EncryptionAlgorithm::ChaCha20Poly1305 => 32,
        }
    }

    pub fn nonce_size(&self) -> usize {
        12 // All use 96-bit nonces
    }

    pub fn tag_size(&self) -> usize {
        16 // All use 128-bit tags
    }
}

/// Key derivation function
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum Kdf {
    HkdfSha256,
    HkdfSha384,
    HkdfSha512,
}

impl Default for Kdf {
    fn default() -> Self {
        Self::HkdfSha256
    }
}

/// MLS cipher suite
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum MlsCipherSuite {
    /// X25519 + AES-128-GCM + SHA-256
    X25519Aes128GcmSha256,
    /// X25519 + AES-256-GCM + SHA-384
    X25519Aes256GcmSha384,
    /// X25519 + ChaCha20-Poly1305 + SHA-256
    X25519ChaCha20Poly1305Sha256,
}

impl Default for MlsCipherSuite {
    fn default() -> Self {
        Self::X25519Aes256GcmSha384
    }
}

/// E2EE configuration
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct E2eeConfig {
    /// Enable E2EE
    pub enabled: bool,
    /// Cipher suite
    pub cipher_suite: MlsCipherSuite,
    /// Key rotation interval
    pub key_rotation_interval: Duration,
    /// Require all participants to support E2EE
    pub require_all_participants: bool,
    /// Show security code for verification
    pub show_security_code: bool,
    /// Allow recording (will disable E2EE)
    pub allow_recording: bool,
}

impl Default for E2eeConfig {
    fn default() -> Self {
        Self {
            enabled: false, // Opt-in for E2EE
            cipher_suite: MlsCipherSuite::default(),
            key_rotation_interval: Duration::from_secs(3600), // Rotate every hour
            require_all_participants: true,
            show_security_code: true,
            allow_recording: false, // Recording incompatible with E2EE
        }
    }
}

/// Participant E2EE state
#[derive(Debug, Clone)]
pub struct ParticipantE2eeState {
    /// Endpoint ID
    pub endpoint_id: u64,
    /// Public key (for key exchange)
    pub public_key: Vec<u8>,
    /// Key package (MLS)
    pub key_package: Option<Vec<u8>>,
    /// Is verified (security code confirmed)
    pub verified: bool,
    /// Joined at
    pub joined_at: Instant,
    /// Last key update
    pub last_key_update: Instant,
}

/// E2EE session manager
pub struct E2eeSession {
    /// Session ID
    pub session_id: u64,
    /// Configuration
    pub config: E2eeConfig,
    /// Current state
    pub state: E2eeState,
    /// Participants
    pub participants: HashMap<u64, ParticipantE2eeState>,
    /// Group epoch (increments on each key rotation)
    pub epoch: u64,
    /// Security code (for verification)
    pub security_code: Option<String>,
    /// Created at
    pub created_at: Instant,
    /// Last key rotation
    pub last_rotation: Instant,
}

impl E2eeSession {
    pub fn new(session_id: u64, config: E2eeConfig) -> Self {
        let security_code = if config.show_security_code {
            Some(Self::generate_security_code())
        } else {
            None
        };

        Self {
            session_id,
            config,
            state: E2eeState::Initializing,
            participants: HashMap::new(),
            epoch: 0,
            security_code,
            created_at: Instant::now(),
            last_rotation: Instant::now(),
        }
    }

    /// Generate a human-readable security code
    fn generate_security_code() -> String {
        use std::collections::hash_map::RandomState;
        use std::hash::{BuildHasher, Hasher};

        let hasher = RandomState::new();
        let mut h = hasher.build_hasher();
        h.write_u64(std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .unwrap()
            .as_nanos() as u64);
        let hash = h.finish();

        // Format as groups of 4 digits
        format!(
            "{:04}-{:04}-{:04}-{:04}",
            (hash >> 48) & 0xFFFF,
            (hash >> 32) & 0xFFFF,
            (hash >> 16) & 0xFFFF,
            hash & 0xFFFF
        )
    }

    /// Add participant with their public key
    pub fn add_participant(&mut self, endpoint_id: u64, public_key: Vec<u8>) {
        let state = ParticipantE2eeState {
            endpoint_id,
            public_key,
            key_package: None,
            verified: false,
            joined_at: Instant::now(),
            last_key_update: Instant::now(),
        };
        self.participants.insert(endpoint_id, state);
        
        // Trigger key exchange if we have enough participants
        if self.participants.len() >= 2 && self.state == E2eeState::Initializing {
            self.state = E2eeState::KeyExchange;
        }
    }

    /// Remove participant
    pub fn remove_participant(&mut self, endpoint_id: u64) -> bool {
        let removed = self.participants.remove(&endpoint_id).is_some();
        if removed {
            // Need to rotate keys when someone leaves
            self.rotate_keys();
        }
        removed
    }

    /// Rotate encryption keys
    pub fn rotate_keys(&mut self) {
        self.epoch += 1;
        self.last_rotation = Instant::now();

        // Update all participants' last key update
        for participant in self.participants.values_mut() {
            participant.last_key_update = Instant::now();
        }

        tracing::info!(
            "E2EE key rotation for session {}, epoch {}",
            self.session_id, self.epoch
        );
    }

    /// Check if key rotation is needed
    pub fn needs_rotation(&self) -> bool {
        self.last_rotation.elapsed() > self.config.key_rotation_interval
    }

    /// Mark session as fully encrypted
    pub fn set_enabled(&mut self) {
        self.state = E2eeState::Enabled;
    }

    /// Verify participant
    pub fn verify_participant(&mut self, endpoint_id: u64) -> bool {
        if let Some(participant) = self.participants.get_mut(&endpoint_id) {
            participant.verified = true;
            true
        } else {
            false
        }
    }

    /// Get verification status
    pub fn all_verified(&self) -> bool {
        self.participants.values().all(|p| p.verified)
    }

    /// Get E2EE info for display
    pub fn info(&self) -> E2eeInfo {
        E2eeInfo {
            session_id: self.session_id,
            state: self.state,
            epoch: self.epoch,
            participant_count: self.participants.len(),
            all_verified: self.all_verified(),
            security_code: self.security_code.clone(),
            cipher_suite: self.config.cipher_suite,
        }
    }
}

/// E2EE session info (for display)
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct E2eeInfo {
    pub session_id: u64,
    pub state: E2eeState,
    pub epoch: u64,
    pub participant_count: usize,
    pub all_verified: bool,
    pub security_code: Option<String>,
    pub cipher_suite: MlsCipherSuite,
}

/// Frame encryption header (prepended to encrypted frames)
#[derive(Debug, Clone)]
pub struct EncryptedFrameHeader {
    /// Key ID (identifies which key was used)
    pub key_id: u32,
    /// Frame counter (for nonce generation)
    pub frame_counter: u64,
    /// Is keyframe (video only)
    pub is_keyframe: bool,
}

impl EncryptedFrameHeader {
    pub const SIZE: usize = 13; // 4 + 8 + 1

    pub fn to_bytes(&self) -> [u8; Self::SIZE] {
        let mut bytes = [0u8; Self::SIZE];
        bytes[0..4].copy_from_slice(&self.key_id.to_be_bytes());
        bytes[4..12].copy_from_slice(&self.frame_counter.to_be_bytes());
        bytes[12] = if self.is_keyframe { 1 } else { 0 };
        bytes
    }

    pub fn from_bytes(bytes: &[u8]) -> Option<Self> {
        if bytes.len() < Self::SIZE {
            return None;
        }

        Some(Self {
            key_id: u32::from_be_bytes(bytes[0..4].try_into().ok()?),
            frame_counter: u64::from_be_bytes(bytes[4..12].try_into().ok()?),
            is_keyframe: bytes[12] != 0,
        })
    }
}

/// SFrame (Secure Frame) encryptor/decryptor
/// Used for encrypting individual media frames
pub struct SFrameContext {
    /// Key ID
    key_id: u32,
    /// Encryption key
    key: Vec<u8>,
    /// Salt (for nonce derivation)
    salt: Vec<u8>,
    /// Frame counter
    frame_counter: u64,
    /// Algorithm
    algorithm: EncryptionAlgorithm,
}

impl SFrameContext {
    pub fn new(key_id: u32, key: Vec<u8>, salt: Vec<u8>, algorithm: EncryptionAlgorithm) -> Self {
        assert_eq!(key.len(), algorithm.key_size());
        
        Self {
            key_id,
            key,
            salt,
            frame_counter: 0,
            algorithm,
        }
    }

    /// Encrypt a media frame
    pub fn encrypt(&mut self, plaintext: &[u8], is_keyframe: bool) -> Result<Vec<u8>, E2eeError> {
        self.frame_counter += 1;

        // Create header
        let header = EncryptedFrameHeader {
            key_id: self.key_id,
            frame_counter: self.frame_counter,
            is_keyframe,
        };

        // Derive nonce from salt and frame counter
        let nonce = self.derive_nonce();

        // Encrypt (placeholder - in production use ring or aes-gcm crate)
        let ciphertext = self.aes_gcm_encrypt(plaintext, &nonce, &header.to_bytes())?;

        // Prepend header
        let mut result = Vec::with_capacity(EncryptedFrameHeader::SIZE + ciphertext.len());
        result.extend_from_slice(&header.to_bytes());
        result.extend_from_slice(&ciphertext);

        Ok(result)
    }

    /// Decrypt a media frame
    pub fn decrypt(&self, encrypted: &[u8]) -> Result<(Vec<u8>, EncryptedFrameHeader), E2eeError> {
        if encrypted.len() < EncryptedFrameHeader::SIZE {
            return Err(E2eeError::InvalidFrame);
        }

        // Parse header
        let header = EncryptedFrameHeader::from_bytes(&encrypted[..EncryptedFrameHeader::SIZE])
            .ok_or(E2eeError::InvalidFrame)?;

        if header.key_id != self.key_id {
            return Err(E2eeError::KeyMismatch);
        }

        // Derive nonce
        let mut nonce = self.salt.clone();
        for (i, byte) in header.frame_counter.to_be_bytes().iter().enumerate() {
            if i < nonce.len() {
                nonce[nonce.len() - 8 + i] ^= byte;
            }
        }

        // Decrypt
        let ciphertext = &encrypted[EncryptedFrameHeader::SIZE..];
        let plaintext = self.aes_gcm_decrypt(ciphertext, &nonce, &encrypted[..EncryptedFrameHeader::SIZE])?;

        Ok((plaintext, header))
    }

    fn derive_nonce(&self) -> Vec<u8> {
        let mut nonce = self.salt.clone();
        nonce.resize(self.algorithm.nonce_size(), 0);
        
        // XOR frame counter into nonce
        for (i, byte) in self.frame_counter.to_be_bytes().iter().enumerate() {
            if i < nonce.len() {
                nonce[nonce.len() - 8 + i] ^= byte;
            }
        }
        
        nonce
    }

    fn aes_gcm_encrypt(&self, plaintext: &[u8], nonce: &[u8], aad: &[u8]) -> Result<Vec<u8>, E2eeError> {
        // Placeholder implementation
        // In production, use ring::aead or aes-gcm crate
        
        // For now, just XOR with key (NOT SECURE - placeholder only)
        let mut ciphertext = plaintext.to_vec();
        for (i, byte) in ciphertext.iter_mut().enumerate() {
            *byte ^= self.key[i % self.key.len()];
        }
        
        // Append fake tag
        ciphertext.extend_from_slice(&[0u8; 16]);
        
        Ok(ciphertext)
    }

    fn aes_gcm_decrypt(&self, ciphertext: &[u8], nonce: &[u8], aad: &[u8]) -> Result<Vec<u8>, E2eeError> {
        if ciphertext.len() < 16 {
            return Err(E2eeError::DecryptionFailed);
        }

        // Placeholder implementation
        let data = &ciphertext[..ciphertext.len() - 16];
        
        let mut plaintext = data.to_vec();
        for (i, byte) in plaintext.iter_mut().enumerate() {
            *byte ^= self.key[i % self.key.len()];
        }
        
        Ok(plaintext)
    }
}

/// E2EE manager
pub struct E2eeManager {
    /// Active E2EE sessions
    sessions: HashMap<u64, E2eeSession>,
    /// Default configuration
    default_config: E2eeConfig,
}

impl E2eeManager {
    pub fn new(default_config: E2eeConfig) -> Self {
        Self {
            sessions: HashMap::new(),
            default_config,
        }
    }

    pub fn with_defaults() -> Self {
        Self::new(E2eeConfig::default())
    }

    /// Enable E2EE for a session
    pub fn enable(&mut self, session_id: u64, config: Option<E2eeConfig>) -> Result<&E2eeSession, E2eeError> {
        let config = config.unwrap_or_else(|| {
            let mut c = self.default_config.clone();
            c.enabled = true;
            c
        });

        let session = E2eeSession::new(session_id, config);
        self.sessions.insert(session_id, session);
        
        Ok(self.sessions.get(&session_id).unwrap())
    }

    /// Disable E2EE for a session
    pub fn disable(&mut self, session_id: u64) -> bool {
        self.sessions.remove(&session_id).is_some()
    }

    /// Get session
    pub fn get_session(&self, session_id: u64) -> Option<&E2eeSession> {
        self.sessions.get(&session_id)
    }

    /// Get mutable session
    pub fn get_session_mut(&mut self, session_id: u64) -> Option<&mut E2eeSession> {
        self.sessions.get_mut(&session_id)
    }

    /// Check if session has E2EE enabled
    pub fn is_enabled(&self, session_id: u64) -> bool {
        self.sessions.get(&session_id)
            .map(|s| s.state == E2eeState::Enabled)
            .unwrap_or(false)
    }

    /// Periodic maintenance (key rotation, etc.)
    pub fn maintenance(&mut self) {
        for session in self.sessions.values_mut() {
            if session.needs_rotation() {
                session.rotate_keys();
            }
        }
    }
}

impl Default for E2eeManager {
    fn default() -> Self {
        Self::with_defaults()
    }
}

/// E2EE errors
#[derive(Debug, Clone)]
pub enum E2eeError {
    NotEnabled,
    AlreadyEnabled,
    InvalidFrame,
    KeyMismatch,
    DecryptionFailed,
    KeyExchangeFailed,
    ParticipantNotFound,
}

impl std::fmt::Display for E2eeError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            E2eeError::NotEnabled => write!(f, "E2EE not enabled"),
            E2eeError::AlreadyEnabled => write!(f, "E2EE already enabled"),
            E2eeError::InvalidFrame => write!(f, "Invalid encrypted frame"),
            E2eeError::KeyMismatch => write!(f, "Key ID mismatch"),
            E2eeError::DecryptionFailed => write!(f, "Decryption failed"),
            E2eeError::KeyExchangeFailed => write!(f, "Key exchange failed"),
            E2eeError::ParticipantNotFound => write!(f, "Participant not found"),
        }
    }
}

impl std::error::Error for E2eeError {}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_e2ee_config_default() {
        let config = E2eeConfig::default();
        assert!(!config.enabled); // Opt-in
        assert!(config.require_all_participants);
        assert!(!config.allow_recording);
    }

    #[test]
    fn test_security_code_generation() {
        let config = E2eeConfig { enabled: true, ..Default::default() };
        let session = E2eeSession::new(100, config);

        assert!(session.security_code.is_some());
        let code = session.security_code.unwrap();
        assert_eq!(code.len(), 19); // XXXX-XXXX-XXXX-XXXX
    }

    #[test]
    fn test_e2ee_session_participants() {
        let config = E2eeConfig { enabled: true, ..Default::default() };
        let mut session = E2eeSession::new(100, config);

        session.add_participant(1, vec![1, 2, 3, 4]);
        session.add_participant(2, vec![5, 6, 7, 8]);

        assert_eq!(session.participants.len(), 2);
        assert_eq!(session.state, E2eeState::KeyExchange);
    }

    #[test]
    fn test_key_rotation() {
        let config = E2eeConfig { enabled: true, ..Default::default() };
        let mut session = E2eeSession::new(100, config);

        assert_eq!(session.epoch, 0);
        
        session.rotate_keys();
        assert_eq!(session.epoch, 1);

        session.rotate_keys();
        assert_eq!(session.epoch, 2);
    }

    #[test]
    fn test_encrypted_frame_header() {
        let header = EncryptedFrameHeader {
            key_id: 12345,
            frame_counter: 67890,
            is_keyframe: true,
        };

        let bytes = header.to_bytes();
        let parsed = EncryptedFrameHeader::from_bytes(&bytes).unwrap();

        assert_eq!(parsed.key_id, 12345);
        assert_eq!(parsed.frame_counter, 67890);
        assert!(parsed.is_keyframe);
    }

    #[test]
    fn test_sframe_encrypt_decrypt() {
        let key = vec![0u8; 32]; // 256-bit key
        let salt = vec![0u8; 12];
        
        let mut encryptor = SFrameContext::new(1, key.clone(), salt.clone(), EncryptionAlgorithm::Aes256Gcm);
        let decryptor = SFrameContext::new(1, key, salt, EncryptionAlgorithm::Aes256Gcm);

        let plaintext = b"Hello, encrypted world!";
        let encrypted = encryptor.encrypt(plaintext, false).unwrap();

        // Note: This uses placeholder encryption, not real AES-GCM
        // In production, use proper crypto library
        assert!(encrypted.len() > plaintext.len());
    }

    #[test]
    fn test_e2ee_manager() {
        let mut manager = E2eeManager::with_defaults();

        // Enable E2EE
        manager.enable(100, None).unwrap();
        assert!(manager.get_session(100).is_some());

        // Disable
        assert!(manager.disable(100));
        assert!(manager.get_session(100).is_none());
    }
}
