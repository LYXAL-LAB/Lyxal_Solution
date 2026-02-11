### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx-tool-cli\src\config\bin_package.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx-tool-cli\src\config\bin_package.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\bin_package.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\bin_package.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\bin_package.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\bin_package.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\bin_package.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\bin_package.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\bin_package.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\bin_package.rs
18: 16: ```rust
19: 17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\bin_package.rs
20: 18: ```rust
21: 19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\bin_package.rs
22: 20: ```rust
23: 21: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\bin_package.rs
24: 22: ```rust
25: 23: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\bin_package.rs
26: 24: ```rust
27: 25: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\bin_package.rs
28: 26: ```rust
29: 27: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\bin_package.rs
30: 28: ```rust
31: 29: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\bin_package.rs
32: 30: ```rust
33: 31: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\bin_package.rs
34: 32: ```rust
35: 33: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\bin_package.rs
36: 34: ```rust
37: 35: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\bin_package.rs
38: 36: ```rust
39: 37: use camino::Utf8PathBuf;
40: 38: use cargo_metadata::{Metadata, Target};
41: 39: 
42: 40: use super::{project::ProjectDefinition, Profile, ProjectConfig};
43: 41: use crate::{
44: 42:     config::Opts,
45: 43:     ext::{
46: 44:         anyhow::{anyhow, bail, Error, Result},
47: 45:         MetadataExt, PackageExt, PathBufExt, PathExt,
48: 46:     },
49: 47: };
50: 48: pub struct BinPackage {
51: 49:     pub name: String,
52: 50:     pub abs_dir: Utf8PathBuf,
53: 51:     pub rel_dir: Utf8PathBuf,
54: 52:     pub exe_file: Utf8PathBuf,
55: 53:     pub target: String,
56: 54:     pub features: Vec<String>,
57: 55:     pub default_features: bool,
58: 56:     /// all source paths, including path dependencies'
59: 57:     pub src_paths: Vec<Utf8PathBuf>,
60: 58:     pub profile: Profile,
61: 59:     pub target_triple: Option<String>,
62: 60:     pub target_dir: Option<String>,
63: 61:     pub cargo_command: Option<String>,
64: 62:     pub cargo_args: Option<Vec<String>>,
65: 63:     pub bin_args: Option<Vec<String>>,
66: 64: }
67: 65: 
68: 66: impl BinPackage {
69: 67:     pub fn resolve(
70: 68:         cli: &Opts,
71: 69:         metadata: &Metadata,
72: 70:         project: &ProjectDefinition,
73: 71:         config: &ProjectConfig,
74: 72:         bin_args: Option<&[String]>,
75: 73:     ) -> Result<Self> {
76: 74:         let mut features = if !cli.bin_features.is_empty() {
77: 75:             cli.bin_features.clone()
78: 76:         } else if !config.bin_features.is_empty() {
79: 77:             config.bin_features.clone()
80: 78:         } else {
81: 79:             vec![]
82: 80:         };
83: 81: 
84: 82:         features.extend(config.features.clone());
85: 83:         features.extend(cli.features.clone());
86: 84: 
87: 85:         let name = project.bin_package.clone();
88: 86:         let packages = metadata.workspace_packages();
89: 87:         let package = packages
90: 88:             .iter()
91: 89:             .find(|p| p.name == name && p.has_bin_target())
92: 90:             .ok_or_else(|| anyhow!(r#"Could not find the project bin-package "{name}""#,))?;
93: 91: 
94: 92:         let package = (*package).clone();
95: 93: 
96: 94:         let targets = package
97: 95:             .targets
98: 96:             .iter()
99: 97:             .filter(|t| t.is_bin())
100: 98:             .collect::<Vec<&Target>>();
101: 99: 
102: 100:         let target: Target = if !&config.bin_target.is_empty() {
103: 101:             targets
104: 102:                 .into_iter()
105: 103:                 .find(|t| t.name == config.bin_target)
106: 104:                 .ok_or_else(|| target_not_found(config.bin_target.as_str()))?
107: 105:                 .clone()
108: 106:         } else if targets.len() == 1 {
109: 107:             targets[0].clone()
110: 108:         } else if targets.is_empty() {
111: 109:             bail!("No bin targets found for member {name}");
112: 110:         } else {
113: 111:             return Err(many_targets_found(&name));
114: 112:         };
115: 113: 
116: 114:         let abs_dir = package.manifest_path.clone().without_last();
117: 115:         let rel_dir = abs_dir.unbase(&metadata.workspace_root)?;
118: 116:         let profile = Profile::new(
119: 117:             cli.release,
120: 118:             &config.bin_profile_release,
121: 119:             &config.bin_profile_dev,
122: 120:         );
123: 121:         let exe_file = {
124: 122:             let file_ext = if cfg!(target_os = "windows") {
125: 123:                 "exe"
126: 124:             } else if config
127: 125:                 .bin_target_triple
128: 126:                 .as_ref()
129: 127:                 .is_some_and(|target| target.starts_with("wasm32-"))
130: 128:             {
131: 129:                 "wasm"
132: 130:             } else {
133: 131:                 ""
134: 132:             };
135: 133: 
136: 134:             let mut file = config
137: 135:                 .bin_target_dir
138: 136:                 .as_ref()
139: 137:                 .map(|dir| dir.into())
140: 138:                 // Can't use absolute path because the path gets stored in snapshot testing, and it differs between developers
141: 139:                 .unwrap_or_else(|| metadata.rel_target_dir());
142: 140:             if let Some(triple) = &config.bin_target_triple {
143: 141:                 file = file.join(triple)
144: 142:             };
145: 143:             let name = if let Some(name) = &config.bin_exe_name {
146: 144:                 name
147: 145:             } else {
148: 146:                 &name
149: 147:             };
150: 148:             file.join(profile.to_string())
151: 149:                 .join(name)
152: 150:                 .with_extension(file_ext)
153: 151:         };
154: 152: 
155: 153:         let mut src_paths = metadata.src_path_dependencies(&package.id);
156: 154:         if rel_dir == "." {
157: 155:             src_paths.push("src".into());
158: 156:         } else {
159: 157:             src_paths.push(rel_dir.join("src"));
160: 158:         }
161: 159: 
162: 160:         log::debug!("BEFORE BIN {:?}", config.bin_cargo_command);
163: 161:         Ok(Self {
164: 162:             name,
165: 163:             abs_dir,
166: 164:             rel_dir,
167: 165:             exe_file,
168: 166:             target: target.name,
169: 167:             features,
170: 168:             default_features: config.bin_default_features,
171: 169:             src_paths,
172: 170:             profile,
173: 171:             target_triple: config.bin_target_triple.clone(),
174: 172:             target_dir: config.bin_target_dir.clone(),
175: 173:             cargo_command: config.bin_cargo_command.clone(),
176: 174:             cargo_args: cli.bin_cargo_args.clone(),
177: 175:             bin_args: bin_args.map(ToOwned::to_owned),
178: 176:         })
179: 177:     }
180: 178: }
181: 179: 
182: 180: impl std::fmt::Debug for BinPackage {
183: 181:     fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
184: 182:         f.debug_struct("BinPackage")
185: 183:             .field("name", &self.name)
186: 184:             .field("rel_dir", &self.rel_dir.test_string())
187: 185:             .field("exe_file", &self.exe_file.test_string())
188: 186:             .field("target", &self.target)
189: 187:             .field("features", &self.features)
190: 188:             .field("default_features", &self.default_features)
191: 189:             .field(
192: 190:                 "src_paths",
193: 191:                 &self
194: 192:                     .src_paths
195: 193:                     .iter()
196: 194:                     .map(|p| p.test_string())
197: 195:                     .collect::<Vec<_>>()
198: 196:                     .join(", "),
199: 197:             )
200: 198:             .field("profile", &self.profile)
201: 199:             .field("bin_args", &self.bin_args)
202: 200:             .finish_non_exhaustive()
203: 201:     }
204: 202: }
205: 203: 
206: 204: fn many_targets_found(pkg: &str) -> Error {
207: 205:     anyhow!(
208: 206:         r#"Several bin targets found for member "{pkg}", please specify which one to use with: [[workspace.metadata.lyx-core-lyx_core_lyx-core-lyx_core_leptos]] bin-target = "name""#
209: 207:     )
210: 208: }
211: 209: fn target_not_found(target: &str) -> Error {
212: 210:     anyhow!(
213: 211:         r#"Could not find the target specified: [[workspace.metadata.lyx-core-lyx_core_lyx-core-lyx_core_leptos]] bin-target = "{target}""#,
214: 212:     )
215: 213: }
216: 214: ```
217: 215: ```
218: 216: ```
219: 217: ```
220: 218: ```
221: 219: ```
222: 220: ```
223: 221: ```
224: 222: ```
225: 223: ```
226: 224: ```
227: 225: ```
228: 226: ```
229: 227: ```
230: 228: ```
231: 229: ```
232: 230: ```
233: 231: ```
234: ```
```
