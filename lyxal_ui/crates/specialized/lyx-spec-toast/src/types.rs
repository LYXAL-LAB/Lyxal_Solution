### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx-spec-toast\src\types.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx-spec-toast\src\types.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\types.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\types.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\types.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\types.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\types.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\types.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\types.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\types.rs
18: 16: ```rust
19: 17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\types.rs
20: 18: ```rust
21: 19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\types.rs
22: 20: ```rust
23: 21: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\types.rs
24: 22: ```rust
25: 23: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\types.rs
26: 24: ```rust
27: 25: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\types.rs
28: 26: ```rust
29: 27: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\types.rs
30: 28: ```rust
31: 29: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\types.rs
32: 30: ```rust
33: 31: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\types.rs
34: 32: ```rust
35: 33: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\types.rs
36: 34: ```rust
37: 35: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\types.rs
38: 36: ```rust
39: 37: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\types.rs
40: 38: ```rust
41: 39: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\types.rs
42: 40: ```rust
43: 41: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\types.rs
44: 42: ```rust
45: 43: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\types.rs
46: 44: ```rust
47: 45: use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
48: 46: use std::time::Duration;
49: 47: use wasm_bindgen::JsValue;
50: 48: 
51: 49: use crate::ToastId;
52: 50: 
53: 51: #[derive(Clone, Debug)]
54: 52: pub struct ToastOptions {
55: 53:     pub dismissible: bool,
56: 54:     /// Duration until the toast should be dismissed
57: 55:     pub duration: Option<Duration>,
58: 56:     /// The position of the toast
59: 57:     pub position: Option<ToasterPosition>,
60: 58: }
61: 59: 
62: 60: impl Default for ToastOptions {
63: 61:     fn default() -> Self {
64: 62:         ToastOptions {
65: 63:             dismissible: true,
66: 64:             duration: None,
67: 65:             position: None,
68: 66:         }
69: 67:     }
70: 68: }
71: 69: 
72: 70: #[derive(Clone)]
73: 71: pub struct Toast {
74: 72:     pub id: ToastId,
75: 73:     pub view: ViewFn,
76: 74:     pub options: ToastOptions,
77: 75: }
78: 76: 
79: 77: #[derive(Clone, Copy)]
80: 78: pub struct Toasts {
81: 79:     pub(crate) toasts: ReadSignal<Vec<Toast>>,
82: 80:     pub(crate) set_toasts: WriteSignal<Vec<Toast>>,
83: 81: }
84: 82: 
85: 83: impl Toasts {
86: 84:     /// Create a new toasts
87: 85:     pub fn new() -> Self {
88: 86:         let (toasts, set_toasts) = signal(Vec::new());
89: 87:         Self { toasts, set_toasts }
90: 88:     }
91: 89: 
92: 90:     /// Create a new toast
93: 91:     pub fn toast(
94: 92:         &self,
95: 93:         toast: impl Into<ViewFn>,
96: 94:         id: Option<ToastId>,
97: 95:         options: Option<ToastOptions>,
98: 96:     ) {
99: 97:         let id = id.unwrap_or_else(ToastId::new);
100: 98:         let toast = Toast {
101: 99:             id,
102: 100:             view: toast.into(),
103: 101:             options: options.unwrap_or_default(),
104: 102:         };
105: 103:         let mut toasts = self.set_toasts.write();
106: 104:         toasts.insert(0, toast);
107: 105:     }
108: 106: 
109: 107:     pub fn dismiss(&self, toast_id: &ToastId) {
110: 108:         self.set_toasts.update(|toasts| {
111: 109:             if let Some(index) = toasts.iter().position(|t| &t.id == toast_id) {
112: 110:                 toasts.remove(index);
113: 111:             };
114: 112:         });
115: 113:     }
116: 114: }
117: 115: 
118: 116: impl Default for Toasts {
119: 117:     fn default() -> Self {
120: 118:         Self::new()
121: 119:     }
122: 120: }
123: 121: 
124: 122: /// Possible positions for the toasts
125: 123: #[derive(Clone, Copy, PartialEq, Eq, Hash, Debug)]
126: 124: pub enum ToasterPosition {
127: 125:     TopLeft,
128: 126:     TopCenter,
129: 127:     TopRight,
130: 128:     BottomRight,
131: 129:     BottomCenter,
132: 130:     BottomLeft,
133: 131: }
134: 132: 
135: 133: impl ToasterPosition {
136: 134:     pub fn x(&self) -> String {
137: 135:         match self {
138: 136:             ToasterPosition::TopLeft | ToasterPosition::BottomLeft => "left".to_string(),
139: 137:             ToasterPosition::TopCenter | ToasterPosition::BottomCenter => "center".to_string(),
140: 138:             ToasterPosition::TopRight | ToasterPosition::BottomRight => "right".to_string(),
141: 139:         }
142: 140:     }
143: 141: 
144: 142:     pub fn y(&self) -> String {
145: 143:         match self {
146: 144:             ToasterPosition::TopLeft | ToasterPosition::TopCenter | ToasterPosition::TopRight => {
147: 145:                 "top".to_string()
148: 146:             }
149: 147:             ToasterPosition::BottomRight
150: 148:             | ToasterPosition::BottomCenter
151: 149:             | ToasterPosition::BottomLeft => "bottom".to_string(),
152: 150:         }
153: 151:     }
154: 152: }
155: 153: 
156: 154: /// Call this to dismiss the toast with the given id
157: 155: pub fn dismiss_toast(toast_id: &ToastId) {
158: 156:     let message = format!("LEPTOS_TOASTER:{}", toast_id.to_decodable_string());
159: 157:     let _ = window().post_message(&JsValue::from_str(&message), "*");
160: 158: }
161: 159: 
162: 160: pub fn decode_message(message: String) -> Option<ToastId> {
163: 161:     if let Some(toast_id) = message.strip_prefix("LEPTOS_TOASTER:") {
164: 162:         return Some(ToastId::decode_string(toast_id));
165: 163:     }
166: 164: 
167: 165:     None
168: 166: }
169: 167: 
170: 168: pub struct HeightT {
171: 169:     pub toast_id: ToastId,
172: 170:     pub height: f64,
173: 171: }
174: 172: ```
175: 173: ```
176: 174: ```
177: 175: ```
178: 176: ```
179: 177: ```
180: 178: ```
181: 179: ```
182: 180: ```
183: 181: ```
184: 182: ```
185: 183: ```
186: 184: ```
187: 185: ```
188: 186: ```
189: 187: ```
190: 188: ```
191: 189: ```
192: 190: ```
193: 191: ```
194: 192: ```
195: 193: ```
196: ```
```
