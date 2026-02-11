//! Spatial Audio - 3D Positional Audio
//!
//! Immersive 3D audio positioning like Apple SharePlay Spatial Audio,
//! Microsoft Teams Together Mode, and Zoom Immersive View.
//!
//! ## Concept
//!
//! ```text
//! ┌─────────────────────────────────────────────────────────────────────────────┐
//! │                    SPATIAL AUDIO                                            │
//! │                                                                             │
//! │   Traditional Audio:         Spatial Audio:                                │
//! │                                                                             │
//! │   ┌───────────────┐          ┌───────────────────────────────────────────┐ │
//! │   │  All voices   │          │          3D Sound Stage                    │ │
//! │   │  come from    │          │                                           │ │
//! │   │  center       │          │     Bob (left)    Alice (center)          │ │
//! │   │               │          │          ◄──────●──────►                  │ │
//! │   │   🔊 🔊 🔊    │          │                 ▲                         │ │
//! │   │               │          │          Charlie (right)                  │ │
//! │   └───────────────┘          │                                           │ │
//! │                              │   Voices sound like they come from        │ │
//! │                              │   different positions in the room         │ │
//! │                              │                                           │ │
//! │                              └───────────────────────────────────────────┘ │
//! │                                                                             │
//! │   Benefits:                                                                │
//! │   • Easier to distinguish speakers                                        │
//! │   • More natural conversation flow                                        │
//! │   • Reduced cognitive load                                                │
//! │   • Better for large meetings                                             │
//! │                                                                             │
//! └─────────────────────────────────────────────────────────────────────────────┘
//! ```

use std::collections::HashMap;
use std::f32::consts::PI;

use serde::{Deserialize, Serialize};

/// 3D position in space
#[derive(Debug, Clone, Copy, Default, Serialize, Deserialize)]
pub struct Position3D {
    /// X coordinate (-1.0 to 1.0, left to right)
    pub x: f32,
    /// Y coordinate (-1.0 to 1.0, down to up)
    pub y: f32,
    /// Z coordinate (-1.0 to 1.0, far to near)
    pub z: f32,
}

impl Position3D {
    pub fn new(x: f32, y: f32, z: f32) -> Self {
        Self { x, y, z }
    }

    /// Center position
    pub fn center() -> Self {
        Self::new(0.0, 0.0, 0.0)
    }

    /// Left position
    pub fn left() -> Self {
        Self::new(-1.0, 0.0, 0.0)
    }

    /// Right position
    pub fn right() -> Self {
        Self::new(1.0, 0.0, 0.0)
    }

    /// Calculate distance from another position
    pub fn distance(&self, other: &Position3D) -> f32 {
        ((self.x - other.x).powi(2) + (self.y - other.y).powi(2) + (self.z - other.z).powi(2)).sqrt()
    }

    /// Calculate angle from listener's perspective (radians)
    pub fn angle_from(&self, listener: &Position3D) -> f32 {
        (self.x - listener.x).atan2(self.z - listener.z)
    }
}

/// Audio orientation (head tracking)
#[derive(Debug, Clone, Copy, Default, Serialize, Deserialize)]
pub struct Orientation3D {
    /// Yaw (horizontal rotation) in radians
    pub yaw: f32,
    /// Pitch (vertical rotation) in radians
    pub pitch: f32,
    /// Roll (tilt) in radians
    pub roll: f32,
}

impl Orientation3D {
    pub fn new(yaw: f32, pitch: f32, roll: f32) -> Self {
        Self { yaw, pitch, roll }
    }

    /// Forward facing
    pub fn forward() -> Self {
        Self::new(0.0, 0.0, 0.0)
    }
}

/// Spatial audio configuration
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SpatialAudioConfig {
    /// Enable spatial audio
    pub enabled: bool,
    /// HRTF (Head-Related Transfer Function) enabled
    pub hrtf_enabled: bool,
    /// Room size (affects reverb)
    pub room_size: RoomSize,
    /// Distance attenuation model
    pub attenuation_model: AttenuationModel,
    /// Maximum distance for audio
    pub max_distance: f32,
    /// Reference distance (where volume is 100%)
    pub reference_distance: f32,
    /// Rolloff factor (how quickly volume decreases)
    pub rolloff_factor: f32,
    /// Enable head tracking (for VR/spatial devices)
    pub head_tracking: bool,
}

impl Default for SpatialAudioConfig {
    fn default() -> Self {
        Self {
            enabled: true,
            hrtf_enabled: true,
            room_size: RoomSize::Medium,
            attenuation_model: AttenuationModel::InverseDistance,
            max_distance: 10.0,
            reference_distance: 1.0,
            rolloff_factor: 1.0,
            head_tracking: false,
        }
    }
}

/// Virtual room size
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum RoomSize {
    Small,  // Close conversation
    Medium, // Conference room
    Large,  // Auditorium
    Open,   // Outdoor/no reverb
}

impl Default for RoomSize {
    fn default() -> Self {
        Self::Medium
    }
}

impl RoomSize {
    /// Get reverb parameters
    pub fn reverb_params(&self) -> ReverbParams {
        match self {
            RoomSize::Small => ReverbParams {
                decay_time: 0.3,
                wet_level: 0.1,
                dry_level: 0.9,
            },
            RoomSize::Medium => ReverbParams {
                decay_time: 0.6,
                wet_level: 0.15,
                dry_level: 0.85,
            },
            RoomSize::Large => ReverbParams {
                decay_time: 1.2,
                wet_level: 0.25,
                dry_level: 0.75,
            },
            RoomSize::Open => ReverbParams {
                decay_time: 0.0,
                wet_level: 0.0,
                dry_level: 1.0,
            },
        }
    }
}

/// Reverb parameters
#[derive(Debug, Clone, Copy)]
pub struct ReverbParams {
    pub decay_time: f32,
    pub wet_level: f32,
    pub dry_level: f32,
}

/// Distance attenuation model
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum AttenuationModel {
    /// Linear falloff
    Linear,
    /// Inverse distance (realistic)
    InverseDistance,
    /// Inverse distance clamped
    InverseDistanceClamped,
    /// Exponential
    Exponential,
    /// No attenuation
    None,
}

impl Default for AttenuationModel {
    fn default() -> Self {
        Self::InverseDistance
    }
}

/// Spatial audio source (participant)
#[derive(Debug, Clone)]
pub struct SpatialSource {
    /// Endpoint ID
    pub endpoint_id: u64,
    /// Position in 3D space
    pub position: Position3D,
    /// Volume multiplier (0.0 - 2.0)
    pub volume: f32,
    /// Is muted
    pub muted: bool,
    /// Directional (sound comes from front)
    pub directional: bool,
    /// Cone inner angle (radians)
    pub cone_inner: f32,
    /// Cone outer angle (radians)
    pub cone_outer: f32,
}

impl SpatialSource {
    pub fn new(endpoint_id: u64, position: Position3D) -> Self {
        Self {
            endpoint_id,
            position,
            volume: 1.0,
            muted: false,
            directional: false,
            cone_inner: PI * 0.25,
            cone_outer: PI * 0.5,
        }
    }
}

/// Spatial audio listener (receiver)
#[derive(Debug, Clone)]
pub struct SpatialListener {
    /// Endpoint ID
    pub endpoint_id: u64,
    /// Position in 3D space
    pub position: Position3D,
    /// Orientation (head direction)
    pub orientation: Orientation3D,
}

impl SpatialListener {
    pub fn new(endpoint_id: u64) -> Self {
        Self {
            endpoint_id,
            position: Position3D::center(),
            orientation: Orientation3D::forward(),
        }
    }
}

/// Spatial layout preset
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum SpatialLayout {
    /// Participants in a circle
    Circle,
    /// Participants in a semicircle facing listener
    Semicircle,
    /// Participants in a grid
    Grid,
    /// Conference table layout
    Table,
    /// Theater (speakers in front, audience behind)
    Theater,
    /// Custom positions
    Custom,
}

impl Default for SpatialLayout {
    fn default() -> Self {
        Self::Semicircle
    }
}

/// Spatial audio manager
pub struct SpatialAudioManager {
    /// Session ID
    session_id: u64,
    /// Configuration
    config: SpatialAudioConfig,
    /// Audio sources (speakers)
    sources: HashMap<u64, SpatialSource>,
    /// Audio listeners (receivers)
    listeners: HashMap<u64, SpatialListener>,
    /// Current layout
    layout: SpatialLayout,
}

impl SpatialAudioManager {
    pub fn new(session_id: u64, config: SpatialAudioConfig) -> Self {
        Self {
            session_id,
            config,
            sources: HashMap::new(),
            listeners: HashMap::new(),
            layout: SpatialLayout::default(),
        }
    }

    pub fn with_defaults(session_id: u64) -> Self {
        Self::new(session_id, SpatialAudioConfig::default())
    }

    /// Add a participant
    pub fn add_participant(&mut self, endpoint_id: u64) {
        // Add as both source and listener
        let position = self.calculate_position_for_new_participant();
        self.sources.insert(endpoint_id, SpatialSource::new(endpoint_id, position));
        self.listeners.insert(endpoint_id, SpatialListener::new(endpoint_id));
        
        // Recalculate positions based on layout
        self.apply_layout();
    }

    /// Remove a participant
    pub fn remove_participant(&mut self, endpoint_id: u64) {
        self.sources.remove(&endpoint_id);
        self.listeners.remove(&endpoint_id);
        self.apply_layout();
    }

    /// Update participant position
    pub fn set_position(&mut self, endpoint_id: u64, position: Position3D) {
        if let Some(source) = self.sources.get_mut(&endpoint_id) {
            source.position = position;
        }
        if let Some(listener) = self.listeners.get_mut(&endpoint_id) {
            listener.position = position;
        }
    }

    /// Update listener orientation (head tracking)
    pub fn set_orientation(&mut self, endpoint_id: u64, orientation: Orientation3D) {
        if let Some(listener) = self.listeners.get_mut(&endpoint_id) {
            listener.orientation = orientation;
        }
    }

    /// Set layout
    pub fn set_layout(&mut self, layout: SpatialLayout) {
        self.layout = layout;
        self.apply_layout();
    }

    /// Apply layout to all participants
    fn apply_layout(&mut self) {
        let count = self.sources.len();
        if count == 0 {
            return;
        }

        let positions = self.calculate_layout_positions(count);

        for (i, (endpoint_id, _)) in self.sources.iter_mut().enumerate() {
            if i < positions.len() {
                if let Some(source) = self.sources.get_mut(endpoint_id) {
                    source.position = positions[i];
                }
            }
        }
    }

    /// Calculate positions for layout
    fn calculate_layout_positions(&self, count: usize) -> Vec<Position3D> {
        match self.layout {
            SpatialLayout::Circle => {
                (0..count)
                    .map(|i| {
                        let angle = (2.0 * PI * i as f32) / count as f32;
                        Position3D::new(angle.sin() * 0.8, 0.0, angle.cos() * 0.8)
                    })
                    .collect()
            }
            SpatialLayout::Semicircle => {
                (0..count)
                    .map(|i| {
                        let angle = PI * (i as f32 + 0.5) / count as f32 - PI / 2.0;
                        Position3D::new(angle.sin() * 0.8, 0.0, angle.cos() * 0.5 + 0.3)
                    })
                    .collect()
            }
            SpatialLayout::Grid => {
                let cols = (count as f32).sqrt().ceil() as usize;
                (0..count)
                    .map(|i| {
                        let row = i / cols;
                        let col = i % cols;
                        let x = (col as f32 / (cols - 1).max(1) as f32) * 2.0 - 1.0;
                        let z = (row as f32 / ((count / cols).max(1) - 1).max(1) as f32) * 0.5;
                        Position3D::new(x * 0.8, 0.0, z)
                    })
                    .collect()
            }
            SpatialLayout::Table => {
                // Two rows facing each other
                (0..count)
                    .map(|i| {
                        let side = i % 2;
                        let pos_in_row = i / 2;
                        let row_count = (count + 1) / 2;
                        let x = (pos_in_row as f32 / row_count.max(1) as f32) * 2.0 - 1.0;
                        let z = if side == 0 { 0.3 } else { -0.3 };
                        Position3D::new(x * 0.8, 0.0, z)
                    })
                    .collect()
            }
            SpatialLayout::Theater => {
                // Speakers in front, rest in back
                (0..count)
                    .map(|i| {
                        if i < 2 {
                            // Speakers
                            let x = if i == 0 { -0.3 } else { 0.3 };
                            Position3D::new(x, 0.0, 0.5)
                        } else {
                            // Audience
                            let pos = i - 2;
                            let row = pos / 4;
                            let col = pos % 4;
                            let x = (col as f32 / 3.0) * 2.0 - 1.0;
                            let z = -0.3 - row as f32 * 0.3;
                            Position3D::new(x * 0.8, 0.0, z)
                        }
                    })
                    .collect()
            }
            SpatialLayout::Custom => {
                // Don't change positions
                self.sources.values().map(|s| s.position).collect()
            }
        }
    }

    fn calculate_position_for_new_participant(&self) -> Position3D {
        // Just return center; will be adjusted by apply_layout
        Position3D::center()
    }

    /// Calculate gain for a source from a listener's perspective
    pub fn calculate_gain(&self, source_id: u64, listener_id: u64) -> (f32, f32) {
        let source = match self.sources.get(&source_id) {
            Some(s) => s,
            None => return (0.0, 0.0),
        };

        if source.muted {
            return (0.0, 0.0);
        }

        let listener = match self.listeners.get(&listener_id) {
            Some(l) => l,
            None => return (source.volume, source.volume),
        };

        // Calculate distance attenuation
        let distance = source.position.distance(&listener.position);
        let attenuation = self.calculate_attenuation(distance);

        // Calculate stereo panning based on angle
        let angle = source.position.angle_from(&listener.position) - listener.orientation.yaw;
        
        // Simple stereo panning
        let pan = angle.sin(); // -1 (left) to 1 (right)
        let left_gain = source.volume * attenuation * (1.0 - pan.max(0.0));
        let right_gain = source.volume * attenuation * (1.0 + pan.min(0.0));

        (left_gain, right_gain)
    }

    fn calculate_attenuation(&self, distance: f32) -> f32 {
        if !self.config.enabled {
            return 1.0;
        }

        let ref_dist = self.config.reference_distance;
        let max_dist = self.config.max_distance;
        let rolloff = self.config.rolloff_factor;

        match self.config.attenuation_model {
            AttenuationModel::None => 1.0,
            AttenuationModel::Linear => {
                1.0 - rolloff * (distance - ref_dist) / (max_dist - ref_dist)
            }
            AttenuationModel::InverseDistance => {
                ref_dist / (ref_dist + rolloff * (distance - ref_dist))
            }
            AttenuationModel::InverseDistanceClamped => {
                let d = distance.clamp(ref_dist, max_dist);
                ref_dist / (ref_dist + rolloff * (d - ref_dist))
            }
            AttenuationModel::Exponential => {
                (distance / ref_dist).powf(-rolloff)
            }
        }
        .clamp(0.0, 1.0)
    }

    /// Get participant count
    pub fn participant_count(&self) -> usize {
        self.sources.len()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_position_distance() {
        let p1 = Position3D::new(0.0, 0.0, 0.0);
        let p2 = Position3D::new(1.0, 0.0, 0.0);
        assert!((p1.distance(&p2) - 1.0).abs() < 0.001);
    }

    #[test]
    fn test_layout_circle() {
        let mut manager = SpatialAudioManager::with_defaults(100);
        manager.set_layout(SpatialLayout::Circle);

        manager.add_participant(1);
        manager.add_participant(2);
        manager.add_participant(3);
        manager.add_participant(4);

        // All should be at roughly same distance from center
        for (_, source) in &manager.sources {
            let dist = source.position.distance(&Position3D::center());
            assert!((dist - 0.8).abs() < 0.1);
        }
    }

    #[test]
    fn test_gain_calculation() {
        let mut manager = SpatialAudioManager::with_defaults(100);

        manager.add_participant(1);
        manager.add_participant(2);

        manager.set_position(1, Position3D::new(-0.5, 0.0, 0.0));
        manager.set_position(2, Position3D::center());

        let (left, right) = manager.calculate_gain(1, 2);
        
        // Source on the left should have more left gain
        assert!(left > right);
    }

    #[test]
    fn test_attenuation() {
        let manager = SpatialAudioManager::with_defaults(100);

        // Close distance
        let close = manager.calculate_attenuation(1.0);
        // Far distance
        let far = manager.calculate_attenuation(5.0);

        assert!(close > far);
    }
}
