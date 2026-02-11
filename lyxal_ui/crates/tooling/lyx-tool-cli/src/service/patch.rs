### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx-tool-cli\src\service\patch.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx-tool-cli\src\service\patch.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\service\patch.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\service\patch.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\service\patch.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\service\patch.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\service\patch.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\service\patch.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\service\patch.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\service\patch.rs
18: 16: ```rust
19: 17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\service\patch.rs
20: 18: ```rust
21: 19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\service\patch.rs
22: 20: ```rust
23: 21: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\service\patch.rs
24: 22: ```rust
25: 23: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\service\patch.rs
26: 24: ```rust
27: 25: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\service\patch.rs
28: 26: ```rust
29: 27: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\service\patch.rs
30: 28: ```rust
31: 29: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\service\patch.rs
32: 30: ```rust
33: 31: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\service\patch.rs
34: 32: ```rust
35: 33: use crate::config::Project;
36: 34: use crate::ext::anyhow::Result;
37: 35: use crate::signal::{Interrupt, ReloadSignal};
38: 36: use crate::{
39: 37:     ext::{remove_nested, PathBufExt},
40: 38:     logger::GRAY,
41: 39: };
42: 40: use camino::Utf8PathBuf;
43: 41: use itertools::Itertools;
44: 42: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_hot_reload::ViewMacros;
45: 43: use notify::{DebouncedEvent, RecursiveMode, Watcher};
46: 44: use std::collections::HashSet;
47: 45: use std::sync::Arc;
48: 46: use std::time::Duration;
49: 47: use tokio::task::JoinHandle;
50: 48: 
51: 49: use super::notify::Watched;
52: 50: 
53: 51: pub async fn spawn(proj: &Arc<Project>, view_macros: &ViewMacros) -> Result<JoinHandle<()>> {
54: 52:     let view_macros = view_macros.to_owned();
55: 53:     let mut set: HashSet<Utf8PathBuf> = HashSet::from_iter(vec![]);
56: 54: 
57: 55:     set.extend(proj.lib.src_paths.clone());
58: 56: 
59: 57:     let paths = remove_nested(set.into_iter());
60: 58: 
61: 59:     log::info!(
62: 60:         "Patch watching folders {}",
63: 61:         GRAY.paint(paths.iter().join(", "))
64: 62:     );
65: 63:     let proj = proj.clone();
66: 64: 
67: 65:     Ok(tokio::spawn(
68: 66:         async move { run(&paths, proj, view_macros).await },
69: 67:     ))
70: 68: }
71: 69: 
72: 70: async fn run(paths: &[Utf8PathBuf], proj: Arc<Project>, view_macros: ViewMacros) {
73: 71:     let (sync_tx, sync_rx) = std::sync::mpsc::channel::<DebouncedEvent>();
74: 72: 
75: 73:     let proj = proj.clone();
76: 74:     std::thread::spawn(move || {
77: 75:         while let Ok(event) = sync_rx.recv() {
78: 76:             match Watched::try_new(&event, &proj) {
79: 77:                 Ok(Some(watched)) => handle(watched, proj.clone(), view_macros.clone()),
80: 78:                 Err(e) => log::error!("Notify error {e}"),
81: 79:                 _ => log::trace!("Notify not handled {}", GRAY.paint(format!("{:?}", event))),
82: 80:             }
83: 81:         }
84: 82:         log::debug!("Notify stopped");
85: 83:     });
86: 84: 
87: 85:     let mut watcher = notify::watcher(sync_tx, Duration::from_millis(200))
88: 86:         .expect("failed to build file system watcher");
89: 87: 
90: 88:     for path in paths {
91: 89:         if let Err(e) = watcher.watch(path, RecursiveMode::Recursive) {
92: 90:             log::error!("Notify could not watch {path:?} due to {e:?}");
93: 91:         }
94: 92:     }
95: 93: 
96: 94:     if let Err(e) = Interrupt::subscribe_shutdown().recv().await {
97: 95:         log::trace!("Notify stopped due to: {e:?}");
98: 96:     }
99: 97: }
100: 98: 
101: 99: fn handle(watched: Watched, proj: Arc<Project>, view_macros: ViewMacros) {
102: 100:     log::trace!(
103: 101:         "Notify handle {}",
104: 102:         GRAY.paint(format!("{:?}", watched.path()))
105: 103:     );
106: 104: 
107: 105:     let Some(path) = watched.path() else {
108: 106:         Interrupt::send_all_changed();
109: 107:         return;
110: 108:     };
111: 109: 
112: 110:     if path.starts_with_any(&proj.lib.src_paths) && path.is_ext_any(&["rs"]) {
113: 111:         // Check if it's possible to patch
114: 112:         let patches = view_macros.patch(path);
115: 113:         if let Ok(Some(patch)) = patches {
116: 114:             log::debug!("Patching view.");
117: 115:             ReloadSignal::send_view_patches(&patch);
118: 116:         }
119: 117:     }
120: 118: }
121: 119: ```
122: 120: ```
123: 121: ```
124: 122: ```
125: 123: ```
126: 124: ```
127: 125: ```
128: 126: ```
129: 127: ```
130: 128: ```
131: 129: ```
132: 130: ```
133: 131: ```
134: 132: ```
135: 133: ```
136: 134: ```
137: ```
```
