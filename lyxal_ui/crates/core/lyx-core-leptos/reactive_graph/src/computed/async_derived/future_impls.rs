### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_reactive_graph\src\computed\async_derived\future_impls.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\src\computed\async_derived\future_impls.rs
2: ```rust
3: 1: use super::{inner::ArcAsyncDerivedInner, ArcAsyncDerived, AsyncDerived};
4: 2: use crate::{
5: 3:     computed::suspense::SuspenseContext,
6: 4:     diagnostics::SpecialNonReactiveZone,
7: 5:     graph::{AnySource, ToAnySource},
8: 6:     owner::{use_context, Storage},
9: 7:     send_wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper_ext::SendOption,
10: 8:     signal::guards::{AsyncPlain, Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_apped, ReadGuard},
11: 9:     traits::{DefinedAt, Track},
12: 10:     unwrap_signal,
13: 11: };
14: 12: use futures::pin_mut;
15: 13: use lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned::OrPoisoned;
16: 14: use std::{
17: 15:     future::{Future, IntoFuture},
18: 16:     pin::Pin,
19: 17:     sync::{
20: 18:         atomic::{AtomicBool, Ordering},
21: 19:         Arc, RwLock,
22: 20:     },
23: 21:     task::{Context, Poll, Waker},
24: 22: };
25: 23: 
26: 24: /// A read guard that holds access to an async derived resource.
27: 25: ///
28: 26: /// Implements [`Deref`](std::ops::Deref) to access the inner value. This should not be held longer
29: 27: /// than it is needed, as it prevents updates to the inner value.
30: 28: pub type AsyncDerivedGuard<T> =
31: 29:     ReadGuard<T, Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_apped<AsyncPlain<SendOption<T>>, T>>;
32: 30: 
33: 31: /// A [`Future`] that is ready when an [`ArcAsyncDerived`] is finished loading or reloading,
34: 32: /// but does not contain its value.
35: 33: pub struct AsyncDerivedReadyFuture {
36: 34:     pub(crate) source: AnySource,
37: 35:     pub(crate) loading: Arc<AtomicBool>,
38: 36:     pub(crate) wakers: Arc<RwLock<Vec<Waker>>>,
39: 37: }
40: 38: 
41: 39: impl AsyncDerivedReadyFuture {
42: 40:     /// Creates a new [`Future`] that will be ready when the given resource is ready.
43: 41:     pub fn new(
44: 42:         source: AnySource,
45: 43:         loading: &Arc<AtomicBool>,
46: 44:         wakers: &Arc<RwLock<Vec<Waker>>>,
47: 45:     ) -> Self {
48: 46:         AsyncDerivedReadyFuture {
49: 47:             source,
50: 48:             loading: Arc::clone(loading),
51: 49:             wakers: Arc::clone(wakers),
52: 50:         }
53: 51:     }
54: 52: }
55: 53: 
56: 54: impl Future for AsyncDerivedReadyFuture {
57: 55:     type Output = ();
58: 56: 
59: 57:     fn poll(self: Pin<&mut Self>, cx: &mut Context<'_>) -> Poll<Self::Output> {
60: 58:         #[cfg(debug_assertions)]
61: 59:         let _guard = SpecialNonReactiveZone::enter();
62: 60:         let waker = cx.waker();
63: 61:         self.source.track();
64: 62:         if self.loading.load(Ordering::Relaxed) {
65: 63:             self.wakers.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned().push(waker.clone());
66: 64:             Poll::Pending
67: 65:         } else {
68: 66:             Poll::Ready(())
69: 67:         }
70: 68:     }
71: 69: }
72: 70: 
73: 71: impl<T> IntoFuture for ArcAsyncDerived<T>
74: 72: where
75: 73:     T: Clone + 'static,
76: 74: {
77: 75:     type Output = T;
78: 76:     type IntoFuture = AsyncDerivedFuture<T>;
79: 77: 
80: 78:     fn into_future(self) -> Self::IntoFuture {
81: 79:         AsyncDerivedFuture {
82: 80:             source: self.to_any_source(),
83: 81:             value: Arc::clone(&self.value),
84: 82:             loading: Arc::clone(&self.loading),
85: 83:             wakers: Arc::clone(&self.wakers),
86: 84:             inner: Arc::clone(&self.inner),
87: 85:         }
88: 86:     }
89: 87: }
90: 88: 
91: 89: impl<T, S> IntoFuture for AsyncDerived<T, S>
92: 90: where
93: 91:     T: Clone + 'static,
94: 92:     S: Storage<ArcAsyncDerived<T>>,
95: 93: {
96: 94:     type Output = T;
97: 95:     type IntoFuture = AsyncDerivedFuture<T>;
98: 96: 
99: 97:     #[track_caller]
100: 98:     fn into_future(self) -> Self::IntoFuture {
101: 99:         let this = self
102: 100:             .inner
103: 101:             .try_get_value()
104: 102:             .unwrap_or_else(unwrap_signal!(self));
105: 103:         this.into_future()
106: 104:     }
107: 105: }
108: 106: 
109: 107: /// A [`Future`] that is ready when an [`ArcAsyncDerived`] is finished loading or reloading,
110: 108: /// and contains its value. `.await`ing this clones the value `T`.
111: 109: pub struct AsyncDerivedFuture<T> {
112: 110:     source: AnySource,
113: 111:     value: Arc<async_lock::RwLock<SendOption<T>>>,
114: 112:     loading: Arc<AtomicBool>,
115: 113:     wakers: Arc<RwLock<Vec<Waker>>>,
116: 114:     inner: Arc<RwLock<ArcAsyncDerivedInner>>,
117: 115: }
118: 116: 
119: 117: impl<T> Future for AsyncDerivedFuture<T>
120: 118: where
121: 119:     T: Clone + 'static,
122: 120: {
123: 121:     type Output = T;
124: 122: 
125: 123:     #[track_caller]
126: 124:     fn poll(self: Pin<&mut Self>, cx: &mut Context<'_>) -> Poll<Self::Output> {
127: 125:         #[cfg(debug_assertions)]
128: 126:         let _guard = SpecialNonReactiveZone::enter();
129: 127:         let waker = cx.waker();
130: 128:         self.source.track();
131: 129:         let value = self.value.read_arc();
132: 130: 
133: 131:         if let Some(suspense_context) = use_context::<SuspenseContext>() {
134: 132:             self.inner
135: 133:                 .write()
136: 134:                 .lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned()
137: 135:                 .suspenses
138: 136:                 .push(suspense_context);
139: 137:         }
140: 138: 
141: 139:         pin_mut!(value);
142: 140:         match (self.loading.load(Ordering::Relaxed), value.poll(cx)) {
143: 141:             (true, _) => {
144: 142:                 self.wakers.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned().push(waker.clone());
145: 143:                 Poll::Pending
146: 144:             }
147: 145:             (_, Poll::Pending) => Poll::Pending,
148: 146:             (_, Poll::Ready(guard)) => {
149: 147:                 Poll::Ready(guard.as_ref().unwrap().clone())
150: 148:             }
151: 149:         }
152: 150:     }
153: 151: }
154: 152: 
155: 153: impl<T: 'static> ArcAsyncDerived<T> {
156: 154:     /// Returns a `Future` that resolves when the computation is finished, and accesses the inner
157: 155:     /// value by reference rather than by cloning it.
158: 156:     #[track_caller]
159: 157:     pub fn by_ref(&self) -> AsyncDerivedRefFuture<T> {
160: 158:         AsyncDerivedRefFuture {
161: 159:             source: self.to_any_source(),
162: 160:             value: Arc::clone(&self.value),
163: 161:             loading: Arc::clone(&self.loading),
164: 162:             wakers: Arc::clone(&self.wakers),
165: 163:         }
166: 164:     }
167: 165: }
168: 166: 
169: 167: impl<T, S> AsyncDerived<T, S>
170: 168: where
171: 169:     T: 'static,
172: 170:     S: Storage<ArcAsyncDerived<T>>,
173: 171: {
174: 172:     /// Returns a `Future` that resolves when the computation is finished, and accesses the inner
175: 173:     /// value by reference rather than by cloning it.
176: 174:     #[track_caller]
177: 175:     pub fn by_ref(&self) -> AsyncDerivedRefFuture<T> {
178: 176:         let this = self
179: 177:             .inner
180: 178:             .try_get_value()
181: 179:             .unwrap_or_else(unwrap_signal!(self));
182: 180:         this.by_ref()
183: 181:     }
184: 182: }
185: 183: 
186: 184: /// A [`Future`] that is ready when an [`ArcAsyncDerived`] is finished loading or reloading,
187: 185: /// and yields an [`AsyncDerivedGuard`] that dereferences to its value.
188: 186: pub struct AsyncDerivedRefFuture<T> {
189: 187:     source: AnySource,
190: 188:     value: Arc<async_lock::RwLock<SendOption<T>>>,
191: 189:     loading: Arc<AtomicBool>,
192: 190:     wakers: Arc<RwLock<Vec<Waker>>>,
193: 191: }
194: 192: 
195: 193: impl<T> Future for AsyncDerivedRefFuture<T>
196: 194: where
197: 195:     T: 'static,
198: 196: {
199: 197:     type Output = AsyncDerivedGuard<T>;
200: 198: 
201: 199:     fn poll(self: Pin<&mut Self>, cx: &mut Context<'_>) -> Poll<Self::Output> {
202: 200:         #[cfg(debug_assertions)]
203: 201:         let _guard = SpecialNonReactiveZone::enter();
204: 202:         let waker = cx.waker();
205: 203:         self.source.track();
206: 204:         let value = self.value.read_arc();
207: 205:         pin_mut!(value);
208: 206:         match (self.loading.load(Ordering::Relaxed), value.poll(cx)) {
209: 207:             (true, _) => {
210: 208:                 self.wakers.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned().push(waker.clone());
211: 209:                 Poll::Pending
212: 210:             }
213: 211:             (_, Poll::Pending) => Poll::Pending,
214: 212:             (_, Poll::Ready(guard)) => Poll::Ready(ReadGuard::new(
215: 213:                 Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_apped::new_with_guard(AsyncPlain { guard }, |guard| {
216: 214:                     guard.as_ref().unwrap()
217: 215:                 }),
218: 216:             )),
219: 217:         }
220: 218:     }
221: 219: }
222: ```
```
