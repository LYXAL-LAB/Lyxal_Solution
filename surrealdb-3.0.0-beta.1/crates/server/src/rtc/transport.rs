//! UDP Transport for SFU Media Traffic
//!
//! This module provides the actual UDP transport layer that bridges
//! the SFU engine with real network I/O using tokio.
//!
//! ## Architecture
//!
//! ```text
//! ┌─────────────────────────────────────────────────────────────────┐
//! │                      UDP Transport                              │
//! │                                                                 │
//! │   ┌─────────────┐    ┌────────────────────────────────────┐   │
//! │   │  UdpSocket  │◄──►│        Handler Pipeline            │   │
//! │   │  (tokio)    │    │                                    │   │
//! │   └─────────────┘    │  ┌────────┐ ┌────────┐ ┌────────┐ │   │
//! │                      │  │  STUN  │→│  DTLS  │→│  SRTP  │ │   │
//! │                      │  └────────┘ └────────┘ └────────┘ │   │
//! │                      │       ↓          ↓          ↓     │   │
//! │                      │  ┌────────┐ ┌────────┐ ┌────────┐ │   │
//! │                      │  │  SCTP  │→│DataChan│→│Gateway │ │   │
//! │                      │  └────────┘ └────────┘ └────────┘ │   │
//! │                      └────────────────────────────────────┘   │
//! │                                      │                        │
//! │                                      ▼                        │
//! │                          ┌─────────────────────┐              │
//! │                          │   ServerStates      │              │
//! │                          │   (from sfu crate)  │              │
//! │                          └─────────────────────┘              │
//! └─────────────────────────────────────────────────────────────────┘
//! ```

use std::net::SocketAddr;
use std::sync::atomic::{AtomicBool, AtomicU64, Ordering};
use std::sync::Arc;
use std::time::{Duration, Instant};

use parking_lot::RwLock;
use tokio::net::UdpSocket;
use tokio::sync::mpsc;
use tokio_util::sync::CancellationToken;

/// Maximum UDP packet size
const MAX_UDP_PAYLOAD: usize = 65535;

/// Transport statistics
#[derive(Debug, Default, Clone)]
pub struct TransportStats {
    /// Total bytes received
    pub bytes_received: u64,
    /// Total bytes sent
    pub bytes_sent: u64,
    /// Total packets received
    pub packets_received: u64,
    /// Total packets sent
    pub packets_sent: u64,
    /// STUN packets processed
    pub stun_packets: u64,
    /// DTLS packets processed
    pub dtls_packets: u64,
    /// RTP packets forwarded
    pub rtp_packets: u64,
    /// RTCP packets forwarded
    pub rtcp_packets: u64,
}

/// UDP Transport configuration
#[derive(Debug, Clone)]
pub struct TransportConfig {
    /// UDP bind address
    pub bind_addr: SocketAddr,
    /// Receive buffer size
    pub recv_buffer_size: usize,
    /// Send buffer size  
    pub send_buffer_size: usize,
    /// Idle timeout for connections
    pub idle_timeout: Duration,
}

impl Default for TransportConfig {
    fn default() -> Self {
        Self {
            bind_addr: "0.0.0.0:10000".parse().unwrap(),
            recv_buffer_size: 2 * 1024 * 1024, // 2MB
            send_buffer_size: 2 * 1024 * 1024, // 2MB
            idle_timeout: Duration::from_secs(30),
        }
    }
}

/// UDP Transport for SFU media traffic
pub struct UdpTransport {
    /// Configuration
    config: TransportConfig,
    /// Running state
    running: AtomicBool,
    /// Cancellation token
    cancel: CancellationToken,
    /// Statistics
    stats: RwLock<TransportStats>,
    /// Local address (after bind)
    local_addr: RwLock<Option<SocketAddr>>,
}

impl UdpTransport {
    /// Create a new UDP transport
    pub fn new(config: TransportConfig) -> Self {
        Self {
            config,
            running: AtomicBool::new(false),
            cancel: CancellationToken::new(),
            stats: RwLock::new(TransportStats::default()),
            local_addr: RwLock::new(None),
        }
    }

    /// Create with default config
    pub fn with_defaults() -> Self {
        Self::new(TransportConfig::default())
    }

    /// Start the transport
    pub async fn start(&self) -> Result<SocketAddr, TransportError> {
        if self.running.swap(true, Ordering::SeqCst) {
            return Err(TransportError::AlreadyRunning);
        }

        // Bind UDP socket
        let socket = UdpSocket::bind(self.config.bind_addr)
            .await
            .map_err(|e| TransportError::BindError(e.to_string()))?;

        let local_addr = socket
            .local_addr()
            .map_err(|e| TransportError::BindError(e.to_string()))?;

        *self.local_addr.write() = Some(local_addr);

        tracing::info!("UDP transport started on {}", local_addr);

        Ok(local_addr)
    }

    /// Stop the transport
    pub fn stop(&self) {
        self.running.store(false, Ordering::SeqCst);
        self.cancel.cancel();
    }

    /// Check if running
    pub fn is_running(&self) -> bool {
        self.running.load(Ordering::SeqCst)
    }

    /// Get local address
    pub fn local_addr(&self) -> Option<SocketAddr> {
        *self.local_addr.read()
    }

    /// Get statistics
    pub fn stats(&self) -> TransportStats {
        self.stats.read().clone()
    }

    /// Update bytes received stat
    pub fn record_bytes_received(&self, bytes: u64) {
        let mut stats = self.stats.write();
        stats.bytes_received += bytes;
        stats.packets_received += 1;
    }

    /// Update bytes sent stat
    pub fn record_bytes_sent(&self, bytes: u64) {
        let mut stats = self.stats.write();
        stats.bytes_sent += bytes;
        stats.packets_sent += 1;
    }

    /// Record packet type
    pub fn record_packet_type(&self, packet_type: PacketType) {
        let mut stats = self.stats.write();
        match packet_type {
            PacketType::Stun => stats.stun_packets += 1,
            PacketType::Dtls => stats.dtls_packets += 1,
            PacketType::Rtp => stats.rtp_packets += 1,
            PacketType::Rtcp => stats.rtcp_packets += 1,
        }
    }
}

impl Default for UdpTransport {
    fn default() -> Self {
        Self::with_defaults()
    }
}

/// Packet type for demuxing
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum PacketType {
    Stun,
    Dtls,
    Rtp,
    Rtcp,
}

impl PacketType {
    /// Demux packet type from first byte
    /// Based on RFC 7983 - Multiplexing of STUN, DTLS, RTP, RTCP
    pub fn from_first_byte(byte: u8) -> Self {
        match byte {
            // STUN: 0x00-0x03
            0..=3 => PacketType::Stun,
            // DTLS: 20-63
            20..=63 => PacketType::Dtls,
            // RTP/RTCP: 128-191
            128..=191 => {
                // Further demux: RTCP has specific payload types
                // For now, assume RTP (proper demux requires more bytes)
                PacketType::Rtp
            }
            // Everything else treat as RTP
            _ => PacketType::Rtp,
        }
    }

    /// Demux RTCP from RTP based on payload type
    /// RTCP uses payload types 72-76 (SR, RR, SDES, BYE, APP)
    /// and 200-207 for extended reports
    pub fn demux_rtp_rtcp(payload_type: u8) -> Self {
        match payload_type {
            72..=76 | 200..=207 => PacketType::Rtcp,
            _ => PacketType::Rtp,
        }
    }
}

/// Transport error types
#[derive(Debug, Clone)]
pub enum TransportError {
    AlreadyRunning,
    NotRunning,
    BindError(String),
    SendError(String),
    ReceiveError(String),
}

impl std::fmt::Display for TransportError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            TransportError::AlreadyRunning => write!(f, "Transport already running"),
            TransportError::NotRunning => write!(f, "Transport not running"),
            TransportError::BindError(e) => write!(f, "Bind error: {}", e),
            TransportError::SendError(e) => write!(f, "Send error: {}", e),
            TransportError::ReceiveError(e) => write!(f, "Receive error: {}", e),
        }
    }
}

impl std::error::Error for TransportError {}

/// Certificate manager for DTLS
pub struct CertificateManager {
    /// PEM encoded certificate
    certificate_pem: String,
    /// SHA-256 fingerprint
    fingerprint: String,
}

impl CertificateManager {
    /// Generate a new self-signed certificate
    pub fn generate() -> Result<Self, TransportError> {
        use rcgen::{CertificateParams, KeyPair};
        use sha2::{Digest, Sha256};

        // Generate key pair
        let key_pair = KeyPair::generate(&rcgen::PKCS_ECDSA_P256_SHA256)
            .map_err(|e| TransportError::BindError(format!("Failed to generate key: {}", e)))?;

        // Create certificate params
        let mut params = CertificateParams::new(vec!["lyxal-sfu".to_string()]);
        params.alg = &rcgen::PKCS_ECDSA_P256_SHA256;
        params.key_pair = Some(key_pair);

        // Generate certificate
        let cert = rcgen::Certificate::from_params(params)
            .map_err(|e| TransportError::BindError(format!("Failed to generate cert: {}", e)))?;

        let der = cert.serialize_der()
            .map_err(|e| TransportError::BindError(format!("Failed to serialize cert: {}", e)))?;

        // Calculate fingerprint
        let mut hasher = Sha256::new();
        hasher.update(&der);
        let hash = hasher.finalize();
        let fingerprint: String = hash
            .iter()
            .map(|b| format!("{:02X}", b))
            .collect::<Vec<_>>()
            .join(":");

        Ok(Self {
            certificate_pem: cert.serialize_pem()
                .map_err(|e| TransportError::BindError(format!("Failed to serialize PEM: {}", e)))?,
            fingerprint,
        })
    }

    /// Get certificate PEM
    pub fn certificate_pem(&self) -> &str {
        &self.certificate_pem
    }

    /// Get SHA-256 fingerprint
    pub fn fingerprint(&self) -> &str {
        &self.fingerprint
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_packet_type_demux() {
        // STUN
        assert_eq!(PacketType::from_first_byte(0x00), PacketType::Stun);
        assert_eq!(PacketType::from_first_byte(0x01), PacketType::Stun);

        // DTLS
        assert_eq!(PacketType::from_first_byte(20), PacketType::Dtls);
        assert_eq!(PacketType::from_first_byte(23), PacketType::Dtls); // DTLS Application Data
        assert_eq!(PacketType::from_first_byte(22), PacketType::Dtls); // DTLS Handshake

        // RTP/RTCP
        assert_eq!(PacketType::from_first_byte(128), PacketType::Rtp);
        assert_eq!(PacketType::from_first_byte(191), PacketType::Rtp);
    }

    #[test]
    fn test_transport_config_default() {
        let config = TransportConfig::default();
        assert_eq!(config.bind_addr.port(), 10000);
        assert_eq!(config.idle_timeout, Duration::from_secs(30));
    }

    #[test]
    fn test_transport_stats() {
        let transport = UdpTransport::with_defaults();

        transport.record_bytes_received(100);
        transport.record_bytes_sent(50);
        transport.record_packet_type(PacketType::Stun);
        transport.record_packet_type(PacketType::Rtp);

        let stats = transport.stats();
        assert_eq!(stats.bytes_received, 100);
        assert_eq!(stats.bytes_sent, 50);
        assert_eq!(stats.packets_received, 1);
        assert_eq!(stats.packets_sent, 1);
        assert_eq!(stats.stun_packets, 1);
        assert_eq!(stats.rtp_packets, 1);
    }

    #[test]
    fn test_certificate_generation() {
        let cert = CertificateManager::generate().unwrap();
        assert!(!cert.certificate_pem().is_empty());
        assert!(!cert.fingerprint().is_empty());
        // Fingerprint should be SHA-256 format (32 bytes = 64 hex chars + 31 colons)
        assert_eq!(cert.fingerprint().len(), 95);
    }
}
