1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx-spec-toast\src\toast.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\toast.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\toast.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\toast.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\toast.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\toast.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\toast.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\toast.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\toast.rs
18: 16: ```rust
19: 17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\toast.rs
20: 18: ```rust
21: 19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\toast.rs
22: 20: ```rust
23: 21: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\toast.rs
24: 22: ```rust
25: 23: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\toast.rs
26: 24: ```rust
27: 25: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\toast.rs
28: 26: ```rust
29: 27: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\toast.rs
30: 28: ```rust
31: 29: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\toast.rs
32: 30: ```rust
33: 31: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\toast.rs
34: 32: ```rust
35: 33: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\toast.rs
36: 34: ```rust
37: 35: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\toast.rs
38: 36: ```rust
39: 37: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\toast.rs
40: 38: ```rust
41: 39: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\toast.rs
42: 40: ```rust
43: 41: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\toast.rs
44: 42: ```rust
45: 43: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\toast.rs
46: 44: ```rust
47: 45: use crate::{mount_style::mount_style, types::dismiss_toast, ToastId};
48: 46: use lyx-core-lyx_core_lyx-core-lyx_core_leptos::{either::EitherOf5, prelude::*};
49: 47: 
50: 48: #[component]
51: 49: fn SuccessIcon() -> impl IntoView {
52: 50:     view! {
53: 51:         <svg
54: 52:             xmlns="http://www.w3.org/2000/svg"
55: 53:             viewBox="0 0 20 20"
56: 54:             fill="currentColor"
57: 55:             height="20"
58: 56:             width="20"
59: 57:         >
60: 58:             <path
61: 59:                 fill-rule="evenodd"
62: 60:                 d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.857-9.809a.75.75 0 00-1.214-.882l-3.483 4.79-1.88-1.88a.75.75 0 10-1.06 1.061l2.5 2.5a.75.75 0 001.137-.089l4-5.5z"
63: 61:                 clip-rule="evenodd"
64: 62:             ></path>
65: 63:         </svg>
66: 64:     }
67: 65: }
68: 66: 
69: 67: #[component]
70: 68: fn WarningIcon() -> impl IntoView {
71: 69:     view! {
72: 70:         <svg
73: 71:             xmlns="http://www.w3.org/2000/svg"
74: 72:             viewBox="0 0 24 24"
75: 73:             fill="currentColor"
76: 74:             height="20"
77: 75:             width="20"
78: 76:         >
79: 77:             <path
80: 78:                 fill-rule="evenodd"
81: 79:                 d="M9.401 3.003c1.155-2 4.043-2 5.197 0l7.355 12.748c1.154 2-.29 4.5-2.599 4.5H4.645c-2.309 0-3.752-2.5-2.598-4.5L9.4 3.003zM12 8.25a.75.75 0 01.75.75v3.75a.75.75 0 01-1.5 0V9a.75.75 0 01.75-.75zm0 8.25a.75.75 0 100-1.5.75.75 0 000 1.5z"
82: 80:                 clip-rule="evenodd"
83: 81:             ></path>
84: 82:         </svg>
85: 83:     }
86: 84: }
87: 85: 
88: 86: #[component]
89: 87: fn InfoIcon() -> impl IntoView {
90: 88:     view! {
91: 89:         <svg
92: 90:             xmlns="http://www.w3.org/2000/svg"
93: 91:             viewBox="0 0 20 20"
94: 92:             fill="currentColor"
95: 93:             height="20"
96: 94:             width="20"
97: 95:         >
98: 96:             <path
99: 97:                 fill-rule="evenodd"
100: 98:                 d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a.75.75 0 000 1.5h.253a.25.25 0 01.244.304l-.459 2.066A1.75 1.75 0 0010.747 15H11a.75.75 0 000-1.5h-.253a.25.25 0 01-.244-.304l.459-2.066A1.75 1.75 0 009.253 9H9z"
101: 99:                 clip-rule="evenodd"
102: 100:             ></path>
103: 101:         </svg>
104: 102:     }
105: 103: }
106: 104: 
107: 105: #[component]
108: 106: fn ErrorIcon() -> impl IntoView {
109: 107:     view! {
110: 108:         <svg
111: 109:             xmlns="http://www.w3.org/2000/svg"
112: 110:             viewBox="0 0 20 20"
113: 111:             fill="currentColor"
114: 112:             height="20"
115: 113:             width="20"
116: 114:         >
117: 115:             <path
118: 116:                 fill-rule="evenodd"
119: 117:                 d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-8-5a.75.75 0 01.75.75v4.5a.75.75 0 01-1.5 0v-4.5A.75.75 0 0110 5zm0 10a1 1 0 100-2 1 1 0 000 2z"
120: 118:                 clip-rule="evenodd"
121: 119:             ></path>
122: 120:         </svg>
123: 121:     }
124: 122: }
125: 123: 
126: 124: #[derive(PartialEq, Clone, Copy)]
127: 125: pub enum ToastVariant {
128: 126:     Normal,
129: 127:     Success,
130: 128:     Info,
131: 129:     Warning,
132: 130:     Error,
133: 131: }
134: 132: 
135: 133: impl ToString for ToastVariant {
136: 134:     fn to_string(&self) -> String {
137: 135:         match self {
138: 136:             ToastVariant::Normal => "normal".to_string(),
139: 137:             ToastVariant::Success => "success".to_string(),
140: 138:             ToastVariant::Info => "info".to_string(),
141: 139:             ToastVariant::Warning => "warning".to_string(),
142: 140:             ToastVariant::Error => "error".to_string(),
143: 141:         }
144: 142:     }
145: 143: }
146: 144: 
147: 145: #[derive(Clone)]
148: 146: pub enum Theme {
149: 147:     Light,
150: 148:     Dark,
151: 149: }
152: 150: 
153: 151: impl std::fmt::Display for Theme {
154: 152:     fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
155: 153:         match self {
156: 154:             Theme::Light => write!(f, "light"),
157: 155:             Theme::Dark => write!(f, "dark"),
158: 156:         }
159: 157:     }
160: 158: }
161: 159: 
162: 160: /// Built in toast component to use with the toast() function if you don't want to roll your own
163: 161: #[component]
164: 162: pub fn Toast(
165: 163:     #[prop(default = ToastVariant::Normal)] variant: ToastVariant,
166: 164:     #[prop(into)] title: ViewFn,
167: 165:     #[prop(default = None,into)] description: Option<ViewFn>,
168: 166:     toast_id: ToastId,
169: 167:     #[prop(default = true)] close_button: bool,
170: 168:     #[prop(default = Theme::Light)] theme: Theme,
171: 169:     #[prop(default = false)] invert: bool,
172: 170:     #[prop(default = false)] rich_colors: bool,
173: 171: ) -> impl IntoView {
174: 172:     mount_style(
175: 173:         "lyx-core-lyx_core_lyx-core-lyx_core_leptos-toaster-builtin_toast",
176: 174:         include_str!("./builtin_toast.css"),
177: 175:     );
178: 176: 
179: 177:     view! {
180: 178:         <div
181: 179:             data-type=variant.to_string()
182: 180:             data-theme=theme.to_string()
183: 181:             data-invert=invert.to_string()
184: 182:             data-rich-colors=rich_colors.to_string()
185: 183:             class="lyx-core-lyx_core_lyx-core-lyx_core_leptos-toast"
186: 184:         >
187: 185:             <Show when=move || close_button>
188: 186:                 <button
189: 187:                     on:click=move |_| {
190: 188:                         dismiss_toast(&toast_id);
191: 189:                     }
192: 190: 
193: 191:                     class="lyx-core-lyx_core_lyx-core-lyx_core_leptos-toast-close-button"
194: 192:                 >
195: 193:                     <svg
196: 194:                         xmlns="http://www.w3.org/2000/svg"
197: 195:                         width="12"
198: 196:                         height="12"
199: 197:                         viewBox="0 0 24 24"
200: 198:                         fill="none"
201: 199:                         stroke="currentColor"
202: 200:                         stroke-width="1.5"
203: 201:                         stroke-linecap="round"
204: 202:                         stroke-linejoin="round"
205: 203:                     >
206: 204:                         <line x1="18" y1="6" x2="6" y2="18"></line>
207: 205:                         <line x1="6" y1="6" x2="18" y2="18"></line>
208: 206:                     </svg>
209: 207:                 </button>
210: 208:             </Show>
211: 209: 
212: 210:             <Show when=move || variant != ToastVariant::Normal>
213: 211:                 <div class="lyx-core-lyx_core_lyx-core-lyx_core_leptos-toast-icon">
214: 212:                     {match variant {
215: 213:                         ToastVariant::Normal => EitherOf5::A(view! {}),
216: 214:                         ToastVariant::Success => EitherOf5::B(view! { <SuccessIcon/> }),
217: 215:                         ToastVariant::Info => EitherOf5::C(view! { <InfoIcon/> }),
218: 216:                         ToastVariant::Warning => EitherOf5::D(view! { <WarningIcon/> }),
219: 217:                         ToastVariant::Error => EitherOf5::E(view! { <ErrorIcon/> }),
220: 218:                     }}
221: 219: 
222: 220:                 </div>
223: 221:             </Show>
224: 222: 
225: 223:             <div>
226: 224:                 <div class="lyx-core-lyx_core_lyx-core-lyx_core_leptos-toast-title">{title.run()}</div>
227: 225:                 <div class="lyx-core-lyx_core_lyx-core-lyx_core_leptos-toast-description">{description.map(|v| v.run())}</div>
228: 226:             </div>
229: 227:         </div>
230: 228:     }
231: 229: }
232: 230: ```
233: 231: ```
234: 232: ```
235: 233: ```
236: 234: ```
237: 235: ```
238: 236: ```
239: 237: ```
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

