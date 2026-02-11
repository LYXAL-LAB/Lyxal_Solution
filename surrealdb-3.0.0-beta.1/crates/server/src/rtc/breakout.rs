//! Breakout Rooms - Sub-sessions for meetings
//!
//! This module provides breakout room functionality like Zoom,
//! allowing hosts to split participants into smaller groups.
//!
//! ## Architecture (like Zoom Breakout Rooms)
//!
//! ```text
//! ┌─────────────────────────────────────────────────────────────────┐
//! │                    BREAKOUT ROOMS                               │
//! │                                                                 │
//! │   ┌─────────────────────────────────────────────────────────┐  │
//! │   │                    MAIN SESSION                          │  │
//! │   │                                                          │  │
//! │   │    Host can see all rooms, broadcast to all             │  │
//! │   │                                                          │  │
//! │   └─────────────────────────────────────────────────────────┘  │
//! │                            │                                    │
//! │         ┌──────────────────┼──────────────────┐                │
//! │         │                  │                  │                │
//! │         ▼                  ▼                  ▼                │
//! │   ┌──────────┐      ┌──────────┐      ┌──────────┐            │
//! │   │  Room 1  │      │  Room 2  │      │  Room 3  │            │
//! │   │          │      │          │      │          │            │
//! │   │ Alice    │      │ Charlie  │      │ Eve      │            │
//! │   │ Bob      │      │ David    │      │ Frank    │            │
//! │   └──────────┘      └──────────┘      └──────────┘            │
//! │                                                                 │
//! │   Features:                                                    │
//! │   • Auto-assign or manual assignment                          │
//! │   • Timer with auto-return                                    │
//! │   • Host can visit/broadcast                                  │
//! │   • Participants can ask for help                             │
//! │                                                                 │
//! └─────────────────────────────────────────────────────────────────┘
//! ```

use std::collections::{HashMap, HashSet};
use std::time::{Duration, Instant};

use serde::{Deserialize, Serialize};

/// Breakout room
#[derive(Debug, Clone)]
pub struct BreakoutRoom {
    /// Room ID
    pub id: u64,
    /// Room name
    pub name: String,
    /// Participants in this room
    pub participants: HashSet<u64>,
    /// Max participants (0 = unlimited)
    pub max_participants: usize,
    /// Room is open for joining
    pub open: bool,
    /// Created at
    pub created_at: Instant,
}

impl BreakoutRoom {
    pub fn new(id: u64, name: &str) -> Self {
        Self {
            id,
            name: name.to_string(),
            participants: HashSet::new(),
            max_participants: 0,
            open: true,
            created_at: Instant::now(),
        }
    }

    pub fn add_participant(&mut self, endpoint_id: u64) -> bool {
        if !self.open {
            return false;
        }
        if self.max_participants > 0 && self.participants.len() >= self.max_participants {
            return false;
        }
        self.participants.insert(endpoint_id)
    }

    pub fn remove_participant(&mut self, endpoint_id: u64) -> bool {
        self.participants.remove(&endpoint_id)
    }

    pub fn participant_count(&self) -> usize {
        self.participants.len()
    }
}

/// Breakout room assignment mode
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum AssignmentMode {
    /// Host manually assigns participants
    Manual,
    /// Automatically distribute evenly
    Automatic,
    /// Participants choose their own room
    SelfSelect,
}

impl Default for AssignmentMode {
    fn default() -> Self {
        Self::Manual
    }
}

/// Breakout session configuration
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct BreakoutConfig {
    /// Assignment mode
    pub assignment_mode: AssignmentMode,
    /// Allow participants to return to main room
    pub allow_return_to_main: bool,
    /// Timer duration (None = no timer)
    pub timer_duration: Option<Duration>,
    /// Countdown before closing (seconds)
    pub countdown_seconds: u32,
    /// Auto-close when timer expires
    pub auto_close: bool,
    /// Allow participants to switch rooms
    pub allow_room_switch: bool,
}

impl Default for BreakoutConfig {
    fn default() -> Self {
        Self {
            assignment_mode: AssignmentMode::Manual,
            allow_return_to_main: true,
            timer_duration: None,
            countdown_seconds: 60,
            auto_close: true,
            allow_room_switch: false,
        }
    }
}

/// Breakout session state
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum BreakoutState {
    /// Not started
    NotStarted,
    /// Rooms are open
    Open,
    /// Countdown to close
    Closing,
    /// Closed
    Closed,
}

/// Breakout session manager
pub struct BreakoutManager {
    /// Parent session ID
    session_id: u64,
    /// Configuration
    config: BreakoutConfig,
    /// Breakout rooms
    rooms: HashMap<u64, BreakoutRoom>,
    /// Room counter
    room_counter: u64,
    /// Current state
    state: BreakoutState,
    /// Participants in main room
    main_room: HashSet<u64>,
    /// Original room assignments (for return)
    original_assignments: HashMap<u64, Option<u64>>,
    /// Started at
    started_at: Option<Instant>,
    /// Help requests (endpoint_id -> room_id)
    help_requests: HashMap<u64, u64>,
}

impl BreakoutManager {
    pub fn new(session_id: u64, config: BreakoutConfig) -> Self {
        Self {
            session_id,
            config,
            rooms: HashMap::new(),
            room_counter: 0,
            state: BreakoutState::NotStarted,
            main_room: HashSet::new(),
            original_assignments: HashMap::new(),
            started_at: None,
            help_requests: HashMap::new(),
        }
    }

    /// Create a breakout room
    pub fn create_room(&mut self, name: &str) -> u64 {
        self.room_counter += 1;
        let room = BreakoutRoom::new(self.room_counter, name);
        let id = room.id;
        self.rooms.insert(id, room);
        id
    }

    /// Create multiple rooms
    pub fn create_rooms(&mut self, count: usize) -> Vec<u64> {
        (0..count)
            .map(|i| self.create_room(&format!("Room {}", i + 1)))
            .collect()
    }

    /// Delete a room
    pub fn delete_room(&mut self, room_id: u64) -> bool {
        if let Some(room) = self.rooms.remove(&room_id) {
            // Move participants back to main
            for participant in room.participants {
                self.main_room.insert(participant);
            }
            true
        } else {
            false
        }
    }

    /// Assign participant to a room
    pub fn assign_participant(&mut self, endpoint_id: u64, room_id: u64) -> Result<(), BreakoutError> {
        // Remove from current location
        self.main_room.remove(&endpoint_id);
        for room in self.rooms.values_mut() {
            room.remove_participant(endpoint_id);
        }

        // Add to new room
        if let Some(room) = self.rooms.get_mut(&room_id) {
            if room.add_participant(endpoint_id) {
                Ok(())
            } else {
                Err(BreakoutError::RoomFull(room_id))
            }
        } else {
            Err(BreakoutError::RoomNotFound(room_id))
        }
    }

    /// Auto-assign all participants in main room
    pub fn auto_assign(&mut self) -> HashMap<u64, u64> {
        let participants: Vec<u64> = self.main_room.drain().collect();
        let room_ids: Vec<u64> = self.rooms.keys().copied().collect();

        if room_ids.is_empty() {
            return HashMap::new();
        }

        let mut assignments = HashMap::new();
        for (i, endpoint_id) in participants.into_iter().enumerate() {
            let room_id = room_ids[i % room_ids.len()];
            if let Some(room) = self.rooms.get_mut(&room_id) {
                room.add_participant(endpoint_id);
                assignments.insert(endpoint_id, room_id);
            }
        }

        assignments
    }

    /// Start breakout session
    pub fn start(&mut self) {
        self.state = BreakoutState::Open;
        self.started_at = Some(Instant::now());

        // Save original assignments
        for room in self.rooms.values() {
            for &participant in &room.participants {
                self.original_assignments.insert(participant, Some(room.id));
            }
        }
        for &participant in &self.main_room {
            self.original_assignments.insert(participant, None);
        }
    }

    /// Close breakout session
    pub fn close(&mut self) {
        self.state = BreakoutState::Closed;

        // Move everyone back to main
        for room in self.rooms.values_mut() {
            for participant in room.participants.drain() {
                self.main_room.insert(participant);
            }
        }

        self.help_requests.clear();
    }

    /// Start closing countdown
    pub fn start_countdown(&mut self) {
        self.state = BreakoutState::Closing;
    }

    /// Move participant to main room
    pub fn return_to_main(&mut self, endpoint_id: u64) -> bool {
        if !self.config.allow_return_to_main {
            return false;
        }

        for room in self.rooms.values_mut() {
            room.remove_participant(endpoint_id);
        }
        self.main_room.insert(endpoint_id)
    }

    /// Request help (participant asks host to visit)
    pub fn request_help(&mut self, endpoint_id: u64) -> Option<u64> {
        // Find which room the participant is in
        for room in self.rooms.values() {
            if room.participants.contains(&endpoint_id) {
                self.help_requests.insert(endpoint_id, room.id);
                return Some(room.id);
            }
        }
        None
    }

    /// Clear help request
    pub fn clear_help_request(&mut self, endpoint_id: u64) {
        self.help_requests.remove(&endpoint_id);
    }

    /// Get pending help requests
    pub fn help_requests(&self) -> &HashMap<u64, u64> {
        &self.help_requests
    }

    /// Get room by ID
    pub fn get_room(&self, room_id: u64) -> Option<&BreakoutRoom> {
        self.rooms.get(&room_id)
    }

    /// Get all rooms
    pub fn rooms(&self) -> impl Iterator<Item = &BreakoutRoom> {
        self.rooms.values()
    }

    /// Get room for participant
    pub fn get_participant_room(&self, endpoint_id: u64) -> Option<u64> {
        for room in self.rooms.values() {
            if room.participants.contains(&endpoint_id) {
                return Some(room.id);
            }
        }
        None
    }

    /// Is participant in main room
    pub fn is_in_main(&self, endpoint_id: u64) -> bool {
        self.main_room.contains(&endpoint_id)
    }

    /// Get current state
    pub fn state(&self) -> BreakoutState {
        self.state
    }

    /// Get time remaining (if timer set)
    pub fn time_remaining(&self) -> Option<Duration> {
        if let (Some(duration), Some(started)) = (self.config.timer_duration, self.started_at) {
            let elapsed = started.elapsed();
            if elapsed < duration {
                Some(duration - elapsed)
            } else {
                Some(Duration::ZERO)
            }
        } else {
            None
        }
    }

    /// Get stats
    pub fn stats(&self) -> BreakoutStats {
        BreakoutStats {
            room_count: self.rooms.len(),
            total_in_rooms: self.rooms.values().map(|r| r.participant_count()).sum(),
            in_main_room: self.main_room.len(),
            help_requests: self.help_requests.len(),
            state: self.state,
        }
    }
}

/// Breakout statistics
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct BreakoutStats {
    pub room_count: usize,
    pub total_in_rooms: usize,
    pub in_main_room: usize,
    pub help_requests: usize,
    pub state: BreakoutState,
}

/// Breakout errors
#[derive(Debug, Clone)]
pub enum BreakoutError {
    RoomNotFound(u64),
    RoomFull(u64),
    NotAllowed,
    InvalidState(BreakoutState),
}

impl std::fmt::Display for BreakoutError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            BreakoutError::RoomNotFound(id) => write!(f, "Room {} not found", id),
            BreakoutError::RoomFull(id) => write!(f, "Room {} is full", id),
            BreakoutError::NotAllowed => write!(f, "Operation not allowed"),
            BreakoutError::InvalidState(s) => write!(f, "Invalid state: {:?}", s),
        }
    }
}

impl std::error::Error for BreakoutError {}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_breakout_room_creation() {
        let mut manager = BreakoutManager::new(100, BreakoutConfig::default());

        let ids = manager.create_rooms(3);
        assert_eq!(ids.len(), 3);
        assert_eq!(manager.rooms.len(), 3);
    }

    #[test]
    fn test_participant_assignment() {
        let mut manager = BreakoutManager::new(100, BreakoutConfig::default());
        let room_id = manager.create_room("Test Room");

        manager.assign_participant(1, room_id).unwrap();
        
        let room = manager.get_room(room_id).unwrap();
        assert!(room.participants.contains(&1));
    }

    #[test]
    fn test_auto_assign() {
        let mut manager = BreakoutManager::new(100, BreakoutConfig::default());
        manager.create_rooms(2);

        // Add participants to main
        manager.main_room.insert(1);
        manager.main_room.insert(2);
        manager.main_room.insert(3);
        manager.main_room.insert(4);

        let assignments = manager.auto_assign();
        assert_eq!(assignments.len(), 4);

        // Main room should be empty
        assert!(manager.main_room.is_empty());
    }

    #[test]
    fn test_return_to_main() {
        let mut manager = BreakoutManager::new(100, BreakoutConfig::default());
        let room_id = manager.create_room("Test");

        manager.assign_participant(1, room_id).unwrap();
        assert!(manager.get_room(room_id).unwrap().participants.contains(&1));

        manager.return_to_main(1);
        assert!(!manager.get_room(room_id).unwrap().participants.contains(&1));
        assert!(manager.is_in_main(1));
    }

    #[test]
    fn test_help_request() {
        let mut manager = BreakoutManager::new(100, BreakoutConfig::default());
        let room_id = manager.create_room("Test");

        manager.assign_participant(1, room_id).unwrap();
        
        let requested_room = manager.request_help(1);
        assert_eq!(requested_room, Some(room_id));
        assert_eq!(manager.help_requests().len(), 1);
    }

    #[test]
    fn test_close_session() {
        let mut manager = BreakoutManager::new(100, BreakoutConfig::default());
        let room_id = manager.create_room("Test");

        manager.assign_participant(1, room_id).unwrap();
        manager.assign_participant(2, room_id).unwrap();
        manager.start();

        manager.close();

        assert_eq!(manager.state(), BreakoutState::Closed);
        assert!(manager.is_in_main(1));
        assert!(manager.is_in_main(2));
    }
}
