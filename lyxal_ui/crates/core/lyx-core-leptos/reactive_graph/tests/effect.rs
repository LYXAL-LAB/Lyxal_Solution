### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_reactive_graph\tests\effect.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\tests\effect.rs
2: ```rust
3: 1: #[cfg(feature = "effects")]
4: 2: pub mod imports {
5: 3:     pub use lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::Executor;
6: 4:     pub use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::{
7: 5:         effect::{Effect, RenderEffect},
8: 6:         owner::Owner,
9: 7:         prelude::*,
10: 8:         signal::RwSignal,
11: 9:     };
12: 10:     pub use std::{
13: 11:         mem,
14: 12:         sync::{Arc, RwLock},
15: 13:     };
16: 14:     pub use tokio::task;
17: 15: }
18: 16: 
19: 17: #[cfg(feature = "effects")]
20: 18: #[tokio::test]
21: 19: async fn render_effect_runs() {
22: 20:     use imports::*;
23: 21: 
24: 22:     _ = Executor::init_tokio();
25: 23:     let owner = Owner::new();
26: 24:     owner.set();
27: 25:     task::LocalSet::new()
28: 26:         .run_until(async {
29: 27:             let a = RwSignal::new(-1);
30: 28: 
31: 29:             // simulate an arbitrary side effect
32: 30:             let b = Arc::new(RwLock::new(String::new()));
33: 31: 
34: 32:             // we forget it so it continues running
35: 33:             // if it's dropped, it will stop listening
36: 34:             mem::forget(RenderEffect::new({
37: 35:                 let b = b.clone();
38: 36:                 move |_| {
39: 37:                     let formatted = format!("Value is {}", a.get());
40: 38:                     *b.write().unwrap() = formatted;
41: 39:                 }
42: 40:             }));
43: 41: 
44: 42:             Executor::tick().await;
45: 43:             assert_eq!(b.read().unwrap().as_str(), "Value is -1");
46: 44: 
47: 45:             println!("setting to 1");
48: 46:             a.set(1);
49: 47: 
50: 48:             Executor::tick().await;
51: 49:             assert_eq!(b.read().unwrap().as_str(), "Value is 1");
52: 50:         })
53: 51:         .await;
54: 52: }
55: 53: 
56: 54: #[cfg(feature = "effects")]
57: 55: #[tokio::test]
58: 56: async fn effect_runs() {
59: 57:     use imports::*;
60: 58: 
61: 59:     _ = Executor::init_tokio();
62: 60:     let owner = Owner::new();
63: 61:     owner.set();
64: 62: 
65: 63:     task::LocalSet::new()
66: 64:         .run_until(async {
67: 65:             let a = RwSignal::new(-1);
68: 66: 
69: 67:             // simulate an arbitrary side effect
70: 68:             let b = Arc::new(RwLock::new(String::new()));
71: 69: 
72: 70:             Effect::new({
73: 71:                 let b = b.clone();
74: 72:                 move || {
75: 73:                     let formatted = format!("Value is {}", a.get());
76: 74:                     *b.write().unwrap() = formatted;
77: 75:                 }
78: 76:             });
79: 77: 
80: 78:             Executor::tick().await;
81: 79:             assert_eq!(b.read().unwrap().as_str(), "Value is -1");
82: 80: 
83: 81:             println!("setting to 1");
84: 82:             a.set(1);
85: 83: 
86: 84:             Executor::tick().await;
87: 85:             assert_eq!(b.read().unwrap().as_str(), "Value is 1");
88: 86:         })
89: 87:         .await
90: 88: }
91: 89: 
92: 90: #[cfg(feature = "effects")]
93: 91: #[tokio::test]
94: 92: async fn dynamic_dependencies() {
95: 93:     use imports::*;
96: 94: 
97: 95:     _ = Executor::init_tokio();
98: 96:     let owner = Owner::new();
99: 97:     owner.set();
100: 98: 
101: 99:     task::LocalSet::new()
102: 100:         .run_until(async {
103: 101:             let first = RwSignal::new("Greg");
104: 102:             let last = RwSignal::new("Johnston");
105: 103:             let use_last = RwSignal::new(true);
106: 104: 
107: 105:             let combined_count = Arc::new(RwLock::new(0));
108: 106: 
109: 107:             mem::forget(RenderEffect::new({
110: 108:                 let combined_count = Arc::clone(&combined_count);
111: 109:                 move |_| {
112: 110:                     *combined_count.write().unwrap() += 1;
113: 111:                     if use_last.get() {
114: 112:                         println!("{} {}", first.get(), last.get());
115: 113:                     } else {
116: 114:                         println!("{}", first.get());
117: 115:                     }
118: 116:                 }
119: 117:             }));
120: 118: 
121: 119:             Executor::tick().await;
122: 120:             assert_eq!(*combined_count.read().unwrap(), 1);
123: 121: 
124: 122:             println!("\nsetting `first` to Bob");
125: 123:             first.set("Bob");
126: 124:             Executor::tick().await;
127: 125:             assert_eq!(*combined_count.read().unwrap(), 2);
128: 126: 
129: 127:             println!("\nsetting `last` to Bob");
130: 128:             last.set("Thompson");
131: 129:             Executor::tick().await;
132: 130:             assert_eq!(*combined_count.read().unwrap(), 3);
133: 131: 
134: 132:             println!("\nsetting `use_last` to false");
135: 133:             use_last.set(false);
136: 134:             Executor::tick().await;
137: 135:             assert_eq!(*combined_count.read().unwrap(), 4);
138: 136: 
139: 137:             println!("\nsetting `last` to Jones");
140: 138:             last.set("Jones");
141: 139:             Executor::tick().await;
142: 140:             assert_eq!(*combined_count.read().unwrap(), 4);
143: 141: 
144: 142:             println!("\nsetting `last` to Jones");
145: 143:             last.set("Smith");
146: 144:             Executor::tick().await;
147: 145:             assert_eq!(*combined_count.read().unwrap(), 4);
148: 146: 
149: 147:             println!("\nsetting `last` to Stevens");
150: 148:             last.set("Stevens");
151: 149:             Executor::tick().await;
152: 150:             assert_eq!(*combined_count.read().unwrap(), 4);
153: 151: 
154: 152:             println!("\nsetting `use_last` to true");
155: 153:             use_last.set(true);
156: 154:             Executor::tick().await;
157: 155:             assert_eq!(*combined_count.read().unwrap(), 5);
158: 156:         })
159: 157:         .await
160: 158: }
161: 159: 
162: 160: #[cfg(feature = "effects")]
163: 161: #[tokio::test]
164: 162: async fn recursive_effect_runs_recursively() {
165: 163:     use imports::*;
166: 164: 
167: 165:     _ = Executor::init_tokio();
168: 166:     let owner = Owner::new();
169: 167:     owner.set();
170: 168:     task::LocalSet::new()
171: 169:         .run_until(async {
172: 170:             let s = RwSignal::new(0);
173: 171: 
174: 172:             let logged_values = Arc::new(RwLock::new(Vec::new()));
175: 173: 
176: 174:             mem::forget(RenderEffect::new({
177: 175:                 let logged_values = Arc::clone(&logged_values);
178: 176:                 move |_| {
179: 177:                     let a = s.get();
180: 178:                     println!("a = {a}");
181: 179:                     logged_values.write().unwrap().push(a);
182: 180:                     if a == 0 {
183: 181:                         return;
184: 182:                     }
185: 183:                     s.set(0);
186: 184:                 }
187: 185:             }));
188: 186: 
189: 187:             s.set(1);
190: 188:             Executor::tick().await;
191: 189:             s.set(2);
192: 190:             Executor::tick().await;
193: 191:             s.set(3);
194: 192:             Executor::tick().await;
195: 193: 
196: 194:             assert_eq!(0, s.get_untracked());
197: 195:             assert_eq!(&*logged_values.read().unwrap(), &[0, 1, 0, 2, 0, 3, 0]);
198: 196:         })
199: 197:         .await;
200: 198: }
201: 199: 
202: 200: #[cfg(feature = "effects")]
203: 201: #[tokio::test]
204: 202: async fn paused_effect_pauses() {
205: 203:     use imports::*;
206: 204:     use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::owner::StoredValue;
207: 205: 
208: 206:     _ = Executor::init_tokio();
209: 207:     let owner = Owner::new();
210: 208:     owner.set();
211: 209: 
212: 210:     task::LocalSet::new()
213: 211:         .run_until(async {
214: 212:             let a = RwSignal::new(-1);
215: 213: 
216: 214:             // simulate an arbitrary side effect
217: 215:             let runs = StoredValue::new(0);
218: 216: 
219: 217:             let owner = StoredValue::new(None);
220: 218: 
221: 219:             Effect::new({
222: 220:                 move || {
223: 221:                     *owner.write_value() = Owner::current();
224: 222: 
225: 223:                     let _ = a.get();
226: 224:                     *runs.write_value() += 1;
227: 225:                 }
228: 226:             });
229: 227: 
230: 228:             Executor::tick().await;
231: 229:             assert_eq!(runs.get_value(), 1);
232: 230: 
233: 231:             println!("setting to 1");
234: 232:             a.set(1);
235: 233: 
236: 234:             Executor::tick().await;
237: 235:             assert_eq!(runs.get_value(), 2);
238: 236: 
239: 237:             println!("pausing");
240: 238:             owner.get_value().unwrap().pause();
241: 239: 
242: 240:             println!("setting to 2");
243: 241:             a.set(2);
244: 242: 
245: 243:             Executor::tick().await;
246: 244:             assert_eq!(runs.get_value(), 2);
247: 245: 
248: 246:             println!("resuming");
249: 247:             owner.get_value().unwrap().resume();
250: 248: 
251: 249:             println!("setting to 3");
252: 250:             a.set(3);
253: 251: 
254: 252:             Executor::tick().await;
255: 253:             println!("checking value");
256: 254:             assert_eq!(runs.get_value(), 3);
257: 255:         })
258: 256:         .await
259: 257: }
260: ```
```
