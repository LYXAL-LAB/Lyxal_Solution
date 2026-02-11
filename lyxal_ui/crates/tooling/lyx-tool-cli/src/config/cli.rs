### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx-tool-cli\src\config\cli.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx-tool-cli\src\config\cli.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\cli.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\cli.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\cli.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\cli.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\cli.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\cli.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\cli.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\cli.rs
18: 16: ```rust
19: 17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\cli.rs
20: 18: ```rust
21: 19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\cli.rs
22: 20: ```rust
23: 21: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\cli.rs
24: 22: ```rust
25: 23: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\cli.rs
26: 24: ```rust
27: 25: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\cli.rs
28: 26: ```rust
29: 27: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\cli.rs
30: 28: ```rust
31: 29: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\cli.rs
32: 30: ```rust
33: 31: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\cli.rs
34: 32: ```rust
35: 33: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\cli.rs
36: 34: ```rust
37: 35: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\cli.rs
38: 36: ```rust
39: 37: use crate::command::NewCommand;
40: 38: use camino::Utf8PathBuf;
41: 39: use clap::{Parser, Subcommand, ValueEnum};
42: 40: 
43: 41: #[derive(Copy, Clone, Debug, PartialEq, Eq, PartialOrd, Ord, ValueEnum)]
44: 42: pub enum Log {
45: 43:     /// WASM build (wasm, wasm-opt, walrus)
46: 44:     Wasm,
47: 45:     /// Internal reload and csr lyx-platform-lyx_platform_lyx-platform-lyx_platform_server (hyper, axum)
48: 46:     Server,
49: 47: }
50: 48: 
51: 49: #[derive(Debug, Clone, Parser, PartialEq, Default)]
52: 50: pub struct Opts {
53: 51:     /// Build artifacts in release mode, with optimizations.
54: 52:     #[arg(short, long)]
55: 53:     pub release: bool,
56: 54: 
57: 55:     /// Precompress static assets with gzip and brotli. Applies to release builds only.
58: 56:     #[arg(short = 'P', long)]
59: 57:     pub precompress: bool,
60: 58: 
61: 59:     /// Turn on partial hot-reloading. Requires rust nightly [beta]
62: 60:     #[arg(long)]
63: 61:     pub hot_reload: bool,
64: 62: 
65: 63:     /// Which project to use, from a list of projects defined in a workspace
66: 64:     #[arg(short, long)]
67: 65:     pub project: Option<String>,
68: 66: 
69: 67:     /// The features to use when compiling all targets
70: 68:     #[arg(long)]
71: 69:     pub features: Vec<String>,
72: 70: 
73: 71:     /// The features to use when compiling the lib target
74: 72:     #[arg(long)]
75: 73:     pub lib_features: Vec<String>,
76: 74: 
77: 75:     /// The cargo flags to pass to cargo when compiling the lib target
78: 76:     #[arg(long)]
79: 77:     pub lib_cargo_args: Option<Vec<String>>,
80: 78: 
81: 79:     /// The features to use when compiling the bin target
82: 80:     #[arg(long)]
83: 81:     pub bin_features: Vec<String>,
84: 82: 
85: 83:     /// The cargo flags to pass to cargo when compiling the bin target
86: 84:     #[arg(long)]
87: 85:     pub bin_cargo_args: Option<Vec<String>>,
88: 86: 
89: 87:     /// Include debug information in Wasm output. Includes source maps and DWARF debug info.
90: 88:     #[arg(long)]
91: 89:     pub wasm_debug: bool,
92: 90: 
93: 91:     /// Verbosity (none: info, errors & warnings, -v: verbose, -vv: very verbose).
94: 92:     #[arg(short, action = clap::ArgAction::Count)]
95: 93:     pub verbose: u8,
96: 94: 
97: 95:     /// Minify javascript assets with swc. Applies to release builds only.
98: 96:     #[arg(long, default_value = "true", value_parser=clap::builder::BoolishValueParser::new(), action = clap::ArgAction::Set)]
99: 97:     pub js_minify: bool,
100: 98: }
101: 99: 
102: 100: #[derive(Debug, Clone, Parser, PartialEq, Default)]
103: 101: pub struct BinOpts {
104: 102:     #[command(flatten)]
105: 103:     opts: Opts,
106: 104: 
107: 105:     #[arg(trailing_var_arg = true)]
108: 106:     bin_args: Vec<String>,
109: 107: }
110: 108: 
111: 109: #[derive(Debug, Parser)]
112: 110: #[clap(version)]
113: 111: pub struct Cli {
114: 112:     /// Path to Cargo.toml.
115: 113:     #[arg(long)]
116: 114:     pub manifest_path: Option<Utf8PathBuf>,
117: 115: 
118: 116:     /// Output logs from dependencies (multiple --log accepted).
119: 117:     #[arg(long)]
120: 118:     pub log: Vec<Log>,
121: 119: 
122: 120:     #[command(subcommand)]
123: 121:     pub command: Commands,
124: 122: }
125: 123: 
126: 124: impl Cli {
127: 125:     pub fn opts(&self) -> Option<Opts> {
128: 126:         use Commands::{Build, EndToEnd, New, Serve, Test, Watch};
129: 127:         match &self.command {
130: 128:             New(_) => None,
131: 129:             Serve(bin_opts) | Watch(bin_opts) => Some(bin_opts.opts.clone()),
132: 130:             Build(opts) | Test(opts) | EndToEnd(opts) => Some(opts.clone()),
133: 131:         }
134: 132:     }
135: 133: 
136: 134:     pub fn bin_args(&self) -> Option<&[String]> {
137: 135:         use Commands::{Serve, Watch};
138: 136:         match &self.command {
139: 137:             Serve(bin_opts) | Watch(bin_opts) => Some(bin_opts.bin_args.as_ref()),
140: 138:             _ => None,
141: 139:         }
142: 140:     }
143: 141: }
144: 142: 
145: 143: #[derive(Debug, Subcommand, PartialEq)]
146: 144: pub enum Commands {
147: 145:     /// Build the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server (feature ssr) and the lyx-core-lyx_core_lyx-core-lyx_core_client (wasm with feature hydrate).
148: 146:     Build(Opts),
149: 147:     /// Run the cargo tests for lyx-platform-lyx_platform_lyx-platform-lyx_platform_app, lyx-core-lyx_core_lyx-core-lyx_core_client and lyx-platform-lyx_platform_lyx-platform-lyx_platform_server.
150: 148:     Test(Opts),
151: 149:     /// Start the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server and end-2-end tests.
152: 150:     EndToEnd(Opts),
153: 151:     /// Serve. Defaults to hydrate mode.
154: 152:     Serve(BinOpts),
155: 153:     /// Serve and automatically reload when files change.
156: 154:     Watch(BinOpts),
157: 155:     /// Start a wizard for creating a new project (using cargo-generate).
158: 156:     New(NewCommand),
159: 157: }
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
174: 172: ```
175: 173: ```
176: 174: ```
177: 175: ```
178: ```
```
