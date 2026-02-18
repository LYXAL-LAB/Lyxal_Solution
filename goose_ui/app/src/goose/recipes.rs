use leptos::prelude::*;

use icons::{Bot}; // Fallback to Bot if others missing


#[derive(Clone, Debug, PartialEq)]
pub struct Recipe {
    pub id: String,
    pub title: String,
    pub description: String,
    pub last_modified: String,
    pub schedule: Option<String>,
    pub slash_command: Option<String>,
}

#[component]
pub fn RecipesView() -> impl IntoView {
    let (search_term, set_search_term) = signal("".to_string());
    
    // Mock data
    let recipes = vec![
        Recipe {
            id: "1".into(),
            title: "Daily Standup".into(),
            description: "Automated daily standup report generation.".into(),
            last_modified: "2023-10-27".into(),
            schedule: Some("Mon-Fri 9:00 AM".into()),
            slash_command: Some("standup".into()),
        },
        Recipe {
            id: "2".into(),
            title: "Code Review".into(),
            description: "Review current changes for best practices.".into(),
            last_modified: "2023-10-26".into(),
            schedule: None,
            slash_command: Some("review".into()),
        },
         Recipe {
            id: "3".into(),
            title: "Summarize Thread".into(),
            description: "Summarize the current conversation thread.".into(),
            last_modified: "2023-10-25".into(),
            schedule: None,
            slash_command: None,
        },
    ];

    let filtered_recipes = move || {
        let term = search_term.get().to_lowercase();
        if term.is_empty() {
            recipes.clone()
        } else {
            recipes.iter()
                .filter(|r| r.title.to_lowercase().contains(&term) || r.description.to_lowercase().contains(&term))
                .cloned()
                .collect()
        }
    };

    view! {
        <div class="flex flex-1 flex-col h-full bg-background-default">
             <div class="bg-background px-8 pb-8 pt-16 border-b">
                <div class="flex flex-col page-transition">
                  <div class="flex justify-between items-center mb-1">
                    <h1 class="text-4xl font-light">"Recipes"</h1>
                    <div class="flex gap-2">
                      <button class="inline-flex items-center justify-center whitespace-nowrap rounded-md text-sm font-medium transition-colors focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring disabled:pointer-events-none disabled:opacity-50 border border-input bg-background shadow-sm hover:bg-accent hover:text-accent-foreground h-8 px-3 text-xs flex items-center gap-2">
                        <Bot class="size-4" />
                        "Create Recipe"
                      </button>
                    </div>
                  </div>
                  <p class="text-sm text-text-muted mb-1 text-muted-foreground">
                    "View and manage your saved recipes to quickly start new sessions with predefined configurations."
                  </p>
                </div>
            </div>

            <div class="flex-1 min-h-0 relative px-8 py-4">
                 // Search Bar
                 <div class="relative mb-4">
                    <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                        // Search icon
                        <span class="text-muted-foreground">"🔍"</span> 
                    </div>
                    <input
                        type="text"
                        placeholder="Search recipes..."
                        class="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 pl-10 text-sm ring-offset-background file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
                        on:input=move |ev| set_search_term.set(event_target_value(&ev))
                    />
                 </div>

                 <div class="space-y-2">
                    <For each=filtered_recipes key=|r| r.id.clone() children=move |recipe| {
                        let has_schedule = recipe.schedule.is_some();
                        let has_slash = recipe.slash_command.is_some();
                        
                        view! {
                            <div class="flex flex-col p-4 border rounded-lg bg-card hover:bg-muted/50 transition-colors">
                                <div class="flex justify-between items-start gap-4">
                                    <div class="min-w-0 flex-1">
                                         <h3 class="text-base font-medium truncate mb-1">{recipe.title}</h3>
                                         <p class="text-sm text-muted-foreground mb-2 line-clamp-2">{recipe.description}</p>
                                         
                                         <div class="flex flex-col gap-1 text-xs text-muted-foreground">
                                             <div class="flex items-center gap-1">
                                                 <Bot class="size-3" />
                                                 {recipe.last_modified}
                                             </div>
                                             <div class="flex gap-3">
                                                 <Show when=move || has_schedule>
                                                     <div class="flex items-center gap-1 text-blue-600 dark:text-blue-400">
                                                         <Bot class="size-3" />
                                                         "Scheduled" // could format schedule string
                                                     </div>
                                                 </Show>
                                                  <Show when=move || has_slash>
                                                     <div class="flex items-center gap-1 text-purple-600 dark:text-purple-400">
                                                         <Bot class="size-3" />
                                                         {format!("/{}", recipe.slash_command.clone().unwrap_or_default())}
                                                     </div>
                                                 </Show>
                                             </div>
                                         </div>
                                    </div>
                                    
                                    <div class="flex items-center gap-2 shrink-0">
                                         <button class="inline-flex items-center justify-center whitespace-nowrap rounded-md text-sm font-medium transition-colors focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring disabled:pointer-events-none disabled:opacity-50 border border-input bg-background shadow-sm hover:bg-accent hover:text-accent-foreground h-8 w-8 p-0" title="Use recipe">
                                             <Bot class="size-4" />
                                         </button>
                                    </div>
                                </div>
                            </div>
                        }
                    } />
                 </div>
            </div>
        </div>
    }
}
