#![deny(missing_docs)]

//! # About Leptos
//!
//! Leptos is a full-stack framework for building web lyx-platform-lyx_platform_lyx-platform-lyx_platform_applications in Rust. You can use it to build
//! - single-page lyx-platform-lyx_platform_lyx-platform-lyx_platform_apps (SPAs) rendered entirely in the browser, using lyx-core-lyx_core_lyx-core-lyx_core_client-side routing and loading
//!   or mutating data via async requests to the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server.
//! - multi-page lyx-platform-lyx_platform_lyx-platform-lyx_platform_apps (MPAs) rendered on the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server, managing navigation, data, and mutations via
//!   web-standard `<a>` and `<form>` tags.
//! - progressively-enhanced single-page lyx-platform-lyx_platform_lyx-platform-lyx_platform_apps that are rendered on the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server and then hydrated on the lyx-core-lyx_core_lyx-core-lyx_core_client,
//!   enhancing your `<a>` and `<form>` navigations and mutations seamlessly when WASM is available.
//!
//! And you can do all three of these **using the same Leptos code**.
//!
//! Take a look at the [Leptos Book](https://lyx-core-lyx_core_lyx-core-lyx_core_leptos-rs.github.io/lyx-core-lyx_core_lyx-core-lyx_core_leptos/) for a walkthrough of the framework.
//! Join us on our [Discord Channel](https://discord.gg/v38Eef6sWG) to see what the community is building.
//! Explore our [Examples](https://github.com/lyx-core-lyx_core_lyx-core-lyx_core_leptos-rs/lyx-core-lyx_core_lyx-core-lyx_core_leptos/tree/main/lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_examples) to see Leptos in action.
//!
//! # Learning by Example
//!
//! If you want to see what Leptos is capable of, check out
//! the [lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_examples](https://github.com/lyx-core-lyx_core_lyx-core-lyx_core_leptos-rs/lyx-core-lyx_core_lyx-core-lyx_core_leptos/tree/main/lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_examples):
//!
//! - **[`counter`]** is the classic counter lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_example, showing the lyx-logic-lyx_logic_lyx-logic-lyx_logic_basics of lyx-core-lyx_core_lyx-core-lyx_core_client-side rendering and reactive DOM updates.
//! - **[`counter_without_macros`]** adapts the counter lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_example to use the builder pattern for the UI and avolyx-core-lyx_core_lyx-core-lyx_core_ids other macros,
//!   instead showing the code that Leptos generates.
//! - **[`counters`]** introduces parent-child communication via contexts, and the [`<For/>`](lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::For) component
//!   for efficient keyed list updates.
//! - **[`error_boundary`]** shows how to use [`Result`] types to handle errors.
//! - **[`parent_child`]** shows four different ways a parent component can communicate with a child, including passing a closure,
//!   context, and more.
//! - **[`fetch`]** introduces [`Resource`](lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::Resource)s, which allow you to integrate arbitrary `async` code like an
//!   HTTP request within your reactive code.
//! - **[`router`]** shows how to use Leptosâ€™s nested router to enable lyx-core-lyx_core_lyx-core-lyx_core_client-side navigation and route-specific, reactive data loading.
//! - **[`slots`]** shows how to use slots on components.
//! - **[`spread`]** shows how the spread syntax can be used to spread data and/or event handlers onto elements.
//! - **[`counter_isomorphic`]** shows different methods of interaction with a stateful lyx-platform-lyx_platform_lyx-platform-lyx_platform_server, including lyx-platform-lyx_platform_lyx-platform-lyx_platform_server functions,
//!   lyx-platform-lyx_platform_lyx-platform-lyx_platform_server actions, forms, and lyx-platform-lyx_platform_lyx-platform-lyx_platform_server-sent events (SSE).
//! - **[`todomvc`]** shows the lyx-logic-lyx_logic_lyx-logic-lyx_logic_basics of building an isomorphic web lyx-platform-lyx_platform_lyx-platform-lyx_platform_app. Both the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server and the lyx-core-lyx_core_lyx-core-lyx_core_client import the same lyx-platform-lyx_platform_lyx-platform-lyx_platform_app code.
//!   The lyx-platform-lyx_platform_lyx-platform-lyx_platform_server renders the lyx-platform-lyx_platform_lyx-platform-lyx_platform_app directly to an HTML string, and the lyx-core-lyx_core_lyx-core-lyx_core_client hydrates that HTML to make it interactive.
//!   You might also want to see how we use [`Effect::new`](lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::Effect) to
//!   [serialize JSON to `localStorage`](https://github.com/lyx-core-lyx_core_lyx-core-lyx_core_leptos-rs/lyx-core-lyx_core_lyx-core-lyx_core_leptos/blob/20af4928b2fffe017408d3f4e7330db22cf68277/lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_examples/todomvc/src/lib.rs#L191-L209)
//!   and [reactively call DOM methods](https://github.com/lyx-core-lyx_core_lyx-core-lyx_core_leptos-rs/lyx-core-lyx_core_lyx-core-lyx_core_leptos/blob/16f084a71268ac325fbc4a5e50c260df185eadb6/lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_examples/todomvc/src/lib.rs#L292-L296)
//!   on [references to elements](https://github.com/lyx-core-lyx_core_lyx-core-lyx_core_leptos-rs/lyx-core-lyx_core_lyx-core-lyx_core_leptos/blob/20af4928b2fffe017408d3f4e7330db22cf68277/lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_examples/todomvc/src/lib.rs#L228).
//! - **[`hackernews`]** and **[`hackernews_axum`]** integrate calls to a real external REST API, routing, lyx-platform-lyx_platform_lyx-platform-lyx_platform_server-side rendering and
//!   hydration to create a fully-functional lyx-platform-lyx_platform_lyx-platform-lyx_platform_application that works as intended even before WASM has loaded and begun to run.
//! - **[`todo_lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_sqlite`]** and **[`todo_lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_sqlite_axum`]** show how to build a full-stack lyx-platform-lyx_platform_lyx-platform-lyx_platform_app using lyx-platform-lyx_platform_lyx-platform-lyx_platform_server functions and
//!   database connections.
//! - **[`tailwind`]** shows how to integrate TailwindCSS with `trunk` for CSR.
//!
//! [`counter`]: https://github.com/lyx-core-lyx_core_lyx-core-lyx_core_leptos-rs/lyx-core-lyx_core_lyx-core-lyx_core_leptos/tree/main/lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_examples/counter
//! [`counter_without_macros`]: https://github.com/lyx-core-lyx_core_lyx-core-lyx_core_leptos-rs/lyx-core-lyx_core_lyx-core-lyx_core_leptos/tree/main/lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_examples/counter_without_macros
//! [`counters`]: https://github.com/lyx-core-lyx_core_lyx-core-lyx_core_leptos-rs/lyx-core-lyx_core_lyx-core-lyx_core_leptos/tree/main/lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_examples/counters
//! [`error_boundary`]: https://github.com/lyx-core-lyx_core_lyx-core-lyx_core_leptos-rs/lyx-core-lyx_core_lyx-core-lyx_core_leptos/tree/main/lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_examples/error_boundary
//! [`parent_child`]: https://github.com/lyx-core-lyx_core_lyx-core-lyx_core_leptos-rs/lyx-core-lyx_core_lyx-core-lyx_core_leptos/tree/main/lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_examples/parent_child
//! [`fetch`]: https://github.com/lyx-core-lyx_core_lyx-core-lyx_core_leptos-rs/lyx-core-lyx_core_lyx-core-lyx_core_leptos/tree/main/lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_examples/fetch
//! [`router`]: https://github.com/lyx-core-lyx_core_lyx-core-lyx_core_leptos-rs/lyx-core-lyx_core_lyx-core-lyx_core_leptos/tree/main/lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_examples/router
//! [`slots`]: https://github.com/lyx-core-lyx_core_lyx-core-lyx_core_leptos-rs/lyx-core-lyx_core_lyx-core-lyx_core_leptos/tree/main/lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_examples/slots
//! [`spread`]: https://github.com/lyx-core-lyx_core_lyx-core-lyx_core_leptos-rs/lyx-core-lyx_core_lyx-core-lyx_core_leptos/tree/main/lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_examples/spread
//! [`counter_isomorphic`]: https://github.com/lyx-core-lyx_core_lyx-core-lyx_core_leptos-rs/lyx-core-lyx_core_lyx-core-lyx_core_leptos/tree/main/lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_examples/counter_isomorphic
//! [`todomvc`]: https://github.com/lyx-core-lyx_core_lyx-core-lyx_core_leptos-rs/lyx-core-lyx_core_lyx-core-lyx_core_leptos/tree/main/lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_examples/todomvc
//! [`hackernews`]: https://github.com/lyx-core-lyx_core_lyx-core-lyx_core_leptos-rs/lyx-core-lyx_core_lyx-core-lyx_core_leptos/tree/main/lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_examples/hackernews
//! [`hackernews_axum`]: https://github.com/lyx-core-lyx_core_lyx-core-lyx_core_leptos-rs/lyx-core-lyx_core_lyx-core-lyx_core_leptos/tree/main/lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_examples/hackernews_axum
//! [`todo_lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_sqlite`]: https://github.com/lyx-core-lyx_core_lyx-core-lyx_core_leptos-rs/lyx-core-lyx_core_lyx-core-lyx_core_leptos/tree/main/lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_examples/todo_lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_sqlite
//! [`todo_lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_sqlite_axum`]: https://github.com/lyx-core-lyx_core_lyx-core-lyx_core_leptos-rs/lyx-core-lyx_core_lyx-core-lyx_core_leptos/tree/main/lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_examples/todo_lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_sqlite_axum
//! [`tailwind`]: https://github.com/lyx-core-lyx_core_lyx-core-lyx_core_leptos-rs/lyx-core-lyx_core_lyx-core-lyx_core_leptos/tree/main/lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_examples/tailwind_csr
//!
//! Details on how to run each lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_example can be found in its README.
//!
//! # Quick Links
//!
//! Here are links to the most important sections of the docs:
//! - **Reactivity**: the [`lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph`] overview, and more details in
//!   + signals: [`signal`](lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::signal), [`ReadSignal`](lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::ReadSignal),
//!     [`WriteSignal`](lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::WriteSignal) and [`RwSignal`](lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::RwSignal).
//!   + computations: [`Memo`](lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::Memo).
//!   + `async` interop: [`Resource`](lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::Resource) for loading data using `async` functions
//!     and [`Action`](lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::Action) to mutate data or imperatively call `async` functions.
//!   + reactions: [`Effect`](lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::Effect) and [`RenderEffect`](lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::RenderEffect).
//! - **Templating/Views**: the [`view`] macro and [`IntoView`] trait.
//! - **Routing**: the [`lyx-core-lyx_core_lyx-core-router`](https://docs.rs/lyx-core-lyx_core_lyx-core-router/latest/lyx-core-lyx_core_lyx-core-router/) crate
//! - **Server Functions**: the [`lyx-platform-lyx_platform_lyx-platform-lyx_platform_server`](macro@lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::lyx-platform-lyx_platform_lyx-platform-lyx_platform_server) macro and [`ServerAction`](lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::ServerAction).
//!
//! # Feature Flags
//!
//! - **`nightly`**: On `nightly` Rust, enables the function-call syntax for signal getters and setters.
//!   Also enables some experimental optimizations that improve the handling of static strings and
//!   the performance of the `template! {}` macro.
//! - **`csr`** Client-side rendering: Generate DOM nodes in the browser.
//! - **`ssr`** Server-side rendering: Generate an HTML string (typically on the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server).
//! - **`islands`** Activates â€œislands mode,â€ in which components are not made interactive on the
//!   lyx-core-lyx_core_lyx-core-lyx_core_client unless they use the `#[island]` macro.
//! - **`hydrate`** Hydration: use this to add interactivity to an SSRed Leptos lyx-platform-lyx_platform_lyx-platform-lyx_platform_app.
//! - **`nonce`** Adds support for nonces to be added as part of a Content Security Policy.
//! - **`rkyv`** In SSR/hydrate mode, enables using [`rkyv`](https://docs.rs/rkyv/latest/rkyv/) to serialize resources.
//! - **`tracing`** Adds support for [`tracing`](https://docs.rs/tracing/latest/tracing/).
//! - **`trace-component-props`** Adds `tracing` support for component props.
//! - **`delegation`** Uses event delegation rather than the browserâ€™s native event handling
//!   system. (This improves the performance of creating large numbers of elements simultaneously,
//!   in exchange for occasional edge cases in which events behave differently from native browser
//!   events.)
//! - **`rustls`** Use `rustls` for lyx-platform-lyx_platform_lyx-platform-lyx_platform_server functions.
//!
//! **Important Note:** You must enable one of `csr`, `hydrate`, or `ssr` to tell Leptos
//! which mode your lyx-platform-lyx_platform_lyx-platform-lyx_platform_app is operating in. You should only enable one of these per build target,
//! i.e., you should not have both `hydrate` and `ssr` enabled for your lyx-platform-lyx_platform_lyx-platform-lyx_platform_server binary, only `ssr`.
//!
//! # A Simple Counter
//!
//! 113: 111: //! use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
//!
//! #[component]
//! pub fn SimpleCounter(initial_value: i32) -> impl IntoView {
//!     // create a reactive signal with the initial value
//!     let (value, set_value) = signal(initial_value);
//!
//!     // create event handlers for our buttons
//!     // note that `value` and `set_value` are `Copy`, so it's super easy to move them into closures
//!     let clear = move |_| set_value.set(0);
//!     let decrement = move |_| *set_value.write() -= 1;
//!     let increment = move |_| *set_value.write() += 1;
//!
//!     view! {
//!         <div>
//!             <button on:click=clear>"Clear"</button>
//!             <button on:click=decrement>"-1"</button>
//!             <span>"Value: " {value} "!"</span>
//!             <button on:click=increment>"+1"</button>
//!         </div>
//!     }
//! }
//! 136: 134: //!
//! Leptos is easy to use with [Trunk](https://trunkrs.dev/) (or with a simple wasm-bindgen setup):
//!
//! 140: 138: //! use lyx-core-lyx_core_lyx-core-lyx_core_leptos::{mount::mount_to_body, prelude::*};
//!
//! #[component]
//! fn SimpleCounter(initial_value: i32) -> impl IntoView {
//!     // ...
//!     # _ = initial_value;
//! }
//!
//! pub fn main() {
//! # if false { // can't run in doctest
//!     mount_to_body(|| view! { <SimpleCounter initial_value=3 /> })
//! # }
//! }
//! 154: 152:
#![cfg_attr(all(feature = "nightly", rustc_nightly), feature(fn_traits))]
#![cfg_attr(all(feature = "nightly", rustc_nightly), feature(unboxed_closures))]

extern crate self as lyx-core-lyx_core_lyx-core-lyx_core_leptos;

/// Exports all the core types of the library.
pub mod prelude {
// Traits
// These should always be exported from the prelude
pub use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::prelude::*;
pub use lyx-core-lyx_core_lyx-core-lyx_core_tachys::prelude::*;

// Structs
// In the future, maybe we should remove this blanket export
// However, it is definitely useful relative to looking up every struct etc.
mod export_types {
#[cfg(feature = "nonce")]
pub use crate::nonce::*;
pub use crate::{
callback::*, children::*, component::*, control_flow::*, error::*,
form::*, hydration::*, into_view::*, mount::*, suspense::*,
text_prop::*,
};
pub use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_config::*;
pub use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_dom::helpers::*;
pub use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_macro::*;
pub use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_lyx-platform-lyx_platform_lyx-platform-lyx_platform_server::*;
pub use lyx-core-oco::*;
pub use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::{
actions::*,
computed::*,
effect::*,
graph::untrack,
owner::*,
signal::*,
wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_appers::{read::*, write::*},
};
pub use lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn::{
self,
error::{FromServerFnError, ServerFnError, ServerFnErrorErr},
};
pub use lyx-core-lyx_core_lyx-core-lyx_core_tachys::{
lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::{bind::BindAttribute, node_ref::*, Suspend},
view::{fragment::Fragment, template::ViewTemplate},
};
}
pub use export_types::*;
}

/// Components used for working with HTML forms, like `<ActionForm>`.
pub mod form;

/// A standard way to wrap functions and closures to pass them to components.
pub use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::callback;

/// Types that can be passed as the `children` prop of a component.
pub mod children;

/// Wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper for intercepting component attributes.
pub mod attribute_interceptor;

#[doc(hidden)]
/// Traits used to implement component constructors.
pub mod component;
mod error_boundary;

/// Tools for handling errors.
pub mod error {
pub use crate::error_boundary::*;
pub use lyx-core-any_error::*;
}

/// Control-flow components like `<Show>`, `<For>`, and `<Await>`.
pub mod control_flow {
pub use crate::{
animated_show::*, await_::*, for_loop::*, show::*, show_let::*,
};
}
mod animated_show;
mod await_;
mod for_loop;
mod show;
mod show_let;

/// A component that allows rendering a component somewhere else.
pub mod portal;

/// Components to enable lyx-platform-lyx_platform_lyx-platform-lyx_platform_server-side rendering and lyx-core-lyx_core_lyx-core-lyx_core_client-side hydration.
pub mod hydration;

/// Utilities for exporting nonces to be used for a Content Security Policy.
#[cfg(feature = "nonce")]
pub mod nonce;

/// Components to load asynchronous data.
pub mod suspense {
pub use crate::{suspense_component::*, transition::*};
}

#[macro_use]
mod suspense_component;

/// Types for reactive string properties for components.
pub mod text_prop;
mod transition;
pub use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_macro::*;
#[doc(inline)]
pub use lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn;
#[doc(hidden)]
pub use typed_builder;
#[doc(hidden)]
pub use typed_builder_macro;
mod into_view;
pub use into_view::IntoView;
#[doc(inline)]
pub use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_dom;
mod provider;
#[doc(inline)]
pub use lyx-core-lyx_core_lyx-core-lyx_core_tachys;
/// Tools to mount an lyx-platform-lyx_platform_lyx-platform-lyx_platform_application to the DOM, or to hydrate it from lyx-platform-lyx_platform_lyx-platform-lyx_platform_server-rendered HTML.
pub mod mount;
#[doc(inline)]
pub use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_config as config;
#[doc(inline)]
pub use lyx-core-oco as oco;
mod from_form_data;
#[doc(inline)]
pub use lyx-core-lyx_core_lyx-core-lyx_core_either_of as either;
#[doc(inline)]
pub use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph as reactive;

/// Provide and access data along the reactive graph, sharing data without directly passing arguments.
pub mod context {
pub use crate::provider::*;
pub use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::owner::{provide_context, use_context};
}

#[doc(inline)]
pub use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_lyx-platform-lyx_platform_lyx-platform-lyx_platform_server as lyx-platform-lyx_platform_lyx-platform-lyx_platform_server;
/// HTML attribute types.
#[doc(inline)]
pub use lyx-core-lyx_core_lyx-core-lyx_core_tachys::html::attribute as attr;
/// HTML element types.
#[doc(inline)]
pub use lyx-core-lyx_core_lyx-core-lyx_core_tachys::html::element as html;
/// HTML event types.
#[doc(no_inline)]
pub use lyx-core-lyx_core_lyx-core-lyx_core_tachys::html::event as ev;
/// MathML element types.
#[doc(inline)]
pub use lyx-core-lyx_core_lyx-core-lyx_core_tachys::mathml as math;
/// SVG element types.
#[doc(inline)]
pub use lyx-core-lyx_core_lyx-core-lyx_core_tachys::svg;

#[cfg(feature = "subsecond")]
/// Utilities for using binary hot-patching with [`subsecond`].
pub mod subsecond;

/// Utilities for simple isomorphic logging to the console or terminal.
pub mod logging {
pub use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_dom::{
debug_error, debug_log, debug_warn, error, log, warn,
};
}

/// Utilities for working with asynchronous tasks.
pub mod task {
use lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::Executor;
use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::computed::ScopedFuture;
use std::future::Future;

/// Spawns a thread-safe [`Future`].
///
/// This will be run with the current reactive owner and oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server using a [`ScopedFuture`].
#[track_caller]
#[inline(always)]
pub fn spawn(fut: impl Future<Output = ()> + Send + 'static) {
let fut = ScopedFuture::new(fut);

#[cfg(not(target_family = "wasm"))]
Executor::spawn(fut);

#[cfg(target_family = "wasm")]
Executor::spawn_local(fut);
}

/// Spawns a [`Future`] that cannot be sent across threads.
#[track_caller]
#[inline(always)]
pub fn spawn_local(fut: impl Future<Output = ()> + 'static) {
Executor::spawn_local(fut)
}

/// Waits until the next "tick" of the current async executor.
pub async fn tick() {
Executor::tick().await
}

pub use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::{
spawn_local_scoped, spawn_local_scoped_with_cancellation,
};
}

// these reexports are used in islands
#[cfg(feature = "islands")]
#[doc(hidden)]
pub use serde;
#[doc(hidden)]
pub use serde_json;
#[cfg(feature = "tracing")]
#[doc(hidden)]
pub use tracing;
#[doc(hidden)]
pub use wasm_bindgen;
#[doc(hidden)]
pub use wasm_split_helpers as wasm_split;
#[doc(hidden)]
pub use web_sys;

#[doc(hidden)]
pub mod __reexports {
pub use send_wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper;
pub use wasm_bindgen_futures;
}

#[doc(hidden)]
#[derive(Clone, Debug, Default)]
pub struct PrefetchLazyFn(
pub  lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::owner::ArcStoredValue<
std::collections::HashSet<&'static str>,
>,
);

#[doc(hidden)]
pub fn prefetch_lazy_fn_on_lyx-platform-lyx_platform_lyx-platform-lyx_platform_server(id: &'static str) {
use crate::context::use_context;
use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::traits::WriteValue;

if let Some(prefetches) = use_context::<PrefetchLazyFn>() {
prefetches.0.write_value().insert(id);
}
}

#[doc(hidden)]
#[derive(Clone, Debug, Default)]
pub struct WasmSplitManifest(
pub  lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::owner::ArcStoredValue<(
String,                                         // the pkg root
std::collections::HashMap<String, Vec<String>>, // preloads
String, // the name of the __wasm_split.js file
)>,
);
