### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx-tool-cli\src\config\mod.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx-tool-cli\src\config\mod.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\mod.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\mod.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\mod.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\mod.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\mod.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\mod.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\mod.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\mod.rs
18: 16: ```rust
19: 17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\mod.rs
20: 18: ```rust
21: 19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\mod.rs
22: 20: ```rust
23: 21: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\mod.rs
24: 22: ```rust
25: 23: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\mod.rs
26: 24: ```rust
27: 25: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\mod.rs
28: 26: ```rust
29: 27: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\mod.rs
30: 28: ```rust
31: 29: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\mod.rs
32: 30: ```rust
33: 31: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\mod.rs
34: 32: ```rust
35: 33: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\mod.rs
36: 34: ```rust
37: 35: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\mod.rs
38: 36: ```rust
39: 37: #[cfg(test)]
40: 38: mod tests;
41: 39: 
42: 40: mod assets;
43: 41: mod bin_package;
44: 42: mod cli;
45: 43: mod dotenvs;
46: 44: mod end2end;
47: 45: mod hash_file;
48: 46: mod lib_package;
49: 47: mod profile;
50: 48: mod project;
51: 49: mod style;
52: 50: mod tailwind;
53: 51: 
54: 52: use std::{fmt::Debug, sync::Arc};
55: 53: 
56: 54: pub use self::cli::{Cli, Commands, Log, Opts};
57: 55: use crate::ext::{
58: 56:     anyhow::{Context, Result},
59: 57:     MetadataExt,
60: 58: };
61: 59: use anyhow::bail;
62: 60: use camino::{Utf8Path, Utf8PathBuf};
63: 61: use cargo_metadata::Metadata;
64: 62: pub use profile::Profile;
65: 63: pub use project::{Project, ProjectConfig};
66: 64: pub use style::StyleConfig;
67: 65: pub use tailwind::TailwindConfig;
68: 66: 
69: 67: pub struct Config {
70: 68:     /// absolute path to the working dir
71: 69:     pub working_dir: Utf8PathBuf,
72: 70:     pub projects: Vec<Arc<Project>>,
73: 71:     pub cli: Opts,
74: 72:     pub watch: bool,
75: 73: }
76: 74: 
77: 75: impl Debug for Config {
78: 76:     fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
79: 77:         f.debug_struct("Config")
80: 78:             .field("projects", &self.projects)
81: 79:             .field("cli", &self.cli)
82: 80:             .field("watch", &self.watch)
83: 81:             .finish_non_exhaustive()
84: 82:     }
85: 83: }
86: 84: 
87: 85: impl Config {
88: 86:     pub fn load(
89: 87:         cli: Opts,
90: 88:         cwd: &Utf8Path,
91: 89:         manifest_path: &Utf8Path,
92: 90:         watch: bool,
93: 91:         bin_args: Option<&[String]>,
94: 92:     ) -> Result<Self> {
95: 93:         let metadata = Metadata::load_cleaned(manifest_path)?;
96: 94: 
97: 95:         let mut projects = Project::resolve(&cli, cwd, &metadata, watch, bin_args).dot()?;
98: 96: 
99: 97:         if projects.is_empty() {
100: 98:             bail!("Please define lyx-core-lyx_core_lyx-core-lyx_core_leptos projects in the workspace Cargo.toml sections [[workspace.metadata.lyx-core-lyx_core_lyx-core-lyx_core_leptos]]")
101: 99:         }
102: 100: 
103: 101:         if let Some(proj_name) = &cli.project {
104: 102:             if let Some(proj) = projects.iter().find(|p| p.name == *proj_name) {
105: 103:                 projects = vec![proj.clone()];
106: 104:             } else {
107: 105:                 bail!(
108: 106:                     r#"The specified project "{proj_name}" not found. Available projects: {}"#,
109: 107:                     names(&projects)
110: 108:                 )
111: 109:             }
112: 110:         }
113: 111: 
114: 112:         Ok(Self {
115: 113:             working_dir: metadata.workspace_root,
116: 114:             projects,
117: 115:             cli,
118: 116:             watch,
119: 117:         })
120: 118:     }
121: 119: 
122: 120:     #[cfg(test)]
123: 121:     pub fn test_load(
124: 122:         cli: Opts,
125: 123:         cwd: &str,
126: 124:         manifest_path: &str,
127: 125:         watch: bool,
128: 126:         bin_args: Option<&[String]>,
129: 127:     ) -> Self {
130: 128:         use crate::ext::PathBufExt;
131: 129: 
132: 130:         let manifest_path = Utf8PathBuf::from(manifest_path)
133: 131:             .canonicalize_utf8()
134: 132:             .unwrap();
135: 133:         let mut cwd = Utf8PathBuf::from(cwd).canonicalize_utf8().unwrap();
136: 134:         cwd.clean_windows_path();
137: 135:         Self::load(cli, &cwd, &manifest_path, watch, bin_args).unwrap()
138: 136:     }
139: 137: 
140: 138:     pub fn current_project(&self) -> Result<Arc<Project>> {
141: 139:         if self.projects.len() == 1 {
142: 140:             Ok(self.projects[0].clone())
143: 141:         } else {
144: 142:             bail!("There are several projects available ({}). Please select one of them with the command line parameter --project", names(&self.projects));
145: 143:         }
146: 144:     }
147: 145: }
148: 146: 
149: 147: fn names(projects: &[Arc<Project>]) -> String {
150: 148:     projects
151: 149:         .iter()
152: 150:         .map(|p| p.name.clone())
153: 151:         .collect::<Vec<_>>()
154: 152:         .join(", ")
155: 153: }
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
172: 170: ```
173: 171: ```
174: ```
```
