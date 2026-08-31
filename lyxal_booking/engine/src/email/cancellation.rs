//! Cancellation email functions for guest and host.

use anyhow::Result;
use lettre::message::header::ContentType;
use lettre::message::{Attachment, MultiPart, Message};

use super::config::SmtpConfig;
use super::dto::{CancellationDetails, EmailRow};
use super::html::{build_multipart_body, h, render_html_email};
use super::i18n::{t, ta};
use super::ics::generate_cancel_ics;
use super::timezone::host_time_display;
use super::transport::send_email;

/// Send cancellation notification to the guest
pub async fn send_guest_cancellation(
    config: &SmtpConfig,
    details: &CancellationDetails,
) -> Result<()> {
    let ics = generate_cancel_ics(details);
    let lang = details.guest_language.as_deref().unwrap_or("en");

    let to = format!("{} <{}>", details.guest_name, details.guest_email).parse()?;

    let time_display = if details.guest_timezone.is_empty() {
        format!("{} \u{2013} {}", details.start_time, details.end_time)
    } else {
        format!(
            "{} \u{2013} {} ({})",
            details.start_time, details.end_time, details.guest_timezone
        )
    };

    let greeting = ta(
        lang,
        "email-confirm-greeting",
        [("name", &details.guest_name)],
    );
    let headline = if details.cancelled_by_host {
        ta(
            lang,
            "email-cancel-headline-by-host",
            [("host", &details.host_name)],
        )
    } else {
        t(lang, "email-cancel-headline-by-guest")
    };
    let label_event = t(lang, "confirmed-detail-event");
    let label_date = t(lang, "confirmed-detail-date");
    let label_time = t(lang, "confirmed-detail-time");
    let label_with = t(lang, "confirmed-detail-with");
    let label_reason = t(lang, "common-detail-reason");
    let ics_attached_plain = t(lang, "email-cancel-ics-attached-plain");
    let ics_attached_html = t(lang, "email-cancel-ics-attached-html");
    let signature = t(lang, "email-signature");

    let reason_text = details
        .reason
        .as_ref()
        .map(|r| format!("{} {}\n\n", label_reason, r))
        .unwrap_or_default();

    let plain = format!(
        "{}\n\n\
         {}\n\n\
         {} {}\n\
         {} {}\n\
         {} {}\n\
         {} {}\n\n\
         {}\
         {}\n\n\
         {}",
        greeting,
        headline,
        label_event,
        details.event_title,
        label_date,
        details.date,
        label_time,
        time_display,
        label_with,
        details.host_name,
        reason_text,
        ics_attached_plain,
        signature,
    );

    let mut rows = vec![
        EmailRow {
            label: label_event.clone(),
            value: details.event_title.clone(),
        },
        EmailRow {
            label: label_date.clone(),
            value: details.date.clone(),
        },
        EmailRow {
            label: label_time.clone(),
            value: time_display,
        },
        EmailRow {
            label: label_with.clone(),
            value: details.host_name.clone(),
        },
    ];
    if let Some(reason) = &details.reason {
        rows.push(EmailRow {
            label: label_reason.clone(),
            value: reason.clone(),
        });
    }

    let html = render_html_email(
        &h(&greeting),
        &headline,
        "#dc2626",
        &rows,
        Some(&ics_attached_html),
    );

    let body = build_multipart_body(&plain, &html);

    let ics_attachment = Attachment::new("cancel.ics".to_string()).body(
        ics,
        ContentType::parse("text/calendar; method=CANCEL; charset=UTF-8")?,
    );

    let subject = ta(
        lang,
        "email-cancel-subject",
        [("event", &details.event_title), ("date", &details.date)],
    );
    let email = Message::builder()
        .from(config.mailbox_from()?)
        .to(to)
        .subject(subject)
        .multipart(
            MultiPart::mixed()
                .multipart(body)
                .singlepart(ics_attachment),
        )?;

    send_email(config, email).await
}

/// Send cancellation notification to the host
pub async fn send_host_cancellation(
    config: &SmtpConfig,
    details: &CancellationDetails,
) -> Result<()> {
    let ics = generate_cancel_ics(details);

    let to = format!("{} <{}>", details.host_name, details.host_email).parse()?;

    let (date_display, time_display) = host_time_display(
        &details.date,
        &details.start_time,
        &details.end_time,
        &details.guest_timezone,
        &details.host_timezone,
    );
    let reason_text = details
        .reason
        .as_ref()
        .map(|r| format!("Reason: {}\n\n", r))
        .unwrap_or_default();

    let plain = format!(
        "Booking cancelled.\n\n\
         Event: {}\n\
         Date: {}\n\
         Time: {}\n\
         Guest: {} <{}>\n\n\
         {}\
         A calendar cancellation is attached.\n\n\
         \u{2014} calrs",
        details.event_title,
        date_display,
        time_display,
        details.guest_name,
        details.guest_email,
        reason_text,
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
    if let Some(reason) = &details.reason {
        rows.push(EmailRow {
            label: "Reason".to_string(),
            value: reason.clone(),
        });
    }

    let html = render_html_email(
        "Booking cancelled.",
        &if details.cancelled_by_host {
            "You cancelled this booking.".to_string()
        } else {
            format!("{} cancelled their booking.", h(&details.guest_name))
        },
        "#dc2626",
        &rows,
        Some("A calendar cancellation is attached to this email."),
    );

    let body = build_multipart_body(&plain, &html);

    let ics_attachment = Attachment::new("cancel.ics".to_string()).body(
        ics,
        ContentType::parse("text/calendar; method=CANCEL; charset=UTF-8")?,
    );

    let email = Message::builder()
        .from(config.mailbox_from()?)
        .to(to)
        .subject(format!(
            "Cancelled: {} \u{2014} {} ({})",
            details.event_title, details.guest_name, date_display
        ))
        .multipart(
            MultiPart::mixed()
                .multipart(body)
                .singlepart(ics_attachment),
        )?;

    send_email(config, email).await
}
