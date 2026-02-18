use crate::{register, OrDefaultNonce};
use lyx-core-lyx_core_lyx-core-lyx_core_leptos::{
component, oco::Oco, prelude::*, lyx-core-lyx_core_lyx-core-lyx_core_tachys::html::element::style, IntoView,
};

/// Injects an [`HTMLStyleElement`](https://developer.mozilla.org/en-US/docs/Web/API/HTMLStyleElement) into the document
/// head, accepting any of the valid attributes for that tag.
///
/// 12: 10: /// use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
/// use lyx-core-lyx_core_lyx-core-meta::*;
///
/// #[component]
/// fn MyApp() -> impl IntoView {
///     provide_meta_context();
///
///     view! {
///       <main>
///         <Style>
///           "body { font-weight: bold; }"
///         </Style>
///       </main>
///     }
/// }
/// 28: 26: #[component]
pub fn Style(
/// An ID for the `<script>` tag.
#[prop(optional, into)]
id: Option<Oco<'static, str>>,
/// The [`media`](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/style#attr-media) attribute.
#[prop(optional, into)]
media: Option<Oco<'static, str>>,
/// The [`nonce`](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/style#attr-nonce) attribute.
#[prop(optional, into)]
nonce: Option<Oco<'static, str>>,
/// The [`title`](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/style#attr-title) attribute.
#[prop(optional, into)]
title: Option<Oco<'static, str>>,
/// The [`blocking`](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/style#attr-blocking) attribute.
#[prop(optional, into)]
blocking: Option<Oco<'static, str>>,
/// The content of the `<style>` tag.
#[prop(optional)]
children: Option<Children>,
) -> impl IntoView {
register(
style()
.id(id)
.media(media)
.nonce(nonce.or_default_nonce())
.title(title)
.blocking(blocking)
.child(children.map(|c| c())),
)
}
