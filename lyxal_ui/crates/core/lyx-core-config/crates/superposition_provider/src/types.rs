### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_lyx-core-lyx_core_superposition_provider\src\types.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_provider\src\types.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_provider\src\types.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_provider\src\types.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_provider\src\types.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_provider\src\types.rs
10: 8: ```rust
11: 9: use serde::{Deserialize, Serialize};
12: 10: use serde_json::Value;
13: 11: use thiserror::Error;
14: 12: 
15: 13: #[derive(Error, Debug)]
16: 14: pub enum SuperpositionError {
17: 15:     #[error("Configuration error: {0}")]
18: 16:     ConfigError(String),
19: 17:     #[error("Network error: {0}")]
20: 18:     NetworkError(String),
21: 19:     #[error("Serialization error: {0}")]
22: 20:     SerializationError(String),
23: 21:     #[error("Provider error: {0}")]
24: 22:     ProviderError(String),
25: 23: }
26: 24: 
27: 25: pub type Result<T> = std::result::Result<T, SuperpositionError>;
28: 26: 
29: 27: #[derive(Debug, Clone, Serialize, Deserialize)]
30: 28: pub struct SuperpositionOptions {
31: 29:     pub endpoint: String,
32: 30:     pub token: String,
33: 31:     pub org_id: String,
34: 32:     pub workspace_id: String,
35: 33: }
36: 34: 
37: 35: impl SuperpositionOptions {
38: 36:     pub fn new(
39: 37:         endpoint: String,
40: 38:         token: String,
41: 39:         org_id: String,
42: 40:         workspace_id: String,
43: 41:     ) -> Self {
44: 42:         Self {
45: 43:             endpoint,
46: 44:             token,
47: 45:             org_id,
48: 46:             workspace_id,
49: 47:         }
50: 48:     }
51: 49: }
52: 50: 
53: 51: /// Cache configuration
54: 52: #[derive(Debug, Clone, Serialize, Deserialize)]
55: 53: pub struct CacheOptions {
56: 54:     pub ttl: Option<u64>,
57: 55:     pub size: Option<usize>,
58: 56: }
59: 57: 
60: 58: impl Default for CacheOptions {
61: 59:     fn default() -> Self {
62: 60:         Self {
63: 61:             ttl: Some(300), // 5 minutes
64: 62:             size: Some(1000),
65: 63:         }
66: 64:     }
67: 65: }
68: 66: 
69: 67: /// Evaluation cache configuration
70: 68: #[derive(Debug, Clone, Serialize, Deserialize)]
71: 69: pub struct EvaluationCacheOptions {
72: 70:     pub ttl: Option<u64>,
73: 71:     pub size: Option<usize>,
74: 72: }
75: 73: 
76: 74: impl Default for EvaluationCacheOptions {
77: 75:     fn default() -> Self {
78: 76:         Self {
79: 77:             ttl: Some(60), // 1 minute
80: 78:             size: Some(500),
81: 79:         }
82: 80:     }
83: 81: }
84: 82: 
85: 83: /// Polling strategy configuration
86: 84: #[derive(Debug, Clone, Serialize, Deserialize)]
87: 85: pub struct PollingStrategy {
88: 86:     pub interval: u64, // seconds
89: 87:     pub timeout: Option<u64>,
90: 88: }
91: 89: 
92: 90: impl Default for PollingStrategy {
93: 91:     fn default() -> Self {
94: 92:         Self {
95: 93:             interval: 60, // 1 minute
96: 94:             timeout: Some(30),
97: 95:         }
98: 96:     }
99: 97: }
100: 98: 
101: 99: #[derive(Debug, Clone, Serialize, Deserialize)]
102: 100: pub struct OnDemandStrategy {
103: 101:     pub ttl: u64, // seconds
104: 102:     pub timeout: Option<u64>,
105: 103:     pub use_stale_on_error: Option<bool>,
106: 104: }
107: 105: 
108: 106: impl Default for OnDemandStrategy {
109: 107:     fn default() -> Self {
110: 108:         Self {
111: 109:             ttl: 300, // 5 minutes
112: 110:             timeout: Some(30),
113: 111:             use_stale_on_error: Some(true),
114: 112:         }
115: 113:     }
116: 114: }
117: 115: 
118: 116: #[derive(Debug, Clone, Serialize, Deserialize)]
119: 117: pub enum RefreshStrategy {
120: 118:     Polling(PollingStrategy),
121: 119:     OnDemand(OnDemandStrategy),
122: 120: }
123: 121: 
124: 122: impl Default for RefreshStrategy {
125: 123:     fn default() -> Self {
126: 124:         RefreshStrategy::OnDemand(OnDemandStrategy::default())
127: 125:     }
128: 126: }
129: 127: 
130: 128: #[derive(Debug, Clone, Serialize, Deserialize)]
131: 129: pub struct ConfigurationOptions {
132: 130:     pub fallback_config: Option<serde_json::Map<String, Value>>,
133: 131:     pub evaluation_cache: Option<EvaluationCacheOptions>,
134: 132:     pub refresh_strategy: RefreshStrategy,
135: 133: }
136: 134: 
137: 135: impl ConfigurationOptions {
138: 136:     pub fn new(
139: 137:         refresh_strategy: RefreshStrategy,
140: 138:         evaluation_cache: Option<EvaluationCacheOptions>,
141: 139:         fallback_config: Option<serde_json::Map<String, Value>>,
142: 140:     ) -> Self {
143: 141:         Self {
144: 142:             fallback_config,
145: 143:             evaluation_cache,
146: 144:             refresh_strategy,
147: 145:         }
148: 146:     }
149: 147: }
150: 148: 
151: 149: /// Experimentation options
152: 150: #[derive(Debug, Clone, Serialize, Deserialize)]
153: 151: pub struct ExperimentationOptions {
154: 152:     pub refresh_strategy: RefreshStrategy,
155: 153:     pub evaluation_cache: Option<EvaluationCacheOptions>,
156: 154:     pub default_toss: Option<u32>,
157: 155: }
158: 156: 
159: 157: impl ExperimentationOptions {
160: 158:     pub fn new(refresh_strategy: RefreshStrategy) -> Self {
161: 159:         Self {
162: 160:             refresh_strategy,
163: 161:             evaluation_cache: Some(EvaluationCacheOptions::default()),
164: 162:             default_toss: None,
165: 163:         }
166: 164:     }
167: 165: 
168: 166:     pub fn with_evaluation_cache(
169: 167:         mut self,
170: 168:         evaluation_cache: EvaluationCacheOptions,
171: 169:     ) -> Self {
172: 170:         self.evaluation_cache = Some(evaluation_cache);
173: 171:         self
174: 172:     }
175: 173: 
176: 174:     pub fn with_default_toss(mut self, default_toss: u32) -> Self {
177: 175:         self.default_toss = Some(default_toss);
178: 176:         self
179: 177:     }
180: 178: }
181: 179: 
182: 180: #[derive(Debug, Clone, Serialize, Deserialize)]
183: 181: pub struct SuperpositionProviderOptions {
184: 182:     pub endpoint: String,
185: 183:     pub token: String,
186: 184:     pub org_id: String,
187: 185:     pub workspace_id: String,
188: 186:     pub fallback_config: Option<serde_json::Map<String, Value>>,
189: 187:     pub evaluation_cache: Option<EvaluationCacheOptions>,
190: 188:     pub refresh_strategy: RefreshStrategy,
191: 189:     pub experimentation_options: Option<ExperimentationOptions>,
192: 190: }
193: 191: 
194: 192: impl SuperpositionProviderOptions {
195: 193:     #[allow(clippy::too_many_arguments)]
196: 194:     pub fn new(
197: 195:         endpoint: String,
198: 196:         token: String,
199: 197:         org_id: String,
200: 198:         workspace_id: String,
201: 199:         fallback_config: Option<serde_json::Map<String, Value>>,
202: 200:         evaluation_cache: Option<EvaluationCacheOptions>,
203: 201:         refresh_strategy: RefreshStrategy,
204: 202:         experimentation_options: Option<ExperimentationOptions>,
205: 203:     ) -> Self {
206: 204:         Self {
207: 205:             endpoint,
208: 206:             token,
209: 207:             org_id,
210: 208:             workspace_id,
211: 209:             fallback_config,
212: 210:             evaluation_cache,
213: 211:             refresh_strategy,
214: 212:             experimentation_options,
215: 213:         }
216: 214:     }
217: 215: }
218: 216: ```
219: 217: ```
220: 218: ```
221: 219: ```
222: ```
```
