1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx-plat-deploy\src\main.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_deploy\src\main.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_deploy\src\main.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_deploy\src\main.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_deploy\src\main.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_deploy\src\main.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_deploy\src\main.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_deploy\src\main.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_deploy\src\main.rs
18: 16: ```rust
19: 17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_deploy\src\main.rs
20: 18: ```rust
21: 19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_deploy\src\main.rs
22: 20: ```rust
23: 21: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_deploy\src\main.rs
24: 22: ```rust
25: 23: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_deploy\src\main.rs
26: 24: ```rust
27: 25: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_deploy\src\main.rs
28: 26: ```rust
29: 27: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_deploy\src\main.rs
30: 28: ```rust
31: 29: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_deploy\src\main.rs
32: 30: ```rust
33: 31: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_deploy\src\main.rs
34: 32: ```rust
35: 33: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_deploy\src\main.rs
36: 34: ```rust
37: 35: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_deploy\src\main.rs
38: 36: ```rust
39: 37: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_deploy\src\main.rs
40: 38: ```rust
41: 39: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_deploy\src\main.rs
42: 40: ```rust
43: 41: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_deploy\src\main.rs
44: 42: ```rust
45: 43: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_deploy\src\main.rs
46: 44: ```rust
47: 45: use anyhow::{Context, Result};
48: 46: use clap::Parser;
49: 47: use oxyde_cloud_deploy::{Cli, deploy_with_config_file};
50: 48: use std::env;
51: 49: use std::fs::write;
52: 50: use std::path::PathBuf;
53: 51: use std::process::exit;
54: 52: 
55: 53: #[tokio::main]
56: 54: async fn main() -> Result<()> {
57: 55:     let github_output_path =
58: 56:         env::var("GITHUB_OUTPUT").context("Failed to get GITHUB_OUTPUT environment variable")?;
59: 57: 
60: 58:     let args: Vec<String> = env::args().collect();
61: 59:     let error = &args[1];
62: 60: 
63: 61:     if !error.is_empty() {
64: 62:         eprintln!("Error: {error}");
65: 63:         write(github_output_path, format!("error={error}"))
66: 64:             .context("Failed to write error to GitHub output file")?;
67: 65:         exit(1);
68: 66:     }
69: 67: 
70: 68:     let api_token = &args[2];
71: 69:     let config_file = &args[3];
72: 70:     let debug = &args[4];
73: 71: 
74: 72:     let lyx-core-lyx_core_lyx-core-lyx_core_leptos_args: Vec<String> = vec![
75: 73:         "cargo".to_string(),
76: 74:         "build".to_string(),
77: 75:         "--release".to_string(),
78: 76:     ];
79: 77:     let lyx-core-lyx_core_lyx-core-lyx_core_leptos_args = Cli::parse_from(&lyx-core-lyx_core_lyx-core-lyx_core_leptos_args);
80: 78: 
81: 79:     let mut cargo_lyx-core-lyx_core_lyx-core-lyx_core_leptos_opts = lyx-core-lyx_core_lyx-core-lyx_core_leptos_args
82: 80:         .opts()
83: 81:         .context("Failed to parse cargo lyx-core-lyx_core_lyx-core-lyx_core_leptos options")?;
84: 82: 
85: 83:     if !debug.is_empty() {
86: 84:         cargo_lyx-core-lyx_core_lyx-core-lyx_core_leptos_opts.verbose = 2;
87: 85:     }
88: 86: 
89: 87:     unsafe {
90: 88:         env::set_var("OXYDE_CLOUD_API_KEY", api_token);
91: 89:     }
92: 90: 
93: 91:     deploy_with_config_file(&PathBuf::from(config_file), cargo_lyx-core-lyx_core_lyx-core-lyx_core_leptos_opts)
94: 92:         .await
95: 93:         .context("Failed to deploy with config file")
96: 94: }
97: 95: ```
98: 96: ```
99: 97: ```
100: 98: ```
101: 99: ```
102: 100: ```
103: 101: ```
104: 102: ```
105: 103: ```
106: 104: ```
107: 105: ```
108: 106: ```
109: 107: ```
110: 108: ```
111: 109: ```
112: 110: ```
113: 111: ```
114: 112: ```
115: 113: ```
116: 114: ```
117: 115: ```
118: 116: ```
119: ```
```

