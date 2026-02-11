### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx-tool-cli\src\compile\style.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx-tool-cli\src\compile\style.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\compile\style.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\compile\style.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\compile\style.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\compile\style.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\compile\style.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\compile\style.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\compile\style.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\compile\style.rs
18: 16: ```rust
19: 17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\compile\style.rs
20: 18: ```rust
21: 19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\compile\style.rs
22: 20: ```rust
23: 21: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\compile\style.rs
24: 22: ```rust
25: 23: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\compile\style.rs
26: 24: ```rust
27: 25: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\compile\style.rs
28: 26: ```rust
29: 27: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\compile\style.rs
30: 28: ```rust
31: 29: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\compile\style.rs
32: 30: ```rust
33: 31: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\compile\style.rs
34: 32: ```rust
35: 33: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\compile\style.rs
36: 34: ```rust
37: 35: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\compile\style.rs
38: 36: ```rust
39: 37: use super::ChangeSet;
40: 38: use crate::{
41: 39:     compile::{sass::compile_sass, tailwind::compile_tailwind},
42: 40:     config::Project,
43: 41:     ext::{
44: 42:         anyhow::{anyhow, bail, Context, Result},
45: 43:         PathBufExt,
46: 44:     },
47: 45:     fs,
48: 46:     logger::GRAY,
49: 47:     signal::{Outcome, Product},
50: 48: };
51: 49: use lightningcss::{
52: 50:     stylesheet::{MinifyOptions, ParserOptions, PrinterOptions, StyleSheet},
53: 51:     targets::Browsers,
54: 52:     targets::Targets,
55: 53: };
56: 54: use std::sync::Arc;
57: 55: use tokio::task::JoinHandle;
58: 56: 
59: 57: pub async fn style(
60: 58:     proj: &Arc<Project>,
61: 59:     changes: &ChangeSet,
62: 60: ) -> JoinHandle<Result<Outcome<Product>>> {
63: 61:     let changes = changes.clone();
64: 62:     let proj = proj.clone();
65: 63: 
66: 64:     tokio::spawn(async move {
67: 65:         let css_in_source = proj.style.tailwind.is_some();
68: 66:         if !changes.need_style_build(true, css_in_source) {
69: 67:             log::debug!("Style no build needed {changes:?}");
70: 68:             return Ok(Outcome::Success(Product::None));
71: 69:         }
72: 70:         build(&proj).await
73: 71:     })
74: 72: }
75: 73: fn build_sass(proj: &Arc<Project>) -> JoinHandle<Result<Outcome<String>>> {
76: 74:     let proj = proj.clone();
77: 75:     tokio::spawn(async move {
78: 76:         let Some(style_file) = &proj.style.file else {
79: 77:             log::trace!("Style not configured");
80: 78:             return Ok(Outcome::Success("".to_string()));
81: 79:         };
82: 80: 
83: 81:         log::trace!("Style found: {}", &style_file);
84: 82:         fs::create_dir_all(style_file.dest.clone().without_last())
85: 83:             .await
86: 84:             .dot()?;
87: 85:         match style_file.source.extension() {
88: 86:             Some("sass") | Some("scss") => compile_sass(style_file, proj.release)
89: 87:                 .await
90: 88:                 .context(format!("compile sass/scss: {}", &style_file)),
91: 89:             Some("css") => Ok(Outcome::Success(
92: 90:                 fs::read_to_string(&style_file.source).await.dot()?,
93: 91:             )),
94: 92:             _ => bail!("Not a css/sass/scss style file: {}", &style_file),
95: 93:         }
96: 94:     })
97: 95: }
98: 96: 
99: 97: fn build_tailwind(proj: &Arc<Project>) -> JoinHandle<Result<Outcome<String>>> {
100: 98:     let proj = proj.clone();
101: 99:     tokio::spawn(async move {
102: 100:         let Some(tw_conf) = proj.style.tailwind.as_ref() else {
103: 101:             log::trace!("Tailwind not configured");
104: 102:             return Ok(Outcome::Success("".to_string()));
105: 103:         };
106: 104:         log::trace!("Tailwind config: {:?}", &tw_conf);
107: 105:         compile_tailwind(&proj, tw_conf).await
108: 106:     })
109: 107: }
110: 108: 
111: 109: async fn build(proj: &Arc<Project>) -> Result<Outcome<Product>> {
112: 110:     let css_handle = build_sass(proj);
113: 111:     let tw_handle = build_tailwind(proj);
114: 112:     let css = css_handle.await??;
115: 113:     let tw = tw_handle.await??;
116: 114: 
117: 115:     use Outcome::*;
118: 116:     let css = match (css, tw) {
119: 117:         (Stopped, _) | (_, Stopped) => return Ok(Stopped),
120: 118:         (Failed, _) | (_, Failed) => return Ok(Failed),
121: 119:         (Success(css), Success(tw)) => format!("{css}\n{tw}"),
122: 120:     };
123: 121:     Ok(Success(process_css(proj, css).await?))
124: 122: }
125: 123: 
126: 124: fn browser_lists(query: &str) -> Result<Option<Browsers>> {
127: 125:     Browsers::from_browserslist([query]).context(format!("Error in browserlist query: {query}"))
128: 126: }
129: 127: 
130: 128: async fn process_css(proj: &Project, css: String) -> Result<Product> {
131: 129:     let browsers = browser_lists(&proj.style.browserquery).context("lyx-core-lyx_core_lyx-core-lyx_core_leptos.style.browserquery")?;
132: 130:     let targets = Targets::from(browsers);
133: 131: 
134: 132:     let mut stylesheet =
135: 133:         StyleSheet::parse(&css, ParserOptions::default()).map_err(|e| anyhow!("{e}"))?;
136: 134: 
137: 135:     if proj.release {
138: 136:         let minify_options = MinifyOptions {
139: 137:             targets,
140: 138:             ..Default::default()
141: 139:         };
142: 140:         stylesheet.minify(minify_options)?;
143: 141:     }
144: 142: 
145: 143:     let options = PrinterOptions::<'_> {
146: 144:         targets,
147: 145:         minify: proj.release,
148: 146:         ..Default::default()
149: 147:     };
150: 148: 
151: 149:     let style_output = stylesheet.to_css(options)?;
152: 150: 
153: 151:     let bytes = style_output.code.as_bytes();
154: 152: 
155: 153:     let prod = match proj.site.updated_with(&proj.style.site_file, bytes).await? {
156: 154:         true => {
157: 155:             log::trace!(
158: 156:                 "Style finished with changes {}",
159: 157:                 GRAY.paint(&proj.style.site_file.to_string())
160: 158:             );
161: 159:             Product::Style("".to_string()) //TODO
162: 160:         }
163: 161:         false => {
164: 162:             log::trace!("Style finished without changes");
165: 163:             Product::None
166: 164:         }
167: 165:     };
168: 166:     Ok(prod)
169: 167: }
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
187: 185: ```
188: ```
```
