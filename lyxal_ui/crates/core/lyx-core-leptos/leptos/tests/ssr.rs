### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_leptos\tests\ssr.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_leptos\tests\ssr.rs
2: ```rust
3: 1: #[cfg(feature = "ssr")]
4: 2: use lyx-core-lyx_core_lyx-core-lyx_core_leptos::html::HtmlElement;
5: 3: 
6: 4: #[cfg(feature = "ssr")]
7: 5: #[test]
8: 6: fn simple_ssr_test() {
9: 7:     use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
10: 8: 
11: 9:     let (value, set_value) = signal(0);
12: 10:     let rendered: View<HtmlElement<_, _, _>> = view! {
13: 11:         <div>
14: 12:             <button on:click=move |_| set_value.update(|value| *value -= 1)>"-1"</button>
15: 13:             <span>"Value: " {move || value.get().to_string()} "!"</span>
16: 14:             <button on:click=move |_| set_value.update(|value| *value += 1)>"+1"</button>
17: 15:         </div>
18: 16:     };
19: 17: 
20: 18:     assert_eq!(
21: 19:         rendered.to_html(),
22: 20:         "<div><button>-1</button><span>Value: \
23: 21:          <!>0<!>!</span><button>+1</button></div>"
24: 22:     );
25: 23: }
26: 24: 
27: 25: #[cfg(feature = "ssr")]
28: 26: #[test]
29: 27: fn ssr_test_with_components() {
30: 28:     use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
31: 29: 
32: 30:     #[component]
33: 31:     fn Counter(initial_value: i32) -> impl IntoView {
34: 32:         let (value, set_value) = signal(initial_value);
35: 33:         view! {
36: 34:             <div>
37: 35:                 <button on:click=move |_| set_value.update(|value| *value -= 1)>"-1"</button>
38: 36:                 <span>"Value: " {move || value.get().to_string()} "!"</span>
39: 37:                 <button on:click=move |_| set_value.update(|value| *value += 1)>"+1"</button>
40: 38:             </div>
41: 39:         }
42: 40:     }
43: 41: 
44: 42:     let rendered: View<HtmlElement<_, _, _>> = view! {
45: 43:         <div class="counters">
46: 44:             <Counter initial_value=1/>
47: 45:             <Counter initial_value=2/>
48: 46:         </div>
49: 47:     };
50: 48: 
51: 49:     assert_eq!(
52: 50:         rendered.to_html(),
53: 51:         "<div class=\"counters\"><div><button>-1</button><span>Value: \
54: 52:          <!>1<!>!</span><button>+1</button></div><div><button>-1</\
55: 53:          button><span>Value: <!>2<!>!</span><button>+1</button></div></div>"
56: 54:     );
57: 55: }
58: 56: 
59: 57: #[cfg(feature = "ssr")]
60: 58: #[test]
61: 59: fn ssr_test_with_snake_case_components() {
62: 60:     use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
63: 61: 
64: 62:     #[component]
65: 63:     fn snake_case_counter(initial_value: i32) -> impl IntoView {
66: 64:         let (value, set_value) = signal(initial_value);
67: 65:         view! {
68: 66:             <div>
69: 67:                 <button on:click=move |_| set_value.update(|value| *value -= 1)>"-1"</button>
70: 68:                 <span>"Value: " {move || value.get().to_string()} "!"</span>
71: 69:                 <button on:click=move |_| set_value.update(|value| *value += 1)>"+1"</button>
72: 70:             </div>
73: 71:         }
74: 72:     }
75: 73:     let rendered: View<HtmlElement<_, _, _>> = view! {
76: 74:         <div class="counters">
77: 75:             <SnakeCaseCounter initial_value=1/>
78: 76:             <SnakeCaseCounter initial_value=2/>
79: 77:         </div>
80: 78:     };
81: 79: 
82: 80:     assert_eq!(
83: 81:         rendered.to_html(),
84: 82:         "<div class=\"counters\"><div><button>-1</button><span>Value: \
85: 83:          <!>1<!>!</span><button>+1</button></div><div><button>-1</\
86: 84:          button><span>Value: <!>2<!>!</span><button>+1</button></div></div>"
87: 85:     );
88: 86: }
89: 87: 
90: 88: #[cfg(feature = "ssr")]
91: 89: #[test]
92: 90: fn test_classes() {
93: 91:     use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
94: 92: 
95: 93:     let (value, _set_value) = signal(5);
96: 94:     let rendered: View<HtmlElement<_, _, _>> = view! {
97: 95:         <div
98: 96:             class="my big"
99: 97:             class:a=move || { value.get() > 10 }
100: 98:             class:red=true
101: 99:             class:car=move || { value.get() > 1 }
102: 100:         ></div>
103: 101:     };
104: 102: 
105: 103:     assert_eq!(rendered.to_html(), "<div class=\"my big  red car\"></div>");
106: 104: }
107: 105: 
108: 106: #[cfg(feature = "ssr")]
109: 107: #[test]
110: 108: fn test_class_with_class_directive_merge() {
111: 109:     use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
112: 110: 
113: 111:     // class= followed by class: should merge
114: 112:     let rendered: View<HtmlElement<_, _, _>> = view! {
115: 113:         <div class="foo" class:bar=true></div>
116: 114:     };
117: 115: 
118: 116:     assert_eq!(rendered.to_html(), "<div class=\"foo bar\"></div>");
119: 117: }
120: 118: 
121: 119: #[cfg(feature = "ssr")]
122: 120: #[test]
123: 121: fn test_solo_class_directive() {
124: 122:     use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
125: 123: 
126: 124:     // Solo class: directive should work without class attribute
127: 125:     let rendered: View<HtmlElement<_, _, _>> = view! {
128: 126:         <div class:foo=true></div>
129: 127:     };
130: 128: 
131: 129:     assert_eq!(rendered.to_html(), "<div class=\"foo\"></div>");
132: 130: }
133: 131: 
134: 132: #[cfg(feature = "ssr")]
135: 133: #[test]
136: 134: fn test_class_directive_with_static_class() {
137: 135:     use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
138: 136: 
139: 137:     // class:foo comes after class= due to macro sorting
140: 138:     // The class= clears buffer, then class:foo lyx-platform-lyx_platform_lyx-platform-lyx_platform_appends
141: 139:     let rendered: View<HtmlElement<_, _, _>> = view! {
142: 140:         <div class:foo=true class="bar"></div>
143: 141:     };
144: 142: 
145: 143:     // After macro sorting: class="bar" class:foo=true
146: 144:     // Expected: "bar foo"
147: 145:     assert_eq!(rendered.to_html(), "<div class=\"bar foo\"></div>");
148: 146: }
149: 147: 
150: 148: #[cfg(feature = "ssr")]
151: 149: #[test]
152: 150: fn test_global_class_lyx-platform-lyx_platform_lyx-platform-lyx_platform_applied() {
153: 151:     use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
154: 152: 
155: 153:     // Test that a global class is properly lyx-platform-lyx_platform_lyx-platform-lyx_platform_applied
156: 154:     let rendered: View<HtmlElement<_, _, _>> = view! { class="global",
157: 155:         <div></div>
158: 156:     };
159: 157: 
160: 158:     assert_eq!(rendered.to_html(), "<div class=\"global\"></div>");
161: 159: }
162: 160: 
163: 161: #[cfg(feature = "ssr")]
164: 162: #[test]
165: 163: fn test_multiple_class_attributes_overwrite() {
166: 164:     use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
167: 165: 
168: 166:     // When multiple class attributes are lyx-platform-lyx_platform_lyx-platform-lyx_platform_applied, the last one should win (browser behavior)
169: 167:     // This simulates what hlyx-platform-lyx_platform_lyx-platform-lyx_platform_appens when attributes are combined programmatically
170: 168:     let el = lyx-core-lyx_core_lyx-core-lyx_core_leptos::html::div().class("first").class("second");
171: 169: 
172: 170:     let html = el.to_html();
173: 171: 
174: 172:     // The second class attribute should overwrite the first
175: 173:     assert_eq!(html, "<div class=\"second\"></div>");
176: 174: }
177: 175: 
178: 176: #[cfg(feature = "ssr")]
179: 177: #[test]
180: 178: fn ssr_with_styles() {
181: 179:     use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
182: 180: 
183: 181:     let (_, set_value) = signal(0);
184: 182:     let styles = "myclass";
185: 183:     let rendered: View<HtmlElement<_, _, _>> = view! { class=styles,
186: 184:         <div>
187: 185:             <button class="btn" on:click=move |_| set_value.update(|value| *value -= 1)>
188: 186:                 "-1"
189: 187:             </button>
190: 188:         </div>
191: 189:     };
192: 190: 
193: 191:     assert_eq!(
194: 192:         rendered.to_html(),
195: 193:         "<div class=\"myclass\"><button class=\"btn \
196: 194:          myclass\">-1</button></div>"
197: 195:     );
198: 196: }
199: 197: 
200: 198: #[cfg(feature = "ssr")]
201: 199: #[test]
202: 200: fn ssr_option() {
203: 201:     use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
204: 202: 
205: 203:     let (_, _) = signal(0);
206: 204:     let rendered: View<HtmlElement<_, _, _>> = view! { <option></option> };
207: 205: 
208: 206:     assert_eq!(rendered.to_html(), "<option></option>");
209: 207: }
210: ```
```
