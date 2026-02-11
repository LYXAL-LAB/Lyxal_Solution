### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lib\macros\src\lib.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lib\macros\src\lib.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lib\macros\src\lib.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lib\macros\src\lib.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lib\macros\src\lib.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lib\macros\src\lib.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lib\macros\src\lib.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lib\macros\src\lib.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lib\macros\src\lib.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lib\macros\src\lib.rs
18: 16: ```rust
19: 17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lib\macros\src\lib.rs
20: 18: ```rust
21: 19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lib\macros\src\lib.rs
22: 20: ```rust
23: 21: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lib\macros\src\lib.rs
24: 22: ```rust
25: 23: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lib\macros\src\lib.rs
26: 24: ```rust
27: 25: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lib\macros\src\lib.rs
28: 26: ```rust
29: 27: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lib\macros\src\lib.rs
30: 28: ```rust
31: 29: // macro_rules! declare_model {
32: 30: //   (
33: 31: //     $( #[$model_meta:meta] )*
34: 32: //     $vis:vis struct $model:ident {
35: 33: //       $(
36: 34: //         $( #[$field_meta:meta] )*
37: 35: //         $field_vis:vis $field_name:ident : $field_ty:ty
38: 36: //       ),* $(,)?
39: 37: //     }
40: 38: //   ) => {
41: 39: //     paste::paste! {
42: 40: //       $( #[$model_meta] )*
43: 41: //       $vis struct $model {
44: 42: //         $(
45: 43: //           $( #[$field_meta] )*
46: 44: //           $field_vis $field_name : $field_ty
47: 45: //         ),*
48: 46: //       }
49: 47: 
50: 48: //       #[derive(Clone, Copy)]
51: 49: //       $vis struct [<Update $model>] {
52: 50: //         $(
53: 51: //           $field_vis $field_name: lyx-core-lyx_core_lyx-core-lyx_core_leptos_reactive::WriteSignal<$field_ty>
54: 52: //         ),*
55: 53: //       }
56: 54: 
57: 55: //       #[derive(Clone, Copy)]
58: 56: //       $vis struct [<View $model>] {
59: 57: //         $(
60: 58: //           $field_vis $field_name: lyx-core-lyx_core_lyx-core-lyx_core_leptos_reactive::ReadSignal<$field_ty>
61: 59: //         ),*
62: 60: //       }
63: 61: 
64: 62: //       impl $model {
65: 63: //         $vis fn init<Msg: Default + 'static>(
66: 64: //           self,
67: 65: //           cx: lyx-core-lyx_core_lyx-core-lyx_core_leptos_reactive::Scope,
68: 66: //           update_fn: impl Fn([<Update $model>], &Msg) + 'static
69: 67: //         ) -> ([<View $model>], $crate::MsgDispatcher<Msg>) {
70: 68: //           let Self {
71: 69: //             $( $field_name ),*
72: 70: //           } = self;
73: 71: 
74: 72: //           let (msg, msg_dispatcher)
75: 73: //             = lyx-core-lyx_core_lyx-core-lyx_core_leptos_reactive::create_signal(cx, Msg::default());
76: 74: 
77: 75: //           $(
78: 76: //             let ($field_name, [<set_ $field_name>])
79: 77: //               = lyx-core-lyx_core_lyx-core-lyx_core_leptos_reactive::create_signal(cx, $field_name);
80: 78: //           )*
81: 79: 
82: 80: //           let update_model = [<Update $model>] {
83: 81: //             $( $field_name: [<set_ $field_name>] ),*
84: 82: //           };
85: 83: 
86: 84: //           let view_model = [<View $model>] {
87: 85: //             $( $field_name ),*
88: 86: //           };
89: 87: 
90: 88: //           lyx-core-lyx_core_lyx-core-lyx_core_leptos_reactive::create_effect(cx, move |_| {
91: 89: //             msg.with(|msg| update_fn(update_model, msg));
92: 90: //           });
93: 91: 
94: 92: //           (
95: 93: //             view_model,
96: 94: //             msg_dispatcher.into(),
97: 95: //           )
98: 96: //         }
99: 97: //       }
100: 98: //     }
101: 99: //   };
102: 100: 
103: 101: //   (
104: 102: //     $( #[$model_meta:meta] )*
105: 103: //     $vis:vis struct $model:ident (
106: 104: //       $(
107: 105: //         $( #[$field_meta:meta] )*
108: 106: //         $field_vis:vis $field_ty:ty
109: 107: //       ),* $(,)?
110: 108: //     )
111: 109: //   ) => {
112: 110: //     paste::paste! {
113: 111: //       $( #[$model_meta] )*
114: 112: //       $vis struct $model (
115: 113: //         $(
116: 114: //           $( #[$field_meta] )*
117: 115: //           $field_vis $field_ty
118: 116: //         ),*
119: 117: //       )
120: 118: 
121: 119: //       $vis struct [<Update $model>] (
122: 120: //         $(
123: 121: //           $field_vis lyx-core-lyx_core_lyx-core-lyx_core_leptos_reactive::WriteSignal<$field_ty>
124: 122: //         ),*
125: 123: //       )
126: 124: 
127: 125: //       impl ::core::clone::Clone for [<Update $model>] {
128: 126: //         fn clone(&self) -> Self {
129: 127: //           let Self(
130: 128: //             $( $field ),*
131: 129: //           ) = self;
132: 130: 
133: 131: //           Self(
134: 132: //             $( core::clone::Clone::clone($field) ),*
135: 133: //           )
136: 134: //         }
137: 135: //       }
138: 136: 
139: 137: //       impl Copy for [<Update $model>] {}
140: 138: 
141: 139: //       $vis struct [<View $model>] {
142: 140: //         $(
143: 141: //           $field_vis $field_name: lyx-core-lyx_core_lyx-core-lyx_core_leptos_reactive::ReadSignal<$field_ty>
144: 142: //         ),*
145: 143: //       }
146: 144: 
147: 145: //       impl ::core::clone::Clone for [<View $model>] {
148: 146: //         fn clone(&self) -> Self {
149: 147: //           Self {
150: 148: //             $(
151: 149: //               $field_name: self.$field_name.clone()
152: 150: //             ),*
153: 151: //           }
154: 152: //         }
155: 153: //       }
156: 154: 
157: 155: //       impl Copy for [<View $model>] {}
158: 156: 
159: 157: //       impl $model {
160: 158: //         $vis fn init<Msg: Default + 'static>(
161: 159: //           self,
162: 160: //           cx: lyx-core-lyx_core_lyx-core-lyx_core_leptos_reactive::Scope,
163: 161: //           update_fn: impl Fn([<Update $model>], &Msg) + 'static
164: 162: //         ) -> ([<View $model>], MsgDispatcher<Msg>) {
165: 163: //           let Self {
166: 164: //             $( $field_name ),*
167: 165: //           } = self;
168: 166: 
169: 167: //           let (msg, msg_dispatcher)
170: 168: //             = lyx-core-lyx_core_lyx-core-lyx_core_leptos_reactive::create_signal(cx, Msg::default());
171: 169: 
172: 170: //           $(
173: 171: //             let ($field_name, [<set_ $field_name>])
174: 172: //               = lyx-core-lyx_core_lyx-core-lyx_core_leptos_reactive::create_signal(cx, $field_name);
175: 173: //           )*
176: 174: 
177: 175: //           let update_model = [<Update $model>] {
178: 176: //             $( $field_name: [<set_ $field_name>] ),*
179: 177: //           };
180: 178: 
181: 179: //           let view_model = [<View $model>] {
182: 180: //             $( $field_name ),*
183: 181: //           };
184: 182: 
185: 183: //           lyx-core-lyx_core_lyx-core-lyx_core_leptos_reactive::create_effect(cx, move |_| {
186: 184: //             msg.with(|msg| update_fn(update_model, msg));
187: 185: //           });
188: 186: 
189: 187: //           (
190: 188: //             view_model,
191: 189: //             msg_dispatcher.into(),
192: 190: //           )
193: 191: //         }
194: 192: //       }
195: 193: //     }
196: 194: //   };
197: 195: // }
198: 196: 
199: 197: // use core as __core;
200: 198: // #[doc(hidden)]
201: 199: // use lyx-core-lyx_core_lyx-core-lyx_core_leptos_reactive::SignalWith;
202: 200: // #[doc(hidden)]
203: 201: // use std::marker::PhantomData;
204: 202: 
205: 203: // type MsgDispatcher<Msg> = lyx-core-lyx_core_lyx-core-lyx_core_leptos_reactive::SignalSetter<Msg>;
206: 204: 
207: 205: // #[cfg(test)]
208: 206: // mod tests {
209: 207: //   use super::*;
210: 208: //   use ::typed_builder::TypedBuilder;
211: 209: 
212: 210: //   #[test]
213: 211: //   fn compiles() {
214: 212: //     declare_model! {
215: 213: //       #[derive(TypedBuilder)]
216: 214: //       struct Model {
217: 215: //         counter: isize,
218: 216: //       }
219: 217: //     }
220: 218: //   }
221: 219: // }
222: 220: 
223: 221: #[macro_use]
224: 222: extern crate proc_macro_error;
225: 223: 
226: 224: mod codegen;
227: 225: mod model;
228: 226: 
229: 227: use proc_macro_error::proc_macro_error;
230: 228: 
231: 229: #[proc_macro_derive(Model, attributes(model))]
232: 230: #[proc_macro_error]
233: 231: pub fn model(stream: proc_macro::TokenStream) -> proc_macro::TokenStream {
234: 232:   let ast = syn::parse_macro_input!(stream as syn::DeriveInput);
235: 233: 
236: 234:   let model = model::model(ast);
237: 235: 
238: 236:   codegen::codegen(model).into()
239: 237: }
240: 238: ```
241: 239: ```
242: 240: ```
243: 241: ```
244: 242: ```
245: 243: ```
246: 244: ```
247: 245: ```
248: 246: ```
249: 247: ```
250: 248: ```
251: 249: ```
252: 250: ```
253: 251: ```
254: ```
```
