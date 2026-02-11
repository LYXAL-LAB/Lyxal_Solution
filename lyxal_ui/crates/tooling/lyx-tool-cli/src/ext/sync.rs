### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx-tool-cli\src\ext\sync.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx-tool-cli\src\ext\sync.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\ext\sync.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\ext\sync.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\ext\sync.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\ext\sync.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\ext\sync.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\ext\sync.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\ext\sync.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\ext\sync.rs
18: 16: ```rust
19: 17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\ext\sync.rs
20: 18: ```rust
21: 19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\ext\sync.rs
22: 20: ```rust
23: 21: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\ext\sync.rs
24: 22: ```rust
25: 23: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\ext\sync.rs
26: 24: ```rust
27: 25: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\ext\sync.rs
28: 26: ```rust
29: 27: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\ext\sync.rs
30: 28: ```rust
31: 29: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\ext\sync.rs
32: 30: ```rust
33: 31: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\ext\sync.rs
34: 32: ```rust
35: 33: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\ext\sync.rs
36: 34: ```rust
37: 35: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\ext\sync.rs
38: 36: ```rust
39: 37: use crate::ext::anyhow::{bail, Context, Result};
40: 38: use std::{
41: 39:     net::SocketAddr,
42: 40:     process::{Output, Stdio},
43: 41:     time::Duration,
44: 42: };
45: 43: use tokio::{
46: 44:     net::TcpStream,
47: 45:     process::{Child, Command},
48: 46:     sync::broadcast,
49: 47:     time::sleep,
50: 48: };
51: 49: 
52: 50: pub trait OutputExt {
53: 51:     fn stderr(&self) -> String;
54: 52:     fn has_stderr(&self) -> bool;
55: 53:     fn stdout(&self) -> String;
56: 54:     fn has_stdout(&self) -> bool;
57: 55: }
58: 56: 
59: 57: impl OutputExt for Output {
60: 58:     fn stderr(&self) -> String {
61: 59:         String::from_utf8_lossy(&self.stderr).to_string()
62: 60:     }
63: 61: 
64: 62:     fn has_stderr(&self) -> bool {
65: 63:         println!("stderr: {}\n'{}'", self.stderr.len(), self.stderr());
66: 64:         self.stderr.len() > 1
67: 65:     }
68: 66: 
69: 67:     fn stdout(&self) -> String {
70: 68:         String::from_utf8_lossy(&self.stdout).to_string()
71: 69:     }
72: 70: 
73: 71:     fn has_stdout(&self) -> bool {
74: 72:         self.stdout.len() > 1
75: 73:     }
76: 74: }
77: 75: pub enum CommandResult<T> {
78: 76:     Success(T),
79: 77:     Failure(T),
80: 78:     Interrupted,
81: 79: }
82: 80: 
83: 81: pub async fn wait_interruptible(
84: 82:     name: &str,
85: 83:     mut process: Child,
86: 84:     mut interrupt_rx: broadcast::Receiver<()>,
87: 85: ) -> Result<CommandResult<()>> {
88: 86:     tokio::select! {
89: 87:         res = process.wait() => match res {
90: 88:             Ok(exit) => {
91: 89:                 if exit.success() {
92: 90:                     log::trace!("{name} process finished with success");
93: 91:                     Ok(CommandResult::Success(()))
94: 92:                 } else {
95: 93:                     log::trace!("{name} process finished with code {:?}", exit.code());
96: 94:                     Ok(CommandResult::Failure(()))
97: 95:                 }
98: 96:             }
99: 97:             Err(e) => bail!("Command failed due to: {e}"),
100: 98:         },
101: 99:         _ = interrupt_rx.recv() => {
102: 100:             process.kill().await.context("Could not kill process")?;
103: 101:             log::trace!("{name} process interrupted");
104: 102:             Ok(CommandResult::Interrupted)
105: 103:         }
106: 104:     }
107: 105: }
108: 106: 
109: 107: pub async fn wait_piped_interruptible(
110: 108:     name: &str,
111: 109:     mut cmd: Command,
112: 110:     mut interrupt_rx: broadcast::Receiver<()>,
113: 111: ) -> Result<CommandResult<Output>> {
114: 112:     // see: https://docs.rs/tokio/latest/tokio/process/index.html
115: 113: 
116: 114:     cmd.kill_on_drop(true);
117: 115:     cmd.stdout(Stdio::piped());
118: 116:     cmd.stderr(Stdio::piped());
119: 117:     let process = cmd.spawn()?;
120: 118:     tokio::select! {
121: 119:         res = process.wait_with_output() => match res {
122: 120:             Ok(output) => {
123: 121:                 if output.status.success() {
124: 122:                     log::trace!("{name} process finished with success");
125: 123:                     Ok(CommandResult::Success(output))
126: 124:                 } else {
127: 125:                     log::trace!("{name} process finished with code {:?}", output.status.code());
128: 126:                     Ok(CommandResult::Failure(output))
129: 127:                 }
130: 128:             }
131: 129:             Err(e) => bail!("Command failed due to: {e}"),
132: 130:         },
133: 131:         _ = interrupt_rx.recv() => {
134: 132:             log::trace!("{name} process interrupted");
135: 133:             Ok(CommandResult::Interrupted)
136: 134:         }
137: 135:     }
138: 136: }
139: 137: pub async fn wait_for_socket(name: &str, addr: SocketAddr) -> bool {
140: 138:     let duration = Duration::from_millis(500);
141: 139: 
142: 140:     for _ in 0..20 {
143: 141:         if TcpStream::connect(&addr).await.is_ok() {
144: 142:             log::debug!("{name} lyx-platform-lyx_platform_lyx-platform-lyx_platform_server port {addr} open");
145: 143:             return true;
146: 144:         }
147: 145:         sleep(duration).await;
148: 146:     }
149: 147:     log::warn!("{name} timed out waiting for port {addr}");
150: 148:     false
151: 149: }
152: 150: ```
153: 151: ```
154: 152: ```
155: 153: ```
156: 154: ```
157: 155: ```
158: 156: ```
159: 157: ```
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
170: ```
```
