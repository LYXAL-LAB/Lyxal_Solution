### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_reactive_graph\src\owner\arena.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\src\owner\arena.rs
2: ```rust
3: 1: use lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned::OrPoisoned;
4: 2: use slotmap::{new_key_type, SlotMap};
5: 3: #[cfg(feature = "sandboxed-arenas")]
6: 4: use std::cell::RefCell;
7: 5: #[cfg(not(feature = "sandboxed-arenas"))]
8: 6: use std::sync::OnceLock;
9: 7: #[cfg(feature = "sandboxed-arenas")]
10: 8: use std::sync::Weak;
11: 9: use std::{
12: 10:     any::Any,
13: 11:     hash::Hash,
14: 12:     sync::{Arc, RwLock},
15: 13: };
16: 14: 
17: 15: new_key_type! {
18: 16:     /// Unique identifier for an item stored in the arena.
19: 17:     pub struct NodeId;
20: 18: }
21: 19: 
22: 20: pub struct Arena;
23: 21: 
24: 22: pub type ArenaMap = SlotMap<NodeId, Box<dyn Any + Send + Sync>>;
25: 23: 
26: 24: #[cfg(not(feature = "sandboxed-arenas"))]
27: 25: static MAP: OnceLock<RwLock<ArenaMap>> = OnceLock::new();
28: 26: #[cfg(feature = "sandboxed-arenas")]
29: 27: thread_local! {
30: 28:     pub(crate) static MAP: RefCell<Option<Weak<RwLock<ArenaMap>>>> = RefCell::new(Some(Default::default()));
31: 29: }
32: 30: 
33: 31: impl Arena {
34: 32:     #[inline(always)]
35: 33:     #[allow(unused)]
36: 34:     pub fn set(arena: &Arc<RwLock<ArenaMap>>) {
37: 35:         #[cfg(feature = "sandboxed-arenas")]
38: 36:         {
39: 37:             let new_arena = Arc::downgrade(arena);
40: 38:             MAP.with_borrow_mut(|arena| {
41: 39:                 *arena = Some(new_arena);
42: 40:             })
43: 41:         }
44: 42:     }
45: 43: 
46: 44:     #[track_caller]
47: 45:     pub fn with<U>(fun: impl FnOnce(&ArenaMap) -> U) -> U {
48: 46:         #[cfg(not(feature = "sandboxed-arenas"))]
49: 47:         {
50: 48:             fun(&MAP.get_or_init(Default::default).read().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned())
51: 49:         }
52: 50:         #[cfg(feature = "sandboxed-arenas")]
53: 51:         {
54: 52:             Arena::try_with(fun).unwrap_or_else(|| {
55: 53:                 panic!(
56: 54:                     "at {}, the `sandboxed-arenas` feature is active, but no \
57: 55:                      Arena is active",
58: 56:                     std::panic::Location::caller()
59: 57:                 )
60: 58:             })
61: 59:         }
62: 60:     }
63: 61: 
64: 62:     #[track_caller]
65: 63:     pub fn try_with<U>(fun: impl FnOnce(&ArenaMap) -> U) -> Option<U> {
66: 64:         #[cfg(not(feature = "sandboxed-arenas"))]
67: 65:         {
68: 66:             Some(fun(&MAP.get_or_init(Default::default).read().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned()))
69: 67:         }
70: 68:         #[cfg(feature = "sandboxed-arenas")]
71: 69:         {
72: 70:             MAP.with_borrow(|arena| {
73: 71:                 arena
74: 72:                     .as_ref()
75: 73:                     .and_then(Weak::upgrade)
76: 74:                     .map(|n| fun(&n.read().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned()))
77: 75:             })
78: 76:         }
79: 77:     }
80: 78: 
81: 79:     #[track_caller]
82: 80:     pub fn with_mut<U>(fun: impl FnOnce(&mut ArenaMap) -> U) -> U {
83: 81:         #[cfg(not(feature = "sandboxed-arenas"))]
84: 82:         {
85: 83:             fun(&mut MAP.get_or_init(Default::default).write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned())
86: 84:         }
87: 85:         #[cfg(feature = "sandboxed-arenas")]
88: 86:         {
89: 87:             Arena::try_with_mut(fun).unwrap_or_else(|| {
90: 88:                 panic!(
91: 89:                     "at {}, the `sandboxed-arenas` feature is active, but no \
92: 90:                      Arena is active",
93: 91:                     std::panic::Location::caller()
94: 92:                 )
95: 93:             })
96: 94:         }
97: 95:     }
98: 96: 
99: 97:     #[track_caller]
100: 98:     pub fn try_with_mut<U>(fun: impl FnOnce(&mut ArenaMap) -> U) -> Option<U> {
101: 99:         #[cfg(not(feature = "sandboxed-arenas"))]
102: 100:         {
103: 101:             Some(fun(&mut MAP
104: 102:                 .get_or_init(Default::default)
105: 103:                 .write()
106: 104:                 .lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned()))
107: 105:         }
108: 106:         #[cfg(feature = "sandboxed-arenas")]
109: 107:         {
110: 108:             MAP.with_borrow(|arena| {
111: 109:                 arena
112: 110:                     .as_ref()
113: 111:                     .and_then(Weak::upgrade)
114: 112:                     .map(|n| fun(&mut n.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned()))
115: 113:             })
116: 114:         }
117: 115:     }
118: 116: }
119: 117: 
120: 118: #[cfg(feature = "sandboxed-arenas")]
121: 119: pub mod sandboxed {
122: 120:     use super::{Arena, ArenaMap, MAP};
123: 121:     use futures::Stream;
124: 122:     use pin_project_lite::pin_project;
125: 123:     use std::{
126: 124:         future::Future,
127: 125:         pin::Pin,
128: 126:         sync::{Arc, RwLock, Weak},
129: 127:         task::{Context, Poll},
130: 128:     };
131: 129: 
132: 130:     pin_project! {
133: 131:         /// A [`Future`] that restores its associated arena as the current arena whenever it is
134: 132:         /// polled.
135: 133:         ///
136: 134:         /// Sandboxed arenas are used to ensure that data created in response to e.g., different
137: 135:         /// HTTP requests can be handled separately, while providing stable identifiers for their
138: 136:         /// stored values. Wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apping a `Future` in `Sandboxed` ensures that it will always use the
139: 137:         /// same arena that it was created under.
140: 138:         pub struct Sandboxed<T> {
141: 139:             arena: Option<Arc<RwLock<ArenaMap>>>,
142: 140:             #[pin]
143: 141:             inner: T,
144: 142:         }
145: 143:     }
146: 144: 
147: 145:     impl<T> Sandboxed<T> {
148: 146:         /// Wraps the given [`Future`], ensuring that any [`ArenaItem`][item] created while it is
149: 147:         /// being polled will be associated with the same arena that was active when this was
150: 148:         /// called.
151: 149:         ///
152: 150:         /// [item]:[crate::owner::ArenaItem]
153: 151:         #[track_caller]
154: 152:         pub fn new(inner: T) -> Self {
155: 153:             let arena = MAP.with_borrow(|n| n.as_ref().and_then(Weak::upgrade));
156: 154:             Self { arena, inner }
157: 155:         }
158: 156:     }
159: 157: 
160: 158:     impl<Fut> Future for Sandboxed<Fut>
161: 159:     where
162: 160:         Fut: Future,
163: 161:     {
164: 162:         type Output = Fut::Output;
165: 163: 
166: 164:         fn poll(
167: 165:             self: Pin<&mut Self>,
168: 166:             cx: &mut Context<'_>,
169: 167:         ) -> Poll<Self::Output> {
170: 168:             if let Some(arena) = self.arena.as_ref() {
171: 169:                 Arena::set(arena);
172: 170:             }
173: 171:             let this = self.project();
174: 172:             this.inner.poll(cx)
175: 173:         }
176: 174:     }
177: 175: 
178: 176:     impl<T> Stream for Sandboxed<T>
179: 177:     where
180: 178:         T: Stream,
181: 179:     {
182: 180:         type Item = T::Item;
183: 181: 
184: 182:         fn poll_next(
185: 183:             self: Pin<&mut Self>,
186: 184:             cx: &mut Context<'_>,
187: 185:         ) -> Poll<Option<Self::Item>> {
188: 186:             if let Some(arena) = self.arena.as_ref() {
189: 187:                 Arena::set(arena);
190: 188:             }
191: 189:             let this = self.project();
192: 190:             this.inner.poll_next(cx)
193: 191:         }
194: 192:     }
195: 193: }
196: ```
```
