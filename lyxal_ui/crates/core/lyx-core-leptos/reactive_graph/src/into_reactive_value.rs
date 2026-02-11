### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_reactive_graph\src\into_reactive_value.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\src\into_reactive_value.rs
2: ```rust
3: 1: #[doc(hidden)]
4: 2: pub struct __IntoReactiveValueMarkerBaseCase;
5: 3: 
6: 4: /// A helper trait that works like `Into<T>` but uses a marker generic
7: 5: /// to allow more `From` implementations than would be allowed with just `Into<T>`.
8: 6: pub trait IntoReactiveValue<T, M> {
9: 7:     /// Converts `self` into a `T`.
10: 8:     fn into_reactive_value(self) -> T;
11: 9: }
12: 10: 
13: 11: // The base case, which allows anything which implements .into() to work:
14: 12: impl<T, I> IntoReactiveValue<T, __IntoReactiveValueMarkerBaseCase> for I
15: 13: where
16: 14:     I: Into<T>,
17: 15: {
18: 16:     fn into_reactive_value(self) -> T {
19: 17:         self.into()
20: 18:     }
21: 19: }
22: 20: 
23: 21: #[cfg(test)]
24: 22: mod tests {
25: 23: 
26: 24:     use crate::{
27: 25:         into_reactive_value::IntoReactiveValue,
28: 26:         owner::{LocalStorage, Owner},
29: 27:         traits::GetUntracked,
30: 28:         wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_appers::read::Signal,
31: 29:     };
32: 30:     use typed_builder::TypedBuilder;
33: 31: 
34: 32:     #[test]
35: 33:     fn test_into_signal_compiles() {
36: 34:         let owner = Owner::new();
37: 35:         owner.set();
38: 36: 
39: 37:         #[cfg(not(feature = "nightly"))]
40: 38:         let _: Signal<usize> = (|| 2).into_reactive_value();
41: 39:         let _: Signal<usize, LocalStorage> = 2.into_reactive_value();
42: 40:         #[cfg(not(feature = "nightly"))]
43: 41:         let _: Signal<usize, LocalStorage> = (|| 2).into_reactive_value();
44: 42:         let _: Signal<String> = "str".into_reactive_value();
45: 43:         let _: Signal<String, LocalStorage> = "str".into_reactive_value();
46: 44: 
47: 45:         #[derive(TypedBuilder)]
48: 46:         struct Foo {
49: 47:             #[builder(setter(
50: 48:                 fn transform<M>(value: impl IntoReactiveValue<Signal<usize>, M>) {
51: 49:                     value.into_reactive_value()
52: 50:                 }
53: 51:             ))]
54: 52:             sig: Signal<usize>,
55: 53:         }
56: 54: 
57: 55:         assert_eq!(Foo::builder().sig(2).build().sig.get_untracked(), 2);
58: 56:         #[cfg(not(feature = "nightly"))]
59: 57:         assert_eq!(Foo::builder().sig(|| 2).build().sig.get_untracked(), 2);
60: 58:         assert_eq!(
61: 59:             Foo::builder()
62: 60:                 .sig(Signal::stored(2))
63: 61:                 .build()
64: 62:                 .sig
65: 63:                 .get_untracked(),
66: 64:             2
67: 65:         );
68: 66:     }
69: 67: }
70: ```
```
