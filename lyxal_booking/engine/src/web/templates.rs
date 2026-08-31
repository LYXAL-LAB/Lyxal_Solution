use crate::db::surreal_query_opt;
use crate::web::state::AppState;
use axum::response::IntoResponse;

pub(crate) fn hex_to_rgb(raw: &str) -> Option<(u8, u8, u8)> {
    let full = match raw.len() {
        3 if raw.chars().all(|c| c.is_ascii_hexdigit()) => {
            raw.chars().flat_map(|c| [c, c]).collect::<String>()
        }
        6 if raw.chars().all(|c| c.is_ascii_hexdigit()) => raw.to_string(),
        _ => return None,
    };
    let r = u8::from_str_radix(&full[0..2], 16).ok()?;
    let g = u8::from_str_radix(&full[2..4], 16).ok()?;
    let b = u8::from_str_radix(&full[4..6], 16).ok()?;
    Some((r, g, b))
}

pub(crate) fn custom_theme_css(
    accent: &str,
    accent_hover: &str,
    bg: &str,
    surface: &str,
    text: &str,
) -> String {
    let (r, g, b) = hex_to_rgb(accent.trim_start_matches('#')).unwrap_or((37, 99, 235));
    format!(
        ":root{{--bg:{bg};--surface:{surface};--text:{text};--accent:{accent};--accent-hover:{accent_hover};\
         --accent-subtle:rgba({r},{g},{b},0.08);--accent-border:rgba({r},{g},{b},0.25);--accent-muted:rgba({r},{g},{b},0.5)}}\
         html.dark{{--bg:{bg};--surface:{surface};--text:{text};--accent:{accent};--accent-hover:{accent_hover};\
         --accent-subtle:rgba({r},{g},{b},0.12);--accent-border:rgba({r},{g},{b},0.3);--accent-muted:rgba({r},{g},{b},0.5)}}",
    )
}

pub(crate) fn preset_theme_css(theme: &str) -> &'static str {
    match theme {
        "emerald" => {
            ":root{--accent:#059669;--accent-hover:#047857;--accent-subtle:rgba(5,150,105,0.08);--accent-border:rgba(5,150,105,0.25);--accent-muted:rgba(5,150,105,0.5)}"
        }
        "violet" => {
            ":root{--accent:#7c3aed;--accent-hover:#6d28d9;--accent-subtle:rgba(124,58,237,0.08);--accent-border:rgba(124,58,237,0.25);--accent-muted:rgba(124,58,237,0.5)}"
        }
        "rose" => {
            ":root{--accent:#e11d48;--accent-hover:#be123c;--accent-subtle:rgba(225,29,72,0.08);--accent-border:rgba(225,29,72,0.25);--accent-muted:rgba(225,29,72,0.5)}"
        }
        "amber" => {
            ":root{--accent:#d97706;--accent-hover:#b45309;--accent-subtle:rgba(217,119,6,0.08);--accent-border:rgba(217,119,6,0.25);--accent-muted:rgba(217,119,6,0.5)}"
        }
        "cyan" => {
            ":root{--accent:#0891b2;--accent-hover:#0e7490;--accent-subtle:rgba(8,145,178,0.08);--accent-border:rgba(8,145,178,0.25);--accent-muted:rgba(8,145,178,0.5)}"
        }
        _ => "",
    }
}

/// Build the full theme CSS string from DB settings.
pub(crate) async fn build_theme_css(db: &crate::store::SurrealStore) -> String {
    let row: Option<(String, Option<String>, Option<String>, Option<String>, Option<String>, Option<String>)> =
        surreal_query_opt(db.client().query("SELECT theme, custom_accent, custom_accent_hover, custom_bg, custom_surface, custom_text FROM auth_config WHERE id = 'singleton'").await).ok().flatten();
    match row {
        Some((ref theme, ref ca, ref cah, ref cb, ref cs, ref ct)) if theme == "custom" => {
            let accent = ca.as_deref().unwrap_or("#2563eb");
            let accent_hover = cah.as_deref().unwrap_or("#1d4ed8");
            let bg = cb.as_deref().unwrap_or("#f4f4f5");
            let surface = cs.as_deref().unwrap_or("#ffffff");
            let text = ct.as_deref().unwrap_or("#18181b");
            custom_theme_css(accent, accent_hover, bg, surface, text)
        }
        Some((ref theme, ..)) => preset_theme_css(theme).to_string(),
        None => String::new(),
    }
}

/// Get the current theme name from DB.
pub(crate) async fn get_theme_name(db: &crate::store::SurrealStore) -> String {
    let row: Option<(String,)> =
        surreal_query_opt(db.client().query("SELECT theme FROM auth_config WHERE id = 'singleton'").await).ok().flatten();
    row.map(|r| r.0).unwrap_or_else(|| "default".to_string())
}

/// Get custom theme colors from DB (for populating the form).
pub(crate) async fn get_custom_colors(db: &crate::store::SurrealStore) -> (String, String, String, String, String) {
    let row: Option<(Option<String>, Option<String>, Option<String>, Option<String>, Option<String>)> =
        surreal_query_opt(db.client().query("SELECT custom_accent, custom_accent_hover, custom_bg, custom_surface, custom_text FROM auth_config WHERE id = 'singleton'").await).ok().flatten();
    match row {
        Some((a, ah, bg, s, t)) => (
            a.unwrap_or_else(|| "#2563eb".to_string()),
            ah.unwrap_or_else(|| "#1d4ed8".to_string()),
            bg.unwrap_or_else(|| "#f4f4f5".to_string()),
            s.unwrap_or_else(|| "#ffffff".to_string()),
            t.unwrap_or_else(|| "#18181b".to_string()),
        ),
        None => (
            "#2563eb".to_string(),
            "#1d4ed8".to_string(),
            "#f4f4f5".to_string(),
            "#ffffff".to_string(),
            "#18181b".to_string(),
        ),
    }
}

/// Read the org-wide display labels for the Jitsi / webhook providers from
/// the cached `MeetingConfig`.
pub(crate) async fn meeting_provider_labels(state: &AppState) -> (String, String) {
    let cfg = state.meeting_config.read().await;
    let jitsi = cfg
        .jitsi
        .as_ref()
        .and_then(|j| j.display_name.clone())
        .unwrap_or_default();
    let webhook = cfg
        .webhook
        .as_ref()
        .and_then(|w| w.display_name.clone())
        .unwrap_or_default();
    (jitsi, webhook)
}

pub(crate) async fn serve_embed_js() -> impl IntoResponse {
    static EMBED_JS: &str = include_str!("../../assets/embed.js");
    axum::response::Response::builder()
        .status(200)
        .header("Content-Type", "application/javascript; charset=utf-8")
        .header("Cache-Control", "public, max-age=3600")
        .header("Access-Control-Allow-Origin", "*")
        .body(axum::body::Body::from(EMBED_JS))
        .unwrap_or_else(|_| axum::response::Response::new(axum::body::Body::empty()))
        .into_response()
}

pub(crate) async fn serve_font_inter_latin() -> impl IntoResponse {
    static FONT: &[u8] = include_bytes!("../../assets/inter-latin.woff2");
    axum::response::Response::builder()
        .status(200)
        .header("Content-Type", "font/woff2")
        .header("Cache-Control", "public, max-age=31536000, immutable")
        .body(axum::body::Body::from(FONT))
        .unwrap_or_else(|_| axum::response::Response::new(axum::body::Body::empty()))
        .into_response()
}

pub(crate) async fn serve_font_inter_latin_ext() -> impl IntoResponse {
    static FONT: &[u8] = include_bytes!("../../assets/inter-latin-ext.woff2");
    axum::response::Response::builder()
        .status(200)
        .header("Content-Type", "font/woff2")
        .header("Cache-Control", "public, max-age=31536000, immutable")
        .body(axum::body::Body::from(FONT))
        .unwrap_or_else(|_| axum::response::Response::new(axum::body::Body::empty()))
        .into_response()
}

pub fn create_environment() -> anyhow::Result<minijinja::Environment<'static>> {
    let mut env = minijinja::Environment::new();
    env.set_loader(minijinja::path_loader("templates"));
    Ok(env)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_hex_to_rgb_valid() {
        assert_eq!(hex_to_rgb("ffffff"), Some((255, 255, 255)));
        assert_eq!(hex_to_rgb("000000"), Some((0, 0, 0)));
        assert_eq!(hex_to_rgb("fff"), Some((255, 255, 255)));
    }

    #[test]
    fn test_hex_to_rgb_invalid_rejects_xss_injection() {
        assert_eq!(hex_to_rgb("<script>alert(1)</script>"), None);
        assert_eq!(hex_to_rgb("red; color: red"), None);
        assert_eq!(hex_to_rgb(""), None);
    }

    #[test]
    fn test_custom_theme_css_sanitization() {
        let css = custom_theme_css("#2563eb", "#1d4ed8", "#ffffff", "#f4f4f5", "#18181b");
        assert!(css.contains("--accent:#2563eb"));
        assert!(css.contains("--accent-subtle:rgba(37,99,235,0.08)"));
    }
}
