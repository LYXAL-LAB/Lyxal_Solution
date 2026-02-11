### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_tachys\src\lyx-core-lyx_core_reactive_graph\node_ref.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\node_ref.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\node_ref.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\node_ref.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\node_ref.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\node_ref.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\node_ref.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\node_ref.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\node_ref.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\node_ref.rs
18: 16: ```rust
19: 17: use crate::html::{element::ElementType, node_ref::NodeRefContainer};
20: 18: use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::{
21: 19:     effect::Effect,
22: 20:     graph::untrack,
23: 21:     signal::{
24: 22:         guards::{Derefable, ReadGuard},
25: 23:         RwSignal,
26: 24:     },
27: 25:     traits::{
28: 26:         DefinedAt, Get, IsDisposed, Notify, ReadUntracked, Set, Track,
29: 27:         UntrackableGuard, Write,
30: 28:     },
31: 29: };
32: 30: use send_wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper::SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper;
33: 31: use std::{cell::Cell, ops::DerefMut};
34: 32: use wasm_bindgen::JsCast;
35: 33: 
36: 34: /// A reactive reference to a DOM node that can be used with the `node_ref` attribute.
37: 35: #[derive(Debug)]
38: 36: pub struct NodeRef<E>(RwSignal<Option<SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper<E::Output>>>)
39: 37: where
40: 38:     E: ElementType,
41: 39:     E::Output: 'static;
42: 40: 
43: 41: impl<E> NodeRef<E>
44: 42: where
45: 43:     E: ElementType,
46: 44:     E::Output: 'static,
47: 45: {
48: 46:     /// Creates a new node reference.
49: 47:     #[track_caller]
50: 48:     pub fn new() -> Self {
51: 49:         Self(RwSignal::new(None))
52: 50:     }
53: 51: 
54: 52:     /// Runs the provided closure when the `NodeRef` has been connected
55: 53:     /// with its element.
56: 54:     #[inline(always)]
57: 55:     pub fn on_load<F>(self, f: F)
58: 56:     where
59: 57:         E: 'static,
60: 58:         F: FnOnce(E::Output) + 'static,
61: 59:         E: ElementType,
62: 60:         E::Output: JsCast + Clone + 'static,
63: 61:     {
64: 62:         let f = Cell::new(Some(f));
65: 63: 
66: 64:         Effect::new(move |_| {
67: 65:             if let Some(node_ref) = self.get() {
68: 66:                 let f = f.take().unwrap();
69: 67:                 untrack(move || {
70: 68:                     f(node_ref);
71: 69:                 });
72: 70:             }
73: 71:         });
74: 72:     }
75: 73: }
76: 74: 
77: 75: impl<E> Default for NodeRef<E>
78: 76: where
79: 77:     E: ElementType,
80: 78:     E::Output: 'static,
81: 79: {
82: 80:     fn default() -> Self {
83: 81:         Self::new()
84: 82:     }
85: 83: }
86: 84: 
87: 85: impl<E> Clone for NodeRef<E>
88: 86: where
89: 87:     E: ElementType,
90: 88:     E::Output: 'static,
91: 89: {
92: 90:     fn clone(&self) -> Self {
93: 91:         *self
94: 92:     }
95: 93: }
96: 94: 
97: 95: impl<E> Copy for NodeRef<E>
98: 96: where
99: 97:     E: ElementType,
100: 98:     E::Output: 'static,
101: 99: {
102: 100: }
103: 101: 
104: 102: impl<E> NodeRefContainer<E> for NodeRef<E>
105: 103: where
106: 104:     E: ElementType,
107: 105:     E::Output: JsCast + 'static,
108: 106: {
109: 107:     fn load(self, el: &crate::renderer::types::Element) {
110: 108:         // safe to construct SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper here, because it will only run in the browser
111: 109:         // so it will always be accessed or dropped from the main thread
112: 110:         self.0
113: 111:             .set(Some(SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper::new(el.clone().unchecked_into())));
114: 112:     }
115: 113: }
116: 114: 
117: 115: impl<E> DefinedAt for NodeRef<E>
118: 116: where
119: 117:     E: ElementType,
120: 118:     E::Output: JsCast + 'static,
121: 119: {
122: 120:     fn defined_at(&self) -> Option<&'static std::panic::Location<'static>> {
123: 121:         self.0.defined_at()
124: 122:     }
125: 123: }
126: 124: 
127: 125: impl<E> Notify for NodeRef<E>
128: 126: where
129: 127:     E: ElementType,
130: 128:     E::Output: JsCast + Clone + 'static,
131: 129: {
132: 130:     fn notify(&self) {
133: 131:         self.0.notify();
134: 132:     }
135: 133: }
136: 134: 
137: 135: impl<E> Write for NodeRef<E>
138: 136: where
139: 137:     E: ElementType,
140: 138:     E::Output: JsCast + Clone + 'static,
141: 139: {
142: 140:     type Value = Option<SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper<E::Output>>;
143: 141: 
144: 142:     fn try_write(&self) -> Option<impl UntrackableGuard<Target = Self::Value>> {
145: 143:         self.0.try_write()
146: 144:     }
147: 145: 
148: 146:     fn try_write_untracked(
149: 147:         &self,
150: 148:     ) -> Option<impl DerefMut<Target = Self::Value>> {
151: 149:         self.0.try_write_untracked()
152: 150:     }
153: 151: }
154: 152: 
155: 153: impl<E> ReadUntracked for NodeRef<E>
156: 154: where
157: 155:     E: ElementType,
158: 156:     E::Output: JsCast + Clone + 'static,
159: 157: {
160: 158:     type Value = ReadGuard<Option<E::Output>, Derefable<Option<E::Output>>>;
161: 159: 
162: 160:     fn try_read_untracked(&self) -> Option<Self::Value> {
163: 161:         Some(ReadGuard::new(Derefable(
164: 162:             self.0.try_read_untracked()?.as_deref().cloned(),
165: 163:         )))
166: 164:     }
167: 165: }
168: 166: 
169: 167: impl<E> Track for NodeRef<E>
170: 168: where
171: 169:     E: ElementType,
172: 170:     E::Output: JsCast + 'static,
173: 171: {
174: 172:     fn track(&self) {
175: 173:         self.0.track();
176: 174:     }
177: 175: }
178: 176: 
179: 177: impl<E> IsDisposed for NodeRef<E>
180: 178: where
181: 179:     E: ElementType,
182: 180:     E::Output: 'static,
183: 181: {
184: 182:     fn is_disposed(&self) -> bool {
185: 183:         self.0.is_disposed()
186: 184:     }
187: 185: }
188: 186: 
189: 187: /// Create a [NodeRef].
190: 188: #[inline(always)]
191: 189: #[track_caller]
192: 190: #[deprecated = "This function is being removed to conform to Rust idioms. \
193: 191:                 Please use `NodeRef::new()` instead."]
194: 192: pub fn create_node_ref<E>() -> NodeRef<E>
195: 193: where
196: 194:     E: ElementType,
197: 195:     E::Output: 'static,
198: 196: {
199: 197:     NodeRef::new()
200: 198: }
201: 199: ```
202: 200: ```
203: 201: ```
204: 202: ```
205: 203: ```
206: 204: ```
207: 205: ```
208: 206: ```
209: ```
```
