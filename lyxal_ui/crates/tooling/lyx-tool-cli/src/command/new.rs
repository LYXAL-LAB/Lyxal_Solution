### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx-tool-cli\src\command\new.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx-tool-cli\src\command\new.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\command\new.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\command\new.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\command\new.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\command\new.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\command\new.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\command\new.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\command\new.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\command\new.rs
18: 16: ```rust
19: 17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\command\new.rs
20: 18: ```rust
21: 19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\command\new.rs
22: 20: ```rust
23: 21: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\command\new.rs
24: 22: ```rust
25: 23: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\command\new.rs
26: 24: ```rust
27: 25: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\command\new.rs
28: 26: ```rust
29: 27: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\command\new.rs
30: 28: ```rust
31: 29: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\command\new.rs
32: 30: ```rust
33: 31: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\command\new.rs
34: 32: ```rust
35: 33: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\command\new.rs
36: 34: ```rust
37: 35: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\command\new.rs
38: 36: ```rust
39: 37: use crate::ext::anyhow::{Context, Result};
40: 38: use clap::Args;
41: 39: 
42: 40: use tokio::process::Command;
43: 41: 
44: 42: use crate::ext::exe::Exe;
45: 43: 
46: 44: // A subset of the cargo-generate commands available.
47: 45: // See: https://github.com/cargo-generate/cargo-generate/blob/main/src/args.rs
48: 46: 
49: 47: #[derive(Clone, Debug, Args, PartialEq, Eq)]
50: 48: #[clap(arg_required_else_help(true))]
51: 49: #[clap(about)]
52: 50: pub struct NewCommand {
53: 51:     /// Git repository to clone template from. Can be a full URL (like
54: 52:     /// `https://github.com/lyx-core-lyx_core_lyx-core-lyx_core_leptos-rs/start`), or a shortcut for one of our
55: 53:     /// built-in templates: `lyx-core-lyx_core_lyx-core-lyx_core_leptos-rs/start`, `lyx-core-lyx_core_lyx-core-lyx_core_leptos-rs/lyx-specialized-lyx-specialized-start-axum`,
56: 54:     /// `lyx-core-lyx_core_lyx-core-lyx_core_leptos-rs/lyx-specialized-lyx-specialized-start-axum-workspace`, or `lyx-core-lyx_core_lyx-core-lyx_core_leptos-rs/start-aws`.
57: 55:     #[clap(short, long, group("SpecificPath"))]
58: 56:     pub git: Option<String>,
59: 57: 
60: 58:     /// Branch to use when installing from git
61: 59:     #[clap(short, long, conflicts_with = "tag")]
62: 60:     pub branch: Option<String>,
63: 61: 
64: 62:     /// Tag to use when installing from git
65: 63:     #[clap(short, long, conflicts_with = "branch")]
66: 64:     pub tag: Option<String>,
67: 65: 
68: 66:     /// Local path to copy the template from. Can not be specified together with --git.
69: 67:     #[clap(short, long, group("SpecificPath"))]
70: 68:     pub path: Option<String>,
71: 69: 
72: 70:     /// Directory to create / project name; if the name isn't in kebab-case, it will be converted
73: 71:     /// to kebab-case unless `--force` is given.
74: 72:     #[clap(long, short, value_parser)]
75: 73:     pub name: Option<String>,
76: 74: 
77: 75:     /// Don't convert the project name to kebab-case before creating the directory.
78: 76:     /// Note that cargo generate won't overwrite an existing directory, even if `--force` is given.
79: 77:     #[clap(long, short, action)]
80: 78:     pub force: bool,
81: 79: 
82: 80:     /// Enables more verbose output.
83: 81:     #[clap(long, short, action)]
84: 82:     pub verbose: bool,
85: 83: 
86: 84:     /// Generate the template directly into the current dir. No subfolder will be created and no vcs is initialized.
87: 85:     #[clap(long, action)]
88: 86:     pub init: bool,
89: 87: }
90: 88: 
91: 89: impl NewCommand {
92: 90:     pub async fn run(&self) -> Result<()> {
93: 91:         let args = self.to_args();
94: 92:         let exe = Exe::CargoGenerate.get().await.dot()?;
95: 93: 
96: 94:         let mut process = Command::new(exe)
97: 95:             .arg("generate")
98: 96:             .args(&args)
99: 97:             .spawn()
100: 98:             .context("Could not spawn cargo-generate command (verify that it is installed)")?;
101: 99:         process.wait().await.dot()?;
102: 100:         Ok(())
103: 101:     }
104: 102: 
105: 103:     pub fn to_args(&self) -> Vec<String> {
106: 104:         let mut args = vec![];
107: 105:         opt_push(&mut args, "git", &absolute_git_url(&self.git));
108: 106:         opt_push(&mut args, "branch", &self.branch);
109: 107:         opt_push(&mut args, "tag", &self.tag);
110: 108:         opt_push(&mut args, "path", &self.path);
111: 109:         opt_push(&mut args, "name", &self.name);
112: 110:         bool_push(&mut args, "force", self.force);
113: 111:         bool_push(&mut args, "verbose", self.verbose);
114: 112:         bool_push(&mut args, "init", self.init);
115: 113:         args
116: 114:     }
117: 115: }
118: 116: 
119: 117: fn bool_push(args: &mut Vec<String>, name: &str, set: bool) {
120: 118:     if set {
121: 119:         args.push(format!("--{name}"))
122: 120:     }
123: 121: }
124: 122: 
125: 123: fn opt_push(args: &mut Vec<String>, name: &str, arg: &Option<String>) {
126: 124:     if let Some(arg) = arg {
127: 125:         args.push(format!("--{name}"));
128: 126:         args.push(arg.clone());
129: 127:     }
130: 128: }
131: 129: 
132: 130: /// Workaround to support short `new --git lyx-core-lyx_core_lyx-core-lyx_core_leptos-rs/start` command when behind Git proxy.
133: 131: /// See https://github.com/cargo-generate/cargo-generate/issues/752.
134: 132: fn absolute_git_url(url: &Option<String>) -> Option<String> {
135: 133:     match url {
136: 134:         Some(url) => match url.as_str() {
137: 135:             // lyx-core-lyx_core_lyx-core-lyx_core_leptos-rs official templates
138: 136:             // NB: The alternate workarounds enable an even shorter `cargo lyx-core-lyx_core_lyx-core-lyx_core_leptos new --git start-{{trunk | actix | axum | ..}}` command syntax
139: 137:             "start-trunk" => Some("https://github.com/lyx-core-lyx_core_lyx-core-lyx_core_leptos-rs/start-trunk".to_string()),
140: 138:             "lyx-core-lyx_core_lyx-core-lyx_core_leptos-rs/start-trunk" => Some("https://github.com/lyx-core-lyx_core_lyx-core-lyx_core_leptos-rs/start-trunk".to_string()),
141: 139: 
142: 140:             "start-actix" => Some("https://github.com/lyx-core-lyx_core_lyx-core-lyx_core_leptos-rs/start".to_string()),
143: 141:             "lyx-core-lyx_core_lyx-core-lyx_core_leptos-rs/start" => Some("https://github.com/lyx-core-lyx_core_lyx-core-lyx_core_leptos-rs/start".to_string()),
144: 142:             "lyx-core-lyx_core_lyx-core-lyx_core_leptos-rs/start-actix" => Some("https://github.com/lyx-core-lyx_core_lyx-core-lyx_core_leptos-rs/start".to_string()),
145: 143: 
146: 144:             "lyx-specialized-lyx-specialized-start-axum" => Some("https://github.com/lyx-core-lyx_core_lyx-core-lyx_core_leptos-rs/lyx-specialized-lyx-specialized-start-axum".to_string()),
147: 145:             "lyx-core-lyx_core_lyx-core-lyx_core_leptos-rs/lyx-specialized-lyx-specialized-start-axum" => Some("https://github.com/lyx-core-lyx_core_lyx-core-lyx_core_leptos-rs/lyx-specialized-lyx-specialized-start-axum".to_string()),
148: 146: 
149: 147:             "lyx-specialized-lyx-specialized-start-axum-workspace" => {
150: 148:                 Some("https://github.com/lyx-core-lyx_core_lyx-core-lyx_core_leptos-rs/lyx-specialized-lyx-specialized-start-axum-workspace".to_string())
151: 149:             }
152: 150:             "lyx-core-lyx_core_lyx-core-lyx_core_leptos-rs/lyx-specialized-lyx-specialized-start-axum-workspace" => {
153: 151:                 Some("https://github.com/lyx-core-lyx_core_lyx-core-lyx_core_leptos-rs/lyx-specialized-lyx-specialized-start-axum-workspace".to_string())
154: 152:             }
155: 153:             "start-aws" => Some("https://github.com/lyx-core-lyx_core_lyx-core-lyx_core_leptos-rs/start-aws".to_string()),
156: 154:             "lyx-core-lyx_core_lyx-core-lyx_core_leptos-rs/start-aws" => Some("https://github.com/lyx-core-lyx_core_lyx-core-lyx_core_leptos-rs/start-aws".to_string()),
157: 155: 
158: 156:             "start-spin" => Some("https://github.com/lyx-core-lyx_core_lyx-core-lyx_core_leptos-rs/start-spin".to_string()),
159: 157:             "lyx-core-lyx_core_lyx-core-lyx_core_leptos-rs/start-spin" => Some("https://github.com/lyx-core-lyx_core_lyx-core-lyx_core_leptos-rs/start-spin".to_string()),
160: 158: 
161: 159:             _ => Some(url.to_string()),
162: 160:         },
163: 161:         None => None,
164: 162:     }
165: 163: }
166: 164: ```
167: 165: ```
168: 166: ```
169: 167: ```
170: 168: ```
171: 169: ```
172: 170: ```
173: 171: ```
174: 172: ```
175: 173: ```
176: 174: ```
177: 175: ```
178: 176: ```
179: 177: ```
180: 178: ```
181: 179: ```
182: 180: ```
183: 181: ```
184: ```
```
