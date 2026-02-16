1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\encryption.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\encryption.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\encryption.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\encryption.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\encryption.rs
10: 8: ```rust
11: 9: use aes_gcm::{
12: 10:     Aes256Gcm, Nonce,
13: 11:     aead::{Aead, AeadCore, KeyInit, OsRng},
14: 12: };
15: 13: use base64::{Engine, engine::general_purpose};
16: 14: use diesel::{ExpressionMethods, QueryDsl, RunQueryDsl};
17: 15: use rand::RngCore;
18: 16: use secrecy::{ExposeSecret, SecretString};
19: 17: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_macros::bad_argument;
20: 18: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types::{
21: 19:     DBConnection,
22: 20:     database::{schema::secrets, lyx-core-lyx_core_lyx-core-lyx_core_superposition_schema::lyx-core-lyx_core_lyx-core-lyx_core_superposition::workspaces},
23: 21:     result,
24: 22: };
25: 23: 
26: 24: use crate::service::types::{AppEnv, EncryptionKey, SchemaName, WorkspaceContext};
27: 25: 
28: 26: const NONCE_SIZE: usize = 12;
29: 27: const ENCRYPTION_KEY_BYTE_LENGTH: usize = 32;
30: 28: 
31: 29: #[derive(Debug)]
32: 30: pub enum EncryptionError {
33: 31:     EncryptionFailed(String),
34: 32:     DecryptionFailed(String),
35: 33:     InvalidKey(String),
36: 34:     InvalidCiphertext(String),
37: 35: }
38: 36: 
39: 37: impl std::fmt::Display for EncryptionError {
40: 38:     fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
41: 39:         match self {
42: 40:             EncryptionError::EncryptionFailed(msg) => {
43: 41:                 write!(f, "Encryption failed: {}", msg)
44: 42:             }
45: 43:             EncryptionError::DecryptionFailed(msg) => {
46: 44:                 write!(f, "Decryption failed: {}", msg)
47: 45:             }
48: 46:             EncryptionError::InvalidKey(msg) => write!(f, "Invalid key: {}", msg),
49: 47:             EncryptionError::InvalidCiphertext(msg) => {
50: 48:                 write!(f, "Invalid ciphertext: {}", msg)
51: 49:             }
52: 50:         }
53: 51:     }
54: 52: }
55: 53: 
56: 54: impl std::error::Error for EncryptionError {}
57: 55: 
58: 56: pub fn generate_encryption_key() -> SecretString {
59: 57:     let mut key_bytes = [0u8; ENCRYPTION_KEY_BYTE_LENGTH];
60: 58:     OsRng.fill_bytes(&mut key_bytes);
61: 59:     SecretString::from(general_purpose::STANDARD.encode(key_bytes))
62: 60: }
63: 61: 
64: 62: pub fn encrypt_secret(
65: 63:     plaintext: &str,
66: 64:     key: &SecretString,
67: 65: ) -> Result<String, EncryptionError> {
68: 66:     let key_bytes = general_purpose::STANDARD
69: 67:         .decode(key.expose_secret())
70: 68:         .map_err(|e| {
71: 69:             EncryptionError::InvalidKey(format!("Failed to decode key: {}", e))
72: 70:         })?;
73: 71: 
74: 72:     if key_bytes.len() != ENCRYPTION_KEY_BYTE_LENGTH {
75: 73:         return Err(EncryptionError::InvalidKey(format!(
76: 74:             "Key must be {ENCRYPTION_KEY_BYTE_LENGTH} bytes, got {}",
77: 75:             key_bytes.len()
78: 76:         )));
79: 77:     }
80: 78: 
81: 79:     let cipher = Aes256Gcm::new_from_slice(&key_bytes).map_err(|e| {
82: 80:         EncryptionError::InvalidKey(format!("Failed to create cipher: {}", e))
83: 81:     })?;
84: 82: 
85: 83:     let nonce = Aes256Gcm::generate_nonce(OsRng);
86: 84: 
87: 85:     let ciphertext = cipher.encrypt(&nonce, plaintext.as_bytes()).map_err(|e| {
88: 86:         EncryptionError::EncryptionFailed(format!("AES-GCM encryption failed: {}", e))
89: 87:     })?;
90: 88: 
91: 89:     let mut result = nonce.to_vec();
92: 90:     result.extend_from_slice(&ciphertext);
93: 91: 
94: 92:     Ok(general_purpose::STANDARD.encode(result))
95: 93: }
96: 94: 
97: 95: pub fn decrypt_secret(
98: 96:     ciphertext: &str,
99: 97:     key: &SecretString,
100: 98: ) -> Result<SecretString, EncryptionError> {
101: 99:     let key_bytes = general_purpose::STANDARD
102: 100:         .decode(key.expose_secret())
103: 101:         .map_err(|e| {
104: 102:             EncryptionError::InvalidKey(format!("Failed to decode key: {}", e))
105: 103:         })?;
106: 104: 
107: 105:     if key_bytes.len() != ENCRYPTION_KEY_BYTE_LENGTH {
108: 106:         return Err(EncryptionError::InvalidKey(format!(
109: 107:             "Key must be {ENCRYPTION_KEY_BYTE_LENGTH} bytes, got {}",
110: 108:             key_bytes.len()
111: 109:         )));
112: 110:     }
113: 111: 
114: 112:     let cipher = Aes256Gcm::new_from_slice(&key_bytes).map_err(|e| {
115: 113:         EncryptionError::InvalidKey(format!("Failed to create cipher: {}", e))
116: 114:     })?;
117: 115: 
118: 116:     let decoded_data = general_purpose::STANDARD.decode(ciphertext).map_err(|e| {
119: 117:         EncryptionError::InvalidCiphertext(format!("Failed to decode ciphertext: {}", e))
120: 118:     })?;
121: 119: 
122: 120:     let Some((nonce_bytes, ciphertext_bytes)) = decoded_data.split_at_checked(NONCE_SIZE)
123: 121:     else {
124: 122:         return Err(EncryptionError::InvalidCiphertext(format!(
125: 123:             "Ciphertext too short, expected at least {} bytes",
126: 124:             NONCE_SIZE
127: 125:         )));
128: 126:     };
129: 127:     let nonce = Nonce::from_slice(nonce_bytes);
130: 128: 
131: 129:     let plaintext_bytes = cipher.decrypt(nonce, ciphertext_bytes).map_err(|e| {
132: 130:         EncryptionError::DecryptionFailed(format!("AES-GCM decryption failed: {}", e))
133: 131:     })?;
134: 132: 
135: 133:     String::from_utf8(plaintext_bytes)
136: 134:         .map(SecretString::from)
137: 135:         .map_err(|e| {
138: 136:             EncryptionError::DecryptionFailed(format!(
139: 137:                 "Invalid UTF-8 in plaintext: {}",
140: 138:                 e
141: 139:             ))
142: 140:         })
143: 141: }
144: 142: 
145: 143: pub fn decrypt_with_fallback(
146: 144:     ciphertext: &str,
147: 145:     encryption_key: &EncryptionKey,
148: 146: ) -> Result<SecretString, EncryptionError> {
149: 147:     match decrypt_secret(ciphertext, &encryption_key.current_key) {
150: 148:         Ok(plaintext) => Ok(plaintext),
151: 149:         Err(e) => {
152: 150:             if let Some(ref prev_key) = encryption_key.previous_key {
153: 151:                 log::info!("Current key failed, trying previous key for decryption");
154: 152:                 decrypt_secret(ciphertext, prev_key).map_err(|_| {
155: 153:                     EncryptionError::DecryptionFailed(
156: 154:                         "Failed to decrypt with both current and previous keys"
157: 155:                             .to_string(),
158: 156:                     )
159: 157:                 })
160: 158:             } else {
161: 159:                 Err(e)
162: 160:             }
163: 161:         }
164: 162:     }
165: 163: }
166: 164: 
167: 165: pub fn encrypt_workspace_key(
168: 166:     workspace_key: &SecretString,
169: 167:     current_key: &SecretString,
170: 168: ) -> Result<String, EncryptionError> {
171: 169:     encrypt_secret(workspace_key.expose_secret(), current_key)
172: 170: }
173: 171: 
174: 172: pub fn decrypt_workspace_key(
175: 173:     encrypted_workspace_key: &str,
176: 174:     master_encryption_key: &EncryptionKey,
177: 175: ) -> Result<SecretString, EncryptionError> {
178: 176:     decrypt_with_fallback(encrypted_workspace_key, master_encryption_key)
179: 177: }
180: 178: 
181: 179: pub async fn get_master_encryption_keys(
182: 180:     kms_lyx-core-lyx_core_lyx-core-lyx_core_client: &Option<aws_sdk_kms::Client>,
183: 181:     lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_env: &AppEnv,
184: 182: ) -> Result<Option<EncryptionKey>, EncryptionError> {
185: 183:     match lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_env {
186: 184:         AppEnv::DEV | AppEnv::TEST => {
187: 185:             let env_key = std::env::var("MASTER_ENCRYPTION_KEY").ok();
188: 186:             let Some(current_key) = env_key.map(SecretString::from) else {
189: 187:                 log::info!(
190: 188:                     "MASTER_ENCRYPTION_KEY not set - secrets functionality will be disabled."
191: 189:                 );
192: 190:                 return Ok(None);
193: 191:             };
194: 192: 
195: 193:             let previous_key = std::env::var("PREVIOUS_MASTER_ENCRYPTION_KEY")
196: 194:                 .ok()
197: 195:                 .map(SecretString::from);
198: 196: 
199: 197:             Ok(Some(EncryptionKey {
200: 198:                 current_key,
201: 199:                 previous_key,
202: 200:             }))
203: 201:         }
204: 202:         _ => {
205: 203:             let kms_lyx-core-lyx_core_lyx-core-lyx_core_client = kms_lyx-core-lyx_core_lyx-core-lyx_core_client.clone().unwrap();
206: 204:             let decrypted_master_key =
207: 205:                 crate::aws::kms::decrypt_opt(kms_lyx-core-lyx_core_lyx-core-lyx_core_client.clone(), "MASTER_ENCRYPTION_KEY")
208: 206:                     .await
209: 207:                     .map(SecretString::from);
210: 208:             let Some(current_key) = decrypted_master_key else {
211: 209:                 log::info!(
212: 210:                     "MASTER_ENCRYPTION_KEY not set - secrets functionality will be disabled."
213: 211:                 );
214: 212:                 return Ok(None);
215: 213:             };
216: 214: 
217: 215:             let previous_key = crate::aws::kms::decrypt_opt(
218: 216:                 kms_lyx-core-lyx_core_lyx-core-lyx_core_client,
219: 217:                 "PREVIOUS_MASTER_ENCRYPTION_KEY",
220: 218:             )
221: 219:             .await
222: 220:             .map(SecretString::from);
223: 221: 
224: 222:             Ok(Some(EncryptionKey {
225: 223:                 current_key,
226: 224:                 previous_key,
227: 225:             }))
228: 226:         }
229: 227:     }
230: 228: }
231: 229: 
232: 230: fn re_encrypt_secrets(
233: 231:     conn: &mut DBConnection,
234: 232:     schema_name: &SchemaName,
235: 233:     current_key: &SecretString,
236: 234:     new_key: &SecretString,
237: 235:     user_email: &str,
238: 236: ) -> result::Result<i64> {
239: 237:     let all_secrets: Vec<(String, String)> = secrets::table
240: 238:         .select((secrets::name, secrets::encrypted_value))
241: 239:         .schema_name(schema_name)
242: 240:         .load(conn)?;
243: 241: 
244: 242:     if all_secrets.is_empty() {
245: 243:         return Ok(0);
246: 244:     }
247: 245: 
248: 246:     let now = chrono::Utc::now();
249: 247: 
250: 248:     for (name, encrypted_value) in &all_secrets {
251: 249:         let decrypted_value = decrypt_secret(encrypted_value, current_key)
252: 250:             .map_err(|e| bad_argument!("Failed to decrypt secret '{}': {}", name, e))?;
253: 251: 
254: 252:         let new_encrypted_value =
255: 253:             encrypt_secret(decrypted_value.expose_secret(), new_key).map_err(|e| {
256: 254:                 bad_argument!("Failed to encrypt secret '{}' with new key: {}", name, e)
257: 255:             })?;
258: 256: 
259: 257:         diesel::update(secrets::table.find(&name))
260: 258:             .set((
261: 259:                 secrets::encrypted_value.eq(&new_encrypted_value),
262: 260:                 secrets::last_modified_by.eq(user_email),
263: 261:                 secrets::last_modified_at.eq(now),
264: 262:                 secrets::change_reason.eq("Key rotation"),
265: 263:             ))
266: 264:             .schema_name(schema_name)
267: 265:             .execute(conn)?;
268: 266:     }
269: 267: 
270: 268:     Ok(all_secrets.len() as i64)
271: 269: }
272: 270: 
273: 271: pub fn rotate_workspace_encryption_key_helper(
274: 272:     workspace_context: &WorkspaceContext,
275: 273:     conn: &mut DBConnection,
276: 274:     master_encryption_key: &EncryptionKey,
277: 275:     user_email: &str,
278: 276: ) -> result::Result<i64> {
279: 277:     let current_key = decrypt_workspace_key(
280: 278:         &workspace_context.settings.encryption_key,
281: 279:         master_encryption_key,
282: 280:     )
283: 281:     .map_err(|e| {
284: 282:         log::error!("Failed to decrypt current workspace key for  {}", e);
285: 283:         bad_argument!("Failed to decrypt workspace encryption key")
286: 284:     })?;
287: 285: 
288: 286:     let new_key = generate_encryption_key();
289: 287:     let encrypted_new_key =
290: 288:         encrypt_workspace_key(&new_key, &master_encryption_key.current_key).map_err(
291: 289:             |e| {
292: 290:                 log::error!("Failed to encrypt new workspace key: {}", e);
293: 291:                 bad_argument!("Failed to encrypt new workspace key: {}", e)
294: 292:             },
295: 293:         )?;
296: 294: 
297: 295:     // Re-encrypt secrets if we have an existing key, otherwise this is initialization
298: 296:     let total_secrets_re_encrypted = re_encrypt_secrets(
299: 297:         conn,
300: 298:         &workspace_context.schema_name,
301: 299:         &current_key,
302: 300:         &new_key,
303: 301:         user_email,
304: 302:     )
305: 303:     .unwrap_or_else(|_| {
306: 304:         log::info!(
307: 305:             "Initializing encryption key for workspace {}",
308: 306:             workspace_context.settings.workspace_name
309: 307:         );
310: 308:         0 // Just return i64, not Result<i64>
311: 309:     });
312: 310: 
313: 311:     let rotation_time = chrono::Utc::now();
314: 312: 
315: 313:     // Update workspace with new encrypted key
316: 314:     diesel::update(workspaces::dsl::workspaces.find((
317: 315:         &workspace_context.organisation_id.0,
318: 316:         &workspace_context.settings.workspace_name,
319: 317:     )))
320: 318:     .set((
321: 319:         workspaces::dsl::encryption_key.eq(&encrypted_new_key),
322: 320:         workspaces::dsl::key_rotated_at.eq(Some(rotation_time)),
323: 321:         workspaces::dsl::last_modified_at.eq(rotation_time),
324: 322:         workspaces::dsl::last_modified_by.eq(user_email),
325: 323:     ))
326: 324:     .execute(conn)?;
327: 325: 
328: 326:     log::info!(
329: 327:         "Rotated encryption key for workspace {}. total number of re-encrypted secrets {}",
330: 328:         workspace_context.settings.workspace_name,
331: 329:         total_secrets_re_encrypted
332: 330:     );
333: 331: 
334: 332:     Ok(total_secrets_re_encrypted)
335: 333: }
336: 334: 
337: 335: #[cfg(test)]
338: 336: mod tests {
339: 337:     use super::*;
340: 338: 
341: 339:     #[test]
342: 340:     fn test_generate_key() {
343: 341:         let key = generate_encryption_key();
344: 342:         let decoded = general_purpose::STANDARD
345: 343:             .decode(key.expose_secret())
346: 344:             .unwrap();
347: 345:         assert_eq!(decoded.len(), ENCRYPTION_KEY_BYTE_LENGTH);
348: 346:     }
349: 347: 
350: 348:     #[test]
351: 349:     fn test_encrypt_decrypt() {
352: 350:         let key = generate_encryption_key();
353: 351:         let plaintext = "my secret value";
354: 352: 
355: 353:         let encrypted = encrypt_secret(plaintext, &key).unwrap();
356: 354:         let decrypted = decrypt_secret(&encrypted, &key).unwrap();
357: 355: 
358: 356:         assert_eq!(plaintext, decrypted.expose_secret());
359: 357:     }
360: 358: 
361: 359:     #[test]
362: 360:     fn test_decrypt_with_wrong_key_fails() {
363: 361:         let key1 = generate_encryption_key();
364: 362:         let key2 = generate_encryption_key();
365: 363:         let plaintext = "my secret";
366: 364: 
367: 365:         let encrypted = encrypt_secret(plaintext, &key1).unwrap();
368: 366:         let result = decrypt_secret(&encrypted, &key2);
369: 367: 
370: 368:         assert!(result.is_err());
371: 369:     }
372: 370: 
373: 371:     #[test]
374: 372:     fn test_decrypt_with_fallback() {
375: 373:         let old_key = generate_encryption_key();
376: 374:         let new_key = generate_encryption_key();
377: 375:         let plaintext = "my secret";
378: 376: 
379: 377:         let encrypted = encrypt_secret(plaintext, &old_key).unwrap();
380: 378: 
381: 379:         let encryption_key = EncryptionKey {
382: 380:             current_key: new_key,
383: 381:             previous_key: Some(old_key),
384: 382:         };
385: 383: 
386: 384:         let decrypted = decrypt_with_fallback(&encrypted, &encryption_key).unwrap();
387: 385:         assert_eq!(plaintext, decrypted.expose_secret());
388: 386:     }
389: 387: }
390: 388: ```
391: 389: ```
392: 390: ```
393: 391: ```
394: ```
```

