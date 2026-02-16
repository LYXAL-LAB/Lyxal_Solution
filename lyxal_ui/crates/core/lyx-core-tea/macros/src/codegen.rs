1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lib\macros\src\codegen.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lib\macros\src\codegen.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lib\macros\src\codegen.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lib\macros\src\codegen.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lib\macros\src\codegen.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lib\macros\src\codegen.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lib\macros\src\codegen.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lib\macros\src\codegen.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lib\macros\src\codegen.rs
18: 16: ```rust
19: 17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lib\macros\src\codegen.rs
20: 18: ```rust
21: 19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lib\macros\src\codegen.rs
22: 20: ```rust
23: 21: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lib\macros\src\codegen.rs
24: 22: ```rust
25: 23: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lib\macros\src\codegen.rs
26: 24: ```rust
27: 25: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lib\macros\src\codegen.rs
28: 26: ```rust
29: 27: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lib\macros\src\codegen.rs
30: 28: ```rust
31: 29: use crate::model::{Field, Model};
32: 30: use core::fmt;
33: 31: use proc_macro2::TokenStream;
34: 32: use quote::{format_ident, quote};
35: 33: use syn::parse_quote;
36: 34: 
37: 35: trait FieldSliceExt: AsRef<[Field]> {
38: 36:   fn to_update_model_fields(&self, is_named: bool) -> TokenStream {
39: 37:     let this = self.as_ref();
40: 38: 
41: 39:     let fields = this.iter().map(
42: 40:       |Field {
43: 41:          vis,
44: 42:          name,
45: 43:          ty,
46: 44:          is_nested_model,
47: 45:        }| {
48: 46:         let ty = if *is_nested_model {
49: 47:           format_ty("Update", ty)
50: 48:         } else {
51: 49:           syn::parse_quote! { ::lyx_core_lib::lyx-core-lyx_core_lyx-core-lyx_core_leptos_reactive::RwSignal<#ty> }
52: 50:         };
53: 51: 
54: 52:         if is_named {
55: 53:           quote! { #vis #name: #ty }
56: 54:         } else {
57: 55:           quote! { #vis #ty }
58: 56:         }
59: 57:       },
60: 58:     );
61: 59: 
62: 60:     if is_named {
63: 61:       quote! { { #( #fields ),* } }
64: 62:     } else {
65: 63:       quote! { ( #( #fields ),* ); }
66: 64:     }
67: 65:   }
68: 66: 
69: 67:   fn to_view_model_fields(&self, is_named: bool) -> TokenStream {
70: 68:     let this = self.as_ref();
71: 69: 
72: 70:     let fields = this.iter().map(
73: 71:       |Field {
74: 72:          vis,
75: 73:          name,
76: 74:          ty,
77: 75:          is_nested_model,
78: 76:        }| {
79: 77:         let ty = if *is_nested_model {
80: 78:           format_ty("View", ty)
81: 79:         } else {
82: 80:           syn::parse_quote! { ::lyx_core_lib::lyx-core-lyx_core_lyx-core-lyx_core_leptos_reactive::ReadSignal<#ty> }
83: 81:         };
84: 82: 
85: 83:         if is_named {
86: 84:           quote! { #vis #name: #ty }
87: 85:         } else {
88: 86:           quote! { #vis #ty }
89: 87:         }
90: 88:       },
91: 89:     );
92: 90: 
93: 91:     if is_named {
94: 92:       quote! { { #( #fields ),* } }
95: 93:     } else {
96: 94:       quote! { ( #( #fields ),* ); }
97: 95:     }
98: 96:   }
99: 97: }
100: 98: 
101: 99: impl<T> FieldSliceExt for T where T: AsRef<[Field]> {}
102: 100: 
103: 101: pub fn codegen(
104: 102:   Model {
105: 103:     vis,
106: 104:     name,
107: 105:     generics,
108: 106:     is_named,
109: 107:     fields,
110: 108:   }: Model,
111: 109: ) -> TokenStream {
112: 110:   codegen_struct(vis, name, generics, is_named, fields)
113: 111: }
114: 112: 
115: 113: fn codegen_struct(
116: 114:   vis: syn::Visibility,
117: 115:   name: syn::Ident,
118: 116:   generics: syn::Generics,
119: 117:   is_named: bool,
120: 118:   fields: Vec<Field>,
121: 119: ) -> TokenStream {
122: 120:   let update_struct = generate_model_struct(
123: 121:     ModelStructKind::Update,
124: 122:     &vis,
125: 123:     &name,
126: 124:     &generics,
127: 125:     is_named,
128: 126:     &fields,
129: 127:   );
130: 128: 
131: 129:   let view_struct = generate_model_struct(
132: 130:     ModelStructKind::View,
133: 131:     &vis,
134: 132:     &name,
135: 133:     &generics,
136: 134:     is_named,
137: 135:     &fields,
138: 136:   );
139: 137: 
140: 138:   let model_impl =
141: 139:     generate_model_impl(&vis, &name, &generics, is_named, &fields);
142: 140: 
143: 141:   quote! {
144: 142:     #update_struct
145: 143: 
146: 144:     #view_struct
147: 145: 
148: 146:     #model_impl
149: 147:   }
150: 148: }
151: 149: 
152: 150: fn format_ty(name: &str, ty: &syn::Type) -> syn::Type {
153: 151:   let mut ty = ty.clone();
154: 152: 
155: 153:   if let syn::Type::Path(syn::TypePath { path, .. }) = &mut ty {
156: 154:     let last_segment = path.segments.iter_mut().last().unwrap();
157: 155: 
158: 156:     last_segment.ident = format_ident!("{name}{}", last_segment.ident);
159: 157:   } else {
160: 158:     abort!(ty, "only path types are allowed")
161: 159:   }
162: 160: 
163: 161:   ty
164: 162: }
165: 163: 
166: 164: enum ModelStructKind {
167: 165:   Update,
168: 166:   View,
169: 167: }
170: 168: 
171: 169: impl fmt::Display for ModelStructKind {
172: 170:   fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
173: 171:     match self {
174: 172:       Self::Update => f.write_str("Update"),
175: 173:       Self::View => f.write_str("View"),
176: 174:     }
177: 175:   }
178: 176: }
179: 177: 
180: 178: fn generate_model_struct(
181: 179:   kind: ModelStructKind,
182: 180:   vis: &syn::Visibility,
183: 181:   name: &syn::Ident,
184: 182:   generics: &syn::Generics,
185: 183:   is_named: bool,
186: 184:   fields: &[Field],
187: 185: ) -> TokenStream {
188: 186:   let model_name = format_ident!("{kind}{name}");
189: 187: 
190: 188:   let model_fields = fields.iter().map(
191: 189:     |Field {
192: 190:        vis,
193: 191:        name,
194: 192:        ty,
195: 193:        is_nested_model,
196: 194:      }| {
197: 195:       let ty = match kind {
198: 196:         ModelStructKind::Update => {
199: 197:           if *is_nested_model {
200: 198:             format_ty(&kind.to_string(), ty)
201: 199:           } else {
202: 200:             parse_quote! { ::lyx_core_lib::lyx-core-lyx_core_lyx-core-lyx_core_leptos_reactive::RwSignal<#ty> }
203: 201:           }
204: 202:         }
205: 203:         ModelStructKind::View => {
206: 204:           if *is_nested_model {
207: 205:             format_ty(&kind.to_string(), ty)
208: 206:           } else {
209: 207:             parse_quote! { ::lyx_core_lib::lyx-core-lyx_core_lyx-core-lyx_core_leptos_reactive::ReadSignal<#ty> }
210: 208:           }
211: 209:         }
212: 210:       };
213: 211: 
214: 212:       if is_named {
215: 213:         quote! { #vis #name: #ty }
216: 214:       } else {
217: 215:         quote! { #vis #ty }
218: 216:       }
219: 217:     },
220: 218:   );
221: 219: 
222: 220:   let (_, type_generics, where_clause) = generics.split_for_impl();
223: 221: 
224: 222:   let model_fields = if is_named {
225: 223:     quote! { #where_clause { #( #model_fields ),* } }
226: 224:   } else {
227: 225:     quote! { ( #( #model_fields ),* ) #where_clause ; }
228: 226:   };
229: 227: 
230: 228:   quote! {
231: 229:     #[derive(Clone, Copy)]
232: 230:     #vis struct #model_name #type_generics #model_fields
233: 231:   }
234: 232: }
235: 233: 
236: 234: fn generate_model_impl(
237: 235:   vis: &syn::Visibility,
238: 236:   name: &syn::Ident,
239: 237:   generics: &syn::Generics,
240: 238:   is_named: bool,
241: 239:   fields: &[Field],
242: 240: ) -> TokenStream {
243: 241:   let (impl_generics, type_generics, where_clause) = generics.split_for_impl();
244: 242: 
245: 243:   let split_fn_impl =
246: 244:     generate_split_fn_impl(vis, name, generics, is_named, fields);
247: 245:   let init_fn_impl = generate_init_fn_impl(vis, name, generics);
248: 246: 
249: 247:   quote! {
250: 248:     impl #impl_generics #name #type_generics #where_clause {
251: 249:       #split_fn_impl
252: 250: 
253: 251:       #init_fn_impl
254: 252:     }
255: 253:   }
256: 254: }
257: 255: 
258: 256: fn generate_split_fn_impl(
259: 257:   vis: &syn::Visibility,
260: 258:   name: &syn::Ident,
261: 259:   generics: &syn::Generics,
262: 260:   is_named: bool,
263: 261:   fields: &[Field],
264: 262: ) -> TokenStream {
265: 263:   let update_model_name = format_ident!("Update{name}");
266: 264:   let view_model_name = format_ident!("View{name}");
267: 265: 
268: 266:   let field_names = fields
269: 267:     .iter()
270: 268:     .enumerate()
271: 269:     .map(|(i, field)| {
272: 270:       if let Some(name) = &field.name {
273: 271:         name.clone()
274: 272:       } else {
275: 273:         format_ident!("field_{i}")
276: 274:       }
277: 275:     })
278: 276:     .collect::<Vec<_>>();
279: 277: 
280: 278:   let get_fields = if is_named {
281: 279:     quote! { { #( #field_names ),* } }
282: 280:   } else {
283: 281:     quote! { ( #( #field_names ),* ) }
284: 282:   };
285: 283: 
286: 284:   let split_model_fields = fields
287: 285:     .iter()
288: 286:     .zip(field_names.iter())
289: 287:     .map(
290: 288:       |(
291: 289:         Field {
292: 290:           is_nested_model, ..
293: 291:         },
294: 292:         field_name,
295: 293:       )| {
296: 294:         let read_name = format_ident!("__read_{field_name}");
297: 295:         let write_name = format_ident!("__write_{field_name}");
298: 296: 
299: 297:         let split = if *is_nested_model {
300: 298:           quote! { let (#read_name, #write_name) = #field_name.split(); }
301: 299:         } else {
302: 300:           quote! {
303: 301:             let #write_name = ::lyx_core_lib::lyx-core-lyx_core_lyx-core-lyx_core_leptos_reactive::create_rw_signal(#field_name);
304: 302:             let #read_name = #write_name.read_only();
305: 303:           }
306: 304:         };
307: 305: 
308: 306:         (split, read_name, write_name)
309: 307:       },
310: 308:     )
311: 309:     .collect::<Vec<_>>();
312: 310: 
313: 311:   let split_model_fields_exprs =
314: 312:     split_model_fields.iter().map(|(split, _, _)| split);
315: 313: 
316: 314:   let init_update_model_fields =
317: 315:     split_model_fields.iter().map(|(_, _, write)| write);
318: 316: 
319: 317:   let init_view_model_fields =
320: 318:     split_model_fields.iter().map(|(_, read, _)| read);
321: 319: 
322: 320:   let init_update_model_fields = if is_named {
323: 321:     quote! { { #( #field_names: #init_update_model_fields ),* } }
324: 322:   } else {
325: 323:     quote! { ( #( #init_update_model_fields ),* ) }
326: 324:   };
327: 325: 
328: 326:   let init_view_model_fields = if is_named {
329: 327:     quote! { { #( #field_names: #init_view_model_fields ),* } }
330: 328:   } else {
331: 329:     quote! { ( #( #init_view_model_fields ),* ) }
332: 330:   };
333: 331: 
334: 332:   let (_, type_generics, _) = generics.split_for_impl();
335: 333: 
336: 334:   quote! {
337: 335:     #vis fn split(
338: 336:       self,
339: 337:     ) -> (#view_model_name #type_generics, #update_model_name #type_generics) {
340: 338:       let Self #get_fields = self;
341: 339: 
342: 340:       #( #split_model_fields_exprs )*
343: 341: 
344: 342:       let __view_model = #view_model_name #init_view_model_fields;
345: 343:       let __update_model = #update_model_name #init_update_model_fields;
346: 344: 
347: 345:       (__view_model, __update_model)
348: 346:     }
349: 347:   }
350: 348: }
351: 349: 
352: 350: fn generate_init_fn_impl(
353: 351:   vis: &syn::Visibility,
354: 352:   name: &syn::Ident,
355: 353:   generics: &syn::Generics,
356: 354: ) -> TokenStream {
357: 355:   let update_model_name = format_ident!("Update{name}");
358: 356:   let view_model_name = format_ident!("View{name}");
359: 357: 
360: 358:   let (_, type_generics, _) = generics.split_for_impl();
361: 359: 
362: 360:   quote! {
363: 361:     #[track_caller]
364: 362:     #vis fn init<Msg: ::core::default::Default + 'static>(
365: 363:       self,
366: 364:       update_fn: impl ::core::ops::Fn(
367: 365:         #update_model_name #type_generics,
368: 366:         Msg,
369: 367:         ::lyx_core_lib::Cmd<Msg>,
370: 368:       ) + 'static
371: 369:     ) -> (#view_model_name #type_generics, ::lyx_core_lib::MsgDispatcher<Msg>) {
372: 370:       let __update_fn = update_fn;
373: 371: 
374: 372:       let (__tx, mut __rx)
375: 373:         = ::lyx_core_lib::futures::channel::mpsc::unbounded();
376: 374: 
377: 375:       __tx.unbounded_send(Msg::default()).unwrap();
378: 376: 
379: 377:       let __tx_store = ::lyx_core_lib::lyx-core-lyx_core_lyx-core-lyx_core_leptos_reactive::store_value(__tx);
380: 378: 
381: 379:       let (__view_model, __update_model) = self.split();
382: 380: 
383: 381:       ::lyx_core_lib::lyx-core-lyx_core_lyx-core-lyx_core_leptos_reactive::try_spawn_local_with_current_owner(
384: 382:         async move {
385: 383:           while let Some(msg)
386: 384:             = ::lyx_core_lib::futures::StreamExt::next(&mut __rx).await
387: 385:           {
388: 386:             let __cmd_dispatcher = ::lyx_core_lib::Cmd::new(
389: 387:               ::lyx_core_lib::lyx-core-lyx_core_lyx-core-lyx_core_leptos_reactive::Owner::current()
390: 388:                 .expect(
391: 389:                   "`Model::init()` must be called  within \
392: 390:                   the context of an `Owner`\n\
393: 391:                   \n\
394: 392:                   try calling `Model::init()` at the top level of \
395: 393:                   the component definition"
396: 394:                 ),
397: 395:               __tx_store,
398: 396:             );
399: 397: 
400: 398:             __update_fn(__update_model, msg, __cmd_dispatcher);
401: 399:           }
402: 400:         },
403: 401:         || {},
404: 402:       );
405: 403: 
406: 404:       (__view_model, ::lyx_core_lib::MsgDispatcher::new(__tx_store))
407: 405:     }
408: 406:   }
409: 407: }
410: 408: ```
411: 409: ```
412: 410: ```
413: 411: ```
414: 412: ```
415: 413: ```
416: 414: ```
417: 415: ```
418: 416: ```
419: 417: ```
420: 418: ```
421: 419: ```
422: 420: ```
423: 421: ```
424: ```
```

