use leptos::prelude::*;
use serde::{Deserialize, Serialize};
use serde_json::Value;

// =============================================================================
// PILLAR 1: DATA BINDING (The Nervous System)
// =============================================================================

/// A value that can be either literal or fetched from the Data Model via a path.
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(untagged)]
pub enum BoundValue {
Literal(Value),
Binding { path: String },
}

/// The Global Data Model containing the state of the UI.
#[derive(Debug, Clone, Default)]
pub struct DataModel(pub Signal<Value>);

impl DataModel {
/// Resolves a path (e.g., "/user/name") into a concrete string for display.
pub fn resolve(&self, value: &BoundValue) -> String {
match value {
BoundValue::Literal(v) => v.as_str().unwrap_or("").to_string(),
BoundValue::Binding { path } => {
// Logic to traverse the JSON Value at `path`
self.0.with(|data| {
// Simple example: path "/name" -> data["name"]
let clean_path = path.trim_start_matches('/');
data.get(clean_path)
.and_then(|v| v.as_str())
.unwrap_or("[Pending...]")
.to_string()
})
}
}
}
}

// =============================================================================
// PILLAR 2: EVENT HANDLING (The Muscles)
// =============================================================================

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Action {
pub name: String,
pub context: Option<Value>,
}

/// Sent from Client to Server when a user interacts.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct UserActionMessage {
pub action: String,
pub surface_id: String,
pub context: Value,
}

// =============================================================================
// PILLAR 3: SOCKET INTEGRATION (The Blood Flow)
// =============================================================================

/// The top-level messages received from the server.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum ServerToClientMsg {
/// Update the UI structure
SurfaceUpdate {
surface_id: String,
root: UniversalComponent,
},
/// Update the data (the values)
DataModelUpdate {
surface_id: String,
payload: Value,
},
}

// =============================================================================
// COMPONENT REGISTRY & RENDERER
// =============================================================================

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum UniversalComponent {
Button {
label: BoundValue,
action: Option<Action>,
variant: Option<String>,
},
Card {
title: BoundValue,
children: Vec<UniversalComponent>,
},
Column {
children: Vec<UniversalComponent>,
},
Text {
text: BoundValue,
}
}

#[component]
pub fn DynamicRenderer(component: UniversalComponent, surface_id: String) -> impl IntoView {
let data_model = expect_context::<DataModel>();
// In a real app, this would be your socket context
// let socket = expect_socket_context::<UserActionMessage>();

match component {
UniversalComponent::Text { text } => {
let label = move || data_model.resolve(&text);
view! { <p>{label}</p> }.into_any()
}
UniversalComponent::Column { children } => {
view! {
<div class="flex flex-col gap-2">
{children.into_iter().map(|child| {
view! { <DynamicRenderer component=child surface_id=surface_id.clone() /> }
}).collect_view()}
</div>
}.into_any()
}
UniversalComponent::Button { label, action, variant } => {
let text = move || data_model.resolve(&label);

let on_click = move |_| {
if let Some(act) = &action {
leptos::logging::log!("Sending action to server: {}", act.name);
// socket.send(UserActionMessage { ... })
}
};

view! {
<button
class=format!("px-4 py-2 rounded bg-{}", variant.unwrap_or("blue".to_string()))
on:click=on_click
>
{text}
</button>
}.into_any()
}
UniversalComponent::Card { title, children } => {
let title_text = move || data_model.resolve(&title);
view! {
<div class="border p-4 rounded shadow-lg bg-gray-50">
<h2 class="text-xl font-bold mb-4">{title_text}</h2>
{children.into_iter().map(|child| {
view! { <DynamicRenderer component=child surface_id=surface_id.clone() /> }
}).collect_view()}
</div>
}.into_any()
}
}
}

// =============================================================================
// THE "SHELL" (The Application Host)
// =============================================================================

#[component]
pub fn AppShell() -> impl IntoView {
// 1. Initialize the Data Model
let initial_data = serde_json::json!({ "username": "Admin", "status": "Online" });
let data_signal = RwSignal::new(initial_data);
provide_context(DataModel(data_signal.into()));

// 2. State for the UI Structure (Normally from Socket)
let (ui_structure, set_ui_structure) = signal::<Option<UniversalComponent>>(None);

// Simulate Receiving UI from Socket after 1 second
leptos::task::spawn_local(async move {
tokio::time::sleep(std::time::Duration::from_secs(1)).await;
let mock_json = r#"{
"Card": {
"title": "Dashboard Dynamique",
"children": [
{ "Text": { "text": { "path": "/status" } } },
{ "Button": { "label": "Sauvegarder", "action": { "name": "save" } } }
]
}
}"#;
let comp: UniversalComponent = serde_json::from_str(mock_json).unwrap();
set_ui_structure.set(Some(comp));
});

view! {
<div class="p-8">
<h1 class="text-3xl mb-8">Lyxal Universal Shell</h1>
{move || match ui_structure.get() {
Some(comp) => view! { <DynamicRenderer component=comp surface_id="main".to_string() /> }.into_any(),
None => view! { <p>"Chargement de l'interface..."</p> }.into_any(),
}}
</div>
}
}
