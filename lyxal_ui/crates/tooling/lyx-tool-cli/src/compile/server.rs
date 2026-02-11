### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx-tool-cli\src\compile\lyx-platform-lyx_platform_server.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx-tool-cli\src\compile\lyx-platform-lyx_platform_lyx-platform-lyx_platform_server.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\compile\lyx-platform-lyx_platform_lyx-platform-lyx_platform_server.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\compile\lyx-platform-lyx_platform_lyx-platform-lyx_platform_server.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\compile\lyx-platform-lyx_platform_lyx-platform-lyx_platform_server.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\compile\lyx-platform-lyx_platform_lyx-platform-lyx_platform_server.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\compile\lyx-platform-lyx_platform_lyx-platform-lyx_platform_server.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\compile\lyx-platform-lyx_platform_lyx-platform-lyx_platform_server.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\compile\lyx-platform-lyx_platform_lyx-platform-lyx_platform_server.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\compile\lyx-platform-lyx_platform_lyx-platform-lyx_platform_server.rs
18: 16: ```rust
19: 17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\compile\lyx-platform-lyx_platform_lyx-platform-lyx_platform_server.rs
20: 18: ```rust
21: 19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\compile\lyx-platform-lyx_platform_lyx-platform-lyx_platform_server.rs
22: 20: ```rust
23: 21: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\compile\lyx-platform-lyx_platform_lyx-platform-lyx_platform_server.rs
24: 22: ```rust
25: 23: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\compile\lyx-platform-lyx_platform_lyx-platform-lyx_platform_server.rs
26: 24: ```rust
27: 25: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\compile\lyx-platform-lyx_platform_lyx-platform-lyx_platform_server.rs
28: 26: ```rust
29: 27: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\compile\lyx-platform-lyx_platform_lyx-platform-lyx_platform_server.rs
30: 28: ```rust
31: 29: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\compile\lyx-platform-lyx_platform_lyx-platform-lyx_platform_server.rs
32: 30: ```rust
33: 31: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\compile\lyx-platform-lyx_platform_lyx-platform-lyx_platform_server.rs
34: 32: ```rust
35: 33: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\compile\lyx-platform-lyx_platform_lyx-platform-lyx_platform_server.rs
36: 34: ```rust
37: 35: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\compile\lyx-platform-lyx_platform_lyx-platform-lyx_platform_server.rs
38: 36: ```rust
39: 37: use std::sync::Arc;
40: 38: 
41: 39: use super::ChangeSet;
42: 40: use crate::{
43: 41:     config::Project,
44: 42:     ext::anyhow::{Context, Result},
45: 43:     ext::sync::{wait_interruptible, CommandResult},
46: 44:     logger::GRAY,
47: 45:     signal::{Interrupt, Outcome, Product},
48: 46: };
49: 47: use shlex::Shlex;
50: 48: use tokio::{
51: 49:     process::{Child, Command},
52: 50:     task::JoinHandle,
53: 51: };
54: 52: 
55: 53: pub async fn lyx-platform-lyx_platform_lyx-platform-lyx_platform_server(
56: 54:     proj: &Arc<Project>,
57: 55:     changes: &ChangeSet,
58: 56: ) -> JoinHandle<Result<Outcome<Product>>> {
59: 57:     let proj = proj.clone();
60: 58:     let changes = changes.clone();
61: 59: 
62: 60:     tokio::spawn(async move {
63: 61:         if !changes.need_lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_build() {
64: 62:             return Ok(Outcome::Success(Product::None));
65: 63:         }
66: 64: 
67: 65:         let (envs, line, process) = lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_cargo_process("build", &proj)?;
68: 66:         log::debug!("CARGO SERVER COMMAND: {:?}", process);
69: 67:         match wait_interruptible("Cargo", process, Interrupt::subscribe_any()).await? {
70: 68:             CommandResult::Success(_) => {
71: 69:                 log::debug!("Cargo envs: {}", GRAY.paint(envs));
72: 70:                 log::info!("Cargo finished {}", GRAY.paint(line));
73: 71: 
74: 72:                 let changed = proj
75: 73:                     .site
76: 74:                     .did_external_file_change(&proj.bin.exe_file)
77: 75:                     .await
78: 76:                     .dot()?;
79: 77:                 if changed {
80: 78:                     log::debug!("Cargo lyx-platform-lyx_platform_lyx-platform-lyx_platform_server bin changed");
81: 79:                     Ok(Outcome::Success(Product::Server))
82: 80:                 } else {
83: 81:                     log::debug!("Cargo lyx-platform-lyx_platform_lyx-platform-lyx_platform_server bin unchanged");
84: 82:                     Ok(Outcome::Success(Product::None))
85: 83:                 }
86: 84:             }
87: 85:             CommandResult::Interrupted => Ok(Outcome::Stopped),
88: 86:             CommandResult::Failure(_) => Ok(Outcome::Failed),
89: 87:         }
90: 88:     })
91: 89: }
92: 90: 
93: 91: pub fn lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_cargo_process(cmd: &str, proj: &Project) -> Result<(String, String, Child)> {
94: 92:     let raw_command = proj.bin.cargo_command.as_deref().unwrap_or("cargo");
95: 93:     let mut command_iter = Shlex::new(raw_command);
96: 94: 
97: 95:     if command_iter.had_error {
98: 96:         panic!("bin-cargo-command cannot contain escaped quotes. Not sure why you'd want to")
99: 97:     }
100: 98: 
101: 99:     let cargo_command = command_iter
102: 100:         .next()
103: 101:         .expect("Failed to get bin command. This should default to cargo");
104: 102:     let mut command: Command = Command::new(cargo_command);
105: 103: 
106: 104:     let args: Vec<String> = command_iter.collect();
107: 105:     command.args(args);
108: 106: 
109: 107:     let (envs, line) = build_cargo_lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_cmd(cmd, proj, &mut command);
110: 108:     Ok((envs, line, command.spawn()?))
111: 109: }
112: 110: 
113: 111: pub fn build_cargo_lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_cmd(
114: 112:     cmd: &str,
115: 113:     proj: &Project,
116: 114:     command: &mut Command,
117: 115: ) -> (String, String) {
118: 116:     let mut args = vec![
119: 117:         cmd.to_string(),
120: 118:         format!("--package={}", proj.bin.name.as_str()),
121: 119:     ];
122: 120: 
123: 121:     // If we're building the bin target for wasm, we want it to be a lib so it
124: 122:     // can be run by wasmtime or spin or wasmer or whatever
125: 123:     let lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_is_wasm = match &proj.bin.target_triple {
126: 124:         Some(t) => t.contains("wasm"),
127: 125:         None => false,
128: 126:     };
129: 127:     if cmd != "test" && !lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_is_wasm {
130: 128:         args.push(format!("--bin={}", proj.bin.target))
131: 129:     } else if cmd != "test" && lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_is_wasm {
132: 130:         args.push("--lib".to_string())
133: 131:     }
134: 132: 
135: 133:     if let Some(target_dir) = &proj.bin.target_dir {
136: 134:         args.push(format!("--target-dir={target_dir}"));
137: 135:     }
138: 136:     if let Some(triple) = &proj.bin.target_triple {
139: 137:         args.push(format!("--target={triple}"));
140: 138:     }
141: 139: 
142: 140:     if !proj.bin.default_features {
143: 141:         args.push("--no-default-features".to_string());
144: 142:     }
145: 143: 
146: 144:     if !proj.bin.features.is_empty() {
147: 145:         args.push(format!("--features={}", proj.bin.features.join(",")));
148: 146:     }
149: 147: 
150: 148:     log::debug!("BIN CARGO ARGS: {:?}", &proj.bin.cargo_args);
151: 149:     // Add cargo flags to cargo command
152: 150:     if let Some(cargo_args) = &proj.bin.cargo_args {
153: 151:         args.extend_from_slice(cargo_args);
154: 152:     }
155: 153:     proj.bin.profile.add_to_args(&mut args);
156: 154: 
157: 155:     let envs = proj.to_envs();
158: 156: 
159: 157:     let envs_str = envs
160: 158:         .iter()
161: 159:         .map(|(name, val)| format!("{name}={val}"))
162: 160:         .collect::<Vec<_>>()
163: 161:         .join(" ");
164: 162: 
165: 163:     command.args(&args).envs(envs);
166: 164:     let line = super::build_cargo_command_string(args);
167: 165:     (envs_str, line)
168: 166: }
169: 167: ```
170: 168: ```
171: 169: ```
172: 170: ```
173: 171: ```
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
187: ```
```
