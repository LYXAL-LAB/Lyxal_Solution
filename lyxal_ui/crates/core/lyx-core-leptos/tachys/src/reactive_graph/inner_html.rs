### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_tachys\src\lyx-core-lyx_core_reactive_graph\inner_html.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\inner_html.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\inner_html.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\inner_html.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\inner_html.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\inner_html.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\inner_html.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\inner_html.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\inner_html.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\inner_html.rs
18: 16: ```rust
19: 17: use super::{ReactiveFunction, SharedReactiveFunction};
20: 18: use crate::html::element::InnerHtmlValue;
21: 19: use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::effect::RenderEffect;
22: 20: 
23: 21: impl<F, V> InnerHtmlValue for F
24: 22: where
25: 23:     F: ReactiveFunction<Output = V>,
26: 24:     V: InnerHtmlValue + 'static,
27: 25:     V::State: 'static,
28: 26: {
29: 27:     type AsyncOutput = V::AsyncOutput;
30: 28:     type State = RenderEffect<V::State>;
31: 29:     type Cloneable = SharedReactiveFunction<V>;
32: 30:     type CloneableOwned = SharedReactiveFunction<V>;
33: 31: 
34: 32:     fn html_len(&self) -> usize {
35: 33:         0
36: 34:     }
37: 35: 
38: 36:     fn to_html(mut self, buf: &mut String) {
39: 37:         let value = self.invoke();
40: 38:         value.to_html(buf);
41: 39:     }
42: 40: 
43: 41:     fn to_template(_buf: &mut String) {}
44: 42: 
45: 43:     fn hydrate<const FROM_SERVER: bool>(
46: 44:         mut self,
47: 45:         el: &crate::renderer::types::Element,
48: 46:     ) -> Self::State {
49: 47:         let el = el.to_owned();
50: 48:         RenderEffect::new(move |prev| {
51: 49:             let value = self.invoke();
52: 50:             if let Some(mut state) = prev {
53: 51:                 value.rebuild(&mut state);
54: 52:                 state
55: 53:             } else {
56: 54:                 value.hydrate::<FROM_SERVER>(&el)
57: 55:             }
58: 56:         })
59: 57:     }
60: 58: 
61: 59:     fn build(mut self, el: &crate::renderer::types::Element) -> Self::State {
62: 60:         let el = el.to_owned();
63: 61:         RenderEffect::new(move |prev| {
64: 62:             let value = self.invoke();
65: 63:             if let Some(mut state) = prev {
66: 64:                 value.rebuild(&mut state);
67: 65:                 state
68: 66:             } else {
69: 67:                 value.build(&el)
70: 68:             }
71: 69:         })
72: 70:     }
73: 71: 
74: 72:     fn rebuild(mut self, state: &mut Self::State) {
75: 73:         let prev_value = state.take_value();
76: 74:         *state = RenderEffect::new_with_value(
77: 75:             move |prev| {
78: 76:                 let value = self.invoke();
79: 77:                 if let Some(mut state) = prev {
80: 78:                     value.rebuild(&mut state);
81: 79:                     state
82: 80:                 } else {
83: 81:                     unreachable!()
84: 82:                 }
85: 83:             },
86: 84:             prev_value,
87: 85:         );
88: 86:     }
89: 87: 
90: 88:     fn into_cloneable(self) -> Self::Cloneable {
91: 89:         self.into_shared()
92: 90:     }
93: 91: 
94: 92:     fn into_cloneable_owned(self) -> Self::CloneableOwned {
95: 93:         self.into_shared()
96: 94:     }
97: 95: 
98: 96:     fn dry_resolve(&mut self) {
99: 97:         self.invoke();
100: 98:     }
101: 99: 
102: 100:     async fn resolve(mut self) -> Self::AsyncOutput {
103: 101:         self.invoke().resolve().await
104: 102:     }
105: 103: }
106: 104: 
107: 105: macro_rules! inner_html_reactive {
108: 106:     ($name:ident, <$($gen:ident),*>, $v:ty, $( $where_clause:tt )*) =>
109: 107:     {
110: 108:         #[allow(deprecated)]
111: 109:         impl<$($gen),*> InnerHtmlValue for $name<$($gen),*>
112: 110:         where
113: 111:             $v: InnerHtmlValue + Clone + Send + Sync + 'static,
114: 112:             <$v as InnerHtmlValue>::State: 'static,
115: 113:             $($where_clause)*
116: 114:         {
117: 115:             type AsyncOutput = Self;
118: 116:             type State = RenderEffect<<$v as InnerHtmlValue>::State>;
119: 117:             type Cloneable = Self;
120: 118:             type CloneableOwned = Self;
121: 119: 
122: 120:             fn html_len(&self) -> usize {
123: 121:                 0
124: 122:             }
125: 123: 
126: 124:             fn to_html(self, buf: &mut String) {
127: 125:                 let value = self.get();
128: 126:                 value.to_html(buf);
129: 127:             }
130: 128: 
131: 129:             fn to_template(_buf: &mut String) {}
132: 130: 
133: 131:             fn hydrate<const FROM_SERVER: bool>(
134: 132:                 self,
135: 133:                 el: &crate::renderer::types::Element,
136: 134:             ) -> Self::State {
137: 135:                 (move || self.get()).hydrate::<FROM_SERVER>(el)
138: 136:             }
139: 137: 
140: 138:             fn build(
141: 139:                 self,
142: 140:                 el: &crate::renderer::types::Element,
143: 141:             ) -> Self::State {
144: 142:                 (move || self.get()).build(el)
145: 143:             }
146: 144: 
147: 145:             fn rebuild(self, state: &mut Self::State) {
148: 146:                 (move || self.get()).rebuild(state)
149: 147:             }
150: 148: 
151: 149:             fn into_cloneable(self) -> Self::Cloneable {
152: 150:                 self
153: 151:             }
154: 152: 
155: 153:             fn into_cloneable_owned(self) -> Self::CloneableOwned {
156: 154:                 self
157: 155:             }
158: 156: 
159: 157:             fn dry_resolve(&mut self) {}
160: 158: 
161: 159:             async fn resolve(self) -> Self::AsyncOutput {
162: 160:                 self
163: 161:             }
164: 162:         }
165: 163:     };
166: 164: }
167: 165: 
168: 166: #[cfg(not(feature = "nightly"))]
169: 167: mod stable {
170: 168:     use crate::html::element::InnerHtmlValue;
171: 169:     #[allow(deprecated)]
172: 170:     use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_appers::read::MaybeSignal;
173: 171:     use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::{
174: 172:         computed::{ArcMemo, Memo},
175: 173:         effect::RenderEffect,
176: 174:         owner::Storage,
177: 175:         signal::{ArcReadSignal, ArcRwSignal, ReadSignal, RwSignal},
178: 176:         traits::Get,
179: 177:         wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_appers::read::{ArcSignal, Signal},
180: 178:     };
181: 179: 
182: 180:     inner_html_reactive!(
183: 181:         RwSignal,
184: 182:         <V, S>,
185: 183:         V,
186: 184:         RwSignal<V, S>: Get<Value = V>,
187: 185:         S: Storage<V> + Storage<Option<V>>,
188: 186:         S: Send + Sync + 'static,
189: 187:     );
190: 188:     inner_html_reactive!(
191: 189:         ReadSignal,
192: 190:         <V, S>,
193: 191:         V,
194: 192:         ReadSignal<V, S>: Get<Value = V>,
195: 193:         S: Storage<V> + Storage<Option<V>>,
196: 194:         S: Send + Sync + 'static,
197: 195:     );
198: 196:     inner_html_reactive!(
199: 197:         Memo,
200: 198:         <V, S>,
201: 199:         V,
202: 200:         Memo<V, S>: Get<Value = V>,
203: 201:         S: Storage<V> + Storage<Option<V>>,
204: 202:         S: Send + Sync + 'static,
205: 203:     );
206: 204:     inner_html_reactive!(
207: 205:         Signal,
208: 206:         <V, S>,
209: 207:         V,
210: 208:         Signal<V, S>: Get<Value = V>,
211: 209:         S: Storage<V> + Storage<Option<V>>,
212: 210:         S: Send + Sync + 'static,
213: 211:     );
214: 212:     inner_html_reactive!(
215: 213:         MaybeSignal,
216: 214:         <V, S>,
217: 215:         V,
218: 216:         MaybeSignal<V, S>: Get<Value = V>,
219: 217:         S: Storage<V> + Storage<Option<V>>,
220: 218:         S: Send + Sync + 'static,
221: 219:     );
222: 220:     inner_html_reactive!(ArcRwSignal, <V>, V, ArcRwSignal<V>: Get<Value = V>);
223: 221:     inner_html_reactive!(ArcReadSignal, <V>, V, ArcReadSignal<V>: Get<Value = V>);
224: 222:     inner_html_reactive!(ArcMemo, <V>, V, ArcMemo<V>: Get<Value = V>);
225: 223:     inner_html_reactive!(ArcSignal, <V>, V, ArcSignal<V>: Get<Value = V>);
226: 224: }
227: 225: 
228: 226: #[cfg(feature = "lyx-core-lyx_core_lyx-core-lyx_core_reactive_stores")]
229: 227: mod lyx-core-lyx_core_lyx-core-lyx_core_reactive_stores {
230: 228:     use crate::html::element::InnerHtmlValue;
231: 229:     #[allow(deprecated)]
232: 230:     use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::{effect::RenderEffect, owner::Storage, traits::Get};
233: 231:     use lyx-core-lyx_core_lyx-core-lyx_core_reactive_stores::{
234: 232:         ArcField, ArcStore, AtIndex, AtKeyed, DerefedField, Field,
235: 233:         KeyedSubfield, Store, StoreField, Subfield,
236: 234:     };
237: 235:     use std::ops::{Deref, DerefMut, Index, IndexMut};
238: 236: 
239: 237:     inner_html_reactive!(
240: 238:         Subfield,
241: 239:         <Inner, Prev, V>,
242: 240:         V,
243: 241:         Subfield<Inner, Prev, V>: Get<Value = V>,
244: 242:         Prev: Send + Sync + 'static,
245: 243:         Inner: Send + Sync + Clone + 'static,
246: 244:     );
247: 245: 
248: 246:     inner_html_reactive!(
249: 247:         AtKeyed,
250: 248:         <Inner, Prev, K, V>,
251: 249:         V,
252: 250:         AtKeyed<Inner, Prev, K, V>: Get<Value = V>,
253: 251:         Prev: Send + Sync + 'static,
254: 252:         Inner: Send + Sync + Clone + 'static,
255: 253:         K: Send + Sync + std::fmt::Debug + Clone + 'static,
256: 254:         for<'a> &'a V: IntoIterator,
257: 255:     );
258: 256: 
259: 257:     inner_html_reactive!(
260: 258:         KeyedSubfield,
261: 259:         <Inner, Prev, K, V>,
262: 260:         V,
263: 261:         KeyedSubfield<Inner, Prev, K, V>: Get<Value = V>,
264: 262:         Prev: Send + Sync + 'static,
265: 263:         Inner: Send + Sync + Clone + 'static,
266: 264:         K: Send + Sync + std::fmt::Debug + Clone + 'static,
267: 265:         for<'a> &'a V: IntoIterator,
268: 266:     );
269: 267: 
270: 268:     inner_html_reactive!(
271: 269:         DerefedField,
272: 270:         <S>,
273: 271:         <S::Value as Deref>::Target,
274: 272:         S: Clone + StoreField + Send + Sync + 'static,
275: 273:         <S as StoreField>::Value: Deref + DerefMut
276: 274:     );
277: 275: 
278: 276:     inner_html_reactive!(
279: 277:         AtIndex,
280: 278:         <Inner, Prev>,
281: 279:         <Prev as Index<usize>>::Output,
282: 280:         AtIndex<Inner, Prev>: Get<Value = Prev::Output>,
283: 281:         Prev: Send + Sync + IndexMut<usize> + 'static,
284: 282:         Inner: Send + Sync + Clone + 'static,
285: 283:     );
286: 284:     inner_html_reactive!(
287: 285:         Store,
288: 286:         <V, S>,
289: 287:         V,
290: 288:         Store<V, S>: Get<Value = V>,
291: 289:         S: Storage<V> + Storage<Option<V>>,
292: 290:         S: Send + Sync + 'static,
293: 291:     );
294: 292:     inner_html_reactive!(
295: 293:         Field,
296: 294:         <V, S>,
297: 295:         V,
298: 296:         Field<V, S>: Get<Value = V>,
299: 297:         S: Storage<V> + Storage<Option<V>>,
300: 298:         S: Send + Sync + 'static,
301: 299:     );
302: 300:     inner_html_reactive!(ArcStore, <V>, V, ArcStore<V>: Get<Value = V>);
303: 301:     inner_html_reactive!(ArcField, <V>, V, ArcField<V>: Get<Value = V>);
304: 302: }
305: 303: ```
306: 304: ```
307: 305: ```
308: 306: ```
309: 307: ```
310: 308: ```
311: 309: ```
312: 310: ```
313: ```
```
