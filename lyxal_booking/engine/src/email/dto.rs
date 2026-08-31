//! Email Data Transfer Objects (BookingDetails, CancellationDetails, RescheduleDetails, EmailRow, EmailAction).

#[derive(Clone, Default, Debug)]
pub struct BookingDetails {
    pub event_title: String,
    pub date: String,
    pub start_time: String,
    pub end_time: String,
    pub guest_name: String,
    pub guest_email: String,
    pub guest_timezone: String,
    pub host_name: String,
    pub host_email: String,
    pub uid: String,
    pub notes: Option<String>,
    pub location: Option<String>,
    pub reminder_minutes: Option<i32>,
    pub additional_attendees: Vec<String>,
    /// Guest's preferred language at booking time (from `bookings.language`).
    pub guest_language: Option<String>,
    /// Host's saved UI-language preference (from `users.language`).
    pub host_language: Option<String>,
    /// Host's IANA timezone.
    pub host_timezone: String,
    /// Shared resource(s) reserved for this booking.
    pub resource_name: Option<String>,
}

#[derive(Default, Clone, Debug)]
pub struct CancellationDetails {
    pub event_title: String,
    pub date: String,
    pub start_time: String,
    pub end_time: String,
    pub guest_name: String,
    pub guest_email: String,
    pub guest_timezone: String,
    pub host_name: String,
    pub host_email: String,
    pub uid: String,
    pub reason: Option<String>,
    pub cancelled_by_host: bool,
    pub guest_language: Option<String>,
    pub host_language: Option<String>,
    pub host_timezone: String,
}

#[derive(Default, Clone, Debug)]
pub struct RescheduleDetails {
    pub event_title: String,
    pub old_date: String,
    pub old_start_time: String,
    pub old_end_time: String,
    pub new_date: String,
    pub new_start_time: String,
    pub new_end_time: String,
    pub guest_name: String,
    pub guest_email: String,
    pub guest_timezone: String,
    pub host_name: String,
    pub host_email: String,
    pub uid: String,
    pub location: Option<String>,
    pub host_timezone: String,
}

pub(crate) struct EmailRow {
    pub label: String,
    pub value: String,
}

pub(crate) struct EmailAction {
    pub label: String,
    pub url: String,
    pub color: String,
}
