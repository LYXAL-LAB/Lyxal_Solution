### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx-tool-cli\src\service\reload.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx-tool-cli\src\service\reload.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\service\reload.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\service\reload.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\service\reload.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\service\reload.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\service\reload.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\service\reload.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\service\reload.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\service\reload.rs
18: 16: ```rust
19: 17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\service\reload.rs
20: 18: ```rust
21: 19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\service\reload.rs
22: 20: ```rust
23: 21: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\service\reload.rs
24: 22: ```rust
25: 23: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\service\reload.rs
26: 24: ```rust
27: 25: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\service\reload.rs
28: 26: ```rust
29: 27: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\service\reload.rs
30: 28: ```rust
31: 29: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\service\reload.rs
32: 30: ```rust
33: 31: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\service\reload.rs
34: 32: ```rust
35: 33: use crate::config::Project;
36: 34: use crate::ext::sync::wait_for_socket;
37: 35: use crate::logger::GRAY;
38: 36: use crate::signal::Interrupt;
39: 37: use crate::signal::{ReloadSignal, ReloadType};
40: 38: use axum::{
41: 39:     extract::ws::{Message, WebSocket, WebSocketUpgrade},
42: 40:     response::IntoResponse,
43: 41:     routing::get,
44: 42:     Router,
45: 43: };
46: 44: use serde::Serialize;
47: 45: use std::sync::Arc;
48: 46: use std::{fmt::Display, net::SocketAddr};
49: 47: use tokio::net::TcpListener;
50: 48: use tokio::{net::TcpStream, select, sync::RwLock, task::JoinHandle};
51: 49: 
52: 50: lazy_static::lazy_static! {
53: 51:   static ref SITE_ADDR: RwLock<SocketAddr> = RwLock::new(SocketAddr::new([127,0,0,1].into(), 3000));
54: 52:   static ref CSS_LINK: RwLock<String> = RwLock::new(String::default());
55: 53: }
56: 54: 
57: 55: pub async fn spawn(proj: &Arc<Project>) -> JoinHandle<()> {
58: 56:     let proj = proj.clone();
59: 57: 
60: 58:     let mut site_addr = SITE_ADDR.write().await;
61: 59:     *site_addr = proj.site.addr;
62: 60:     if let Some(file) = &proj.style.file {
63: 61:         let mut css_link = CSS_LINK.write().await;
64: 62:         // Always use `/` as separator in links
65: 63:         *css_link = file
66: 64:             .site
67: 65:             .components()
68: 66:             .map(|c| c.as_str())
69: 67:             .collect::<Vec<_>>()
70: 68:             .join("/");
71: 69:     }
72: 70: 
73: 71:     tokio::spawn(async move {
74: 72:         let _change = ReloadSignal::subscribe();
75: 73: 
76: 74:         let reload_addr = proj.site.reload;
77: 75: 
78: 76:         if TcpStream::connect(&reload_addr).await.is_ok() {
79: 77:             log::error!(
80: 78:                     "Reload TCP port {reload_addr} already in use. You can set the port in the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server integration's RenderOptions reload_port"
81: 79:                 );
82: 80:             Interrupt::request_shutdown().await;
83: 81: 
84: 82:             return;
85: 83:         }
86: 84:         let route = Router::new().route("/live_reload", get(websocket_handler));
87: 85: 
88: 86:         log::debug!(
89: 87:             "Reload lyx-platform-lyx_platform_lyx-platform-lyx_platform_server started {}",
90: 88:             GRAY.paint(reload_addr.to_string())
91: 89:         );
92: 90: 
93: 91:         match TcpListener::bind(&reload_addr).await {
94: 92:             Ok(listener) => match axum::serve(listener, route).await {
95: 93:                 Ok(_) => log::debug!("Reload lyx-platform-lyx_platform_lyx-platform-lyx_platform_server stopped"),
96: 94:                 Err(e) => log::error!("Reload {e}"),
97: 95:             },
98: 96:             Err(e) => log::error!("Reload {e}"),
99: 97:         }
100: 98:     })
101: 99: }
102: 100: 
103: 101: async fn websocket_handler(ws: WebSocketUpgrade) -> impl IntoResponse {
104: 102:     ws.on_upgrade(websocket)
105: 103: }
106: 104: 
107: 105: async fn websocket(mut stream: WebSocket) {
108: 106:     let mut rx = ReloadSignal::subscribe();
109: 107:     let mut int = Interrupt::subscribe_any();
110: 108: 
111: 109:     log::trace!("Reload websocket connected");
112: 110:     tokio::spawn(async move {
113: 111:         loop {
114: 112:             select! {
115: 113:                 res = rx.recv() =>{
116: 114:                     match res {
117: 115:                         Ok(ReloadType::Full) => {
118: 116:                             send_and_close(stream, BrowserMessage::all()).await;
119: 117:                             return
120: 118:                         }
121: 119:                         Ok(ReloadType::Style) => {
122: 120:                             send(&mut stream, BrowserMessage::css().await).await;
123: 121:                         },
124: 122:                         Ok(ReloadType::ViewPatches(data)) => {
125: 123:                             send(&mut stream, BrowserMessage::view(data)).await;
126: 124:                         }
127: 125:                         Err(e) => log::debug!("Reload recive error {e}")
128: 126:                     }
129: 127:                 }
130: 128:                 _ = int.recv(), if Interrupt::is_shutdown_requested().await => {
131: 129:                     log::trace!("Reload websocket closed");
132: 130:                     return
133: 131:                 },
134: 132:             }
135: 133:         }
136: 134:     });
137: 135: }
138: 136: 
139: 137: async fn send(stream: &mut WebSocket, msg: BrowserMessage) {
140: 138:     let site_addr = *SITE_ADDR.read().await;
141: 139:     if !wait_for_socket("Reload", site_addr).await {
142: 140:         log::warn!(r#"Reload could not send "{msg}" to websocket"#);
143: 141:     }
144: 142: 
145: 143:     let text = serde_json::to_string(&msg).unwrap();
146: 144:     match stream.send(Message::Text(text)).await {
147: 145:         Err(e) => {
148: 146:             log::debug!("Reload could not send {msg} due to {e}");
149: 147:         }
150: 148:         Ok(_) => {
151: 149:             log::debug!(r#"Reload sent "{msg}" to browser"#);
152: 150:         }
153: 151:     }
154: 152: }
155: 153: 
156: 154: async fn send_and_close(mut stream: WebSocket, msg: BrowserMessage) {
157: 155:     send(&mut stream, msg).await;
158: 156:     let _ = stream.close().await;
159: 157:     log::trace!("Reload websocket closed");
160: 158: }
161: 159: 
162: 160: #[derive(Serialize)]
163: 161: struct BrowserMessage {
164: 162:     css: Option<String>,
165: 163:     view: Option<String>,
166: 164:     all: bool,
167: 165: }
168: 166: 
169: 167: impl BrowserMessage {
170: 168:     async fn css() -> Self {
171: 169:         let link = CSS_LINK.read().await.clone();
172: 170:         if link.is_empty() {
173: 171:             log::error!("Reload internal error: sending css reload but no css file is set.");
174: 172:         }
175: 173:         Self {
176: 174:             css: Some(link),
177: 175:             view: None,
178: 176:             all: false,
179: 177:         }
180: 178:     }
181: 179: 
182: 180:     fn view(data: String) -> Self {
183: 181:         Self {
184: 182:             css: None,
185: 183:             view: Some(data),
186: 184:             all: false,
187: 185:         }
188: 186:     }
189: 187: 
190: 188:     fn all() -> Self {
191: 189:         Self {
192: 190:             css: None,
193: 191:             view: None,
194: 192:             all: true,
195: 193:         }
196: 194:     }
197: 195: }
198: 196: 
199: 197: impl Display for BrowserMessage {
200: 198:     fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
201: 199:         if let Some(css) = &self.css {
202: 200:             write!(f, "reload {}", css)
203: 201:         } else {
204: 202:             write!(f, "reload all")
205: 203:         }
206: 204:     }
207: 205: }
208: 206: ```
209: 207: ```
210: 208: ```
211: 209: ```
212: 210: ```
213: 211: ```
214: 212: ```
215: 213: ```
216: 214: ```
217: 215: ```
218: 216: ```
219: 217: ```
220: 218: ```
221: 219: ```
222: 220: ```
223: 221: ```
224: ```
```
