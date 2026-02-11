//! Live Streaming - RTMP/HLS/DASH Output
//!
//! Broadcast meetings to large audiences via streaming protocols
//! like YouTube Live, Twitch, Facebook Live, LinkedIn Live.
//!
//! ## Architecture (like Zoom Webinar to YouTube)
//!
//! ```text
//! ┌─────────────────────────────────────────────────────────────────────────────┐
//! │                    LIVE STREAMING PIPELINE                                  │
//! │                                                                             │
//! │   ┌─────────────┐                                                          │
//! │   │    SFU      │                                                          │
//! │   │  (WebRTC)   │                                                          │
//! │   └──────┬──────┘                                                          │
//! │          │                                                                  │
//! │          ▼                                                                  │
//! │   ┌─────────────────────────────────────────────────────────────────────┐  │
//! │   │                    TRANSCODING ENGINE                                │  │
//! │   │                                                                      │  │
//! │   │  ┌─────────────┐   ┌─────────────┐   ┌─────────────────────────┐   │  │
//! │   │  │   Decode    │──►│   Compose   │──►│       Encode            │   │  │
//! │   │  │  (VP8/VP9)  │   │  (Layout)   │   │  (H264 for streaming)   │   │  │
//! │   │  └─────────────┘   └─────────────┘   └───────────────┬─────────┘   │  │
//! │   │                                                      │             │  │
//! │   └──────────────────────────────────────────────────────┼─────────────┘  │
//! │                                                          │                 │
//! │          ┌───────────────────────────────────────────────┘                │
//! │          │                                                                 │
//! │          ▼                                                                 │
//! │   ┌─────────────────────────────────────────────────────────────────────┐  │
//! │   │                    OUTPUT PROTOCOLS                                  │  │
//! │   │                                                                      │  │
//! │   │   ┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────────────┐   │  │
//! │   │   │   RTMP   │   │   HLS    │   │   DASH   │   │    WebRTC    │   │  │
//! │   │   │ YouTube  │   │ Website  │   │ Website  │   │  Low latency │   │  │
//! │   │   │ Twitch   │   │ CDN      │   │ CDN      │   │  preview     │   │  │
//! │   │   └──────────┘   └──────────┘   └──────────┘   └──────────────┘   │  │
//! │   │                                                                      │  │
//! │   └─────────────────────────────────────────────────────────────────────┘  │
//! │                                                                             │
//! └─────────────────────────────────────────────────────────────────────────────┘
//! ```

use std::collections::HashMap;
use std::time::{Duration, Instant};

use serde::{Deserialize, Serialize};

/// Streaming protocol
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub enum StreamProtocol {
    /// RTMP (Real-Time Messaging Protocol) - for YouTube, Twitch, Facebook
    Rtmp,
    /// RTMPS (RTMP over TLS)
    Rtmps,
    /// HLS (HTTP Live Streaming) - Apple
    Hls,
    /// DASH (Dynamic Adaptive Streaming over HTTP)
    Dash,
    /// SRT (Secure Reliable Transport) - Low latency
    Srt,
    /// WebRTC restream
    WebRtc,
}

impl Default for StreamProtocol {
    fn default() -> Self {
        Self::Rtmps
    }
}

/// Streaming destination
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct StreamDestination {
    /// Destination ID
    pub id: u64,
    /// Name (e.g., "YouTube", "Custom RTMP")
    pub name: String,
    /// Protocol
    pub protocol: StreamProtocol,
    /// RTMP URL
    pub rtmp_url: Option<String>,
    /// Stream key
    pub stream_key: Option<String>,
    /// HLS/DASH output path
    pub output_path: Option<String>,
    /// Is enabled
    pub enabled: bool,
}

impl StreamDestination {
    /// Create YouTube destination
    pub fn youtube(stream_key: &str) -> Self {
        Self {
            id: 0,
            name: "YouTube Live".to_string(),
            protocol: StreamProtocol::Rtmps,
            rtmp_url: Some("rtmps://a.rtmps.youtube.com/live2".to_string()),
            stream_key: Some(stream_key.to_string()),
            output_path: None,
            enabled: true,
        }
    }

    /// Create Twitch destination
    pub fn twitch(stream_key: &str, ingest_server: &str) -> Self {
        Self {
            id: 0,
            name: "Twitch".to_string(),
            protocol: StreamProtocol::Rtmps,
            rtmp_url: Some(format!("rtmp://{}.twitch.tv/app", ingest_server)),
            stream_key: Some(stream_key.to_string()),
            output_path: None,
            enabled: true,
        }
    }

    /// Create Facebook destination
    pub fn facebook(stream_key: &str) -> Self {
        Self {
            id: 0,
            name: "Facebook Live".to_string(),
            protocol: StreamProtocol::Rtmps,
            rtmp_url: Some("rtmps://live-api-s.facebook.com:443/rtmp/".to_string()),
            stream_key: Some(stream_key.to_string()),
            output_path: None,
            enabled: true,
        }
    }

    /// Create custom RTMP destination
    pub fn custom_rtmp(name: &str, url: &str, stream_key: &str) -> Self {
        Self {
            id: 0,
            name: name.to_string(),
            protocol: StreamProtocol::Rtmp,
            rtmp_url: Some(url.to_string()),
            stream_key: Some(stream_key.to_string()),
            output_path: None,
            enabled: true,
        }
    }

    /// Create HLS output
    pub fn hls(output_path: &str) -> Self {
        Self {
            id: 0,
            name: "HLS Output".to_string(),
            protocol: StreamProtocol::Hls,
            rtmp_url: None,
            stream_key: None,
            output_path: Some(output_path.to_string()),
            enabled: true,
        }
    }

    /// Get full RTMP URL with stream key
    pub fn full_rtmp_url(&self) -> Option<String> {
        match (&self.rtmp_url, &self.stream_key) {
            (Some(url), Some(key)) => Some(format!("{}/{}", url, key)),
            _ => None,
        }
    }
}

/// Streaming quality preset
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum StreamQuality {
    /// 360p, 1 Mbps
    Low,
    /// 480p, 2 Mbps
    Medium,
    /// 720p, 4 Mbps
    High,
    /// 1080p, 6 Mbps
    Full,
    /// 1080p60, 8 Mbps
    Ultra,
    /// 4K, 20 Mbps
    UltraHd,
}

impl Default for StreamQuality {
    fn default() -> Self {
        Self::High
    }
}

impl StreamQuality {
    pub fn resolution(&self) -> (u32, u32) {
        match self {
            StreamQuality::Low => (640, 360),
            StreamQuality::Medium => (854, 480),
            StreamQuality::High => (1280, 720),
            StreamQuality::Full => (1920, 1080),
            StreamQuality::Ultra => (1920, 1080),
            StreamQuality::UltraHd => (3840, 2160),
        }
    }

    pub fn framerate(&self) -> u32 {
        match self {
            StreamQuality::Low => 30,
            StreamQuality::Medium => 30,
            StreamQuality::High => 30,
            StreamQuality::Full => 30,
            StreamQuality::Ultra => 60,
            StreamQuality::UltraHd => 30,
        }
    }

    pub fn bitrate_kbps(&self) -> u32 {
        match self {
            StreamQuality::Low => 1000,
            StreamQuality::Medium => 2000,
            StreamQuality::High => 4000,
            StreamQuality::Full => 6000,
            StreamQuality::Ultra => 8000,
            StreamQuality::UltraHd => 20000,
        }
    }

    pub fn audio_bitrate_kbps(&self) -> u32 {
        match self {
            StreamQuality::Low => 64,
            StreamQuality::Medium => 128,
            _ => 160,
        }
    }
}

/// Streaming layout
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum StreamLayout {
    /// Active speaker only
    ActiveSpeaker,
    /// Grid of all participants
    Grid,
    /// Active speaker large + thumbnails
    SpeakerWithThumbnails,
    /// Screen share with speaker overlay
    ScreenShareWithSpeaker,
    /// Custom layout
    Custom,
}

impl Default for StreamLayout {
    fn default() -> Self {
        Self::SpeakerWithThumbnails
    }
}

/// Streaming configuration
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct StreamConfig {
    /// Quality preset
    pub quality: StreamQuality,
    /// Layout
    pub layout: StreamLayout,
    /// Destinations
    pub destinations: Vec<StreamDestination>,
    /// Include captions
    pub include_captions: bool,
    /// Include chat overlay
    pub include_chat: bool,
    /// Branding logo URL
    pub logo_url: Option<String>,
    /// Branding watermark URL
    pub watermark_url: Option<String>,
    /// Delay in seconds (for moderation)
    pub delay_seconds: u32,
    /// DVR enabled (viewers can rewind)
    pub dvr_enabled: bool,
    /// Low-latency mode
    pub low_latency: bool,
}

impl Default for StreamConfig {
    fn default() -> Self {
        Self {
            quality: StreamQuality::High,
            layout: StreamLayout::SpeakerWithThumbnails,
            destinations: Vec::new(),
            include_captions: true,
            include_chat: false,
            logo_url: None,
            watermark_url: None,
            delay_seconds: 0,
            dvr_enabled: true,
            low_latency: false,
        }
    }
}

/// Stream state
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum StreamState {
    Idle,
    Starting,
    Live,
    Reconnecting,
    Stopping,
    Stopped,
    Error,
}

impl Default for StreamState {
    fn default() -> Self {
        Self::Idle
    }
}

/// Stream statistics
#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct StreamStats {
    /// Current state
    pub state: StreamState,
    /// Duration
    pub duration_secs: u64,
    /// Viewers (if available)
    pub viewers: Option<u64>,
    /// Bitrate (actual)
    pub bitrate_kbps: u32,
    /// Frames dropped
    pub frames_dropped: u64,
    /// Connection quality (0-100)
    pub quality_score: u8,
    /// Bytes sent
    pub bytes_sent: u64,
}

/// Live stream instance
#[derive(Debug)]
pub struct LiveStream {
    /// Stream ID
    pub id: u64,
    /// Session ID
    pub session_id: u64,
    /// Configuration
    pub config: StreamConfig,
    /// State
    pub state: StreamState,
    /// Started at
    pub started_at: Option<Instant>,
    /// Statistics per destination
    pub stats: HashMap<u64, StreamStats>,
    /// Error message
    pub error: Option<String>,
}

impl LiveStream {
    pub fn new(id: u64, session_id: u64, config: StreamConfig) -> Self {
        Self {
            id,
            session_id,
            config,
            state: StreamState::Idle,
            started_at: None,
            stats: HashMap::new(),
            error: None,
        }
    }

    /// Start streaming
    pub fn start(&mut self) -> Result<(), StreamError> {
        if self.config.destinations.is_empty() {
            return Err(StreamError::NoDestinations);
        }

        self.state = StreamState::Starting;
        self.started_at = Some(Instant::now());

        // Initialize stats for each destination
        for dest in &self.config.destinations {
            if dest.enabled {
                self.stats.insert(dest.id, StreamStats::default());
            }
        }

        tracing::info!("Starting live stream {} for session {}", self.id, self.session_id);

        // In production, this would start the actual streaming process
        self.state = StreamState::Live;

        Ok(())
    }

    /// Stop streaming
    pub fn stop(&mut self) {
        self.state = StreamState::Stopping;
        // In production, gracefully stop the stream
        self.state = StreamState::Stopped;
        tracing::info!("Stopped live stream {}", self.id);
    }

    /// Get duration
    pub fn duration(&self) -> Duration {
        self.started_at.map(|s| s.elapsed()).unwrap_or_default()
    }

    /// Is live
    pub fn is_live(&self) -> bool {
        self.state == StreamState::Live
    }

    /// Update statistics
    pub fn update_stats(&mut self, destination_id: u64, stats: StreamStats) {
        self.stats.insert(destination_id, stats);
    }

    /// Get aggregate stats
    pub fn aggregate_stats(&self) -> StreamStats {
        let mut aggregate = StreamStats::default();
        aggregate.state = self.state;
        aggregate.duration_secs = self.duration().as_secs();

        for stats in self.stats.values() {
            aggregate.bitrate_kbps += stats.bitrate_kbps;
            aggregate.frames_dropped += stats.frames_dropped;
            aggregate.bytes_sent += stats.bytes_sent;
            if let Some(viewers) = stats.viewers {
                aggregate.viewers = Some(aggregate.viewers.unwrap_or(0) + viewers);
            }
        }

        if !self.stats.is_empty() {
            aggregate.quality_score = (self.stats.values()
                .map(|s| s.quality_score as u32)
                .sum::<u32>() / self.stats.len() as u32) as u8;
        }

        aggregate
    }
}

/// Streaming manager
pub struct StreamingManager {
    /// Active streams
    streams: HashMap<u64, LiveStream>,
    /// Stream counter
    stream_counter: u64,
}

impl StreamingManager {
    pub fn new() -> Self {
        Self {
            streams: HashMap::new(),
            stream_counter: 0,
        }
    }

    /// Create a new stream
    pub fn create(&mut self, session_id: u64, config: StreamConfig) -> &LiveStream {
        self.stream_counter += 1;
        let stream = LiveStream::new(self.stream_counter, session_id, config);
        self.streams.insert(self.stream_counter, stream);
        self.streams.get(&self.stream_counter).unwrap()
    }

    /// Start a stream
    pub fn start(&mut self, stream_id: u64) -> Result<(), StreamError> {
        let stream = self.streams.get_mut(&stream_id)
            .ok_or(StreamError::NotFound)?;
        stream.start()
    }

    /// Stop a stream
    pub fn stop(&mut self, stream_id: u64) -> Result<(), StreamError> {
        let stream = self.streams.get_mut(&stream_id)
            .ok_or(StreamError::NotFound)?;
        stream.stop();
        Ok(())
    }

    /// Get stream
    pub fn get(&self, stream_id: u64) -> Option<&LiveStream> {
        self.streams.get(&stream_id)
    }

    /// Get active stream for session
    pub fn get_for_session(&self, session_id: u64) -> Option<&LiveStream> {
        self.streams.values().find(|s| s.session_id == session_id && s.is_live())
    }

    /// Stop all streams for session
    pub fn stop_all_for_session(&mut self, session_id: u64) {
        for stream in self.streams.values_mut() {
            if stream.session_id == session_id && stream.is_live() {
                stream.stop();
            }
        }
    }
}

impl Default for StreamingManager {
    fn default() -> Self {
        Self::new()
    }
}

/// Streaming errors
#[derive(Debug, Clone)]
pub enum StreamError {
    NotFound,
    NoDestinations,
    AlreadyLive,
    ConnectionFailed(String),
    EncodingError(String),
}

impl std::fmt::Display for StreamError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            StreamError::NotFound => write!(f, "Stream not found"),
            StreamError::NoDestinations => write!(f, "No streaming destinations configured"),
            StreamError::AlreadyLive => write!(f, "Stream is already live"),
            StreamError::ConnectionFailed(e) => write!(f, "Connection failed: {}", e),
            StreamError::EncodingError(e) => write!(f, "Encoding error: {}", e),
        }
    }
}

impl std::error::Error for StreamError {}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_stream_destinations() {
        let yt = StreamDestination::youtube("stream-key-123");
        assert!(yt.full_rtmp_url().unwrap().contains("stream-key-123"));

        let twitch = StreamDestination::twitch("key", "jfk");
        assert!(twitch.full_rtmp_url().unwrap().contains("jfk.twitch.tv"));
    }

    #[test]
    fn test_stream_quality() {
        let quality = StreamQuality::High;
        assert_eq!(quality.resolution(), (1280, 720));
        assert_eq!(quality.bitrate_kbps(), 4000);
    }

    #[test]
    fn test_streaming_manager() {
        let mut manager = StreamingManager::new();

        let config = StreamConfig {
            destinations: vec![StreamDestination::youtube("test")],
            ..Default::default()
        };

        let stream = manager.create(100, config);
        let stream_id = stream.id;

        manager.start(stream_id).unwrap();

        let stream = manager.get(stream_id).unwrap();
        assert!(stream.is_live());

        manager.stop(stream_id).unwrap();
    }
}
