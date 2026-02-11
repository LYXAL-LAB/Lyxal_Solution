//! RTC Bridge - Implements the RtcEngine trait
//!
//! This is the server-side implementation that connects to the RTC motor.

use std::collections::HashMap;
use std::sync::atomic::{AtomicU64, Ordering};

use parking_lot::RwLock;
use tokio::sync::mpsc;

use surrealdb_core::rtc::{
    RtcConfig, RtcEngine, RtcError, RtcEvent, RtcPeerId, RtcSessionId, RtcSignal,
};

use super::session::RtcSession;

/// The RTC Bridge - implements RtcEngine for the server
pub struct RtcBridge {
    /// Active sessions
    sessions: RwLock<HashMap<RtcSessionId, RtcSession>>,
    /// Default configuration for new sessions
    default_config: RtcConfig,
    /// Event sender for broadcasting RTC events
    event_tx: mpsc::UnboundedSender<RtcEvent>,
    /// Sequence counter for signals
    seq_counter: AtomicU64,
}

impl RtcBridge {
    /// Create a new RTC bridge
    pub fn new(event_tx: mpsc::UnboundedSender<RtcEvent>) -> Self {
        Self {
            sessions: RwLock::new(HashMap::new()),
            default_config: RtcConfig::default(),
            event_tx,
            seq_counter: AtomicU64::new(0),
        }
    }

    /// Create with custom default configuration
    pub fn with_config(event_tx: mpsc::UnboundedSender<RtcEvent>, config: RtcConfig) -> Self {
        Self {
            sessions: RwLock::new(HashMap::new()),
            default_config: config,
            event_tx,
            seq_counter: AtomicU64::new(0),
        }
    }

    /// Get next sequence number
    fn next_seq(&self) -> u64 {
        self.seq_counter.fetch_add(1, Ordering::SeqCst)
    }

    /// Emit an event
    fn emit(&self, event: RtcEvent) {
        let _ = self.event_tx.send(event);
    }

    /// Get session statistics
    pub fn stats(&self) -> RtcBridgeStats {
        let sessions = self.sessions.read();
        let total_peers: usize = sessions.values().map(|s| s.peer_count()).sum();
        
        RtcBridgeStats {
            active_sessions: sessions.len(),
            total_peers,
        }
    }
}

impl RtcEngine for RtcBridge {
    fn signal(
        &self,
        session_id: &RtcSessionId,
        from: &RtcPeerId,
        to: Option<&RtcPeerId>,
        signal: RtcSignal,
    ) -> Result<u64, RtcError> {
        let mut sessions = self.sessions.write();
        
        let session = sessions
            .get_mut(session_id)
            .ok_or_else(|| RtcError::SessionNotFound(session_id.0.clone()))?;

        session.queue_signal(from, to, signal)?;
        
        Ok(self.next_seq())
    }

    fn poll(&self, session_id: &RtcSessionId, peer: &RtcPeerId) -> Vec<RtcSignal> {
        let mut sessions = self.sessions.write();
        
        sessions
            .get_mut(session_id)
            .map(|session| session.drain_signals(peer))
            .unwrap_or_default()
    }

    fn create_session(
        &self,
        session_id: RtcSessionId,
        config: Option<RtcConfig>,
    ) -> Result<(), RtcError> {
        let mut sessions = self.sessions.write();
        
        if sessions.contains_key(&session_id) {
            return Err(RtcError::SessionExists(session_id.0.clone()));
        }

        let config = config.unwrap_or_else(|| self.default_config.clone());
        let mut session = RtcSession::new(session_id.clone(), config);
        session.start();

        sessions.insert(session_id, session);
        
        Ok(())
    }

    fn join_session(
        &self,
        session_id: &RtcSessionId,
        peer: RtcPeerId,
    ) -> Result<Vec<RtcPeerId>, RtcError> {
        let mut sessions = self.sessions.write();
        
        let session = sessions
            .get_mut(session_id)
            .ok_or_else(|| RtcError::SessionNotFound(session_id.0.clone()))?;

        // Get existing peers before adding new one
        let existing_peers = session.get_peer_ids();

        // Add the peer
        let event = session.add_peer(peer, None)?;
        
        // Emit the join event
        self.emit(event);

        Ok(existing_peers)
    }

    fn leave_session(&self, session_id: &RtcSessionId, peer: &RtcPeerId) -> Result<(), RtcError> {
        let mut sessions = self.sessions.write();
        
        let session = sessions
            .get_mut(session_id)
            .ok_or_else(|| RtcError::SessionNotFound(session_id.0.clone()))?;

        let event = session.remove_peer(peer, None)?;
        self.emit(event);

        // If session is empty, close it
        if session.peer_count() == 0 {
            let session_id = session.id.clone();
            sessions.remove(&session_id);
        }

        Ok(())
    }

    fn close_session(&self, session_id: &RtcSessionId) -> Result<(), RtcError> {
        let mut sessions = self.sessions.write();
        
        let session = sessions
            .get_mut(session_id)
            .ok_or_else(|| RtcError::SessionNotFound(session_id.0.clone()))?;

        let events = session.close(Some("Session closed".to_string()));
        
        for event in events {
            self.emit(event);
        }

        sessions.remove(session_id);
        
        Ok(())
    }

    fn list_sessions(&self) -> Vec<RtcSessionId> {
        let sessions = self.sessions.read();
        sessions.keys().cloned().collect()
    }

    fn get_peers(&self, session_id: &RtcSessionId) -> Result<Vec<RtcPeerId>, RtcError> {
        let sessions = self.sessions.read();
        
        let session = sessions
            .get(session_id)
            .ok_or_else(|| RtcError::SessionNotFound(session_id.0.clone()))?;

        Ok(session.get_peer_ids())
    }
}

/// Statistics about the RTC bridge
#[derive(Debug, Clone)]
pub struct RtcBridgeStats {
    /// Number of active sessions
    pub active_sessions: usize,
    /// Total number of connected peers
    pub total_peers: usize,
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_create_session() {
        let (tx, _rx) = mpsc::unbounded_channel();
        let bridge = RtcBridge::new(tx);
        
        let session_id = RtcSessionId::new("test-session");
        bridge.create_session(session_id.clone(), None).unwrap();
        
        let sessions = bridge.list_sessions();
        assert_eq!(sessions.len(), 1);
        assert_eq!(sessions[0], session_id);
    }

    #[test]
    fn test_join_leave_session() {
        let (tx, _rx) = mpsc::unbounded_channel();
        let bridge = RtcBridge::new(tx);
        
        let session_id = RtcSessionId::new("test-session");
        bridge.create_session(session_id.clone(), None).unwrap();
        
        let peer1 = RtcPeerId::new();
        let peer2 = RtcPeerId::new();
        
        // First peer joins
        let existing = bridge.join_session(&session_id, peer1.clone()).unwrap();
        assert!(existing.is_empty());
        
        // Second peer joins, should see first peer
        let existing = bridge.join_session(&session_id, peer2.clone()).unwrap();
        assert_eq!(existing.len(), 1);
        assert_eq!(existing[0], peer1);
        
        // Leave
        bridge.leave_session(&session_id, &peer1).unwrap();
        
        let peers = bridge.get_peers(&session_id).unwrap();
        assert_eq!(peers.len(), 1);
        assert_eq!(peers[0], peer2);
    }

    #[test]
    fn test_signaling() {
        let (tx, _rx) = mpsc::unbounded_channel();
        let bridge = RtcBridge::new(tx);
        
        let session_id = RtcSessionId::new("test-session");
        bridge.create_session(session_id.clone(), None).unwrap();
        
        let peer1 = RtcPeerId::new();
        let peer2 = RtcPeerId::new();
        
        bridge.join_session(&session_id, peer1.clone()).unwrap();
        bridge.join_session(&session_id, peer2.clone()).unwrap();
        
        // Send offer from peer1 to peer2
        use surrealdb_core::rtc::{SessionDescription, SdpType};
        let offer = RtcSignal::Offer(SessionDescription {
            sdp_type: SdpType::Offer,
            sdp: "v=0...".to_string(),
        });
        
        bridge.signal(&session_id, &peer1, Some(&peer2), offer).unwrap();
        
        // Peer2 should receive it
        let signals = bridge.poll(&session_id, &peer2);
        assert_eq!(signals.len(), 1);
        
        // Peer1 should not receive it
        let signals = bridge.poll(&session_id, &peer1);
        assert!(signals.is_empty());
    }
}
