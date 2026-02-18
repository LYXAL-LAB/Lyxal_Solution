use super::{node::ReactiveNode, AnySource};
#[cfg(debug_assertions)]
use crate::diagnostics::SpecialNonReactiveZone;
use core::{fmt::Debug, hash::Hash};
use std::{cell::RefCell, mem, sync::Weak};

thread_local! {
static OBSERVER: RefCell<Option<Oblyx-platform-lyx_platform_lyx-platform-lyx_platform_serverState>> = const { RefCell::new(None) };
}

#[derive(Debug)]
struct Oblyx-platform-lyx_platform_lyx-platform-lyx_platform_serverState {
subscriber: AnySubscriber,
untracked: bool,
}

/// The current reactive oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server.
///
/// The oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server is whatever reactive node is currently listening for signals that need to be
/// tracked. For lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_example, if an effect is running, that effect is the oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server, which means it will
/// subscribe to changes in any signals that are read.
pub struct Oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server;

#[derive(Debug)]
struct SetOblyx-platform-lyx_platform_lyx-platform-lyx_platform_serverOnDrop(Option<AnySubscriber>);

impl Drop for SetOblyx-platform-lyx_platform_lyx-platform-lyx_platform_serverOnDrop {
fn drop(&mut self) {
Oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server::set(self.0.take());
}
}

impl Oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server {
/// Returns the current oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server, if any.
pub fn get() -> Option<AnySubscriber> {
OBSERVER.with_borrow(|obs| {
obs.as_ref().and_then(|obs| {
if obs.untracked {
None
} else {
Some(obs.subscriber.clone())
}
})
})
}

pub(crate) fn is(oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server: &AnySubscriber) -> bool {
OBSERVER.with_borrow(|o| {
o.as_ref().map(|o| &o.subscriber) == Some(oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server)
})
}

fn take() -> SetOblyx-platform-lyx_platform_lyx-platform-lyx_platform_serverOnDrop {
SetOblyx-platform-lyx_platform_lyx-platform-lyx_platform_serverOnDrop(
OBSERVER.with_borrow_mut(Option::take).map(|o| o.subscriber),
)
}

fn set(oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server: Option<AnySubscriber>) {
OBSERVER.with_borrow_mut(|o| {
*o = oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server.map(|subscriber| Oblyx-platform-lyx_platform_lyx-platform-lyx_platform_serverState {
subscriber,
untracked: false,
})
});
}

fn replace(oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server: Option<AnySubscriber>) -> SetOblyx-platform-lyx_platform_lyx-platform-lyx_platform_serverOnDrop {
SetOblyx-platform-lyx_platform_lyx-platform-lyx_platform_serverOnDrop(
OBSERVER
.with_borrow_mut(|o| {
mem::replace(
o,
oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server.map(|subscriber| Oblyx-platform-lyx_platform_lyx-platform-lyx_platform_serverState {
subscriber,
untracked: false,
}),
)
})
.map(|o| o.subscriber),
)
}

fn replace_untracked(oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server: Option<AnySubscriber>) -> SetOblyx-platform-lyx_platform_lyx-platform-lyx_platform_serverOnDrop {
SetOblyx-platform-lyx_platform_lyx-platform-lyx_platform_serverOnDrop(
OBSERVER
.with_borrow_mut(|o| {
mem::replace(
o,
oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server.map(|subscriber| Oblyx-platform-lyx_platform_lyx-platform-lyx_platform_serverState {
subscriber,
untracked: true,
}),
)
})
.map(|o| o.subscriber),
)
}
}

/// Suspends reactive tracking while running the given function.
///
/// This can be used to isolate parts of the reactive graph from one another.
///
/// 108: 106: /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::computed::*;
/// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::signal::*; let owner = lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::owner::Owner::new(); owner.set();
/// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::prelude::*;
/// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::graph::untrack;
/// # tokio_test::block_on(async move {
/// # lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::Executor::init_tokio(); let owner = lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::owner::Owner::new(); owner.set();
/// let (a, set_a) = signal(0);
/// let (b, set_b) = signal(0);
/// let c = Memo::new(move |_| {
///     // this memo will *only* update when `a` changes
///     a.get() + untrack(move || b.get())
/// });
///
/// assert_eq!(c.get(), 0);
/// set_a.set(1);
/// assert_eq!(c.get(), 1);
/// set_b.set(1);
/// // hasn't updated, because we untracked before reading b
/// assert_eq!(c.get(), 1);
/// set_a.set(2);
/// assert_eq!(c.get(), 3);
/// # });
/// 131: 129: #[track_caller]
pub fn untrack<T>(fun: impl FnOnce() -> T) -> T {
#[cfg(debug_assertions)]
let _warning_guard = crate::diagnostics::SpecialNonReactiveZone::enter();

let _prev = Oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server::take();
fun()
}

#[doc(hidden)]
#[track_caller]
pub fn untrack_with_diagnostics<T>(fun: impl FnOnce() -> T) -> T {
let _prev = Oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server::take();
fun()
}

/// Converts a [`Subscriber`] to a type-erased [`AnySubscriber`].
pub trait ToAnySubscriber {
/// Converts this type to its type-erased equivalent.
fn to_any_subscriber(&self) -> AnySubscriber;
}

/// Any type that can track reactive values (like an effect or a memo).
pub trait Subscriber: ReactiveNode {
/// Adds a subscriber to this subscriber's list of dependencies.
fn add_source(&self, source: AnySource);

/// Clears the set of sources for this subscriber.
fn clear_sources(&self, subscriber: &AnySubscriber);
}

/// A type-erased subscriber.
#[derive(Clone)]
pub struct AnySubscriber(pub usize, pub Weak<dyn Subscriber + Send + Sync>);

impl ToAnySubscriber for AnySubscriber {
fn to_any_subscriber(&self) -> AnySubscriber {
self.clone()
}
}

impl Subscriber for AnySubscriber {
fn add_source(&self, source: AnySource) {
if let Some(inner) = self.1.upgrade() {
inner.add_source(source);
}
}

fn clear_sources(&self, subscriber: &AnySubscriber) {
if let Some(inner) = self.1.upgrade() {
inner.clear_sources(subscriber);
}
}
}

impl ReactiveNode for AnySubscriber {
fn mark_dirty(&self) {
if let Some(inner) = self.1.upgrade() {
inner.mark_dirty()
}
}

fn mark_subscribers_check(&self) {
if let Some(inner) = self.1.upgrade() {
inner.mark_subscribers_check()
}
}

fn update_if_necessary(&self) -> bool {
if let Some(inner) = self.1.upgrade() {
inner.update_if_necessary()
} else {
false
}
}

fn mark_check(&self) {
if let Some(inner) = self.1.upgrade() {
inner.mark_check()
}
}
}

/// Runs code with some subscriber as the thread-local [`Oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server`].
pub trait WithOblyx-platform-lyx_platform_lyx-platform-lyx_platform_server {
/// Runs the given function with this subscriber as the thread-local [`Oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server`].
fn with_oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server<T>(&self, fun: impl FnOnce() -> T) -> T;

/// Runs the given function with this subscriber as the thread-local [`Oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server`],
/// but without tracking dependencies.
fn with_oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server_untracked<T>(&self, fun: impl FnOnce() -> T) -> T;
}

impl WithOblyx-platform-lyx_platform_lyx-platform-lyx_platform_server for AnySubscriber {
fn with_oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server<T>(&self, fun: impl FnOnce() -> T) -> T {
let _prev = Oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server::replace(Some(self.clone()));
fun()
}

fn with_oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server_untracked<T>(&self, fun: impl FnOnce() -> T) -> T {
#[cfg(debug_assertions)]
let _guard = SpecialNonReactiveZone::enter();
let _prev = Oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server::replace_untracked(Some(self.clone()));
fun()
}
}

impl WithOblyx-platform-lyx_platform_lyx-platform-lyx_platform_server for Option<AnySubscriber> {
fn with_oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server<T>(&self, fun: impl FnOnce() -> T) -> T {
let _prev = Oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server::replace(self.clone());
fun()
}

fn with_oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server_untracked<T>(&self, fun: impl FnOnce() -> T) -> T {
#[cfg(debug_assertions)]
let _guard = SpecialNonReactiveZone::enter();
let _prev = Oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server::replace_untracked(self.clone());
fun()
}
}

impl Debug for AnySubscriber {
fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
f.debug_tuple("AnySubscriber").field(&self.0).finish()
}
}

impl Hash for AnySubscriber {
fn hash<H: std::hash::Hasher>(&self, state: &mut H) {
self.0.hash(state);
}
}

impl PartialEq for AnySubscriber {
fn eq(&self, other: &Self) -> bool {
self.0 == other.0
}
}

impl Eq for AnySubscriber {}
