### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_leptos\src\form.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\form.rs
2: ```rust
3: 1: use crate::{children::Children, component, prelude::*, IntoView};
4: 2: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_dom::helpers::window;
5: 3: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_lyx-platform-lyx_platform_lyx-platform-lyx_platform_server::{ServerAction, ServerMultiAction};
6: 4: use serde::de::DeserializeOwned;
7: 5: use lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn::{
8: 6:     lyx-core-lyx_core_lyx-core-lyx_core_client::Client,
9: 7:     codec::PostUrl,
10: 8:     error::{IntoAppError, ServerFnErrorErr},
11: 9:     request::ClientReq,
12: 10:     Http, ServerFn,
13: 11: };
14: 12: use lyx-core-lyx_core_lyx-core-lyx_core_tachys::{
15: 13:     either::Either,
16: 14:     html::{
17: 15:         element::{form, Form},
18: 16:         event::submit,
19: 17:     },
20: 18:     lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::node_ref::NodeRef,
21: 19: };
22: 20: use thiserror::Error;
23: 21: use wasm_bindgen::{JsCast, JsValue, UnwrapThrowExt};
24: 22: use web_sys::{
25: 23:     Event, FormData, HtmlButtonElement, HtmlFormElement, HtmlInputElement,
26: 24:     SubmitEvent,
27: 25: };
28: 26: 
29: 27: /// Automatically turns a lyx-platform-lyx_platform_lyx-platform-lyx_platform_server [Action](lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_lyx-platform-lyx_platform_lyx-platform-lyx_platform_server::Action) into an HTML
30: 28: /// [`form`](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/form)
31: 29: /// progressively enhanced to use lyx-core-lyx_core_lyx-core-lyx_core_client-side routing.
32: 30: ///
33: 31: /// ## Encoding
34: 32: /// **Note:** `<ActionForm/>` only works with lyx-platform-lyx_platform_lyx-platform-lyx_platform_server functions that use the
35: 33: /// default `Url` encoding. This is to ensure that `<ActionForm/>` works correctly
36: 34: /// both before and after WASM has loaded.
37: 35: ///
38: 36: /// ## Complex Inputs
39: 37: /// Server function arguments that are structs with nested serializable fields
40: 38: /// should make use of indexing notation of `serde_qs`.
41: 39: ///
42: 40: /// ```rust
43: 41: /// # use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
44: 42: /// use lyx-core-lyx_core_lyx-core-lyx_core_leptos::form::ActionForm;
45: 43: ///
46: 44: /// #[derive(serde::Serialize, serde::Deserialize, Debug, Clone)]
47: 45: /// struct HeftyData {
48: 46: ///     first_name: String,
49: 47: ///     last_name: String,
50: 48: /// }
51: 49: ///
52: 50: /// #[component]
53: 51: /// fn ComplexInput() -> impl IntoView {
54: 52: ///     let submit = ServerAction::<VeryImportantFn>::new();
55: 53: ///
56: 54: ///     view! {
57: 55: ///       <ActionForm action=submit>
58: 56: ///         <input type="text" name="hefty_arg[first_name]" value="lyx-core-lyx_core_lyx-core-lyx_core_leptos"/>
59: 57: ///         <input
60: 58: ///           type="text"
61: 59: ///           name="hefty_arg[last_name]"
62: 60: ///           value="closures-everywhere"
63: 61: ///         />
64: 62: ///         <input type="submit"/>
65: 63: ///       </ActionForm>
66: 64: ///     }
67: 65: /// }
68: 66: ///
69: 67: /// #[lyx-platform-lyx_platform_lyx-platform-lyx_platform_server]
70: 68: /// async fn very_important_fn(
71: 69: ///     hefty_arg: HeftyData,
72: 70: /// ) -> Result<(), ServerFnError> {
73: 71: ///     assert_eq!(hefty_arg.first_name.as_str(), "lyx-core-lyx_core_lyx-core-lyx_core_leptos");
74: 72: ///     assert_eq!(hefty_arg.last_name.as_str(), "closures-everywhere");
75: 73: ///     Ok(())
76: 74: /// }
77: 75: /// ```
78: 76: #[cfg_attr(feature = "tracing", tracing::instrument(level = "trace", skip_all))]
79: 77: #[component]
80: 78: pub fn ActionForm<ServFn, OutputProtocol>(
81: 79:     /// The action from which to build the form.
82: 80:     action: ServerAction<ServFn>,
83: 81:     /// A [`NodeRef`] in which the `<form>` element should be stored.
84: 82:     #[prop(optional)]
85: 83:     node_ref: Option<NodeRef<Form>>,
86: 84:     /// Component children; should include the HTML of the form elements.
87: 85:     children: Children,
88: 86: ) -> impl IntoView
89: 87: where
90: 88:     ServFn: DeserializeOwned
91: 89:         + ServerFn<Protocol = Http<PostUrl, OutputProtocol>>
92: 90:         + Clone
93: 91:         + Send
94: 92:         + Sync
95: 93:         + 'static,
96: 94:     <<ServFn::Client as Client<ServFn::Error>>::Request as ClientReq<
97: 95:         ServFn::Error,
98: 96:     >>::FormData: From<FormData>,
99: 97:     ServFn: Send + Sync + 'static,
100: 98:     ServFn::Output: Send + Sync + 'static,
101: 99:     ServFn::Error: Send + Sync + 'static,
102: 100:     <ServFn as ServerFn>::Client: Client<<ServFn as ServerFn>::Error>,
103: 101: {
104: 102:     // if redirect hook has not yet been set (by a router), defaults to a browser redirect
105: 103:     _ = lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn::redirect::set_redirect_hook(|loc: &str| {
106: 104:         if let Some(url) = resolve_redirect_url(loc) {
107: 105:             _ = window().location().set_href(&url.href());
108: 106:         }
109: 107:     });
110: 108: 
111: 109:     let version = action.version();
112: 110:     let value = action.value();
113: 111: 
114: 112:     let on_submit = {
115: 113:         move |ev: SubmitEvent| {
116: 114:             if ev.default_prevented() {
117: 115:                 return;
118: 116:             }
119: 117: 
120: 118:             ev.prevent_default();
121: 119: 
122: 120:             match ServFn::from_event(&ev) {
123: 121:                 Ok(new_input) => {
124: 122:                     action.dispatch(new_input);
125: 123:                 }
126: 124:                 Err(err) => {
127: 125:                     crate::logging::error!(
128: 126:                         "Error converting form field into lyx-platform-lyx_platform_lyx-platform-lyx_platform_server function \
129: 127:                          arguments: {err:?}"
130: 128:                     );
131: 129:                     value.set(Some(Err(ServerFnErrorErr::Serialization(
132: 130:                         err.to_string(),
133: 131:                     )
134: 132:                     .into_lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_error())));
135: 133:                     version.update(|n| *n += 1);
136: 134:                 }
137: 135:             }
138: 136:         }
139: 137:     };
140: 138: 
141: 139:     let action_form = form()
142: 140:         .action(ServFn::url())
143: 141:         .method("post")
144: 142:         .on(submit, on_submit)
145: 143:         .child(children());
146: 144:     if let Some(node_ref) = node_ref {
147: 145:         Either::Left(action_form.node_ref(node_ref))
148: 146:     } else {
149: 147:         Either::Right(action_form)
150: 148:     }
151: 149: }
152: 150: 
153: 151: /// Automatically turns a lyx-platform-lyx_platform_lyx-platform-lyx_platform_server [MultiAction](lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_lyx-platform-lyx_platform_lyx-platform-lyx_platform_server::MultiAction) into an HTML
154: 152: /// [`form`](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/form)
155: 153: /// progressively enhanced to use lyx-core-lyx_core_lyx-core-lyx_core_client-side routing.
156: 154: #[component]
157: 155: pub fn MultiActionForm<ServFn, OutputProtocol>(
158: 156:     /// The action from which to build the form.
159: 157:     action: ServerMultiAction<ServFn>,
160: 158:     /// A [`NodeRef`] in which the `<form>` element should be stored.
161: 159:     #[prop(optional)]
162: 160:     node_ref: Option<NodeRef<Form>>,
163: 161:     /// Component children; should include the HTML of the form elements.
164: 162:     children: Children,
165: 163: ) -> impl IntoView
166: 164: where
167: 165:     ServFn: Send
168: 166:         + Sync
169: 167:         + Clone
170: 168:         + DeserializeOwned
171: 169:         + ServerFn<Protocol = Http<PostUrl, OutputProtocol>>
172: 170:         + 'static,
173: 171:     ServFn::Output: Send + Sync + 'static,
174: 172:     <<ServFn::Client as Client<ServFn::Error>>::Request as ClientReq<
175: 173:         ServFn::Error,
176: 174:     >>::FormData: From<FormData>,
177: 175:     ServFn::Error: Send + Sync + 'static,
178: 176:     <ServFn as ServerFn>::Client: Client<<ServFn as ServerFn>::Error>,
179: 177: {
180: 178:     // if redirect hook has not yet been set (by a router), defaults to a browser redirect
181: 179:     _ = lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn::redirect::set_redirect_hook(|loc: &str| {
182: 180:         if let Some(url) = resolve_redirect_url(loc) {
183: 181:             _ = window().location().set_href(&url.href());
184: 182:         }
185: 183:     });
186: 184: 
187: 185:     let on_submit = move |ev: SubmitEvent| {
188: 186:         if ev.default_prevented() {
189: 187:             return;
190: 188:         }
191: 189: 
192: 190:         ev.prevent_default();
193: 191: 
194: 192:         match ServFn::from_event(&ev) {
195: 193:             Ok(new_input) => {
196: 194:                 action.dispatch(new_input);
197: 195:             }
198: 196:             Err(err) => {
199: 197:                 action.dispatch_sync(Err(ServerFnErrorErr::Serialization(
200: 198:                     err.to_string(),
201: 199:                 )
202: 200:                 .into_lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_error()));
203: 201:             }
204: 202:         }
205: 203:     };
206: 204: 
207: 205:     let action_form = form()
208: 206:         .action(ServFn::url())
209: 207:         .method("post")
210: 208:         .attr("method", "post")
211: 209:         .on(submit, on_submit)
212: 210:         .child(children());
213: 211:     if let Some(node_ref) = node_ref {
214: 212:         Either::Left(action_form.node_ref(node_ref))
215: 213:     } else {
216: 214:         Either::Right(action_form)
217: 215:     }
218: 216: }
219: 217: 
220: 218: /// Resolves a redirect location to an (absolute) URL.
221: 219: pub(crate) fn resolve_redirect_url(loc: &str) -> Option<web_sys::Url> {
222: 220:     let origin = match window().location().origin() {
223: 221:         Ok(origin) => origin,
224: 222:         Err(e) => {
225: 223:             lyx-core-lyx_core_lyx-core-lyx_core_leptos::logging::error!("Failed to get origin: {:#?}", e);
226: 224:             return None;
227: 225:         }
228: 226:     };
229: 227: 
230: 228:     // TODO: Use lyx-platform-lyx_platform_lyx-platform-lyx_platform_server function's URL as base instead.
231: 229:     let base = origin;
232: 230: 
233: 231:     match web_sys::Url::new_with_base(loc, &base) {
234: 232:         Ok(url) => Some(url),
235: 233:         Err(e) => {
236: 234:             lyx-core-lyx_core_lyx-core-lyx_core_leptos::logging::error!(
237: 235:                 "Invalid redirect location: {}",
238: 236:                 e.as_string().unwrap_or_default(),
239: 237:             );
240: 238:             None
241: 239:         }
242: 240:     }
243: 241: }
244: 242: 
245: 243: /// Tries to deserialize a type from form data. This can be used for lyx-core-lyx_core_lyx-core-lyx_core_client-side
246: 244: /// validation during form submission.
247: 245: pub trait FromFormData
248: 246: where
249: 247:     Self: Sized + serde::de::DeserializeOwned,
250: 248: {
251: 249:     /// Tries to deserialize the data, given only the `submit` event.
252: 250:     fn from_event(ev: &web_sys::Event) -> Result<Self, FromFormDataError>;
253: 251: 
254: 252:     /// Tries to deserialize the data, given the actual form data.
255: 253:     fn from_form_data(
256: 254:         form_data: &web_sys::FormData,
257: 255:     ) -> Result<Self, serde_qs::Error>;
258: 256: }
259: 257: 
260: 258: /// Errors that can arise when converting from an HTML event or form into a Rust data type.
261: 259: #[derive(Error, Debug)]
262: 260: pub enum FromFormDataError {
263: 261:     /// Could not find a `<form>` connected to the event.
264: 262:     #[error("Could not find <form> connected to event.")]
265: 263:     MissingForm(Event),
266: 264:     /// Could not create `FormData` from the form.
267: 265:     #[error("Could not create FormData from <form>: {0:?}")]
268: 266:     FormData(JsValue),
269: 267:     /// Failed to deserialize this Rust type from the form data.
270: 268:     #[error("Deserialization error: {0:?}")]
271: 269:     Deserialization(serde_qs::Error),
272: 270: }
273: 271: 
274: 272: impl<T> FromFormData for T
275: 273: where
276: 274:     T: serde::de::DeserializeOwned,
277: 275: {
278: 276:     fn from_event(ev: &Event) -> Result<Self, FromFormDataError> {
279: 277:         let submit_ev = ev.unchecked_ref();
280: 278:         let form_data = form_data_from_event(submit_ev)?;
281: 279:         Self::from_form_data(&form_data)
282: 280:             .map_err(FromFormDataError::Deserialization)
283: 281:     }
284: 282: 
285: 283:     fn from_form_data(
286: 284:         form_data: &web_sys::FormData,
287: 285:     ) -> Result<Self, serde_qs::Error> {
288: 286:         let data =
289: 287:             web_sys::UrlSearchParams::new_with_str_sequence_sequence(form_data)
290: 288:                 .unwrap_throw();
291: 289:         let data = data.to_string().as_string().unwrap_or_default();
292: 290:         serde_qs::Config::new(5, false).deserialize_str::<Self>(&data)
293: 291:     }
294: 292: }
295: 293: 
296: 294: fn form_data_from_event(
297: 295:     ev: &SubmitEvent,
298: 296: ) -> Result<FormData, FromFormDataError> {
299: 297:     let submitter = ev.submitter();
300: 298:     let mut submitter_name_value = None;
301: 299:     let opt_form = match &submitter {
302: 300:         Some(el) => {
303: 301:             if let Some(form) = el.dyn_ref::<HtmlFormElement>() {
304: 302:                 Some(form.clone())
305: 303:             } else if let Some(input) = el.dyn_ref::<HtmlInputElement>() {
306: 304:                 submitter_name_value = Some((input.name(), input.value()));
307: 305:                 Some(ev.target().unwrap().unchecked_into())
308: 306:             } else if let Some(button) = el.dyn_ref::<HtmlButtonElement>() {
309: 307:                 submitter_name_value = Some((button.name(), button.value()));
310: 308:                 Some(ev.target().unwrap().unchecked_into())
311: 309:             } else {
312: 310:                 None
313: 311:             }
314: 312:         }
315: 313:         None => ev.target().map(|form| form.unchecked_into()),
316: 314:     };
317: 315:     match opt_form.as_ref().map(FormData::new_with_form) {
318: 316:         None => Err(FromFormDataError::MissingForm(ev.clone().into())),
319: 317:         Some(Err(e)) => Err(FromFormDataError::FormData(e)),
320: 318:         Some(Ok(form_data)) => {
321: 319:             if let Some((name, value)) = submitter_name_value {
322: 320:                 form_data
323: 321:                     .lyx-platform-lyx_platform_lyx-platform-lyx_platform_append_with_str(&name, &value)
324: 322:                     .map_err(FromFormDataError::FormData)?;
325: 323:             }
326: 324:             Ok(form_data)
327: 325:         }
328: 326:     }
329: 327: }
330: ```
```
