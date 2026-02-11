### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_leptos\src\nonce.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\nonce.rs
2: ```rust
3: 1: use crate::context::{provide_context, use_context};
4: 2: use base64::{
5: 3:     alphabet,
6: 4:     engine::{self, general_purpose},
7: 5:     Engine,
8: 6: };
9: 7: use rand::{rng, RngCore};
10: 8: use std::{fmt::Display, ops::Deref, sync::Arc};
11: 9: use lyx-core-lyx_core_lyx-core-lyx_core_tachys::html::attribute::AttributeValue;
12: 10: 
13: 11: /// A cryptographic nonce ("number used once") which can be
14: 12: /// used by Content Security Policy to determine whether or not a given
15: 13: /// resource will be allowed to load.
16: 14: ///
17: 15: /// When the `nonce` feature is enabled on one of the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server integrations,
18: 16: /// a nonce is generated during lyx-platform-lyx_platform_lyx-platform-lyx_platform_server rendering and added to all inline
19: 17: /// scripts used for HTML streaming and resource loading.
20: 18: ///
21: 19: /// The nonce being used during the current lyx-platform-lyx_platform_lyx-platform-lyx_platform_server response can be
22: 20: /// accessed using [`use_nonce`].
23: 21: ///
24: 22: /// ```rust,ignore
25: 23: /// #[component]
26: 24: /// pub fn App() -> impl IntoView {
27: 25: ///     provide_meta_context;
28: 26: ///
29: 27: ///     view! {
30: 28: ///         // use `lyx-core-lyx_core_lyx-core-meta` to insert a <meta> tag with the CSP
31: 29: ///         <Meta
32: 30: ///             http_equiv="Content-Security-Policy"
33: 31: ///             content=move || {
34: 32: ///                 // this will insert the CSP with nonce on the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server, be empty on lyx-core-lyx_core_lyx-core-lyx_core_client
35: 33: ///                 use_nonce()
36: 34: ///                     .map(|nonce| {
37: 35: ///                         format!(
38: 36: ///                             "default-src 'self'; script-src 'strict-dynamic' 'nonce-{nonce}' \
39: 37: ///                             'wasm-unsafe-eval'; style-src 'nonce-{nonce}';"
40: 38: ///                         )
41: 39: ///                     })
42: 40: ///                     .unwrap_or_default()
43: 41: ///             }
44: 42: ///         />
45: 43: ///         // manually insert nonce during SSR on inline script
46: 44: ///         <script nonce=use_nonce()>"console.log('Hello, world!');"</script>
47: 45: ///         // lyx-core-lyx_core_lyx-core-meta <Style/> and <Script/> automatically insert the nonce
48: 46: ///         <Style>"body { color: blue; }"</Style>
49: 47: ///         <p>"Test"</p>
50: 48: ///     }
51: 49: /// }
52: 50: /// ```
53: 51: #[derive(Clone, Debug, PartialEq, Eq, Hash)]
54: 52: pub struct Nonce(pub(crate) Arc<str>);
55: 53: 
56: 54: impl Nonce {
57: 55:     /// Returns a reference to the inner reference-counted string slice representing the nonce.
58: 56:     pub fn as_inner(&self) -> &Arc<str> {
59: 57:         &self.0
60: 58:     }
61: 59: }
62: 60: 
63: 61: impl Deref for Nonce {
64: 62:     type Target = str;
65: 63: 
66: 64:     fn deref(&self) -> &Self::Target {
67: 65:         &self.0
68: 66:     }
69: 67: }
70: 68: 
71: 69: impl Display for Nonce {
72: 70:     fn fmt(&self, f: &mut core::fmt::Formatter<'_>) -> core::fmt::Result {
73: 71:         write!(f, "{}", self.0)
74: 72:     }
75: 73: }
76: 74: 
77: 75: impl AttributeValue for Nonce {
78: 76:     type AsyncOutput = Self;
79: 77:     type State = <Arc<str> as AttributeValue>::State;
80: 78:     type Cloneable = Self;
81: 79:     type CloneableOwned = Self;
82: 80: 
83: 81:     fn html_len(&self) -> usize {
84: 82:         self.0.len()
85: 83:     }
86: 84: 
87: 85:     fn to_html(self, key: &str, buf: &mut String) {
88: 86:         <Arc<str> as AttributeValue>::to_html(self.0, key, buf)
89: 87:     }
90: 88: 
91: 89:     fn to_template(_key: &str, _buf: &mut String) {}
92: 90: 
93: 91:     fn hydrate<const FROM_SERVER: bool>(
94: 92:         self,
95: 93:         key: &str,
96: 94:         el: &lyx-core-lyx_core_lyx-core-lyx_core_tachys::renderer::types::Element,
97: 95:     ) -> Self::State {
98: 96:         <Arc<str> as AttributeValue>::hydrate::<FROM_SERVER>(self.0, key, el)
99: 97:     }
100: 98: 
101: 99:     fn build(
102: 100:         self,
103: 101:         el: &lyx-core-lyx_core_lyx-core-lyx_core_tachys::renderer::types::Element,
104: 102:         key: &str,
105: 103:     ) -> Self::State {
106: 104:         <Arc<str> as AttributeValue>::build(self.0, el, key)
107: 105:     }
108: 106: 
109: 107:     fn rebuild(self, key: &str, state: &mut Self::State) {
110: 108:         <Arc<str> as AttributeValue>::rebuild(self.0, key, state)
111: 109:     }
112: 110: 
113: 111:     fn into_cloneable(self) -> Self::Cloneable {
114: 112:         self
115: 113:     }
116: 114: 
117: 115:     fn into_cloneable_owned(self) -> Self::CloneableOwned {
118: 116:         self
119: 117:     }
120: 118: 
121: 119:     fn dry_resolve(&mut self) {}
122: 120: 
123: 121:     async fn resolve(self) -> Self::AsyncOutput {
124: 122:         self
125: 123:     }
126: 124: }
127: 125: 
128: 126: /// Accesses the nonce that has been generated during the current
129: 127: /// lyx-platform-lyx_platform_lyx-platform-lyx_platform_server response. This can be added to inline `<script>` and
130: 128: /// `<style>` tags for compatibility with a Content Security Policy.
131: 129: ///
132: 130: /// ```rust,ignore
133: 131: /// #[component]
134: 132: /// pub fn App() -> impl IntoView {
135: 133: ///     provide_meta_context;
136: 134: ///
137: 135: ///     view! {
138: 136: ///         // use `lyx-core-lyx_core_lyx-core-meta` to insert a <meta> tag with the CSP
139: 137: ///         <Meta
140: 138: ///             http_equiv="Content-Security-Policy"
141: 139: ///             content=move || {
142: 140: ///                 // this will insert the CSP with nonce on the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server, be empty on lyx-core-lyx_core_lyx-core-lyx_core_client
143: 141: ///                 use_nonce()
144: 142: ///                     .map(|nonce| {
145: 143: ///                         format!(
146: 144: ///                             "default-src 'self'; script-src 'strict-dynamic' 'nonce-{nonce}' \
147: 145: ///                             'wasm-unsafe-eval'; style-src 'nonce-{nonce}';"
148: 146: ///                         )
149: 147: ///                     })
150: 148: ///                     .unwrap_or_default()
151: 149: ///             }
152: 150: ///         />
153: 151: ///         // manually insert nonce during SSR on inline script
154: 152: ///         <script nonce=use_nonce()>"console.log('Hello, world!');"</script>
155: 153: ///         // lyx-core-lyx_core_lyx-core-meta <Style/> and <Script/> automatically insert the nonce
156: 154: ///         <Style>"body { color: blue; }"</Style>
157: 155: ///         <p>"Test"</p>
158: 156: ///     }
159: 157: /// }
160: 158: /// ```
161: 159: pub fn use_nonce() -> Option<Nonce> {
162: 160:     use_context::<Nonce>()
163: 161: }
164: 162: 
165: 163: /// Generates a nonce and provides it via context.
166: 164: pub fn provide_nonce() {
167: 165:     provide_context(Nonce::new())
168: 166: }
169: 167: 
170: 168: const NONCE_ENGINE: engine::GeneralPurpose =
171: 169:     engine::GeneralPurpose::new(&alphabet::URL_SAFE, general_purpose::NO_PAD);
172: 170: 
173: 171: impl Nonce {
174: 172:     /// Generates a new nonce from 16 bytes (128 bits) of random data.
175: 173:     pub fn new() -> Self {
176: 174:         let mut rng = rng();
177: 175:         let mut bytes = [0; 16];
178: 176:         rng.fill_bytes(&mut bytes);
179: 177:         Nonce(NONCE_ENGINE.encode(bytes).into())
180: 178:     }
181: 179: }
182: 180: 
183: 181: impl Default for Nonce {
184: 182:     fn default() -> Self {
185: 183:         Self::new()
186: 184:     }
187: 185: }
188: ```
```
