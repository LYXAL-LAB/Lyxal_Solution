### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_reactive_graph\src\effect\effect_function.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\src\effect\effect_function.rs
2: ```rust
3: 1: /// Trait to enable effect functions that have zero or one parameter
4: 2: pub trait EffectFunction<T, M> {
5: 3:     /// Call this to execute the function. In case the actual function has no parameters
6: 4:     /// the parameter `p` will simply be ignored.
7: 5:     fn run(&mut self, p: Option<T>) -> T;
8: 6: }
9: 7: 
10: 8: /// Marker for single parameter functions
11: 9: pub struct SingleParam;
12: 10: /// Marker for no parameter functions
13: 11: pub struct NoParam;
14: 12: 
15: 13: impl<Func, T> EffectFunction<T, SingleParam> for Func
16: 14: where
17: 15:     Func: FnMut(Option<T>) -> T,
18: 16: {
19: 17:     #[inline(always)]
20: 18:     fn run(&mut self, p: Option<T>) -> T {
21: 19:         (self)(p)
22: 20:     }
23: 21: }
24: 22: 
25: 23: impl<Func> EffectFunction<(), NoParam> for Func
26: 24: where
27: 25:     Func: FnMut(),
28: 26: {
29: 27:     #[inline(always)]
30: 28:     fn run(&mut self, _: Option<()>) {
31: 29:         self()
32: 30:     }
33: 31: }
34: ```
```
