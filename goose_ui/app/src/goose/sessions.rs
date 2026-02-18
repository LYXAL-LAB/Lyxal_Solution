use leptos::prelude::*;
use icons::{ArrowLeft, MessageSquare, Search, Hash};
use tw_merge::tw_merge;
use crate::goose::api::{list_sessions, get_session_messages, Session};

#[component]
pub fn SessionsView() -> impl IntoView {
    let (search_term, set_search_term) = signal(String::new());
    let (selected_session, set_selected_session) = signal(Option::<String>::None);
    let sessions_resource = Resource::new(|| (), |_| async move { list_sessions().await });

    view! {
        <div class="flex flex-1 flex-col h-full bg-background overflow-hidden text-foreground">
            {move || {
                if let Some(session_id) = selected_session.get() {
                    view! {
                        <SessionHistory
                            session_id=session_id
                            on_back=move || set_selected_session.set(None)
                        />
                    }.into_any()
                } else {
                    let search = search_term.clone();
                    view! {
                        <div class="flex flex-col h-full">
                            // Header
                            <div class="bg-background px-8 pb-6 pt-16 border-b shrink-0">
                                <h1 class="text-4xl font-light mb-2">"Sessions"</h1>
                                <p class="text-sm text-muted-foreground mb-4">
                                    "Browse and manage your previous chat sessions."
                                </p>
                                <div class="relative max-w-md">
                                    <Search class="absolute left-3 top-1/2 -translate-y-1/2 size-4 text-muted-foreground" />
                                    <input
                                        type="text"
                                        placeholder="Search sessions..."
                                        class="w-full bg-muted/50 border border-border rounded-xl py-2 pl-10 pr-4 text-sm outline-none focus:ring-2 focus:ring-primary/20 transition-all"
                                        on:input=move |ev| set_search_term.set(event_target_value(&ev))
                                    />
                                </div>
                            </div>

                            // Session List
                            <div class="flex-1 overflow-y-auto px-8 py-6">
                                <Suspense fallback=|| view! {
                                    <div class="space-y-3">
                                        <div class="h-20 bg-muted rounded-xl animate-pulse" />
                                        <div class="h-20 bg-muted rounded-xl animate-pulse" />
                                        <div class="h-20 bg-muted rounded-xl animate-pulse" />
                                    </div>
                                }>
                                    {move || {
                                        let res = sessions_resource.get();
                                        match res {
                                            Some(Ok(sessions)) => {
                                                let term = search.get().to_lowercase();
                                                let filtered: Vec<Session> = if term.is_empty() {
                                                    sessions
                                                } else {
                                                    sessions.into_iter().filter(|s| {
                                                        s.title.as_deref().unwrap_or("").to_lowercase().contains(&term)
                                                            || s.id.to_lowercase().contains(&term)
                                                    }).collect()
                                                };

                                                if filtered.is_empty() {
                                                    view! {
                                                        <div class="flex flex-col items-center justify-center py-20 text-muted-foreground">
                                                            <MessageSquare class="size-12 mb-4 opacity-20" />
                                                            <p class="text-sm">"No sessions found."</p>
                                                        </div>
                                                    }.into_any()
                                                } else {
                                                    let items = filtered.into_iter().map(|session| {
                                                        let id = session.id.clone();
                                                        let title = session.title.clone().unwrap_or_else(|| "Untitled Session".to_string());
                                                        let id_click = id.clone();

                                                        view! {
                                                            <button
                                                                on:click=move |_| set_selected_session.set(Some(id_click.clone()))
                                                                class="w-full flex items-center justify-between p-5 rounded-xl border bg-card hover:border-primary/30 hover:bg-accent/5 transition-all group text-left"
                                                            >
                                                                <div class="min-w-0 flex-1">
                                                                    <div class="flex items-center gap-3">
                                                                        <MessageSquare class="size-4 text-muted-foreground group-hover:text-primary transition-colors shrink-0" />
                                                                        <h3 class="font-semibold text-foreground truncate">{title}</h3>
                                                                    </div>
                                                                    <p class="text-xs text-muted-foreground mt-1 ml-7 font-mono truncate">{id.clone()}</p>
                                                                </div>
                                                                <div class="text-xs text-muted-foreground opacity-0 group-hover:opacity-100 transition-opacity ml-4 shrink-0 bg-muted px-2 py-0.5 rounded border border-border/50 font-bold">
                                                                    "View"
                                                                </div>
                                                            </button>
                                                        }.into_any()
                                                    }).collect::<Vec<_>>();
                                                    view! { <div class="space-y-3">{items}</div> }.into_any()
                                                }
                                            },
                                            Some(Err(e)) => view! {
                                                <div class="text-destructive p-4 border border-destructive/20 bg-destructive/5 rounded-lg">
                                                    "Failed to load sessions: " {e.to_string()}
                                                </div>
                                            }.into_any(),
                                            None => ().into_any()
                                        }
                                    }}
                                </Suspense>
                            </div>
                        </div>
                    }.into_any()
                }
            }}
        </div>
    }
}

#[component]
fn SessionHistory(session_id: String, on_back: impl Fn() + Send + Sync + Clone + 'static) -> impl IntoView {
    let sid = session_id.clone();
    let messages_resource = Resource::new(
        move || sid.clone(),
        |id: String| async move { get_session_messages(id).await }
    );

    view! {
        <div class="flex flex-col h-full">
            // Header
            <div class="bg-background px-8 pb-6 pt-16 border-b shrink-0">
                <div class="flex items-center gap-4">
                    <button
                        on:click=move |_| on_back()
                        class="flex items-center gap-2 text-sm font-medium text-muted-foreground hover:text-foreground transition-colors group"
                    >
                        <ArrowLeft class="size-4 group-hover:-translate-x-1 transition-transform" />
                        "Back to Sessions"
                    </button>
                </div>
                <h1 class="text-2xl font-bold mt-3 tracking-tight">"Session History"</h1>
                <p class="text-xs text-muted-foreground font-mono mt-1">{session_id.clone()}</p>
            </div>

            // Messages
            <div class="flex-1 overflow-y-auto px-8 py-6">
                <Suspense fallback=|| view! {
                    <div class="space-y-4">
                        <div class="h-16 bg-muted rounded-xl animate-pulse" />
                        <div class="h-24 bg-muted rounded-xl animate-pulse" />
                        <div class="h-16 bg-muted rounded-xl animate-pulse" />
                    </div>
                }>
                    {move || {
                        let res = messages_resource.get();
                        match res {
                            Some(Ok(messages)) => {
                                if messages.is_empty() {
                                    view! {
                                        <div class="flex flex-col items-center justify-center py-20 text-muted-foreground">
                                            <MessageSquare class="size-12 mb-4 opacity-20" />
                                            <p>"No messages in this session."</p>
                                        </div>
                                    }.into_any()
                                } else {
                                    // Stats bar
                                    let msg_count = messages.len();
                                    let user_count = messages.iter().filter(|m| m.role == "user").count();
                                    let assistant_count = messages.iter().filter(|m| m.role != "user").count();

                                    let items = messages.into_iter().map(|msg| {
                                        let is_user = msg.role == "user";
                                        let content_text = msg.content.iter().map(|c| c.text.clone()).collect::<Vec<_>>().join("\n");

                                        view! {
                                            <div class=move || tw_merge!(
                                                "flex w-full",
                                                if is_user { "justify-end" } else { "justify-start" }
                                            )>
                                                <div class=move || tw_merge!(
                                                    "max-w-[85%] text-sm leading-relaxed rounded-2xl px-4 py-3",
                                                    if is_user {
                                                        "bg-muted/80 text-foreground border border-border shadow-sm"
                                                    } else {
                                                        "text-foreground bg-card border border-border/50 shadow-sm"
                                                    }
                                                )>
                                                    <div class="flex items-center gap-2 mb-1">
                                                        <span class=move || tw_merge!(
                                                            "text-[10px] font-bold uppercase tracking-wider",
                                                            if is_user { "text-primary" } else { "text-muted-foreground" }
                                                        )>
                                                            {if is_user { "You" } else { "Goose" }}
                                                        </span>
                                                    </div>
                                                    <p class="whitespace-pre-wrap break-words">{content_text}</p>
                                                </div>
                                            </div>
                                        }.into_any()
                                    }).collect::<Vec<_>>();

                                    view! {
                                        <div class="space-y-2">
                                            // Stats
                                            <div class="flex items-center gap-4 mb-6 text-xs text-muted-foreground">
                                                <div class="flex items-center gap-1.5">
                                                    <Hash class="size-3.5" />
                                                    <span>{format!("{} messages", msg_count)}</span>
                                                </div>
                                                <span>{"•"}</span>
                                                <span>{format!("{} from you", user_count)}</span>
                                                <span>{"•"}</span>
                                                <span>{format!("{} from goose", assistant_count)}</span>
                                            </div>
                                            <div class="space-y-4">{items}</div>
                                        </div>
                                    }.into_any()
                                }
                            },
                            Some(Err(e)) => view! {
                                <div class="text-destructive p-4 border border-destructive/20 bg-destructive/5 rounded-lg">
                                    "Failed to load messages: " {e.to_string()}
                                </div>
                            }.into_any(),
                            None => ().into_any()
                        }
                    }}
                </Suspense>
            </div>
        </div>
    }
}
