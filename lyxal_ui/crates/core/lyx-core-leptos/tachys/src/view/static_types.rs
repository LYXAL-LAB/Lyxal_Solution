### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_tachys\src\view\static_types.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\static_types.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\static_types.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\static_types.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\static_types.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\static_types.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\static_types.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\static_types.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\static_types.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\static_types.rs
18: 16: ```rust
19: 17: use super::{
20: 18:     add_attr::AddAnyAttr, Mountable, Position, PositionState, Render,
21: 19:     RenderHtml, ToTemplate,
22: 20: };
23: 21: use crate::{
24: 22:     html::attribute::{
25: 23:         any_attribute::AnyAttribute,
26: 24:         maybe_next_attr_erasure_macros::{
27: 25:             next_attr_combine, next_attr_output_type,
28: 26:         },
29: 27:         Attribute, AttributeKey, AttributeValue, NamedAttributeKey,
30: 28:         NextAttribute,
31: 29:     },
32: 30:     hydration::Cursor,
33: 31:     renderer::{CastFrom, Rndr},
34: 32: };
35: 33: use std::marker::PhantomData;
36: 34: 
37: 35: /// An attribute for which both the key and the value are known at compile time,
38: 36: /// i.e., as `&'static str`s.
39: 37: #[derive(Debug)]
40: 38: pub struct StaticAttr<K: AttributeKey, const V: &'static str> {
41: 39:     ty: PhantomData<K>,
42: 40: }
43: 41: 
44: 42: impl<K: AttributeKey, const V: &'static str> Clone for StaticAttr<K, V> {
45: 43:     fn clone(&self) -> Self {
46: 44:         Self { ty: PhantomData }
47: 45:     }
48: 46: }
49: 47: 
50: 48: impl<K: AttributeKey, const V: &'static str> PartialEq for StaticAttr<K, V> {
51: 49:     fn eq(&self, _other: &Self) -> bool {
52: 50:         // by definition, two static attrs with same key and same const V are same
53: 51:         true
54: 52:     }
55: 53: }
56: 54: 
57: 55: /// Creates an [`Attribute`] whose key and value are both known at compile time.
58: 56: pub fn static_attr<K: AttributeKey, const V: &'static str>() -> StaticAttr<K, V>
59: 57: {
60: 58:     StaticAttr { ty: PhantomData }
61: 59: }
62: 60: 
63: 61: impl<K, const V: &'static str> ToTemplate for StaticAttr<K, V>
64: 62: where
65: 63:     K: AttributeKey,
66: 64: {
67: 65:     fn to_template(
68: 66:         buf: &mut String,
69: 67:         _class: &mut String,
70: 68:         _style: &mut String,
71: 69:         _inner_html: &mut String,
72: 70:         _position: &mut Position,
73: 71:     ) {
74: 72:         buf.push(' ');
75: 73:         buf.push_str(K::KEY);
76: 74:         buf.push_str("=\"");
77: 75:         buf.push_str(V);
78: 76:         buf.push('"');
79: 77:     }
80: 78: }
81: 79: 
82: 80: impl<K, const V: &'static str> Attribute for StaticAttr<K, V>
83: 81: where
84: 82:     K: AttributeKey,
85: 83: {
86: 84:     const MIN_LENGTH: usize = K::KEY.len() + 3 + V.len(); // K::KEY + ="..." + V
87: 85: 
88: 86:     type AsyncOutput = Self;
89: 87:     type State = ();
90: 88:     type Cloneable = Self;
91: 89:     type CloneableOwned = Self;
92: 90: 
93: 91:     #[inline(always)]
94: 92:     fn html_len(&self) -> usize {
95: 93:         K::KEY.len() + 3 + V.len()
96: 94:     }
97: 95: 
98: 96:     fn to_html(
99: 97:         self,
100: 98:         buf: &mut String,
101: 99:         _class: &mut String,
102: 100:         _style: &mut String,
103: 101:         _inner_html: &mut String,
104: 102:     ) {
105: 103:         AttributeValue::to_html(V, K::KEY, buf)
106: 104:     }
107: 105: 
108: 106:     fn hydrate<const FROM_SERVER: bool>(
109: 107:         self,
110: 108:         _el: &crate::renderer::types::Element,
111: 109:     ) -> Self::State {
112: 110:     }
113: 111: 
114: 112:     fn build(self, el: &crate::renderer::types::Element) -> Self::State {
115: 113:         Rndr::set_attribute(el, K::KEY, V);
116: 114:     }
117: 115: 
118: 116:     fn rebuild(self, _state: &mut Self::State) {}
119: 117: 
120: 118:     fn into_cloneable(self) -> Self::Cloneable {
121: 119:         self
122: 120:     }
123: 121: 
124: 122:     fn into_cloneable_owned(self) -> Self::CloneableOwned {
125: 123:         self
126: 124:     }
127: 125: 
128: 126:     fn dry_resolve(&mut self) {}
129: 127: 
130: 128:     async fn resolve(self) -> Self::AsyncOutput {
131: 129:         self
132: 130:     }
133: 131: 
134: 132:     fn keys(&self) -> Vec<NamedAttributeKey> {
135: 133:         vec![NamedAttributeKey::Attribute(K::KEY.into())]
136: 134:     }
137: 135: }
138: 136: 
139: 137: impl<K, const V: &'static str> NextAttribute for StaticAttr<K, V>
140: 138: where
141: 139:     K: AttributeKey,
142: 140: {
143: 141:     next_attr_output_type!(Self, NewAttr);
144: 142: 
145: 143:     fn add_any_attr<NewAttr: Attribute>(
146: 144:         self,
147: 145:         new_attr: NewAttr,
148: 146:     ) -> Self::Output<NewAttr> {
149: 147:         next_attr_combine!(StaticAttr::<K, V> { ty: PhantomData }, new_attr)
150: 148:     }
151: 149: }
152: 150: 
153: 151: /// A static string that is known at compile time and can be optimized by including its type in the
154: 152: /// view tree.
155: 153: #[derive(Debug, Clone, Copy)]
156: 154: pub struct Static<const V: &'static str>;
157: 155: 
158: 156: impl<const V: &'static str> PartialEq for Static<V> {
159: 157:     fn eq(&self, _other: &Self) -> bool {
160: 158:         // by definition, two static values of same const V are same
161: 159:         true
162: 160:     }
163: 161: }
164: 162: 
165: 163: impl<const V: &'static str> AsRef<str> for Static<V> {
166: 164:     fn as_ref(&self) -> &str {
167: 165:         V
168: 166:     }
169: 167: }
170: 168: 
171: 169: impl<const V: &'static str> Render for Static<V>
172: 170: where
173: 171:     crate::renderer::types::Text: Mountable,
174: 172: {
175: 173:     type State = Option<crate::renderer::types::Text>;
176: 174: 
177: 175:     fn build(self) -> Self::State {
178: 176:         // a view state has to be returned so it can be mounted
179: 177:         Some(Rndr::create_text_node(V))
180: 178:     }
181: 179: 
182: 180:     // This type is specified as static, so no rebuilding is done.
183: 181:     fn rebuild(self, _state: &mut Self::State) {}
184: 182: }
185: 183: 
186: 184: impl<const V: &'static str> RenderHtml for Static<V> {
187: 185:     type AsyncOutput = Self;
188: 186:     type Owned = Self;
189: 187: 
190: 188:     const MIN_LENGTH: usize = V.len();
191: 189: 
192: 190:     fn dry_resolve(&mut self) {}
193: 191: 
194: 192:     // this won't actually compile because if a weird interaction because the const &'static str and
195: 193:     // the RPITIT, so we just refine it to a concrete future type; this will never change in any
196: 194:     // case
197: 195:     #[allow(refining_impl_trait)]
198: 196:     fn resolve(self) -> std::future::Ready<Self> {
199: 197:         std::future::ready(self)
200: 198:     }
201: 199: 
202: 200:     fn to_html_with_buf(
203: 201:         self,
204: 202:         buf: &mut String,
205: 203:         position: &mut Position,
206: 204:         escape: bool,
207: 205:         _mark_branches: bool,
208: 206:         _extra_attrs: Vec<AnyAttribute>,
209: 207:     ) {
210: 208:         // add a comment node to separate from previous sibling, if any
211: 209:         if matches!(position, Position::NextChildAfterText) {
212: 210:             buf.push_str("<!>")
213: 211:         }
214: 212:         if V.is_empty() && escape {
215: 213:             buf.push(' ');
216: 214:         } else if escape {
217: 215:             let escaped = html_escape::encode_text(V);
218: 216:             buf.push_str(&escaped);
219: 217:         } else {
220: 218:             buf.push_str(V);
221: 219:         }
222: 220:         *position = Position::NextChildAfterText;
223: 221:     }
224: 222: 
225: 223:     fn hydrate<const FROM_SERVER: bool>(
226: 224:         self,
227: 225:         cursor: &Cursor,
228: 226:         position: &PositionState,
229: 227:     ) -> Self::State {
230: 228:         if position.get() == Position::FirstChild {
231: 229:             cursor.child();
232: 230:         } else {
233: 231:             cursor.sibling();
234: 232:         }
235: 233: 
236: 234:         // separating placeholder marker comes before text node
237: 235:         if matches!(position.get(), Position::NextChildAfterText) {
238: 236:             cursor.sibling();
239: 237:         }
240: 238: 
241: 239:         let node = cursor.current();
242: 240:         let node = crate::renderer::types::Text::cast_from(node.clone())
243: 241:             .unwrap_or_else(|| {
244: 242:                 crate::hydration::failed_to_cast_text_node(node)
245: 243:             });
246: 244: 
247: 245:         position.set(Position::NextChildAfterText);
248: 246: 
249: 247:         Some(node)
250: 248:     }
251: 249: 
252: 250:     fn into_owned(self) -> Self::Owned {
253: 251:         self
254: 252:     }
255: 253: }
256: 254: 
257: 255: impl<const V: &'static str> AddAnyAttr for Static<V> {
258: 256:     type Output<NewAttr: Attribute> = Static<V>;
259: 257: 
260: 258:     fn add_any_attr<NewAttr: Attribute>(
261: 259:         self,
262: 260:         _attr: NewAttr,
263: 261:     ) -> Self::Output<NewAttr>
264: 262:     where
265: 263:         Self::Output<NewAttr>: RenderHtml,
266: 264:     {
267: 265:         // inline helper function to assist the compiler with type inference
268: 266:         #[inline(always)]
269: 267:         const fn create_static<const S: &'static str, A: Attribute>(
270: 268:         ) -> <Static<S> as AddAnyAttr>::Output<A> {
271: 269:             Static
272: 270:         }
273: 271: 
274: 272:         // call the helper function with the current const value and new attribute type
275: 273:         create_static::<V, NewAttr>()
276: 274:     }
277: 275: }
278: 276: 
279: 277: impl<const V: &'static str> ToTemplate for Static<V> {
280: 278:     const TEMPLATE: &'static str = V;
281: 279: 
282: 280:     fn to_template(
283: 281:         buf: &mut String,
284: 282:         _class: &mut String,
285: 283:         _style: &mut String,
286: 284:         _inner_html: &mut String,
287: 285:         position: &mut Position,
288: 286:     ) {
289: 287:         if matches!(*position, Position::NextChildAfterText) {
290: 288:             buf.push_str("<!>")
291: 289:         }
292: 290:         buf.push_str(V);
293: 291:         *position = Position::NextChildAfterText;
294: 292:     }
295: 293: }
296: 294: ```
297: 295: ```
298: 296: ```
299: 297: ```
300: 298: ```
301: 299: ```
302: 300: ```
303: 301: ```
304: ```
```
