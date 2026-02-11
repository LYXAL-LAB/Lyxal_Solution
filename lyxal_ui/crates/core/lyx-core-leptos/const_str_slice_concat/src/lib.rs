### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_const_str_slice_concat\src\lib.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_const_str_slice_concat\src\lib.rs
2: ```rust
3: 1: #![no_std]
4: 2: #![forbid(unsafe_code)]
5: 3: #![deny(missing_docs)]
6: 4: 
7: 5: //! Utilities for const concatenation of string slices.
8: 6: 
9: 7: pub(crate) const MAX_TEMPLATE_SIZE: usize = 4096;
10: 8: 
11: 9: /// Converts a zero-terminated buffer of bytes into a UTF-8 string.
12: 10: pub const fn str_from_buffer(buf: &[u8; MAX_TEMPLATE_SIZE]) -> &str {
13: 11:     match core::ffi::CStr::from_bytes_until_nul(buf) {
14: 12:         Ok(cstr) => match cstr.to_str() {
15: 13:             Ok(str) => str,
16: 14:             Err(_) => panic!("TEMPLATE FAILURE"),
17: 15:         },
18: 16:         Err(_) => panic!("TEMPLATE FAILURE"),
19: 17:     }
20: 18: }
21: 19: 
22: 20: /// Concatenates any number of static strings into a single array.
23: 21: // credit to Rainer Stropek, "Constant fun," Rust Linz, June 2022
24: 22: pub const fn const_concat(
25: 23:     strs: &'static [&'static str],
26: 24: ) -> [u8; MAX_TEMPLATE_SIZE] {
27: 25:     let mut buffer = [0; MAX_TEMPLATE_SIZE];
28: 26:     let mut position = 0;
29: 27:     let mut remaining = strs;
30: 28: 
31: 29:     while let [current, tail @ ..] = remaining {
32: 30:         let x = current.as_bytes();
33: 31:         let mut i = 0;
34: 32: 
35: 33:         // have it iterate over bytes manually, because, again,
36: 34:         // no mutable references in const fns
37: 35:         while i < x.len() {
38: 36:             buffer[position] = x[i];
39: 37:             position += 1;
40: 38:             i += 1;
41: 39:         }
42: 40: 
43: 41:         remaining = tail;
44: 42:     }
45: 43: 
46: 44:     buffer
47: 45: }
48: 46: 
49: 47: /// Converts a zero-terminated buffer of bytes into a UTF-8 string with the given prefix.
50: 48: pub const fn const_concat_with_prefix(
51: 49:     strs: &'static [&'static str],
52: 50:     prefix: &'static str,
53: 51:     suffix: &'static str,
54: 52: ) -> [u8; MAX_TEMPLATE_SIZE] {
55: 53:     let mut buffer = [0; MAX_TEMPLATE_SIZE];
56: 54:     let mut position = 0;
57: 55:     let mut remaining = strs;
58: 56: 
59: 57:     while let [current, tail @ ..] = remaining {
60: 58:         let x = current.as_bytes();
61: 59:         let mut i = 0;
62: 60: 
63: 61:         // have it iterate over bytes manually, because, again,
64: 62:         // no mutable references in const fns
65: 63:         while i < x.len() {
66: 64:             buffer[position] = x[i];
67: 65:             position += 1;
68: 66:             i += 1;
69: 67:         }
70: 68: 
71: 69:         remaining = tail;
72: 70:     }
73: 71: 
74: 72:     if buffer[0] == 0 {
75: 73:         buffer
76: 74:     } else {
77: 75:         let mut new_buf = [0; MAX_TEMPLATE_SIZE];
78: 76:         let prefix = prefix.as_bytes();
79: 77:         let suffix = suffix.as_bytes();
80: 78:         let mut position = 0;
81: 79:         let mut i = 0;
82: 80:         while i < prefix.len() {
83: 81:             new_buf[position] = prefix[i];
84: 82:             position += 1;
85: 83:             i += 1;
86: 84:         }
87: 85:         i = 0;
88: 86:         while i < buffer.len() {
89: 87:             if buffer[i] == 0 {
90: 88:                 break;
91: 89:             }
92: 90:             new_buf[position] = buffer[i];
93: 91:             position += 1;
94: 92:             i += 1;
95: 93:         }
96: 94:         i = 0;
97: 95:         while i < suffix.len() {
98: 96:             new_buf[position] = suffix[i];
99: 97:             position += 1;
100: 98:             i += 1;
101: 99:         }
102: 100: 
103: 101:         new_buf
104: 102:     }
105: 103: }
106: 104: 
107: 105: /// Converts any number of strings into a UTF-8 string, separated by the given string.
108: 106: pub const fn const_concat_with_separator(
109: 107:     strs: &[&str],
110: 108:     separator: &'static str,
111: 109: ) -> [u8; MAX_TEMPLATE_SIZE] {
112: 110:     let mut buffer = [0; MAX_TEMPLATE_SIZE];
113: 111:     let mut position = 0;
114: 112:     let mut remaining = strs;
115: 113: 
116: 114:     while let [current, tail @ ..] = remaining {
117: 115:         let x = current.as_bytes();
118: 116:         let mut i = 0;
119: 117: 
120: 118:         // have it iterate over bytes manually, because, again,
121: 119:         // no mutable references in const fns
122: 120:         while i < x.len() {
123: 121:             buffer[position] = x[i];
124: 122:             position += 1;
125: 123:             i += 1;
126: 124:         }
127: 125:         if !x.is_empty() {
128: 126:             let mut position = 0;
129: 127:             let separator = separator.as_bytes();
130: 128:             while i < separator.len() {
131: 129:                 buffer[position] = separator[i];
132: 130:                 position += 1;
133: 131:                 i += 1;
134: 132:             }
135: 133:         }
136: 134: 
137: 135:         remaining = tail;
138: 136:     }
139: 137: 
140: 138:     buffer
141: 139: }
142: ```
```
