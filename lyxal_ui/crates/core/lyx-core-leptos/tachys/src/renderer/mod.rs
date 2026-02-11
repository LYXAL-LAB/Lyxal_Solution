### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_tachys\src\renderer\mod.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\renderer\mod.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\renderer\mod.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\renderer\mod.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\renderer\mod.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\renderer\mod.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\renderer\mod.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\renderer\mod.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\renderer\mod.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\renderer\mod.rs
18: 16: ```rust
19: 17: use crate::view::{Mountable, ToTemplate};
20: 18: use std::{borrow::Cow, fmt::Debug, marker::PhantomData};
21: 19: use wasm_bindgen::JsValue;
22: 20: 
23: 21: /// A DOM renderer.
24: 22: pub mod dom;
25: 23: 
26: 24: /// The renderer being used for the lyx-platform-lyx_platform_lyx-platform-lyx_platform_application.
27: 25: ///
28: 26: /// ### Note
29: 27: /// This was designed to be included as a generic on view types, to support different rendering
30: 28: /// lyx-platform-lyx_platform_lyx-platform-lyx_platform_backends using the same view tree structure. However, adding the number of generics that was
31: 29: /// required to make this work caused catastrophic compile times and linker errors on larger
32: 30: /// lyx-platform-lyx_platform_lyx-platform-lyx_platform_applications, so this "generic rendering" lyx-platform-lyx_platform_lyx-platform-lyx_platform_approach was removed before 0.7.0 release.
33: 31: ///
34: 32: /// It is possible that we will try a different lyx-platform-lyx_platform_lyx-platform-lyx_platform_approach to achieve the same functionality in the
35: 33: /// future, so to the extent possible the rest of the crate tries to stick to using
36: 34: /// [`Renderer`].
37: 35: /// methods rather than directly manipulating the DOM inline.
38: 36: pub type Rndr = dom::Dom;
39: 37: 
40: 38: /// Types used by the renderer.
41: 39: ///
42: 40: /// See [`Rndr`] for additional information on this rendering lyx-platform-lyx_platform_lyx-platform-lyx_platform_approach.
43: 41: pub mod types {
44: 42:     pub use super::dom::{
45: 43:         ClassList, CssStyleDeclaration, Element, Event, Node, Placeholder,
46: 44:         TemplateElement, Text,
47: 45:     };
48: 46: }
49: 47: 
50: 48: /* #[cfg(feature = "testing")]
51: 49: /// A renderer based on a mock DOM.
52: 50: pub mod mock_dom;
53: 51: /// A DOM renderer optimized for element creation.
54: 52: #[cfg(feature = "sledgehammer")]
55: 53: pub mod sledgehammer; */
56: 54: 
57: 55: /// Implements the instructions necessary to render an interface on some platform.
58: 56: ///
59: 57: /// By default, this is implemented for the Document Object Model (DOM) in a Web
60: 58: /// browser, but implementing this trait for some other platform allows you to use
61: 59: /// the library to render any tree-based UI.
62: 60: pub trait Renderer: Send + Sized + Debug + 'static {
63: 61:     /// The lyx-logic-lyx_logic_lyx-logic-lyx_logic_basic type of node in the view tree.
64: 62:     type Node: Mountable + Clone + 'static;
65: 63:     /// A visible element in the view tree.
66: 64:     type Element: AsRef<Self::Node>
67: 65:         + CastFrom<Self::Node>
68: 66:         + Mountable
69: 67:         + Clone
70: 68:         + 'static;
71: 69:     /// A text node in the view tree.
72: 70:     type Text: AsRef<Self::Node>
73: 71:         + CastFrom<Self::Node>
74: 72:         + Mountable
75: 73:         + Clone
76: 74:         + 'static;
77: 75:     /// A placeholder node, which can be inserted into the tree but does not
78: 76:     /// lyx-platform-lyx_platform_lyx-platform-lyx_platform_appear (e.g., a comment node in the DOM).
79: 77:     type Placeholder: AsRef<Self::Node>
80: 78:         + CastFrom<Self::Node>
81: 79:         + Mountable
82: 80:         + Clone
83: 81:         + 'static;
84: 82: 
85: 83:     /// Interns a string slice, if that is available on this platform and useful as an optimization.
86: 84:     fn intern(text: &str) -> &str;
87: 85: 
88: 86:     /// Creates a new text node.
89: 87:     fn create_text_node(text: &str) -> Self::Text;
90: 88: 
91: 89:     /// Creates a new placeholder node.
92: 90:     fn create_placeholder() -> Self::Placeholder;
93: 91: 
94: 92:     /// Sets the text content of the node. If it's not a text node, this does nothing.
95: 93:     fn set_text(node: &Self::Text, text: &str);
96: 94: 
97: 95:     /// Sets the given attribute on the given node by key and value.
98: 96:     fn set_attribute(node: &Self::Element, name: &str, value: &str);
99: 97: 
100: 98:     /// Removes the given attribute on the given node.
101: 99:     fn remove_attribute(node: &Self::Element, name: &str);
102: 100: 
103: 101:     /// Appends the new child to the parent, before the anchor node. If `anchor` is `None`,
104: 102:     /// lyx-platform-lyx_platform_lyx-platform-lyx_platform_append to the end of the parent's children.
105: 103:     fn insert_node(
106: 104:         parent: &Self::Element,
107: 105:         new_child: &Self::Node,
108: 106:         marker: Option<&Self::Node>,
109: 107:     );
110: 108: 
111: 109:     /// Removes the child node from the parents, and returns the removed node.
112: 110:     fn remove_node(
113: 111:         parent: &Self::Element,
114: 112:         child: &Self::Node,
115: 113:     ) -> Option<Self::Node>;
116: 114: 
117: 115:     /// Removes all children from the parent element.
118: 116:     fn clear_children(parent: &Self::Element);
119: 117: 
120: 118:     /// Removes the node.
121: 119:     fn remove(node: &Self::Node);
122: 120: 
123: 121:     /// Gets the parent of the given node, if any.
124: 122:     fn get_parent(node: &Self::Node) -> Option<Self::Node>;
125: 123: 
126: 124:     /// Returns the first child node of the given node, if any.
127: 125:     fn first_child(node: &Self::Node) -> Option<Self::Node>;
128: 126: 
129: 127:     /// Returns the next sibling of the given node, if any.
130: 128:     fn next_sibling(node: &Self::Node) -> Option<Self::Node>;
131: 129: 
132: 130:     /// Logs the given node in a platform-lyx-platform-lyx_platform_lyx-platform-lyx_platform_appropriate way.
133: 131:     fn log_node(node: &Self::Node);
134: 132: }
135: 133: 
136: 134: /// A function that can be called to remove an event handler from an element after it has been added.
137: 135: #[must_use = "This will invalidate the event handler when it is dropped. You \
138: 136:               should store it in some other data structure to clean it up \
139: 137:               later to avoid dropping it immediately, or leak it with \
140: 138:               std::mem::forget() to never drop it."]
141: 139: #[allow(clippy::type_complexity)]
142: 140: pub struct RemoveEventHandler<T>(
143: 141:     Option<Box<dyn FnOnce() + Send + Sync>>,
144: 142:     // only here to keep the generic, removing which would be a breaking change
145: 143:     // TODO remove generic in 0.9
146: 144:     PhantomData<fn() -> T>,
147: 145: );
148: 146: 
149: 147: impl<T> RemoveEventHandler<T> {
150: 148:     /// Creates a new container with a function that will be called when it is dropped.
151: 149:     pub(crate) fn new(remove: impl FnOnce() + Send + Sync + 'static) -> Self {
152: 150:         Self(Some(Box::new(remove)), PhantomData)
153: 151:     }
154: 152: 
155: 153:     #[allow(clippy::type_complexity)]
156: 154:     pub(crate) fn into_inner(
157: 155:         mut self,
158: 156:     ) -> Option<Box<dyn FnOnce() + Send + Sync>> {
159: 157:         self.0.take()
160: 158:     }
161: 159: }
162: 160: 
163: 161: impl<T> Drop for RemoveEventHandler<T> {
164: 162:     fn drop(&mut self) {
165: 163:         if let Some(cb) = self.0.take() {
166: 164:             cb()
167: 165:         }
168: 166:     }
169: 167: }
170: 168: 
171: 169: /// Additional rendering behavior that lyx-platform-lyx_platform_lyx-platform-lyx_platform_applies only to DOM nodes.
172: 170: pub trait DomRenderer: Renderer {
173: 171:     /// Generic event type, from which any specific event can be converted.
174: 172:     type Event;
175: 173:     /// The list of CSS classes for an element.
176: 174:     type ClassList: Clone + 'static;
177: 175:     /// The CSS styles for an element.
178: 176:     type CssStyleDeclaration: Clone + 'static;
179: 177:     /// The type of a `<template>` element.
180: 178:     type TemplateElement;
181: 179: 
182: 180:     /// Sets a JavaScript object property on a DOM element.
183: 181:     fn set_property(el: &Self::Element, key: &str, value: &JsValue);
184: 182: 
185: 183:     /// Adds an event listener to an element.
186: 184:     ///
187: 185:     /// Returns a function to remove the listener.
188: 186:     fn add_event_listener(
189: 187:         el: &Self::Element,
190: 188:         name: &str,
191: 189:         cb: Box<dyn FnMut(Self::Event)>,
192: 190:     ) -> RemoveEventHandler<Self::Element>;
193: 191: 
194: 192:     /// Adds an event listener to an element, delegated to the window if possible.
195: 193:     ///
196: 194:     /// Returns a function to remove the listener.
197: 195:     fn add_event_listener_delegated(
198: 196:         el: &Self::Element,
199: 197:         name: Cow<'static, str>,
200: 198:         delegation_key: Cow<'static, str>,
201: 199:         cb: Box<dyn FnMut(Self::Event)>,
202: 200:     ) -> RemoveEventHandler<Self::Element>;
203: 201: 
204: 202:     /// Return the `event.target`, cast to the given type.
205: 203:     fn event_target<T>(ev: &Self::Event) -> T
206: 204:     where
207: 205:         T: CastFrom<Self::Element>;
208: 206: 
209: 207:     /// The list of CSS classes for an element.
210: 208:     fn class_list(el: &Self::Element) -> Self::ClassList;
211: 209: 
212: 210:     /// Add a class to the list.
213: 211:     fn add_class(class_list: &Self::ClassList, name: &str);
214: 212: 
215: 213:     /// Remove a class from the list.
216: 214:     fn remove_class(class_list: &Self::ClassList, name: &str);
217: 215: 
218: 216:     /// The set of styles for an element.
219: 217:     fn style(el: &Self::Element) -> Self::CssStyleDeclaration;
220: 218: 
221: 219:     /// Sets a CSS property.
222: 220:     fn set_css_property(
223: 221:         style: &Self::CssStyleDeclaration,
224: 222:         name: &str,
225: 223:         value: &str,
226: 224:     );
227: 225: 
228: 226:     /// Sets the `innerHTML` of a DOM element, without escaping any values.
229: 227:     fn set_inner_html(el: &Self::Element, html: &str);
230: 228: 
231: 229:     /// Returns a cached template element created from the given type.
232: 230:     fn get_template<V>() -> Self::TemplateElement
233: 231:     where
234: 232:         V: ToTemplate + 'static;
235: 233: 
236: 234:     /// Deeply clones a template.
237: 235:     fn clone_template(tpl: &Self::TemplateElement) -> Self::Element;
238: 236: 
239: 237:     /// Creates a single element from a string of HTML.
240: 238:     fn create_element_from_html(html: &str) -> Self::Element;
241: 239: }
242: 240: 
243: 241: /// Attempts to cast from one type to another.
244: 242: ///
245: 243: /// This works in a similar way to `TryFrom`. We implement it as a separate trait
246: 244: /// simply so we don't have to create wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_appers for the `web_sys` types; it can't be
247: 245: /// implemented on them directly because of the orphan rules.
248: 246: pub trait CastFrom<T>
249: 247: where
250: 248:     Self: Sized,
251: 249: {
252: 250:     /// Casts a node from one type to another.
253: 251:     fn cast_from(source: T) -> Option<Self>;
254: 252: }
255: 253: ```
256: 254: ```
257: 255: ```
258: 256: ```
259: 257: ```
260: 258: ```
261: 259: ```
262: 260: ```
263: ```
```
