use crate::{prelude::Suspend, suspense_component::Suspense, IntoView};
use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_macro::{component, view};
use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_lyx-platform-lyx_platform_lyx-platform-lyx_platform_server::ArcOnceResource;
use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::prelude::ReadUntracked;
use serde::{de::DeserializeOwned, Serialize};

#[component]
/// Allows you to inline the data loading for an `async` block or
/// lyx-platform-lyx_platform_lyx-platform-lyx_platform_server function directly into your view. This is the equivalent of combining a
/// [`create_resource`] that only loads once (i.e., with a source signal `|| ()`) with
/// a [`Suspense`] with no `fallback`.
///
/// Adding `let:{variable name}` to the props makes the data available in the children
/// that variable name, when resolved.
/// 18: 16: /// # use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
/// # if false {
/// async fn fetch_monkeys(monkey: i32) -> i32 {
///     // do some expensive work
///     3
/// }
///
/// view! {
///     <Await
///         future=fetch_monkeys(3)
///         let:data
///     >
///         <p>{*data} " little monkeys, jumping on the bed."</p>
///     </Await>
/// }
/// # ;
/// # }
/// 36: 34: pub fn Await<T, Fut, Chil, V>(
/// A [`Future`](std::future::Future) that will the component will `.await`
/// before rendering.
future: Fut,
/// If `true`, the component will create a blocking resource, preventing
/// the HTML stream from returning anything before `future` has resolved.
#[prop(optional)]
blocking: bool,
/// A function that takes a reference to the resolved data from the `future`
/// renders a view.
///
/// ## Syntax
/// This can be passed in the `view` children of the `<Await/>` by using the
/// `let:` syntax to specify the name for the data variable.
///
/// 52: 50:     /// # use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
/// # if false {
/// # async fn fetch_monkeys(monkey: i32) -> i32 {
/// #    3
/// # }
/// view! {
///     <Await
///         future=fetch_monkeys(3)
///         let:data
///     >
///         <p>{*data} " little monkeys, jumping on the bed."</p>
///     </Await>
/// }
/// # ;
/// # }
/// 68: 66:     /// is the same as
///  70: 68:     /// # use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
/// # if false {
/// # async fn fetch_monkeys(monkey: i32) -> i32 {
/// #    3
/// # }
/// view! {
///     <Await
///         future=fetch_monkeys(3)
///         children=|data| view! {
///           <p>{*data} " little monkeys, jumping on the bed."</p>
///         }
///     />
/// }
/// # ;
/// # }
/// 86: 84:     children: Chil,
) -> impl IntoView
where
T: Send + Sync + Serialize + DeserializeOwned + 'static,
Fut: std::future::Future<Output = T> + Send + 'static,
Chil: FnOnce(&T) -> V + Send + 'static,
V: IntoView + 'static,
{
let res = ArcOnceResource::<T>::new_with_options(future, blocking);
let ready = res.ready();

view! {
<Suspense fallback=|| ()>
{Suspend::new(async move {
ready.await;
children(res.read_untracked().as_ref().unwrap())
})}

</Suspense>
}
}
