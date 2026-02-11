### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx-tool-cli\src\tests.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx-tool-cli\src\tests.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\tests.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\tests.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\tests.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\tests.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\tests.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\tests.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\tests.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\tests.rs
18: 16: ```rust
19: 17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\tests.rs
20: 18: ```rust
21: 19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\tests.rs
22: 20: ```rust
23: 21: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\tests.rs
24: 22: ```rust
25: 23: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\tests.rs
26: 24: ```rust
27: 25: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\tests.rs
28: 26: ```rust
29: 27: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\tests.rs
30: 28: ```rust
31: 29: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\tests.rs
32: 30: ```rust
33: 31: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\tests.rs
34: 32: ```rust
35: 33: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\tests.rs
36: 34: ```rust
37: 35: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\tests.rs
38: 36: ```rust
39: 37: use camino::Utf8PathBuf;
40: 38: 
41: 39: use crate::{
42: 40:     config::{Cli, Commands, Opts},
43: 41:     ext::PathBufExt,
44: 42:     run,
45: 43: };
46: 44: 
47: 45: #[tokio::test]
48: 46: async fn workspace_build() {
49: 47:     let command = Commands::Build(Opts::default());
50: 48: 
51: 49:     let cli = Cli {
52: 50:         manifest_path: Some(Utf8PathBuf::from("lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_examples/workspace/Cargo.toml")),
53: 51:         log: Vec::new(),
54: 52:         command,
55: 53:     };
56: 54: 
57: 55:     run(cli).await.unwrap();
58: 56: 
59: 57:     // when running the current working directory is changed to the manifest path.
60: 58:     let site_dir = Utf8PathBuf::from("target/site");
61: 59: 
62: 60:     //insta::assert_snapshot!(site_dir.ls_ascii(0).unwrap_or_default());
63: 61: }
64: 62: 
65: 63: // TODO: `cargo-lyx-core-lyx_core_lyx-core-lyx_core_leptos` sets the cwd which is a global env
66: 64: // and that prevents builds to run in parallel in the same process
67: 65: //
68: 66: // #[tokio::test]
69: 67: // async fn project_build() {
70: 68: //     let command = Commands::Build(Opts::default());
71: 69: 
72: 70: //     let cli = Cli {
73: 71: //         manifest_path: Some(Utf8PathBuf::from("lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_examples/project/Cargo.toml")),
74: 72: //         log: Vec::new(),
75: 73: //         command,
76: 74: //     };
77: 75: 
78: 76: //     run(cli).await.unwrap();
79: 77: 
80: 78: //     // when running the current working directory is changed to the manifest path.
81: 79: //     let site_dir = Utf8PathBuf::from("target/site");
82: 80: 
83: 81: //     insta::assert_snapshot!(site_dir.ls_ascii(0).unwrap_or_default());
84: 82: // }
85: 83: ```
86: 84: ```
87: 85: ```
88: 86: ```
89: 87: ```
90: 88: ```
91: 89: ```
92: 90: ```
93: 91: ```
94: 92: ```
95: 93: ```
96: 94: ```
97: 95: ```
98: 96: ```
99: 97: ```
100: 98: ```
101: 99: ```
102: 100: ```
103: ```
```
