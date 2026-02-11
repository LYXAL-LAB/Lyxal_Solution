### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_reactive_graph\src\graph\subscriber.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\src\graph\subscriber.rs
2: ```rust
3: 1: use super::{node::ReactiveNode, AnySource};
4: 2: #[cfg(debug_assertions)]
5: 3: use crate::diagnostics::SpecialNonReactiveZone;
6: 4: use core::{fmt::Debug, hash::Hash};
7: 5: use std::{cell::RefCell, mem, sync::Weak};
8: 6: 
9: 7: thread_local! {
10: 8:     static OBSERVER: RefCell<Option<Oblyx-platform-lyx_platform_lyx-platform-lyx_platform_serverState>> = const { RefCell::new(None) };
11: 9: }
12: 10: 
13: 11: #[derive(Debug)]
14: 12: struct Oblyx-platform-lyx_platform_lyx-platform-lyx_platform_serverState {
15: 13:     subscriber: AnySubscriber,
16: 14:     untracked: bool,
17: 15: }
18: 16: 
19: 17: /// The current reactive oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server.
20: 18: ///
21: 19: /// The oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server is whatever reactive node is currently listening for signals that need to be
22: 20: /// tracked. For lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_example, if an effect is running, that effect is the oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server, which means it will
23: 21: /// subscribe to changes in any signals that are read.
24: 22: pub struct Oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server;
25: 23: 
26: 24: #[derive(Debug)]
27: 25: struct SetOblyx-platform-lyx_platform_lyx-platform-lyx_platform_serverOnDrop(Option<AnySubscriber>);
28: 26: 
29: 27: impl Drop for SetOblyx-platform-lyx_platform_lyx-platform-lyx_platform_serverOnDrop {
30: 28:     fn drop(&mut self) {
31: 29:         Oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server::set(self.0.take());
32: 30:     }
33: 31: }
34: 32: 
35: 33: impl Oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server {
36: 34:     /// Returns the current oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server, if any.
37: 35:     pub fn get() -> Option<AnySubscriber> {
38: 36:         OBSERVER.with_borrow(|obs| {
39: 37:             obs.as_ref().and_then(|obs| {
40: 38:                 if obs.untracked {
41: 39:                     None
42: 40:                 } else {
43: 41:                     Some(obs.subscriber.clone())
44: 42:                 }
45: 43:             })
46: 44:         })
47: 45:     }
48: 46: 
49: 47:     pub(crate) fn is(oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server: &AnySubscriber) -> bool {
50: 48:         OBSERVER.with_borrow(|o| {
51: 49:             o.as_ref().map(|o| &o.subscriber) == Some(oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server)
52: 50:         })
53: 51:     }
54: 52: 
55: 53:     fn take() -> SetOblyx-platform-lyx_platform_lyx-platform-lyx_platform_serverOnDrop {
56: 54:         SetOblyx-platform-lyx_platform_lyx-platform-lyx_platform_serverOnDrop(
57: 55:             OBSERVER.with_borrow_mut(Option::take).map(|o| o.subscriber),
58: 56:         )
59: 57:     }
60: 58: 
61: 59:     fn set(oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server: Option<AnySubscriber>) {
62: 60:         OBSERVER.with_borrow_mut(|o| {
63: 61:             *o = oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server.map(|subscriber| Oblyx-platform-lyx_platform_lyx-platform-lyx_platform_serverState {
64: 62:                 subscriber,
65: 63:                 untracked: false,
66: 64:             })
67: 65:         });
68: 66:     }
69: 67: 
70: 68:     fn replace(oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server: Option<AnySubscriber>) -> SetOblyx-platform-lyx_platform_lyx-platform-lyx_platform_serverOnDrop {
71: 69:         SetOblyx-platform-lyx_platform_lyx-platform-lyx_platform_serverOnDrop(
72: 70:             OBSERVER
73: 71:                 .with_borrow_mut(|o| {
74: 72:                     mem::replace(
75: 73:                         o,
76: 74:                         oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server.map(|subscriber| Oblyx-platform-lyx_platform_lyx-platform-lyx_platform_serverState {
77: 75:                             subscriber,
78: 76:                             untracked: false,
79: 77:                         }),
80: 78:                     )
81: 79:                 })
82: 80:                 .map(|o| o.subscriber),
83: 81:         )
84: 82:     }
85: 83: 
86: 84:     fn replace_untracked(oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server: Option<AnySubscriber>) -> SetOblyx-platform-lyx_platform_lyx-platform-lyx_platform_serverOnDrop {
87: 85:         SetOblyx-platform-lyx_platform_lyx-platform-lyx_platform_serverOnDrop(
88: 86:             OBSERVER
89: 87:                 .with_borrow_mut(|o| {
90: 88:                     mem::replace(
91: 89:                         o,
92: 90:                         oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server.map(|subscriber| Oblyx-platform-lyx_platform_lyx-platform-lyx_platform_serverState {
93: 91:                             subscriber,
94: 92:                             untracked: true,
95: 93:                         }),
96: 94:                     )
97: 95:                 })
98: 96:                 .map(|o| o.subscriber),
99: 97:         )
100: 98:     }
101: 99: }
102: 100: 
103: 101: /// Suspends reactive tracking while running the given function.
104: 102: ///
105: 103: /// This can be used to isolate parts of the reactive graph from one another.
106: 104: ///
107: 105: /// ```rust
108: 106: /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::computed::*;
109: 107: /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::signal::*; let owner = lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::owner::Owner::new(); owner.set();
110: 108: /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::prelude::*;
111: 109: /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::graph::untrack;
112: 110: /// # tokio_test::block_on(async move {
113: 111: /// # lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::Executor::init_tokio(); let owner = lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::owner::Owner::new(); owner.set();
114: 112: /// let (a, set_a) = signal(0);
115: 113: /// let (b, set_b) = signal(0);
116: 114: /// let c = Memo::new(move |_| {
117: 115: ///     // this memo will *only* update when `a` changes
118: 116: ///     a.get() + untrack(move || b.get())
119: 117: /// });
120: 118: ///
121: 119: /// assert_eq!(c.get(), 0);
122: 120: /// set_a.set(1);
123: 121: /// assert_eq!(c.get(), 1);
124: 122: /// set_b.set(1);
125: 123: /// // hasn't updated, because we untracked before reading b
126: 124: /// assert_eq!(c.get(), 1);
127: 125: /// set_a.set(2);
128: 126: /// assert_eq!(c.get(), 3);
129: 127: /// # });
130: 128: /// ```
131: 129: #[track_caller]
132: 130: pub fn untrack<T>(fun: impl FnOnce() -> T) -> T {
133: 131:     #[cfg(debug_assertions)]
134: 132:     let _warning_guard = crate::diagnostics::SpecialNonReactiveZone::enter();
135: 133: 
136: 134:     let _prev = Oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server::take();
137: 135:     fun()
138: 136: }
139: 137: 
140: 138: #[doc(hidden)]
141: 139: #[track_caller]
142: 140: pub fn untrack_with_diagnostics<T>(fun: impl FnOnce() -> T) -> T {
143: 141:     let _prev = Oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server::take();
144: 142:     fun()
145: 143: }
146: 144: 
147: 145: /// Converts a [`Subscriber`] to a type-erased [`AnySubscriber`].
148: 146: pub trait ToAnySubscriber {
149: 147:     /// Converts this type to its type-erased equivalent.
150: 148:     fn to_any_subscriber(&self) -> AnySubscriber;
151: 149: }
152: 150: 
153: 151: /// Any type that can track reactive values (like an effect or a memo).
154: 152: pub trait Subscriber: ReactiveNode {
155: 153:     /// Adds a subscriber to this subscriber's list of dependencies.
156: 154:     fn add_source(&self, source: AnySource);
157: 155: 
158: 156:     /// Clears the set of sources for this subscriber.
159: 157:     fn clear_sources(&self, subscriber: &AnySubscriber);
160: 158: }
161: 159: 
162: 160: /// A type-erased subscriber.
163: 161: #[derive(Clone)]
164: 162: pub struct AnySubscriber(pub usize, pub Weak<dyn Subscriber + Send + Sync>);
165: 163: 
166: 164: impl ToAnySubscriber for AnySubscriber {
167: 165:     fn to_any_subscriber(&self) -> AnySubscriber {
168: 166:         self.clone()
169: 167:     }
170: 168: }
171: 169: 
172: 170: impl Subscriber for AnySubscriber {
173: 171:     fn add_source(&self, source: AnySource) {
174: 172:         if let Some(inner) = self.1.upgrade() {
175: 173:             inner.add_source(source);
176: 174:         }
177: 175:     }
178: 176: 
179: 177:     fn clear_sources(&self, subscriber: &AnySubscriber) {
180: 178:         if let Some(inner) = self.1.upgrade() {
181: 179:             inner.clear_sources(subscriber);
182: 180:         }
183: 181:     }
184: 182: }
185: 183: 
186: 184: impl ReactiveNode for AnySubscriber {
187: 185:     fn mark_dirty(&self) {
188: 186:         if let Some(inner) = self.1.upgrade() {
189: 187:             inner.mark_dirty()
190: 188:         }
191: 189:     }
192: 190: 
193: 191:     fn mark_subscribers_check(&self) {
194: 192:         if let Some(inner) = self.1.upgrade() {
195: 193:             inner.mark_subscribers_check()
196: 194:         }
197: 195:     }
198: 196: 
199: 197:     fn update_if_necessary(&self) -> bool {
200: 198:         if let Some(inner) = self.1.upgrade() {
201: 199:             inner.update_if_necessary()
202: 200:         } else {
203: 201:             false
204: 202:         }
205: 203:     }
206: 204: 
207: 205:     fn mark_check(&self) {
208: 206:         if let Some(inner) = self.1.upgrade() {
209: 207:             inner.mark_check()
210: 208:         }
211: 209:     }
212: 210: }
213: 211: 
214: 212: /// Runs code with some subscriber as the thread-local [`Oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server`].
215: 213: pub trait WithOblyx-platform-lyx_platform_lyx-platform-lyx_platform_server {
216: 214:     /// Runs the given function with this subscriber as the thread-local [`Oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server`].
217: 215:     fn with_oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server<T>(&self, fun: impl FnOnce() -> T) -> T;
218: 216: 
219: 217:     /// Runs the given function with this subscriber as the thread-local [`Oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server`],
220: 218:     /// but without tracking dependencies.
221: 219:     fn with_oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server_untracked<T>(&self, fun: impl FnOnce() -> T) -> T;
222: 220: }
223: 221: 
224: 222: impl WithOblyx-platform-lyx_platform_lyx-platform-lyx_platform_server for AnySubscriber {
225: 223:     fn with_oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server<T>(&self, fun: impl FnOnce() -> T) -> T {
226: 224:         let _prev = Oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server::replace(Some(self.clone()));
227: 225:         fun()
228: 226:     }
229: 227: 
230: 228:     fn with_oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server_untracked<T>(&self, fun: impl FnOnce() -> T) -> T {
231: 229:         #[cfg(debug_assertions)]
232: 230:         let _guard = SpecialNonReactiveZone::enter();
233: 231:         let _prev = Oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server::replace_untracked(Some(self.clone()));
234: 232:         fun()
235: 233:     }
236: 234: }
237: 235: 
238: 236: impl WithOblyx-platform-lyx_platform_lyx-platform-lyx_platform_server for Option<AnySubscriber> {
239: 237:     fn with_oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server<T>(&self, fun: impl FnOnce() -> T) -> T {
240: 238:         let _prev = Oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server::replace(self.clone());
241: 239:         fun()
242: 240:     }
243: 241: 
244: 242:     fn with_oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server_untracked<T>(&self, fun: impl FnOnce() -> T) -> T {
245: 243:         #[cfg(debug_assertions)]
246: 244:         let _guard = SpecialNonReactiveZone::enter();
247: 245:         let _prev = Oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server::replace_untracked(self.clone());
248: 246:         fun()
249: 247:     }
250: 248: }
251: 249: 
252: 250: impl Debug for AnySubscriber {
253: 251:     fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
254: 252:         f.debug_tuple("AnySubscriber").field(&self.0).finish()
255: 253:     }
256: 254: }
257: 255: 
258: 256: impl Hash for AnySubscriber {
259: 257:     fn hash<H: std::hash::Hasher>(&self, state: &mut H) {
260: 258:         self.0.hash(state);
261: 259:     }
262: 260: }
263: 261: 
264: 262: impl PartialEq for AnySubscriber {
265: 263:     fn eq(&self, other: &Self) -> bool {
266: 264:         self.0 == other.0
267: 265:     }
268: 266: }
269: 267: 
270: 268: impl Eq for AnySubscriber {}
271: ```
```
