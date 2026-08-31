//! Reminder email functions for guest and host.

use anyhow::Result;
use lettre::message::Message;

use super::config::SmtpConfig;
use super::dto::{BookingDetails, EmailAction, EmailRow};
use super::html::{build_multipart_body, h, render_html_email, render_html_email_with_actions};
use super::i18n::{guest_lang, t, ta};
use super::timezone::host_time_display;
use super::transport::send_email;

/// Send booking reminder to the guest
pub async fn send_guest_reminder(
    config: &SmtpConfig,
    details: &BookingDetails,
    cancel_url: Option<&str>,
) -> Result<()> {
    let lang = guest_lang(details);
    let to = format!("{} <{}>", details.guest_name, details.guest_email).parse()?;

    let time_display = format!(
        "{} \u{2013} {} ({})",
        details.start_time, details.end_time, details.guest_timezone
    );

    let greeting = ta(
        lang,
        "email-confirm-greeting",
        [("name", &details.guest_name)],
    );
    let headline = t(lang, "email-reminder-headline");
    let label_event = t(lang, "confirmed-detail-event");
    let label_date = t(lang, "confirmed-detail-date");
    let label_time = t(lang, "confirmed-detail-time");
    let label_with = t(lang, "confirmed-detail-with");
    let label_location = t(lang, "confirmed-detail-location");
    let signature = t(lang, "email-signature");

    let plain = format!(
        "{}\n\n\
         {}\n\n\
         {} {}\n\
         {} {}\n\
         {} {}\n\
         {} {}\n\
         {}{}\n\
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
        details
            .location
            .as_ref()
            .map(|l| format!("{} {}\n", label_location, l))
            .unwrap_or_default(),
        cancel_url
            .map(|u| format!(
                "\n{}\n",
                ta(lang, "email-confirm-need-to-cancel", [("url", u)])
            ))
            .unwrap_or_default(),
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
    if let Some(loc) = &details.location {
        rows.push(EmailRow {
            label: label_location.clone(),
            value: loc.clone(),
        });
    }

    let actions: Vec<EmailAction> = cancel_url
        .map(|u| {
            vec![EmailAction {
                label: t(lang, "email-action-cancel-booking"),
                url: u.to_string(),
                color: "#dc2626".to_string(),
            }]
        })
        .unwrap_or_default();

    let html =
        render_html_email_with_actions(&h(&greeting), &headline, "#3b82f6", &rows, None, &actions);

    let body = build_multipart_body(&plain, &html);

    let subject = ta(
        lang,
        "email-reminder-subject",
        [
            ("event", &details.event_title),
            ("time", &details.start_time),
        ],
    );
    let email = Message::builder()
        .from(config.mailbox_from()?)
        .to(to)
        .subject(subject)
        .multipart(body)?;

    send_email(config, email).await
}

/// Send booking reminder to the host
pub async fn send_host_reminder(config: &SmtpConfig, details: &BookingDetails) -> Result<()> {
    let to = format!("{} <{}>", details.host_name, details.host_email).parse()?;

    let (date_display, time_display) = host_time_display(
        &details.date,
        &details.start_time,
        &details.end_time,
        &details.guest_timezone,
        &details.host_timezone,
    );

    let plain = format!(
        "Reminder: you have an upcoming booking.\n\n\
         Event: {}\n\
         Date: {}\n\
         Time: {}\n\
         Guest: {} <{}>\n\
         {}\n\
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
    if let Some(res) = &details.resource_name {
        rows.push(EmailRow {
            label: "Resource".to_string(),
            value: res.clone(),
        });
    }

    let html = render_html_email(
        "Upcoming booking",
        &format!(
            "Reminder: you have a booking with {} coming up.",
            h(&details.guest_name)
        ),
        "#3b82f6",
        &rows,
        None,
    );

    let body = build_multipart_body(&plain, &html);

    let email = Message::builder()
        .from(config.mailbox_from()?)
        .to(to)
        .subject(format!(
            "Reminder: {} \u{2014} {} ({})",
            details.event_title, details.guest_name, date_display
        ))
        .multipart(body)?;

    send_email(config, email).await
}
