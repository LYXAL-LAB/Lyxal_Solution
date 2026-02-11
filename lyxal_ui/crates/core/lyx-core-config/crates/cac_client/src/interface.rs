### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_cac_lyx-core-lyx_core_client\src\interface.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_cac_lyx-core-lyx_core_lyx-core-lyx_core_client\src\interface.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_cac_lyx-core-lyx_core_lyx-core-lyx_core_client\src\interface.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_cac_lyx-core-lyx_core_lyx-core-lyx_core_client\src\interface.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_cac_lyx-core-lyx_core_lyx-core-lyx_core_client\src\interface.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_cac_lyx-core-lyx_core_lyx-core-lyx_core_client\src\interface.rs
10: 8: ```rust
11: 9: // Primary interface so CAC lyx-core-lyx_core_lyx-core-lyx_core_client can work with other languages like haskell
12: 10: use std::{
13: 11:     ffi::{c_char, c_ulong, CStr},
14: 12:     sync::Arc,
15: 13: };
16: 14: 
17: 15: use crate::{utils::core::MapError, Client, MergeStrategy, CLIENT_FACTORY};
18: 16: use once_cell::sync::Lazy;
19: 17: use serde_json::{Map, Value};
20: 18: use std::{
21: 19:     cell::RefCell,
22: 20:     ffi::{c_int, CString},
23: 21:     time::Duration,
24: 22: };
25: 23: use tokio::runtime::Runtime;
26: 24: 
27: 25: thread_local! {
28: 26:     static LAST_ERROR: RefCell<Option<String>> = const { RefCell::new(None) };
29: 27: }
30: 28: 
31: 29: static CAC_RUNTIME: Lazy<Runtime> =
32: 30:     Lazy::new(|| Runtime::new().expect("The runtime was not intialized"));
33: 31: 
34: 32: macro_rules! null_check {
35: 33:     ($lyx-core-lyx_core_lyx-core-lyx_core_client: ident, $err: literal, $return: stmt) => {
36: 34:         if $lyx-core-lyx_core_lyx-core-lyx_core_client.is_null() {
37: 35:             update_last_error($err.into());
38: 36:             $return
39: 37:         }
40: 38:     };
41: 39: }
42: 40: 
43: 41: macro_rules! unwrap_safe {
44: 42:     ($result: expr, $return: stmt) => {
45: 43:         match $result {
46: 44:             Ok(value) => value,
47: 45:             Err(err) => {
48: 46:                 update_last_error(err.to_string());
49: 47:                 $return
50: 48:             }
51: 49:         }
52: 50:     };
53: 51: }
54: 52: 
55: 53: fn cstring_to_rstring(s: *const c_char) -> Result<String, String> {
56: 54:     null_check!(
57: 55:         s,
58: 56:         "Invalid C string passed: string was a NULL pointer",
59: 57:         return Err("Invalid C string passed: string was a NULL pointer".into())
60: 58:     );
61: 59:     let s = unsafe { CStr::from_ptr(s) };
62: 60:     s.to_str().map(str::to_string).map_err_to_string()
63: 61: }
64: 62: 
65: 63: fn rstring_to_cstring(s: String) -> CString {
66: 64:     CString::new(s.as_str()).unwrap_or_default()
67: 65: }
68: 66: 
69: 67: pub fn update_last_error(err: String) {
70: 68:     println!("Setting LAST_ERROR: {}", err);
71: 69:     LAST_ERROR.with(|prev| {
72: 70:         *prev.borrow_mut() = Some(err);
73: 71:     });
74: 72: }
75: 73: 
76: 74: pub fn take_last_error() -> Option<String> {
77: 75:     LAST_ERROR.with(|prev| prev.borrow_mut().take())
78: 76: }
79: 77: 
80: 78: #[no_mangle]
81: 79: pub extern "C" fn cac_last_error_length() -> c_int {
82: 80:     LAST_ERROR.with(|prev| match *prev.borrow() {
83: 81:         Some(ref err) => err.to_string().len() as c_int + 1,
84: 82:         None => 0,
85: 83:     })
86: 84: }
87: 85: 
88: 86: #[no_mangle]
89: 87: pub unsafe extern "C" fn cac_last_error_message() -> *const c_char {
90: 88:     let last_error = unwrap_safe!(
91: 89:         take_last_error().ok_or("No error found"),
92: 90:         return std::ptr::null_mut()
93: 91:     );
94: 92:     let error_message = last_error.to_string();
95: 93:     // println!("Error in last_error_message {error_message}");
96: 94:     let err = rstring_to_cstring(error_message);
97: 95:     err.into_raw()
98: 96: }
99: 97: 
100: 98: #[no_mangle]
101: 99: pub unsafe extern "C" fn cac_free_string(s: *mut c_char) {
102: 100:     if s.is_null() {
103: 101:         return;
104: 102:     }
105: 103:     unsafe {
106: 104:         let _ = CString::from_raw(s);
107: 105:     }
108: 106: }
109: 107: 
110: 108: #[no_mangle]
111: 109: pub extern "C" fn cac_new_lyx-core-lyx_core_lyx-core-lyx_core_client(
112: 110:     tenant: *const c_char,
113: 111:     update_frequency: c_ulong,
114: 112:     hostname: *const c_char,
115: 113: ) -> c_int {
116: 114:     #[allow(clippy::useless_conversion)] // done for windows support
117: 115:     let duration = Duration::new(update_frequency.into(), 0);
118: 116:     let tenant = unwrap_safe!(cstring_to_rstring(tenant), return 1);
119: 117:     let hostname = unwrap_safe!(cstring_to_rstring(hostname), return 1);
120: 118:     // println!("Creating cac lyx-core-lyx_core_lyx-core-lyx_core_client thread for tenant {tenant}");
121: 119:     CAC_RUNTIME.block_on(async move {
122: 120:         match CLIENT_FACTORY
123: 121:             .create_lyx-core-lyx_core_lyx-core-lyx_core_client(tenant.clone(), duration, hostname)
124: 122:             .await
125: 123:         {
126: 124:             Ok(_) => 0,
127: 125:             Err(err) => {
128: 126:                 update_last_error(err);
129: 127:                 1
130: 128:             }
131: 129:         }
132: 130:     })
133: 131: }
134: 132: 
135: 133: #[no_mangle]
136: 134: pub extern "C" fn cac_new_lyx-core-lyx_core_lyx-core-lyx_core_client_with_cache_properties(
137: 135:     tenant: *const c_char,
138: 136:     update_frequency: c_ulong,
139: 137:     hostname: *const c_char,
140: 138:     cache_max_capacity: c_ulong,
141: 139:     cache_ttl: c_ulong,
142: 140:     cache_tti: c_ulong,
143: 141: ) -> c_int {
144: 142:     #[allow(clippy::useless_conversion)] // done for windows support
145: 143:     let duration = Duration::new(update_frequency.into(), 0);
146: 144:     let tenant = unwrap_safe!(cstring_to_rstring(tenant), return 1);
147: 145:     let hostname = unwrap_safe!(cstring_to_rstring(hostname), return 1);
148: 146:     // println!("Creating cac lyx-core-lyx_core_lyx-core-lyx_core_client thread for tenant {tenant}");
149: 147:     CAC_RUNTIME.block_on(async move {
150: 148:         #[allow(clippy::useless_conversion)]
151: 149:         match CLIENT_FACTORY
152: 150:             .create_lyx-core-lyx_core_lyx-core-lyx_core_client_with_cache_properties(
153: 151:                 tenant.clone(),
154: 152:                 duration,
155: 153:                 hostname,
156: 154:                 cache_max_capacity.into(),
157: 155:                 cache_ttl.into(),
158: 156:                 cache_tti.into(),
159: 157:             )
160: 158:             .await
161: 159:         {
162: 160:             Ok(_) => 0,
163: 161:             Err(err) => {
164: 162:                 update_last_error(err);
165: 163:                 1
166: 164:             }
167: 165:         }
168: 166:     })
169: 167: }
170: 168: 
171: 169: #[no_mangle]
172: 170: pub extern "C" fn cac_start_polling_update(tenant: *const c_char) {
173: 171:     null_check!(tenant, "NULL pointer provided for tenant", return);
174: 172:     unsafe {
175: 173:         let lyx-core-lyx_core_lyx-core-lyx_core_client = cac_get_lyx-core-lyx_core_lyx-core-lyx_core_client(tenant);
176: 174:         null_check!(lyx-core-lyx_core_lyx-core-lyx_core_client, "CAC lyx-core-lyx_core_lyx-core-lyx_core_client for tenant not found", return);
177: 175:         // println!("in FFI polling");
178: 176:         let _handle = CAC_RUNTIME.spawn((*lyx-core-lyx_core_lyx-core-lyx_core_client).clone().run_polling_updates());
179: 177:     }
180: 178: }
181: 179: 
182: 180: #[no_mangle]
183: 181: pub extern "C" fn cac_free_lyx-core-lyx_core_lyx-core-lyx_core_client(ptr: *mut Arc<Client>) {
184: 182:     if ptr.is_null() {
185: 183:         return;
186: 184:     }
187: 185:     unsafe {
188: 186:         let _ = Box::from_raw(ptr);
189: 187:     }
190: 188: }
191: 189: 
192: 190: #[no_mangle]
193: 191: pub extern "C" fn cac_get_lyx-core-lyx_core_lyx-core-lyx_core_client(tenant: *const c_char) -> *mut Arc<Client> {
194: 192:     let ten = unwrap_safe!(cstring_to_rstring(tenant), return std::ptr::null_mut());
195: 193:     // println!("fetching cac lyx-core-lyx_core_lyx-core-lyx_core_client thread for tenant {ten}");
196: 194:     CAC_RUNTIME.block_on(async move {
197: 195:         unwrap_safe!(
198: 196:             CLIENT_FACTORY
199: 197:                 .get_lyx-core-lyx_core_lyx-core-lyx_core_client(ten)
200: 198:                 .await
201: 199:                 .map(|lyx-core-lyx_core_lyx-core-lyx_core_client| Box::into_raw(Box::new(lyx-core-lyx_core_lyx-core-lyx_core_client))),
202: 200:             std::ptr::null_mut()
203: 201:         )
204: 202:     })
205: 203: }
206: 204: 
207: 205: #[no_mangle]
208: 206: pub extern "C" fn cac_get_last_modified(lyx-core-lyx_core_lyx-core-lyx_core_client: *mut Arc<Client>) -> *const c_char {
209: 207:     null_check!(
210: 208:         lyx-core-lyx_core_lyx-core-lyx_core_client,
211: 209:         "an invalid null pointer lyx-core-lyx_core_lyx-core-lyx_core_client is being used, please call get_lyx-core-lyx_core_lyx-core-lyx_core_client()",
212: 210:         return std::ptr::null()
213: 211:     );
214: 212:     CAC_RUNTIME.block_on(async move {
215: 213:         unsafe {
216: 214:             let datetime = (*lyx-core-lyx_core_lyx-core-lyx_core_client).get_last_modified().await;
217: 215:             rstring_to_cstring(datetime.to_string()).into_raw()
218: 216:         }
219: 217:     })
220: 218: }
221: 219: 
222: 220: #[no_mangle]
223: 221: pub extern "C" fn cac_get_config(
224: 222:     lyx-core-lyx_core_lyx-core-lyx_core_client: *mut Arc<Client>,
225: 223:     filter_query: *const c_char,
226: 224:     filter_prefix: *const c_char,
227: 225: ) -> *const c_char {
228: 226:     null_check!(
229: 227:         lyx-core-lyx_core_lyx-core-lyx_core_client,
230: 228:         "an invalid null pointer lyx-core-lyx_core_lyx-core-lyx_core_client is being used, please call get_lyx-core-lyx_core_lyx-core-lyx_core_client()",
231: 229:         return std::ptr::null()
232: 230:     );
233: 231: 
234: 232:     let filters = if filter_query.is_null() {
235: 233:         None
236: 234:     } else {
237: 235:         let filter_string =
238: 236:             unwrap_safe!(cstring_to_rstring(filter_query), return std::ptr::null());
239: 237:         let filters: Map<String, Value> = unwrap_safe!(
240: 238:             serde_json::from_str::<Map<String, Value>>(filter_string.as_str()),
241: 239:             return std::ptr::null()
242: 240:         );
243: 241: 
244: 242:         Some(filters).filter(|filters| !filters.is_empty())
245: 243:     };
246: 244: 
247: 245:     let prefix_list = if filter_prefix.is_null() {
248: 246:         None
249: 247:     } else {
250: 248:         let filter_string =
251: 249:             unwrap_safe!(cstring_to_rstring(filter_prefix), return std::ptr::null());
252: 250:         let prefix_list: Vec<String> =
253: 251:             filter_string.split(',').map(String::from).collect();
254: 252: 
255: 253:         Some(prefix_list).filter(|list| !list.is_empty())
256: 254:     };
257: 255:     CAC_RUNTIME.block_on(async move {
258: 256:         unsafe {
259: 257:             unwrap_safe!(
260: 258:                 (*lyx-core-lyx_core_lyx-core-lyx_core_client)
261: 259:                     .get_full_config_state_with_filter(filters, prefix_list)
262: 260:                     .await
263: 261:                     .map(|config| {
264: 262:                         rstring_to_cstring(
265: 263:                             serde_json::to_value(config).unwrap().to_string(),
266: 264:                         )
267: 265:                         .into_raw()
268: 266:                     }),
269: 267:                 std::ptr::null_mut()
270: 268:             )
271: 269:         }
272: 270:     })
273: 271: }
274: 272: 
275: 273: #[no_mangle]
276: 274: pub extern "C" fn cac_get_resolved_config(
277: 275:     lyx-core-lyx_core_lyx-core-lyx_core_client: *mut Arc<Client>,
278: 276:     query: *const c_char,
279: 277:     filter_keys: *const c_char,
280: 278:     merge_strategy: *const c_char,
281: 279: ) -> *const c_char {
282: 280:     null_check!(
283: 281:         lyx-core-lyx_core_lyx-core-lyx_core_client,
284: 282:         "an invalid null pointer lyx-core-lyx_core_lyx-core-lyx_core_client is being used, please call get_lyx-core-lyx_core_lyx-core-lyx_core_client()",
285: 283:         return std::ptr::null()
286: 284:     );
287: 285: 
288: 286:     let keys: Option<Vec<String>> = if filter_keys.is_null() {
289: 287:         None
290: 288:     } else {
291: 289:         let filter_string =
292: 290:             unwrap_safe!(cstring_to_rstring(filter_keys), return std::ptr::null());
293: 291:         Some(filter_string.split('|').map(str::to_string).collect())
294: 292:     };
295: 293: 
296: 294:     let query = unwrap_safe!(cstring_to_rstring(query), return std::ptr::null());
297: 295:     let merge_strategem =
298: 296:         unwrap_safe!(cstring_to_rstring(merge_strategy), return std::ptr::null());
299: 297:     println!(
300: 298:         "key vector {:#?}, merge strategy {:#?}",
301: 299:         keys, merge_strategem
302: 300:     );
303: 301: 
304: 302:     let context = unwrap_safe!(
305: 303:         serde_json::from_str::<Map<String, Value>>(query.as_str()),
306: 304:         return std::ptr::null()
307: 305:     );
308: 306:     CAC_RUNTIME.block_on(async move {
309: 307:         unsafe {
310: 308:             unwrap_safe!(
311: 309:                 (*lyx-core-lyx_core_lyx-core-lyx_core_client)
312: 310:                     .get_resolved_config(
313: 311:                         context,
314: 312:                         keys,
315: 313:                         MergeStrategy::from(merge_strategem),
316: 314:                     )
317: 315:                     .await
318: 316:                     .map(|ov| {
319: 317:                         unwrap_safe!(
320: 318:                         serde_json::to_string::<Map<String, Value>>(&ov)
321: 319:                             .map(|overrides| rstring_to_cstring(overrides).into_raw()),
322: 320:                         std::ptr::null()
323: 321:                     )
324: 322:                     }),
325: 323:                 std::ptr::null()
326: 324:             )
327: 325:         }
328: 326:     })
329: 327: }
330: 328: 
331: 329: #[no_mangle]
332: 330: pub extern "C" fn cac_get_default_config(
333: 331:     lyx-core-lyx_core_lyx-core-lyx_core_client: *mut Arc<Client>,
334: 332:     filter_keys: *const c_char,
335: 333: ) -> *const c_char {
336: 334:     let keys: Option<Vec<String>> = if filter_keys.is_null() {
337: 335:         None
338: 336:     } else {
339: 337:         let filter_string = match cstring_to_rstring(filter_keys) {
340: 338:             Ok(s) => s,
341: 339:             Err(err) => {
342: 340:                 update_last_error(err);
343: 341:                 return std::ptr::null();
344: 342:             }
345: 343:         };
346: 344:         Some(filter_string.split('|').map(str::to_string).collect())
347: 345:     };
348: 346:     CAC_RUNTIME.block_on(async move {
349: 347:         unwrap_safe!(
350: 348:             unsafe {
351: 349:                 (*lyx-core-lyx_core_lyx-core-lyx_core_client).get_default_config(keys).await.map(|ov| {
352: 350:                     unwrap_safe!(
353: 351:                         serde_json::to_string::<Map<String, Value>>(&ov)
354: 352:                             .map(|overrides| rstring_to_cstring(overrides).into_raw()),
355: 353:                         std::ptr::null()
356: 354:                     )
357: 355:                 })
358: 356:             },
359: 357:             std::ptr::null()
360: 358:         )
361: 359:     })
362: 360: }
363: 361: ```
364: 362: ```
365: 363: ```
366: 364: ```
367: ```
```
