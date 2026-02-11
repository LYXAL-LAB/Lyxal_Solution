### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx-found-animation\src\lib.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx-found-animation\src\lib.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_animation\src\lib.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_animation\src\lib.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_animation\src\lib.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_animation\src\lib.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_animation\src\lib.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_animation\src\lib.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_animation\src\lib.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_animation\src\lib.rs
18: 16: ```rust
19: 17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_animation\src\lib.rs
20: 18: ```rust
21: 19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_animation\src\lib.rs
22: 20: ```rust
23: 21: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_animation\src\lib.rs
24: 22: ```rust
25: 23: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_animation\src\lib.rs
26: 24: ```rust
27: 25: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_animation\src\lib.rs
28: 26: ```rust
29: 27: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_animation\src\lib.rs
30: 28: ```rust
31: 29: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_animation\src\lib.rs
32: 30: ```rust
33: 31: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_animation\src\lib.rs
34: 32: ```rust
35: 33: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_animation\src\lib.rs
36: 34: ```rust
37: 35: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_animation\src\lib.rs
38: 36: ```rust
39: 37: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_animation\src\lib.rs
40: 38: ```rust
41: 39: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_animation\src\lib.rs
42: 40: ```rust
43: 41: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_animation\src\lib.rs
44: 42: ```rust
45: 43: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_animation\src\lib.rs
46: 44: ```rust
47: 45: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_animation\src\lib.rs
48: 46: ```rust
49: 47: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_animation\src\lib.rs
50: 48: ```rust
51: 49: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_animation\src\lib.rs
52: 50: ```rust
53: 51: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_animation\src\lib.rs
54: 52: ```rust
55: 53: use instant::Instant;
56: 54: use std::cmp::PartialEq;
57: 55: use std::fmt::Debug;
58: 56: use std::ops::{Add, Deref, Mul};
59: 57: use std::{collections::VecDeque, ops::Sub, time::Duration};
60: 58: 
61: 59: use lyx-core-lyx_core_lyx-core-lyx_core_leptos::{
62: 60:     create_effect, create_memo, create_trigger, lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_dom::helpers::AnimationFrameRequestHandle,
63: 61:     on_cleanup, provide_context, request_animation_frame_with_handle, store_value, use_context,
64: 62:     Effect, IntoView, Memo, Signal, SignalDispose, SignalGet, SignalGetUntracked, SignalWith,
65: 63:     StoredValue, Trigger, View,
66: 64: };
67: 65: 
68: 66: pub mod animation_target;
69: 67: pub mod easing;
70: 68: 
71: 69: #[derive(Clone)]
72: 70: enum AnimationContextState {
73: 71:     NoAnimationFrameRequested,
74: 72:     AnimationFrameRequested(AnimationFrameRequestHandle),
75: 73:     CustomAnimationFrameRequested,
76: 74: }
77: 75: 
78: 76: /// The `AnimationContext` handles updating all animated values and calls to `window.request_animation_frame()`.
79: 77: /// It is required to provide one in a parent context before calling [`create_animated_signal()`]
80: 78: /// ```
81: 79: /// # use lyx-core-lyx_core_lyx-core-lyx_core_leptos::*;
82: 80: /// # use lyx-core-lyx_core_lyx-found-animation::AnimationContext;
83: 81: /// # let runtime = create_runtime();
84: 82: ///  AnimationContext::provide();
85: 83: /// # runtime.dispose();
86: 84: /// ```
87: 85: #[derive(Copy, Clone)]
88: 86: pub struct AnimationContext {
89: 87:     /// The `animation_frame` trigger is the root for all animation updates. It is triggered on
90: 88:     /// the `window.request_animation_frame()` callback. It is not necessary to notify or track
91: 89:     /// this trigger yourself, it will hlyx-platform-lyx_platform_lyx-platform-lyx_platform_appen automatically when animated signals exist.
92: 90:     pub animation_frame: Trigger,
93: 91:     state: StoredValue<AnimationContextState>,
94: 92:     custom_request_animation_frame: StoredValue<Option<Box<dyn Fn()>>>,
95: 93: }
96: 94: 
97: 95: impl AnimationContext {
98: 96:     /// Sets up an AnimationContext for this scope and all child scopes. For normal use you only
99: 97:     /// need to call this once in a root component of the lyx-platform-lyx_platform_lyx-platform-lyx_platform_application.
100: 98:     pub fn provide() -> AnimationContext {
101: 99:         let animation_frame = create_trigger();
102: 100:         let state = store_value(AnimationContextState::NoAnimationFrameRequested);
103: 101: 
104: 102:         let animation_context = AnimationContext {
105: 103:             animation_frame,
106: 104:             state,
107: 105:             custom_request_animation_frame: store_value(None),
108: 106:         };
109: 107:         provide_context(animation_context);
110: 108: 
111: 109:         on_cleanup(move || {
112: 110:             if let AnimationContextState::AnimationFrameRequested(handle) = state.get_value() {
113: 111:                 handle.cancel()
114: 112:             }
115: 113:         });
116: 114: 
117: 115:         animation_context
118: 116:     }
119: 117: 
120: 118:     /// This method can be used instead of `provide` when you are in a non-web environment such as
121: 119:     /// a desktop lyx-platform-lyx_platform_lyx-platform-lyx_platform_application. *For web environments it is recommended to use the normal `provide` instead*
122: 120:     ///
123: 121:     /// There are two extra callbacks that have to be correctly called and implemented in order
124: 122:     /// for this library to correctly function.
125: 123:     ///
126: 124:     /// The callback given in the argument has to call some function that triggers an animation frame
127: 125:     /// request. For lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_example, in the `winit` crate this would be calling [`Window::request_redraw()`](https://docs.rs/winit/latest/winit/window/struct.Window.html#method.request_redraw).
128: 126:     /// This callback will be called at most once per animation frame.
129: 127:     ///
130: 128:     /// The callback returned from this function should be called when the animation frame from the
131: 129:     /// previous callback has arrived.
132: 130:     /// For lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_example, in the `winit` crate this should be called when the [`WindowEvent::RedrawRequested`](https://docs.rs/winit/latest/winit/event/enum.WindowEvent.html#variant.RedrawRequested) event hlyx-platform-lyx_platform_lyx-platform-lyx_platform_appens
133: 131:     /// Extraneous calls to this callback are ignored.
134: 132:     ///
135: 133:     /// ````
136: 134:     /// # // Lots of boilerplate to simulate winit environment
137: 135:     /// # use lyx-core-lyx_core_lyx-core-lyx_core_leptos::create_runtime;
138: 136:     /// # use lyx-core-lyx_core_lyx-found-animation::AnimationContext;
139: 137:     /// # struct Window {}
140: 138:     /// # impl Window { fn request_redraw(&self) {} }
141: 139:     /// # let window = Window {};
142: 140:     /// # let runtime = create_runtime();
143: 141:     /// # struct EventLoop {};
144: 142:     /// # impl EventLoop { fn run(&self, f: impl Fn(Event, ())) {} }
145: 143:     /// # let event_loop = EventLoop {};
146: 144:     /// # enum WindowEvent { RedrawRequested }
147: 145:     /// # enum Event { WindowEvent { event: WindowEvent}, Other }
148: 146:     /// let (_, on_redraw_requested) =
149: 147:     ///         AnimationContext::provide_with_custom_request_animation_frame(move || {
150: 148:     ///             window.request_redraw();
151: 149:     ///         });
152: 150:     ///
153: 151:     /// event_loop.run(move |event, elwt| match event {
154: 152:     ///         Event::WindowEvent {
155: 153:     ///             event: WindowEvent::RedrawRequested,
156: 154:     ///             ..
157: 155:     ///         } => on_redraw_requested(),
158: 156:     ///         _ => {}
159: 157:     /// });
160: 158:     ///
161: 159:     /// ````
162: 160: 
163: 161:     pub fn provide_with_custom_request_animation_frame(
164: 162:         callback: impl Fn() + 'static,
165: 163:     ) -> (AnimationContext, impl Fn()) {
166: 164:         let animation_context = Self::provide();
167: 165:         animation_context
168: 166:             .custom_request_animation_frame
169: 167:             .set_value(Some(Box::new(callback)));
170: 168: 
171: 169:         (animation_context, move || {
172: 170:             if !matches!(
173: 171:                 animation_context.state.get_value(),
174: 172:                 AnimationContextState::NoAnimationFrameRequested
175: 173:             ) {
176: 174:                 animation_context
177: 175:                     .state
178: 176:                     .set_value(AnimationContextState::NoAnimationFrameRequested);
179: 177:                 animation_context.animation_frame.notify();
180: 178:             }
181: 179:         })
182: 180:     }
183: 181: 
184: 182:     /// Manually request a new animation frame. It will result in a `notify()` on the
185: 183:     /// `AnimationContext.animation_frame` trigger which updates all running animations
186: 184:     /// simultaneously. Repeated calls will result in only a single animation frame request.
187: 185:     ///
188: 186:     /// Animated signals will call this automatically when they are running, it is not necessary
189: 187:     /// to call this function unless you are doing something custom.
190: 188:     pub fn request_animation_frame(&self) {
191: 189:         // Prevent multiple animation frame requests from existing simultaneously
192: 190:         if matches!(
193: 191:             self.state.get_value(),
194: 192:             AnimationContextState::NoAnimationFrameRequested
195: 193:         ) {
196: 194:             self.custom_request_animation_frame
197: 195:                 .with_value(
198: 196:                     |custom_request_animation_frame| match custom_request_animation_frame {
199: 197:                         None => {
200: 198:                             let this = self.clone();
201: 199:                             self.state
202: 200:                                 .set_value(AnimationContextState::AnimationFrameRequested(
203: 201:                                     request_animation_frame_with_handle(move || {
204: 202:                                         this.state.set_value(
205: 203:                                             AnimationContextState::NoAnimationFrameRequested,
206: 204:                                         );
207: 205:                                         this.animation_frame.notify();
208: 206:                                     })
209: 207:                                     .unwrap(),
210: 208:                                 ))
211: 209:                         }
212: 210:                         Some(callback) => {
213: 211:                             self.state
214: 212:                                 .set_value(AnimationContextState::CustomAnimationFrameRequested);
215: 213:                             callback()
216: 214:                         }
217: 215:                     },
218: 216:                 );
219: 217:         }
220: 218:     }
221: 219: }
222: 220: 
223: 221: /// An `AnimationTarget` is a target value for the animation system to ease towards to along with
224: 222: /// details about the animation such as its duration, easing method and how to deal with previous animations.
225: 223: ///
226: 224: /// An AnimationTarget can also be created from a tuple:
227: 225: /// ```
228: 226: /// # use std::time::Duration;
229: 227: /// # use lyx-core-lyx_core_lyx-found-animation::{AnimationMode, AnimationTarget, easing};
230: 228: /// let _: AnimationTarget<u32> = (42, Duration::from_secs_f64(1.5), easing::ELASTIC_IN, AnimationMode::ReplaceOrStart).into();
231: 229: /// ```
232: 230: ///
233: 231: /// It is possible to omit any combination of duration, easing or animation mode:
234: 232: /// ```
235: 233: /// # use std::time::Duration;
236: 234: /// # use lyx-core-lyx_core_lyx-found-animation::AnimationTarget;
237: 235: /// // Omit easing & animation mode, will be filled in by default values
238: 236: /// let _: AnimationTarget<u32> = (42, Duration::from_secs_f64(1.5)).into();
239: 237: /// ```
240: 238: ///
241: 239: /// If you want to use all the default animation options you can call `into()` directly on a target value:
242: 240: /// ```
243: 241: /// # use std::time::Duration;
244: 242: /// # use lyx-core-lyx_core_lyx-found-animation::AnimationTarget;
245: 243: /// let _: AnimationTarget<u32> = 42.into();
246: 244: /// ```
247: 245: #[derive(Clone, Copy, Debug, Eq, PartialEq)]
248: 246: pub struct AnimationTarget<T> {
249: 247:     /// The final value to animate towards to
250: 248:     pub target: T,
251: 249: 
252: 250:     /// The time for which the animation plays. Defaults to 0.5 seconds
253: 251:     pub duration: Duration,
254: 252: 
255: 253:     /// The easing method to lyx-platform-lyx_platform_lyx-platform-lyx_platform_apply during the animation. Defaults to [`SINE_OUT`](easing::SINE_OUT)
256: 254:     pub easing: Easing,
257: 255: 
258: 256:     /// The mode specifies how to deal with running animation. Defaults to [`Start`](AnimationMode::Start).
259: 257:     /// This can be used to add, overwrite or cancel running animations.
260: 258:     /// See [`AnimationMode`] for more information
261: 259:     pub mode: AnimationMode,
262: 260: }
263: 261: 
264: 262: /// The `AnimationMode` specifies how to handle new animation target values with respect to currently running animations
265: 263: #[derive(Clone, Copy, Debug, Eq, PartialEq)]
266: 264: pub enum AnimationMode {
267: 265:     /// Always start a new animation on top of the already running animations when the input signal changes.
268: 266:     /// This is the default mode. For 'bursty' input signals which can update many times in quick succession (like mouse move events)
269: 267:     /// it is recommended to use one of the other modes to prevent many overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping animations running simultaneously
270: 268:     Start,
271: 269: 
272: 270:     /// Replace the target value of the latest running animation or start a new animation if there are no animations running
273: 271:     ReplaceOrStart,
274: 272: 
275: 273:     /// Replace the target of the latest running animation or snap directly to the target if there are no animations running
276: 274:     ReplaceOrSnap,
277: 275: 
278: 276:     /// Cancels any previous animation and sets the output directly to the target value
279: 277:     Snap,
280: 278: }
281: 279: 
282: 280: /// An easing function is one that takes a value between 0.0 - 1.0 and maps it to another value between 0.0 and 1.0
283: 281: /// See `https://easings.net` for a list of implemented functions
284: 282: pub type Easing = fn(f64) -> f64;
285: 283: 
286: 284: struct Animation<T, I> {
287: 285:     from: T,
288: 286:     to: T,
289: 287:     to_i: I,
290: 288:     start: Instant,
291: 289:     duration: Duration,
292: 290:     easing: Easing,
293: 291: }
294: 292: 
295: 293: impl<T, I> Animation<T, I> {
296: 294:     fn is_finished(&self) -> bool {
297: 295:         Instant::now() > self.start + self.duration
298: 296:     }
299: 297: 
300: 298:     fn progress(&self) -> f64 {
301: 299:         (self.easing)((Instant::now() - self.start).as_secs_f64() / self.duration.as_secs_f64())
302: 300:     }
303: 301: }
304: 302: 
305: 303: enum AnimationStatus<T, I> {
306: 304:     /// No animation running
307: 305:     Static(T),
308: 306: 
309: 307:     /// No animation running, but animated signal is expected to update in the next animation frame to this value.
310: 308:     /// After that it will revert back to Static
311: 309:     Snap(T),
312: 310: 
313: 311:     /// Animations are running
314: 312:     /// The `VecDeque` is guaranteed to contain at least one animation. All animations are guaranteed
315: 313:     /// to be sorted in reverse order of when they started with the most recent one in front and
316: 314:     /// the oldest one in the back.
317: 315:     Running {
318: 316:         to: T,
319: 317:         to_i: I,
320: 318:         animations: VecDeque<Animation<T, I>>,
321: 319:     },
322: 320: }
323: 321: 
324: 322: impl<T: Clone, I> AnimationStatus<T, I> {
325: 323:     fn remove_finished_animations(&mut self) {
326: 324:         match self {
327: 325:             AnimationStatus::Static(_) => {}
328: 326:             AnimationStatus::Snap(value) => *self = AnimationStatus::Static(value.clone()),
329: 327:             AnimationStatus::Running { to, animations, .. } => {
330: 328:                 animations.retain(|animation| !animation.is_finished());
331: 329:                 if animations.len() == 0 {
332: 330:                     *self = AnimationStatus::Snap(to.clone());
333: 331:                 }
334: 332:             }
335: 333:         }
336: 334:     }
337: 335: }
338: 336: 
339: 337: // This is used to filter signals with create_memo. Yes, a total hack.
340: 338: enum SignalUpdate {
341: 339:     Ignore,
342: 340:     Update,
343: 341: }
344: 342: 
345: 343: impl PartialEq for SignalUpdate {
346: 344:     fn eq(&self, other: &Self) -> bool {
347: 345:         match other {
348: 346:             SignalUpdate::Ignore => true,
349: 347:             SignalUpdate::Update => false,
350: 348:         }
351: 349:     }
352: 350: }
353: 351: 
354: 352: /// Create a derived signal that animated the value of the input signals.
355: 353: /// Takes as input a reactive source callback function and a tween function.
356: 354: ///
357: 355: /// The source callback function is run in a reactive context and is expected to take the value of one or more input
358: 356: /// signals and return an `AnimationTarget` value. An `AnimationTarget` specifies a target value to
359: 357: /// animate towards and details about the duration, easing and animation of how to animate towards it.
360: 358: /// There are shortcut methods to create an `AnimationTarget` with default values, see
361: 359: /// [`AnimationTarget`] for details.
362: 360: ///
363: 361: /// The tween callback specifies how to interpolate between two input values. As input it takes three
364: 362: /// arguments: `from`, `to` and `progress`. Where `from` and `to` are the values from the input signal
365: 363: /// and the `progress` is a value between 0.0 - 1.0. The easing is already lyx-platform-lyx_platform_lyx-platform-lyx_platform_applied to the `progress`.
366: 364: /// The tween function is expected to do a linear interpolation between `from` & `to` and return the
367: 365: /// result.
368: 366: ///
369: 367: /// If the input is in any way numeric or supports the `Add`, `Sub` and `Mul<f64>` traits it is recommended
370: 368: /// to use the [`tween_default`] function as input which performs a simple `(to - from) * progress + from`.
371: 369: ///
372: 370: /// If you are dealing with structs that are composed of numbers (for lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_example a `Position { x: f64, y: f64 }`)
373: 371: /// you can use the [derive_more](https://docs.rs/crate/derive_more/latest) crate to implement the necessary traits.
374: 372: /// This way you can still use the `tween_default` function.
375: 373: ///
376: 374: /// This function is generic over two types: `T` and `I`.
377: 375: /// * `T` is the type of values that are animated between. Animations are always from a `T` towards another `T`
378: 376: /// * `I` is the type of the interpolated values between values of type `T`.
379: 377: ///
380: 378: /// In simple cases `I` is the same as `T` such as animating between `f64`'s. But they can also be different
381: 379: /// if for lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_example the `T` is an enum which cannot represent 'in-between' values by itself.
382: 380: ///
383: 381: /// Updates to the derived signal only hlyx-platform-lyx_platform_lyx-platform-lyx_platform_appen on browser animation frames and only when there are animations
384: 382: /// running. If you are dealing with a HTML Canvas it is recommended to use a `create_effect()` to draw on the
385: 383: /// canvas and subscribe directly to the animated signals.
386: 384: /// All animated signals update simultaneously on animation frames so even if you subscribe to multiple animated
387: 385: /// input signals the effect will never run more than 60fps.
388: 386: ///
389: 387: /// # Additive animations
390: 388: ///
391: 389: /// This library uses an additive animation system. This means that multiple animations with different
392: 390: /// targets and different durations can play simultaneously without them interrupting each other.
393: 391: ///
394: 392: /// Internally all animations are towards 0. For lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_example if we start an animation from 0 to 100, this is
395: 393: /// converted to an animation from -100 to 0 which gets added to the final 100 value.
396: 394: ///
397: 395: /// If then a second animation is started from 100 to 1000 it gets converted to an animation from -900 to 0.
398: 396: /// Both the -100 to 0 and the -900 to 0 animation value get added to the final 1000 value until both settle on 1000 as they reach 0.
399: 397: ///
400: 398: /// This allows for all animations to play to completion even if animations are started before the previous animation is finished.
401: 399: ///
402: 400: /// # Examples
403: 401: /// ```
404: 402: /// # use std::time::Duration;
405: 403: /// # use lyx-core-lyx_core_lyx-core-lyx_core_leptos::*;
406: 404: /// # use lyx-core-lyx_core_lyx-found-animation::{AnimationContext, AnimationMode, AnimationTarget, create_animated_signal, easing, tween_default};
407: 405: /// # let runtime = create_runtime();
408: 406: /// # AnimationContext::provide();
409: 407: /// let (value, set_value) = create_signal(42.0);
410: 408: ///
411: 409: /// // Simple default animation
412: 410: /// let animated_value = create_animated_signal(move || value.get().into(), tween_default);
413: 411: ///
414: 412: /// // Custom duration
415: 413: /// let slow_value = create_animated_signal(move || (value.get(), Duration::from_secs_f64(5.0)).into(), tween_default::<f64, f64>);
416: 414: ///
417: 415: /// // Custom duration, easing & mode
418: 416: /// let custom_value = create_animated_signal(
419: 417: ///         move || AnimationTarget {
420: 418: ///             target: value.get(),
421: 419: ///             duration: Duration::from_secs_f64(1.5),
422: 420: ///             easing: easing::ELASTIC_IN_OUT,
423: 421: ///             mode: AnimationMode::ReplaceOrStart
424: 422: ///         },
425: 423: ///         tween_default);
426: 424: ///
427: 425: /// // Custom tween function
428: 426: /// let tween_value = create_animated_signal(
429: 427: ///         move || value.get().into(),
430: 428: ///         |from, to, progress| {
431: 429: ///             (to - from) * progress + from
432: 430: ///         });
433: 431: ///
434: 432: /// # runtime.dispose();
435: 433: /// ```
436: 434: pub fn create_animated_signal<T, I>(
437: 435:     source: impl Fn() -> AnimationTarget<T> + 'static,
438: 436:     tween: fn(&T, &T, f64) -> I,
439: 437: ) -> AnimatedSignal<T, I>
440: 438: where
441: 439:     T: 'static,
442: 440:     T: Clone,
443: 441:     I: Clone,
444: 442:     I: Sub<I, Output = I>,
445: 443: {
446: 444:     let context: AnimationContext = use_context()
447: 445:         .expect("No AnimationContext present, call AnimationContext::provide() in a parent scope");
448: 446: 
449: 447:     let source = Signal::derive(source);
450: 448: 
451: 449:     let animation_status = store_value(AnimationStatus::<T, I>::Static(
452: 450:         source.get_untracked().target,
453: 451:     ));
454: 452: 
455: 453:     // Effect that listens to changes in the source and updates the animation status
456: 454:     let update_animation_status_effect = create_effect(move |prev| {
457: 455:         let animation_target = source.get();
458: 456: 
459: 457:         // Don't start an animation the very first run
460: 458:         if prev.is_none() {
461: 459:             return;
462: 460:         }
463: 461: 
464: 462:         animation_status.update_value(|animation_status| {
465: 463:             match animation_status {
466: 464:                 // Starting an animation from a non-running state
467: 465:                 AnimationStatus::Static(state) | AnimationStatus::Snap(state) => {
468: 466:                     match animation_target.mode {
469: 467:                         AnimationMode::Start | AnimationMode::ReplaceOrStart => {
470: 468:                             let to_i =
471: 469:                                 tween(&animation_target.target, &animation_target.target, 1.0);
472: 470:                             *animation_status = AnimationStatus::Running {
473: 471:                                 to: animation_target.target.clone(),
474: 472:                                 to_i: to_i.clone(),
475: 473:                                 animations: VecDeque::from([Animation {
476: 474:                                     from: state.clone(),
477: 475:                                     to: animation_target.target,
478: 476:                                     to_i,
479: 477:                                     start: Instant::now(),
480: 478:                                     duration: animation_target.duration,
481: 479:                                     easing: animation_target.easing,
482: 480:                                 }]),
483: 481:                             }
484: 482:                         }
485: 483:                         AnimationMode::ReplaceOrSnap | AnimationMode::Snap => {
486: 484:                             *animation_status = AnimationStatus::Snap(animation_target.target)
487: 485:                         }
488: 486:                     }
489: 487:                 }
490: 488:                 // Start an animation from a running state
491: 489:                 AnimationStatus::Running {
492: 490:                     to,
493: 491:                     to_i,
494: 492:                     animations,
495: 493:                 } => match animation_target.mode {
496: 494:                     AnimationMode::Start => {
497: 495:                         let new_to_i =
498: 496:                             tween(&animation_target.target, &animation_target.target, 1.0);
499: 497: 
500: 498:                         animations.push_front(Animation {
501: 499:                             from: to.clone(),
502: 500:                             to: animation_target.target.clone(),
503: 501:                             to_i: new_to_i.clone(),
504: 502:                             start: Instant::now(),
505: 503:                             duration: animation_target.duration,
506: 504:                             easing: animation_target.easing,
507: 505:                         });
508: 506:                         *to = animation_target.target;
509: 507:                         *to_i = new_to_i;
510: 508:                     }
511: 509:                     // This arm can only be reached when there are still live animations, so we perform the 'replace' operation
512: 510:                     AnimationMode::ReplaceOrStart | AnimationMode::ReplaceOrSnap => {
513: 511:                         *to = animation_target.target.clone();
514: 512:                         *to_i = tween(&animation_target.target, &animation_target.target, 1.0);
515: 513:                         let last_animation = animations.front_mut().unwrap();
516: 514:                         last_animation.to = animation_target.target;
517: 515:                         last_animation.to_i = to_i.clone();
518: 516:                     }
519: 517:                     AnimationMode::Snap => {
520: 518:                         *animation_status = AnimationStatus::Snap(animation_target.target)
521: 519:                     }
522: 520:                 },
523: 521:             }
524: 522:         });
525: 523:         context.request_animation_frame();
526: 524:     });
527: 525: 
528: 526:     // Signal that derives from the global animation_frame signal but only
529: 527:     // fires when 'this' animation has something to update.
530: 528:     let animation_tick = create_memo(move |_| {
531: 529:         context.animation_frame.track();
532: 530: 
533: 531:         let was_snap = animation_status
534: 532:             .with_value(|animation_status| matches!(animation_status, AnimationStatus::Snap(_)));
535: 533: 
536: 534:         animation_status.update_value(|animation_status| {
537: 535:             animation_status.remove_finished_animations();
538: 536:         });
539: 537: 
540: 538:         if was_snap {
541: 539:             SignalUpdate::Update
542: 540:         } else {
543: 541:             animation_status.with_value(|animation_status| match animation_status {
544: 542:                 AnimationStatus::Static(_) => SignalUpdate::Ignore,
545: 543:                 _ => SignalUpdate::Update,
546: 544:             })
547: 545:         }
548: 546:     });
549: 547: 
550: 548:     let animated_signal = Signal::derive(move || {
551: 549:         animation_tick.track();
552: 550: 
553: 551:         let i: I = animation_status.with_value(|animation_status| match animation_status {
554: 552:             AnimationStatus::Static(state) | AnimationStatus::Snap(state) => {
555: 553:                 tween(state, state, 1.0)
556: 554:             }
557: 555:             AnimationStatus::Running {
558: 556:                 animations, to_i, ..
559: 557:             } => {
560: 558:                 // Keep this signal updated in the animation loop
561: 559:                 context.request_animation_frame();
562: 560: 
563: 561:                 // Add all animation results to a single value
564: 562:                 animations.iter().fold(to_i.clone(), |acc, animation| {
565: 563:                     let animation_value =
566: 564:                         tween(&animation.from, &animation.to, animation.progress());
567: 565: 
568: 566:                     acc - (animation.to_i.clone() - animation_value)
569: 567:                 })
570: 568:             }
571: 569:         });
572: 570:         i
573: 571:     });
574: 572: 
575: 573:     AnimatedSignal {
576: 574:         animation_status,
577: 575:         update_animation_status_effect,
578: 576:         animation_tick,
579: 577:         animated_signal,
580: 578:     }
581: 579: }
582: 580: 
583: 581: /// Default linear tween between any type of number
584: 582: pub fn tween_default<T, I>(from: &T, to: &T, progress: f64) -> I
585: 583: where
586: 584:     T: Copy,
587: 585:     T: Sub<T, Output = I>,
588: 586:     I: Mul<f64, Output = I>,
589: 587:     I: Add<T, Output = I>,
590: 588: {
591: 589:     (*to - *from) * progress + *from
592: 590: }
593: 591: 
594: 592: #[derive(Copy, Clone)]
595: 593: pub struct AnimatedSignal<T: 'static, I: 'static> {
596: 594:     animation_status: StoredValue<AnimationStatus<T, I>>,
597: 595:     update_animation_status_effect: Effect<()>,
598: 596:     animation_tick: Memo<SignalUpdate>,
599: 597:     animated_signal: Signal<I>,
600: 598: }
601: 599: 
602: 600: impl<T, I> Deref for AnimatedSignal<T, I> {
603: 601:     type Target = Signal<I>;
604: 602: 
605: 603:     fn deref(&self) -> &Self::Target {
606: 604:         &self.animated_signal
607: 605:     }
608: 606: }
609: 607: 
610: 608: impl<T, I> SignalDispose for AnimatedSignal<T, I> {
611: 609:     fn dispose(self) {
612: 610:         self.animation_status.dispose();
613: 611:         self.animation_tick.dispose();
614: 612:         self.update_animation_status_effect.dispose();
615: 613:         self.animated_signal.dispose();
616: 614:     }
617: 615: }
618: 616: 
619: 617: impl<T, I> IntoView for AnimatedSignal<T, I>
620: 618: where
621: 619:     I: IntoView + Clone,
622: 620: {
623: 621:     fn into_view(self) -> View {
624: 622:         self.animated_signal.into_view()
625: 623:     }
626: 624: }
627: 625: ```
628: 626: ```
629: 627: ```
630: 628: ```
631: 629: ```
632: 630: ```
633: 631: ```
634: 632: ```
635: 633: ```
636: 634: ```
637: 635: ```
638: 636: ```
639: 637: ```
640: 638: ```
641: 639: ```
642: 640: ```
643: 641: ```
644: 642: ```
645: 643: ```
646: 644: ```
647: 645: ```
648: 646: ```
649: 647: ```
650: 648: ```
651: 649: ```
652: 650: ```
653: ```
```
