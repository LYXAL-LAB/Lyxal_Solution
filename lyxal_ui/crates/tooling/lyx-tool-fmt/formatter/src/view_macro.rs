### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx-tool-fmt\formatter\src\view_macro.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_fmt\formatter\src\view_macro.rs
2: ```rust
3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_fmt\formatter\src\view_macro.rs
4: ```rust
5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_fmt\formatter\src\view_macro.rs
6: ```rust
7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_fmt\formatter\src\view_macro.rs
8: ```rust
9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_fmt\formatter\src\view_macro.rs
10: ```rust
11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_fmt\formatter\src\view_macro.rs
12: ```rust
13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_fmt\formatter\src\view_macro.rs
14: ```rust
15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_fmt\formatter\src\view_macro.rs
16: ```rust
17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_fmt\formatter\src\view_macro.rs
18: ```rust
19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_fmt\formatter\src\view_macro.rs
20: ```rust
21: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_fmt\formatter\src\view_macro.rs
22: ```rust
23: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_fmt\formatter\src\view_macro.rs
24: ```rust
25: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_fmt\formatter\src\view_macro.rs
26: ```rust
27: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_fmt\formatter\src\view_macro.rs
28: ```rust
29: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_fmt\formatter\src\view_macro.rs
30: ```rust
31: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_fmt\formatter\src\view_macro.rs
32: ```rust
33: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_fmt\formatter\src\view_macro.rs
34: ```rust
35: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_fmt\formatter\src\view_macro.rs
36: ```rust
37: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_fmt\formatter\src\view_macro.rs
38: ```rust
39: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_fmt\formatter\src\view_macro.rs
40: ```rust
41: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_fmt\formatter\src\view_macro.rs
42: ```rust
43: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_fmt\formatter\src\view_macro.rs
44: ```rust
45: use std::collections::HashMap;
46: 
47: use crop::Rope;
48: use lyx-core-lyx_core_lyx-tooling-cli_prettyplease::MacroFormatter;
49: 
50: use crate::{Formatter, FormatterSettings, ViewMacro};
51: 
52: pub struct ViewMacroFormatter<'a> {
53:     settings: &'a FormatterSettings,
54:     source: Option<&'a Rope>,
55:     line_offset: &'a mut Option<usize>,
56:     comments: HashMap<usize, Option<String>>,
57: }
58: 
59: impl ViewMacroFormatter<'_> {
60:     pub fn new<'a>(
61:         settings: &'a FormatterSettings,
62:         source: Option<&'a Rope>,
63:         line_offset: &'a mut Option<usize>,
64:         comments: HashMap<usize, Option<String>>,
65:     ) -> ViewMacroFormatter<'a> {
66:         ViewMacroFormatter {
67:             settings,
68:             source,
69:             line_offset,
70:             comments,
71:         }
72:     }
73: }
74: 
75: pub fn get_macro_full_path(mac: &syn::Macro) -> String {
76:     mac.path
77:         .segments
78:         .iter()
79:         .map(|path| path.ident.to_string())
80:         .collect::<Vec<String>>()
81:         .join("::")
82: }
83: 
84: impl MacroFormatter for ViewMacroFormatter<'_> {
85:     fn format(
86:         &mut self,
87:         printer: &mut lyx-core-lyx_core_lyx-tooling-cli_pretty_printer::Printer,
88:         mac: &syn::Macro,
89:     ) -> bool {
90:         let mut formatted = false;
91: 
92:         for macro_name in &self.settings.macro_names {
93:             if &get_macro_full_path(mac) != macro_name {
94:                 continue;
95:             }
96: 
97:             let Some(m) = ViewMacro::try_parse(Default::default(), mac) else {
98:                 continue;
99:             };
100: 
101:             let mut formatter = Formatter {
102:                 printer,
103:                 settings: self.settings,
104:                 source: self.source,
105:                 line_offset: *self.line_offset,
106:                 whitespace_and_comments: self.comments.clone(),
107:             };
108: 
109:             formatter.view_macro(&m);
110:             formatted = true;
111:             *self.line_offset = formatter.line_offset;
112:         }
113: 
114:         formatted
115:     }
116: }
117: ```
118: ```
119: ```
120: ```
121: ```
122: ```
123: ```
124: ```
125: ```
126: ```
127: ```
128: ```
129: ```
130: ```
131: ```
132: ```
133: ```
134: ```
135: ```
136: ```
137: ```
138: ```
```
