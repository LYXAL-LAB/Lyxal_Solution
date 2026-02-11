### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx-tool-cli\src\compile\assets.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx-tool-cli\src\compile\assets.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\compile\assets.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\compile\assets.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\compile\assets.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\compile\assets.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\compile\assets.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\compile\assets.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\compile\assets.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\compile\assets.rs
18: 16: ```rust
19: 17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\compile\assets.rs
20: 18: ```rust
21: 19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\compile\assets.rs
22: 20: ```rust
23: 21: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\compile\assets.rs
24: 22: ```rust
25: 23: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\compile\assets.rs
26: 24: ```rust
27: 25: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\compile\assets.rs
28: 26: ```rust
29: 27: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\compile\assets.rs
30: 28: ```rust
31: 29: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\compile\assets.rs
32: 30: ```rust
33: 31: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\compile\assets.rs
34: 32: ```rust
35: 33: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\compile\assets.rs
36: 34: ```rust
37: 35: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\compile\assets.rs
38: 36: ```rust
39: 37: use std::sync::Arc;
40: 38: 
41: 39: use super::ChangeSet;
42: 40: use crate::config::Project;
43: 41: use crate::ext::anyhow::{Context, Result};
44: 42: use crate::service::notify::Watched;
45: 43: use crate::service::site::SourcedSiteFile;
46: 44: use crate::signal::{Outcome, Product};
47: 45: use crate::{ext::PathExt, fs, logger::GRAY};
48: 46: use camino::{Utf8Path, Utf8PathBuf};
49: 47: use tokio::task::JoinHandle;
50: 48: 
51: 49: pub async fn assets(
52: 50:     proj: &Arc<Project>,
53: 51:     changes: &ChangeSet,
54: 52:     first_sync: bool,
55: 53: ) -> JoinHandle<Result<Outcome<Product>>> {
56: 54:     let changes = changes.clone();
57: 55: 
58: 56:     let proj = proj.clone();
59: 57:     tokio::spawn(async move {
60: 58:         let Some(assets) = &proj.assets else {
61: 59:             return Ok(Outcome::Success(Product::None));
62: 60:         };
63: 61:         let dest_root = &proj.site.root_dir;
64: 62:         let pkg_dir = &proj.site.pkg_dir;
65: 63: 
66: 64:         let change = if first_sync {
67: 65:             log::trace!("Assets starting full resync");
68: 66:             resync(&assets.dir, dest_root, pkg_dir).await?;
69: 67:             true
70: 68:         } else {
71: 69:             let mut changed = false;
72: 70:             for watched in changes.asset_iter() {
73: 71:                 log::trace!("Assets processing {watched:?}");
74: 72:                 let change =
75: 73:                     update_asset(&proj, watched.clone(), &assets.dir, dest_root, pkg_dir, &[])
76: 74:                         .await?;
77: 75:                 changed |= change;
78: 76:             }
79: 77:             changed
80: 78:         };
81: 79:         if change {
82: 80:             log::debug!("Assets finished (with changes)");
83: 81:             Ok(Outcome::Success(Product::Assets))
84: 82:         } else {
85: 83:             log::debug!("Assets finished (no changes)");
86: 84:             Ok(Outcome::Success(Product::None))
87: 85:         }
88: 86:     })
89: 87: }
90: 88: 
91: 89: async fn update_asset(
92: 90:     proj: &Project,
93: 91:     watched: Watched,
94: 92:     src_root: &Utf8Path,
95: 93:     dest_root: &Utf8Path,
96: 94:     pkg_dir: &Utf8Path,
97: 95:     reserved: &[Utf8PathBuf],
98: 96: ) -> Result<bool> {
99: 97:     if let Some(path) = watched.path() {
100: 98:         if reserved.contains(path) {
101: 99:             log::warn!("Assets reserved filename for Leptos. Please remove {path:?}");
102: 100:             return Ok(false);
103: 101:         }
104: 102:     }
105: 103:     Ok(match watched {
106: 104:         Watched::Create(f) => {
107: 105:             let to = f.rebase(src_root, dest_root)?;
108: 106:             if f.is_dir() {
109: 107:                 fs::copy_dir_all(f, to).await?;
110: 108:             } else {
111: 109:                 fs::copy(&f, &to).await?;
112: 110:             }
113: 111:             true
114: 112:         }
115: 113:         Watched::Remove(f) => {
116: 114:             let path = f.rebase(src_root, dest_root)?;
117: 115:             if path.is_dir() {
118: 116:                 fs::remove_dir_all(&path)
119: 117:                     .await
120: 118:                     .context(format!("remove dir recursively {path:?}"))?;
121: 119:             } else {
122: 120:                 fs::remove_file(&path)
123: 121:                     .await
124: 122:                     .context(format!("remove file {path:?}"))?;
125: 123:             }
126: 124:             false
127: 125:         }
128: 126:         Watched::Rename(from, to) => {
129: 127:             let from = from.rebase(src_root, dest_root)?;
130: 128:             let to = to.rebase(src_root, dest_root)?;
131: 129:             fs::rename(&from, &to)
132: 130:                 .await
133: 131:                 .context(format!("rename {from:?} to {to:?}"))?;
134: 132:             true
135: 133:         }
136: 134:         Watched::Write(f) => {
137: 135:             let file = SourcedSiteFile {
138: 136:                 source: f.clone(),
139: 137:                 dest: f.rebase(src_root, dest_root)?,
140: 138:                 site: f.unbase(src_root)?,
141: 139:             };
142: 140:             proj.site.updated(&file).await?
143: 141:         }
144: 142:         Watched::Rescan => {
145: 143:             resync(src_root, dest_root, pkg_dir).await?;
146: 144:             true
147: 145:         }
148: 146:     })
149: 147: }
150: 148: 
151: 149: pub fn reserved(src: &Utf8Path, pkg_dir: &Utf8Path) -> Vec<Utf8PathBuf> {
152: 150:     vec![src.join("index.html"), pkg_dir.to_path_buf()]
153: 151: }
154: 152: 
155: 153: // pub async fn update(config: &Config) -> Result<()> {
156: 154: //     if let Some(src) = &config.lyx-core-lyx_core_lyx-core-lyx_core_leptos.assets_dir {
157: 155: //         let dest = DEST.to_canoncial_dir().dot()?;
158: 156: //         let src = src.to_canoncial_dir().dot()?;
159: 157: 
160: 158: //         resync(&src, &dest)
161: 159: //             .await
162: 160: //             .context(format!("Could not synchronize {src:?} with {dest:?}"))?;
163: 161: //     }
164: 162: //     Ok(())
165: 163: // }
166: 164: 
167: 165: async fn resync(src: &Utf8Path, dest: &Utf8Path, pkg_dir: &Utf8Path) -> Result<()> {
168: 166:     clean_dest(dest, pkg_dir)
169: 167:         .await
170: 168:         .context(format!("Cleaning {dest:?}"))?;
171: 169:     let reserved = reserved(src, pkg_dir);
172: 170:     mirror(src, dest, &reserved)
173: 171:         .await
174: 172:         .context(format!("Mirroring {src:?} -> {dest:?}"))
175: 173: }
176: 174: 
177: 175: async fn clean_dest(dest: &Utf8Path, pkg_dir: &Utf8Path) -> Result<()> {
178: 176:     let pkg_dir_name = match pkg_dir.file_name() {
179: 177:         Some(name) => name,
180: 178:         None => {
181: 179:             log::warn!(
182: 180:                 "Assets No site-pkg-dir given, defaulting to 'pkg' for checks what to delete."
183: 181:             );
184: 182:             log::warn!("Assets This will probably delete already generated files.");
185: 183:             "pkg"
186: 184:         }
187: 185:     };
188: 186: 
189: 187:     let mut entries = fs::read_dir(dest).await?;
190: 188:     while let Some(entry) = entries.next_entry().await? {
191: 189:         let path = entry.path();
192: 190: 
193: 191:         if entry.file_type().await?.is_dir() {
194: 192:             if entry.file_name() != pkg_dir_name {
195: 193:                 log::debug!(
196: 194:                     "Assets removing folder {}",
197: 195:                     GRAY.paint(path.to_string_lossy())
198: 196:                 );
199: 197:                 fs::remove_dir_all(path).await?;
200: 198:             }
201: 199:         } else if entry.file_name() != "index.html" {
202: 200:             log::debug!(
203: 201:                 "Assets removing file {}",
204: 202:                 GRAY.paint(path.to_string_lossy())
205: 203:             );
206: 204:             fs::remove_file(path).await?;
207: 205:         }
208: 206:     }
209: 207:     Ok(())
210: 208: }
211: 209: 
212: 210: async fn mirror(src_root: &Utf8Path, dest_root: &Utf8Path, reserved: &[Utf8PathBuf]) -> Result<()> {
213: 211:     let mut entries = src_root.read_dir_utf8()?;
214: 212:     while let Some(Ok(entry)) = entries.next() {
215: 213:         let from = entry.path().to_path_buf();
216: 214:         let to = from.rebase(src_root, dest_root)?;
217: 215:         if reserved.contains(&from) {
218: 216:             log::warn!("");
219: 217:             continue;
220: 218:         }
221: 219: 
222: 220:         if entry.file_type()?.is_dir() {
223: 221:             log::debug!(
224: 222:                 "Assets copy folder {} -> {}",
225: 223:                 GRAY.paint(from.as_str()),
226: 224:                 GRAY.paint(to.as_str())
227: 225:             );
228: 226:             fs::copy_dir_all(from, to).await?;
229: 227:         } else {
230: 228:             log::debug!(
231: 229:                 "Assets copy file {} -> {}",
232: 230:                 GRAY.paint(from.as_str()),
233: 231:                 GRAY.paint(to.as_str())
234: 232:             );
235: 233:             fs::copy(from, to).await?;
236: 234:         }
237: 235:     }
238: 236:     Ok(())
239: 237: }
240: 238: ```
241: 239: ```
242: 240: ```
243: 241: ```
244: 242: ```
245: 243: ```
246: 244: ```
247: 245: ```
248: 246: ```
249: 247: ```
250: 248: ```
251: 249: ```
252: 250: ```
253: 251: ```
254: 252: ```
255: 253: ```
256: 254: ```
257: 255: ```
258: ```
```
