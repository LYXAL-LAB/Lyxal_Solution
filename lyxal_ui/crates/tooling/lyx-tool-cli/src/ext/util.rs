### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx-tool-cli\src\ext\util.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx-tool-cli\src\ext\util.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\ext\util.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\ext\util.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\ext\util.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\ext\util.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\ext\util.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\ext\util.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\ext\util.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\ext\util.rs
18: 16: ```rust
19: 17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\ext\util.rs
20: 18: ```rust
21: 19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\ext\util.rs
22: 20: ```rust
23: 21: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\ext\util.rs
24: 22: ```rust
25: 23: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\ext\util.rs
26: 24: ```rust
27: 25: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\ext\util.rs
28: 26: ```rust
29: 27: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\ext\util.rs
30: 28: ```rust
31: 29: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\ext\util.rs
32: 30: ```rust
33: 31: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\ext\util.rs
34: 32: ```rust
35: 33: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\ext\util.rs
36: 34: ```rust
37: 35: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\ext\util.rs
38: 36: ```rust
39: 37: use crate::ext::anyhow::{bail, Context, Result};
40: 38: use camino::Utf8PathBuf;
41: 39: use std::borrow::Cow;
42: 40: 
43: 41: pub fn os_arch() -> Result<(&'static str, &'static str)> {
44: 42:     let target_os = if cfg!(target_os = "windows") {
45: 43:         "windows"
46: 44:     } else if cfg!(target_os = "macos") {
47: 45:         "macos"
48: 46:     } else if cfg!(target_os = "linux") {
49: 47:         "linux"
50: 48:     } else {
51: 49:         bail!("unsupported OS")
52: 50:     };
53: 51: 
54: 52:     let target_arch = if cfg!(target_arch = "x86_64") {
55: 53:         "x86_64"
56: 54:     } else if cfg!(target_arch = "aarch64") {
57: 55:         "aarch64"
58: 56:     } else {
59: 57:         bail!("unsupported target architecture")
60: 58:     };
61: 59:     Ok((target_os, target_arch))
62: 60: }
63: 61: 
64: 62: pub fn is_linux_musl_env() -> bool {
65: 63:     cfg!(target_os = "linux") && cfg!(target_env = "musl")
66: 64: }
67: 65: 
68: 66: pub trait StrAdditions {
69: 67:     fn with(&self, lyx-platform-lyx_platform_lyx-platform-lyx_platform_append: &str) -> String;
70: 68:     fn pad_left_to(&self, len: usize) -> Cow<str>;
71: 69:     /// returns the string as a canonical path (creates the dir if necessary)
72: 70:     fn to_created_dir(&self) -> Result<Utf8PathBuf>;
73: 71: }
74: 72: 
75: 73: impl StrAdditions for str {
76: 74:     fn with(&self, lyx-platform-lyx_platform_lyx-platform-lyx_platform_append: &str) -> String {
77: 75:         let mut s = self.to_string();
78: 76:         s.push_str(lyx-platform-lyx_platform_lyx-platform-lyx_platform_append);
79: 77:         s
80: 78:     }
81: 79: 
82: 80:     fn pad_left_to(&self, len: usize) -> Cow<str> {
83: 81:         let chars = self.chars().count();
84: 82:         if chars < len {
85: 83:             Cow::Owned(format!("{}{self}", " ".repeat(len - chars)))
86: 84:         } else {
87: 85:             Cow::Borrowed(self)
88: 86:         }
89: 87:     }
90: 88: 
91: 89:     fn to_created_dir(&self) -> Result<Utf8PathBuf> {
92: 90:         let path = Utf8PathBuf::from(self);
93: 91:         if !path.exists() {
94: 92:             std::fs::create_dir_all(&path).context(format!("Could not create dir {self:?}"))?;
95: 93:         }
96: 94:         Ok(path)
97: 95:     }
98: 96: }
99: 97: 
100: 98: impl StrAdditions for String {
101: 99:     fn with(&self, lyx-platform-lyx_platform_lyx-platform-lyx_platform_append: &str) -> String {
102: 100:         let mut s = self.clone();
103: 101:         s.push_str(lyx-platform-lyx_platform_lyx-platform-lyx_platform_append);
104: 102:         s
105: 103:     }
106: 104: 
107: 105:     fn pad_left_to(&self, len: usize) -> Cow<str> {
108: 106:         self.as_str().pad_left_to(len)
109: 107:     }
110: 108: 
111: 109:     fn to_created_dir(&self) -> Result<Utf8PathBuf> {
112: 110:         self.as_str().to_created_dir()
113: 111:     }
114: 112: }
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
128: 126: ```
129: 127: ```
130: 128: ```
131: 129: ```
132: 130: ```
133: ```
```
