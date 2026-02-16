1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_experimentation_lyx-core-lyx_core_lyx-core-lyx_core_client\src\interface.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_experimentation_lyx-core-lyx_core_lyx-core-lyx_core_client\src\interface.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_experimentation_lyx-core-lyx_core_lyx-core-lyx_core_client\src\interface.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_experimentation_lyx-core-lyx_core_lyx-core-lyx_core_client\src\interface.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_experimentation_lyx-core-lyx_core_lyx-core-lyx_core_client\src\interface.rs
10: 8: ```rust
11: 9: use std::{
12: 10:     collections::HashMap,
13: 11:     ffi::{c_char, c_ulong, CStr},
14: 12:     sync::Arc,
15: 13: };
16: 14: 
17: 15: use crate::{Client, CLIENT_FACTORY};
18: 16: use once_cell::sync::Lazy;
19: 17: use serde_json::{Map, Value};
20: 18: use std::{
21: 19:     cell::RefCell,
22: 20:     ffi::{c_int, CString},
23: 21: };
24: 22: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types::{
25: 23:     logic::{evaluate_local_cohorts, evaluate_local_cohorts_skip_unresolved},
26: 24:     DimensionInfo,
27: 25: };
28: 26: use tokio::{runtime::Runtime, task};
29: 27: 
30: 28: thread_local! {
31: 29:     static LAST_ERROR: RefCell<Option<String>> = const { RefCell::new(None) };
32: 30: }
33: 31: 
34: 32: static EXP_RUNTIME: Lazy<Runtime> =
35: 33:     Lazy::new(|| Runtime::new().expect("The runtime was not intialized"));
36: 34: 
37: 35: macro_rules! null_check {
38: 36:     ($lyx-core-lyx_core_lyx-core-lyx_core_client: ident, $err: literal, $return: stmt) => {
39: 37:         if $lyx-core-lyx_core_lyx-core-lyx_core_client.is_null() {
40: 38:             update_last_error($err.into());
41: 39:             $return
42: 40:         }
43: 41:     };
44: 42: }
45: 43: 
46: 44: macro_rules! unwrap_safe {
47: 45:     ($result: expr, $return: stmt) => {
48: 46:         match $result {
49: 47:             Ok(value) => value,
50: 48:             Err(err) => {
51: 49:                 update_last_error(err.to_string());
52: 50:                 $return
53: 51:             }
54: 52:         }
55: 53:     };
56: 54: }
57: 55: 
58: 56: fn to_string<E>(e: E) -> String
59: 57: where
60: 58:     E: ToString,
61: 59: {
62: 60:     e.to_string()
63: 61: }
64: 62: 
65: 63: fn error_block<E>(err: String) -> *mut E {
66: 64:     update_last_error(err);
67: 65:     std::ptr::null_mut()
68: 66: }
69: 67: 
70: 68: fn cstring_to_rstring(s: *const c_char) -> Result<String, String> {
71: 69:     let s = unsafe { CStr::from_ptr(s) };
72: 70:     s.to_str().map(str::to_string).map_err(to_string)
73: 71: }
74: 72: 
75: 73: fn rstring_to_cstring(s: String) -> CString {
76: 74:     CString::new(s.as_str()).unwrap_or_default()
77: 75: }
78: 76: 
79: 77: pub fn update_last_error(err: String) {
80: 78:     println!("Setting LAST_ERROR: {}", err);
81: 79: 
82: 80:     LAST_ERROR.with(|prev| {
83: 81:         *prev.borrow_mut() = Some(err);
84: 82:     });
85: 83: }
86: 84: 
87: 85: pub fn take_last_error() -> Option<String> {
88: 86:     LAST_ERROR.with(|prev| prev.take())
89: 87: }
90: 88: 
91: 89: #[no_mangle]
92: 90: pub extern "C" fn expt_last_error_length() -> c_int {
93: 91:     LAST_ERROR.with(|prev| match *prev.borrow() {
94: 92:         Some(ref err) => err.to_string().len() as c_int + 1,
95: 93:         None => 0,
96: 94:     })
97: 95: }
98: 96: 
99: 97: #[no_mangle]
100: 98: pub unsafe extern "C" fn expt_last_error_message() -> *const c_char {
101: 99:     let last_error = match take_last_error() {
102: 100:         Some(err) => err,
103: 101:         None => return std::ptr::null_mut(),
104: 102:     };
105: 103:     let error_message = last_error.to_string();
106: 104:     // println!("Error in last_error_message {error_message}");
107: 105:     let err = rstring_to_cstring(error_message);
108: 106:     err.into_raw()
109: 107: }
110: 108: 
111: 109: #[no_mangle]
112: 110: pub unsafe extern "C" fn expt_free_string(s: *mut c_char) {
113: 111:     if s.is_null() {
114: 112:         return;
115: 113:     }
116: 114:     unsafe {
117: 115:         let _ = CString::from_raw(s);
118: 116:     }
119: 117: }
120: 118: 
121: 119: #[no_mangle]
122: 120: pub extern "C" fn expt_new_lyx-core-lyx_core_lyx-core-lyx_core_client(
123: 121:     tenant: *const c_char,
124: 122:     update_frequency: c_ulong,
125: 123:     hostname: *const c_char,
126: 124: ) -> c_int {
127: 125:     let tenant = unwrap_safe!(cstring_to_rstring(tenant), return 1);
128: 126:     let hostname = unwrap_safe!(cstring_to_rstring(hostname), return 1);
129: 127: 
130: 128:     // println!("Creating cac lyx-core-lyx_core_lyx-core-lyx_core_client thread for tenant {tenant}");
131: 129:     EXP_RUNTIME.block_on(async move {
132: 130:         #[allow(clippy::useless_conversion)]
133: 131:         match CLIENT_FACTORY
134: 132:             .create_lyx-core-lyx_core_lyx-core-lyx_core_client(tenant.clone(), update_frequency.into(), hostname)
135: 133:             .await
136: 134:         {
137: 135:             Ok(_) => 0,
138: 136:             Err(err) => {
139: 137:                 update_last_error(err);
140: 138:                 1
141: 139:             }
142: 140:         }
143: 141:     });
144: 142:     0
145: 143: }
146: 144: 
147: 145: #[no_mangle]
148: 146: pub extern "C" fn expt_start_polling_update(tenant: *const c_char) {
149: 147:     null_check!(tenant, "Tenant cannot be a null string", return);
150: 148:     unsafe {
151: 149:         let lyx-core-lyx_core_lyx-core-lyx_core_client = expt_get_lyx-core-lyx_core_lyx-core-lyx_core_client(tenant);
152: 150:         let local = task::LocalSet::new();
153: 151:         // println!("in FFI polling");
154: 152:         local.block_on(&EXP_RUNTIME, (*lyx-core-lyx_core_lyx-core-lyx_core_client).clone().run_polling_updates());
155: 153:     }
156: 154: }
157: 155: 
158: 156: #[no_mangle]
159: 157: pub extern "C" fn expt_free_lyx-core-lyx_core_lyx-core-lyx_core_client(ptr: *mut Arc<Client>) {
160: 158:     null_check!(ptr, "cannot free a null pointer", return);
161: 159:     unsafe {
162: 160:         let _ = Box::from_raw(ptr);
163: 161:     }
164: 162: }
165: 163: 
166: 164: #[no_mangle]
167: 165: pub extern "C" fn expt_get_lyx-core-lyx_core_lyx-core-lyx_core_client(tenant: *const c_char) -> *mut Arc<Client> {
168: 166:     let ten = unwrap_safe!(cstring_to_rstring(tenant), return std::ptr::null_mut());
169: 167:     EXP_RUNTIME.block_on(async move {
170: 168:         match CLIENT_FACTORY.get_lyx-core-lyx_core_lyx-core-lyx_core_client(ten).await {
171: 169:             Ok(lyx-core-lyx_core_lyx-core-lyx_core_client) => Box::into_raw(Box::new(lyx-core-lyx_core_lyx-core-lyx_core_client)),
172: 170:             Err(err) => {
173: 171:                 // println!("error occurred {err}");
174: 172:                 update_last_error(err);
175: 173:                 // println!("error set");
176: 174:                 std::ptr::null_mut()
177: 175:             }
178: 176:         }
179: 177:     })
180: 178: }
181: 179: 
182: 180: #[no_mangle]
183: 181: pub extern "C" fn expt_get_lyx-platform-lyx_platform_lyx-platform-lyx_platform_applicable_variant(
184: 182:     lyx-core-lyx_core_lyx-core-lyx_core_client: *mut Arc<Client>,
185: 183:     c_dimensions: *const c_char,
186: 184:     c_context: *const c_char,
187: 185:     identifier: *const c_char,
188: 186:     filter_prefix: *const c_char,
189: 187: ) -> *mut c_char {
190: 188:     let dimensions = unwrap_safe!(
191: 189:         cstring_to_rstring(c_dimensions),
192: 190:         return std::ptr::null_mut()
193: 191:     );
194: 192:     let context =
195: 193:         unwrap_safe!(cstring_to_rstring(c_context), return std::ptr::null_mut());
196: 194:     let identifier =
197: 195:         unwrap_safe!(cstring_to_rstring(identifier), return std::ptr::null_mut());
198: 196: 
199: 197:     let dimensions = unwrap_safe!(
200: 198:         serde_json::from_str::<HashMap<String, DimensionInfo>>(dimensions.as_str()),
201: 199:         return std::ptr::null_mut()
202: 200:     );
203: 201:     let context = unwrap_safe!(
204: 202:         serde_json::from_str::<Map<String, Value>>(context.as_str()),
205: 203:         return std::ptr::null_mut()
206: 204:     );
207: 205:     let prefix_list = if filter_prefix.is_null() {
208: 206:         None
209: 207:     } else {
210: 208:         let filter_string = unwrap_safe!(
211: 209:             cstring_to_rstring(filter_prefix),
212: 210:             return std::ptr::null_mut()
213: 211:         );
214: 212:         let prefix_list = filter_string.split(',').map(String::from).collect();
215: 213:         Some(prefix_list)
216: 214:     };
217: 215:     let variants_result = EXP_RUNTIME.block_on(unsafe {
218: 216:         (*lyx-core-lyx_core_lyx-core-lyx_core_client).get_lyx-platform-lyx_platform_lyx-platform-lyx_platform_applicable_variant(&dimensions, &context, &identifier, prefix_list)
219: 217:     });
220: 218:     variants_result
221: 219:         .map(|result| {
222: 220:             serde_json::to_string(&result)
223: 221:                 .map(|json| rstring_to_cstring(json).into_raw())
224: 222:                 .unwrap_or_else(|err| error_block(err.to_string()))
225: 223:         })
226: 224:         .unwrap_or_else(|err| error_block(err.to_string()))
227: 225: }
228: 226: 
229: 227: #[no_mangle]
230: 228: pub extern "C" fn expt_get_satisfied_experiments(
231: 229:     lyx-core-lyx_core_lyx-core-lyx_core_client: *mut Arc<Client>,
232: 230:     c_dimensions: *const c_char,
233: 231:     c_context: *const c_char,
234: 232:     filter_prefix: *const c_char,
235: 233: ) -> *mut c_char {
236: 234:     let context =
237: 235:         unwrap_safe!(cstring_to_rstring(c_context), return std::ptr::null_mut());
238: 236: 
239: 237:     let context = unwrap_safe!(
240: 238:         serde_json::from_str::<Map<String, Value>>(context.as_str()),
241: 239:         return std::ptr::null_mut()
242: 240:     );
243: 241: 
244: 242:     let dimensions = unwrap_safe!(
245: 243:         cstring_to_rstring(c_dimensions),
246: 244:         return std::ptr::null_mut()
247: 245:     );
248: 246: 
249: 247:     let dimensions = unwrap_safe!(
250: 248:         serde_json::from_str::<HashMap<String, DimensionInfo>>(dimensions.as_str()),
251: 249:         return std::ptr::null_mut()
252: 250:     );
253: 251: 
254: 252:     let prefix_list = if filter_prefix.is_null() {
255: 253:         None
256: 254:     } else {
257: 255:         let filter_string = unwrap_safe!(
258: 256:             cstring_to_rstring(filter_prefix),
259: 257:             return std::ptr::null_mut()
260: 258:         );
261: 259:         let prefix_list = filter_string.split(',').map(String::from).collect();
262: 260:         Some(prefix_list)
263: 261:     };
264: 262: 
265: 263:     let context = evaluate_local_cohorts(&dimensions, &context);
266: 264: 
267: 265:     let local = task::LocalSet::new();
268: 266:     local.block_on(&Runtime::new().unwrap(), async move {
269: 267:         unsafe {
270: 268:             unwrap_safe!(
271: 269:                 (*lyx-core-lyx_core_lyx-core-lyx_core_client)
272: 270:                     .get_satisfied_experiments(&context, prefix_list)
273: 271:                     .await
274: 272:                     .map(|exp| {
275: 273:                         rstring_to_cstring(serde_json::to_value(exp).unwrap().to_string())
276: 274:                             .into_raw()
277: 275:                     }),
278: 276:                 std::ptr::null_mut()
279: 277:             )
280: 278:         }
281: 279:     })
282: 280: }
283: 281: 
284: 282: #[no_mangle]
285: 283: pub extern "C" fn expt_get_filtered_satisfied_experiments(
286: 284:     lyx-core-lyx_core_lyx-core-lyx_core_client: *mut Arc<Client>,
287: 285:     c_dimensions: *const c_char,
288: 286:     c_context: *const c_char,
289: 287:     filter_prefix: *const c_char,
290: 288: ) -> *mut c_char {
291: 289:     let context =
292: 290:         unwrap_safe!(cstring_to_rstring(c_context), return std::ptr::null_mut());
293: 291: 
294: 292:     let context = unwrap_safe!(
295: 293:         serde_json::from_str::<Map<String, Value>>(context.as_str()),
296: 294:         return std::ptr::null_mut()
297: 295:     );
298: 296: 
299: 297:     let dimensions = unwrap_safe!(
300: 298:         cstring_to_rstring(c_dimensions),
301: 299:         return std::ptr::null_mut()
302: 300:     );
303: 301: 
304: 302:     let dimensions = unwrap_safe!(
305: 303:         serde_json::from_str::<HashMap<String, DimensionInfo>>(dimensions.as_str()),
306: 304:         return std::ptr::null_mut()
307: 305:     );
308: 306: 
309: 307:     let prefix_list = if filter_prefix.is_null() {
310: 308:         None
311: 309:     } else {
312: 310:         let filter_string = unwrap_safe!(
313: 311:             cstring_to_rstring(filter_prefix),
314: 312:             return std::ptr::null_mut()
315: 313:         );
316: 314:         let prefix_list: Vec<String> =
317: 315:             filter_string.split(',').map(String::from).collect();
318: 316: 
319: 317:         Some(prefix_list).filter(|list| !list.is_empty())
320: 318:     };
321: 319: 
322: 320:     let context = evaluate_local_cohorts_skip_unresolved(&dimensions, &context);
323: 321: 
324: 322:     let local = task::LocalSet::new();
325: 323:     local.block_on(&Runtime::new().unwrap(), async move {
326: 324:         unsafe {
327: 325:             unwrap_safe!(
328: 326:                 (*lyx-core-lyx_core_lyx-core-lyx_core_client)
329: 327:                     .get_filtered_satisfied_experiments(&context, prefix_list)
330: 328:                     .await
331: 329:                     .map(|exp| {
332: 330:                         rstring_to_cstring(serde_json::to_value(exp).unwrap().to_string())
333: 331:                             .into_raw()
334: 332:                     }),
335: 333:                 std::ptr::null_mut()
336: 334:             )
337: 335:         }
338: 336:     })
339: 337: }
340: 338: 
341: 339: #[no_mangle]
342: 340: pub extern "C" fn expt_get_running_experiments(lyx-core-lyx_core_lyx-core-lyx_core_client: *mut Arc<Client>) -> *mut c_char {
343: 341:     let local = task::LocalSet::new();
344: 342:     local.block_on(&Runtime::new().unwrap(), async move {
345: 343:         unsafe {
346: 344:             unwrap_safe!(
347: 345:                 (*lyx-core-lyx_core_lyx-core-lyx_core_client).get_running_experiments().await.map(|exp| {
348: 346:                     rstring_to_cstring(serde_json::to_value(exp).unwrap().to_string())
349: 347:                         .into_raw()
350: 348:                 }),
351: 349:                 std::ptr::null_mut()
352: 350:             )
353: 351:         }
354: 352:     })
355: 353: }
356: 354: ```
357: 355: ```
358: 356: ```
359: 357: ```
360: ```
```

