### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_tachys\src\lyx-core-lyx_core_reactive_graph\property.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\property.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\property.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\property.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\property.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\property.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\property.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\property.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\property.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\property.rs
18: 16: ```rust
19: 17: use super::{ReactiveFunction, SharedReactiveFunction};
20: 18: use crate::{html::property::IntoProperty, renderer::Rndr};
21: 19: use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::effect::RenderEffect;
22: 20: 
23: 21: // These do update during hydration because properties don't exist in the DOM
24: 22: impl<F, V> IntoProperty for F
25: 23: where
26: 24:     F: ReactiveFunction<Output = V>,
27: 25:     V: IntoProperty + 'static,
28: 26:     V::State: 'static,
29: 27: {
30: 28:     type State = RenderEffect<V::State>;
31: 29:     type Cloneable = SharedReactiveFunction<V>;
32: 30:     type CloneableOwned = SharedReactiveFunction<V>;
33: 31: 
34: 32:     fn hydrate<const FROM_SERVER: bool>(
35: 33:         mut self,
36: 34:         el: &crate::renderer::types::Element,
37: 35:         key: &str,
38: 36:     ) -> Self::State {
39: 37:         let key = Rndr::intern(key);
40: 38:         let key = key.to_owned();
41: 39:         let el = el.to_owned();
42: 40: 
43: 41:         RenderEffect::new(move |prev| {
44: 42:             let value = self.invoke();
45: 43:             if let Some(mut state) = prev {
46: 44:                 value.rebuild(&mut state, &key);
47: 45:                 state
48: 46:             } else {
49: 47:                 value.hydrate::<FROM_SERVER>(&el, &key)
50: 48:             }
51: 49:         })
52: 50:     }
53: 51: 
54: 52:     fn build(
55: 53:         mut self,
56: 54:         el: &crate::renderer::types::Element,
57: 55:         key: &str,
58: 56:     ) -> Self::State {
59: 57:         let key = Rndr::intern(key);
60: 58:         let key = key.to_owned();
61: 59:         let el = el.to_owned();
62: 60: 
63: 61:         RenderEffect::new(move |prev| {
64: 62:             let value = self.invoke();
65: 63:             if let Some(mut state) = prev {
66: 64:                 value.rebuild(&mut state, &key);
67: 65:                 state
68: 66:             } else {
69: 67:                 value.build(&el, &key)
70: 68:             }
71: 69:         })
72: 70:     }
73: 71: 
74: 72:     fn rebuild(mut self, state: &mut Self::State, key: &str) {
75: 73:         let prev_value = state.take_value();
76: 74:         let key = key.to_owned();
77: 75:         *state = RenderEffect::new_with_value(
78: 76:             move |prev| {
79: 77:                 let value = self.invoke();
80: 78:                 if let Some(mut state) = prev {
81: 79:                     value.rebuild(&mut state, &key);
82: 80:                     state
83: 81:                 } else {
84: 82:                     unreachable!()
85: 83:                 }
86: 84:             },
87: 85:             prev_value,
88: 86:         );
89: 87:     }
90: 88: 
91: 89:     fn into_cloneable(self) -> Self::Cloneable {
92: 90:         self.into_shared()
93: 91:     }
94: 92: 
95: 93:     fn into_cloneable_owned(self) -> Self::CloneableOwned {
96: 94:         self.into_shared()
97: 95:     }
98: 96: }
99: 97: 
100: 98: macro_rules! property_reactive {
101: 99:     ($name:ident, <$($gen:ident),*>, $v:ty, $( $where_clause:tt )*) =>
102: 100:     {
103: 101:         #[allow(deprecated)]
104: 102:         impl<$($gen),*> IntoProperty for $name<$($gen),*>
105: 103:         where
106: 104:             $v: IntoProperty + Clone + Send + Sync + 'static,
107: 105:             <$v as IntoProperty>::State: 'static,
108: 106:             $($where_clause)*
109: 107:         {
110: 108:             type State = RenderEffect<<$v as IntoProperty>::State>;
111: 109:             type Cloneable = Self;
112: 110:             type CloneableOwned = Self;
113: 111: 
114: 112:             fn hydrate<const FROM_SERVER: bool>(
115: 113:                 self,
116: 114:                 el: &crate::renderer::types::Element,
117: 115:                 key: &str,
118: 116:             ) -> Self::State {
119: 117:                 (move || self.get()).hydrate::<FROM_SERVER>(el, key)
120: 118:             }
121: 119: 
122: 120:             fn build(
123: 121:                 self,
124: 122:                 el: &crate::renderer::types::Element,
125: 123:                 key: &str,
126: 124:             ) -> Self::State {
127: 125:                 (move || self.get()).build(el, key)
128: 126:             }
129: 127: 
130: 128:             fn rebuild(self, state: &mut Self::State, key: &str) {
131: 129:                 (move || self.get()).rebuild(state, key)
132: 130:             }
133: 131: 
134: 132:             fn into_cloneable(self) -> Self::Cloneable {
135: 133:                 self
136: 134:             }
137: 135: 
138: 136:             fn into_cloneable_owned(self) -> Self::CloneableOwned {
139: 137:                 self
140: 138:             }
141: 139:         }
142: 140:     };
143: 141: }
144: 142: 
145: 143: #[cfg(not(feature = "nightly"))]
146: 144: mod stable {
147: 145:     use crate::html::property::IntoProperty;
148: 146:     #[allow(deprecated)]
149: 147:     use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_appers::read::MaybeSignal;
150: 148:     use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::{
151: 149:         computed::{ArcMemo, Memo},
152: 150:         effect::RenderEffect,
153: 151:         owner::Storage,
154: 152:         signal::{ArcReadSignal, ArcRwSignal, ReadSignal, RwSignal},
155: 153:         traits::Get,
156: 154:         wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_appers::read::{ArcSignal, Signal},
157: 155:     };
158: 156: 
159: 157:     property_reactive!(
160: 158:         RwSignal,
161: 159:         <V, S>,
162: 160:         V,
163: 161:         RwSignal<V, S>: Get<Value = V>,
164: 162:         S: Storage<V> + Storage<Option<V>>,
165: 163:         S: Send + Sync + 'static,
166: 164:     );
167: 165:     property_reactive!(
168: 166:         ReadSignal,
169: 167:         <V, S>,
170: 168:         V,
171: 169:         ReadSignal<V, S>: Get<Value = V>,
172: 170:         S: Storage<V> + Storage<Option<V>>,
173: 171:         S: Send + Sync + 'static,
174: 172:     );
175: 173:     property_reactive!(
176: 174:         Memo,
177: 175:         <V, S>,
178: 176:         V,
179: 177:         Memo<V, S>: Get<Value = V>,
180: 178:         S: Storage<V> + Storage<Option<V>>,
181: 179:         S: Send + Sync + 'static,
182: 180:     );
183: 181:     property_reactive!(
184: 182:         Signal,
185: 183:         <V, S>,
186: 184:         V,
187: 185:         Signal<V, S>: Get<Value = V>,
188: 186:         S: Storage<V> + Storage<Option<V>>,
189: 187:         S: Send + Sync + 'static,
190: 188:     );
191: 189:     property_reactive!(
192: 190:         MaybeSignal,
193: 191:         <V, S>,
194: 192:         V,
195: 193:         MaybeSignal<V, S>: Get<Value = V>,
196: 194:         S: Storage<V> + Storage<Option<V>>,
197: 195:         S: Send + Sync + 'static,
198: 196:     );
199: 197:     property_reactive!(ArcRwSignal, <V>, V, ArcRwSignal<V>: Get<Value = V>);
200: 198:     property_reactive!(ArcReadSignal, <V>, V, ArcReadSignal<V>: Get<Value = V>);
201: 199:     property_reactive!(ArcMemo, <V>, V, ArcMemo<V>: Get<Value = V>);
202: 200:     property_reactive!(ArcSignal, <V>, V, ArcSignal<V>: Get<Value = V>);
203: 201: }
204: 202: 
205: 203: #[cfg(feature = "lyx-core-lyx_core_lyx-core-lyx_core_reactive_stores")]
206: 204: mod lyx-core-lyx_core_lyx-core-lyx_core_reactive_stores {
207: 205:     use crate::html::property::IntoProperty;
208: 206:     #[allow(deprecated)]
209: 207:     use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::{effect::RenderEffect, owner::Storage, traits::Get};
210: 208:     use lyx-core-lyx_core_lyx-core-lyx_core_reactive_stores::{
211: 209:         ArcField, ArcStore, AtIndex, AtKeyed, DerefedField, Field,
212: 210:         KeyedSubfield, Store, StoreField, Subfield,
213: 211:     };
214: 212:     use std::ops::{Deref, DerefMut, Index, IndexMut};
215: 213: 
216: 214:     property_reactive!(
217: 215:         Subfield,
218: 216:         <Inner, Prev, V>,
219: 217:         V,
220: 218:         Subfield<Inner, Prev, V>: Get<Value = V>,
221: 219:         Prev: Send + Sync + 'static,
222: 220:         Inner: Send + Sync + Clone + 'static,
223: 221:     );
224: 222: 
225: 223:     property_reactive!(
226: 224:         AtKeyed,
227: 225:         <Inner, Prev, K, V>,
228: 226:         V,
229: 227:         AtKeyed<Inner, Prev, K, V>: Get<Value = V>,
230: 228:         Prev: Send + Sync + 'static,
231: 229:         Inner: Send + Sync + Clone + 'static,
232: 230:         K: Send + Sync + std::fmt::Debug + Clone + 'static,
233: 231:         for<'a> &'a V: IntoIterator,
234: 232:     );
235: 233: 
236: 234:     property_reactive!(
237: 235:         KeyedSubfield,
238: 236:         <Inner, Prev, K, V>,
239: 237:         V,
240: 238:         KeyedSubfield<Inner, Prev, K, V>: Get<Value = V>,
241: 239:         Prev: Send + Sync + 'static,
242: 240:         Inner: Send + Sync + Clone + 'static,
243: 241:         K: Send + Sync + std::fmt::Debug + Clone + 'static,
244: 242:         for<'a> &'a V: IntoIterator,
245: 243:     );
246: 244: 
247: 245:     property_reactive!(
248: 246:         DerefedField,
249: 247:         <S>,
250: 248:         <S::Value as Deref>::Target,
251: 249:         S: Clone + StoreField + Send + Sync + 'static,
252: 250:         <S as StoreField>::Value: Deref + DerefMut
253: 251:     );
254: 252: 
255: 253:     property_reactive!(
256: 254:         AtIndex,
257: 255:         <Inner, Prev>,
258: 256:         <Prev as Index<usize>>::Output,
259: 257:         AtIndex<Inner, Prev>: Get<Value = Prev::Output>,
260: 258:         Prev: Send + Sync + IndexMut<usize> + 'static,
261: 259:         Inner: Send + Sync + Clone + 'static,
262: 260:     );
263: 261:     property_reactive!(
264: 262:         Store,
265: 263:         <V, S>,
266: 264:         V,
267: 265:         Store<V, S>: Get<Value = V>,
268: 266:         S: Storage<V> + Storage<Option<V>>,
269: 267:         S: Send + Sync + 'static,
270: 268:     );
271: 269:     property_reactive!(
272: 270:         Field,
273: 271:         <V, S>,
274: 272:         V,
275: 273:         Field<V, S>: Get<Value = V>,
276: 274:         S: Storage<V> + Storage<Option<V>>,
277: 275:         S: Send + Sync + 'static,
278: 276:     );
279: 277:     property_reactive!(ArcStore, <V>, V, ArcStore<V>: Get<Value = V>);
280: 278:     property_reactive!(ArcField, <V>, V, ArcField<V>: Get<Value = V>);
281: 279: }
282: 280: ```
283: 281: ```
284: 282: ```
285: 283: ```
286: 284: ```
287: 285: ```
288: 286: ```
289: 287: ```
290: ```
```
