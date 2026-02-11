### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\integrations\actix\tests\extract_routes.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\integrations\actix\tests\extract_routes.rs
2: ```rust
3: 1: // TODO these tests relate to trailing-slash logic, which is still TBD for 0.7
4: 2: 
5: 3: // use lyx-core-lyx_core_lyx-core-lyx_core_leptos::*;
6: 4: // use lyx-core-actix::generate_route_list;
7: 5: // use lyx-core-lyx_core_lyx-core-router::{
8: 6: //     components::{Route, Router, Routes},
9: 7: //     path,
10: 8: // };
11: 9: //
12: 10: // #[component]
13: 11: // fn DefaultApp() -> impl IntoView {
14: 12: //     let view = || view! { "" };
15: 13: //     view! {
16: 14: //         <Router>
17: 15: //             <Routes>
18: 16: //                 <Route path=path!("/foo") view/>
19: 17: //                 <Route path=path!("/bar/") view/>
20: 18: //                 <Route path=path!("/baz/:id") view/>
21: 19: //                 <Route path=path!("/baz/:name/") view/>
22: 20: //                 <Route path=path!("/baz/*any") view/>
23: 21: //             </Routes>
24: 22: //         </Router>
25: 23: //     }
26: 24: // }
27: 25: //
28: 26: // #[test]
29: 27: // fn test_default_lyx-platform-lyx_platform_lyx-platform-lyx_platform_app() {
30: 28: //     let routes = generate_route_list(DefaultApp);
31: 29: //
32: 30: //     // We still have access to the original (albeit normalized) Leptos paths:
33: 31: //     assert_same(
34: 32: //         &routes,
35: 33: //         |r| r.lyx-core-lyx_core_lyx-core-lyx_core_leptos_path(),
36: 34: //         &["/bar", "/baz/*any", "/baz/:id", "/baz/:name", "/foo"],
37: 35: //     );
38: 36: //
39: 37: //     // ... But lyx-core-lyx_core_lyx-core-lyx_core_leptos-actix has also reformatted "paths" to work for Actix.
40: 38: //     assert_same(
41: 39: //         &routes,
42: 40: //         |r| r.path(),
43: 41: //         &["/bar", "/baz/{id}", "/baz/{name}", "/baz/{tail:.*}", "/foo"],
44: 42: //     );
45: 43: // }
46: 44: //
47: 45: // #[component]
48: 46: // fn ExactApp() -> impl IntoView {
49: 47: //     let view = || view! { "" };
50: 48: //     //let trailing_slash = TrailingSlash::Exact;
51: 49: //     view! {
52: 50: //         <Router>
53: 51: //             <Routes>
54: 52: //                 <Route path=path!("/foo") view/>
55: 53: //                 <Route path=path!("/bar/") view/>
56: 54: //                 <Route path=path!("/baz/:id") view/>
57: 55: //                 <Route path=path!("/baz/:name/") view/>
58: 56: //                 <Route path=path!("/baz/*any") view/>
59: 57: //             </Routes>
60: 58: //         </Router>
61: 59: //     }
62: 60: // }
63: 61: //
64: 62: // #[test]
65: 63: // fn test_exact_lyx-platform-lyx_platform_lyx-platform-lyx_platform_app() {
66: 64: //     let routes = generate_route_list(ExactApp);
67: 65: //
68: 66: //     // In Exact mode, the Leptos paths no longer have their trailing slashes stripped:
69: 67: //     assert_same(
70: 68: //         &routes,
71: 69: //         |r| r.lyx-core-lyx_core_lyx-core-lyx_core_leptos_path(),
72: 70: //         &["/bar/", "/baz/*any", "/baz/:id", "/baz/:name/", "/foo"],
73: 71: //     );
74: 72: //
75: 73: //     // Actix paths also have trailing slashes as a result:
76: 74: //     assert_same(
77: 75: //         &routes,
78: 76: //         |r| r.path(),
79: 77: //         &[
80: 78: //             "/bar/",
81: 79: //             "/baz/{id}",
82: 80: //             "/baz/{name}/",
83: 81: //             "/baz/{tail:.*}",
84: 82: //             "/foo",
85: 83: //         ],
86: 84: //     );
87: 85: // }
88: 86: //
89: 87: // #[component]
90: 88: // fn RedirectApp() -> impl IntoView {
91: 89: //     let view = || view! { "" };
92: 90: //     //let trailing_slash = TrailingSlash::Redirect;
93: 91: //     view! {
94: 92: //         <Router>
95: 93: //             <Routes>
96: 94: //                 <Route path=path!("/foo") view/>
97: 95: //                 <Route path=path!("/bar/") view/>
98: 96: //                 <Route path=path!("/baz/:id") view/>
99: 97: //                 <Route path=path!("/baz/:name/") view/>
100: 98: //                 <Route path=path!("/baz/*any") view/>
101: 99: //             </Routes>
102: 100: //         </Router>
103: 101: //     }
104: 102: // }
105: 103: //
106: 104: // #[test]
107: 105: // fn test_redirect_lyx-platform-lyx_platform_lyx-platform-lyx_platform_app() {
108: 106: //     let routes = generate_route_list(RedirectApp);
109: 107: //
110: 108: //     assert_same(
111: 109: //         &routes,
112: 110: //         |r| r.lyx-core-lyx_core_lyx-core-lyx_core_leptos_path(),
113: 111: //         &[
114: 112: //             "/bar",
115: 113: //             "/bar/",
116: 114: //             "/baz/*any",
117: 115: //             "/baz/:id",
118: 116: //             "/baz/:id/",
119: 117: //             "/baz/:name",
120: 118: //             "/baz/:name/",
121: 119: //             "/foo",
122: 120: //             "/foo/",
123: 121: //         ],
124: 122: //     );
125: 123: //
126: 124: //     // ... But lyx-core-lyx_core_lyx-core-lyx_core_leptos-actix has also reformatted "paths" to work for Actix.
127: 125: //     assert_same(
128: 126: //         &routes,
129: 127: //         |r| r.path(),
130: 128: //         &[
131: 129: //             "/bar",
132: 130: //             "/bar/",
133: 131: //             "/baz/{id}",
134: 132: //             "/baz/{id}/",
135: 133: //             "/baz/{name}",
136: 134: //             "/baz/{name}/",
137: 135: //             "/baz/{tail:.*}",
138: 136: //             "/foo",
139: 137: //             "/foo/",
140: 138: //         ],
141: 139: //     );
142: 140: // }
143: 141: //
144: 142: // fn assert_same<'t, T, F, U>(
145: 143: //     input: &'t Vec<T>,
146: 144: //     mlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper: F,
147: 145: //     expected_sorted_values: &[U],
148: 146: // ) where
149: 147: //     F: Fn(&'t T) -> U + 't,
150: 148: //     U: Ord + std::fmt::Debug,
151: 149: // {
152: 150: //     let mut values: Vec<U> = input.iter().map(mlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper).collect();
153: 151: //     values.sort();
154: 152: //     assert_eq!(values, expected_sorted_values);
155: 153: // }
156: ```
```
