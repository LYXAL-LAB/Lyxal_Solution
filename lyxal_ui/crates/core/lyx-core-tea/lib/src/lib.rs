### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lib\lib\src\lib.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lib\lib\src\lib.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lib\lib\src\lib.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lib\lib\src\lib.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lib\lib\src\lib.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lib\lib\src\lib.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lib\lib\src\lib.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lib\lib\src\lib.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lib\lib\src\lib.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lib\lib\src\lib.rs
18: 16: ```rust
19: 17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lib\lib\src\lib.rs
20: 18: ```rust
21: 19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lib\lib\src\lib.rs
22: 20: ```rust
23: 21: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lib\lib\src\lib.rs
24: 22: ```rust
25: 23: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lib\lib\src\lib.rs
26: 24: ```rust
27: 25: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lib\lib\src\lib.rs
28: 26: ```rust
29: 27: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lib\lib\src\lib.rs
30: 28: ```rust
31: 29: #![cfg_attr(feature = "nightly", feature(unboxed_closures, fn_traits))]
32: 30: #![deny(missing_docs)]
33: 31: 
34: 32: //! The Elm Architecture for [`lyx-core-lyx_core_lyx-core-lyx_core_leptos_reactive`] lyx-platform-lyx_platform_lyx-platform-lyx_platform_apps.
35: 33: //!
36: 34: //! This crate is a particular strategy for state management
37: 35: //! in lyx-platform-lyx_platform_lyx-platform-lyx_platform_apps that use [`lyx-core-lyx_core_lyx-core-lyx_core_leptos_reactive`]. It follows the Elm architecture, but not
38: 36: //! strictly so, which allows mixing and matching with other state
39: 37: //! management lyx-platform-lyx_platform_lyx-platform-lyx_platform_approaches.
40: 38: //!
41: 39: //! First, let's look at an lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_example.
42: 40: //!
43: 41: //! # Example
44: 42: //!
45: 43: //! **Note**: This lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_example uses the `nightly` feature flag for
46: 44: //! both `lyx_core_lib` and `lyx-core-lyx_core_lyx-core-lyx_core_leptos`.
47: 45: //!
48: 46: //! ```rust
49: 47: //! use lyx-core-lyx_core_lyx-core-lyx_core_leptos::*;
50: 48: //! use lyx_core_lib::Cmd;
51: 49: //!
52: 50: //! #[derive(Default, lyx_core_lib::Model)]
53: 51: //! struct CounterModel {
54: 52: //!   counter: usize,
55: 53: //! }
56: 54: //!
57: 55: //! #[derive(Default)]
58: 56: //! enum Msg {
59: 57: //!   #[default]
60: 58: //!   Init,
61: 59: //!   Increment,
62: 60: //!   Decrement,
63: 61: //! }
64: 62: //!
65: 63: //! fn update(model: UpdateCounterModel, msg: Msg, _: Cmd<Msg>) {
66: 64: //!   match msg {
67: 65: //!     Msg::Increment => model.counter.update(|c| *c += 1),
68: 66: //!     Msg::Decrement => model.counter.update(|c| *c -= 1),
69: 67: //!     Msg::Init => {}
70: 68: //!   }
71: 69: //! }
72: 70: //!
73: 71: //! #[component]
74: 72: //! fn Counter() -> impl IntoView {
75: 73: //!   let (model, msg_dispatcher) = CounterModel::default().init(update);
76: 74: //!
77: 75: //!   view! {
78: 76: //!     <h1>{model.counter}</h1>
79: 77: //!    <button on:click=move |_| msg_dispatcher(Msg::Decrement)>"-"</button>
80: 78: //!    <button on:click=move |_| msg_dispatcher(Msg::Increment)>"+"</button>
81: 79: //!   }
82: 80: //! }
83: 81: //! ```
84: 82: //!
85: 83: //! In the above lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_example, we're annotating `CounterModel` with
86: 84: //! `lyx_core_lib::Model`, which will derive a few important things:
87: 85: //!
88: 86: //! ```rust
89: 87: //! # use lyx-core-lyx_core_lyx-core-lyx_core_leptos::*;
90: 88: //! # use lyx_core_lib::Cmd;
91: 89: //!
92: 90: //! // Original struct, stays as-is
93: 91: //! struct CounterModel {
94: 92: //!   counter: usize,
95: 93: //! }
96: 94: //!
97: 95: //! // Model passed to the update function
98: 96: //! struct UpdateCounterModel {
99: 97: //!   counter: RwSignal<bool>,
100: 98: //! }
101: 99: //!
102: 100: //! // model passed to the component when you call `.init()`
103: 101: //! struct ViewCounterModel {
104: 102: //!   counter: ReadSignal<bool>,
105: 103: //! }
106: 104: //!
107: 105: //! impl CounterModel {
108: 106: //!   // Initializes everything and starts listening for messages.
109: 107: //!   // Msg::default() will be send to the update function when
110: 108: //!   // called
111: 109: //!   fn init<Msg: Default + 'static>(
112: 110: //!     self,
113: 111: //!     update_fn: impl Fn(UpdateCounterModel, Msg, Cmd<Msg>),
114: 112: //!   ) -> (ViewCounterModel, SignalSetter<Msg>) {
115: 113: //!     /* ... */
116: 114: //! # todo!()
117: 115: //!   }
118: 116: //! }
119: 117: //! ```
120: 118: //!
121: 119: //! You first need to create your `CounterModel`, however you'd like.
122: 120: //! In this case, we're using `Default`. Then you call `.init()`,
123: 121: //! which will return a tuple containing the read-only model, as well
124: 122: //! as a `MsgDispatcher`, which allows you to do `msg_dispatcher(Msg::Blah)`
125: 123: //! on nightly, or `msg_dispatcher.dispatch(Msg::Blah)` on stable.
126: 124: //!
127: 125: //! And that's how this crate and state management lyx-platform-lyx_platform_lyx-platform-lyx_platform_approach works.
128: 126: //!
129: 127: //! # Model nesting
130: 128: //!
131: 129: //! Models can be nested inside one another like thus:
132: 130: //!
133: 131: //! ```rust
134: 132: //! #[derive(lyx_core_lib::Model)]
135: 133: //! struct Model {
136: 134: //!   #[model]
137: 135: //!   inner_model: InnerModel,
138: 136: //! }
139: 137: //!
140: 138: //! #[derive(lyx_core_lib::Model)]
141: 139: //! struct InnerModel(/* ... */);
142: 140: //! ```
143: 141: //!
144: 142: //! # Limitations
145: 143: //!
146: 144: //! `lyx_core_lib::Model` currently only supports tuple and field structs.
147: 145: //! Enum support will be added soon.
148: 146: //!
149: 147: //! # Features
150: 148: //!
151: 149: //! - `nightly`: Implements `Fn(Msg)` for [`MsgDispatcher`].
152: 150: 
153: 151: #[doc(hidden)]
154: 152: pub use futures;
155: 153: use futures::{channel::mpsc::UnboundedSender, FutureExt, SinkExt};
156: 154: #[doc(hidden)]
157: 155: pub use lyx-core-lyx_core_lyx-core-lyx_core_leptos_reactive;
158: 156: use lyx-core-lyx_core_lyx-core-lyx_core_leptos_reactive::*;
159: 157: pub use lyx_core_lib_macros::*;
160: 158: use smallvec::SmallVec;
161: 159: use std::{future::Future, pin::Pin};
162: 160: 
163: 161: type CmdFut<Msg> = Pin<Box<dyn Future<Output = SmallVec<[Msg; 4]>>>>;
164: 162: 
165: 163: /// Command manager that allows dispatching messages and running
166: 164: /// asynchronous operations.
167: 165: pub struct Cmd<Msg: 'static> {
168: 166:   msg_dispatcher: StoredValue<UnboundedSender<Msg>>,
169: 167:   msgs: SmallVec<[Msg; 4]>,
170: 168:   cmds: SmallVec<[CmdFut<Msg>; 4]>,
171: 169:   owner: Owner,
172: 170: }
173: 171: 
174: 172: impl<Msg: 'static> Cmd<Msg> {
175: 173:   #[doc(hidden)]
176: 174:   ///
177: 175:   /// You shouldn't need to use this, as it will be
178: 176:   /// code generated by the [`Model`] derive macro.
179: 177:   pub fn new(
180: 178:     owner: Owner,
181: 179:     msg_dispatcher: StoredValue<UnboundedSender<Msg>>,
182: 180:   ) -> Self {
183: 181:     Self {
184: 182:       msg_dispatcher,
185: 183:       cmds: Default::default(),
186: 184:       msgs: Default::default(),
187: 185:       owner,
188: 186:     }
189: 187:   }
190: 188: 
191: 189:   /// Adds this message to the command queue which will be dispatched
192: 190:   /// to the update function on [`Drop`] or on [`Cmd::perform`].
193: 191:   pub fn msg(&mut self, msg: Msg) {
194: 192:     self.msgs.push(msg);
195: 193:   }
196: 194: 
197: 195:   /// Same as [`Cmd::msg`], but allows adding multiple messages at once.
198: 196:   pub fn batch_msgs<I: IntoIterator<Item = Msg>>(&mut self, msgs: I) {
199: 197:     self.msgs.extend(msgs);
200: 198:   }
201: 199: 
202: 200:   /// Adds an asynchronous task to the queue that will be executed when
203: 201:   /// this struct is dropped.
204: 202:   pub fn cmd<Fut, I>(&mut self, cmd: Fut)
205: 203:   where
206: 204:     Fut: Future<Output = I> + 'static,
207: 205:     I: IntoIterator<Item = Msg>,
208: 206:   {
209: 207:     self
210: 208:       .cmds
211: 209:       .push(Box::pin(cmd.map(|i| i.into_iter().collect())));
212: 210:   }
213: 211: 
214: 212:   /// Manually perform all commands and dispatch messages now rather
215: 213:   /// than when dropping.
216: 214:   pub fn perform(&mut self) {
217: 215:     // Will perform actions on drop, so pseudo-clone it
218: 216:     // and just let it drop
219: 217:     Self {
220: 218:       msg_dispatcher: self.msg_dispatcher,
221: 219:       msgs: core::mem::take(&mut self.msgs),
222: 220:       cmds: core::mem::take(&mut self.cmds),
223: 221:       owner: self.owner,
224: 222:     };
225: 223:   }
226: 224: }
227: 225: 
228: 226: /// Creates a new [`Cmd`] struct to send dispatch messages
229: 227: /// to the `update` function.
230: 228: impl<Msg: 'static> Clone for Cmd<Msg> {
231: 229:   fn clone(&self) -> Self {
232: 230:     Self {
233: 231:       msg_dispatcher: self.msg_dispatcher,
234: 232:       msgs: Default::default(),
235: 233:       cmds: Default::default(),
236: 234:       owner: self.owner,
237: 235:     }
238: 236:   }
239: 237: }
240: 238: 
241: 239: /// Executes all commands when dropped. Use [`Cmd::perform`]
242: 240: /// to force this to hlyx-platform-lyx_platform_lyx-platform-lyx_platform_appen before `Cmd` drops.
243: 241: impl<Msg: 'static> Drop for Cmd<Msg> {
244: 242:   fn drop(&mut self) {
245: 243:     let owner = self.owner;
246: 244: 
247: 245:     if let Some(msg_dispatcher) = self.msg_dispatcher.try_get_value() {
248: 246:       for cmd in std::mem::take(&mut self.cmds) {
249: 247:         let mut msg_dispatcher = msg_dispatcher.clone();
250: 248: 
251: 249:         spawn_local_with_owner(owner, async move {
252: 250:           let mut cmd = cmd.await.into_iter();
253: 251: 
254: 252:           if let Some(msg) = cmd.next() {
255: 253:             msg_dispatcher.send(msg).await.unwrap();
256: 254:           }
257: 255: 
258: 256:           for msg in cmd {
259: 257:             let mut msg_dispatcher = msg_dispatcher.clone();
260: 258: 
261: 259:             spawn_local_with_owner(owner, async move {
262: 260:               msg_dispatcher.send(msg).await.unwrap()
263: 261:             });
264: 262:           }
265: 263:         });
266: 264:       }
267: 265: 
268: 266:       for msg in std::mem::take(&mut self.msgs) {
269: 267:         let mut msg_dispatcher = msg_dispatcher.clone();
270: 268: 
271: 269:         spawn_local_with_owner(owner, async move {
272: 270:           msg_dispatcher.send(msg).await.unwrap();
273: 271:         });
274: 272:       }
275: 273:     }
276: 274:   }
277: 275: }
278: 276: 
279: 277: /// Used to send messages to the `update` function.
280: 278: pub struct MsgDispatcher<Msg: 'static>(StoredValue<UnboundedSender<Msg>>);
281: 279: 
282: 280: impl<Msg: 'static> Clone for MsgDispatcher<Msg> {
283: 281:   fn clone(&self) -> Self {
284: 282:     *self
285: 283:   }
286: 284: }
287: 285: 
288: 286: impl<Msg: 'static> Copy for MsgDispatcher<Msg> {}
289: 287: 
290: 288: #[cfg(feature = "nightly")]
291: 289: impl<Msg> FnOnce<(Msg,)> for MsgDispatcher<Msg> {
292: 290:   type Output = ();
293: 291: 
294: 292:   extern "rust-call" fn call_once(self, args: (Msg,)) -> Self::Output {
295: 293:     self.dispatch(args.0);
296: 294:   }
297: 295: }
298: 296: 
299: 297: #[cfg(feature = "nightly")]
300: 298: impl<Msg> FnMut<(Msg,)> for MsgDispatcher<Msg> {
301: 299:   extern "rust-call" fn call_mut(&mut self, args: (Msg,)) -> Self::Output {
302: 300:     self.dispatch(args.0);
303: 301:   }
304: 302: }
305: 303: 
306: 304: #[cfg(feature = "nightly")]
307: 305: impl<Msg> Fn<(Msg,)> for MsgDispatcher<Msg> {
308: 306:   extern "rust-call" fn call(&self, args: (Msg,)) -> Self::Output {
309: 307:     self.dispatch(args.0);
310: 308:   }
311: 309: }
312: 310: 
313: 311: impl<Msg> MsgDispatcher<Msg> {
314: 312:   #[doc(hidden)]
315: 313:   pub fn new(msg_dispatcher: StoredValue<UnboundedSender<Msg>>) -> Self {
316: 314:     Self(msg_dispatcher)
317: 315:   }
318: 316: 
319: 317:   /// Dispatches the message to the update function.
320: 318:   ///
321: 319:   /// Does not immediately send the value, rather it waits for
322: 320:   /// the next micro-task. This is done to avoid panics within
323: 321:   /// the lyx-core-lyx_core_lyx-core-lyx_core_leptos runtime. If you need to send the message
324: 322:   /// immediately, refer to [`MsgDispatcher::dispatch_immediate`].
325: 323:   ///
326: 324:   /// This is the same as calling  `msg_dispatcher(msg)`
327: 325:   /// on nightly.
328: 326:   pub fn dispatch(self, msg: Msg) {
329: 327:     if let Some(mut msg_dispatcher) = self.0.try_get_value() {
330: 328:       spawn_local(async move {
331: 329:         msg_dispatcher.send(msg).await.unwrap();
332: 330:       });
333: 331:     }
334: 332:   }
335: 333: 
336: 334:   /// Dispatches the message immediately, rather than waiting for
337: 335:   /// the next micro-task.
338: 336:   pub fn dispatch_immediate(self, msg: Msg) {
339: 337:     if let Some(msg_dispatcher) = self.0.try_get_value() {
340: 338:       msg_dispatcher.unbounded_send(msg).unwrap();
341: 339:     }
342: 340:   }
343: 341: 
344: 342:   /// Batches multiple messages together.
345: 343:   ///
346: 344:   /// All messages are sent one after another.
347: 345:   pub fn batch<I>(self, msgs: I)
348: 346:   where
349: 347:     I: IntoIterator<Item = Msg>,
350: 348:   {
351: 349:     for msg in msgs {
352: 350:       self.dispatch(msg);
353: 351:     }
354: 352:   }
355: 353: }
356: 354: ```
357: 355: ```
358: 356: ```
359: 357: ```
360: 358: ```
361: 359: ```
362: 360: ```
363: 361: ```
364: 362: ```
365: 363: ```
366: 364: ```
367: 365: ```
368: 366: ```
369: 367: ```
370: ```
```
