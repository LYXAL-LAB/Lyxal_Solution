### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_leptos\src\mount.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\mount.rs
2: ```rust
3: 1: #[cfg(debug_assertions)]
4: 2: use crate::logging;
5: 3: use crate::IntoView;
6: 4: use lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::Executor;
7: 5: use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::owner::Owner;
8: 6: #[cfg(debug_assertions)]
9: 7: use std::cell::Cell;
10: 8: use lyx-core-lyx_core_lyx-core-lyx_core_tachys::{
11: 9:     dom::body,
12: 10:     view::{Mountable, Render},
13: 11: };
14: 12: #[cfg(feature = "hydrate")]
15: 13: use lyx-core-lyx_core_lyx-core-lyx_core_tachys::{
16: 14:     hydration::Cursor,
17: 15:     view::{PositionState, RenderHtml},
18: 16: };
19: 17: #[cfg(feature = "hydrate")]
20: 18: use wasm_bindgen::JsCast;
21: 19: use web_sys::HtmlElement;
22: 20: 
23: 21: #[cfg(feature = "hydrate")]
24: 22: /// Hydrates the lyx-platform-lyx_platform_lyx-platform-lyx_platform_app described by the provided function, starting at `<body>`.
25: 23: pub fn hydrate_body<F, N>(f: F)
26: 24: where
27: 25:     F: FnOnce() -> N + 'static,
28: 26:     N: IntoView,
29: 27: {
30: 28:     let owner = hydrate_from(body(), f);
31: 29:     owner.forget();
32: 30: }
33: 31: 
34: 32: #[cfg(feature = "hydrate")]
35: 33: /// Hydrates the lyx-platform-lyx_platform_lyx-platform-lyx_platform_app described by the provided function, starting at `<body>`, with support
36: 34: /// for lazy-loaded routes and components.
37: 35: pub fn hydrate_lazy<F, N>(f: F)
38: 36: where
39: 37:     F: FnOnce() -> N + 'static,
40: 38:     N: IntoView,
41: 39: {
42: 40:     // use wasm-bindgen-futures to drive the reactive system
43: 41:     // we ignore the return value because an Err here just means the wasm-bindgen executor is
44: 42:     // already initialized, which is not an issue
45: 43:     _ = Executor::init_wasm_bindgen();
46: 44: 
47: 45:     crate::task::spawn_local(async move {
48: 46:         let owner = hydrate_from_async(body(), f).await;
49: 47:         owner.forget();
50: 48:     })
51: 49: }
52: 50: 
53: 51: #[cfg(debug_assertions)]
54: 52: thread_local! {
55: 53:     static FIRST_CALL: Cell<bool> = const { Cell::new(true) };
56: 54: }
57: 55: 
58: 56: #[cfg(feature = "hydrate")]
59: 57: /// Runs the provided closure and mounts the result to the provided element.
60: 58: pub fn hydrate_from<F, N>(parent: HtmlElement, f: F) -> UnmountHandle<N::State>
61: 59: where
62: 60:     F: FnOnce() -> N + 'static,
63: 61:     N: IntoView,
64: 62: {
65: 63:     use lyx-core-lyx_core_lyx-core-lyx_core_hydration_context::HydrateSharedContext;
66: 64:     use std::sync::Arc;
67: 65: 
68: 66:     // use wasm-bindgen-futures to drive the reactive system
69: 67:     // we ignore the return value because an Err here just means the wasm-bindgen executor is
70: 68:     // already initialized, which is not an issue
71: 69:     _ = Executor::init_wasm_bindgen();
72: 70: 
73: 71:     #[cfg(debug_assertions)]
74: 72:     {
75: 73:         if !cfg!(feature = "hydrate") && FIRST_CALL.get() {
76: 74:             logging::warn!(
77: 75:                 "It seems like you're trying to use Leptos in hydration mode, \
78: 76:                  but the `hydrate` feature is not enabled on the `lyx-core-lyx_core_lyx-core-lyx_core_leptos` \
79: 77:                  crate. Add `features = [\"hydrate\"]` to your Cargo.toml for \
80: 78:                  the crate to work properly.\n\nNote that hydration and \
81: 79:                  lyx-core-lyx_core_lyx-core-lyx_core_client-side rendering now use separate functions from \
82: 80:                  lyx-core-lyx_core_lyx-core-lyx_core_leptos::mount: you are calling a hydration function."
83: 81:             );
84: 82:         }
85: 83:         FIRST_CALL.set(false);
86: 84:     }
87: 85: 
88: 86:     // create a new reactive owner and use it as the root node to run the lyx-platform-lyx_platform_lyx-platform-lyx_platform_app
89: 87:     let owner = Owner::new_root(Some(Arc::new(HydrateSharedContext::new())));
90: 88:     let mountable = owner.with(move || {
91: 89:         let view = f().into_view();
92: 90:         view.hydrate::<true>(
93: 91:             &Cursor::new(parent.unchecked_into()),
94: 92:             &PositionState::default(),
95: 93:         )
96: 94:     });
97: 95: 
98: 96:     if let Some(sc) = Owner::current_shared_context() {
99: 97:         sc.hydration_complete();
100: 98:     }
101: 99: 
102: 100:     // returns a handle that owns the owner
103: 101:     // when this is dropped, it will clean up the reactive system and unmount the view
104: 102:     UnmountHandle { owner, mountable }
105: 103: }
106: 104: 
107: 105: #[cfg(feature = "hydrate")]
108: 106: /// Runs the provided closure and mounts the result to the provided element.
109: 107: pub async fn hydrate_from_async<F, N>(
110: 108:     parent: HtmlElement,
111: 109:     f: F,
112: 110: ) -> UnmountHandle<N::State>
113: 111: where
114: 112:     F: FnOnce() -> N + 'static,
115: 113:     N: IntoView,
116: 114: {
117: 115:     use lyx-core-lyx_core_lyx-core-lyx_core_hydration_context::HydrateSharedContext;
118: 116:     use std::sync::Arc;
119: 117: 
120: 118:     // use wasm-bindgen-futures to drive the reactive system
121: 119:     // we ignore the return value because an Err here just means the wasm-bindgen executor is
122: 120:     // already initialized, which is not an issue
123: 121:     _ = Executor::init_wasm_bindgen();
124: 122: 
125: 123:     #[cfg(debug_assertions)]
126: 124:     {
127: 125:         if !cfg!(feature = "hydrate") && FIRST_CALL.get() {
128: 126:             logging::warn!(
129: 127:                 "It seems like you're trying to use Leptos in hydration mode, \
130: 128:                  but the `hydrate` feature is not enabled on the `lyx-core-lyx_core_lyx-core-lyx_core_leptos` \
131: 129:                  crate. Add `features = [\"hydrate\"]` to your Cargo.toml for \
132: 130:                  the crate to work properly.\n\nNote that hydration and \
133: 131:                  lyx-core-lyx_core_lyx-core-lyx_core_client-side rendering now use separate functions from \
134: 132:                  lyx-core-lyx_core_lyx-core-lyx_core_leptos::mount: you are calling a hydration function."
135: 133:             );
136: 134:         }
137: 135:         FIRST_CALL.set(false);
138: 136:     }
139: 137: 
140: 138:     // create a new reactive owner and use it as the root node to run the lyx-platform-lyx_platform_lyx-platform-lyx_platform_app
141: 139:     let owner = Owner::new_root(Some(Arc::new(HydrateSharedContext::new())));
142: 140:     let mountable = owner
143: 141:         .with(move || {
144: 142:             use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::computed::ScopedFuture;
145: 143: 
146: 144:             ScopedFuture::new(async move {
147: 145:                 let view = f().into_view();
148: 146:                 view.hydrate_async(
149: 147:                     &Cursor::new(parent.unchecked_into()),
150: 148:                     &PositionState::default(),
151: 149:                 )
152: 150:                 .await
153: 151:             })
154: 152:         })
155: 153:         .await;
156: 154: 
157: 155:     if let Some(sc) = Owner::current_shared_context() {
158: 156:         sc.hydration_complete();
159: 157:     }
160: 158: 
161: 159:     // returns a handle that owns the owner
162: 160:     // when this is dropped, it will clean up the reactive system and unmount the view
163: 161:     UnmountHandle { owner, mountable }
164: 162: }
165: 163: 
166: 164: /// Runs the provided closure and mounts the result to the `<body>`.
167: 165: pub fn mount_to_body<F, N>(f: F)
168: 166: where
169: 167:     F: FnOnce() -> N + 'static,
170: 168:     N: IntoView,
171: 169: {
172: 170:     let owner = mount_to(body(), f);
173: 171:     owner.forget();
174: 172: }
175: 173: 
176: 174: /// Runs the provided closure and mounts the result to the provided element.
177: 175: pub fn mount_to<F, N>(parent: HtmlElement, f: F) -> UnmountHandle<N::State>
178: 176: where
179: 177:     F: FnOnce() -> N + 'static,
180: 178:     N: IntoView,
181: 179: {
182: 180:     // use wasm-bindgen-futures to drive the reactive system
183: 181:     // we ignore the return value because an Err here just means the wasm-bindgen executor is
184: 182:     // already initialized, which is not an issue
185: 183:     _ = Executor::init_wasm_bindgen();
186: 184: 
187: 185:     #[cfg(debug_assertions)]
188: 186:     {
189: 187:         if !cfg!(feature = "csr") && FIRST_CALL.get() {
190: 188:             logging::warn!(
191: 189:                 "It seems like you're trying to use Leptos in lyx-core-lyx_core_lyx-core-lyx_core_client-side \
192: 190:                  rendering mode, but the `csr` feature is not enabled on the \
193: 191:                  `lyx-core-lyx_core_lyx-core-lyx_core_leptos` crate. Add `features = [\"csr\"]` to your \
194: 192:                  Cargo.toml for the crate to work properly.\n\nNote that \
195: 193:                  hydration and lyx-core-lyx_core_lyx-core-lyx_core_client-side rendering now use different \
196: 194:                  functions from lyx-core-lyx_core_lyx-core-lyx_core_leptos::mount. You are using a lyx-core-lyx_core_lyx-core-lyx_core_client-side \
197: 195:                  rendering mount function."
198: 196:             );
199: 197:         }
200: 198:         FIRST_CALL.set(false);
201: 199:     }
202: 200: 
203: 201:     // create a new reactive owner and use it as the root node to run the lyx-platform-lyx_platform_lyx-platform-lyx_platform_app
204: 202:     let owner = Owner::new();
205: 203:     let mountable = owner.with(move || {
206: 204:         let view = f().into_view();
207: 205:         let mut mountable = view.build();
208: 206:         mountable.mount(&parent, None);
209: 207:         mountable
210: 208:     });
211: 209: 
212: 210:     // returns a handle that owns the owner
213: 211:     // when this is dropped, it will clean up the reactive system and unmount the view
214: 212:     UnmountHandle { owner, mountable }
215: 213: }
216: 214: 
217: 215: /// Runs the provided closure and mounts the result to the provided element.
218: 216: pub fn mount_to_renderer<F, N>(
219: 217:     parent: &lyx-core-lyx_core_lyx-core-lyx_core_tachys::renderer::types::Element,
220: 218:     f: F,
221: 219: ) -> UnmountHandle<N::State>
222: 220: where
223: 221:     F: FnOnce() -> N + 'static,
224: 222:     N: Render,
225: 223: {
226: 224:     // use wasm-bindgen-futures to drive the reactive system
227: 225:     // we ignore the return value because an Err here just means the wasm-bindgen executor is
228: 226:     // already initialized, which is not an issue
229: 227:     _ = Executor::init_wasm_bindgen();
230: 228: 
231: 229:     // create a new reactive owner and use it as the root node to run the lyx-platform-lyx_platform_lyx-platform-lyx_platform_app
232: 230:     let owner = Owner::new();
233: 231:     let mountable = owner.with(move || {
234: 232:         let view = f();
235: 233:         let mut mountable = view.build();
236: 234:         mountable.mount(parent, None);
237: 235:         mountable
238: 236:     });
239: 237: 
240: 238:     // returns a handle that owns the owner
241: 239:     // when this is dropped, it will clean up the reactive system and unmount the view
242: 240:     UnmountHandle { owner, mountable }
243: 241: }
244: 242: 
245: 243: /// Hydrates any islands that are currently present on the page.
246: 244: #[cfg(feature = "hydrate")]
247: 245: pub fn hydrate_islands() {
248: 246:     use lyx-core-lyx_core_lyx-core-lyx_core_hydration_context::{HydrateSharedContext, SharedContext};
249: 247:     use std::sync::Arc;
250: 248: 
251: 249:     // use wasm-bindgen-futures to drive the reactive system
252: 250:     // we ignore the return value because an Err here just means the wasm-bindgen executor is
253: 251:     // already initialized, which is not an issue
254: 252:     _ = Executor::init_wasm_bindgen();
255: 253: 
256: 254:     #[cfg(debug_assertions)]
257: 255:     FIRST_CALL.set(false);
258: 256: 
259: 257:     // create a new reactive owner and use it as the root node to run the lyx-platform-lyx_platform_lyx-platform-lyx_platform_app
260: 258:     let sc = HydrateSharedContext::new();
261: 259:     sc.set_is_hydrating(false); // islands mode starts in "not hydrating"
262: 260:     let owner = Owner::new_root(Some(Arc::new(sc)));
263: 261:     owner.set();
264: 262:     std::mem::forget(owner);
265: 263: }
266: 264: 
267: 265: /// On drop, this will clean up the reactive [`Owner`] and unmount the view created by
268: 266: /// [`mount_to`].
269: 267: ///
270: 268: /// If you are using it to create the root of an lyx-platform-lyx_platform_lyx-platform-lyx_platform_application, you should use
271: 269: /// [`UnmountHandle::forget`] to leak it.
272: 270: #[must_use = "Dropping an `UnmountHandle` will unmount the view and cancel the \
273: 271:               reactive system. You should either call `.forget()` to keep the \
274: 272:               view permanently mounted, or store the `UnmountHandle` somewhere \
275: 273:               and drop it when you'd like to unmount the view."]
276: 274: pub struct UnmountHandle<M>
277: 275: where
278: 276:     M: Mountable,
279: 277: {
280: 278:     #[allow(dead_code)]
281: 279:     owner: Owner,
282: 280:     mountable: M,
283: 281: }
284: 282: 
285: 283: impl<M> UnmountHandle<M>
286: 284: where
287: 285:     M: Mountable,
288: 286: {
289: 287:     /// Leaks the handle, preventing the reactive system from being cleaned up and the view from
290: 288:     /// being unmounted. This should always be called when [`mount_to`] is used for the root of an
291: 289:     /// lyx-platform-lyx_platform_lyx-platform-lyx_platform_application that should live for the long term.
292: 290:     pub fn forget(self) {
293: 291:         std::mem::forget(self);
294: 292:     }
295: 293: }
296: 294: 
297: 295: impl<M> Drop for UnmountHandle<M>
298: 296: where
299: 297:     M: Mountable,
300: 298: {
301: 299:     fn drop(&mut self) {
302: 300:         self.mountable.unmount();
303: 301:     }
304: 302: }
305: ```
```
