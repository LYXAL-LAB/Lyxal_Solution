### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_hydration_context\src\hydrate.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_hydration_context\src\hydrate.rs
2: ```rust
3: 1: // #[wasm_bindgen(thread_local)] is deprecated in wasm-bindgen 0.2.96
4: 2: // but the replacement is also only shipped in that version
5: 3: // as a result, we'll just allow deprecated for now
6: 4: #![allow(deprecated)]
7: 5: 
8: 6: use super::{SerializedDataId, SharedContext};
9: 7: use crate::{PinnedFuture, PinnedStream};
10: 8: use core::fmt::Debug;
11: 9: use js_sys::Array;
12: 10: use std::{
13: 11:     fmt::Display,
14: 12:     sync::{
15: 13:         atomic::{AtomicBool, AtomicUsize, Ordering},
16: 14:         LazyLock,
17: 15:     },
18: 16: };
19: 17: use lyx-core-any_error::{Error, ErrorId};
20: 18: use wasm_bindgen::{prelude::wasm_bindgen, JsCast};
21: 19: 
22: 20: #[wasm_bindgen]
23: 21: extern "C" {
24: 22:     #[wasm_bindgen(thread_local)]
25: 23:     static __RESOLVED_RESOURCES: Array;
26: 24: 
27: 25:     #[wasm_bindgen(thread_local)]
28: 26:     static __SERIALIZED_ERRORS: Array;
29: 27: 
30: 28:     #[wasm_bindgen(thread_local)]
31: 29:     static __INCOMPLETE_CHUNKS: Array;
32: 30: }
33: 31: 
34: 32: fn serialized_errors() -> Vec<(SerializedDataId, ErrorId, Error)> {
35: 33:     __SERIALIZED_ERRORS.with(|s| {
36: 34:         s.iter()
37: 35:             .flat_map(|value| {
38: 36:                 value.dyn_ref::<Array>().map(|value| {
39: 37:                     let error_boundary_id =
40: 38:                         value.get(0).as_f64().unwrap() as usize;
41: 39:                     let error_id = value.get(1).as_f64().unwrap() as usize;
42: 40:                     let value = value
43: 41:                         .get(2)
44: 42:                         .as_string()
45: 43:                         .expect("Expected a [number, string] tuple");
46: 44:                     (
47: 45:                         SerializedDataId(error_boundary_id),
48: 46:                         ErrorId::from(error_id),
49: 47:                         Error::from(SerializedError(value)),
50: 48:                     )
51: 49:                 })
52: 50:             })
53: 51:             .collect()
54: 52:     })
55: 53: }
56: 54: 
57: 55: fn incomplete_chunks() -> Vec<SerializedDataId> {
58: 56:     __INCOMPLETE_CHUNKS.with(|i| {
59: 57:         i.iter()
60: 58:             .map(|value| {
61: 59:                 let id = value.as_f64().unwrap() as usize;
62: 60:                 SerializedDataId(id)
63: 61:             })
64: 62:             .collect()
65: 63:     })
66: 64: }
67: 65: 
68: 66: /// An error that has been serialized across the network boundary.
69: 67: #[derive(Debug, Clone)]
70: 68: struct SerializedError(String);
71: 69: 
72: 70: impl Display for SerializedError {
73: 71:     fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
74: 72:         Display::fmt(&self.0, f)
75: 73:     }
76: 74: }
77: 75: 
78: 76: impl std::error::Error for SerializedError {}
79: 77: 
80: 78: #[derive(Default)]
81: 79: /// The shared context that should be used in the browser while hydrating.
82: 80: pub struct HydrateSharedContext {
83: 81:     id: AtomicUsize,
84: 82:     is_hydrating: AtomicBool,
85: 83:     during_hydration: AtomicBool,
86: 84:     errors: LazyLock<Vec<(SerializedDataId, ErrorId, Error)>>,
87: 85:     incomplete: LazyLock<Vec<SerializedDataId>>,
88: 86: }
89: 87: 
90: 88: impl HydrateSharedContext {
91: 89:     /// Creates a new shared context for hydration in the browser.
92: 90:     pub fn new() -> Self {
93: 91:         Self {
94: 92:             id: AtomicUsize::new(0),
95: 93:             is_hydrating: AtomicBool::new(true),
96: 94:             during_hydration: AtomicBool::new(true),
97: 95:             errors: LazyLock::new(serialized_errors),
98: 96:             incomplete: LazyLock::new(incomplete_chunks),
99: 97:         }
100: 98:     }
101: 99: 
102: 100:     /// Creates a new shared context for hydration in the browser.
103: 101:     ///
104: 102:     /// This defaults to a mode in which the lyx-platform-lyx_platform_lyx-platform-lyx_platform_app is not hydrated, but allows you to opt into
105: 103:     /// hydration for certain portions using [`SharedContext::set_is_hydrating`].
106: 104:     pub fn new_islands() -> Self {
107: 105:         Self {
108: 106:             id: AtomicUsize::new(0),
109: 107:             is_hydrating: AtomicBool::new(false),
110: 108:             during_hydration: AtomicBool::new(true),
111: 109:             errors: LazyLock::new(serialized_errors),
112: 110:             incomplete: LazyLock::new(incomplete_chunks),
113: 111:         }
114: 112:     }
115: 113: }
116: 114: 
117: 115: impl Debug for HydrateSharedContext {
118: 116:     fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
119: 117:         f.debug_struct("HydrateSharedContext").finish()
120: 118:     }
121: 119: }
122: 120: 
123: 121: impl SharedContext for HydrateSharedContext {
124: 122:     fn is_browser(&self) -> bool {
125: 123:         true
126: 124:     }
127: 125: 
128: 126:     fn next_id(&self) -> SerializedDataId {
129: 127:         let id = self.id.fetch_add(1, Ordering::Relaxed);
130: 128:         SerializedDataId(id)
131: 129:     }
132: 130: 
133: 131:     fn write_async(&self, _id: SerializedDataId, _fut: PinnedFuture<String>) {}
134: 132: 
135: 133:     fn read_data(&self, id: &SerializedDataId) -> Option<String> {
136: 134:         __RESOLVED_RESOURCES.with(|r| r.get(id.0 as u32).as_string())
137: 135:     }
138: 136: 
139: 137:     fn await_data(&self, _id: &SerializedDataId) -> Option<String> {
140: 138:         todo!()
141: 139:     }
142: 140: 
143: 141:     fn pending_data(&self) -> Option<PinnedStream<String>> {
144: 142:         None
145: 143:     }
146: 144: 
147: 145:     fn during_hydration(&self) -> bool {
148: 146:         self.during_hydration.load(Ordering::Relaxed)
149: 147:     }
150: 148: 
151: 149:     fn hydration_complete(&self) {
152: 150:         self.during_hydration.store(false, Ordering::Relaxed)
153: 151:     }
154: 152: 
155: 153:     fn get_is_hydrating(&self) -> bool {
156: 154:         self.is_hydrating.load(Ordering::Relaxed)
157: 155:     }
158: 156: 
159: 157:     fn set_is_hydrating(&self, is_hydrating: bool) {
160: 158:         self.is_hydrating.store(is_hydrating, Ordering::Relaxed)
161: 159:     }
162: 160: 
163: 161:     fn errors(&self, boundary_id: &SerializedDataId) -> Vec<(ErrorId, Error)> {
164: 162:         self.errors
165: 163:             .iter()
166: 164:             .filter_map(|(boundary, id, error)| {
167: 165:                 if boundary == boundary_id {
168: 166:                     Some((id.clone(), error.clone()))
169: 167:                 } else {
170: 168:                     None
171: 169:                 }
172: 170:             })
173: 171:             .collect()
174: 172:     }
175: 173: 
176: 174:     #[inline(always)]
177: 175:     fn register_error(
178: 176:         &self,
179: 177:         _error_boundary: SerializedDataId,
180: 178:         _error_id: ErrorId,
181: 179:         _error: Error,
182: 180:     ) {
183: 181:     }
184: 182: 
185: 183:     #[inline(always)]
186: 184:     fn seal_errors(&self, _boundary_id: &SerializedDataId) {}
187: 185: 
188: 186:     fn take_errors(&self) -> Vec<(SerializedDataId, ErrorId, Error)> {
189: 187:         self.errors.clone()
190: 188:     }
191: 189: 
192: 190:     #[inline(always)]
193: 191:     fn defer_stream(&self, _wait_for: PinnedFuture<()>) {}
194: 192: 
195: 193:     #[inline(always)]
196: 194:     fn await_deferred(&self) -> Option<PinnedFuture<()>> {
197: 195:         None
198: 196:     }
199: 197: 
200: 198:     #[inline(always)]
201: 199:     fn set_incomplete_chunk(&self, _id: SerializedDataId) {}
202: 200: 
203: 201:     fn get_incomplete_chunk(&self, id: &SerializedDataId) -> bool {
204: 202:         self.incomplete.iter().any(|entry| entry == id)
205: 203:     }
206: 204: }
207: ```
```
