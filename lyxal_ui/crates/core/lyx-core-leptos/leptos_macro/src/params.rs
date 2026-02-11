### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_leptos_macro\src\params.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_macro\src\params.rs
2: ```rust
3: 1: use quote::{quote, quote_spanned};
4: 2: use syn::spanned::Spanned;
5: 3: 
6: 4: pub fn params_impl(ast: &syn::DeriveInput) -> proc_macro::TokenStream {
7: 5:     let name = &ast.ident;
8: 6: 
9: 7:     let fields = if let syn::Data::Struct(syn::DataStruct {
10: 8:         fields: syn::Fields::Named(ref fields),
11: 9:         ..
12: 10:     }) = ast.data
13: 11:     {
14: 12:         fields
15: 13:             .named
16: 14:             .iter()
17: 15:             .map(|field| {
18: 16: 				let field_name_string = &field
19: 17:                     .ident
20: 18:                     .as_ref()
21: 19:                     .expect("expected named struct fields")
22: 20:                     .to_string()
23: 21:                     .trim_start_matches("r#")
24: 22:                     .to_owned();
25: 23: 				let ident = &field.ident;
26: 24: 				let ty = &field.ty;
27: 25: 				let span = field.span();
28: 26: 
29: 27: 				quote_spanned! {
30: 28: 					span=> #ident: ::lyx-core-lyx_core_lyx-core-router::params::macro_helpers::Wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper::<#ty>::__into_param(
31: 29:                         map.get_str(#field_name_string),
32: 30:                         #field_name_string
33: 31:                     )?
34: 32: 				}
35: 33: 			})
36: 34:             .collect()
37: 35:     } else {
38: 36:         vec![]
39: 37:     };
40: 38: 
41: 39:     let gen = quote! {
42: 40:         impl Params for #name {
43: 41:             fn from_map(map: &::lyx-core-lyx_core_lyx-core-router::params::ParamsMap) -> ::core::result::Result<Self, ::lyx-core-lyx_core_lyx-core-router::params::ParamsError> {
44: 42:                 use ::lyx-core-lyx_core_lyx-core-router::params::macro_helpers::Fallback as _;
45: 43: 
46: 44:                 Ok(Self {
47: 45:                     #(#fields,)*
48: 46:                 })
49: 47:             }
50: 48:         }
51: 49:     };
52: 50:     gen.into()
53: 51: }
54: ```
```
