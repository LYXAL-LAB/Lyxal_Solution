### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_tachys\src\mathml\mod.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\mathml\mod.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\mathml\mod.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\mathml\mod.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\mathml\mod.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\mathml\mod.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\mathml\mod.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\mathml\mod.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\mathml\mod.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\mathml\mod.rs
18: 16: ```rust
19: 17: use crate::{
20: 18:     html::{
21: 19:         attribute::{Attr, Attribute, AttributeValue, NextAttribute},
22: 20:         element::{ElementType, ElementWithChildren, HtmlElement},
23: 21:     },
24: 22:     view::Render,
25: 23: };
26: 24: use std::fmt::Debug;
27: 25: 
28: 26: macro_rules! mathml_global {
29: 27: 	($tag:ty, $attr:ty) => {
30: 28: 		paste::paste! {
31: 29:             /// A MathML attribute.
32: 30: 			pub fn $attr<V>(self, value: V) -> HtmlElement <
33: 31: 				[<$tag:camel>],
34: 32: 				<At as NextAttribute>::Output<Attr<$crate::html::attribute::[<$attr:camel>], V>>,
35: 33: 				Ch
36: 34: 			>
37: 35: 			where
38: 36: 				V: AttributeValue,
39: 37: 				At: NextAttribute,
40: 38: 				<At as NextAttribute>::Output<Attr<$crate::html::attribute::[<$attr:camel>], V>>: Attribute,
41: 39: 			{
42: 40: 				let HtmlElement {
43: 41:                     #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
44: 42:                     defined_at,
45: 43:                     tag,
46: 44:                     children,
47: 45:                     attributes
48: 46:                 } = self;
49: 47: 				HtmlElement {
50: 48:                     #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
51: 49:                     defined_at,
52: 50: 					tag,
53: 51: 					children,
54: 52: 					attributes: attributes.add_any_attr($crate::html::attribute::$attr(value)),
55: 53: 				}
56: 54: 			}
57: 55: 		}
58: 56: 	}
59: 57: }
60: 58: 
61: 59: macro_rules! mathml_elements {
62: 60: 	($($tag:ident  [$($attr:ty),*]),* $(,)?) => {
63: 61:         paste::paste! {
64: 62:             $(
65: 63:                 // `tag()` function
66: 64:                 /// A MathML element.
67: 65:                 #[track_caller]
68: 66:                 pub fn $tag() -> HtmlElement<[<$tag:camel>], (), ()>
69: 67:                 where
70: 68: 
71: 69:                 {
72: 70:                     HtmlElement {
73: 71:                         #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
74: 72:                         defined_at: std::panic::Location::caller(),
75: 73:                         tag: [<$tag:camel>],
76: 74:                         attributes: (),
77: 75:                         children: (),
78: 76:                     }
79: 77:                 }
80: 78: 
81: 79:                 /// A MathML element.
82: 80:                 #[derive(Debug, Copy, Clone, PartialEq, Eq)]
83: 81:                 pub struct [<$tag:camel>];
84: 82: 
85: 83: 				impl<At, Ch> HtmlElement<[<$tag:camel>], At, Ch>
86: 84: 				where
87: 85: 					At: Attribute,
88: 86: 					Ch: Render,
89: 87: 
90: 88: 				{
91: 89: 					mathml_global!($tag, displaystyle);
92: 90: 					mathml_global!($tag, href);
93: 91: 					mathml_global!($tag, id);
94: 92: 					mathml_global!($tag, mathbackground);
95: 93: 					mathml_global!($tag, mathcolor);
96: 94: 					mathml_global!($tag, mathsize);
97: 95: 					mathml_global!($tag, mathvariant);
98: 96: 					mathml_global!($tag, scriptlevel);
99: 97: 
100: 98: 					$(
101: 99:                         /// A MathML attribute.
102: 100:                         pub fn $attr<V>(self, value: V) -> HtmlElement <
103: 101:                             [<$tag:camel>],
104: 102:                             <At as NextAttribute>::Output<Attr<$crate::html::attribute::[<$attr:camel>], V>>,
105: 103:                             Ch
106: 104:                         >
107: 105:                         where
108: 106:                             V: AttributeValue,
109: 107:                             At: NextAttribute,
110: 108:                             <At as NextAttribute>::Output<Attr<$crate::html::attribute::[<$attr:camel>], V>>: Attribute,
111: 109:                         {
112: 110:                             let HtmlElement {
113: 111:                                 #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
114: 112:                                 defined_at,
115: 113:                                 tag,
116: 114:                                 children,
117: 115:                                 attributes
118: 116:                             } = self;
119: 117:                             HtmlElement {
120: 118:                                 #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
121: 119:                                 defined_at,
122: 120:                                 tag,
123: 121:                                 children,
124: 122:                                 attributes: attributes.add_any_attr($crate::html::attribute::$attr(value)),
125: 123:                             }
126: 124:                         }
127: 125: 					)*
128: 126: 				}
129: 127: 
130: 128:                 impl ElementType for [<$tag:camel>] {
131: 129:                     type Output = web_sys::Element;
132: 130: 
133: 131:                     const TAG: &'static str = stringify!($tag);
134: 132:                     const SELF_CLOSING: bool = false;
135: 133:                     const ESCAPE_CHILDREN: bool = true;
136: 134:                     const NAMESPACE: Option<&'static str> = Some("http://www.w3.org/1998/Math/MathML");
137: 135: 
138: 136:                     #[inline(always)]
139: 137:                     fn tag(&self) -> &str {
140: 138:                         Self::TAG
141: 139:                     }
142: 140:                 }
143: 141: 
144: 142:                 impl ElementWithChildren for [<$tag:camel>] {}
145: 143:             )*
146: 144: 		}
147: 145:     }
148: 146: }
149: 147: 
150: 148: mathml_elements![
151: 149:     math [display, xmlns],
152: 150:     mi [],
153: 151:     mn [],
154: 152:     mo [
155: 153:         accent, fence, lspace, maxsize, minsize, movablelimits,
156: 154:         rspace, separator, stretchy, symmetric, form
157: 155:     ],
158: 156:     ms [],
159: 157:     mspace [height, width],
160: 158:     mtext [],
161: 159:     menclose [notation],
162: 160:     merror [],
163: 161:     mfenced [],
164: 162:     mfrac [linethickness],
165: 163:     mpadded [depth, height, voffset, width],
166: 164:     mphantom [],
167: 165:     mroot [],
168: 166:     mrow [],
169: 167:     msqrt [],
170: 168:     mstyle [],
171: 169:     mmultiscripts [],
172: 170:     mover [accent],
173: 171:     mprescripts [],
174: 172:     msub [],
175: 173:     msubsup [],
176: 174:     msup [],
177: 175:     munder [accentunder],
178: 176:     munderover [accent, accentunder],
179: 177:     mtable [
180: 178:         align, columnalign, columnlines, columnspacing, frame,
181: 179:         framespacing, rowalign, rowlines, rowspacing, width
182: 180:     ],
183: 181:     mtd [columnalign, columnspan, rowalign, rowspan],
184: 182:     mtr [columnalign, rowalign],
185: 183:     maction [],
186: 184:     annotation [],
187: 185:     semantics [],
188: 186: ];
189: 187: ```
190: 188: ```
191: 189: ```
192: 190: ```
193: 191: ```
194: 192: ```
195: 193: ```
196: 194: ```
197: ```
```
