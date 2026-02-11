//! Interactive Features - Polls, Q&A, Reactions, Chat
//!
//! Real-time interactive features like Zoom Polls, Slido Q&A,
//! Microsoft Teams reactions, and meeting chat.
//!
//! ## Features
//!
//! ```text
//! ┌─────────────────────────────────────────────────────────────────────────────┐
//! │                    INTERACTIVE FEATURES                                     │
//! │                                                                             │
//! │   ┌───────────────┐  ┌───────────────┐  ┌───────────────┐  ┌─────────────┐│
//! │   │     POLLS     │  │     Q&A       │  │   REACTIONS   │  │    CHAT     ││
//! │   │               │  │               │  │               │  │             ││
//! │   │ • Create poll │  │ • Ask question│  │ 👍 👎 ❤️ 😂    │  │ • Messages  ││
//! │   │ • Vote        │  │ • Upvote      │  │ 🎉 👏 🤔 😮    │  │ • Threads   ││
//! │   │ • Results     │  │ • Answer      │  │               │  │ • Files     ││
//! │   │ • Analytics   │  │ • Dismiss     │  │ • Floating    │  │ • Mentions  ││
//! │   │               │  │               │  │ • Aggregated  │  │             ││
//! │   └───────────────┘  └───────────────┘  └───────────────┘  └─────────────┘│
//! │                                                                             │
//! └─────────────────────────────────────────────────────────────────────────────┘
//! ```

use std::collections::{HashMap, HashSet};
use std::time::{Duration, Instant};

use serde::{Deserialize, Serialize};

// ============================================================================
// REACTIONS
// ============================================================================

/// Reaction type
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub enum ReactionType {
    ThumbsUp,
    ThumbsDown,
    Heart,
    Laugh,
    Celebrate,
    Clap,
    Thinking,
    Surprised,
    Sad,
    Angry,
    RaiseHand,
    SlowDown,
    SpeedUp,
    Yes,
    No,
}

impl ReactionType {
    pub fn emoji(&self) -> &'static str {
        match self {
            ReactionType::ThumbsUp => "👍",
            ReactionType::ThumbsDown => "👎",
            ReactionType::Heart => "❤️",
            ReactionType::Laugh => "😂",
            ReactionType::Celebrate => "🎉",
            ReactionType::Clap => "👏",
            ReactionType::Thinking => "🤔",
            ReactionType::Surprised => "😮",
            ReactionType::Sad => "😢",
            ReactionType::Angry => "😠",
            ReactionType::RaiseHand => "✋",
            ReactionType::SlowDown => "🐢",
            ReactionType::SpeedUp => "🐇",
            ReactionType::Yes => "✅",
            ReactionType::No => "❌",
        }
    }
}

/// A reaction instance
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Reaction {
    /// Reaction type
    pub reaction_type: ReactionType,
    /// Sender endpoint ID
    pub sender_id: u64,
    /// Sender name
    pub sender_name: Option<String>,
    /// Timestamp
    pub timestamp: u64,
}

/// Reaction manager
pub struct ReactionManager {
    /// Session ID
    session_id: u64,
    /// Recent reactions (for display)
    recent_reactions: Vec<Reaction>,
    /// Reaction counts (for aggregation)
    reaction_counts: HashMap<ReactionType, u32>,
    /// Raised hands (ordered)
    raised_hands: Vec<(u64, Instant)>,
    /// Max recent reactions to keep
    max_recent: usize,
}

impl ReactionManager {
    pub fn new(session_id: u64) -> Self {
        Self {
            session_id,
            recent_reactions: Vec::new(),
            reaction_counts: HashMap::new(),
            raised_hands: Vec::new(),
            max_recent: 50,
        }
    }

    /// Add a reaction
    pub fn add_reaction(&mut self, reaction: Reaction) -> &Reaction {
        // Update counts
        *self.reaction_counts.entry(reaction.reaction_type).or_insert(0) += 1;

        // Handle raise hand specially
        if reaction.reaction_type == ReactionType::RaiseHand {
            if !self.raised_hands.iter().any(|(id, _)| *id == reaction.sender_id) {
                self.raised_hands.push((reaction.sender_id, Instant::now()));
            }
        }

        // Add to recent
        self.recent_reactions.push(reaction);
        if self.recent_reactions.len() > self.max_recent {
            self.recent_reactions.remove(0);
        }

        self.recent_reactions.last().unwrap()
    }

    /// Lower hand
    pub fn lower_hand(&mut self, endpoint_id: u64) {
        self.raised_hands.retain(|(id, _)| *id != endpoint_id);
    }

    /// Get raised hands (in order)
    pub fn get_raised_hands(&self) -> Vec<u64> {
        self.raised_hands.iter().map(|(id, _)| *id).collect()
    }

    /// Get recent reactions
    pub fn get_recent(&self, count: usize) -> Vec<&Reaction> {
        self.recent_reactions.iter().rev().take(count).collect()
    }

    /// Get reaction counts
    pub fn get_counts(&self) -> &HashMap<ReactionType, u32> {
        &self.reaction_counts
    }

    /// Clear reactions (for next segment)
    pub fn clear_counts(&mut self) {
        self.reaction_counts.clear();
    }
}

// ============================================================================
// POLLS
// ============================================================================

/// Poll type
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum PollType {
    /// Single choice
    SingleChoice,
    /// Multiple choice
    MultipleChoice,
    /// Rating (1-5 or 1-10)
    Rating,
    /// Open ended (text)
    OpenEnded,
    /// Word cloud
    WordCloud,
    /// Quiz (with correct answer)
    Quiz,
}

/// Poll status
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum PollStatus {
    Draft,
    Active,
    Closed,
    ResultsShared,
}

/// Poll option
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PollOption {
    /// Option ID
    pub id: u32,
    /// Option text
    pub text: String,
    /// Is correct (for quiz)
    pub is_correct: bool,
    /// Vote count
    pub votes: u32,
    /// Percentage
    pub percentage: f32,
}

/// A poll
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Poll {
    /// Poll ID
    pub id: u64,
    /// Session ID
    pub session_id: u64,
    /// Question
    pub question: String,
    /// Poll type
    pub poll_type: PollType,
    /// Options
    pub options: Vec<PollOption>,
    /// Status
    pub status: PollStatus,
    /// Creator endpoint ID
    pub creator_id: u64,
    /// Created at
    pub created_at: u64,
    /// Closed at
    pub closed_at: Option<u64>,
    /// Anonymous voting
    pub anonymous: bool,
    /// Allow change vote
    pub allow_change: bool,
    /// Show results during voting
    pub show_live_results: bool,
    /// Voters (endpoint_id -> option_ids)
    pub voters: HashMap<u64, Vec<u32>>,
    /// Total votes
    pub total_votes: u32,
}

impl Poll {
    pub fn new(
        id: u64,
        session_id: u64,
        creator_id: u64,
        question: String,
        poll_type: PollType,
        options: Vec<String>,
    ) -> Self {
        let options = options
            .into_iter()
            .enumerate()
            .map(|(i, text)| PollOption {
                id: i as u32,
                text,
                is_correct: false,
                votes: 0,
                percentage: 0.0,
            })
            .collect();

        Self {
            id,
            session_id,
            creator_id,
            question,
            poll_type,
            options,
            status: PollStatus::Draft,
            created_at: std::time::SystemTime::now()
                .duration_since(std::time::UNIX_EPOCH)
                .unwrap()
                .as_secs(),
            closed_at: None,
            anonymous: false,
            allow_change: false,
            show_live_results: false,
            voters: HashMap::new(),
            total_votes: 0,
        }
    }

    /// Launch the poll
    pub fn launch(&mut self) {
        self.status = PollStatus::Active;
    }

    /// Vote
    pub fn vote(&mut self, endpoint_id: u64, option_ids: Vec<u32>) -> Result<(), PollError> {
        if self.status != PollStatus::Active {
            return Err(PollError::NotActive);
        }

        // Check if already voted
        if self.voters.contains_key(&endpoint_id) && !self.allow_change {
            return Err(PollError::AlreadyVoted);
        }

        // Validate options
        for &opt_id in &option_ids {
            if !self.options.iter().any(|o| o.id == opt_id) {
                return Err(PollError::InvalidOption);
            }
        }

        // For single choice, only one option
        if self.poll_type == PollType::SingleChoice && option_ids.len() > 1 {
            return Err(PollError::TooManySelections);
        }

        // Remove previous vote if changing
        if let Some(previous) = self.voters.remove(&endpoint_id) {
            for opt_id in previous {
                if let Some(opt) = self.options.iter_mut().find(|o| o.id == opt_id) {
                    opt.votes = opt.votes.saturating_sub(1);
                }
            }
            self.total_votes = self.total_votes.saturating_sub(1);
        }

        // Add new vote
        for &opt_id in &option_ids {
            if let Some(opt) = self.options.iter_mut().find(|o| o.id == opt_id) {
                opt.votes += 1;
            }
        }
        self.voters.insert(endpoint_id, option_ids);
        self.total_votes += 1;

        // Recalculate percentages
        self.recalculate_percentages();

        Ok(())
    }

    /// Close poll
    pub fn close(&mut self) {
        self.status = PollStatus::Closed;
        self.closed_at = Some(
            std::time::SystemTime::now()
                .duration_since(std::time::UNIX_EPOCH)
                .unwrap()
                .as_secs(),
        );
    }

    /// Share results
    pub fn share_results(&mut self) {
        self.status = PollStatus::ResultsShared;
    }

    fn recalculate_percentages(&mut self) {
        let total = self.options.iter().map(|o| o.votes).sum::<u32>() as f32;
        for opt in &mut self.options {
            opt.percentage = if total > 0.0 {
                (opt.votes as f32 / total) * 100.0
            } else {
                0.0
            };
        }
    }
}

/// Poll error
#[derive(Debug, Clone)]
pub enum PollError {
    NotFound,
    NotActive,
    AlreadyVoted,
    InvalidOption,
    TooManySelections,
    NotCreator,
}

// ============================================================================
// Q&A
// ============================================================================

/// Question status
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum QuestionStatus {
    Open,
    Answered,
    Dismissed,
    Highlighted,
}

/// A question
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Question {
    /// Question ID
    pub id: u64,
    /// Session ID
    pub session_id: u64,
    /// Question text
    pub text: String,
    /// Asker endpoint ID
    pub asker_id: u64,
    /// Asker name
    pub asker_name: Option<String>,
    /// Anonymous
    pub anonymous: bool,
    /// Status
    pub status: QuestionStatus,
    /// Upvotes
    pub upvotes: u32,
    /// Upvoters
    pub upvoters: HashSet<u64>,
    /// Answer
    pub answer: Option<String>,
    /// Answered by
    pub answered_by: Option<u64>,
    /// Created at
    pub created_at: u64,
    /// Answered at
    pub answered_at: Option<u64>,
}

impl Question {
    pub fn new(
        id: u64,
        session_id: u64,
        asker_id: u64,
        asker_name: Option<String>,
        text: String,
        anonymous: bool,
    ) -> Self {
        Self {
            id,
            session_id,
            text,
            asker_id,
            asker_name,
            anonymous,
            status: QuestionStatus::Open,
            upvotes: 0,
            upvoters: HashSet::new(),
            answer: None,
            answered_by: None,
            created_at: std::time::SystemTime::now()
                .duration_since(std::time::UNIX_EPOCH)
                .unwrap()
                .as_secs(),
            answered_at: None,
        }
    }

    /// Upvote the question
    pub fn upvote(&mut self, voter_id: u64) -> bool {
        if self.upvoters.insert(voter_id) {
            self.upvotes += 1;
            true
        } else {
            false
        }
    }

    /// Remove upvote
    pub fn remove_upvote(&mut self, voter_id: u64) -> bool {
        if self.upvoters.remove(&voter_id) {
            self.upvotes = self.upvotes.saturating_sub(1);
            true
        } else {
            false
        }
    }

    /// Answer the question
    pub fn answer(&mut self, answer: String, answered_by: u64) {
        self.answer = Some(answer);
        self.answered_by = Some(answered_by);
        self.status = QuestionStatus::Answered;
        self.answered_at = Some(
            std::time::SystemTime::now()
                .duration_since(std::time::UNIX_EPOCH)
                .unwrap()
                .as_secs(),
        );
    }

    /// Dismiss the question
    pub fn dismiss(&mut self) {
        self.status = QuestionStatus::Dismissed;
    }

    /// Highlight the question
    pub fn highlight(&mut self) {
        self.status = QuestionStatus::Highlighted;
    }
}

/// Q&A manager
pub struct QaManager {
    /// Session ID
    session_id: u64,
    /// Questions
    questions: HashMap<u64, Question>,
    /// Question counter
    question_counter: u64,
    /// Q&A enabled
    enabled: bool,
    /// Allow anonymous questions
    allow_anonymous: bool,
    /// Moderation required
    moderation_required: bool,
}

impl QaManager {
    pub fn new(session_id: u64) -> Self {
        Self {
            session_id,
            questions: HashMap::new(),
            question_counter: 0,
            enabled: true,
            allow_anonymous: true,
            moderation_required: false,
        }
    }

    /// Ask a question
    pub fn ask(
        &mut self,
        asker_id: u64,
        asker_name: Option<String>,
        text: String,
        anonymous: bool,
    ) -> &Question {
        self.question_counter += 1;
        let question = Question::new(
            self.question_counter,
            self.session_id,
            asker_id,
            asker_name,
            text,
            anonymous && self.allow_anonymous,
        );
        self.questions.insert(self.question_counter, question);
        self.questions.get(&self.question_counter).unwrap()
    }

    /// Get question
    pub fn get(&self, question_id: u64) -> Option<&Question> {
        self.questions.get(&question_id)
    }

    /// Get mutable question
    pub fn get_mut(&mut self, question_id: u64) -> Option<&mut Question> {
        self.questions.get_mut(&question_id)
    }

    /// Get all open questions sorted by upvotes
    pub fn get_open_sorted(&self) -> Vec<&Question> {
        let mut questions: Vec<_> = self.questions
            .values()
            .filter(|q| q.status == QuestionStatus::Open || q.status == QuestionStatus::Highlighted)
            .collect();
        questions.sort_by(|a, b| b.upvotes.cmp(&a.upvotes));
        questions
    }

    /// Get answered questions
    pub fn get_answered(&self) -> Vec<&Question> {
        self.questions
            .values()
            .filter(|q| q.status == QuestionStatus::Answered)
            .collect()
    }
}

// ============================================================================
// CHAT
// ============================================================================

/// Chat message
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ChatMessage {
    /// Message ID
    pub id: u64,
    /// Session ID
    pub session_id: u64,
    /// Sender endpoint ID
    pub sender_id: u64,
    /// Sender name
    pub sender_name: Option<String>,
    /// Message text
    pub text: String,
    /// Reply to message ID
    pub reply_to: Option<u64>,
    /// Mentions (endpoint IDs)
    pub mentions: Vec<u64>,
    /// Is private (to specific recipient)
    pub is_private: bool,
    /// Private recipient
    pub recipient_id: Option<u64>,
    /// Timestamp
    pub timestamp: u64,
    /// Edited
    pub edited: bool,
    /// Deleted
    pub deleted: bool,
    /// Reactions
    pub reactions: HashMap<ReactionType, Vec<u64>>,
}

impl ChatMessage {
    pub fn new(
        id: u64,
        session_id: u64,
        sender_id: u64,
        sender_name: Option<String>,
        text: String,
    ) -> Self {
        Self {
            id,
            session_id,
            sender_id,
            sender_name,
            text,
            reply_to: None,
            mentions: Vec::new(),
            is_private: false,
            recipient_id: None,
            timestamp: std::time::SystemTime::now()
                .duration_since(std::time::UNIX_EPOCH)
                .unwrap()
                .as_secs(),
            edited: false,
            deleted: false,
            reactions: HashMap::new(),
        }
    }

    /// Add reaction to message
    pub fn add_reaction(&mut self, reaction: ReactionType, user_id: u64) {
        self.reactions
            .entry(reaction)
            .or_default()
            .push(user_id);
    }

    /// Remove reaction from message
    pub fn remove_reaction(&mut self, reaction: ReactionType, user_id: u64) {
        if let Some(users) = self.reactions.get_mut(&reaction) {
            users.retain(|&id| id != user_id);
        }
    }
}

/// Chat manager
pub struct ChatManager {
    /// Session ID
    session_id: u64,
    /// Messages
    messages: Vec<ChatMessage>,
    /// Message counter
    message_counter: u64,
    /// Chat enabled
    enabled: bool,
    /// Only hosts can chat
    hosts_only: bool,
    /// Private chat enabled
    private_chat_enabled: bool,
}

impl ChatManager {
    pub fn new(session_id: u64) -> Self {
        Self {
            session_id,
            messages: Vec::new(),
            message_counter: 0,
            enabled: true,
            hosts_only: false,
            private_chat_enabled: true,
        }
    }

    /// Send a message
    pub fn send(
        &mut self,
        sender_id: u64,
        sender_name: Option<String>,
        text: String,
    ) -> &ChatMessage {
        self.message_counter += 1;
        let message = ChatMessage::new(
            self.message_counter,
            self.session_id,
            sender_id,
            sender_name,
            text,
        );
        self.messages.push(message);
        self.messages.last().unwrap()
    }

    /// Send private message
    pub fn send_private(
        &mut self,
        sender_id: u64,
        sender_name: Option<String>,
        recipient_id: u64,
        text: String,
    ) -> &ChatMessage {
        self.message_counter += 1;
        let mut message = ChatMessage::new(
            self.message_counter,
            self.session_id,
            sender_id,
            sender_name,
            text,
        );
        message.is_private = true;
        message.recipient_id = Some(recipient_id);
        self.messages.push(message);
        self.messages.last().unwrap()
    }

    /// Get recent messages
    pub fn get_recent(&self, count: usize) -> Vec<&ChatMessage> {
        self.messages
            .iter()
            .filter(|m| !m.deleted && !m.is_private)
            .rev()
            .take(count)
            .collect()
    }

    /// Get private messages between two users
    pub fn get_private(&self, user1: u64, user2: u64) -> Vec<&ChatMessage> {
        self.messages
            .iter()
            .filter(|m| {
                m.is_private
                    && !m.deleted
                    && ((m.sender_id == user1 && m.recipient_id == Some(user2))
                        || (m.sender_id == user2 && m.recipient_id == Some(user1)))
            })
            .collect()
    }

    /// Delete message
    pub fn delete(&mut self, message_id: u64, by_user: u64) -> bool {
        if let Some(msg) = self.messages.iter_mut().find(|m| m.id == message_id) {
            if msg.sender_id == by_user {
                msg.deleted = true;
                msg.text = "[Message deleted]".to_string();
                return true;
            }
        }
        false
    }

    /// Get message count
    pub fn message_count(&self) -> usize {
        self.messages.iter().filter(|m| !m.deleted).count()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_reactions() {
        let mut manager = ReactionManager::new(100);

        let reaction = Reaction {
            reaction_type: ReactionType::ThumbsUp,
            sender_id: 1,
            sender_name: Some("Alice".to_string()),
            timestamp: 0,
        };

        manager.add_reaction(reaction);
        assert_eq!(manager.get_counts().get(&ReactionType::ThumbsUp), Some(&1));
    }

    #[test]
    fn test_raised_hands() {
        let mut manager = ReactionManager::new(100);

        let reaction = Reaction {
            reaction_type: ReactionType::RaiseHand,
            sender_id: 1,
            sender_name: None,
            timestamp: 0,
        };

        manager.add_reaction(reaction);
        assert_eq!(manager.get_raised_hands(), vec![1]);

        manager.lower_hand(1);
        assert!(manager.get_raised_hands().is_empty());
    }

    #[test]
    fn test_poll_voting() {
        let mut poll = Poll::new(
            1, 100, 1,
            "Favorite color?".to_string(),
            PollType::SingleChoice,
            vec!["Red".to_string(), "Blue".to_string(), "Green".to_string()],
        );

        poll.launch();
        
        poll.vote(2, vec![0]).unwrap();
        poll.vote(3, vec![1]).unwrap();
        poll.vote(4, vec![0]).unwrap();

        assert_eq!(poll.total_votes, 3);
        assert_eq!(poll.options[0].votes, 2);
        assert_eq!(poll.options[1].votes, 1);
    }

    #[test]
    fn test_qa() {
        let mut qa = QaManager::new(100);

        qa.ask(1, Some("Alice".to_string()), "What is the plan?".to_string(), false);
        qa.ask(2, Some("Bob".to_string()), "When is the deadline?".to_string(), false);

        qa.get_mut(1).unwrap().upvote(3);
        qa.get_mut(1).unwrap().upvote(4);

        let sorted = qa.get_open_sorted();
        assert_eq!(sorted[0].id, 1); // Most upvoted first
    }

    #[test]
    fn test_chat() {
        let mut chat = ChatManager::new(100);

        chat.send(1, Some("Alice".to_string()), "Hello everyone!".to_string());
        chat.send(2, Some("Bob".to_string()), "Hi Alice!".to_string());
        chat.send_private(1, Some("Alice".to_string()), 2, "Private message".to_string());

        assert_eq!(chat.get_recent(10).len(), 2); // Excludes private
        assert_eq!(chat.get_private(1, 2).len(), 1);
    }
}
