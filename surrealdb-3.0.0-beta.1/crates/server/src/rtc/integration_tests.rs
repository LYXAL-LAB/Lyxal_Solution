//! RTC Integration Tests - End-to-End Orchestration
//!
//! These tests validate the RTC engine orchestration, not media functionality.
//! They prove that the engine can be activated without regression.
//!
//! ## What these tests verify:
//! - Session lifecycle (create → join → leave → close)
//! - Multi-peer orchestration
//! - Signal exchange (offer/answer/ice)
//! - Clean teardown (no panics, no leaks)
//!
//! ## What these tests DO NOT verify:
//! - Real media transport
//! - SFU forwarding
//! - Network connectivity

#![cfg(test)]

use std::sync::Arc;

use surrealdb_core::rtc::{
    RtcConfig, RtcEngine, RtcError, RtcPeerId, RtcSessionId, RtcSignal,
    SessionDescription, SdpType, IceCandidate,
};

use super::bridge::RtcBridge;
use super::sfu::SfuServer;

use tokio::sync::mpsc;

// ============================================================================
// Test Fixtures
// ============================================================================

fn create_test_engine() -> Arc<RtcBridge> {
    let (tx, _rx) = mpsc::unbounded_channel();
    Arc::new(RtcBridge::new(tx))
}

fn create_test_sfu() -> Arc<SfuServer> {
    Arc::new(SfuServer::with_defaults())
}

fn mock_offer() -> RtcSignal {
    RtcSignal::Offer(SessionDescription {
        sdp_type: SdpType::Offer,
        sdp: "v=0\r\no=- 0 0 IN IP4 127.0.0.1\r\ns=-\r\nt=0 0\r\n".to_string(),
    })
}

fn mock_answer() -> RtcSignal {
    RtcSignal::Answer(SessionDescription {
        sdp_type: SdpType::Answer,
        sdp: "v=0\r\no=- 0 0 IN IP4 127.0.0.1\r\ns=-\r\nt=0 0\r\n".to_string(),
    })
}

fn mock_ice() -> RtcSignal {
    RtcSignal::Ice(IceCandidate {
        candidate: "candidate:1 1 UDP 2130706431 192.168.1.1 54321 typ host".to_string(),
        sdp_mid: Some("0".to_string()),
        sdp_m_line_index: Some(0),
    })
}

// ============================================================================
// P2P Engine Tests
// ============================================================================

mod p2p_lifecycle {
    use super::*;

    #[test]
    fn test_create_session() {
        let engine = create_test_engine();
        let session_id = RtcSessionId::new("test-session-1");

        let result = engine.create_session(session_id.clone(), None);
        assert!(result.is_ok(), "Session creation should succeed");

        let sessions = engine.list_sessions();
        assert!(sessions.contains(&session_id), "Session should be listed");
    }

    #[test]
    fn test_create_session_with_config() {
        let engine = create_test_engine();
        let session_id = RtcSessionId::new("test-session-2");
        let config = RtcConfig::default();

        let result = engine.create_session(session_id.clone(), Some(config));
        assert!(result.is_ok(), "Session creation with config should succeed");
    }

    #[test]
    fn test_duplicate_session_creation() {
        let engine = create_test_engine();
        let session_id = RtcSessionId::new("test-session-3");

        engine.create_session(session_id.clone(), None).unwrap();
        let result = engine.create_session(session_id, None);
        
        assert!(result.is_err(), "Duplicate session creation should fail");
    }

    #[test]
    fn test_join_session() {
        let engine = create_test_engine();
        let session_id = RtcSessionId::new("test-session-4");
        let peer_id = RtcPeerId::new();

        engine.create_session(session_id.clone(), None).unwrap();
        let result = engine.join_session(&session_id, peer_id.clone());

        assert!(result.is_ok(), "Joining session should succeed");
        
        let peers = engine.get_peers(&session_id).unwrap();
        assert!(peers.contains(&peer_id), "Peer should be in session");
    }

    #[test]
    fn test_join_nonexistent_session() {
        let engine = create_test_engine();
        let session_id = RtcSessionId::new("nonexistent");
        let peer_id = RtcPeerId::new();

        let result = engine.join_session(&session_id, peer_id);
        assert!(result.is_err(), "Joining nonexistent session should fail");
    }

    #[test]
    fn test_leave_session() {
        let engine = create_test_engine();
        let session_id = RtcSessionId::new("test-session-5");
        let peer_id = RtcPeerId::new();

        engine.create_session(session_id.clone(), None).unwrap();
        engine.join_session(&session_id, peer_id.clone()).unwrap();
        
        let result = engine.leave_session(&session_id, &peer_id);
        assert!(result.is_ok(), "Leaving session should succeed");

        let peers = engine.get_peers(&session_id).unwrap();
        assert!(!peers.contains(&peer_id), "Peer should not be in session after leaving");
    }

    #[test]
    fn test_close_session() {
        let engine = create_test_engine();
        let session_id = RtcSessionId::new("test-session-6");

        engine.create_session(session_id.clone(), None).unwrap();
        
        let result = engine.close_session(&session_id);
        assert!(result.is_ok(), "Closing session should succeed");

        let sessions = engine.list_sessions();
        assert!(!sessions.contains(&session_id), "Session should not be listed after close");
    }
}

mod p2p_signaling {
    use super::*;

    #[test]
    fn test_send_offer() {
        let engine = create_test_engine();
        let session_id = RtcSessionId::new("signal-test-1");
        let peer1 = RtcPeerId::new();
        let peer2 = RtcPeerId::new();

        engine.create_session(session_id.clone(), None).unwrap();
        engine.join_session(&session_id, peer1.clone()).unwrap();
        engine.join_session(&session_id, peer2.clone()).unwrap();

        let result = engine.signal(&session_id, &peer1, Some(&peer2), mock_offer());
        assert!(result.is_ok(), "Sending offer should succeed");
    }

    #[test]
    fn test_poll_signals() {
        let engine = create_test_engine();
        let session_id = RtcSessionId::new("signal-test-2");
        let peer1 = RtcPeerId::new();
        let peer2 = RtcPeerId::new();

        engine.create_session(session_id.clone(), None).unwrap();
        engine.join_session(&session_id, peer1.clone()).unwrap();
        engine.join_session(&session_id, peer2.clone()).unwrap();

        // Peer1 sends offer to peer2
        engine.signal(&session_id, &peer1, Some(&peer2), mock_offer()).unwrap();

        // Peer2 polls for signals
        let signals = engine.poll(&session_id, &peer2);
        assert!(!signals.is_empty(), "Peer2 should receive the offer");
    }

    #[test]
    fn test_offer_answer_exchange() {
        let engine = create_test_engine();
        let session_id = RtcSessionId::new("signal-test-3");
        let peer1 = RtcPeerId::new();
        let peer2 = RtcPeerId::new();

        // Setup
        engine.create_session(session_id.clone(), None).unwrap();
        engine.join_session(&session_id, peer1.clone()).unwrap();
        engine.join_session(&session_id, peer2.clone()).unwrap();

        // Peer1 → Offer → Peer2
        engine.signal(&session_id, &peer1, Some(&peer2), mock_offer()).unwrap();
        let signals = engine.poll(&session_id, &peer2);
        assert!(signals.iter().any(|s| matches!(s, RtcSignal::Offer(_))));

        // Peer2 → Answer → Peer1
        engine.signal(&session_id, &peer2, Some(&peer1), mock_answer()).unwrap();
        let signals = engine.poll(&session_id, &peer1);
        assert!(signals.iter().any(|s| matches!(s, RtcSignal::Answer(_))));
    }

    #[test]
    fn test_ice_exchange() {
        let engine = create_test_engine();
        let session_id = RtcSessionId::new("signal-test-4");
        let peer1 = RtcPeerId::new();
        let peer2 = RtcPeerId::new();

        engine.create_session(session_id.clone(), None).unwrap();
        engine.join_session(&session_id, peer1.clone()).unwrap();
        engine.join_session(&session_id, peer2.clone()).unwrap();

        // Exchange ICE candidates
        engine.signal(&session_id, &peer1, Some(&peer2), mock_ice()).unwrap();
        engine.signal(&session_id, &peer2, Some(&peer1), mock_ice()).unwrap();

        let signals1 = engine.poll(&session_id, &peer1);
        let signals2 = engine.poll(&session_id, &peer2);

        assert!(signals1.iter().any(|s| matches!(s, RtcSignal::Ice(_))));
        assert!(signals2.iter().any(|s| matches!(s, RtcSignal::Ice(_))));
    }
}

mod p2p_teardown {
    use super::*;

    #[test]
    fn test_clean_teardown_single_peer() {
        let engine = create_test_engine();
        let session_id = RtcSessionId::new("teardown-1");
        let peer = RtcPeerId::new();

        engine.create_session(session_id.clone(), None).unwrap();
        engine.join_session(&session_id, peer.clone()).unwrap();
        engine.leave_session(&session_id, &peer).unwrap();
        engine.close_session(&session_id).unwrap();

        // No panic, no leak - success
        assert!(engine.list_sessions().is_empty());
    }

    #[test]
    fn test_clean_teardown_multi_peer() {
        let engine = create_test_engine();
        let session_id = RtcSessionId::new("teardown-2");
        let peers: Vec<RtcPeerId> = (0..5).map(|_| RtcPeerId::new()).collect();

        engine.create_session(session_id.clone(), None).unwrap();
        
        for peer in &peers {
            engine.join_session(&session_id, peer.clone()).unwrap();
        }

        for peer in &peers {
            engine.leave_session(&session_id, peer).unwrap();
        }

        engine.close_session(&session_id).unwrap();
        assert!(engine.list_sessions().is_empty());
    }

    #[test]
    fn test_force_close_with_active_peers() {
        let engine = create_test_engine();
        let session_id = RtcSessionId::new("teardown-3");
        let peers: Vec<RtcPeerId> = (0..3).map(|_| RtcPeerId::new()).collect();

        engine.create_session(session_id.clone(), None).unwrap();
        
        for peer in &peers {
            engine.join_session(&session_id, peer.clone()).unwrap();
        }

        // Force close without leaving
        engine.close_session(&session_id).unwrap();
        
        // Should not panic, session should be gone
        assert!(engine.list_sessions().is_empty());
    }
}

// ============================================================================
// SFU Tests
// ============================================================================

mod sfu_lifecycle {
    use super::*;

    #[test]
    fn test_sfu_create_session() {
        let sfu = create_test_sfu();

        let result = sfu.create_session();
        assert!(result.is_ok(), "SFU session creation should succeed");
        
        let session_id = result.unwrap();
        assert!(session_id > 0, "Session ID should be positive");
    }

    #[test]
    fn test_sfu_join_with_offer() {
        let sfu = create_test_sfu();
        let session_id = sfu.create_session().unwrap();

        let offer = "v=0\r\no=- 0 0 IN IP4 127.0.0.1\r\ns=-\r\nt=0 0\r\n";
        let result = sfu.join(session_id, offer);

        assert!(result.is_ok(), "Joining SFU should succeed");
        
        let (endpoint_id, answer) = result.unwrap();
        assert!(endpoint_id > 0, "Endpoint ID should be positive");
        assert!(!answer.is_empty(), "Answer should not be empty");
    }

    #[test]
    fn test_sfu_multiple_endpoints() {
        let sfu = create_test_sfu();
        let session_id = sfu.create_session().unwrap();

        let offer = "v=0\r\no=- 0 0 IN IP4 127.0.0.1\r\ns=-\r\nt=0 0\r\n";
        
        let (ep1, _) = sfu.join(session_id, offer).unwrap();
        let (ep2, _) = sfu.join(session_id, offer).unwrap();
        let (ep3, _) = sfu.join(session_id, offer).unwrap();

        assert_ne!(ep1, ep2);
        assert_ne!(ep2, ep3);

        let info = sfu.get_session_info(session_id).unwrap();
        assert_eq!(info.endpoint_count, 3);
    }

    #[test]
    fn test_sfu_leave() {
        let sfu = create_test_sfu();
        let session_id = sfu.create_session().unwrap();

        let offer = "v=0\r\no=- 0 0 IN IP4 127.0.0.1\r\ns=-\r\nt=0 0\r\n";
        let (endpoint_id, _) = sfu.join(session_id, offer).unwrap();

        let result = sfu.leave(session_id, endpoint_id);
        assert!(result.is_ok(), "Leaving SFU should succeed");

        let info = sfu.get_session_info(session_id).unwrap();
        assert_eq!(info.endpoint_count, 0);
    }

    #[test]
    fn test_sfu_close_session() {
        let sfu = create_test_sfu();
        let session_id = sfu.create_session().unwrap();

        let result = sfu.close_session(session_id);
        assert!(result.is_ok(), "Closing SFU session should succeed");

        let info = sfu.get_session_info(session_id);
        assert!(info.is_err(), "Session should not exist after close");
    }
}

mod sfu_stats {
    use super::*;

    #[test]
    fn test_sfu_stats() {
        let sfu = create_test_sfu();
        
        let stats = sfu.get_stats();
        assert_eq!(stats.active_sessions, 0);

        let session_id = sfu.create_session().unwrap();
        let offer = "v=0\r\n";
        sfu.join(session_id, offer).unwrap();

        let stats = sfu.get_stats();
        assert_eq!(stats.active_sessions, 1);
        assert_eq!(stats.total_endpoints, 1);
    }

    #[test]
    fn test_sfu_list_sessions() {
        let sfu = create_test_sfu();

        let s1 = sfu.create_session().unwrap();
        let s2 = sfu.create_session().unwrap();
        let s3 = sfu.create_session().unwrap();

        let sessions = sfu.list_sessions();
        assert_eq!(sessions.len(), 3);
        assert!(sessions.contains(&s1));
        assert!(sessions.contains(&s2));
        assert!(sessions.contains(&s3));
    }
}

mod sfu_teardown {
    use super::*;

    #[test]
    fn test_sfu_clean_teardown() {
        let sfu = create_test_sfu();
        let session_id = sfu.create_session().unwrap();

        let offer = "v=0\r\n";
        for _ in 0..10 {
            sfu.join(session_id, offer).unwrap();
        }

        sfu.close_session(session_id).unwrap();

        let stats = sfu.get_stats();
        assert_eq!(stats.active_sessions, 0);
        assert_eq!(stats.total_endpoints, 0);
    }
}

// ============================================================================
// Full Orchestration Test
// ============================================================================

mod full_orchestration {
    use super::*;

    #[test]
    fn test_complete_p2p_flow() {
        // This test simulates a complete P2P call flow
        let engine = create_test_engine();
        let session_id = RtcSessionId::new("full-p2p-test");

        // 1. Create session
        engine.create_session(session_id.clone(), None).unwrap();

        // 2. Peer A joins
        let peer_a = RtcPeerId::new();
        let existing = engine.join_session(&session_id, peer_a.clone()).unwrap();
        assert!(existing.is_empty());

        // 3. Peer B joins
        let peer_b = RtcPeerId::new();
        let existing = engine.join_session(&session_id, peer_b.clone()).unwrap();
        assert!(existing.contains(&peer_a));

        // 4. Peer A sends offer
        engine.signal(&session_id, &peer_a, Some(&peer_b), mock_offer()).unwrap();

        // 5. Peer B receives offer
        let signals = engine.poll(&session_id, &peer_b);
        assert!(signals.iter().any(|s| matches!(s, RtcSignal::Offer(_))));

        // 6. Peer B sends answer
        engine.signal(&session_id, &peer_b, Some(&peer_a), mock_answer()).unwrap();

        // 7. Peer A receives answer
        let signals = engine.poll(&session_id, &peer_a);
        assert!(signals.iter().any(|s| matches!(s, RtcSignal::Answer(_))));

        // 8. ICE exchange
        engine.signal(&session_id, &peer_a, Some(&peer_b), mock_ice()).unwrap();
        engine.signal(&session_id, &peer_b, Some(&peer_a), mock_ice()).unwrap();

        // 9. Verify state
        let peers = engine.get_peers(&session_id).unwrap();
        assert_eq!(peers.len(), 2);

        // 10. Teardown
        engine.leave_session(&session_id, &peer_a).unwrap();
        engine.leave_session(&session_id, &peer_b).unwrap();
        engine.close_session(&session_id).unwrap();

        // 11. Verify clean state
        assert!(engine.list_sessions().is_empty());
    }

    #[test]
    fn test_complete_sfu_flow() {
        // This test simulates a complete SFU meeting flow
        let sfu = create_test_sfu();

        // 1. Create session
        let session_id = sfu.create_session().unwrap();

        // 2. Multiple participants join
        let offer = "v=0\r\no=- 0 0 IN IP4 127.0.0.1\r\ns=-\r\nt=0 0\r\n";
        let mut endpoints = Vec::new();

        for _ in 0..5 {
            let (ep, answer) = sfu.join(session_id, offer).unwrap();
            assert!(!answer.is_empty());
            endpoints.push(ep);
        }

        // 3. Verify session state
        let info = sfu.get_session_info(session_id).unwrap();
        assert_eq!(info.endpoint_count, 5);

        // 4. Some leave
        sfu.leave(session_id, endpoints[0]).unwrap();
        sfu.leave(session_id, endpoints[1]).unwrap();

        let info = sfu.get_session_info(session_id).unwrap();
        assert_eq!(info.endpoint_count, 3);

        // 5. Close session
        sfu.close_session(session_id).unwrap();

        // 6. Verify clean state
        let stats = sfu.get_stats();
        assert_eq!(stats.active_sessions, 0);
    }
}

// ============================================================================
// Non-Regression Tests
// ============================================================================

mod non_regression {
    use super::*;

    #[test]
    fn test_no_panic_on_invalid_operations() {
        let engine = create_test_engine();

        // These should not panic, just return errors
        let _ = engine.join_session(&RtcSessionId::new("invalid"), RtcPeerId::new());
        let _ = engine.leave_session(&RtcSessionId::new("invalid"), &RtcPeerId::new());
        let _ = engine.signal(&RtcSessionId::new("invalid"), &RtcPeerId::new(), None, mock_offer());
        let _ = engine.close_session(&RtcSessionId::new("invalid"));
    }

    #[test]
    fn test_no_panic_on_sfu_invalid_operations() {
        let sfu = create_test_sfu();

        // These should not panic
        let _ = sfu.leave(99999, 99999);
        let _ = sfu.get_session_info(99999);
        let _ = sfu.close_session(99999);
    }

    #[test]
    fn test_concurrent_sessions() {
        let engine = create_test_engine();

        // Create multiple concurrent sessions
        for i in 0..10 {
            let session_id = RtcSessionId::new(format!("concurrent-{}", i));
            engine.create_session(session_id.clone(), None).unwrap();

            for _ in 0..3 {
                engine.join_session(&session_id, RtcPeerId::new()).unwrap();
            }
        }

        assert_eq!(engine.list_sessions().len(), 10);

        // Clean up all
        for session_id in engine.list_sessions() {
            engine.close_session(&session_id).unwrap();
        }

        assert!(engine.list_sessions().is_empty());
    }
}
