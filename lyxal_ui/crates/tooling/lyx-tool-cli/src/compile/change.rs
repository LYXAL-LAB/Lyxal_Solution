### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx-tool-cli\src\compile\change.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx-tool-cli\src\compile\change.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\compile\change.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\compile\change.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\compile\change.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\compile\change.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\compile\change.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\compile\change.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\compile\change.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\compile\change.rs
18: 16: ```rust
19: 17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\compile\change.rs
20: 18: ```rust
21: 19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\compile\change.rs
22: 20: ```rust
23: 21: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\compile\change.rs
24: 22: ```rust
25: 23: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\compile\change.rs
26: 24: ```rust
27: 25: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\compile\change.rs
28: 26: ```rust
29: 27: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\compile\change.rs
30: 28: ```rust
31: 29: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\compile\change.rs
32: 30: ```rust
33: 31: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\compile\change.rs
34: 32: ```rust
35: 33: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\compile\change.rs
36: 34: ```rust
37: 35: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\compile\change.rs
38: 36: ```rust
39: 37: use std::vec;
40: 38: 
41: 39: use crate::service::notify::Watched;
42: 40: 
43: 41: #[derive(Debug, Clone, PartialEq, Eq)]
44: 42: pub enum Change {
45: 43:     /// sent when a bin target source file is changed
46: 44:     BinSource,
47: 45:     /// sent when a lib target source file is changed
48: 46:     LibSource,
49: 47:     /// sent when an asset file changed
50: 48:     Asset(Watched),
51: 49:     /// sent when a style file changed
52: 50:     Style,
53: 51:     /// Cargo.toml changed
54: 52:     Conf,
55: 53:     /// Additional file changed
56: 54:     Additional,
57: 55: }
58: 56: 
59: 57: #[derive(Debug, Default, Clone)]
60: 58: pub struct ChangeSet(Vec<Change>);
61: 59: 
62: 60: impl ChangeSet {
63: 61:     pub fn all_changes() -> Self {
64: 62:         Self(vec![
65: 63:             Change::BinSource,
66: 64:             Change::LibSource,
67: 65:             Change::Style,
68: 66:             Change::Conf,
69: 67:             Change::Asset(Watched::Rescan),
70: 68:         ])
71: 69:     }
72: 70: 
73: 71:     pub fn is_empty(&self) -> bool {
74: 72:         self.0.is_empty()
75: 73:     }
76: 74: 
77: 75:     pub fn clear(&mut self) {
78: 76:         self.0.clear()
79: 77:     }
80: 78: 
81: 79:     pub fn need_lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_build(&self) -> bool {
82: 80:         self.0.contains(&Change::BinSource)
83: 81:             || self.0.contains(&Change::Conf)
84: 82:             || self.0.contains(&Change::Additional)
85: 83:     }
86: 84: 
87: 85:     pub fn need_front_build(&self) -> bool {
88: 86:         self.0.contains(&Change::LibSource)
89: 87:             || self.0.contains(&Change::Conf)
90: 88:             || self.0.contains(&Change::Additional)
91: 89:     }
92: 90: 
93: 91:     pub fn asset_iter(&self) -> impl Iterator<Item = &Watched> {
94: 92:         self.0.iter().filter_map(|change| match change {
95: 93:             Change::Asset(a) => Some(a),
96: 94:             _ => None,
97: 95:         })
98: 96:     }
99: 97: 
100: 98:     pub fn need_style_build(&self, css_files: bool, css_in_source: bool) -> bool {
101: 99:         (css_files && self.0.contains(&Change::Style))
102: 100:             || (css_in_source && self.0.contains(&Change::LibSource))
103: 101:     }
104: 102: 
105: 103:     pub fn add(&mut self, change: Change) -> bool {
106: 104:         if !self.0.contains(&change) {
107: 105:             self.0.push(change);
108: 106:             true
109: 107:         } else {
110: 108:             false
111: 109:         }
112: 110:     }
113: 111: }
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
128: 126: ```
129: 127: ```
130: 128: ```
131: 129: ```
132: ```
```
