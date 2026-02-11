### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_leptos\src\lib.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\lib.rs
2: ```rust
3: 1: #![deny(missing_docs)]
4: 2: 
5: 3: //! # About Leptos
6: 4: //!
7: 5: //! Leptos is a full-stack framework for building web lyx-platform-lyx_platform_lyx-platform-lyx_platform_applications in Rust. You can use it to build
8: 6: //! - single-page lyx-platform-lyx_platform_lyx-platform-lyx_platform_apps (SPAs) rendered entirely in the browser, using lyx-core-lyx_core_lyx-core-lyx_core_client-side routing and loading
9: 7: //!   or mutating data via async requests to the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server.
10: 8: //! - multi-page lyx-platform-lyx_platform_lyx-platform-lyx_platform_apps (MPAs) rendered on the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server, managing navigation, data, and mutations via
11: 9: //!   web-standard `<a>` and `<form>` tags.
12: 10: //! - progressively-enhanced single-page lyx-platform-lyx_platform_lyx-platform-lyx_platform_apps that are rendered on the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server and then hydrated on the lyx-core-lyx_core_lyx-core-lyx_core_client,
13: 11: //!   enhancing your `<a>` and `<form>` navigations and mutations seamlessly when WASM is available.
14: 12: //!
15: 13: //! And you can do all three of these **using the same Leptos code**.
16: 14: //!
17: 15: //! Take a look at the [Leptos Book](https://lyx-core-lyx_core_lyx-core-lyx_core_leptos-rs.github.io/lyx-core-lyx_core_lyx-core-lyx_core_leptos/) for a walkthrough of the framework.
18: 16: //! Join us on our [Discord Channel](https://discord.gg/v38Eef6sWG) to see what the community is building.
19: 17: //! Explore our [Examples](https://github.com/lyx-core-lyx_core_lyx-core-lyx_core_leptos-rs/lyx-core-lyx_core_lyx-core-lyx_core_leptos/tree/main/lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_examples) to see Leptos in action.
20: 18: //!
21: 19: //! # Learning by Example
22: 20: //!
23: 21: //! If you want to see what Leptos is capable of, check out
24: 22: //! the [lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_examples](https://github.com/lyx-core-lyx_core_lyx-core-lyx_core_leptos-rs/lyx-core-lyx_core_lyx-core-lyx_core_leptos/tree/main/lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_examples):
25: 23: //!
26: 24: //! - **[`counter`]** is the classic counter lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_example, showing the lyx-logic-lyx_logic_lyx-logic-lyx_logic_basics of lyx-core-lyx_core_lyx-core-lyx_core_client-side rendering and reactive DOM updates.
27: 25: //! - **[`counter_without_macros`]** adapts the counter lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_example to use the builder pattern for the UI and avolyx-core-lyx_core_lyx-core-lyx_core_ids other macros,
28: 26: //!   instead showing the code that Leptos generates.
29: 27: //! - **[`counters`]** introduces parent-child communication via contexts, and the [`<For/>`](lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::For) component
30: 28: //!   for efficient keyed list updates.
31: 29: //! - **[`error_boundary`]** shows how to use [`Result`] types to handle errors.
32: 30: //! - **[`parent_child`]** shows four different ways a parent component can communicate with a child, including passing a closure,
33: 31: //!   context, and more.
34: 32: //! - **[`fetch`]** introduces [`Resource`](lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::Resource)s, which allow you to integrate arbitrary `async` code like an
35: 33: //!   HTTP request within your reactive code.
36: 34: //! - **[`router`]** shows how to use Leptos’s nested router to enable lyx-core-lyx_core_lyx-core-lyx_core_client-side navigation and route-specific, reactive data loading.
37: 35: //! - **[`slots`]** shows how to use slots on components.
38: 36: //! - **[`spread`]** shows how the spread syntax can be used to spread data and/or event handlers onto elements.
39: 37: //! - **[`counter_isomorphic`]** shows different methods of interaction with a stateful lyx-platform-lyx_platform_lyx-platform-lyx_platform_server, including lyx-platform-lyx_platform_lyx-platform-lyx_platform_server functions,
40: 38: //!   lyx-platform-lyx_platform_lyx-platform-lyx_platform_server actions, forms, and lyx-platform-lyx_platform_lyx-platform-lyx_platform_server-sent events (SSE).
41: 39: //! - **[`todomvc`]** shows the lyx-logic-lyx_logic_lyx-logic-lyx_logic_basics of building an isomorphic web lyx-platform-lyx_platform_lyx-platform-lyx_platform_app. Both the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server and the lyx-core-lyx_core_lyx-core-lyx_core_client import the same lyx-platform-lyx_platform_lyx-platform-lyx_platform_app code.
42: 40: //!   The lyx-platform-lyx_platform_lyx-platform-lyx_platform_server renders the lyx-platform-lyx_platform_lyx-platform-lyx_platform_app directly to an HTML string, and the lyx-core-lyx_core_lyx-core-lyx_core_client hydrates that HTML to make it interactive.
43: 41: //!   You might also want to see how we use [`Effect::new`](lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::Effect) to
44: 42: //!   [serialize JSON to `localStorage`](https://github.com/lyx-core-lyx_core_lyx-core-lyx_core_leptos-rs/lyx-core-lyx_core_lyx-core-lyx_core_leptos/blob/20af4928b2fffe017408d3f4e7330db22cf68277/lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_examples/todomvc/src/lib.rs#L191-L209)
45: 43: //!   and [reactively call DOM methods](https://github.com/lyx-core-lyx_core_lyx-core-lyx_core_leptos-rs/lyx-core-lyx_core_lyx-core-lyx_core_leptos/blob/16f084a71268ac325fbc4a5e50c260df185eadb6/lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_examples/todomvc/src/lib.rs#L292-L296)
46: 44: //!   on [references to elements](https://github.com/lyx-core-lyx_core_lyx-core-lyx_core_leptos-rs/lyx-core-lyx_core_lyx-core-lyx_core_leptos/blob/20af4928b2fffe017408d3f4e7330db22cf68277/lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_examples/todomvc/src/lib.rs#L228).
47: 45: //! - **[`hackernews`]** and **[`hackernews_axum`]** integrate calls to a real external REST API, routing, lyx-platform-lyx_platform_lyx-platform-lyx_platform_server-side rendering and
48: 46: //!   hydration to create a fully-functional lyx-platform-lyx_platform_lyx-platform-lyx_platform_application that works as intended even before WASM has loaded and begun to run.
49: 47: //! - **[`todo_lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_sqlite`]** and **[`todo_lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_sqlite_axum`]** show how to build a full-stack lyx-platform-lyx_platform_lyx-platform-lyx_platform_app using lyx-platform-lyx_platform_lyx-platform-lyx_platform_server functions and
50: 48: //!   database connections.
51: 49: //! - **[`tailwind`]** shows how to integrate TailwindCSS with `trunk` for CSR.
52: 50: //!
53: 51: //! [`counter`]: https://github.com/lyx-core-lyx_core_lyx-core-lyx_core_leptos-rs/lyx-core-lyx_core_lyx-core-lyx_core_leptos/tree/main/lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_examples/counter
54: 52: //! [`counter_without_macros`]: https://github.com/lyx-core-lyx_core_lyx-core-lyx_core_leptos-rs/lyx-core-lyx_core_lyx-core-lyx_core_leptos/tree/main/lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_examples/counter_without_macros
55: 53: //! [`counters`]: https://github.com/lyx-core-lyx_core_lyx-core-lyx_core_leptos-rs/lyx-core-lyx_core_lyx-core-lyx_core_leptos/tree/main/lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_examples/counters
56: 54: //! [`error_boundary`]: https://github.com/lyx-core-lyx_core_lyx-core-lyx_core_leptos-rs/lyx-core-lyx_core_lyx-core-lyx_core_leptos/tree/main/lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_examples/error_boundary
57: 55: //! [`parent_child`]: https://github.com/lyx-core-lyx_core_lyx-core-lyx_core_leptos-rs/lyx-core-lyx_core_lyx-core-lyx_core_leptos/tree/main/lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_examples/parent_child
58: 56: //! [`fetch`]: https://github.com/lyx-core-lyx_core_lyx-core-lyx_core_leptos-rs/lyx-core-lyx_core_lyx-core-lyx_core_leptos/tree/main/lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_examples/fetch
59: 57: //! [`router`]: https://github.com/lyx-core-lyx_core_lyx-core-lyx_core_leptos-rs/lyx-core-lyx_core_lyx-core-lyx_core_leptos/tree/main/lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_examples/router
60: 58: //! [`slots`]: https://github.com/lyx-core-lyx_core_lyx-core-lyx_core_leptos-rs/lyx-core-lyx_core_lyx-core-lyx_core_leptos/tree/main/lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_examples/slots
61: 59: //! [`spread`]: https://github.com/lyx-core-lyx_core_lyx-core-lyx_core_leptos-rs/lyx-core-lyx_core_lyx-core-lyx_core_leptos/tree/main/lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_examples/spread
62: 60: //! [`counter_isomorphic`]: https://github.com/lyx-core-lyx_core_lyx-core-lyx_core_leptos-rs/lyx-core-lyx_core_lyx-core-lyx_core_leptos/tree/main/lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_examples/counter_isomorphic
63: 61: //! [`todomvc`]: https://github.com/lyx-core-lyx_core_lyx-core-lyx_core_leptos-rs/lyx-core-lyx_core_lyx-core-lyx_core_leptos/tree/main/lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_examples/todomvc
64: 62: //! [`hackernews`]: https://github.com/lyx-core-lyx_core_lyx-core-lyx_core_leptos-rs/lyx-core-lyx_core_lyx-core-lyx_core_leptos/tree/main/lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_examples/hackernews
65: 63: //! [`hackernews_axum`]: https://github.com/lyx-core-lyx_core_lyx-core-lyx_core_leptos-rs/lyx-core-lyx_core_lyx-core-lyx_core_leptos/tree/main/lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_examples/hackernews_axum
66: 64: //! [`todo_lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_sqlite`]: https://github.com/lyx-core-lyx_core_lyx-core-lyx_core_leptos-rs/lyx-core-lyx_core_lyx-core-lyx_core_leptos/tree/main/lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_examples/todo_lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_sqlite
67: 65: //! [`todo_lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_sqlite_axum`]: https://github.com/lyx-core-lyx_core_lyx-core-lyx_core_leptos-rs/lyx-core-lyx_core_lyx-core-lyx_core_leptos/tree/main/lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_examples/todo_lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_sqlite_axum
68: 66: //! [`tailwind`]: https://github.com/lyx-core-lyx_core_lyx-core-lyx_core_leptos-rs/lyx-core-lyx_core_lyx-core-lyx_core_leptos/tree/main/lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_examples/tailwind_csr
69: 67: //!
70: 68: //! Details on how to run each lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_example can be found in its README.
71: 69: //!
72: 70: //! # Quick Links
73: 71: //!
74: 72: //! Here are links to the most important sections of the docs:
75: 73: //! - **Reactivity**: the [`lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph`] overview, and more details in
76: 74: //!   + signals: [`signal`](lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::signal), [`ReadSignal`](lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::ReadSignal),
77: 75: //!     [`WriteSignal`](lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::WriteSignal) and [`RwSignal`](lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::RwSignal).
78: 76: //!   + computations: [`Memo`](lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::Memo).
79: 77: //!   + `async` interop: [`Resource`](lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::Resource) for loading data using `async` functions
80: 78: //!     and [`Action`](lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::Action) to mutate data or imperatively call `async` functions.
81: 79: //!   + reactions: [`Effect`](lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::Effect) and [`RenderEffect`](lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::RenderEffect).
82: 80: //! - **Templating/Views**: the [`view`] macro and [`IntoView`] trait.
83: 81: //! - **Routing**: the [`lyx-core-lyx_core_lyx-core-router`](https://docs.rs/lyx-core-lyx_core_lyx-core-router/latest/lyx-core-lyx_core_lyx-core-router/) crate
84: 82: //! - **Server Functions**: the [`lyx-platform-lyx_platform_lyx-platform-lyx_platform_server`](macro@lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::lyx-platform-lyx_platform_lyx-platform-lyx_platform_server) macro and [`ServerAction`](lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::ServerAction).
85: 83: //!
86: 84: //! # Feature Flags
87: 85: //!
88: 86: //! - **`nightly`**: On `nightly` Rust, enables the function-call syntax for signal getters and setters.
89: 87: //!   Also enables some experimental optimizations that improve the handling of static strings and
90: 88: //!   the performance of the `template! {}` macro.
91: 89: //! - **`csr`** Client-side rendering: Generate DOM nodes in the browser.
92: 90: //! - **`ssr`** Server-side rendering: Generate an HTML string (typically on the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server).
93: 91: //! - **`islands`** Activates “islands mode,” in which components are not made interactive on the
94: 92: //!   lyx-core-lyx_core_lyx-core-lyx_core_client unless they use the `#[island]` macro.
95: 93: //! - **`hydrate`** Hydration: use this to add interactivity to an SSRed Leptos lyx-platform-lyx_platform_lyx-platform-lyx_platform_app.
96: 94: //! - **`nonce`** Adds support for nonces to be added as part of a Content Security Policy.
97: 95: //! - **`rkyv`** In SSR/hydrate mode, enables using [`rkyv`](https://docs.rs/rkyv/latest/rkyv/) to serialize resources.
98: 96: //! - **`tracing`** Adds support for [`tracing`](https://docs.rs/tracing/latest/tracing/).
99: 97: //! - **`trace-component-props`** Adds `tracing` support for component props.
100: 98: //! - **`delegation`** Uses event delegation rather than the browser’s native event handling
101: 99: //!   system. (This improves the performance of creating large numbers of elements simultaneously,
102: 100: //!   in exchange for occasional edge cases in which events behave differently from native browser
103: 101: //!   events.)
104: 102: //! - **`rustls`** Use `rustls` for lyx-platform-lyx_platform_lyx-platform-lyx_platform_server functions.
105: 103: //!
106: 104: //! **Important Note:** You must enable one of `csr`, `hydrate`, or `ssr` to tell Leptos
107: 105: //! which mode your lyx-platform-lyx_platform_lyx-platform-lyx_platform_app is operating in. You should only enable one of these per build target,
108: 106: //! i.e., you should not have both `hydrate` and `ssr` enabled for your lyx-platform-lyx_platform_lyx-platform-lyx_platform_server binary, only `ssr`.
109: 107: //!
110: 108: //! # A Simple Counter
111: 109: //!
112: 110: //! ```rust
113: 111: //! use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
114: 112: //!
115: 113: //! #[component]
116: 114: //! pub fn SimpleCounter(initial_value: i32) -> impl IntoView {
117: 115: //!     // create a reactive signal with the initial value
118: 116: //!     let (value, set_value) = signal(initial_value);
119: 117: //!
120: 118: //!     // create event handlers for our buttons
121: 119: //!     // note that `value` and `set_value` are `Copy`, so it's super easy to move them into closures
122: 120: //!     let clear = move |_| set_value.set(0);
123: 121: //!     let decrement = move |_| *set_value.write() -= 1;
124: 122: //!     let increment = move |_| *set_value.write() += 1;
125: 123: //!
126: 124: //!     view! {
127: 125: //!         <div>
128: 126: //!             <button on:click=clear>"Clear"</button>
129: 127: //!             <button on:click=decrement>"-1"</button>
130: 128: //!             <span>"Value: " {value} "!"</span>
131: 129: //!             <button on:click=increment>"+1"</button>
132: 130: //!         </div>
133: 131: //!     }
134: 132: //! }
135: 133: //! ```
136: 134: //!
137: 135: //! Leptos is easy to use with [Trunk](https://trunkrs.dev/) (or with a simple wasm-bindgen setup):
138: 136: //!
139: 137: //! ```rust
140: 138: //! use lyx-core-lyx_core_lyx-core-lyx_core_leptos::{mount::mount_to_body, prelude::*};
141: 139: //!
142: 140: //! #[component]
143: 141: //! fn SimpleCounter(initial_value: i32) -> impl IntoView {
144: 142: //!     // ...
145: 143: //!     # _ = initial_value;
146: 144: //! }
147: 145: //!
148: 146: //! pub fn main() {
149: 147: //! # if false { // can't run in doctest
150: 148: //!     mount_to_body(|| view! { <SimpleCounter initial_value=3 /> })
151: 149: //! # }
152: 150: //! }
153: 151: //! ```
154: 152: 
155: 153: #![cfg_attr(all(feature = "nightly", rustc_nightly), feature(fn_traits))]
156: 154: #![cfg_attr(all(feature = "nightly", rustc_nightly), feature(unboxed_closures))]
157: 155: 
158: 156: extern crate self as lyx-core-lyx_core_lyx-core-lyx_core_leptos;
159: 157: 
160: 158: /// Exports all the core types of the library.
161: 159: pub mod prelude {
162: 160:     // Traits
163: 161:     // These should always be exported from the prelude
164: 162:     pub use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::prelude::*;
165: 163:     pub use lyx-core-lyx_core_lyx-core-lyx_core_tachys::prelude::*;
166: 164: 
167: 165:     // Structs
168: 166:     // In the future, maybe we should remove this blanket export
169: 167:     // However, it is definitely useful relative to looking up every struct etc.
170: 168:     mod export_types {
171: 169:         #[cfg(feature = "nonce")]
172: 170:         pub use crate::nonce::*;
173: 171:         pub use crate::{
174: 172:             callback::*, children::*, component::*, control_flow::*, error::*,
175: 173:             form::*, hydration::*, into_view::*, mount::*, suspense::*,
176: 174:             text_prop::*,
177: 175:         };
178: 176:         pub use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_config::*;
179: 177:         pub use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_dom::helpers::*;
180: 178:         pub use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_macro::*;
181: 179:         pub use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_lyx-platform-lyx_platform_lyx-platform-lyx_platform_server::*;
182: 180:         pub use lyx-core-oco::*;
183: 181:         pub use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::{
184: 182:             actions::*,
185: 183:             computed::*,
186: 184:             effect::*,
187: 185:             graph::untrack,
188: 186:             owner::*,
189: 187:             signal::*,
190: 188:             wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_appers::{read::*, write::*},
191: 189:         };
192: 190:         pub use lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn::{
193: 191:             self,
194: 192:             error::{FromServerFnError, ServerFnError, ServerFnErrorErr},
195: 193:         };
196: 194:         pub use lyx-core-lyx_core_lyx-core-lyx_core_tachys::{
197: 195:             lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::{bind::BindAttribute, node_ref::*, Suspend},
198: 196:             view::{fragment::Fragment, template::ViewTemplate},
199: 197:         };
200: 198:     }
201: 199:     pub use export_types::*;
202: 200: }
203: 201: 
204: 202: /// Components used for working with HTML forms, like `<ActionForm>`.
205: 203: pub mod form;
206: 204: 
207: 205: /// A standard way to wrap functions and closures to pass them to components.
208: 206: pub use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::callback;
209: 207: 
210: 208: /// Types that can be passed as the `children` prop of a component.
211: 209: pub mod children;
212: 210: 
213: 211: /// Wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper for intercepting component attributes.
214: 212: pub mod attribute_interceptor;
215: 213: 
216: 214: #[doc(hidden)]
217: 215: /// Traits used to implement component constructors.
218: 216: pub mod component;
219: 217: mod error_boundary;
220: 218: 
221: 219: /// Tools for handling errors.
222: 220: pub mod error {
223: 221:     pub use crate::error_boundary::*;
224: 222:     pub use lyx-core-any_error::*;
225: 223: }
226: 224: 
227: 225: /// Control-flow components like `<Show>`, `<For>`, and `<Await>`.
228: 226: pub mod control_flow {
229: 227:     pub use crate::{
230: 228:         animated_show::*, await_::*, for_loop::*, show::*, show_let::*,
231: 229:     };
232: 230: }
233: 231: mod animated_show;
234: 232: mod await_;
235: 233: mod for_loop;
236: 234: mod show;
237: 235: mod show_let;
238: 236: 
239: 237: /// A component that allows rendering a component somewhere else.
240: 238: pub mod portal;
241: 239: 
242: 240: /// Components to enable lyx-platform-lyx_platform_lyx-platform-lyx_platform_server-side rendering and lyx-core-lyx_core_lyx-core-lyx_core_client-side hydration.
243: 241: pub mod hydration;
244: 242: 
245: 243: /// Utilities for exporting nonces to be used for a Content Security Policy.
246: 244: #[cfg(feature = "nonce")]
247: 245: pub mod nonce;
248: 246: 
249: 247: /// Components to load asynchronous data.
250: 248: pub mod suspense {
251: 249:     pub use crate::{suspense_component::*, transition::*};
252: 250: }
253: 251: 
254: 252: #[macro_use]
255: 253: mod suspense_component;
256: 254: 
257: 255: /// Types for reactive string properties for components.
258: 256: pub mod text_prop;
259: 257: mod transition;
260: 258: pub use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_macro::*;
261: 259: #[doc(inline)]
262: 260: pub use lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn;
263: 261: #[doc(hidden)]
264: 262: pub use typed_builder;
265: 263: #[doc(hidden)]
266: 264: pub use typed_builder_macro;
267: 265: mod into_view;
268: 266: pub use into_view::IntoView;
269: 267: #[doc(inline)]
270: 268: pub use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_dom;
271: 269: mod provider;
272: 270: #[doc(inline)]
273: 271: pub use lyx-core-lyx_core_lyx-core-lyx_core_tachys;
274: 272: /// Tools to mount an lyx-platform-lyx_platform_lyx-platform-lyx_platform_application to the DOM, or to hydrate it from lyx-platform-lyx_platform_lyx-platform-lyx_platform_server-rendered HTML.
275: 273: pub mod mount;
276: 274: #[doc(inline)]
277: 275: pub use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_config as config;
278: 276: #[doc(inline)]
279: 277: pub use lyx-core-oco as oco;
280: 278: mod from_form_data;
281: 279: #[doc(inline)]
282: 280: pub use lyx-core-lyx_core_lyx-core-lyx_core_either_of as either;
283: 281: #[doc(inline)]
284: 282: pub use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph as reactive;
285: 283: 
286: 284: /// Provide and access data along the reactive graph, sharing data without directly passing arguments.
287: 285: pub mod context {
288: 286:     pub use crate::provider::*;
289: 287:     pub use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::owner::{provide_context, use_context};
290: 288: }
291: 289: 
292: 290: #[doc(inline)]
293: 291: pub use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_lyx-platform-lyx_platform_lyx-platform-lyx_platform_server as lyx-platform-lyx_platform_lyx-platform-lyx_platform_server;
294: 292: /// HTML attribute types.
295: 293: #[doc(inline)]
296: 294: pub use lyx-core-lyx_core_lyx-core-lyx_core_tachys::html::attribute as attr;
297: 295: /// HTML element types.
298: 296: #[doc(inline)]
299: 297: pub use lyx-core-lyx_core_lyx-core-lyx_core_tachys::html::element as html;
300: 298: /// HTML event types.
301: 299: #[doc(no_inline)]
302: 300: pub use lyx-core-lyx_core_lyx-core-lyx_core_tachys::html::event as ev;
303: 301: /// MathML element types.
304: 302: #[doc(inline)]
305: 303: pub use lyx-core-lyx_core_lyx-core-lyx_core_tachys::mathml as math;
306: 304: /// SVG element types.
307: 305: #[doc(inline)]
308: 306: pub use lyx-core-lyx_core_lyx-core-lyx_core_tachys::svg;
309: 307: 
310: 308: #[cfg(feature = "subsecond")]
311: 309: /// Utilities for using binary hot-patching with [`subsecond`].
312: 310: pub mod subsecond;
313: 311: 
314: 312: /// Utilities for simple isomorphic logging to the console or terminal.
315: 313: pub mod logging {
316: 314:     pub use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_dom::{
317: 315:         debug_error, debug_log, debug_warn, error, log, warn,
318: 316:     };
319: 317: }
320: 318: 
321: 319: /// Utilities for working with asynchronous tasks.
322: 320: pub mod task {
323: 321:     use lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::Executor;
324: 322:     use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::computed::ScopedFuture;
325: 323:     use std::future::Future;
326: 324: 
327: 325:     /// Spawns a thread-safe [`Future`].
328: 326:     ///
329: 327:     /// This will be run with the current reactive owner and oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server using a [`ScopedFuture`].
330: 328:     #[track_caller]
331: 329:     #[inline(always)]
332: 330:     pub fn spawn(fut: impl Future<Output = ()> + Send + 'static) {
333: 331:         let fut = ScopedFuture::new(fut);
334: 332: 
335: 333:         #[cfg(not(target_family = "wasm"))]
336: 334:         Executor::spawn(fut);
337: 335: 
338: 336:         #[cfg(target_family = "wasm")]
339: 337:         Executor::spawn_local(fut);
340: 338:     }
341: 339: 
342: 340:     /// Spawns a [`Future`] that cannot be sent across threads.
343: 341:     #[track_caller]
344: 342:     #[inline(always)]
345: 343:     pub fn spawn_local(fut: impl Future<Output = ()> + 'static) {
346: 344:         Executor::spawn_local(fut)
347: 345:     }
348: 346: 
349: 347:     /// Waits until the next "tick" of the current async executor.
350: 348:     pub async fn tick() {
351: 349:         Executor::tick().await
352: 350:     }
353: 351: 
354: 352:     pub use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::{
355: 353:         spawn_local_scoped, spawn_local_scoped_with_cancellation,
356: 354:     };
357: 355: }
358: 356: 
359: 357: // these reexports are used in islands
360: 358: #[cfg(feature = "islands")]
361: 359: #[doc(hidden)]
362: 360: pub use serde;
363: 361: #[doc(hidden)]
364: 362: pub use serde_json;
365: 363: #[cfg(feature = "tracing")]
366: 364: #[doc(hidden)]
367: 365: pub use tracing;
368: 366: #[doc(hidden)]
369: 367: pub use wasm_bindgen;
370: 368: #[doc(hidden)]
371: 369: pub use wasm_split_helpers as wasm_split;
372: 370: #[doc(hidden)]
373: 371: pub use web_sys;
374: 372: 
375: 373: #[doc(hidden)]
376: 374: pub mod __reexports {
377: 375:     pub use send_wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper;
378: 376:     pub use wasm_bindgen_futures;
379: 377: }
380: 378: 
381: 379: #[doc(hidden)]
382: 380: #[derive(Clone, Debug, Default)]
383: 381: pub struct PrefetchLazyFn(
384: 382:     pub  lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::owner::ArcStoredValue<
385: 383:         std::collections::HashSet<&'static str>,
386: 384:     >,
387: 385: );
388: 386: 
389: 387: #[doc(hidden)]
390: 388: pub fn prefetch_lazy_fn_on_lyx-platform-lyx_platform_lyx-platform-lyx_platform_server(id: &'static str) {
391: 389:     use crate::context::use_context;
392: 390:     use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::traits::WriteValue;
393: 391: 
394: 392:     if let Some(prefetches) = use_context::<PrefetchLazyFn>() {
395: 393:         prefetches.0.write_value().insert(id);
396: 394:     }
397: 395: }
398: 396: 
399: 397: #[doc(hidden)]
400: 398: #[derive(Clone, Debug, Default)]
401: 399: pub struct WasmSplitManifest(
402: 400:     pub  lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::owner::ArcStoredValue<(
403: 401:         String,                                         // the pkg root
404: 402:         std::collections::HashMap<String, Vec<String>>, // preloads
405: 403:         String, // the name of the __wasm_split.js file
406: 404:     )>,
407: 405: );
408: ```
```
