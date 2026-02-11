### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_tachys\src\svg\mod.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\svg\mod.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\svg\mod.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\svg\mod.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\svg\mod.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\svg\mod.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\svg\mod.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\svg\mod.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\svg\mod.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\svg\mod.rs
18: 16: ```rust
19: 17: use crate::{
20: 18:     html::{
21: 19:         attribute::{any_attribute::AnyAttribute, Attribute},
22: 20:         element::{ElementType, ElementWithChildren, HtmlElement},
23: 21:     },
24: 22:     hydration::Cursor,
25: 23:     prelude::{AddAnyAttr, Mountable},
26: 24:     renderer::{
27: 25:         dom::{Element, Node},
28: 26:         CastFrom, Rndr,
29: 27:     },
30: 28:     view::{Position, PositionState, Render, RenderHtml},
31: 29: };
32: 30: use std::{borrow::Cow, fmt::Debug};
33: 31: 
34: 32: macro_rules! svg_elements {
35: 33: 	($($tag:ident  [$($attr:ty),*]),* $(,)?) => {
36: 34:         paste::paste! {
37: 35:             $(
38: 36:                 /// An SVG element.
39: 37:                 // `tag()` function
40: 38:                 #[allow(non_snake_case)]
41: 39:                 #[track_caller]
42: 40:                 pub fn $tag() -> HtmlElement<[<$tag:camel>], (), ()>
43: 41:                 where
44: 42:                 {
45: 43:                     HtmlElement {
46: 44:                         #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
47: 45:                         defined_at: std::panic::Location::caller(),
48: 46:                         tag: [<$tag:camel>],
49: 47:                         attributes: (),
50: 48:                         children: (),
51: 49:                     }
52: 50:                 }
53: 51: 
54: 52:                 /// An SVG element.
55: 53:                 #[derive(Debug, Copy, Clone, PartialEq, Eq)]
56: 54:                 pub struct [<$tag:camel>];
57: 55: 
58: 56: 				impl<At, Ch> HtmlElement<[<$tag:camel>], At, Ch>
59: 57: 				where
60: 58: 					At: Attribute,
61: 59: 					Ch: Render,
62: 60: 
63: 61: 				{
64: 62: 					$(
65: 63:                         pub fn $attr<V>(self, value: V) -> HtmlElement <
66: 64:                             [<$tag:camel>],
67: 65:                             <At as $crate::html::attribute::NextAttribute<Attr<$crate::html::attribute::[<$attr:camel>], V>>>::Output,
68: 66:                             Ch
69: 67:                         >
70: 68:                         where
71: 69:                             V: AttributeValue,
72: 70:                             At: $crate::html::attribute::NextAttribute<Attr<$crate::html::attribute::[<$attr:camel>], V>>,
73: 71:                             <At as $crate::html::attribute::NextAttribute<Attr<$crate::html::attribute::[<$attr:camel>], V>>>::Output: Attribute,
74: 72:                         {
75: 73:                             let HtmlElement { tag, children, attributes,
76: 74:                                 #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
77: 75:                                 defined_at
78: 76:                             } = self;
79: 77:                             HtmlElement {
80: 78:                                 tag,
81: 79: 
82: 80:                                 children,
83: 81:                                 attributes: attributes.add_any_attr($crate::html::attribute::$attr(value)),
84: 82:                                 #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
85: 83:                                 defined_at
86: 84:                             }
87: 85:                         }
88: 86: 					)*
89: 87: 				}
90: 88: 
91: 89:                 impl ElementType for [<$tag:camel>] {
92: 90:                     type Output = web_sys::SvgElement;
93: 91: 
94: 92:                     const TAG: &'static str = stringify!($tag);
95: 93:                     const SELF_CLOSING: bool = false;
96: 94:                     const ESCAPE_CHILDREN: bool = true;
97: 95:                     const NAMESPACE: Option<&'static str> = Some("http://www.w3.org/2000/svg");
98: 96: 
99: 97:                     #[inline(always)]
100: 98:                     fn tag(&self) -> &str {
101: 99:                         Self::TAG
102: 100:                     }
103: 101:                 }
104: 102: 
105: 103:                 impl ElementWithChildren for [<$tag:camel>] {}
106: 104:             )*
107: 105: 		}
108: 106:     }
109: 107: }
110: 108: 
111: 109: svg_elements![
112: 110:   a [],
113: 111:   animate [],
114: 112:   animateMotion [],
115: 113:   animateTransform [],
116: 114:   circle [],
117: 115:   clipPath [],
118: 116:   defs [],
119: 117:   desc [],
120: 118:   discard [],
121: 119:   ellipse [],
122: 120:   feBlend [],
123: 121:   feColorMatrix [],
124: 122:   feComponentTransfer [],
125: 123:   feComposite [],
126: 124:   feConvolveMatrix [],
127: 125:   feDiffuseLighting [],
128: 126:   feDisplacementMap [],
129: 127:   feDistantLight [],
130: 128:   feDropShadow [],
131: 129:   feFlood [],
132: 130:   feFuncA [],
133: 131:   feFuncB [],
134: 132:   feFuncG [],
135: 133:   feFuncR [],
136: 134:   feGaussianBlur [],
137: 135:   feImage [],
138: 136:   feMerge [],
139: 137:   feMergeNode [],
140: 138:   feMorphology [],
141: 139:   feOffset [],
142: 140:   fePointLight [],
143: 141:   feSpecularLighting [],
144: 142:   feSpotLight [],
145: 143:   feTile [],
146: 144:   feTurbulence [],
147: 145:   filter [],
148: 146:   foreignObject [],
149: 147:   g [],
150: 148:   hatch [],
151: 149:   hatchpath [],
152: 150:   image [],
153: 151:   line [],
154: 152:   linearGradient [],
155: 153:   marker [],
156: 154:   mask [],
157: 155:   metadata [],
158: 156:   mpath [],
159: 157:   path [],
160: 158:   pattern [],
161: 159:   polygon [],
162: 160:   polyline [],
163: 161:   radialGradient [],
164: 162:   rect [],
165: 163:   script [],
166: 164:   set [],
167: 165:   stop [],
168: 166:   style [],
169: 167:   svg [],
170: 168:   switch [],
171: 169:   symbol [],
172: 170:   text [],
173: 171:   textPath [],
174: 172:   title [],
175: 173:   tspan [],
176: 174:   view [],
177: 175: ];
178: 176: 
179: 177: /// An SVG element.
180: 178: #[allow(non_snake_case)]
181: 179: #[track_caller]
182: 180: pub fn r#use() -> HtmlElement<Use, (), ()>
183: 181: where {
184: 182:     HtmlElement {
185: 183:         #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
186: 184:         defined_at: std::panic::Location::caller(),
187: 185:         tag: Use,
188: 186:         attributes: (),
189: 187:         children: (),
190: 188:     }
191: 189: }
192: 190: 
193: 191: /// An SVG element.
194: 192: #[derive(Debug, Copy, Clone, PartialEq, Eq)]
195: 193: pub struct Use;
196: 194: 
197: 195: impl ElementType for Use {
198: 196:     type Output = web_sys::SvgElement;
199: 197: 
200: 198:     const TAG: &'static str = "use";
201: 199:     const SELF_CLOSING: bool = false;
202: 200:     const ESCAPE_CHILDREN: bool = true;
203: 201:     const NAMESPACE: Option<&'static str> = Some("http://www.w3.org/2000/svg");
204: 202: 
205: 203:     #[inline(always)]
206: 204:     fn tag(&self) -> &str {
207: 205:         Self::TAG
208: 206:     }
209: 207: }
210: 208: 
211: 209: impl ElementWithChildren for Use {}
212: 210: 
213: 211: /// An element that contains no interactivity, and whose contents can be known at compile time.
214: 212: pub struct InertElement {
215: 213:     html: Cow<'static, str>,
216: 214: }
217: 215: 
218: 216: impl InertElement {
219: 217:     /// Creates a new inert svg element.
220: 218:     pub fn new(html: impl Into<Cow<'static, str>>) -> Self {
221: 219:         Self { html: html.into() }
222: 220:     }
223: 221: }
224: 222: 
225: 223: /// Retained view state for [`InertElement`].
226: 224: pub struct InertElementState(Cow<'static, str>, Element);
227: 225: 
228: 226: impl Mountable for InertElementState {
229: 227:     fn unmount(&mut self) {
230: 228:         self.1.unmount();
231: 229:     }
232: 230: 
233: 231:     fn mount(&mut self, parent: &Element, marker: Option<&Node>) {
234: 232:         self.1.mount(parent, marker)
235: 233:     }
236: 234: 
237: 235:     fn insert_before_this(&self, child: &mut dyn Mountable) -> bool {
238: 236:         self.1.insert_before_this(child)
239: 237:     }
240: 238: 
241: 239:     fn elements(&self) -> Vec<crate::renderer::types::Element> {
242: 240:         vec![self.1.clone()]
243: 241:     }
244: 242: }
245: 243: 
246: 244: impl Render for InertElement {
247: 245:     type State = InertElementState;
248: 246: 
249: 247:     fn build(self) -> Self::State {
250: 248:         let el = Rndr::create_svg_element_from_html(self.html.clone());
251: 249:         InertElementState(self.html, el)
252: 250:     }
253: 251: 
254: 252:     fn rebuild(self, state: &mut Self::State) {
255: 253:         let InertElementState(prev, el) = state;
256: 254:         if &self.html != prev {
257: 255:             let mut new_el =
258: 256:                 Rndr::create_svg_element_from_html(self.html.clone());
259: 257:             el.insert_before_this(&mut new_el);
260: 258:             el.unmount();
261: 259:             *el = new_el;
262: 260:             *prev = self.html;
263: 261:         }
264: 262:     }
265: 263: }
266: 264: 
267: 265: impl AddAnyAttr for InertElement {
268: 266:     type Output<SomeNewAttr: Attribute> = Self;
269: 267: 
270: 268:     fn add_any_attr<NewAttr: Attribute>(
271: 269:         self,
272: 270:         _attr: NewAttr,
273: 271:     ) -> Self::Output<NewAttr>
274: 272:     where
275: 273:         Self::Output<NewAttr>: RenderHtml,
276: 274:     {
277: 275:         panic!(
278: 276:             "InertElement does not support adding attributes. It should only \
279: 277:              be used as a child, and not returned at the top level."
280: 278:         )
281: 279:     }
282: 280: }
283: 281: 
284: 282: impl RenderHtml for InertElement {
285: 283:     type AsyncOutput = Self;
286: 284:     type Owned = Self;
287: 285: 
288: 286:     const MIN_LENGTH: usize = 0;
289: 287: 
290: 288:     fn html_len(&self) -> usize {
291: 289:         self.html.len()
292: 290:     }
293: 291: 
294: 292:     fn dry_resolve(&mut self) {}
295: 293: 
296: 294:     async fn resolve(self) -> Self {
297: 295:         self
298: 296:     }
299: 297: 
300: 298:     fn to_html_with_buf(
301: 299:         self,
302: 300:         buf: &mut String,
303: 301:         position: &mut Position,
304: 302:         _escape: bool,
305: 303:         _mark_branches: bool,
306: 304:         _extra_attrs: Vec<AnyAttribute>,
307: 305:     ) {
308: 306:         buf.push_str(&self.html);
309: 307:         *position = Position::NextChild;
310: 308:     }
311: 309: 
312: 310:     fn hydrate<const FROM_SERVER: bool>(
313: 311:         self,
314: 312:         cursor: &Cursor,
315: 313:         position: &PositionState,
316: 314:     ) -> Self::State {
317: 315:         let curr_position = position.get();
318: 316:         if curr_position == Position::FirstChild {
319: 317:             cursor.child();
320: 318:         } else if curr_position != Position::Current {
321: 319:             cursor.sibling();
322: 320:         }
323: 321:         let el = crate::renderer::types::Element::cast_from(cursor.current())
324: 322:             .unwrap();
325: 323:         position.set(Position::NextChild);
326: 324:         InertElementState(self.html, el)
327: 325:     }
328: 326: 
329: 327:     fn into_owned(self) -> Self::Owned {
330: 328:         self
331: 329:     }
332: 330: }
333: 331: ```
334: 332: ```
335: 333: ```
336: 334: ```
337: 335: ```
338: 336: ```
339: 337: ```
340: 338: ```
341: ```
```
