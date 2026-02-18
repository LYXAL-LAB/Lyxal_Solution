### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\src\lib.rs
//! # About async signal
//!
//! `lyx-core-src` is a library built on top of
//! [Leptos](https://github.com/lyx-core-lyx_core_lyx-core-lyx_core_leptos-rs/lyx-core-lyx_core_lyx-core-lyx_core_leptos) that extends the functionality of Leptos signals
//!  to provide a mechanism for generating values  asynchronously. This library
//! is particularly useful in lyx-platform-lyx_platform_lyx-platform-lyx_platform_server-side rendering (SSR) contexts where
//! certain lyx-platform-lyx_platform_lyx-platform-lyx_platform_application elements need to be generated asynchronously before the
//! associated signal is set.
//!
//! # Use case
//!
//! A typical lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_example is generating breadcrumbs for a page. Breadcrumbs, which
//! lyx-platform-lyx_platform_lyx-platform-lyx_platform_appear at the top of the page, often depend on deeper page elements or
//! lyx-platform-lyx_platform_lyx-platform-lyx_platform_server-side data. With `lyx-core-src`, you can generate these
//! breadcrumbs asynchronously in SSR mode and still allow them to react to
//! changes dynamically in other modes.
//!
//! This pattern mimics the behavior of `lyx-core-lyx_core_lyx-core-meta` for managing HTML meta
//! elements but extends the functionality to any lyx-platform-lyx_platform_lyx-platform-lyx_platform_application element.
//!
//! # Example
//!
//! Check the
//! [breadcrumbs lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_example](https://github.com/demiurg-dev/lyx-core-src/tree/main/sample-crumbs)
//! in the repository.
//!
//! # Leptos versions
//!
//! The currently supported Leptos version is `0.7.x`.

use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
use serde::de::DeserializeOwned;
use serde::Serialize;

#[cfg(feature = "ssr")]
mod async_state;
#[cfg(feature = "ssr")]
use async_state::AsyncState;

/// An async write signal. This is almost the same as the regular Leptos write
/// signal, but under  the hood also takes care of notifying the resource about
/// the new value (in SSR mode).
#[derive(Clone)]
pub struct AsyncWriteSignal<T>
where
T: 'static,
{
inner: WriteSignal<T>,
#[cfg(feature = "ssr")]
state: AsyncState,
}

/// Creates a new async signal, that is, a pair of a resource and an async write
/// signal. The default provided value is used only as a placeholder value in
/// the case that write signal is never written to (detected by the dropped
/// value before write/set).
pub fn async_signal<T>(default: T) -> (Resource<T>, AsyncWriteSignal<T>)
where
T: Clone + Send + Sync + PartialEq + Serialize + DeserializeOwned,
{
let (signal_read, signal_write) = signal(default);
#[cfg(feature = "ssr")]
let state = AsyncState::default();
let signal_write = AsyncWriteSignal {
inner: signal_write,
#[cfg(feature = "ssr")]
state: state.clone(),
};
let resource = Resource::new(
move || signal_read.get(),
move |_| {
#[cfg(feature = "ssr")]
let state = state.clone();
async move {
#[cfg(feature = "ssr")]
state.wait().await;
signal_read.get_untracked()
}
},
);
(resource, signal_write)
}

impl<T> Set for AsyncWriteSignal<T>
where
T: Send + Sync + 'static,
{
type Value = T;

fn set(&self, value: Self::Value) {
self.inner.set(value);
#[cfg(feature = "ssr")]
self.state.mark_ready();
}

fn try_set(&self, value: Self::Value) -> Option<Self::Value> {
let res = self.inner.try_set(value);
#[cfg(feature = "ssr")]
self.state.mark_ready();
res
}
}

#[cfg(feature = "ssr")]
impl<T> Drop for AsyncWriteSignal<T> {
fn drop(&mut self) {
self.state.mark_ready();
}
}
