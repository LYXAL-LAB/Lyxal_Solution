### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx-tool-cli\src\compile\mod.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx-tool-cli\src\compile\mod.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\compile\mod.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\compile\mod.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\compile\mod.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\compile\mod.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\compile\mod.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\compile\mod.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\compile\mod.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\compile\mod.rs
18: 16: ```rust
19: 17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\compile\mod.rs
20: 18: ```rust
21: 19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\compile\mod.rs
22: 20: ```rust
23: 21: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\compile\mod.rs
24: 22: ```rust
25: 23: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\compile\mod.rs
26: 24: ```rust
27: 25: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\compile\mod.rs
28: 26: ```rust
29: 27: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\compile\mod.rs
30: 28: ```rust
31: 29: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\compile\mod.rs
32: 30: ```rust
33: 31: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\compile\mod.rs
34: 32: ```rust
35: 33: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\compile\mod.rs
36: 34: ```rust
37: 35: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\compile\mod.rs
38: 36: ```rust
39: 37: #[cfg(test)]
40: 38: mod tests;
41: 39: 
42: 40: mod assets;
43: 41: mod change;
44: 42: mod front;
45: 43: mod hash;
46: 44: mod sass;
47: 45: mod lyx-platform-lyx_platform_lyx-platform-lyx_platform_server;
48: 46: mod style;
49: 47: mod tailwind;
50: 48: 
51: 49: pub use assets::assets;
52: 50: pub use change::{Change, ChangeSet};
53: 51: pub use front::{front, front_cargo_process};
54: 52: pub use hash::add_hashes_to_site;
55: 53: pub use lyx-platform-lyx_platform_lyx-platform-lyx_platform_server::{lyx-platform-lyx_platform_lyx-platform-lyx_platform_server, lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_cargo_process};
56: 54: pub use style::style;
57: 55: 
58: 56: use itertools::Itertools;
59: 57: 
60: 58: fn build_cargo_command_string(args: impl IntoIterator<Item = String>) -> String {
61: 59:     std::iter::once("cargo".to_owned())
62: 60:         .chain(args.into_iter().map(|arg| {
63: 61:             if arg.contains(' ') {
64: 62:                 format!("'{arg}'")
65: 63:             } else {
66: 64:                 arg
67: 65:             }
68: 66:         }))
69: 67:         .join(" ")
70: 68: }
71: 69: ```
72: 70: ```
73: 71: ```
74: 72: ```
75: 73: ```
76: 74: ```
77: 75: ```
78: 76: ```
79: 77: ```
80: 78: ```
81: 79: ```
82: 80: ```
83: 81: ```
84: 82: ```
85: 83: ```
86: 84: ```
87: 85: ```
88: 86: ```
89: ```
```
