### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_leptos_macro\src\view\utils.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_macro\src\view\utils.rs
2: ```rust
3: 1: use proc_macro2::Ident;
4: 2: use quote::format_ident;
5: 3: use rstml::node::{KeyedAttribute, NodeName};
6: 4: use syn::{spanned::Spanned, ExprPath};
7: 5: 
8: 6: pub fn filter_prefixed_attrs<'a, A>(attrs: A, prefix: &str) -> Vec<Ident>
9: 7: where
10: 8:     A: IntoIterator<Item = &'a KeyedAttribute> + Clone,
11: 9: {
12: 10:     attrs
13: 11:         .into_iter()
14: 12:         .filter_map(|attr| {
15: 13:             attr.key
16: 14:                 .to_string()
17: 15:                 .strip_prefix(prefix)
18: 16:                 .map(|ident| format_ident!("{ident}", span = attr.key.span()))
19: 17:         })
20: 18:         .collect()
21: 19: }
22: 20: 
23: 21: /// Handle nostrip: prefix:
24: 22: /// if there strip from the name, and return true to indicate that
25: 23: /// the prop should be an Option<T> and shouldn't be called on the builder if None,
26: 24: /// if Some(T) then T supplied to the builder.
27: 25: pub fn is_nostrip_optional_and_update_key(key: &mut NodeName) -> bool {
28: 26:     let maybe_cleaned_name_and_span = if let NodeName::Punctuated(punct) = &key
29: 27:     {
30: 28:         if punct.len() == 2 {
31: 29:             if let Some(cleaned_name) = key.to_string().strip_prefix("nostrip:")
32: 30:             {
33: 31:                 punct
34: 32:                     .get(1)
35: 33:                     .map(|segment| (cleaned_name.to_string(), segment.span()))
36: 34:             } else {
37: 35:                 None
38: 36:             }
39: 37:         } else {
40: 38:             None
41: 39:         }
42: 40:     } else {
43: 41:         None
44: 42:     };
45: 43:     if let Some((cleaned_name, span)) = maybe_cleaned_name_and_span {
46: 44:         *key = NodeName::Path(ExprPath {
47: 45:             attrs: vec![],
48: 46:             qself: None,
49: 47:             path: format_ident!("{}", cleaned_name, span = span).into(),
50: 48:         });
51: 49:         true
52: 50:     } else {
53: 51:         false
54: 52:     }
55: 53: }
56: ```
```
