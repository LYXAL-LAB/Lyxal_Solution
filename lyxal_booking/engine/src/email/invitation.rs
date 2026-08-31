//! Booking invitation and SMTP test email functions.

use anyhow::Result;
use lettre::message::Message;

use super::config::SmtpConfig;
use super::dto::{EmailAction, EmailRow};
use super::html::{build_multipart_body, h, render_html_email, render_html_email_with_actions};
use super::transport::send_email;

/// Send a test email
pub async fn send_test_email(config: &SmtpConfig, to_email: &str) -> Result<()> {
    let to = to_email.parse()?;

    let plain = "This is a test email from calrs. SMTP is working!".to_string();

    let html = render_html_email(
        "SMTP test",
        "This is a test email from calrs. SMTP is working!",
        "#6366f1",
        &[],
        None,
    );

    let body = build_multipart_body(&plain, &html);

    let email = Message::builder()
        .from(config.mailbox_from()?)
        .to(to)
        .subject("calrs \u{2014} SMTP test")
        .multipart(body)?;

    tracing::debug!("Sending: {:?}", email);
    send_email(config, email).await
}

/// Send a booking invite email to a guest
pub async fn send_invite_email(
    config: &SmtpConfig,
    guest_name: &str,
    guest_email: &str,
    event_title: &str,
    host_name: &str,
    message: Option<&str>,
    invite_url: &str,
    expires_at: Option<&str>,
) -> Result<()> {
    let from = config.mailbox_from()?;
    let to = format!("{} <{}>", guest_name, guest_email).parse()?;

    let expiry_note = expires_at
        .map(|e| format!("\nThis invite expires on {}.", e))
        .unwrap_or_default();
    let message_note = message
        .filter(|m| !m.trim().is_empty())
        .map(|m| format!("\n\n\"{}\"\n", m))
        .unwrap_or_default();

    let plain = format!(
        "Hi {},\n\n\
         {} has invited you to book: {}\n\
         {}\
         Click the link below to choose a time:\n\
         {}\n\
         {}\n\
         \u{2014} calrs",
        guest_name, host_name, event_title, message_note, invite_url, expiry_note,
    );

    let mut rows = vec![
        EmailRow {
            label: "Event".to_string(),
            value: event_title.to_string(),
        },
        EmailRow {
            label: "Invited by".to_string(),
            value: host_name.to_string(),
        },
    ];
    if let Some(msg) = message.filter(|m| !m.trim().is_empty()) {
        rows.push(EmailRow {
            label: "Note".to_string(),
            value: msg.to_string(),
        });
    }

    let actions = vec![EmailAction {
        label: "Book a time".to_string(),
        url: invite_url.to_string(),
        color: "#16a34a".to_string(),
    }];

    let footer_text = expires_at.map(|e| format!("This invite expires on {}.", e));

    let html = render_html_email_with_actions(
        &format!("Hi {},", h(guest_name)),
        &format!("{} has invited you to book a time.", h(host_name)),
        "#16a34a",
        &rows,
        footer_text.as_deref(),
        &actions,
    );

    let body = build_multipart_body(&plain, &html);

    let email = Message::builder()
        .from(from)
        .to(to)
        .subject(format!("Invitation: {} from {}", event_title, host_name))
        .multipart(body)?;

    send_email(config, email).await
}
