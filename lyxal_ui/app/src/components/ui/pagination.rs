//! Pagination and data grid configuration constants and components.

use leptos::prelude::*;
use crate::components::ui::button::{Button, ButtonVariant};

/// Pagination and data grid configuration
pub struct PAGINATION;

impl PAGINATION {
/// Default number of rows per page
pub const DEFAULT_PAGE_SIZE: u32 = 1000;

/// Available page size options for the dropdown
pub const PAGE_SIZE_OPTIONS: [u32; 3] = [500, 700, 1000];

/// Row height in pixels for virtual scrolling (must match CSS)
pub const ROW_HEIGHT: usize = 36;
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum PageDirection {
Previous,
Next,
}

#[component]
pub fn Pagination(children: Children) -> impl IntoView {
view! {
<nav class="flex w-full justify-center" aria-label="pagination">
{children()}
</nav>
}
}

#[component]
pub fn PaginationList(children: Children) -> impl IntoView {
view! {
<ul class="flex flex-row items-center gap-1">
{children()}
</ul>
}
}

#[component]
pub fn PaginationItem(children: Children) -> impl IntoView {
view! {
<li>
{children()}
</li>
}
}

#[component]
pub fn PaginationLink(page: u32, #[prop(optional)] active: bool) -> impl IntoView {
view! {
<Button
variant={if active { ButtonVariant::Outline } else { ButtonVariant::Ghost }}
>
{page.to_string()}
</Button>
}
}

#[component]
pub fn PaginationNavButton(direction: PageDirection) -> impl IntoView {
let label = match direction {
PageDirection::Previous => "Previous",
PageDirection::Next => "Next",
};

view! {
<Button variant=ButtonVariant::Ghost>
{label}
</Button>
}
}
