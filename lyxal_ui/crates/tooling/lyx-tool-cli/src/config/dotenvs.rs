### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx-tool-cli\src\config\dotenvs.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx-tool-cli\src\config\dotenvs.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\dotenvs.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\dotenvs.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\dotenvs.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\dotenvs.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\dotenvs.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\dotenvs.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\dotenvs.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\dotenvs.rs
18: 16: ```rust
19: 17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\dotenvs.rs
20: 18: ```rust
21: 19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\dotenvs.rs
22: 20: ```rust
23: 21: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\dotenvs.rs
24: 22: ```rust
25: 23: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\dotenvs.rs
26: 24: ```rust
27: 25: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\dotenvs.rs
28: 26: ```rust
29: 27: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\dotenvs.rs
30: 28: ```rust
31: 29: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\dotenvs.rs
32: 30: ```rust
33: 31: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\dotenvs.rs
34: 32: ```rust
35: 33: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\dotenvs.rs
36: 34: ```rust
37: 35: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\dotenvs.rs
38: 36: ```rust
39: 37: use super::ProjectConfig;
40: 38: use crate::ext::anyhow::Result;
41: 39: use crate::ext::exe;
42: 40: use camino::{Utf8Path, Utf8PathBuf};
43: 41: use std::{env, fs};
44: 42: 
45: 43: pub fn load_dotenvs(directory: &Utf8Path) -> Result<Option<Vec<(String, String)>>> {
46: 44:     let candidate = directory.join(".env");
47: 45: 
48: 46:     if let Ok(metadata) = fs::metadata(&candidate) {
49: 47:         if metadata.is_file() {
50: 48:             let mut dotenvs = vec![];
51: 49:             for entry in dotenvy::from_path_iter(&candidate)? {
52: 50:                 let (key, val) = entry?;
53: 51:                 dotenvs.push((key, val));
54: 52:             }
55: 53: 
56: 54:             return Ok(Some(dotenvs));
57: 55:         }
58: 56:     }
59: 57: 
60: 58:     if let Some(parent) = directory.parent() {
61: 59:         load_dotenvs(parent)
62: 60:     } else {
63: 61:         Ok(None)
64: 62:     }
65: 63: }
66: 64: 
67: 65: pub fn overlay_env(conf: &mut ProjectConfig, dotenvs: Option<Vec<(String, String)>>) -> Result<()> {
68: 66:     if let Some(dotenvs) = dotenvs {
69: 67:         overlay(conf, dotenvs.into_iter())?;
70: 68:     }
71: 69:     overlay(conf, env::vars())?;
72: 70:     Ok(())
73: 71: }
74: 72: 
75: 73: fn overlay(conf: &mut ProjectConfig, envs: impl Iterator<Item = (String, String)>) -> Result<()> {
76: 74:     for (key, val) in envs {
77: 75:         match key.as_str() {
78: 76:             "LEPTOS_OUTPUT_NAME" => conf.output_name = val,
79: 77:             "LEPTOS_SITE_ROOT" => conf.site_root = Utf8PathBuf::from(val),
80: 78:             "LEPTOS_SITE_PKG_DIR" => conf.site_pkg_dir = Utf8PathBuf::from(val),
81: 79:             "LEPTOS_STYLE_FILE" => conf.style_file = Some(Utf8PathBuf::from(val)),
82: 80:             "LEPTOS_ASSETS_DIR" => conf.assets_dir = Some(Utf8PathBuf::from(val)),
83: 81:             "LEPTOS_SITE_ADDR" => conf.site_addr = val.parse()?,
84: 82:             "LEPTOS_RELOAD_PORT" => conf.reload_port = val.parse()?,
85: 83:             "LEPTOS_END2END_CMD" => conf.end2end_cmd = Some(val),
86: 84:             "LEPTOS_END2END_DIR" => conf.end2end_dir = Some(Utf8PathBuf::from(val)),
87: 85:             "LEPTOS_HASH_FILES" => conf.hash_files = val.parse()?,
88: 86:             "LEPTOS_HASH_FILE_NAME" => conf.hash_file_name = Some(val.parse()?),
89: 87:             "LEPTOS_BROWSERQUERY" => conf.browserquery = val,
90: 88:             "LEPTOS_BIN_EXE_NAME" => conf.bin_exe_name = Some(val),
91: 89:             "LEPTOS_BIN_TARGET" => conf.bin_target = val,
92: 90:             "LEPTOS_BIN_TARGET_TRIPLE" => conf.bin_target_triple = Some(val),
93: 91:             "LEPTOS_BIN_TARGET_DIR" => conf.bin_target_dir = Some(val),
94: 92:             "LEPTOS_BIN_CARGO_COMMAND" => conf.bin_cargo_command = Some(val),
95: 93:             "LEPTOS_JS_MINIFY" => conf.js_minify = val.parse()?,
96: 94:             // put these here to suppress the warning, but there's no
97: 95:             // good way at the moment to pull the ProjectConfig all the way to Exe
98: 96:             exe::ENV_VAR_LEPTOS_TAILWIND_VERSION => {}
99: 97:             exe::ENV_VAR_LEPTOS_SASS_VERSION => {}
100: 98:             exe::ENV_VAR_LEPTOS_CARGO_GENERATE_VERSION => {}
101: 99:             exe::ENV_VAR_LEPTOS_WASM_OPT_VERSION => {}
102: 100:             _ if key.starts_with("LEPTOS_") => {
103: 101:                 log::warn!("Env {key} is not used by cargo-lyx-core-lyx_core_lyx-core-lyx_core_leptos")
104: 102:             }
105: 103:             _ => {}
106: 104:         }
107: 105:     }
108: 106:     Ok(())
109: 107: }
110: 108: ```
111: 109: ```
112: 110: ```
113: 111: ```
114: 112: ```
115: 113: ```
116: 114: ```
117: 115: ```
118: 116: ```
119: 117: ```
120: 118: ```
121: 119: ```
122: 120: ```
123: 121: ```
124: 122: ```
125: 123: ```
126: 124: ```
127: 125: ```
128: ```
```
