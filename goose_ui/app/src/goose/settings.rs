use leptos::prelude::*;
use leptos::task::spawn_local;
use icons::{Bot, MessageSquare, Share2, FileText, Keyboard, Monitor, RotateCcw, ArrowLeft, Info, TriangleAlert};
use tw_merge::tw_merge;
use crate::goose::api::{get_prompts, save_prompt, reset_prompt};

#[component]
pub fn SettingsPage() -> impl IntoView {
    let (active_tab, set_active_tab) = signal("prompts".to_string());

    let tab_trigger_class = move |tab_name: &str| {
        let base_class = "inline-flex h-9 items-center justify-center whitespace-nowrap rounded-md px-3 py-1 text-sm font-medium ring-offset-background transition-all focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50";
        let is_active = active_tab.get() == tab_name;
        tw_merge!(
            base_class,
            if is_active { "bg-background text-foreground shadow-sm" } else { "text-muted-foreground hover:bg-muted/50" }
        )
    };

    view! {
        <div class="flex flex-1 flex-col h-full bg-background overflow-hidden text-foreground">
            <div class="px-8 pb-8 pt-16 border-b shrink-0">
                 <h1 class="text-4xl font-light mb-8">"Settings"</h1>
                 
                 <div class="inline-flex h-11 items-center justify-center rounded-lg bg-muted p-1 text-muted-foreground w-fit">
                    <button class=move || tab_trigger_class("models") on:click=move |_| set_active_tab.set("models".into())>
                        <Bot class="mr-2 h-4 w-4" /> "Models"
                    </button>
                    <button class=move || tab_trigger_class("chat") on:click=move |_| set_active_tab.set("chat".into())>
                        <MessageSquare class="mr-2 h-4 w-4" /> "Chat"
                    </button>
                    <button class=move || tab_trigger_class("session") on:click=move |_| set_active_tab.set("session".into())>
                        <Share2 class="mr-2 h-4 w-4" /> "Session"
                    </button>
                    <button class=move || tab_trigger_class("prompts") on:click=move |_| set_active_tab.set("prompts".into())>
                        <FileText class="mr-2 h-4 w-4" /> "Prompts"
                    </button>
                    <button class=move || tab_trigger_class("keyboard") on:click=move |_| set_active_tab.set("keyboard".into())>
                         <Keyboard class="mr-2 h-4 w-4" /> "Keyboard"
                    </button>
                    <button class=move || tab_trigger_class("app") on:click=move |_| set_active_tab.set("app".into())>
                        <Monitor class="mr-2 h-4 w-4" /> "App"
                    </button>
                 </div>
            </div>

            <div class="flex-1 overflow-y-auto p-8">
                <div class="max-w-5xl mx-auto h-full text-foreground">
                    {move || match active_tab.get().as_str() {
                        "prompts" => view! { <PromptsSettings /> }.into_any(),
                        "models" => view! { <ModelsSettings /> }.into_any(),
                        "chat" => view! { <ChatSettings /> }.into_any(),
                        "session" => view! { <SessionSettings /> }.into_any(),
                        "keyboard" => view! { <KeyboardSettings /> }.into_any(),
                        "app" => view! { <AppSettings /> }.into_any(),
                        _ => view! {
                            <div class="flex flex-col items-center justify-center h-full text-muted-foreground">
                                <Info class="size-12 mb-4 opacity-20" />
                                <p>"Cette section est en cours de développement."</p>
                            </div>
                        }.into_any()
                    }}
                </div>
            </div>
        </div>
    }
}

#[component]
fn PromptsSettings() -> impl IntoView {
    let (selected_prompt, set_selected_prompt) = signal(Option::<String>::None);
    let prompts_resource = Resource::new(|| (), |_| async move { get_prompts().await });

    view! {
        <div class="space-y-6 text-foreground">
            {move || {
                if let Some(name) = selected_prompt.get() {
                    let name_clone = name.clone();
                    view! {
                        <PromptEditor 
                            name=name_clone
                            on_back=move || {
                                set_selected_prompt.set(None);
                                prompts_resource.refetch();
                            } 
                        />
                    }.into_any()
                } else {
                    view! {
                        <div class="space-y-6 animate-in fade-in duration-300">
                            <div class="p-6 rounded-xl border border-blue-500/20 bg-blue-500/5 flex gap-4 text-foreground">
                                <Info class="h-6 w-6 text-blue-500 shrink-0 mt-1" />
                                <div class="space-y-2">
                                    <h3 class="text-lg font-semibold text-blue-700 dark:text-blue-400">"Prompt Editing"</h3>
                                    <p class="text-sm text-muted-foreground leading-relaxed">
                                        "Customize the prompts that define goose's behavior. These prompts use Jinja2 templating syntax. Be careful when modifying template variables."
                                    </p>
                                </div>
                            </div>

                            <div class="grid gap-3">
                                <Suspense fallback=|| view! { <div class="space-y-3 text-foreground">
                                    <div class="h-20 bg-muted rounded-xl animate-pulse" />
                                    <div class="h-20 bg-muted rounded-xl animate-pulse" />
                                </div> }>
                                    {move || {
                                        let res = prompts_resource.get();
                                        match res {
                                            Some(Ok(prompts)) => {
                                                if prompts.is_empty() {
                                                    view! { <div class="p-8 text-center text-muted-foreground border border-dashed rounded-xl">"No prompts found in the backend."</div> }.into_any()
                                                } else {
                                                    let list = prompts.into_iter().map(|p| {
                                                        let name = p.name.clone();
                                                        let desc = p.description.clone();
                                                        let customized = p.is_customized;
                                                        view! {
                                                            <div class="flex items-center justify-between p-5 rounded-xl border bg-card hover:border-primary/30 hover:bg-accent/5 transition-all group">
                                                                <div class="min-w-0 flex-1">
                                                                    <div class="flex items-center gap-3">
                                                                        <h4 class="font-semibold text-foreground truncate">{name.clone()}</h4>
                                                                        {if customized {
                                                                            view! { <span class="px-2 py-0.5 text-[10px] rounded-full bg-blue-500/10 text-blue-600 font-bold uppercase tracking-wider border border-blue-500/20">"Customized"</span> }.into_any()
                                                                        } else {
                                                                            ().into_any()
                                                                        }}
                                                                    </div>
                                                                    <p class="text-sm text-muted-foreground mt-1 truncate">{desc}</p>
                                                                </div>
                                                                <button 
                                                                    on:click=move |_| set_selected_prompt.set(Some(name.clone()))
                                                                    class="ml-6 px-4 py-2 text-sm font-medium border rounded-lg hover:bg-primary hover:text-primary-foreground transition-all shrink-0"
                                                                >
                                                                    "Edit"
                                                                </button>
                                                            </div>
                                                        }.into_any()
                                                    }).collect::<Vec<_>>();
                                                    view! { <div class="grid gap-3">{list}</div> }.into_any()
                                                }
                                            },
                                            Some(Err(e)) => view! { <div class="text-destructive p-4 border border-destructive/20 bg-destructive/5 rounded-lg text-foreground">"Failed to load prompts: " {e.to_string()}</div> }.into_any(),
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
fn PromptEditor(name: String, on_back: impl Fn() + Send + Sync + Clone + 'static) -> impl IntoView {
    let (content, set_content) = signal(String::new());
    let (initial_content, set_initial_content) = signal(String::new());
    let (is_customized, set_is_customized) = signal(false);
    let (default_content, set_default_content) = signal(String::new());
    let (is_loading, set_is_loading) = signal(true);
    let (has_changes, set_has_changes) = signal(false);

    let name_clone = name.clone();
    Effect::new(move |_| {
        let n = name_clone.clone();
        spawn_local(async move {
            if let Ok(data) = crate::goose::api::get_prompt(n).await {
                set_content.set(data.content.clone());
                set_initial_content.set(data.content);
                set_default_content.set(data.default_content);
                set_is_customized.set(data.is_customized);
                set_is_loading.set(false);
            }
        });
    });

    Effect::new(move |_| {
        set_has_changes.set(content.get() != initial_content.get());
    });

    let on_back_clone = on_back.clone();
    let name_save = name.clone();
    let name_reset = name.clone();

    view! {
        <div class="space-y-6 animate-in slide-in-from-right-4 duration-300 text-foreground">
            <div class="flex items-center justify-between">
                <button 
                    on:click=move |_| on_back_clone()
                    class="flex items-center gap-2 text-sm font-medium text-muted-foreground hover:text-foreground transition-colors group"
                >
                    <ArrowLeft class="size-4 group-hover:-translate-x-1 transition-transform" /> "Back to List"
                </button>
                <div class="flex items-center gap-3">
                    <Show when=move || is_customized.get()>
                        <button 
                            on:click={
                                let n = name_reset.clone();
                                let def = default_content.clone();
                                move |_| {
                                    let n = n.clone();
                                    let def = def.get();
                                    spawn_local(async move {
                                        if let Ok(_) = reset_prompt(n).await {
                                            set_content.set(def.clone());
                                            set_initial_content.set(def);
                                            set_is_customized.set(false);
                                        }
                                    });
                                }
                            }
                            class="flex items-center gap-2 px-3 py-1.5 text-xs font-medium border rounded-lg hover:bg-accent transition-colors text-foreground"
                        >
                            <RotateCcw class="size-3.5" /> "Reset"
                        </button>
                    </Show>
                    <button 
                        on:click={
                            let n = name_save.clone();
                            move |_| {
                                let n = n.clone();
                                let c = content.get();
                                spawn_local(async move {
                                    if let Ok(_) = save_prompt(n, c.clone()).await {
                                        set_initial_content.set(c);
                                        set_is_customized.set(true);
                                    }
                                });
                            }
                        }
                        disabled=move || !has_changes.get() || is_loading.get()
                        class="px-5 py-2 text-xs font-bold bg-primary text-primary-foreground rounded-lg hover:opacity-90 transition-all disabled:opacity-50 shadow-sm"
                    >
                        "Save Changes"
                    </button>
                </div>
            </div>

            <div class="p-8 border bg-card rounded-2xl space-y-8 shadow-sm text-foreground">
                <div class="flex items-center gap-4">
                    <h2 class="text-2xl font-bold tracking-tight">"Edit: " {name.clone()}</h2>
                    <Show when=move || is_customized.get()>
                        <span class="px-2 py-0.5 text-[11px] rounded-full bg-blue-500/10 text-blue-600 font-bold uppercase tracking-wider border border-blue-500/20">"Customized"</span>
                    </Show>
                </div>

                <div class="p-4 bg-muted/40 rounded-xl text-sm text-muted-foreground flex gap-4 border text-foreground">
                    <TriangleAlert class="size-5 shrink-0 text-primary mt-0.5" />
                    <p>
                        <strong class="text-foreground font-semibold">"Tip: "</strong>
                        "Variables like " <code class="bg-background px-1.5 py-0.5 rounded border font-mono">"{{" extensions "}}"</code> " are replaced at runtime."
                    </p>
                </div>

                <div class="space-y-3">
                    <div class="flex justify-between items-center px-1 text-foreground">
                        <span class="text-xs font-bold uppercase tracking-widest text-muted-foreground">"Template Content"</span>
                    </div>
                    <textarea 
                        prop:value=move || content.get()
                        on:input=move |ev| set_content.set(event_target_value(&ev))
                        class="w-full min-h-[500px] p-5 font-mono text-sm bg-muted/20 border rounded-xl outline-none focus:ring-2 focus:ring-primary/20 transition-all resize-y leading-relaxed text-foreground"
                        spellcheck="false"
                    />
                </div>

                <Show when=move || has_changes.get()>
                    <div class="flex items-center gap-2 text-sm text-yellow-600 dark:text-yellow-400 font-semibold">
                        <Info class="size-4" />
                        "You have unsaved changes"
                    </div>
                </Show>
            </div>
        </div>
    }
}

// ============================================================================
// Models Settings — faithful to original ModelsSection.tsx
// ============================================================================

#[component]
fn ModelsSettings() -> impl IntoView {
    let (is_loading, set_is_loading) = signal(true);
    let (display_model, set_display_model) = signal(String::new());
    let (display_provider, set_display_provider) = signal(String::new());
    let (show_switch_modal, set_show_switch_modal) = signal(false);
    let (show_providers_grid, set_show_providers_grid) = signal(false);

    // Load current model/provider on mount
    {
        spawn_local(async move {
            let model = crate::goose::api::read_config("GOOSE_MODEL".into()).await.ok().flatten();
            let provider = crate::goose::api::read_config("GOOSE_PROVIDER".into()).await.ok().flatten();

            // Try to get provider display name
            let provider_display = match &provider {
                Some(p) => {
                    match crate::goose::api::list_providers().await {
                        Ok(providers) => {
                            providers.iter()
                                .find(|prov| &prov.name == p)
                                .map(|prov| prov.metadata.display_name.clone())
                                .unwrap_or_else(|| p.clone())
                        }
                        Err(_) => p.clone(),
                    }
                }
                None => String::new(),
            };

            set_display_model.set(model.unwrap_or_default());
            set_display_provider.set(provider_display);
            set_is_loading.set(false);
        });
    }

    // Reload helper
    let reload_display = move || {
        set_is_loading.set(true);
        spawn_local(async move {
            let model = crate::goose::api::read_config("GOOSE_MODEL".into()).await.ok().flatten();
            let provider = crate::goose::api::read_config("GOOSE_PROVIDER".into()).await.ok().flatten();
            let provider_display = match &provider {
                Some(p) => match crate::goose::api::list_providers().await {
                    Ok(providers) => providers.iter()
                        .find(|prov| &prov.name == p)
                        .map(|prov| prov.metadata.display_name.clone())
                        .unwrap_or_else(|| p.clone()),
                    Err(_) => p.clone(),
                },
                None => String::new(),
            };
            set_display_model.set(model.unwrap_or_default());
            set_display_provider.set(provider_display);
            set_is_loading.set(false);
        });
    };

    // Handle reset — matches ResetProviderSection.tsx
    let reload_after_reset = reload_display.clone();
    let handle_reset = move |_| {
        let reload = reload_after_reset.clone();
        spawn_local(async move {
            let _ = crate::goose::api::write_config("GOOSE_PROVIDER".into(), "".into()).await;
            let _ = crate::goose::api::write_config("GOOSE_MODEL".into(), "".into()).await;
            reload();
        });
    };

    let reload_after_switch = reload_display.clone();

    view! {
        <section class="space-y-4 pr-4 animate-in fade-in duration-300">
            // ── Current Model Card — matches ModelsSection.tsx ──
            <div class="p-4 pb-6 rounded-xl border bg-card">
                <div class="px-2">
                    {move || {
                        if is_loading.get() {
                            view! {
                                <div>
                                    <div class="h-5 w-40 bg-muted rounded animate-pulse mb-1" />
                                    <div class="h-4 w-24 bg-muted rounded animate-pulse" />
                                </div>
                            }.into_any()
                        } else {
                            let model = display_model.get();
                            let provider = display_provider.get();
                            view! {
                                <div class="animate-in fade-in duration-100">
                                    <h3 class="text-foreground text-base font-medium">
                                        {if model.is_empty() { "Select Model".to_string() } else { model }}
                                    </h3>
                                    <h4 class="text-xs text-muted-foreground">
                                        {if provider.is_empty() { "\u{00a0}".to_string() } else { provider }}
                                    </h4>
                                </div>
                            }.into_any()
                        }
                    }}

                    // ── Buttons — matches ModelSettingsButtons.tsx ──
                    <div class="flex gap-2 pt-4">
                        <button
                            on:click=move |_| set_show_switch_modal.set(true)
                            class="flex items-center gap-2 justify-center px-4 py-2 text-sm font-medium bg-primary text-primary-foreground rounded-md hover:opacity-90 transition-all"
                        >
                            "Switch models"
                        </button>
                        <button
                            on:click=move |_| set_show_providers_grid.set(true)
                            class="flex items-center gap-2 justify-center px-4 py-2 text-sm font-medium bg-secondary text-secondary-foreground rounded-md hover:opacity-90 transition-all"
                        >
                            "Configure providers"
                        </button>
                    </div>
                </div>
            </div>

            // ── Reset Provider Card — matches ResetProviderSection.tsx ──
            <div class="pb-2 rounded-xl border bg-card">
                <div class="p-4 pb-0">
                    <h3 class="text-base font-semibold text-foreground">"Reset Provider and Model"</h3>
                    <p class="text-sm text-muted-foreground mt-1">
                        "Clear your selected model and provider settings to start fresh"
                    </p>
                </div>
                <div class="p-4">
                    <button
                        on:click=handle_reset
                        class="flex items-center justify-center gap-2 px-4 py-2 text-sm font-medium bg-destructive text-destructive-foreground rounded-md hover:opacity-90 transition-all"
                    >
                        <RotateCcw class="size-4" />
                        "Reset Provider and Model"
                    </button>
                    <p class="text-xs text-muted-foreground mt-2">
                        "This will clear your selected model and provider settings. If no defaults are available, you'll be taken to the welcome screen to set them up again."
                    </p>
                </div>
            </div>

            // ── SwitchModelModal ──
            <Show when=move || show_switch_modal.get()>
                {
                    let reload = reload_after_switch.clone();
                    view! {
                        <SwitchModelModal
                            on_close=move || set_show_switch_modal.set(false)
                            on_model_changed=move || reload()
                        />
                    }
                }
            </Show>

            // ── Configure Providers Grid ──
            <Show when=move || show_providers_grid.get()>
                <ProviderGridModal
                    on_close=move || set_show_providers_grid.set(false)
                />
            </Show>
        </section>
    }
}

// ============================================================================
// SwitchModelModal — faithful to original SwitchModelModal.tsx
// ============================================================================

#[component]
fn SwitchModelModal(
    on_close: impl Fn() + Send + Sync + Clone + 'static,
    on_model_changed: impl Fn() + Send + Sync + Clone + 'static,
) -> impl IntoView {
    let (selected_provider, set_selected_provider) = signal(Option::<String>::None);
    let (selected_model, set_selected_model) = signal(String::new());
    let (is_custom_model, set_is_custom_model) = signal(false);
    let (_loading_providers, set_loading_providers) = signal(true);
    let (loading_models, set_loading_models) = signal(false);
    let (provider_options, set_provider_options) = signal(Vec::<(String, String)>::new());
    let (model_options, set_model_options) = signal(Vec::<String>::new());
    let (validation_error, set_validation_error) = signal(Option::<String>::None);
    let (attempted_submit, set_attempted_submit) = signal(false);

    let on_close_bg = on_close.clone();
    let on_close_cancel = on_close.clone();
    let on_close_submit = on_close.clone();
    let on_model_changed_submit = on_model_changed.clone();

    // Load providers on mount
    {
        spawn_local(async move {
            match crate::goose::api::list_providers().await {
                Ok(providers) => {
                    let active: Vec<(String, String)> = providers.iter()
                        .filter(|p| p.is_configured)
                        .map(|p| (p.name.clone(), p.metadata.display_name.clone()))
                        .collect();
                    set_provider_options.set(active);

                    // Pre-select current provider
                    if let Ok(Some(current)) = crate::goose::api::read_config("GOOSE_PROVIDER".into()).await {
                        set_selected_provider.set(Some(current.clone()));
                        set_loading_models.set(true);
                        if let Ok(models) = crate::goose::api::get_provider_models(current).await {
                            set_model_options.set(models);
                        }
                        set_loading_models.set(false);
                        if let Ok(Some(current_model)) = crate::goose::api::read_config("GOOSE_MODEL".into()).await {
                            set_selected_model.set(current_model);
                        }
                    }
                }
                Err(e) => leptos::logging::error!("Failed to load providers: {}", e),
            }
            set_loading_providers.set(false);
        });
    }

    // Load models when provider changes
    let load_models_for_provider = move |provider_name: String| {
        set_loading_models.set(true);
        set_selected_model.set(String::new());
        set_model_options.set(Vec::new());
        set_is_custom_model.set(false);
        spawn_local(async move {
            if let Ok(models) = crate::goose::api::get_provider_models(provider_name).await {
                set_model_options.set(models);
            }
            set_loading_models.set(false);
        });
    };

    let handle_submit = move |_| {
        set_attempted_submit.set(true);
        let provider = selected_provider.get();
        let model = selected_model.get();

        if provider.is_none() {
            set_validation_error.set(Some("Please select a provider".into()));
            return;
        }
        if model.trim().is_empty() {
            set_validation_error.set(Some("Please select or enter a model".into()));
            return;
        }

        set_validation_error.set(None);
        let prov = provider.unwrap();
        let on_close = on_close_submit.clone();
        let on_model_changed = on_model_changed_submit.clone();
        spawn_local(async move {
            match crate::goose::api::set_provider_and_model(prov, model).await {
                Ok(_) => {
                    on_model_changed();
                    on_close();
                }
                Err(e) => set_validation_error.set(Some(format!("Failed: {}", e))),
            }
        });
    };

    view! {
        // Dialog overlay
        <div class="fixed inset-0 z-50 bg-black/60 backdrop-blur-sm animate-in fade-in duration-200"
            on:click=move |_| on_close_bg()
        >
            <div class="fixed left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 w-full max-w-[500px] px-4"
                on:click=move |e| e.stop_propagation()
            >
                <div class="bg-card border rounded-xl shadow-2xl animate-in zoom-in-95 slide-in-from-bottom-4 duration-300">
                    // DialogHeader
                    <div class="p-6 pb-2">
                        <div class="flex items-center gap-2">
                            <Bot class="size-6 text-foreground" />
                            <h2 class="text-lg font-semibold">"Switch models"</h2>
                        </div>
                        <p class="text-sm text-muted-foreground mt-1">
                            "Select a provider and model to use for your conversations."
                        </p>
                    </div>

                    // Body
                    <div class="flex flex-col gap-4 px-6 py-4">
                        // Provider select
                        <div>
                            <select
                                class="w-full bg-muted/50 border border-border rounded-lg py-2.5 px-3 text-sm outline-none focus:ring-2 focus:ring-primary/20 transition-all"
                                on:change=move |ev| {
                                    let val = event_target_value(&ev);
                                    if val.is_empty() {
                                        set_selected_provider.set(None);
                                        set_model_options.set(Vec::new());
                                    } else {
                                        set_selected_provider.set(Some(val.clone()));
                                        load_models_for_provider(val);
                                    }
                                }
                            >
                                <option value="" disabled=true selected=move || selected_provider.get().is_none()>
                                    "Provider, type to search"
                                </option>
                                {move || {
                                    provider_options.get().into_iter().map(|(value, label)| {
                                        let v = value.clone();
                                        let is_selected = selected_provider.get().as_deref() == Some(value.as_str());
                                        view! { <option value=v selected=is_selected>{label}</option> }
                                    }).collect::<Vec<_>>()
                                }}
                            </select>
                            <Show when=move || attempted_submit.get() && selected_provider.get().is_none()>
                                <div class="text-red-500 text-sm mt-1">"Please select a provider"</div>
                            </Show>
                        </div>

                        // Model select (only when provider selected)
                        <Show when=move || selected_provider.get().is_some()>
                            {move || {
                                if is_custom_model.get() {
                                    view! {
                                        <div class="flex flex-col gap-2">
                                            <div class="flex justify-between">
                                                <label class="text-sm text-muted-foreground">"Custom model name"</label>
                                                <button
                                                    on:click=move |_| set_is_custom_model.set(false)
                                                    class="text-sm text-muted-foreground hover:text-foreground transition-colors"
                                                >
                                                    "Back to model list"
                                                </button>
                                            </div>
                                            <input
                                                class="border-2 border-border rounded-lg px-4 py-2.5 text-sm outline-none focus:ring-2 focus:ring-primary/20 bg-background text-foreground"
                                                placeholder="Type model name here"
                                                prop:value=move || selected_model.get()
                                                on:input=move |ev| set_selected_model.set(event_target_value(&ev))
                                            />
                                            <Show when=move || attempted_submit.get() && selected_model.get().trim().is_empty()>
                                                <div class="text-red-500 text-sm">"Please select or enter a model"</div>
                                            </Show>
                                        </div>
                                    }.into_any()
                                } else if loading_models.get() {
                                    view! {
                                        <select class="w-full bg-muted/50 border border-border rounded-lg py-2.5 px-3 text-sm outline-none opacity-60" disabled=true>
                                            <option>"Loading models\u{2026}"</option>
                                        </select>
                                    }.into_any()
                                } else {
                                    view! {
                                        <div>
                                            <select
                                                class="w-full bg-muted/50 border border-border rounded-lg py-2.5 px-3 text-sm outline-none focus:ring-2 focus:ring-primary/20 transition-all"
                                                on:change=move |ev| {
                                                    let val = event_target_value(&ev);
                                                    if val == "__custom__" {
                                                        set_is_custom_model.set(true);
                                                        set_selected_model.set(String::new());
                                                    } else {
                                                        set_selected_model.set(val);
                                                    }
                                                }
                                            >
                                                <option value="" disabled=true selected=move || selected_model.get().is_empty()>
                                                    "Select a model, type to search"
                                                </option>
                                                {move || {
                                                    let mut items = model_options.get().into_iter().map(|m| {
                                                        let v = m.clone();
                                                        let is_sel = selected_model.get() == m;
                                                        view! { <option value=v selected=is_sel>{m}</option> }.into_any()
                                                    }).collect::<Vec<_>>();
                                                    items.push(view! {
                                                        <option value="__custom__">"Enter a model not listed..."</option>
                                                    }.into_any());
                                                    items
                                                }}
                                            </select>
                                            <Show when=move || attempted_submit.get() && selected_model.get().trim().is_empty()>
                                                <div class="text-red-500 text-sm mt-1">"Please select or enter a model"</div>
                                            </Show>
                                        </div>
                                    }.into_any()
                                }
                            }}
                        </Show>
                    </div>

                    // Validation error
                    <Show when=move || validation_error.get().is_some()>
                        <div class="px-6 pb-2">
                            <div class="text-red-500 text-sm">{move || validation_error.get().unwrap_or_default()}</div>
                        </div>
                    </Show>

                    // DialogFooter — matches original with Quick start guide link
                    <div class="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-3 p-6 pt-4 border-t border-border">
                        <a
                            href="https://block.github.io/goose/docs/getting-started/providers"
                            target="_blank"
                            rel="noopener noreferrer"
                            class="inline-flex items-center text-muted-foreground hover:text-foreground text-sm transition-colors"
                        >
                            <svg class="size-3.5 mr-1" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                <path d="M18 13v6a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h6" />
                                <polyline points="15 3 21 3 21 9" />
                                <line x1="10" y1="14" x2="21" y2="3" />
                            </svg>
                            "Quick start guide"
                        </a>
                        <div class="flex gap-2">
                            <button
                                on:click=move |_| on_close_cancel()
                                class="px-4 py-2 text-sm font-medium border rounded-md hover:bg-accent transition-colors"
                            >
                                "Cancel"
                            </button>
                            <button
                                on:click=handle_submit
                                disabled=move || selected_provider.get().is_none() || selected_model.get().trim().is_empty()
                                class="px-4 py-2 text-sm font-medium bg-primary text-primary-foreground rounded-md hover:opacity-90 transition-all disabled:opacity-50"
                            >
                                "Select model"
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    }
}

// ============================================================================
// ProviderGridModal — 1:1 visual copy of original
// CardContainer.tsx + CardHeader.tsx + CardBody.tsx + DefaultCardButtons.tsx
// + ProviderGrid.tsx + ProviderSettingsPage.tsx
// ============================================================================

#[component]
fn ProviderGridModal(
    on_close: impl Fn() + Send + Sync + Clone + 'static,
) -> impl IntoView {
    let (providers, set_providers) = signal(Vec::<crate::goose::api::ProviderDetails>::new());
    let (loading, set_loading) = signal(true);
    let (configuring, set_configuring) = signal(Option::<crate::goose::api::ProviderDetails>::None);
    let (api_key_input, set_api_key_input) = signal(String::new());
    let _on_close_bg = on_close.clone();
    let on_close_back = on_close.clone();

    // Load providers
    {
        spawn_local(async move {
            match crate::goose::api::list_providers().await {
                Ok(p) => {
                    let mut sorted = p;
                    sorted.sort_by(|a, b| a.name.cmp(&b.name));
                    set_providers.set(sorted);
                }
                Err(e) => leptos::logging::error!("Failed to load providers: {}", e),
            }
            set_loading.set(false);
        });
    }

    // CSS for the GlowingRing animation (injected via style tag)
    let glowing_ring_style = r#"
        @keyframes provider-ring-rotate {
            from { transform: rotate(0deg); }
            to { transform: rotate(360deg); }
        }
    "#;

    view! {
        // Inject keyframe animation
        <style>{glowing_ring_style}</style>

        // Full-screen overlay — matches ProviderSettingsPage.tsx
        <div class="fixed inset-0 z-50 bg-background text-foreground animate-in fade-in duration-200 overflow-hidden flex flex-col">
            // ScrollArea container
            <div class="flex-1 w-full overflow-y-auto">
                <div class="w-full max-w-6xl mx-auto px-4 sm:px-6 md:px-8 pt-12 pb-4">
                    // Header — matches ProviderSettingsPage header exactly
                    <div class="flex flex-col pb-8 border-b border-border">
                        <div class="flex items-center pt-2 mb-1">
                            <button
                                on:click=move |_| on_close_back()
                                class="flex items-center gap-1.5 text-sm text-muted-foreground hover:text-foreground transition-colors"
                            >
                                <ArrowLeft class="size-4" />
                                "Back"
                            </button>
                        </div>
                        <h1 class="text-4xl font-light mb-4 pt-6">
                            "Provider Configuration Settings"
                        </h1>
                    </div>
                </div>

                // Content area — matches ProviderSettingsPage
                <div class="py-8 pt-5">
                    <div class="w-full max-w-6xl mx-auto pt-4 px-4 sm:px-6 md:px-8">
                        <div class="relative z-10">
                            {move || {
                                if loading.get() {
                                    view! { <div class="text-muted-foreground">"Loading providers..."</div> }.into_any()
                                } else {
                                    // Provider cards — GridLayout: grid gap-4 p-1, repeat(auto-fill, minmax(200px, 200px)), justify-content: center
                                    let cards = providers.get().into_iter().map(|provider| {
                                        let display_name = provider.metadata.display_name.clone();
                                        let description = provider.metadata.description.clone();
                                        let is_configured = provider.is_configured;
                                        let provider_for_config = provider.clone();

                                        // CardContainer exact structure
                                        view! {
                                            // Outer wrapper — p-[2px] rounded-[9px] with hover glow
                                            <div
                                                class="relative h-full p-[2px] overflow-hidden rounded-[9px] group/card bg-border hover:bg-transparent hover:duration-300 cursor-pointer"
                                                on:click=move |_| {
                                                    set_configuring.set(Some(provider_for_config.clone()));
                                                    set_api_key_input.set(String::new());
                                                }
                                            >
                                                // GlowingRing — gradient 45deg #13BBAF → #FF4F00, rotate 6s, opacity on hover
                                                <div
                                                    class="absolute pointer-events-none inset-0 rounded-[9px] origin-center opacity-0 group-hover/card:opacity-40 transition-opacity duration-300"
                                                    style="background: linear-gradient(45deg, #13BBAF, #FF4F00); animation: provider-ring-rotate 6s linear infinite; z-index: -1;"
                                                />

                                                // Inner card — bg-background rounded-lg p-3 h-[160px] flex flex-col justify-between border
                                                <div class=move || tw_merge!(
                                                    "relative bg-background rounded-lg p-3 transition-all duration-200 h-[160px] flex flex-col justify-between border",
                                                    "border-border hover:border-muted-foreground/40"
                                                )>
                                                    // CardHeader
                                                    <div>
                                                        // ProviderNameAndStatus — flex items-center justify-between
                                                        <div class="flex items-center justify-between w-full">
                                                            // CardTitle — text-base font-medium truncate
                                                            <h3 class="text-base font-medium text-foreground truncate mr-2">
                                                                {display_name}
                                                            </h3>
                                                            // GreenCheckButton — only if configured
                                                            {if is_configured {
                                                                view! {
                                                                    <div class="text-green-600 dark:text-green-500 shrink-0">
                                                                        <svg class="size-4" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                                                                            <polyline points="20 6 9 17 4 12" />
                                                                        </svg>
                                                                    </div>
                                                                }.into_any()
                                                            } else {
                                                                ().into_any()
                                                            }}
                                                        </div>
                                                        // ProviderDescription — text-xs text-muted mt-1.5 mb-3 max-h-[54px] overflow-y-auto
                                                        <p class="text-xs text-muted-foreground mt-1.5 mb-3 leading-normal overflow-y-auto max-h-[54px]">
                                                            {description}
                                                        </p>
                                                    </div>

                                                    // CardBody — flex items-center justify-start
                                                    <div class="flex items-center justify-start">
                                                        // ConfigureSettingsButton — pill with Sliders icon rotated 90deg + "Configure" text
                                                        <button
                                                            on:click=move |e| {
                                                                e.stop_propagation();
                                                                // configure action handled by card click
                                                            }
                                                            class="inline-flex items-center gap-1.5 px-3 py-1.5 text-xs font-medium border border-border rounded-full bg-background hover:bg-accent transition-colors cursor-pointer"
                                                        >
                                                            // Sliders icon rotated 90deg
                                                            <svg class="size-4 rotate-90" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                                                <line x1="4" y1="21" x2="4" y2="14" />
                                                                <line x1="4" y1="10" x2="4" y2="3" />
                                                                <line x1="12" y1="21" x2="12" y2="12" />
                                                                <line x1="12" y1="8" x2="12" y2="3" />
                                                                <line x1="20" y1="21" x2="20" y2="16" />
                                                                <line x1="20" y1="12" x2="20" y2="3" />
                                                                <line x1="1" y1="14" x2="7" y2="14" />
                                                                <line x1="9" y1="8" x2="15" y2="8" />
                                                                <line x1="17" y1="16" x2="23" y2="16" />
                                                            </svg>
                                                            "Configure"
                                                        </button>
                                                    </div>
                                                </div>
                                            </div>
                                        }
                                    }).collect::<Vec<_>>();

                                    // CustomProviderCard — dashed border + Plus icon + "Add Custom Provider"
                                    let custom_card = view! {
                                        <div class="relative h-full p-[2px] overflow-hidden rounded-[9px] cursor-pointer bg-border hover:bg-transparent hover:duration-300">
                                            <div class="relative bg-background rounded-lg p-3 transition-all duration-200 h-[160px] flex flex-col justify-center border-2 border-dashed border-border hover:border-muted-foreground/40">
                                                <div class="flex flex-col items-center justify-center min-h-[120px]">
                                                    // Plus icon
                                                    <svg class="w-8 h-8 text-muted-foreground/60 mb-2" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                                        <line x1="12" y1="5" x2="12" y2="19" />
                                                        <line x1="5" y1="12" x2="19" y2="12" />
                                                    </svg>
                                                    <div class="text-sm text-muted-foreground text-center">
                                                        <div>"Add"</div>
                                                        <div>"Custom Provider"</div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    };

                                    view! {
                                        // GridLayout — exact original: grid gap-4 p-1, repeat(auto-fill, minmax(200px, 200px)), justify-content: center
                                        <div
                                            class="grid gap-4 p-1"
                                            style="grid-template-columns: repeat(auto-fill, minmax(200px, 200px)); justify-content: center;"
                                        >
                                            {cards}
                                            {custom_card}
                                        </div>
                                    }.into_any()
                                }
                            }}
                        </div>
                    </div>
                </div>
            </div>

            // Configure panel — slides up from bottom when a provider is selected
            <Show when=move || configuring.get().is_some()>
                {move || {
                    let prov = configuring.get().expect("checked");
                    let prov_name = prov.name.clone();
                    let prov_display = prov.metadata.display_name.clone();
                    view! {
                        <div class="border-t border-border p-6 bg-muted/30 shrink-0 animate-in slide-in-from-bottom-2 duration-200">
                            <h3 class="font-semibold text-sm mb-3">"Configure " {prov_display}</h3>
                            <div class="flex gap-3">
                                <input
                                    type="password"
                                    placeholder="Enter API key"
                                    prop:value=move || api_key_input.get()
                                    on:input=move |ev| set_api_key_input.set(event_target_value(&ev))
                                    class="flex-1 bg-background border border-border rounded-lg py-2 px-3 text-sm outline-none focus:ring-2 focus:ring-primary/20 font-mono"
                                />
                                <button
                                    on:click=move |_| {
                                        let key = api_key_input.get();
                                        let name = prov_name.clone();
                                        if !key.trim().is_empty() {
                                            spawn_local(async move {
                                                let _ = crate::goose::api::configure_provider(name, key).await;
                                                if let Ok(p) = crate::goose::api::list_providers().await {
                                                    let mut sorted = p;
                                                    sorted.sort_by(|a, b| a.name.cmp(&b.name));
                                                    set_providers.set(sorted);
                                                }
                                                set_configuring.set(None);
                                            });
                                        }
                                    }
                                    disabled=move || api_key_input.get().trim().is_empty()
                                    class="px-4 py-2 text-sm font-medium bg-primary text-primary-foreground rounded-md hover:opacity-90 transition-all disabled:opacity-50"
                                >
                                    "Save"
                                </button>
                                <button
                                    on:click=move |_| set_configuring.set(None)
                                    class="px-4 py-2 text-sm font-medium border rounded-md hover:bg-accent transition-colors"
                                >
                                    "Cancel"
                                </button>
                            </div>
                        </div>
                    }
                }}
            </Show>
        </div>
    }
}

// ============================================================================
// Chat Settings
// ============================================================================

#[component]
fn ChatSettings() -> impl IntoView {
    view! {
        <div class="space-y-6 animate-in fade-in duration-300">
            <div class="space-y-2">
                <h2 class="text-2xl font-bold tracking-tight">"Chat Settings"</h2>
                <p class="text-sm text-muted-foreground">"Customize chat behavior and appearance."</p>
            </div>

            <div class="space-y-4">
                <div class="p-5 rounded-xl border bg-card flex items-center justify-between">
                    <div class="space-y-1">
                        <h3 class="font-semibold text-sm">"Auto-scroll to bottom"</h3>
                        <p class="text-xs text-muted-foreground">"Automatically scroll to the latest message."</p>
                    </div>
                    <div class="w-10 h-6 bg-primary rounded-full relative cursor-pointer">
                        <div class="absolute right-0.5 top-0.5 w-5 h-5 bg-white rounded-full shadow transition-transform" />
                    </div>
                </div>

                <div class="p-5 rounded-xl border bg-card flex items-center justify-between">
                    <div class="space-y-1">
                        <h3 class="font-semibold text-sm">"Show thinking blocks"</h3>
                        <p class="text-xs text-muted-foreground">"Display the model's reasoning process in expandable sections."</p>
                    </div>
                    <div class="w-10 h-6 bg-primary rounded-full relative cursor-pointer">
                        <div class="absolute right-0.5 top-0.5 w-5 h-5 bg-white rounded-full shadow transition-transform" />
                    </div>
                </div>

                <div class="p-5 rounded-xl border bg-card flex items-center justify-between">
                    <div class="space-y-1">
                        <h3 class="font-semibold text-sm">"Tool confirmation"</h3>
                        <p class="text-xs text-muted-foreground">"Ask for confirmation before executing potentially destructive tool calls."</p>
                    </div>
                    <div class="w-10 h-6 bg-muted rounded-full relative cursor-pointer">
                        <div class="absolute left-0.5 top-0.5 w-5 h-5 bg-white rounded-full shadow transition-transform" />
                    </div>
                </div>

                <div class="p-5 rounded-xl border bg-card space-y-3">
                    <div class="space-y-1">
                        <h3 class="font-semibold text-sm">"Response style"</h3>
                        <p class="text-xs text-muted-foreground">"Control the verbosity of responses."</p>
                    </div>
                    <div class="flex gap-2">
                        <button class="px-3 py-1.5 text-xs font-medium border rounded-lg hover:bg-accent transition-colors">"Concise"</button>
                        <button class="px-3 py-1.5 text-xs font-medium bg-primary text-primary-foreground rounded-lg">"Balanced"</button>
                        <button class="px-3 py-1.5 text-xs font-medium border rounded-lg hover:bg-accent transition-colors">"Detailed"</button>
                    </div>
                </div>
            </div>
        </div>
    }
}

// ============================================================================
// Session Settings
// ============================================================================

#[component]
fn SessionSettings() -> impl IntoView {
    view! {
        <div class="space-y-6 animate-in fade-in duration-300">
            <div class="space-y-2">
                <h2 class="text-2xl font-bold tracking-tight">"Session & Sharing"</h2>
                <p class="text-sm text-muted-foreground">"Manage session sharing and collaboration settings."</p>
            </div>

            <div class="space-y-4">
                <div class="p-5 rounded-xl border bg-card flex items-center justify-between">
                    <div class="space-y-1">
                        <h3 class="font-semibold text-sm">"Enable session sharing"</h3>
                        <p class="text-xs text-muted-foreground">"Allow generating shareable links for your sessions."</p>
                    </div>
                    <div class="w-10 h-6 bg-muted rounded-full relative cursor-pointer">
                        <div class="absolute left-0.5 top-0.5 w-5 h-5 bg-white rounded-full shadow transition-transform" />
                    </div>
                </div>

                <div class="p-5 rounded-xl border bg-card space-y-3">
                    <div class="space-y-1">
                        <h3 class="font-semibold text-sm">"External backend"</h3>
                        <p class="text-xs text-muted-foreground">"Connect to a remote goose backend for session persistence."</p>
                    </div>
                    <input
                        type="text"
                        placeholder="https://your-backend.example.com"
                        class="w-full bg-muted/50 border border-border rounded-lg py-2 px-3 text-sm outline-none focus:ring-2 focus:ring-primary/20"
                    />
                </div>

                <div class="p-5 rounded-xl border bg-card flex items-center justify-between">
                    <div class="space-y-1">
                        <h3 class="font-semibold text-sm">"Auto-save sessions"</h3>
                        <p class="text-xs text-muted-foreground">"Automatically save sessions to your backend."</p>
                    </div>
                    <div class="w-10 h-6 bg-primary rounded-full relative cursor-pointer">
                        <div class="absolute right-0.5 top-0.5 w-5 h-5 bg-white rounded-full shadow transition-transform" />
                    </div>
                </div>
            </div>
        </div>
    }
}

// ============================================================================
// Keyboard Settings
// ============================================================================

#[component]
fn KeyboardSettings() -> impl IntoView {
    let shortcuts = vec![
        ("New Chat", "Ctrl+N"),
        ("Send Message", "Enter"),
        ("New Line", "Shift+Enter"),
        ("Focus Input", "Ctrl+L"),
        ("Open Settings", "Ctrl+,"),
        ("Open Sidebar", "Ctrl+B"),
        ("Search", "Ctrl+K"),
        ("Close Panel", "Escape"),
    ];

    view! {
        <div class="space-y-6 animate-in fade-in duration-300">
            <div class="space-y-2">
                <h2 class="text-2xl font-bold tracking-tight">"Keyboard Shortcuts"</h2>
                <p class="text-sm text-muted-foreground">"View and customize keyboard shortcuts."</p>
            </div>

            <div class="rounded-xl border bg-card divide-y">
                {shortcuts.into_iter().map(|(action, shortcut)| {
                    view! {
                        <div class="flex items-center justify-between px-5 py-3.5">
                            <span class="text-sm font-medium">{action}</span>
                            <div class="flex items-center gap-1">
                                {shortcut.split('+').map(|key| {
                                    view! {
                                        <kbd class="px-2 py-1 text-xs font-mono bg-muted border border-border rounded-md shadow-sm">{key}</kbd>
                                    }
                                }).collect::<Vec<_>>()}
                            </div>
                        </div>
                    }
                }).collect::<Vec<_>>()}
            </div>
        </div>
    }
}

// ============================================================================
// App Settings
// ============================================================================

#[component]
fn AppSettings() -> impl IntoView {
    view! {
        <div class="space-y-6 animate-in fade-in duration-300">
            <div class="space-y-2">
                <h2 class="text-2xl font-bold tracking-tight">"App Settings"</h2>
                <p class="text-sm text-muted-foreground">"General application configuration."</p>
            </div>

            <div class="space-y-4">
                <div class="p-5 rounded-xl border bg-card space-y-3">
                    <div class="space-y-1">
                        <h3 class="font-semibold text-sm">"Theme"</h3>
                        <p class="text-xs text-muted-foreground">"Choose your preferred color scheme."</p>
                    </div>
                    <div class="flex gap-2">
                        <button class="px-3 py-1.5 text-xs font-medium border rounded-lg hover:bg-accent transition-colors">"Light"</button>
                        <button class="px-3 py-1.5 text-xs font-medium bg-primary text-primary-foreground rounded-lg">"Dark"</button>
                        <button class="px-3 py-1.5 text-xs font-medium border rounded-lg hover:bg-accent transition-colors">"System"</button>
                    </div>
                </div>

                <div class="p-5 rounded-xl border bg-card flex items-center justify-between">
                    <div class="space-y-1">
                        <h3 class="font-semibold text-sm">"Notifications"</h3>
                        <p class="text-xs text-muted-foreground">"Receive desktop notifications for completed tasks."</p>
                    </div>
                    <div class="w-10 h-6 bg-muted rounded-full relative cursor-pointer">
                        <div class="absolute left-0.5 top-0.5 w-5 h-5 bg-white rounded-full shadow transition-transform" />
                    </div>
                </div>

                <div class="p-5 rounded-xl border bg-card flex items-center justify-between">
                    <div class="space-y-1">
                        <h3 class="font-semibold text-sm">"Telemetry"</h3>
                        <p class="text-xs text-muted-foreground">"Help improve goose by sharing anonymous usage data."</p>
                    </div>
                    <div class="w-10 h-6 bg-muted rounded-full relative cursor-pointer">
                        <div class="absolute left-0.5 top-0.5 w-5 h-5 bg-white rounded-full shadow transition-transform" />
                    </div>
                </div>

                <div class="p-5 rounded-xl border bg-card space-y-3">
                    <div class="flex items-center justify-between">
                        <div class="space-y-1">
                            <h3 class="font-semibold text-sm">"Version"</h3>
                            <p class="text-xs text-muted-foreground">"Goose UI v0.1.0 (Leptos)"</p>
                        </div>
                        <button class="px-3 py-1.5 text-xs font-medium border rounded-lg hover:bg-accent transition-colors">"Check for Updates"</button>
                    </div>
                </div>
            </div>
        </div>
    }
}
