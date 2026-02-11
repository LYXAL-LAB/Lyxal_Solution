//! Cascade SFU - Multi-Server Scalability
//!
//! This module implements cascade/mesh SFU architecture for scaling
//! to massive conferences like Zoom (1000+ participants) and global distribution.
//!
//! ## How Zoom/Meet scale to millions
//!
//! ```text
//! ┌─────────────────────────────────────────────────────────────────────────────┐
//! │                        CASCADE SFU ARCHITECTURE                             │
//! │                                                                             │
//! │   Region: US-East                      Region: EU-West                     │
//! │   ┌─────────────────┐                  ┌─────────────────┐                 │
//! │   │   SFU Node 1    │◄────Cascade─────►│   SFU Node 3    │                 │
//! │   │   (Primary)     │                  │                  │                 │
//! │   └────────┬────────┘                  └────────┬────────┘                 │
//! │            │                                    │                           │
//! │            │                                    │                           │
//! │   ┌────────┴────────┐                  ┌────────┴────────┐                 │
//! │   │   SFU Node 2    │                  │   SFU Node 4    │                 │
//! │   │   (Backup)      │                  │                  │                 │
//! │   └────────┬────────┘                  └────────┬────────┘                 │
//! │            │                                    │                           │
//! │      ┌─────┴─────┐                        ┌─────┴─────┐                    │
//! │      │  Clients  │                        │  Clients  │                    │
//! │      │ (US)      │                        │ (EU)      │                    │
//! │      └───────────┘                        └───────────┘                    │
//! │                                                                             │
//! │   Benefits:                                                                │
//! │   • Geographic distribution (low latency)                                  │
//! │   • Horizontal scaling (unlimited participants)                            │
//! │   • Fault tolerance (node failover)                                        │
//! │   • Bandwidth optimization (regional media)                                │
//! │                                                                             │
//! └─────────────────────────────────────────────────────────────────────────────┘
//! ```

use std::collections::{HashMap, HashSet};
use std::net::SocketAddr;
use std::time::{Duration, Instant};

use serde::{Deserialize, Serialize};
use tokio::sync::mpsc;

/// Cascade node role
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum NodeRole {
    /// Origin node (where the session was created)
    Origin,
    /// Edge node (serving clients in a region)
    Edge,
    /// Relay node (pure forwarding, no clients)
    Relay,
}

impl Default for NodeRole {
    fn default() -> Self {
        Self::Edge
    }
}

/// Node status
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum NodeStatus {
    /// Node is healthy
    Healthy,
    /// Node is degraded (high load)
    Degraded,
    /// Node is down
    Down,
    /// Node is draining (no new connections)
    Draining,
}

impl Default for NodeStatus {
    fn default() -> Self {
        Self::Healthy
    }
}

/// Geographic region
#[derive(Debug, Clone, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub struct Region {
    pub code: String,
    pub name: String,
    pub continent: String,
}

impl Region {
    pub fn new(code: &str, name: &str, continent: &str) -> Self {
        Self {
            code: code.to_string(),
            name: name.to_string(),
            continent: continent.to_string(),
        }
    }

    /// Common regions
    pub fn us_east() -> Self {
        Self::new("us-east-1", "US East (N. Virginia)", "NA")
    }

    pub fn us_west() -> Self {
        Self::new("us-west-2", "US West (Oregon)", "NA")
    }

    pub fn eu_west() -> Self {
        Self::new("eu-west-1", "EU West (Ireland)", "EU")
    }

    pub fn eu_central() -> Self {
        Self::new("eu-central-1", "EU Central (Frankfurt)", "EU")
    }

    pub fn ap_northeast() -> Self {
        Self::new("ap-northeast-1", "Asia Pacific (Tokyo)", "AP")
    }

    pub fn ap_southeast() -> Self {
        Self::new("ap-southeast-1", "Asia Pacific (Singapore)", "AP")
    }
}

/// Cascade node information
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CascadeNode {
    /// Node ID
    pub id: String,
    /// Node role
    pub role: NodeRole,
    /// Node status
    pub status: NodeStatus,
    /// Region
    pub region: Region,
    /// Public address for cascade connections
    pub cascade_addr: SocketAddr,
    /// Public address for client connections
    pub client_addr: SocketAddr,
    /// Current load (0.0 - 1.0)
    pub load: f32,
    /// Active session count
    pub session_count: u32,
    /// Active endpoint count
    pub endpoint_count: u32,
    /// Last heartbeat
    pub last_heartbeat: u64,
    /// Cascade connections (node IDs)
    pub connections: Vec<String>,
}

impl CascadeNode {
    pub fn new(
        id: &str,
        role: NodeRole,
        region: Region,
        cascade_addr: SocketAddr,
        client_addr: SocketAddr,
    ) -> Self {
        Self {
            id: id.to_string(),
            role,
            status: NodeStatus::Healthy,
            region,
            cascade_addr,
            client_addr,
            load: 0.0,
            session_count: 0,
            endpoint_count: 0,
            last_heartbeat: 0,
            connections: Vec::new(),
        }
    }

    pub fn is_available(&self) -> bool {
        matches!(self.status, NodeStatus::Healthy | NodeStatus::Degraded)
            && self.load < 0.9
    }
}

/// Cascade session state
#[derive(Debug, Clone)]
pub struct CascadeSession {
    /// Session ID
    pub session_id: u64,
    /// Origin node ID
    pub origin_node: String,
    /// Nodes participating in this session
    pub participating_nodes: HashSet<String>,
    /// Endpoints per node
    pub endpoints_by_node: HashMap<String, Vec<u64>>,
    /// Created at
    pub created_at: Instant,
}

impl CascadeSession {
    pub fn new(session_id: u64, origin_node: &str) -> Self {
        let mut participating_nodes = HashSet::new();
        participating_nodes.insert(origin_node.to_string());

        Self {
            session_id,
            origin_node: origin_node.to_string(),
            participating_nodes,
            endpoints_by_node: HashMap::new(),
            created_at: Instant::now(),
        }
    }

    pub fn add_node(&mut self, node_id: &str) {
        self.participating_nodes.insert(node_id.to_string());
    }

    pub fn remove_node(&mut self, node_id: &str) {
        self.participating_nodes.remove(node_id);
        self.endpoints_by_node.remove(node_id);
    }

    pub fn add_endpoint(&mut self, node_id: &str, endpoint_id: u64) {
        self.endpoints_by_node
            .entry(node_id.to_string())
            .or_default()
            .push(endpoint_id);
    }

    pub fn remove_endpoint(&mut self, node_id: &str, endpoint_id: u64) {
        if let Some(endpoints) = self.endpoints_by_node.get_mut(node_id) {
            endpoints.retain(|&id| id != endpoint_id);
        }
    }

    pub fn total_endpoints(&self) -> usize {
        self.endpoints_by_node.values().map(|v| v.len()).sum()
    }
}

/// Cascade event
#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum CascadeEvent {
    /// Node joined the cluster
    NodeJoined { node_id: String },
    /// Node left the cluster
    NodeLeft { node_id: String },
    /// Node status changed
    NodeStatusChanged { node_id: String, status: NodeStatus },
    /// Session created on a node
    SessionCreated { session_id: u64, origin_node: String },
    /// Session ended
    SessionEnded { session_id: u64 },
    /// Endpoint joined session on a node
    EndpointJoined { session_id: u64, node_id: String, endpoint_id: u64 },
    /// Endpoint left
    EndpointLeft { session_id: u64, node_id: String, endpoint_id: u64 },
    /// Media route established
    MediaRouteEstablished { from_node: String, to_node: String, session_id: u64 },
}

/// Cascade manager
pub struct CascadeManager {
    /// This node's ID
    local_node_id: String,
    /// Known nodes
    nodes: HashMap<String, CascadeNode>,
    /// Active cascade sessions
    sessions: HashMap<u64, CascadeSession>,
    /// Event sender
    event_tx: Option<mpsc::UnboundedSender<CascadeEvent>>,
    /// Configuration
    config: CascadeConfig,
}

/// Cascade configuration
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CascadeConfig {
    /// Enable cascade mode
    pub enabled: bool,
    /// Heartbeat interval
    pub heartbeat_interval: Duration,
    /// Node timeout
    pub node_timeout: Duration,
    /// Max hops for cascade routing
    pub max_hops: u8,
    /// Prefer same-region nodes
    pub prefer_same_region: bool,
    /// Enable media relay between nodes
    pub media_relay_enabled: bool,
}

impl Default for CascadeConfig {
    fn default() -> Self {
        Self {
            enabled: true,
            heartbeat_interval: Duration::from_secs(5),
            node_timeout: Duration::from_secs(30),
            max_hops: 3,
            prefer_same_region: true,
            media_relay_enabled: true,
        }
    }
}

impl CascadeManager {
    pub fn new(local_node_id: &str, config: CascadeConfig) -> Self {
        Self {
            local_node_id: local_node_id.to_string(),
            nodes: HashMap::new(),
            sessions: HashMap::new(),
            event_tx: None,
            config,
        }
    }

    /// Set event channel
    pub fn set_event_channel(&mut self, tx: mpsc::UnboundedSender<CascadeEvent>) {
        self.event_tx = Some(tx);
    }

    /// Register the local node
    pub fn register_local_node(&mut self, node: CascadeNode) {
        self.nodes.insert(node.id.clone(), node);
    }

    /// Add a remote node
    pub fn add_node(&mut self, node: CascadeNode) {
        let node_id = node.id.clone();
        self.nodes.insert(node_id.clone(), node);
        self.emit_event(CascadeEvent::NodeJoined { node_id });
    }

    /// Remove a node
    pub fn remove_node(&mut self, node_id: &str) {
        if self.nodes.remove(node_id).is_some() {
            // Remove from all sessions
            for session in self.sessions.values_mut() {
                session.remove_node(node_id);
            }
            self.emit_event(CascadeEvent::NodeLeft { node_id: node_id.to_string() });
        }
    }

    /// Update node status
    pub fn update_node_status(&mut self, node_id: &str, status: NodeStatus) {
        if let Some(node) = self.nodes.get_mut(node_id) {
            node.status = status;
            self.emit_event(CascadeEvent::NodeStatusChanged {
                node_id: node_id.to_string(),
                status,
            });
        }
    }

    /// Update node metrics
    pub fn update_node_metrics(&mut self, node_id: &str, load: f32, sessions: u32, endpoints: u32) {
        if let Some(node) = self.nodes.get_mut(node_id) {
            node.load = load;
            node.session_count = sessions;
            node.endpoint_count = endpoints;
            node.last_heartbeat = std::time::SystemTime::now()
                .duration_since(std::time::UNIX_EPOCH)
                .unwrap()
                .as_secs();
        }
    }

    /// Create a cascade session
    pub fn create_session(&mut self, session_id: u64) -> CascadeSession {
        let session = CascadeSession::new(session_id, &self.local_node_id);
        self.sessions.insert(session_id, session.clone());
        
        self.emit_event(CascadeEvent::SessionCreated {
            session_id,
            origin_node: self.local_node_id.clone(),
        });

        session
    }

    /// End a cascade session
    pub fn end_session(&mut self, session_id: u64) {
        if self.sessions.remove(&session_id).is_some() {
            self.emit_event(CascadeEvent::SessionEnded { session_id });
        }
    }

    /// Join an existing session on this node
    pub fn join_session(&mut self, session_id: u64, endpoint_id: u64) {
        if let Some(session) = self.sessions.get_mut(&session_id) {
            session.add_node(&self.local_node_id);
            session.add_endpoint(&self.local_node_id, endpoint_id);
            
            self.emit_event(CascadeEvent::EndpointJoined {
                session_id,
                node_id: self.local_node_id.clone(),
                endpoint_id,
            });
        }
    }

    /// Leave a session
    pub fn leave_session(&mut self, session_id: u64, endpoint_id: u64) {
        if let Some(session) = self.sessions.get_mut(&session_id) {
            session.remove_endpoint(&self.local_node_id, endpoint_id);
            
            self.emit_event(CascadeEvent::EndpointLeft {
                session_id,
                node_id: self.local_node_id.clone(),
                endpoint_id,
            });
        }
    }

    /// Find best node for a new endpoint
    pub fn find_best_node(&self, client_region: Option<&Region>) -> Option<&CascadeNode> {
        let available_nodes: Vec<_> = self.nodes.values()
            .filter(|n| n.is_available())
            .collect();

        if available_nodes.is_empty() {
            return None;
        }

        // If we have a client region and prefer same-region
        if let Some(region) = client_region {
            if self.config.prefer_same_region {
                // First try same region
                if let Some(node) = available_nodes.iter()
                    .filter(|n| n.region.code == region.code)
                    .min_by(|a, b| a.load.partial_cmp(&b.load).unwrap())
                {
                    return Some(node);
                }

                // Then try same continent
                if let Some(node) = available_nodes.iter()
                    .filter(|n| n.region.continent == region.continent)
                    .min_by(|a, b| a.load.partial_cmp(&b.load).unwrap())
                {
                    return Some(node);
                }
            }
        }

        // Fall back to least loaded
        available_nodes.into_iter()
            .min_by(|a, b| a.load.partial_cmp(&b.load).unwrap())
    }

    /// Get all nodes
    pub fn nodes(&self) -> impl Iterator<Item = &CascadeNode> {
        self.nodes.values()
    }

    /// Get node by ID
    pub fn get_node(&self, node_id: &str) -> Option<&CascadeNode> {
        self.nodes.get(node_id)
    }

    /// Get session
    pub fn get_session(&self, session_id: u64) -> Option<&CascadeSession> {
        self.sessions.get(&session_id)
    }

    /// Get statistics
    pub fn stats(&self) -> CascadeStats {
        CascadeStats {
            node_count: self.nodes.len(),
            healthy_nodes: self.nodes.values().filter(|n| n.status == NodeStatus::Healthy).count(),
            session_count: self.sessions.len(),
            total_endpoints: self.sessions.values().map(|s| s.total_endpoints()).sum(),
        }
    }

    fn emit_event(&self, event: CascadeEvent) {
        if let Some(tx) = &self.event_tx {
            let _ = tx.send(event);
        }
    }
}

/// Cascade statistics
#[derive(Debug, Clone, Default)]
pub struct CascadeStats {
    pub node_count: usize,
    pub healthy_nodes: usize,
    pub session_count: usize,
    pub total_endpoints: usize,
}

/// Media routing table entry
#[derive(Debug, Clone)]
pub struct MediaRoute {
    /// Source node
    pub from_node: String,
    /// Destination node
    pub to_node: String,
    /// Session ID
    pub session_id: u64,
    /// Streams being forwarded
    pub stream_ids: Vec<u64>,
    /// Established at
    pub established_at: Instant,
    /// Bytes forwarded
    pub bytes_forwarded: u64,
}

/// Media router for cascade forwarding
pub struct MediaRouter {
    /// Active routes
    routes: HashMap<String, MediaRoute>,
}

impl MediaRouter {
    pub fn new() -> Self {
        Self {
            routes: HashMap::new(),
        }
    }

    /// Add a media route
    pub fn add_route(
        &mut self,
        from_node: &str,
        to_node: &str,
        session_id: u64,
    ) -> String {
        let route_id = format!("{}->{}:{}", from_node, to_node, session_id);
        
        let route = MediaRoute {
            from_node: from_node.to_string(),
            to_node: to_node.to_string(),
            session_id,
            stream_ids: Vec::new(),
            established_at: Instant::now(),
            bytes_forwarded: 0,
        };

        self.routes.insert(route_id.clone(), route);
        route_id
    }

    /// Remove a route
    pub fn remove_route(&mut self, route_id: &str) {
        self.routes.remove(route_id);
    }

    /// Add stream to route
    pub fn add_stream_to_route(&mut self, route_id: &str, stream_id: u64) {
        if let Some(route) = self.routes.get_mut(route_id) {
            if !route.stream_ids.contains(&stream_id) {
                route.stream_ids.push(stream_id);
            }
        }
    }

    /// Get routes for session
    pub fn routes_for_session(&self, session_id: u64) -> Vec<&MediaRoute> {
        self.routes.values()
            .filter(|r| r.session_id == session_id)
            .collect()
    }

    /// Update bytes forwarded
    pub fn update_bytes_forwarded(&mut self, route_id: &str, bytes: u64) {
        if let Some(route) = self.routes.get_mut(route_id) {
            route.bytes_forwarded += bytes;
        }
    }
}

impl Default for MediaRouter {
    fn default() -> Self {
        Self::new()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn test_node(id: &str, region: Region) -> CascadeNode {
        CascadeNode::new(
            id,
            NodeRole::Edge,
            region,
            "127.0.0.1:5000".parse().unwrap(),
            "127.0.0.1:3478".parse().unwrap(),
        )
    }

    #[test]
    fn test_cascade_manager_creation() {
        let manager = CascadeManager::new("node-1", CascadeConfig::default());
        assert_eq!(manager.local_node_id, "node-1");
        assert!(manager.nodes.is_empty());
    }

    #[test]
    fn test_add_remove_nodes() {
        let mut manager = CascadeManager::new("node-1", CascadeConfig::default());

        let node = test_node("node-2", Region::us_east());
        manager.add_node(node);

        assert_eq!(manager.nodes.len(), 1);
        assert!(manager.get_node("node-2").is_some());

        manager.remove_node("node-2");
        assert!(manager.nodes.is_empty());
    }

    #[test]
    fn test_find_best_node_by_region() {
        let mut manager = CascadeManager::new("node-1", CascadeConfig::default());

        let mut node1 = test_node("node-us", Region::us_east());
        node1.load = 0.3;
        manager.add_node(node1);

        let mut node2 = test_node("node-eu", Region::eu_west());
        node2.load = 0.2;
        manager.add_node(node2);

        // Client from EU should get EU node
        let best = manager.find_best_node(Some(&Region::eu_west()));
        assert_eq!(best.unwrap().id, "node-eu");

        // Client from US should get US node
        let best = manager.find_best_node(Some(&Region::us_east()));
        assert_eq!(best.unwrap().id, "node-us");
    }

    #[test]
    fn test_cascade_session() {
        let mut session = CascadeSession::new(100, "origin");

        session.add_node("edge-1");
        session.add_endpoint("edge-1", 1);
        session.add_endpoint("edge-1", 2);

        assert_eq!(session.participating_nodes.len(), 2);
        assert_eq!(session.total_endpoints(), 2);

        session.remove_endpoint("edge-1", 1);
        assert_eq!(session.total_endpoints(), 1);
    }

    #[test]
    fn test_media_router() {
        let mut router = MediaRouter::new();

        let route_id = router.add_route("node-1", "node-2", 100);
        router.add_stream_to_route(&route_id, 1);
        router.add_stream_to_route(&route_id, 2);

        let routes = router.routes_for_session(100);
        assert_eq!(routes.len(), 1);
        assert_eq!(routes[0].stream_ids.len(), 2);
    }

    #[test]
    fn test_node_availability() {
        let mut node = test_node("test", Region::us_east());

        assert!(node.is_available());

        node.status = NodeStatus::Draining;
        assert!(!node.is_available());

        node.status = NodeStatus::Healthy;
        node.load = 0.95;
        assert!(!node.is_available());
    }
}
