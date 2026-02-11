//! Simulcast - Multi-quality video streaming
//!
//! Simulcast allows senders to encode video at multiple resolutions/qualities
//! simultaneously. The SFU then selects the best quality for each receiver
//! based on their available bandwidth.
//!
//! ## How Zoom/Meet/Teams do it
//!
//! ```text
//! ┌─────────────────────────────────────────────────────────────────┐
//! │                     SIMULCAST ARCHITECTURE                      │
//! │                                                                 │
//! │   ┌─────────────┐                                              │
//! │   │   Sender    │                                              │
//! │   │  (Camera)   │                                              │
//! │   └──────┬──────┘                                              │
//! │          │                                                      │
//! │          ▼                                                      │
//! │   ┌─────────────────────────────────────────┐                  │
//! │   │           Video Encoder                  │                  │
//! │   │                                          │                  │
//! │   │  ┌─────────┐ ┌─────────┐ ┌─────────┐   │                  │
//! │   │  │  HIGH   │ │  MID    │ │  LOW    │   │                  │
//! │   │  │ 1080p   │ │  720p   │ │  360p   │   │                  │
//! │   │  │ 2.5Mbps │ │  1Mbps  │ │ 250Kbps │   │                  │
//! │   │  └────┬────┘ └────┬────┘ └────┬────┘   │                  │
//! │   └───────┼───────────┼───────────┼────────┘                  │
//! │           │           │           │                            │
//! │           ▼           ▼           ▼                            │
//! │   ┌─────────────────────────────────────────┐                  │
//! │   │                 SFU                      │                  │
//! │   │                                          │                  │
//! │   │   Bandwidth estimation per receiver      │                  │
//! │   │   → High bandwidth → forward HIGH        │                  │
//! │   │   → Medium bandwidth → forward MID       │                  │
//! │   │   → Low bandwidth → forward LOW          │                  │
//! │   │                                          │                  │
//! │   └───────┬───────────┬───────────┬─────────┘                  │
//! │           │           │           │                            │
//! │           ▼           ▼           ▼                            │
//! │      ┌────────┐  ┌────────┐  ┌────────┐                       │
//! │      │Receiver│  │Receiver│  │Receiver│                       │
//! │      │ WiFi   │  │  4G    │  │  3G    │                       │
//! │      │ HIGH   │  │  MID   │  │  LOW   │                       │
//! │      └────────┘  └────────┘  └────────┘                       │
//! └─────────────────────────────────────────────────────────────────┘
//! ```

use std::collections::HashMap;
use std::time::{Duration, Instant};

use serde::{Deserialize, Serialize};

/// Simulcast layer quality
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub enum SimulcastLayer {
    /// Low quality (e.g., 360p, 250kbps)
    Low,
    /// Medium quality (e.g., 720p, 1Mbps)
    Medium,
    /// High quality (e.g., 1080p, 2.5Mbps)
    High,
}

impl SimulcastLayer {
    /// Get the RID (RTP Stream ID) for this layer
    pub fn rid(&self) -> &'static str {
        match self {
            SimulcastLayer::Low => "l",
            SimulcastLayer::Medium => "m",
            SimulcastLayer::High => "h",
        }
    }

    /// Get typical target bitrate in kbps
    pub fn target_bitrate_kbps(&self) -> u32 {
        match self {
            SimulcastLayer::Low => 250,
            SimulcastLayer::Medium => 1000,
            SimulcastLayer::High => 2500,
        }
    }

    /// Get typical resolution
    pub fn resolution(&self) -> (u32, u32) {
        match self {
            SimulcastLayer::Low => (640, 360),
            SimulcastLayer::Medium => (1280, 720),
            SimulcastLayer::High => (1920, 1080),
        }
    }

    /// Get typical framerate
    pub fn framerate(&self) -> u32 {
        match self {
            SimulcastLayer::Low => 15,
            SimulcastLayer::Medium => 30,
            SimulcastLayer::High => 30,
        }
    }

    /// Select best layer for given bandwidth
    pub fn for_bandwidth(available_kbps: u32) -> Self {
        if available_kbps >= 2000 {
            SimulcastLayer::High
        } else if available_kbps >= 750 {
            SimulcastLayer::Medium
        } else {
            SimulcastLayer::Low
        }
    }

    /// All layers in order (high to low)
    pub fn all() -> &'static [SimulcastLayer] {
        &[SimulcastLayer::High, SimulcastLayer::Medium, SimulcastLayer::Low]
    }
}

impl Default for SimulcastLayer {
    fn default() -> Self {
        SimulcastLayer::Medium
    }
}

/// Simulcast stream info
#[derive(Debug, Clone)]
pub struct SimulcastStream {
    /// Layer quality
    pub layer: SimulcastLayer,
    /// SSRC for this layer
    pub ssrc: u32,
    /// RTX SSRC for retransmissions
    pub rtx_ssrc: Option<u32>,
    /// Current bitrate in bps
    pub current_bitrate: u64,
    /// Packets sent
    pub packets_sent: u64,
    /// Bytes sent
    pub bytes_sent: u64,
    /// Packet loss percentage
    pub packet_loss: f32,
    /// Last keyframe received
    pub last_keyframe: Option<Instant>,
    /// Is layer active (receiving data)
    pub active: bool,
}

impl SimulcastStream {
    pub fn new(layer: SimulcastLayer, ssrc: u32) -> Self {
        Self {
            layer,
            ssrc,
            rtx_ssrc: None,
            current_bitrate: 0,
            packets_sent: 0,
            bytes_sent: 0,
            packet_loss: 0.0,
            last_keyframe: None,
            active: true,
        }
    }
}

/// Simulcast configuration
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SimulcastConfig {
    /// Enable simulcast
    pub enabled: bool,
    /// Number of layers (1-3)
    pub num_layers: u8,
    /// Minimum layer to forward
    pub min_layer: SimulcastLayer,
    /// Maximum layer to forward
    pub max_layer: SimulcastLayer,
    /// Enable temporal scalability (SVC)
    pub temporal_layers: bool,
    /// Number of temporal layers
    pub num_temporal_layers: u8,
}

impl Default for SimulcastConfig {
    fn default() -> Self {
        Self {
            enabled: true,
            num_layers: 3,
            min_layer: SimulcastLayer::Low,
            max_layer: SimulcastLayer::High,
            temporal_layers: true,
            num_temporal_layers: 3,
        }
    }
}

/// Publisher (sender) simulcast state
#[derive(Debug)]
pub struct PublisherSimulcast {
    /// Endpoint ID
    pub endpoint_id: u64,
    /// Available layers
    pub layers: HashMap<SimulcastLayer, SimulcastStream>,
    /// Configuration
    pub config: SimulcastConfig,
    /// Last stats update
    pub last_update: Instant,
}

impl PublisherSimulcast {
    pub fn new(endpoint_id: u64) -> Self {
        Self {
            endpoint_id,
            layers: HashMap::new(),
            config: SimulcastConfig::default(),
            last_update: Instant::now(),
        }
    }

    /// Add a simulcast layer
    pub fn add_layer(&mut self, layer: SimulcastLayer, ssrc: u32) {
        self.layers.insert(layer, SimulcastStream::new(layer, ssrc));
    }

    /// Get best available layer
    pub fn best_available_layer(&self) -> Option<SimulcastLayer> {
        for layer in SimulcastLayer::all() {
            if let Some(stream) = self.layers.get(layer) {
                if stream.active {
                    return Some(*layer);
                }
            }
        }
        None
    }

    /// Get layer for target bandwidth
    pub fn layer_for_bandwidth(&self, available_kbps: u32) -> Option<SimulcastLayer> {
        let target = SimulcastLayer::for_bandwidth(available_kbps);
        
        // Find the best available layer at or below target
        let layers_ordered = match target {
            SimulcastLayer::High => vec![SimulcastLayer::High, SimulcastLayer::Medium, SimulcastLayer::Low],
            SimulcastLayer::Medium => vec![SimulcastLayer::Medium, SimulcastLayer::Low],
            SimulcastLayer::Low => vec![SimulcastLayer::Low],
        };

        for layer in layers_ordered {
            if let Some(stream) = self.layers.get(&layer) {
                if stream.active {
                    return Some(layer);
                }
            }
        }

        None
    }
}

/// Subscriber (receiver) simulcast state
#[derive(Debug)]
pub struct SubscriberSimulcast {
    /// Endpoint ID
    pub endpoint_id: u64,
    /// Currently subscribed layer per publisher
    pub subscriptions: HashMap<u64, SubscribedLayer>,
    /// Estimated available bandwidth in kbps
    pub estimated_bandwidth_kbps: u32,
    /// Last bandwidth update
    pub last_bandwidth_update: Instant,
}

/// Subscription to a publisher's layer
#[derive(Debug, Clone)]
pub struct SubscribedLayer {
    /// Publisher endpoint ID
    pub publisher_id: u64,
    /// Current layer
    pub current_layer: SimulcastLayer,
    /// Target layer (may differ during switching)
    pub target_layer: SimulcastLayer,
    /// Is switching in progress
    pub switching: bool,
    /// Time of last layer switch
    pub last_switch: Instant,
}

impl SubscriberSimulcast {
    pub fn new(endpoint_id: u64) -> Self {
        Self {
            endpoint_id,
            subscriptions: HashMap::new(),
            estimated_bandwidth_kbps: 2500, // Start optimistic
            last_bandwidth_update: Instant::now(),
        }
    }

    /// Subscribe to a publisher
    pub fn subscribe(&mut self, publisher_id: u64, initial_layer: SimulcastLayer) {
        self.subscriptions.insert(publisher_id, SubscribedLayer {
            publisher_id,
            current_layer: initial_layer,
            target_layer: initial_layer,
            switching: false,
            last_switch: Instant::now(),
        });
    }

    /// Unsubscribe from a publisher
    pub fn unsubscribe(&mut self, publisher_id: u64) {
        self.subscriptions.remove(&publisher_id);
    }

    /// Update bandwidth estimate
    pub fn update_bandwidth(&mut self, bandwidth_kbps: u32) {
        self.estimated_bandwidth_kbps = bandwidth_kbps;
        self.last_bandwidth_update = Instant::now();
    }

    /// Request layer switch for a publisher
    pub fn request_layer_switch(&mut self, publisher_id: u64, target_layer: SimulcastLayer) -> bool {
        if let Some(sub) = self.subscriptions.get_mut(&publisher_id) {
            if sub.current_layer != target_layer && !sub.switching {
                sub.target_layer = target_layer;
                sub.switching = true;
                return true;
            }
        }
        false
    }

    /// Complete layer switch
    pub fn complete_layer_switch(&mut self, publisher_id: u64) {
        if let Some(sub) = self.subscriptions.get_mut(&publisher_id) {
            sub.current_layer = sub.target_layer;
            sub.switching = false;
            sub.last_switch = Instant::now();
        }
    }
}

/// Simulcast manager for the SFU
pub struct SimulcastManager {
    /// Publishers
    publishers: HashMap<u64, PublisherSimulcast>,
    /// Subscribers
    subscribers: HashMap<u64, SubscriberSimulcast>,
    /// Default config
    default_config: SimulcastConfig,
}

impl SimulcastManager {
    pub fn new() -> Self {
        Self {
            publishers: HashMap::new(),
            subscribers: HashMap::new(),
            default_config: SimulcastConfig::default(),
        }
    }

    /// Register a publisher
    pub fn register_publisher(&mut self, endpoint_id: u64) {
        self.publishers.insert(endpoint_id, PublisherSimulcast::new(endpoint_id));
    }

    /// Register a subscriber
    pub fn register_subscriber(&mut self, endpoint_id: u64) {
        self.subscribers.insert(endpoint_id, SubscriberSimulcast::new(endpoint_id));
    }

    /// Unregister an endpoint
    pub fn unregister(&mut self, endpoint_id: u64) {
        self.publishers.remove(&endpoint_id);
        self.subscribers.remove(&endpoint_id);
        
        // Remove subscriptions to this publisher
        for sub in self.subscribers.values_mut() {
            sub.unsubscribe(endpoint_id);
        }
    }

    /// Add simulcast layer to publisher
    pub fn add_publisher_layer(&mut self, endpoint_id: u64, layer: SimulcastLayer, ssrc: u32) {
        if let Some(pub_state) = self.publishers.get_mut(&endpoint_id) {
            pub_state.add_layer(layer, ssrc);
        }
    }

    /// Subscribe to a publisher
    pub fn subscribe(&mut self, subscriber_id: u64, publisher_id: u64) -> Option<SimulcastLayer> {
        // Get subscriber bandwidth
        let bandwidth = self.subscribers.get(&subscriber_id)
            .map(|s| s.estimated_bandwidth_kbps)
            .unwrap_or(2500);

        // Get best layer from publisher
        let layer = self.publishers.get(&publisher_id)
            .and_then(|p| p.layer_for_bandwidth(bandwidth))?;

        // Create subscription
        if let Some(sub) = self.subscribers.get_mut(&subscriber_id) {
            sub.subscribe(publisher_id, layer);
        }

        Some(layer)
    }

    /// Update subscriber bandwidth and adjust layers
    pub fn update_subscriber_bandwidth(&mut self, subscriber_id: u64, bandwidth_kbps: u32) -> Vec<LayerSwitch> {
        let mut switches = Vec::new();

        if let Some(sub) = self.subscribers.get_mut(&subscriber_id) {
            sub.update_bandwidth(bandwidth_kbps);

            // Check each subscription
            for (&publisher_id, subscription) in &sub.subscriptions {
                // Get ideal layer for new bandwidth
                if let Some(publisher) = self.publishers.get(&publisher_id) {
                    if let Some(new_layer) = publisher.layer_for_bandwidth(bandwidth_kbps) {
                        if new_layer != subscription.current_layer {
                            switches.push(LayerSwitch {
                                subscriber_id,
                                publisher_id,
                                from_layer: subscription.current_layer,
                                to_layer: new_layer,
                            });
                        }
                    }
                }
            }
        }

        // Apply switches
        for switch in &switches {
            if let Some(sub) = self.subscribers.get_mut(&switch.subscriber_id) {
                sub.request_layer_switch(switch.publisher_id, switch.to_layer);
            }
        }

        switches
    }

    /// Get SSRC for forwarding
    pub fn get_forward_ssrc(&self, subscriber_id: u64, publisher_id: u64) -> Option<u32> {
        let layer = self.subscribers.get(&subscriber_id)?
            .subscriptions.get(&publisher_id)?
            .current_layer;

        self.publishers.get(&publisher_id)?
            .layers.get(&layer)?
            .ssrc.into()
    }

    /// Get statistics
    pub fn stats(&self) -> SimulcastStats {
        SimulcastStats {
            publisher_count: self.publishers.len(),
            subscriber_count: self.subscribers.len(),
            total_layers: self.publishers.values()
                .map(|p| p.layers.len())
                .sum(),
            total_subscriptions: self.subscribers.values()
                .map(|s| s.subscriptions.len())
                .sum(),
        }
    }
}

impl Default for SimulcastManager {
    fn default() -> Self {
        Self::new()
    }
}

/// Layer switch event
#[derive(Debug, Clone)]
pub struct LayerSwitch {
    pub subscriber_id: u64,
    pub publisher_id: u64,
    pub from_layer: SimulcastLayer,
    pub to_layer: SimulcastLayer,
}

/// Simulcast statistics
#[derive(Debug, Clone, Default)]
pub struct SimulcastStats {
    pub publisher_count: usize,
    pub subscriber_count: usize,
    pub total_layers: usize,
    pub total_subscriptions: usize,
}

/// SDP helpers for simulcast
pub mod sdp {
    use super::SimulcastLayer;

    /// Generate simulcast SDP attributes
    pub fn generate_simulcast_attrs(layers: &[SimulcastLayer], direction: &str) -> String {
        let rids: Vec<&str> = layers.iter().map(|l| l.rid()).collect();
        
        let mut attrs = String::new();
        
        // RID attributes
        for layer in layers {
            attrs.push_str(&format!(
                "a=rid:{} {}\r\n",
                layer.rid(),
                direction
            ));
        }
        
        // Simulcast attribute
        attrs.push_str(&format!(
            "a=simulcast:{} {}\r\n",
            direction,
            rids.join(";")
        ));
        
        attrs
    }

    /// Parse simulcast layers from SDP
    pub fn parse_simulcast_layers(sdp: &str) -> Vec<SimulcastLayer> {
        let mut layers = Vec::new();

        for line in sdp.lines() {
            if line.starts_with("a=rid:") {
                let rid = line.trim_start_matches("a=rid:")
                    .split_whitespace()
                    .next()
                    .unwrap_or("");
                
                match rid {
                    "l" => layers.push(SimulcastLayer::Low),
                    "m" => layers.push(SimulcastLayer::Medium),
                    "h" => layers.push(SimulcastLayer::High),
                    _ => {}
                }
            }
        }

        layers
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_simulcast_layer_selection() {
        assert_eq!(SimulcastLayer::for_bandwidth(3000), SimulcastLayer::High);
        assert_eq!(SimulcastLayer::for_bandwidth(2000), SimulcastLayer::High);
        assert_eq!(SimulcastLayer::for_bandwidth(1500), SimulcastLayer::Medium);
        assert_eq!(SimulcastLayer::for_bandwidth(750), SimulcastLayer::Medium);
        assert_eq!(SimulcastLayer::for_bandwidth(500), SimulcastLayer::Low);
        assert_eq!(SimulcastLayer::for_bandwidth(100), SimulcastLayer::Low);
    }

    #[test]
    fn test_publisher_simulcast() {
        let mut publisher = PublisherSimulcast::new(1);
        
        publisher.add_layer(SimulcastLayer::High, 1000);
        publisher.add_layer(SimulcastLayer::Medium, 1001);
        publisher.add_layer(SimulcastLayer::Low, 1002);

        assert_eq!(publisher.best_available_layer(), Some(SimulcastLayer::High));
        assert_eq!(publisher.layer_for_bandwidth(3000), Some(SimulcastLayer::High));
        assert_eq!(publisher.layer_for_bandwidth(800), Some(SimulcastLayer::Medium));
        assert_eq!(publisher.layer_for_bandwidth(200), Some(SimulcastLayer::Low));
    }

    #[test]
    fn test_subscriber_simulcast() {
        let mut subscriber = SubscriberSimulcast::new(2);
        
        subscriber.subscribe(1, SimulcastLayer::High);
        assert_eq!(subscriber.subscriptions.len(), 1);
        
        subscriber.update_bandwidth(500);
        assert_eq!(subscriber.estimated_bandwidth_kbps, 500);

        assert!(subscriber.request_layer_switch(1, SimulcastLayer::Low));
        subscriber.complete_layer_switch(1);
        
        assert_eq!(
            subscriber.subscriptions.get(&1).unwrap().current_layer,
            SimulcastLayer::Low
        );
    }

    #[test]
    fn test_simulcast_manager() {
        let mut manager = SimulcastManager::new();

        // Register publisher with layers
        manager.register_publisher(1);
        manager.add_publisher_layer(1, SimulcastLayer::High, 1000);
        manager.add_publisher_layer(1, SimulcastLayer::Medium, 1001);
        manager.add_publisher_layer(1, SimulcastLayer::Low, 1002);

        // Register subscriber
        manager.register_subscriber(2);

        // Subscribe
        let layer = manager.subscribe(2, 1);
        assert_eq!(layer, Some(SimulcastLayer::High)); // Default bandwidth is high

        // Lower bandwidth
        let switches = manager.update_subscriber_bandwidth(2, 500);
        assert_eq!(switches.len(), 1);
        assert_eq!(switches[0].to_layer, SimulcastLayer::Low);
    }

    #[test]
    fn test_sdp_generation() {
        let layers = vec![SimulcastLayer::High, SimulcastLayer::Medium, SimulcastLayer::Low];
        let attrs = sdp::generate_simulcast_attrs(&layers, "send");

        assert!(attrs.contains("a=rid:h send"));
        assert!(attrs.contains("a=rid:m send"));
        assert!(attrs.contains("a=rid:l send"));
        assert!(attrs.contains("a=simulcast:send h;m;l"));
    }

    #[test]
    fn test_sdp_parsing() {
        let sdp = r#"
a=rid:h send
a=rid:m send
a=rid:l send
a=simulcast:send h;m;l
"#;
        let layers = sdp::parse_simulcast_layers(sdp);
        assert_eq!(layers.len(), 3);
        assert!(layers.contains(&SimulcastLayer::High));
        assert!(layers.contains(&SimulcastLayer::Medium));
        assert!(layers.contains(&SimulcastLayer::Low));
    }
}
