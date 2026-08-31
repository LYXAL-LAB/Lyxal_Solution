use crate::db::surreal_query_opt;
use serde::Deserialize;

#[derive(Deserialize)]
pub(crate) struct CompanyLinkForm {
    pub company_link: String,
    pub _csrf: Option<String>,
}

/// Whether a `company_link` URL is safe to render as a clickable anchor.
/// Only `http://` and `https://` schemes are accepted; this rejects
/// `javascript:`, `data:`, `vbscript:`, `file:` etc., any of which would
/// turn the admin-controlled link on every public page into a stored XSS
/// or local-file vector.
pub(crate) fn is_safe_company_link(url: &str) -> bool {
    let lower = url.trim().to_ascii_lowercase();
    lower.starts_with("http://") || lower.starts_with("https://")
}

pub(crate) async fn get_company_link(db: &crate::store::SurrealStore) -> Option<String> {
    match surreal_query_opt::<String>(db.client().query("RETURN fn::booking_get_company_link();").await) {
        Ok(val) => val
            .filter(|s| !s.is_empty())
            .filter(|s| is_safe_company_link(s)),
        Err(error) => {
            tracing::warn!(%error, "Failed to load company link");
            None
        }
    }
}
