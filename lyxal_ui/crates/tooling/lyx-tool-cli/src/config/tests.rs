### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx-tool-cli\src\config\tests.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx-tool-cli\src\config\tests.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\tests.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\tests.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\tests.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\tests.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\tests.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\tests.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\tests.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\tests.rs
18: 16: ```rust
19: 17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\tests.rs
20: 18: ```rust
21: 19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\tests.rs
22: 20: ```rust
23: 21: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\tests.rs
24: 22: ```rust
25: 23: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\tests.rs
26: 24: ```rust
27: 25: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\tests.rs
28: 26: ```rust
29: 27: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\tests.rs
30: 28: ```rust
31: 29: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\tests.rs
32: 30: ```rust
33: 31: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\tests.rs
34: 32: ```rust
35: 33: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\tests.rs
36: 34: ```rust
37: 35: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\tests.rs
38: 36: ```rust
39: 37: use super::Config;
40: 38: 
41: 39: fn opts(project: Option<&str>) -> crate::config::Opts {
42: 40:     crate::config::Opts {
43: 41:         release: false,
44: 42:         js_minify: false,
45: 43:         precompress: false,
46: 44:         hot_reload: false,
47: 45:         project: project.map(|s| s.to_string()),
48: 46:         verbose: 0,
49: 47:         features: Vec::new(),
50: 48:         bin_features: Vec::new(),
51: 49:         lib_features: Vec::new(),
52: 50:         bin_cargo_args: None,
53: 51:         lib_cargo_args: None,
54: 52:         wasm_debug: false,
55: 53:     }
56: 54: }
57: 55: 
58: 56: // this test causes issues in CI because the tailwind tmp_file field is an absolute path,
59: 57: // so differs by platform
60: 58: /* #[test]
61: 59: fn test_project() {
62: 60:     let cli = opts(None);
63: 61: 
64: 62:     let conf = Config::test_load(cli, "lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_examples", "lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_examples/project/Cargo.toml", true);
65: 63: 
66: 64:     insta::assert_debug_snapshot!(conf);
67: 65: } */
68: 66: 
69: 67: #[test]
70: 68: fn test_workspace() {
71: 69:     let cli = opts(None);
72: 70: 
73: 71:     let conf = Config::test_load(cli, "lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_examples", "lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_examples/workspace/Cargo.toml", true, None);
74: 72: 
75: 73:     insta::assert_debug_snapshot!(conf);
76: 74: }
77: 75: 
78: 76: #[test]
79: 77: fn test_workspace_project1() {
80: 78:     let cli = opts(Some("project1"));
81: 79: 
82: 80:     let conf = Config::test_load(cli, "lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_examples", "lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_examples/workspace/Cargo.toml", true, None);
83: 81: 
84: 82:     insta::assert_debug_snapshot!(conf);
85: 83: }
86: 84: 
87: 85: #[test]
88: 86: fn test_workspace_project2() {
89: 87:     let cli = opts(Some("project2"));
90: 88: 
91: 89:     let conf = Config::test_load(cli, "lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_examples", "lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_examples/workspace/Cargo.toml", true, None);
92: 90: 
93: 91:     insta::assert_debug_snapshot!(conf);
94: 92: }
95: 93: 
96: 94: #[test]
97: 95: fn test_workspace_in_subdir_project2() {
98: 96:     let cli = opts(None);
99: 97: 
100: 98:     let conf = Config::test_load(
101: 99:         cli,
102: 100:         "lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_examples/workspace/project2",
103: 101:         "lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_examples/workspace/Cargo.toml",
104: 102:         true,
105: 103:         None,
106: 104:     );
107: 105: 
108: 106:     insta::assert_debug_snapshot!(conf);
109: 107: }
110: 108: 
111: 109: #[test]
112: 110: fn test_workspace_bin_args_project2() {
113: 111:     let cli = opts(Some("project2"));
114: 112: 
115: 113:     let conf = Config::test_load(
116: 114:         cli,
117: 115:         "lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_examples",
118: 116:         "lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_examples/workspace/Cargo.toml",
119: 117:         true,
120: 118:         Some(&["--".to_string(), "--foo".to_string()]),
121: 119:     );
122: 120: 
123: 121:     insta::assert_debug_snapshot!(conf);
124: 122: }
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
137: 135: ```
138: 136: ```
139: 137: ```
140: 138: ```
141: 139: ```
142: 140: ```
143: ```
```
