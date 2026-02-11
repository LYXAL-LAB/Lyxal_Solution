### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_hydration_context\src\lib.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_hydration_context\src\lib.rs
2: ```rust
3: 1: //! Isomorphic web lyx-platform-lyx_platform_lyx-platform-lyx_platform_applications that run on the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server to render HTML, then add interactivity in
4: 2: //! the lyx-core-lyx_core_lyx-core-lyx_core_client, need to accomplish two tasks:
5: 3: //! 1. Send HTML from the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server, so that the lyx-core-lyx_core_lyx-core-lyx_core_client can "hydrate" it in the browser by adding
6: 4: //!    event listeners and setting up other interactivity.
7: 5: //! 2. Send data that was loaded on the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server to the lyx-core-lyx_core_lyx-core-lyx_core_client, so that the lyx-core-lyx_core_lyx-core-lyx_core_client "hydrates" with
8: 6: //!    the same data with which the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server rendered HTML.
9: 7: //!
10: 8: //! This crate helps with the second part of this process. It provides a [`SharedContext`] type
11: 9: //! that allows you to store data on the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server, and then extract the same data in the lyx-core-lyx_core_lyx-core-lyx_core_client.
12: 10: 
13: 11: #![deny(missing_docs)]
14: 12: #![forbid(unsafe_code)]
15: 13: #![cfg_attr(docsrs, feature(doc_cfg))]
16: 14: 
17: 15: #[cfg(feature = "browser")]
18: 16: #[cfg_attr(docsrs, doc(cfg(feature = "browser")))]
19: 17: mod csr;
20: 18: #[cfg(feature = "browser")]
21: 19: #[cfg_attr(docsrs, doc(cfg(feature = "browser")))]
22: 20: mod hydrate;
23: 21: mod ssr;
24: 22: #[cfg(feature = "browser")]
25: 23: pub use csr::*;
26: 24: use futures::Stream;
27: 25: #[cfg(feature = "browser")]
28: 26: pub use hydrate::*;
29: 27: use serde::{Deserialize, Serialize};
30: 28: pub use ssr::*;
31: 29: use std::{fmt::Debug, future::Future, pin::Pin};
32: 30: use lyx-core-any_error::{Error, ErrorId};
33: 31: 
34: 32: /// Type alias for a boxed [`Future`].
35: 33: pub type PinnedFuture<T> = Pin<Box<dyn Future<Output = T> + Send + Sync>>;
36: 34: /// Type alias for a boxed [`Future`] that is `!Send`.
37: 35: pub type PinnedLocalFuture<T> = Pin<Box<dyn Future<Output = T>>>;
38: 36: /// Type alias for a boxed [`Stream`].
39: 37: pub type PinnedStream<T> = Pin<Box<dyn Stream<Item = T> + Send + Sync>>;
40: 38: 
41: 39: #[derive(
42: 40:     Clone, Debug, PartialEq, Eq, Hash, Default, Deserialize, Serialize,
43: 41: )]
44: 42: #[serde(transparent)]
45: 43: /// A unique identifier for a piece of data that will be serialized
46: 44: /// from the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server to the lyx-core-lyx_core_lyx-core-lyx_core_client.
47: 45: pub struct SerializedDataId(usize);
48: 46: 
49: 47: impl SerializedDataId {
50: 48:     /// Create a new instance of [`SerializedDataId`].
51: 49:     pub fn new(id: usize) -> Self {
52: 50:         SerializedDataId(id)
53: 51:     }
54: 52: 
55: 53:     /// Consume into the inner usize identifier.
56: 54:     pub fn into_inner(self) -> usize {
57: 55:         self.0
58: 56:     }
59: 57: }
60: 58: 
61: 59: impl From<SerializedDataId> for ErrorId {
62: 60:     fn from(value: SerializedDataId) -> Self {
63: 61:         value.0.into()
64: 62:     }
65: 63: }
66: 64: 
67: 65: /// Information that will be shared between the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server and the lyx-core-lyx_core_lyx-core-lyx_core_client.
68: 66: pub trait SharedContext: Debug {
69: 67:     /// Whether the lyx-platform-lyx_platform_lyx-platform-lyx_platform_application is running in the browser.
70: 68:     fn is_browser(&self) -> bool;
71: 69: 
72: 70:     /// Returns the next in a series of IDs that is unique to a particular request and response.
73: 71:     ///
74: 72:     /// This should not be used as a global unique ID mechanism. It is specific to the process
75: 73:     /// of serializing and deserializing data from the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server to the browser as part of an HTTP
76: 74:     /// response.
77: 75:     fn next_id(&self) -> SerializedDataId;
78: 76: 
79: 77:     /// The given [`Future`] should resolve with some data that can be serialized
80: 78:     /// from the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server to the lyx-core-lyx_core_lyx-core-lyx_core_client. This will be polled as part of the process of
81: 79:     /// building the HTTP response, *not* when it is first created.
82: 80:     ///
83: 81:     /// In browser implementations, this should be a no-op.
84: 82:     fn write_async(&self, id: SerializedDataId, fut: PinnedFuture<String>);
85: 83: 
86: 84:     /// Reads the current value of some data from the shared context, if it has been
87: 85:     /// sent from the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server. This returns the serialized data as a `String` that should
88: 86:     /// be deserialized.
89: 87:     ///
90: 88:     /// On the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server and in lyx-core-lyx_core_lyx-core-lyx_core_client-side rendered implementations, this should
91: 89:     /// always return [`None`].
92: 90:     fn read_data(&self, id: &SerializedDataId) -> Option<String>;
93: 91: 
94: 92:     /// Returns a [`Future`] that resolves with a `String` that should
95: 93:     /// be deserialized once the given piece of lyx-platform-lyx_platform_lyx-platform-lyx_platform_server data has resolved.
96: 94:     ///
97: 95:     /// On the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server and in lyx-core-lyx_core_lyx-core-lyx_core_client-side rendered implementations, this should
98: 96:     /// return a [`Future`] that is immediately ready with [`None`].
99: 97:     fn await_data(&self, id: &SerializedDataId) -> Option<String>;
100: 98: 
101: 99:     /// Returns some [`Stream`] of HTML that contains JavaScript `<script>` tags defining
102: 100:     /// all values being serialized from the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server to the lyx-core-lyx_core_lyx-core-lyx_core_client, with their serialized values
103: 101:     /// and any boilerplate needed to notify a running lyx-platform-lyx_platform_lyx-platform-lyx_platform_application that they exist; or `None`.
104: 102:     ///
105: 103:     /// In browser implementations, this return `None`.
106: 104:     fn pending_data(&self) -> Option<PinnedStream<String>>;
107: 105: 
108: 106:     /// Whether the page is currently being hydrated.
109: 107:     ///
110: 108:     /// Should always be `false` on the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server or when lyx-core-lyx_core_lyx-core-lyx_core_client-rendering, including after the
111: 109:     /// initial hydration in the lyx-core-lyx_core_lyx-core-lyx_core_client.
112: 110:     fn during_hydration(&self) -> bool;
113: 111: 
114: 112:     /// Tells the shared context that the hydration process is complete.
115: 113:     fn hydration_complete(&self);
116: 114: 
117: 115:     /// Returns `true` if you are currently in a part of the lyx-platform-lyx_platform_lyx-platform-lyx_platform_application tree that should be
118: 116:     /// hydrated.
119: 117:     ///
120: 118:     /// For lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_example, in an lyx-platform-lyx_platform_lyx-platform-lyx_platform_app with "islands," this should be `true` inside islands and
121: 119:     /// false elsewhere.
122: 120:     fn get_is_hydrating(&self) -> bool;
123: 121: 
124: 122:     /// Sets whether you are currently in a part of the lyx-platform-lyx_platform_lyx-platform-lyx_platform_application tree that should be hydrated.
125: 123:     ///
126: 124:     /// For lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_example, in an lyx-platform-lyx_platform_lyx-platform-lyx_platform_app with "islands," this should be `true` inside islands and
127: 125:     /// false elsewhere.
128: 126:     fn set_is_hydrating(&self, is_hydrating: bool);
129: 127: 
130: 128:     /// Returns all errors that have been registered, removing them from the list.
131: 129:     fn take_errors(&self) -> Vec<(SerializedDataId, ErrorId, Error)>;
132: 130: 
133: 131:     /// Returns the set of errors that have been registered with a particular boundary.
134: 132:     fn errors(&self, boundary_id: &SerializedDataId) -> Vec<(ErrorId, Error)>;
135: 133: 
136: 134:     /// "Seals" an error boundary, preventing further errors from being registered for it.
137: 135:     ///
138: 136:     /// This can be used in streaming SSR scenarios in which the final state of the error boundary
139: 137:     /// can only be known after the initial state is hydrated.
140: 138:     fn seal_errors(&self, boundary_id: &SerializedDataId);
141: 139: 
142: 140:     /// Registers an error with the context to be shared from lyx-platform-lyx_platform_lyx-platform-lyx_platform_server to lyx-core-lyx_core_lyx-core-lyx_core_client.
143: 141:     fn register_error(
144: 142:         &self,
145: 143:         error_boundary: SerializedDataId,
146: 144:         error_id: ErrorId,
147: 145:         error: Error,
148: 146:     );
149: 147: 
150: 148:     /// Adds a `Future` to the set of “blocking resources” that should prevent the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server’s
151: 149:     /// response stream from beginning until all are resolved. The `Future` returned by
152: 150:     /// blocking resources will not resolve until every `Future` added by this method
153: 151:     /// has resolved.
154: 152:     ///
155: 153:     /// In browser implementations, this should be a no-op.
156: 154:     fn defer_stream(&self, wait_for: PinnedFuture<()>);
157: 155: 
158: 156:     /// Returns a `Future` that will resolve when every `Future` added via
159: 157:     /// [`defer_stream`](Self::defer_stream) has resolved.
160: 158:     ///
161: 159:     /// In browser implementations, this should be a no-op.
162: 160:     fn await_deferred(&self) -> Option<PinnedFuture<()>>;
163: 161: 
164: 162:     /// Tells the lyx-core-lyx_core_lyx-core-lyx_core_client that this chunk is being sent from the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server before all its data have
165: 163:     /// loaded, and it may be in a fallback state.
166: 164:     fn set_incomplete_chunk(&self, id: SerializedDataId);
167: 165: 
168: 166:     /// Checks whether this chunk is being sent from the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server before all its data have loaded.
169: 167:     fn get_incomplete_chunk(&self, id: &SerializedDataId) -> bool;
170: 168: }
171: ```
```
