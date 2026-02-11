//! Bandwidth Estimation - Adaptive Quality Control
//!
//! This module implements bandwidth estimation and congestion control
//! similar to what Zoom, Meet, and Teams use for smooth video.
//!
//! ## How GAFAM do it
//!
//! ```text
//! ┌─────────────────────────────────────────────────────────────────┐
//! │                 BANDWIDTH ESTIMATION LOOP                       │
//! │                                                                 │
//! │   ┌──────────────────────────────────────────────────────┐     │
//! │   │                    SENDER                             │     │
//! │   │                                                       │     │
//! │   │  ┌─────────┐   ┌─────────┐   ┌─────────────────┐    │     │
//! │   │  │ Encoder │──►│   RTP   │──►│ Transport-wide  │    │     │
//! │   │  │         │   │ Pacer   │   │   CC (TWCC)     │    │     │
//! │   │  └─────────┘   └─────────┘   └────────┬────────┘    │     │
//! │   │       ▲                               │             │     │
//! │   │       │                               │             │     │
//! │   │       │  ┌────────────────────────────┘             │     │
//! │   │       │  │                                          │     │
//! │   │  ┌────┴──┴────┐                                     │     │
//! │   │  │  Bitrate   │◄─────────────────────────────┐      │     │
//! │   │  │ Controller │                              │      │     │
//! │   │  └────────────┘                              │      │     │
//! │   └──────────────────────────────────────────────┼──────┘     │
//! │                                                  │            │
//! │   ┌──────────────────────────────────────────────┼──────┐     │
//! │   │                    RECEIVER                  │       │     │
//! │   │                                              │       │     │
//! │   │  ┌─────────────┐   ┌──────────────────┐     │       │     │
//! │   │  │    RTCP     │──►│  Receive-side    │─────┘       │     │
//! │   │  │  Feedback   │   │  BWE (REMB/TWCC) │             │     │
//! │   │  └─────────────┘   └──────────────────┘             │     │
//! │   │                                                      │     │
//! │   └──────────────────────────────────────────────────────┘     │
//! │                                                                 │
//! │   Algorithms:                                                  │
//! │   • GCC (Google Congestion Control) - delay-based             │
//! │   • REMB (Receiver Estimated Max Bitrate)                     │
//! │   • TWCC (Transport-Wide Congestion Control)                  │
//! │   • BBR (Bottleneck Bandwidth and RTT) - experimental         │
//! │                                                                 │
//! └─────────────────────────────────────────────────────────────────┘
//! ```

use std::collections::VecDeque;
use std::time::{Duration, Instant};

use serde::{Deserialize, Serialize};

/// Bandwidth estimation algorithm
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum BweAlgorithm {
    /// Google Congestion Control (delay-based)
    Gcc,
    /// Receiver Estimated Max Bitrate
    Remb,
    /// Transport-Wide Congestion Control
    Twcc,
    /// Simple loss-based
    LossBased,
}

impl Default for BweAlgorithm {
    fn default() -> Self {
        Self::Gcc
    }
}

/// Bandwidth estimation configuration
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct BweConfig {
    /// Algorithm to use
    pub algorithm: BweAlgorithm,
    /// Minimum bitrate in bps
    pub min_bitrate_bps: u32,
    /// Maximum bitrate in bps
    pub max_bitrate_bps: u32,
    /// Start bitrate in bps
    pub start_bitrate_bps: u32,
    /// Probing enabled
    pub probing_enabled: bool,
    /// RTCP feedback interval
    pub feedback_interval: Duration,
    /// Smoothing factor (0-1)
    pub smoothing_factor: f64,
}

impl Default for BweConfig {
    fn default() -> Self {
        Self {
            algorithm: BweAlgorithm::default(),
            min_bitrate_bps: 100_000,      // 100 kbps
            max_bitrate_bps: 5_000_000,    // 5 Mbps
            start_bitrate_bps: 1_000_000,  // 1 Mbps
            probing_enabled: true,
            feedback_interval: Duration::from_millis(100),
            smoothing_factor: 0.9,
        }
    }
}

/// Network state
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum NetworkState {
    /// Network is underutilized, can increase bitrate
    Underuse,
    /// Network is at optimal capacity
    Normal,
    /// Network is congested, should decrease bitrate
    Overuse,
}

impl Default for NetworkState {
    fn default() -> Self {
        Self::Normal
    }
}

/// Packet timing information for TWCC
#[derive(Debug, Clone, Copy)]
pub struct PacketTiming {
    /// Sequence number
    pub seq: u16,
    /// Send timestamp
    pub send_time: Instant,
    /// Receive timestamp (from feedback)
    pub recv_time: Option<Instant>,
    /// Packet size in bytes
    pub size: u32,
}

/// Bandwidth estimator
pub struct BandwidthEstimator {
    /// Configuration
    config: BweConfig,
    /// Current estimated bitrate (bps)
    estimated_bitrate: u32,
    /// Target bitrate (bps)
    target_bitrate: u32,
    /// Current network state
    network_state: NetworkState,
    /// Recent packet timings
    packet_history: VecDeque<PacketTiming>,
    /// Recent RTT samples
    rtt_samples: VecDeque<Duration>,
    /// Average RTT
    avg_rtt: Duration,
    /// Recent loss rates
    loss_samples: VecDeque<f32>,
    /// Average loss rate
    avg_loss: f32,
    /// Last estimate update
    last_update: Instant,
    /// Last bitrate change
    last_change: Instant,
    /// Probing state
    probing: bool,
    /// Probe bitrate
    probe_bitrate: u32,
}

impl BandwidthEstimator {
    pub fn new(config: BweConfig) -> Self {
        let start_bitrate = config.start_bitrate_bps;
        Self {
            config,
            estimated_bitrate: start_bitrate,
            target_bitrate: start_bitrate,
            network_state: NetworkState::Normal,
            packet_history: VecDeque::with_capacity(1000),
            rtt_samples: VecDeque::with_capacity(100),
            avg_rtt: Duration::from_millis(100),
            loss_samples: VecDeque::with_capacity(100),
            avg_loss: 0.0,
            last_update: Instant::now(),
            last_change: Instant::now(),
            probing: false,
            probe_bitrate: 0,
        }
    }

    pub fn with_defaults() -> Self {
        Self::new(BweConfig::default())
    }

    /// Record a sent packet
    pub fn on_packet_sent(&mut self, seq: u16, size: u32) {
        let timing = PacketTiming {
            seq,
            send_time: Instant::now(),
            recv_time: None,
            size,
        };

        self.packet_history.push_back(timing);

        // Keep only recent packets
        while self.packet_history.len() > 1000 {
            self.packet_history.pop_front();
        }
    }

    /// Record TWCC feedback
    pub fn on_twcc_feedback(&mut self, feedbacks: &[(u16, Option<Instant>)]) {
        for (seq, recv_time) in feedbacks {
            // Find the packet in history
            for timing in self.packet_history.iter_mut() {
                if timing.seq == *seq {
                    timing.recv_time = *recv_time;
                    break;
                }
            }
        }

        self.update_estimate();
    }

    /// Record REMB feedback
    pub fn on_remb_feedback(&mut self, bitrate_bps: u32) {
        // REMB gives us a direct bitrate estimate from receiver
        let smoothed = self.smooth_value(
            self.estimated_bitrate as f64,
            bitrate_bps as f64,
        ) as u32;

        self.estimated_bitrate = smoothed.clamp(
            self.config.min_bitrate_bps,
            self.config.max_bitrate_bps,
        );

        self.update_network_state();
        self.last_update = Instant::now();
    }

    /// Record RTT sample
    pub fn on_rtt_sample(&mut self, rtt: Duration) {
        self.rtt_samples.push_back(rtt);

        // Keep only recent samples
        while self.rtt_samples.len() > 100 {
            self.rtt_samples.pop_front();
        }

        // Update average
        if !self.rtt_samples.is_empty() {
            let sum: Duration = self.rtt_samples.iter().sum();
            self.avg_rtt = sum / self.rtt_samples.len() as u32;
        }
    }

    /// Record loss rate sample
    pub fn on_loss_sample(&mut self, loss_rate: f32) {
        self.loss_samples.push_back(loss_rate);

        // Keep only recent samples
        while self.loss_samples.len() > 100 {
            self.loss_samples.pop_front();
        }

        // Update average
        if !self.loss_samples.is_empty() {
            self.avg_loss = self.loss_samples.iter().sum::<f32>() 
                / self.loss_samples.len() as f32;
        }

        // Loss-based adjustment
        if loss_rate > 0.1 {
            // >10% loss - significant reduction
            self.network_state = NetworkState::Overuse;
            self.decrease_bitrate(0.5);
        } else if loss_rate > 0.02 {
            // >2% loss - mild reduction
            self.network_state = NetworkState::Overuse;
            self.decrease_bitrate(0.9);
        }
    }

    /// Update the bandwidth estimate based on packet history
    fn update_estimate(&mut self) {
        if self.packet_history.is_empty() {
            return;
        }

        // Calculate inter-arrival time variations (GCC algorithm)
        let mut delay_gradients = Vec::new();

        let packets: Vec<_> = self.packet_history.iter()
            .filter(|p| p.recv_time.is_some())
            .collect();

        for window in packets.windows(2) {
            let p1 = window[0];
            let p2 = window[1];

            if let (Some(r1), Some(r2)) = (p1.recv_time, p2.recv_time) {
                let send_delta = p2.send_time.duration_since(p1.send_time);
                let recv_delta = r2.duration_since(r1);

                // Delay gradient: positive = increasing delay (congestion)
                let gradient = recv_delta.as_micros() as i64 - send_delta.as_micros() as i64;
                delay_gradients.push(gradient);
            }
        }

        if delay_gradients.is_empty() {
            return;
        }

        // Calculate trend
        let avg_gradient: i64 = delay_gradients.iter().sum::<i64>() 
            / delay_gradients.len() as i64;

        // Threshold for state detection (in microseconds)
        const OVERUSE_THRESHOLD: i64 = 10_000;  // 10ms
        const UNDERUSE_THRESHOLD: i64 = -5_000; // -5ms

        if avg_gradient > OVERUSE_THRESHOLD {
            self.network_state = NetworkState::Overuse;
            self.decrease_bitrate(0.85);
        } else if avg_gradient < UNDERUSE_THRESHOLD {
            self.network_state = NetworkState::Underuse;
            self.increase_bitrate(1.05);
        } else {
            self.network_state = NetworkState::Normal;
        }

        self.last_update = Instant::now();
    }

    /// Increase bitrate by factor
    fn increase_bitrate(&mut self, factor: f64) {
        // Don't increase too frequently
        if self.last_change.elapsed() < Duration::from_millis(500) {
            return;
        }

        let new_bitrate = (self.estimated_bitrate as f64 * factor) as u32;
        self.estimated_bitrate = new_bitrate.min(self.config.max_bitrate_bps);
        self.last_change = Instant::now();

        tracing::debug!(
            "BWE: Increased bitrate to {} kbps (factor {})",
            self.estimated_bitrate / 1000,
            factor
        );
    }

    /// Decrease bitrate by factor
    fn decrease_bitrate(&mut self, factor: f64) {
        let new_bitrate = (self.estimated_bitrate as f64 * factor) as u32;
        self.estimated_bitrate = new_bitrate.max(self.config.min_bitrate_bps);
        self.last_change = Instant::now();

        tracing::debug!(
            "BWE: Decreased bitrate to {} kbps (factor {})",
            self.estimated_bitrate / 1000,
            factor
        );
    }

    fn smooth_value(&self, old: f64, new: f64) -> f64 {
        self.config.smoothing_factor * old + (1.0 - self.config.smoothing_factor) * new
    }

    fn update_network_state(&mut self) {
        // State is already set by update_estimate or feedback
    }

    /// Get current estimated bitrate
    pub fn estimated_bitrate(&self) -> u32 {
        self.estimated_bitrate
    }

    /// Get target bitrate (what we should send at)
    pub fn target_bitrate(&self) -> u32 {
        if self.probing {
            self.probe_bitrate
        } else {
            self.estimated_bitrate
        }
    }

    /// Get network state
    pub fn network_state(&self) -> NetworkState {
        self.network_state
    }

    /// Get average RTT
    pub fn avg_rtt(&self) -> Duration {
        self.avg_rtt
    }

    /// Get average loss rate
    pub fn avg_loss(&self) -> f32 {
        self.avg_loss
    }

    /// Start probing for higher bandwidth
    pub fn start_probe(&mut self, probe_bitrate: u32) {
        if self.config.probing_enabled && probe_bitrate > self.estimated_bitrate {
            self.probing = true;
            self.probe_bitrate = probe_bitrate.min(self.config.max_bitrate_bps);
            tracing::debug!("BWE: Starting probe at {} kbps", probe_bitrate / 1000);
        }
    }

    /// Stop probing
    pub fn stop_probe(&mut self, success: bool) {
        if self.probing {
            if success {
                self.estimated_bitrate = self.probe_bitrate;
            }
            self.probing = false;
            self.probe_bitrate = 0;
        }
    }

    /// Get statistics
    pub fn stats(&self) -> BweStats {
        BweStats {
            estimated_bitrate_bps: self.estimated_bitrate,
            target_bitrate_bps: self.target_bitrate(),
            network_state: self.network_state,
            avg_rtt_ms: self.avg_rtt.as_millis() as u32,
            avg_loss_percent: self.avg_loss * 100.0,
            probing: self.probing,
        }
    }
}

impl Default for BandwidthEstimator {
    fn default() -> Self {
        Self::with_defaults()
    }
}

/// BWE statistics
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct BweStats {
    pub estimated_bitrate_bps: u32,
    pub target_bitrate_bps: u32,
    pub network_state: NetworkState,
    pub avg_rtt_ms: u32,
    pub avg_loss_percent: f32,
    pub probing: bool,
}

/// Bitrate allocator for multiple streams
pub struct BitrateAllocator {
    /// Total available bitrate
    total_bitrate: u32,
    /// Stream allocations
    allocations: Vec<StreamAllocation>,
    /// Minimum per-stream bitrate
    min_stream_bitrate: u32,
}

/// Stream allocation
#[derive(Debug, Clone)]
pub struct StreamAllocation {
    /// Stream ID
    pub stream_id: u64,
    /// Stream type
    pub stream_type: StreamType,
    /// Priority (higher = more important)
    pub priority: u8,
    /// Allocated bitrate
    pub allocated_bitrate: u32,
    /// Minimum bitrate
    pub min_bitrate: u32,
    /// Maximum bitrate
    pub max_bitrate: u32,
}

/// Stream type for prioritization
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum StreamType {
    Audio,
    Video,
    ScreenShare,
    Data,
}

impl BitrateAllocator {
    pub fn new(total_bitrate: u32) -> Self {
        Self {
            total_bitrate,
            allocations: Vec::new(),
            min_stream_bitrate: 50_000, // 50 kbps
        }
    }

    /// Add a stream
    pub fn add_stream(
        &mut self,
        stream_id: u64,
        stream_type: StreamType,
        priority: u8,
        min_bitrate: u32,
        max_bitrate: u32,
    ) {
        self.allocations.push(StreamAllocation {
            stream_id,
            stream_type,
            priority,
            allocated_bitrate: 0,
            min_bitrate,
            max_bitrate,
        });
        self.reallocate();
    }

    /// Remove a stream
    pub fn remove_stream(&mut self, stream_id: u64) {
        self.allocations.retain(|a| a.stream_id != stream_id);
        self.reallocate();
    }

    /// Update total available bitrate
    pub fn set_total_bitrate(&mut self, bitrate: u32) {
        self.total_bitrate = bitrate;
        self.reallocate();
    }

    /// Reallocate bitrate across streams
    fn reallocate(&mut self) {
        if self.allocations.is_empty() {
            return;
        }

        // Sort by priority (descending)
        self.allocations.sort_by(|a, b| b.priority.cmp(&a.priority));

        // First pass: allocate minimum to each
        let mut remaining = self.total_bitrate;
        for alloc in &mut self.allocations {
            let min = alloc.min_bitrate.min(remaining);
            alloc.allocated_bitrate = min;
            remaining = remaining.saturating_sub(min);
        }

        // Second pass: distribute remaining by priority
        if remaining > 0 {
            let total_priority: u32 = self.allocations.iter()
                .map(|a| a.priority as u32)
                .sum();

            if total_priority > 0 {
                for alloc in &mut self.allocations {
                    let share = remaining * alloc.priority as u32 / total_priority;
                    let additional = share.min(alloc.max_bitrate - alloc.allocated_bitrate);
                    alloc.allocated_bitrate += additional;
                }
            }
        }
    }

    /// Get allocation for a stream
    pub fn get_allocation(&self, stream_id: u64) -> Option<u32> {
        self.allocations.iter()
            .find(|a| a.stream_id == stream_id)
            .map(|a| a.allocated_bitrate)
    }

    /// Get all allocations
    pub fn allocations(&self) -> &[StreamAllocation] {
        &self.allocations
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_bandwidth_estimator_creation() {
        let bwe = BandwidthEstimator::with_defaults();
        assert_eq!(bwe.estimated_bitrate(), 1_000_000);
        assert_eq!(bwe.network_state(), NetworkState::Normal);
    }

    #[test]
    fn test_remb_feedback() {
        let mut bwe = BandwidthEstimator::with_defaults();

        // Simulate REMB feedback
        bwe.on_remb_feedback(2_000_000);
        assert!(bwe.estimated_bitrate() > 1_000_000);

        bwe.on_remb_feedback(500_000);
        assert!(bwe.estimated_bitrate() < 2_000_000);
    }

    #[test]
    fn test_loss_based_adjustment() {
        let mut bwe = BandwidthEstimator::with_defaults();
        let initial = bwe.estimated_bitrate();

        // High loss should decrease bitrate
        bwe.on_loss_sample(0.15);
        assert!(bwe.estimated_bitrate() < initial);
        assert_eq!(bwe.network_state(), NetworkState::Overuse);
    }

    #[test]
    fn test_rtt_tracking() {
        let mut bwe = BandwidthEstimator::with_defaults();

        bwe.on_rtt_sample(Duration::from_millis(50));
        bwe.on_rtt_sample(Duration::from_millis(100));
        bwe.on_rtt_sample(Duration::from_millis(150));

        assert_eq!(bwe.avg_rtt(), Duration::from_millis(100));
    }

    #[test]
    fn test_probing() {
        let mut bwe = BandwidthEstimator::with_defaults();

        bwe.start_probe(2_000_000);
        assert!(bwe.stats().probing);
        assert_eq!(bwe.target_bitrate(), 2_000_000);

        bwe.stop_probe(true);
        assert!(!bwe.stats().probing);
        assert_eq!(bwe.estimated_bitrate(), 2_000_000);
    }

    #[test]
    fn test_bitrate_allocator() {
        let mut allocator = BitrateAllocator::new(3_000_000);

        // Add audio (high priority, low bandwidth)
        allocator.add_stream(1, StreamType::Audio, 100, 32_000, 128_000);

        // Add video (medium priority, high bandwidth)
        allocator.add_stream(2, StreamType::Video, 50, 100_000, 2_000_000);

        // Add screen share (low priority)
        allocator.add_stream(3, StreamType::ScreenShare, 25, 100_000, 3_000_000);

        // Check allocations exist
        assert!(allocator.get_allocation(1).is_some());
        assert!(allocator.get_allocation(2).is_some());
        assert!(allocator.get_allocation(3).is_some());

        // Higher priority should get more
        let audio = allocator.get_allocation(1).unwrap();
        assert!(audio >= 32_000);
    }
}
