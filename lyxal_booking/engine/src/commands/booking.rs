use anyhow::{bail, Result};
use clap::Subcommand;
use lyxal_surreal::LyxalSurrealCall;
use serde::{Deserialize, Serialize};
use surrealdb::sql::Datetime;
use surrealdb::RecordId;
use tabled::{Table, Tabled};

use crate::db::SurrealBookingStore;

#[derive(Subcommand, Debug)]
pub enum BookingCommands {
    /// List bookings
    List {
        /// Filter by status (confirmed, cancelled, rescheduled)
        #[arg(long)]
        status: Option<String>,
        /// Limit maximum number of results
        #[arg(long, default_value = "50")]
        limit: usize,
    },
    /// Show details of a booking
    Show {
        /// Booking ID (e.g. booking:xyz or UUID)
        id: String,
    },
    /// Cancel a booking
    Cancel {
        /// Booking ID (e.g. booking:xyz)
        id: String,
        /// Reason for cancellation
        #[arg(long)]
        reason: Option<String>,
    },
    /// Reschedule a booking
    Reschedule {
        /// Booking ID (e.g. booking:xyz)
        id: String,
        /// New start time (RFC3339 string)
        #[arg(long)]
        start_at: String,
        /// New end time (RFC3339 string)
        #[arg(long)]
        end_at: String,
    },
}

#[derive(Debug, Serialize)]
struct ListBookingsParams {
    status: Option<String>,
    limit: usize,
}

#[derive(Debug, Deserialize, Tabled)]
pub struct BookingRow {
    #[tabled(rename = "ID")]
    pub id: String,
    #[tabled(rename = "GUEST")]
    pub guest_name: String,
    #[tabled(rename = "EMAIL")]
    pub guest_email: String,
    #[tabled(rename = "START AT")]
    pub start_at: String,
    #[tabled(rename = "END AT")]
    pub end_at: String,
    #[tabled(rename = "STATUS")]
    pub status: String,
}

#[derive(Debug, Serialize)]
struct GetBookingParams {
    booking_id: RecordId,
}

#[derive(Debug, Deserialize)]
pub struct BookingDetail {
    pub id: RecordId,
    pub guest_name: String,
    pub guest_email: String,
    pub start_at: Datetime,
    pub end_at: Datetime,
    pub status: String,
    pub cancellation_reason: Option<String>,
}

#[derive(Debug, Serialize)]
struct CancelBookingParams {
    booking_id: RecordId,
    reason: Option<String>,
}

#[derive(Debug, Deserialize)]
struct CancelBookingResult {
    booking_id: RecordId,
    cancelled: bool,
}

#[derive(Debug, Serialize)]
struct RescheduleBookingParams<'a> {
    booking_id: &'a RecordId,
    expected_start_at: Datetime,
    expected_end_at: Datetime,
    new_start_at: Datetime,
    new_end_at: Datetime,
}

#[derive(Debug, Deserialize)]
pub struct RescheduleBookingData {
    pub booking_id: RecordId,
    pub assigned_resource_id: Option<RecordId>,
    pub start_at: Datetime,
    pub end_at: Datetime,
}

fn parse_booking_id(raw: &str) -> Result<RecordId> {
    let clean = raw.trim();
    if let Some((table, id)) = clean.split_once(':') {
        if table != "booking" {
            bail!("Expected booking:<id>, got '{}'", clean);
        }
        return Ok(RecordId::from(("booking", id)));
    }
    Ok(RecordId::from(("booking", clean)))
}

fn parse_datetime(raw: &str) -> Result<Datetime> {
    let clean = raw.trim();
    if let Ok(dt) = chrono::DateTime::parse_from_rfc3339(clean) {
        return Ok(Datetime::from(dt.with_timezone(&chrono::Utc)));
    }
    bail!("Invalid RFC3339 datetime '{}'. Expected e.g. 2026-07-29T10:00:00Z", clean);
}

pub async fn run(
    store: &SurrealBookingStore,
    cmd: BookingCommands,
) -> Result<()> {
    match cmd {
        BookingCommands::List { status, limit } => {
            let params = ListBookingsParams { status, limit };
            let bookings: Vec<BookingRow> = store
                .call_fn("booking_list_bookings", params)
                .await?;

            if bookings.is_empty() {
                println!("No bookings found.");
            } else {
                println!("{}", Table::new(bookings));
            }
        }
        BookingCommands::Show { id } => {
            let booking_id = parse_booking_id(&id)?;
            let detail: Option<BookingDetail> = store
                .call_fn("booking_get_booking_detail", GetBookingParams { booking_id: booking_id.clone() })
                .await?;

            match detail {
                Some(b) => {
                    println!("Booking ID : {}", b.id);
                    println!("Guest      : {} ({})", b.guest_name, b.guest_email);
                    println!("Start      : {}", b.start_at);
                    println!("End        : {}", b.end_at);
                    println!("Status     : {}", b.status);
                    if let Some(reason) = b.cancellation_reason {
                        println!("Reason     : {}", reason);
                    }
                }
                None => bail!("Booking not found with ID '{}'", booking_id),
            }
        }
        BookingCommands::Cancel { id, reason } => {
            let booking_id = parse_booking_id(&id)?;
            let params = CancelBookingParams {
                booking_id: booking_id.clone(),
                reason,
            };

            let res: CancelBookingResult = store
                .call_fn("booking_cancel_booking", params)
                .await?;

            if !res.cancelled {
                bail!("Failed to cancel booking '{}'", booking_id);
            }

            println!("Successfully cancelled booking '{}'", res.booking_id);
        }
        BookingCommands::Reschedule {
            id,
            start_at,
            end_at,
        } => {
            let booking_id = parse_booking_id(&id)?;

            // 1. Parsing et validation des dates en Rust avant l'appel
            let new_start_dt = parse_datetime(&start_at)?;
            let new_end_dt = parse_datetime(&end_at)?;

            if new_start_dt >= new_end_dt {
                bail!("Invalid reschedule interval: new_start_at ({}) must be strictly earlier than new_end_at ({})", new_start_dt, new_end_dt);
            }

            // 2. Charger la réservation pour valider l'existence et récupérer les dates actuelles (verrou optimiste non-optionnel)
            let detail: Option<BookingDetail> = store
                .call_fn("booking_get_booking_detail", GetBookingParams { booking_id: booking_id.clone() })
                .await?;

            let current = match detail {
                Some(b) => b,
                None => bail!("Booking not found with ID '{}'", booking_id),
            };

            // 4. Appel de la fonction SurrealQL atomique de réaffectation/report
            let res: RescheduleBookingData = store
                .call_fn(
                    "booking_reschedule_with_resource_assignment",
                    serde_json::json!({
                        "booking_id": booking_id,
                        "expected_start_at": current.start_at,
                        "expected_end_at": current.end_at,
                        "new_start_at": new_start_dt,
                        "new_end_at": new_end_dt,
                    }),
                )
                .await?;

            println!(
                "Successfully rescheduled booking '{}' (Resource: {:?})",
                res.booking_id, res.assigned_resource_id
            );
        }
    }
    Ok(())
}
