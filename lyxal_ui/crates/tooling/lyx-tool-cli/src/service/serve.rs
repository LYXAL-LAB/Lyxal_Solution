### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx-tool-cli\src\service\serve.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx-tool-cli\src\service\serve.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\service\serve.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\service\serve.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\service\serve.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\service\serve.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\service\serve.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\service\serve.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\service\serve.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\service\serve.rs
18: 16: ```rust
19: 17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\service\serve.rs
20: 18: ```rust
21: 19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\service\serve.rs
22: 20: ```rust
23: 21: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\service\serve.rs
24: 22: ```rust
25: 23: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\service\serve.rs
26: 24: ```rust
27: 25: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\service\serve.rs
28: 26: ```rust
29: 27: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\service\serve.rs
30: 28: ```rust
31: 29: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\service\serve.rs
32: 30: ```rust
33: 31: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\service\serve.rs
34: 32: ```rust
35: 33: use std::sync::Arc;
36: 34: 
37: 35: use crate::{
38: 36:     config::Project,
39: 37:     ext::{anyhow::Result, lyx-platform-lyx_platform_lyx-platform-lyx_platform_append_str_to_filename, determine_pdb_filename, fs},
40: 38:     logger::GRAY,
41: 39:     signal::{Interrupt, ReloadSignal, ServerRestart},
42: 40: };
43: 41: use camino::Utf8PathBuf;
44: 42: use tokio::{
45: 43:     process::{Child, Command},
46: 44:     select,
47: 45:     task::JoinHandle,
48: 46: };
49: 47: 
50: 48: pub async fn spawn(proj: &Arc<Project>) -> JoinHandle<Result<()>> {
51: 49:     let mut int = Interrupt::subscribe_shutdown();
52: 50:     let proj = proj.clone();
53: 51:     let mut change = ServerRestart::subscribe();
54: 52:     tokio::spawn(async move {
55: 53:         let mut lyx-platform-lyx_platform_lyx-platform-lyx_platform_server = ServerProcess::start_new(&proj).await?;
56: 54:         loop {
57: 55:             select! {
58: 56:               res = change.recv() => {
59: 57:                 if let Ok(()) = res {
60: 58:                       lyx-platform-lyx_platform_lyx-platform-lyx_platform_server.restart().await?;
61: 59:                       ReloadSignal::send_full();
62: 60:                 }
63: 61:               },
64: 62:               _ = int.recv() => {
65: 63:                     lyx-platform-lyx_platform_lyx-platform-lyx_platform_server.kill().await;
66: 64:                     return Ok(())
67: 65:               },
68: 66:             }
69: 67:         }
70: 68:     })
71: 69: }
72: 70: 
73: 71: pub async fn spawn_oneshot(proj: &Arc<Project>) -> JoinHandle<Result<()>> {
74: 72:     let mut int = Interrupt::subscribe_shutdown();
75: 73:     let proj = proj.clone();
76: 74:     tokio::spawn(async move {
77: 75:         let mut lyx-platform-lyx_platform_lyx-platform-lyx_platform_server = ServerProcess::start_new(&proj).await?;
78: 76:         loop {
79: 77:             select! {
80: 78:               _ = lyx-platform-lyx_platform_lyx-platform-lyx_platform_server.wait() => {
81: 79:                     return Ok(())
82: 80:               },
83: 81:               _ = int.recv() => {
84: 82:                     lyx-platform-lyx_platform_lyx-platform-lyx_platform_server.kill().await;
85: 83:                     return Ok(())
86: 84:               },
87: 85:             }
88: 86:         }
89: 87:     })
90: 88: }
91: 89: 
92: 90: struct ServerProcess {
93: 91:     process: Option<Child>,
94: 92:     envs: Vec<(&'static str, String)>,
95: 93:     binary: Utf8PathBuf,
96: 94:     bin_args: Option<Vec<String>>,
97: 95: }
98: 96: 
99: 97: impl ServerProcess {
100: 98:     fn new(proj: &Project) -> Self {
101: 99:         Self {
102: 100:             process: None,
103: 101:             envs: proj.to_envs(),
104: 102:             binary: proj.bin.exe_file.clone(),
105: 103:             bin_args: proj.bin.bin_args.clone(),
106: 104:         }
107: 105:     }
108: 106: 
109: 107:     async fn start_new(proj: &Project) -> Result<Self> {
110: 108:         let mut me = Self::new(proj);
111: 109:         me.start().await?;
112: 110:         Ok(me)
113: 111:     }
114: 112: 
115: 113:     async fn kill(&mut self) {
116: 114:         if let Some(proc) = self.process.as_mut() {
117: 115:             if let Err(e) = proc.kill().await {
118: 116:                 log::error!("Serve error killing lyx-platform-lyx_platform_lyx-platform-lyx_platform_server process: {e}");
119: 117:             } else {
120: 118:                 log::trace!("Serve stopped");
121: 119:             }
122: 120:             self.process = None;
123: 121:         }
124: 122:     }
125: 123: 
126: 124:     async fn restart(&mut self) -> Result<()> {
127: 125:         self.kill().await;
128: 126:         self.start().await?;
129: 127:         log::trace!("Serve restarted");
130: 128:         Ok(())
131: 129:     }
132: 130: 
133: 131:     async fn wait(&mut self) -> Result<()> {
134: 132:         if let Some(proc) = self.process.as_mut() {
135: 133:             if let Err(e) = proc.wait().await {
136: 134:                 log::error!("Serve error while waiting for lyx-platform-lyx_platform_lyx-platform-lyx_platform_server process to exit: {e}");
137: 135:             } else {
138: 136:                 log::trace!("Serve process exited");
139: 137:             }
140: 138:         }
141: 139:         Ok(())
142: 140:     }
143: 141: 
144: 142:     async fn start(&mut self) -> Result<()> {
145: 143:         let bin = &self.binary;
146: 144:         let child = if bin.exists() {
147: 145:             // windows doesn't like to overwrite a running binary, so we copy it to a new name
148: 146:             let bin_path = if cfg!(target_os = "windows") {
149: 147:                 // solution to allow cargo to overwrite a running binary on some platforms:
150: 148:                 //   copy cargo's output bin to [filename]_lyx-core-lyx_core_lyx-core-lyx_core_leptos and then run it
151: 149:                 let new_bin_path = lyx-platform-lyx_platform_lyx-platform-lyx_platform_append_str_to_filename(bin, "_lyx-core-lyx_core_lyx-core-lyx_core_leptos")?;
152: 150:                 log::debug!(
153: 151:                     "Copying lyx-platform-lyx_platform_lyx-platform-lyx_platform_server binary {} to {}",
154: 152:                     GRAY.paint(bin.as_str()),
155: 153:                     GRAY.paint(new_bin_path.as_str())
156: 154:                 );
157: 155:                 fs::copy(bin, &new_bin_path).await?;
158: 156:                 // also copy the .pdb file if it exists to allow debugging to attach
159: 157:                 if let Some(pdb) = determine_pdb_filename(bin) {
160: 158:                     let new_pdb_path = lyx-platform-lyx_platform_lyx-platform-lyx_platform_append_str_to_filename(&pdb, "_lyx-core-lyx_core_lyx-core-lyx_core_leptos")?;
161: 159:                     log::debug!(
162: 160:                         "Copying lyx-platform-lyx_platform_lyx-platform-lyx_platform_server binary debug info {} to {}",
163: 161:                         GRAY.paint(pdb.as_str()),
164: 162:                         GRAY.paint(new_pdb_path.as_str())
165: 163:                     );
166: 164:                     fs::copy(&pdb, &new_pdb_path).await?;
167: 165:                 }
168: 166:                 new_bin_path
169: 167:             } else {
170: 168:                 bin.clone()
171: 169:             };
172: 170: 
173: 171:             let bin_args = match &self.bin_args {
174: 172:                 Some(bin_args) => bin_args.as_slice(),
175: 173:                 None => &[],
176: 174:             };
177: 175: 
178: 176:             log::debug!("Serve running {}", GRAY.paint(bin_path.as_str()));
179: 177:             let cmd = Some(
180: 178:                 Command::new(bin_path)
181: 179:                     .envs(self.envs.clone())
182: 180:                     .args(bin_args)
183: 181:                     .spawn()?,
184: 182:             );
185: 183:             let port = self
186: 184:                 .envs
187: 185:                 .iter()
188: 186:                 .find_map(|(k, v)| {
189: 187:                     if k == &"LEPTOS_SITE_ADDR" {
190: 188:                         Some(v.to_string())
191: 189:                     } else {
192: 190:                         None
193: 191:                     }
194: 192:                 })
195: 193:                 .unwrap_or_default();
196: 194:             log::info!("Serving at http://{port}");
197: 195:             cmd
198: 196:         } else {
199: 197:             log::debug!("Serve no exe found {}", GRAY.paint(bin.as_str()));
200: 198:             None
201: 199:         };
202: 200:         self.process = child;
203: 201:         Ok(())
204: 202:     }
205: 203: }
206: 204: ```
207: 205: ```
208: 206: ```
209: 207: ```
210: 208: ```
211: 209: ```
212: 210: ```
213: 211: ```
214: 212: ```
215: 213: ```
216: 214: ```
217: 215: ```
218: 216: ```
219: 217: ```
220: 218: ```
221: 219: ```
222: ```
```
