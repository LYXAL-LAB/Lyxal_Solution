### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_reactive_graph\src\effect.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\src\effect.rs
2: ```rust
3: 1: //! Side effects that run in response to changes in the reactive values they read from.
4: 2: 
5: 3: #[allow(clippy::module_inception)]
6: 4: mod effect;
7: 5: mod effect_function;
8: 6: mod immediate;
9: 7: mod inner;
10: 8: mod render_effect;
11: 9: 
12: 10: pub use effect::*;
13: 11: pub use effect_function::*;
14: 12: pub use immediate::*;
15: 13: pub use render_effect::*;
16: 14: 
17: 15: /// Creates a new render effect, which immediately runs `fun`.
18: 16: #[inline(always)]
19: 17: #[track_caller]
20: 18: #[deprecated = "This function is being removed to conform to Rust idioms. \
21: 19:                 Please use `RenderEffect::new()` instead."]
22: 20: pub fn create_render_effect<T>(
23: 21:     fun: impl FnMut(Option<T>) -> T + 'static,
24: 22: ) -> RenderEffect<T>
25: 23: where
26: 24:     T: 'static,
27: 25: {
28: 26:     RenderEffect::new(fun)
29: 27: }
30: ```
```
