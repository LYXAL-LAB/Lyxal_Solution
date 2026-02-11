### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_cac_lyx-core-lyx_core_client\src\utils.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_cac_lyx-core-lyx_core_lyx-core-lyx_core_client\src\utils.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_cac_lyx-core-lyx_core_lyx-core-lyx_core_client\src\utils.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_cac_lyx-core-lyx_core_lyx-core-lyx_core_client\src\utils.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_cac_lyx-core-lyx_core_lyx-core-lyx_core_client\src\utils.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_cac_lyx-core-lyx_core_lyx-core-lyx_core_client\src\utils.rs
10: 8: ```rust
11: 9: use itertools::{self, Itertools};
12: 10: use serde_json::Value;
13: 11: pub mod core;
14: 12: 
15: 13: pub fn json_to_sorted_string(v: &Value) -> String {
16: 14:     match v {
17: 15:         Value::Object(m) => {
18: 16:             let mut new_str: String = String::from("");
19: 17:             for (i, val) in m.iter().sorted_by_key(|item| item.0) {
20: 18:                 let p: String = json_to_sorted_string(val);
21: 19:                 new_str.push_str(i);
22: 20:                 new_str.push_str(&String::from(":"));
23: 21:                 new_str.push_str(&p);
24: 22:                 new_str.push_str(&String::from("$"));
25: 23:             }
26: 24:             new_str
27: 25:         }
28: 26:         Value::String(m) => m.to_string(),
29: 27:         Value::Number(m) => m.to_string(),
30: 28:         Value::Bool(m) => m.to_string(),
31: 29:         Value::Null => String::from("null"),
32: 30:         Value::Array(m) => {
33: 31:             let mut new_vec =
34: 32:                 m.iter().map(json_to_sorted_string).collect::<Vec<String>>();
35: 33:             new_vec.sort();
36: 34:             new_vec.join(",")
37: 35:         }
38: 36:     }
39: 37: }
40: 38: 
41: 39: #[cfg(test)]
42: 40: mod tests {
43: 41:     use super::*;
44: 42:     use serde_json::json;
45: 43: 
46: 44:     #[test]
47: 45:     fn test_json_to_sorted_string() {
48: 46:         let first_condition: Value = json!({
49: 47:             "and": [
50: 48:                 {
51: 49:                     "==": [
52: 50:                         {
53: 51:                             "var": "os"
54: 52:                         },
55: 53:                         "android"
56: 54:                     ]
57: 55:                 },
58: 56:                 {
59: 57:                     "==": [
60: 58:                         {
61: 59:                             "var": "lyx-core-lyx_core_lyx-core-lyx_core_clientId"
62: 60:                         },
63: 61:                         "geddit"
64: 62:                     ]
65: 63:                 }
66: 64:             ]
67: 65:         });
68: 66: 
69: 67:         let second_condition: Value = json!({
70: 68:             "and": [
71: 69:                 {
72: 70:                     "==": [
73: 71:                         {
74: 72:                             "var": "lyx-core-lyx_core_lyx-core-lyx_core_clientId"
75: 73:                         },
76: 74:                         "geddit"
77: 75:                     ]
78: 76:                 },
79: 77:                 {
80: 78:                     "==": [
81: 79:                         {
82: 80:                             "var": "os"
83: 81:                         },
84: 82:                         "android"
85: 83:                     ]
86: 84:                 }
87: 85:             ]
88: 86:         });
89: 87:         let expected_string: String =
90: 88:             "and:==:android,var:os$$,==:geddit,var:lyx-core-lyx_core_lyx-core-lyx_core_clientId$$$".to_owned();
91: 89:         assert_eq!(json_to_sorted_string(&first_condition), expected_string);
92: 90:         assert_eq!(
93: 91:             json_to_sorted_string(&first_condition),
94: 92:             json_to_sorted_string(&second_condition)
95: 93:         );
96: 94:     }
97: 95: }
98: 96: ```
99: 97: ```
100: 98: ```
101: 99: ```
102: ```
```
