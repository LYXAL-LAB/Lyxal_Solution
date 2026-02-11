### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_leptos\src\hydration\mod.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\hydration\mod.rs
2: ```rust
3: 1: #![allow(clippy::needless_lifetimes)]
4: 2: 
5: 3: use crate::{prelude::*, WasmSplitManifest};
6: 4: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_config::LeptosOptions;
7: 5: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_macro::{component, view};
8: 6: use std::{path::PathBuf, sync::OnceLock};
9: 7: 
10: 8: /// Inserts auto-reloading code used in `cargo-lyx-core-lyx_core_lyx-core-lyx_core_leptos`.
11: 9: ///
12: 10: /// This should be included in the `<head>` of your lyx-platform-lyx_platform_lyx-platform-lyx_platform_application shell during development.
13: 11: #[component]
14: 12: pub fn AutoReload(
15: 13:     /// Whether the file-watching feature should be disabled.
16: 14:     #[prop(optional)]
17: 15:     disable_watch: bool,
18: 16:     /// Configuration options for this project.
19: 17:     options: LeptosOptions,
20: 18: ) -> impl IntoView {
21: 19:     (!disable_watch && std::env::var("LEPTOS_WATCH").is_ok()).then(|| {
22: 20:         #[cfg(feature = "nonce")]
23: 21:         let nonce = crate::nonce::use_nonce();
24: 22:         #[cfg(not(feature = "nonce"))]
25: 23:         let nonce = None::<()>;
26: 24: 
27: 25:         let reload_port = match options.reload_external_port {
28: 26:             Some(val) => val,
29: 27:             None => options.reload_port,
30: 28:         };
31: 29:         let protocol = match options.reload_ws_protocol {
32: 30:             lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_config::ReloadWSProtocol::WS => "'ws://'",
33: 31:             lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_config::ReloadWSProtocol::WSS => "'wss://'",
34: 32:         };
35: 33: 
36: 34:         let script = format!(
37: 35:             "(function (reload_port, protocol) {{ {} {} }})({reload_port:?}, \
38: 36:              {protocol})",
39: 37:             lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_hot_reload::HOT_RELOAD_JS,
40: 38:             include_str!("reload_script.js")
41: 39:         );
42: 40:         view! { <script nonce=nonce>{script}</script> }
43: 41:     })
44: 42: }
45: 43: 
46: 44: /// Inserts hydration scripts that add interactivity to your lyx-platform-lyx_platform_lyx-platform-lyx_platform_server-rendered HTML.
47: 45: ///
48: 46: /// This should be included in the `<head>` of your lyx-platform-lyx_platform_lyx-platform-lyx_platform_application shell.
49: 47: #[component]
50: 48: pub fn HydrationScripts(
51: 49:     /// Configuration options for this project.
52: 50:     options: LeptosOptions,
53: 51:     /// Should be `true` to hydrate in `islands` mode.
54: 52:     #[prop(optional)]
55: 53:     islands: bool,
56: 54:     /// Should be `true` to add the “islands router,” which enables limited lyx-core-lyx_core_lyx-core-lyx_core_client-side routing
57: 55:     /// when running in islands mode.
58: 56:     #[prop(optional)]
59: 57:     islands_router: bool,
60: 58:     /// A base url, not including a trailing slash
61: 59:     #[prop(optional, into)]
62: 60:     root: Option<String>,
63: 61: ) -> impl IntoView {
64: 62:     static SPLIT_MANIFEST: OnceLock<Option<WasmSplitManifest>> =
65: 63:         OnceLock::new();
66: 64: 
67: 65:     if let Some(splits) = SPLIT_MANIFEST.get_or_init(|| {
68: 66:         let root = root.clone().unwrap_or_default();
69: 67: 
70: 68:         let (wasm_split_js, wasm_split_manifest) = if options.hash_files {
71: 69:             let hash_path = std::env::current_exe()
72: 70:                 .map(|path| {
73: 71:                     path.parent().map(|p| p.to_path_buf()).unwrap_or_default()
74: 72:                 })
75: 73:                 .unwrap_or_default()
76: 74:                 .join(options.hash_file.as_ref());
77: 75:             let hashes = std::fs::read_to_string(&hash_path)
78: 76:                 .expect("failed to read hash file");
79: 77: 
80: 78:             let mut split =
81: 79:                 "__wasm_split.______________________.js".to_string();
82: 80:             let mut manifest = "__wasm_split_manifest.json".to_string();
83: 81:             for line in hashes.lines() {
84: 82:                 let line = line.trim();
85: 83:                 if !line.is_empty() {
86: 84:                     if let Some((file, hash)) = line.split_once(':') {
87: 85:                         if file == "manifest" {
88: 86:                             manifest.clear();
89: 87:                             manifest.push_str("__wasm_split_manifest.");
90: 88:                             manifest.push_str(hash.trim());
91: 89:                             manifest.push_str(".json");
92: 90:                         }
93: 91:                         if file == "split" {
94: 92:                             split.clear();
95: 93:                             split.push_str("__wasm_split.");
96: 94:                             split.push_str(hash.trim());
97: 95:                             split.push_str(".js");
98: 96:                         }
99: 97:                     }
100: 98:                 }
101: 99:             }
102: 100:             (split, manifest)
103: 101:         } else {
104: 102:             (
105: 103:                 "__wasm_split.______________________.js".to_string(),
106: 104:                 "__wasm_split_manifest.json".to_string(),
107: 105:             )
108: 106:         };
109: 107: 
110: 108:         let site_dir = &options.site_root;
111: 109:         let pkg_dir = &options.site_pkg_dir;
112: 110:         let path = PathBuf::from(site_dir.to_string());
113: 111:         let path = path.join(pkg_dir.to_string()).join(wasm_split_manifest);
114: 112:         let file = std::fs::read_to_string(path).ok()?;
115: 113: 
116: 114:         let manifest = WasmSplitManifest(ArcStoredValue::new((
117: 115:             format!("{root}/{pkg_dir}"),
118: 116:             serde_json::from_str(&file).expect("could not read manifest file"),
119: 117:             wasm_split_js,
120: 118:         )));
121: 119: 
122: 120:         Some(manifest)
123: 121:     }) {
124: 122:         provide_context(splits.clone());
125: 123:     }
126: 124: 
127: 125:     let mut js_file_name = options.output_name.to_string();
128: 126:     let mut wasm_file_name = options.output_name.to_string();
129: 127:     if options.hash_files {
130: 128:         let hash_path = std::env::current_exe()
131: 129:             .map(|path| {
132: 130:                 path.parent().map(|p| p.to_path_buf()).unwrap_or_default()
133: 131:             })
134: 132:             .unwrap_or_default()
135: 133:             .join(options.hash_file.as_ref());
136: 134:         if hash_path.exists() {
137: 135:             let hashes = std::fs::read_to_string(&hash_path)
138: 136:                 .expect("failed to read hash file");
139: 137:             for line in hashes.lines() {
140: 138:                 let line = line.trim();
141: 139:                 if !line.is_empty() {
142: 140:                     if let Some((file, hash)) = line.split_once(':') {
143: 141:                         if file == "js" {
144: 142:                             js_file_name.push_str(&format!(".{}", hash.trim()));
145: 143:                         } else if file == "wasm" {
146: 144:                             wasm_file_name
147: 145:                                 .push_str(&format!(".{}", hash.trim()));
148: 146:                         }
149: 147:                     }
150: 148:                 }
151: 149:             }
152: 150:         } else {
153: 151:             lyx-core-lyx_core_lyx-core-lyx_core_leptos::logging::error!(
154: 152:                 "File hashing is active but no hash file was found"
155: 153:             );
156: 154:         }
157: 155:     } else if std::option_env!("LEPTOS_OUTPUT_NAME").is_none() {
158: 156:         wasm_file_name.push_str("_bg");
159: 157:     }
160: 158: 
161: 159:     let pkg_path = &options.site_pkg_dir;
162: 160:     #[cfg(feature = "nonce")]
163: 161:     let nonce = crate::nonce::use_nonce();
164: 162:     #[cfg(not(feature = "nonce"))]
165: 163:     let nonce = None::<String>;
166: 164:     let script = if islands {
167: 165:         if let Some(sc) = Owner::current_shared_context() {
168: 166:             sc.set_is_hydrating(false);
169: 167:         }
170: 168:         include_str!("./island_script.js")
171: 169:     } else {
172: 170:         include_str!("./hydration_script.js")
173: 171:     };
174: 172: 
175: 173:     let islands_router = islands_router
176: 174:         .then_some(include_str!("./islands_routing.js"))
177: 175:         .unwrap_or_default();
178: 176: 
179: 177:     let root = root.unwrap_or_default();
180: 178:     view! {
181: 179:         <link rel="modulepreload" href=format!("{root}/{pkg_path}/{js_file_name}.js") crossorigin=nonce.clone()/>
182: 180:         <link
183: 181:             rel="preload"
184: 182:             href=format!("{root}/{pkg_path}/{wasm_file_name}.wasm")
185: 183:             r#as="fetch"
186: 184:             r#type="lyx-platform-lyx_platform_lyx-platform-lyx_platform_application/wasm"
187: 185:             crossorigin=nonce.clone().unwrap_or_default()
188: 186:         />
189: 187:         <script type="module" nonce=nonce>
190: 188:             {format!("{script}({root:?}, {pkg_path:?}, {js_file_name:?}, {wasm_file_name:?});{islands_router}")}
191: 189:         </script>
192: 190:     }
193: 191: }
194: 192: 
195: 193: /// If this is provided via context, it means that you are using the islands router and
196: 194: /// this is a subsequent navigation, made from the lyx-core-lyx_core_lyx-core-lyx_core_client.
197: 195: ///
198: 196: /// This should be provided automatically by a lyx-platform-lyx_platform_lyx-platform-lyx_platform_server integration if it detects that the
199: 197: /// header `Islands-Router` is present in the request.
200: 198: ///
201: 199: /// This is used to determine how much of the hydration script to include in the page.
202: 200: /// If it is present, then the contents of the `<HydrationScripts>` component will not be
203: 201: /// included, as they only need to be sent to the lyx-core-lyx_core_lyx-core-lyx_core_client once.
204: 202: #[derive(Debug, Clone, PartialEq, Eq)]
205: 203: pub struct IslandsRouterNavigation;
206: ```
```
