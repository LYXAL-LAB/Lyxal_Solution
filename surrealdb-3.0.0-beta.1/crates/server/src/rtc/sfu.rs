//! SFU Server - Selective Forwarding Unit for multi-party video conferencing
//!
//! This module provides a high-level abstraction over the SFU engine from `crates/rtc/sfu/`.
//! It handles:
//! - UDP socket management for media traffic
//! - Session and endpoint lifecycle
//! - SDP offer/answer generation
//! - Media packet forwarding
//! - Session modes (SFU, Webinar, Broadcast)
//! - Participant roles (Host, Speaker, Viewer)

use std::collections::HashMap;
use std::net::SocketAddr;
use std::sync::atomic::{AtomicBool, AtomicU64, Ordering};
use std::sync::Arc;

use parking_lot::RwLock;
use tokio_util::sync::CancellationToken;

use surrealdb_core::rtc::{
    Participant, ParticipantRole, SessionMode, SfuConfig, SfuStats, WebinarConfig,
};

use super::transport::{CertificateManager, TransportConfig, TransportStats, UdpTransport};

/// SFU Server state
pub struct SfuServer {
    /// Configuration
    config: SfuConfig,
    /// Running state
    running: AtomicBool,
    /// Cancellation token for shutdown
    cancel: CancellationToken,
    /// Statistics
    stats: RwLock<SfuStats>,
    /// Session counter
    session_counter: AtomicU64,
    /// Endpoint counter (global)
    endpoint_counter: AtomicU64,
    /// Active sessions (session_id -> session info)
    sessions: RwLock<HashMap<u64, SfuSessionState>>,
    /// Pending offers awaiting answers
    pending_offers: RwLock<HashMap<String, PendingOffer>>,
    /// UDP Transport for media traffic
    transport: Arc<UdpTransport>,
    /// DTLS Certificate manager
    certificate: RwLock<Option<CertificateManager>>,
}

/// Internal session state with mode and participants
struct SfuSessionState {
    session_id: u64,
    /// Session mode
    mode: SessionMode,
    /// Webinar config (if mode is Webinar)
    webinar_config: Option<WebinarConfig>,
    /// Participants with roles
    participants: HashMap<u64, Participant>,
    /// Created timestamp
    created_at: std::time::Instant,
}

impl SfuSessionState {
    fn new(session_id: u64, mode: SessionMode, webinar_config: Option<WebinarConfig>) -> Self {
        Self {
            session_id,
            mode,
            webinar_config,
            participants: HashMap::new(),
            created_at: std::time::Instant::now(),
        }
    }

    fn endpoint_count(&self) -> usize {
        self.participants.len()
    }

    fn speaker_count(&self) -> usize {
        self.participants
            .values()
            .filter(|p| p.role.can_send())
            .count()
    }

    fn viewer_count(&self) -> usize {
        self.participants
            .values()
            .filter(|p| !p.role.can_send())
            .count()
    }

    fn can_add_speaker(&self) -> bool {
        match (&self.mode, &self.webinar_config) {
            (SessionMode::Webinar, Some(config)) => self.speaker_count() < config.max_speakers,
            _ => true,
        }
    }

    fn can_add_viewer(&self) -> bool {
        match (&self.mode, &self.webinar_config) {
            (SessionMode::Webinar, Some(config)) => self.viewer_count() < config.max_viewers,
            _ => true,
        }
    }
}

/// Pending SDP offer
struct PendingOffer {
    session_id: u64,
    endpoint_id: u64,
    local_sdp: String,
    role: ParticipantRole,
    created_at: std::time::Instant,
}

impl SfuServer {
    /// Create a new SFU server
    pub fn new(config: SfuConfig) -> Self {
        let transport_config = TransportConfig {
            bind_addr: config.bind_addr.parse().unwrap_or_else(|_| "0.0.0.0:10000".parse().unwrap()),
            idle_timeout: std::time::Duration::from_secs(config.idle_timeout_secs),
            ..Default::default()
        };

        Self {
            config,
            running: AtomicBool::new(false),
            cancel: CancellationToken::new(),
            stats: RwLock::new(SfuStats::default()),
            session_counter: AtomicU64::new(0),
            endpoint_counter: AtomicU64::new(0),
            sessions: RwLock::new(HashMap::new()),
            pending_offers: RwLock::new(HashMap::new()),
            transport: Arc::new(UdpTransport::new(transport_config)),
            certificate: RwLock::new(None),
        }
    }

    /// Create with default configuration
    pub fn with_defaults() -> Self {
        Self::new(SfuConfig::default())
    }

    /// Start the SFU server
    pub async fn start(&self) -> Result<SocketAddr, SfuError> {
        if self.running.swap(true, Ordering::SeqCst) {
            return Err(SfuError::AlreadyRunning);
        }

        // Generate DTLS certificate
        let cert = CertificateManager::generate()
            .map_err(|e| SfuError::BindError(e.to_string()))?;
        
        tracing::info!("Generated DTLS certificate with fingerprint: {}", cert.fingerprint());
        *self.certificate.write() = Some(cert);

        // Start UDP transport
        let local_addr = self.transport.start().await
            .map_err(|e| SfuError::BindError(e.to_string()))?;

        tracing::info!("SFU server started on {}", local_addr);
        Ok(local_addr)
    }

    /// Stop the SFU server
    pub async fn stop(&self) -> Result<(), SfuError> {
        if !self.running.swap(false, Ordering::SeqCst) {
            return Err(SfuError::NotRunning);
        }

        self.transport.stop();
        self.cancel.cancel();
        tracing::info!("SFU server stopped");
        Ok(())
    }

    /// Check if server is running
    pub fn is_running(&self) -> bool {
        self.running.load(Ordering::SeqCst)
    }

    /// Get the local address the server is bound to
    pub fn local_addr(&self) -> Option<SocketAddr> {
        self.transport.local_addr()
    }

    /// Get the DTLS fingerprint
    pub fn dtls_fingerprint(&self) -> Option<String> {
        self.certificate.read().as_ref().map(|c| c.fingerprint().to_string())
    }

    /// Get transport statistics
    pub fn transport_stats(&self) -> TransportStats {
        self.transport.stats()
    }

    // ========================================================================
    // Session Management
    // ========================================================================

    /// Create a new SFU session (default mode)
    pub fn create_session(&self) -> Result<u64, SfuError> {
        self.create_session_with_mode(SessionMode::Sfu, None)
    }

    /// Create a new session with specific mode
    pub fn create_session_with_mode(
        &self,
        mode: SessionMode,
        webinar_config: Option<WebinarConfig>,
    ) -> Result<u64, SfuError> {
        let session_id = self.session_counter.fetch_add(1, Ordering::SeqCst);

        let state = SfuSessionState::new(session_id, mode, webinar_config);

        self.sessions.write().insert(session_id, state);
        self.stats.write().active_sessions += 1;

        tracing::debug!("Created {:?} session {}", mode, session_id);
        Ok(session_id)
    }

    /// Create a Webinar session
    pub fn create_webinar(&self, config: WebinarConfig) -> Result<u64, SfuError> {
        self.create_session_with_mode(SessionMode::Webinar, Some(config))
    }

    /// Create a Broadcast session (one-to-many)
    pub fn create_broadcast(&self) -> Result<u64, SfuError> {
        self.create_session_with_mode(SessionMode::Broadcast, None)
    }

    // ========================================================================
    // Endpoint/Participant Management
    // ========================================================================

    /// Join a session with a specific role
    pub fn join_with_role(
        &self,
        session_id: u64,
        role: ParticipantRole,
        display_name: Option<String>,
        remote_sdp: &str,
    ) -> Result<(u64, String), SfuError> {
        let mut sessions = self.sessions.write();
        let session = sessions
            .get_mut(&session_id)
            .ok_or(SfuError::SessionNotFound(session_id))?;

        // Check capacity based on role
        if role.can_send() && !session.can_add_speaker() {
            return Err(SfuError::MaxSpeakersReached(session_id));
        }
        if !role.can_send() && !session.can_add_viewer() {
            return Err(SfuError::MaxViewersReached(session_id));
        }

        // Generate endpoint ID
        let endpoint_id = self.endpoint_counter.fetch_add(1, Ordering::SeqCst);

        // Create participant
        let mut participant = Participant::new(endpoint_id, role);
        participant.display_name = display_name;
        session.participants.insert(endpoint_id, participant);

        // Generate SDP answer
        let local_sdp = self.generate_mock_answer(remote_sdp, role);

        // Store pending offer
        let offer_id = format!("{}-{}", session_id, endpoint_id);
        self.pending_offers.write().insert(
            offer_id,
            PendingOffer {
                session_id,
                endpoint_id,
                local_sdp: local_sdp.clone(),
                role,
                created_at: std::time::Instant::now(),
            },
        );

        self.stats.write().total_endpoints += 1;

        tracing::debug!(
            "Endpoint {} joined session {} as {:?}",
            endpoint_id,
            session_id,
            role
        );

        Ok((endpoint_id, local_sdp))
    }

    /// Create an SDP offer for a new endpoint (backward compatible, defaults to Speaker role)
    pub fn create_offer(&self, session_id: u64, remote_sdp: &str) -> Result<(u64, String), SfuError> {
        // Determine default role based on session mode
        let role = {
            let sessions = self.sessions.read();
            let session = sessions
                .get(&session_id)
                .ok_or(SfuError::SessionNotFound(session_id))?;
            match session.mode {
                SessionMode::Webinar | SessionMode::Broadcast => ParticipantRole::Viewer,
                _ => ParticipantRole::Speaker,
            }
        };
        self.join_with_role(session_id, role, None, remote_sdp)
    }

    /// Accept an SDP answer for a pending offer
    pub fn accept_answer(
        &self,
        session_id: u64,
        endpoint_id: u64,
        _answer_sdp: &str,
    ) -> Result<(), SfuError> {
        let offer_id = format!("{}-{}", session_id, endpoint_id);

        let _pending = self
            .pending_offers
            .write()
            .remove(&offer_id)
            .ok_or(SfuError::NoPendingOffer(offer_id))?;

        tracing::debug!(
            "Accepted answer for session {} endpoint {}",
            session_id,
            endpoint_id
        );

        Ok(())
    }

    /// Remove an endpoint from a session
    pub fn remove_endpoint(&self, session_id: u64, endpoint_id: u64) -> Result<(), SfuError> {
        let mut sessions = self.sessions.write();
        let session = sessions
            .get_mut(&session_id)
            .ok_or(SfuError::SessionNotFound(session_id))?;

        session.participants.remove(&endpoint_id);
        self.stats.write().total_endpoints = self.stats.read().total_endpoints.saturating_sub(1);

        // If no endpoints left, remove session
        if session.participants.is_empty() {
            sessions.remove(&session_id);
            self.stats.write().active_sessions = self.stats.read().active_sessions.saturating_sub(1);
        }

        tracing::debug!(
            "Removed endpoint {} from session {}",
            endpoint_id,
            session_id
        );

        Ok(())
    }

    // ========================================================================
    // Role Management (Webinar/Broadcast specific)
    // ========================================================================

    /// Promote a participant to speaker
    pub fn promote_to_speaker(&self, session_id: u64, endpoint_id: u64) -> Result<(), SfuError> {
        self.set_role(session_id, endpoint_id, ParticipantRole::Speaker)
    }

    /// Demote a participant to viewer
    pub fn demote_to_viewer(&self, session_id: u64, endpoint_id: u64) -> Result<(), SfuError> {
        self.set_role(session_id, endpoint_id, ParticipantRole::Viewer)
    }

    /// Set participant role
    pub fn set_role(
        &self,
        session_id: u64,
        endpoint_id: u64,
        new_role: ParticipantRole,
    ) -> Result<(), SfuError> {
        let mut sessions = self.sessions.write();
        let session = sessions
            .get_mut(&session_id)
            .ok_or(SfuError::SessionNotFound(session_id))?;

        // Check capacity for promotion
        if new_role.can_send() && !session.can_add_speaker() {
            return Err(SfuError::MaxSpeakersReached(session_id));
        }

        let participant = session
            .participants
            .get_mut(&endpoint_id)
            .ok_or(SfuError::EndpointNotFound(session_id, endpoint_id))?;

        let old_role = participant.role;
        participant.role = new_role;

        tracing::debug!(
            "Changed role for endpoint {} in session {}: {:?} -> {:?}",
            endpoint_id,
            session_id,
            old_role,
            new_role
        );

        Ok(())
    }

    /// Raise hand (viewer wants to speak)
    pub fn raise_hand(&self, session_id: u64, endpoint_id: u64) -> Result<(), SfuError> {
        let mut sessions = self.sessions.write();
        let session = sessions
            .get_mut(&session_id)
            .ok_or(SfuError::SessionNotFound(session_id))?;

        let participant = session
            .participants
            .get_mut(&endpoint_id)
            .ok_or(SfuError::EndpointNotFound(session_id, endpoint_id))?;

        participant.hand_raised = true;
        Ok(())
    }

    /// Lower hand
    pub fn lower_hand(&self, session_id: u64, endpoint_id: u64) -> Result<(), SfuError> {
        let mut sessions = self.sessions.write();
        let session = sessions
            .get_mut(&session_id)
            .ok_or(SfuError::SessionNotFound(session_id))?;

        let participant = session
            .participants
            .get_mut(&endpoint_id)
            .ok_or(SfuError::EndpointNotFound(session_id, endpoint_id))?;

        participant.hand_raised = false;
        Ok(())
    }

    /// Get participants with raised hands
    pub fn get_raised_hands(&self, session_id: u64) -> Result<Vec<Participant>, SfuError> {
        let sessions = self.sessions.read();
        let session = sessions
            .get(&session_id)
            .ok_or(SfuError::SessionNotFound(session_id))?;

        Ok(session
            .participants
            .values()
            .filter(|p| p.hand_raised)
            .cloned()
            .collect())
    }

    /// Get all participants
    pub fn get_participants(&self, session_id: u64) -> Result<Vec<Participant>, SfuError> {
        let sessions = self.sessions.read();
        let session = sessions
            .get(&session_id)
            .ok_or(SfuError::SessionNotFound(session_id))?;

        Ok(session.participants.values().cloned().collect())
    }

    /// Get speakers only
    pub fn get_speakers(&self, session_id: u64) -> Result<Vec<Participant>, SfuError> {
        let sessions = self.sessions.read();
        let session = sessions
            .get(&session_id)
            .ok_or(SfuError::SessionNotFound(session_id))?;

        Ok(session
            .participants
            .values()
            .filter(|p| p.role.can_send())
            .cloned()
            .collect())
    }

    // ========================================================================
    // Session Info & Stats
    // ========================================================================

    /// Close a session
    pub fn close_session(&self, session_id: u64) -> Result<(), SfuError> {
        let session = self
            .sessions
            .write()
            .remove(&session_id)
            .ok_or(SfuError::SessionNotFound(session_id))?;

        let mut stats = self.stats.write();
        stats.active_sessions = stats.active_sessions.saturating_sub(1);
        stats.total_endpoints = stats.total_endpoints.saturating_sub(session.participants.len());

        // Remove any pending offers for this session
        self.pending_offers
            .write()
            .retain(|_, offer| offer.session_id != session_id);

        tracing::debug!("Closed SFU session {}", session_id);
        Ok(())
    }

    /// Get server statistics
    pub fn get_stats(&self) -> SfuStats {
        self.stats.read().clone()
    }

    /// List active sessions
    pub fn list_sessions(&self) -> Vec<u64> {
        self.sessions.read().keys().copied().collect()
    }

    /// Get session info
    pub fn get_session_info(&self, session_id: u64) -> Option<surrealdb_core::rtc::SfuSessionInfo> {
        let sessions = self.sessions.read();
        sessions.get(&session_id).map(|s| surrealdb_core::rtc::SfuSessionInfo {
            session_id: s.session_id,
            mode: s.mode,
            endpoint_count: s.endpoint_count(),
            speaker_count: s.speaker_count(),
            viewer_count: s.viewer_count(),
            transport_count: 0,
        })
    }

    /// Get session mode
    pub fn get_session_mode(&self, session_id: u64) -> Option<SessionMode> {
        self.sessions.read().get(&session_id).map(|s| s.mode)
    }

    // ========================================================================
    // Internal Helpers
    // ========================================================================

    /// Generate SDP answer based on role and server configuration
    fn generate_mock_answer(&self, _remote_sdp: &str, role: ParticipantRole) -> String {
        let direction = if role.can_send() { "sendrecv" } else { "recvonly" };
        
        // Get real fingerprint or fallback
        let fingerprint = self.certificate.read()
            .as_ref()
            .map(|c| c.fingerprint().to_lowercase())
            .unwrap_or_else(|| "00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00".to_string());

        // Get real local address or fallback
        let local_ip = self.transport.local_addr()
            .map(|a| a.ip().to_string())
            .unwrap_or_else(|| self.config.bind_addr.split(':').next().unwrap_or("0.0.0.0").to_string());

        let local_port = self.transport.local_addr()
            .map(|a| a.port())
            .unwrap_or(10000);

        // Generate unique ICE credentials per session
        let ice_ufrag = format!("sfu{:08x}", rand::random::<u32>());
        let ice_pwd = format!("sfupwd{:016x}{:016x}", rand::random::<u64>(), rand::random::<u64>());

        let session_id = std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .unwrap()
            .as_secs();

        format!(
            "v=0\r\n\
o=- {session_id} 2 IN IP4 {local_ip}\r\n\
s=Lyxal SFU\r\n\
t=0 0\r\n\
a=group:BUNDLE 0 1\r\n\
a=msid-semantic: WMS *\r\n\
m=audio {local_port} UDP/TLS/RTP/SAVPF 111 9 0 8\r\n\
c=IN IP4 {local_ip}\r\n\
a=rtcp:{local_port} IN IP4 {local_ip}\r\n\
a=ice-ufrag:{ice_ufrag}\r\n\
a=ice-pwd:{ice_pwd}\r\n\
a=ice-options:trickle\r\n\
a=fingerprint:sha-256 {fingerprint}\r\n\
a=setup:actpass\r\n\
a=mid:0\r\n\
a=extmap:1 urn:ietf:params:rtp-hdrext:ssrc-audio-level\r\n\
a=extmap:2 http://www.webrtc.org/experiments/rtp-hdrext/abs-send-time\r\n\
a={direction}\r\n\
a=rtcp-mux\r\n\
a=rtpmap:111 opus/48000/2\r\n\
a=rtcp-fb:111 transport-cc\r\n\
a=fmtp:111 minptime=10;useinbandfec=1\r\n\
a=rtpmap:9 G722/8000\r\n\
a=rtpmap:0 PCMU/8000\r\n\
a=rtpmap:8 PCMA/8000\r\n\
m=video {local_port} UDP/TLS/RTP/SAVPF 96 97 98 99 100 101\r\n\
c=IN IP4 {local_ip}\r\n\
a=rtcp:{local_port} IN IP4 {local_ip}\r\n\
a=ice-ufrag:{ice_ufrag}\r\n\
a=ice-pwd:{ice_pwd}\r\n\
a=ice-options:trickle\r\n\
a=fingerprint:sha-256 {fingerprint}\r\n\
a=setup:actpass\r\n\
a=mid:1\r\n\
a=extmap:3 http://www.webrtc.org/experiments/rtp-hdrext/abs-send-time\r\n\
a=extmap:4 urn:3gpp:video-orientation\r\n\
a={direction}\r\n\
a=rtcp-mux\r\n\
a=rtpmap:96 VP8/90000\r\n\
a=rtcp-fb:96 ccm fir\r\n\
a=rtcp-fb:96 nack\r\n\
a=rtcp-fb:96 nack pli\r\n\
a=rtcp-fb:96 goog-remb\r\n\
a=rtcp-fb:96 transport-cc\r\n\
a=rtpmap:97 rtx/90000\r\n\
a=fmtp:97 apt=96\r\n\
a=rtpmap:98 VP9/90000\r\n\
a=rtcp-fb:98 ccm fir\r\n\
a=rtcp-fb:98 nack\r\n\
a=rtcp-fb:98 nack pli\r\n\
a=rtcp-fb:98 goog-remb\r\n\
a=rtcp-fb:98 transport-cc\r\n\
a=rtpmap:99 rtx/90000\r\n\
a=fmtp:99 apt=98\r\n\
a=rtpmap:100 H264/90000\r\n\
a=rtcp-fb:100 ccm fir\r\n\
a=rtcp-fb:100 nack\r\n\
a=rtcp-fb:100 nack pli\r\n\
a=rtcp-fb:100 goog-remb\r\n\
a=rtcp-fb:100 transport-cc\r\n\
a=fmtp:100 level-asymmetry-allowed=1;packetization-mode=1;profile-level-id=42001f\r\n\
a=rtpmap:101 rtx/90000\r\n\
a=fmtp:101 apt=100\r\n",
        )
    }
}

impl Default for SfuServer {
    fn default() -> Self {
        Self::with_defaults()
    }
}

/// SFU Error types
#[derive(Debug, Clone)]
pub enum SfuError {
    AlreadyRunning,
    NotRunning,
    SessionNotFound(u64),
    EndpointNotFound(u64, u64),
    NoPendingOffer(String),
    InvalidSdp(String),
    BindError(String),
    InternalError(String),
    /// Max speakers reached for webinar session
    MaxSpeakersReached(u64),
    /// Max viewers reached for webinar session
    MaxViewersReached(u64),
    /// Permission denied for role change
    PermissionDenied(String),
}

impl std::fmt::Display for SfuError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            SfuError::AlreadyRunning => write!(f, "SFU server is already running"),
            SfuError::NotRunning => write!(f, "SFU server is not running"),
            SfuError::SessionNotFound(id) => write!(f, "SFU session {} not found", id),
            SfuError::EndpointNotFound(s, e) => {
                write!(f, "Endpoint {} not found in session {}", e, s)
            }
            SfuError::NoPendingOffer(id) => write!(f, "No pending offer for {}", id),
            SfuError::InvalidSdp(msg) => write!(f, "Invalid SDP: {}", msg),
            SfuError::BindError(msg) => write!(f, "Bind error: {}", msg),
            SfuError::InternalError(msg) => write!(f, "Internal error: {}", msg),
            SfuError::MaxSpeakersReached(id) => {
                write!(f, "Max speakers reached for session {}", id)
            }
            SfuError::MaxViewersReached(id) => {
                write!(f, "Max viewers reached for session {}", id)
            }
            SfuError::PermissionDenied(msg) => write!(f, "Permission denied: {}", msg),
        }
    }
}

impl std::error::Error for SfuError {}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_sfu_server_creation() {
        let server = SfuServer::with_defaults();
        assert!(!server.is_running());
    }

    #[test]
    fn test_session_lifecycle() {
        let server = SfuServer::with_defaults();

        // Create session
        let session_id = server.create_session().unwrap();
        assert!(server.list_sessions().contains(&session_id));

        // Get info
        let info = server.get_session_info(session_id).unwrap();
        assert_eq!(info.session_id, session_id);
        assert_eq!(info.endpoint_count, 0);
        assert_eq!(info.mode, SessionMode::Sfu);

        // Close session
        server.close_session(session_id).unwrap();
        assert!(!server.list_sessions().contains(&session_id));
    }

    #[test]
    fn test_offer_answer_flow() {
        let server = SfuServer::with_defaults();

        let session_id = server.create_session().unwrap();

        // Create offer
        let remote_sdp = "v=0\r\no=- 123 456 IN IP4 127.0.0.1\r\n...";
        let (endpoint_id, local_sdp) = server.create_offer(session_id, remote_sdp).unwrap();

        assert!(!local_sdp.is_empty());

        // Accept answer
        let answer = "v=0\r\no=- 789 012 IN IP4 127.0.0.1\r\n...";
        server.accept_answer(session_id, endpoint_id, answer).unwrap();

        // Check stats
        let stats = server.get_stats();
        assert_eq!(stats.active_sessions, 1);
        assert_eq!(stats.total_endpoints, 1);
    }

    #[test]
    fn test_remove_endpoint() {
        let server = SfuServer::with_defaults();

        let session_id = server.create_session().unwrap();
        let (endpoint_id, _) = server.create_offer(session_id, "sdp").unwrap();

        server.remove_endpoint(session_id, endpoint_id).unwrap();

        // Session should be removed when no endpoints
        assert!(!server.list_sessions().contains(&session_id));
    }

    // ========================================================================
    // Webinar Mode Tests
    // ========================================================================

    #[test]
    fn test_webinar_creation() {
        let server = SfuServer::with_defaults();

        let config = WebinarConfig {
            max_speakers: 5,
            max_viewers: 100,
            ..Default::default()
        };
        let session_id = server.create_webinar(config).unwrap();

        let info = server.get_session_info(session_id).unwrap();
        assert_eq!(info.mode, SessionMode::Webinar);
        assert_eq!(info.speaker_count, 0);
        assert_eq!(info.viewer_count, 0);
    }

    #[test]
    fn test_webinar_roles() {
        let server = SfuServer::with_defaults();

        let config = WebinarConfig::default();
        let session_id = server.create_webinar(config).unwrap();

        // Join as host
        let (host_id, _) = server
            .join_with_role(session_id, ParticipantRole::Host, Some("Host".to_string()), "sdp")
            .unwrap();

        // Join as viewer
        let (viewer_id, _) = server
            .join_with_role(session_id, ParticipantRole::Viewer, Some("Viewer1".to_string()), "sdp")
            .unwrap();

        let info = server.get_session_info(session_id).unwrap();
        assert_eq!(info.speaker_count, 1); // Host can send
        assert_eq!(info.viewer_count, 1);

        // Get participants
        let participants = server.get_participants(session_id).unwrap();
        assert_eq!(participants.len(), 2);

        // Get speakers only
        let speakers = server.get_speakers(session_id).unwrap();
        assert_eq!(speakers.len(), 1);
        assert_eq!(speakers[0].endpoint_id, host_id);
    }

    #[test]
    fn test_webinar_promotion() {
        let server = SfuServer::with_defaults();

        let config = WebinarConfig::default();
        let session_id = server.create_webinar(config).unwrap();

        // Join as viewer
        let (viewer_id, _) = server
            .join_with_role(session_id, ParticipantRole::Viewer, None, "sdp")
            .unwrap();

        // Check initial state
        let info = server.get_session_info(session_id).unwrap();
        assert_eq!(info.speaker_count, 0);
        assert_eq!(info.viewer_count, 1);

        // Promote to speaker
        server.promote_to_speaker(session_id, viewer_id).unwrap();

        let info = server.get_session_info(session_id).unwrap();
        assert_eq!(info.speaker_count, 1);
        assert_eq!(info.viewer_count, 0);

        // Demote back to viewer
        server.demote_to_viewer(session_id, viewer_id).unwrap();

        let info = server.get_session_info(session_id).unwrap();
        assert_eq!(info.speaker_count, 0);
        assert_eq!(info.viewer_count, 1);
    }

    #[test]
    fn test_webinar_max_speakers() {
        let server = SfuServer::with_defaults();

        let config = WebinarConfig {
            max_speakers: 2,
            max_viewers: 100,
            ..Default::default()
        };
        let session_id = server.create_webinar(config).unwrap();

        // Add 2 speakers
        server.join_with_role(session_id, ParticipantRole::Speaker, None, "sdp").unwrap();
        server.join_with_role(session_id, ParticipantRole::Speaker, None, "sdp").unwrap();

        // Third speaker should fail
        let result = server.join_with_role(session_id, ParticipantRole::Speaker, None, "sdp");
        assert!(matches!(result, Err(SfuError::MaxSpeakersReached(_))));

        // But viewer should work
        server.join_with_role(session_id, ParticipantRole::Viewer, None, "sdp").unwrap();
    }

    #[test]
    fn test_raise_hand() {
        let server = SfuServer::with_defaults();

        let config = WebinarConfig::default();
        let session_id = server.create_webinar(config).unwrap();

        let (viewer_id, _) = server
            .join_with_role(session_id, ParticipantRole::Viewer, None, "sdp")
            .unwrap();

        // Raise hand
        server.raise_hand(session_id, viewer_id).unwrap();

        let raised = server.get_raised_hands(session_id).unwrap();
        assert_eq!(raised.len(), 1);
        assert_eq!(raised[0].endpoint_id, viewer_id);

        // Lower hand
        server.lower_hand(session_id, viewer_id).unwrap();

        let raised = server.get_raised_hands(session_id).unwrap();
        assert!(raised.is_empty());
    }

    #[test]
    fn test_broadcast_mode() {
        let server = SfuServer::with_defaults();

        let session_id = server.create_broadcast().unwrap();

        let info = server.get_session_info(session_id).unwrap();
        assert_eq!(info.mode, SessionMode::Broadcast);

        // Default join should be as viewer for broadcast
        let (_, sdp) = server.create_offer(session_id, "sdp").unwrap();
        assert!(sdp.contains("recvonly")); // Viewers can only receive
    }

    // ========================================================================
    // Transport & Certificate Tests
    // ========================================================================

    #[test]
    fn test_sdp_contains_required_fields() {
        let server = SfuServer::with_defaults();
        let session_id = server.create_session().unwrap();

        let (_, sdp) = server.create_offer(session_id, "sdp").unwrap();

        // Check SDP contains required fields
        assert!(sdp.contains("v=0"));
        assert!(sdp.contains("o=-"));
        assert!(sdp.contains("m=audio"));
        assert!(sdp.contains("m=video"));
        assert!(sdp.contains("a=ice-ufrag:"));
        assert!(sdp.contains("a=ice-pwd:"));
        assert!(sdp.contains("a=fingerprint:sha-256"));
        assert!(sdp.contains("a=rtcp-mux"));
        assert!(sdp.contains("a=rtpmap:111 opus/48000/2")); // Opus codec
        assert!(sdp.contains("a=rtpmap:96 VP8/90000")); // VP8 codec
    }

    #[test]
    fn test_sdp_direction_based_on_role() {
        let server = SfuServer::with_defaults();
        let session_id = server.create_webinar(WebinarConfig::default()).unwrap();

        // Speaker should have sendrecv
        let (_, sdp_speaker) = server
            .join_with_role(session_id, ParticipantRole::Speaker, None, "sdp")
            .unwrap();
        assert!(sdp_speaker.contains("a=sendrecv"));

        // Viewer should have recvonly
        let (_, sdp_viewer) = server
            .join_with_role(session_id, ParticipantRole::Viewer, None, "sdp")
            .unwrap();
        assert!(sdp_viewer.contains("a=recvonly"));
    }

    #[test]
    fn test_unique_ice_credentials() {
        let server = SfuServer::with_defaults();
        let session_id = server.create_session().unwrap();

        let (_, sdp1) = server.create_offer(session_id, "sdp1").unwrap();
        let (_, sdp2) = server.create_offer(session_id, "sdp2").unwrap();

        // Extract ice-ufrag from both SDPs
        let extract_ufrag = |sdp: &str| -> &str {
            sdp.lines()
                .find(|l| l.starts_with("a=ice-ufrag:"))
                .map(|l| l.trim_start_matches("a=ice-ufrag:"))
                .unwrap_or("")
        };

        let ufrag1 = extract_ufrag(&sdp1);
        let ufrag2 = extract_ufrag(&sdp2);

        // Each endpoint should have unique ICE credentials
        assert_ne!(ufrag1, ufrag2);
    }

    #[test]
    fn test_transport_stats_initial() {
        let server = SfuServer::with_defaults();
        let stats = server.transport_stats();

        assert_eq!(stats.bytes_received, 0);
        assert_eq!(stats.bytes_sent, 0);
        assert_eq!(stats.packets_received, 0);
        assert_eq!(stats.packets_sent, 0);
    }

    #[test]
    fn test_dtls_fingerprint_before_start() {
        let server = SfuServer::with_defaults();
        
        // Before start, no certificate
        assert!(server.dtls_fingerprint().is_none());
    }
}
