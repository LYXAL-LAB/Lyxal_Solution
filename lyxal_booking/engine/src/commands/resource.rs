use anyhow::{bail, Result};
use clap::Subcommand;
use lyxal_surreal::LyxalSurrealCall;
use serde::{Deserialize, Serialize};
use surrealdb::RecordId;
use tabled::{Table, Tabled};

use crate::db::SurrealBookingStore;

#[derive(Subcommand, Debug)]
pub enum ResourceCommands {
    /// List resources
    List,
    /// Add a new physical resource (meeting room, projector, etc.)
    Add {
        /// Name of the resource
        name: String,
        /// Maximum capacity (optional)
        #[arg(long)]
        capacity: Option<i32>,
        /// Location (optional)
        #[arg(long)]
        location: Option<String>,
        /// Description (optional)
        #[arg(long)]
        description: Option<String>,
    },
    /// Disable a resource
    Disable {
        /// Resource ID or UUID
        id: String,
    },
    /// Enable a resource
    Enable {
        /// Resource ID or UUID
        id: String,
    },
    /// Remove a resource
    Remove {
        /// Resource ID or UUID
        id: String,
    },
}

fn display_opt_i32(o: &Option<i32>) -> String {
    o.map(|v| v.to_string()).unwrap_or_default()
}

fn display_opt_str(o: &Option<String>) -> String {
    o.clone().unwrap_or_default()
}

#[derive(Debug, Deserialize, Tabled)]
pub struct ResourceRow {
    #[tabled(rename = "ID")]
    pub id: String,
    #[tabled(rename = "NAME")]
    pub name: String,
    #[tabled(rename = "CAPACITY", display_with = "display_opt_i32")]
    pub capacity: Option<i32>,
    #[tabled(rename = "LOCATION", display_with = "display_opt_str")]
    pub location: Option<String>,
    #[tabled(rename = "ENABLED")]
    pub enabled: bool,
}

#[derive(Debug, Serialize)]
struct CreateResourceParams {
    name: String,
    description: Option<String>,
    capacity: Option<i32>,
    location: Option<String>,
}

#[derive(Debug, Deserialize)]
struct CreateResourceResult {
    id: RecordId,
    created: bool,
}

#[derive(Debug, Serialize)]
struct SetResourceEnabledParams {
    resource_id: RecordId,
    enabled: bool,
}

#[derive(Debug, Deserialize)]
struct SetResourceEnabledResult {
    resource_id: RecordId,
    updated: bool,
}

#[derive(Debug, Serialize)]
struct DeleteResourceParams {
    resource_id: RecordId,
}

#[derive(Debug, Deserialize)]
struct DeleteResourceResult {
    resource_id: RecordId,
    deleted: bool,
}

fn parse_resource_id(raw: &str) -> Result<RecordId> {
    let clean = raw.trim();
    if let Some((table, id)) = clean.split_once(':') {
        if table != "booking_resource" {
            bail!("Expected booking_resource:<id>, got '{}'", clean);
        }
        return Ok(RecordId::from(("booking_resource", id)));
    }
    Ok(RecordId::from(("booking_resource", clean)))
}

pub async fn run(store: &SurrealBookingStore, cmd: ResourceCommands) -> Result<()> {
    match cmd {
        ResourceCommands::List => {
            let resources: Vec<ResourceRow> = store
                .call_fn("booking_list_resources", serde_json::json!({}))
                .await?;

            if resources.is_empty() {
                println!("No resources configured.");
            } else {
                println!("{}", Table::new(resources));
            }
        }
        ResourceCommands::Add {
            name,
            capacity,
            location,
            description,
        } => {
            let clean_name = name.trim();
            if clean_name.is_empty() {
                bail!("Resource name cannot be empty");
            }

            if capacity.is_some_and(|v| v <= 0) {
                bail!("Resource capacity must be greater than zero");
            }

            let params = CreateResourceParams {
                name: clean_name.to_string(),
                description,
                capacity,
                location,
            };

            let res: CreateResourceResult = store
                .call_fn("booking_create_resource", params)
                .await?;

            if !res.created {
                bail!("Failed to create resource '{}'", clean_name);
            }

            println!("Successfully created resource '{}' ({})", clean_name, res.id);
        }
        ResourceCommands::Disable { id } => {
            let resource_id = parse_resource_id(&id)?;
            let params = SetResourceEnabledParams {
                resource_id: resource_id.clone(),
                enabled: false,
            };

            let res: SetResourceEnabledResult = store
                .call_fn("booking_set_resource_enabled", params)
                .await?;

            if !res.updated {
                bail!("Failed to disable resource '{}'", resource_id);
            }

            println!("Successfully disabled resource '{}'", res.resource_id);
        }
        ResourceCommands::Enable { id } => {
            let resource_id = parse_resource_id(&id)?;
            let params = SetResourceEnabledParams {
                resource_id: resource_id.clone(),
                enabled: true,
            };

            let res: SetResourceEnabledResult = store
                .call_fn("booking_set_resource_enabled", params)
                .await?;

            if !res.updated {
                bail!("Failed to enable resource '{}'", resource_id);
            }

            println!("Successfully enabled resource '{}'", res.resource_id);
        }
        ResourceCommands::Remove { id } => {
            let resource_id = parse_resource_id(&id)?;
            let params = DeleteResourceParams {
                resource_id: resource_id.clone(),
            };

            let res: DeleteResourceResult = store
                .call_fn("booking_delete_resource", params)
                .await?;

            if !res.deleted {
                bail!("Failed to remove resource '{}'", resource_id);
            }

            println!("Successfully removed resource '{}'", res.resource_id);
        }
    }
    Ok(())
}
