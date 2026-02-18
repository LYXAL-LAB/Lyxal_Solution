use leptos::prelude::*;
use tw_merge::tw_merge;

#[component]
pub fn Input(
#[prop(into, optional, default = "text".into())] r#type: String,
#[prop(into, optional)] class: String,
#[prop(into, optional)] placeholder: Option<String>,
#[prop(into, optional)] name: Option<String>,
#[prop(into, optional)] id: Option<String>,
#[prop(optional)] disabled: bool,
#[prop(optional)] readonly: bool,
#[prop(optional)] required: bool,
#[prop(optional)] autofocus: bool,
#[prop(optional)] value: Option<RwSignal<String>>,
) -> impl IntoView {
let merged_class = tw_merge!(
"border-input placeholder:text-muted-foreground focus-visible:border-ring focus-visible:ring-ring/50 aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 aria-invalid:border-destructive dark:bg-input/30 flex h-9 w-full rounded-md border bg-transparent px-3 py-1 text-base shadow-xs transition-[color,box-shadow] outline-none file:inline-flex file:h-7 file:border-0 file:bg-transparent file:text-sm file:font-medium focus-visible:ring-2 disabled:cursor-not-allowed disabled:opacity-50 md:text-sm",
class
);

view! {
<input
type=r#type
class=merged_class
placeholder=placeholder
name=name
id=id
disabled=disabled
readonly=readonly
required=required
autofocus=autofocus
prop:value=move || value.map(|v| v.get()).unwrap_or_default()
on:input=move |ev| {
if let Some(v) = value {
v.set(event_target_value(&ev));
}
}
/>
}
}
