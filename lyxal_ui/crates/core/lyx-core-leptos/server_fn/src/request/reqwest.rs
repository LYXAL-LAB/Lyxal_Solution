### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\src\request\reqwest.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\src\request\reqwest.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\src\request\reqwest.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\src\request\reqwest.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\src\request\reqwest.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\src\request\reqwest.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\src\request\reqwest.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\src\request\reqwest.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\src\request\reqwest.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\src\request\reqwest.rs
18: 16: ```rust
19: 17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\src\request\reqwest.rs
20: 18: ```rust
21: 19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\src\request\reqwest.rs
22: 20: ```rust
23: 21: use super::ClientReq;
24: 22: use crate::{
25: 23:     lyx-core-lyx_core_lyx-core-lyx_core_client::get_lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_url,
26: 24:     error::{FromServerFnError, IntoAppError, ServerFnErrorErr},
27: 25: };
28: 26: use bytes::Bytes;
29: 27: use futures::{Stream, StreamExt};
30: 28: use reqwest::{
31: 29:     header::{ACCEPT, CONTENT_TYPE},
32: 30:     Body,
33: 31: };
34: 32: pub use reqwest::{multipart::Form, Client, Method, Request, Url};
35: 33: use std::sync::LazyLock;
36: 34: 
37: 35: pub(crate) static CLIENT: LazyLock<Client> = LazyLock::new(Client::new);
38: 36: 
39: 37: impl<E> ClientReq<E> for Request
40: 38: where
41: 39:     E: FromServerFnError,
42: 40: {
43: 41:     type FormData = Form;
44: 42: 
45: 43:     fn try_new_req_query(
46: 44:         path: &str,
47: 45:         content_type: &str,
48: 46:         accepts: &str,
49: 47:         query: &str,
50: 48:         method: Method,
51: 49:     ) -> Result<Self, E> {
52: 50:         let url = format!("{}{}", get_lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_url(), path);
53: 51:         let mut url = Url::try_from(url.as_str()).map_err(|e| {
54: 52:             E::from_lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn_error(ServerFnErrorErr::Request(e.to_string()))
55: 53:         })?;
56: 54:         url.set_query(Some(query));
57: 55:         let req = match method {
58: 56:             Method::GET => CLIENT.get(url),
59: 57:             Method::DELETE => CLIENT.delete(url),
60: 58:             Method::HEAD => CLIENT.head(url),
61: 59:             Method::POST => CLIENT.post(url),
62: 60:             Method::PATCH => CLIENT.patch(url),
63: 61:             Method::PUT => CLIENT.put(url),
64: 62:             m => {
65: 63:                 return Err(E::from_lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn_error(
66: 64:                     ServerFnErrorErr::UnsupportedRequestMethod(m.to_string()),
67: 65:                 ))
68: 66:             }
69: 67:         }
70: 68:         .header(CONTENT_TYPE, content_type)
71: 69:         .header(ACCEPT, accepts)
72: 70:         .build()
73: 71:         .map_err(|e| {
74: 72:             E::from_lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn_error(ServerFnErrorErr::Request(e.to_string()))
75: 73:         })?;
76: 74:         Ok(req)
77: 75:     }
78: 76: 
79: 77:     fn try_new_req_text(
80: 78:         path: &str,
81: 79:         content_type: &str,
82: 80:         accepts: &str,
83: 81:         body: String,
84: 82:         method: Method,
85: 83:     ) -> Result<Self, E> {
86: 84:         let url = format!("{}{}", get_lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_url(), path);
87: 85:         match method {
88: 86:             Method::POST => CLIENT.post(url),
89: 87:             Method::PUT => CLIENT.put(url),
90: 88:             Method::PATCH => CLIENT.patch(url),
91: 89:             m => {
92: 90:                 return Err(E::from_lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn_error(
93: 91:                     ServerFnErrorErr::UnsupportedRequestMethod(m.to_string()),
94: 92:                 ))
95: 93:             }
96: 94:         }
97: 95:         .header(CONTENT_TYPE, content_type)
98: 96:         .header(ACCEPT, accepts)
99: 97:         .body(body)
100: 98:         .build()
101: 99:         .map_err(|e| ServerFnErrorErr::Request(e.to_string()).into_lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_error())
102: 100:     }
103: 101: 
104: 102:     fn try_new_req_bytes(
105: 103:         path: &str,
106: 104:         content_type: &str,
107: 105:         accepts: &str,
108: 106:         body: Bytes,
109: 107:         method: Method,
110: 108:     ) -> Result<Self, E> {
111: 109:         let url = format!("{}{}", get_lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_url(), path);
112: 110:         match method {
113: 111:             Method::POST => CLIENT.post(url),
114: 112:             Method::PATCH => CLIENT.patch(url),
115: 113:             Method::PUT => CLIENT.put(url),
116: 114:             m => {
117: 115:                 return Err(E::from_lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn_error(
118: 116:                     ServerFnErrorErr::UnsupportedRequestMethod(m.to_string()),
119: 117:                 ))
120: 118:             }
121: 119:         }
122: 120:         .header(CONTENT_TYPE, content_type)
123: 121:         .header(ACCEPT, accepts)
124: 122:         .body(body)
125: 123:         .build()
126: 124:         .map_err(|e| ServerFnErrorErr::Request(e.to_string()).into_lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_error())
127: 125:     }
128: 126: 
129: 127:     fn try_new_req_multipart(
130: 128:         path: &str,
131: 129:         accepts: &str,
132: 130:         body: Self::FormData,
133: 131:         method: Method,
134: 132:     ) -> Result<Self, E> {
135: 133:         match method {
136: 134:             Method::POST => CLIENT.post(path),
137: 135:             Method::PUT => CLIENT.put(path),
138: 136:             Method::PATCH => CLIENT.patch(path),
139: 137:             m => {
140: 138:                 return Err(E::from_lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn_error(
141: 139:                     ServerFnErrorErr::UnsupportedRequestMethod(m.to_string()),
142: 140:                 ))
143: 141:             }
144: 142:         }
145: 143:         .header(ACCEPT, accepts)
146: 144:         .multipart(body)
147: 145:         .build()
148: 146:         .map_err(|e| ServerFnErrorErr::Request(e.to_string()).into_lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_error())
149: 147:     }
150: 148: 
151: 149:     fn try_new_req_form_data(
152: 150:         path: &str,
153: 151:         accepts: &str,
154: 152:         content_type: &str,
155: 153:         body: Self::FormData,
156: 154:         method: Method,
157: 155:     ) -> Result<Self, E> {
158: 156:         match method {
159: 157:             Method::POST => CLIENT.post(path),
160: 158:             Method::PATCH => CLIENT.patch(path),
161: 159:             Method::PUT => CLIENT.put(path),
162: 160:             m => {
163: 161:                 return Err(E::from_lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn_error(
164: 162:                     ServerFnErrorErr::UnsupportedRequestMethod(m.to_string()),
165: 163:                 ))
166: 164:             }
167: 165:         }
168: 166:         .header(CONTENT_TYPE, content_type)
169: 167:         .header(ACCEPT, accepts)
170: 168:         .multipart(body)
171: 169:         .build()
172: 170:         .map_err(|e| ServerFnErrorErr::Request(e.to_string()).into_lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_error())
173: 171:     }
174: 172: 
175: 173:     fn try_new_req_streaming(
176: 174:         path: &str,
177: 175:         accepts: &str,
178: 176:         content_type: &str,
179: 177:         body: impl Stream<Item = Bytes> + Send + 'static,
180: 178:         method: Method,
181: 179:     ) -> Result<Self, E> {
182: 180:         let url = format!("{}{}", get_lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_url(), path);
183: 181:         let body = Body::wrap_stream(
184: 182:             body.map(|chunk| Ok(chunk) as Result<Bytes, ServerFnErrorErr>),
185: 183:         );
186: 184:         match method {
187: 185:             Method::POST => CLIENT.post(url),
188: 186:             Method::PUT => CLIENT.put(url),
189: 187:             Method::PATCH => CLIENT.patch(url),
190: 188:             m => {
191: 189:                 return Err(E::from_lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn_error(
192: 190:                     ServerFnErrorErr::UnsupportedRequestMethod(m.to_string()),
193: 191:                 ))
194: 192:             }
195: 193:         }
196: 194:         .header(CONTENT_TYPE, content_type)
197: 195:         .header(ACCEPT, accepts)
198: 196:         .body(body)
199: 197:         .build()
200: 198:         .map_err(|e| ServerFnErrorErr::Request(e.to_string()).into_lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_error())
201: 199:     }
202: 200: }
203: 201: ```
204: 202: ```
205: 203: ```
206: 204: ```
207: 205: ```
208: 206: ```
209: 207: ```
210: 208: ```
211: 209: ```
212: 210: ```
213: ```
```
