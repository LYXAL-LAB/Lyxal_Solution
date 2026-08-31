//! Network feed fetching and URL derivation helpers for ICS resources.

use super::error::ResourceError;

/// Fetch the raw ICS publish feed. An empty body with a calendar
/// content-type is a valid, empty calendar (BlueMind behaviour).
pub async fn fetch_feed(feed_url: &str) -> Result<String, ResourceError> {
    // Re-validate on every fetch to prevent SSRF vulnerabilities
    crate::caldav::validate_caldav_url(feed_url)
        .map_err(|e| ResourceError::InvalidFeedUrl(e.to_string()))?;

    // No redirects: following one would let a validated public URL bounce
    // the request to an internal host (SSRF).
    let client = reqwest::Client::builder()
        .timeout(std::time::Duration::from_secs(30))
        .redirect(reqwest::redirect::Policy::none())
        .build()?;
    let mut resp = client.get(feed_url).send().await?;
    if !resp.status().is_success() {
        return Err(ResourceError::InvalidCalendar(format!(
            "feed returned HTTP {}",
            resp.status()
        )));
    }
    let is_calendar = resp
        .headers()
        .get(reqwest::header::CONTENT_TYPE)
        .and_then(|v| v.to_str().ok())
        .map(|ct| ct.contains("text/calendar"))
        .unwrap_or(false);

    // Bound the body: a hostile feed must not exhaust memory (max 10 MB).
    const MAX_FEED_BYTES: usize = 10 * 1024 * 1024;
    let mut raw: Vec<u8> = Vec::new();
    while let Some(chunk) = resp.chunk().await? {
        raw.extend_from_slice(&chunk);
        if raw.len() > MAX_FEED_BYTES {
            return Err(ResourceError::FeedTooLarge(MAX_FEED_BYTES));
        }
    }
    let body = String::from_utf8_lossy(&raw).into_owned();
    if !is_calendar && !body.contains("BEGIN:VCALENDAR") {
        return Err(ResourceError::InvalidCalendar(
            "URL did not return an ICS calendar".to_string(),
        ));
    }
    Ok(body)
}

/// Derive the CalDAV collection URL from a BlueMind publish URL.
///
/// `https://host/api/calendars/publish/calendar:UID/x-calendar-…` →
/// `https://host/dav/calendars/__uids__/UID/calendar:UID/`
/// Returns `None` for non-BlueMind feeds.
pub fn derive_caldav_url(feed_url: &str) -> Option<String> {
    let u = reqwest::Url::parse(feed_url).ok()?;
    let container = u
        .path()
        .split('/')
        .find(|s| s.starts_with("calendar:"))?
        .to_string();
    let uid = container.strip_prefix("calendar:")?;
    let host = u.host_str()?;
    let port = u.port().map(|p| format!(":{}", p)).unwrap_or_default();
    Some(format!(
        "{}://{}{}/dav/calendars/__uids__/{}/{}/",
        u.scheme(),
        host,
        port,
        uid,
        container
    ))
}

/// Return scheme + host + port of a feed URL (`https://host:8443`).
pub fn url_origin(feed_url: &str) -> Option<String> {
    let u = reqwest::Url::parse(feed_url).ok()?;
    let host = u.host_str()?;
    let port = u.port().map(|p| format!(":{}", p)).unwrap_or_default();
    Some(format!("{}://{}{}", u.scheme(), host, port))
}

/// Extract `X-WR-CALNAME` from a VCALENDAR header block.
pub fn feed_calendar_name(body: &str) -> Option<String> {
    for line in body.lines() {
        let trimmed = line.trim();
        if trimmed.starts_with("BEGIN:VEVENT") {
            break;
        }
        if let Some(rest) = trimmed.strip_prefix("X-WR-CALNAME:") {
            let name = rest.trim();
            if !name.is_empty() {
                return Some(name.to_string());
            }
        }
    }
    None
}
