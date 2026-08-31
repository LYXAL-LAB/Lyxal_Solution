//! Guest email sending functions for confirmations and pending notices.

use anyhow::Result;
use lettre::message::header::ContentType;
use lettre::message::{Attachment, MultiPart, Message};

use super::config::SmtpConfig;
use super::dto::{BookingDetails, EmailAction, EmailRow};
use super::html::{build_multipart_body, h, render_html_email_with_actions};
use super::i18n::{guest_lang, t, ta};
use super::ics::generate_ics;
use super::transport::send_email;

/// Send booking confirmation to the guest
pub async fn send_guest_confirmation(
    config: &SmtpConfig,
    details: &BookingDetails,
    cancel_url: Option<&str>,
) -> Result<()> {
    send_guest_confirmation_ex(config, details, cancel_url, None, None, None).await
}

pub async fn send_guest_confirmation_ex(
    config: &SmtpConfig,
    details: &BookingDetails,
    cancel_url: Option<&str>,
    reschedule_url: Option<&str>,
    cancel_notice_min: Option<i32>,
    reschedule_notice_min: Option<i32>,
) -> Result<()> {
    let ics = generate_ics(details, "REQUEST");
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
    let headline = t(lang, "email-confirm-headline");
    let label_event = t(lang, "confirmed-detail-event");
    let label_date = t(lang, "confirmed-detail-date");
    let label_time = t(lang, "confirmed-detail-time");
    let label_with = t(lang, "confirmed-detail-with");
    let label_location = t(lang, "confirmed-detail-location");
    let label_notes = t(lang, "confirmed-detail-notes");
    let ics_attached_plain = t(lang, "email-confirm-ics-attached-plain");
    let ics_attached_html = t(lang, "email-confirm-ics-attached-html");
    let signature = t(lang, "email-signature");

    let cancel_notice_line = cancel_notice_min.filter(|m| *m > 0).map(|m| {
        ta(
            lang,
            "email-confirm-cancel-notice",
            [("minutes", m.to_string().as_str())],
        )
    });
    let reschedule_notice_line = reschedule_notice_min.filter(|m| *m > 0).map(|m| {
        ta(
            lang,
            "email-confirm-reschedule-notice",
            [("minutes", m.to_string().as_str())],
        )
    });

    let plain = format!(
        "{}\n\n\
         {}\n\n\
         {} {}\n\
         {} {}\n\
         {} {}\n\
         {} {}\n\
         {}{}\
         {}\n\
         {}{}{}\
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
        details
            .notes
            .as_ref()
            .map(|n| format!("{} {}\n", label_notes, n))
            .unwrap_or_default(),
        ics_attached_plain,
        reschedule_notice_line
            .as_ref()
            .map(|l| format!("\n{}\n", l))
            .unwrap_or_default(),
        cancel_notice_line
            .as_ref()
            .map(|l| format!("\n{}\n", l))
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
    if let Some(notes) = &details.notes {
        rows.push(EmailRow {
            label: label_notes.clone(),
            value: notes.clone(),
        });
    }

    let mut actions: Vec<EmailAction> = Vec::new();
    if let Some(u) = reschedule_url {
        actions.push(EmailAction {
            label: t(lang, "email-action-reschedule"),
            url: u.to_string(),
            color: "#3b82f6".to_string(),
        });
    }
    if let Some(u) = cancel_url {
        actions.push(EmailAction {
            label: t(lang, "email-action-cancel-booking"),
            url: u.to_string(),
            color: "#dc2626".to_string(),
        });
    }

    let mut footer_note_html = ics_attached_html.clone();
    if let Some(line) = &reschedule_notice_line {
        footer_note_html.push('\n');
        footer_note_html.push_str(line);
    }
    if let Some(line) = &cancel_notice_line {
        footer_note_html.push('\n');
        footer_note_html.push_str(line);
    }
    let html = render_html_email_with_actions(
        &h(&greeting),
        &headline,
        "#16a34a",
        &rows,
        Some(&footer_note_html),
        &actions,
    );

    let body = build_multipart_body(&plain, &html);

    let ics_attachment = Attachment::new("invite.ics".to_string()).body(
        ics,
        ContentType::parse("text/calendar; method=REQUEST; charset=UTF-8")?,
    );

    let subject = ta(
        lang,
        "email-confirm-subject",
        [("event", &details.event_title), ("date", &details.date)],
    );

    let from = config.mailbox_from()?;

    let email = Message::builder()
        .from(from.clone())
        .to(to)
        .subject(subject)
        .multipart(
            MultiPart::mixed()
                .multipart(body)
                .singlepart(ics_attachment),
        )?;

    send_email(config, email).await?;

    for attendee_email in &details.additional_attendees {
        let ics2 = generate_ics(details, "REQUEST");
        let to2: lettre::message::Mailbox = attendee_email.parse()?;
        let plain2 = format!(
            "Hi,\n\n\
             You've been added as an attendee to a booking.\n\n\
             Event: {}\n\
             Date: {}\n\
             Time: {} \u{2013} {} ({})\n\
             Organizer: {}\n\
             Booked by: {} <{}>\n\n\
             A calendar invite is attached.\n\n\
             \u{2014} calrs",
            details.event_title,
            details.date,
            details.start_time,
            details.end_time,
            details.guest_timezone,
            details.host_name,
            details.guest_name,
            details.guest_email,
        );
        let html2 = super::html::render_html_email(
            "Hi,",
            "You've been added as an attendee to a booking.",
            "#16a34a",
            &[
                EmailRow {
                    label: "Event".to_string(),
                    value: details.event_title.clone(),
                },
                EmailRow {
                    label: "Date".to_string(),
                    value: details.date.clone(),
                },
                EmailRow {
                    label: "Time".to_string(),
                    value: format!(
                        "{} \u{2013} {} ({})",
                        details.start_time, details.end_time, details.guest_timezone
                    ),
                },
                EmailRow {
                    label: "Organizer".to_string(),
                    value: details.host_name.clone(),
                },
                EmailRow {
                    label: "Booked by".to_string(),
                    value: format!("{} <{}>", details.guest_name, details.guest_email),
                },
            ],
            Some("A calendar invite is attached to this email."),
        );
        let body2 = build_multipart_body(&plain2, &html2);
        let att2 = Attachment::new("invite.ics".to_string()).body(
            ics2,
            ContentType::parse("text/calendar; method=REQUEST; charset=UTF-8")?,
        );
        let email2 = Message::builder()
            .from(from.clone())
            .to(to2)
            .subject(format!(
                "Invite: {} \u{2014} {}",
                details.event_title, details.date
            ))
            .multipart(MultiPart::mixed().multipart(body2).singlepart(att2))?;
        if let Err(e) = send_email(config, email2).await {
            tracing::warn!(attendee = %attendee_email, error = %e, "failed to send attendee confirmation");
        }
    }

    Ok(())
}

/// Send pending notice to guest (booking awaits host approval)
pub async fn send_guest_pending_notice(
    config: &SmtpConfig,
    details: &BookingDetails,
    cancel_url: Option<&str>,
) -> Result<()> {
    send_guest_pending_notice_ex(config, details, cancel_url, None).await
}

pub async fn send_guest_pending_notice_ex(
    config: &SmtpConfig,
    details: &BookingDetails,
    cancel_url: Option<&str>,
    reschedule_url: Option<&str>,
) -> Result<()> {
    let to = format!("{} <{}>", details.guest_name, details.guest_email).parse()?;

    let time_display = format!(
        "{} \u{2013} {} ({})",
        details.start_time, details.end_time, details.guest_timezone
    );

    let plain = format!(
        "Hi {},\n\n\
         Your booking request has been received and is awaiting confirmation from {}.\n\n\
         Event: {}\n\
         Date: {}\n\
         Time: {}\n\
         {}\
         You'll receive another email once it's confirmed.\n\
         {}\n\
         \u{2014} calrs",
        details.guest_name,
        details.host_name,
        details.event_title,
        details.date,
        time_display,
        details
            .notes
            .as_ref()
            .map(|n| format!("Notes: {}\n", n))
            .unwrap_or_default(),
        cancel_url
            .map(|u| format!("\nNeed to cancel? {}\n", u))
            .unwrap_or_default(),
    );

    let mut rows = vec![
        EmailRow {
            label: "Event".to_string(),
            value: details.event_title.clone(),
        },
        EmailRow {
            label: "Date".to_string(),
            value: details.date.clone(),
        },
        EmailRow {
            label: "Time".to_string(),
            value: time_display,
        },
        EmailRow {
            label: "Host".to_string(),
            value: details.host_name.clone(),
        },
    ];
    if let Some(notes) = &details.notes {
        rows.push(EmailRow {
            label: "Notes".to_string(),
            value: notes.clone(),
        });
    }

    let mut actions: Vec<EmailAction> = Vec::new();
    if let Some(u) = reschedule_url {
        actions.push(EmailAction {
            label: "Reschedule".to_string(),
            url: u.to_string(),
            color: "#3b82f6".to_string(),
        });
    }
    if let Some(u) = cancel_url {
        actions.push(EmailAction {
            label: "Cancel booking".to_string(),
            url: u.to_string(),
            color: "#dc2626".to_string(),
        });
    }

    let html = render_html_email_with_actions(
        &format!("Hi {},", h(&details.guest_name)),
        &format!(
            "Your booking request is awaiting confirmation from {}.",
            h(&details.host_name)
        ),
        "#f59e0b",
        &rows,
        Some("You\u{2019}ll receive another email once it\u{2019}s confirmed."),
        &actions,
    );

    let body = build_multipart_body(&plain, &html);

    let email = Message::builder()
        .from(config.mailbox_from()?)
        .to(to)
        .subject(format!(
            "Booking requested: {} \u{2014} {}",
            details.event_title, details.date
        ))
        .multipart(body)?;

    send_email(config, email).await
}
