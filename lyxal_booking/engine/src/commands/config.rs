use anyhow::{bail, Result};
use clap::Subcommand;
use lyxal_surreal::LyxalSurrealCall;
use serde::{Deserialize, Serialize};

use crate::crypto_helpers::BookingCryptoEngine;
use crate::db::SurrealBookingStore;
use crate::integrations;
use crate::settings;
use crate::utils::{prompt_password, validate_outbound_url};

#[derive(Subcommand, Debug)]
pub enum ConfigCommands {
    /// Show current runtime settings
    Show,
    /// Set public base URL
    SetBaseUrl {
        /// Public base URL of the booking service (e.g. https://booking.company.com/)
        url: String,
    },
    /// Set SSRF private hosts allowlist
    SetPrivateHosts {
        /// Comma-separated allowlist of internal domain/IP patterns
        allow: String,
    },
    /// Configure SMTP email server credentials
    Smtp {
        /// SMTP host
        #[arg(long)]
        host: String,
        /// SMTP port
        #[arg(long, default_value = "587")]
        port: u16,
        /// SMTP username
        #[arg(long)]
        username: String,
        /// Default sender email address
        #[arg(long)]
        from_email: String,
    },
    /// Configure Captcha verification settings
    Captcha {
        /// Captcha site key (public)
        #[arg(long)]
        site_key: String,
    },
    /// Configure Video Meeting Webhook settings
    Meeting {
        /// Webhook URL endpoint
        #[arg(long)]
        webhook_url: String,
    },
    /// Configure Google OAuth2 application credentials
    Oauth {
        /// Google OAuth2 client ID
        #[arg(long)]
        client_id: String,
    },
}

#[derive(Debug, Deserialize)]
struct RuntimeSettingsData {
    base_url: Option<String>,
    allow_private_hosts: Option<String>,
}

#[derive(Debug, Serialize)]
struct SetSettingParams {
    key: String,
    value: String,
}

#[derive(Debug, Deserialize)]
struct SetSettingResult {
    key: String,
    updated: bool,
}

fn normalize_base_url(raw: &str) -> Result<String> {
    let clean = raw.trim();
    let url = url::Url::parse(clean)?;
    if url.scheme() != "http" && url.scheme() != "https" {
        bail!("Base URL scheme must be http or https");
    }
    if url.host_str().is_none() {
        bail!("Base URL must contain a valid host");
    }
    if !url.username().is_empty() || url.password().is_some() {
        bail!("Base URL cannot contain user credentials");
    }
    let mut base = format!("{}://{}", url.scheme(), url.host_str().unwrap());
    if let Some(port) = url.port() {
        base.push_str(&format!(":{}", port));
    }
    base.push_str(url.path());
    if !base.ends_with('/') {
        base.push('/');
    }
    Ok(base)
}

pub async fn run(
    store: &SurrealBookingStore,
    crypto: &BookingCryptoEngine,
    tenant: &str,
    cmd: ConfigCommands,
) -> Result<()> {
    match cmd {
        ConfigCommands::Show => {
            let config: RuntimeSettingsData = store
                .call_fn("booking_get_runtime_settings", serde_json::json!({}))
                .await?;

            println!("--- Lyxal Booking Configuration ---");
            println!("Base URL             : {}", config.base_url.unwrap_or_else(|| "Not set".into()));
            println!("Allowed Private Hosts: {}", config.allow_private_hosts.unwrap_or_else(|| "None".into()));
        }
        ConfigCommands::SetBaseUrl { url } => {
            let normalized_url = normalize_base_url(&url)?;

            let params = SetSettingParams {
                key: "base_url".to_string(),
                value: normalized_url.clone(),
            };

            let res: SetSettingResult = store
                .call_fn("booking_set_runtime_setting", params)
                .await?;

            if !res.updated {
                bail!("Failed to update base_url in database.");
            }

            // Rechargement immédiat du cache snapshot en mémoire
            settings::load(store).await?;

            println!("Successfully set base_url to '{}' and reloaded settings cache.", normalized_url);
        }
        ConfigCommands::SetPrivateHosts { allow } => {
            // Validation et normalisation de la liste des hôtes avant écriture en DB
            let parsed_hosts = settings::parse_host_list(&allow)?;
            let canonical_value = parsed_hosts.join(",");

            let params = SetSettingParams {
                key: "allow_private_hosts".to_string(),
                value: canonical_value.clone(),
            };

            let res: SetSettingResult = store
                .call_fn("booking_set_runtime_setting", params)
                .await?;

            if !res.updated {
                bail!("Failed to update allow_private_hosts in database.");
            }

            // Rechargement immédiat du cache snapshot en mémoire
            settings::load(store).await?;

            println!("Successfully set allow_private_hosts to '{}' and reloaded settings cache.", canonical_value);
        }
        ConfigCommands::Smtp {
            host,
            port,
            username,
            from_email,
        } => {
            let raw_password = prompt_password("SMTP Password: ")?;
            integrations::smtp_config::set_smtp_config(
                store,
                crypto,
                tenant,
                &host,
                port,
                &username,
                &raw_password,
                &from_email,
            )
            .await?;

            println!("Successfully configured SMTP settings for host '{}'.", host);
        }
        ConfigCommands::Captcha { site_key } => {
            let raw_secret = prompt_password("Captcha Secret Key: ")?;
            integrations::captcha_config::set_captcha_config(
                store,
                crypto,
                tenant,
                &site_key,
                &raw_secret,
            )
            .await?;

            println!("Successfully configured Captcha settings (Site Key: '{}').", site_key);
        }
        ConfigCommands::Meeting { webhook_url } => {
            let allowlist = settings::private_host_allowlist();
            validate_outbound_url(&webhook_url, &allowlist).await?;

            let raw_secret = prompt_password("Meeting Webhook Secret: ")?;
            integrations::meeting_config::set_meeting_config(
                store,
                crypto,
                tenant,
                &webhook_url,
                &raw_secret,
            )
            .await?;

            println!("Successfully configured Meeting Webhook settings (URL: '{}').", webhook_url);
        }
        ConfigCommands::Oauth { client_id } => {
            let raw_secret = prompt_password("Google Client Secret: ")?;
            integrations::oauth_config::set_google_oauth_config(
                store,
                crypto,
                tenant,
                &client_id,
                &raw_secret,
            )
            .await?;

            println!("Successfully configured Google OAuth settings (Client ID: '{}').", client_id);
        }
    }
    Ok(())
}
