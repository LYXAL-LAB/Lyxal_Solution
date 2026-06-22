use leptos::*;

#[component]
pub fn Superscript(
    #[prop(optional)] class: String,
    #[prop(optional)] id: String,
    #[prop(optional)] tag: Option<String>,
    children: Children,
) -> impl IntoView {
    let tag_name = tag.unwrap_or_else(|| "superscript".to_string());
    html::custom(leptos::html::Custom::new(tag_name))
        .attr("class", class)
        .attr("id", id)
        .child(children())
}
