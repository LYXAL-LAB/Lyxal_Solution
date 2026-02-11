### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_reactive_stores\src\iter.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_reactive_stores\src\iter.rs
2: ```rust
3: 1: use crate::{
4: 2:     len::Len,
5: 3:     path::{StorePath, StorePathSegment},
6: 4:     store_field::StoreField,
7: 5:     KeyMap, StoreFieldTrigger,
8: 6: };
9: 7: use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::{
10: 8:     signal::{
11: 9:         guards::{Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedMutArc, WriteGuard},
12: 10:         ArcTrigger,
13: 11:     },
14: 12:     traits::{
15: 13:         DefinedAt, IsDisposed, Notify, ReadUntracked, Track, UntrackableGuard,
16: 14:         Write,
17: 15:     },
18: 16: };
19: 17: use std::{
20: 18:     iter,
21: 19:     marker::PhantomData,
22: 20:     ops::{DerefMut, IndexMut},
23: 21:     panic::Location,
24: 22: };
25: 23: 
26: 24: /// Provides access to the data at some index in another collection.
27: 25: #[derive(Debug)]
28: 26: pub struct AtIndex<Inner, Prev> {
29: 27:     #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
30: 28:     defined_at: &'static Location<'static>,
31: 29:     inner: Inner,
32: 30:     index: usize,
33: 31:     ty: PhantomData<Prev>,
34: 32: }
35: 33: 
36: 34: impl<Inner, Prev> Clone for AtIndex<Inner, Prev>
37: 35: where
38: 36:     Inner: Clone,
39: 37: {
40: 38:     fn clone(&self) -> Self {
41: 39:         Self {
42: 40:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
43: 41:             defined_at: self.defined_at,
44: 42:             inner: self.inner.clone(),
45: 43:             index: self.index,
46: 44:             ty: self.ty,
47: 45:         }
48: 46:     }
49: 47: }
50: 48: 
51: 49: impl<Inner, Prev> Copy for AtIndex<Inner, Prev> where Inner: Copy {}
52: 50: 
53: 51: impl<Inner, Prev> AtIndex<Inner, Prev> {
54: 52:     /// Creates a new accessor for the inner collection at the given index.
55: 53:     #[track_caller]
56: 54:     pub fn new(inner: Inner, index: usize) -> Self {
57: 55:         Self {
58: 56:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
59: 57:             defined_at: Location::caller(),
60: 58:             inner,
61: 59:             index,
62: 60:             ty: PhantomData,
63: 61:         }
64: 62:     }
65: 63: }
66: 64: 
67: 65: impl<Inner, Prev> StoreField for AtIndex<Inner, Prev>
68: 66: where
69: 67:     Inner: StoreField<Value = Prev>,
70: 68:     Prev: IndexMut<usize> + 'static,
71: 69:     Prev::Output: Sized,
72: 70: {
73: 71:     type Value = Prev::Output;
74: 72:     type Reader = Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedMutArc<Inner::Reader, Prev::Output>;
75: 73:     type Writer =
76: 74:         Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedMutArc<WriteGuard<ArcTrigger, Inner::Writer>, Prev::Output>;
77: 75: 
78: 76:     fn path(&self) -> impl IntoIterator<Item = StorePathSegment> {
79: 77:         self.inner
80: 78:             .path()
81: 79:             .into_iter()
82: 80:             .chain(iter::once(self.index.into()))
83: 81:     }
84: 82: 
85: 83:     fn path_unkeyed(&self) -> impl IntoIterator<Item = StorePathSegment> {
86: 84:         self.inner
87: 85:             .path_unkeyed()
88: 86:             .into_iter()
89: 87:             .chain(iter::once(self.index.into()))
90: 88:     }
91: 89: 
92: 90:     fn get_trigger(&self, path: StorePath) -> StoreFieldTrigger {
93: 91:         self.inner.get_trigger(path)
94: 92:     }
95: 93: 
96: 94:     fn get_trigger_unkeyed(&self, path: StorePath) -> StoreFieldTrigger {
97: 95:         self.inner.get_trigger_unkeyed(path)
98: 96:     }
99: 97: 
100: 98:     fn reader(&self) -> Option<Self::Reader> {
101: 99:         let inner = self.inner.reader()?;
102: 100:         let index = self.index;
103: 101:         Some(Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedMutArc::new(
104: 102:             inner,
105: 103:             move |n| &n[index],
106: 104:             move |n| &mut n[index],
107: 105:         ))
108: 106:     }
109: 107: 
110: 108:     fn writer(&self) -> Option<Self::Writer> {
111: 109:         let trigger = self.get_trigger(self.path().into_iter().collect());
112: 110:         let inner = WriteGuard::new(trigger.children, self.inner.writer()?);
113: 111:         let index = self.index;
114: 112:         Some(Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedMutArc::new(
115: 113:             inner,
116: 114:             move |n| &n[index],
117: 115:             move |n| &mut n[index],
118: 116:         ))
119: 117:     }
120: 118: 
121: 119:     #[inline(always)]
122: 120:     fn keys(&self) -> Option<KeyMap> {
123: 121:         self.inner.keys()
124: 122:     }
125: 123: 
126: 124:     fn track_field(&self) {
127: 125:         let mut full_path = self.path().into_iter().collect::<StorePath>();
128: 126:         let trigger = self.get_trigger(self.path().into_iter().collect());
129: 127:         trigger.this.track();
130: 128:         trigger.children.track();
131: 129: 
132: 130:         // tracks `this` for all ancestors: i.e., it will track any change that is made
133: 131:         // directly to one of its ancestors, but not a change made to a *child* of an ancestor
134: 132:         // (which would end up with every subfield tracking its own siblings, because they are
135: 133:         // children of its parent)
136: 134:         while !full_path.is_empty() {
137: 135:             full_path.pop();
138: 136:             let inner = self.get_trigger(full_path.clone());
139: 137:             inner.this.track();
140: 138:         }
141: 139:     }
142: 140: }
143: 141: 
144: 142: impl<Inner, Prev> DefinedAt for AtIndex<Inner, Prev>
145: 143: where
146: 144:     Inner: StoreField<Value = Prev>,
147: 145: {
148: 146:     fn defined_at(&self) -> Option<&'static Location<'static>> {
149: 147:         #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
150: 148:         {
151: 149:             Some(self.defined_at)
152: 150:         }
153: 151:         #[cfg(not(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo)))]
154: 152:         {
155: 153:             None
156: 154:         }
157: 155:     }
158: 156: }
159: 157: 
160: 158: impl<Inner, Prev> IsDisposed for AtIndex<Inner, Prev>
161: 159: where
162: 160:     Inner: StoreField<Value = Prev> + IsDisposed,
163: 161: {
164: 162:     fn is_disposed(&self) -> bool {
165: 163:         self.inner.is_disposed()
166: 164:     }
167: 165: }
168: 166: 
169: 167: impl<Inner, Prev> Notify for AtIndex<Inner, Prev>
170: 168: where
171: 169:     Inner: StoreField<Value = Prev>,
172: 170:     Prev: IndexMut<usize> + 'static,
173: 171:     Prev::Output: Sized,
174: 172: {
175: 173:     fn notify(&self) {
176: 174:         let trigger = self.get_trigger(self.path().into_iter().collect());
177: 175:         trigger.this.notify();
178: 176:     }
179: 177: }
180: 178: 
181: 179: impl<Inner, Prev> Track for AtIndex<Inner, Prev>
182: 180: where
183: 181:     Inner: StoreField<Value = Prev> + Send + Sync + Clone + 'static,
184: 182:     Prev: IndexMut<usize> + 'static,
185: 183:     Prev::Output: Sized + 'static,
186: 184: {
187: 185:     fn track(&self) {
188: 186:         self.track_field();
189: 187:     }
190: 188: }
191: 189: 
192: 190: impl<Inner, Prev> ReadUntracked for AtIndex<Inner, Prev>
193: 191: where
194: 192:     Inner: StoreField<Value = Prev>,
195: 193:     Prev: IndexMut<usize> + 'static,
196: 194:     Prev::Output: Sized,
197: 195: {
198: 196:     type Value = <Self as StoreField>::Reader;
199: 197: 
200: 198:     fn try_read_untracked(&self) -> Option<Self::Value> {
201: 199:         self.reader()
202: 200:     }
203: 201: }
204: 202: 
205: 203: impl<Inner, Prev> Write for AtIndex<Inner, Prev>
206: 204: where
207: 205:     Inner: StoreField<Value = Prev>,
208: 206:     Prev: IndexMut<usize> + 'static,
209: 207:     Prev::Output: Sized + 'static,
210: 208: {
211: 209:     type Value = Prev::Output;
212: 210: 
213: 211:     fn try_write(&self) -> Option<impl UntrackableGuard<Target = Self::Value>> {
214: 212:         self.writer()
215: 213:     }
216: 214: 
217: 215:     fn try_write_untracked(
218: 216:         &self,
219: 217:     ) -> Option<impl DerefMut<Target = Self::Value>> {
220: 218:         self.writer().map(|mut writer| {
221: 219:             writer.untrack();
222: 220:             writer
223: 221:         })
224: 222:     }
225: 223: }
226: 224: 
227: 225: /// Provides unkeyed reactive access to the fields of some collection.
228: 226: pub trait StoreFieldIterator<Prev>
229: 227: where
230: 228:     Self: StoreField<Value = Prev>,
231: 229: {
232: 230:     /// Reactive access to the value at some index.
233: 231:     fn at_unkeyed(self, index: usize) -> AtIndex<Self, Prev>;
234: 232: 
235: 233:     /// An iterator over the values in the collection.
236: 234:     fn iter_unkeyed(self) -> StoreFieldIter<Self, Prev>;
237: 235: }
238: 236: 
239: 237: impl<Inner, Prev> StoreFieldIterator<Prev> for Inner
240: 238: where
241: 239:     Inner: StoreField<Value = Prev> + Clone,
242: 240:     Prev::Output: Sized,
243: 241:     Prev: IndexMut<usize> + Len,
244: 242: {
245: 243:     #[track_caller]
246: 244:     fn at_unkeyed(self, index: usize) -> AtIndex<Inner, Prev> {
247: 245:         AtIndex::new(self.clone(), index)
248: 246:     }
249: 247: 
250: 248:     #[track_caller]
251: 249:     fn iter_unkeyed(self) -> StoreFieldIter<Inner, Prev> {
252: 250:         // reactively track changes to this field
253: 251:         let trigger = self.get_trigger(self.path().into_iter().collect());
254: 252:         trigger.this.track();
255: 253:         trigger.children.track();
256: 254: 
257: 255:         // get the current length of the field by accessing slice
258: 256:         let len = self.reader().map(|n| n.len()).unwrap_or(0);
259: 257: 
260: 258:         // return the iterator
261: 259:         StoreFieldIter {
262: 260:             inner: self,
263: 261:             idx: 0,
264: 262:             len,
265: 263:             prev: PhantomData,
266: 264:         }
267: 265:     }
268: 266: }
269: 267: 
270: 268: /// An iterator over the values in a collection, as reactive fields.
271: 269: pub struct StoreFieldIter<Inner, Prev> {
272: 270:     inner: Inner,
273: 271:     idx: usize,
274: 272:     len: usize,
275: 273:     prev: PhantomData<Prev>,
276: 274: }
277: 275: 
278: 276: impl<Inner, Prev> Iterator for StoreFieldIter<Inner, Prev>
279: 277: where
280: 278:     Inner: StoreField<Value = Prev> + Clone + 'static,
281: 279:     Prev: IndexMut<usize> + 'static,
282: 280:     Prev::Output: Sized + 'static,
283: 281: {
284: 282:     type Item = AtIndex<Inner, Prev>;
285: 283: 
286: 284:     fn next(&mut self) -> Option<Self::Item> {
287: 285:         if self.idx < self.len {
288: 286:             let field = AtIndex::new(self.inner.clone(), self.idx);
289: 287:             self.idx += 1;
290: 288:             Some(field)
291: 289:         } else {
292: 290:             None
293: 291:         }
294: 292:     }
295: 293: }
296: 294: 
297: 295: impl<Inner, Prev> DoubleEndedIterator for StoreFieldIter<Inner, Prev>
298: 296: where
299: 297:     Inner: StoreField<Value = Prev> + Clone + 'static,
300: 298:     Prev: IndexMut<usize> + 'static,
301: 299:     Prev::Output: Sized + 'static,
302: 300: {
303: 301:     fn next_back(&mut self) -> Option<Self::Item> {
304: 302:         if self.len > self.idx {
305: 303:             self.len -= 1;
306: 304:             let field = AtIndex::new(self.inner.clone(), self.len);
307: 305:             Some(field)
308: 306:         } else {
309: 307:             None
310: 308:         }
311: 309:     }
312: 310: }
313: ```
```
