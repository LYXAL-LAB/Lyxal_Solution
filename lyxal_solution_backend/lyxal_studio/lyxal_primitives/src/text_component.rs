use leptos::*;

#[component]
pub fn Text(
    #[prop(optional)] class: String,
    #[prop(optional)] id: String,
    #[prop(optional)] tag: Option<String>,
    children: Children,
) -> impl IntoView {
    let tag_name = tag.unwrap_or_else(|| "span".to_string());
    
    html::custom(html::Custom::new(tag_name))
        .attr("class", class)
        .attr("id", id)
        .child(children())
}