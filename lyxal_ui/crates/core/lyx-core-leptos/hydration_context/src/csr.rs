### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_hydration_context\src\csr.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_hydration_context\src\csr.rs
2: ```rust
3: 1: use super::{SerializedDataId, SharedContext};
4: 2: use crate::{PinnedFuture, PinnedStream};
5: 3: 
6: 4: #[derive(Debug, Default)]
7: 5: /// The shared context that should be used in the browser while hydrating.
8: 6: pub struct CsrSharedContext;
9: 7: 
10: 8: impl SharedContext for CsrSharedContext {
11: 9:     #[inline(always)]
12: 10:     fn is_browser(&self) -> bool {
13: 11:         true
14: 12:     }
15: 13: 
16: 14:     #[inline(always)]
17: 15:     fn next_id(&self) -> SerializedDataId {
18: 16:         SerializedDataId(0)
19: 17:     }
20: 18: 
21: 19:     #[inline(always)]
22: 20:     fn write_async(&self, _id: SerializedDataId, _fut: PinnedFuture<String>) {}
23: 21: 
24: 22:     #[inline(always)]
25: 23:     fn read_data(&self, _id: &SerializedDataId) -> Option<String> {
26: 24:         None
27: 25:     }
28: 26: 
29: 27:     #[inline(always)]
30: 28:     fn await_data(&self, _id: &SerializedDataId) -> Option<String> {
31: 29:         todo!()
32: 30:     }
33: 31: 
34: 32:     #[inline(always)]
35: 33:     fn pending_data(&self) -> Option<PinnedStream<String>> {
36: 34:         None
37: 35:     }
38: 36: 
39: 37:     #[inline(always)]
40: 38:     fn get_is_hydrating(&self) -> bool {
41: 39:         false
42: 40:     }
43: 41: 
44: 42:     #[inline(always)]
45: 43:     fn set_is_hydrating(&self, _is_hydrating: bool) {}
46: 44: 
47: 45:     #[inline(always)]
48: 46:     fn errors(
49: 47:         &self,
50: 48:         _boundary_id: &SerializedDataId,
51: 49:     ) -> Vec<(lyx-core-any_error::ErrorId, lyx-core-any_error::Error)> {
52: 50:         Vec::new()
53: 51:     }
54: 52: 
55: 53:     #[inline(always)]
56: 54:     fn take_errors(
57: 55:         &self,
58: 56:     ) -> Vec<(SerializedDataId, lyx-core-any_error::ErrorId, lyx-core-any_error::Error)> {
59: 57:         Vec::new()
60: 58:     }
61: 59: 
62: 60:     #[inline(always)]
63: 61:     fn register_error(
64: 62:         &self,
65: 63:         _error_boundary: SerializedDataId,
66: 64:         _error_id: lyx-core-any_error::ErrorId,
67: 65:         _error: lyx-core-any_error::Error,
68: 66:     ) {
69: 67:     }
70: 68: 
71: 69:     #[inline(always)]
72: 70:     fn seal_errors(&self, _boundary_id: &SerializedDataId) {}
73: 71: 
74: 72:     #[inline(always)]
75: 73:     fn during_hydration(&self) -> bool {
76: 74:         false
77: 75:     }
78: 76: 
79: 77:     #[inline(always)]
80: 78:     fn hydration_complete(&self) {}
81: 79: 
82: 80:     #[inline(always)]
83: 81:     fn defer_stream(&self, _wait_for: PinnedFuture<()>) {}
84: 82: 
85: 83:     #[inline(always)]
86: 84:     fn await_deferred(&self) -> Option<PinnedFuture<()>> {
87: 85:         None
88: 86:     }
89: 87: 
90: 88:     #[inline(always)]
91: 89:     fn set_incomplete_chunk(&self, _id: SerializedDataId) {}
92: 90: 
93: 91:     #[inline(always)]
94: 92:     fn get_incomplete_chunk(&self, _id: &SerializedDataId) -> bool {
95: 93:         false
96: 94:     }
97: 95: }
98: ```
```
