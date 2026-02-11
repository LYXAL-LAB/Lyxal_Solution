### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\projects\lyx-core-lyx_core_session_auth_axum\src\error_template.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\projects\lyx-core-lyx_core_lyx-core-lyx_core_session_auth_axum\src\error_template.rs
2: ```rust
3: 1: use crate::errors::TodoAppError;
4: 2: use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
5: 3: #[cfg(feature = "ssr")]
6: 4: use lyx-core-axum::ResponseOptions;
7: 5: 
8: 6: // A lyx-logic-lyx_logic_lyx-logic-lyx_logic_basic function to display errors served by the error boundaries. Feel free to do more complicated things
9: 7: // here than just displaying them
10: 8: #[component]
11: 9: pub fn ErrorTemplate(
12: 10:     #[prop(optional)] outside_errors: Option<Errors>,
13: 11:     #[prop(optional)] errors: Option<ArcRwSignal<Errors>>,
14: 12: ) -> impl IntoView {
15: 13:     let errors = match outside_errors {
16: 14:         Some(e) => ArcRwSignal::new(e),
17: 15:         None => match errors {
18: 16:             Some(e) => e,
19: 17:             None => panic!("No Errors found and we expected errors!"),
20: 18:         },
21: 19:     };
22: 20: 
23: 21:     // Get Errors from Signal
24: 22:     // Downcast lets us take a type that implements `std::error::Error`
25: 23:     let errors: Vec<TodoAppError> = errors
26: 24:         .get()
27: 25:         .into_iter()
28: 26:         .filter_map(|(_, v)| v.downcast_ref::<TodoAppError>().cloned())
29: 27:         .collect();
30: 28: 
31: 29:     // Only the response code for the first error is actually sent from the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server
32: 30:     // this may be customized by the specific lyx-platform-lyx_platform_lyx-platform-lyx_platform_application
33: 31:     #[cfg(feature = "ssr")]
34: 32:     {
35: 33:         let response = use_context::<ResponseOptions>();
36: 34:         if let Some(response) = response {
37: 35:             response.set_status(errors[0].status_code());
38: 36:         }
39: 37:     }
40: 38: 
41: 39:     view! {
42: 40:         <h1>"Errors"</h1>
43: 41:         <For
44: 42:             // a function that returns the items we're iterating over; a signal is fine
45: 43:             each=move || { errors.clone().into_iter().enumerate() }
46: 44:             // a unique key for each item as a reference
47: 45:             key=|(index, _error)| *index
48: 46:             // renders each item to a view
49: 47:             children=move |error| {
50: 48:                 let error_string = error.1.to_string();
51: 49:                 let error_code = error.1.status_code();
52: 50:                 view! {
53: 51:                     <h2>{error_code.to_string()}</h2>
54: 52:                     <p>"Error: " {error_string}</p>
55: 53:                 }
56: 54:             }
57: 55:         />
58: 56:     }
59: 57: }
60: ```
```
