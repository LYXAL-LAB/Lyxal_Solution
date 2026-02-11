//! RTC Integration Tests

#[cfg(test)]
mod tests {
    use crate::rtc::{RtcBridge, RtcSession, RtcSessionState};
    use surrealdb_core::rtc::{
        IceCandidate, RtcConfig, RtcEngine, RtcPeerId, RtcSessionId, RtcSignal, SdpType,
        SessionDescription,
    };
    use tokio::sync::mpsc;

    fn create_bridge() -> RtcBridge {
        let (tx, _rx) = mpsc::unbounded_channel();
        RtcBridge::new(tx)
    }

    #[test]
    fn test_session_lifecycle() {
        let mut session = RtcSession::new(
            RtcSessionId::new("test-session"),
            RtcConfig::default(),
        );

        assert_eq!(session.state, RtcSessionState::Creating);
        
        session.start();
        assert_eq!(session.state, RtcSessionState::Active);
        assert!(session.is_active());

        let peer1 = RtcPeerId::new();
        let event = session.add_peer(peer1.clone(), None).unwrap();
        assert_eq!(session.peer_count(), 1);

        let peer2 = RtcPeerId::new();
        session.add_peer(peer2.clone(), None).unwrap();
        assert_eq!(session.peer_count(), 2);

        session.remove_peer(&peer1, None).unwrap();
        assert_eq!(session.peer_count(), 1);

        let events = session.close(Some("Test close".to_string()));
        assert_eq!(session.state, RtcSessionState::Closed);
        assert_eq!(events.len(), 1); // One peer left
    }

    #[test]
    fn test_bridge_create_session() {
        let bridge = create_bridge();

        let session_id = RtcSessionId::new("my-room");
        bridge.create_session(session_id.clone(), None).unwrap();

        let sessions = bridge.list_sessions();
        assert_eq!(sessions.len(), 1);
        assert_eq!(sessions[0], session_id);

        // Should fail to create duplicate
        let result = bridge.create_session(session_id.clone(), None);
        assert!(result.is_err());
    }

    #[test]
    fn test_bridge_join_leave() {
        let bridge = create_bridge();

        let session_id = RtcSessionId::new("room-1");
        bridge.create_session(session_id.clone(), None).unwrap();

        let peer1 = RtcPeerId::new();
        let peer2 = RtcPeerId::new();
        let peer3 = RtcPeerId::new();

        // First peer joins - sees no one
        let existing = bridge.join_session(&session_id, peer1.clone()).unwrap();
        assert!(existing.is_empty());

        // Second peer joins - sees first peer
        let existing = bridge.join_session(&session_id, peer2.clone()).unwrap();
        assert_eq!(existing.len(), 1);
        assert!(existing.contains(&peer1));

        // Third peer joins - sees first two peers
        let existing = bridge.join_session(&session_id, peer3.clone()).unwrap();
        assert_eq!(existing.len(), 2);

        // Leave
        bridge.leave_session(&session_id, &peer1).unwrap();
        
        let peers = bridge.get_peers(&session_id).unwrap();
        assert_eq!(peers.len(), 2);
        assert!(!peers.contains(&peer1));
    }

    #[test]
    fn test_bridge_signaling() {
        let bridge = create_bridge();

        let session_id = RtcSessionId::new("video-call");
        bridge.create_session(session_id.clone(), None).unwrap();

        let peer_a = RtcPeerId::new();
        let peer_b = RtcPeerId::new();

        bridge.join_session(&session_id, peer_a.clone()).unwrap();
        bridge.join_session(&session_id, peer_b.clone()).unwrap();

        // Peer A sends offer to Peer B
        let offer = RtcSignal::Offer(SessionDescription {
            sdp_type: SdpType::Offer,
            sdp: "v=0\r\no=- 123 456 IN IP4 127.0.0.1\r\n...".to_string(),
        });
        
        let seq = bridge
            .signal(&session_id, &peer_a, Some(&peer_b), offer)
            .unwrap();
        assert_eq!(seq, 0);

        // Peer B polls and receives the offer
        let signals = bridge.poll(&session_id, &peer_b);
        assert_eq!(signals.len(), 1);
        
        match &signals[0] {
            RtcSignal::Offer(desc) => {
                assert!(desc.sdp.starts_with("v=0"));
            }
            _ => panic!("Expected offer"),
        }

        // Peer A should have nothing
        let signals = bridge.poll(&session_id, &peer_a);
        assert!(signals.is_empty());

        // Peer B sends answer to Peer A
        let answer = RtcSignal::Answer(SessionDescription {
            sdp_type: SdpType::Answer,
            sdp: "v=0\r\no=- 789 012 IN IP4 127.0.0.1\r\n...".to_string(),
        });
        
        bridge
            .signal(&session_id, &peer_b, Some(&peer_a), answer)
            .unwrap();

        // Peer A receives the answer
        let signals = bridge.poll(&session_id, &peer_a);
        assert_eq!(signals.len(), 1);
        
        match &signals[0] {
            RtcSignal::Answer(desc) => {
                assert_eq!(desc.sdp_type, SdpType::Answer);
            }
            _ => panic!("Expected answer"),
        }
    }

    #[test]
    fn test_ice_candidates() {
        let bridge = create_bridge();

        let session_id = RtcSessionId::new("ice-test");
        bridge.create_session(session_id.clone(), None).unwrap();

        let peer_a = RtcPeerId::new();
        let peer_b = RtcPeerId::new();

        bridge.join_session(&session_id, peer_a.clone()).unwrap();
        bridge.join_session(&session_id, peer_b.clone()).unwrap();

        // Send multiple ICE candidates
        for i in 0..3 {
            let candidate = RtcSignal::Ice(IceCandidate::new(
                format!("candidate:{} 1 UDP 123456 192.168.1.{} 5000 typ host", i, i),
                Some("0".to_string()),
                Some(0),
            ));
            
            bridge
                .signal(&session_id, &peer_a, Some(&peer_b), candidate)
                .unwrap();
        }

        // Peer B receives all candidates
        let signals = bridge.poll(&session_id, &peer_b);
        assert_eq!(signals.len(), 3);

        for signal in signals {
            match signal {
                RtcSignal::Ice(candidate) => {
                    assert!(candidate.candidate.starts_with("candidate:"));
                }
                _ => panic!("Expected ICE candidate"),
            }
        }
    }

    #[test]
    fn test_broadcast_signal() {
        let bridge = create_bridge();

        let session_id = RtcSessionId::new("broadcast-test");
        bridge.create_session(session_id.clone(), None).unwrap();

        let peer_a = RtcPeerId::new();
        let peer_b = RtcPeerId::new();
        let peer_c = RtcPeerId::new();

        bridge.join_session(&session_id, peer_a.clone()).unwrap();
        bridge.join_session(&session_id, peer_b.clone()).unwrap();
        bridge.join_session(&session_id, peer_c.clone()).unwrap();

        // Peer A broadcasts offer (no target)
        let offer = RtcSignal::Offer(SessionDescription {
            sdp_type: SdpType::Offer,
            sdp: "broadcast-sdp".to_string(),
        });
        
        bridge
            .signal(&session_id, &peer_a, None, offer) // None = broadcast
            .unwrap();

        // Peer B and C receive it, but not A
        let signals_b = bridge.poll(&session_id, &peer_b);
        let signals_c = bridge.poll(&session_id, &peer_c);
        let signals_a = bridge.poll(&session_id, &peer_a);

        assert_eq!(signals_b.len(), 1);
        assert_eq!(signals_c.len(), 1);
        assert_eq!(signals_a.len(), 0); // Sender doesn't receive own broadcast
    }

    #[test]
    fn test_close_session() {
        let bridge = create_bridge();

        let session_id = RtcSessionId::new("to-close");
        bridge.create_session(session_id.clone(), None).unwrap();

        let peer = RtcPeerId::new();
        bridge.join_session(&session_id, peer).unwrap();

        bridge.close_session(&session_id).unwrap();

        let sessions = bridge.list_sessions();
        assert!(sessions.is_empty());

        // Session no longer exists
        let result = bridge.get_peers(&session_id);
        assert!(result.is_err());
    }

    #[test]
    fn test_stats() {
        let bridge = create_bridge();

        // Initially empty
        let stats = bridge.stats();
        assert_eq!(stats.active_sessions, 0);
        assert_eq!(stats.total_peers, 0);

        // Create sessions and add peers
        let s1 = RtcSessionId::new("s1");
        let s2 = RtcSessionId::new("s2");
        
        bridge.create_session(s1.clone(), None).unwrap();
        bridge.create_session(s2.clone(), None).unwrap();

        bridge.join_session(&s1, RtcPeerId::new()).unwrap();
        bridge.join_session(&s1, RtcPeerId::new()).unwrap();
        bridge.join_session(&s2, RtcPeerId::new()).unwrap();

        let stats = bridge.stats();
        assert_eq!(stats.active_sessions, 2);
        assert_eq!(stats.total_peers, 3);
    }

    // ========================================================================
    // SFU Server Tests
    // ========================================================================

    use crate::rtc::SfuServer;

    #[test]
    fn test_sfu_server_creation() {
        let server = SfuServer::with_defaults();
        assert!(!server.is_running());
    }

    #[test]
    fn test_sfu_session_lifecycle() {
        let server = SfuServer::with_defaults();

        // Create session
        let session_id = server.create_session().unwrap();
        assert!(server.list_sessions().contains(&session_id));

        // Get info
        let info = server.get_session_info(session_id).unwrap();
        assert_eq!(info.session_id, session_id);
        assert_eq!(info.endpoint_count, 0);

        // Stats
        let stats = server.get_stats();
        assert_eq!(stats.active_sessions, 1);
        assert_eq!(stats.total_endpoints, 0);

        // Close session
        server.close_session(session_id).unwrap();
        assert!(!server.list_sessions().contains(&session_id));
    }

    #[test]
    fn test_sfu_offer_answer_flow() {
        let server = SfuServer::with_defaults();

        let session_id = server.create_session().unwrap();

        // Create offer
        let remote_sdp = "v=0\r\no=- 123 456 IN IP4 127.0.0.1\r\n...";
        let (endpoint_id, local_sdp) = server.create_offer(session_id, remote_sdp).unwrap();

        assert!(!local_sdp.is_empty());
        assert!(local_sdp.starts_with("v=0"));

        // Accept answer
        let answer = "v=0\r\no=- 789 012 IN IP4 127.0.0.1\r\n...";
        server.accept_answer(session_id, endpoint_id, answer).unwrap();

        // Check stats
        let stats = server.get_stats();
        assert_eq!(stats.active_sessions, 1);
        assert_eq!(stats.total_endpoints, 1);

        // Check session info
        let info = server.get_session_info(session_id).unwrap();
        assert_eq!(info.endpoint_count, 1);
    }

    #[test]
    fn test_sfu_multiple_endpoints() {
        let server = SfuServer::with_defaults();

        let session_id = server.create_session().unwrap();

        // Add 3 endpoints
        for i in 0..3 {
            let (endpoint_id, _) = server.create_offer(session_id, &format!("sdp{}", i)).unwrap();
            assert_eq!(endpoint_id, i as u64);
        }

        let info = server.get_session_info(session_id).unwrap();
        assert_eq!(info.endpoint_count, 3);

        let stats = server.get_stats();
        assert_eq!(stats.total_endpoints, 3);
    }

    #[test]
    fn test_sfu_remove_endpoint() {
        let server = SfuServer::with_defaults();

        let session_id = server.create_session().unwrap();
        let (endpoint_id, _) = server.create_offer(session_id, "sdp").unwrap();
        
        // Add another endpoint
        let (_, _) = server.create_offer(session_id, "sdp2").unwrap();

        // Remove first endpoint
        server.remove_endpoint(session_id, endpoint_id).unwrap();

        let info = server.get_session_info(session_id).unwrap();
        assert_eq!(info.endpoint_count, 1);

        // Remove last endpoint - session should be removed
        server.remove_endpoint(session_id, 1).unwrap();
        assert!(!server.list_sessions().contains(&session_id));
    }

    #[test]
    fn test_sfu_multiple_sessions() {
        let server = SfuServer::with_defaults();

        // Create multiple sessions
        let s1 = server.create_session().unwrap();
        let s2 = server.create_session().unwrap();
        let s3 = server.create_session().unwrap();

        assert_eq!(server.list_sessions().len(), 3);

        // Add endpoints to each
        server.create_offer(s1, "sdp").unwrap();
        server.create_offer(s1, "sdp").unwrap();
        server.create_offer(s2, "sdp").unwrap();

        let stats = server.get_stats();
        assert_eq!(stats.active_sessions, 3);
        assert_eq!(stats.total_endpoints, 3);

        // Close one session
        server.close_session(s2).unwrap();
        
        let stats = server.get_stats();
        assert_eq!(stats.active_sessions, 2);
        assert_eq!(stats.total_endpoints, 2); // Only s1 endpoints remain
    }

    #[test]
    fn test_sfu_session_not_found() {
        let server = SfuServer::with_defaults();

        // Session doesn't exist
        let result = server.create_offer(999, "sdp");
        assert!(result.is_err());

        let result = server.close_session(999);
        assert!(result.is_err());

        let info = server.get_session_info(999);
        assert!(info.is_none());
    }

    #[test]
    fn test_sfu_no_pending_offer() {
        let server = SfuServer::with_defaults();

        let session_id = server.create_session().unwrap();

        // Try to accept answer without offer
        let result = server.accept_answer(session_id, 999, "answer");
        assert!(result.is_err());
    }
}
