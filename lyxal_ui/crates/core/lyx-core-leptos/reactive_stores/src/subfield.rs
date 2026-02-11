### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_reactive_stores\src\subfield.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_reactive_stores\src\subfield.rs
2: ```rust
3: 1: use crate::{
4: 2:     path::{StorePath, StorePathSegment},
5: 3:     store_field::StoreField,
6: 4:     KeyMap, StoreFieldTrigger,
7: 5: };
8: 6: use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::{
9: 7:     signal::{
10: 8:         guards::{Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_apped, Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedMut, WriteGuard},
11: 9:         ArcTrigger,
12: 10:     },
13: 11:     traits::{
14: 12:         DefinedAt, Get as _, IsDisposed, Notify, ReadUntracked, Track,
15: 13:         UntrackableGuard, Write,
16: 14:     },
17: 15:     wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_appers::read::Signal,
18: 16: };
19: 17: use std::{iter, marker::PhantomData, ops::DerefMut, panic::Location};
20: 18: 
21: 19: /// Accesses a single field of a reactive structure.
22: 20: #[derive(Debug)]
23: 21: pub struct Subfield<Inner, Prev, T> {
24: 22:     #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
25: 23:     defined_at: &'static Location<'static>,
26: 24:     path_segment: StorePathSegment,
27: 25:     inner: Inner,
28: 26:     read: fn(&Prev) -> &T,
29: 27:     write: fn(&mut Prev) -> &mut T,
30: 28:     ty: PhantomData<T>,
31: 29: }
32: 30: 
33: 31: impl<Inner, Prev, T> Clone for Subfield<Inner, Prev, T>
34: 32: where
35: 33:     Inner: Clone,
36: 34: {
37: 35:     fn clone(&self) -> Self {
38: 36:         Self {
39: 37:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
40: 38:             defined_at: self.defined_at,
41: 39:             path_segment: self.path_segment,
42: 40:             inner: self.inner.clone(),
43: 41:             read: self.read,
44: 42:             write: self.write,
45: 43:             ty: self.ty,
46: 44:         }
47: 45:     }
48: 46: }
49: 47: 
50: 48: impl<Inner, Prev, T> Copy for Subfield<Inner, Prev, T> where Inner: Copy {}
51: 49: 
52: 50: impl<Inner, Prev, T> Subfield<Inner, Prev, T> {
53: 51:     /// Creates an accessor for a single field of the inner structure.
54: 52:     #[track_caller]
55: 53:     pub fn new(
56: 54:         inner: Inner,
57: 55:         path_segment: StorePathSegment,
58: 56:         read: fn(&Prev) -> &T,
59: 57:         write: fn(&mut Prev) -> &mut T,
60: 58:     ) -> Self {
61: 59:         Self {
62: 60:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
63: 61:             defined_at: Location::caller(),
64: 62:             inner,
65: 63:             path_segment,
66: 64:             read,
67: 65:             write,
68: 66:             ty: PhantomData,
69: 67:         }
70: 68:     }
71: 69: }
72: 70: 
73: 71: impl<Inner, Prev, T> StoreField for Subfield<Inner, Prev, T>
74: 72: where
75: 73:     Inner: StoreField<Value = Prev>,
76: 74:     Prev: 'static,
77: 75: {
78: 76:     type Value = T;
79: 77:     type Reader = Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_apped<Inner::Reader, T>;
80: 78:     type Writer = Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedMut<WriteGuard<Vec<ArcTrigger>, Inner::Writer>, T>;
81: 79: 
82: 80:     fn path(&self) -> impl IntoIterator<Item = StorePathSegment> {
83: 81:         self.inner
84: 82:             .path()
85: 83:             .into_iter()
86: 84:             .chain(iter::once(self.path_segment))
87: 85:     }
88: 86: 
89: 87:     fn path_unkeyed(&self) -> impl IntoIterator<Item = StorePathSegment> {
90: 88:         self.inner
91: 89:             .path_unkeyed()
92: 90:             .into_iter()
93: 91:             .chain(iter::once(self.path_segment))
94: 92:     }
95: 93: 
96: 94:     fn get_trigger(&self, path: StorePath) -> StoreFieldTrigger {
97: 95:         self.inner.get_trigger(path)
98: 96:     }
99: 97: 
100: 98:     fn get_trigger_unkeyed(&self, path: StorePath) -> StoreFieldTrigger {
101: 99:         self.inner.get_trigger_unkeyed(path)
102: 100:     }
103: 101: 
104: 102:     fn reader(&self) -> Option<Self::Reader> {
105: 103:         let inner = self.inner.reader()?;
106: 104:         Some(Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_apped::new_with_guard(inner, self.read))
107: 105:     }
108: 106: 
109: 107:     fn writer(&self) -> Option<Self::Writer> {
110: 108:         let mut parent = self.inner.writer()?;
111: 109: 
112: 110:         // we will manually include all the parent and ancestor `children` triggers
113: 111:         // in triggers_for_current_path() below. we want to untrack the parent writer
114: 112:         // so that it doesn't notify on the parent's `this` trigger, which would notify our
115: 113:         // siblings too
116: 114:         parent.untrack();
117: 115:         let triggers = self.triggers_for_current_path();
118: 116:         let guard = WriteGuard::new(triggers, parent);
119: 117:         Some(Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedMut::new(guard, self.read, self.write))
120: 118:     }
121: 119: 
122: 120:     #[inline(always)]
123: 121:     fn keys(&self) -> Option<KeyMap> {
124: 122:         self.inner.keys()
125: 123:     }
126: 124: 
127: 125:     #[track_caller]
128: 126:     fn track_field(&self) {
129: 127:         let mut full_path = self.path().into_iter().collect::<StorePath>();
130: 128:         let trigger = self.get_trigger(self.path().into_iter().collect());
131: 129:         trigger.this.track();
132: 130:         trigger.children.track();
133: 131: 
134: 132:         // tracks `this` for all ancestors: i.e., it will track any change that is made
135: 133:         // directly to one of its ancestors, but not a change made to a *child* of an ancestor
136: 134:         // (which would end up with every subfield tracking its own siblings, because they are
137: 135:         // children of its parent)
138: 136:         while !full_path.is_empty() {
139: 137:             full_path.pop();
140: 138:             let inner = self.get_trigger(full_path.clone());
141: 139:             inner.this.track();
142: 140:         }
143: 141:     }
144: 142: }
145: 143: 
146: 144: impl<Inner, Prev, T> DefinedAt for Subfield<Inner, Prev, T>
147: 145: where
148: 146:     Inner: StoreField<Value = Prev>,
149: 147: {
150: 148:     fn defined_at(&self) -> Option<&'static Location<'static>> {
151: 149:         #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
152: 150:         {
153: 151:             Some(self.defined_at)
154: 152:         }
155: 153:         #[cfg(not(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo)))]
156: 154:         {
157: 155:             None
158: 156:         }
159: 157:     }
160: 158: }
161: 159: 
162: 160: impl<Inner, Prev, T> IsDisposed for Subfield<Inner, Prev, T>
163: 161: where
164: 162:     Inner: IsDisposed,
165: 163: {
166: 164:     fn is_disposed(&self) -> bool {
167: 165:         self.inner.is_disposed()
168: 166:     }
169: 167: }
170: 168: 
171: 169: impl<Inner, Prev, T> Notify for Subfield<Inner, Prev, T>
172: 170: where
173: 171:     Inner: StoreField<Value = Prev>,
174: 172:     Prev: 'static,
175: 173: {
176: 174:     #[track_caller]
177: 175:     fn notify(&self) {
178: 176:         let trigger = self.get_trigger(self.path().into_iter().collect());
179: 177:         trigger.this.notify();
180: 178:         trigger.children.notify();
181: 179:     }
182: 180: }
183: 181: 
184: 182: impl<Inner, Prev, T> Track for Subfield<Inner, Prev, T>
185: 183: where
186: 184:     Inner: StoreField<Value = Prev> + Track + 'static,
187: 185:     Prev: 'static,
188: 186:     T: 'static,
189: 187: {
190: 188:     #[track_caller]
191: 189:     fn track(&self) {
192: 190:         self.track_field();
193: 191:     }
194: 192: }
195: 193: 
196: 194: impl<Inner, Prev, T> ReadUntracked for Subfield<Inner, Prev, T>
197: 195: where
198: 196:     Inner: StoreField<Value = Prev>,
199: 197:     Prev: 'static,
200: 198: {
201: 199:     type Value = <Self as StoreField>::Reader;
202: 200: 
203: 201:     fn try_read_untracked(&self) -> Option<Self::Value> {
204: 202:         self.reader()
205: 203:     }
206: 204: }
207: 205: 
208: 206: impl<Inner, Prev, T> Write for Subfield<Inner, Prev, T>
209: 207: where
210: 208:     T: 'static,
211: 209:     Inner: StoreField<Value = Prev>,
212: 210:     Prev: 'static,
213: 211: {
214: 212:     type Value = T;
215: 213: 
216: 214:     fn try_write(&self) -> Option<impl UntrackableGuard<Target = Self::Value>> {
217: 215:         self.writer()
218: 216:     }
219: 217: 
220: 218:     fn try_write_untracked(
221: 219:         &self,
222: 220:     ) -> Option<impl DerefMut<Target = Self::Value>> {
223: 221:         self.writer().map(|mut writer| {
224: 222:             writer.untrack();
225: 223:             writer
226: 224:         })
227: 225:     }
228: 226: }
229: 227: 
230: 228: impl<Inner, Prev, T> From<Subfield<Inner, Prev, T>> for Signal<T>
231: 229: where
232: 230:     Inner: StoreField<Value = Prev> + Track + Send + Sync + 'static,
233: 231:     Prev: 'static,
234: 232:     T: Send + Sync + Clone + 'static,
235: 233: {
236: 234:     fn from(subfield: Subfield<Inner, Prev, T>) -> Self {
237: 235:         Signal::derive(move || subfield.get())
238: 236:     }
239: 237: }
240: ```
```
