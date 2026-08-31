use leptos::prelude::*;
use tw_merge::tw_merge;

#[derive(Default, Clone, Copy, PartialEq)]
pub enum SeparatorOrientation {
#[default]
Horizontal,
Vertical,
}

#[component]
pub fn Separator(
#[prop(into, optional, default = SeparatorOrientation::Horizontal.into())] orientation: Signal<SeparatorOrientation>,
#[prop(into, optional)] class: String,
) -> impl IntoView {
let merged_class = Memo::new(move |_| {
tw_merge!(
"bg-border shrink-0",
if orientation.get() == SeparatorOrientation::Horizontal { "h-[1px] w-full" } else { "h-full w-[1px]" },
class.clone()
)
});

view! { <div class=move || merged_class.get() role="separator" /> }
}
