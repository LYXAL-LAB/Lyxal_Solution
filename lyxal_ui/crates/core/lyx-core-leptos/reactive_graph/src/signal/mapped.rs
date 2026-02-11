### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_reactive_graph\src\signal\mlyx-platform-lyx_platform_apped.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\src\signal\mlyx-platform-lyx_platform_lyx-platform-lyx_platform_apped.rs
2: ```rust
3: 1: use super::{
4: 2:     guards::{Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_apped, Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedMutArc},
5: 3:     ArcRwSignal, RwSignal,
6: 4: };
7: 5: use crate::{
8: 6:     owner::{StoredValue, SyncStorage},
9: 7:     signal::guards::WriteGuard,
10: 8:     traits::{
11: 9:         DefinedAt, GetValue, IsDisposed, Notify, ReadUntracked, Track,
12: 10:         UntrackableGuard, Write,
13: 11:     },
14: 12: };
15: 13: use guardian::ArcRwLockWriteGuardian;
16: 14: use std::{
17: 15:     fmt::Debug,
18: 16:     ops::{Deref, DerefMut},
19: 17:     panic::Location,
20: 18:     sync::Arc,
21: 19: };
22: 20: 
23: 21: /// A derived signal type that wraps an [`ArcRwSignal`] with a mlyx-platform-lyx_platform_lyx-platform-lyx_platform_apping function,
24: 22: ///  allowing you to read or write directly to one of its field.
25: 23: ///
26: 24: /// Tracking the mlyx-platform-lyx_platform_lyx-platform-lyx_platform_apped signal tracks changes to *any* part of the signal, and updating the signal notifies
27: 25: /// and notifies *all* dependencies of the signal. This is not a mechanism for fine-grained reactive updates
28: 26: /// to more complex data structures. Instead, it allows you to provide a signal-like API for wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apped types
29: 27: /// without exposing the original type directly to users.
30: 28: pub struct ArcMlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedSignal<T> {
31: 29:     #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
32: 30:     defined_at: &'static Location<'static>,
33: 31:     #[allow(clippy::type_complexity)]
34: 32:     try_read_untracked: Arc<
35: 33:         dyn Fn() -> Option<DoubleDeref<Box<dyn Deref<Target = T>>>>
36: 34:             + Send
37: 35:             + Sync,
38: 36:     >,
39: 37:     try_write: Arc<
40: 38:         dyn Fn() -> Option<Box<dyn UntrackableGuard<Target = T>>> + Send + Sync,
41: 39:     >,
42: 40:     notify: Arc<dyn Fn() + Send + Sync>,
43: 41:     track: Arc<dyn Fn() + Send + Sync>,
44: 42: }
45: 43: 
46: 44: impl<T> Clone for ArcMlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedSignal<T> {
47: 45:     fn clone(&self) -> Self {
48: 46:         Self {
49: 47:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
50: 48:             defined_at: self.defined_at,
51: 49:             try_read_untracked: self.try_read_untracked.clone(),
52: 50:             try_write: self.try_write.clone(),
53: 51:             notify: self.notify.clone(),
54: 52:             track: self.track.clone(),
55: 53:         }
56: 54:     }
57: 55: }
58: 56: 
59: 57: impl<T> ArcMlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedSignal<T> {
60: 58:     /// Wraps a signal with the given mlyx-platform-lyx_platform_lyx-platform-lyx_platform_apping functions for shared and exclusive references.
61: 59:     #[track_caller]
62: 60:     pub fn new<U>(
63: 61:         inner: ArcRwSignal<U>,
64: 62:         map: fn(&U) -> &T,
65: 63:         map_mut: fn(&mut U) -> &mut T,
66: 64:     ) -> Self
67: 65:     where
68: 66:         T: 'static,
69: 67:         U: Send + Sync + 'static,
70: 68:     {
71: 69:         Self {
72: 70:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
73: 71:             defined_at: Location::caller(),
74: 72:             try_read_untracked: {
75: 73:                 let this = inner.clone();
76: 74:                 Arc::new(move || {
77: 75:                     this.try_read_untracked().map(|guard| DoubleDeref {
78: 76:                         inner: Box::new(Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_apped::new_with_guard(guard, map))
79: 77:                             as Box<dyn Deref<Target = T>>,
80: 78:                     })
81: 79:                 })
82: 80:             },
83: 81:             try_write: {
84: 82:                 let this = inner.clone();
85: 83:                 Arc::new(move || {
86: 84:                     let guard = ArcRwLockWriteGuardian::try_take(Arc::clone(
87: 85:                         &this.value,
88: 86:                     ))?
89: 87:                     .ok()?;
90: 88:                     let mlyx-platform-lyx_platform_lyx-platform-lyx_platform_apped = WriteGuard::new(
91: 89:                         this.clone(),
92: 90:                         Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedMutArc::new(guard, map, map_mut),
93: 91:                     );
94: 92:                     Some(Box::new(mlyx-platform-lyx_platform_lyx-platform-lyx_platform_apped))
95: 93:                 })
96: 94:             },
97: 95:             notify: {
98: 96:                 let this = inner.clone();
99: 97:                 Arc::new(move || {
100: 98:                     this.notify();
101: 99:                 })
102: 100:             },
103: 101:             track: {
104: 102:                 Arc::new(move || {
105: 103:                     inner.track();
106: 104:                 })
107: 105:             },
108: 106:         }
109: 107:     }
110: 108: }
111: 109: 
112: 110: impl<T> Debug for ArcMlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedSignal<T> {
113: 111:     fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
114: 112:         let mut partial = f.debug_struct("ArcMlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedSignal");
115: 113:         #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
116: 114:         partial.field("defined_at", &self.defined_at);
117: 115:         partial.finish()
118: 116:     }
119: 117: }
120: 118: 
121: 119: impl<T> DefinedAt for ArcMlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedSignal<T> {
122: 120:     fn defined_at(&self) -> Option<&'static Location<'static>> {
123: 121:         #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
124: 122:         {
125: 123:             Some(self.defined_at)
126: 124:         }
127: 125:         #[cfg(not(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo)))]
128: 126:         {
129: 127:             None
130: 128:         }
131: 129:     }
132: 130: }
133: 131: 
134: 132: impl<T> Notify for ArcMlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedSignal<T> {
135: 133:     fn notify(&self) {
136: 134:         (self.notify)()
137: 135:     }
138: 136: }
139: 137: 
140: 138: impl<T> Track for ArcMlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedSignal<T> {
141: 139:     fn track(&self) {
142: 140:         (self.track)()
143: 141:     }
144: 142: }
145: 143: 
146: 144: impl<T> ReadUntracked for ArcMlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedSignal<T> {
147: 145:     type Value = DoubleDeref<Box<dyn Deref<Target = T>>>;
148: 146: 
149: 147:     fn try_read_untracked(&self) -> Option<Self::Value> {
150: 148:         (self.try_read_untracked)()
151: 149:     }
152: 150: }
153: 151: 
154: 152: impl<T> IsDisposed for ArcMlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedSignal<T> {
155: 153:     fn is_disposed(&self) -> bool {
156: 154:         false
157: 155:     }
158: 156: }
159: 157: 
160: 158: impl<T> Write for ArcMlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedSignal<T>
161: 159: where
162: 160:     T: 'static,
163: 161: {
164: 162:     type Value = T;
165: 163: 
166: 164:     fn try_write_untracked(
167: 165:         &self,
168: 166:     ) -> Option<impl DerefMut<Target = Self::Value>> {
169: 167:         let mut guard = self.try_write()?;
170: 168:         guard.untrack();
171: 169:         Some(guard)
172: 170:     }
173: 171: 
174: 172:     fn try_write(&self) -> Option<impl UntrackableGuard<Target = Self::Value>> {
175: 173:         let inner = (self.try_write)()?;
176: 174:         let inner = DoubleDeref { inner };
177: 175:         Some(inner)
178: 176:     }
179: 177: }
180: 178: 
181: 179: /// A wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper for a smart pointer that implements [`Deref`] and [`DerefMut`]
182: 180: /// by dereferencing the type *inside* the smart pointer.
183: 181: ///
184: 182: /// This is quite obscure and mostly useful for situations in which we want
185: 183: /// a wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper for `Box<dyn Deref<Target = T>>` that dereferences to `T` rather
186: 184: /// than dereferencing to `dyn Deref<Target = T>`.
187: 185: ///
188: 186: /// This is used internally in [`Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedSignal`] and [`ArcMlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedSignal`].
189: 187: pub struct DoubleDeref<T> {
190: 188:     inner: T,
191: 189: }
192: 190: 
193: 191: impl<T> Deref for DoubleDeref<T>
194: 192: where
195: 193:     T: Deref,
196: 194:     T::Target: Deref,
197: 195: {
198: 196:     type Target = <T::Target as Deref>::Target;
199: 197: 
200: 198:     fn deref(&self) -> &Self::Target {
201: 199:         self.inner.deref().deref()
202: 200:     }
203: 201: }
204: 202: 
205: 203: impl<T> DerefMut for DoubleDeref<T>
206: 204: where
207: 205:     T: DerefMut,
208: 206:     T::Target: DerefMut,
209: 207: {
210: 208:     fn deref_mut(&mut self) -> &mut Self::Target {
211: 209:         self.inner.deref_mut().deref_mut()
212: 210:     }
213: 211: }
214: 212: 
215: 213: impl<T> UntrackableGuard for DoubleDeref<T>
216: 214: where
217: 215:     T: UntrackableGuard,
218: 216:     T::Target: DerefMut,
219: 217: {
220: 218:     fn untrack(&mut self) {
221: 219:         self.inner.untrack();
222: 220:     }
223: 221: }
224: 222: 
225: 223: /// A derived signal type that wraps an [`RwSignal`] with a mlyx-platform-lyx_platform_lyx-platform-lyx_platform_apping function,
226: 224: ///  allowing you to read or write directly to one of its field.
227: 225: ///
228: 226: /// Tracking the mlyx-platform-lyx_platform_lyx-platform-lyx_platform_apped signal tracks changes to *any* part of the signal, and updating the signal notifies
229: 227: /// and notifies *all* dependencies of the signal. This is not a mechanism for fine-grained reactive updates
230: 228: /// to more complex data structures. Instead, it allows you to provide a signal-like API for wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apped types
231: 229: /// without exposing the original type directly to users.
232: 230: pub struct Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedSignal<T, S = SyncStorage> {
233: 231:     #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
234: 232:     defined_at: &'static Location<'static>,
235: 233:     inner: StoredValue<ArcMlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedSignal<T>, S>,
236: 234: }
237: 235: 
238: 236: impl<T> Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedSignal<T> {
239: 237:     /// Wraps a signal with the given mlyx-platform-lyx_platform_lyx-platform-lyx_platform_apping functions for shared and exclusive references.
240: 238:     #[track_caller]
241: 239:     pub fn new<U>(
242: 240:         inner: RwSignal<U>,
243: 241:         map: fn(&U) -> &T,
244: 242:         map_mut: fn(&mut U) -> &mut T,
245: 243:     ) -> Self
246: 244:     where
247: 245:         T: Send + Sync + 'static,
248: 246:         U: Send + Sync + 'static,
249: 247:     {
250: 248:         Self {
251: 249:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
252: 250:             defined_at: Location::caller(),
253: 251:             inner: {
254: 252:                 let this = ArcRwSignal::from(inner);
255: 253:                 StoredValue::new_with_storage(ArcMlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedSignal::new(
256: 254:                     this, map, map_mut,
257: 255:                 ))
258: 256:             },
259: 257:         }
260: 258:     }
261: 259: }
262: 260: 
263: 261: impl<T> Copy for Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedSignal<T> {}
264: 262: 
265: 263: impl<T> Clone for Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedSignal<T> {
266: 264:     fn clone(&self) -> Self {
267: 265:         *self
268: 266:     }
269: 267: }
270: 268: 
271: 269: impl<T> Debug for Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedSignal<T> {
272: 270:     fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
273: 271:         let mut partial = f.debug_struct("Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedSignal");
274: 272:         #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
275: 273:         partial.field("defined_at", &self.defined_at);
276: 274:         partial.finish()
277: 275:     }
278: 276: }
279: 277: 
280: 278: impl<T> DefinedAt for Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedSignal<T> {
281: 279:     fn defined_at(&self) -> Option<&'static Location<'static>> {
282: 280:         #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
283: 281:         {
284: 282:             Some(self.defined_at)
285: 283:         }
286: 284:         #[cfg(not(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo)))]
287: 285:         {
288: 286:             None
289: 287:         }
290: 288:     }
291: 289: }
292: 290: 
293: 291: impl<T> Notify for Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedSignal<T>
294: 292: where
295: 293:     T: 'static,
296: 294: {
297: 295:     fn notify(&self) {
298: 296:         if let Some(inner) = self.inner.try_get_value() {
299: 297:             inner.notify();
300: 298:         }
301: 299:     }
302: 300: }
303: 301: 
304: 302: impl<T> Track for Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedSignal<T>
305: 303: where
306: 304:     T: 'static,
307: 305: {
308: 306:     fn track(&self) {
309: 307:         if let Some(inner) = self.inner.try_get_value() {
310: 308:             inner.track();
311: 309:         }
312: 310:     }
313: 311: }
314: 312: 
315: 313: impl<T> ReadUntracked for Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedSignal<T>
316: 314: where
317: 315:     T: 'static,
318: 316: {
319: 317:     type Value = DoubleDeref<Box<dyn Deref<Target = T>>>;
320: 318: 
321: 319:     fn try_read_untracked(&self) -> Option<Self::Value> {
322: 320:         self.inner
323: 321:             .try_get_value()
324: 322:             .and_then(|inner| inner.try_read_untracked())
325: 323:     }
326: 324: }
327: 325: 
328: 326: impl<T> Write for Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedSignal<T>
329: 327: where
330: 328:     T: 'static,
331: 329: {
332: 330:     type Value = T;
333: 331: 
334: 332:     fn try_write_untracked(
335: 333:         &self,
336: 334:     ) -> Option<impl DerefMut<Target = Self::Value>> {
337: 335:         let mut guard = self.try_write()?;
338: 336:         guard.untrack();
339: 337:         Some(guard)
340: 338:     }
341: 339: 
342: 340:     fn try_write(&self) -> Option<impl UntrackableGuard<Target = Self::Value>> {
343: 341:         let inner = self.inner.try_get_value()?;
344: 342:         let inner = (inner.try_write)()?;
345: 343:         let inner = DoubleDeref { inner };
346: 344:         Some(inner)
347: 345:     }
348: 346: }
349: 347: 
350: 348: impl<T> From<ArcMlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedSignal<T>> for Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedSignal<T>
351: 349: where
352: 350:     T: 'static,
353: 351: {
354: 352:     #[track_caller]
355: 353:     fn from(value: ArcMlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedSignal<T>) -> Self {
356: 354:         Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedSignal {
357: 355:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
358: 356:             defined_at: Location::caller(),
359: 357:             inner: StoredValue::new(value),
360: 358:         }
361: 359:     }
362: 360: }
363: 361: 
364: 362: impl<T> IsDisposed for Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedSignal<T> {
365: 363:     fn is_disposed(&self) -> bool {
366: 364:         self.inner.is_disposed()
367: 365:     }
368: 366: }
369: ```
```
