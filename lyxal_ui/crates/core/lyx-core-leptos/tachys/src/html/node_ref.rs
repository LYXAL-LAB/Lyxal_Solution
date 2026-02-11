### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_tachys\src\html\node_ref.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\node_ref.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\node_ref.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\node_ref.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\node_ref.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\node_ref.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\node_ref.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\node_ref.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\node_ref.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\node_ref.rs
18: 16: ```rust
19: 17: use super::{
20: 18:     attribute::{
21: 19:         maybe_next_attr_erasure_macros::next_attr_output_type, Attribute,
22: 20:         NextAttribute,
23: 21:     },
24: 22:     element::ElementType,
25: 23: };
26: 24: use crate::{
27: 25:     html::{
28: 26:         attribute::{
29: 27:             maybe_next_attr_erasure_macros::next_attr_combine,
30: 28:             NamedAttributeKey,
31: 29:         },
32: 30:         element::HtmlElement,
33: 31:     },
34: 32:     prelude::Render,
35: 33:     view::add_attr::AddAnyAttr,
36: 34: };
37: 35: use std::marker::PhantomData;
38: 36: 
39: 37: /// Describes a container that can be used to hold a reference to an HTML element.
40: 38: pub trait NodeRefContainer<E>: Send + Clone + 'static
41: 39: where
42: 40:     E: ElementType,
43: 41: {
44: 42:     /// Fills the container with the element.
45: 43:     fn load(self, el: &crate::renderer::types::Element);
46: 44: }
47: 45: 
48: 46: /// An [`Attribute`] that will fill a [`NodeRefContainer`] with an HTML element.
49: 47: #[derive(Debug)]
50: 48: pub struct NodeRefAttr<E, C> {
51: 49:     container: C,
52: 50:     ty: PhantomData<E>,
53: 51: }
54: 52: 
55: 53: impl<E, C> Clone for NodeRefAttr<E, C>
56: 54: where
57: 55:     C: Clone,
58: 56: {
59: 57:     fn clone(&self) -> Self {
60: 58:         Self {
61: 59:             container: self.container.clone(),
62: 60:             ty: PhantomData,
63: 61:         }
64: 62:     }
65: 63: }
66: 64: 
67: 65: /// Creates an attribute that will fill a [`NodeRefContainer`] with the element it is lyx-platform-lyx_platform_lyx-platform-lyx_platform_applied to.
68: 66: pub fn node_ref<E, C>(container: C) -> NodeRefAttr<E, C>
69: 67: where
70: 68:     E: ElementType,
71: 69:     C: NodeRefContainer<E>,
72: 70: {
73: 71:     NodeRefAttr {
74: 72:         container,
75: 73:         ty: PhantomData,
76: 74:     }
77: 75: }
78: 76: 
79: 77: impl<E, C> Attribute for NodeRefAttr<E, C>
80: 78: where
81: 79:     E: ElementType,
82: 80:     C: NodeRefContainer<E>,
83: 81: 
84: 82:     crate::renderer::types::Element: PartialEq,
85: 83: {
86: 84:     const MIN_LENGTH: usize = 0;
87: 85:     type AsyncOutput = Self;
88: 86:     type State = crate::renderer::types::Element;
89: 87:     type Cloneable = Self;
90: 88:     type CloneableOwned = Self;
91: 89: 
92: 90:     #[inline(always)]
93: 91:     fn html_len(&self) -> usize {
94: 92:         0
95: 93:     }
96: 94: 
97: 95:     fn to_html(
98: 96:         self,
99: 97:         _buf: &mut String,
100: 98:         _class: &mut String,
101: 99:         _style: &mut String,
102: 100:         _inner_html: &mut String,
103: 101:     ) {
104: 102:     }
105: 103: 
106: 104:     fn hydrate<const FROM_SERVER: bool>(
107: 105:         self,
108: 106:         el: &crate::renderer::types::Element,
109: 107:     ) -> Self::State {
110: 108:         self.container.load(el);
111: 109:         el.to_owned()
112: 110:     }
113: 111: 
114: 112:     fn build(self, el: &crate::renderer::types::Element) -> Self::State {
115: 113:         self.container.load(el);
116: 114:         el.to_owned()
117: 115:     }
118: 116: 
119: 117:     fn rebuild(self, state: &mut Self::State) {
120: 118:         self.container.load(state);
121: 119:     }
122: 120: 
123: 121:     fn into_cloneable(self) -> Self::Cloneable {
124: 122:         self
125: 123:     }
126: 124: 
127: 125:     fn into_cloneable_owned(self) -> Self::Cloneable {
128: 126:         self
129: 127:     }
130: 128: 
131: 129:     fn dry_resolve(&mut self) {}
132: 130: 
133: 131:     async fn resolve(self) -> Self::AsyncOutput {
134: 132:         self
135: 133:     }
136: 134: 
137: 135:     fn keys(&self) -> Vec<NamedAttributeKey> {
138: 136:         vec![]
139: 137:     }
140: 138: }
141: 139: 
142: 140: impl<E, C> NextAttribute for NodeRefAttr<E, C>
143: 141: where
144: 142:     E: ElementType,
145: 143:     C: NodeRefContainer<E>,
146: 144: 
147: 145:     crate::renderer::types::Element: PartialEq,
148: 146: {
149: 147:     next_attr_output_type!(Self, NewAttr);
150: 148: 
151: 149:     fn add_any_attr<NewAttr: Attribute>(
152: 150:         self,
153: 151:         new_attr: NewAttr,
154: 152:     ) -> Self::Output<NewAttr> {
155: 153:         next_attr_combine!(self, new_attr)
156: 154:     }
157: 155: }
158: 156: 
159: 157: /// Adds the `node_ref` attribute to an element.
160: 158: pub trait NodeRefAttribute<E, C>
161: 159: where
162: 160:     E: ElementType,
163: 161:     C: NodeRefContainer<E>,
164: 162: 
165: 163:     crate::renderer::types::Element: PartialEq,
166: 164: {
167: 165:     /// Binds this HTML element to a [`NodeRefContainer`].
168: 166:     fn node_ref(
169: 167:         self,
170: 168:         container: C,
171: 169:     ) -> <Self as AddAnyAttr>::Output<NodeRefAttr<E, C>>
172: 170:     where
173: 171:         Self: Sized + AddAnyAttr,
174: 172:         <Self as AddAnyAttr>::Output<NodeRefAttr<E, C>>: Render,
175: 173:     {
176: 174:         self.add_any_attr(node_ref(container))
177: 175:     }
178: 176: }
179: 177: 
180: 178: impl<E, At, Ch, C> NodeRefAttribute<E, C> for HtmlElement<E, At, Ch>
181: 179: where
182: 180:     E: ElementType,
183: 181:     At: Attribute,
184: 182:     Ch: Render,
185: 183:     C: NodeRefContainer<E>,
186: 184: 
187: 185:     crate::renderer::types::Element: PartialEq,
188: 186: {
189: 187: }
190: 188: ```
191: 189: ```
192: 190: ```
193: 191: ```
194: 192: ```
195: 193: ```
196: 194: ```
197: 195: ```
198: ```
```
