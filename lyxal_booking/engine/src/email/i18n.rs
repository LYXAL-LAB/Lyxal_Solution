//! Internationalization helpers for email rendering.

use fluent_bundle::{FluentArgs, FluentValue};
use super::dto::BookingDetails;

pub(crate) fn t(lang: &str, key: &str) -> String {
    crate::i18n::translate(lang, key, None)
}

pub(crate) fn ta<const N: usize>(lang: &str, key: &str, args: [(&str, &str); N]) -> String {
    let mut fa = FluentArgs::new();
    for (k, v) in args.iter() {
        fa.set(*k, FluentValue::from(*v));
    }
    crate::i18n::translate(lang, key, Some(&fa))
}

pub(crate) fn guest_lang(details: &BookingDetails) -> &str {
    details.guest_language.as_deref().unwrap_or("en")
}

pub(crate) fn host_lang(details: &BookingDetails) -> &str {
    details.host_language.as_deref().unwrap_or("en")
}
