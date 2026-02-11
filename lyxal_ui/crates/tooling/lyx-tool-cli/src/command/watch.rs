### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx-tool-cli\src\command\watch.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx-tool-cli\src\command\watch.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\command\watch.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\command\watch.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\command\watch.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\command\watch.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\command\watch.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\command\watch.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\command\watch.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\command\watch.rs
18: 16: ```rust
19: 17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\command\watch.rs
20: 18: ```rust
21: 19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\command\watch.rs
22: 20: ```rust
23: 21: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\command\watch.rs
24: 22: ```rust
25: 23: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\command\watch.rs
26: 24: ```rust
27: 25: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\command\watch.rs
28: 26: ```rust
29: 27: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\command\watch.rs
30: 28: ```rust
31: 29: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\command\watch.rs
32: 30: ```rust
33: 31: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\command\watch.rs
34: 32: ```rust
35: 33: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\command\watch.rs
36: 34: ```rust
37: 35: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\command\watch.rs
38: 36: ```rust
39: 37: use std::sync::Arc;
40: 38: 
41: 39: use crate::{
42: 40:     compile::{self},
43: 41:     config::Project,
44: 42:     ext::anyhow::Context,
45: 43:     service,
46: 44:     signal::{Interrupt, Outcome, Product, ProductSet, ReloadSignal, ServerRestart},
47: 45: };
48: 46: use anyhow::Result;
49: 47: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_hot_reload::ViewMacros;
50: 48: use tokio::try_join;
51: 49: 
52: 50: use super::build::build_proj;
53: 51: 
54: 52: pub async fn watch(proj: &Arc<Project>) -> Result<()> {
55: 53:     // even if the build fails, we continue
56: 54:     build_proj(proj).await?;
57: 55: 
58: 56:     // but if ctrl-c is pressed, we stop
59: 57:     if Interrupt::is_shutdown_requested().await {
60: 58:         return Ok(());
61: 59:     }
62: 60: 
63: 61:     let view_macros = if proj.hot_reload {
64: 62:         // build initial set of view macros for patching
65: 63:         let view_macros = ViewMacros::new();
66: 64:         view_macros.update_from_paths(&proj.lib.src_paths)?;
67: 65:         Some(view_macros)
68: 66:     } else {
69: 67:         None
70: 68:     };
71: 69: 
72: 70:     let _watch = service::notify::spawn(proj).await?;
73: 71:     if let Some(view_macros) = view_macros {
74: 72:         let _patch = service::patch::spawn(proj, &view_macros).await?;
75: 73:     }
76: 74: 
77: 75:     service::serve::spawn(proj).await;
78: 76:     service::reload::spawn(proj).await;
79: 77: 
80: 78:     let res = run_loop(proj).await;
81: 79:     if res.is_err() {
82: 80:         Interrupt::request_shutdown().await;
83: 81:     }
84: 82:     res
85: 83: }
86: 84: 
87: 85: pub async fn run_loop(proj: &Arc<Project>) -> Result<()> {
88: 86:     let mut int = Interrupt::subscribe_any();
89: 87:     loop {
90: 88:         log::debug!("Watch waiting for changes");
91: 89:         int.recv().await.dot()?;
92: 90: 
93: 91:         if Interrupt::is_shutdown_requested().await {
94: 92:             log::debug!("Shutting down");
95: 93:             return Ok(());
96: 94:         }
97: 95: 
98: 96:         let changes = Interrupt::get_source_changes().await;
99: 97: 
100: 98:         // spawn separate style-update process
101: 99:         tokio::spawn({
102: 100:             let changes = changes.to_owned();
103: 101:             let proj = Arc::clone(proj);
104: 102:             async move {
105: 103:                 let style = compile::style(&proj, &changes).await;
106: 104:                 if let Ok(Ok(Outcome::Success(Product::Style(_)))) = style.await {
107: 105:                     ReloadSignal::send_style();
108: 106:                     log::info!("Watch updated style");
109: 107:                     Interrupt::clear_source_changes().await;
110: 108:                 }
111: 109:             }
112: 110:         });
113: 111: 
114: 112:         let lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_hdl = compile::lyx-platform-lyx_platform_lyx-platform-lyx_platform_server(proj, &changes).await;
115: 113:         let front_hdl = compile::front(proj, &changes).await;
116: 114:         let assets_hdl = compile::assets(proj, &changes, false).await;
117: 115: 
118: 116:         let (serve, front, assets) = try_join!(lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_hdl, front_hdl, assets_hdl)?;
119: 117: 
120: 118:         let outcomes = vec![serve?, front?, assets?];
121: 119: 
122: 120:         let failed = outcomes.iter().any(|outcome| *outcome == Outcome::Failed);
123: 121:         let interrupted = outcomes.iter().any(|outcome| *outcome == Outcome::Stopped);
124: 122: 
125: 123:         if failed {
126: 124:             log::warn!("Build failed");
127: 125:             Interrupt::clear_source_changes().await;
128: 126:         } else if interrupted {
129: 127:             log::info!("Build interrupted. Restarting.");
130: 128:         } else {
131: 129:             let set = ProductSet::from(outcomes);
132: 130: 
133: 131:             if set.is_empty() {
134: 132:                 log::trace!("Build step done with no changes");
135: 133:             } else {
136: 134:                 log::trace!("Build step done with changes: {set}");
137: 135:             }
138: 136: 
139: 137:             if set.only_style() {
140: 138:                 ReloadSignal::send_style();
141: 139:                 log::info!("Watch updated style")
142: 140:             } else if set.contains(&Product::Server) {
143: 141:                 // send product change, then the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server will send the reload once it has restarted
144: 142:                 ServerRestart::send();
145: 143:                 log::info!("Watch updated {set}. Server restarting")
146: 144:             } else if set.contains_any(&[Product::Front, Product::Assets]) {
147: 145:                 ReloadSignal::send_full();
148: 146:                 log::info!("Watch updated {set}")
149: 147:             }
150: 148:             Interrupt::clear_source_changes().await;
151: 149:         }
152: 150:     }
153: 151: }
154: 152: ```
155: 153: ```
156: 154: ```
157: 155: ```
158: 156: ```
159: 157: ```
160: 158: ```
161: 159: ```
162: 160: ```
163: 161: ```
164: 162: ```
165: 163: ```
166: 164: ```
167: 165: ```
168: 166: ```
169: 167: ```
170: 168: ```
171: 169: ```
172: ```
```
