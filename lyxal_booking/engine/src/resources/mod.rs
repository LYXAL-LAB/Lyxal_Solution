//! Shared bookable resources module.
//!
//! A resource is an instance-level entity backed by a read-only ICS publish
//! feed (BlueMind "public/private calendar address", Nextcloud "public link", …).
//! Its events are cached in `booking_resource_event` and merged into slot
//! availability for every event type the resource is attached to.

pub mod assignment;
pub mod availability;
pub mod error;
pub mod feed;
pub mod model;
pub mod parser;
pub mod sync;

pub use assignment::{create_with_resource_assignment, reschedule_with_resource_assignment};
pub use availability::{blocking_intervals_for_event_type, busy_for_resource, merge_mode_busy};
pub use error::ResourceError;
pub use feed::{derive_caldav_url, feed_calendar_name, fetch_feed, url_origin};
pub use model::{
    AvailabilityPreview, CreateWithResourceAssignmentParams, RescheduleWithResourceParams,
    ResourceAssignmentResult, ResourceEventInput, ResourceRef,
};
pub use parser::{parse_calendar_events, parse_resource_event};
pub use sync::{sync_if_stale, sync_resource, sync_resources_if_stale, SYNC_STALE_MINUTES};

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_derive_caldav_url() {
        let feed = "https://example.com/api/calendars/publish/calendar:12345/x-calendar-abc";
        assert_eq!(
            derive_caldav_url(feed).as_deref(),
            Some("https://example.com/dav/calendars/__uids__/12345/calendar:12345/")
        );
        assert_eq!(derive_caldav_url("https://example.com/some/feed.ics"), None);
    }

    #[test]
    fn test_feed_calendar_name() {
        let body = "BEGIN:VCALENDAR\r\nX-WR-CALNAME:Vates Demo Lab 1\r\nEND:VCALENDAR\r\n";
        assert_eq!(feed_calendar_name(body).as_deref(), Some("Vates Demo Lab 1"));
        assert_eq!(feed_calendar_name("BEGIN:VCALENDAR\r\n"), None);
    }
}
