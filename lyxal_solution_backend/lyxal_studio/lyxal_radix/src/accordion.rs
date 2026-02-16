use leptos::*;

#[component]
pub fn Accordion(
    #[prop(optional)] default_value: String,
    children: Children
) -> impl IntoView {
    let (value, set_value) = create_signal(default_value);
    provide_context((value, set_value));
    
    view! {
        <div class="accordion-root">
            {children()}
        </div>
    }
}

#[component]
pub fn AccordionItem(value: String, children: Children) -> impl IntoView {
    view! { <div class="accordion-item" data-value=value>{children()}</div> }
}

#[component]
pub fn AccordionTrigger(children: Children) -> impl IntoView {
    // Logique de toggle Ã  implÃ©menter avec le contexte
    view! { <button class="accordion-trigger">{children()}</button> }
}

#[component]
pub fn AccordionContent(children: Children) -> impl IntoView {
    view! { <div class="accordion-content">{children()}</div> }
}

