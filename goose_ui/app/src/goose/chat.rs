use leptos::prelude::*;
use leptos::html;
use crate::components::ui::markdown::Markdown;
use icons::{Bot, Paperclip, Send, FolderTree, MessageSquare, Code};
use tw_merge::tw_merge;
use crate::goose::api::{Message, MessageContent, send_message};
use leptos_router::hooks::use_query_map;
use leptos::task::spawn_local;

#[component]
pub fn GooseChat() -> impl IntoView {
    let query = use_query_map();
    let session_id = move || query.get().get("id").map(|s| s.to_string()).unwrap_or_default();
    
    let (messages, set_messages) = signal(Vec::<Message>::new());
    let input = RwSignal::new(String::new());
    let (is_loading, set_is_loading) = signal(false);
    let scroll_viewport_ref = NodeRef::<html::Div>::new();

    let history = Resource::new(
        move || session_id(),
        |id: String| async move {
            if id.is_empty() { return Vec::<Message>::new(); }
            crate::goose::api::get_session_messages(id).await.unwrap_or_default()
        }
    );

    Effect::new(move |_| {
        if let Some(h) = history.get() {
            set_messages.set(h);
        }
    });

    // Fix: Access scroll_viewport_ref.get_untracked() inside raf to avoid reactive warning
    Effect::new(move |_| {
        messages.track();
        request_animation_frame(move || {
            if let Some(div) = scroll_viewport_ref.get_untracked() {
                div.set_scroll_top(div.scroll_height());
            }
        });
    });

    let perform_send = move || {
        let val = input.get();
        let sid = session_id();
        if !val.trim().is_empty() && !sid.is_empty() {
            set_is_loading.set(true);
            set_messages.update(|m| m.push(Message {
                id: None,
                role: "user".into(),
                content: vec![MessageContent { text: val.clone() }],
                created: 0,
            }));
            input.set("".into());

            spawn_local(async move {
                match send_message(sid, val).await {
                    Ok(response_messages) => {
                        set_messages.update(|m| {
                            for msg in response_messages {
                                if msg.role != "user" {
                                    m.push(msg);
                                }
                            }
                        });
                    }
                    Err(e) => {
                        set_messages.update(|m| m.push(Message {
                            id: None,
                            role: "assistant".into(),
                            content: vec![MessageContent { text: format!("Error: {}", e) }],
                            created: 0,
                        }));
                    }
                }
                set_is_loading.set(false);
            });
        }
    };

    view! {
        <div class="flex flex-col h-full bg-background relative overflow-hidden font-sans">
            // Discrete branding (Top Right)
            <div class="absolute top-4 right-6 z-10 flex items-center gap-1.5 opacity-30 select-none">
                <Bot class="size-5" />
                <span class="text-sm font-semibold tracking-tight uppercase tracking-widest">"goose"</span>
            </div>

            // Chat Messages
            <div class="flex-1 overflow-y-auto px-6 pt-16 pb-32 scroll-smooth" node_ref=scroll_viewport_ref>
                <div class="max-w-4xl mx-auto w-full flex flex-col min-h-full">
                    {move || {
                        let msgs = messages.get();
                        if msgs.is_empty() {
                            view! { 
                                <div class="mt-auto mb-4 animate-in fade-in slide-in-from-bottom-4 duration-700">
                                    <PopularTopics append=move |t| input.set(t) /> 
                                </div>
                            }.into_any()
                        } else {
                            view! {
                                <div class="space-y-10 pb-4">
                                    <For each=move || messages.get() key=|m| format!("{:?}-{:?}", m.id, m.created) children=move |msg| {
                                        let is_user = msg.role == "user";
                                        view! {
                                            <div class=move || tw_merge!("flex w-full group", if is_user { "justify-end" } else { "justify-start" })>
                                                <div class=move || tw_merge!(
                                                    "max-w-[85%] text-[15px] leading-relaxed",
                                                    if is_user { 
                                                        "bg-muted/80 text-foreground px-4 py-2.5 rounded-2xl shadow-sm border border-border" 
                                                    } else { 
                                                        "text-foreground pr-10" 
                                                    }
                                                )>
                                                    <For each=move || msg.content.clone() key=|c| c.text.clone() children=move |content| {
                                                        let text = content.text.clone();
                                                        if text.contains("<think>") {
                                                            let parts: Vec<&str> = text.split("</think>").collect();
                                                            let thinking = parts[0].replace("<think>", "");
                                                            let response = parts.get(1).unwrap_or(&"");
                                                            view! {
                                                                <details class="bg-muted/40 border rounded-xl p-3 mb-4 text-sm text-muted-foreground italic">
                                                                    <summary class="cursor-pointer select-none font-medium hover:text-foreground transition-colors">"Goose is thinking..."</summary>
                                                                    <div class="mt-2 not-italic text-foreground/80"><Markdown content=thinking /></div>
                                                                </details>
                                                                <Markdown content=response.to_string() />
                                                            }.into_any()
                                                        } else {
                                                            view! { <Markdown content=text /> }.into_any()
                                                        }
                                                    } />
                                                </div>
                                            </div>
                                        }.into_any()
                                    } />
                                </div>
                            }.into_any()
                        }
                    }}
                </div>
            </div>
            
            // Input Bar
            <div class="absolute bottom-0 left-0 right-0 p-4 bg-gradient-to-t from-background via-background/95 to-transparent z-20">
                <div class="max-w-3xl mx-auto relative flex items-end gap-2 bg-card p-2 rounded-2xl border shadow-2xl ring-1 ring-black/5 focus-within:ring-2 focus-within:ring-primary/20 transition-all">
                    <button class="p-3 text-muted-foreground hover:text-foreground transition-colors" title="Attach file">
                        <Paperclip class="size-5" />
                    </button>
                    <textarea
                        placeholder="Message Goose..."
                        class="flex-1 resize-none min-h-[44px] max-h-[200px] border-0 focus:ring-0 bg-transparent p-3 text-base outline-none text-foreground placeholder:text-muted-foreground/60"
                        prop:value=move || input.get()
                        on:input=move |ev| input.set(event_target_value(&ev))
                        on:keydown=move |ev| if ev.key() == "Enter" && !ev.shift_key() { ev.prevent_default(); perform_send(); }
                    />
                    <button 
                        on:click=move |_| perform_send() 
                        class="p-3 bg-foreground text-background rounded-xl hover:opacity-90 transition-all disabled:opacity-10 flex items-center justify-center shadow-lg"
                        disabled=move || is_loading.get() || input.get().trim().is_empty()
                    >
                        <Send class="size-5" />
                    </button>
                </div>
            </div>
        </div>
    }
}

#[component]
fn PopularTopics<F>(append: F) -> impl IntoView 
where F: Fn(String) + Clone + Send + 'static 
{
    view! {
        <div class="max-w-md space-y-4 ml-1">
            <h3 class="text-[10px] font-bold text-muted-foreground uppercase tracking-[0.2em] opacity-70">"Popular chat topics"</h3>
            <div class="space-y-1">
                <TopicItem 
                    append=append.clone()
                    icon=move || view! { <FolderTree class="size-5" /> }
                    text="Organize the photos on my desktop into folders by subject matter"
                />
                <TopicItem 
                    append=append.clone()
                    icon=move || view! { <MessageSquare class="size-5" /> }
                    text="Describe how various forms of government works and rank each by units of geese"
                />
                <TopicItem 
                    append=append
                    icon=move || view! { <Code class="size-5" /> }
                    text="Develop a tamagotchi game that lives on my computer with pixelated styling"
                />
            </div>
        </div>
    }
}

#[component]
fn TopicItem<F, I, IV>(append: F, icon: I, text: &'static str) -> impl IntoView 
where F: Fn(String) + 'static, I: Fn() -> IV + Send + 'static, IV: IntoView + 'static
{
    view! {
        <button 
            on:click=move |_| append(text.to_string())
            class="flex items-center justify-between w-full p-2.5 rounded-xl hover:bg-muted/80 transition-all group text-left border border-transparent hover:border-border/50"
        >
            <div class="flex items-center gap-3 min-w-0">
                <div class="text-muted-foreground group-hover:text-primary transition-colors flex-shrink-0">{icon()}</div>
                <p class="text-[13px] text-foreground leading-tight truncate font-medium">{text}</p>
            </div>
            <span class="text-[10px] font-bold text-muted-foreground opacity-0 group-hover:opacity-100 transition-opacity ml-4 shrink-0 bg-muted px-2 py-0.5 rounded shadow-sm border border-border/50">"Start"</span>
        </button>
    }
}
