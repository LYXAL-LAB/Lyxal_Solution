//! RTC Session Management
//!
//! Runtime session management for RTC connections.

use std::collections::HashMap;
use std::time::Instant;

use surrealdb_core::rtc::{
    RtcConfig, RtcError, RtcEvent, RtcEventType, RtcPeerId, RtcSessionId, RtcSignal,
};

/// State of an RTC session
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum RtcSessionState {
    /// Session is being created
    Creating,
    /// Session is active and accepting peers
    Active,
    /// Session is closing
    Closing,
    /// Session is closed
    Closed,
}

/// Information about a peer in a session
#[derive(Debug, Clone)]
pub struct PeerInfo {
    /// Peer ID
    pub id: RtcPeerId,
    /// When the peer joined
    pub joined_at: Instant,
    /// User ID (from SurrealDB session)
    pub user_id: Option<String>,
}

/// An RTC session containing multiple peers
pub struct RtcSession {
    /// Session ID
    pub id: RtcSessionId,
    /// Session state
    pub state: RtcSessionState,
    /// Session configuration
    pub config: RtcConfig,
    /// Peers in this session
    pub peers: HashMap<RtcPeerId, PeerInfo>,
    /// Pending signals per peer
    pub pending_signals: HashMap<RtcPeerId, Vec<RtcSignal>>,
    /// Session creation time
    pub created_at: Instant,
    /// Maximum number of peers allowed
    pub max_peers: Option<usize>,
}

impl RtcSession {
    /// Create a new RTC session
    pub fn new(id: RtcSessionId, config: RtcConfig) -> Self {
        Self {
            id,
            state: RtcSessionState::Creating,
            config,
            peers: HashMap::new(),
            pending_signals: HashMap::new(),
            created_at: Instant::now(),
            max_peers: None,
        }
    }

    /// Set maximum number of peers
    pub fn with_max_peers(mut self, max: usize) -> Self {
        self.max_peers = Some(max);
        self
    }

    /// Start the session
    pub fn start(&mut self) {
        self.state = RtcSessionState::Active;
    }

    /// Add a peer to the session
    pub fn add_peer(
        &mut self,
        peer_id: RtcPeerId,
        user_id: Option<String>,
    ) -> Result<RtcEvent, RtcError> {
        // Check state
        if self.state != RtcSessionState::Active {
            return Err(RtcError::SessionClosed);
        }

        // Check max peers
        if let Some(max) = self.max_peers {
            if self.peers.len() >= max {
                return Err(RtcError::SessionFull(max));
            }
        }

        // Check if peer already exists
        if self.peers.contains_key(&peer_id) {
            return Err(RtcError::PeerExists(peer_id.to_string()));
        }

        // Add peer
        let peer_info = PeerInfo {
            id: peer_id.clone(),
            joined_at: Instant::now(),
            user_id,
        };
        self.peers.insert(peer_id.clone(), peer_info);
        self.pending_signals.insert(peer_id.clone(), Vec::new());

        // Return join event
        Ok(RtcEvent {
            session_id: self.id.clone(),
            peer_id,
            event_type: RtcEventType::PeerJoined,
            timestamp: current_timestamp(),
        })
    }

    /// Remove a peer from the session
    pub fn remove_peer(
        &mut self,
        peer_id: &RtcPeerId,
        reason: Option<String>,
    ) -> Result<RtcEvent, RtcError> {
        if self.peers.remove(peer_id).is_none() {
            return Err(RtcError::PeerNotFound(peer_id.to_string()));
        }

        self.pending_signals.remove(peer_id);

        Ok(RtcEvent {
            session_id: self.id.clone(),
            peer_id: peer_id.clone(),
            event_type: RtcEventType::PeerLeft { reason },
            timestamp: current_timestamp(),
        })
    }

    /// Get a peer by ID
    pub fn get_peer(&self, peer_id: &RtcPeerId) -> Option<&PeerInfo> {
        self.peers.get(peer_id)
    }

    /// Get all peer IDs
    pub fn get_peer_ids(&self) -> Vec<RtcPeerId> {
        self.peers.keys().cloned().collect()
    }

    /// Get peer count
    pub fn peer_count(&self) -> usize {
        self.peers.len()
    }

    /// Queue a signal for a peer (or all peers if target is None)
    pub fn queue_signal(
        &mut self,
        from: &RtcPeerId,
        to: Option<&RtcPeerId>,
        signal: RtcSignal,
    ) -> Result<(), RtcError> {
        // Verify sender is in session
        if !self.peers.contains_key(from) {
            return Err(RtcError::PeerNotFound(from.to_string()));
        }

        match to {
            Some(target) => {
                // Send to specific peer
                if let Some(signals) = self.pending_signals.get_mut(target) {
                    signals.push(signal);
                } else {
                    return Err(RtcError::PeerNotFound(target.to_string()));
                }
            }
            None => {
                // Broadcast to all peers except sender
                for (peer_id, signals) in &mut self.pending_signals {
                    if peer_id != from {
                        signals.push(signal.clone());
                    }
                }
            }
        }

        Ok(())
    }

    /// Get and clear pending signals for a peer
    pub fn drain_signals(&mut self, peer_id: &RtcPeerId) -> Vec<RtcSignal> {
        self.pending_signals
            .get_mut(peer_id)
            .map(|signals| std::mem::take(signals))
            .unwrap_or_default()
    }

    /// Close the session
    pub fn close(&mut self, reason: Option<String>) -> Vec<RtcEvent> {
        self.state = RtcSessionState::Closing;

        let events: Vec<RtcEvent> = self
            .peers
            .keys()
            .cloned()
            .map(|peer_id| RtcEvent {
                session_id: self.id.clone(),
                peer_id,
                event_type: RtcEventType::PeerLeft {
                    reason: reason.clone(),
                },
                timestamp: current_timestamp(),
            })
            .collect();

        self.peers.clear();
        self.pending_signals.clear();
        self.state = RtcSessionState::Closed;

        events
    }

    /// Check if the session is active
    pub fn is_active(&self) -> bool {
        self.state == RtcSessionState::Active
    }
}

/// Get current timestamp in milliseconds
fn current_timestamp() -> u64 {
    std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .unwrap_or_default()
        .as_millis() as u64
}
