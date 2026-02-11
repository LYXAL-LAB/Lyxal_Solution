//! RTC Error types - Pure error definitions

use std::fmt;

/// Errors that can occur during RTC operations
#[derive(Debug, Clone)]
pub enum RtcError {
    /// Session not found
    SessionNotFound(String),
    /// Session already exists
    SessionExists(String),
    /// Peer not found in session
    PeerNotFound(String),
    /// Peer already in session
    PeerExists(String),
    /// Invalid signaling message
    InvalidSignaling(String),
    /// Invalid SDP
    InvalidSdp(String),
    /// Invalid ICE candidate
    InvalidIceCandidate(String),
    /// Connection failed
    ConnectionFailed(String),
    /// Session is closed
    SessionClosed,
    /// Session is full
    SessionFull(usize),
    /// Internal engine error
    EngineError(String),
    /// Configuration error
    ConfigError(String),
    /// Timeout
    Timeout,
    /// Not authorized
    Unauthorized,
}

impl fmt::Display for RtcError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            RtcError::SessionNotFound(id) => write!(f, "RTC session not found: {}", id),
            RtcError::SessionExists(id) => write!(f, "RTC session already exists: {}", id),
            RtcError::PeerNotFound(id) => write!(f, "Peer not found: {}", id),
            RtcError::PeerExists(id) => write!(f, "Peer already in session: {}", id),
            RtcError::InvalidSignaling(msg) => write!(f, "Invalid signaling: {}", msg),
            RtcError::InvalidSdp(msg) => write!(f, "Invalid SDP: {}", msg),
            RtcError::InvalidIceCandidate(msg) => write!(f, "Invalid ICE candidate: {}", msg),
            RtcError::ConnectionFailed(msg) => write!(f, "Connection failed: {}", msg),
            RtcError::SessionClosed => write!(f, "RTC session is closed"),
            RtcError::SessionFull(max) => write!(f, "Session is full (max: {})", max),
            RtcError::EngineError(msg) => write!(f, "RTC engine error: {}", msg),
            RtcError::ConfigError(msg) => write!(f, "RTC config error: {}", msg),
            RtcError::Timeout => write!(f, "RTC operation timed out"),
            RtcError::Unauthorized => write!(f, "Not authorized for RTC operation"),
        }
    }
}

impl std::error::Error for RtcError {}

impl From<RtcError> for crate::err::Error {
    fn from(err: RtcError) -> Self {
        crate::err::Error::Internal(err.to_string())
    }
}
