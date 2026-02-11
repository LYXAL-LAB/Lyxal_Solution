### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_benchmarks\src\reactive.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_benchmarks\src\reactive.rs
2: ```rust
3: 1: use std::{cell::Cell, rc::Rc};
4: 2: use test::Bencher;
5: 3: 
6: 4: #[bench]
7: 5: fn lyx-core-lyx_core_lyx-core-lyx_core_leptos_deep_creation(b: &mut Bencher) {
8: 6:     use lyx-core-lyx_core_lyx-core-lyx_core_leptos::*;
9: 7:     let runtime = create_runtime();
10: 8: 
11: 9:     b.iter(|| {
12: 10:         let signal = create_rw_signal(0);
13: 11:         let mut memos = Vec::<Memo<usize>>::new();
14: 12:         for _ in 0..1000usize {
15: 13:             let prev = memos.last().copied();
16: 14:             if let Some(prev) = prev {
17: 15:                 memos.push(create_memo(move |_| prev.get() + 1));
18: 16:             } else {
19: 17:                 memos.push(create_memo(move |_| signal.get() + 1));
20: 18:             }
21: 19:         }
22: 20:     });
23: 21: 
24: 22:     runtime.dispose();
25: 23: }
26: 24: 
27: 25: #[bench]
28: 26: fn lyx-core-lyx_core_lyx-core-lyx_core_leptos_deep_update(b: &mut Bencher) {
29: 27:     use lyx-core-lyx_core_lyx-core-lyx_core_leptos::*;
30: 28:     let runtime = create_runtime();
31: 29: 
32: 30:     b.iter(|| {
33: 31:         let signal = create_rw_signal(0);
34: 32:         let mut memos = Vec::<Memo<usize>>::new();
35: 33:         for _ in 0..1000usize {
36: 34:             if let Some(prev) = memos.last().copied() {
37: 35:                 memos.push(create_memo(move |_| prev.get() + 1));
38: 36:             } else {
39: 37:                 memos.push(create_memo(move |_| signal.get() + 1));
40: 38:             }
41: 39:         }
42: 40:         signal.set(1);
43: 41:         assert_eq!(memos[999].get(), 1001);
44: 42:     });
45: 43: 
46: 44:     runtime.dispose();
47: 45: }
48: 46: 
49: 47: #[bench]
50: 48: fn lyx-core-lyx_core_lyx-core-lyx_core_leptos_narrowing_down(b: &mut Bencher) {
51: 49:     use lyx-core-lyx_core_lyx-core-lyx_core_leptos::*;
52: 50:     let runtime = create_runtime();
53: 51: 
54: 52:     b.iter(|| {
55: 53:         let sigs = (0..1000).map(|n| create_signal(n)).collect::<Vec<_>>();
56: 54:         let reads = sigs.iter().map(|(r, _)| *r).collect::<Vec<_>>();
57: 55:         let writes = sigs.iter().map(|(_, w)| *w).collect::<Vec<_>>();
58: 56:         let memo =
59: 57:             create_memo(move |_| reads.iter().map(|r| r.get()).sum::<i32>());
60: 58:         assert_eq!(memo(), 499500);
61: 59:     });
62: 60: 
63: 61:     runtime.dispose();
64: 62: }
65: 63: 
66: 64: #[bench]
67: 65: fn lyx-core-lyx_core_lyx-core-lyx_core_leptos_fanning_out(b: &mut Bencher) {
68: 66:     use lyx-core-lyx_core_lyx-core-lyx_core_leptos::*;
69: 67:     let runtime = create_runtime();
70: 68: 
71: 69:     b.iter(|| {
72: 70:         let sig = create_rw_signal(0);
73: 71:         let memos = (0..1000)
74: 72:             .map(|_| create_memo(move |_| sig.get()))
75: 73:             .collect::<Vec<_>>();
76: 74:         assert_eq!(memos.iter().map(|m| m.get()).sum::<i32>(), 0);
77: 75:         sig.set(1);
78: 76:         assert_eq!(memos.iter().map(|m| m.get()).sum::<i32>(), 1000);
79: 77:     });
80: 78: 
81: 79:     runtime.dispose();
82: 80: }
83: 81: 
84: 82: #[bench]
85: 83: fn lyx-core-lyx_core_lyx-core-lyx_core_leptos_narrowing_update(b: &mut Bencher) {
86: 84:     use lyx-core-lyx_core_lyx-core-lyx_core_leptos::*;
87: 85:     let runtime = create_runtime();
88: 86: 
89: 87:     b.iter(|| {
90: 88:         let acc = Rc::new(Cell::new(0));
91: 89:         let sigs = (0..1000).map(|n| create_signal(n)).collect::<Vec<_>>();
92: 90:         let reads = sigs.iter().map(|(r, _)| *r).collect::<Vec<_>>();
93: 91:         let writes = sigs.iter().map(|(_, w)| *w).collect::<Vec<_>>();
94: 92:         let memo =
95: 93:             create_memo(move |_| reads.iter().map(|r| r.get()).sum::<i32>());
96: 94:         assert_eq!(memo(), 499500);
97: 95:         create_isomorphic_effect({
98: 96:             let acc = Rc::clone(&acc);
99: 97:             move |_| {
100: 98:                 acc.set(memo());
101: 99:             }
102: 100:         });
103: 101:         assert_eq!(acc.get(), 499500);
104: 102: 
105: 103:         writes[1].update(|n| *n += 1);
106: 104:         writes[10].update(|n| *n += 1);
107: 105:         writes[100].update(|n| *n += 1);
108: 106: 
109: 107:         assert_eq!(acc.get(), 499503);
110: 108:         assert_eq!(memo(), 499503);
111: 109:     });
112: 110: 
113: 111:     runtime.dispose();
114: 112: }
115: 113: 
116: 114: #[bench]
117: 115: fn l0410_deep_creation(b: &mut Bencher) {
118: 116:     use l0410::*;
119: 117:     let runtime = create_runtime();
120: 118: 
121: 119:     b.iter(|| {
122: 120:         create_scope(runtime, |cx| {
123: 121:             let signal = create_rw_signal(cx, 0);
124: 122:             let mut memos = Vec::<Memo<usize>>::new();
125: 123:             for _ in 0..1000usize {
126: 124:                 if let Some(prev) = memos.last().copied() {
127: 125:                     memos.push(create_memo(cx, move |_| prev.get() + 1));
128: 126:                 } else {
129: 127:                     memos.push(create_memo(cx, move |_| signal.get() + 1));
130: 128:                 }
131: 129:             }
132: 130:         })
133: 131:         .dispose()
134: 132:     });
135: 133: 
136: 134:     runtime.dispose();
137: 135: }
138: 136: 
139: 137: #[bench]
140: 138: fn l0410_deep_update(b: &mut Bencher) {
141: 139:     use l0410::*;
142: 140:     let runtime = create_runtime();
143: 141: 
144: 142:     b.iter(|| {
145: 143:         create_scope(runtime, |cx| {
146: 144:             let signal = create_rw_signal(cx, 0);
147: 145:             let mut memos = Vec::<Memo<usize>>::new();
148: 146:             for _ in 0..1000usize {
149: 147:                 if let Some(prev) = memos.last().copied() {
150: 148:                     memos.push(create_memo(cx, move |_| prev.get() + 1));
151: 149:                 } else {
152: 150:                     memos.push(create_memo(cx, move |_| signal.get() + 1));
153: 151:                 }
154: 152:             }
155: 153:             signal.set(1);
156: 154:             assert_eq!(memos[999].get(), 1001);
157: 155:         })
158: 156:         .dispose()
159: 157:     });
160: 158: 
161: 159:     runtime.dispose();
162: 160: }
163: 161: 
164: 162: #[bench]
165: 163: fn l0410_narrowing_down(b: &mut Bencher) {
166: 164:     use l0410::*;
167: 165:     let runtime = create_runtime();
168: 166: 
169: 167:     b.iter(|| {
170: 168:         create_scope(runtime, |cx| {
171: 169:             let acc = Rc::new(Cell::new(0));
172: 170:             let sigs =
173: 171:                 (0..1000).map(|n| create_signal(cx, n)).collect::<Vec<_>>();
174: 172:             let reads = sigs.iter().map(|(r, _)| *r).collect::<Vec<_>>();
175: 173:             let writes = sigs.iter().map(|(_, w)| *w).collect::<Vec<_>>();
176: 174:             let memo = create_memo(cx, move |_| {
177: 175:                 reads.iter().map(|r| r.get()).sum::<i32>()
178: 176:             });
179: 177:             assert_eq!(memo(), 499500);
180: 178:         })
181: 179:         .dispose()
182: 180:     });
183: 181: 
184: 182:     runtime.dispose();
185: 183: }
186: 184: 
187: 185: #[bench]
188: 186: fn l0410_fanning_out(b: &mut Bencher) {
189: 187:     use l0410::*;
190: 188:     let runtime = create_runtime();
191: 189: 
192: 190:     b.iter(|| {
193: 191:         create_scope(runtime, |cx| {
194: 192:             let sig = create_rw_signal(cx, 0);
195: 193:             let memos = (0..1000)
196: 194:                 .map(|_| create_memo(cx, move |_| sig.get()))
197: 195:                 .collect::<Vec<_>>();
198: 196:             assert_eq!(memos.iter().map(|m| m.get()).sum::<i32>(), 0);
199: 197:             sig.set(1);
200: 198:             assert_eq!(memos.iter().map(|m| m.get()).sum::<i32>(), 1000);
201: 199:         })
202: 200:         .dispose()
203: 201:     });
204: 202: 
205: 203:     runtime.dispose();
206: 204: }
207: 205: #[bench]
208: 206: fn l0410_narrowing_update(b: &mut Bencher) {
209: 207:     use l0410::*;
210: 208:     let runtime = create_runtime();
211: 209: 
212: 210:     b.iter(|| {
213: 211:         create_scope(runtime, |cx| {
214: 212:             let acc = Rc::new(Cell::new(0));
215: 213:             let sigs =
216: 214:                 (0..1000).map(|n| create_signal(cx, n)).collect::<Vec<_>>();
217: 215:             let reads = sigs.iter().map(|(r, _)| *r).collect::<Vec<_>>();
218: 216:             let writes = sigs.iter().map(|(_, w)| *w).collect::<Vec<_>>();
219: 217:             let memo = create_memo(cx, move |_| {
220: 218:                 reads.iter().map(|r| r.get()).sum::<i32>()
221: 219:             });
222: 220:             assert_eq!(memo.get(), 499500);
223: 221:             create_isomorphic_effect(cx, {
224: 222:                 let acc = Rc::clone(&acc);
225: 223:                 move |_| {
226: 224:                     acc.set(memo.get());
227: 225:                 }
228: 226:             });
229: 227:             assert_eq!(acc.get(), 499500);
230: 228: 
231: 229:             writes[1].update(|n| *n += 1);
232: 230:             writes[10].update(|n| *n += 1);
233: 231:             writes[100].update(|n| *n += 1);
234: 232: 
235: 233:             assert_eq!(acc.get(), 499503);
236: 234:             assert_eq!(memo.get(), 499503);
237: 235:         })
238: 236:         .dispose()
239: 237:     });
240: 238: 
241: 239:     runtime.dispose();
242: 240: }
243: 241: 
244: 242: #[bench]
245: 243: fn l0410_scope_creation_and_disposal(b: &mut Bencher) {
246: 244:     use l0410::*;
247: 245:     let runtime = create_runtime();
248: 246: 
249: 247:     b.iter(|| {
250: 248:         let acc = Rc::new(Cell::new(0));
251: 249:         let disposers = (0..1000)
252: 250:             .map(|_| {
253: 251:                 create_scope(runtime, {
254: 252:                     let acc = Rc::clone(&acc);
255: 253:                     move |cx| {
256: 254:                         let (r, w) = create_signal(cx, 0);
257: 255:                         create_isomorphic_effect(cx, {
258: 256:                             move |_| {
259: 257:                                 acc.set(r.get());
260: 258:                             }
261: 259:                         });
262: 260:                         w.update(|n| *n += 1);
263: 261:                     }
264: 262:                 })
265: 263:             })
266: 264:             .collect::<Vec<_>>();
267: 265:         for disposer in disposers {
268: 266:             disposer.dispose();
269: 267:         }
270: 268:     });
271: 269: 
272: 270:     runtime.dispose();
273: 271: }
274: 272: 
275: 273: #[bench]
276: 274: fn sycamore_narrowing_down(b: &mut Bencher) {
277: 275:     use sycamore::reactive::{
278: 276:         create_effect, create_memo, create_scope, create_signal,
279: 277:     };
280: 278: 
281: 279:     b.iter(|| {
282: 280:         let d = create_scope(|cx| {
283: 281:             let acc = Rc::new(Cell::new(0));
284: 282:             let sigs = Rc::new(
285: 283:                 (0..1000).map(|n| create_signal(cx, n)).collect::<Vec<_>>(),
286: 284:             );
287: 285:             let memo = create_memo(cx, {
288: 286:                 let sigs = Rc::clone(&sigs);
289: 287:                 move || sigs.iter().map(|r| *r.get()).sum::<i32>()
290: 288:             });
291: 289:             assert_eq!(*memo.get(), 499500);
292: 290:         });
293: 291:         unsafe { d.dispose() };
294: 292:     });
295: 293: }
296: 294: 
297: 295: #[bench]
298: 296: fn sycamore_fanning_out(b: &mut Bencher) {
299: 297:     use sycamore::reactive::{
300: 298:         create_effect, create_memo, create_scope, create_signal,
301: 299:     };
302: 300: 
303: 301:     b.iter(|| {
304: 302:         let d = create_scope(|cx| {
305: 303:             let sig = create_signal(cx, 0);
306: 304:             let memos = (0..1000)
307: 305:                 .map(|_| create_memo(cx, move || sig.get()))
308: 306:                 .collect::<Vec<_>>();
309: 307:             assert_eq!(memos.iter().map(|m| *(*m.get())).sum::<i32>(), 0);
310: 308:             sig.set(1);
311: 309:             assert_eq!(memos.iter().map(|m| *(*m.get())).sum::<i32>(), 1000);
312: 310:         });
313: 311:         unsafe { d.dispose() };
314: 312:     });
315: 313: }
316: 314: 
317: 315: #[bench]
318: 316: fn sycamore_deep_creation(b: &mut Bencher) {
319: 317:     use sycamore::reactive::*;
320: 318: 
321: 319:     b.iter(|| {
322: 320:         let d = create_scope(|cx| {
323: 321:             let signal = create_signal(cx, 0);
324: 322:             let mut memos = Vec::<&ReadSignal<usize>>::new();
325: 323:             for _ in 0..1000usize {
326: 324:                 if let Some(prev) = memos.last().copied() {
327: 325:                     memos.push(create_memo(cx, move || *prev.get() + 1));
328: 326:                 } else {
329: 327:                     memos.push(create_memo(cx, move || *signal.get() + 1));
330: 328:                 }
331: 329:             }
332: 330:         });
333: 331:         unsafe { d.dispose() };
334: 332:     });
335: 333: }
336: 334: 
337: 335: #[bench]
338: 336: fn sycamore_deep_update(b: &mut Bencher) {
339: 337:     use sycamore::reactive::*;
340: 338: 
341: 339:     b.iter(|| {
342: 340:         let d = create_scope(|cx| {
343: 341:             let signal = create_signal(cx, 0);
344: 342:             let mut memos = Vec::<&ReadSignal<usize>>::new();
345: 343:             for _ in 0..1000usize {
346: 344:                 if let Some(prev) = memos.last().copied() {
347: 345:                     memos.push(create_memo(cx, move || *prev.get() + 1));
348: 346:                 } else {
349: 347:                     memos.push(create_memo(cx, move || *signal.get() + 1));
350: 348:                 }
351: 349:             }
352: 350:             signal.set(1);
353: 351:             assert_eq!(*memos[999].get(), 1001);
354: 352:         });
355: 353:         unsafe { d.dispose() };
356: 354:     });
357: 355: }
358: 356: #[bench]
359: 357: fn sycamore_narrowing_update(b: &mut Bencher) {
360: 358:     use sycamore::reactive::{
361: 359:         create_effect, create_memo, create_scope, create_signal,
362: 360:     };
363: 361: 
364: 362:     b.iter(|| {
365: 363:         let d = create_scope(|cx| {
366: 364:             let acc = Rc::new(Cell::new(0));
367: 365:             let sigs = Rc::new(
368: 366:                 (0..1000).map(|n| create_signal(cx, n)).collect::<Vec<_>>(),
369: 367:             );
370: 368:             let memo = create_memo(cx, {
371: 369:                 let sigs = Rc::clone(&sigs);
372: 370:                 move || sigs.iter().map(|r| *r.get()).sum::<i32>()
373: 371:             });
374: 372:             assert_eq!(*memo.get(), 499500);
375: 373:             create_effect(cx, {
376: 374:                 let acc = Rc::clone(&acc);
377: 375:                 move || {
378: 376:                     acc.set(*memo.get());
379: 377:                 }
380: 378:             });
381: 379:             assert_eq!(acc.get(), 499500);
382: 380: 
383: 381:             sigs[1].set(*sigs[1].get() + 1);
384: 382:             sigs[10].set(*sigs[10].get() + 1);
385: 383:             sigs[100].set(*sigs[100].get() + 1);
386: 384: 
387: 385:             assert_eq!(acc.get(), 499503);
388: 386:             assert_eq!(*memo.get(), 499503);
389: 387:         });
390: 388:         unsafe { d.dispose() };
391: 389:     });
392: 390: }
393: 391: 
394: 392: #[bench]
395: 393: fn sycamore_scope_creation_and_disposal(b: &mut Bencher) {
396: 394:     use sycamore::reactive::{create_effect, create_scope, create_signal};
397: 395: 
398: 396:     b.iter(|| {
399: 397:         let acc = Rc::new(Cell::new(0));
400: 398:         let disposers = (0..1000)
401: 399:             .map(|_| {
402: 400:                 create_scope({
403: 401:                     let acc = Rc::clone(&acc);
404: 402:                     move |cx| {
405: 403:                         let s = create_signal(cx, 0);
406: 404:                         create_effect(cx, {
407: 405:                             move || {
408: 406:                                 acc.set(*s.get());
409: 407:                             }
410: 408:                         });
411: 409:                         s.set(*s.get() + 1);
412: 410:                     }
413: 411:                 })
414: 412:             })
415: 413:             .collect::<Vec<_>>();
416: 414:         for disposer in disposers {
417: 415:             unsafe {
418: 416:                 disposer.dispose();
419: 417:             }
420: 418:         }
421: 419:     });
422: 420: }
423: ```
```
