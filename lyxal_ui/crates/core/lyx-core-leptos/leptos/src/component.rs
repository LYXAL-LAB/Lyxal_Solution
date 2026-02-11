### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_leptos\src\component.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\component.rs
2: ```rust
3: 1: //! Utility traits and functions that allow building components,
4: 2: //! as either functions of their props or functions with no arguments,
5: 3: //! without knowing the name of the props struct.
6: 4: 
7: 5: pub trait Component<P> {}
8: 6: 
9: 7: pub trait Props {
10: 8:     type Builder;
11: 9: 
12: 10:     fn builder() -> Self::Builder;
13: 11: }
14: 12: 
15: 13: #[doc(hidden)]
16: 14: pub trait PropsOrNoPropsBuilder {
17: 15:     type Builder;
18: 16: 
19: 17:     fn builder_or_not() -> Self::Builder;
20: 18: }
21: 19: 
22: 20: #[doc(hidden)]
23: 21: #[derive(Copy, Clone, Debug, Default)]
24: 22: pub struct EmptyPropsBuilder {}
25: 23: 
26: 24: impl EmptyPropsBuilder {
27: 25:     pub fn build(self) {}
28: 26: }
29: 27: 
30: 28: impl<P: Props> PropsOrNoPropsBuilder for P {
31: 29:     type Builder = <P as Props>::Builder;
32: 30: 
33: 31:     fn builder_or_not() -> Self::Builder {
34: 32:         Self::builder()
35: 33:     }
36: 34: }
37: 35: 
38: 36: impl PropsOrNoPropsBuilder for EmptyPropsBuilder {
39: 37:     type Builder = EmptyPropsBuilder;
40: 38: 
41: 39:     fn builder_or_not() -> Self::Builder {
42: 40:         EmptyPropsBuilder {}
43: 41:     }
44: 42: }
45: 43: 
46: 44: impl<F, R> Component<EmptyPropsBuilder> for F where F: FnOnce() -> R {}
47: 45: 
48: 46: impl<P, F, R> Component<P> for F
49: 47: where
50: 48:     F: FnOnce(P) -> R,
51: 49:     P: Props,
52: 50: {
53: 51: }
54: 52: 
55: 53: pub fn component_props_builder<P: PropsOrNoPropsBuilder>(
56: 54:     _f: &impl Component<P>,
57: 55: ) -> <P as PropsOrNoPropsBuilder>::Builder {
58: 56:     <P as PropsOrNoPropsBuilder>::builder_or_not()
59: 57: }
60: 58: 
61: 59: pub fn component_view<P, T>(f: impl ComponentConstructor<P, T>, props: P) -> T {
62: 60:     f.construct(props)
63: 61: }
64: 62: pub trait ComponentConstructor<P, T> {
65: 63:     fn construct(self, props: P) -> T;
66: 64: }
67: 65: 
68: 66: impl<Func, T> ComponentConstructor<(), T> for Func
69: 67: where
70: 68:     Func: FnOnce() -> T,
71: 69: {
72: 70:     fn construct(self, (): ()) -> T {
73: 71:         (self)()
74: 72:     }
75: 73: }
76: 74: 
77: 75: impl<Func, T, P> ComponentConstructor<P, T> for Func
78: 76: where
79: 77:     Func: FnOnce(P) -> T,
80: 78:     P: PropsOrNoPropsBuilder,
81: 79: {
82: 80:     fn construct(self, props: P) -> T {
83: 81:         (self)(props)
84: 82:     }
85: 83: }
86: ```
```
