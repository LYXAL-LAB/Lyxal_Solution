1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx-found-floating\packages\core\src\detect_overflow.rs
2: ```rust
3: 1: use lyx_ui_foundations_utils::{
4: 2:     Coords, ElementOrVirtual, OwnedElementOrWindow, Padding, Rect, SideObject, get_padding_object,
5: 3:     rect_to_lyx-core-lyx_core_lyx-core-lyx_core_client_rect,
6: 4: };
7: 5: 
8: 6: use crate::types::{
9: 7:     Boundary, ConvertOffsetParentRelativeRectToViewportRelativeRectArgs, ElementContext, Elements,
10: 8:     GetClippingRectArgs, MiddlewareState, RootBoundary,
11: 9: };
12: 10: 
13: 11: /// Options for [`detect_overflow`].
14: 12: #[derive(Clone, Debug, PartialEq)]
15: 13: pub struct DetectOverflowOptions<Element> {
16: 14:     /// The clipping element(s) or area in which overflow will be checked.
17: 15:     ///
18: 16:     /// Defaults to [`Boundary::ClippingAncestors`].
19: 17:     pub boundary: Option<Boundary<Element>>,
20: 18: 
21: 19:     /// The root clipping area in which overflow will be checked.
22: 20:     ///
23: 21:     /// Defaults to [`RootBoundary::Viewport`].
24: 22:     pub root_boundary: Option<RootBoundary>,
25: 23: 
26: 24:     /// The element in which overflow is being checked relative to a boundary.
27: 25:     ///
28: 26:     /// Defaults to [`ElementContext::Floating`].
29: 27:     pub element_context: Option<ElementContext>,
30: 28: 
31: 29:     /// Whether to check for overflow using the alternate element's boundary (only when [`boundary`][`Self::boundary`] is [`Boundary::ClippingAncestors`]).
32: 30:     ///
33: 31:     /// Defaults to `false`.
34: 32:     pub alt_boundary: Option<bool>,
35: 33: 
36: 34:     /// Virtual padding for the resolved overflow detection offsets.
37: 35:     ///
38: 36:     /// Defaults to `0` on all sides.
39: 37:     pub padding: Option<Padding>,
40: 38: }
41: 39: 
42: 40: impl<Element> DetectOverflowOptions<Element> {
43: 41:     /// Set `boundary` option.
44: 42:     pub fn boundary(mut self, value: Boundary<Element>) -> Self {
45: 43:         self.boundary = Some(value);
46: 44:         self
47: 45:     }
48: 46: 
49: 47:     /// Set `root_boundary` option.
50: 48:     pub fn root_boundary(mut self, value: RootBoundary) -> Self {
51: 49:         self.root_boundary = Some(value);
52: 50:         self
53: 51:     }
54: 52: 
55: 53:     /// Set `element_context` option.
56: 54:     pub fn element_context(mut self, value: ElementContext) -> Self {
57: 55:         self.element_context = Some(value);
58: 56:         self
59: 57:     }
60: 58: 
61: 59:     /// Set `alt_boundary` option.
62: 60:     pub fn alt_boundary(mut self, value: bool) -> Self {
63: 61:         self.alt_boundary = Some(value);
64: 62:         self
65: 63:     }
66: 64: 
67: 65:     /// Set `padding` option.
68: 66:     pub fn padding(mut self, value: Padding) -> Self {
69: 67:         self.padding = Some(value);
70: 68:         self
71: 69:     }
72: 70: }
73: 71: 
74: 72: impl<Element> Default for DetectOverflowOptions<Element> {
75: 73:     fn default() -> Self {
76: 74:         Self {
77: 75:             boundary: Default::default(),
78: 76:             root_boundary: Default::default(),
79: 77:             element_context: Default::default(),
80: 78:             alt_boundary: Default::default(),
81: 79:             padding: Default::default(),
82: 80:         }
83: 81:     }
84: 82: }
85: 83: 
86: 84: /// Resolves with an object of overflow side offsets that determine how much the element is overflowing a given clipping boundary on each side.
87: 85: /// - positive = overflowing the boundary by that number of pixels
88: 86: /// - negative = how many pixels left before it will overflow
89: 87: /// - `0` = lies flush with the boundary
90: 88: ///
91: 89: /// See [the Rust Floating UI book](https://floating-ui.rustforweb.org/detect-overflow.html) for more documentation.
92: 90: pub fn detect_overflow<Element: Clone + 'static, Window: Clone + 'static>(
93: 91:     state: MiddlewareState<Element, Window>,
94: 92:     options: DetectOverflowOptions<Element>,
95: 93: ) -> SideObject {
96: 94:     let MiddlewareState {
97: 95:         x,
98: 96:         y,
99: 97:         platform,
100: 98:         rects,
101: 99:         elements,
102: 100:         strategy,
103: 101:         ..
104: 102:     } = state;
105: 103: 
106: 104:     let boundary = options.boundary.unwrap_or(Boundary::ClippingAncestors);
107: 105:     let root_boundary = options.root_boundary.unwrap_or(RootBoundary::Viewport);
108: 106:     let element_context = options.element_context.unwrap_or(ElementContext::Floating);
109: 107:     let alt_boundary = options.alt_boundary.unwrap_or(false);
110: 108:     let padding = options.padding.unwrap_or(Padding::All(0.0));
111: 109: 
112: 110:     let padding_object = get_padding_object(padding);
113: 111:     let alt_context = match element_context {
114: 112:         ElementContext::Reference => ElementContext::Floating,
115: 113:         ElementContext::Floating => ElementContext::Reference,
116: 114:     };
117: 115:     let element = if alt_boundary {
118: 116:         elements.get_element_context(alt_context)
119: 117:     } else {
120: 118:         elements.get_element_context(element_context)
121: 119:     };
122: 120: 
123: 121:     let document_element = platform.get_document_element(elements.floating);
124: 122:     let context_element: Option<Element>;
125: 123: 
126: 124:     let element = match element {
127: 125:         ElementOrVirtual::Element(element) => element,
128: 126:         ElementOrVirtual::VirtualElement(virtual_element) => {
129: 127:             context_element = virtual_element.context_element();
130: 128: 
131: 129:             context_element
132: 130:                 .as_ref()
133: 131:                 .or(document_element.as_ref())
134: 132:                 .expect("Element should exist.")
135: 133:         }
136: 134:     };
137: 135: 
138: 136:     let clipping_lyx-core-lyx_core_lyx-core-lyx_core_client_rect =
139: 137:         rect_to_lyx-core-lyx_core_lyx-core-lyx_core_client_rect(platform.get_clipping_rect(GetClippingRectArgs {
140: 138:             element,
141: 139:             boundary,
142: 140:             root_boundary,
143: 141:             strategy,
144: 142:         }));
145: 143: 
146: 144:     let rect = match element_context {
147: 145:         ElementContext::Reference => rects.reference.clone(),
148: 146:         ElementContext::Floating => Rect {
149: 147:             x,
150: 148:             y,
151: 149:             width: rects.floating.width,
152: 150:             height: rects.floating.height,
153: 151:         },
154: 152:     };
155: 153: 
156: 154:     let offset_parent = platform.get_offset_parent(elements.floating);
157: 155:     let offset_scale = match offset_parent.as_ref() {
158: 156:         Some(offset_parent) => match offset_parent {
159: 157:             OwnedElementOrWindow::Element(element) => {
160: 158:                 platform.get_scale(element).unwrap_or(Coords::new(1.0))
161: 159:             }
162: 160:             OwnedElementOrWindow::Window(_) => Coords::new(1.0),
163: 161:         },
164: 162:         None => Coords::new(1.0),
165: 163:     };
166: 164: 
167: 165:     let element_lyx-core-lyx_core_lyx-core-lyx_core_client_rect = rect_to_lyx-core-lyx_core_lyx-core-lyx_core_client_rect(
168: 166:         platform
169: 167:             .convert_offset_parent_relative_rect_to_viewport_relative_rect(
170: 168:                 ConvertOffsetParentRelativeRectToViewportRelativeRectArgs {
171: 169:                     elements: Some(Elements {
172: 170:                         reference: elements.reference,
173: 171:                         floating: elements.floating,
174: 172:                     }),
175: 173:                     rect: rect.clone(),
176: 174:                     offset_parent: offset_parent
177: 175:                         .as_ref()
178: 176:                         .map(|offset_parent| offset_parent.into()),
179: 177:                     strategy,
180: 178:                 },
181: 179:             )
182: 180:             .unwrap_or(rect),
183: 181:     );
184: 182: 
185: 183:     SideObject {
186: 184:         top: (clipping_lyx-core-lyx_core_lyx-core-lyx_core_client_rect.top - element_lyx-core-lyx_core_lyx-core-lyx_core_client_rect.top + padding_object.top)
187: 185:             / offset_scale.y,
188: 186:         right: (element_lyx-core-lyx_core_lyx-core-lyx_core_client_rect.right - clipping_lyx-core-lyx_core_lyx-core-lyx_core_client_rect.right + padding_object.right)
189: 187:             / offset_scale.x,
190: 188:         bottom: (element_lyx-core-lyx_core_lyx-core-lyx_core_client_rect.bottom - clipping_lyx-core-lyx_core_lyx-core-lyx_core_client_rect.bottom + padding_object.bottom)
191: 189:             / offset_scale.y,
192: 190:         left: (clipping_lyx-core-lyx_core_lyx-core-lyx_core_client_rect.left - element_lyx-core-lyx_core_lyx-core-lyx_core_client_rect.left + padding_object.left)
193: 191:             / offset_scale.x,
194: 192:     }
195: 193: }
196: ```
```

