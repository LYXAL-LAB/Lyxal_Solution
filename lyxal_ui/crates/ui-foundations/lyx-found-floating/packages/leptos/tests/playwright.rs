1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx-found-floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\tests\playwright.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\tests\playwright.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\tests\playwright.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\tests\playwright.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\tests\playwright.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\tests\playwright.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\tests\playwright.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\tests\playwright.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\tests\playwright.rs
18: 16: ```rust
19: 17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\tests\playwright.rs
20: 18: ```rust
21: 19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\tests\playwright.rs
22: 20: ```rust
23: 21: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\tests\playwright.rs
24: 22: ```rust
25: 23: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\tests\playwright.rs
26: 24: ```rust
27: 25: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\tests\playwright.rs
28: 26: ```rust
29: 27: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\tests\playwright.rs
30: 28: ```rust
31: 29: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\tests\playwright.rs
32: 30: ```rust
33: 31: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\tests\playwright.rs
34: 32: ```rust
35: 33: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\tests\playwright.rs
36: 34: ```rust
37: 35: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\tests\playwright.rs
38: 36: ```rust
39: 37: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\tests\playwright.rs
40: 38: ```rust
41: 39: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\tests\playwright.rs
42: 40: ```rust
43: 41: use std::{env, fs, path::Path, process::Command};
44: 42: 
45: 43: const IMPLEMENTED_TESTS: [&str; 19] = [
46: 44:     "arrow",
47: 45:     "autoPlacement",
48: 46:     "autoUpdate",
49: 47:     "border",
50: 48:     "containing-block",
51: 49:     "decimal-size",
52: 50:     "flip",
53: 51:     "hide",
54: 52:     // "iframe",
55: 53:     "inline",
56: 54:     "offset",
57: 55:     "placement",
58: 56:     "relative",
59: 57:     "scroll",
60: 58:     "scrollbars",
61: 59:     // "shadow-dom",
62: 60:     "shift",
63: 61:     "size",
64: 62:     "table",
65: 63:     // "top-layer",
66: 64:     "transform",
67: 65:     "virtual-element",
68: 66: ];
69: 67: 
70: 68: #[test]
71: 69: pub fn playwright() {
72: 70:     let repository_url = "https://github.com/floating-ui/floating-ui";
73: 71:     let repository_path = Path::new(env!("CARGO_TARGET_TMPDIR")).join("floating-ui");
74: 72:     let repository_dom_path = repository_path.join("packages/dom");
75: 73:     let repository_package_json_path = repository_dom_path.join("package.json");
76: 74:     let repository_playwright_config_path = repository_dom_path.join("playwright.config.ts");
77: 75:     let repository_arrow_test_path = repository_dom_path.join("test/functional/arrow.test.ts");
78: 76: 
79: 77:     let visual_test_path = Path::new(env!("CARGO_MANIFEST_DIR")).join("tests/visual");
80: 78: 
81: 79:     if !repository_path.exists() {
82: 80:         let status = Command::new("git")
83: 81:             .arg("clone")
84: 82:             .arg(repository_url)
85: 83:             .arg(repository_path.clone())
86: 84:             .status()
87: 85:             .expect("Cloning Git repository failed.");
88: 86:         assert!(status.success(), "Cloning Git repository failed.");
89: 87:     } else {
90: 88:         let status = Command::new("git")
91: 89:             .arg("reset")
92: 90:             .arg("--hard")
93: 91:             .current_dir(repository_path.clone())
94: 92:             .status()
95: 93:             .expect("Git reset failed.");
96: 94:         assert!(status.success(), "Git reset failed.");
97: 95: 
98: 96:         let status = Command::new("git")
99: 97:             .arg("pull")
100: 98:             .current_dir(repository_path.clone())
101: 99:             .status()
102: 100:             .expect("Git pull failed.");
103: 101:         assert!(status.success(), "Git pull failed.");
104: 102:     }
105: 103: 
106: 104:     let status = Command::new("pnpm")
107: 105:         .arg("install")
108: 106:         .current_dir(repository_path.clone())
109: 107:         .status()
110: 108:         .expect("pnpm install failed.");
111: 109:     assert!(status.success(), "pnpm install failed");
112: 110: 
113: 111:     if env::var("CI")
114: 112:         .unwrap_or("false".to_owned())
115: 113:         .parse::<bool>()
116: 114:         .unwrap_or(false)
117: 115:     {
118: 116:         let status = Command::new("npx")
119: 117:             .arg("playwright")
120: 118:             .arg("install")
121: 119:             .arg("--with-deps")
122: 120:             .arg("chromium")
123: 121:             .current_dir(repository_dom_path.clone())
124: 122:             .status()
125: 123:             .expect("Playwright install failed.");
126: 124:         assert!(status.success(), "Playwright install failed.");
127: 125:     }
128: 126: 
129: 127:     let status = Command::new("pnpm")
130: 128:         .arg("run")
131: 129:         .arg("build")
132: 130:         .current_dir(repository_path.clone())
133: 131:         .status()
134: 132:         .expect("Build failed.");
135: 133:     assert!(status.success(), "Build failed.");
136: 134: 
137: 135:     if env::var("UPDATE_SNAPSHOTS")
138: 136:         .unwrap_or("false".to_owned())
139: 137:         .parse::<bool>()
140: 138:         .unwrap_or(false)
141: 139:     {
142: 140:         let status = Command::new("pnpm")
143: 141:             .arg("run")
144: 142:             .arg("playwright")
145: 143:             .arg("--update-snapshots")
146: 144:             .current_dir(repository_dom_path.clone())
147: 145:             .status()
148: 146:             .expect("Playwright update snapshot tests failed.");
149: 147:         assert!(status.success(), "Playwright update snapshot tests failed.");
150: 148:     }
151: 149: 
152: 150:     // TODO: remove when all tests are implemented
153: 151:     let package_json_content = fs::read_to_string(repository_package_json_path.clone())
154: 152:         .expect("Reading package.json file failed.")
155: 153:         .replace(
156: 154:             "playwright test ./test/functional",
157: 155:             &format!(
158: 156:                 "playwright test {}",
159: 157:                 IMPLEMENTED_TESTS
160: 158:                     .map(|name| format!("./test/functional/{name}.test.ts"))
161: 159:                     .join(" ")
162: 160:             ),
163: 161:         );
164: 162:     fs::write(repository_package_json_path, package_json_content)
165: 163:         .expect("Writing package.json file failed.");
166: 164: 
167: 165:     let config_content = fs::read_to_string(repository_playwright_config_path.clone())
168: 166:         .expect("Reading Playwright config file failed.")
169: 167:         .replace("retries: 3,", "retries: 0,\n  timeout: 10 * 1000,\nexpect: {toMatchSnapshot: {maxDiffPixelRatio: 0.01}},")
170: 168:         .replace(
171: 169:             "command: 'pnpm run dev',",
172: 170:             &format!(
173: 171:                 "command: 'trunk serve --port 1234',\n    cwd: '{}',\n    stdout: 'pipe',",
174: 172:                 visual_test_path.to_str().expect("Path should be valid.")
175: 173:             ),
176: 174:         );
177: 175:     fs::write(repository_playwright_config_path, config_content)
178: 176:         .expect("Writing Playwright config file failed.");
179: 177: 
180: 178:     let arrow_test_content = fs::read_to_string(repository_arrow_test_path.clone())
181: 179:         .expect("Reading arrow test file failed.")
182: 180:         .replace(
183: 181:             // Match React test behaviour
184: 182:             "await click(page, `[data-testid=\"arrow-padding-${arrowPadding}\"]`);",
185: 183:             "if (arrowPadding !== 0) { await click(page, `[data-testid=\"arrow-padding-${arrowPadding}\"]`); }",
186: 184:         )
187: 185:         .replace(
188: 186:             // Match React test behaviour
189: 187:             "await click(page, `[data-testid=\"centerOffset-true\"]`);",
190: 188:             "await click(page, `[data-testid=\"centerOffset-true\"]`);\n  await click(page, `[data-testid=\"centerOffset-true\"]`);",
191: 189:         );
192: 190:     fs::write(repository_arrow_test_path, arrow_test_content)
193: 191:         .expect("Writing arrow test file failed.");
194: 192: 
195: 193:     let status = Command::new("pnpm")
196: 194:         .arg("run")
197: 195:         .arg("playwright")
198: 196:         // .arg("--debug")
199: 197:         .current_dir(repository_dom_path.clone())
200: 198:         .status()
201: 199:         .expect("Playwright tests failed.");
202: 200:     assert!(status.success(), "Playwright tests failed.");
203: 201: }
204: 202: ```
205: 203: ```
206: 204: ```
207: 205: ```
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

