use yew::prelude::*;
#[derive(PartialEq, Properties)]
pub struct PaintBucketProps {
#[prop_or(24)]
pub size: usize,
#[prop_or(AttrValue::from("currentColor"))]
pub color: AttrValue,
#[prop_or(AttrValue::from("none"))]
pub fill: AttrValue,
#[prop_or(2)]
pub stroke_width: usize,
#[prop_or(false)]
pub absolute_stroke_width: bool,
#[prop_or_default]
pub class: Classes,
#[prop_or_default]
pub style: std::option::Option<AttrValue>,
#[prop_or_default]
pub node_ref: NodeRef,
}
#[component]
pub fn PaintBucket(props: &PaintBucketProps) -> Html {
let stroke_width = if props.absolute_stroke_width {
props.stroke_width * 24 / props.size
} else {
props.stroke_width
};
html! {
<svg
ref={props.node_ref.clone()}
class={classes!("lucide", props.class
.clone())}
style={props.style.clone()}
xmlns="http://www.w3.org/2000/svg"
width={props.size.to_string()}
height={props.size.to_string()}
viewBox="0 0 24 24"
fill={& props.fill}
stroke={& props.color}
stroke-width={stroke_width.to_string()}
stroke-linecap="round"
stroke-linejoin="round"
>
<path d="M11 7 6 2" />
<path d="M18.992 12H2.041" />
<path
d="M21.145 18.38A3.34 3.34 0 0 1 20 16.5a3.3 3.3 0 0 1-1.145 1.88c-.575.46-.855 1.02-.855 1.595A2 2 0 0 0 20 22a2 2 0 0 0 2-2.025c0-.58-.285-1.13-.855-1.595"
/>
<path
d="m8.5 4.5 2.148-2.148a1.205 1.205 0 0 1 1.704 0l7.296 7.296a1.205 1.205 0 0 1 0 1.704l-7.592 7.592a3.615 3.615 0 0 1-5.112 0l-3.888-3.888a3.615 3.615 0 0 1 0-5.112L5.67 7.33"
/>
</svg>
}
}
