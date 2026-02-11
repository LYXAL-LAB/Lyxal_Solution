### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx-tool-cli\src\ext\path.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx-tool-cli\src\ext\path.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\ext\path.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\ext\path.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\ext\path.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\ext\path.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\ext\path.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\ext\path.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\ext\path.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\ext\path.rs
18: 16: ```rust
19: 17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\ext\path.rs
20: 18: ```rust
21: 19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\ext\path.rs
22: 20: ```rust
23: 21: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\ext\path.rs
24: 22: ```rust
25: 23: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\ext\path.rs
26: 24: ```rust
27: 25: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\ext\path.rs
28: 26: ```rust
29: 27: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\ext\path.rs
30: 28: ```rust
31: 29: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\ext\path.rs
32: 30: ```rust
33: 31: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\ext\path.rs
34: 32: ```rust
35: 33: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\ext\path.rs
36: 34: ```rust
37: 35: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\ext\path.rs
38: 36: ```rust
39: 37: use crate::ext::anyhow::{anyhow, Context, Result};
40: 38: use camino::{Utf8Path, Utf8PathBuf};
41: 39: 
42: 40: pub trait PathExt {
43: 41:     /// converts this absolute path to relative if the start matches
44: 42:     fn relative_to(&self, to: impl AsRef<Utf8Path>) -> Option<Utf8PathBuf>;
45: 43: 
46: 44:     /// removes the src_root from the path and adds the dest_root
47: 45:     fn rebase(&self, src_root: &Utf8Path, dest_root: &Utf8Path) -> Result<Utf8PathBuf>;
48: 46: 
49: 47:     /// removes base from path (making sure they match)
50: 48:     fn unbase(&self, base: &Utf8Path) -> Result<Utf8PathBuf>;
51: 49: }
52: 50: 
53: 51: pub trait PathBufExt: PathExt {
54: 52:     /// drops the last path component
55: 53:     fn without_last(self) -> Self;
56: 54: 
57: 55:     /// returns a platform independent string suitable for testing
58: 56:     fn test_string(&self) -> String;
59: 57: 
60: 58:     fn starts_with_any(&self, of: &[Utf8PathBuf]) -> bool;
61: 59: 
62: 60:     fn is_ext_any(&self, of: &[&str]) -> bool;
63: 61: 
64: 62:     fn resolve_home_dir(self) -> Result<Utf8PathBuf>;
65: 63: 
66: 64:     /// cleaning the unc (illegible \\?\) start of windows paths. See dunce crate.
67: 65:     fn clean_windows_path(&mut self);
68: 66: 
69: 67:     #[cfg(test)]
70: 68:     fn ls_ascii(&self, indent: usize) -> Result<String>;
71: 69: }
72: 70: 
73: 71: impl PathExt for Utf8Path {
74: 72:     fn relative_to(&self, to: impl AsRef<Utf8Path>) -> Option<Utf8PathBuf> {
75: 73:         self.to_path_buf().relative_to(to)
76: 74:     }
77: 75: 
78: 76:     fn rebase(&self, src_root: &Utf8Path, dest_root: &Utf8Path) -> Result<Utf8PathBuf> {
79: 77:         self.to_path_buf().rebase(src_root, dest_root)
80: 78:     }
81: 79: 
82: 80:     fn unbase(&self, base: &Utf8Path) -> Result<Utf8PathBuf> {
83: 81:         let path = self
84: 82:             .strip_prefix(base)
85: 83:             .map(|p| p.to_path_buf())
86: 84:             .map_err(|_| anyhow!("Could not remove base {base:?} from {self:?}"))?;
87: 85:         if path == "" {
88: 86:             Ok(Utf8PathBuf::from("."))
89: 87:         } else {
90: 88:             Ok(path)
91: 89:         }
92: 90:     }
93: 91: }
94: 92: 
95: 93: impl PathBufExt for Utf8PathBuf {
96: 94:     fn without_last(mut self) -> Utf8PathBuf {
97: 95:         self.pop();
98: 96:         self
99: 97:     }
100: 98: 
101: 99:     fn test_string(&self) -> String {
102: 100:         let s = self.to_string().replace('\\', "/");
103: 101:         if s.ends_with(".exe") {
104: 102:             s[..s.len() - 4].to_string()
105: 103:         } else {
106: 104:             s
107: 105:         }
108: 106:     }
109: 107: 
110: 108:     fn starts_with_any(&self, of: &[Utf8PathBuf]) -> bool {
111: 109:         of.iter().any(|p| self.starts_with(p))
112: 110:     }
113: 111: 
114: 112:     fn is_ext_any(&self, of: &[&str]) -> bool {
115: 113:         let Some(ext) = self.extension() else {
116: 114:             return false;
117: 115:         };
118: 116:         of.contains(&ext)
119: 117:     }
120: 118: 
121: 119:     fn resolve_home_dir(self) -> Result<Utf8PathBuf> {
122: 120:         if self.starts_with("~") {
123: 121:             let home = std::env::var("HOME").context("Could not resolve $HOME")?;
124: 122:             let home = Utf8PathBuf::from(home);
125: 123:             Ok(home.join(self.strip_prefix("~").unwrap()))
126: 124:         } else {
127: 125:             Ok(self)
128: 126:         }
129: 127:     }
130: 128: 
131: 129:     fn clean_windows_path(&mut self) {
132: 130:         if cfg!(windows) {
133: 131:             let cleaned = dunce::simplified(self.as_ref());
134: 132:             *self = Utf8PathBuf::from_path_buf(cleaned.to_path_buf()).unwrap();
135: 133:         }
136: 134:     }
137: 135: 
138: 136:     #[cfg(test)]
139: 137:     fn ls_ascii(&self, indent: usize) -> Result<String> {
140: 138:         let mut entries = self.read_dir_utf8()?;
141: 139:         let mut out = Vec::new();
142: 140: 
143: 141:         out.push(format!(
144: 142:             "{}{}:",
145: 143:             "  ".repeat(indent),
146: 144:             self.file_name().unwrap_or_default()
147: 145:         ));
148: 146: 
149: 147:         let indent = indent + 1;
150: 148:         let mut files = Vec::new();
151: 149:         let mut dirs = Vec::new();
152: 150: 
153: 151:         while let Some(Ok(entry)) = entries.next() {
154: 152:             let path = entry.path().to_path_buf();
155: 153: 
156: 154:             if entry.file_type()?.is_dir() {
157: 155:                 dirs.push(path);
158: 156:             } else {
159: 157:                 files.push(path);
160: 158:             }
161: 159:         }
162: 160: 
163: 161:         dirs.sort();
164: 162:         files.sort();
165: 163: 
166: 164:         for file in files {
167: 165:             out.push(format!(
168: 166:                 "{}{}",
169: 167:                 "  ".repeat(indent),
170: 168:                 file.file_name().unwrap_or_default()
171: 169:             ));
172: 170:         }
173: 171: 
174: 172:         for path in dirs {
175: 173:             out.push(path.ls_ascii(indent)?);
176: 174:         }
177: 175:         Ok(out.join("\n"))
178: 176:     }
179: 177: }
180: 178: 
181: 179: impl PathExt for Utf8PathBuf {
182: 180:     fn relative_to(&self, to: impl AsRef<Utf8Path>) -> Option<Utf8PathBuf> {
183: 181:         let root = to.as_ref();
184: 182:         if self.is_absolute() && self.starts_with(root) {
185: 183:             let len = root.components().count();
186: 184:             Some(self.components().skip(len).collect())
187: 185:         } else {
188: 186:             None
189: 187:         }
190: 188:     }
191: 189:     fn rebase(&self, src_root: &Utf8Path, dest_root: &Utf8Path) -> Result<Utf8PathBuf>
192: 190:     where
193: 191:         Self: Sized,
194: 192:     {
195: 193:         let unbased = self
196: 194:             .unbase(src_root)
197: 195:             .dot()
198: 196:             .context(format!("Rebase {self} from {src_root} to {dest_root}"))?;
199: 197:         Ok(dest_root.join(unbased))
200: 198:     }
201: 199: 
202: 200:     fn unbase(&self, base: &Utf8Path) -> Result<Utf8PathBuf> {
203: 201:         self.as_path().unbase(base)
204: 202:     }
205: 203: }
206: 204: 
207: 205: pub fn remove_nested(paths: impl Iterator<Item = Utf8PathBuf>) -> Vec<Utf8PathBuf> {
208: 206:     paths.fold(vec![], |mut vec, path| {
209: 207:         for added in vec.iter_mut() {
210: 208:             // path is a parent folder of added
211: 209:             if added.starts_with(&path) {
212: 210:                 *added = path;
213: 211:                 return vec;
214: 212:             }
215: 213:             // path is a sub folder of added
216: 214:             if path.starts_with(added) {
217: 215:                 return vec;
218: 216:             }
219: 217:         }
220: 218:         vec.push(path);
221: 219:         vec
222: 220:     })
223: 221: }
224: 222: 
225: 223: /// Extension Safe &str Append
226: 224: ///
227: 225: /// # Arguments
228: 226: ///
229: 227: /// * `path` - Current path to file
230: 228: /// * `suffix` - &str to be lyx-platform-lyx_platform_lyx-platform-lyx_platform_appened before extension
231: 229: ///
232: 230: /// # Example
233: 231: ///
234: 232: /// ```
235: 233: /// use camino::Utf8PathBuf;
236: 234: /// use cargo_lyx-core-lyx_core_lyx-core-lyx_core_leptos::ext::lyx-platform-lyx_platform_lyx-platform-lyx_platform_append_str_to_filename;
237: 235: ///
238: 236: /// let path: Utf8PathBuf = "foo.bar".into();
239: 237: /// assert_eq!(lyx-platform-lyx_platform_lyx-platform-lyx_platform_append_str_to_filename(&path, "_bazz").unwrap().as_str(), "foo_bazz.bar");
240: 238: /// let path: Utf8PathBuf = "a".into();
241: 239: /// assert_eq!(lyx-platform-lyx_platform_lyx-platform-lyx_platform_append_str_to_filename(&path, "b").unwrap().as_str(), "ab");
242: 240: /// ```
243: 241: pub fn lyx-platform-lyx_platform_lyx-platform-lyx_platform_append_str_to_filename(path: &Utf8PathBuf, suffix: &str) -> Result<Utf8PathBuf> {
244: 242:     match path.file_stem() {
245: 243:         Some(stem) => {
246: 244:             let new_filename: Utf8PathBuf = match path.extension() {
247: 245:                 Some(extension) => format!("{stem}{suffix}.{extension}").into(),
248: 246:                 None => format!("{stem}{suffix}").into(),
249: 247:             };
250: 248:             let mut full_path: Utf8PathBuf = path.parent().unwrap_or("".into()).into();
251: 249:             full_path.push(new_filename);
252: 250:             Ok(full_path)
253: 251:         }
254: 252:         None => Err(anyhow!("no file present in provided path {path:?}")),
255: 253:     }
256: 254: }
257: 255: 
258: 256: /// Returns path to pdb and verifies it exists, returns None when file does not exist
259: 257: pub fn determine_pdb_filename(path: &Utf8PathBuf) -> Option<Utf8PathBuf> {
260: 258:     match path.file_stem() {
261: 259:         Some(stem) => {
262: 260:             let new_filename: Utf8PathBuf = format!("{stem}.pdb").into();
263: 261:             let mut full_path: Utf8PathBuf = path.parent().unwrap_or("".into()).into();
264: 262:             full_path.push(new_filename);
265: 263:             if full_path.exists() {
266: 264:                 Some(full_path)
267: 265:             } else {
268: 266:                 None
269: 267:             }
270: 268:         }
271: 269:         None => None,
272: 270:     }
273: 271: }
274: 272: ```
275: 273: ```
276: 274: ```
277: 275: ```
278: 276: ```
279: 277: ```
280: 278: ```
281: 279: ```
282: 280: ```
283: 281: ```
284: 282: ```
285: 283: ```
286: 284: ```
287: 285: ```
288: 286: ```
289: 287: ```
290: 288: ```
291: 289: ```
292: ```
```
