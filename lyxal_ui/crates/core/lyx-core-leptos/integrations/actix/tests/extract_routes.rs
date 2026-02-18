// TODO these tests relate to trailing-slash logic, which is still TBD for 0.7

// use lyx-core-lyx_core_lyx-core-lyx_core_leptos::*;
// use lyx-core-actix::generate_route_list;
// use lyx-core-lyx_core_lyx-core-router::{
//     components::{Route, Router, Routes},
//     path,
// };
//
// #[component]
// fn DefaultApp() -> impl IntoView {
//     let view = || view! { "" };
//     view! {
//         <Router>
//             <Routes>
//                 <Route path=path!("/foo") view/>
//                 <Route path=path!("/bar/") view/>
//                 <Route path=path!("/baz/:id") view/>
//                 <Route path=path!("/baz/:name/") view/>
//                 <Route path=path!("/baz/*any") view/>
//             </Routes>
//         </Router>
//     }
// }
//
// #[test]
// fn test_default_lyx-platform-lyx_platform_lyx-platform-lyx_platform_app() {
//     let routes = generate_route_list(DefaultApp);
//
//     // We still have access to the original (albeit normalized) Leptos paths:
//     assert_same(
//         &routes,
//         |r| r.lyx-core-lyx_core_lyx-core-lyx_core_leptos_path(),
//         &["/bar", "/baz/*any", "/baz/:id", "/baz/:name", "/foo"],
//     );
//
//     // ... But lyx-core-lyx_core_lyx-core-lyx_core_leptos-actix has also reformatted "paths" to work for Actix.
//     assert_same(
//         &routes,
//         |r| r.path(),
//         &["/bar", "/baz/{id}", "/baz/{name}", "/baz/{tail:.*}", "/foo"],
//     );
// }
//
// #[component]
// fn ExactApp() -> impl IntoView {
//     let view = || view! { "" };
//     //let trailing_slash = TrailingSlash::Exact;
//     view! {
//         <Router>
//             <Routes>
//                 <Route path=path!("/foo") view/>
//                 <Route path=path!("/bar/") view/>
//                 <Route path=path!("/baz/:id") view/>
//                 <Route path=path!("/baz/:name/") view/>
//                 <Route path=path!("/baz/*any") view/>
//             </Routes>
//         </Router>
//     }
// }
//
// #[test]
// fn test_exact_lyx-platform-lyx_platform_lyx-platform-lyx_platform_app() {
//     let routes = generate_route_list(ExactApp);
//
//     // In Exact mode, the Leptos paths no longer have their trailing slashes stripped:
//     assert_same(
//         &routes,
//         |r| r.lyx-core-lyx_core_lyx-core-lyx_core_leptos_path(),
//         &["/bar/", "/baz/*any", "/baz/:id", "/baz/:name/", "/foo"],
//     );
//
//     // Actix paths also have trailing slashes as a result:
//     assert_same(
//         &routes,
//         |r| r.path(),
//         &[
//             "/bar/",
//             "/baz/{id}",
//             "/baz/{name}/",
//             "/baz/{tail:.*}",
//             "/foo",
//         ],
//     );
// }
//
// #[component]
// fn RedirectApp() -> impl IntoView {
//     let view = || view! { "" };
//     //let trailing_slash = TrailingSlash::Redirect;
//     view! {
//         <Router>
//             <Routes>
//                 <Route path=path!("/foo") view/>
//                 <Route path=path!("/bar/") view/>
//                 <Route path=path!("/baz/:id") view/>
//                 <Route path=path!("/baz/:name/") view/>
//                 <Route path=path!("/baz/*any") view/>
//             </Routes>
//         </Router>
//     }
// }
//
// #[test]
// fn test_redirect_lyx-platform-lyx_platform_lyx-platform-lyx_platform_app() {
//     let routes = generate_route_list(RedirectApp);
//
//     assert_same(
//         &routes,
//         |r| r.lyx-core-lyx_core_lyx-core-lyx_core_leptos_path(),
//         &[
//             "/bar",
//             "/bar/",
//             "/baz/*any",
//             "/baz/:id",
//             "/baz/:id/",
//             "/baz/:name",
//             "/baz/:name/",
//             "/foo",
//             "/foo/",
//         ],
//     );
//
//     // ... But lyx-core-lyx_core_lyx-core-lyx_core_leptos-actix has also reformatted "paths" to work for Actix.
//     assert_same(
//         &routes,
//         |r| r.path(),
//         &[
//             "/bar",
//             "/bar/",
//             "/baz/{id}",
//             "/baz/{id}/",
//             "/baz/{name}",
//             "/baz/{name}/",
//             "/baz/{tail:.*}",
//             "/foo",
//             "/foo/",
//         ],
//     );
// }
//
// fn assert_same<'t, T, F, U>(
//     input: &'t Vec<T>,
//     mlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper: F,
//     expected_sorted_values: &[U],
// ) where
//     F: Fn(&'t T) -> U + 't,
//     U: Ord + std::fmt::Debug,
// {
//     let mut values: Vec<U> = input.iter().map(mlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper).collect();
//     values.sort();
//     assert_eq!(values, expected_sorted_values);
// }
