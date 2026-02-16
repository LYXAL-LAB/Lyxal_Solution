1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_lyx-core-lyx_core_cac_toml\src\bin.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_cac_toml\src\bin.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_cac_toml\src\bin.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_cac_toml\src\bin.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_cac_toml\src\bin.rs
10: 8: ```rust
11: 9: use std::collections::HashMap;
12: 10: use std::process;
13: 11: 
14: 12: use lyx-core-lyx_core_lyx-core-lyx_core_cac_toml::ContextAwareConfig;
15: 13: use clap::{Arg, Command};
16: 14: use toml::Value;
17: 15: 
18: 16: fn main() {
19: 17:     let args = Command::new("CAC Demo App")
20: 18:         .arg(
21: 19:             Arg::new("dimension")
22: 20:                 .long("dimension")
23: 21:                 .short('d')
24: 22:                 .value_name("KEY=VALUE")
25: 23:                 .action(clap::ArgAction::Append)
26: 24:                 .help("Sets a key-value pair")
27: 25:                 .num_args(1),
28: 26:         )
29: 27:         .arg(
30: 28:             Arg::new("file")
31: 29:                 .long("file")
32: 30:                 .short('f')
33: 31:                 .help("take a cac config file as input")
34: 32:                 .required(true)
35: 33:                 .num_args(1),
36: 34:         )
37: 35:         .get_matches();
38: 36: 
39: 37:     let mut dimensions: HashMap<String, Value> = HashMap::new();
40: 38: 
41: 39:     if let Some(values) = args.get_many::<String>("dimension") {
42: 40:         for value in values {
43: 41:             let parts: Vec<&str> = value.split('=').collect();
44: 42:             if parts.len() == 2 {
45: 43:                 dimensions.insert(
46: 44:                     parts[0].to_string(),
47: 45:                     toml::Value::String(parts[1].to_string()),
48: 46:                 );
49: 47:             }
50: 48:         }
51: 49:     }
52: 50: 
53: 51:     let file: String = args.get_one::<String>("file").unwrap().to_string();
54: 52: 
55: 53:     let cac = ContextAwareConfig::parse(&file).unwrap_or_else(|_err| {
56: 54:         eprintln!("Could not parse file at {}", file);
57: 55:         process::exit(-1);
58: 56:     });
59: 57: 
60: 58:     println!("{:#?}", cac.get_resolved_config(&dimensions));
61: 59:     process::exit(0);
62: 60: }
63: 61: ```
64: 62: ```
65: 63: ```
66: 64: ```
67: ```
```

