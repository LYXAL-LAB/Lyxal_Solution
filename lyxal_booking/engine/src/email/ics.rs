//! ICS calendar generation helpers (RFC 4791 / RFC 6638).

use super::dto::{BookingDetails, CancellationDetails};
use super::timezone::convert_to_utc;

/// Strip newline characters to prevent ICS header injection.
pub fn sanitize_ics(s: &str) -> String {
    s.replace('\r', "")
        .replace('\n', " ")
        .replace('\\', "\\\\")
        .replace(';', "\\;")
        .replace(',', "\\,")
}

fn first_name(full_name: &str) -> &str {
    full_name.split_whitespace().next().unwrap_or(full_name)
}

/// Generate an .ics VCALENDAR string for a booking.
pub fn generate_ics(details: &BookingDetails, method: &str) -> String {
    generate_ics_impl(details, method, false)
}

/// ICS for CalDAV write-back (RFC 4791: no METHOD).
pub fn generate_ics_caldav(details: &BookingDetails) -> String {
    generate_ics_impl(details, "", true)
}

fn generate_ics_impl(
    details: &BookingDetails,
    method: &str,
    schedule_agent_client: bool,
) -> String {
    let guest_first = first_name(&details.guest_name);
    let host_first = first_name(&details.host_name);
    let summary = sanitize_ics(&format!(
        "{} \u{2014} {} & {}",
        details.event_title, guest_first, host_first
    ));
    let host_name = sanitize_ics(&details.host_name);
    let guest_name = sanitize_ics(&details.guest_name);
    let host_email = sanitize_ics(&details.host_email);
    let guest_email = sanitize_ics(&details.guest_email);
    let location_line = details
        .location
        .as_ref()
        .map(|l| format!("LOCATION:{}\r\n", sanitize_ics(l)))
        .unwrap_or_default();
    let description_line = details
        .notes
        .as_ref()
        .filter(|n| !n.trim().is_empty())
        .map(|n| format!("DESCRIPTION:{}\r\n", sanitize_ics(n)))
        .unwrap_or_default();
    let valarm = details
        .reminder_minutes
        .filter(|&m| m > 0)
        .map(|m| {
            format!(
                "BEGIN:VALARM\r\n\
                 TRIGGER:-PT{m}M\r\n\
                 ACTION:DISPLAY\r\n\
                 DESCRIPTION:Reminder\r\n\
                 END:VALARM\r\n"
            )
        })
        .unwrap_or_default();
    let sa = if schedule_agent_client {
        ";SCHEDULE-AGENT=CLIENT"
    } else {
        ""
    };
    let additional_attendee_lines: String = details
        .additional_attendees
        .iter()
        .map(|email| format!("ATTENDEE{sa};RSVP=TRUE:mailto:{}\r\n", sanitize_ics(email)))
        .collect();
    let dtstamp = chrono::Utc::now().format("%Y%m%dT%H%M%SZ").to_string();
    let (dtstart, dtend) = convert_to_utc(
        &details.date,
        &details.start_time,
        &details.end_time,
        &details.guest_timezone,
    );
    format!(
        "BEGIN:VCALENDAR\r\n\
         VERSION:2.0\r\n\
         PRODID:-//calrs//calrs//EN\r\n\
         {method_line}\
         BEGIN:VEVENT\r\n\
         UID:{uid}\r\n\
         DTSTAMP:{dtstamp}\r\n\
         DTSTART:{dtstart}\r\n\
         DTEND:{dtend}\r\n\
         SUMMARY:{summary}\r\n\
         {description_line}\
         {location_line}\
         ORGANIZER;CN={host_name}:mailto:{host_email}\r\n\
         ATTENDEE{sa};CN={guest_name};RSVP=TRUE:mailto:{guest_email}\r\n\
         {additional_attendee_lines}\
         STATUS:CONFIRMED\r\n\
         {valarm}\
         END:VEVENT\r\n\
         END:VCALENDAR\r\n",
        method_line = if method.is_empty() {
            String::new()
        } else {
            format!("METHOD:{method}\r\n")
        },
        uid = details.uid,
        dtstamp = dtstamp,
        dtstart = dtstart,
        dtend = dtend,
        summary = summary,
        description_line = description_line,
        location_line = location_line,
        host_name = host_name,
        host_email = host_email,
        guest_name = guest_name,
        guest_email = guest_email,
        additional_attendee_lines = additional_attendee_lines,
    )
}

/// Generate an .ics VCALENDAR for cancellation (METHOD:CANCEL)
pub fn generate_cancel_ics(details: &CancellationDetails) -> String {
    let guest_first = first_name(&details.guest_name);
    let host_first = first_name(&details.host_name);
    let summary = sanitize_ics(&format!(
        "{} \u{2014} {} & {}",
        details.event_title, guest_first, host_first
    ));
    let host_name = sanitize_ics(&details.host_name);
    let guest_name = sanitize_ics(&details.guest_name);
    let host_email = sanitize_ics(&details.host_email);
    let guest_email = sanitize_ics(&details.guest_email);
    let dtstamp = chrono::Utc::now().format("%Y%m%dT%H%M%SZ").to_string();
    let (dtstart, dtend) = convert_to_utc(
        &details.date,
        &details.start_time,
        &details.end_time,
        &details.guest_timezone,
    );
    format!(
        "BEGIN:VCALENDAR\r\n\
         VERSION:2.0\r\n\
         PRODID:-//calrs//calrs//EN\r\n\
         METHOD:CANCEL\r\n\
         BEGIN:VEVENT\r\n\
         UID:{uid}\r\n\
         DTSTAMP:{dtstamp}\r\n\
         DTSTART:{dtstart}\r\n\
         DTEND:{dtend}\r\n\
         SUMMARY:{summary}\r\n\
         ORGANIZER;CN={host_name}:mailto:{host_email}\r\n\
         ATTENDEE;CN={guest_name}:mailto:{guest_email}\r\n\
         STATUS:CANCELLED\r\n\
         END:VEVENT\r\n\
         END:VCALENDAR\r\n",
        uid = details.uid,
        dtstamp = dtstamp,
        dtstart = dtstart,
        dtend = dtend,
        summary = summary,
        host_name = host_name,
        host_email = host_email,
        guest_name = guest_name,
        guest_email = guest_email,
    )
}
