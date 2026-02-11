### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_tachys\src\html\directive.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\directive.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\directive.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\directive.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\directive.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\directive.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\directive.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\directive.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\directive.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\directive.rs
18: 16: ```rust
19: 17: use super::attribute::{
20: 18:     maybe_next_attr_erasure_macros::next_attr_output_type, Attribute,
21: 19:     NextAttribute,
22: 20: };
23: 21: use crate::{
24: 22:     html::attribute::{
25: 23:         maybe_next_attr_erasure_macros::next_attr_combine, NamedAttributeKey,
26: 24:     },
27: 25:     prelude::AddAnyAttr,
28: 26:     view::{Position, ToTemplate},
29: 27: };
30: 28: use send_wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper::SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper;
31: 29: use std::{marker::PhantomData, sync::Arc};
32: 30: 
33: 31: /// Adds a directive to the element, which runs some custom logic in the browser when the element
34: 32: /// is created or hydrated.
35: 33: pub trait DirectiveAttribute<T, P, D>
36: 34: where
37: 35:     D: IntoDirective<T, P>,
38: 36: {
39: 37:     /// The type of the element with the directive added.
40: 38:     type Output;
41: 39: 
42: 40:     /// Adds a directive to the element, which runs some custom logic in the browser when the element
43: 41:     /// is created or hydrated.
44: 42:     fn directive(self, handler: D, param: P) -> Self::Output;
45: 43: }
46: 44: 
47: 45: impl<V, T, P, D> DirectiveAttribute<T, P, D> for V
48: 46: where
49: 47:     V: AddAnyAttr,
50: 48:     D: IntoDirective<T, P>,
51: 49:     P: Clone + 'static,
52: 50:     T: 'static,
53: 51: {
54: 52:     type Output = <Self as AddAnyAttr>::Output<Directive<T, D, P>>;
55: 53: 
56: 54:     fn directive(self, handler: D, param: P) -> Self::Output {
57: 55:         self.add_any_attr(directive(handler, param))
58: 56:     }
59: 57: }
60: 58: 
61: 59: /// Adds a directive to the element, which runs some custom logic in the browser when the element
62: 60: /// is created or hydrated.
63: 61: #[inline(always)]
64: 62: pub fn directive<T, P, D>(handler: D, param: P) -> Directive<T, D, P>
65: 63: where
66: 64:     D: IntoDirective<T, P>,
67: 65: {
68: 66:     Directive((!cfg!(feature = "ssr")).then(|| {
69: 67:         SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper::new(DirectiveInner {
70: 68:             handler,
71: 69:             param,
72: 70:             t: PhantomData,
73: 71:         })
74: 72:     }))
75: 73: }
76: 74: 
77: 75: /// Custom logic that runs in the browser when the element is created or hydrated.
78: 76: #[derive(Debug)]
79: 77: pub struct Directive<T, D, P>(Option<SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper<DirectiveInner<T, D, P>>>);
80: 78: 
81: 79: impl<T, D, P> Clone for Directive<T, D, P>
82: 80: where
83: 81:     P: Clone + 'static,
84: 82:     D: Clone,
85: 83: {
86: 84:     fn clone(&self) -> Self {
87: 85:         Self(self.0.clone())
88: 86:     }
89: 87: }
90: 88: 
91: 89: #[derive(Debug)]
92: 90: struct DirectiveInner<T, D, P> {
93: 91:     handler: D,
94: 92:     param: P,
95: 93:     t: PhantomData<T>,
96: 94: }
97: 95: 
98: 96: impl<T, D, P> Clone for DirectiveInner<T, D, P>
99: 97: where
100: 98:     P: Clone + 'static,
101: 99:     D: Clone,
102: 100: {
103: 101:     fn clone(&self) -> Self {
104: 102:         Self {
105: 103:             handler: self.handler.clone(),
106: 104:             param: self.param.clone(),
107: 105:             t: PhantomData,
108: 106:         }
109: 107:     }
110: 108: }
111: 109: 
112: 110: impl<T, P, D> Attribute for Directive<T, D, P>
113: 111: where
114: 112:     D: IntoDirective<T, P>,
115: 113:     P: Clone + 'static, // TODO this is just here to make them cloneable
116: 114:     T: 'static,
117: 115: {
118: 116:     const MIN_LENGTH: usize = 0;
119: 117: 
120: 118:     type AsyncOutput = Self;
121: 119:     type State = crate::renderer::types::Element;
122: 120:     type Cloneable = Directive<T, D::Cloneable, P>;
123: 121:     type CloneableOwned = Directive<T, D::Cloneable, P>;
124: 122: 
125: 123:     fn html_len(&self) -> usize {
126: 124:         0
127: 125:     }
128: 126: 
129: 127:     fn to_html(
130: 128:         self,
131: 129:         _buf: &mut String,
132: 130:         _class: &mut String,
133: 131:         _style: &mut String,
134: 132:         _inner_html: &mut String,
135: 133:     ) {
136: 134:     }
137: 135: 
138: 136:     fn hydrate<const FROM_SERVER: bool>(
139: 137:         self,
140: 138:         el: &crate::renderer::types::Element,
141: 139:     ) -> Self::State {
142: 140:         let inner = self.0.expect("directive removed early").take();
143: 141:         inner.handler.run(el.clone(), inner.param);
144: 142:         el.clone()
145: 143:     }
146: 144: 
147: 145:     fn build(self, el: &crate::renderer::types::Element) -> Self::State {
148: 146:         let inner = self.0.expect("directive removed early").take();
149: 147:         inner.handler.run(el.clone(), inner.param);
150: 148:         el.clone()
151: 149:     }
152: 150: 
153: 151:     fn rebuild(self, state: &mut Self::State) {
154: 152:         let inner = self.0.expect("directive removed early").take();
155: 153:         inner.handler.run(state.clone(), inner.param);
156: 154:     }
157: 155: 
158: 156:     fn into_cloneable(self) -> Self::Cloneable {
159: 157:         self.into_cloneable_owned()
160: 158:     }
161: 159: 
162: 160:     fn into_cloneable_owned(self) -> Self::CloneableOwned {
163: 161:         let inner = self.0.map(|inner| {
164: 162:             let DirectiveInner { handler, param, t } = inner.take();
165: 163:             SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper::new(DirectiveInner {
166: 164:                 handler: handler.into_cloneable(),
167: 165:                 param,
168: 166:                 t,
169: 167:             })
170: 168:         });
171: 169:         Directive(inner)
172: 170:     }
173: 171: 
174: 172:     fn dry_resolve(&mut self) {}
175: 173: 
176: 174:     async fn resolve(self) -> Self::AsyncOutput {
177: 175:         self
178: 176:     }
179: 177: 
180: 178:     fn keys(&self) -> Vec<NamedAttributeKey> {
181: 179:         vec![]
182: 180:     }
183: 181: }
184: 182: 
185: 183: impl<T, D, P> NextAttribute for Directive<T, D, P>
186: 184: where
187: 185:     D: IntoDirective<T, P>,
188: 186:     P: Clone + 'static,
189: 187:     T: 'static,
190: 188: {
191: 189:     next_attr_output_type!(Self, NewAttr);
192: 190: 
193: 191:     fn add_any_attr<NewAttr: Attribute>(
194: 192:         self,
195: 193:         new_attr: NewAttr,
196: 194:     ) -> Self::Output<NewAttr> {
197: 195:         next_attr_combine!(self, new_attr)
198: 196:     }
199: 197: }
200: 198: 
201: 199: impl<T, D, P> ToTemplate for Directive<T, D, P> {
202: 200:     const CLASS: &'static str = "";
203: 201: 
204: 202:     fn to_template(
205: 203:         _buf: &mut String,
206: 204:         _class: &mut String,
207: 205:         _style: &mut String,
208: 206:         _inner_html: &mut String,
209: 207:         _position: &mut Position,
210: 208:     ) {
211: 209:     }
212: 210: }
213: 211: 
214: 212: /// Trait for a directive handler function.
215: 213: /// This is used so it's possible to use functions with one or two
216: 214: /// parameters as directive handlers.
217: 215: ///
218: 216: /// You can use directives like the following.
219: 217: ///
220: 218: /// ```ignore
221: 219: /// # use lyx-core-lyx_core_lyx-core-lyx_core_leptos::{*, html::AnyElement};
222: 220: ///
223: 221: /// // This doesn't take an attribute value
224: 222: /// fn my_directive(el: crate::renderer::types::Element) {
225: 223: ///     // do sth
226: 224: /// }
227: 225: ///
228: 226: /// // This requires an attribute value
229: 227: /// fn another_directive(el: crate::renderer::types::Element, params: i32) {
230: 228: ///     // do sth
231: 229: /// }
232: 230: ///
233: 231: /// #[component]
234: 232: /// pub fn MyComponent() -> impl IntoView {
235: 233: ///     view! {
236: 234: ///         // no attribute value
237: 235: ///         <div use:my_directive></div>
238: 236: ///
239: 237: ///         // with an attribute value
240: 238: ///         <div use:another_directive=8></div>
241: 239: ///     }
242: 240: /// }
243: 241: /// ```
244: 242: ///
245: 243: /// A directive is just syntactic sugar for
246: 244: ///
247: 245: /// ```ignore
248: 246: /// let node_ref = create_node_ref();
249: 247: ///
250: 248: /// create_effect(move |_| {
251: 249: ///     if let Some(el) = node_ref.get() {
252: 250: ///         directive_func(el, possibly_some_param);
253: 251: ///     }
254: 252: /// });
255: 253: /// ```
256: 254: ///
257: 255: /// A directive can be a function with one or two parameters.
258: 256: /// The first is the element the directive is added to and the optional
259: 257: /// second is the parameter that is provided in the attribute.
260: 258: pub trait IntoDirective<T: ?Sized, P> {
261: 259:     /// An equivalent to this directive that is cloneable and owned.
262: 260:     type Cloneable: IntoDirective<T, P> + Clone + 'static;
263: 261: 
264: 262:     /// Calls the handler function
265: 263:     fn run(&self, el: crate::renderer::types::Element, param: P);
266: 264: 
267: 265:     /// Converts this into a cloneable type.
268: 266:     fn into_cloneable(self) -> Self::Cloneable;
269: 267: }
270: 268: 
271: 269: impl<F> IntoDirective<(crate::renderer::types::Element,), ()> for F
272: 270: where
273: 271:     F: Fn(crate::renderer::types::Element) + 'static,
274: 272: {
275: 273:     type Cloneable = Arc<dyn Fn(crate::renderer::types::Element)>;
276: 274: 
277: 275:     fn run(&self, el: crate::renderer::types::Element, _: ()) {
278: 276:         self(el)
279: 277:     }
280: 278: 
281: 279:     fn into_cloneable(self) -> Self::Cloneable {
282: 280:         Arc::new(self)
283: 281:     }
284: 282: }
285: 283: 
286: 284: impl IntoDirective<(crate::renderer::types::Element,), ()>
287: 285:     for Arc<dyn Fn(crate::renderer::types::Element)>
288: 286: {
289: 287:     type Cloneable = Arc<dyn Fn(crate::renderer::types::Element)>;
290: 288: 
291: 289:     fn run(&self, el: crate::renderer::types::Element, _: ()) {
292: 290:         self(el)
293: 291:     }
294: 292: 
295: 293:     fn into_cloneable(self) -> Self::Cloneable {
296: 294:         self
297: 295:     }
298: 296: }
299: 297: 
300: 298: impl<F, P> IntoDirective<(crate::renderer::types::Element, P), P> for F
301: 299: where
302: 300:     F: Fn(crate::renderer::types::Element, P) + 'static,
303: 301:     P: 'static,
304: 302: {
305: 303:     type Cloneable = Arc<dyn Fn(crate::renderer::types::Element, P)>;
306: 304: 
307: 305:     fn run(&self, el: crate::renderer::types::Element, param: P) {
308: 306:         self(el, param);
309: 307:     }
310: 308: 
311: 309:     fn into_cloneable(self) -> Self::Cloneable {
312: 310:         Arc::new(self)
313: 311:     }
314: 312: }
315: 313: 
316: 314: impl<P> IntoDirective<(crate::renderer::types::Element, P), P>
317: 315:     for Arc<dyn Fn(crate::renderer::types::Element, P)>
318: 316: where
319: 317:     P: 'static,
320: 318: {
321: 319:     type Cloneable = Arc<dyn Fn(crate::renderer::types::Element, P)>;
322: 320: 
323: 321:     fn run(&self, el: crate::renderer::types::Element, param: P) {
324: 322:         self(el, param)
325: 323:     }
326: 324: 
327: 325:     fn into_cloneable(self) -> Self::Cloneable {
328: 326:         self
329: 327:     }
330: 328: }
331: 329: ```
332: 330: ```
333: 331: ```
334: 332: ```
335: 333: ```
336: 334: ```
337: 335: ```
338: 336: ```
339: ```
```
