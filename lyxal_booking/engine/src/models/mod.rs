//! Domain models module tree for Lyxal Booking.

pub mod account;
pub mod activity;
pub mod auth;
pub mod booking;
pub mod calendar;
pub mod event_type;
pub mod form;
pub mod integration;
pub mod resource;
pub mod schedule;
pub mod team;
pub mod types;

// Public re-exports for backwards compatibility and clean imports
pub use account::{Account, Session, User};
pub use activity::BookingActivity;
pub use auth::AuthConfig;
pub use booking::{Booking, BookingInvite, BookingSummary};
pub use calendar::{CaldavSource, Calendar, Event};
pub use event_type::EventType;
pub use form::{BookingAnswer, BookingQuestion};
pub use integration::BookingSyncLog;
pub use resource::Resource;
pub use schedule::{BookingSchedule, BookingScheduleOverride, BookingScheduleRule, BookingTimeOff};
pub use team::{Group, Team, TeamMember};
pub use types::{BookingDatetime, BookingRecordId};

// Restricted pub(crate) re-exports for internal persistence structures
pub(crate) use account::AuthUserRecord;
pub(crate) use auth::StoredAuthSecrets;
pub(crate) use calendar::StoredCaldavSecrets;
pub(crate) use resource::StoredResourceSecrets;
