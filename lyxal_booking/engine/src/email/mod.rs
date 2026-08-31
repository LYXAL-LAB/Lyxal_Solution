//! Lyxal Booking Email Service and Templates.

pub mod approval;
pub mod cancellation;
pub mod claim;
pub mod config;
pub mod dto;
pub mod guest;
pub mod host;
pub mod html;
pub mod i18n;
pub mod ics;
pub mod invitation;
pub mod reminder;
pub mod reschedule;
pub mod timezone;
pub mod transport;

#[cfg(test)]
mod tests;

// Re-exports for 100% import compatibility
pub use approval::*;
pub use cancellation::*;
pub use claim::*;
pub use config::{
    determine_smtp_password_format, load_smtp_config, load_smtp_config_from_env, load_smtp_status,
    smtp_env_active, SmtpConfig, SmtpStatus, SmtpTlsMode, StoredSmtpPasswordFormat,
};
pub use dto::{BookingDetails, CancellationDetails, RescheduleDetails};
pub use guest::*;
pub use host::*;
pub use ics::{generate_cancel_ics, generate_ics, generate_ics_caldav, sanitize_ics};
pub use invitation::*;
pub use reminder::*;
pub use reschedule::*;
pub use timezone::host_time_display;

/// Complete EmailService façade wrapping purely `SmtpConfig` without database or crypto dependencies.
pub struct EmailService {
    config: SmtpConfig,
}

impl EmailService {
    pub fn new(config: SmtpConfig) -> Self {
        Self { config }
    }

    pub fn config(&self) -> &SmtpConfig {
        &self.config
    }

    pub async fn send_guest_confirmation(
        &self,
        details: &BookingDetails,
        cancel_url: Option<&str>,
    ) -> anyhow::Result<()> {
        guest::send_guest_confirmation(&self.config, details, cancel_url).await
    }

    pub async fn send_guest_confirmation_ex(
        &self,
        details: &BookingDetails,
        cancel_url: Option<&str>,
        reschedule_url: Option<&str>,
        cancel_notice_min: Option<i32>,
        reschedule_notice_min: Option<i32>,
    ) -> anyhow::Result<()> {
        guest::send_guest_confirmation_ex(
            &self.config,
            details,
            cancel_url,
            reschedule_url,
            cancel_notice_min,
            reschedule_notice_min,
        )
        .await
    }

    pub async fn send_guest_pending_notice(
        &self,
        details: &BookingDetails,
        cancel_url: Option<&str>,
    ) -> anyhow::Result<()> {
        guest::send_guest_pending_notice(&self.config, details, cancel_url).await
    }

    pub async fn send_guest_pending_notice_ex(
        &self,
        details: &BookingDetails,
        cancel_url: Option<&str>,
        reschedule_url: Option<&str>,
    ) -> anyhow::Result<()> {
        guest::send_guest_pending_notice_ex(&self.config, details, cancel_url, reschedule_url).await
    }

    pub async fn send_host_notification(
        &self,
        details: &BookingDetails,
    ) -> anyhow::Result<()> {
        host::send_host_notification(&self.config, details).await
    }

    pub async fn send_host_booking_confirmed(
        &self,
        details: &BookingDetails,
    ) -> anyhow::Result<()> {
        host::send_host_booking_confirmed(&self.config, details).await
    }

    pub async fn send_guest_reminder(
        &self,
        details: &BookingDetails,
        cancel_url: Option<&str>,
    ) -> anyhow::Result<()> {
        reminder::send_guest_reminder(&self.config, details, cancel_url).await
    }

    pub async fn send_host_reminder(
        &self,
        details: &BookingDetails,
    ) -> anyhow::Result<()> {
        reminder::send_host_reminder(&self.config, details).await
    }

    pub async fn send_guest_cancellation(
        &self,
        details: &CancellationDetails,
    ) -> anyhow::Result<()> {
        cancellation::send_guest_cancellation(&self.config, details).await
    }

    pub async fn send_host_cancellation(
        &self,
        details: &CancellationDetails,
    ) -> anyhow::Result<()> {
        cancellation::send_host_cancellation(&self.config, details).await
    }

    pub async fn send_host_approval_request(
        &self,
        details: &BookingDetails,
        booking_id: &str,
        confirm_token: Option<&str>,
        base_url: Option<&str>,
    ) -> anyhow::Result<()> {
        approval::send_host_approval_request(&self.config, details, booking_id, confirm_token, base_url).await
    }

    pub async fn send_guest_decline_notice(
        &self,
        details: &CancellationDetails,
    ) -> anyhow::Result<()> {
        approval::send_guest_decline_notice(&self.config, details).await
    }

    pub async fn send_test_email(&self, to_email: &str) -> anyhow::Result<()> {
        invitation::send_test_email(&self.config, to_email).await
    }

    pub async fn send_invite_email(
        &self,
        guest_name: &str,
        guest_email: &str,
        event_title: &str,
        host_name: &str,
        message: Option<&str>,
        invite_url: &str,
        expires_at: Option<&str>,
    ) -> anyhow::Result<()> {
        invitation::send_invite_email(
            &self.config,
            guest_name,
            guest_email,
            event_title,
            host_name,
            message,
            invite_url,
            expires_at,
        )
        .await
    }

    pub async fn send_guest_pick_new_time(
        &self,
        details: &BookingDetails,
        reschedule_url: &str,
        cancel_url: Option<&str>,
    ) -> anyhow::Result<()> {
        reschedule::send_guest_pick_new_time(&self.config, details, reschedule_url, cancel_url).await
    }

    pub async fn send_guest_reschedule_notification(
        &self,
        details: &RescheduleDetails,
        cancel_url: Option<&str>,
        reschedule_url: Option<&str>,
    ) -> anyhow::Result<()> {
        reschedule::send_guest_reschedule_notification(&self.config, details, cancel_url, reschedule_url).await
    }

    pub async fn send_host_reschedule_request(
        &self,
        details: &RescheduleDetails,
        confirm_token: Option<&str>,
        base_url: Option<&str>,
    ) -> anyhow::Result<()> {
        reschedule::send_host_reschedule_request(&self.config, details, confirm_token, base_url).await
    }

    pub async fn send_watcher_claim_notification(
        &self,
        details: &BookingDetails,
        watcher_name: &str,
        watcher_email: &str,
        assigned_to_name: &str,
        claim_url: &str,
    ) -> anyhow::Result<()> {
        claim::send_watcher_claim_notification(
            &self.config,
            details,
            watcher_name,
            watcher_email,
            assigned_to_name,
            claim_url,
        )
        .await
    }

    pub async fn send_claim_confirmation(
        &self,
        details: &BookingDetails,
        claimant_name: &str,
        claimant_email: &str,
    ) -> anyhow::Result<()> {
        claim::send_claim_confirmation(&self.config, details, claimant_name, claimant_email).await
    }
}
