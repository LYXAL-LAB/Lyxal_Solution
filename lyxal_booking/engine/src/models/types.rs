//! Type aliases for native SurrealDB 2.2 types used across Lyxal OS domain models.

use surrealdb::sql::Datetime;
use surrealdb::RecordId;

/// Official type alias for SurrealDB Record IDs across Lyxal OS.
pub type BookingRecordId = RecordId;

/// Official type alias for SurrealDB Datetime values across Lyxal OS.
pub type BookingDatetime = Datetime;
