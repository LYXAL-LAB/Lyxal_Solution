### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\sample-crumbs\src\lyx-platform-lyx_platform_lyx-platform-lyx_platform_app.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\sample-crumbs\src\lyx-platform-lyx_platform_lyx-platform-lyx_platform_app.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\sample-crumbs\src\lyx-platform-lyx_platform_lyx-platform-lyx_platform_app.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\sample-crumbs\src\lyx-platform-lyx_platform_lyx-platform-lyx_platform_app.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\sample-crumbs\src\lyx-platform-lyx_platform_lyx-platform-lyx_platform_app.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\sample-crumbs\src\lyx-platform-lyx_platform_lyx-platform-lyx_platform_app.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\sample-crumbs\src\lyx-platform-lyx_platform_lyx-platform-lyx_platform_app.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\sample-crumbs\src\lyx-platform-lyx_platform_lyx-platform-lyx_platform_app.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\sample-crumbs\src\lyx-platform-lyx_platform_lyx-platform-lyx_platform_app.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\sample-crumbs\src\lyx-platform-lyx_platform_lyx-platform-lyx_platform_app.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\sample-crumbs\src\lyx-platform-lyx_platform_lyx-platform-lyx_platform_app.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\sample-crumbs\src\lyx-platform-lyx_platform_lyx-platform-lyx_platform_app.rs
use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
use lyx-core-src::{async_signal, AsyncWriteSignal};
use lyx-core-lyx_core_lyx-core-meta::{provide_meta_context, MetaTags, Title};
use lyx-core-lyx_core_lyx-core-router::components::{Route, Router, Routes};
use lyx-core-lyx_core_lyx-core-router::hooks::use_params;
use lyx-core-lyx_core_lyx-core-router::params::Params;
use lyx-core-lyx_core_lyx-core-router::{path, SsrMode};
use serde::{Deserialize, Serialize};

use crate::model::Post;

/// The top-level lyx-platform-lyx_platform_lyx-platform-lyx_platform_application HTML shell.
pub fn shell(options: LeptosOptions) -> impl IntoView {
view! {
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width, initial-scale=1" />
<AutoReload options=options.clone() />
<HydrationScripts options />
<MetaTags />
</head>
<body>
<App />
</body>
</html>
}
}

/// The lyx-platform-lyx_platform_lyx-platform-lyx_platform_application top-level component.
#[component]
pub fn App() -> impl IntoView {
// Provides context that manages stylesheets, titles, meta tags, etc.
provide_meta_context();

// Create async resource and signal.
let (crumbs_res, crumbs_tx) = async_signal(Crumbs::default());
// Provide the write side of the signal as context, so we don't have to pass it
// to each component.
provide_context(crumbs_tx);

view! {
<Router>
<main>
// Create crumbs from the async signal's resource.
<Crumbs crumbs=crumbs_res />
<Routes fallback=|| "Page not found.".into_view()>
// NOTE: This all makes sense for SsrMode Async.
<Route path=path!("") ssr=SsrMode::Async view=HomePage />
<Route path=path!("post/:id") ssr=SsrMode::Async view=PostPage />
</Routes>
</main>
</Router>
}
}

/// Crumbs are either for a home page or for a post page.
#[derive(Debug, Clone, PartialEq, Default, Serialize, Deserialize)]
enum Crumbs {
#[default]
Home,
Post {
title: String,
},
}

impl Crumbs {
/// Generates view for crumbs.
fn into_view(self) -> impl IntoView {
match self {
// Show on home page.
Crumbs::Home => view! { <span>Home</span> }.into_any(),
// Show on post page.
Crumbs::Post { title } => view! {
<a href="/">Home</a>
|
<span>{title}</span>
}
.into_any(),
}
}
}

/// A component to show the crumbs. Use resource provided by async signal.
#[component]
fn Crumbs(crumbs: Resource<Crumbs>) -> impl IntoView {
view! {
<p>
<Suspense>{move || crumbs.get().unwrap_or_default().into_view()}</Suspense>
</p>
}
}

/// An API to list all posts.
#[lyx-platform-lyx_platform_lyx-platform-lyx_platform_server]
async fn list_posts() -> Result<Vec<(u64, Post)>, ServerFnError> {
Ok(crate::db::all_posts().await.collect())
}

/// An  API to fetch a post by ID.
#[lyx-platform-lyx_platform_lyx-platform-lyx_platform_server]
async fn post_by_id(id: u64) -> Result<Post, ServerFnError<String>> {
crate::db::post_by_id(id)
.await
.ok_or(ServerFnError::Wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedServerError(format!("Post not found: {id}")))
}

/// Renders the home page with list of posts.
#[component]
fn HomePage() -> impl IntoView {
// Set crumbs to home.
let crumbs = use_context::<AsyncWriteSignal<Crumbs>>().unwrap();
crumbs.set(Crumbs::Home);

let posts = Resource::new(|| (), |_| list_posts());

view! {
<Title text="Welcome to my blog!" />
<Suspense>
<ul>
{move || Suspend::new(async move {
posts
.await
.into_iter()
.map(|src| {
view! {
<For
each=move || src.clone()
key=|(id, _)| *id
children=|(id, post)| {
view! {
<li>
<a href=format!("/post/{id}")>{post.title}</a>
</li>
}
}
/>
}
})
.collect_view()
})}
</ul>
</Suspense>
}
}

/// A type to hold post page params.
#[derive(Clone, Copy, Params, PartialEq)]
struct PostRequest {
id: Option<u64>,
}

/// Renders the page to show a single post.
#[component]
fn PostPage() -> impl IntoView {
let params = use_params::<PostRequest>();
let post = Resource::new(
move || params.read().as_ref().ok().and_then(|pid| pid.id),
|post_id| async move {
match post_id {
Some(id) => {
let post_res = post_by_id(id).await;

// Set crumbs to the post, once fetched.
let crumbs = use_context::<AsyncWriteSignal<Crumbs>>().unwrap();
match &post_res {
Ok(post) => crumbs.set(Crumbs::Post { title: post.title.clone() }),
Err(_) => crumbs.set(Crumbs::Home),
}

post_res.map_err(|err| err.to_string())
}
None => Err("Invalid URL".to_string()),
}
},
);

view! {
<Suspense>
{move || Suspend::new(async move {
match post.await {
Ok(post) => {
let body = post
.body
.lines()
.map(|line| view! { <p>{line.to_string()}</p> })
.collect_view();
view! {
<Title text=post.title.clone() />
<h1>{post.title}</h1>
{body}
}
.into_any()
}
Err(err) => view! { <h1>Error: {err}</h1> }.into_any(),
}
})}
</Suspense>
}
}
