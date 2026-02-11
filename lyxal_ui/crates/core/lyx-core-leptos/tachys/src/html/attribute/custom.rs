### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_tachys\src\html\attribute\custom.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\attribute\custom.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\attribute\custom.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\attribute\custom.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\attribute\custom.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\attribute\custom.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\attribute\custom.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\attribute\custom.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\attribute\custom.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\attribute\custom.rs
18: 16: ```rust
19: 17: use super::{
20: 18:     maybe_next_attr_erasure_macros::next_attr_output_type, NextAttribute,
21: 19: };
22: 20: use crate::{
23: 21:     html::attribute::{
24: 22:         maybe_next_attr_erasure_macros::next_attr_combine, Attribute,
25: 23:         AttributeValue, NamedAttributeKey,
26: 24:     },
27: 25:     view::{add_attr::AddAnyAttr, Position, ToTemplate},
28: 26: };
29: 27: use std::{borrow::Cow, sync::Arc};
30: 28: 
31: 29: /// Adds a custom attribute with any key-value combination.
32: 30: #[inline(always)]
33: 31: pub fn custom_attribute<K, V>(key: K, value: V) -> CustomAttr<K, V>
34: 32: where
35: 33:     K: CustomAttributeKey,
36: 34:     V: AttributeValue,
37: 35: {
38: 36:     CustomAttr { key, value }
39: 37: }
40: 38: 
41: 39: /// A custom attribute with any key-value combination.
42: 40: #[derive(Debug)]
43: 41: pub struct CustomAttr<K, V>
44: 42: where
45: 43:     K: CustomAttributeKey,
46: 44:     V: AttributeValue,
47: 45: {
48: 46:     key: K,
49: 47:     value: V,
50: 48: }
51: 49: 
52: 50: impl<K, V> Clone for CustomAttr<K, V>
53: 51: where
54: 52:     K: CustomAttributeKey,
55: 53:     V: AttributeValue + Clone,
56: 54: {
57: 55:     fn clone(&self) -> Self {
58: 56:         Self {
59: 57:             key: self.key.clone(),
60: 58:             value: self.value.clone(),
61: 59:         }
62: 60:     }
63: 61: }
64: 62: 
65: 63: impl<K, V> Attribute for CustomAttr<K, V>
66: 64: where
67: 65:     K: CustomAttributeKey,
68: 66:     V: AttributeValue,
69: 67: {
70: 68:     const MIN_LENGTH: usize = 0;
71: 69:     type AsyncOutput = CustomAttr<K, V::AsyncOutput>;
72: 70:     type State = V::State;
73: 71:     type Cloneable = CustomAttr<K, V::Cloneable>;
74: 72:     type CloneableOwned = CustomAttr<K, V::CloneableOwned>;
75: 73: 
76: 74:     fn html_len(&self) -> usize {
77: 75:         self.key.as_ref().len() + 3 + self.value.html_len()
78: 76:     }
79: 77: 
80: 78:     fn to_html(
81: 79:         self,
82: 80:         buf: &mut String,
83: 81:         _class: &mut String,
84: 82:         _style: &mut String,
85: 83:         _inner_html: &mut String,
86: 84:     ) {
87: 85:         self.value.to_html(self.key.as_ref(), buf);
88: 86:     }
89: 87: 
90: 88:     fn hydrate<const FROM_SERVER: bool>(
91: 89:         self,
92: 90:         el: &crate::renderer::types::Element,
93: 91:     ) -> Self::State {
94: 92:         if !K::KEY.is_empty() {
95: 93:             self.value.hydrate::<FROM_SERVER>(self.key.as_ref(), el)
96: 94:         } else {
97: 95:             self.value.build(el, self.key.as_ref())
98: 96:         }
99: 97:     }
100: 98: 
101: 99:     fn build(self, el: &crate::renderer::types::Element) -> Self::State {
102: 100:         self.value.build(el, self.key.as_ref())
103: 101:     }
104: 102: 
105: 103:     fn rebuild(self, state: &mut Self::State) {
106: 104:         self.value.rebuild(self.key.as_ref(), state);
107: 105:     }
108: 106: 
109: 107:     fn into_cloneable(self) -> Self::Cloneable {
110: 108:         CustomAttr {
111: 109:             key: self.key,
112: 110:             value: self.value.into_cloneable(),
113: 111:         }
114: 112:     }
115: 113: 
116: 114:     fn into_cloneable_owned(self) -> Self::CloneableOwned {
117: 115:         CustomAttr {
118: 116:             key: self.key,
119: 117:             value: self.value.into_cloneable_owned(),
120: 118:         }
121: 119:     }
122: 120: 
123: 121:     fn dry_resolve(&mut self) {
124: 122:         self.value.dry_resolve();
125: 123:     }
126: 124: 
127: 125:     async fn resolve(self) -> Self::AsyncOutput {
128: 126:         CustomAttr {
129: 127:             key: self.key,
130: 128:             value: self.value.resolve().await,
131: 129:         }
132: 130:     }
133: 131: 
134: 132:     fn keys(&self) -> Vec<NamedAttributeKey> {
135: 133:         vec![NamedAttributeKey::Attribute(
136: 134:             self.key.as_ref().to_string().into(),
137: 135:         )]
138: 136:     }
139: 137: }
140: 138: 
141: 139: impl<K, V> NextAttribute for CustomAttr<K, V>
142: 140: where
143: 141:     K: CustomAttributeKey,
144: 142:     V: AttributeValue,
145: 143: {
146: 144:     next_attr_output_type!(Self, NewAttr);
147: 145: 
148: 146:     fn add_any_attr<NewAttr: Attribute>(
149: 147:         self,
150: 148:         new_attr: NewAttr,
151: 149:     ) -> Self::Output<NewAttr> {
152: 150:         next_attr_combine!(self, new_attr)
153: 151:     }
154: 152: }
155: 153: 
156: 154: impl<K, V> ToTemplate for CustomAttr<K, V>
157: 155: where
158: 156:     K: CustomAttributeKey,
159: 157:     V: AttributeValue,
160: 158: {
161: 159:     fn to_template(
162: 160:         buf: &mut String,
163: 161:         _class: &mut String,
164: 162:         _style: &mut String,
165: 163:         _inner_html: &mut String,
166: 164:         _position: &mut Position,
167: 165:     ) {
168: 166:         if !K::KEY.is_empty() {
169: 167:             V::to_template(K::KEY, buf);
170: 168:         }
171: 169:     }
172: 170: }
173: 171: 
174: 172: // TODO this needs to be a method, not a const
175: 173: /// Defines a custom attribute key.
176: 174: pub trait CustomAttributeKey: Clone + AsRef<str> + Send + 'static {
177: 175:     /// The attribute name.
178: 176:     const KEY: &'static str;
179: 177: }
180: 178: 
181: 179: impl CustomAttributeKey for &'static str {
182: 180:     const KEY: &'static str = "";
183: 181: }
184: 182: 
185: 183: impl CustomAttributeKey for Cow<'static, str> {
186: 184:     const KEY: &'static str = "";
187: 185: }
188: 186: 
189: 187: impl CustomAttributeKey for String {
190: 188:     const KEY: &'static str = "";
191: 189: }
192: 190: 
193: 191: impl CustomAttributeKey for Arc<str> {
194: 192:     const KEY: &'static str = "";
195: 193: }
196: 194: 
197: 195: #[cfg(all(feature = "nightly", rustc_nightly))]
198: 196: impl<const K: &'static str> CustomAttributeKey
199: 197:     for crate::view::static_types::Static<K>
200: 198: {
201: 199:     const KEY: &'static str = K;
202: 200: }
203: 201: 
204: 202: /// Adds a custom attribute to an element.
205: 203: pub trait CustomAttribute<K, V>
206: 204: where
207: 205:     K: CustomAttributeKey,
208: 206:     V: AttributeValue,
209: 207: 
210: 208:     Self: Sized + AddAnyAttr,
211: 209: {
212: 210:     /// Adds an HTML attribute by key and value.
213: 211:     fn attr(
214: 212:         self,
215: 213:         key: K,
216: 214:         value: V,
217: 215:     ) -> <Self as AddAnyAttr>::Output<CustomAttr<K, V>> {
218: 216:         self.add_any_attr(custom_attribute(key, value))
219: 217:     }
220: 218: }
221: 219: 
222: 220: impl<T, K, V> CustomAttribute<K, V> for T
223: 221: where
224: 222:     T: AddAnyAttr,
225: 223:     K: CustomAttributeKey,
226: 224:     V: AttributeValue,
227: 225: {
228: 226: }
229: 227: ```
230: 228: ```
231: 229: ```
232: 230: ```
233: 231: ```
234: 232: ```
235: 233: ```
236: 234: ```
237: ```
```
