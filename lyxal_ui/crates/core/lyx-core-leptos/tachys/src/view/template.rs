### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_tachys\src\view\template.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\template.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\template.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\template.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\template.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\template.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\template.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\template.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\template.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\template.rs
18: 16: ```rust
19: 17: use super::{
20: 18:     add_attr::AddAnyAttr, Mountable, Position, PositionState, Render,
21: 19:     RenderHtml, ToTemplate,
22: 20: };
23: 21: use crate::{
24: 22:     html::attribute::{any_attribute::AnyAttribute, Attribute},
25: 23:     hydration::Cursor,
26: 24:     renderer::Rndr,
27: 25: };
28: 26: 
29: 27: /// A view wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper that uses a `<template>` node to optimize DOM node creation.
30: 28: ///
31: 29: /// Rather than creating all of the DOM nodes each time it is built, this template will create a
32: 30: /// single `<template>` node once, then use `.cloneNode(true)` to clone that entire tree, and
33: 31: /// hydrate it to add event listeners and interactivity for this instance.
34: 32: pub struct ViewTemplate<V> {
35: 33:     view: V,
36: 34: }
37: 35: 
38: 36: impl<V> ViewTemplate<V>
39: 37: where
40: 38:     V: Render + ToTemplate + 'static,
41: 39: {
42: 40:     /// Creates a new view template.
43: 41:     pub fn new(view: V) -> Self {
44: 42:         Self { view }
45: 43:     }
46: 44: 
47: 45:     fn to_template() -> crate::renderer::types::TemplateElement {
48: 46:         Rndr::get_template::<V>()
49: 47:     }
50: 48: }
51: 49: 
52: 50: impl<V> Render for ViewTemplate<V>
53: 51: where
54: 52:     V: Render + RenderHtml + ToTemplate + 'static,
55: 53:     V::State: Mountable,
56: 54: {
57: 55:     type State = V::State;
58: 56: 
59: 57:     // TODO try_build/try_rebuild()
60: 58: 
61: 59:     fn build(self) -> Self::State {
62: 60:         let tpl = Self::to_template();
63: 61:         let contents = Rndr::clone_template(&tpl);
64: 62:         self.view
65: 63:             .hydrate::<false>(&Cursor::new(contents), &Default::default())
66: 64:     }
67: 65: 
68: 66:     fn rebuild(self, state: &mut Self::State) {
69: 67:         self.view.rebuild(state)
70: 68:     }
71: 69: }
72: 70: 
73: 71: impl<V> AddAnyAttr for ViewTemplate<V>
74: 72: where
75: 73:     V: RenderHtml + ToTemplate + 'static,
76: 74:     V::State: Mountable,
77: 75: {
78: 76:     type Output<SomeNewAttr: Attribute> = ViewTemplate<V>;
79: 77: 
80: 78:     fn add_any_attr<NewAttr: Attribute>(
81: 79:         self,
82: 80:         _attr: NewAttr,
83: 81:     ) -> Self::Output<NewAttr> {
84: 82:         panic!("AddAnyAttr not supported on ViewTemplate");
85: 83:     }
86: 84: }
87: 85: 
88: 86: impl<V> RenderHtml for ViewTemplate<V>
89: 87: where
90: 88:     V: RenderHtml + ToTemplate + 'static,
91: 89:     V::State: Mountable,
92: 90: {
93: 91:     type AsyncOutput = V::AsyncOutput;
94: 92:     type Owned = V::Owned;
95: 93: 
96: 94:     const MIN_LENGTH: usize = V::MIN_LENGTH;
97: 95: 
98: 96:     fn to_html_with_buf(
99: 97:         self,
100: 98:         buf: &mut String,
101: 99:         position: &mut Position,
102: 100:         escape: bool,
103: 101:         mark_branches: bool,
104: 102:         extra_attrs: Vec<AnyAttribute>,
105: 103:     ) {
106: 104:         self.view.to_html_with_buf(
107: 105:             buf,
108: 106:             position,
109: 107:             escape,
110: 108:             mark_branches,
111: 109:             extra_attrs,
112: 110:         )
113: 111:     }
114: 112: 
115: 113:     fn hydrate<const FROM_SERVER: bool>(
116: 114:         self,
117: 115:         cursor: &Cursor,
118: 116:         position: &PositionState,
119: 117:     ) -> Self::State {
120: 118:         self.view.hydrate::<FROM_SERVER>(cursor, position)
121: 119:     }
122: 120: 
123: 121:     fn dry_resolve(&mut self) {
124: 122:         self.view.dry_resolve();
125: 123:     }
126: 124: 
127: 125:     async fn resolve(self) -> Self::AsyncOutput {
128: 126:         self.view.resolve().await
129: 127:     }
130: 128: 
131: 129:     fn into_owned(self) -> Self::Owned {
132: 130:         self.view.into_owned()
133: 131:     }
134: 132: }
135: 133: 
136: 134: impl<V> ToTemplate for ViewTemplate<V>
137: 135: where
138: 136:     V: RenderHtml + ToTemplate + 'static,
139: 137:     V::State: Mountable,
140: 138: {
141: 139:     const TEMPLATE: &'static str = V::TEMPLATE;
142: 140: 
143: 141:     fn to_template(
144: 142:         buf: &mut String,
145: 143:         class: &mut String,
146: 144:         style: &mut String,
147: 145:         inner_html: &mut String,
148: 146:         position: &mut Position,
149: 147:     ) {
150: 148:         V::to_template(buf, class, style, inner_html, position);
151: 149:     }
152: 150: }
153: 151: ```
154: 152: ```
155: 153: ```
156: 154: ```
157: 155: ```
158: 156: ```
159: 157: ```
160: 158: ```
161: ```
```
