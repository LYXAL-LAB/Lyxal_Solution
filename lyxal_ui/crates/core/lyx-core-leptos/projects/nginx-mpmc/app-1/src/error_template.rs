### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\projects\nginx-mpmc\lyx-core-lyx-platform-lyx_platform_app-1\src\error_template.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\projects\nginx-mpmc\lyx-core-lyx-platform-lyx_platform_lyx-core-lyx-platform-lyx_platform_app-1\src\error_template.rs
2: ```rust
3: 1: use http::status::StatusCode;
4: 2: use lyx-core-lyx_core_lyx-core-lyx_core_leptos::*;
5: 3: use thiserror::Error;
6: 4: 
7: 5: #[derive(Clone, Debug, Error)]
8: 6: pub enum AppError {
9: 7:     #[error("Not Found")]
10: 8:     NotFound,
11: 9: }
12: 10: 
13: 11: impl AppError {
14: 12:     pub fn status_code(&self) -> StatusCode {
15: 13:         match self {
16: 14:             AppError::NotFound => StatusCode::NOT_FOUND,
17: 15:         }
18: 16:     }
19: 17: }
20: 18: 
21: 19: // A lyx-logic-lyx_logic_lyx-logic-lyx_logic_basic function to display errors served by the error boundaries.
22: 20: // Feel free to do more complicated things here than just displaying the error.
23: 21: #[component]
24: 22: pub fn ErrorTemplate(
25: 23:     #[prop(optional)] outside_errors: Option<Errors>,
26: 24:     #[prop(optional)] errors: Option<RwSignal<Errors>>,
27: 25: ) -> impl IntoView {
28: 26:     let errors = match outside_errors {
29: 27:         Some(e) => create_rw_signal(e),
30: 28:         None => match errors {
31: 29:             Some(e) => e,
32: 30:             None => panic!("No Errors found and we expected errors!"),
33: 31:         },
34: 32:     };
35: 33:     // Get Errors from Signal
36: 34:     let errors = errors.get_untracked();
37: 35: 
38: 36:     // Downcast lets us take a type that implements `std::error::Error`
39: 37:     let errors: Vec<AppError> = errors
40: 38:         .into_iter()
41: 39:         .filter_map(|(_k, v)| v.downcast_ref::<AppError>().cloned())
42: 40:         .collect();
43: 41:     println!("Errors: {errors:#?}");
44: 42: 
45: 43:     // Only the response code for the first error is actually sent from the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server
46: 44:     // this may be customized by the specific lyx-platform-lyx_platform_lyx-platform-lyx_platform_application
47: 45:     #[cfg(feature = "ssr")]
48: 46:     {
49: 47:         use lyx-core-axum::ResponseOptions;
50: 48:         let response = use_context::<ResponseOptions>();
51: 49:         if let Some(response) = response {
52: 50:             response.set_status(errors[0].status_code());
53: 51:         }
54: 52:     }
55: 53: 
56: 54:     view! {
57: 55:         <h1>{if errors.len() > 1 {"Errors"} else {"Error"}}</h1>
58: 56:         <For
59: 57:             // a function that returns the items we're iterating over; a signal is fine
60: 58:             each= move || {errors.clone().into_iter().enumerate()}
61: 59:             // a unique key for each item as a reference
62: 60:             key=|(index, _error)| *index
63: 61:             // renders each item to a view
64: 62:             children=move |error| {
65: 63:                 let error_string = error.1.to_string();
66: 64:                 let error_code= error.1.status_code();
67: 65:                 view! {
68: 66:                     <h2>{error_code.to_string()}</h2>
69: 67:                     <p>"Error: " {error_string}</p>
70: 68:                 }
71: 69:             }
72: 70:         />
73: 71:     }
74: 72: }
75: ```
```
