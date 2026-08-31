pub mod captcha_config;
pub mod meeting_config;
pub mod oauth_config;
pub mod smtp_config;

use anyhow::Result;
use surrealdb::RecordId;
use crate::db::SurrealBookingStore;

pub async fn sync_calendar_source(
    _store: &SurrealBookingStore,
    _source_id: &RecordId,
) -> Result<usize> {
    // Executera la synchronisation distante CalDAV/EWS
    Ok(0)
}
