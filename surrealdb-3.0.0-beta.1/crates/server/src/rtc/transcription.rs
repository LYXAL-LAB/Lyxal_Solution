//! AI Transcription & Live Captions
//!
//! Real-time speech-to-text transcription like Google Meet Live Captions,
//! Zoom Live Transcription, and Microsoft Teams Transcribe.
//!
//! ## Architecture (Google/Microsoft Level)
//!
//! ```text
//! ┌─────────────────────────────────────────────────────────────────────────────┐
//! │                    AI TRANSCRIPTION PIPELINE                                │
//! │                                                                             │
//! │   ┌─────────┐     ┌──────────────┐     ┌─────────────────────────────────┐ │
//! │   │  Audio  │────►│   VAD +      │────►│      Speech Recognition         │ │
//! │   │ Stream  │     │  Chunking    │     │      (Whisper/DeepSpeech)       │ │
//! │   └─────────┘     └──────────────┘     └───────────────┬─────────────────┘ │
//! │                                                        │                    │
//! │                                                        ▼                    │
//! │   ┌─────────────────────────────────────────────────────────────────────┐  │
//! │   │                     POST-PROCESSING                                  │  │
//! │   │                                                                      │  │
//! │   │  ┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────────────────┐ │  │
//! │   │  │Punctuate │──►│ Speaker  │──►│ Language │──►│   Translation    │ │  │
//! │   │  │ + Format │   │   ID     │   │ Detect   │   │   (Optional)     │ │  │
//! │   │  └──────────┘   └──────────┘   └──────────┘   └──────────────────┘ │  │
//! │   │                                                                      │  │
//! │   └───────────────────────────────────┬─────────────────────────────────┘  │
//! │                                       │                                     │
//! │                                       ▼                                     │
//! │   ┌─────────────────────────────────────────────────────────────────────┐  │
//! │   │                        OUTPUT CHANNELS                               │  │
//! │   │                                                                      │  │
//! │   │  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────────┐  │  │
//! │   │  │ Live Captions│  │  Transcript  │  │    Meeting Summary       │  │  │
//! │   │  │  (WebSocket) │  │   (Storage)  │  │    (AI Generated)        │  │  │
//! │   │  └──────────────┘  └──────────────┘  └──────────────────────────┘  │  │
//! │   │                                                                      │  │
//! │   └─────────────────────────────────────────────────────────────────────┘  │
//! │                                                                             │
//! └─────────────────────────────────────────────────────────────────────────────┘
//! ```

use std::collections::HashMap;
use std::time::{Duration, Instant};

use serde::{Deserialize, Serialize};
use tokio::sync::mpsc;

/// Supported languages for transcription
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub enum Language {
    English,
    French,
    Spanish,
    German,
    Italian,
    Portuguese,
    Dutch,
    Russian,
    Chinese,
    Japanese,
    Korean,
    Arabic,
    Hindi,
    Auto, // Auto-detect
}

impl Default for Language {
    fn default() -> Self {
        Self::Auto
    }
}

impl Language {
    pub fn code(&self) -> &'static str {
        match self {
            Language::English => "en",
            Language::French => "fr",
            Language::Spanish => "es",
            Language::German => "de",
            Language::Italian => "it",
            Language::Portuguese => "pt",
            Language::Dutch => "nl",
            Language::Russian => "ru",
            Language::Chinese => "zh",
            Language::Japanese => "ja",
            Language::Korean => "ko",
            Language::Arabic => "ar",
            Language::Hindi => "hi",
            Language::Auto => "auto",
        }
    }

    pub fn name(&self) -> &'static str {
        match self {
            Language::English => "English",
            Language::French => "Français",
            Language::Spanish => "Español",
            Language::German => "Deutsch",
            Language::Italian => "Italiano",
            Language::Portuguese => "Português",
            Language::Dutch => "Nederlands",
            Language::Russian => "Русский",
            Language::Chinese => "中文",
            Language::Japanese => "日本語",
            Language::Korean => "한국어",
            Language::Arabic => "العربية",
            Language::Hindi => "हिन्दी",
            Language::Auto => "Auto-detect",
        }
    }
}

/// Transcription configuration
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TranscriptionConfig {
    /// Enable live transcription
    pub enabled: bool,
    /// Source language
    pub source_language: Language,
    /// Enable auto-punctuation
    pub auto_punctuation: bool,
    /// Enable profanity filter
    pub profanity_filter: bool,
    /// Enable speaker diarization (identify who's speaking)
    pub speaker_diarization: bool,
    /// Max speakers to identify
    pub max_speakers: u8,
    /// Enable word-level timestamps
    pub word_timestamps: bool,
    /// Minimum confidence threshold (0.0 - 1.0)
    pub min_confidence: f32,
    /// Enable translation
    pub translation_enabled: bool,
    /// Target languages for translation
    pub translation_targets: Vec<Language>,
    /// Save transcript to storage
    pub save_transcript: bool,
    /// Generate AI summary after meeting
    pub generate_summary: bool,
}

impl Default for TranscriptionConfig {
    fn default() -> Self {
        Self {
            enabled: true,
            source_language: Language::Auto,
            auto_punctuation: true,
            profanity_filter: false,
            speaker_diarization: true,
            max_speakers: 10,
            word_timestamps: true,
            min_confidence: 0.6,
            translation_enabled: false,
            translation_targets: Vec::new(),
            save_transcript: true,
            generate_summary: true,
        }
    }
}

/// A single word with timing
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TranscriptWord {
    /// The word text
    pub word: String,
    /// Start time (ms from session start)
    pub start_ms: u64,
    /// End time (ms from session start)
    pub end_ms: u64,
    /// Confidence score (0.0 - 1.0)
    pub confidence: f32,
}

/// A transcript segment (utterance)
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TranscriptSegment {
    /// Segment ID
    pub id: u64,
    /// Speaker endpoint ID
    pub speaker_id: u64,
    /// Speaker name (if known)
    pub speaker_name: Option<String>,
    /// Full text
    pub text: String,
    /// Individual words (if word_timestamps enabled)
    pub words: Vec<TranscriptWord>,
    /// Start time (ms from session start)
    pub start_ms: u64,
    /// End time (ms from session start)
    pub end_ms: u64,
    /// Detected language
    pub language: Language,
    /// Confidence score
    pub confidence: f32,
    /// Is this a final result (not interim)
    pub is_final: bool,
    /// Translations
    pub translations: HashMap<Language, String>,
}

/// Live caption event (sent to clients)
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CaptionEvent {
    /// Session ID
    pub session_id: u64,
    /// Segment
    pub segment: TranscriptSegment,
    /// Event timestamp
    pub timestamp: u64,
}

/// Full meeting transcript
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MeetingTranscript {
    /// Session ID
    pub session_id: u64,
    /// Meeting title
    pub title: Option<String>,
    /// Start time (Unix timestamp)
    pub started_at: u64,
    /// End time (Unix timestamp)
    pub ended_at: Option<u64>,
    /// Duration
    pub duration_ms: u64,
    /// Participants
    pub participants: Vec<TranscriptParticipant>,
    /// All segments
    pub segments: Vec<TranscriptSegment>,
    /// Languages detected
    pub languages_detected: Vec<Language>,
    /// Word count
    pub word_count: usize,
    /// AI-generated summary
    pub summary: Option<MeetingSummary>,
}

/// Participant info for transcript
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TranscriptParticipant {
    pub endpoint_id: u64,
    pub name: Option<String>,
    pub speaking_time_ms: u64,
    pub word_count: usize,
    pub segment_count: usize,
}

/// AI-generated meeting summary
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MeetingSummary {
    /// Brief summary (1-2 paragraphs)
    pub summary: String,
    /// Key points discussed
    pub key_points: Vec<String>,
    /// Action items identified
    pub action_items: Vec<ActionItem>,
    /// Decisions made
    pub decisions: Vec<String>,
    /// Questions raised
    pub questions: Vec<String>,
    /// Topics discussed with time spent
    pub topics: Vec<TopicSummary>,
    /// Sentiment analysis
    pub sentiment: Sentiment,
    /// Generated at
    pub generated_at: u64,
}

/// Action item from meeting
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ActionItem {
    /// Description
    pub description: String,
    /// Assigned to (if mentioned)
    pub assignee: Option<String>,
    /// Due date (if mentioned)
    pub due_date: Option<String>,
    /// Priority
    pub priority: Priority,
    /// Source segment ID
    pub source_segment_id: u64,
}

/// Topic summary
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TopicSummary {
    /// Topic name
    pub topic: String,
    /// Time spent discussing (ms)
    pub duration_ms: u64,
    /// Key points for this topic
    pub key_points: Vec<String>,
}

/// Priority level
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum Priority {
    Low,
    Medium,
    High,
    Critical,
}

/// Meeting sentiment
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum Sentiment {
    VeryNegative,
    Negative,
    Neutral,
    Positive,
    VeryPositive,
}

impl Default for Sentiment {
    fn default() -> Self {
        Self::Neutral
    }
}

/// Transcription service state
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum TranscriptionState {
    Idle,
    Starting,
    Active,
    Paused,
    Stopping,
    Stopped,
}

/// Transcription manager
pub struct TranscriptionManager {
    /// Active sessions
    sessions: HashMap<u64, TranscriptionSession>,
    /// Configuration
    default_config: TranscriptionConfig,
    /// Caption event sender
    caption_tx: Option<mpsc::UnboundedSender<CaptionEvent>>,
}

/// Transcription session
pub struct TranscriptionSession {
    /// Session ID
    pub session_id: u64,
    /// Configuration
    pub config: TranscriptionConfig,
    /// State
    pub state: TranscriptionState,
    /// Started at
    pub started_at: Instant,
    /// Segments collected
    pub segments: Vec<TranscriptSegment>,
    /// Segment counter
    segment_counter: u64,
    /// Speaker stats
    pub speaker_stats: HashMap<u64, SpeakerStats>,
    /// Languages detected
    pub languages_detected: std::collections::HashSet<Language>,
}

/// Speaker statistics
#[derive(Debug, Clone, Default)]
pub struct SpeakerStats {
    pub speaking_time_ms: u64,
    pub word_count: usize,
    pub segment_count: usize,
    pub last_spoke: Option<Instant>,
}

impl TranscriptionSession {
    pub fn new(session_id: u64, config: TranscriptionConfig) -> Self {
        Self {
            session_id,
            config,
            state: TranscriptionState::Idle,
            started_at: Instant::now(),
            segments: Vec::new(),
            segment_counter: 0,
            speaker_stats: HashMap::new(),
            languages_detected: std::collections::HashSet::new(),
        }
    }

    /// Add a transcript segment
    pub fn add_segment(&mut self, mut segment: TranscriptSegment) {
        self.segment_counter += 1;
        segment.id = self.segment_counter;

        // Update speaker stats
        let stats = self.speaker_stats
            .entry(segment.speaker_id)
            .or_default();
        stats.speaking_time_ms += segment.end_ms - segment.start_ms;
        stats.word_count += segment.words.len();
        stats.segment_count += 1;
        stats.last_spoke = Some(Instant::now());

        // Track language
        self.languages_detected.insert(segment.language);

        self.segments.push(segment);
    }

    /// Get total word count
    pub fn word_count(&self) -> usize {
        self.segments.iter().map(|s| s.words.len()).sum()
    }

    /// Get duration
    pub fn duration(&self) -> Duration {
        self.started_at.elapsed()
    }

    /// Generate transcript
    pub fn to_transcript(&self, title: Option<String>) -> MeetingTranscript {
        let participants: Vec<TranscriptParticipant> = self.speaker_stats
            .iter()
            .map(|(&endpoint_id, stats)| TranscriptParticipant {
                endpoint_id,
                name: None, // Would be filled from session data
                speaking_time_ms: stats.speaking_time_ms,
                word_count: stats.word_count,
                segment_count: stats.segment_count,
            })
            .collect();

        MeetingTranscript {
            session_id: self.session_id,
            title,
            started_at: std::time::SystemTime::now()
                .duration_since(std::time::UNIX_EPOCH)
                .unwrap()
                .as_secs() - self.duration().as_secs(),
            ended_at: None,
            duration_ms: self.duration().as_millis() as u64,
            participants,
            segments: self.segments.clone(),
            languages_detected: self.languages_detected.iter().copied().collect(),
            word_count: self.word_count(),
            summary: None,
        }
    }
}

impl TranscriptionManager {
    pub fn new(default_config: TranscriptionConfig) -> Self {
        Self {
            sessions: HashMap::new(),
            default_config,
            caption_tx: None,
        }
    }

    pub fn with_defaults() -> Self {
        Self::new(TranscriptionConfig::default())
    }

    /// Set caption event channel
    pub fn set_caption_channel(&mut self, tx: mpsc::UnboundedSender<CaptionEvent>) {
        self.caption_tx = Some(tx);
    }

    /// Start transcription for a session
    pub fn start(&mut self, session_id: u64, config: Option<TranscriptionConfig>) -> Result<(), TranscriptionError> {
        if self.sessions.contains_key(&session_id) {
            return Err(TranscriptionError::AlreadyActive(session_id));
        }

        let config = config.unwrap_or_else(|| self.default_config.clone());
        let mut session = TranscriptionSession::new(session_id, config);
        session.state = TranscriptionState::Active;

        self.sessions.insert(session_id, session);
        tracing::info!("Started transcription for session {}", session_id);

        Ok(())
    }

    /// Stop transcription
    pub fn stop(&mut self, session_id: u64) -> Result<MeetingTranscript, TranscriptionError> {
        let mut session = self.sessions
            .remove(&session_id)
            .ok_or(TranscriptionError::NotFound(session_id))?;

        session.state = TranscriptionState::Stopped;
        let transcript = session.to_transcript(None);

        tracing::info!(
            "Stopped transcription for session {}. {} segments, {} words",
            session_id,
            transcript.segments.len(),
            transcript.word_count
        );

        Ok(transcript)
    }

    /// Pause transcription
    pub fn pause(&mut self, session_id: u64) -> Result<(), TranscriptionError> {
        let session = self.sessions
            .get_mut(&session_id)
            .ok_or(TranscriptionError::NotFound(session_id))?;

        session.state = TranscriptionState::Paused;
        Ok(())
    }

    /// Resume transcription
    pub fn resume(&mut self, session_id: u64) -> Result<(), TranscriptionError> {
        let session = self.sessions
            .get_mut(&session_id)
            .ok_or(TranscriptionError::NotFound(session_id))?;

        session.state = TranscriptionState::Active;
        Ok(())
    }

    /// Process recognized speech
    pub fn on_speech_recognized(
        &mut self,
        session_id: u64,
        speaker_id: u64,
        text: String,
        start_ms: u64,
        end_ms: u64,
        language: Language,
        confidence: f32,
        is_final: bool,
    ) -> Result<(), TranscriptionError> {
        let session = self.sessions
            .get_mut(&session_id)
            .ok_or(TranscriptionError::NotFound(session_id))?;

        if session.state != TranscriptionState::Active {
            return Ok(()); // Ignore if not active
        }

        // Create segment
        let segment = TranscriptSegment {
            id: 0, // Will be set by add_segment
            speaker_id,
            speaker_name: None,
            text: text.clone(),
            words: Vec::new(), // Would be filled by ASR
            start_ms,
            end_ms,
            language,
            confidence,
            is_final,
            translations: HashMap::new(),
        };

        // Emit caption event
        if let Some(tx) = &self.caption_tx {
            let event = CaptionEvent {
                session_id,
                segment: segment.clone(),
                timestamp: std::time::SystemTime::now()
                    .duration_since(std::time::UNIX_EPOCH)
                    .unwrap()
                    .as_millis() as u64,
            };
            let _ = tx.send(event);
        }

        // Store if final
        if is_final {
            session.add_segment(segment);
        }

        Ok(())
    }

    /// Get session state
    pub fn get_state(&self, session_id: u64) -> Option<TranscriptionState> {
        self.sessions.get(&session_id).map(|s| s.state)
    }

    /// Get live stats
    pub fn get_stats(&self, session_id: u64) -> Option<TranscriptionStats> {
        self.sessions.get(&session_id).map(|s| TranscriptionStats {
            state: s.state,
            duration_ms: s.duration().as_millis() as u64,
            segment_count: s.segments.len(),
            word_count: s.word_count(),
            speaker_count: s.speaker_stats.len(),
            languages_detected: s.languages_detected.len(),
        })
    }
}

impl Default for TranscriptionManager {
    fn default() -> Self {
        Self::with_defaults()
    }
}

/// Transcription statistics
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TranscriptionStats {
    pub state: TranscriptionState,
    pub duration_ms: u64,
    pub segment_count: usize,
    pub word_count: usize,
    pub speaker_count: usize,
    pub languages_detected: usize,
}

impl Serialize for TranscriptionState {
    fn serialize<S>(&self, serializer: S) -> Result<S::Ok, S::Error>
    where
        S: serde::Serializer,
    {
        let s = match self {
            TranscriptionState::Idle => "idle",
            TranscriptionState::Starting => "starting",
            TranscriptionState::Active => "active",
            TranscriptionState::Paused => "paused",
            TranscriptionState::Stopping => "stopping",
            TranscriptionState::Stopped => "stopped",
        };
        serializer.serialize_str(s)
    }
}

impl<'de> Deserialize<'de> for TranscriptionState {
    fn deserialize<D>(deserializer: D) -> Result<Self, D::Error>
    where
        D: serde::Deserializer<'de>,
    {
        let s = String::deserialize(deserializer)?;
        match s.as_str() {
            "idle" => Ok(TranscriptionState::Idle),
            "starting" => Ok(TranscriptionState::Starting),
            "active" => Ok(TranscriptionState::Active),
            "paused" => Ok(TranscriptionState::Paused),
            "stopping" => Ok(TranscriptionState::Stopping),
            "stopped" => Ok(TranscriptionState::Stopped),
            _ => Err(serde::de::Error::unknown_variant(&s, &["idle", "starting", "active", "paused", "stopping", "stopped"])),
        }
    }
}

/// Transcription errors
#[derive(Debug, Clone)]
pub enum TranscriptionError {
    NotFound(u64),
    AlreadyActive(u64),
    NotActive(u64),
    ConfigError(String),
}

impl std::fmt::Display for TranscriptionError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            TranscriptionError::NotFound(id) => write!(f, "Transcription session {} not found", id),
            TranscriptionError::AlreadyActive(id) => write!(f, "Transcription already active for session {}", id),
            TranscriptionError::NotActive(id) => write!(f, "Transcription not active for session {}", id),
            TranscriptionError::ConfigError(e) => write!(f, "Configuration error: {}", e),
        }
    }
}

impl std::error::Error for TranscriptionError {}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_transcription_config_default() {
        let config = TranscriptionConfig::default();
        assert!(config.enabled);
        assert!(config.auto_punctuation);
        assert!(config.speaker_diarization);
    }

    #[test]
    fn test_language_codes() {
        assert_eq!(Language::English.code(), "en");
        assert_eq!(Language::French.code(), "fr");
        assert_eq!(Language::Auto.code(), "auto");
    }

    #[test]
    fn test_transcription_session() {
        let config = TranscriptionConfig::default();
        let mut session = TranscriptionSession::new(100, config);

        let segment = TranscriptSegment {
            id: 0,
            speaker_id: 1,
            speaker_name: Some("Alice".to_string()),
            text: "Hello everyone".to_string(),
            words: vec![
                TranscriptWord { word: "Hello".to_string(), start_ms: 0, end_ms: 500, confidence: 0.9 },
                TranscriptWord { word: "everyone".to_string(), start_ms: 500, end_ms: 1000, confidence: 0.95 },
            ],
            start_ms: 0,
            end_ms: 1000,
            language: Language::English,
            confidence: 0.92,
            is_final: true,
            translations: HashMap::new(),
        };

        session.add_segment(segment);

        assert_eq!(session.segments.len(), 1);
        assert_eq!(session.word_count(), 2);
        assert!(session.languages_detected.contains(&Language::English));
    }

    #[test]
    fn test_transcription_manager() {
        let mut manager = TranscriptionManager::with_defaults();

        // Start transcription
        manager.start(100, None).unwrap();
        assert_eq!(manager.get_state(100), Some(TranscriptionState::Active));

        // Process speech
        manager.on_speech_recognized(
            100, 1,
            "This is a test".to_string(),
            0, 2000,
            Language::English,
            0.9,
            true
        ).unwrap();

        let stats = manager.get_stats(100).unwrap();
        assert_eq!(stats.segment_count, 1);

        // Stop and get transcript
        let transcript = manager.stop(100).unwrap();
        assert_eq!(transcript.segments.len(), 1);
    }

    #[test]
    fn test_meeting_summary_structure() {
        let summary = MeetingSummary {
            summary: "This meeting discussed project updates.".to_string(),
            key_points: vec!["Point 1".to_string(), "Point 2".to_string()],
            action_items: vec![
                ActionItem {
                    description: "Complete the report".to_string(),
                    assignee: Some("John".to_string()),
                    due_date: Some("2024-01-15".to_string()),
                    priority: Priority::High,
                    source_segment_id: 5,
                }
            ],
            decisions: vec!["Decision 1".to_string()],
            questions: vec![],
            topics: vec![
                TopicSummary {
                    topic: "Project Status".to_string(),
                    duration_ms: 300000,
                    key_points: vec!["On track".to_string()],
                }
            ],
            sentiment: Sentiment::Positive,
            generated_at: 0,
        };

        assert_eq!(summary.action_items.len(), 1);
        assert_eq!(summary.topics.len(), 1);
    }
}
