use leptos::{prelude::*, svg::Svg};
#[component]
pub fn BrushCleaning(
#[prop(default = 24.into(), into)] size: Signal<usize>,
#[prop(default = "currentColor".into(), into)] color: Signal<String>,
#[prop(default = "none".into(), into)] fill: Signal<String>,
#[prop(default = 2.into(), into)] stroke_width: Signal<usize>,
#[prop(default = false.into(), into)] absolute_stroke_width: Signal<bool>,
#[prop(optional)] node_ref: NodeRef<Svg>,
) -> impl IntoView {
let stroke_width = Signal::derive(move || {
if absolute_stroke_width.get() {
stroke_width.get() * 24 / size.get()
} else {
stroke_width.get()
}
});
view! {
<svg
node_ref=node_ref
class:lucide=true
xmlns="http://www.w3.org/2000/svg"
width=size
height=size
viewBox="0 0 24 24"
fill=fill
stroke=color
stroke-width=stroke_width
stroke-linecap="round"
stroke-linejoin="round"
>
<path d="m16 22-1-4" />
<path d="M19 14a1 1 0 0 0 1-1v-1a2 2 0 0 0-2-2h-3a1 1 0 0 1-1-1V4a2 2 0 0 0-4 0v5a1 1 0 0 1-1 1H6a2 2 0 0 0-2 2v1a1 1 0 0 0 1 1" />
<path d="M19 14H5l-1.973 6.767A1 1 0 0 0 4 22h16a1 1 0 0 0 .973-1.233z" />
<path d="m8 22 1-4" />
</svg>
}
}
