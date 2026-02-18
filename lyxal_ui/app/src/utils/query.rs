use leptos::prelude::*;
use leptos_router::hooks::use_location;

pub struct QUERY;

impl QUERY {
pub const PAGE: &'static str = "page";
}

pub struct QueryUtils;

impl QueryUtils {
pub fn extract(key: String) -> Memo<Option<String>> {
let location = use_location();
Memo::new(move |_| {
location.query.with(|q| q.get(&key))
})
}
}
