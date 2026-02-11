### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_tachys\src\html\attribute\maybe_next_attr_erasure_macros.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\attribute\maybe_next_attr_erasure_macros.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\attribute\maybe_next_attr_erasure_macros.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\attribute\maybe_next_attr_erasure_macros.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\attribute\maybe_next_attr_erasure_macros.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\attribute\maybe_next_attr_erasure_macros.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\attribute\maybe_next_attr_erasure_macros.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\attribute\maybe_next_attr_erasure_macros.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\attribute\maybe_next_attr_erasure_macros.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\attribute\maybe_next_attr_erasure_macros.rs
18: 16: ```rust
19: 17: macro_rules! next_attr_output_type {
20: 18:     ($current:ty, $next:ty) => {
21: 19:         #[cfg(not(erase_components))]
22: 20:         type Output<NewAttr: Attribute> = ($current, $next);
23: 21: 
24: 22:         #[cfg(erase_components)]
25: 23:         type Output<NewAttr: Attribute> =
26: 24:             Vec<$crate::html::attribute::any_attribute::AnyAttribute>;
27: 25:     };
28: 26: }
29: 27: 
30: 28: macro_rules! next_attr_combine {
31: 29:     ($self:expr, $next_attr:expr) => {{
32: 30:         #[cfg(not(erase_components))]
33: 31:         {
34: 32:             ($self, $next_attr)
35: 33:         }
36: 34:         #[cfg(erase_components)]
37: 35:         {
38: 36:             use $crate::html::attribute::any_attribute::IntoAnyAttribute;
39: 37:             vec![$self.into_any_attr(), $next_attr.into_any_attr()]
40: 38:         }
41: 39:     }};
42: 40: }
43: 41: 
44: 42: pub(crate) use next_attr_combine;
45: 43: pub(crate) use next_attr_output_type;
46: 44: ```
47: 45: ```
48: 46: ```
49: 47: ```
50: 48: ```
51: 49: ```
52: 50: ```
53: 51: ```
54: ```
```
