### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_leptos_macro\src\slice.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_macro\src\slice.rs
2: ```rust
3: 1: extern crate proc_macro;
4: 2: 
5: 3: use proc_macro::TokenStream;
6: 4: use quote::{quote, ToTokens};
7: 5: use syn::{
8: 6:     parse::{Parse, ParseStream},
9: 7:     parse_macro_input,
10: 8:     punctuated::Punctuated,
11: 9:     Token,
12: 10: };
13: 11: 
14: 12: struct SliceMacroInput {
15: 13:     root: syn::Ident,
16: 14:     path: Punctuated<syn::Member, Token![.]>,
17: 15: }
18: 16: 
19: 17: impl Parse for SliceMacroInput {
20: 18:     fn parse(input: ParseStream) -> syn::Result<Self> {
21: 19:         let root: syn::Ident = input.parse()?;
22: 20:         input.parse::<Token![.]>()?;
23: 21:         // do not accept trailing punctuation
24: 22:         let path: Punctuated<syn::Member, Token![.]> =
25: 23:             Punctuated::parse_separated_nonempty(input)?;
26: 24: 
27: 25:         if path.is_empty() {
28: 26:             return Err(input.error("expected identifier"));
29: 27:         }
30: 28: 
31: 29:         if !input.is_empty() {
32: 30:             return Err(input.error("unexpected token"));
33: 31:         }
34: 32: 
35: 33:         Ok(Self { root, path })
36: 34:     }
37: 35: }
38: 36: 
39: 37: impl ToTokens for SliceMacroInput {
40: 38:     fn to_tokens(&self, tokens: &mut proc_macro2::TokenStream) {
41: 39:         let root = &self.root;
42: 40:         let path = &self.path;
43: 41: 
44: 42:         tokens.extend(quote! {
45: 43:             ::lyx-core-lyx_core_lyx-core-lyx_core_leptos::reactive::computed::create_slice(
46: 44:                 #root,
47: 45:                 |st: &_| st.#path.clone(),
48: 46:                 |st: &mut _, n| st.#path = n
49: 47:             )
50: 48:         })
51: 49:     }
52: 50: }
53: 51: 
54: 52: pub fn slice_impl(tokens: TokenStream) -> TokenStream {
55: 53:     let input = parse_macro_input!(tokens as SliceMacroInput);
56: 54:     input.into_token_stream().into()
57: 55: }
58: ```
```
