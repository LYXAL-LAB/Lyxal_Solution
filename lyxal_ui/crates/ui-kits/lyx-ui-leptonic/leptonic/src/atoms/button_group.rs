use leptos::*;

#[component]
pub fn ButtonGroup(
    children: Children,
    #[prop(into, optional)] id: Option<AttributeValue>,
    #[prop(into, optional)] class: Option<AttributeValue>,
    #[prop(into, optional)] style: Option<AttributeValue>,
    /// Arbitrary additional LeptonicAttributes.
    #[prop(attrs)]
    LeptonicAttributes: Vec<(&'static str, LeptonicAttribute)>,
) -> impl IntoView {
    // TODO: Manage focus through something like `useFocusContainer`?

    view! {
        <leptonic-btn-group {..LeptonicAttributes} id=id class=class style=style>
            { children() }
        </leptonic-btn-group>
    }
}
