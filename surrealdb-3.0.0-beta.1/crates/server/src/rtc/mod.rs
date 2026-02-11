//! # RTC Runtime Module
//!
//! This module implements the RTC runtime for SurrealDB server.
//! It provides session management, signaling routing, and RPC handlers.
//!
//! ## Architecture
//!
//! ```text
//! ┌─────────────────────────────────────────────────────────────┐
//! │                    SERVER RTC RUNTIME                       │
//! │                                                             │
//! │  ┌──────────────┐   ┌──────────────┐   ┌──────────────┐   │
//! │  │   RpcState   │──►│  RtcBridge   │──►│  Sessions    │   │
//! │  │  (handlers)  │   │ (RtcEngine)  │   │  (runtime)   │   │
//! │  └──────────────┘   └──────────────┘   └──────────────┘   │
//! │                            │                               │
//! │                            ▼                               │
//! │                    ┌──────────────┐                        │
//! │                    │ crates/rtc/  │                        │
//! │                    │ (moteur pur) │                        │
//! │                    └──────────────┘                        │
//! └─────────────────────────────────────────────────────────────┘
//! ```

// Core modules
pub mod bridge;
pub mod media_loop;
pub mod session;
pub mod sfu;
pub mod transport;

// Media processing
pub mod audio;
pub mod bandwidth;
pub mod simulcast;
pub mod spatial;

// Features
pub mod breakout;
pub mod cascade;
pub mod effects;
pub mod recording;
pub mod screen_share;
pub mod turn;

// Enterprise features
pub mod analytics;
pub mod encryption;
pub mod interactive;
pub mod lobby;
pub mod streaming;
pub mod transcription;

#[cfg(test)]
mod tests;
#[cfg(test)]
mod integration_tests;

// Core exports
pub use bridge::RtcBridge;
pub use media_loop::{MediaLoop, MediaLoopConfig, MediaLoopStats, ConnectionState, DtlsState};
pub use session::{RtcSession, RtcSessionState};
pub use sfu::{SfuError, SfuServer};
pub use transport::{CertificateManager, PacketType, TransportConfig, TransportStats, UdpTransport};

// Media processing exports
pub use audio::{
    ActiveSpeakerDetector, AudioLevel, AudioMixer, AudioProcessingConfig,
    NoiseSuppressionLevel, VoiceActivityDetector, VoiceActivityState,
};
pub use bandwidth::{BandwidthEstimator, BitrateAllocator, BweConfig, BweStats, NetworkState};
pub use simulcast::{SimulcastConfig, SimulcastLayer, SimulcastManager, SimulcastStats};
pub use spatial::{Position3D, SpatialAudioConfig, SpatialAudioManager, SpatialLayout};

// Feature exports
pub use breakout::{BreakoutConfig, BreakoutManager, BreakoutRoom, BreakoutState};
pub use cascade::{CascadeConfig, CascadeManager, CascadeNode, CascadeSession, NodeRole, Region};
pub use effects::{BackgroundEffect, BlurLevel, VideoEffectsConfig, VideoEffectsManager, VideoFilter};
pub use recording::{RecordingConfig, RecordingManager, RecordingMode, RecordingState};
pub use screen_share::{ScreenShare, ScreenShareConfig, ScreenShareManager};
pub use turn::{IceServer, TurnConfig, TurnServer};

// Enterprise feature exports
pub use analytics::{AnalyticsCollector, MeetingAnalytics, ParticipantAnalytics};
pub use encryption::{E2eeConfig, E2eeManager, E2eeSession, E2eeState};
pub use interactive::{ChatManager, Poll, PollType, QaManager, Question, ReactionManager, ReactionType};
pub use lobby::{LobbyConfig, LobbyManager, LobbyParticipant, LobbyStatus};
pub use streaming::{LiveStream, StreamConfig, StreamDestination, StreamingManager};
pub use transcription::{Language, MeetingSummary, TranscriptionConfig, TranscriptionManager};

use std::sync::Arc;

use surrealdb_core::rtc::{RtcEvent, SharedRtcEngine};
use tokio::sync::mpsc;

/// RTC runtime state for the server
pub struct RtcState {
    /// The RTC bridge implementing the RtcEngine trait (for P2P signaling)
    pub bridge: Arc<RtcBridge>,
    /// The SFU server (for multi-party conferencing)
    pub sfu: Arc<SfuServer>,
    /// Channel for broadcasting RTC events
    pub event_tx: mpsc::UnboundedSender<RtcEvent>,
    /// Channel receiver for consuming RTC events
    pub event_rx: mpsc::UnboundedReceiver<RtcEvent>,
}

impl RtcState {
    /// Create a new RTC state
    pub fn new() -> Self {
        let (event_tx, event_rx) = mpsc::unbounded_channel();
        let bridge = Arc::new(RtcBridge::new(event_tx.clone()));
        let sfu = Arc::new(SfuServer::with_defaults());
        
        Self {
            bridge,
            sfu,
            event_tx,
            event_rx,
        }
    }

    /// Create with custom SFU configuration
    pub fn with_sfu_config(sfu_config: surrealdb_core::rtc::SfuConfig) -> Self {
        let (event_tx, event_rx) = mpsc::unbounded_channel();
        let bridge = Arc::new(RtcBridge::new(event_tx.clone()));
        let sfu = Arc::new(SfuServer::new(sfu_config));
        
        Self {
            bridge,
            sfu,
            event_tx,
            event_rx,
        }
    }

    /// Get a shared reference to the RTC engine (P2P)
    pub fn engine(&self) -> SharedRtcEngine {
        self.bridge.clone()
    }

    /// Get a shared reference to the SFU server
    pub fn sfu_server(&self) -> Arc<SfuServer> {
        self.sfu.clone()
    }
}

impl Default for RtcState {
    fn default() -> Self {
        Self::new()
    }
}
