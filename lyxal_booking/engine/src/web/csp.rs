use crate::web::captcha;
use crate::web::state::AppState;
use axum::extract::State;
use std::sync::Arc;

pub(crate) fn build_csp(captcha: &Option<captcha::CaptchaConfig>) -> String {
    let (wasm_eval, worker_src, script_extra, connect_extra) = match captcha.as_ref() {
        Some(c) => {
            let widget_origin = c.widget_script_origin();
            let instance_origin = c.instance_origin();
            (
                " 'wasm-unsafe-eval'",
                "worker-src blob:; ",
                format!(" {}", widget_origin),
                format!(" {} {}", instance_origin, widget_origin),
            )
        }
        None => ("", "", String::new(), String::new()),
    };
    format!(
        "default-src 'self'; img-src 'self' data:; \
         style-src 'self' 'unsafe-inline'; \
         script-src 'self' 'unsafe-inline'{}{}; \
         {}connect-src 'self'{}; \
         object-src 'none'; base-uri 'self'; frame-ancestors 'self'",
        wasm_eval, script_extra, worker_src, connect_extra
    )
}

/// Booking form pages (`…/book`) are the only pages that embed the captcha
/// widget, so they are the only ones that get the relaxed CSP when captcha is
/// enabled. Every other page keeps the strict baseline policy.
pub(crate) fn is_booking_form_path(path: &str) -> bool {
    path.ends_with("/book")
}

pub(crate) fn is_embed_request(query: Option<&str>) -> bool {
    let q = match query {
        Some(q) => q,
        None => return false,
    };
    q.split('&').any(|pair| {
        let mut kv = pair.split('=');
        let k = kv.next().unwrap_or("");
        let v = kv.next().unwrap_or("");
        k == "embed" && (v == "1" || v == "true")
    })
}

pub(crate) fn is_embeddable_path(path: &str) -> bool {
    if path == "/u"
        || path.starts_with("/u/")
        || path == "/team"
        || path.starts_with("/team/")
        || path == "/g"
        || path.starts_with("/g/")
    {
        return true;
    }
    let trimmed = path.trim_start_matches('/');
    if trimmed.is_empty() {
        return false;
    }
    let mut segs = trimmed.split('/');
    let first = segs.next().unwrap_or("");
    let rest: Vec<&str> = segs.collect();
    let shape_ok = rest.is_empty() || (rest.len() == 1 && rest[0] == "book");
    if !shape_ok {
        return false;
    }
    const RESERVED: &[&str] = &[
        "auth",
        "dashboard",
        "avatar",
        "team-avatar",
        "logo",
        "accent.css",
        "brand-logo",
        "embed.js",
        "fonts",
        "t",
        "booking",
        "u",
        "team",
        "g",
    ];
    !RESERVED.contains(&first)
}

pub(crate) fn is_embedded_booking_request(path: &str, query: Option<&str>) -> bool {
    is_embed_request(query) && is_embeddable_path(path)
}

pub(crate) async fn csp_middleware(
    State(state): State<AppState>,
    request: axum::extract::Request,
    next: axum::middleware::Next,
) -> axum::response::Response {
    let booking_page = is_booking_form_path(request.uri().path());
    let embed_mode = is_embedded_booking_request(request.uri().path(), request.uri().query());
    let mut response = next.run(request).await;
    if !response
        .headers()
        .contains_key(axum::http::header::CONTENT_SECURITY_POLICY)
    {
        let strict = if booking_page {
            state.csp.read().await.clone()
        } else {
            state.csp_baseline.clone()
        };
        let csp = if embed_mode {
            strict.replace("frame-ancestors 'self'", "frame-ancestors *")
        } else {
            strict
        };
        if let Ok(val) = axum::http::HeaderValue::from_str(&csp) {
            response
                .headers_mut()
                .insert(axum::http::header::CONTENT_SECURITY_POLICY, val);
        }
    }
    response
}

#[cfg(test)]
mod tests {
    use super::*;

    fn make_captcha_config(instance_url: &str, widget_url: &str) -> captcha::CaptchaConfig {
        captcha::CaptchaConfig {
            instance_url: instance_url.to_string(),
            site_key: "testkey".to_string(),
            secret: lyxal_crypto::Zeroizing::new("secret".to_string()),
            widget_url: widget_url.to_string(),
        }
    }

    #[test]
    fn build_csp_without_captcha_has_no_extra_directives() {
        let csp = build_csp(&None);
        assert!(!csp.contains("wasm-unsafe-eval"));
        assert!(!csp.contains("worker-src"));
        assert!(!csp.contains("cdn.jsdelivr.net"));
        assert!(csp.contains("script-src 'self' 'unsafe-inline'"));
        assert!(csp.contains("connect-src 'self'"));
    }

    #[test]
    fn build_csp_with_captcha_includes_wasm_and_worker_src() {
        let cfg = Some(make_captcha_config(
            "https://cap.example.com",
            captcha::DEFAULT_WIDGET_URL,
        ));
        let csp = build_csp(&cfg);
        assert!(csp.contains("'wasm-unsafe-eval'"));
        assert!(csp.contains("worker-src blob:"));
    }

    #[test]
    fn build_csp_with_captcha_includes_script_origin() {
        let cfg = Some(make_captcha_config(
            "https://cap.example.com",
            captcha::DEFAULT_WIDGET_URL,
        ));
        let csp = build_csp(&cfg);
        assert!(csp.contains("https://cdn.jsdelivr.net"), "{}", csp);
    }

    #[test]
    fn booking_form_paths_get_relaxed_csp() {
        assert!(is_booking_form_path("/u/alice/intro/book"));
        assert!(is_booking_form_path("/team/sales/demo/book"));
        assert!(is_booking_form_path("/intro/book"));
    }

    #[test]
    fn non_booking_paths_keep_baseline_csp() {
        assert!(!is_booking_form_path("/"));
        assert!(!is_booking_form_path("/dashboard"));
        assert!(!is_booking_form_path("/dashboard/admin"));
        assert!(!is_booking_form_path("/u/alice/intro"));
        assert!(!is_booking_form_path("/booking/cancel/sometoken"));
        assert!(!is_booking_form_path("/u/alice/bookkeeping"));
    }

    #[test]
    fn build_csp_with_captcha_includes_connect_origins() {
        let cfg = Some(make_captcha_config(
            "https://cap.example.com",
            captcha::DEFAULT_WIDGET_URL,
        ));
        let csp = build_csp(&cfg);
        assert!(csp.contains("connect-src 'self'"), "{}", csp);
        assert!(csp.contains("https://cap.example.com"), "{}", csp);
        assert!(csp.contains("https://cdn.jsdelivr.net"), "{}", csp);
    }

    #[test]
    fn build_csp_contains_frame_ancestors_self_for_swap() {
        assert_eq!(
            build_csp(&None).matches("frame-ancestors 'self'").count(),
            1
        );
        let cfg = Some(make_captcha_config(
            "https://cap.example.com",
            captcha::DEFAULT_WIDGET_URL,
        ));
        assert_eq!(build_csp(&cfg).matches("frame-ancestors 'self'").count(), 1);
    }

    #[test]
    fn build_csp_embed_swap_preserves_captcha_allowances() {
        let cfg = Some(make_captcha_config(
            "https://cap.example.com",
            captcha::DEFAULT_WIDGET_URL,
        ));
        let strict = build_csp(&cfg);
        let embed_csp = strict.replace("frame-ancestors 'self'", "frame-ancestors *");
        assert!(embed_csp.contains("frame-ancestors *"));
        assert!(!embed_csp.contains("frame-ancestors 'self'"));
        assert!(embed_csp.contains("'wasm-unsafe-eval'"));
        assert!(embed_csp.contains("worker-src blob:"));
        assert!(embed_csp.contains("https://cap.example.com"));
        assert!(embed_csp.contains("https://cdn.jsdelivr.net"));
    }
}
