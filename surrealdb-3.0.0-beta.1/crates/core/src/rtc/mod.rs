//! # RTC Contract (Real-Time Communication)
//!
//! This module defines the **contract** for RTC integration in SurrealDB.
//! It contains only types, traits, and errors - no runtime logic.
//!
//! ## Architecture
//!
//! ```text
//! ┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
//! │  crates/rtc/    │     │  core/src/rtc/  │     │ server/src/rtc/ │
//! │  (moteur pur)   │◄────│   (contrat)     │◄────│  (applicatif)   │
//! │  Sans-IO        │     │  Types+Traits   │     │  Runtime        │
//! └─────────────────┘     └─────────────────┘     └─────────────────┘
//! ```
//!
//! - `crates/rtc/` : Pure Sans-IO WebRTC engine (no SurrealDB dependencies)
//! - `core/src/rtc/` : Contract types and traits (this module)
//! - `server/src/rtc/` : Runtime implementation (sessions, bridge, handlers)

mod error;
mod types;

pub use error::RtcError;
pub use types::{
    IceCandidate, RtcConfig, RtcEvent, RtcEventType, RtcPeerId, RtcSessionId, RtcSignal,
    SessionDescription, SdpType,
    // Session modes & roles
    SessionMode, ParticipantRole, Participant, WebinarConfig,
    // SFU types
    SfuConfig, SfuEndpointInfo, SfuSessionInfo, SfuStats,
};

use std::sync::Arc;

/// Trait defining the RTC engine contract.
///
/// This trait is implemented by `server/` using the `crates/rtc/` engine.
/// It provides a minimal interface for RTC operations without any runtime specifics.
#[allow(async_fn_in_trait)]
pub trait RtcEngine: Send + Sync {
    /// Send a signaling message to the engine
    fn signal(
        &self,
        session: &RtcSessionId,
        from: &RtcPeerId,
        to: Option<&RtcPeerId>,
        signal: RtcSignal,
    ) -> Result<u64, RtcError>;

    /// Poll for pending signals for a peer
    fn poll(&self, session: &RtcSessionId, peer: &RtcPeerId) -> Vec<RtcSignal>;

    /// Create a new session
    fn create_session(&self, session_id: RtcSessionId, config: Option<RtcConfig>) -> Result<(), RtcError>;

    /// Join a session
    fn join_session(
        &self,
        session: &RtcSessionId,
        peer: RtcPeerId,
    ) -> Result<Vec<RtcPeerId>, RtcError>;

    /// Leave a session
    fn leave_session(&self, session: &RtcSessionId, peer: &RtcPeerId) -> Result<(), RtcError>;

    /// Close a session
    fn close_session(&self, session: &RtcSessionId) -> Result<(), RtcError>;

    /// List active sessions
    fn list_sessions(&self) -> Vec<RtcSessionId>;

    /// Get peers in a session
    fn get_peers(&self, session: &RtcSessionId) -> Result<Vec<RtcPeerId>, RtcError>;
}

/// Thread-safe RTC engine handle
pub type SharedRtcEngine = Arc<dyn RtcEngine>;
