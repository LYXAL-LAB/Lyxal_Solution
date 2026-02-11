### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\projects\ory-kratos\lyx-core-lyx_core_e2e\tests\fixtures\steps.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\projects\ory-kratos\lyx-core-lyx_core_lyx-core-lyx_core_e2e\tests\fixtures\steps.rs
2: ```rust
3: 1: use crate::{AppWorld, EMAIL_ID_MAP};
4: 2: use anyhow::anyhow;
5: 3: use anyhow::{Ok, Result};
6: 4: use chromiumoxide::cdp::browser_protocol::input::TimeSinceEpoch;
7: 5: use chromiumoxide::cdp::browser_protocol::network::{CookieParam, DeleteCookiesParams};
8: 6: use cucumber::{given, then, when};
9: 7: use fake::locales::EN;
10: 8: use fake::{faker::internet::raw::FreeEmail, Fake};
11: 9: 
12: 10: use super::wait;
13: 11: #[given("I pass")]
14: 12: pub async fn i_pass(_world: &mut AppWorld) -> Result<()> {
15: 13:     tracing::info!("I pass and I trace.");
16: 14:     Ok(())
17: 15: }
18: 16: 
19: 17: #[given("I am on the homepage")]
20: 18: pub async fn navigate_to_homepage(world: &mut AppWorld) -> Result<()> {
21: 19:     world.goto_path("/").await?;
22: 20:     Ok(())
23: 21: }
24: 22: 
25: 23: #[then("I am on the homepage")]
26: 24: pub async fn check_url_for_homepage(world: &mut AppWorld) -> Result<()> {
27: 25:     world.verify_route("/").await?;
28: 26:     Ok(())
29: 27: }
30: 28: 
31: 29: #[given("I click register")]
32: 30: #[when("I click register")]
33: 31: pub async fn click_register(world: &mut AppWorld) -> Result<()> {
34: 32:     world.click(lyx-core-lyx_core_lyx-core-lyx_core_ids::REGISTER_BUTTON_ID).await?;
35: 33:     Ok(())
36: 34: }
37: 35: 
38: 36: #[given("I see the registration form")]
39: 37: #[when("I see the registration form")]
40: 38: #[then("I see the registration form")]
41: 39: pub async fn find_registration_form(world: &mut AppWorld) -> Result<()> {
42: 40:     world.find(lyx-core-lyx_core_lyx-core-lyx_core_ids::REGISTRATION_FORM_ID).await?;
43: 41:     Ok(())
44: 42: }
45: 43: 
46: 44: #[given("I see the login form")]
47: 45: #[when("I see the login form")]
48: 46: #[then("I see the login form")]
49: 47: pub async fn find_login_form(world: &mut AppWorld) -> Result<()> {
50: 48:     world.find(lyx-core-lyx_core_lyx-core-lyx_core_ids::LOGIN_FORM_ID).await?;
51: 49:     Ok(())
52: 50: }
53: 51: 
54: 52: #[given("I am on the registration page")]
55: 53: pub async fn navigate_to_register(world: &mut AppWorld) -> Result<()> {
56: 54:     world.goto_path("/register").await?;
57: 55:     Ok(())
58: 56: }
59: 57: 
60: 58: #[given("I enter valid credentials")]
61: 59: pub async fn fill_form_fields_with_credentials(world: &mut AppWorld) -> Result<()> {
62: 60:     let email = FreeEmail(EN).fake::<String>();
63: 61:     world
64: 62:         .set_field(lyx-core-lyx_core_lyx-core-lyx_core_ids::EMAIL_INPUT_ID, &email)
65: 63:         .await
66: 64:         .expect(&format!(
67: 65:             "To find element with id {} BUT ERROR : ",
68: 66:             lyx-core-lyx_core_lyx-core-lyx_core_ids::EMAIL_INPUT_ID
69: 67:         ));
70: 68:     world.clipboard.insert("email", email);
71: 69:     world
72: 70:         .set_field(lyx-core-lyx_core_lyx-core-lyx_core_ids::PASSWORD_INPUT_ID, lyx-core-lyx_core_lyx-core-lyx_core_ids::PASSWORD)
73: 71:         .await
74: 72:         .expect(&format!(
75: 73:             "To find element with id {} BUT ERROR : ",
76: 74:             lyx-core-lyx_core_lyx-core-lyx_core_ids::PASSWORD_INPUT_ID
77: 75:         ));
78: 76:     world.submit().await?;
79: 77:     world.errors().await?;
80: 78:     wait().await;
81: 79:     Ok(())
82: 80: }
83: 81: 
84: 82: #[given("I enter valid other credentials")]
85: 83: pub async fn fill_form_fields_with_other_credentials(world: &mut AppWorld) -> Result<()> {
86: 84:     let email = FreeEmail(EN).fake::<String>();
87: 85:     world
88: 86:         .set_field(lyx-core-lyx_core_lyx-core-lyx_core_ids::EMAIL_INPUT_ID, &email)
89: 87:         .await
90: 88:         .expect(&format!(
91: 89:             "To find element with id {} BUT ERROR : ",
92: 90:             lyx-core-lyx_core_lyx-core-lyx_core_ids::EMAIL_INPUT_ID
93: 91:         ));
94: 92:     world.clipboard.insert("other_email", email);
95: 93:     world
96: 94:         .set_field(lyx-core-lyx_core_lyx-core-lyx_core_ids::PASSWORD_INPUT_ID, lyx-core-lyx_core_lyx-core-lyx_core_ids::PASSWORD)
97: 95:         .await
98: 96:         .expect(&format!(
99: 97:             "To find element with id {} BUT ERROR : ",
100: 98:             lyx-core-lyx_core_lyx-core-lyx_core_ids::PASSWORD_INPUT_ID
101: 99:         ));
102: 100:     world.submit().await?;
103: 101:     world.errors().await?;
104: 102:     wait().await;
105: 103:     Ok(())
106: 104: }
107: 105: #[given("I re-enter other valid credentials")]
108: 106: #[when("I re-enter other valid credentials")]
109: 107: pub async fn fill_form_fields_with_previous_other_credentials(world: &mut AppWorld) -> Result<()> {
110: 108:     let email = world
111: 109:         .clipboard
112: 110:         .get("other_email")
113: 111:         .cloned()
114: 112:         .ok_or(anyhow!("Can't find other credentials in clipboard"))?;
115: 113:     world
116: 114:         .set_field(lyx-core-lyx_core_lyx-core-lyx_core_ids::EMAIL_INPUT_ID, &email)
117: 115:         .await
118: 116:         .expect("set email field");
119: 117:     world
120: 118:         .set_field(lyx-core-lyx_core_lyx-core-lyx_core_ids::PASSWORD_INPUT_ID, lyx-core-lyx_core_lyx-core-lyx_core_ids::PASSWORD)
121: 119:         .await
122: 120:         .expect("set password field");
123: 121:     world.submit().await?;
124: 122:     world.errors().await?;
125: 123:     Ok(())
126: 124: }
127: 125: 
128: 126: #[when("I enter valid credentials")]
129: 127: #[when("I re-enter valid credentials")]
130: 128: #[given("I re-enter valid credentials")]
131: 129: pub async fn fill_form_fields_with_previous_credentials(world: &mut AppWorld) -> Result<()> {
132: 130:     let email = world.clipboard.get("email").cloned();
133: 131:     let email = if let Some(email) = email {
134: 132:         email
135: 133:     } else {
136: 134:         let email = FreeEmail(EN).fake::<String>();
137: 135:         world.clipboard.insert("email", email.clone());
138: 136:         email
139: 137:     };
140: 138:     world
141: 139:         .set_field(lyx-core-lyx_core_lyx-core-lyx_core_ids::EMAIL_INPUT_ID, &email)
142: 140:         .await
143: 141:         .expect("set email field");
144: 142:     world
145: 143:         .set_field(lyx-core-lyx_core_lyx-core-lyx_core_ids::PASSWORD_INPUT_ID, lyx-core-lyx_core_lyx-core-lyx_core_ids::PASSWORD)
146: 144:         .await
147: 145:         .expect("set password field");
148: 146:     world.submit().await?;
149: 147:     world.errors().await?;
150: 148:     Ok(())
151: 149: }
152: 150: 
153: 151: #[then("I am on the verify email page")]
154: 152: pub async fn check_url_to_be_verify_page(world: &mut AppWorld) -> Result<()> {
155: 153:     world.find(lyx-core-lyx_core_lyx-core-lyx_core_ids::VERIFY_EMAIL_DIV_ID).await?;
156: 154:     Ok(())
157: 155: }
158: 156: #[given("I check my other email for the verification link and code")]
159: 157: #[when("I check my other email for the verification link and code")]
160: 158: pub async fn check_email_other_for_verification_link_and_code(world: &mut AppWorld) -> Result<()> {
161: 159:     tokio::time::sleep(std::time::Duration::from_secs(2)).await;
162: 160:     // we've stored the email with the id
163: 161:     // so we get the id with our email from our clipboard
164: 162:     let email = world
165: 163:         .clipboard
166: 164:         .get("other_email")
167: 165:         .ok_or(anyhow!("email not found in clipboard"))?;
168: 166:     let id = EMAIL_ID_MAP
169: 167:         .read()
170: 168:         .await
171: 169:         .get(email)
172: 170:         .ok_or(anyhow!("{email} not found in EMAIL_ID_MAP"))?
173: 171:         .clone();
174: 172:     // then we use the id to get the message from mailcrab
175: 173:     let body = reqwest::get(format!("http://127.0.0.1:1080/api/message/{}/body", id))
176: 174:         .await
177: 175:         .unwrap()
178: 176:         .text()
179: 177:         .await
180: 178:         .unwrap();
181: 179:     let (code, link) = super::extract_code_and_link(&body)?;
182: 180:     world.clipboard.insert("code", code);
183: 181:     world.clipboard.insert("link", link);
184: 182:     Ok(())
185: 183: }
186: 184: 
187: 185: #[given("I check my email for the verification link and code")]
188: 186: #[when("I check my email for the verification link and code")]
189: 187: pub async fn check_email_for_verification_link_and_code(world: &mut AppWorld) -> Result<()> {
190: 188:     tokio::time::sleep(std::time::Duration::from_secs(2)).await;
191: 189:     // we've stored the email with the id
192: 190:     // so we get the id with our email from our clipboard
193: 191:     let email = world
194: 192:         .clipboard
195: 193:         .get("email")
196: 194:         .ok_or(anyhow!("email not found in clipboard"))?;
197: 195:     let id = EMAIL_ID_MAP
198: 196:         .read()
199: 197:         .await
200: 198:         .get(email)
201: 199:         .ok_or(anyhow!("{email} not found in EMAIL_ID_MAP"))?
202: 200:         .clone();
203: 201:     // then we use the id to get the message from mailcrab
204: 202:     let body = reqwest::get(format!("http://127.0.0.1:1080/api/message/{}/body", id))
205: 203:         .await
206: 204:         .unwrap()
207: 205:         .text()
208: 206:         .await
209: 207:         .unwrap();
210: 208:     let (code, link) = super::extract_code_and_link(&body)?;
211: 209:     world.clipboard.insert("code", code);
212: 210:     world.clipboard.insert("link", link);
213: 211:     Ok(())
214: 212: }
215: 213: 
216: 214: #[given("I copy the code onto the verification link page")]
217: 215: #[when("I copy the code onto the verification link page")]
218: 216: pub async fn copy_code_onto_verification_page(world: &mut AppWorld) -> Result<()> {
219: 217:     let link = world
220: 218:         .clipboard
221: 219:         .get("link")
222: 220:         .ok_or(anyhow!("link not found in clipboard"))?
223: 221:         .clone();
224: 222:     world.goto_url(&link).await?;
225: 223:     let code = world
226: 224:         .clipboard
227: 225:         .get("code")
228: 226:         .ok_or(anyhow!("link not found in clipboard"))?
229: 227:         .clone();
230: 228:     world
231: 229:         .set_field(lyx-core-lyx_core_lyx-core-lyx_core_ids::VERFICATION_CODE_ID, code)
232: 230:         .await
233: 231:         .expect(&format!("Can't find {}", lyx-core-lyx_core_lyx-core-lyx_core_ids::VERFICATION_CODE_ID));
234: 232:     world.submit().await?;
235: 233:     world.click("continue").await?;
236: 234:     wait().await;
237: 235:     Ok(())
238: 236: }
239: 237: 
240: 238: #[when("I click login")]
241: 239: #[given("I click login")]
242: 240: pub async fn click_login(world: &mut AppWorld) -> Result<()> {
243: 241:     world.click(lyx-core-lyx_core_lyx-core-lyx_core_ids::LOGIN_BUTTON_ID).await?;
244: 242:     wait().await;
245: 243:     Ok(())
246: 244: }
247: 245: 
248: 246: #[given("I click logout")]
249: 247: #[when("I click logout")]
250: 248: pub async fn click_logout(world: &mut AppWorld) -> Result<()> {
251: 249:     world.click(lyx-core-lyx_core_lyx-core-lyx_core_ids::LOGOUT_BUTTON_ID).await?;
252: 250:     wait().await;
253: 251:     world.errors().await?;
254: 252:     Ok(())
255: 253: }
256: 254: 
257: 255: #[tracing::instrument]
258: 256: #[given("I am logged out")]
259: 257: #[then("I am logged out")]
260: 258: pub async fn check_ory_kratos_cookie_doesnt_exist(world: &mut AppWorld) -> Result<()> {
261: 259:     let cookies = world.page.get_cookies().await?;
262: 260:     if !cookies
263: 261:         .iter()
264: 262:         .filter(|c| c.name.contains("ory_kratos_session"))
265: 263:         .collect::<Vec<_>>()
266: 264:         .is_empty()
267: 265:     {
268: 266:         tracing::error!("{cookies:#?}");
269: 267:         Err(anyhow!("Ory kratos cookie exists."))
270: 268:     } else {
271: 269:         Ok(())
272: 270:     }
273: 271: }
274: 272: 
275: 273: #[then("I am logged in")]
276: 274: #[given("I am logged in")]
277: 275: pub async fn check_ory_kratos_cookie_exists(world: &mut AppWorld) -> Result<()> {
278: 276:     if world
279: 277:         .page
280: 278:         .get_cookies()
281: 279:         .await?
282: 280:         .iter()
283: 281:         .filter(|c| c.name.contains("ory_kratos_session"))
284: 282:         .collect::<Vec<_>>()
285: 283:         .is_empty()
286: 284:     {
287: 285:         Err(anyhow!("Ory kratos cookie doesn't exists."))
288: 286:     } else {
289: 287:         Ok(())
290: 288:     }
291: 289: }
292: 290: 
293: 291: #[given("I add lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_example post")]
294: 292: #[when("I add lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_example post")]
295: 293: pub async fn add_content_to_box(world: &mut AppWorld) -> Result<()> {
296: 294:     let content: Vec<String> = fake::faker::lorem::en::Words(0..10).fake();
297: 295:     let content = content.join(" ");
298: 296:     world.clipboard.insert("content", content.clone());
299: 297:     world
300: 298:         .set_field(lyx-core-lyx_core_lyx-core-lyx_core_ids::POST_POST_TEXT_AREA_ID, content)
301: 299:         .await?;
302: 300:     world.click(lyx-core-lyx_core_lyx-core-lyx_core_ids::POST_POST_SUBMIT_ID).await?;
303: 301:     Ok(())
304: 302: }
305: 303: 
306: 304: #[given("I see lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_example content posted")]
307: 305: #[then("I see lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_example content posted")]
308: 306: #[when("I see lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_example content posted")]
309: 307: pub async fn see_my_content_posted(world: &mut AppWorld) -> Result<()> {
310: 308:     world.click(lyx-core-lyx_core_lyx-core-lyx_core_ids::POST_SHOW_LIST_BUTTON_ID).await?;
311: 309:     let content = world
312: 310:         .clipboard
313: 311:         .get("content")
314: 312:         .cloned()
315: 313:         .ok_or(anyhow!("Can't find content in clipboard"))?;
316: 314:     world.errors().await?;
317: 315:     let _ = world.find_text(content).await?;
318: 316:     Ok(())
319: 317: }
320: 318: 
321: 319: #[when("I see error")]
322: 320: #[then("I see error")]
323: 321: pub async fn see_err(world: &mut AppWorld) -> Result<()> {
324: 322:     wait().await;
325: 323:     if world.errors().await.is_ok() {
326: 324:         return Err(anyhow!("Expecting an error."));
327: 325:     }
328: 326:     Ok(())
329: 327: }
330: 328: 
331: 329: #[when("I don't see error")]
332: 330: #[then("I don't see error")]
333: 331: pub async fn dont_see_err(world: &mut AppWorld) -> Result<()> {
334: 332:     world.errors().await?;
335: 333:     Ok(())
336: 334: }
337: 335: 
338: 336: #[given("I add other email as editor")]
339: 337: #[when("I add other email as editor")]
340: 338: pub async fn add_other_email_as_editor(world: &mut AppWorld) -> Result<()> {
341: 339:     let other_email = world
342: 340:         .clipboard
343: 341:         .get("other_email")
344: 342:         .cloned()
345: 343:         .ok_or(anyhow!("Can't find other email."))?;
346: 344:     world
347: 345:         .set_field(lyx-core-lyx_core_lyx-core-lyx_core_ids::POST_ADD_EDITOR_INPUT_ID, other_email)
348: 346:         .await?;
349: 347:     world.click(lyx-core-lyx_core_lyx-core-lyx_core_ids::POST_ADD_EDITOR_SUBMIT_ID).await?;
350: 348:     Ok(())
351: 349: }
352: 350: 
353: 351: #[when("I logout")]
354: 352: pub async fn i_logout(world: &mut AppWorld) -> Result<()> {
355: 353:     world.click(lyx-core-lyx_core_lyx-core-lyx_core_ids::LOGOUT_BUTTON_ID).await?;
356: 354:     world.errors().await?;
357: 355:     Ok(())
358: 356: }
359: 357: #[when("I edit lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_example post")]
360: 358: pub async fn add_new_edit_content_to_previous(world: &mut AppWorld) -> Result<()> {
361: 359:     let edit_content: Vec<String> = fake::faker::lorem::en::Words(0..10).fake();
362: 360:     let edit_content = edit_content.join(" ");
363: 361:     world.clipboard.insert("edit_content", edit_content.clone());
364: 362:     world
365: 363:         .set_field(lyx-core-lyx_core_lyx-core-lyx_core_ids::POST_EDIT_TEXT_AREA_ID, edit_content)
366: 364:         .await?;
367: 365:     world.click(lyx-core-lyx_core_lyx-core-lyx_core_ids::POST_EDIT_SUBMIT_ID).await?;
368: 366:     Ok(())
369: 367: }
370: 368: #[then("I see my new content posted")]
371: 369: pub async fn new_content_boom_ba_da_boom(world: &mut AppWorld) -> Result<()> {
372: 370:     let content = world
373: 371:         .clipboard
374: 372:         .get("edit_content")
375: 373:         .cloned()
376: 374:         .ok_or(anyhow!("Can't find content in clipboard"))?;
377: 375:     world.find_text(content).await?;
378: 376:     Ok(())
379: 377: }
380: 378: #[then("I don't see old content")]
381: 379: pub async fn dont_see_old_content_posted(world: &mut AppWorld) -> Result<()> {
382: 380:     let content = world
383: 381:         .clipboard
384: 382:         .get("content")
385: 383:         .cloned()
386: 384:         .ok_or(anyhow!("Can't find content in clipboard"))?;
387: 385:     if world.find_text(content).await.is_ok() {
388: 386:         return Err(anyhow!("But I do see old content..."));
389: 387:     }
390: 388:     Ok(())
391: 389: }
392: 390: 
393: 391: #[given("I click show post list")]
394: 392: #[when("I click show post list")]
395: 393: pub async fn i_click_show_post_list(world: &mut AppWorld) -> Result<()> {
396: 394:     world.click(lyx-core-lyx_core_lyx-core-lyx_core_ids::POST_SHOW_LIST_BUTTON_ID).await?;
397: 395:     Ok(())
398: 396: }
399: 397: 
400: 398: #[given("I clear cookies")]
401: 399: pub async fn i_clear_cookies(world: &mut AppWorld) -> Result<()> {
402: 400:     let cookies = world
403: 401:         .page
404: 402:         .get_cookies()
405: 403:         .await?
406: 404:         .into_iter()
407: 405:         .map(|cookie| {
408: 406:             DeleteCookiesParams::from_cookie(&CookieParam {
409: 407:                 name: cookie.name,
410: 408:                 value: cookie.value,
411: 409:                 url: None, // Since there's no direct field for URL, it's set as None
412: 410:                 domain: Some(cookie.domain),
413: 411:                 path: Some(cookie.path),
414: 412:                 secure: Some(cookie.secure),
415: 413:                 http_only: Some(cookie.http_only),
416: 414:                 same_site: cookie.same_site,
417: 415:                 // Assuming you have a way to convert f64 expires to TimeSinceEpoch
418: 416:                 expires: None,
419: 417:                 priority: Some(cookie.priority),
420: 418:                 same_party: Some(cookie.same_party),
421: 419:                 source_scheme: Some(cookie.source_scheme),
422: 420:                 source_port: Some(cookie.source_port),
423: 421:                 partition_key: cookie.partition_key,
424: 422:                 // Note: `partition_key_opaque` is omitted since it doesn't have a direct mlyx-platform-lyx_platform_lyx-platform-lyx_platform_apping
425: 423:             })
426: 424:         })
427: 425:         .collect();
428: 426:     world.page.delete_cookies(cookies).await?;
429: 427:     Ok(())
430: 428: }
431: 429: 
432: 430: #[given("I click recover email")]
433: 431: pub async fn click_recover_email(world: &mut AppWorld) -> Result<()> {
434: 432:     world.click(lyx-core-lyx_core_lyx-core-lyx_core_ids::RECOVER_EMAIL_BUTTON_ID).await?;
435: 433:     wait().await;
436: 434:     Ok(())
437: 435: }
438: 436: #[given("I submit valid recovery email")]
439: 437: pub async fn submit_valid_recovery_email(world: &mut AppWorld) -> Result<()> {
440: 438:     let email = world
441: 439:         .clipboard
442: 440:         .get("email")
443: 441:         .cloned()
444: 442:         .ok_or(anyhow!("Expecting email in clipboard if recovering email."))?;
445: 443:     world
446: 444:         .set_field(lyx-core-lyx_core_lyx-core-lyx_core_ids::EMAIL_INPUT_ID, &email)
447: 445:         .await
448: 446:         .expect("set email field");
449: 447:     world.submit().await?;
450: 448:     world.errors().await?;
451: 449:     Ok(())
452: 450: }
453: 451: #[given("I check my email for recovery link and code")]
454: 452: pub async fn check_email_for_recovery_link_and_code(world: &mut AppWorld) -> Result<()> {
455: 453:     tokio::time::sleep(std::time::Duration::from_secs(1)).await;
456: 454:     // we've stored the email with the id
457: 455:     // so we get the id with our email from our clipboard
458: 456:     let email = world
459: 457:         .clipboard
460: 458:         .get("email")
461: 459:         .ok_or(anyhow!("email not found in clipboard"))?;
462: 460:     let id = EMAIL_ID_MAP
463: 461:         .read()
464: 462:         .await
465: 463:         .get(email)
466: 464:         .ok_or(anyhow!("{email} not found in EMAIL_ID_MAP"))?
467: 465:         .clone();
468: 466:     // then we use the id to get the message from mailcrab
469: 467:     let body = reqwest::get(format!("http://127.0.0.1:1080/api/message/{}/body", id))
470: 468:         .await
471: 469:         .unwrap()
472: 470:         .text()
473: 471:         .await
474: 472:         .unwrap();
475: 473:     let code = super::extract_code(&body)?;
476: 474:     world.clipboard.insert("recovery_code", code);
477: 475:     Ok(())
478: 476: }
479: 477: 
480: 478: #[when("I copy the code onto the recovery link page")]
481: 479: pub async fn copy_code_onto_recovery_page(world: &mut AppWorld) -> Result<()> {
482: 480:     // we should figure out how to be on the right page, will this just work?
483: 481: 
484: 482:     let code = world
485: 483:         .clipboard
486: 484:         .get("recovery_code")
487: 485:         .ok_or(anyhow!("link not found in clipboard"))?
488: 486:         .clone();
489: 487:     world
490: 488:         .set_field(lyx-core-lyx_core_lyx-core-lyx_core_ids::VERFICATION_CODE_ID, code)
491: 489:         .await
492: 490:         .expect(&format!("Can't find {}", lyx-core-lyx_core_lyx-core-lyx_core_ids::VERFICATION_CODE_ID));
493: 491:     world.submit().await?;
494: 492:     wait().await;
495: 493:     Ok(())
496: 494: }
497: 495: 
498: 496: #[then("I am on the settings page")]
499: 497: pub async fn im_on_settings_page(world: &mut AppWorld) -> Result<()> {
500: 498:     wait().await;
501: 499:     world.url_contains("/settings").await?;
502: 500:     Ok(())
503: 501: }
504: 502: 
505: 503: #[given("I enter recovery credentials")]
506: 504: #[when("I enter recovery credentials")]
507: 505: pub async fn i_enter_a_new_recovery_password(world: &mut AppWorld) -> Result<()> {
508: 506:     let email = world
509: 507:         .clipboard
510: 508:         .get("email")
511: 509:         .cloned()
512: 510:         .ok_or(anyhow!("Can't find credentials in clipboard"))?;
513: 511:     world
514: 512:         .set_field(lyx-core-lyx_core_lyx-core-lyx_core_ids::EMAIL_INPUT_ID, &email)
515: 513:         .await
516: 514:         .expect("set email field");
517: 515:     world
518: 516:         .set_field(lyx-core-lyx_core_lyx-core-lyx_core_ids::PASSWORD_INPUT_ID, lyx-core-lyx_core_lyx-core-lyx_core_ids::RECOVERY_PASSWORD)
519: 517:         .await
520: 518:         .expect("set password field");
521: 519:     let code = world
522: 520:         .clipboard
523: 521:         .get("recovery_code")
524: 522:         .ok_or(anyhow!("link not found in clipboard"))?
525: 523:         .clone();
526: 524:     world
527: 525:         .set_field(lyx-core-lyx_core_lyx-core-lyx_core_ids::VERFICATION_CODE_ID, code)
528: 526:         .await
529: 527:         .expect(&format!("Can't find {}", lyx-core-lyx_core_lyx-core-lyx_core_ids::VERFICATION_CODE_ID));
530: 528:     world.submit().await?;
531: 529:     wait().await;
532: 530:     Ok(())
533: 531: }
534: ```
```
