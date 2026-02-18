use crate::context::{provide_context, use_context};
use base64::{
alphabet,
engine::{self, general_purpose},
Engine,
};
use rand::{rng, RngCore};
use std::{fmt::Display, ops::Deref, sync::Arc};
use lyx-core-lyx_core_lyx-core-lyx_core_tachys::html::attribute::AttributeValue;

/// A cryptographic nonce ("number used once") which can be
/// used by Content Security Policy to determine whether or not a given
/// resource will be allowed to load.
///
/// When the `nonce` feature is enabled on one of the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server integrations,
/// a nonce is generated during lyx-platform-lyx_platform_lyx-platform-lyx_platform_server rendering and added to all inline
/// scripts used for HTML streaming and resource loading.
///
/// The nonce being used during the current lyx-platform-lyx_platform_lyx-platform-lyx_platform_server response can be
/// accessed using [`use_nonce`].
///
/// ,ignore
/// #[component]
/// pub fn App() -> impl IntoView {
///     provide_meta_context;
///
///     view! {
///         // use `lyx-core-lyx_core_lyx-core-meta` to insert a <meta> tag with the CSP
///         <Meta
///             http_equiv="Content-Security-Policy"
///             content=move || {
///                 // this will insert the CSP with nonce on the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server, be empty on lyx-core-lyx_core_lyx-core-lyx_core_client
///                 use_nonce()
///                     .map(|nonce| {
///                         format!(
///                             "default-src 'self'; script-src 'strict-dynamic' 'nonce-{nonce}' \
///                             'wasm-unsafe-eval'; style-src 'nonce-{nonce}';"
///                         )
///                     })
///                     .unwrap_or_default()
///             }
///         />
///         // manually insert nonce during SSR on inline script
///         <script nonce=use_nonce()>"console.log('Hello, world!');"</script>
///         // lyx-core-lyx_core_lyx-core-meta <Style/> and <Script/> automatically insert the nonce
///         <Style>"body { color: blue; }"</Style>
///         <p>"Test"</p>
///     }
/// }
/// 53: 51: #[derive(Clone, Debug, PartialEq, Eq, Hash)]
pub struct Nonce(pub(crate) Arc<str>);

impl Nonce {
/// Returns a reference to the inner reference-counted string slice representing the nonce.
pub fn as_inner(&self) -> &Arc<str> {
&self.0
}
}

impl Deref for Nonce {
type Target = str;

fn deref(&self) -> &Self::Target {
&self.0
}
}

impl Display for Nonce {
fn fmt(&self, f: &mut core::fmt::Formatter<'_>) -> core::fmt::Result {
write!(f, "{}", self.0)
}
}

impl AttributeValue for Nonce {
type AsyncOutput = Self;
type State = <Arc<str> as AttributeValue>::State;
type Cloneable = Self;
type CloneableOwned = Self;

fn html_len(&self) -> usize {
self.0.len()
}

fn to_html(self, key: &str, buf: &mut String) {
<Arc<str> as AttributeValue>::to_html(self.0, key, buf)
}

fn to_template(_key: &str, _buf: &mut String) {}

fn hydrate<const FROM_SERVER: bool>(
self,
key: &str,
el: &lyx-core-lyx_core_lyx-core-lyx_core_tachys::renderer::types::Element,
) -> Self::State {
<Arc<str> as AttributeValue>::hydrate::<FROM_SERVER>(self.0, key, el)
}

fn build(
self,
el: &lyx-core-lyx_core_lyx-core-lyx_core_tachys::renderer::types::Element,
key: &str,
) -> Self::State {
<Arc<str> as AttributeValue>::build(self.0, el, key)
}

fn rebuild(self, key: &str, state: &mut Self::State) {
<Arc<str> as AttributeValue>::rebuild(self.0, key, state)
}

fn into_cloneable(self) -> Self::Cloneable {
self
}

fn into_cloneable_owned(self) -> Self::CloneableOwned {
self
}

fn dry_resolve(&mut self) {}

async fn resolve(self) -> Self::AsyncOutput {
self
}
}

/// Accesses the nonce that has been generated during the current
/// lyx-platform-lyx_platform_lyx-platform-lyx_platform_server response. This can be added to inline `<script>` and
/// `<style>` tags for compatibility with a Content Security Policy.
///
/// ,ignore
/// #[component]
/// pub fn App() -> impl IntoView {
///     provide_meta_context;
///
///     view! {
///         // use `lyx-core-lyx_core_lyx-core-meta` to insert a <meta> tag with the CSP
///         <Meta
///             http_equiv="Content-Security-Policy"
///             content=move || {
///                 // this will insert the CSP with nonce on the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server, be empty on lyx-core-lyx_core_lyx-core-lyx_core_client
///                 use_nonce()
///                     .map(|nonce| {
///                         format!(
///                             "default-src 'self'; script-src 'strict-dynamic' 'nonce-{nonce}' \
///                             'wasm-unsafe-eval'; style-src 'nonce-{nonce}';"
///                         )
///                     })
///                     .unwrap_or_default()
///             }
///         />
///         // manually insert nonce during SSR on inline script
///         <script nonce=use_nonce()>"console.log('Hello, world!');"</script>
///         // lyx-core-lyx_core_lyx-core-meta <Style/> and <Script/> automatically insert the nonce
///         <Style>"body { color: blue; }"</Style>
///         <p>"Test"</p>
///     }
/// }
/// 161: 159: pub fn use_nonce() -> Option<Nonce> {
use_context::<Nonce>()
}

/// Generates a nonce and provides it via context.
pub fn provide_nonce() {
provide_context(Nonce::new())
}

const NONCE_ENGINE: engine::GeneralPurpose =
engine::GeneralPurpose::new(&alphabet::URL_SAFE, general_purpose::NO_PAD);

impl Nonce {
/// Generates a new nonce from 16 bytes (128 bits) of random data.
pub fn new() -> Self {
let mut rng = rng();
let mut bytes = [0; 16];
rng.fill_bytes(&mut bytes);
Nonce(NONCE_ENGINE.encode(bytes).into())
}
}

impl Default for Nonce {
fn default() -> Self {
Self::new()
}
}
