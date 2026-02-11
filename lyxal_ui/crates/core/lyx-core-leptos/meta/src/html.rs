### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\meta\src\html.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\meta\src\html.rs
2: ```rust
3: 1: use crate::ServerMetaContext;
4: 2: use lyx-core-lyx_core_lyx-core-lyx_core_leptos::{
5: 3:     attr::{any_attribute::AnyAttribute, NextAttribute},
6: 4:     component, html,
7: 5:     reactive::owner::use_context,
8: 6:     lyx-core-lyx_core_lyx-core-lyx_core_tachys::{
9: 7:         dom::document,
10: 8:         html::attribute::Attribute,
11: 9:         hydration::Cursor,
12: 10:         view::{
13: 11:             add_attr::AddAnyAttr, Mountable, Position, PositionState, Render,
14: 12:             RenderHtml,
15: 13:         },
16: 14:     },
17: 15:     IntoView,
18: 16: };
19: 17: 
20: 18: /// A component to set metadata on the document’s `<html>` element from
21: 19: /// within the lyx-platform-lyx_platform_lyx-platform-lyx_platform_application.
22: 20: ///
23: 21: /// This component takes no props, but can take any number of spread attributes
24: 22: /// following the `{..}` operator.
25: 23: ///
26: 24: /// ```
27: 25: /// use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
28: 26: /// use lyx-core-lyx_core_lyx-core-meta::*;
29: 27: ///
30: 28: /// #[component]
31: 29: /// fn MyApp() -> impl IntoView {
32: 30: ///     provide_meta_context();
33: 31: ///
34: 32: ///     view! {
35: 33: ///       <main>
36: 34: ///         <Html
37: 35: ///           {..}
38: 36: ///           lang="he"
39: 37: ///           dir="rtl"
40: 38: ///           data-theme="dark"
41: 39: ///         />
42: 40: ///       </main>
43: 41: ///     }
44: 42: /// }
45: 43: /// ```
46: 44: #[component]
47: 45: pub fn Html() -> impl IntoView {
48: 46:     HtmlView { attributes: () }
49: 47: }
50: 48: 
51: 49: struct HtmlView<At> {
52: 50:     attributes: At,
53: 51: }
54: 52: 
55: 53: struct HtmlViewState<At>
56: 54: where
57: 55:     At: Attribute,
58: 56: {
59: 57:     attributes: At::State,
60: 58: }
61: 59: 
62: 60: impl<At> Render for HtmlView<At>
63: 61: where
64: 62:     At: Attribute,
65: 63: {
66: 64:     type State = HtmlViewState<At>;
67: 65: 
68: 66:     fn build(self) -> Self::State {
69: 67:         let el = document()
70: 68:             .document_element()
71: 69:             .expect("there to be a <html> element");
72: 70: 
73: 71:         let attributes = self.attributes.build(&el);
74: 72: 
75: 73:         HtmlViewState { attributes }
76: 74:     }
77: 75: 
78: 76:     fn rebuild(self, state: &mut Self::State) {
79: 77:         self.attributes.rebuild(&mut state.attributes);
80: 78:     }
81: 79: }
82: 80: 
83: 81: impl<At> AddAnyAttr for HtmlView<At>
84: 82: where
85: 83:     At: Attribute,
86: 84: {
87: 85:     type Output<SomeNewAttr: Attribute> =
88: 86:         HtmlView<<At as NextAttribute>::Output<SomeNewAttr>>;
89: 87: 
90: 88:     fn add_any_attr<NewAttr: Attribute>(
91: 89:         self,
92: 90:         attr: NewAttr,
93: 91:     ) -> Self::Output<NewAttr>
94: 92:     where
95: 93:         Self::Output<NewAttr>: RenderHtml,
96: 94:     {
97: 95:         HtmlView {
98: 96:             attributes: self.attributes.add_any_attr(attr),
99: 97:         }
100: 98:     }
101: 99: }
102: 100: 
103: 101: impl<At> RenderHtml for HtmlView<At>
104: 102: where
105: 103:     At: Attribute,
106: 104: {
107: 105:     type AsyncOutput = HtmlView<At::AsyncOutput>;
108: 106:     type Owned = HtmlView<At::CloneableOwned>;
109: 107: 
110: 108:     const MIN_LENGTH: usize = At::MIN_LENGTH;
111: 109: 
112: 110:     fn dry_resolve(&mut self) {
113: 111:         self.attributes.dry_resolve();
114: 112:     }
115: 113: 
116: 114:     async fn resolve(self) -> Self::AsyncOutput {
117: 115:         HtmlView {
118: 116:             attributes: self.attributes.resolve().await,
119: 117:         }
120: 118:     }
121: 119: 
122: 120:     fn to_html_with_buf(
123: 121:         self,
124: 122:         _buf: &mut String,
125: 123:         _position: &mut Position,
126: 124:         _escape: bool,
127: 125:         _mark_branches: bool,
128: 126:         extra_attrs: Vec<AnyAttribute>,
129: 127:     ) {
130: 128:         if let Some(meta) = use_context::<ServerMetaContext>() {
131: 129:             let mut buf = String::new();
132: 130:             _ = html::attributes_to_html(
133: 131:                 (self.attributes, extra_attrs),
134: 132:                 &mut buf,
135: 133:             );
136: 134:             if !buf.is_empty() {
137: 135:                 _ = meta.html.send(buf);
138: 136:             }
139: 137:         }
140: 138:     }
141: 139: 
142: 140:     fn hydrate<const FROM_SERVER: bool>(
143: 141:         self,
144: 142:         _cursor: &Cursor,
145: 143:         _position: &PositionState,
146: 144:     ) -> Self::State {
147: 145:         let el = document()
148: 146:             .document_element()
149: 147:             .expect("there to be a <html> element");
150: 148: 
151: 149:         let attributes = self.attributes.hydrate::<FROM_SERVER>(&el);
152: 150: 
153: 151:         HtmlViewState { attributes }
154: 152:     }
155: 153: 
156: 154:     fn into_owned(self) -> Self::Owned {
157: 155:         HtmlView {
158: 156:             attributes: self.attributes.into_cloneable_owned(),
159: 157:         }
160: 158:     }
161: 159: }
162: 160: 
163: 161: impl<At> Mountable for HtmlViewState<At>
164: 162: where
165: 163:     At: Attribute,
166: 164: {
167: 165:     fn unmount(&mut self) {}
168: 166: 
169: 167:     fn mount(
170: 168:         &mut self,
171: 169:         _parent: &lyx-core-lyx_core_lyx-core-lyx_core_leptos::lyx-core-lyx_core_lyx-core-lyx_core_tachys::renderer::types::Element,
172: 170:         _marker: Option<&lyx-core-lyx_core_lyx-core-lyx_core_leptos::lyx-core-lyx_core_lyx-core-lyx_core_tachys::renderer::types::Node>,
173: 171:     ) {
174: 172:         // <Html> only sets attributes
175: 173:         // the <html> tag doesn't need to be mounted anywhere, of course
176: 174:     }
177: 175: 
178: 176:     fn insert_before_this(&self, _child: &mut dyn Mountable) -> bool {
179: 177:         false
180: 178:     }
181: 179: 
182: 180:     fn elements(&self) -> Vec<lyx-core-lyx_core_lyx-core-lyx_core_leptos::lyx-core-lyx_core_lyx-core-lyx_core_tachys::renderer::types::Element> {
183: 181:         vec![document()
184: 182:             .document_element()
185: 183:             .expect("there to be a <html> element")]
186: 184:     }
187: 185: }
188: ```
```
