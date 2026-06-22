use leptos::*;

#[component]
pub fn Heading(
    #[prop(optional)] class: String,
    #[prop(optional)] id: String,
    #[prop(optional)] level: u8,
    children: Children,
) -> impl IntoView {
    let tag_name = format!("h{}", if level == 0 { 1 } else { level });

    html::custom(html::Custom::new(tag_name))
        .attr("class", class)
        .attr("id", id)
        .child(children())
}