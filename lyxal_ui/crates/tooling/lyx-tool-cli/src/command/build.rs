### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx-tool-cli\src\command\build.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx-tool-cli\src\command\build.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\command\build.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\command\build.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\command\build.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\command\build.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\command\build.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\command\build.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\command\build.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\command\build.rs
18: 16: ```rust
19: 17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\command\build.rs
20: 18: ```rust
21: 19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\command\build.rs
22: 20: ```rust
23: 21: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\command\build.rs
24: 22: ```rust
25: 23: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\command\build.rs
26: 24: ```rust
27: 25: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\command\build.rs
28: 26: ```rust
29: 27: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\command\build.rs
30: 28: ```rust
31: 29: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\command\build.rs
32: 30: ```rust
33: 31: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\command\build.rs
34: 32: ```rust
35: 33: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\command\build.rs
36: 34: ```rust
37: 35: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\command\build.rs
38: 36: ```rust
39: 37: use std::sync::Arc;
40: 38: 
41: 39: use crate::ext::compress;
42: 40: use crate::{
43: 41:     compile,
44: 42:     compile::ChangeSet,
45: 43:     config::{Config, Project},
46: 44:     ext::{
47: 45:         anyhow::{anyhow, Context, Result},
48: 46:         fs,
49: 47:     },
50: 48: };
51: 49: 
52: 50: pub async fn build_all(conf: &Config) -> Result<()> {
53: 51:     let mut first_failed_project = None;
54: 52: 
55: 53:     for proj in &conf.projects {
56: 54:         log::debug!("Building project: {}, {}", proj.name, proj.working_dir);
57: 55:         if !build_proj(proj).await? && first_failed_project.is_none() {
58: 56:             first_failed_project = Some(proj);
59: 57:         }
60: 58:     }
61: 59: 
62: 60:     if let Some(proj) = first_failed_project {
63: 61:         Err(anyhow!("Failed to build {}", proj.name))
64: 62:     } else {
65: 63:         Ok(())
66: 64:     }
67: 65: }
68: 66: 
69: 67: /// Build the project. Returns true if the build was successful
70: 68: pub async fn build_proj(proj: &Arc<Project>) -> Result<bool> {
71: 69:     if proj.site.root_dir.exists() {
72: 70:         fs::rm_dir_content(&proj.site.root_dir).await.dot()?;
73: 71:     }
74: 72:     let changes = ChangeSet::all_changes();
75: 73: 
76: 74:     if !compile::front(proj, &changes).await.await??.is_success() {
77: 75:         return Ok(false);
78: 76:     }
79: 77:     if !compile::assets(proj, &changes, true)
80: 78:         .await
81: 79:         .await??
82: 80:         .is_success()
83: 81:     {
84: 82:         return Ok(false);
85: 83:     }
86: 84:     if !compile::style(proj, &changes).await.await??.is_success() {
87: 85:         return Ok(false);
88: 86:     }
89: 87: 
90: 88:     if proj.hash_files {
91: 89:         compile::add_hashes_to_site(proj)?;
92: 90:     }
93: 91: 
94: 92:     // it is important to do the precompression of the static files before building the
95: 93:     // lyx-platform-lyx_platform_lyx-platform-lyx_platform_server to make it possible to include them as assets into the binary itself
96: 94:     if proj.release && proj.precompress {
97: 95:         compress::compress_static_files(proj.site.root_dir.clone().into()).await?;
98: 96:     }
99: 97: 
100: 98:     if !compile::lyx-platform-lyx_platform_lyx-platform-lyx_platform_server(proj, &changes).await.await??.is_success() {
101: 99:         return Ok(false);
102: 100:     }
103: 101: 
104: 102:     Ok(true)
105: 103: }
106: 104: ```
107: 105: ```
108: 106: ```
109: 107: ```
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
124: ```
```
