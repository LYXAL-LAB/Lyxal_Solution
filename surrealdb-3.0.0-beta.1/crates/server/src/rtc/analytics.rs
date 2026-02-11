//! Analytics & Insights - Meeting Intelligence
//!
//! Real-time and post-meeting analytics like Microsoft Teams Insights,
//! Zoom Dashboard, and Google Meet attendance reports.
//!
//! ## Features (Enterprise Level)
//!
//! ```text
//! ┌─────────────────────────────────────────────────────────────────────────────┐
//! │                    MEETING ANALYTICS                                        │
//! │                                                                             │
//! │   ┌─────────────────────────────────────────────────────────────────────┐  │
//! │   │                    REAL-TIME METRICS                                 │  │
//! │   │                                                                      │  │
//! │   │  • Participant count over time                                      │  │
//! │   │  • Speaking time per participant                                    │  │
//! │   │  • Engagement score (camera on, reactions, chat)                   │  │
//! │   │  • Network quality indicators                                       │  │
//! │   │  • Audio/video issues detected                                      │  │
//! │   │                                                                      │  │
//! │   └─────────────────────────────────────────────────────────────────────┘  │
//! │                                                                             │
//! │   ┌─────────────────────────────────────────────────────────────────────┐  │
//! │   │                    POST-MEETING INSIGHTS                             │  │
//! │   │                                                                      │  │
//! │   │  • Attendance report with join/leave times                         │  │
//! │   │  • Participation breakdown (who spoke, how much)                   │  │
//! │   │  • Attention metrics (multitasking detection)                      │  │
//! │   │  • Meeting effectiveness score                                      │  │
//! │   │  • Comparison with previous meetings                               │  │
//! │   │                                                                      │  │
//! │   └─────────────────────────────────────────────────────────────────────┘  │
//! │                                                                             │
//! └─────────────────────────────────────────────────────────────────────────────┘
//! ```

use std::collections::HashMap;
use std::time::{Duration, Instant};

use serde::{Deserialize, Serialize};

/// Participant analytics
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ParticipantAnalytics {
    /// Endpoint ID
    pub endpoint_id: u64,
    /// Display name
    pub name: Option<String>,
    /// Join time (offset from meeting start)
    pub join_time: Duration,
    /// Leave time (None if still in meeting)
    pub leave_time: Option<Duration>,
    /// Total time in meeting
    pub total_time: Duration,
    /// Speaking time
    pub speaking_time: Duration,
    /// Speaking percentage
    pub speaking_percent: f32,
    /// Camera on time
    pub camera_on_time: Duration,
    /// Camera on percentage
    pub camera_on_percent: f32,
    /// Screen share time
    pub screen_share_time: Duration,
    /// Reactions sent
    pub reactions_sent: u32,
    /// Messages sent
    pub messages_sent: u32,
    /// Questions asked
    pub questions_asked: u32,
    /// Polls answered
    pub polls_answered: u32,
    /// Network quality scores (over time)
    pub quality_scores: Vec<QualitySnapshot>,
    /// Engagement score (0-100)
    pub engagement_score: u32,
}

impl ParticipantAnalytics {
    pub fn new(endpoint_id: u64) -> Self {
        Self {
            endpoint_id,
            name: None,
            join_time: Duration::ZERO,
            leave_time: None,
            total_time: Duration::ZERO,
            speaking_time: Duration::ZERO,
            speaking_percent: 0.0,
            camera_on_time: Duration::ZERO,
            camera_on_percent: 0.0,
            screen_share_time: Duration::ZERO,
            reactions_sent: 0,
            messages_sent: 0,
            questions_asked: 0,
            polls_answered: 0,
            quality_scores: Vec::new(),
            engagement_score: 0,
        }
    }

    /// Calculate engagement score
    pub fn calculate_engagement(&mut self) {
        let mut score = 0u32;

        // Speaking participation (up to 30 points)
        score += (self.speaking_percent * 30.0).min(30.0) as u32;

        // Camera usage (up to 20 points)
        score += (self.camera_on_percent * 20.0).min(20.0) as u32;

        // Reactions (up to 15 points)
        score += (self.reactions_sent as u32 * 3).min(15);

        // Messages (up to 15 points)
        score += (self.messages_sent as u32 * 2).min(15);

        // Questions (up to 10 points)
        score += (self.questions_asked as u32 * 5).min(10);

        // Polls (up to 10 points)
        score += (self.polls_answered as u32 * 5).min(10);

        self.engagement_score = score.min(100);
    }
}

/// Network quality snapshot
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct QualitySnapshot {
    /// Timestamp (offset from meeting start)
    pub timestamp: Duration,
    /// Overall quality (1-5)
    pub quality: u8,
    /// Packet loss percentage
    pub packet_loss: f32,
    /// RTT in ms
    pub rtt_ms: u32,
    /// Jitter in ms
    pub jitter_ms: u32,
    /// Bitrate in kbps
    pub bitrate_kbps: u32,
}

/// Meeting analytics
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MeetingAnalytics {
    /// Session ID
    pub session_id: u64,
    /// Meeting title
    pub title: Option<String>,
    /// Scheduled start
    pub scheduled_start: Option<u64>,
    /// Actual start (Unix timestamp)
    pub started_at: u64,
    /// End time (Unix timestamp)
    pub ended_at: Option<u64>,
    /// Duration
    pub duration: Duration,
    /// Total participants
    pub total_participants: usize,
    /// Peak participants
    pub peak_participants: usize,
    /// Unique participants
    pub unique_participants: usize,
    /// Participant analytics
    pub participants: Vec<ParticipantAnalytics>,
    /// Total speaking time (all participants)
    pub total_speaking_time: Duration,
    /// Average engagement score
    pub avg_engagement_score: f32,
    /// Meeting effectiveness score (0-100)
    pub effectiveness_score: u32,
    /// Timeline events
    pub timeline: Vec<TimelineEvent>,
    /// Quality summary
    pub quality_summary: QualitySummary,
}

/// Timeline event
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TimelineEvent {
    /// Event type
    pub event_type: TimelineEventType,
    /// Timestamp (offset from start)
    pub timestamp: Duration,
    /// Participant (if applicable)
    pub participant_id: Option<u64>,
    /// Description
    pub description: String,
}

/// Timeline event types
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum TimelineEventType {
    MeetingStarted,
    MeetingEnded,
    ParticipantJoined,
    ParticipantLeft,
    ScreenShareStarted,
    ScreenShareEnded,
    RecordingStarted,
    RecordingEnded,
    BreakoutStarted,
    BreakoutEnded,
    PollCreated,
    ReactionPeak,
    QualityDrop,
    HostChanged,
}

/// Quality summary
#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct QualitySummary {
    /// Average quality (1-5)
    pub avg_quality: f32,
    /// Time with good quality (%)
    pub good_quality_percent: f32,
    /// Time with poor quality (%)
    pub poor_quality_percent: f32,
    /// Participants with issues
    pub participants_with_issues: usize,
    /// Most common issue
    pub most_common_issue: Option<String>,
}

/// Analytics collector
pub struct AnalyticsCollector {
    /// Session ID
    session_id: u64,
    /// Started at
    started_at: Instant,
    /// Participants
    participants: HashMap<u64, ParticipantState>,
    /// Timeline events
    timeline: Vec<TimelineEvent>,
    /// Current participant count
    current_count: usize,
    /// Peak participant count
    peak_count: usize,
}

/// Internal participant state for tracking
struct ParticipantState {
    analytics: ParticipantAnalytics,
    is_speaking: bool,
    speaking_start: Option<Instant>,
    camera_on: bool,
    camera_on_start: Option<Instant>,
    screen_sharing: bool,
    screen_share_start: Option<Instant>,
}

impl AnalyticsCollector {
    pub fn new(session_id: u64) -> Self {
        Self {
            session_id,
            started_at: Instant::now(),
            participants: HashMap::new(),
            timeline: vec![TimelineEvent {
                event_type: TimelineEventType::MeetingStarted,
                timestamp: Duration::ZERO,
                participant_id: None,
                description: "Meeting started".to_string(),
            }],
            current_count: 0,
            peak_count: 0,
        }
    }

    /// Record participant join
    pub fn on_join(&mut self, endpoint_id: u64, name: Option<String>) {
        let elapsed = self.started_at.elapsed();

        let mut analytics = ParticipantAnalytics::new(endpoint_id);
        analytics.name = name.clone();
        analytics.join_time = elapsed;

        let state = ParticipantState {
            analytics,
            is_speaking: false,
            speaking_start: None,
            camera_on: false,
            camera_on_start: None,
            screen_sharing: false,
            screen_share_start: None,
        };

        self.participants.insert(endpoint_id, state);
        self.current_count += 1;
        self.peak_count = self.peak_count.max(self.current_count);

        self.timeline.push(TimelineEvent {
            event_type: TimelineEventType::ParticipantJoined,
            timestamp: elapsed,
            participant_id: Some(endpoint_id),
            description: format!("{} joined", name.unwrap_or_else(|| "Participant".to_string())),
        });
    }

    /// Record participant leave
    pub fn on_leave(&mut self, endpoint_id: u64) {
        let elapsed = self.started_at.elapsed();

        if let Some(state) = self.participants.get_mut(&endpoint_id) {
            state.analytics.leave_time = Some(elapsed);
            state.analytics.total_time = elapsed - state.analytics.join_time;

            // Finalize any ongoing activities
            if state.is_speaking {
                if let Some(start) = state.speaking_start {
                    state.analytics.speaking_time += start.elapsed();
                }
            }
            if state.camera_on {
                if let Some(start) = state.camera_on_start {
                    state.analytics.camera_on_time += start.elapsed();
                }
            }

            self.current_count = self.current_count.saturating_sub(1);

            self.timeline.push(TimelineEvent {
                event_type: TimelineEventType::ParticipantLeft,
                timestamp: elapsed,
                participant_id: Some(endpoint_id),
                description: format!(
                    "{} left",
                    state.analytics.name.clone().unwrap_or_else(|| "Participant".to_string())
                ),
            });
        }
    }

    /// Record speaking start
    pub fn on_speaking_start(&mut self, endpoint_id: u64) {
        if let Some(state) = self.participants.get_mut(&endpoint_id) {
            state.is_speaking = true;
            state.speaking_start = Some(Instant::now());
        }
    }

    /// Record speaking stop
    pub fn on_speaking_stop(&mut self, endpoint_id: u64) {
        if let Some(state) = self.participants.get_mut(&endpoint_id) {
            if state.is_speaking {
                if let Some(start) = state.speaking_start {
                    state.analytics.speaking_time += start.elapsed();
                }
                state.is_speaking = false;
                state.speaking_start = None;
            }
        }
    }

    /// Record camera toggle
    pub fn on_camera_toggle(&mut self, endpoint_id: u64, on: bool) {
        if let Some(state) = self.participants.get_mut(&endpoint_id) {
            if on && !state.camera_on {
                state.camera_on = true;
                state.camera_on_start = Some(Instant::now());
            } else if !on && state.camera_on {
                if let Some(start) = state.camera_on_start {
                    state.analytics.camera_on_time += start.elapsed();
                }
                state.camera_on = false;
                state.camera_on_start = None;
            }
        }
    }

    /// Record reaction
    pub fn on_reaction(&mut self, endpoint_id: u64) {
        if let Some(state) = self.participants.get_mut(&endpoint_id) {
            state.analytics.reactions_sent += 1;
        }
    }

    /// Record message
    pub fn on_message(&mut self, endpoint_id: u64) {
        if let Some(state) = self.participants.get_mut(&endpoint_id) {
            state.analytics.messages_sent += 1;
        }
    }

    /// Record quality snapshot
    pub fn on_quality_update(&mut self, endpoint_id: u64, snapshot: QualitySnapshot) {
        if let Some(state) = self.participants.get_mut(&endpoint_id) {
            state.analytics.quality_scores.push(snapshot);
        }
    }

    /// Finalize and generate report
    pub fn finalize(&mut self) -> MeetingAnalytics {
        let elapsed = self.started_at.elapsed();

        self.timeline.push(TimelineEvent {
            event_type: TimelineEventType::MeetingEnded,
            timestamp: elapsed,
            participant_id: None,
            description: "Meeting ended".to_string(),
        });

        // Calculate percentages and scores
        let mut participants: Vec<ParticipantAnalytics> = Vec::new();
        let mut total_speaking = Duration::ZERO;
        let mut total_engagement = 0u32;

        for (_, state) in self.participants.iter_mut() {
            let analytics = &mut state.analytics;

            // Calculate percentages
            if analytics.total_time > Duration::ZERO {
                analytics.speaking_percent = 
                    analytics.speaking_time.as_secs_f32() / analytics.total_time.as_secs_f32() * 100.0;
                analytics.camera_on_percent = 
                    analytics.camera_on_time.as_secs_f32() / analytics.total_time.as_secs_f32() * 100.0;
            }

            analytics.calculate_engagement();
            total_speaking += analytics.speaking_time;
            total_engagement += analytics.engagement_score;

            participants.push(analytics.clone());
        }

        let avg_engagement = if !participants.is_empty() {
            total_engagement as f32 / participants.len() as f32
        } else {
            0.0
        };

        MeetingAnalytics {
            session_id: self.session_id,
            title: None,
            scheduled_start: None,
            started_at: std::time::SystemTime::now()
                .duration_since(std::time::UNIX_EPOCH)
                .unwrap()
                .as_secs() - elapsed.as_secs(),
            ended_at: Some(
                std::time::SystemTime::now()
                    .duration_since(std::time::UNIX_EPOCH)
                    .unwrap()
                    .as_secs(),
            ),
            duration: elapsed,
            total_participants: self.participants.len(),
            peak_participants: self.peak_count,
            unique_participants: self.participants.len(),
            participants,
            total_speaking_time: total_speaking,
            avg_engagement_score: avg_engagement,
            effectiveness_score: (avg_engagement * 0.8) as u32 + 20, // Simplified
            timeline: self.timeline.clone(),
            quality_summary: QualitySummary::default(),
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_participant_analytics() {
        let mut analytics = ParticipantAnalytics::new(1);
        analytics.speaking_percent = 50.0;
        analytics.camera_on_percent = 100.0;
        analytics.reactions_sent = 5;
        analytics.messages_sent = 3;

        analytics.calculate_engagement();
        assert!(analytics.engagement_score > 50);
    }

    #[test]
    fn test_analytics_collector() {
        let mut collector = AnalyticsCollector::new(100);

        collector.on_join(1, Some("Alice".to_string()));
        collector.on_join(2, Some("Bob".to_string()));

        assert_eq!(collector.current_count, 2);
        assert_eq!(collector.peak_count, 2);

        collector.on_speaking_start(1);
        std::thread::sleep(Duration::from_millis(10));
        collector.on_speaking_stop(1);

        collector.on_reaction(1);
        collector.on_message(2);

        collector.on_leave(2);
        assert_eq!(collector.current_count, 1);

        let report = collector.finalize();
        assert_eq!(report.peak_participants, 2);
        assert!(!report.timeline.is_empty());
    }
}
