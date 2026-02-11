//! Recording - Session recording for meetings/webinars
//!
//! This module provides the infrastructure for recording RTC sessions,
//! similar to Zoom Cloud Recording or Google Meet recording.
//!
//! ## Architecture (like Zoom/Meet)
//!
//! ```text
//! ┌─────────────────────────────────────────────────────────────────┐
//! │                    RECORDING ARCHITECTURE                       │
//! │                                                                 │
//! │   ┌─────────────┐     ┌─────────────┐     ┌─────────────┐     │
//! │   │   SFU       │────►│  Recorder   │────►│   Storage   │     │
//! │   │  (Media)    │     │  (Process)  │     │  (Files)    │     │
//! │   └─────────────┘     └─────────────┘     └─────────────┘     │
//! │                              │                                  │
//! │                              ▼                                  │
//! │                       ┌─────────────┐                          │
//! │                       │   Encoder   │                          │
//! │                       │  (VP8→MP4)  │                          │
//! │                       └─────────────┘                          │
//! │                                                                 │
//! │   Recording Modes:                                             │
//! │   1. Composite - All participants in one video                 │
//! │   2. Individual - Separate file per participant                │
//! │   3. Audio-only - Just audio track                            │
//! │                                                                 │
//! └─────────────────────────────────────────────────────────────────┘
//! ```

use std::collections::HashMap;
use std::path::PathBuf;
use std::sync::atomic::{AtomicBool, AtomicU64, Ordering};
use std::sync::Arc;
use std::time::{Duration, Instant, SystemTime};

use parking_lot::RwLock;
use serde::{Deserialize, Serialize};
use tokio::sync::mpsc;

/// Recording mode
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum RecordingMode {
    /// All participants composited into one video
    Composite,
    /// Separate file for each participant
    Individual,
    /// Audio only (no video)
    AudioOnly,
    /// Active speaker only
    ActiveSpeaker,
}

impl Default for RecordingMode {
    fn default() -> Self {
        Self::Composite
    }
}

/// Recording output format
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum RecordingFormat {
    /// WebM (VP8/VP9 + Opus)
    WebM,
    /// MP4 (H264 + AAC) - Most compatible
    Mp4,
    /// MKV (Any codec)
    Mkv,
    /// Raw RTP packets (for post-processing)
    RawRtp,
}

impl Default for RecordingFormat {
    fn default() -> Self {
        Self::Mp4
    }
}

/// Recording quality preset
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum RecordingQuality {
    /// 360p, 500kbps
    Low,
    /// 720p, 1.5Mbps
    Medium,
    /// 1080p, 3Mbps
    High,
    /// 4K, 10Mbps (if available)
    Ultra,
}

impl Default for RecordingQuality {
    fn default() -> Self {
        Self::High
    }
}

impl RecordingQuality {
    pub fn resolution(&self) -> (u32, u32) {
        match self {
            Self::Low => (640, 360),
            Self::Medium => (1280, 720),
            Self::High => (1920, 1080),
            Self::Ultra => (3840, 2160),
        }
    }

    pub fn bitrate_kbps(&self) -> u32 {
        match self {
            Self::Low => 500,
            Self::Medium => 1500,
            Self::High => 3000,
            Self::Ultra => 10000,
        }
    }

    pub fn framerate(&self) -> u32 {
        match self {
            Self::Low => 15,
            Self::Medium => 30,
            Self::High => 30,
            Self::Ultra => 60,
        }
    }
}

/// Recording configuration
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RecordingConfig {
    /// Recording mode
    pub mode: RecordingMode,
    /// Output format
    pub format: RecordingFormat,
    /// Quality preset
    pub quality: RecordingQuality,
    /// Output directory
    pub output_dir: PathBuf,
    /// Include timestamps in filename
    pub timestamp_filename: bool,
    /// Max recording duration (None = unlimited)
    pub max_duration: Option<Duration>,
    /// Auto-start recording when session begins
    pub auto_start: bool,
    /// Pause when no participants
    pub pause_on_empty: bool,
    /// Generate thumbnail
    pub generate_thumbnail: bool,
    /// Transcription enabled
    pub transcription_enabled: bool,
}

impl Default for RecordingConfig {
    fn default() -> Self {
        Self {
            mode: RecordingMode::default(),
            format: RecordingFormat::default(),
            quality: RecordingQuality::default(),
            output_dir: PathBuf::from("./recordings"),
            timestamp_filename: true,
            max_duration: None,
            auto_start: false,
            pause_on_empty: true,
            generate_thumbnail: true,
            transcription_enabled: false,
        }
    }
}

/// Recording state
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum RecordingState {
    /// Not started
    Idle,
    /// Recording in progress
    Recording,
    /// Temporarily paused
    Paused,
    /// Stopped, processing
    Processing,
    /// Completed
    Completed,
    /// Failed
    Failed,
}

impl Default for RecordingState {
    fn default() -> Self {
        Self::Idle
    }
}

/// Recording session
#[derive(Debug)]
pub struct RecordingSession {
    /// Recording ID
    pub id: u64,
    /// Session ID being recorded
    pub session_id: u64,
    /// Configuration
    pub config: RecordingConfig,
    /// Current state
    pub state: RecordingState,
    /// Started at
    pub started_at: Option<Instant>,
    /// Total duration
    pub duration: Duration,
    /// Pause duration (not counted in total)
    pub pause_duration: Duration,
    /// Output file paths
    pub output_files: Vec<PathBuf>,
    /// Bytes written
    pub bytes_written: u64,
    /// Participants recorded
    pub participants: Vec<RecordedParticipant>,
    /// Error message (if failed)
    pub error: Option<String>,
}

impl RecordingSession {
    pub fn new(id: u64, session_id: u64, config: RecordingConfig) -> Self {
        Self {
            id,
            session_id,
            config,
            state: RecordingState::Idle,
            started_at: None,
            duration: Duration::ZERO,
            pause_duration: Duration::ZERO,
            output_files: Vec::new(),
            bytes_written: 0,
            participants: Vec::new(),
            error: None,
        }
    }

    pub fn start(&mut self) {
        if self.state == RecordingState::Idle {
            self.state = RecordingState::Recording;
            self.started_at = Some(Instant::now());
        }
    }

    pub fn pause(&mut self) {
        if self.state == RecordingState::Recording {
            self.state = RecordingState::Paused;
        }
    }

    pub fn resume(&mut self) {
        if self.state == RecordingState::Paused {
            self.state = RecordingState::Recording;
        }
    }

    pub fn stop(&mut self) {
        if self.state == RecordingState::Recording || self.state == RecordingState::Paused {
            self.state = RecordingState::Processing;
            if let Some(started) = self.started_at {
                self.duration = started.elapsed() - self.pause_duration;
            }
        }
    }

    pub fn complete(&mut self) {
        self.state = RecordingState::Completed;
    }

    pub fn fail(&mut self, error: &str) {
        self.state = RecordingState::Failed;
        self.error = Some(error.to_string());
    }

    pub fn is_active(&self) -> bool {
        matches!(self.state, RecordingState::Recording | RecordingState::Paused)
    }
}

/// Recorded participant info
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RecordedParticipant {
    /// Endpoint ID
    pub endpoint_id: u64,
    /// Display name
    pub display_name: Option<String>,
    /// Join time (offset from recording start)
    pub join_offset: Duration,
    /// Leave time (offset from recording start)
    pub leave_offset: Option<Duration>,
    /// Has audio
    pub has_audio: bool,
    /// Has video
    pub has_video: bool,
}

/// Recording event
#[derive(Debug, Clone)]
pub enum RecordingEvent {
    Started { recording_id: u64, session_id: u64 },
    Paused { recording_id: u64 },
    Resumed { recording_id: u64 },
    Stopped { recording_id: u64 },
    Completed { recording_id: u64, files: Vec<PathBuf>, duration: Duration },
    Failed { recording_id: u64, error: String },
    ParticipantJoined { recording_id: u64, endpoint_id: u64, name: Option<String> },
    ParticipantLeft { recording_id: u64, endpoint_id: u64 },
}

/// Recording manager
pub struct RecordingManager {
    /// Active recordings
    recordings: RwLock<HashMap<u64, RecordingSession>>,
    /// Recording counter
    recording_counter: AtomicU64,
    /// Default configuration
    default_config: RecordingConfig,
    /// Event sender
    event_tx: Option<mpsc::UnboundedSender<RecordingEvent>>,
}

impl RecordingManager {
    pub fn new(default_config: RecordingConfig) -> Self {
        Self {
            recordings: RwLock::new(HashMap::new()),
            recording_counter: AtomicU64::new(0),
            default_config,
            event_tx: None,
        }
    }

    pub fn with_defaults() -> Self {
        Self::new(RecordingConfig::default())
    }

    /// Set event channel
    pub fn set_event_channel(&mut self, tx: mpsc::UnboundedSender<RecordingEvent>) {
        self.event_tx = Some(tx);
    }

    /// Start recording a session
    pub fn start_recording(
        &self,
        session_id: u64,
        config: Option<RecordingConfig>,
    ) -> Result<u64, RecordingError> {
        let config = config.unwrap_or_else(|| self.default_config.clone());
        let recording_id = self.recording_counter.fetch_add(1, Ordering::SeqCst);

        let mut session = RecordingSession::new(recording_id, session_id, config.clone());
        session.start();

        // Generate output filename
        let filename = self.generate_filename(session_id, &config);
        session.output_files.push(filename);

        self.recordings.write().insert(recording_id, session);

        self.emit_event(RecordingEvent::Started {
            recording_id,
            session_id,
        });

        tracing::info!(
            "Started recording {} for session {} in {:?} mode",
            recording_id,
            session_id,
            config.mode
        );

        Ok(recording_id)
    }

    /// Pause recording
    pub fn pause_recording(&self, recording_id: u64) -> Result<(), RecordingError> {
        let mut recordings = self.recordings.write();
        let recording = recordings
            .get_mut(&recording_id)
            .ok_or(RecordingError::NotFound(recording_id))?;

        recording.pause();
        self.emit_event(RecordingEvent::Paused { recording_id });

        Ok(())
    }

    /// Resume recording
    pub fn resume_recording(&self, recording_id: u64) -> Result<(), RecordingError> {
        let mut recordings = self.recordings.write();
        let recording = recordings
            .get_mut(&recording_id)
            .ok_or(RecordingError::NotFound(recording_id))?;

        recording.resume();
        self.emit_event(RecordingEvent::Resumed { recording_id });

        Ok(())
    }

    /// Stop recording
    pub fn stop_recording(&self, recording_id: u64) -> Result<RecordingInfo, RecordingError> {
        let mut recordings = self.recordings.write();
        let recording = recordings
            .get_mut(&recording_id)
            .ok_or(RecordingError::NotFound(recording_id))?;

        recording.stop();
        
        self.emit_event(RecordingEvent::Stopped { recording_id });

        // In production, this would trigger post-processing
        // For now, mark as completed
        recording.complete();

        let info = RecordingInfo {
            recording_id,
            session_id: recording.session_id,
            duration: recording.duration,
            files: recording.output_files.clone(),
            bytes_written: recording.bytes_written,
            participants: recording.participants.len(),
        };

        self.emit_event(RecordingEvent::Completed {
            recording_id,
            files: recording.output_files.clone(),
            duration: recording.duration,
        });

        Ok(info)
    }

    /// Get recording status
    pub fn get_status(&self, recording_id: u64) -> Option<RecordingStatus> {
        let recordings = self.recordings.read();
        recordings.get(&recording_id).map(|r| RecordingStatus {
            recording_id: r.id,
            session_id: r.session_id,
            state: r.state,
            duration: if let Some(started) = r.started_at {
                if r.state == RecordingState::Recording {
                    started.elapsed() - r.pause_duration
                } else {
                    r.duration
                }
            } else {
                Duration::ZERO
            },
            bytes_written: r.bytes_written,
            participants: r.participants.len(),
        })
    }

    /// List active recordings
    pub fn list_active(&self) -> Vec<u64> {
        self.recordings
            .read()
            .iter()
            .filter(|(_, r)| r.is_active())
            .map(|(id, _)| *id)
            .collect()
    }

    /// List all recordings for a session
    pub fn list_for_session(&self, session_id: u64) -> Vec<u64> {
        self.recordings
            .read()
            .iter()
            .filter(|(_, r)| r.session_id == session_id)
            .map(|(id, _)| *id)
            .collect()
    }

    /// Record participant join
    pub fn record_participant_join(
        &self,
        recording_id: u64,
        endpoint_id: u64,
        display_name: Option<String>,
    ) {
        let mut recordings = self.recordings.write();
        if let Some(recording) = recordings.get_mut(&recording_id) {
            let offset = recording.started_at
                .map(|s| s.elapsed())
                .unwrap_or_default();

            recording.participants.push(RecordedParticipant {
                endpoint_id,
                display_name: display_name.clone(),
                join_offset: offset,
                leave_offset: None,
                has_audio: true,
                has_video: true,
            });

            self.emit_event(RecordingEvent::ParticipantJoined {
                recording_id,
                endpoint_id,
                name: display_name,
            });
        }
    }

    /// Record participant leave
    pub fn record_participant_leave(&self, recording_id: u64, endpoint_id: u64) {
        let mut recordings = self.recordings.write();
        if let Some(recording) = recordings.get_mut(&recording_id) {
            let offset = recording.started_at
                .map(|s| s.elapsed())
                .unwrap_or_default();

            for participant in &mut recording.participants {
                if participant.endpoint_id == endpoint_id && participant.leave_offset.is_none() {
                    participant.leave_offset = Some(offset);
                    break;
                }
            }

            self.emit_event(RecordingEvent::ParticipantLeft {
                recording_id,
                endpoint_id,
            });
        }
    }

    fn generate_filename(&self, session_id: u64, config: &RecordingConfig) -> PathBuf {
        let ext = match config.format {
            RecordingFormat::WebM => "webm",
            RecordingFormat::Mp4 => "mp4",
            RecordingFormat::Mkv => "mkv",
            RecordingFormat::RawRtp => "rtp",
        };

        let timestamp = if config.timestamp_filename {
            let now = SystemTime::now()
                .duration_since(std::time::UNIX_EPOCH)
                .unwrap()
                .as_secs();
            format!("_{}", now)
        } else {
            String::new()
        };

        config.output_dir.join(format!("session_{}{}.{}", session_id, timestamp, ext))
    }

    fn emit_event(&self, event: RecordingEvent) {
        if let Some(tx) = &self.event_tx {
            let _ = tx.send(event);
        }
    }
}

impl Default for RecordingManager {
    fn default() -> Self {
        Self::with_defaults()
    }
}

/// Recording info (returned after stop)
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RecordingInfo {
    pub recording_id: u64,
    pub session_id: u64,
    pub duration: Duration,
    pub files: Vec<PathBuf>,
    pub bytes_written: u64,
    pub participants: usize,
}

/// Recording status
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RecordingStatus {
    pub recording_id: u64,
    pub session_id: u64,
    pub state: RecordingState,
    pub duration: Duration,
    pub bytes_written: u64,
    pub participants: usize,
}

/// Recording errors
#[derive(Debug, Clone)]
pub enum RecordingError {
    NotFound(u64),
    AlreadyExists(u64),
    InvalidState(RecordingState),
    IoError(String),
    EncodingError(String),
}

impl std::fmt::Display for RecordingError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            RecordingError::NotFound(id) => write!(f, "Recording {} not found", id),
            RecordingError::AlreadyExists(id) => write!(f, "Recording {} already exists", id),
            RecordingError::InvalidState(state) => write!(f, "Invalid state: {:?}", state),
            RecordingError::IoError(e) => write!(f, "IO error: {}", e),
            RecordingError::EncodingError(e) => write!(f, "Encoding error: {}", e),
        }
    }
}

impl std::error::Error for RecordingError {}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_recording_session_lifecycle() {
        let config = RecordingConfig::default();
        let mut session = RecordingSession::new(1, 100, config);

        assert_eq!(session.state, RecordingState::Idle);

        session.start();
        assert_eq!(session.state, RecordingState::Recording);
        assert!(session.started_at.is_some());

        session.pause();
        assert_eq!(session.state, RecordingState::Paused);

        session.resume();
        assert_eq!(session.state, RecordingState::Recording);

        session.stop();
        assert_eq!(session.state, RecordingState::Processing);

        session.complete();
        assert_eq!(session.state, RecordingState::Completed);
    }

    #[test]
    fn test_recording_manager() {
        let manager = RecordingManager::with_defaults();

        // Start recording
        let recording_id = manager.start_recording(100, None).unwrap();

        // Check status
        let status = manager.get_status(recording_id).unwrap();
        assert_eq!(status.state, RecordingState::Recording);

        // List active
        let active = manager.list_active();
        assert!(active.contains(&recording_id));

        // Pause
        manager.pause_recording(recording_id).unwrap();
        let status = manager.get_status(recording_id).unwrap();
        assert_eq!(status.state, RecordingState::Paused);

        // Resume
        manager.resume_recording(recording_id).unwrap();

        // Stop
        let info = manager.stop_recording(recording_id).unwrap();
        assert_eq!(info.session_id, 100);
        assert!(!info.files.is_empty());
    }

    #[test]
    fn test_recording_quality() {
        assert_eq!(RecordingQuality::High.resolution(), (1920, 1080));
        assert_eq!(RecordingQuality::Medium.resolution(), (1280, 720));
        assert_eq!(RecordingQuality::Low.resolution(), (640, 360));
    }

    #[test]
    fn test_participant_tracking() {
        let manager = RecordingManager::with_defaults();
        let recording_id = manager.start_recording(100, None).unwrap();

        manager.record_participant_join(recording_id, 1, Some("Alice".to_string()));
        manager.record_participant_join(recording_id, 2, Some("Bob".to_string()));

        let status = manager.get_status(recording_id).unwrap();
        assert_eq!(status.participants, 2);

        manager.record_participant_leave(recording_id, 1);
    }
}
