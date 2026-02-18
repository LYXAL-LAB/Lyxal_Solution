use leptos::prelude::*;
use leptos_router::components::A;
use leptos_router::hooks::use_query_map;
use crate::goose::api::{list_sessions};
use icons::{MessageSquarePlus, Settings, Bot, Clock, Puzzle, ChevronRight, History, FileText, AppWindow};
use tw_merge::tw_merge;

#[component]
pub fn GooseSidebar() -> impl IntoView {
    let query = use_query_map();
    let current_id = move || query.get().get("id").map(|s| s.to_string()).unwrap_or_default();
    let (is_chat_expanded, set_is_chat_expanded) = signal(true);

    let sessions_resource = Resource::new(|| (), |_| async move { list_sessions().await });

    view! {
        <aside class="w-64 border-r bg-background flex flex-col h-full overflow-hidden hidden lg:flex text-foreground pt-12">
            <div class="flex-1 overflow-y-auto px-2">
                
                // Home Section
                <div class="px-2 mb-1">
                    <A href="/" 
                       attr:class=move || tw_merge!(
                           "flex items-center gap-3 px-3 py-2 rounded-lg transition-all text-sm font-medium w-full",
                           if current_id().is_empty() { "bg-muted text-foreground" } else { "text-muted-foreground hover:bg-muted/50 hover:text-foreground" }
                       )>
                        <Bot class="size-4" />
                        <span>"Home"</span>
                    </A>
                </div>

                // Chat Section
                <div class="px-2">
                    <div class="flex items-center group">
                        <A href="/" attr:class="flex-1 flex items-center gap-3 px-3 py-2 rounded-lg hover:bg-muted/50 transition-all text-sm font-medium text-foreground">
                            <MessageSquarePlus class="size-4 text-primary" />
                            <span>"Chat"</span>
                        </A>
                        <button 
                            on:click=move |_| set_is_chat_expanded.update(|v| *v = !*v)
                            class="p-1 hover:bg-muted rounded-md transition-colors mr-1"
                        >
                            <ChevronRight attr:class=move || tw_merge!("size-4 text-muted-foreground transition-transform", if is_chat_expanded.get() { "rotate-90" } else { "" }) />
                        </button>
                    </div>

                    <Show when=move || is_chat_expanded.get()>
                        <div class="mt-1 relative">
                            // Tree visualization
                            <Suspense fallback=|| view! { <div class="pl-9 py-2 text-[11px] text-muted-foreground animate-pulse">"Loading..."</div> }>
                                {move || {
                                    let val = sessions_resource.get();
                                    match val {
                                        Some(Ok(sessions)) => {
                                            if sessions.is_empty() {
                                                view! { <div class="pl-9 py-2 text-[11px] text-muted-foreground">"No recent chats"</div> }.into_any()
                                            } else {
                                                let sessions_len = sessions.len();
                                                let items = sessions.into_iter().take(10).enumerate().map(|(idx, session)| {
                                                    let id = session.id.clone();
                                                    let title = session.title.clone().unwrap_or_else(|| "New Chat".to_string());
                                                    let id_active = id.clone();
                                                    let is_last = idx == sessions_len - 1 || idx == 9;

                                                    view! {
                                                        <div class="relative flex items-center ml-3">
                                                            // Vertical line
                                                            <div class=tw_merge!(
                                                                "absolute left-0 w-px bg-border",
                                                                if is_last { "top-0 h-1/2" } else { "top-0 h-full" }
                                                            ) />
                                                            // Horizontal branch
                                                            <div class="absolute left-0 w-2.5 h-px bg-border top-1/2" />
                                                            
                                                            <A href=format!("/?id={}", id)
                                                               attr:class=move || {
                                                                   let active = current_id() == id_active;
                                                                   tw_merge!(
                                                                       "w-full text-left ml-3 px-2 py-1.5 rounded-md text-sm transition-colors flex items-center justify-between group/item truncate",
                                                                       if active { "bg-muted text-foreground" } 
                                                                       else { "text-muted-foreground hover:bg-muted/30 hover:text-foreground" }
                                                                   )
                                                               }
                                                            >
                                                                <span class="truncate">{title}</span>
                                                            </A>
                                                        </div>
                                                    }.into_any()
                                                }).collect::<Vec<_>>();
                                                view! { <div class="space-y-0.5">{items}</div> }.into_any()
                                            }
                                        }
                                        Some(Err(_)) => view! { <div class="pl-9 py-2 text-[10px] text-destructive">"Error loading sessions"</div> }.into_any(),
                                        None => view! { <div class="pl-9 py-2 text-[11px] text-muted-foreground animate-pulse">"Loading..."</div> }.into_any()
                                    }
                                }}
                            </Suspense>
                            
                            // View All Link
                            <A href="/sessions" attr:class="w-full text-left ml-6 px-3 py-1.5 rounded-md text-[12px] text-muted-foreground hover:bg-muted/30 transition-colors flex items-center gap-2 mt-1">
                                <History class="size-3.5" />
                                <span>"View All"</span>
                            </A>
                        </div>
                    </Show>
                </div>

                <div class="my-4 border-t border-border mx-4" />

                // Navigation Items
                <div class="px-2 space-y-1">
                    <SidebarItem href="/recipes" icon=move || view! { <FileText class="size-4" /> } label="Recipes" />
                    <SidebarItem href="/apps" icon=move || view! { <AppWindow class="size-4" /> } label="Apps" />
                    <SidebarItem href="/schedules" icon=move || view! { <Clock class="size-4" /> } label="Scheduler" />
                    <SidebarItem href="/extensions" icon=move || view! { <Puzzle class="size-4" /> } label="Extensions" />
                </div>
            </div>

            // Bottom Settings
            <div class="p-4 border-t mt-auto">
                <A href="/settings" attr:class="flex items-center gap-3 rounded-lg px-3 py-2 text-sm font-medium text-muted-foreground hover:bg-muted hover:text-foreground transition-all">
                    <Settings class="size-4" />
                    <span>"Settings"</span>
                </A>
            </div>
        </aside>
    }
}

#[component]
fn SidebarItem<F, IV>(href: &'static str, icon: F, label: &'static str) -> impl IntoView 
where F: Fn() -> IV + Send + 'static, IV: IntoView + 'static
{
    view! {
        <A href=href attr:class="flex items-center gap-3 px-3 py-2 rounded-lg hover:bg-muted/50 transition-all text-sm font-medium text-muted-foreground hover:text-foreground">
            <span class="size-4 flex items-center justify-center">
                {icon()}
            </span>
            <span>{label}</span>
        </A>
    }
}
