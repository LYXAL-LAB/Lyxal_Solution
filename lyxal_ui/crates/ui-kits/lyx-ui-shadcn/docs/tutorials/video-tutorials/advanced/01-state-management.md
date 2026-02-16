# Tutorial: Advanced State Management

**Video Length**: ~28 minutes | **Difficulty**: Advanced | **Series**: Advanced Patterns

## Overview

Learn advanced patterns for managing application state in Leptos with shadcn-ui components. This tutorial covers global state, data fetching, caching, and state synchronization patterns.

## What You'll Learn

- Global state management with signals
- Server state integration and caching
- Optimistic UI updates
- State persistence and recovery
- Cross-component state sharing
- Performance optimization techniques

## Prerequisites

- Completed Getting Started and Component series
- Strong understanding of signals and reactivity
- Familiarity with async operations

## Video Outline

**[0:00]** Introduction to state management
**[2:30]** Local vs. global state patterns
**[6:00]** Building a store system
**[10:00]** Server state and data fetching
**[14:00]** Caching and invalidation strategies
**[17:30]** Optimistic updates
**[20:00]** State persistence
**[23:00]** State synchronization patterns
**[26:00]** Performance considerations
**[27:00]** Summary and resources

## Global State with Signals

### Basic Store Pattern

```rust
use leptos::*;
use std::rc::Rc;

/// Simple global store using signals
#[derive(Clone)]
pub struct AppState {
    pub user: ReadSignal<Option<User>>,
    pub set_user: WriteSignal<Option<User>>,
    pub theme: ReadSignal<Theme>,
    pub set_theme: WriteSignal<Theme>,
    pub notifications: ReadSignal<Vec<Notification>>,
    pub add_notification: WriteSignal<Notification>,
    pub clear_notifications: WriteSignal<()>,
}

impl AppState {
    pub fn new() -> Self {
        let (user, set_user) = create_signal(None);
        let (theme, set_theme) = create_signal(Theme::Light);
        let (notifications, set_notifications) = create_signal(Vec::new());

        // Auto-clear old notifications
        create_effect(move |_| {
            let notifs = notifications.get();
            if notifs.len() > 5 {
                set_notifications.update(|n| {
                    n.truncate(5);
                });
            }
        });

        AppState {
            user,
            set_user,
            theme,
            set_theme,
            notifications: notifications.clone(),
            add_notification: create_signal_from(notifications, |n, notif| {
                n.push(notif);
            }),
            clear_notifications: create_signal_from(notifications, |n, _| {
                n.clear();
            }),
        }
    }

    pub fn login(&self, email: String, password: String) {
        // API call to login
        self.set_user.set(Some(User {
            id: "1".to_string(),
            email,
            name: "User".to_string(),
        }));
    }

    pub fn logout(&self) {
        self.set_user.set(None);
    }
}

fn create_signal_from<T, U>(
    signal: ReadSignal<T>,
    mut updater: impl FnMut(&mut T, U) + 'static,
) -> WriteSignal<U> {
    // Create a write signal that modifies the original signal
    // Implementation depends on your leptos version
    unimplemented!()
}

// Type definitions
#[derive(Clone, Debug)]
pub struct User {
    pub id: String,
    pub email: String,
    pub name: String,
}

#[derive(Clone, Copy, Debug, PartialEq)]
pub enum Theme {
    Light,
    Dark,
    System,
}

#[derive(Clone, Debug)]
pub struct Notification {
    pub id: String,
    pub title: String,
    pub message: String,
    pub variant: NotificationVariant,
}

#[derive(Clone, Copy, Debug)]
pub enum NotificationVariant {
    Info,
    Success,
    Warning,
    Error,
}
```

### Context Provider Pattern

```rust
use leptos::*;
use lyx_ui_shadcn_button::Button;
use lyx_ui_shadcn_card::Card;

/// Context key for app state
pub static APP_STATE: crate::context::ContextState<Rc<AppState>> =
    crate::context::ContextState::new();

#[component]
pub fn App() -> impl IntoView {
    // Create app state
    let state = Rc::new(AppState::new());

    view! {
        // Provide state to all children
        <crate::context::ContextProvider value=state>
            <AppBar/>
            <main class="container mx-auto p-4">
                <Dashboard/>
            </main>
            <NotificationCenter/>
        </crate::context::ContextProvider>
    }
}

#[component]
pub fn AppBar() -> impl IntoView {
    let state = use_context(APP_STATE).expect("AppState not found");

    view! {
        <header class="border-b bg-card">
            <div class="container mx-auto px-4 py-4 flex justify-between items-center">
                <h1 class="text-2xl font-bold">"My App"</h1>

                <div class="flex items-center gap-4">
                    // Theme toggle
                    <Button
                        variant="ghost"
                        size="icon"
                        on_click=move |_| {
                            let new_theme = match state.theme.get() {
                                Theme::Light => Theme::Dark,
                                Theme::Dark => Theme::System,
                                Theme::System => Theme::Light,
                            };
                            state.set_theme.set(new_theme);
                        }
                    >
                        {move || match state.theme.get() {
                            Theme::Light => "☀️",
                            Theme::Dark => "🌙",
                            Theme::System => "💻",
                        }}
                    </Button>

                    // User menu
                    {move || {
                        state.user.get().map(|user| {
                            view! {
                                <div class="flex items-center gap-2">
                                    <span class="text-sm">{user.name}</span>
                                    <Button
                                        variant="outline"
                                        size="sm"
                                        on_click=move |_| state.logout()
                                    >
                                        "Logout"
                                    </Button>
                                </div>
                            }
                        })
                    }}
                </div>
            </div>
        </header>
    }
}

#[component]
pub fn NotificationCenter() -> impl IntoView {
    let state = use_context(APP_STATE).expect("AppState not found");

    view! {
        <div class="fixed bottom-4 right-4 space-y-2 z-50">
            {move || {
                state.notifications.get().into_iter().map(|notif| {
                    view! {
                        <Card class=format!(
                            "p-4 shadow-lg border-l-4 {}",
                            match notif.variant {
                                NotificationVariant::Info => "border-l-blue-500",
                                NotificationVariant::Success => "border-l-green-500",
                                NotificationVariant::Warning => "border-l-yellow-500",
                                NotificationVariant::Error => "border-l-red-500",
                            }
                        )>
                            <div class="font-semibold">{notif.title}</div>
                            <div class="text-sm text-muted-foreground">{notif.message}</div>
                        </Card>
                    }
                }).collect_view()
            }}
        </div>
    }
}
```

## Server State Management

### Data Fetching Hook

```rust
use leptos::*;
use leptos_query::*;
use std::time::Duration;

/// Query for fetching user data
pub fn use_user_query(user_id: impl Fn() -> String + 'static) {
    use_query(
        user_id,
        |id| async move {
            // Simulate API call
            tokio::time::sleep(Duration::from_millis(500)).await;
            Ok(User {
                id: id.clone(),
                email: format!("{}@example.com", id),
                name: format!("User {}", id),
            })
        },
        QueryOptions {
            default_value: None,
            refetch_on_mount: true,
            stale_time: Duration::from_secs(60),
            cache_time: Duration::from_secs(300),
            ..Default::default()
        },
    )
}

#[component]
pub fn UserProfile(user_id: String) -> impl IntoView {
    let query = use_user_query(move || user_id.clone());

    view! {
        <Card class="p-6">
            {move || {
                match query.data.get() {
                    Some(Ok(user)) => {
                        view! {
                            <div class="space-y-4">
                                <div>
                                    <div class="text-sm text-muted-foreground">"Name"</div>
                                    <div class="text-lg font-semibold">{user.name.clone()}</div>
                                </div>
                                <div>
                                    <div class="text-sm text-muted-foreground">"Email"</div>
                                    <div class="text-lg">{user.email.clone()}</div>
                                </div>
                                <Button
                                    variant="outline"
                                    on_click=move |_| query.refetch()
                                >
                                    "Refresh"
                                </Button>
                            </div>
                        }.into_any()
                    }
                    Some(Err(_)) => {
                        view! {
                            <div class="text-destructive">
                                "Failed to load user data"
                                <Button
                                    variant="outline"
                                    class="ml-2"
                                    on_click=move |_| query.refetch()
                                >
                                    "Retry"
                                </Button>
                            </div>
                        }.into_any()
                    }
                    None => {
                        view! {
                            <div class="text-muted-foreground">"Loading..."</div>
                        }.into_any()
                    }
                }
            }}
        </Card>
    }
}
```

### Optimistic Updates

```rust
#[component]
pub fn TodoList() -> impl IntoView {
    // Local state for optimistic updates
    let (todos, set_todos) = create_signal(Vec::<Todo>::new());
    let (is_adding, set_is_adding) = create_signal(false);
    let (new_todo, set_new_todo) = create_signal(String::new());

    // Add todo optimistically
    let add_todo = move |_| {
        let title = new_todo.get();
        if title.is_empty() {
            return;
        }

        let temp_id = format!("temp-{}", uuid::Uuid::new_v4());

        // Optimistic update
        set_todos.update(|todos| {
            todos.push(Todo {
                id: temp_id.clone(),
                title: title.clone(),
                completed: false,
                status: TodoStatus::Pending,
            });
        });

        set_new_todo.set(String::new());
        set_is_adding.set(true);

        // Send to server
        spawn_local(async move {
            // Simulate API call
            tokio::time::sleep(Duration::from_secs(1)).await;

            // Update with real ID
            set_todos.update(|todos| {
                if let Some(todo) = todos.iter_mut().find(|t| t.id == temp_id) {
                    todo.id = "real-id".to_string();
                    todo.status = TodoStatus::Complete;
                }
            });
            set_is_adding.set(false);
        });
    };

    // Toggle todo optimistically
    let toggle_todo = move |id: String| {
        let previous_state = todos.get()
            .iter()
            .find(|t| t.id == id)
            .map(|t| t.completed);

        // Optimistic update
        set_todos.update(|todos| {
            if let Some(todo) = todos.iter_mut().find(|t| t.id == id) {
                todo.completed = !todo.completed;
            }
        });

        // Send to server
        spawn_local(async move {
            // Simulate API call
            tokio::time::sleep(Duration::from_millis(500)).await;

            // On error, rollback
            if let Some(previous) = previous_state {
                set_todos.update(|todos| {
                    if let Some(todo) = todos.iter_mut().find(|t| t.id == id) {
                        todo.completed = previous;
                    }
                });
            }
        });
    };

    view! {
        <Card class="p-6">
            <h2 class="text-2xl font-bold mb-4">"Todos"</h2>

            // Add todo form
            <form on_submit=move |ev| {
                ev.prevent_default();
                add_todo(ev);
            } class="flex gap-2 mb-4">
                <Input
                    placeholder="Add a new todo..."
                    value=new_todo
                    on_change=move |ev| set_new_todo.set(event_target_value(&ev))
                />
                <Button type="submit" disabled=move || is_adding.get() || new_todo.get().is_empty()>
                    {move || if is_adding.get() { "Adding..." } else { "Add" }}
                </Button>
            </form>

            // Todo list
            <div class="space-y-2">
                {move || {
                    todos.get().into_iter().map(|todo| {
                        let todo_id = todo.id.clone();
                        view! {
                            <div class="flex items-center gap-3 p-3 border rounded-md">
                                <Checkbox
                                    checked=todo.completed
                                    on_change=move |_| toggle_todo(todo_id.clone())
                                />
                                <span class=move || {
                                    format!(
                                        "{}{}",
                                        todo.title,
                                        if todo.status == TodoStatus::Pending {
                                            " (Saving...)"
                                        } else {
                                            ""
                                        }
                                    )
                                }
                                class=move || if todo.completed { "line-through text-muted-foreground" } else { "" }>
                                    {todo.title}
                                </span>
                            </div>
                        }
                    }).collect_view()
                }}
            </div>
        </Card>
    }
}

#[derive(Clone, Debug)]
pub struct Todo {
    pub id: String,
    pub title: String,
    pub completed: bool,
    pub status: TodoStatus,
}

#[derive(Clone, Copy, Debug, PartialEq)]
pub enum TodoStatus {
    Complete,
    Pending,
}
```

## State Persistence

### LocalStorage Hook

```rust
use leptos::*;
use serde::{Deserialize, Serialize};

/// Hook for persisting state to localStorage
pub fn use_persistent_signal<T>(
    key: impl Fn() -> String + 'static,
    default_value: impl Fn() -> T + 'static,
) -> (ReadSignal<T>, WriteSignal<T>)
where
    T: Serialize + DeserializeOwned + Clone + 'static,
{
    // Load from localStorage on mount
    let initial = {
        let key = key();
        window()
            .local_storage()
            .ok()
            .flatten()
            .and_then(|storage| storage.get(&key).ok())
            .flatten()
            .and_then(|json| serde_json::from_str(&json).ok())
            .unwrap_or_else(default_value)
    };

    let (signal, set_signal) = create_signal(initial);

    // Save to localStorage on change
    create_effect(move |_| {
        let value = signal.get();
        let key = key();

        if let Ok(json) = serde_json::to_string(&value) {
            if let Some(storage) = window().local_storage().ok().flatten() {
                let _ = storage.set(&key, &json);
            }
        }
    });

    // Listen for storage events (sync across tabs)
    window().add_event_listener(move |event: StorageEvent| {
        if event.key().as_deref() == Some(&key()) {
            if let Some(new_value) = event.new_value() {
                if let Ok(value) = serde_json::from_str(&new_value) {
                    set_signal.set(value);
                }
            }
        }
    });

    (signal, set_signal)
}

#[component]
pub fn PersistentSettings() -> impl IntoView {
    let (theme, set_theme) = use_persistent_signal(
        || "theme".to_string(),
        || "light".to_string(),
    );

    let (language, set_language) = use_persistent_signal(
        || "language".to_string(),
        || "en".to_string(),
    );

    let (sidebar_collapsed, set_sidebar_collapsed) = use_persistent_signal(
        || "sidebar-collapsed".to_string(),
        || false,
    );

    view! {
        <Card class="p-6">
            <h2 class="text-2xl font-bold mb-4">"Settings"</h2>

            <div class="space-y-4">
                <div class="space-y-2">
                    <Label>"Theme"</Label>
                    <Select value=theme on_change=set_theme>
                        <SelectTrigger>
                            <SelectValue/>
                        </SelectTrigger>
                        <SelectContent>
                            <SelectItem value="light">"Light"</SelectItem>
                            <SelectItem value="dark">"Dark"</SelectItem>
                            <SelectItem value="system">"System"</SelectItem>
                        </SelectContent>
                    </Select>
                </div>

                <div class="space-y-2">
                    <Label>"Language"</Label>
                    <Select value=language on_change=set_language>
                        <SelectTrigger>
                            <SelectValue/>
                        </SelectTrigger>
                        <SelectContent>
                            <SelectItem value="en">"English"</SelectItem>
                            <SelectItem value="es">"Español"</SelectItem>
                            <SelectItem value="fr">"Français"</SelectItem>
                        </SelectContent>
                    </Select>
                </div>

                <div class="flex items-center justify-between">
                    <div>
                        <Label>"Collapse Sidebar"</Label>
                        <p class="text-sm text-muted-foreground">
                            "Show collapsed sidebar by default"
                        </p>
                    </div>
                    <Switch
                        checked=sidebar_collapsed
                        on_change=set_sidebar_collapsed
                    />
                </div>
            </div>
        </Card>
    }
}
```

## Complete Example: Application State Manager

```rust
use leptos::*;
use std::sync::Arc;
use tokio::sync::RwLock;

/// Application state manager with persistence and sync
#[derive(Clone)]
pub struct StateManager {
    inner: Arc<RwLock<StateInner>>,
}

struct StateInner {
    user: Option<User>,
    settings: Settings,
    cache: HashMap<String, CachedData>,
}

#[derive(Clone, Debug)]
pub struct Settings {
    pub theme: String,
    pub language: String,
    pub notifications_enabled: bool,
}

#[derive(Clone, Debug)]
pub struct CachedData {
    pub data: String,
    pub timestamp: i64,
    pub ttl: i64, // Time to live in seconds
}

impl StateManager {
    pub async fn new() -> Self {
        // Load from persistence
        let settings = Self::load_settings().await;

        Self {
            inner: Arc::new(RwLock::new(StateInner {
                user: None,
                settings,
                cache: HashMap::new(),
            })),
        }
    }

    async fn load_settings() -> Settings {
        // Load from localStorage or API
        Settings {
            theme: "light".to_string(),
            language: "en".to_string(),
            notifications_enabled: true,
        }
    }

    pub async fn get_user(&self) -> Option<User> {
        self.inner.read().await.user.clone()
    }

    pub async fn set_user(&self, user: Option<User>) {
        let mut inner = self.inner.write().await;
        inner.user = user;
        // Persist to localStorage
    }

    pub async fn get_cached(&self, key: &str) -> Option<String> {
        let inner = self.inner.read().await;
        let cached = inner.cache.get(key)?;

        // Check TTL
        let now = chrono::Utc::now().timestamp();
        if now - cached.timestamp > cached.ttl {
            return None;
        }

        Some(cached.data.clone())
    }

    pub async fn set_cache(&self, key: String, data: String, ttl: i64) {
        let mut inner = self.inner.write().await;
        inner.cache.insert(key, CachedData {
            data,
            timestamp: chrono::Utc::now().timestamp(),
            ttl,
        });
    }
}
```

## Performance Optimization

### Memoization

```rust
#[component]
pub fn OptimizedComponent() -> impl IntoView {
    let (items, set_items) = create_signal(vec![
        Item { id: 1, name: "Item 1".to_string(), value: 100 },
        Item { id: 2, name: "Item 2".to_string(), value: 200 },
    ]);

    // Memoized computed values
    let total_value = create_memo(move |_| {
        items.get().into_iter().map(|i| i.value).sum()
    });

    let expensive_computation = create_memo(move |_| {
        // Only recalculates when items change
        items.get()
            .into_iter()
            .map(|i| complex_calculation(i))
            .collect::<Vec<_>>()
    });

    // Filtered list (also memoized)
    let expensive_items = create_memo(move |_| {
        items.get()
            .into_iter()
            .filter(|i| i.value > 150)
            .collect::<Vec<_>>()
    });

    view! {
        <div>
            <div>"Total: "{total_value}</div>
            <div>"Expensive: "{expensive_computation.get().len()}</div>
        </div>
    }
}
```

## Exercise

1. Create a global state manager for a shopping cart
2. Implement optimistic updates for cart operations
3. Add persistence with localStorage
4. Create a state synchronization system for multiple tabs
5. Implement a caching layer for API responses

## What's Next?

- [Form Validation Patterns](02-form-validation.md) - Advanced form techniques
- [Performance Optimization](04-performance.md) - Rendering optimization
- [Real-time Data](06-realtime.md) - WebSockets and live updates

---

**Previous**: [Component Series](../components/01-form-components.md) | **Next**: [Form Validation](02-form-validation.md)
