use anyhow::{bail, Result};
use clap::Subcommand;
use lyxal_surreal::LyxalSurrealCall;
use serde::{Deserialize, Serialize};
use surrealdb::RecordId;
use tabled::{Table, Tabled};

use crate::db::SurrealBookingStore;

#[derive(Subcommand, Debug)]
pub enum EventTypeCommands {
    /// List event types
    List,
    /// Create a new event type
    Create {
        /// Title of the event type
        title: String,
        /// Unique URL slug
        slug: String,
        /// Duration in minutes
        #[arg(long, default_value = "30")]
        duration_min: i32,
    },
    /// Delete an event type
    Delete {
        /// Event type record ID or UUID
        id: String,
    },
}

#[derive(Debug, Deserialize, Tabled)]
pub struct EventTypeRow {
    #[tabled(rename = "ID")]
    pub id: String,
    #[tabled(rename = "TITLE")]
    pub title: String,
    #[tabled(rename = "SLUG")]
    pub slug: String,
    #[tabled(rename = "DURATION")]
    pub duration_min: i32,
    #[tabled(rename = "ENABLED")]
    pub enabled: bool,
}

#[derive(Debug, Serialize)]
struct CreateEventTypeParams {
    title: String,
    slug: String,
    duration_min: i32,
}

#[derive(Debug, Deserialize)]
struct CreateEventTypeResult {
    id: RecordId,
    created: bool,
}

#[derive(Debug, Serialize)]
struct DeleteEventTypeParams {
    id: RecordId,
}

#[derive(Debug, Deserialize)]
struct DeleteEventTypeResult {
    id: RecordId,
    deleted: bool,
}

fn validate_slug(slug: &str) -> Result<()> {
    let clean = slug.trim();
    if clean.is_empty()
        || clean.len() > 100
        || clean.starts_with('-')
        || clean.ends_with('-')
        || clean.contains("--")
        || !clean
            .chars()
            .all(|c| c.is_ascii_lowercase() || c.is_ascii_digit() || c == '-')
    {
        bail!(
            "Invalid slug '{}': must be 1-100 characters containing lowercase letters, numbers, or single dashes, and cannot start or end with a dash",
            clean
        );
    }
    Ok(())
}

fn parse_event_type_id(raw: &str) -> Result<RecordId> {
    let clean = raw.trim();
    if let Some((table, id)) = clean.split_once(':') {
        if table != "booking_event_type" {
            bail!("Expected booking_event_type:<id>, got '{}'", clean);
        }
        return Ok(RecordId::from(("booking_event_type", id)));
    }
    Ok(RecordId::from(("booking_event_type", clean)))
}

pub async fn run(store: &SurrealBookingStore, cmd: EventTypeCommands) -> Result<()> {
    match cmd {
        EventTypeCommands::List => {
            let event_types: Vec<EventTypeRow> = store
                .call_fn("booking_list_event_types", serde_json::json!({}))
                .await?;

            if event_types.is_empty() {
                println!("No event types configured.");
            } else {
                println!("{}", Table::new(event_types));
            }
        }
        EventTypeCommands::Create {
            title,
            slug,
            duration_min,
        } => {
            let clean_title = title.trim();
            if clean_title.is_empty() {
                bail!("Title cannot be empty.");
            }

            validate_slug(&slug)?;
            if duration_min <= 0 {
                bail!("Duration must be greater than 0 minutes.");
            }

            let params = CreateEventTypeParams {
                title: clean_title.to_string(),
                slug: slug.trim().to_string(),
                duration_min,
            };

            let res: CreateEventTypeResult = store
                .call_fn("booking_create_event_type", params)
                .await?;

            if !res.created {
                bail!("Failed to create event type '{}'", clean_title);
            }

            println!("Successfully created event type '{}' ({})", clean_title, res.id);
        }
        EventTypeCommands::Delete { id } => {
            let record_id = parse_event_type_id(&id)?;
            let params = DeleteEventTypeParams { id: record_id.clone() };

            let res: DeleteEventTypeResult = store
                .call_fn("booking_delete_event_type", params)
                .await?;

            if !res.deleted {
                bail!("Failed to delete event type '{}'", record_id);
            }

            println!("Successfully deleted event type '{}'", res.id);
        }
    }
    Ok(())
}
