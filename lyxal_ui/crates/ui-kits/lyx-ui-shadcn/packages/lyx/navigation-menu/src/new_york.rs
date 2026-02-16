use leptos::prelude::*;
use leptos_style::Style;

const NAVIGATION_MENU_CLASS: &str = "inline-flex items-center justify-center whitespace-nowrap rounded-md text-sm font-medium ring-offset-background transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50";

#[component]
pub fn NavigationMenu(
    #[prop(into, optional)] variant: MaybeProp<String>,
    #[prop(into, optional)] size: MaybeProp<String>,

    #[prop(into, optional)] disabled: Signal<bool>,
    #[prop(into, optional)] class: MaybeProp<String>,
    #[prop(into, optional)] id: MaybeProp<String>,
    #[prop(into, optional)] style: Signal<Style>,
    #[prop(optional)] children: Option<Children>,
) -> impl IntoView {


    let computed_class = Signal::derive(move || {
        let variant_class = match variant.get().unwrap_or_default().as_str() {
            "default" => "bg-primary text-primary-foreground hover:bg-primary/90",
            "destructive" => "bg-destructive text-destructive-foreground hover:bg-destructive/90",
            "outline" => "border border-input bg-background hover:bg-accent hover:text-accent-foreground",
            "secondary" => "bg-secondary text-secondary-foreground hover:bg-secondary/80",
            "ghost" => "hover:bg-accent hover:text-accent-foreground",
            "link" => "text-primary underline-offset-4 hover:underline",
            _ => "bg-primary text-primary-foreground hover:bg-primary/90",
        };
        
        let size_class = match size.get().unwrap_or_default().as_str() {
            "default" => "h-10 px-4 py-2",
            "sm" => "h-9 rounded-md px-3",
            "lg" => "h-11 rounded-md px-8",
            "icon" => "h-10 w-10",
            _ => "h-10 px-4 py-2",
        };
        
        format!("{} {} {} {}", NAVIGATION_MENU_CLASS, variant_class, size_class, class.get().unwrap_or_default())
    });

    view! {
        <nav
            class=computed_class
            id=id.get().unwrap_or_default()
            style=move || style.get().to_string()
        >
            {children.map(|c| c())}
        </nav>
    }
}

#[component]
pub fn NavigationMenuList(
    #[prop(into, optional)] class: MaybeProp<String>,
    #[prop(optional)] children: Option<Children>,
) -> impl IntoView {
    view! {
        <ul class=move || format!("flex items-center space-x-1 {}", class.get().unwrap_or_default())>
            {children.map(|c| c())}
        </ul>
    }
}

#[component]
pub fn NavigationMenuItem(
    #[prop(optional)] children: Option<Children>,
) -> impl IntoView {
    view! {
        <li>
            {children.map(|c| c())}
        </li>
    }
}

#[component]
pub fn NavigationMenuTrigger(
    #[prop(into, optional)] disabled: Signal<bool>,
    #[prop(into, optional)] class: MaybeProp<String>,
    #[prop(into, optional)] id: MaybeProp<String>,
    #[prop(into, optional)] style: Signal<Style>,
    #[prop(optional)] children: Option<Children>,
) -> impl IntoView {
    view! {
        <button
            class=move || format!("inline-flex items-center justify-center {}", class.get().unwrap_or_default())
            id=id.get().unwrap_or_default()
            style=move || style.get().to_string()
            disabled=disabled
        >
            {children.map(|c| c())}
        </button>
    }
}

#[component]
pub fn NavigationMenuContent(
    #[prop(into, optional)] class: MaybeProp<String>,
    #[prop(into, optional)] id: MaybeProp<String>,
    #[prop(into, optional)] style: Signal<Style>,
    #[prop(optional)] children: Option<Children>,
) -> impl IntoView {
    view! {
        <div
            class=move || format!("absolute left-0 top-0 w-full {}", class.get().unwrap_or_default())
            id=id.get().unwrap_or_default()
            style=move || style.get().to_string()
        >
            {children.map(|c| c())}
        </div>
    }
}
