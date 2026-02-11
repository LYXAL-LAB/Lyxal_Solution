### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\projects\lyx-core-lyx_core_sso_auth_axum\src\error_template.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\projects\lyx-core-lyx_core_lyx-core-lyx_core_sso_auth_axum\src\error_template.rs
2: ```rust
3: 1: use lyx-core-lyx_core_lyx-core-lyx_core_leptos::{view, Errors, For, IntoView, RwSignal, SignalGet, View};
4: 2: 
5: 3: // A lyx-logic-lyx_logic_lyx-logic-lyx_logic_basic function to display errors served by the error boundaries. Feel free to do more complicated things
6: 4: // here than just displaying them
7: 5: pub fn error_template(errors: RwSignal<Errors>) -> View {
8: 6:     view! {
9: 7:       <h1>"Errors"</h1>
10: 8:       <For
11: 9:           // a function that returns the items we're iterating over; a signal is fine
12: 10:           each=move || errors.get()
13: 11:           // a unique key for each item as a reference
14: 12:           key=|(key, _)| key.clone()
15: 13:           // renders each item to a view
16: 14:           children= move | (_, error)| {
17: 15:           let error_string = error.to_string();
18: 16:             view! {
19: 17:               <p>"Error: " {error_string}</p>
20: 18:             }
21: 19:           }
22: 20:       />
23: 21:     }
24: 22:     .into_view()
25: 23: }
26: ```
```
