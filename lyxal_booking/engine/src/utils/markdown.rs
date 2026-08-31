//! Safe Inline Markdown Rendering with XSS Protection.

use pulldown_cmark::{Event, Options, Parser, Tag, TagEnd};

/// Validate if a URL scheme is safe (`http`, `https`, `mailto`).
pub fn is_safe_link(raw: &str) -> bool {
    let raw = raw.trim();

    if raw.to_ascii_lowercase().starts_with("mailto:") {
        return raw.len() > "mailto:".len() && !raw.contains('\n') && !raw.contains('\r');
    }

    match url::Url::parse(raw) {
        Ok(url) => {
            matches!(url.scheme(), "http" | "https")
                && url.host_str().is_some()
                && url.username().is_empty()
                && url.password().is_none()
        }
        Err(_) => false,
    }
}

/// Render a Markdown string to safe inline HTML.
///
/// Only allows inline elements: links, bold, italic, strikethrough, inline code.
/// Dangerous links (`javascript:`, `data:`, credentials) have their `<a href>` anchor
/// neutralised while preserving the inner visible text.
pub fn render_inline_markdown(text: &str) -> String {
    let parser = Parser::new_ext(text, Options::ENABLE_STRIKETHROUGH);

    let mut unsafe_link_depth = 0usize;

    // Filter to inline-only elements & neutralize unsafe links while preserving link text
    let filtered = parser.filter_map(|event| match event {
        Event::Start(Tag::Heading { .. }
        | Tag::BlockQuote(_)
        | Tag::CodeBlock(_)
        | Tag::Image { .. }
        | Tag::List(_)
        | Tag::Item
        | Tag::Table(_)
        | Tag::TableHead
        | Tag::TableRow
        | Tag::TableCell
        | Tag::HtmlBlock)
        | Event::End(TagEnd::Heading(_)
        | TagEnd::BlockQuote(_)
        | TagEnd::CodeBlock
        | TagEnd::Image
        | TagEnd::List(_)
        | TagEnd::Item
        | TagEnd::Table
        | TagEnd::TableHead
        | TagEnd::TableRow
        | TagEnd::TableCell
        | TagEnd::HtmlBlock)
        | Event::Html(_)
        | Event::InlineHtml(_) => None,

        Event::Start(Tag::Link {
            link_type,
            dest_url,
            title,
            id,
        }) => {
            if is_safe_link(dest_url.as_ref()) {
                Some(Event::Start(Tag::Link {
                    link_type,
                    dest_url,
                    title,
                    id,
                }))
            } else {
                unsafe_link_depth += 1;
                None
            }
        }

        Event::End(TagEnd::Link) => {
            if unsafe_link_depth > 0 {
                unsafe_link_depth -= 1;
                None
            } else {
                Some(Event::End(TagEnd::Link))
            }
        }

        other => Some(other),
    });

    let mut html = String::new();
    pulldown_cmark::html::push_html(&mut html, filtered);

    // Safely inject target="_blank" and rel="noopener noreferrer" onto allowed <a> tags
    let mut safe_html = html.replace(
        "<a href=",
        "<a target=\"_blank\" rel=\"noopener noreferrer\" href=",
    );

    // Strip wrapping <p> tags to keep it inline
    let trimmed = safe_html.trim();
    if trimmed.starts_with("<p>") && trimmed.ends_with("</p>") {
        let inner = &trimmed[3..trimmed.len() - 4];
        if !inner.contains("<p>") {
            return inner.to_string();
        }
    }

    safe_html
        .trim()
        .replace("</p>\n<p>", "<br>")
        .trim_start_matches("<p>")
        .trim_end_matches("</p>")
        .to_string()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_is_safe_link() {
        assert!(is_safe_link("https://example.com"));
        assert!(is_safe_link("http://example.com/path"));
        assert!(is_safe_link("mailto:user@example.com"));

        assert!(!is_safe_link("javascript:alert(1)"));
        assert!(!is_safe_link("data:text/html,script"));
        assert!(!is_safe_link("https://user:pass@example.com"));
        assert!(!is_safe_link("/relative/path"));
    }

    #[test]
    fn bio_rejects_javascript_links_and_preserves_text() {
        let rendered = render_inline_markdown("[Cliquer ici](javascript:alert(1))");
        assert!(!rendered.contains("javascript:"));
        assert!(!rendered.contains("<a href"));
        assert!(rendered.contains("Cliquer ici"));
    }

    #[test]
    fn safe_link_rendered_with_target_blank() {
        let rendered = render_inline_markdown("[Doc](https://example.com)");
        assert!(rendered.contains("target=\"_blank\""));
        assert!(rendered.contains("href=\"https://example.com\""));
    }
}
