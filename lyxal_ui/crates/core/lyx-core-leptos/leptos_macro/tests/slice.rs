### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_leptos_macro\tests\slice.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_macro\tests\slice.rs
2: ```rust
3: 1: use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::RwSignal;
4: 2: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_macro::slice;
5: 3: 
6: 4: #[derive(Default)]
7: 5: pub struct OuterState {
8: 6:     count: i32,
9: 7:     inner: InnerState,
10: 8: }
11: 9: 
12: 10: #[derive(Clone, PartialEq, Default)]
13: 11: pub struct InnerState {
14: 12:     inner_count: i32,
15: 13:     inner_tuple: InnerTuple,
16: 14: }
17: 15: 
18: 16: #[derive(Clone, PartialEq, Default)]
19: 17: pub struct InnerTuple(String);
20: 18: 
21: 19: #[test]
22: 20: fn green() {
23: 21:     let outer_signal = RwSignal::new(OuterState::default());
24: 22: 
25: 23:     let (_, _) = slice!(outer_signal.count);
26: 24: 
27: 25:     let (_, _) = slice!(outer_signal.inner.inner_count);
28: 26:     let (_, _) = slice!(outer_signal.inner.inner_tuple.0);
29: 27: }
30: 28: 
31: 29: #[test]
32: 30: fn red() {
33: 31:     let t = trybuild::TestCases::new();
34: 32:     t.compile_fail("tests/slice/red.rs")
35: 33: }
36: ```
```
