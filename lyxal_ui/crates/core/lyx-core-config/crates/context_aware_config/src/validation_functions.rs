1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\validation_functions.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\validation_functions.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\validation_functions.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\validation_functions.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\validation_functions.rs
10: 8: ```rust
11: 9: use std::{process::Command, str};
12: 10: 
13: 11: use serde::Serialize;
14: 12: use lyx-core-lyx_core_lyx-core-lyx_core_service_utils::service::types::{EncryptionKey, WorkspaceContext};
15: 13: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_macros::{unexpected_error, validation_error};
16: 14: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types::{
17: 15:     DBConnection,
18: 16:     api::functions::{FunctionExecutionRequest, FunctionExecutionResponse},
19: 17:     database::models::cac::{FunctionCode, FunctionRuntimeVersion, FunctionType},
20: 18:     result as lyx-core-lyx_core_lyx-core-lyx_core_superposition,
21: 19: };
22: 20: 
23: 21: use crate::api::functions::helpers::inject_secrets_and_variables_into_code;
24: 22: 
25: 23: static FUNCTION_ENV_VARIABLES: &str =
26: 24:     "HTTP_PROXY,HTTPS_PROXY,HTTP_PROXY_HOST,HTTP_PROXY_PORT,NO_PROXY";
27: 25: 
28: 26: const CODE_TOKEN: &str = "{replaceme-with-code}";
29: 27: 
30: 28: const FUNCTION_ENV_TOKEN: &str = "{function-envs}";
31: 29: 
32: 30: const FUNCTION_NAME_TOKEN: &str = "{function-name}";
33: 31: 
34: 32: const FUNCTION_NAME: &str = "execute";
35: 33: 
36: 34: const FUNCTION_TYPE_CHECK_SNIPPET: &str = r#"const vm = require("node:vm")
37: 35:         const axios = require("./target/node_modules/axios/dist/node/axios.cjs")
38: 36:         const script = new vm.Script(\`
39: 37: 
40: 38:         {replaceme-with-code}
41: 39: 
42: 40:         if(typeof({function-name})!="function")
43: 41:         {
44: 42:             throw Error("{function-name} is not of function type")
45: 43:         }\`);
46: 44: 
47: 45:         script.runInNewContext({axios,console}, { timeout: 1500 });
48: 46:         "#;
49: 47: 
50: 48: const FUNCTION_EXECUTION_SNIPPET: &str = r#"
51: 49:         const vm = require("node:vm")
52: 50:         const axios = require("./target/node_modules/axios/dist/node/axios.cjs")
53: 51:         const { parentPort } = require("node:worker_threads")
54: 52:         const script = new vm.Script(\`
55: 53: 
56: 54:         {replaceme-with-code}
57: 55:         Promise.resolve({function-invocation}).then((output) => {
58: 56:             if({condition}) {
59: 57:                 throw new Error("The function did not return a value that was expected. Check the return type and logic of the function")
60: 58:             }
61: 59:             parentPort.postMessage({tag: "result", value: output});
62: 60:             return output;
63: 61:         }).catch((err)=> {
64: 62:             throw new Error(err)
65: 63:         });\`);
66: 64: 
67: 65:         script.runInNewContext({ axios, console, parentPort }, { timeout: 1500 });
68: 66:         "#;
69: 67: 
70: 68: const CODE_GENERATION_SNIPPET: &str = r#"
71: 69:     const { Worker, isMainThread, threadId } =  require("node:worker_threads");
72: 70:     if (isMainThread) {
73: 71:         let function_env_variables = "{function-envs}"
74: 72:         let variablesToKeep = []
75: 73:         variablesToKeep = function_env_variables.split(',').map(variable => variable.trim());
76: 74:         for (const key in process.env) {
77: 75:             if (!variablesToKeep.includes(key)) {
78: 76:                 delete process.env[key];
79: 77:             }
80: 78:         }
81: 79: 
82: 80: 
83: 81:     // starting worker thread , making separated from the main thread
84: 82:     function runService() {
85: 83:         return new Promise((resolve, reject) => {
86: 84:         let result = null;
87: 85:         const worker = new Worker(
88: 86:             `{replaceme-with-code}`,{ eval:true }
89: 87:         );
90: 88:         worker.on("message", (msg) => {
91: 89:             if (typeof msg === 'object' && 'tag' in msg) {
92: 90:                 result = msg;
93: 91:             } else {
94: 92:                 console.log(msg);
95: 93:             }
96: 94:         });
97: 95:         worker.on("error", (err) => {
98: 96:             clearTimeout(tl);
99: 97:             console.error(err.message);
100: 98:             process.exit(1);
101: 99:         });
102: 100:         worker.on("exit", (code) => {
103: 101:             clearTimeout(tl);
104: 102:             if (code != 0) {
105: 103:                 console.error(`Script stopped with exit code ${code}`);
106: 104:                 worker.terminate();
107: 105:                 throw new Error(code);
108: 106:             } else {
109: 107:                 resolve(result);
110: 108:             }
111: 109:         });
112: 110: 
113: 111:         function timelimit() {
114: 112:             worker.terminate();
115: 113:             throw new Error("time limit exceeded");
116: 114:         }
117: 115: 
118: 116:         // terminate worker thread if execution time exceed 10 secs
119: 117:         var tl = setTimeout(timelimit, 10000);
120: 118:         return result;
121: 119:         });
122: 120:     }
123: 121: 
124: 122:     runService()
125: 123:         .then((v) => console.log("|", v.value))
126: 124:         .catch((err) => console.error(err));
127: 125:     }
128: 126:     "#;
129: 127: 
130: 128: fn type_check(code_str: &FunctionCode) -> String {
131: 129:     FUNCTION_TYPE_CHECK_SNIPPET
132: 130:         .replace(FUNCTION_NAME_TOKEN, FUNCTION_NAME)
133: 131:         .replace(CODE_TOKEN, code_str)
134: 132: }
135: 133: 
136: 134: #[derive(Serialize)]
137: 135: struct FunctionPayload {
138: 136:     version: FunctionRuntimeVersion,
139: 137:     #[serde(flatten)]
140: 138:     payload: FunctionExecutionRequest,
141: 139: }
142: 140: 
143: 141: fn generate_fn_code(
144: 142:     code_str: &FunctionCode,
145: 143:     function_args: &FunctionExecutionRequest,
146: 144:     runtime_version: FunctionRuntimeVersion,
147: 145: ) -> String {
148: 146:     let payload = match runtime_version {
149: 147:         FunctionRuntimeVersion::V1 => FunctionPayload {
150: 148:             version: runtime_version,
151: 149:             payload: function_args.clone(),
152: 150:         },
153: 151:     };
154: 152: 
155: 153:     let output_check = match function_args {
156: 154:         FunctionExecutionRequest::ValueValidationFunctionRequest { .. } => "output!=true",
157: 155:         FunctionExecutionRequest::ValueComputeFunctionRequest { .. } => {
158: 156:             "!(Array.isArray(output))"
159: 157:         }
160: 158:         FunctionExecutionRequest::ContextValidationFunctionRequest { .. } => {
161: 159:             "output!=true"
162: 160:         }
163: 161:         FunctionExecutionRequest::ChangeReasonValidationFunctionRequest { .. } => {
164: 162:             "output!=true"
165: 163:         }
166: 164:     };
167: 165: 
168: 166:     FUNCTION_EXECUTION_SNIPPET
169: 167:         .replace("{condition}", output_check)
170: 168:         .replace(
171: 169:             "{function-invocation}",
172: 170:             &format!(
173: 171:                 "{}({})",
174: 172:                 FUNCTION_NAME,
175: 173:                 serde_json::to_string(&payload).unwrap_or("Invalid Payload".to_string())
176: 174:             ),
177: 175:         )
178: 176:         .replace(CODE_TOKEN, code_str)
179: 177: }
180: 178: 
181: 179: fn generate_wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper_runtime(code_str: &str) -> String {
182: 180:     CODE_GENERATION_SNIPPET
183: 181:         .replace(FUNCTION_ENV_TOKEN, FUNCTION_ENV_VARIABLES)
184: 182:         .replace(CODE_TOKEN, code_str)
185: 183: }
186: 184: 
187: 185: pub fn execute_fn(
188: 186:     workspace_context: &WorkspaceContext,
189: 187:     code_str: &FunctionCode,
190: 188:     args: &FunctionExecutionRequest,
191: 189:     runtime_version: FunctionRuntimeVersion,
192: 190:     conn: &mut DBConnection,
193: 191:     master_encryption_key: &Option<EncryptionKey>,
194: 192: ) -> Result<FunctionExecutionResponse, (String, Option<String>)> {
195: 193:     let code = inject_secrets_and_variables_into_code(
196: 194:         code_str,
197: 195:         conn,
198: 196:         workspace_context,
199: 197:         master_encryption_key,
200: 198:     )
201: 199:     .map_err(|err| {
202: 200:         let err_msg = format!("Failed to inject variables/secrets: {:?}", err);
203: 201:         log::error!("{}", err_msg);
204: 202:         (err_msg, None)
205: 203:     })?;
206: 204:     let exec_code = generate_fn_code(&code, args, runtime_version);
207: 205:     log::trace!("{}", format!("Running function code: {:?}", exec_code));
208: 206:     let output = Command::new("node")
209: 207:         .arg("-e")
210: 208:         .arg(generate_wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper_runtime(&exec_code))
211: 209:         .output();
212: 210:     log::trace!("{}", format!("Running function output : {:?}", output));
213: 211:     match output {
214: 212:         Ok(val) => {
215: 213:             let stdout = str::from_utf8(&val.stdout)
216: 214:                 .unwrap_or("[Invalid UTF-8 in stdout]")
217: 215:                 .to_owned();
218: 216:             if !(val.status.success()) {
219: 217:                 let stderr = str::from_utf8(&val.stderr)
220: 218:                     .unwrap_or("[Invalid UTF-8 in stderr]")
221: 219:                     .to_owned();
222: 220:                 log::error!(
223: 221:                     "{}",
224: 222:                     format!("validation function output error: {:?}", stderr)
225: 223:                 );
226: 224:                 Err((stderr, Some(stdout)))
227: 225:             } else {
228: 226:                 let function_type = FunctionType::from(args);
229: 227:                 let stdout_vec = stdout.trim().split('|').collect::<Vec<_>>();
230: 228:                 let fn_output = stdout_vec
231: 229:                     .last()
232: 230:                     .map(|i| i.to_string())
233: 231:                     .unwrap_or_default()
234: 232:                     .replace('\'', "\"");
235: 233: 
236: 234:                 log::trace!("Function output in rust {:?}", fn_output);
237: 235:                 let fn_output = serde_json::from_str::<serde_json::Value>(&fn_output)
238: 236:                     .unwrap_or_default();
239: 237:                 Ok(FunctionExecutionResponse {
240: 238:                     fn_output,
241: 239:                     stdout: stdout_vec[0..stdout_vec.len() - 1].join("\n"),
242: 240:                     function_type,
243: 241:                 })
244: 242:             }
245: 243:         }
246: 244:         Err(e) => {
247: 245:             log::error!("js_eval error: {}", e);
248: 246:             Err((format!("js_eval error: {}", e), None))
249: 247:         }
250: 248:     }
251: 249: }
252: 250: 
253: 251: pub fn compile_fn(code_str: &FunctionCode) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<()> {
254: 252:     let type_check_code = type_check(code_str);
255: 253:     log::trace!(
256: 254:         "{}",
257: 255:         format!(
258: 256:             "validation function code : {:?}",
259: 257:             generate_wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper_runtime(&type_check_code)
260: 258:         )
261: 259:     );
262: 260:     let output = Command::new("node")
263: 261:         .arg("-e")
264: 262:         .arg(generate_wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper_runtime(&type_check_code))
265: 263:         .output();
266: 264: 
267: 265:     log::trace!("{}", format!("validation function output : {:?}", output));
268: 266:     match output {
269: 267:         Ok(val) => {
270: 268:             if !(val.status.success()) {
271: 269:                 let stderr = str::from_utf8(&val.stderr)
272: 270:                     .unwrap_or("[Invalid UTF-8 in stderr]")
273: 271:                     .to_owned();
274: 272:                 log::error!("{}", format!("eslint check output error: {:?}", stderr));
275: 273:                 Err(validation_error!(stderr))
276: 274:             } else {
277: 275:                 Ok(())
278: 276:             }
279: 277:         }
280: 278:         Err(e) => {
281: 279:             log::error!("eslint check error: {}", e);
282: 280:             Err(unexpected_error!("js_eval error: {}", e))
283: 281:         }
284: 282:     }
285: 283: }
286: 284: ```
287: 285: ```
288: 286: ```
289: 287: ```
290: ```
```

