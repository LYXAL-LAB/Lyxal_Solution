### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_tachys\src\view\add_attr.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\add_attr.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\add_attr.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\add_attr.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\add_attr.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\add_attr.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\add_attr.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\add_attr.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\add_attr.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\add_attr.rs
18: 16: ```rust
19: 17: use super::RenderHtml;
20: 18: use crate::html::attribute::Attribute;
21: 19: 
22: 20: /// Allows adding a new attribute to some type, before it is rendered.
23: 21: /// This takes place at compile time as part of the builder syntax for creating a statically typed
24: 22: /// view tree.
25: 23: ///
26: 24: /// Normally, this is used to add an attribute to an HTML element. But it is required to be
27: 25: /// implemented for all types that implement [`RenderHtml`], so that attributes can be spread onto
28: 26: /// other structures like the return type of a component.
29: 27: pub trait AddAnyAttr {
30: 28:     /// The new type once the attribute has been added.
31: 29:     type Output<SomeNewAttr: Attribute>: RenderHtml;
32: 30: 
33: 31:     /// Adds an attribute to the view.
34: 32:     fn add_any_attr<NewAttr: Attribute>(
35: 33:         self,
36: 34:         attr: NewAttr,
37: 35:     ) -> Self::Output<NewAttr>
38: 36:     where
39: 37:         Self::Output<NewAttr>: RenderHtml;
40: 38: }
41: 39: 
42: 40: /// Declares that spreading attributes onto a particular type has no effect.
43: 41: #[macro_export]
44: 42: macro_rules! no_attrs {
45: 43:     ($ty_name:ty) => {
46: 44:         impl<'a> $crate::view::add_attr::AddAnyAttr for $ty_name {
47: 45:             type Output<SomeNewAttr: $crate::html::attribute::Attribute> =
48: 46:                 $ty_name;
49: 47: 
50: 48:             fn add_any_attr<NewAttr: $crate::html::attribute::Attribute>(
51: 49:                 self,
52: 50:                 _attr: NewAttr,
53: 51:             ) -> Self::Output<NewAttr> {
54: 52:                 self
55: 53:             }
56: 54:         }
57: 55:     };
58: 56: }
59: 57: ```
60: 58: ```
61: 59: ```
62: 60: ```
63: 61: ```
64: 62: ```
65: 63: ```
66: 64: ```
67: ```
```
