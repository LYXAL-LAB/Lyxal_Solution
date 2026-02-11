### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_tachys\src\html\element\element_ext.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\element\element_ext.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\element\element_ext.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\element\element_ext.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\element\element_ext.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\element\element_ext.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\element\element_ext.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\element\element_ext.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\element\element_ext.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\element\element_ext.rs
18: 16: ```rust
19: 17: use crate::{
20: 18:     html::{
21: 19:         attribute::Attribute,
22: 20:         class::IntoClass,
23: 21:         event::{on, EventDescriptor},
24: 22:         style::IntoStyle,
25: 23:     },
26: 24:     renderer::RemoveEventHandler,
27: 25: };
28: 26: use wasm_bindgen::JsValue;
29: 27: use web_sys::Element;
30: 28: 
31: 29: /// Extends an HTML element, allowing you to add attributes and children to the
32: 30: /// element's built state at runtime, with a similar API to how they
33: 31: /// can be added to the static view tree at compile time.
34: 32: ///
35: 33: /// ```rust,ignore
36: 34: /// use lyx-core-lyx_core_lyx-core-lyx_core_tachys::html::element::ElementExt;
37: 35: ///
38: 36: /// let view: HtmlElement<_, _, _, MockDom> = button();
39: 37: ///
40: 38: /// // add an event listener as part of the static type
41: 39: /// // this will be lazily added when the element is built
42: 40: /// let view = element.on(ev::click, move |_| /* ... */);
43: 41: ///
44: 42: /// // `element` now contains the actual element
45: 43: /// let element = element.build();
46: 44: /// let remove = element.on(ev::blur, move |_| /* ... */);
47: 45: /// ```
48: 46: pub trait ElementExt {
49: 47:     /// Adds an attribute to the element, at runtime.
50: 48:     fn attr<At>(&self, attribute: At) -> At::State
51: 49:     where
52: 50:         At: Attribute;
53: 51: 
54: 52:     /// Adds a class to the element, at runtime.
55: 53:     fn class<C>(&self, class: C) -> C::State
56: 54:     where
57: 55:         C: IntoClass;
58: 56: 
59: 57:     /// Adds a style to the element, at runtime.
60: 58:     fn style<S>(&self, style: S) -> S::State
61: 59:     where
62: 60:         S: IntoStyle;
63: 61: 
64: 62:     /// Adds an event listener to the element, at runtime.
65: 63:     fn on<E>(
66: 64:         &self,
67: 65:         ev: E,
68: 66:         cb: impl FnMut(E::EventType) + 'static,
69: 67:     ) -> RemoveEventHandler<Element>
70: 68:     where
71: 69:         E: EventDescriptor + Send + 'static,
72: 70:         E::EventType: 'static,
73: 71:         E::EventType: From<JsValue>;
74: 72: }
75: 73: 
76: 74: impl<T> ElementExt for T
77: 75: where
78: 76:     T: AsRef<Element>,
79: 77: {
80: 78:     fn attr<At>(&self, attribute: At) -> At::State
81: 79:     where
82: 80:         At: Attribute,
83: 81:     {
84: 82:         attribute.build(self.as_ref())
85: 83:     }
86: 84: 
87: 85:     fn class<C>(&self, class: C) -> C::State
88: 86:     where
89: 87:         C: IntoClass,
90: 88:     {
91: 89:         class.build(self.as_ref())
92: 90:     }
93: 91: 
94: 92:     fn on<E>(
95: 93:         &self,
96: 94:         ev: E,
97: 95:         cb: impl FnMut(E::EventType) + 'static,
98: 96:     ) -> RemoveEventHandler<Element>
99: 97:     where
100: 98:         E: EventDescriptor + Send + 'static,
101: 99:         E::EventType: 'static,
102: 100:         E::EventType: From<JsValue>,
103: 101:     {
104: 102:         on::<E, _>(ev, cb).attach(self.as_ref())
105: 103:     }
106: 104: 
107: 105:     fn style<S>(&self, style: S) -> S::State
108: 106:     where
109: 107:         S: IntoStyle,
110: 108:     {
111: 109:         style.build(self.as_ref())
112: 110:     }
113: 111: }
114: 112: ```
115: 113: ```
116: 114: ```
117: 115: ```
118: 116: ```
119: 117: ```
120: 118: ```
121: 119: ```
122: ```
```
