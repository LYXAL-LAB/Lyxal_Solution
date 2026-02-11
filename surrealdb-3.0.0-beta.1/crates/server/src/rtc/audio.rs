//! Audio Processing - Noise Suppression, Echo Cancellation, AGC
//!
//! This module provides server-side audio processing capabilities
//! similar to Zoom's AI noise suppression and Krisp integration.
//!
//! ## Audio Pipeline (like Zoom/Teams)
//!
//! ```text
//! ┌─────────────────────────────────────────────────────────────────┐
//! │                    AUDIO PROCESSING PIPELINE                    │
//! │                                                                 │
//! │   ┌─────────┐                                                  │
//! │   │  Input  │ (Raw audio from client)                          │
//! │   │  Audio  │                                                  │
//! │   └────┬────┘                                                  │
//! │        │                                                        │
//! │        ▼                                                        │
//! │   ┌─────────────────┐                                          │
//! │   │  Noise Gate     │ Remove silence/very quiet sounds         │
//! │   └────────┬────────┘                                          │
//! │            │                                                    │
//! │            ▼                                                    │
//! │   ┌─────────────────┐                                          │
//! │   │  Noise          │ ML-based noise suppression               │
//! │   │  Suppression    │ (keyboard, fan, traffic, etc.)           │
//! │   └────────┬────────┘                                          │
//! │            │                                                    │
//! │            ▼                                                    │
//! │   ┌─────────────────┐                                          │
//! │   │  Echo           │ Remove acoustic echo from speakers       │
//! │   │  Cancellation   │                                          │
//! │   └────────┬────────┘                                          │
//! │            │                                                    │
//! │            ▼                                                    │
//! │   ┌─────────────────┐                                          │
//! │   │  AGC            │ Automatic Gain Control                   │
//! │   │  (Leveling)     │ Normalize volume levels                  │
//! │   └────────┬────────┘                                          │
//! │            │                                                    │
//! │            ▼                                                    │
//! │   ┌─────────────────┐                                          │
//! │   │  Voice Activity │ Detect when user is speaking            │
//! │   │  Detection      │                                          │
//! │   └────────┬────────┘                                          │
//! │            │                                                    │
//! │            ▼                                                    │
//! │   ┌─────────┐                                                  │
//! │   │ Output  │                                                  │
//! │   │ Audio   │                                                  │
//! │   └─────────┘                                                  │
//! │                                                                 │
//! └─────────────────────────────────────────────────────────────────┘
//! ```

use std::collections::HashMap;
use std::time::{Duration, Instant};

use serde::{Deserialize, Serialize};

/// Noise suppression level
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum NoiseSuppressionLevel {
    /// No suppression
    Off,
    /// Light suppression (preserve natural sound)
    Low,
    /// Medium suppression (balanced)
    Medium,
    /// High suppression (aggressive, may affect voice)
    High,
    /// AI-powered adaptive suppression
    Auto,
}

impl Default for NoiseSuppressionLevel {
    fn default() -> Self {
        Self::Auto
    }
}

/// Echo cancellation mode
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum EchoCancellationMode {
    /// Disabled
    Off,
    /// Conference mode (multiple speakers)
    Conference,
    /// Desktop mode (single speaker/mic)
    Desktop,
    /// Mobile mode
    Mobile,
}

impl Default for EchoCancellationMode {
    fn default() -> Self {
        Self::Conference
    }
}

/// AGC (Automatic Gain Control) mode
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum AgcMode {
    /// Disabled
    Off,
    /// Fixed gain
    Fixed,
    /// Adaptive gain
    Adaptive,
    /// Digital AGC
    Digital,
}

impl Default for AgcMode {
    fn default() -> Self {
        Self::Adaptive
    }
}

/// Audio processing configuration
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AudioProcessingConfig {
    /// Enable audio processing
    pub enabled: bool,
    /// Noise suppression level
    pub noise_suppression: NoiseSuppressionLevel,
    /// Echo cancellation mode
    pub echo_cancellation: EchoCancellationMode,
    /// AGC mode
    pub agc_mode: AgcMode,
    /// Target volume level (dB)
    pub target_level_db: i16,
    /// Voice activity detection threshold
    pub vad_threshold: f32,
    /// Noise gate threshold (dB)
    pub noise_gate_db: i16,
    /// Enable comfort noise
    pub comfort_noise_enabled: bool,
    /// Comfort noise level (dB)
    pub comfort_noise_db: i16,
    /// Enable highpass filter
    pub highpass_filter_enabled: bool,
    /// Highpass cutoff frequency (Hz)
    pub highpass_cutoff_hz: u32,
}

impl Default for AudioProcessingConfig {
    fn default() -> Self {
        Self {
            enabled: true,
            noise_suppression: NoiseSuppressionLevel::Auto,
            echo_cancellation: EchoCancellationMode::Conference,
            agc_mode: AgcMode::Adaptive,
            target_level_db: -18,
            vad_threshold: 0.3,
            noise_gate_db: -50,
            comfort_noise_enabled: true,
            comfort_noise_db: -60,
            highpass_filter_enabled: true,
            highpass_cutoff_hz: 80,
        }
    }
}

impl AudioProcessingConfig {
    /// Config optimized for meetings
    pub fn for_meeting() -> Self {
        Self::default()
    }

    /// Config optimized for webinars (presenter focus)
    pub fn for_webinar() -> Self {
        Self {
            noise_suppression: NoiseSuppressionLevel::High,
            echo_cancellation: EchoCancellationMode::Conference,
            agc_mode: AgcMode::Adaptive,
            target_level_db: -16,
            ..Default::default()
        }
    }

    /// Config optimized for music/high quality
    pub fn for_music() -> Self {
        Self {
            noise_suppression: NoiseSuppressionLevel::Off,
            echo_cancellation: EchoCancellationMode::Off,
            agc_mode: AgcMode::Off,
            highpass_filter_enabled: false,
            ..Default::default()
        }
    }

    /// Minimal processing
    pub fn minimal() -> Self {
        Self {
            enabled: true,
            noise_suppression: NoiseSuppressionLevel::Low,
            echo_cancellation: EchoCancellationMode::Off,
            agc_mode: AgcMode::Off,
            comfort_noise_enabled: false,
            highpass_filter_enabled: false,
            ..Default::default()
        }
    }
}

/// Voice activity state
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum VoiceActivityState {
    /// User is silent
    Silent,
    /// User is speaking
    Speaking,
    /// Uncertain (transition)
    Uncertain,
}

impl Default for VoiceActivityState {
    fn default() -> Self {
        Self::Silent
    }
}

/// Audio level info
#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
pub struct AudioLevel {
    /// RMS level in dBFS (-96 to 0)
    pub level_dbfs: f32,
    /// Peak level in dBFS
    pub peak_dbfs: f32,
    /// Normalized level (0.0 to 1.0)
    pub normalized: f32,
    /// Is clipping
    pub clipping: bool,
}

impl Default for AudioLevel {
    fn default() -> Self {
        Self {
            level_dbfs: -96.0,
            peak_dbfs: -96.0,
            normalized: 0.0,
            clipping: false,
        }
    }
}

impl AudioLevel {
    pub fn from_samples(samples: &[i16]) -> Self {
        if samples.is_empty() {
            return Self::default();
        }

        // Calculate RMS
        let sum_sq: f64 = samples.iter()
            .map(|&s| (s as f64).powi(2))
            .sum();
        let rms = (sum_sq / samples.len() as f64).sqrt();

        // Find peak
        let peak = samples.iter()
            .map(|&s| s.abs() as f64)
            .fold(0.0f64, |a, b| a.max(b));

        // Convert to dBFS
        let max_value = i16::MAX as f64;
        let level_dbfs = if rms > 0.0 {
            20.0 * (rms / max_value).log10()
        } else {
            -96.0
        };
        let peak_dbfs = if peak > 0.0 {
            20.0 * (peak / max_value).log10()
        } else {
            -96.0
        };

        // Normalize (0-1 scale)
        let normalized = (rms / max_value).min(1.0);

        // Check for clipping
        let clipping = peak >= max_value * 0.99;

        Self {
            level_dbfs: level_dbfs as f32,
            peak_dbfs: peak_dbfs as f32,
            normalized: normalized as f32,
            clipping,
        }
    }

    /// Check if level indicates speech
    pub fn is_speech(&self, threshold_db: f32) -> bool {
        self.level_dbfs > threshold_db
    }
}

/// Voice Activity Detector
pub struct VoiceActivityDetector {
    /// Configuration
    config: VadConfig,
    /// Current state
    state: VoiceActivityState,
    /// History of levels
    level_history: Vec<f32>,
    /// Last state change
    last_change: Instant,
    /// Consecutive speech frames
    speech_frames: u32,
    /// Consecutive silence frames
    silence_frames: u32,
}

/// VAD configuration
#[derive(Debug, Clone)]
pub struct VadConfig {
    /// Threshold for speech detection (dB)
    pub threshold_db: f32,
    /// Frames needed to confirm speech
    pub speech_confirm_frames: u32,
    /// Frames needed to confirm silence
    pub silence_confirm_frames: u32,
    /// History size
    pub history_size: usize,
}

impl Default for VadConfig {
    fn default() -> Self {
        Self {
            threshold_db: -40.0,
            speech_confirm_frames: 3,
            silence_confirm_frames: 10,
            history_size: 30,
        }
    }
}

impl VoiceActivityDetector {
    pub fn new(config: VadConfig) -> Self {
        Self {
            config,
            state: VoiceActivityState::Silent,
            level_history: Vec::new(),
            last_change: Instant::now(),
            speech_frames: 0,
            silence_frames: 0,
        }
    }

    pub fn with_defaults() -> Self {
        Self::new(VadConfig::default())
    }

    /// Process an audio frame
    pub fn process(&mut self, level: AudioLevel) -> VoiceActivityState {
        // Update history
        self.level_history.push(level.level_dbfs);
        if self.level_history.len() > self.config.history_size {
            self.level_history.remove(0);
        }

        // Check if current frame is speech
        let is_speech_frame = level.level_dbfs > self.config.threshold_db;

        if is_speech_frame {
            self.speech_frames += 1;
            self.silence_frames = 0;
        } else {
            self.silence_frames += 1;
            self.speech_frames = 0;
        }

        // State transitions
        let new_state = match self.state {
            VoiceActivityState::Silent => {
                if self.speech_frames >= self.config.speech_confirm_frames {
                    VoiceActivityState::Speaking
                } else if is_speech_frame {
                    VoiceActivityState::Uncertain
                } else {
                    VoiceActivityState::Silent
                }
            }
            VoiceActivityState::Speaking => {
                if self.silence_frames >= self.config.silence_confirm_frames {
                    VoiceActivityState::Silent
                } else if !is_speech_frame {
                    VoiceActivityState::Uncertain
                } else {
                    VoiceActivityState::Speaking
                }
            }
            VoiceActivityState::Uncertain => {
                if self.speech_frames >= self.config.speech_confirm_frames {
                    VoiceActivityState::Speaking
                } else if self.silence_frames >= self.config.silence_confirm_frames {
                    VoiceActivityState::Silent
                } else {
                    VoiceActivityState::Uncertain
                }
            }
        };

        if new_state != self.state {
            self.last_change = Instant::now();
            self.state = new_state;
        }

        self.state
    }

    /// Get current state
    pub fn state(&self) -> VoiceActivityState {
        self.state
    }

    /// Get time since last state change
    pub fn time_in_state(&self) -> Duration {
        self.last_change.elapsed()
    }

    /// Is currently speaking
    pub fn is_speaking(&self) -> bool {
        self.state == VoiceActivityState::Speaking
    }
}

impl Default for VoiceActivityDetector {
    fn default() -> Self {
        Self::with_defaults()
    }
}

/// Active speaker detector
pub struct ActiveSpeakerDetector {
    /// Endpoint audio states
    endpoint_states: HashMap<u64, EndpointAudioState>,
    /// Current active speaker
    active_speaker: Option<u64>,
    /// Last change time
    last_change: Instant,
    /// Minimum time before speaker can change
    switch_delay: Duration,
}

/// Audio state for an endpoint
#[derive(Debug)]
struct EndpointAudioState {
    vad: VoiceActivityDetector,
    level: AudioLevel,
    speaking_duration: Duration,
    last_update: Instant,
}

impl ActiveSpeakerDetector {
    pub fn new() -> Self {
        Self {
            endpoint_states: HashMap::new(),
            active_speaker: None,
            last_change: Instant::now(),
            switch_delay: Duration::from_millis(500),
        }
    }

    /// Register an endpoint
    pub fn register(&mut self, endpoint_id: u64) {
        self.endpoint_states.insert(endpoint_id, EndpointAudioState {
            vad: VoiceActivityDetector::with_defaults(),
            level: AudioLevel::default(),
            speaking_duration: Duration::ZERO,
            last_update: Instant::now(),
        });
    }

    /// Unregister an endpoint
    pub fn unregister(&mut self, endpoint_id: u64) {
        self.endpoint_states.remove(&endpoint_id);
        if self.active_speaker == Some(endpoint_id) {
            self.active_speaker = None;
        }
    }

    /// Update audio level for an endpoint
    pub fn update_level(&mut self, endpoint_id: u64, level: AudioLevel) -> Option<u64> {
        if let Some(state) = self.endpoint_states.get_mut(&endpoint_id) {
            state.level = level;
            let vad_state = state.vad.process(level);
            
            if vad_state == VoiceActivityState::Speaking {
                state.speaking_duration += state.last_update.elapsed();
            } else {
                state.speaking_duration = Duration::ZERO;
            }
            state.last_update = Instant::now();
        }

        // Determine active speaker
        self.update_active_speaker()
    }

    fn update_active_speaker(&mut self) -> Option<u64> {
        // Don't switch too quickly
        if self.last_change.elapsed() < self.switch_delay {
            return self.active_speaker;
        }

        // Find loudest speaking endpoint
        let mut loudest: Option<(u64, f32)> = None;

        for (&endpoint_id, state) in &self.endpoint_states {
            if state.vad.is_speaking() {
                let level = state.level.level_dbfs;
                if loudest.map(|(_, l)| level > l).unwrap_or(true) {
                    loudest = Some((endpoint_id, level));
                }
            }
        }

        let new_speaker = loudest.map(|(id, _)| id);

        if new_speaker != self.active_speaker && new_speaker.is_some() {
            self.active_speaker = new_speaker;
            self.last_change = Instant::now();
        }

        self.active_speaker
    }

    /// Get current active speaker
    pub fn active_speaker(&self) -> Option<u64> {
        self.active_speaker
    }

    /// Get all speaking endpoints
    pub fn speaking_endpoints(&self) -> Vec<u64> {
        self.endpoint_states.iter()
            .filter(|(_, state)| state.vad.is_speaking())
            .map(|(&id, _)| id)
            .collect()
    }

    /// Get audio levels for all endpoints
    pub fn audio_levels(&self) -> HashMap<u64, AudioLevel> {
        self.endpoint_states.iter()
            .map(|(&id, state)| (id, state.level))
            .collect()
    }
}

impl Default for ActiveSpeakerDetector {
    fn default() -> Self {
        Self::new()
    }
}

/// Audio mixer for combining multiple streams
pub struct AudioMixer {
    /// Gain per source
    gains: HashMap<u64, f32>,
    /// Master gain
    master_gain: f32,
    /// Limiter enabled
    limiter_enabled: bool,
    /// Limiter threshold
    limiter_threshold: f32,
}

impl AudioMixer {
    pub fn new() -> Self {
        Self {
            gains: HashMap::new(),
            master_gain: 1.0,
            limiter_enabled: true,
            limiter_threshold: 0.95,
        }
    }

    /// Set gain for a source
    pub fn set_gain(&mut self, source_id: u64, gain: f32) {
        self.gains.insert(source_id, gain.clamp(0.0, 2.0));
    }

    /// Set master gain
    pub fn set_master_gain(&mut self, gain: f32) {
        self.master_gain = gain.clamp(0.0, 2.0);
    }

    /// Mix multiple audio sources
    pub fn mix(&self, sources: &HashMap<u64, &[i16]>) -> Vec<i16> {
        if sources.is_empty() {
            return Vec::new();
        }

        // Find the maximum length
        let max_len = sources.values().map(|s| s.len()).max().unwrap_or(0);
        if max_len == 0 {
            return Vec::new();
        }

        // Accumulate samples as f32
        let mut mixed: Vec<f32> = vec![0.0; max_len];

        for (&source_id, samples) in sources {
            let gain = self.gains.get(&source_id).copied().unwrap_or(1.0);

            for (i, &sample) in samples.iter().enumerate() {
                mixed[i] += sample as f32 * gain;
            }
        }

        // Apply master gain and limiter
        for sample in &mut mixed {
            *sample *= self.master_gain;

            if self.limiter_enabled {
                let max = i16::MAX as f32 * self.limiter_threshold;
                if *sample > max {
                    *sample = max + (*sample - max).tanh() * (i16::MAX as f32 - max);
                } else if *sample < -max {
                    *sample = -max + (*sample + max).tanh() * (i16::MAX as f32 - max);
                }
            }
        }

        // Convert back to i16
        mixed.into_iter()
            .map(|s| s.clamp(i16::MIN as f32, i16::MAX as f32) as i16)
            .collect()
    }
}

impl Default for AudioMixer {
    fn default() -> Self {
        Self::new()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_audio_level_from_samples() {
        // Silent samples
        let silent = vec![0i16; 480];
        let level = AudioLevel::from_samples(&silent);
        assert!(level.level_dbfs < -90.0);
        assert!(!level.clipping);

        // Full volume samples
        let full = vec![i16::MAX; 480];
        let level = AudioLevel::from_samples(&full);
        assert!(level.level_dbfs > -1.0);
        assert!(level.clipping);
    }

    #[test]
    fn test_vad_state_transitions() {
        let mut vad = VoiceActivityDetector::with_defaults();

        // Silent frames
        for _ in 0..10 {
            let level = AudioLevel { level_dbfs: -60.0, ..Default::default() };
            vad.process(level);
        }
        assert_eq!(vad.state(), VoiceActivityState::Silent);

        // Speech frames
        for _ in 0..5 {
            let level = AudioLevel { level_dbfs: -20.0, ..Default::default() };
            vad.process(level);
        }
        assert_eq!(vad.state(), VoiceActivityState::Speaking);
    }

    #[test]
    fn test_active_speaker_detection() {
        let mut detector = ActiveSpeakerDetector::new();

        detector.register(1);
        detector.register(2);

        // Endpoint 1 speaks louder
        let level1 = AudioLevel { level_dbfs: -20.0, ..Default::default() };
        let level2 = AudioLevel { level_dbfs: -30.0, ..Default::default() };

        // Need multiple updates to confirm speech
        for _ in 0..5 {
            detector.update_level(1, level1);
            detector.update_level(2, level2);
        }

        // Wait for switch delay
        std::thread::sleep(Duration::from_millis(600));
        detector.update_level(1, level1);

        assert_eq!(detector.active_speaker(), Some(1));
    }

    #[test]
    fn test_audio_mixer() {
        let mut mixer = AudioMixer::new();

        mixer.set_gain(1, 0.5);
        mixer.set_gain(2, 0.5);

        let source1: Vec<i16> = vec![1000; 10];
        let source2: Vec<i16> = vec![1000; 10];

        let mut sources = HashMap::new();
        sources.insert(1, source1.as_slice());
        sources.insert(2, source2.as_slice());

        let mixed = mixer.mix(&sources);

        // Each source at 50% gain, summed should be ~1000
        assert!(mixed.iter().all(|&s| s > 900 && s < 1100));
    }

    #[test]
    fn test_audio_config_presets() {
        let meeting = AudioProcessingConfig::for_meeting();
        assert_eq!(meeting.noise_suppression, NoiseSuppressionLevel::Auto);

        let webinar = AudioProcessingConfig::for_webinar();
        assert_eq!(webinar.noise_suppression, NoiseSuppressionLevel::High);

        let music = AudioProcessingConfig::for_music();
        assert_eq!(music.noise_suppression, NoiseSuppressionLevel::Off);
    }
}
