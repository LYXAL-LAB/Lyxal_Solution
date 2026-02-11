//! Media Loop - Core UDP receive/send loop for SFU
//!
//! This module implements the main media processing loop that:
//! - Receives UDP packets from clients
//! - Demultiplexes STUN/DTLS/RTP/RTCP
//! - Processes through handler pipeline
//! - Forwards media to appropriate endpoints
//!
//! ## Architecture (like Zoom/Meet)
//!
//! ```text
//! ┌─────────────────────────────────────────────────────────────────┐
//! │                      MEDIA LOOP                                 │
//! │                                                                 │
//! │   ┌─────────────┐                      ┌─────────────────────┐ │
//! │   │   Client    │─────UDP Packet──────►│    recv_from()      │ │
//! │   │  (Browser)  │                      └──────────┬──────────┘ │
//! │   └─────────────┘                                 │            │
//! │                                                   ▼            │
//! │                                        ┌─────────────────────┐ │
//! │                                        │     Demuxer         │ │
//! │                                        │  STUN/DTLS/RTP/RTCP │ │
//! │                                        └──────────┬──────────┘ │
//! │                                                   │            │
//! │         ┌─────────────────────────────────────────┼───────┐   │
//! │         │                                         │       │   │
//! │         ▼                    ▼                    ▼       │   │
//! │   ┌──────────┐        ┌──────────┐         ┌──────────┐  │   │
//! │   │   STUN   │        │   DTLS   │         │   SRTP   │  │   │
//! │   │ Handler  │        │ Handler  │         │ Handler  │  │   │
//! │   └────┬─────┘        └────┬─────┘         └────┬─────┘  │   │
//! │        │                   │                    │        │   │
//! │        │                   ▼                    ▼        │   │
//! │        │            ┌──────────┐         ┌──────────┐   │   │
//! │        │            │   SCTP   │         │  Gateway │   │   │
//! │        │            │ Handler  │         │ (Forward)│   │   │
//! │        │            └────┬─────┘         └────┬─────┘   │   │
//! │        │                 │                    │         │   │
//! │        └─────────────────┴────────────────────┘         │   │
//! │                          │                              │   │
//! │                          ▼                              │   │
//! │                   ┌──────────────┐                      │   │
//! │                   │  send_to()   │──────────────────────┘   │
//! │                   │  (to peers)  │                          │
//! │                   └──────────────┘                          │
//! └─────────────────────────────────────────────────────────────────┘
//! ```

use std::collections::HashMap;
use std::net::SocketAddr;
use std::sync::Arc;
use std::time::{Duration, Instant};

use bytes::{Bytes, BytesMut};
use parking_lot::RwLock;
use tokio::net::UdpSocket;
use tokio::sync::mpsc;
use tokio_util::sync::CancellationToken;

use super::transport::{PacketType, TransportStats};

/// Maximum UDP packet size (MTU safe)
const MAX_UDP_PAYLOAD: usize = 1500;

/// Buffer size for receive
const RECV_BUFFER_SIZE: usize = 2048;

/// Media loop configuration
#[derive(Debug, Clone)]
pub struct MediaLoopConfig {
    /// Local bind address
    pub bind_addr: SocketAddr,
    /// Number of worker tasks
    pub worker_count: usize,
    /// Packet buffer size per worker
    pub packet_buffer_size: usize,
    /// Idle connection timeout
    pub idle_timeout: Duration,
    /// Enable STUN server mode (respond to binding requests)
    pub stun_server_enabled: bool,
}

impl Default for MediaLoopConfig {
    fn default() -> Self {
        Self {
            bind_addr: "0.0.0.0:10000".parse().unwrap(),
            worker_count: num_cpus::get().max(2),
            packet_buffer_size: 1024,
            idle_timeout: Duration::from_secs(30),
            stun_server_enabled: true,
        }
    }
}

/// Incoming packet from network
#[derive(Debug)]
pub struct IncomingPacket {
    /// Source address
    pub src_addr: SocketAddr,
    /// Packet data
    pub data: Bytes,
    /// Receive timestamp
    pub received_at: Instant,
    /// Packet type (demuxed)
    pub packet_type: PacketType,
}

/// Outgoing packet to network
#[derive(Debug)]
pub struct OutgoingPacket {
    /// Destination address
    pub dst_addr: SocketAddr,
    /// Packet data
    pub data: Bytes,
}

/// Connection state for a remote endpoint
#[derive(Debug)]
pub struct ConnectionState {
    /// Remote address
    pub remote_addr: SocketAddr,
    /// Last activity timestamp
    pub last_activity: Instant,
    /// ICE username fragment
    pub ice_ufrag: Option<String>,
    /// ICE password
    pub ice_pwd: Option<String>,
    /// DTLS state
    pub dtls_state: DtlsState,
    /// SRTP session established
    pub srtp_ready: bool,
    /// Associated session ID
    pub session_id: Option<u64>,
    /// Associated endpoint ID
    pub endpoint_id: Option<u64>,
    /// Packets received
    pub packets_received: u64,
    /// Packets sent
    pub packets_sent: u64,
    /// Bytes received
    pub bytes_received: u64,
    /// Bytes sent
    pub bytes_sent: u64,
}

impl ConnectionState {
    pub fn new(remote_addr: SocketAddr) -> Self {
        Self {
            remote_addr,
            last_activity: Instant::now(),
            ice_ufrag: None,
            ice_pwd: None,
            dtls_state: DtlsState::New,
            srtp_ready: false,
            session_id: None,
            endpoint_id: None,
            packets_received: 0,
            packets_sent: 0,
            bytes_received: 0,
            bytes_sent: 0,
        }
    }

    pub fn touch(&mut self) {
        self.last_activity = Instant::now();
    }

    pub fn is_idle(&self, timeout: Duration) -> bool {
        self.last_activity.elapsed() > timeout
    }
}

/// DTLS handshake state
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum DtlsState {
    New,
    Connecting,
    Connected,
    Failed,
    Closed,
}

/// Media loop runner
pub struct MediaLoop {
    /// Configuration
    config: MediaLoopConfig,
    /// UDP socket (shared)
    socket: Option<Arc<UdpSocket>>,
    /// Connection states
    connections: Arc<RwLock<HashMap<SocketAddr, ConnectionState>>>,
    /// Statistics
    stats: Arc<RwLock<MediaLoopStats>>,
    /// Cancellation token
    cancel: CancellationToken,
    /// Running state
    running: std::sync::atomic::AtomicBool,
    /// Outgoing packet sender
    outgoing_tx: Option<mpsc::UnboundedSender<OutgoingPacket>>,
}

/// Media loop statistics
#[derive(Debug, Default, Clone)]
pub struct MediaLoopStats {
    /// Total packets received
    pub packets_received: u64,
    /// Total packets sent
    pub packets_sent: u64,
    /// Total bytes received
    pub bytes_received: u64,
    /// Total bytes sent
    pub bytes_sent: u64,
    /// STUN packets processed
    pub stun_packets: u64,
    /// DTLS packets processed
    pub dtls_packets: u64,
    /// RTP packets forwarded
    pub rtp_packets: u64,
    /// RTCP packets processed
    pub rtcp_packets: u64,
    /// Active connections
    pub active_connections: usize,
    /// Packets dropped
    pub packets_dropped: u64,
}

impl MediaLoop {
    /// Create a new media loop
    pub fn new(config: MediaLoopConfig) -> Self {
        Self {
            config,
            socket: None,
            connections: Arc::new(RwLock::new(HashMap::new())),
            stats: Arc::new(RwLock::new(MediaLoopStats::default())),
            cancel: CancellationToken::new(),
            running: std::sync::atomic::AtomicBool::new(false),
            outgoing_tx: None,
        }
    }

    /// Create with default config
    pub fn with_defaults() -> Self {
        Self::new(MediaLoopConfig::default())
    }

    /// Start the media loop
    pub async fn start(&mut self) -> Result<SocketAddr, MediaLoopError> {
        use std::sync::atomic::Ordering;

        if self.running.swap(true, Ordering::SeqCst) {
            return Err(MediaLoopError::AlreadyRunning);
        }

        // Bind UDP socket
        let socket = UdpSocket::bind(self.config.bind_addr)
            .await
            .map_err(|e| MediaLoopError::BindError(e.to_string()))?;

        let local_addr = socket.local_addr()
            .map_err(|e| MediaLoopError::BindError(e.to_string()))?;

        let socket = Arc::new(socket);
        self.socket = Some(socket.clone());

        // Create outgoing channel
        let (outgoing_tx, outgoing_rx) = mpsc::unbounded_channel();
        self.outgoing_tx = Some(outgoing_tx);

        // Spawn receive loop
        let recv_socket = socket.clone();
        let recv_connections = self.connections.clone();
        let recv_stats = self.stats.clone();
        let recv_cancel = self.cancel.clone();
        let recv_config = self.config.clone();

        tokio::spawn(async move {
            Self::receive_loop(
                recv_socket,
                recv_connections,
                recv_stats,
                recv_cancel,
                recv_config,
            ).await;
        });

        // Spawn send loop
        let send_socket = socket.clone();
        let send_stats = self.stats.clone();
        let send_cancel = self.cancel.clone();

        tokio::spawn(async move {
            Self::send_loop(send_socket, outgoing_rx, send_stats, send_cancel).await;
        });

        // Spawn cleanup loop
        let cleanup_connections = self.connections.clone();
        let cleanup_stats = self.stats.clone();
        let cleanup_cancel = self.cancel.clone();
        let cleanup_timeout = self.config.idle_timeout;

        tokio::spawn(async move {
            Self::cleanup_loop(cleanup_connections, cleanup_stats, cleanup_cancel, cleanup_timeout).await;
        });

        tracing::info!("Media loop started on {} with {} workers", local_addr, self.config.worker_count);

        Ok(local_addr)
    }

    /// Stop the media loop
    pub fn stop(&self) {
        use std::sync::atomic::Ordering;
        self.running.store(false, Ordering::SeqCst);
        self.cancel.cancel();
    }

    /// Check if running
    pub fn is_running(&self) -> bool {
        use std::sync::atomic::Ordering;
        self.running.load(Ordering::SeqCst)
    }

    /// Get statistics
    pub fn stats(&self) -> MediaLoopStats {
        self.stats.read().clone()
    }

    /// Get active connection count
    pub fn connection_count(&self) -> usize {
        self.connections.read().len()
    }

    /// Send a packet to a remote address
    pub fn send(&self, dst_addr: SocketAddr, data: Bytes) -> Result<(), MediaLoopError> {
        if let Some(tx) = &self.outgoing_tx {
            tx.send(OutgoingPacket { dst_addr, data })
                .map_err(|_| MediaLoopError::SendError("Channel closed".to_string()))?;
            Ok(())
        } else {
            Err(MediaLoopError::NotRunning)
        }
    }

    /// Receive loop - reads packets from UDP socket
    async fn receive_loop(
        socket: Arc<UdpSocket>,
        connections: Arc<RwLock<HashMap<SocketAddr, ConnectionState>>>,
        stats: Arc<RwLock<MediaLoopStats>>,
        cancel: CancellationToken,
        config: MediaLoopConfig,
    ) {
        let mut buf = vec![0u8; RECV_BUFFER_SIZE];

        loop {
            tokio::select! {
                _ = cancel.cancelled() => {
                    tracing::info!("Receive loop shutting down");
                    break;
                }
                result = socket.recv_from(&mut buf) => {
                    match result {
                        Ok((len, src_addr)) => {
                            let data = Bytes::copy_from_slice(&buf[..len]);
                            
                            // Update stats
                            {
                                let mut s = stats.write();
                                s.packets_received += 1;
                                s.bytes_received += len as u64;
                            }

                            // Demux packet type
                            let packet_type = if len > 0 {
                                PacketType::from_first_byte(buf[0])
                            } else {
                                continue;
                            };

                            // Update packet type stats
                            {
                                let mut s = stats.write();
                                match packet_type {
                                    PacketType::Stun => s.stun_packets += 1,
                                    PacketType::Dtls => s.dtls_packets += 1,
                                    PacketType::Rtp => s.rtp_packets += 1,
                                    PacketType::Rtcp => s.rtcp_packets += 1,
                                }
                            }

                            // Get or create connection state
                            {
                                let mut conns = connections.write();
                                let conn = conns.entry(src_addr).or_insert_with(|| {
                                    tracing::debug!("New connection from {}", src_addr);
                                    ConnectionState::new(src_addr)
                                });
                                conn.touch();
                                conn.packets_received += 1;
                                conn.bytes_received += len as u64;
                            }

                            // Process packet based on type
                            match packet_type {
                                PacketType::Stun => {
                                    if config.stun_server_enabled {
                                        if let Some(response) = Self::handle_stun_packet(&data, src_addr) {
                                            // Send STUN response
                                            if let Err(e) = socket.send_to(&response, src_addr).await {
                                                tracing::warn!("Failed to send STUN response: {}", e);
                                            }
                                        }
                                    }
                                }
                                PacketType::Dtls => {
                                    // DTLS handshake - handled by DTLS state machine
                                    Self::handle_dtls_packet(&data, src_addr, &connections);
                                }
                                PacketType::Rtp => {
                                    // RTP media - forward to other endpoints in session
                                    Self::handle_rtp_packet(&data, src_addr, &connections, &socket, &stats).await;
                                }
                                PacketType::Rtcp => {
                                    // RTCP control - process and potentially forward
                                    Self::handle_rtcp_packet(&data, src_addr, &connections);
                                }
                            }
                        }
                        Err(e) => {
                            tracing::warn!("Receive error: {}", e);
                            {
                                let mut s = stats.write();
                                s.packets_dropped += 1;
                            }
                        }
                    }
                }
            }
        }
    }

    /// Send loop - sends packets to UDP socket
    async fn send_loop(
        socket: Arc<UdpSocket>,
        mut outgoing_rx: mpsc::UnboundedReceiver<OutgoingPacket>,
        stats: Arc<RwLock<MediaLoopStats>>,
        cancel: CancellationToken,
    ) {
        loop {
            tokio::select! {
                _ = cancel.cancelled() => {
                    tracing::info!("Send loop shutting down");
                    break;
                }
                Some(packet) = outgoing_rx.recv() => {
                    match socket.send_to(&packet.data, packet.dst_addr).await {
                        Ok(len) => {
                            let mut s = stats.write();
                            s.packets_sent += 1;
                            s.bytes_sent += len as u64;
                        }
                        Err(e) => {
                            tracing::warn!("Send error to {}: {}", packet.dst_addr, e);
                            let mut s = stats.write();
                            s.packets_dropped += 1;
                        }
                    }
                }
            }
        }
    }

    /// Cleanup loop - removes idle connections
    async fn cleanup_loop(
        connections: Arc<RwLock<HashMap<SocketAddr, ConnectionState>>>,
        stats: Arc<RwLock<MediaLoopStats>>,
        cancel: CancellationToken,
        idle_timeout: Duration,
    ) {
        let mut interval = tokio::time::interval(Duration::from_secs(10));

        loop {
            tokio::select! {
                _ = cancel.cancelled() => {
                    tracing::info!("Cleanup loop shutting down");
                    break;
                }
                _ = interval.tick() => {
                    let mut conns = connections.write();
                    let before = conns.len();
                    
                    conns.retain(|addr, conn| {
                        if conn.is_idle(idle_timeout) {
                            tracing::debug!("Removing idle connection: {}", addr);
                            false
                        } else {
                            true
                        }
                    });

                    let after = conns.len();
                    if before != after {
                        tracing::info!("Cleaned up {} idle connections", before - after);
                    }

                    // Update stats
                    stats.write().active_connections = after;
                }
            }
        }
    }

    /// Handle STUN binding request
    fn handle_stun_packet(data: &Bytes, src_addr: SocketAddr) -> Option<Bytes> {
        // Minimal STUN binding response
        // In production, use proper STUN library
        
        if data.len() < 20 {
            return None;
        }

        // Check if this is a STUN binding request (0x0001)
        let msg_type = u16::from_be_bytes([data[0], data[1]]);
        if msg_type != 0x0001 {
            return None;
        }

        // Get transaction ID (bytes 8-20)
        let transaction_id = &data[8..20];

        // Build STUN binding success response (0x0101)
        let mut response = BytesMut::with_capacity(32);
        
        // Message type: Binding Success Response
        response.extend_from_slice(&0x0101u16.to_be_bytes());
        
        // Message length (will update later)
        response.extend_from_slice(&0u16.to_be_bytes());
        
        // Magic cookie
        response.extend_from_slice(&0x2112A442u32.to_be_bytes());
        
        // Transaction ID
        response.extend_from_slice(transaction_id);

        // XOR-MAPPED-ADDRESS attribute
        let attr_type: u16 = 0x0020; // XOR-MAPPED-ADDRESS
        let attr_len: u16 = 8; // IPv4
        
        response.extend_from_slice(&attr_type.to_be_bytes());
        response.extend_from_slice(&attr_len.to_be_bytes());
        
        // Reserved + Family (IPv4 = 0x01)
        response.extend_from_slice(&[0x00, 0x01]);
        
        // XOR'd port
        let xor_port = src_addr.port() ^ 0x2112;
        response.extend_from_slice(&xor_port.to_be_bytes());
        
        // XOR'd IP address
        if let std::net::IpAddr::V4(ip) = src_addr.ip() {
            let ip_bytes = ip.octets();
            let magic = 0x2112A442u32.to_be_bytes();
            let xor_ip = [
                ip_bytes[0] ^ magic[0],
                ip_bytes[1] ^ magic[1],
                ip_bytes[2] ^ magic[2],
                ip_bytes[3] ^ magic[3],
            ];
            response.extend_from_slice(&xor_ip);
        } else {
            return None; // IPv6 not implemented in this minimal version
        }

        // Update message length
        let msg_len = (response.len() - 20) as u16;
        response[2..4].copy_from_slice(&msg_len.to_be_bytes());

        tracing::debug!("Sending STUN response to {}", src_addr);
        Some(response.freeze())
    }

    /// Handle DTLS packet
    fn handle_dtls_packet(
        data: &Bytes,
        src_addr: SocketAddr,
        connections: &Arc<RwLock<HashMap<SocketAddr, ConnectionState>>>,
    ) {
        // Update DTLS state
        let mut conns = connections.write();
        if let Some(conn) = conns.get_mut(&src_addr) {
            if conn.dtls_state == DtlsState::New {
                conn.dtls_state = DtlsState::Connecting;
                tracing::debug!("DTLS handshake started with {}", src_addr);
            }
            // In production, process through DTLS state machine
        }
    }

    /// Handle RTP packet - forward to other endpoints
    async fn handle_rtp_packet(
        data: &Bytes,
        src_addr: SocketAddr,
        connections: &Arc<RwLock<HashMap<SocketAddr, ConnectionState>>>,
        socket: &Arc<UdpSocket>,
        stats: &Arc<RwLock<MediaLoopStats>>,
    ) {
        // Get session ID for this source
        let session_id = {
            let conns = connections.read();
            conns.get(&src_addr).and_then(|c| c.session_id)
        };

        if let Some(session_id) = session_id {
            // Find all other endpoints in the same session
            let destinations: Vec<SocketAddr> = {
                let conns = connections.read();
                conns.iter()
                    .filter(|(addr, conn)| {
                        **addr != src_addr 
                            && conn.session_id == Some(session_id)
                            && conn.srtp_ready
                    })
                    .map(|(addr, _)| *addr)
                    .collect()
            };

            // Forward to all destinations
            for dst_addr in destinations {
                if let Err(e) = socket.send_to(data, dst_addr).await {
                    tracing::warn!("Failed to forward RTP to {}: {}", dst_addr, e);
                } else {
                    let mut s = stats.write();
                    s.packets_sent += 1;
                    s.bytes_sent += data.len() as u64;
                }
            }
        }
    }

    /// Handle RTCP packet
    fn handle_rtcp_packet(
        _data: &Bytes,
        src_addr: SocketAddr,
        _connections: &Arc<RwLock<HashMap<SocketAddr, ConnectionState>>>,
    ) {
        // RTCP packets contain:
        // - Sender Reports (SR)
        // - Receiver Reports (RR)
        // - SDES (Source Description)
        // - BYE
        // - APP-specific
        
        tracing::trace!("RTCP packet from {}", src_addr);
        // In production, parse RTCP and update bandwidth estimation
    }

    /// Associate a connection with a session
    pub fn associate_connection(
        &self,
        remote_addr: SocketAddr,
        session_id: u64,
        endpoint_id: u64,
    ) -> Result<(), MediaLoopError> {
        let mut conns = self.connections.write();
        if let Some(conn) = conns.get_mut(&remote_addr) {
            conn.session_id = Some(session_id);
            conn.endpoint_id = Some(endpoint_id);
            tracing::info!(
                "Associated {} with session {} endpoint {}",
                remote_addr, session_id, endpoint_id
            );
            Ok(())
        } else {
            Err(MediaLoopError::ConnectionNotFound(remote_addr.to_string()))
        }
    }

    /// Mark connection as SRTP ready
    pub fn set_srtp_ready(&self, remote_addr: SocketAddr) -> Result<(), MediaLoopError> {
        let mut conns = self.connections.write();
        if let Some(conn) = conns.get_mut(&remote_addr) {
            conn.srtp_ready = true;
            conn.dtls_state = DtlsState::Connected;
            tracing::info!("SRTP ready for {}", remote_addr);
            Ok(())
        } else {
            Err(MediaLoopError::ConnectionNotFound(remote_addr.to_string()))
        }
    }
}

impl Default for MediaLoop {
    fn default() -> Self {
        Self::with_defaults()
    }
}

/// Media loop errors
#[derive(Debug, Clone)]
pub enum MediaLoopError {
    AlreadyRunning,
    NotRunning,
    BindError(String),
    SendError(String),
    ConnectionNotFound(String),
}

impl std::fmt::Display for MediaLoopError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            MediaLoopError::AlreadyRunning => write!(f, "Media loop already running"),
            MediaLoopError::NotRunning => write!(f, "Media loop not running"),
            MediaLoopError::BindError(e) => write!(f, "Bind error: {}", e),
            MediaLoopError::SendError(e) => write!(f, "Send error: {}", e),
            MediaLoopError::ConnectionNotFound(addr) => write!(f, "Connection not found: {}", addr),
        }
    }
}

impl std::error::Error for MediaLoopError {}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_media_loop_config_default() {
        let config = MediaLoopConfig::default();
        assert_eq!(config.bind_addr.port(), 10000);
        assert!(config.worker_count >= 2);
        assert!(config.stun_server_enabled);
    }

    #[test]
    fn test_connection_state() {
        let addr: SocketAddr = "127.0.0.1:5000".parse().unwrap();
        let mut conn = ConnectionState::new(addr);

        assert_eq!(conn.dtls_state, DtlsState::New);
        assert!(!conn.srtp_ready);
        assert!(!conn.is_idle(Duration::from_secs(30)));

        conn.touch();
        assert!(!conn.is_idle(Duration::from_secs(30)));
    }

    #[test]
    fn test_stun_response_generation() {
        // Minimal STUN binding request
        let mut request = vec![0u8; 20];
        request[0..2].copy_from_slice(&0x0001u16.to_be_bytes()); // Binding Request
        request[2..4].copy_from_slice(&0u16.to_be_bytes()); // Length
        request[4..8].copy_from_slice(&0x2112A442u32.to_be_bytes()); // Magic cookie
        // Transaction ID (12 bytes)
        request[8..20].copy_from_slice(&[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]);

        let src_addr: SocketAddr = "192.168.1.100:12345".parse().unwrap();
        let response = MediaLoop::handle_stun_packet(&Bytes::from(request), src_addr);

        assert!(response.is_some());
        let resp = response.unwrap();
        
        // Check response type (0x0101 = Binding Success)
        assert_eq!(resp[0], 0x01);
        assert_eq!(resp[1], 0x01);
        
        // Check transaction ID preserved
        assert_eq!(&resp[8..20], &[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]);
    }

    #[test]
    fn test_media_loop_stats_default() {
        let stats = MediaLoopStats::default();
        assert_eq!(stats.packets_received, 0);
        assert_eq!(stats.packets_sent, 0);
        assert_eq!(stats.active_connections, 0);
    }
}
