//! Screen Sharing - Share screen, window, or tab
//!
//! This module provides screen sharing functionality similar to
//! Zoom, Meet, and Teams.
//!
//! ## Architecture
//!
//! ```text
//! ┌─────────────────────────────────────────────────────────────────┐
//! │                    SCREEN SHARING                               │
//! │                                                                 │
//! │   ┌─────────────────┐     ┌─────────────────┐                  │
//! │   │   Presenter     │────►│      SFU        │                  │
//! │   │   (Screen)      │     │                 │                  │
//! │   └─────────────────┘     └────────┬────────┘                  │
//! │                                    │                            │
//! │         ┌──────────────────────────┼──────────────────┐        │
//! │         │                          │                  │        │
//! │         ▼                          ▼                  ▼        │
//! │   ┌──────────┐              ┌──────────┐       ┌──────────┐   │
//! │   │ Viewer 1 │              │ Viewer 2 │       │ Viewer N │   │
//! │   └──────────┘              └──────────┘       └──────────┘   │
//! │                                                                 │
//! │   Share Types:                                                 │
//! │   • Entire Screen - Full display                               │
//! │   • Window - Single application                                │
//! │   • Tab - Browser tab with audio                              │
//! │                                                                 │
//! └─────────────────────────────────────────────────────────────────┘
//! ```

use std::collections::HashMap;
use std::time::{Duration, Instant};

use serde::{Deserialize, Serialize};

/// Screen share source type
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum ShareSource {
    /// Entire screen/display
    Screen,
    /// Specific window
    Window,
    /// Browser tab
    Tab,
    /// System audio only
    Audio,
}

impl Default for ShareSource {
    fn default() -> Self {
        Self::Screen
    }
}

/// Screen share quality
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum ShareQuality {
    /// Optimized for text/documents (higher FPS, lower compression)
    Text,
    /// Optimized for video/motion (lower FPS, higher compression)
    Motion,
    /// Balanced
    Balanced,
    /// Auto-detect
    Auto,
}

impl Default for ShareQuality {
    fn default() -> Self {
        Self::Auto
    }
}

/// Screen share configuration
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ScreenShareConfig {
    /// Source type
    pub source: ShareSource,
    /// Quality optimization
    pub quality: ShareQuality,
    /// Include system audio
    pub include_audio: bool,
    /// Max resolution (width, height)
    pub max_resolution: (u32, u32),
    /// Max framerate
    pub max_framerate: u32,
    /// Allow remote control
    pub remote_control_enabled: bool,
    /// Highlight cursor
    pub highlight_cursor: bool,
    /// Show pointer
    pub show_pointer: bool,
}

impl Default for ScreenShareConfig {
    fn default() -> Self {
        Self {
            source: ShareSource::Screen,
            quality: ShareQuality::Auto,
            include_audio: true,
            max_resolution: (1920, 1080),
            max_framerate: 30,
            remote_control_enabled: false,
            highlight_cursor: true,
            show_pointer: true,
        }
    }
}

impl ScreenShareConfig {
    /// High quality for presentations
    pub fn for_presentation() -> Self {
        Self {
            source: ShareSource::Screen,
            quality: ShareQuality::Text,
            include_audio: false,
            max_resolution: (1920, 1080),
            max_framerate: 15,
            remote_control_enabled: false,
            highlight_cursor: true,
            show_pointer: true,
        }
    }

    /// Optimized for video playback
    pub fn for_video() -> Self {
        Self {
            source: ShareSource::Tab,
            quality: ShareQuality::Motion,
            include_audio: true,
            max_resolution: (1920, 1080),
            max_framerate: 30,
            remote_control_enabled: false,
            highlight_cursor: false,
            show_pointer: false,
        }
    }

    /// Optimized for remote support
    pub fn for_remote_support() -> Self {
        Self {
            source: ShareSource::Screen,
            quality: ShareQuality::Text,
            include_audio: true,
            max_resolution: (1920, 1080),
            max_framerate: 30,
            remote_control_enabled: true,
            highlight_cursor: true,
            show_pointer: true,
        }
    }
}

/// Active screen share state
#[derive(Debug, Clone)]
pub struct ScreenShare {
    /// Screen share ID
    pub id: u64,
    /// Session ID
    pub session_id: u64,
    /// Presenter endpoint ID
    pub presenter_id: u64,
    /// Configuration
    pub config: ScreenShareConfig,
    /// Track ID (for SDP)
    pub track_id: String,
    /// Audio track ID (if separate)
    pub audio_track_id: Option<String>,
    /// Started at
    pub started_at: Instant,
    /// Current viewers
    pub viewers: Vec<u64>,
    /// Paused
    pub paused: bool,
}

impl ScreenShare {
    pub fn new(
        id: u64,
        session_id: u64,
        presenter_id: u64,
        config: ScreenShareConfig,
    ) -> Self {
        Self {
            id,
            session_id,
            presenter_id,
            config,
            track_id: format!("screen-{}", id),
            audio_track_id: None,
            started_at: Instant::now(),
            viewers: Vec::new(),
            paused: false,
        }
    }

    pub fn duration(&self) -> Duration {
        self.started_at.elapsed()
    }

    pub fn add_viewer(&mut self, endpoint_id: u64) {
        if !self.viewers.contains(&endpoint_id) {
            self.viewers.push(endpoint_id);
        }
    }

    pub fn remove_viewer(&mut self, endpoint_id: u64) {
        self.viewers.retain(|&id| id != endpoint_id);
    }

    pub fn viewer_count(&self) -> usize {
        self.viewers.len()
    }
}

/// Screen share manager
pub struct ScreenShareManager {
    /// Active screen shares (share_id -> ScreenShare)
    shares: HashMap<u64, ScreenShare>,
    /// Share counter
    share_counter: u64,
    /// Session to shares mapping
    session_shares: HashMap<u64, Vec<u64>>,
    /// Max concurrent shares per session
    max_shares_per_session: usize,
}

impl ScreenShareManager {
    pub fn new() -> Self {
        Self {
            shares: HashMap::new(),
            share_counter: 0,
            session_shares: HashMap::new(),
            max_shares_per_session: 1, // Most platforms only allow 1 share at a time
        }
    }

    /// Start screen sharing
    pub fn start_share(
        &mut self,
        session_id: u64,
        presenter_id: u64,
        config: ScreenShareConfig,
    ) -> Result<ScreenShare, ScreenShareError> {
        // Check if session already has max shares
        let current_shares = self.session_shares
            .get(&session_id)
            .map(|s| s.len())
            .unwrap_or(0);

        if current_shares >= self.max_shares_per_session {
            return Err(ScreenShareError::MaxSharesReached(session_id));
        }

        // Check if presenter is already sharing
        if self.is_sharing(session_id, presenter_id) {
            return Err(ScreenShareError::AlreadySharing(presenter_id));
        }

        self.share_counter += 1;
        let share_id = self.share_counter;

        let share = ScreenShare::new(share_id, session_id, presenter_id, config);

        self.shares.insert(share_id, share.clone());
        self.session_shares
            .entry(session_id)
            .or_default()
            .push(share_id);

        tracing::info!(
            "Screen share {} started by endpoint {} in session {}",
            share_id, presenter_id, session_id
        );

        Ok(share)
    }

    /// Stop screen sharing
    pub fn stop_share(&mut self, share_id: u64) -> Result<ScreenShare, ScreenShareError> {
        let share = self.shares
            .remove(&share_id)
            .ok_or(ScreenShareError::NotFound(share_id))?;

        // Remove from session mapping
        if let Some(shares) = self.session_shares.get_mut(&share.session_id) {
            shares.retain(|&id| id != share_id);
        }

        tracing::info!(
            "Screen share {} stopped after {:?}",
            share_id, share.duration()
        );

        Ok(share)
    }

    /// Stop all shares for an endpoint
    pub fn stop_shares_for_endpoint(&mut self, endpoint_id: u64) -> Vec<ScreenShare> {
        let share_ids: Vec<u64> = self.shares
            .iter()
            .filter(|(_, s)| s.presenter_id == endpoint_id)
            .map(|(id, _)| *id)
            .collect();

        share_ids
            .into_iter()
            .filter_map(|id| self.stop_share(id).ok())
            .collect()
    }

    /// Get active share for session
    pub fn get_session_share(&self, session_id: u64) -> Option<&ScreenShare> {
        self.session_shares
            .get(&session_id)
            .and_then(|ids| ids.first())
            .and_then(|id| self.shares.get(id))
    }

    /// Get share by ID
    pub fn get_share(&self, share_id: u64) -> Option<&ScreenShare> {
        self.shares.get(&share_id)
    }

    /// Get mutable share by ID
    pub fn get_share_mut(&mut self, share_id: u64) -> Option<&mut ScreenShare> {
        self.shares.get_mut(&share_id)
    }

    /// Check if endpoint is sharing in session
    pub fn is_sharing(&self, session_id: u64, endpoint_id: u64) -> bool {
        self.session_shares
            .get(&session_id)
            .map(|ids| {
                ids.iter().any(|id| {
                    self.shares.get(id)
                        .map(|s| s.presenter_id == endpoint_id)
                        .unwrap_or(false)
                })
            })
            .unwrap_or(false)
    }

    /// Add viewer to share
    pub fn add_viewer(&mut self, share_id: u64, endpoint_id: u64) -> Result<(), ScreenShareError> {
        let share = self.shares.get_mut(&share_id)
            .ok_or(ScreenShareError::NotFound(share_id))?;

        share.add_viewer(endpoint_id);
        Ok(())
    }

    /// Remove viewer from share
    pub fn remove_viewer(&mut self, share_id: u64, endpoint_id: u64) -> Result<(), ScreenShareError> {
        let share = self.shares.get_mut(&share_id)
            .ok_or(ScreenShareError::NotFound(share_id))?;

        share.remove_viewer(endpoint_id);
        Ok(())
    }

    /// Pause share
    pub fn pause_share(&mut self, share_id: u64) -> Result<(), ScreenShareError> {
        let share = self.shares.get_mut(&share_id)
            .ok_or(ScreenShareError::NotFound(share_id))?;

        share.paused = true;
        Ok(())
    }

    /// Resume share
    pub fn resume_share(&mut self, share_id: u64) -> Result<(), ScreenShareError> {
        let share = self.shares.get_mut(&share_id)
            .ok_or(ScreenShareError::NotFound(share_id))?;

        share.paused = false;
        Ok(())
    }

    /// Set max shares per session
    pub fn set_max_shares(&mut self, max: usize) {
        self.max_shares_per_session = max;
    }

    /// Get statistics
    pub fn stats(&self) -> ScreenShareStats {
        ScreenShareStats {
            active_shares: self.shares.len(),
            total_viewers: self.shares.values().map(|s| s.viewers.len()).sum(),
            sessions_with_shares: self.session_shares.len(),
        }
    }
}

impl Default for ScreenShareManager {
    fn default() -> Self {
        Self::new()
    }
}

/// Screen share statistics
#[derive(Debug, Clone, Default)]
pub struct ScreenShareStats {
    pub active_shares: usize,
    pub total_viewers: usize,
    pub sessions_with_shares: usize,
}

/// Screen share errors
#[derive(Debug, Clone)]
pub enum ScreenShareError {
    NotFound(u64),
    MaxSharesReached(u64),
    AlreadySharing(u64),
    NotPresenter(u64),
    RemoteControlDenied,
}

impl std::fmt::Display for ScreenShareError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            ScreenShareError::NotFound(id) => write!(f, "Screen share {} not found", id),
            ScreenShareError::MaxSharesReached(sid) => write!(f, "Max shares reached for session {}", sid),
            ScreenShareError::AlreadySharing(eid) => write!(f, "Endpoint {} is already sharing", eid),
            ScreenShareError::NotPresenter(eid) => write!(f, "Endpoint {} is not the presenter", eid),
            ScreenShareError::RemoteControlDenied => write!(f, "Remote control denied"),
        }
    }
}

impl std::error::Error for ScreenShareError {}

/// Remote control request
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RemoteControlRequest {
    /// Requester endpoint ID
    pub requester_id: u64,
    /// Share ID
    pub share_id: u64,
    /// Request timestamp
    pub timestamp: u64,
}

/// Remote control input event
#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum RemoteControlEvent {
    MouseMove { x: i32, y: i32 },
    MouseDown { button: u8, x: i32, y: i32 },
    MouseUp { button: u8, x: i32, y: i32 },
    MouseScroll { delta_x: i32, delta_y: i32 },
    KeyDown { key_code: u32, modifiers: u8 },
    KeyUp { key_code: u32, modifiers: u8 },
    KeyPress { char: char },
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_screen_share_config_presets() {
        let presentation = ScreenShareConfig::for_presentation();
        assert_eq!(presentation.quality, ShareQuality::Text);
        assert!(!presentation.include_audio);

        let video = ScreenShareConfig::for_video();
        assert_eq!(video.quality, ShareQuality::Motion);
        assert!(video.include_audio);

        let support = ScreenShareConfig::for_remote_support();
        assert!(support.remote_control_enabled);
    }

    #[test]
    fn test_screen_share_manager() {
        let mut manager = ScreenShareManager::new();

        // Start share
        let share = manager.start_share(100, 1, ScreenShareConfig::default()).unwrap();
        assert_eq!(share.session_id, 100);
        assert_eq!(share.presenter_id, 1);

        // Try to start another share (should fail - max 1)
        let result = manager.start_share(100, 2, ScreenShareConfig::default());
        assert!(result.is_err());

        // Add viewers
        manager.add_viewer(share.id, 2).unwrap();
        manager.add_viewer(share.id, 3).unwrap();

        let share = manager.get_share(share.id).unwrap();
        assert_eq!(share.viewer_count(), 2);

        // Stop share
        let stopped = manager.stop_share(share.id).unwrap();
        assert_eq!(stopped.viewer_count(), 2);
    }

    #[test]
    fn test_is_sharing() {
        let mut manager = ScreenShareManager::new();

        assert!(!manager.is_sharing(100, 1));

        manager.start_share(100, 1, ScreenShareConfig::default()).unwrap();
        assert!(manager.is_sharing(100, 1));
        assert!(!manager.is_sharing(100, 2));
    }

    #[test]
    fn test_stop_shares_for_endpoint() {
        let mut manager = ScreenShareManager::new();
        manager.set_max_shares(5);

        manager.start_share(100, 1, ScreenShareConfig::default()).unwrap();
        manager.start_share(101, 1, ScreenShareConfig::default()).unwrap();

        let stopped = manager.stop_shares_for_endpoint(1);
        assert_eq!(stopped.len(), 2);
        assert!(manager.shares.is_empty());
    }
}
