### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_lyx-core-lyx_core_superposition_derives\src\lib.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_derives\src\lib.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_derives\src\lib.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_derives\src\lib.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_derives\src\lib.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_derives\src\lib.rs
10: 8: ```rust
11: 9: extern crate proc_macro;
12: 10: 
13: 11: use proc_macro::TokenStream;
14: 12: use quote::{format_ident, quote};
15: 13: use syn::{Data, DeriveInput, Fields, ItemFn, LitStr, Type, parse_macro_input};
16: 14: 
17: 15: /// Implements `FromSql` trait for converting `Json` type to the type for `Pg` lyx-platform-lyx_platform_lyx-platform-lyx_platform_backend
18: 16: ///
19: 17: #[cfg(feature = "diesel_derives")]
20: 18: #[proc_macro_derive(JsonFromSql)]
21: 19: pub fn json_from_sql_derive(input: TokenStream) -> TokenStream {
22: 20:     let input = parse_macro_input!(input as DeriveInput);
23: 21:     let name = input.ident;
24: 22: 
25: 23:     let expanded = quote! {
26: 24:         impl diesel::deserialize::FromSql<diesel::sql_types::Json, diesel::pg::Pg> for #name {
27: 25:             fn from_sql(bytes: diesel::pg::PgValue<'_>) -> diesel::deserialize::Result<Self> {
28: 26:                 let value = <serde_json::Value as diesel::deserialize::FromSql<diesel::sql_types::Json, diesel::pg::Pg>>::from_sql(bytes)?;
29: 27:                 Ok(serde_json::from_value(value)?)
30: 28:             }
31: 29:         }
32: 30:     };
33: 31: 
34: 32:     TokenStream::from(expanded)
35: 33: }
36: 34: 
37: 35: /// Implements `ToSql` trait for converting the typed data to `Json` type for `Pg` lyx-platform-lyx_platform_lyx-platform-lyx_platform_backend
38: 36: ///
39: 37: #[cfg(feature = "diesel_derives")]
40: 38: #[proc_macro_derive(JsonToSql)]
41: 39: pub fn json_to_sql_derive(input: TokenStream) -> TokenStream {
42: 40:     let input = parse_macro_input!(input as DeriveInput);
43: 41:     let name = input.ident;
44: 42: 
45: 43:     let expanded = quote! {
46: 44:         impl diesel::serialize::ToSql<diesel::sql_types::Json, diesel::pg::Pg> for #name {
47: 45:             fn to_sql<'b>(
48: 46:                 &'b self,
49: 47:                 out: &mut diesel::serialize::Output<'b, '_, diesel::pg::Pg>,
50: 48:             ) -> diesel::serialize::Result {
51: 49:                 let value = serde_json::to_value(self)?;
52: 50:                 <serde_json::Value as diesel::serialize::ToSql<diesel::sql_types::Json, diesel::pg::Pg>>::to_sql(
53: 51:                     &value,
54: 52:                     &mut out.reborrow(),
55: 53:                 )
56: 54:             }
57: 55:         }
58: 56:     };
59: 57: 
60: 58:     TokenStream::from(expanded)
61: 59: }
62: 60: 
63: 61: /// Implements `FromSql` trait for converting `Text` type to the type for `Pg` lyx-platform-lyx_platform_lyx-platform-lyx_platform_backend
64: 62: ///
65: 63: #[cfg(feature = "diesel_derives")]
66: 64: #[proc_macro_derive(TextFromSql)]
67: 65: pub fn text_from_sql_derive(input: TokenStream) -> TokenStream {
68: 66:     let input = parse_macro_input!(input as DeriveInput);
69: 67:     let name = input.ident;
70: 68: 
71: 69:     quote! {
72: 70:         impl diesel::deserialize::FromSql<diesel::sql_types::Text, diesel::pg::Pg> for #name {
73: 71:             fn from_sql(bytes: diesel::pg::PgValue<'_>) -> diesel::deserialize::Result<Self> {
74: 72:                 let text = <String as diesel::deserialize::FromSql<diesel::sql_types::Text, diesel::pg::Pg>>::from_sql(bytes)?;
75: 73:                 text.try_into().map_err(|e: String| e.into())
76: 74:             }
77: 75:         }
78: 76:     }.into()
79: 77: }
80: 78: 
81: 79: /// Implements `ToSql` trait for converting the typed data to `Json` type for `Pg` lyx-platform-lyx_platform_lyx-platform-lyx_platform_backend
82: 80: ///
83: 81: #[cfg(feature = "diesel_derives")]
84: 82: #[proc_macro_derive(TextToSql)]
85: 83: pub fn text_to_sql_derive(input: TokenStream) -> TokenStream {
86: 84:     let input = parse_macro_input!(input as DeriveInput);
87: 85:     let name = input.ident;
88: 86: 
89: 87:     quote! {
90: 88:         impl diesel::serialize::ToSql<diesel::sql_types::Text, diesel::pg::Pg> for #name {
91: 89:             fn to_sql<'b>(
92: 90:                 &'b self,
93: 91:                 out: &mut diesel::serialize::Output<'b, '_, diesel::pg::Pg>,
94: 92:             ) -> diesel::serialize::Result {
95: 93:                 let text: String = self.into();
96: 94:                 <String as diesel::serialize::ToSql<
97: 95:                     diesel::sql_types::Text,
98: 96:                     diesel::pg::Pg,
99: 97:                 >>::to_sql(&text, &mut out.reborrow())
100: 98:             }
101: 99:         }
102: 100:     }
103: 101:     .into()
104: 102: }
105: 103: 
106: 104: /// Implements `FromSql` trait for converting `Text` type to the type for `Pg` lyx-platform-lyx_platform_lyx-platform-lyx_platform_backend without running validations on it
107: 105: ///
108: 106: #[cfg(feature = "diesel_derives")]
109: 107: #[proc_macro_derive(TextFromSqlNoValidation)]
110: 108: pub fn text_from_sql_derive_no_validation(input: TokenStream) -> TokenStream {
111: 109:     let input = parse_macro_input!(input as DeriveInput);
112: 110:     let name = input.ident;
113: 111: 
114: 112:     quote! {
115: 113:         impl diesel::deserialize::FromSql<diesel::sql_types::Text, diesel::pg::Pg> for #name {
116: 114:             fn from_sql(bytes: diesel::pg::PgValue<'_>) -> diesel::deserialize::Result<Self> {
117: 115:                 let text = <String as diesel::deserialize::FromSql<diesel::sql_types::Text, diesel::pg::Pg>>::from_sql(bytes)?;
118: 116:                 Ok(<#name as DisableDBValidation>::from_db_unvalidated(text))
119: 117:             }
120: 118:         }
121: 119:     }.into()
122: 120: }
123: 121: 
124: 122: /// Implements `IsEmpty` trait for structs
125: 123: ///
126: 124: /// This trait is used to check if a struct is empty based on its fields.
127: 125: /// If a struct has any non-Option fields, it is considered non-empty.
128: 126: /// If all fields are Option types, it is considered empty if all Options are None.
129: 127: /// The macro generates an implementation of the `IsEmpty` trait for the struct.
130: 128: /// The macro checks the fields of the struct and generates the lyx-platform-lyx_platform_lyx-platform-lyx_platform_appropriate implementation.
131: 129: /// The macro can only be used on structs with named fields.
132: 130: /// If the struct has no fields or has unnamed fields, an error is returned.
133: 131: ///
134: 132: #[proc_macro_derive(IsEmpty)]
135: 133: pub fn derive_is_empty(input: TokenStream) -> TokenStream {
136: 134:     let input = parse_macro_input!(input as DeriveInput);
137: 135:     let struct_name = input.ident;
138: 136: 
139: 137:     let fields = if let Data::Struct(data) = input.data {
140: 138:         match data.fields {
141: 139:             Fields::Named(fields) => fields.named,
142: 140:             Fields::Unnamed(_) | Fields::Unit => {
143: 141:                 return syn::Error::new_spanned(
144: 142:                     struct_name,
145: 143:                     "IsEmpty can only be derived for structs with named fields",
146: 144:                 )
147: 145:                 .to_compile_error()
148: 146:                 .into();
149: 147:             }
150: 148:         }
151: 149:     } else {
152: 150:         return syn::Error::new_spanned(
153: 151:             struct_name,
154: 152:             "IsEmpty can only be derived for structs",
155: 153:         )
156: 154:         .to_compile_error()
157: 155:         .into();
158: 156:     };
159: 157: 
160: 158:     let mut checks = Vec::new();
161: 159:     let mut has_mandatory = false;
162: 160: 
163: 161:     for field in fields {
164: 162:         let field_name = field.ident.unwrap();
165: 163:         let ty = field.ty;
166: 164: 
167: 165:         if let Type::Path(type_path) = &ty {
168: 166:             if type_path
169: 167:                 .path
170: 168:                 .segments
171: 169:                 .first()
172: 170:                 .is_some_and(|seg| seg.ident == "Option")
173: 171:             {
174: 172:                 checks.push(quote! {
175: 173:                     if self.#field_name.is_some() {
176: 174:                         return false;
177: 175:                     }
178: 176:                 });
179: 177:                 continue;
180: 178:             }
181: 179:         }
182: 180: 
183: 181:         has_mandatory = true;
184: 182:         break;
185: 183:     }
186: 184: 
187: 185:     let expanded = if has_mandatory {
188: 186:         quote! {
189: 187:             impl IsEmpty for #struct_name {
190: 188:                 fn is_empty(&self) -> bool {
191: 189:                     false
192: 190:                 }
193: 191:             }
194: 192:         }
195: 193:     } else {
196: 194:         quote! {
197: 195:             impl IsEmpty for #struct_name {
198: 196:                 fn is_empty(&self) -> bool {
199: 197:                     #(#checks)*
200: 198: 
201: 199:                     true
202: 200:                 }
203: 201:             }
204: 202:         }
205: 203:     };
206: 204: 
207: 205:     TokenStream::from(expanded)
208: 206: }
209: 207: 
210: 208: /// Implements `QueryParam` trait for the struct, allowing it to be used as a query string
211: 209: ///
212: 210: /// Supports the following attributes on fields:
213: 211: /// - `#[query_param(skip_if_empty)]`: Skip the field if it's empty (requires `IsEmpty` trait)
214: 212: /// - `#[query_param(iterable)]`: Iterate over the field and create multiple query parameters with the same key
215: 213: /// - `#[query_param(skip_if_empty, iterable)]`: Combine both behaviors
216: 214: ///
217: 215: #[proc_macro_derive(QueryParam, attributes(query_param))]
218: 216: pub fn derive_query_param(input: TokenStream) -> TokenStream {
219: 217:     let input = parse_macro_input!(input as DeriveInput);
220: 218:     let struct_name = input.ident;
221: 219: 
222: 220:     let fields = if let Data::Struct(data) = input.data {
223: 221:         match data.fields {
224: 222:             Fields::Named(fields) => fields.named,
225: 223:             Fields::Unnamed(_) | Fields::Unit => {
226: 224:                 return syn::Error::new_spanned(
227: 225:                     struct_name,
228: 226:                     "QueryParam can only be derived for structs with named fields",
229: 227:                 )
230: 228:                 .to_compile_error()
231: 229:                 .into();
232: 230:             }
233: 231:         }
234: 232:     } else {
235: 233:         return syn::Error::new_spanned(
236: 234:             struct_name,
237: 235:             "QueryParam can only be derived for structs",
238: 236:         )
239: 237:         .to_compile_error()
240: 238:         .into();
241: 239:     };
242: 240: 
243: 241:     let mut query_parts = Vec::new();
244: 242: 
245: 243:     for field in fields {
246: 244:         let field_name = field.ident.unwrap();
247: 245:         let field_str = field_name.to_string();
248: 246: 
249: 247:         // detect if field has #[query_param(skip_if_empty, iterable)]
250: 248:         let mut skip_if_empty = false;
251: 249:         let mut iter = false;
252: 250:         for attr in &field.attrs {
253: 251:             if attr.path().is_ident("query_param") {
254: 252:                 // Parse comma-separated arguments
255: 253:                 let args: syn::punctuated::Punctuated<syn::Ident, syn::Token![,]> =
256: 254:                     match attr
257: 255:                         .parse_args_with(syn::punctuated::Punctuated::parse_terminated)
258: 256:                     {
259: 257:                         Ok(v) => v,
260: 258:                         Err(_) => continue,
261: 259:                     };
262: 260: 
263: 261:                 for arg in args {
264: 262:                     match arg.to_string().as_str() {
265: 263:                         "skip_if_empty" => skip_if_empty = true,
266: 264:                         "iterable" => iter = true,
267: 265:                         _ => {}
268: 266:                     }
269: 267:                 }
270: 268:             }
271: 269:         }
272: 270: 
273: 271:         // check if the type is Option<_>
274: 272:         let is_option = matches!(&field.ty, Type::Path(type_path) if type_path.path.segments.first().is_some_and(|seg| seg.ident == "Option"));
275: 273: 
276: 274:         // Build the query generation logic dynamically
277: 275:         let query_generation = match (is_option, skip_if_empty, iter) {
278: 276:             // For Option types
279: 277:             (true, skip_empty, use_iter) => {
280: 278:                 let inner_logic = if use_iter {
281: 279:                     quote! {
282: 280:                         for item in value.iter() {
283: 281:                             query_params.push(format!("{}={}", #field_str, item));
284: 282:                         }
285: 283:                     }
286: 284:                 } else {
287: 285:                     quote! {
288: 286:                         query_params.push(format!("{}={}", #field_str, value));
289: 287:                     }
290: 288:                 };
291: 289: 
292: 290:                 if skip_empty {
293: 291:                     quote! {
294: 292:                         if let Some(value) = &self.#field_name {
295: 293:                             if !value.is_empty() {
296: 294:                                 #inner_logic
297: 295:                             }
298: 296:                         }
299: 297:                     }
300: 298:                 } else {
301: 299:                     quote! {
302: 300:                         if let Some(value) = &self.#field_name {
303: 301:                             #inner_logic
304: 302:                         }
305: 303:                     }
306: 304:                 }
307: 305:             }
308: 306:             // For non-Option types
309: 307:             (false, skip_empty, use_iter) => {
310: 308:                 let inner_logic = if use_iter {
311: 309:                     quote! {
312: 310:                         for item in self.#field_name.iter() {
313: 311:                             query_params.push(format!("{}={}", #field_str, item));
314: 312:                         }
315: 313:                     }
316: 314:                 } else {
317: 315:                     quote! {
318: 316:                         query_params.push(format!("{}={}", #field_str, self.#field_name));
319: 317:                     }
320: 318:                 };
321: 319:                 if skip_empty {
322: 320:                     quote! {
323: 321:                         if !self.#field_name.is_empty() {
324: 322:                             #inner_logic
325: 323:                         }
326: 324:                     }
327: 325:                 } else {
328: 326:                     inner_logic
329: 327:                 }
330: 328:             }
331: 329:         };
332: 330: 
333: 331:         query_parts.push(query_generation);
334: 332:     }
335: 333: 
336: 334:     let expanded = quote! {
337: 335:         impl QueryParam for #struct_name {
338: 336:             fn to_query_param(&self) -> String {
339: 337:                 let mut query_params = Vec::new();
340: 338:                 #(#query_parts)*
341: 339: 
342: 340:                 query_params.join("&")
343: 341:             }
344: 342:         }
345: 343:     };
346: 344: 
347: 345:     TokenStream::from(expanded)
348: 346: }
349: 347: 
350: 348: /// For an action `act` on a resource, on a function `act_handler`, this macro generates a struct
351: 349: /// `AuthZActionAct` that implements the `Action` trait from `lyx-core-lyx_core_lyx-core-lyx_core_service_utils::middlewares::auth_z`.
352: 350: /// It injects an additional parameter `_auth_z: AuthZ<AuthZActionAct>` into the function signature.
353: 351: /// `AuthZ` struct implements `FromRequest` trait to handle authorization checks.
354: 352: ///
355: 353: /// The struct is used to represent the action and is generated based on the action name and function name.
356: 354: /// The handler function name must end with `_handler` to derive the struct name correctly and should not have
357: 355: /// the resource part in its name, the name should represent the action only.
358: 356: #[proc_macro_attribute]
359: 357: pub fn authorized(attr: TokenStream, item: TokenStream) -> TokenStream {
360: 358:     // Parse the function
361: 359:     let mut input_fn = parse_macro_input!(item as ItemFn);
362: 360:     let fn_name = input_fn.sig.ident.to_string();
363: 361: 
364: 362:     // Use provided action name or derive from function name
365: 363:     let action_name = if attr.is_empty() {
366: 364:         // Ensure the function name ends with '_handler'
367: 365:         let Some(name) = fn_name.strip_suffix("_handler") else {
368: 366:             return syn::Error::new_spanned(
369: 367:                 input_fn.sig.ident,
370: 368:                 "Function name must end with '_handler' to derive action name automatically",
371: 369:             )
372: 370:             .to_compile_error()
373: 371:             .into();
374: 372:         };
375: 373:         name.to_string()
376: 374:     } else {
377: 375:         let lit = parse_macro_input!(attr as LitStr);
378: 376:         lit.value()
379: 377:     };
380: 378: 
381: 379:     // Generate mangled struct name: AuthZActionAct
382: 380:     let struct_name = format_ident!("AuthZAction{}", pascal_case(&action_name));
383: 381: 
384: 382:     // Inject parameter: _auth_z: AuthZ<AuthZActionAct>
385: 383:     input_fn.sig.inputs.insert(
386: 384:         0,
387: 385:         syn::parse_quote!(_auth_z: lyx-core-lyx_core_lyx-core-lyx_core_service_utils::middlewares::auth_z::AuthZ<#struct_name>),
388: 386:     );
389: 387: 
390: 388:     quote! {
391: 389:         struct #struct_name;
392: 390: 
393: 391:         impl lyx-core-lyx_core_lyx-core-lyx_core_service_utils::middlewares::auth_z::Action for #struct_name {
394: 392:             fn get() -> String {
395: 393:                 #action_name.to_string()
396: 394:             }
397: 395:         }
398: 396: 
399: 397:         #input_fn
400: 398:     }
401: 399:     .into()
402: 400: }
403: 401: 
404: 402: fn pascal_case(s: &str) -> String {
405: 403:     s.split(&['-', '_'])
406: 404:         .map(|word| {
407: 405:             let mut chars = word.chars();
408: 406:             match chars.next() {
409: 407:                 Some(first) => first.to_uppercase().collect::<String>() + chars.as_str(),
410: 408:                 None => String::new(),
411: 409:             }
412: 410:         })
413: 411:         .collect()
414: 412: }
415: 413: ```
416: 414: ```
417: 415: ```
418: 416: ```
419: ```
```
