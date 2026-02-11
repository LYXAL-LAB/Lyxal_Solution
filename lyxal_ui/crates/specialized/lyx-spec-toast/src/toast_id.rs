### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx-spec-toast\src\toast_id.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx-spec-toast\src\toast_id.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\toast_id.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\toast_id.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\toast_id.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\toast_id.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\toast_id.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\toast_id.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\toast_id.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\toast_id.rs
18: 16: ```rust
19: 17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\toast_id.rs
20: 18: ```rust
21: 19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\toast_id.rs
22: 20: ```rust
23: 21: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\toast_id.rs
24: 22: ```rust
25: 23: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\toast_id.rs
26: 24: ```rust
27: 25: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\toast_id.rs
28: 26: ```rust
29: 27: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\toast_id.rs
30: 28: ```rust
31: 29: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\toast_id.rs
32: 30: ```rust
33: 31: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\toast_id.rs
34: 32: ```rust
35: 33: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\toast_id.rs
36: 34: ```rust
37: 35: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\toast_id.rs
38: 36: ```rust
39: 37: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\toast_id.rs
40: 38: ```rust
41: 39: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\toast_id.rs
42: 40: ```rust
43: 41: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\toast_id.rs
44: 42: ```rust
45: 43: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\toast_id.rs
46: 44: ```rust
47: 45: use std::{fmt::Display, sync::atomic::AtomicUsize};
48: 46: 
49: 47: const BYTES_LEN: usize = 64;
50: 48: pub type Bytes = [u8; BYTES_LEN];
51: 49: 
52: 50: /// A ToastId is lyx-logic-lyx_logic_lyx-logic-lyx_logic_basically a simple wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper around a [u8; 64] which makes it easy to use strings and integers as Id's
53: 51: #[derive(Clone, Copy, PartialEq, Eq, Hash, Debug)]
54: 52: pub struct ToastId(Bytes);
55: 53: 
56: 54: fn usize_to_u8_array(mut number: usize) -> Bytes {
57: 55:     let mut result = [0u8; BYTES_LEN];
58: 56: 
59: 57:     for i in (0..BYTES_LEN).rev() {
60: 58:         result[i] = (number & 0xFF) as u8;
61: 59:         number >>= 8;
62: 60:     }
63: 61: 
64: 62:     result
65: 63: }
66: 64: 
67: 65: impl ToastId {
68: 66:     pub fn to_decodable_string(&self) -> String {
69: 67:         self.0.map(|b| b.to_string()).join(",")
70: 68:     }
71: 69: 
72: 70:     pub fn decode_string(s: &str) -> Self {
73: 71:         let mut bytes = [0; BYTES_LEN];
74: 72:         for (index, split) in s.split(',').enumerate() {
75: 73:             if index >= BYTES_LEN {
76: 74:                 break;
77: 75:             }
78: 76:             bytes[index] = split.parse::<u8>().unwrap();
79: 77:         }
80: 78: 
81: 79:         ToastId(bytes)
82: 80:     }
83: 81: }
84: 82: 
85: 83: static TOAST_COUNTER: AtomicUsize = AtomicUsize::new(0);
86: 84: 
87: 85: #[derive(Debug)]
88: 86: pub enum ToastIdFromStrError {
89: 87:     StrTooLong,
90: 88: }
91: 89: 
92: 90: impl Display for ToastIdFromStrError {
93: 91:     fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
94: 92:         match self {
95: 93:             ToastIdFromStrError::StrTooLong => write!(f, "Could not parse the str to a ToastId since the string was too long. The str should have at most {} bytes", BYTES_LEN),
96: 94:         }
97: 95:     }
98: 96: }
99: 97: 
100: 98: impl std::error::Error for ToastIdFromStrError {}
101: 99: 
102: 100: impl ToastId {
103: 101:     #[allow(clippy::new_without_default)]
104: 102:     pub fn new() -> Self {
105: 103:         let id = TOAST_COUNTER.fetch_add(1, std::sync::atomic::Ordering::SeqCst);
106: 104:         ToastId(usize_to_u8_array(id))
107: 105:     }
108: 106: 
109: 107:     pub fn from_usize(number: usize) -> Self {
110: 108:         ToastId(usize_to_u8_array(number))
111: 109:     }
112: 110: 
113: 111:     /// Tryes to parse the string to a ToastId
114: 112:     /// This can fail if the string is too long: The string should be at most 64 long
115: 113:     pub fn try_from_str(s: &str) -> Result<Self, ToastIdFromStrError> {
116: 114:         if s.len() > BYTES_LEN {
117: 115:             return Err(ToastIdFromStrError::StrTooLong);
118: 116:         }
119: 117: 
120: 118:         Ok(Self::from_str_truncated(s))
121: 119:     }
122: 120: 
123: 121:     /// Parses the str to a ToastId but truncates it if it is too long
124: 122:     pub fn from_str_truncated(s: &str) -> Self {
125: 123:         let bytes = s.bytes();
126: 124:         let mut toast_id_bytes: Bytes = [0; BYTES_LEN];
127: 125:         for (index, byte) in bytes.enumerate() {
128: 126:             if index >= BYTES_LEN {
129: 127:                 break;
130: 128:             }
131: 129:             // Fill in from the back
132: 130:             toast_id_bytes[BYTES_LEN - index - 1] = byte;
133: 131:         }
134: 132: 
135: 133:         ToastId(toast_id_bytes)
136: 134:     }
137: 135: }
138: 136: ```
139: 137: ```
140: 138: ```
141: 139: ```
142: 140: ```
143: 141: ```
144: 142: ```
145: 143: ```
146: 144: ```
147: 145: ```
148: 146: ```
149: 147: ```
150: 148: ```
151: 149: ```
152: 150: ```
153: 151: ```
154: 152: ```
155: 153: ```
156: 154: ```
157: 155: ```
158: 156: ```
159: 157: ```
160: ```
```
