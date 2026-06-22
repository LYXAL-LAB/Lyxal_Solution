use leptos::*;

#[component]
pub fn Checkbox(
    #[prop(optional)] class: String,
    #[prop(optional)] id: String,
    children: Children,
) -> impl IntoView {
    view! {
        <div class=class id=id>
            {children()}
        </div>
    }
}

