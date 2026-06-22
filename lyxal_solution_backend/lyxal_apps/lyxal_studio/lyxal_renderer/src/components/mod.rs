use leptos::*;
use lyxal_types::instance::Instance;

#[component]
pub fn Dynamic(view: String, class: String, children: Children) -> impl IntoView 
{
    // Minimal implementation stub using a div
    view! { <div data-tag=view class=class>{children()}</div> }
}

pub fn render_component(instance: &Instance, class: String, children: View) -> View {
    let tag = instance.component.clone();
    view! { <Dynamic view=tag class=class>{move || children.clone()}</Dynamic> }.into_view()
}

