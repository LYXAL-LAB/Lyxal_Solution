### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_leptos_macro\src\view\slot_helper.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_macro\src\view\slot_helper.rs
2: ```rust
3: 1: use super::{
4: 2:     component_builder::maybe_optimised_component_children,
5: 3:     convert_to_snake_case, full_path_from_tag_name,
6: 4: };
7: 5: use crate::view::{fragment_to_tokens, utils::filter_prefixed_attrs, TagType};
8: 6: use proc_macro2::{Ident, TokenStream, TokenTree};
9: 7: use quote::{quote, quote_spanned};
10: 8: use rstml::node::{CustomNode, KeyedAttribute, NodeAttribute, NodeElement};
11: 9: use std::collections::HashMap;
12: 10: use syn::spanned::Spanned;
13: 11: 
14: 12: pub(crate) fn slot_to_tokens(
15: 13:     node: &mut NodeElement<impl CustomNode>,
16: 14:     slot: &KeyedAttribute,
17: 15:     parent_slots: Option<&mut HashMap<String, Vec<TokenStream>>>,
18: 16:     global_class: Option<&TokenTree>,
19: 17:     disable_inert_html: bool,
20: 18: ) {
21: 19:     let name = slot.key.to_string();
22: 20:     let name = name.trim();
23: 21:     let name = convert_to_snake_case(if name.starts_with("slot:") {
24: 22:         name.replacen("slot:", "", 1)
25: 23:     } else {
26: 24:         node.name().to_string()
27: 25:     });
28: 26: 
29: 27:     let component_path = full_path_from_tag_name(node.name());
30: 28: 
31: 29:     let Some(parent_slots) = parent_slots else {
32: 30:         proc_macro_error2::emit_error!(
33: 31:             node.name().span(),
34: 32:             "slots cannot be used inside HTML elements"
35: 33:         );
36: 34:         return;
37: 35:     };
38: 36: 
39: 37:     let attrs = node
40: 38:         .attributes()
41: 39:         .iter()
42: 40:         .filter_map(|node| {
43: 41:             if let NodeAttribute::Attribute(node) = node {
44: 42:                 if is_slot(node) {
45: 43:                     None
46: 44:                 } else {
47: 45:                     Some(node)
48: 46:                 }
49: 47:             } else {
50: 48:                 None
51: 49:             }
52: 50:         })
53: 51:         .cloned()
54: 52:         .collect::<Vec<_>>();
55: 53: 
56: 54:     let props = attrs
57: 55:         .iter()
58: 56:         .filter(|attr| {
59: 57:             !attr.key.to_string().starts_with("let:")
60: 58:                 && !attr.key.to_string().starts_with("clone:")
61: 59:                 && !attr.key.to_string().starts_with("attr:")
62: 60:         })
63: 61:         .map(|attr| {
64: 62:             let name = &attr.key;
65: 63: 
66: 64:             let value = attr
67: 65:                 .value()
68: 66:                 .map(|v| {
69: 67:                     quote! { #v }
70: 68:                 })
71: 69:                 .unwrap_or_else(|| quote! { #name });
72: 70: 
73: 71:             quote! {
74: 72:                 .#name(#[allow(unused_braces)] { #value })
75: 73:             }
76: 74:         });
77: 75: 
78: 76:     let items_to_bind = filter_prefixed_attrs(attrs.iter(), "let:")
79: 77:         .into_iter()
80: 78:         .map(|ident| quote! { #ident })
81: 79:         .collect::<Vec<_>>();
82: 80: 
83: 81:     let items_to_clone = filter_prefixed_attrs(attrs.iter(), "clone:");
84: 82: 
85: 83:     let dyn_attrs = attrs
86: 84:         .iter()
87: 85:         .filter(|attr| attr.key.to_string().starts_with("attr:"))
88: 86:         .filter_map(|attr| {
89: 87:             let name = &attr.key.to_string();
90: 88:             let name = name.strip_prefix("attr:");
91: 89:             let value = attr.value().map(|v| {
92: 90:                 quote! { #v }
93: 91:             })?;
94: 92:             Some(quote! { (#name, #value) })
95: 93:         })
96: 94:         .collect::<Vec<_>>();
97: 95: 
98: 96:     let dyn_attrs = if dyn_attrs.is_empty() {
99: 97:         quote! {}
100: 98:     } else {
101: 99:         quote! { .dyn_attrs(vec![#(#dyn_attrs),*]) }
102: 100:     };
103: 101: 
104: 102:     let mut slots = HashMap::new();
105: 103:     let children = if node.children.is_empty() {
106: 104:         quote! {}
107: 105:     } else if let Some(children) = maybe_optimised_component_children(
108: 106:         &node.children,
109: 107:         &items_to_bind,
110: 108:         &items_to_clone,
111: 109:     ) {
112: 110:         children
113: 111:     } else {
114: 112:         let children = fragment_to_tokens(
115: 113:             &mut node.children,
116: 114:             TagType::Unknown,
117: 115:             Some(&mut slots),
118: 116:             global_class,
119: 117:             None,
120: 118:             disable_inert_html,
121: 119:         );
122: 120: 
123: 121:         // TODO view markers for hot-reloading
124: 122:         /*
125: 123:          cfg_if::cfg_if! {
126: 124:             if #[cfg(debug_assertions)] {
127: 125:                 let marker = format!("<{component_name}/>-children");
128: 126:                 // For some reason spanning for `.children` breaks, unless `#view_marker`
129: 127:                 // is also covered by `children.span()`.
130: 128:                 let view_marker = quote_spanned!(children.span()=> .with_view_marker(#marker));
131: 129:             } else {
132: 130:                 let view_marker = quote! {};
133: 131:             }
134: 132:         }
135: 133:         */
136: 134:         let view_marker = quote! {};
137: 135: 
138: 136:         if let Some(children) = children {
139: 137:             let bindables =
140: 138:                 items_to_bind.iter().map(|ident| quote! { #ident, });
141: 139: 
142: 140:             let clonables = items_to_clone.iter().map(|ident| {
143: 141:                 quote_spanned! {ident.span()=>
144: 142:                     let #ident = ::core::clone::Clone::clone(&#ident);
145: 143:                 }
146: 144:             });
147: 145: 
148: 146:             if bindables.len() > 0 {
149: 147:                 quote_spanned! {children.span()=>
150: 148:                     .children({
151: 149:                         #(#clonables)*
152: 150: 
153: 151:                         move |#(#bindables)*| #children #view_marker
154: 152:                     })
155: 153:                 }
156: 154:             } else {
157: 155:                 quote_spanned! {children.span()=>
158: 156:                     .children({
159: 157:                         #(#clonables)*
160: 158: 
161: 159:                         ::lyx-core-lyx_core_lyx-core-lyx_core_leptos::children::ToChildren::to_children(move || #children #view_marker)
162: 160:                     })
163: 161:                 }
164: 162:             }
165: 163:         } else {
166: 164:             quote! {}
167: 165:         }
168: 166:     };
169: 167: 
170: 168:     let slots = slots.drain().map(|(slot, mut values)| {
171: 169:         let span = values
172: 170:             .last()
173: 171:             .expect("List of slots must not be empty")
174: 172:             .span();
175: 173:         let slot = Ident::new(&slot, span);
176: 174:         let value = if values.len() > 1 {
177: 175:             quote! {
178: 176:                 ::std::vec![
179: 177:                     #(#values)*
180: 178:                 ]
181: 179:             }
182: 180:         } else {
183: 181:             values.remove(0)
184: 182:         };
185: 183: 
186: 184:         quote! { .#slot(#value) }
187: 185:     });
188: 186: 
189: 187:     let build = quote_spanned! {node.name().span()=>
190: 188:         .build()
191: 189:     };
192: 190: 
193: 191:     let slot = quote_spanned! {node.span()=>
194: 192:         {
195: 193:             let slot = #component_path::builder()
196: 194:                 #(#props)*
197: 195:                 #(#slots)*
198: 196:                 #children
199: 197:                 #build
200: 198:                 #dyn_attrs;
201: 199: 
202: 200:             #[allow(unreachable_code, clippy::useless_conversion)]
203: 201:             slot.into()
204: 202:         },
205: 203:     };
206: 204: 
207: 205:     // We need to move "allow" out of "quote_spanned" because it breaks hovering in rust-analyzer
208: 206:     let slot = quote!(#[allow(unused_braces)] #slot);
209: 207: 
210: 208:     parent_slots
211: 209:         .entry(name)
212: 210:         .and_modify(|entry| entry.push(slot.clone()))
213: 211:         .or_insert(vec![slot]);
214: 212: }
215: 213: 
216: 214: pub(crate) fn is_slot(node: &KeyedAttribute) -> bool {
217: 215:     let key = node.key.to_string();
218: 216:     let key = key.trim();
219: 217:     key == "slot" || key.starts_with("slot:")
220: 218: }
221: 219: 
222: 220: pub(crate) fn get_slot(
223: 221:     node: &NodeElement<impl CustomNode>,
224: 222: ) -> Option<&KeyedAttribute> {
225: 223:     node.attributes().iter().find_map(|node| {
226: 224:         if let NodeAttribute::Attribute(node) = node {
227: 225:             if is_slot(node) {
228: 226:                 Some(node)
229: 227:             } else {
230: 228:                 None
231: 229:             }
232: 230:         } else {
233: 231:             None
234: 232:         }
235: 233:     })
236: 234: }
237: ```
```
