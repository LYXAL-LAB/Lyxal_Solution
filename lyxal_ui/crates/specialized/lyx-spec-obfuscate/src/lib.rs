### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx-spec-obfuscate\src\lib.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx-spec-obfuscate\src\lib.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_obfuscate\src\lib.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_obfuscate\src\lib.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_obfuscate\src\lib.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_obfuscate\src\lib.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_obfuscate\src\lib.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_obfuscate\src\lib.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_obfuscate\src\lib.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_obfuscate\src\lib.rs
18: 16: ```rust
19: 17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_obfuscate\src\lib.rs
20: 18: ```rust
21: 19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_obfuscate\src\lib.rs
22: 20: ```rust
23: 21: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_obfuscate\src\lib.rs
24: 22: ```rust
25: 23: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_obfuscate\src\lib.rs
26: 24: ```rust
27: 25: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_obfuscate\src\lib.rs
28: 26: ```rust
29: 27: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_obfuscate\src\lib.rs
30: 28: ```rust
31: 29: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_obfuscate\src\lib.rs
32: 30: ```rust
33: 31: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_obfuscate\src\lib.rs
34: 32: ```rust
35: 33: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_obfuscate\src\lib.rs
36: 34: ```rust
37: 35: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_obfuscate\src\lib.rs
38: 36: ```rust
39: 37: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_obfuscate\src\lib.rs
40: 38: ```rust
41: 39: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_obfuscate\src\lib.rs
42: 40: ```rust
43: 41: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_obfuscate\src\lib.rs
44: 42: ```rust
45: 43: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_obfuscate\src\lib.rs
46: 44: ```rust
47: 45: // Copyright 2024 Sebastian Dobe <sebastiandobe@mailbox.org>
48: 46: 
49: 47: #![doc = include_str!("../README.md")]
50: 48: 
51: 49: use core::time::Duration;
52: 50: use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
53: 51: 
54: 52: /// The component accepts an optional honeypot email address / link you can use, if you want to have a
55: 53: /// sophisticated setup and blacklist any sender that sends an E-Mail to it.
56: 54: ///
57: 55: /// The `delay_seconds` can be set as well. After this timeout, when mounted inside the browser,
58: 56: /// the honeypot address will be exchanged with the real one. This means the link will not work with
59: 57: /// HTML only, but there is no good way to prevent bots without Javascript / WASM.
60: 58: ///
61: 59: /// # Panics
62: 60: /// If the given String does not contain '@'
63: 61: #[component]
64: 62: pub fn ObfuscateEmail(
65: 63:     #[prop(into)] email: MaybeProp<String>,
66: 64:     #[prop(default = "mailto:honeypot@lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_example.com")] honeypot: &'static str,
67: 65:     #[prop(default = 3)] delay_seconds: u64,
68: 66: ) -> impl IntoView {
69: 67:     let mailto = RwSignal::new(honeypot.to_string());
70: 68: 
71: 69:     Effect::new(move |_| {
72: 70:         if let Some(real_email) = email.get() {
73: 71:             let mail = format!("mailto:{}", real_email);
74: 72:             set_timeout(move || mailto.set(mail), Duration::from_secs(delay_seconds));
75: 73:         }
76: 74:     });
77: 75: 
78: 76:     let one = move || {
79: 77:         email.get().and_then(|plain| plain.split_once('@').map(|(one, _)| one.chars().rev().collect::<String>()))
80: 78:             .unwrap_or_default()
81: 79:     };
82: 80: 
83: 81:     let two = move || {
84: 82:         email.get().and_then(|plain| plain.split_once('@').map(|(_, two)| two.chars().rev().collect::<String>()))
85: 83:             .unwrap_or_default()
86: 84:     };
87: 85: 
88: 86:     view! {
89: 87:         <a href=move || mailto.get()>
90: 88:             <span aria-label="E-Mail" class="obfuscate">
91: 89:                 {two}
92: 90:                 <i>"%/#"</i>
93: 91:                 <span></span>
94: 92:                 {one}
95: 93:             </span>
96: 94:         </a>
97: 95:     }
98: 96: }
99: 97: 
100: 98: ```
101: 99: ```
102: 100: ```
103: 101: ```
104: 102: ```
105: 103: ```
106: 104: ```
107: 105: ```
108: 106: ```
109: 107: ```
110: 108: ```
111: 109: ```
112: 110: ```
113: 111: ```
114: 112: ```
115: 113: ```
116: 114: ```
117: 115: ```
118: 116: ```
119: 117: ```
120: 118: ```
121: 119: ```
122: ```
```
