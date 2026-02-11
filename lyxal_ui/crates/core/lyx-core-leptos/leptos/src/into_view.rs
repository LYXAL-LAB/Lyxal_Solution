### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_leptos\src\into_view.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\into_view.rs
2: ```rust
3: 1: use std::borrow::Cow;
4: 2: use lyx-core-lyx_core_lyx-core-lyx_core_tachys::{
5: 3:     html::attribute::{any_attribute::AnyAttribute, Attribute},
6: 4:     hydration::Cursor,
7: 5:     ssr::StreamBuilder,
8: 6:     view::{
9: 7:         add_attr::AddAnyAttr, Position, PositionState, Render, RenderHtml,
10: 8:         ToTemplate,
11: 9:     },
12: 10: };
13: 11: 
14: 12: /// A wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper for any kind of view.
15: 13: #[derive(Debug, Clone, PartialEq, Eq, Hash, PartialOrd, Ord)]
16: 14: pub struct View<T>
17: 15: where
18: 16:     T: Sized,
19: 17: {
20: 18:     inner: T,
21: 19:     #[cfg(debug_assertions)]
22: 20:     view_marker: Option<Cow<'static, str>>,
23: 21: }
24: 22: 
25: 23: impl<T> View<T> {
26: 24:     /// Wraps the view.
27: 25:     pub fn new(inner: T) -> Self {
28: 26:         Self {
29: 27:             inner,
30: 28:             #[cfg(debug_assertions)]
31: 29:             view_marker: None,
32: 30:         }
33: 31:     }
34: 32: 
35: 33:     /// Unwraps the view, returning the inner type.
36: 34:     pub fn into_inner(self) -> T {
37: 35:         self.inner
38: 36:     }
39: 37: 
40: 38:     /// Adds a view marker, which is used for hot-reloading and debug purposes.
41: 39:     #[inline(always)]
42: 40:     pub fn with_view_marker(
43: 41:         #[allow(unused_mut)] // used in debug
44: 42:         mut self,
45: 43:         #[allow(unused_variables)] // used in debug
46: 44:         view_marker: impl Into<Cow<'static, str>>,
47: 45:     ) -> Self {
48: 46:         #[cfg(debug_assertions)]
49: 47:         {
50: 48:             self.view_marker = Some(view_marker.into());
51: 49:         }
52: 50:         self
53: 51:     }
54: 52: }
55: 53: 
56: 54: /// A trait that is implemented for types that can be rendered.
57: 55: pub trait IntoView
58: 56: where
59: 57:     Self: Sized + Render + RenderHtml + Send,
60: 58: {
61: 59:     /// Wraps the inner type.
62: 60:     fn into_view(self) -> View<Self>;
63: 61: }
64: 62: 
65: 63: impl<T> IntoView for T
66: 64: where
67: 65:     T: Sized + Render + RenderHtml + Send, //+ AddAnyAttr,
68: 66: {
69: 67:     fn into_view(self) -> View<Self> {
70: 68:         View {
71: 69:             inner: self,
72: 70:             #[cfg(debug_assertions)]
73: 71:             view_marker: None,
74: 72:         }
75: 73:     }
76: 74: }
77: 75: 
78: 76: impl<T: Render> Render for View<T> {
79: 77:     type State = T::State;
80: 78: 
81: 79:     fn build(self) -> Self::State {
82: 80:         self.inner.build()
83: 81:     }
84: 82: 
85: 83:     fn rebuild(self, state: &mut Self::State) {
86: 84:         self.inner.rebuild(state)
87: 85:     }
88: 86: }
89: 87: 
90: 88: impl<T: RenderHtml> RenderHtml for View<T> {
91: 89:     type AsyncOutput = T::AsyncOutput;
92: 90:     type Owned = View<T::Owned>;
93: 91: 
94: 92:     const MIN_LENGTH: usize = <T as RenderHtml>::MIN_LENGTH;
95: 93:     const EXISTS: bool = <T as RenderHtml>::EXISTS;
96: 94: 
97: 95:     async fn resolve(self) -> Self::AsyncOutput {
98: 96:         self.inner.resolve().await
99: 97:     }
100: 98: 
101: 99:     fn dry_resolve(&mut self) {
102: 100:         self.inner.dry_resolve();
103: 101:     }
104: 102: 
105: 103:     fn to_html_with_buf(
106: 104:         self,
107: 105:         buf: &mut String,
108: 106:         position: &mut Position,
109: 107:         escape: bool,
110: 108:         mark_branches: bool,
111: 109:         extra_attrs: Vec<AnyAttribute>,
112: 110:     ) {
113: 111:         #[cfg(debug_assertions)]
114: 112:         let vm = if option_env!("LEPTOS_WATCH").is_some() {
115: 113:             self.view_marker.to_owned()
116: 114:         } else {
117: 115:             None
118: 116:         };
119: 117: 
120: 118:         #[cfg(debug_assertions)]
121: 119:         if let Some(vm) = vm.as_ref() {
122: 120:             buf.push_str(&format!("<!--hot-reload|{vm}|open-->"));
123: 121:         }
124: 122: 
125: 123:         self.inner.to_html_with_buf(
126: 124:             buf,
127: 125:             position,
128: 126:             escape,
129: 127:             mark_branches,
130: 128:             extra_attrs,
131: 129:         );
132: 130: 
133: 131:         #[cfg(debug_assertions)]
134: 132:         if let Some(vm) = vm.as_ref() {
135: 133:             buf.push_str(&format!("<!--hot-reload|{vm}|close-->"));
136: 134:         }
137: 135:     }
138: 136: 
139: 137:     fn to_html_async_with_buf<const OUT_OF_ORDER: bool>(
140: 138:         self,
141: 139:         buf: &mut StreamBuilder,
142: 140:         position: &mut Position,
143: 141:         escape: bool,
144: 142:         mark_branches: bool,
145: 143:         extra_attrs: Vec<AnyAttribute>,
146: 144:     ) where
147: 145:         Self: Sized,
148: 146:     {
149: 147:         #[cfg(debug_assertions)]
150: 148:         let vm = if option_env!("LEPTOS_WATCH").is_some() {
151: 149:             self.view_marker.to_owned()
152: 150:         } else {
153: 151:             None
154: 152:         };
155: 153: 
156: 154:         #[cfg(debug_assertions)]
157: 155:         if let Some(vm) = vm.as_ref() {
158: 156:             buf.push_sync(&format!("<!--hot-reload|{vm}|open-->"));
159: 157:         }
160: 158: 
161: 159:         self.inner.to_html_async_with_buf::<OUT_OF_ORDER>(
162: 160:             buf,
163: 161:             position,
164: 162:             escape,
165: 163:             mark_branches,
166: 164:             extra_attrs,
167: 165:         );
168: 166: 
169: 167:         #[cfg(debug_assertions)]
170: 168:         if let Some(vm) = vm.as_ref() {
171: 169:             buf.push_sync(&format!("<!--hot-reload|{vm}|close-->"));
172: 170:         }
173: 171:     }
174: 172: 
175: 173:     fn hydrate<const FROM_SERVER: bool>(
176: 174:         self,
177: 175:         cursor: &Cursor,
178: 176:         position: &PositionState,
179: 177:     ) -> Self::State {
180: 178:         self.inner.hydrate::<FROM_SERVER>(cursor, position)
181: 179:     }
182: 180: 
183: 181:     async fn hydrate_async(
184: 182:         self,
185: 183:         cursor: &Cursor,
186: 184:         position: &PositionState,
187: 185:     ) -> Self::State {
188: 186:         self.inner.hydrate_async(cursor, position).await
189: 187:     }
190: 188: 
191: 189:     fn into_owned(self) -> Self::Owned {
192: 190:         View {
193: 191:             inner: self.inner.into_owned(),
194: 192:             #[cfg(debug_assertions)]
195: 193:             view_marker: self.view_marker,
196: 194:         }
197: 195:     }
198: 196: }
199: 197: 
200: 198: impl<T: ToTemplate> ToTemplate for View<T> {
201: 199:     fn to_template(
202: 200:         buf: &mut String,
203: 201:         class: &mut String,
204: 202:         style: &mut String,
205: 203:         inner_html: &mut String,
206: 204:         position: &mut Position,
207: 205:     ) {
208: 206:         T::to_template(buf, class, style, inner_html, position);
209: 207:     }
210: 208: }
211: 209: 
212: 210: impl<T: AddAnyAttr> AddAnyAttr for View<T> {
213: 211:     type Output<SomeNewAttr: Attribute> = View<T::Output<SomeNewAttr>>;
214: 212: 
215: 213:     fn add_any_attr<NewAttr: Attribute>(
216: 214:         self,
217: 215:         attr: NewAttr,
218: 216:     ) -> Self::Output<NewAttr>
219: 217:     where
220: 218:         Self::Output<NewAttr>: RenderHtml,
221: 219:     {
222: 220:         let View {
223: 221:             inner,
224: 222:             #[cfg(debug_assertions)]
225: 223:             view_marker,
226: 224:         } = self;
227: 225:         View {
228: 226:             inner: inner.add_any_attr(attr),
229: 227:             #[cfg(debug_assertions)]
230: 228:             view_marker,
231: 229:         }
232: 230:     }
233: 231: }
234: 232: 
235: 233: /// Collects some iterator of views into a list, so they can be rendered.
236: 234: ///
237: 235: /// This is a shorthand for `.collect::<Vec<_>>()`, and allows any iterator of renderable
238: 236: /// items to be collected into a renderable collection.
239: 237: pub trait CollectView {
240: 238:     /// The inner view type.
241: 239:     type View: IntoView;
242: 240: 
243: 241:     /// Collects the iterator into a list of views.
244: 242:     fn collect_view(self) -> Vec<Self::View>;
245: 243: }
246: 244: 
247: 245: impl<It, V> CollectView for It
248: 246: where
249: 247:     It: IntoIterator<Item = V>,
250: 248:     V: IntoView,
251: 249: {
252: 250:     type View = V;
253: 251: 
254: 252:     fn collect_view(self) -> Vec<Self::View> {
255: 253:         self.into_iter().collect()
256: 254:     }
257: 255: }
258: ```
```
