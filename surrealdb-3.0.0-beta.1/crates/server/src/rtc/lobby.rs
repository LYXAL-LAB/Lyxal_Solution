//! Waiting Room / Lobby - Meeting Entry Control
//!
//! Security feature for controlling who enters a meeting,
//! like Zoom Waiting Room and Microsoft Teams Lobby.
//!
//! ## Features
//!
//! ```text
//! ┌─────────────────────────────────────────────────────────────────────────────┐
//! │                    WAITING ROOM / LOBBY                                     │
//! │                                                                             │
//! │   ┌─────────────────────────────────────────────────────────────────────┐  │
//! │   │                      LOBBY                                           │  │
//! │   │                                                                      │  │
//! │   │    ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐             │  │
//! │   │    │ Guest 1 │  │ Guest 2 │  │ Guest 3 │  │ Guest 4 │             │  │
//! │   │    │ Waiting │  │ Waiting │  │ Waiting │  │ Waiting │             │  │
//! │   │    └────┬────┘  └────┬────┘  └────┬────┘  └────┬────┘             │  │
//! │   │         │            │            │            │                  │  │
//! │   └─────────┼────────────┼────────────┼────────────┼──────────────────┘  │
//! │             │            │            │            │                      │
//! │             ▼            ▼            ▼            ▼                      │
//! │   ┌──────────────────────────────────────────────────────────────────┐   │
//! │   │                       HOST CONTROL                                │   │
//! │   │                                                                   │   │
//! │   │    [Admit]  [Admit All]  [Remove]  [Message]                     │   │
//! │   │                                                                   │   │
//! │   └──────────────────────────────────────────────────────────────────┘   │
//! │                              │                                            │
//! │                              ▼                                            │
//! │   ┌──────────────────────────────────────────────────────────────────┐   │
//! │   │                        MEETING                                    │   │
//! │   │                                                                   │   │
//! │   │    Admitted participants                                         │   │
//! │   │                                                                   │   │
//! │   └──────────────────────────────────────────────────────────────────┘   │
//! │                                                                             │
//! │   Bypass Rules:                                                            │
//! │   • Authenticated users                                                    │
//! │   • Same organization                                                      │
//! │   • Invited guests                                                         │
//! │   • Returning participants                                                 │
//! │                                                                             │
//! └─────────────────────────────────────────────────────────────────────────────┘
//! ```

use std::collections::HashMap;
use std::time::{Duration, Instant};

use serde::{Deserialize, Serialize};

/// Waiting room status for a participant
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum LobbyStatus {
    /// In the waiting room
    Waiting,
    /// Admitted to meeting
    Admitted,
    /// Removed from waiting room
    Removed,
    /// Auto-admitted (bypass)
    Bypassed,
}

/// Lobby bypass rule
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum BypassRule {
    /// Never bypass (all go to lobby)
    None,
    /// Authenticated users bypass
    Authenticated,
    /// Same organization bypasses
    SameOrganization,
    /// Invited guests bypass
    InvitedOnly,
    /// Specific role bypasses
    SpecificRoles,
    /// Everyone bypasses (lobby disabled)
    Everyone,
}

impl Default for BypassRule {
    fn default() -> Self {
        Self::SameOrganization
    }
}

/// Lobby configuration
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct LobbyConfig {
    /// Enable waiting room
    pub enabled: bool,
    /// Bypass rule
    pub bypass_rule: BypassRule,
    /// Custom welcome message
    pub welcome_message: Option<String>,
    /// Show meeting info in lobby
    pub show_meeting_info: bool,
    /// Allow guests to see other waiting participants
    pub show_other_waiting: bool,
    /// Auto-admit after N seconds (0 = never)
    pub auto_admit_after_secs: u32,
    /// Notify host on new arrival
    pub notify_host: bool,
    /// Allow participants to send messages to host
    pub allow_messages: bool,
    /// Maximum time in lobby before timeout
    pub lobby_timeout_secs: u32,
}

impl Default for LobbyConfig {
    fn default() -> Self {
        Self {
            enabled: true,
            bypass_rule: BypassRule::SameOrganization,
            welcome_message: Some("Please wait, the host will let you in shortly.".to_string()),
            show_meeting_info: true,
            show_other_waiting: false,
            auto_admit_after_secs: 0,
            notify_host: true,
            allow_messages: true,
            lobby_timeout_secs: 3600, // 1 hour
        }
    }
}

impl LobbyConfig {
    /// Secure configuration (everyone waits)
    pub fn secure() -> Self {
        Self {
            enabled: true,
            bypass_rule: BypassRule::None,
            welcome_message: Some("The host must admit you. Please wait.".to_string()),
            show_meeting_info: false,
            show_other_waiting: false,
            auto_admit_after_secs: 0,
            notify_host: true,
            allow_messages: true,
            lobby_timeout_secs: 1800,
        }
    }

    /// Open configuration (no lobby)
    pub fn open() -> Self {
        Self {
            enabled: false,
            bypass_rule: BypassRule::Everyone,
            ..Default::default()
        }
    }
}

/// Participant in the lobby
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct LobbyParticipant {
    /// Endpoint ID
    pub endpoint_id: u64,
    /// Display name
    pub name: Option<String>,
    /// Email (if authenticated)
    pub email: Option<String>,
    /// Avatar URL
    pub avatar_url: Option<String>,
    /// Is authenticated
    pub authenticated: bool,
    /// Organization ID
    pub organization_id: Option<String>,
    /// Device type
    pub device_type: DeviceType,
    /// Status
    pub status: LobbyStatus,
    /// Joined at
    pub joined_at: Instant,
    /// Messages to host
    pub messages: Vec<LobbyMessage>,
    /// Has raised hand
    pub hand_raised: bool,
}

/// Device type
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum DeviceType {
    Desktop,
    Mobile,
    Tablet,
    Phone,
    Unknown,
}

impl Default for DeviceType {
    fn default() -> Self {
        Self::Unknown
    }
}

/// Message from lobby participant
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct LobbyMessage {
    /// Message text
    pub text: String,
    /// Sent at (Unix timestamp)
    pub sent_at: u64,
    /// Is from host (response)
    pub from_host: bool,
}

/// Lobby event
#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum LobbyEvent {
    /// Participant arrived in lobby
    Arrived {
        endpoint_id: u64,
        name: Option<String>,
    },
    /// Participant was admitted
    Admitted {
        endpoint_id: u64,
        by_host: Option<u64>,
    },
    /// Participant was removed
    Removed {
        endpoint_id: u64,
        reason: Option<String>,
    },
    /// Participant left lobby
    Left {
        endpoint_id: u64,
    },
    /// Message received
    MessageReceived {
        endpoint_id: u64,
        message: String,
    },
    /// Hand raised
    HandRaised {
        endpoint_id: u64,
    },
    /// Lobby timeout
    Timeout {
        endpoint_id: u64,
    },
}

/// Lobby manager
pub struct LobbyManager {
    /// Session ID
    session_id: u64,
    /// Configuration
    config: LobbyConfig,
    /// Waiting participants
    waiting: HashMap<u64, LobbyParticipant>,
    /// Admitted participants (for tracking)
    admitted: HashMap<u64, LobbyParticipant>,
    /// Removed participants
    removed: HashMap<u64, LobbyParticipant>,
    /// Session organization ID (for bypass)
    organization_id: Option<String>,
    /// Invited emails (for bypass)
    invited_emails: Vec<String>,
    /// Event history
    events: Vec<(Instant, LobbyEvent)>,
}

impl LobbyManager {
    pub fn new(session_id: u64, config: LobbyConfig) -> Self {
        Self {
            session_id,
            config,
            waiting: HashMap::new(),
            admitted: HashMap::new(),
            removed: HashMap::new(),
            organization_id: None,
            invited_emails: Vec::new(),
            events: Vec::new(),
        }
    }

    pub fn with_defaults(session_id: u64) -> Self {
        Self::new(session_id, LobbyConfig::default())
    }

    /// Set session organization ID
    pub fn set_organization(&mut self, org_id: &str) {
        self.organization_id = Some(org_id.to_string());
    }

    /// Add invited email
    pub fn add_invited_email(&mut self, email: &str) {
        self.invited_emails.push(email.to_lowercase());
    }

    /// Participant arrives
    pub fn on_arrival(
        &mut self,
        endpoint_id: u64,
        name: Option<String>,
        email: Option<String>,
        organization_id: Option<String>,
        authenticated: bool,
        device_type: DeviceType,
    ) -> LobbyStatus {
        // Check if lobby is disabled
        if !self.config.enabled {
            return LobbyStatus::Bypassed;
        }

        // Check bypass rules
        if self.should_bypass(&email, &organization_id, authenticated) {
            let participant = LobbyParticipant {
                endpoint_id,
                name: name.clone(),
                email,
                avatar_url: None,
                authenticated,
                organization_id,
                device_type,
                status: LobbyStatus::Bypassed,
                joined_at: Instant::now(),
                messages: Vec::new(),
                hand_raised: false,
            };
            self.admitted.insert(endpoint_id, participant);
            return LobbyStatus::Bypassed;
        }

        // Add to waiting room
        let participant = LobbyParticipant {
            endpoint_id,
            name: name.clone(),
            email,
            avatar_url: None,
            authenticated,
            organization_id,
            device_type,
            status: LobbyStatus::Waiting,
            joined_at: Instant::now(),
            messages: Vec::new(),
            hand_raised: false,
        };
        self.waiting.insert(endpoint_id, participant);

        self.events.push((Instant::now(), LobbyEvent::Arrived {
            endpoint_id,
            name,
        }));

        LobbyStatus::Waiting
    }

    /// Check if participant should bypass lobby
    fn should_bypass(
        &self,
        email: &Option<String>,
        organization_id: &Option<String>,
        authenticated: bool,
    ) -> bool {
        match self.config.bypass_rule {
            BypassRule::None => false,
            BypassRule::Everyone => true,
            BypassRule::Authenticated => authenticated,
            BypassRule::SameOrganization => {
                if let (Some(session_org), Some(participant_org)) = (&self.organization_id, organization_id) {
                    session_org == participant_org
                } else {
                    false
                }
            }
            BypassRule::InvitedOnly => {
                if let Some(email) = email {
                    self.invited_emails.contains(&email.to_lowercase())
                } else {
                    false
                }
            }
            BypassRule::SpecificRoles => false, // Would need role info
        }
    }

    /// Admit a participant
    pub fn admit(&mut self, endpoint_id: u64, by_host: Option<u64>) -> Result<(), LobbyError> {
        let mut participant = self.waiting.remove(&endpoint_id)
            .ok_or(LobbyError::NotInLobby(endpoint_id))?;

        participant.status = LobbyStatus::Admitted;
        self.admitted.insert(endpoint_id, participant);

        self.events.push((Instant::now(), LobbyEvent::Admitted {
            endpoint_id,
            by_host,
        }));

        Ok(())
    }

    /// Admit all waiting participants
    pub fn admit_all(&mut self, by_host: Option<u64>) -> Vec<u64> {
        let endpoint_ids: Vec<u64> = self.waiting.keys().copied().collect();
        
        for endpoint_id in &endpoint_ids {
            let _ = self.admit(*endpoint_id, by_host);
        }

        endpoint_ids
    }

    /// Remove a participant from lobby
    pub fn remove(&mut self, endpoint_id: u64, reason: Option<String>) -> Result<(), LobbyError> {
        let mut participant = self.waiting.remove(&endpoint_id)
            .ok_or(LobbyError::NotInLobby(endpoint_id))?;

        participant.status = LobbyStatus::Removed;
        self.removed.insert(endpoint_id, participant);

        self.events.push((Instant::now(), LobbyEvent::Removed {
            endpoint_id,
            reason,
        }));

        Ok(())
    }

    /// Participant leaves lobby voluntarily
    pub fn on_leave(&mut self, endpoint_id: u64) {
        self.waiting.remove(&endpoint_id);
        self.events.push((Instant::now(), LobbyEvent::Left { endpoint_id }));
    }

    /// Send message from participant to host
    pub fn send_message(&mut self, endpoint_id: u64, message: String) -> Result<(), LobbyError> {
        if !self.config.allow_messages {
            return Err(LobbyError::MessagesDisabled);
        }

        let participant = self.waiting.get_mut(&endpoint_id)
            .ok_or(LobbyError::NotInLobby(endpoint_id))?;

        participant.messages.push(LobbyMessage {
            text: message.clone(),
            sent_at: std::time::SystemTime::now()
                .duration_since(std::time::UNIX_EPOCH)
                .unwrap()
                .as_secs(),
            from_host: false,
        });

        self.events.push((Instant::now(), LobbyEvent::MessageReceived {
            endpoint_id,
            message,
        }));

        Ok(())
    }

    /// Send message from host to participant
    pub fn send_host_message(&mut self, endpoint_id: u64, message: String) -> Result<(), LobbyError> {
        let participant = self.waiting.get_mut(&endpoint_id)
            .ok_or(LobbyError::NotInLobby(endpoint_id))?;

        participant.messages.push(LobbyMessage {
            text: message,
            sent_at: std::time::SystemTime::now()
                .duration_since(std::time::UNIX_EPOCH)
                .unwrap()
                .as_secs(),
            from_host: true,
        });

        Ok(())
    }

    /// Raise hand
    pub fn raise_hand(&mut self, endpoint_id: u64) -> Result<(), LobbyError> {
        let participant = self.waiting.get_mut(&endpoint_id)
            .ok_or(LobbyError::NotInLobby(endpoint_id))?;

        participant.hand_raised = true;

        self.events.push((Instant::now(), LobbyEvent::HandRaised { endpoint_id }));

        Ok(())
    }

    /// Lower hand
    pub fn lower_hand(&mut self, endpoint_id: u64) -> Result<(), LobbyError> {
        let participant = self.waiting.get_mut(&endpoint_id)
            .ok_or(LobbyError::NotInLobby(endpoint_id))?;

        participant.hand_raised = false;
        Ok(())
    }

    /// Get waiting participants
    pub fn get_waiting(&self) -> Vec<&LobbyParticipant> {
        self.waiting.values().collect()
    }

    /// Get waiting count
    pub fn waiting_count(&self) -> usize {
        self.waiting.len()
    }

    /// Get participant info
    pub fn get_participant(&self, endpoint_id: u64) -> Option<&LobbyParticipant> {
        self.waiting.get(&endpoint_id)
    }

    /// Check for timeouts
    pub fn check_timeouts(&mut self) -> Vec<u64> {
        if self.config.lobby_timeout_secs == 0 {
            return Vec::new();
        }

        let timeout = Duration::from_secs(self.config.lobby_timeout_secs as u64);
        let now = Instant::now();

        let timed_out: Vec<u64> = self.waiting
            .iter()
            .filter(|(_, p)| now.duration_since(p.joined_at) > timeout)
            .map(|(&id, _)| id)
            .collect();

        for endpoint_id in &timed_out {
            self.waiting.remove(endpoint_id);
            self.events.push((now, LobbyEvent::Timeout { endpoint_id: *endpoint_id }));
        }

        timed_out
    }

    /// Get lobby info (for display to waiting participant)
    pub fn get_lobby_info(&self) -> LobbyInfo {
        LobbyInfo {
            waiting_count: self.waiting_count(),
            welcome_message: self.config.welcome_message.clone(),
            show_meeting_info: self.config.show_meeting_info,
            allow_messages: self.config.allow_messages,
        }
    }

    /// Get stats
    pub fn stats(&self) -> LobbyStats {
        LobbyStats {
            waiting: self.waiting.len(),
            admitted: self.admitted.len(),
            removed: self.removed.len(),
            hands_raised: self.waiting.values().filter(|p| p.hand_raised).count(),
        }
    }
}

/// Lobby info (sent to waiting participants)
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct LobbyInfo {
    pub waiting_count: usize,
    pub welcome_message: Option<String>,
    pub show_meeting_info: bool,
    pub allow_messages: bool,
}

/// Lobby statistics
#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct LobbyStats {
    pub waiting: usize,
    pub admitted: usize,
    pub removed: usize,
    pub hands_raised: usize,
}

/// Lobby errors
#[derive(Debug, Clone)]
pub enum LobbyError {
    NotInLobby(u64),
    AlreadyAdmitted(u64),
    MessagesDisabled,
}

impl std::fmt::Display for LobbyError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            LobbyError::NotInLobby(id) => write!(f, "Participant {} not in lobby", id),
            LobbyError::AlreadyAdmitted(id) => write!(f, "Participant {} already admitted", id),
            LobbyError::MessagesDisabled => write!(f, "Messages are disabled"),
        }
    }
}

impl std::error::Error for LobbyError {}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_lobby_arrival() {
        let mut lobby = LobbyManager::with_defaults(100);

        let status = lobby.on_arrival(1, Some("Alice".to_string()), None, None, false, DeviceType::Desktop);
        assert_eq!(status, LobbyStatus::Waiting);
        assert_eq!(lobby.waiting_count(), 1);
    }

    #[test]
    fn test_lobby_bypass_authenticated() {
        let config = LobbyConfig {
            bypass_rule: BypassRule::Authenticated,
            ..Default::default()
        };
        let mut lobby = LobbyManager::new(100, config);

        // Unauthenticated goes to lobby
        let status1 = lobby.on_arrival(1, Some("Alice".to_string()), None, None, false, DeviceType::Desktop);
        assert_eq!(status1, LobbyStatus::Waiting);

        // Authenticated bypasses
        let status2 = lobby.on_arrival(2, Some("Bob".to_string()), Some("bob@example.com".to_string()), None, true, DeviceType::Desktop);
        assert_eq!(status2, LobbyStatus::Bypassed);
    }

    #[test]
    fn test_lobby_admit() {
        let mut lobby = LobbyManager::with_defaults(100);

        lobby.on_arrival(1, Some("Alice".to_string()), None, None, false, DeviceType::Desktop);
        lobby.admit(1, None).unwrap();

        assert_eq!(lobby.waiting_count(), 0);
        assert_eq!(lobby.stats().admitted, 1);
    }

    #[test]
    fn test_lobby_admit_all() {
        let mut lobby = LobbyManager::with_defaults(100);

        lobby.on_arrival(1, Some("Alice".to_string()), None, None, false, DeviceType::Desktop);
        lobby.on_arrival(2, Some("Bob".to_string()), None, None, false, DeviceType::Desktop);
        lobby.on_arrival(3, Some("Charlie".to_string()), None, None, false, DeviceType::Desktop);

        let admitted = lobby.admit_all(None);
        assert_eq!(admitted.len(), 3);
        assert_eq!(lobby.waiting_count(), 0);
    }

    #[test]
    fn test_lobby_messages() {
        let mut lobby = LobbyManager::with_defaults(100);

        lobby.on_arrival(1, Some("Alice".to_string()), None, None, false, DeviceType::Desktop);
        lobby.send_message(1, "Hi, can you let me in?".to_string()).unwrap();

        let participant = lobby.get_participant(1).unwrap();
        assert_eq!(participant.messages.len(), 1);
        assert!(!participant.messages[0].from_host);
    }

    #[test]
    fn test_lobby_organization_bypass() {
        let config = LobbyConfig {
            bypass_rule: BypassRule::SameOrganization,
            ..Default::default()
        };
        let mut lobby = LobbyManager::new(100, config);
        lobby.set_organization("org123");

        // Same org bypasses
        let status = lobby.on_arrival(1, Some("Alice".to_string()), None, Some("org123".to_string()), false, DeviceType::Desktop);
        assert_eq!(status, LobbyStatus::Bypassed);

        // Different org waits
        let status = lobby.on_arrival(2, Some("Bob".to_string()), None, Some("org456".to_string()), false, DeviceType::Desktop);
        assert_eq!(status, LobbyStatus::Waiting);
    }
}
