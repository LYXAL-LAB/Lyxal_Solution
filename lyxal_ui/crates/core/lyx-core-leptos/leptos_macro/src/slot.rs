### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_leptos_macro\src\slot.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_macro\src\slot.rs
2: ```rust
3: 1: use crate::component::{
4: 2:     convert_from_snake_case, drain_filter, is_option, unwrap_option, Docs,
5: 3: };
6: 4: use attribute_derive::FromAttr;
7: 5: use proc_macro2::{Ident, TokenStream};
8: 6: use quote::{quote, ToTokens, TokenStreamExt};
9: 7: use syn::{
10: 8:     parse::Parse, parse_quote, Field, ItemStruct, LitStr, Meta, Type,
11: 9:     Visibility,
12: 10: };
13: 11: 
14: 12: pub struct Model {
15: 13:     docs: Docs,
16: 14:     vis: Visibility,
17: 15:     name: Ident,
18: 16:     props: Vec<Prop>,
19: 17:     body: ItemStruct,
20: 18: }
21: 19: 
22: 20: impl Parse for Model {
23: 21:     fn parse(input: syn::parse::ParseStream) -> syn::Result<Self> {
24: 22:         let mut item = ItemStruct::parse(input)?;
25: 23: 
26: 24:         let docs = Docs::new(&item.attrs);
27: 25: 
28: 26:         let props = item
29: 27:             .fields
30: 28:             .clone()
31: 29:             .into_iter()
32: 30:             .map(Prop::new)
33: 31:             .collect::<Vec<_>>();
34: 32: 
35: 33:         // We need to remove the `#[doc = ""]` and `#[builder(_)]`
36: 34:         // attrs from the function signature
37: 35:         drain_filter(&mut item.attrs, |attr| match &attr.meta {
38: 36:             Meta::NameValue(attr) => attr.path == parse_quote!(doc),
39: 37:             Meta::List(attr) => attr.path == parse_quote!(prop),
40: 38:             _ => false,
41: 39:         });
42: 40:         item.fields.iter_mut().for_each(|arg| {
43: 41:             drain_filter(&mut arg.attrs, |attr| match &attr.meta {
44: 42:                 Meta::NameValue(attr) => attr.path == parse_quote!(doc),
45: 43:                 Meta::List(attr) => attr.path == parse_quote!(prop),
46: 44:                 _ => false,
47: 45:             });
48: 46:         });
49: 47: 
50: 48:         Ok(Self {
51: 49:             docs,
52: 50:             vis: item.vis.clone(),
53: 51:             name: convert_from_snake_case(&item.ident),
54: 52:             props,
55: 53:             body: item,
56: 54:         })
57: 55:     }
58: 56: }
59: 57: 
60: 58: impl ToTokens for Model {
61: 59:     fn to_tokens(&self, tokens: &mut TokenStream) {
62: 60:         let Self {
63: 61:             docs,
64: 62:             vis,
65: 63:             name,
66: 64:             props,
67: 65:             body,
68: 66:         } = self;
69: 67: 
70: 68:         let (_, generics, where_clause) = body.generics.split_for_impl();
71: 69: 
72: 70:         let prop_builder_fields = prop_builder_fields(vis, props);
73: 71:         let prop_docs = generate_prop_docs(props);
74: 72:         let builder_name_doc = LitStr::new(
75: 73:             &format!("Props for the [`{name}`] slot."),
76: 74:             name.span(),
77: 75:         );
78: 76: 
79: 77:         let output = quote! {
80: 78:             #[doc = #builder_name_doc]
81: 79:             #[doc = ""]
82: 80:             #docs
83: 81:             #prop_docs
84: 82:             #[derive(::lyx-core-lyx_core_lyx-core-lyx_core_leptos::typed_builder_macro::TypedBuilder)]
85: 83:             #[builder(doc, crate_module_path=::lyx-core-lyx_core_lyx-core-lyx_core_leptos::typed_builder)]
86: 84:             #vis struct #name #generics #where_clause {
87: 85:                 #prop_builder_fields
88: 86:             }
89: 87: 
90: 88:             impl #generics From<#name #generics> for Vec<#name #generics> #where_clause {
91: 89:                 fn from(value: #name #generics) -> Self {
92: 90:                     vec![value]
93: 91:                 }
94: 92:             }
95: 93: 
96: 94:             /*impl #impl_generics ::lyx-core-lyx_core_lyx-core-lyx_core_leptos::Props for #name #generics #where_clause {
97: 95:                 type Builder = #builder_name #generics;
98: 96:                 fn builder() -> Self::Builder {
99: 97:                     #name::builder()
100: 98:                 }
101: 99:             }
102: 100: 
103: 101:             impl #impl_generics ::lyx-core-lyx_core_lyx-core-lyx_core_leptos::DynAttrs for #name #generics #where_clause {
104: 102:                 fn dyn_attrs(mut self, v: Vec<(&'static str, ::lyx-core-lyx_core_lyx-core-lyx_core_leptos::Attribute)>) -> Self {
105: 103:                     #dyn_attrs_props
106: 104:                     self
107: 105:                 }
108: 106:             }*/
109: 107:         };
110: 108: 
111: 109:         tokens.lyx-platform-lyx_platform_lyx-platform-lyx_platform_append_all(output)
112: 110:     }
113: 111: }
114: 112: 
115: 113: struct Prop {
116: 114:     docs: Docs,
117: 115:     prop_opts: PropOpt,
118: 116:     name: Ident,
119: 117:     ty: Type,
120: 118: }
121: 119: 
122: 120: impl Prop {
123: 121:     fn new(arg: Field) -> Self {
124: 122:         let prop_opts =
125: 123:             PropOpt::from_attributes(&arg.attrs).unwrap_or_else(|e| {
126: 124:                 // TODO: replace with `.unwrap_or_abort()` once https://gitlab.com/CreepySkeleton/proc-macro-error/-/issues/17 is fixed
127: 125:                 abort!(e.span(), e.to_string());
128: 126:             });
129: 127: 
130: 128:         let name = if let Some(i) = arg.ident {
131: 129:             i
132: 130:         } else {
133: 131:             abort!(
134: 132:                 arg.ident,
135: 133:                 "only `prop: bool` style types are allowed within the \
136: 134:                  `#[slot]` macro"
137: 135:             );
138: 136:         };
139: 137: 
140: 138:         Self {
141: 139:             docs: Docs::new(&arg.attrs),
142: 140:             prop_opts,
143: 141:             name,
144: 142:             ty: arg.ty,
145: 143:         }
146: 144:     }
147: 145: }
148: 146: 
149: 147: #[derive(Clone, Debug, FromAttr)]
150: 148: #[attribute(ident = prop)]
151: 149: struct PropOpt {
152: 150:     #[attribute(conflicts = [optional_no_strip, strip_option])]
153: 151:     pub optional: bool,
154: 152:     #[attribute(conflicts = [optional, strip_option])]
155: 153:     pub optional_no_strip: bool,
156: 154:     #[attribute(conflicts = [optional, optional_no_strip])]
157: 155:     pub strip_option: bool,
158: 156:     #[attribute(lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_example = "5 * 10")]
159: 157:     pub default: Option<syn::Expr>,
160: 158:     pub into: bool,
161: 159:     pub attrs: bool,
162: 160: }
163: 161: 
164: 162: struct TypedBuilderOpts<'a> {
165: 163:     default: bool,
166: 164:     default_with_value: Option<syn::Expr>,
167: 165:     strip_option: bool,
168: 166:     into: bool,
169: 167:     ty: &'a Type,
170: 168: }
171: 169: 
172: 170: impl<'a> TypedBuilderOpts<'a> {
173: 171:     pub fn from_opts(opts: &PropOpt, ty: &'a Type) -> Self {
174: 172:         Self {
175: 173:             default: opts.optional || opts.optional_no_strip || opts.attrs,
176: 174:             default_with_value: opts.default.clone(),
177: 175:             strip_option: opts.strip_option || opts.optional && is_option(ty),
178: 176:             into: opts.into,
179: 177:             ty,
180: 178:         }
181: 179:     }
182: 180: }
183: 181: 
184: 182: impl ToTokens for TypedBuilderOpts<'_> {
185: 183:     fn to_tokens(&self, tokens: &mut TokenStream) {
186: 184:         let default = if let Some(v) = &self.default_with_value {
187: 185:             let v = v.to_token_stream().to_string();
188: 186:             quote! { default_code=#v, }
189: 187:         } else if self.default {
190: 188:             quote! { default, }
191: 189:         } else {
192: 190:             quote! {}
193: 191:         };
194: 192: 
195: 193:         // If self.strip_option && self.into, then the strip_option will be represented as part of the transform closure.
196: 194:         let strip_option = if self.strip_option && !self.into {
197: 195:             quote! { strip_option, }
198: 196:         } else {
199: 197:             quote! {}
200: 198:         };
201: 199: 
202: 200:         let into = if self.into {
203: 201:             if !self.strip_option {
204: 202:                 let ty = &self.ty;
205: 203:                 quote! {
206: 204:                     fn transform<__IntoReactiveValueMarker>(value: impl ::lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::IntoReactiveValue<#ty, __IntoReactiveValueMarker>) -> #ty {
207: 205:                         value.into_reactive_value()
208: 206:                     },
209: 207:                 }
210: 208:             } else {
211: 209:                 let ty = unwrap_option(self.ty);
212: 210:                 quote! {
213: 211:                     fn transform<__IntoReactiveValueMarker>(value: impl ::lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::IntoReactiveValue<#ty, __IntoReactiveValueMarker>) -> Option<#ty> {
214: 212:                         Some(value.into_reactive_value())
215: 213:                     },
216: 214:                 }
217: 215:             }
218: 216:         } else {
219: 217:             quote! {}
220: 218:         };
221: 219: 
222: 220:         let setter = if !strip_option.is_empty() || !into.is_empty() {
223: 221:             quote! { setter(#strip_option #into) }
224: 222:         } else {
225: 223:             quote! {}
226: 224:         };
227: 225: 
228: 226:         let output = if !default.is_empty() || !setter.is_empty() {
229: 227:             quote! { #[builder(#default #setter)] }
230: 228:         } else {
231: 229:             quote! {}
232: 230:         };
233: 231: 
234: 232:         tokens.lyx-platform-lyx_platform_lyx-platform-lyx_platform_append_all(output);
235: 233:     }
236: 234: }
237: 235: 
238: 236: fn prop_builder_fields(vis: &Visibility, props: &[Prop]) -> TokenStream {
239: 237:     props
240: 238:         .iter()
241: 239:         .map(|prop| {
242: 240:             let Prop {
243: 241:                 docs,
244: 242:                 name,
245: 243:                 prop_opts,
246: 244:                 ty,
247: 245:             } = prop;
248: 246: 
249: 247:             let builder_attrs = TypedBuilderOpts::from_opts(prop_opts, ty);
250: 248: 
251: 249:             let builder_docs = prop_to_doc(prop, PropDocStyle::Inline);
252: 250: 
253: 251:             quote! {
254: 252:                 #docs
255: 253:                 #builder_docs
256: 254:                 #builder_attrs
257: 255:                 #vis #name: #ty,
258: 256:             }
259: 257:         })
260: 258:         .collect()
261: 259: }
262: 260: 
263: 261: fn generate_prop_docs(props: &[Prop]) -> TokenStream {
264: 262:     let required_prop_docs = props
265: 263:         .iter()
266: 264:         .filter(|Prop { prop_opts, .. }| {
267: 265:             !(prop_opts.optional || prop_opts.optional_no_strip)
268: 266:         })
269: 267:         .map(|p| prop_to_doc(p, PropDocStyle::List))
270: 268:         .collect::<TokenStream>();
271: 269: 
272: 270:     let optional_prop_docs = props
273: 271:         .iter()
274: 272:         .filter(|Prop { prop_opts, .. }| {
275: 273:             prop_opts.optional || prop_opts.optional_no_strip
276: 274:         })
277: 275:         .map(|p| prop_to_doc(p, PropDocStyle::List))
278: 276:         .collect::<TokenStream>();
279: 277: 
280: 278:     let required_prop_docs = if !required_prop_docs.is_empty() {
281: 279:         quote! {
282: 280:             #[doc = "# Required Props"]
283: 281:             #required_prop_docs
284: 282:         }
285: 283:     } else {
286: 284:         quote! {}
287: 285:     };
288: 286: 
289: 287:     let optional_prop_docs = if !optional_prop_docs.is_empty() {
290: 288:         quote! {
291: 289:             #[doc = "# Optional Props"]
292: 290:             #optional_prop_docs
293: 291:         }
294: 292:     } else {
295: 293:         quote! {}
296: 294:     };
297: 295: 
298: 296:     quote! {
299: 297:         #required_prop_docs
300: 298:         #optional_prop_docs
301: 299:     }
302: 300: }
303: 301: 
304: 302: #[derive(Clone, Copy)]
305: 303: enum PropDocStyle {
306: 304:     List,
307: 305:     Inline,
308: 306: }
309: 307: 
310: 308: fn prop_to_doc(
311: 309:     Prop {
312: 310:         docs,
313: 311:         name,
314: 312:         ty,
315: 313:         prop_opts,
316: 314:     }: &Prop,
317: 315:     style: PropDocStyle,
318: 316: ) -> TokenStream {
319: 317:     let ty = if (prop_opts.optional || prop_opts.strip_option) && is_option(ty)
320: 318:     {
321: 319:         unwrap_option(ty)
322: 320:     } else {
323: 321:         ty.to_owned()
324: 322:     };
325: 323: 
326: 324:     let type_item: syn::Item = parse_quote! {
327: 325:         type SomeType = #ty;
328: 326:     };
329: 327: 
330: 328:     let file = syn::File {
331: 329:         shebang: None,
332: 330:         attrs: vec![],
333: 331:         items: vec![type_item],
334: 332:     };
335: 333: 
336: 334:     let pretty_ty = prettyplease::unparse(&file);
337: 335: 
338: 336:     let pretty_ty = &pretty_ty[16..&pretty_ty.len() - 2];
339: 337: 
340: 338:     match style {
341: 339:         PropDocStyle::List => {
342: 340:             let arg_ty_doc = LitStr::new(
343: 341:                 &if !prop_opts.into {
344: 342:                     format!("- **{}**: [`{}`]", quote!(#name), pretty_ty)
345: 343:                 } else {
346: 344:                     format!(
347: 345:                         "- **{}**: `impl`[`Into<{}>`]",
348: 346:                         quote!(#name),
349: 347:                         pretty_ty
350: 348:                     )
351: 349:                 },
352: 350:                 name.span(),
353: 351:             );
354: 352: 
355: 353:             let arg_user_docs = docs.padded();
356: 354: 
357: 355:             quote! {
358: 356:                 #[doc = #arg_ty_doc]
359: 357:                 #arg_user_docs
360: 358:             }
361: 359:         }
362: 360:         PropDocStyle::Inline => {
363: 361:             let arg_ty_doc = LitStr::new(
364: 362:                 &if !prop_opts.into {
365: 363:                     format!(
366: 364:                         "**{}**: [`{}`]{}",
367: 365:                         quote!(#name),
368: 366:                         pretty_ty,
369: 367:                         docs.typed_builder()
370: 368:                     )
371: 369:                 } else {
372: 370:                     format!(
373: 371:                         "**{}**: `impl`[`Into<{}>`]{}",
374: 372:                         quote!(#name),
375: 373:                         pretty_ty,
376: 374:                         docs.typed_builder()
377: 375:                     )
378: 376:                 },
379: 377:                 name.span(),
380: 378:             );
381: 379: 
382: 380:             quote! {
383: 381:                 #[builder(setter(doc = #arg_ty_doc))]
384: 382:             }
385: 383:         }
386: 384:     }
387: 385: }
388: ```
```
