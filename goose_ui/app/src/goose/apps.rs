use leptos::prelude::*;
use crate::components::ui::button::{Button, ButtonSize, ButtonVariant};
use icons::{Play, Download, Upload};

#[derive(Clone, Debug, PartialEq)]
pub struct GooseApp {
    pub name: String,
    pub description: Option<String>,
    pub mcp_servers: Vec<String>,
    pub uri: String,
}

#[component]
pub fn AppsView() -> impl IntoView {
    // Mock data
    let apps = vec![
        GooseApp {
            name: "Calculator".into(),
            description: Some("A simple calculator app".into()),
            mcp_servers: vec!["math".into()],
            uri: "app:calculator".into(),
        },
        GooseApp {
            name: "Weather".into(),
            description: Some("Check current weather".into()),
            mcp_servers: vec!["weather-api".into()],
            uri: "app:weather".into(),
        },
        GooseApp {
            name: "Notes".into(),
            description: Some("Take quick notes".into()),
            mcp_servers: vec!["notes".into()],
            uri: "app:notes".into(),
        },
        GooseApp {
            name: "Todo List".into(),
            description: Some("Manage your tasks".into()),
            mcp_servers: vec!["todo".into()],
            uri: "app:todo".into(),
        },
    ];

    view! {
        <div class="flex flex-1 flex-col h-full bg-background-default">
             <div class="bg-background px-8 pb-8 pt-16 border-b">
                <div class="flex justify-between items-center mb-1">
                    <h1 class="text-4xl font-light">"Apps"</h1>
                    <Button variant=ButtonVariant::Outline size=ButtonSize::Sm class="flex items-center gap-2">
                        <Upload class="size-4" />
                        "Import App"
                    </Button>
                </div>
                <div class="mb-4">
                    <p class="text-sm text-muted-foreground mb-2">
                        "Applications from your MCP servers and Apps build by goose itself. You can ask it to creating new apps through the chat interface."
                    </p>
                    <p class="text-xs text-amber-600 dark:text-amber-500">
                        "⚠️ Experimental feature - may change or be removed at any time"
                    </p>
                </div>
            </div>
            
            <div class="flex-1 overflow-y-auto bg-muted/20 px-8 py-8">
                 <div class="grid gap-4 p-1" style="grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));">
                    <For each=move || apps.clone() key=|app| app.uri.clone() children=move |app| {
                        let is_custom_app = app.mcp_servers.contains(&"apps".to_string());
                        let description = app.description.clone();
                        let mcp_servers = app.mcp_servers.clone();
                        
                        view! {
                             <div class="flex flex-col p-4 border rounded-lg bg-card hover:border-primary/50 transition-colors shadow-sm">
                                <div class="flex-1 mb-4">
                                     <h3 class="font-medium text-foreground mb-2">{app.name}</h3>
                                     {
                                         if let Some(desc) = description {
                                             view! { <p class="text-sm text-muted-foreground mb-2">{desc}</p> }.into_any()
                                         } else {
                                             ().into_any()
                                         }
                                     }
                                     <div class="flex flex-wrap gap-1">
                                         <For each=move || mcp_servers.clone() key=|s| s.clone() children=move |server| {
                                             view! {
                                                 <span class="inline-block px-2 py-1 text-xs bg-muted text-muted-foreground rounded">
                                                     {server}
                                                 </span>
                                             }
                                         }/>
                                     </div>
                                </div>
                                <div class="flex gap-2">
                                     <Button variant=ButtonVariant::Default size=ButtonSize::Sm class="flex items-center gap-2 flex-1">
                                         <Play class="size-4" />
                                         "Launch"
                                     </Button>
                                     <Show when=move || is_custom_app>
                                          <Button variant=ButtonVariant::Outline size=ButtonSize::Sm class="flex items-center gap-2">
                                              <Download class="size-4" />
                                          </Button>
                                     </Show>
                                </div>
                             </div>
                        }
                    } />
                 </div>
            </div>
        </div>
    }
}
