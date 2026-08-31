use anyhow::{bail, Result};
use clap::Subcommand;
use lyxal_surreal::LyxalSurrealCall;
use serde::{Deserialize, Serialize};
use surrealdb::RecordId;
use tabled::{Table, Tabled};
use uuid::Uuid;

use crate::crypto_helpers::{encrypt_caldav_password, BookingCryptoEngine};
use crate::db::SurrealBookingStore;
use crate::providers;
use crate::settings;
use crate::utils::{prompt_password, validate_outbound_url};

#[derive(Debug, Clone, clap::ValueEnum, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum ProviderKind {
    Caldav,
    Ews,
}

impl ProviderKind {
    pub fn as_str(&self) -> &'static str {
        match self {
            ProviderKind::Caldav => "caldav",
            ProviderKind::Ews => "ews",
        }
    }
}

#[derive(Debug, Clone, clap::ValueEnum, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum AuthKind {
    Basic,
    Oauth2,
}

impl AuthKind {
    pub fn as_str(&self) -> &'static str {
        match self {
            AuthKind::Basic => "basic",
            AuthKind::Oauth2 => "oauth2",
        }
    }
}

#[derive(Subcommand, Debug)]
pub enum SourceCommands {
    /// List calendar sources
    List,
    /// Add a new calendar source
    Add {
        /// Provider type (caldav, ews)
        #[arg(long, value_enum, default_value_t = ProviderKind::Caldav)]
        provider: ProviderKind,
        /// Authentication mechanism (basic, oauth2)
        #[arg(long, value_enum, default_value_t = AuthKind::Basic)]
        auth: AuthKind,
        /// Server base URL
        #[arg(long)]
        url: String,
        /// Account username or email
        #[arg(long)]
        username: String,
    },
    /// Disable a calendar source
    Disable {
        /// Source record ID or UUID
        id: String,
    },
    /// Enable a calendar source
    Enable {
        /// Source record ID or UUID
        id: String,
    },
    /// Permanently remove a calendar source
    Remove {
        /// Source record ID or UUID
        id: String,
    },
}

#[derive(Debug, Serialize)]
struct CreateSourceParams {
    id: RecordId,
    account_id: RecordId,
    provider: String,
    auth_kind: String,
    url: String,
    username: String,
    password_enc: Option<String>,
}

#[derive(Debug, Deserialize)]
struct CreateSourceResult {
    id: RecordId,
    created: bool,
}

#[derive(Debug, Deserialize, Tabled)]
struct SourceRow {
    #[tabled(rename = "ID")]
    id: String,
    #[tabled(rename = "PROVIDER")]
    provider: String,
    #[tabled(rename = "AUTH")]
    auth_kind: String,
    #[tabled(rename = "URL")]
    url: String,
    #[tabled(rename = "USERNAME")]
    username: String,
    #[tabled(rename = "STATUS")]
    sync_status: String,
}

#[derive(Debug, Serialize)]
struct ListSourcesParams {
    account_id: RecordId,
}

#[derive(Debug, Serialize)]
struct SetSourceEnabledParams {
    source_id: RecordId,
    enabled: bool,
}

#[derive(Debug, Deserialize)]
struct SetSourceEnabledResult {
    source_id: RecordId,
    updated: bool,
}

#[derive(Debug, Serialize)]
struct DeleteSourceParams {
    source_id: RecordId,
}

#[derive(Debug, Deserialize)]
struct DeleteSourceResult {
    source_id: RecordId,
    deleted: bool,
}

fn parse_source_id(raw: &str) -> Result<RecordId> {
    let clean = raw.trim();
    if let Some((table, id)) = clean.split_once(':') {
        if table != "booking_caldav_source" {
            bail!("Expected booking_caldav_source:<id>, got '{}'", clean);
        }
        return Ok(RecordId::from(("booking_caldav_source", id)));
    }
    Ok(RecordId::from(("booking_caldav_source", clean)))
}

pub async fn run(
    store: &SurrealBookingStore,
    crypto: &BookingCryptoEngine,
    tenant: &str,
    account_id: &RecordId,
    cmd: SourceCommands,
) -> Result<()> {
    match cmd {
        SourceCommands::List => {
            let params = ListSourcesParams {
                account_id: account_id.clone(),
            };
            let sources: Vec<SourceRow> = store
                .call_fn("booking_get_user_caldav_sources", params)
                .await?;

            if sources.is_empty() {
                println!("No calendar sources configured.");
            } else {
                println!("{}", Table::new(sources));
            }
        }
        SourceCommands::Add {
            provider,
            auth,
            url,
            username,
        } => {
            // 1. Validation de la combinaison Provider / AuthKind
            match (&provider, &auth) {
                (ProviderKind::Caldav, AuthKind::Basic) => {}
                (ProviderKind::Caldav, AuthKind::Oauth2) => {}
                (ProviderKind::Ews, AuthKind::Basic) => {}
                (ProviderKind::Ews, AuthKind::Oauth2) => {
                    bail!("EWS OAuth2 authentication is not supported yet.");
                }
            }

            // 2. Validation d'URL par provider
            providers::factory::validate_url(provider.as_str(), &url)?;

            // 3. Validation SSRF de l'URL sortante
            let allowlist = settings::private_host_allowlist();
            validate_outbound_url(&url, &allowlist).await?;

            // 4. Identifiant canonique de la source
            let source_id = RecordId::from((
                "booking_caldav_source",
                Uuid::new_v4().to_string(),
            ));

            // 5. Traitement du mot de passe selon AuthKind
            let password_enc = match auth {
                AuthKind::Basic => {
                    let raw_password = prompt_password("Password: ")?;
                    let encrypted = encrypt_caldav_password(
                        crypto,
                        tenant,
                        &source_id,
                        raw_password.as_bytes(),
                    )?;
                    Some(encrypted)
                }
                AuthKind::Oauth2 => None,
            };

            let params = CreateSourceParams {
                id: source_id.clone(),
                account_id: account_id.clone(),
                provider: provider.as_str().to_string(),
                auth_kind: auth.as_str().to_string(),
                url: url.clone(),
                username: username.clone(),
                password_enc,
            };

            // 6. Exécution typée de la fonction SurrealQL
            let res: CreateSourceResult = store
                .call_fn("booking_create_caldav_source", params)
                .await?;

            if !res.created {
                bail!("The calendar source was not created.");
            }

            if matches!(auth, AuthKind::Oauth2) {
                println!(
                    "Source '{}' created in 'pending_oauth' state. Please complete the OAuth consent flow to authenticate.",
                    res.id
                );
            } else {
                println!("Successfully created calendar source '{}' ({})", res.id, url);
            }
        }
        SourceCommands::Disable { id } => {
            let source_id = parse_source_id(&id)?;
            let params = SetSourceEnabledParams {
                source_id: source_id.clone(),
                enabled: false,
            };

            let res: SetSourceEnabledResult = store
                .call_fn("booking_set_caldav_source_enabled", params)
                .await?;

            if !res.updated {
                bail!("Failed to disable calendar source '{}'", source_id);
            }

            println!("Successfully disabled calendar source '{}'", res.source_id);
        }
        SourceCommands::Enable { id } => {
            let source_id = parse_source_id(&id)?;
            let params = SetSourceEnabledParams {
                source_id: source_id.clone(),
                enabled: true,
            };

            let res: SetSourceEnabledResult = store
                .call_fn("booking_set_caldav_source_enabled", params)
                .await?;

            if !res.updated {
                bail!("Failed to enable calendar source '{}'", source_id);
            }

            println!("Successfully enabled calendar source '{}'", res.source_id);
        }
        SourceCommands::Remove { id } => {
            let source_id = parse_source_id(&id)?;
            let params = DeleteSourceParams {
                source_id: source_id.clone(),
            };

            let res: DeleteSourceResult = store
                .call_fn("booking_delete_caldav_source", params)
                .await?;

            if !res.deleted {
                bail!("Failed to remove calendar source '{}'", source_id);
            }

            println!("Successfully removed calendar source '{}'", res.source_id);
        }
    }
    Ok(())
}
