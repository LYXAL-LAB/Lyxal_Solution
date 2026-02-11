### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_leptos_macro\tests\lyx-platform-lyx_platform_server.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_macro\tests\lyx-platform-lyx_platform_lyx-platform-lyx_platform_server.rs
2: ```rust
3: 1: #[cfg(not(feature = "ssr"))]
4: 2: pub mod tests {
5: 3:     use lyx-core-lyx_core_lyx-core-lyx_core_leptos::{
6: 4:         lyx-platform-lyx_platform_lyx-platform-lyx_platform_server,
7: 5:         lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn::{codec, Http, ServerFn, ServerFnError},
8: 6:     };
9: 7:     use std::any::TypeId;
10: 8: 
11: 9:     #[test]
12: 10:     fn lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_default() {
13: 11:         #[lyx-platform-lyx_platform_lyx-platform-lyx_platform_server]
14: 12:         pub async fn my_lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_action() -> Result<(), ServerFnError> {
15: 13:             Ok(())
16: 14:         }
17: 15:         assert_eq!(
18: 16:             <MyServerAction as ServerFn>::PATH
19: 17:                 .trim_end_matches(char::is_numeric),
20: 18:             "/api/my_lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_action"
21: 19:         );
22: 20:         assert_eq!(
23: 21:             TypeId::of::<<MyServerAction as ServerFn>::Protocol>(),
24: 22:             TypeId::of::<Http<codec::PostUrl, codec::Json>>()
25: 23:         );
26: 24:     }
27: 25: 
28: 26:     #[test]
29: 27:     fn lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_full_legacy() {
30: 28:         #[lyx-platform-lyx_platform_lyx-platform-lyx_platform_server(FooBar, "/foo/bar", "Cbor", "my_path")]
31: 29:         pub async fn my_lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_action() -> Result<(), ServerFnError> {
32: 30:             Ok(())
33: 31:         }
34: 32:         assert_eq!(<FooBar as ServerFn>::PATH, "/foo/bar/my_path");
35: 33:         assert_eq!(
36: 34:             TypeId::of::<<FooBar as ServerFn>::Protocol>(),
37: 35:             TypeId::of::<Http<codec::Cbor, codec::Cbor>>()
38: 36:         );
39: 37:     }
40: 38: 
41: 39:     #[test]
42: 40:     fn lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_all_keywords() {
43: 41:         #[lyx-platform-lyx_platform_lyx-platform-lyx_platform_server(endpoint = "my_path", encoding = "Cbor", prefix = "/foo/bar", name = FooBar)]
44: 42:         pub async fn my_lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_action() -> Result<(), ServerFnError> {
45: 43:             Ok(())
46: 44:         }
47: 45:         assert_eq!(<FooBar as ServerFn>::PATH, "/foo/bar/my_path");
48: 46:         assert_eq!(
49: 47:             TypeId::of::<<FooBar as ServerFn>::Protocol>(),
50: 48:             TypeId::of::<Http<codec::Cbor, codec::Cbor>>()
51: 49:         );
52: 50:     }
53: 51: 
54: 52:     #[test]
55: 53:     fn lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_mix() {
56: 54:         #[lyx-platform-lyx_platform_lyx-platform-lyx_platform_server(FooBar, endpoint = "my_path")]
57: 55:         pub async fn my_lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_action() -> Result<(), ServerFnError> {
58: 56:             Ok(())
59: 57:         }
60: 58:         assert_eq!(<FooBar as ServerFn>::PATH, "/api/my_path");
61: 59:         assert_eq!(
62: 60:             TypeId::of::<<FooBar as ServerFn>::Protocol>(),
63: 61:             TypeId::of::<Http<codec::PostUrl, codec::Json>>()
64: 62:         );
65: 63:     }
66: 64: 
67: 65:     #[test]
68: 66:     fn lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_name() {
69: 67:         #[lyx-platform-lyx_platform_lyx-platform-lyx_platform_server(name = FooBar)]
70: 68:         pub async fn my_lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_action() -> Result<(), ServerFnError> {
71: 69:             Ok(())
72: 70:         }
73: 71:         assert_eq!(
74: 72:             <FooBar as ServerFn>::PATH.trim_end_matches(char::is_numeric),
75: 73:             "/api/my_lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_action"
76: 74:         );
77: 75:         assert_eq!(
78: 76:             TypeId::of::<<FooBar as ServerFn>::Protocol>(),
79: 77:             TypeId::of::<Http<codec::PostUrl, codec::Json>>()
80: 78:         );
81: 79:     }
82: 80: 
83: 81:     #[test]
84: 82:     fn lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_prefix() {
85: 83:         #[lyx-platform-lyx_platform_lyx-platform-lyx_platform_server(prefix = "/foo/bar")]
86: 84:         pub async fn my_lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_action() -> Result<(), ServerFnError> {
87: 85:             Ok(())
88: 86:         }
89: 87:         assert_eq!(
90: 88:             <MyServerAction as ServerFn>::PATH
91: 89:                 .trim_end_matches(char::is_numeric),
92: 90:             "/foo/bar/my_lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_action"
93: 91:         );
94: 92:         assert_eq!(
95: 93:             TypeId::of::<<MyServerAction as ServerFn>::Protocol>(),
96: 94:             TypeId::of::<Http<codec::PostUrl, codec::Json>>()
97: 95:         );
98: 96:     }
99: 97: 
100: 98:     #[test]
101: 99:     fn lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_encoding() {
102: 100:         #[lyx-platform-lyx_platform_lyx-platform-lyx_platform_server(encoding = "GetJson")]
103: 101:         pub async fn my_lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_action() -> Result<(), ServerFnError> {
104: 102:             Ok(())
105: 103:         }
106: 104:         assert_eq!(
107: 105:             <MyServerAction as ServerFn>::PATH
108: 106:                 .trim_end_matches(char::is_numeric),
109: 107:             "/api/my_lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_action"
110: 108:         );
111: 109:         assert_eq!(
112: 110:             TypeId::of::<<MyServerAction as ServerFn>::Protocol>(),
113: 111:             TypeId::of::<Http<codec::GetUrl, codec::Json>>()
114: 112:         );
115: 113:     }
116: 114: 
117: 115:     #[test]
118: 116:     fn lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_endpoint() {
119: 117:         #[lyx-platform-lyx_platform_lyx-platform-lyx_platform_server(endpoint = "/path/to/my/endpoint")]
120: 118:         pub async fn my_lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_action() -> Result<(), ServerFnError> {
121: 119:             Ok(())
122: 120:         }
123: 121:         assert_eq!(
124: 122:             <MyServerAction as ServerFn>::PATH,
125: 123:             "/api/path/to/my/endpoint"
126: 124:         );
127: 125:         assert_eq!(
128: 126:             TypeId::of::<<MyServerAction as ServerFn>::Protocol>(),
129: 127:             TypeId::of::<Http<codec::PostUrl, codec::Json>>()
130: 128:         );
131: 129:     }
132: 130: }
133: ```
```
