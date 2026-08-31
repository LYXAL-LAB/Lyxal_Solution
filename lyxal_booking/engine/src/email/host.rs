//! Host email notification functions.

use anyhow::Result;
use lettre::message::header::ContentType;
use lettre::message::{Attachment, MultiPart, Message};

use super::config::SmtpConfig;
use super::dto::{BookingDetails, EmailRow};
use super::html::{build_multipart_body, h, render_html_email};
use super::ics::generate_ics;
use super::timezone::host_time_display;
use super::transport::send_email;

/// Send booking notification to the host
pub async fn send_host_notification(config: &SmtpConfig, details: &BookingDetails) -> Result<()> {
    let ics = generate_ics(details, "REQUEST");

    let to = format!("{} <{}>", details.host_name, details.host_email).parse()?;

    let (date_display, time_display) = host_time_display(
        &details.date,
        &details.start_time,
        &details.end_time,
        &details.guest_timezone,
        &details.host_timezone,
    );

    let plain = format!(
        "New booking!\n\n\
         Event: {}\n\
         Date: {}\n\
         Time: {}\n\
         Guest: {} <{}>\n\
         {}{}{}\n\
         A calendar invite is attached.\n\n\
         \u{2014} calrs",
        details.event_title,
        date_display,
        time_display,
        details.guest_name,
        details.guest_email,
        details
            .location
            .as_ref()
            .map(|l| format!("Location: {}\n", l))
            .unwrap_or_default(),
        details
            .notes
            .as_ref()
            .map(|n| format!("Notes: {}\n", n))
            .unwrap_or_default(),
        details
            .resource_name
            .as_ref()
            .map(|r| format!("Resource: {}\n", r))
            .unwrap_or_default(),
    );

    let mut rows = vec![
        EmailRow {
            label: "Event".to_string(),
            value: details.event_title.clone(),
        },
        EmailRow {
            label: "Date".to_string(),
            value: date_display.clone(),
        },
        EmailRow {
            label: "Time".to_string(),
            value: time_display,
        },
        EmailRow {
            label: "Guest".to_string(),
            value: format!("{} <{}>", details.guest_name, details.guest_email),
        },
    ];
    if let Some(loc) = &details.location {
        rows.push(EmailRow {
            label: "Location".to_string(),
            value: loc.clone(),
        });
    }
    if let Some(res) = &details.resource_name {
        rows.push(EmailRow {
            label: "Resource".to_string(),
            value: res.clone(),
        });
    }
    if let Some(notes) = &details.notes {
        rows.push(EmailRow {
            label: "Notes".to_string(),
            value: notes.clone(),
        });
    }

    let html = render_html_email(
        "New booking!",
        &format!("{} booked a slot with you.", h(&details.guest_name)),
        "#16a34a",
        &rows,
        Some("A calendar invite is attached to this email."),
    );

    let body = build_multipart_body(&plain, &html);

    let ics_attachment = Attachment::new("invite.ics".to_string()).body(
        ics,
        ContentType::parse("text/calendar; method=REQUEST; charset=UTF-8")?,
    );

    let email = Message::builder()
        .from(config.mailbox_from()?)
        .to(to)
        .subject(format!(
            "New booking: {} \u{2014} {} ({})",
            details.event_title, details.guest_name, date_display
        ))
        .multipart(
            MultiPart::mixed()
                .multipart(body)
                .singlepart(ics_attachment),
        )?;

    send_email(config, email).await
}

/// Send host a confirmation that a pending booking was approved
pub async fn send_host_booking_confirmed(
    config: &SmtpConfig,
    details: &BookingDetails,
) -> Result<()> {
    let to = format!("{} <{}>", details.host_name, details.host_email).parse()?;

    let (date_display, time_display) = host_time_display(
        &details.date,
        &details.start_time,
        &details.end_time,
        &details.guest_timezone,
        &details.host_timezone,
    );

    let plain = format!(
        "Booking confirmed!\n\n\
         Event: {}\n\
         Date: {}\n\
         Time: {}\n\
         Guest: {} <{}>\n\
         {}\
         The event has been added to your calendar.\n\n\
         \u{2014} calrs",
        details.event_title,
        date_display,
        time_display,
        details.guest_name,
        details.guest_email,
        details
            .location
            .as_ref()
            .map(|l| format!("Location: {}\n", l))
            .unwrap_or_default(),
    );

    let mut rows = vec![
        EmailRow {
            label: "Event".to_string(),
            value: details.event_title.clone(),
        },
        EmailRow {
            label: "Date".to_string(),
            value: date_display.clone(),
        },
        EmailRow {
            label: "Time".to_string(),
            value: time_display,
        },
        EmailRow {
            label: "Guest".to_string(),
            value: format!("{} <{}>", details.guest_name, details.guest_email),
        },
    ];
    if let Some(loc) = &details.location {
        rows.push(EmailRow {
            label: "Location".to_string(),
            value: loc.clone(),
        });
    }
    if let Some(res) = &details.resource_name {
        rows.push(EmailRow {
            label: "Resource".to_string(),
            value: res.clone(),
        });
    }

    let html = render_html_email(
        "Booking confirmed!",
        &format!("Your booking with {} has been confirmed.", h(&details.guest_name)),
        "#16a34a",
        &rows,
        Some("The event has been added to your calendar."),
    );

    let body = build_multipart_body(&plain, &html);

    let email = Message::builder()
        .from(config.mailbox_from()?)
        .to(to)
        .subject(format!(
            "Confirmed: {} \u{2014} {} ({})",
            details.event_title, details.guest_name, date_display
        ))
        .multipart(body)?;

    send_email(config, email).await
}
