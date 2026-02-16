use leptos::*;

#[component]
pub fn Box(
    #[prop(into, optional)] id: Option<AttributeValue>,
    #[prop(into, optional)] class: Option<AttributeValue>,
    #[prop(into, optional)] style: Option<AttributeValue>,
    /// Arbitrary additional LeptonicAttributes.
    #[prop(attrs)]
    LeptonicAttributes: Vec<(&'static str, LeptonicAttribute)>,
    children: Children,
) -> impl IntoView {
    view! {
        <leptonic-box {..LeptonicAttributes} id=id class=class style=style>
            { children() }
        </leptonic-box>
    }
}
