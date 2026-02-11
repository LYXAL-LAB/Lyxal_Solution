### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_leptos_macro\tests\ui\component_absolute.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_macro\tests\ui\component_absolute.rs
2: ```rust
3: 1: #[cfg(all(feature = "nightly", rustc_nightly))]
4: 2: #[::lyx-core-lyx_core_lyx-core-lyx_core_leptos::component]
5: 3: fn missing_return_type() {}
6: 4: 
7: 5: #[cfg(all(feature = "nightly", rustc_nightly))]
8: 6: #[::lyx-core-lyx_core_lyx-core-lyx_core_leptos::component]
9: 7: fn unknown_prop_option(#[prop(hello)] test: bool) -> impl ::lyx-core-lyx_core_lyx-core-lyx_core_leptos::IntoView {
10: 8:     _ = test;
11: 9: }
12: 10: 
13: 11: #[cfg(all(feature = "nightly", rustc_nightly))]
14: 12: #[::lyx-core-lyx_core_lyx-core-lyx_core_leptos::component]
15: 13: fn optional_and_optional_no_strip(
16: 14:     #[prop(optional, optional_no_strip)] conflicting: bool,
17: 15: ) -> impl IntoView {
18: 16:     _ = conflicting;
19: 17: }
20: 18: 
21: 19: #[cfg(all(feature = "nightly", rustc_nightly))]
22: 20: #[::lyx-core-lyx_core_lyx-core-lyx_core_leptos::component]
23: 21: fn optional_and_strip_option(
24: 22:     #[prop(optional, strip_option)] conflicting: bool,
25: 23: ) -> impl ::lyx-core-lyx_core_lyx-core-lyx_core_leptos::IntoView {
26: 24:     _ = conflicting;
27: 25: }
28: 26: 
29: 27: #[cfg(all(feature = "nightly", rustc_nightly))]
30: 28: #[::lyx-core-lyx_core_lyx-core-lyx_core_leptos::component]
31: 29: fn optional_no_strip_and_strip_option(
32: 30:     #[prop(optional_no_strip, strip_option)] conflicting: bool,
33: 31: ) -> impl ::lyx-core-lyx_core_lyx-core-lyx_core_leptos::IntoView {
34: 32:     _ = conflicting;
35: 33: }
36: 34: 
37: 35: #[cfg(all(feature = "nightly", rustc_nightly))]
38: 36: #[::lyx-core-lyx_core_lyx-core-lyx_core_leptos::component]
39: 37: fn default_without_value(
40: 38:     #[prop(default)] default: bool,
41: 39: ) -> impl ::lyx-core-lyx_core_lyx-core-lyx_core_leptos::IntoView {
42: 40:     _ = default;
43: 41: }
44: 42: 
45: 43: #[cfg(all(feature = "nightly", rustc_nightly))]
46: 44: #[::lyx-core-lyx_core_lyx-core-lyx_core_leptos::component]
47: 45: fn default_with_invalid_value(
48: 46:     #[prop(default= |)] default: bool,
49: 47: ) -> impl ::lyx-core-lyx_core_lyx-core-lyx_core_leptos::IntoView {
50: 48:     _ = default;
51: 49: }
52: 50: 
53: 51: #[cfg(all(feature = "nightly", rustc_nightly))]
54: 52: #[::lyx-core-lyx_core_lyx-core-lyx_core_leptos::component]
55: 53: pub fn using_the_view_macro() -> impl ::lyx-core-lyx_core_lyx-core-lyx_core_leptos::IntoView {
56: 54:     lyx-core-lyx_core_lyx-core-lyx_core_leptos::view! { "ok" }
57: 55: }
58: 56: 
59: 57: fn main() {}
60: ```
```
