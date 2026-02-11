//! RTC Types - Pure data structures for RTC contract
//!
//! These types are runtime-agnostic and contain no state management.

use serde::{Deserialize, Serialize};
use std::time::Duration;
use uuid::Uuid;

// ============================================================================
// Identifiers
// ============================================================================

/// Unique identifier for an RTC peer
#[derive(Debug, Clone, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub struct RtcPeerId(pub Uuid);

impl RtcPeerId {
    /// Create a new random peer ID
    pub fn new() -> Self {
        Self(Uuid::new_v4())
    }

    /// Create from an existing UUID
    pub fn from_uuid(uuid: Uuid) -> Self {
        Self(uuid)
    }
}

impl Default for RtcPeerId {
    fn default() -> Self {
        Self::new()
    }
}

impl std::fmt::Display for RtcPeerId {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.0)
    }
}

/// Unique identifier for an RTC session
#[derive(Debug, Clone, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub struct RtcSessionId(pub String);

impl RtcSessionId {
    /// Create a new session ID from a string
    pub fn new(id: impl Into<String>) -> Self {
        Self(id.into())
    }
}

impl std::fmt::Display for RtcSessionId {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.0)
    }
}

// ============================================================================
// Signaling Types
// ============================================================================

/// RTC signaling message (SDP or ICE)
#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum RtcSignal {
    /// SDP Offer
    Offer(SessionDescription),
    /// SDP Answer
    Answer(SessionDescription),
    /// SDP Pranswer (provisional answer)
    Pranswer(SessionDescription),
    /// ICE Candidate
    Ice(IceCandidate),
    /// ICE Candidate removal
    IceRemoval(IceCandidate),
    /// Renegotiation needed
    Renegotiate,
}

/// Session Description Protocol (SDP) content
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SessionDescription {
    /// SDP type
    pub sdp_type: SdpType,
    /// The SDP string
    pub sdp: String,
}

impl SessionDescription {
    /// Create a new offer SDP
    pub fn offer(sdp: String) -> Self {
        Self {
            sdp_type: SdpType::Offer,
            sdp,
        }
    }

    /// Create a new answer SDP
    pub fn answer(sdp: String) -> Self {
        Self {
            sdp_type: SdpType::Answer,
            sdp,
        }
    }
}

/// SDP type
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum SdpType {
    Offer,
    Answer,
    Pranswer,
    Rollback,
}

/// ICE candidate information
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct IceCandidate {
    /// The candidate string
    pub candidate: String,
    /// SDP mid (media stream identification)
    pub sdp_mid: Option<String>,
    /// SDP m-line index
    pub sdp_m_line_index: Option<u16>,
}

impl IceCandidate {
    /// Create a new ICE candidate
    pub fn new(candidate: String, sdp_mid: Option<String>, sdp_m_line_index: Option<u16>) -> Self {
        Self {
            candidate,
            sdp_mid,
            sdp_m_line_index,
        }
    }

    /// Check if this is an end-of-candidates marker
    pub fn is_end_of_candidates(&self) -> bool {
        self.candidate.is_empty()
    }
}

// ============================================================================
// Configuration
// ============================================================================

/// RTC configuration options (pure data, no runtime)
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RtcConfig {
    /// ICE servers for NAT traversal
    pub ice_servers: Vec<IceServer>,
    /// Maximum time to wait for ICE gathering
    pub ice_gathering_timeout: Duration,
    /// Enable data channels
    pub data_channels_enabled: bool,
    /// Enable audio
    pub audio_enabled: bool,
    /// Enable video
    pub video_enabled: bool,
}

impl Default for RtcConfig {
    fn default() -> Self {
        Self {
            ice_servers: vec![IceServer {
                urls: vec!["stun:stun.l.google.com:19302".to_string()],
                username: None,
                credential: None,
            }],
            ice_gathering_timeout: Duration::from_secs(30),
            data_channels_enabled: true,
            audio_enabled: true,
            video_enabled: true,
        }
    }
}

/// ICE server configuration
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct IceServer {
    /// STUN/TURN server URLs
    pub urls: Vec<String>,
    /// Username for TURN servers
    pub username: Option<String>,
    /// Credential for TURN servers
    pub credential: Option<String>,
}

// ============================================================================
// Events (logical, no channels)
// ============================================================================

/// RTC event (logical representation, no runtime)
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RtcEvent {
    /// Session ID this event belongs to
    pub session_id: RtcSessionId,
    /// Peer ID that generated this event
    pub peer_id: RtcPeerId,
    /// Event type
    pub event_type: RtcEventType,
    /// Event timestamp (milliseconds since epoch)
    pub timestamp: u64,
}

/// Types of RTC events
#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum RtcEventType {
    /// Peer joined the session
    PeerJoined,
    /// Peer left the session
    PeerLeft { reason: Option<String> },
    /// Connection state changed
    ConnectionStateChanged { state: ConnectionState },
    /// ICE connection state changed
    IceStateChanged { state: IceConnectionState },
    /// Data channel event
    DataChannel { label: String, event: DataChannelEvent },
    /// Error occurred
    Error { message: String },
}

/// Data channel event type
#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum DataChannelEvent {
    Opened,
    Closed,
    Message { data: Vec<u8>, is_binary: bool },
}

/// Peer connection state
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum ConnectionState {
    New,
    Connecting,
    Connected,
    Disconnected,
    Failed,
    Closed,
}

/// ICE connection state
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum IceConnectionState {
    New,
    Checking,
    Connected,
    Completed,
    Failed,
    Disconnected,
    Closed,
}

// ============================================================================
// Session Modes & Roles
// ============================================================================

/// Session mode determines the communication topology
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum SessionMode {
    /// Peer-to-peer: direct connection between 2 participants
    /// Best for: 1:1 calls (WhatsApp, FaceTime style)
    P2P,
    /// Selective Forwarding Unit: server forwards streams
    /// Best for: small meetings 2-100 participants (Google Meet style)
    Sfu,
    /// Webinar: few speakers, many viewers
    /// Best for: large events 100-10000 participants (Zoom Webinar style)
    Webinar,
    /// Broadcast: one-to-many, viewers can't speak
    /// Best for: live streaming (YouTube Live, Twitch style)
    Broadcast,
}

impl Default for SessionMode {
    fn default() -> Self {
        Self::Sfu
    }
}

/// Participant role in a session
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum ParticipantRole {
    /// Host: full control, can promote/demote others
    Host,
    /// Co-host: can manage participants
    CoHost,
    /// Speaker: can send audio/video
    Speaker,
    /// Viewer: can only receive, not send
    Viewer,
    /// Waiting: in waiting room, not yet admitted
    Waiting,
}

impl Default for ParticipantRole {
    fn default() -> Self {
        Self::Viewer
    }
}

impl ParticipantRole {
    /// Check if this role can send media
    pub fn can_send(&self) -> bool {
        matches!(self, Self::Host | Self::CoHost | Self::Speaker)
    }

    /// Check if this role can receive media
    pub fn can_receive(&self) -> bool {
        !matches!(self, Self::Waiting)
    }

    /// Check if this role can manage participants
    pub fn can_manage(&self) -> bool {
        matches!(self, Self::Host | Self::CoHost)
    }

    /// Check if this role can promote/demote others
    pub fn can_promote(&self) -> bool {
        matches!(self, Self::Host | Self::CoHost)
    }
}

/// Participant info with role
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Participant {
    /// Unique endpoint ID
    pub endpoint_id: u64,
    /// Display name
    pub display_name: Option<String>,
    /// Role in the session
    pub role: ParticipantRole,
    /// Is audio muted
    pub audio_muted: bool,
    /// Is video muted
    pub video_muted: bool,
    /// Is screen sharing
    pub screen_sharing: bool,
    /// Is hand raised
    pub hand_raised: bool,
    /// Join timestamp (unix millis)
    pub joined_at: u64,
}

impl Participant {
    /// Create a new participant
    pub fn new(endpoint_id: u64, role: ParticipantRole) -> Self {
        Self {
            endpoint_id,
            display_name: None,
            role,
            audio_muted: false,
            video_muted: false,
            screen_sharing: false,
            hand_raised: false,
            joined_at: std::time::SystemTime::now()
                .duration_since(std::time::UNIX_EPOCH)
                .unwrap_or_default()
                .as_millis() as u64,
        }
    }
}

/// Webinar-specific configuration
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct WebinarConfig {
    /// Maximum number of speakers allowed
    pub max_speakers: usize,
    /// Maximum number of viewers allowed
    pub max_viewers: usize,
    /// Enable waiting room
    pub waiting_room_enabled: bool,
    /// Allow viewers to raise hand
    pub raise_hand_enabled: bool,
    /// Allow Q&A
    pub qa_enabled: bool,
    /// Allow chat
    pub chat_enabled: bool,
    /// Record the session
    pub recording_enabled: bool,
}

impl Default for WebinarConfig {
    fn default() -> Self {
        Self {
            max_speakers: 10,
            max_viewers: 1000,
            waiting_room_enabled: false,
            raise_hand_enabled: true,
            qa_enabled: true,
            chat_enabled: true,
            recording_enabled: false,
        }
    }
}

impl WebinarConfig {
    /// Configuration for large webinars (1000+ viewers)
    pub fn large() -> Self {
        Self {
            max_speakers: 25,
            max_viewers: 10000,
            waiting_room_enabled: true,
            raise_hand_enabled: true,
            qa_enabled: true,
            chat_enabled: true,
            recording_enabled: true,
        }
    }

    /// Configuration for small webinars (< 100 viewers)
    pub fn small() -> Self {
        Self {
            max_speakers: 5,
            max_viewers: 100,
            waiting_room_enabled: false,
            raise_hand_enabled: true,
            qa_enabled: true,
            chat_enabled: true,
            recording_enabled: false,
        }
    }
}

// ============================================================================
// SFU Types
// ============================================================================

/// SFU server configuration
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SfuConfig {
    /// UDP bind address for media traffic
    pub bind_addr: String,
    /// Idle timeout in seconds
    pub idle_timeout_secs: u64,
    /// Enable DTLS
    pub dtls_enabled: bool,
    /// Max sessions
    pub max_sessions: Option<usize>,
    /// Max endpoints per session
    pub max_endpoints_per_session: Option<usize>,
}

impl Default for SfuConfig {
    fn default() -> Self {
        Self {
            bind_addr: "0.0.0.0:10000".to_string(),
            idle_timeout_secs: 30,
            dtls_enabled: true,
            max_sessions: None,
            max_endpoints_per_session: None,
        }
    }
}

/// SFU session info
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SfuSessionInfo {
    /// Session ID
    pub session_id: u64,
    /// Session mode
    pub mode: SessionMode,
    /// Number of endpoints in this session
    pub endpoint_count: usize,
    /// Number of speakers (for Webinar mode)
    pub speaker_count: usize,
    /// Number of viewers (for Webinar mode)
    pub viewer_count: usize,
    /// Active transports count
    pub transport_count: usize,
}

/// SFU endpoint info
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SfuEndpointInfo {
    /// Endpoint ID
    pub endpoint_id: u64,
    /// Session ID this endpoint belongs to
    pub session_id: u64,
    /// Number of media tracks
    pub track_count: usize,
    /// Is renegotiation needed
    pub renegotiation_needed: bool,
}

/// SFU server statistics
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SfuStats {
    /// Number of active sessions
    pub active_sessions: usize,
    /// Total number of endpoints
    pub total_endpoints: usize,
    /// Total number of active transports
    pub total_transports: usize,
    /// Bytes sent
    pub bytes_sent: u64,
    /// Bytes received
    pub bytes_received: u64,
    /// Packets sent
    pub packets_sent: u64,
    /// Packets received
    pub packets_received: u64,
}

impl Default for SfuStats {
    fn default() -> Self {
        Self {
            active_sessions: 0,
            total_endpoints: 0,
            total_transports: 0,
            bytes_sent: 0,
            bytes_received: 0,
            packets_sent: 0,
            packets_received: 0,
        }
    }
}
