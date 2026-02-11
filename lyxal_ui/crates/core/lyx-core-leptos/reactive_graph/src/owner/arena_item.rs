### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_reactive_graph\src\owner\arena_item.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\src\owner\arena_item.rs
2: ```rust
3: 1: use super::{
4: 2:     arena::{Arena, NodeId},
5: 3:     LocalStorage, Storage, SyncStorage, OWNER,
6: 4: };
7: 5: use crate::traits::{Dispose, IntoInner, IsDisposed};
8: 6: use send_wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper::SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper;
9: 7: use std::{any::Any, hash::Hash, marker::PhantomData};
10: 8: 
11: 9: /// A copyable, stable reference for any value, stored on the arena whose ownership is managed by the
12: 10: /// reactive ownership tree.
13: 11: #[derive(Debug)]
14: 12: pub struct ArenaItem<T, S = SyncStorage> {
15: 13:     node: NodeId,
16: 14:     #[allow(clippy::type_complexity)]
17: 15:     ty: PhantomData<fn() -> (SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper<T>, S)>,
18: 16: }
19: 17: 
20: 18: impl<T, S> Copy for ArenaItem<T, S> {}
21: 19: 
22: 20: impl<T, S> Clone for ArenaItem<T, S> {
23: 21:     fn clone(&self) -> Self {
24: 22:         *self
25: 23:     }
26: 24: }
27: 25: 
28: 26: impl<T, S> PartialEq for ArenaItem<T, S> {
29: 27:     fn eq(&self, other: &Self) -> bool {
30: 28:         self.node == other.node
31: 29:     }
32: 30: }
33: 31: 
34: 32: impl<T, S> Eq for ArenaItem<T, S> {}
35: 33: 
36: 34: impl<T, S> Hash for ArenaItem<T, S> {
37: 35:     fn hash<H: std::hash::Hasher>(&self, state: &mut H) {
38: 36:         self.node.hash(state);
39: 37:     }
40: 38: }
41: 39: 
42: 40: impl<T, S> ArenaItem<T, S>
43: 41: where
44: 42:     T: 'static,
45: 43:     S: Storage<T>,
46: 44: {
47: 45:     /// Stores the given value in the arena allocator.
48: 46:     #[track_caller]
49: 47:     pub fn new_with_storage(value: T) -> Self {
50: 48:         let node = {
51: 49:             Arena::with_mut(|arena| {
52: 50:                 arena.insert(
53: 51:                     Box::new(S::wrap(value)) as Box<dyn Any + Send + Sync>
54: 52:                 )
55: 53:             })
56: 54:         };
57: 55:         OWNER.with(|o| {
58: 56:             if let Some(owner) = o.borrow().as_ref().and_then(|o| o.upgrade()) {
59: 57:                 owner.register(node);
60: 58:             }
61: 59:         });
62: 60: 
63: 61:         Self {
64: 62:             node,
65: 63:             ty: PhantomData,
66: 64:         }
67: 65:     }
68: 66: }
69: 67: 
70: 68: impl<T, S> Default for ArenaItem<T, S>
71: 69: where
72: 70:     T: Default + 'static,
73: 71:     S: Storage<T>,
74: 72: {
75: 73:     #[track_caller] // Default trait is not annotated with #[track_caller]
76: 74:     fn default() -> Self {
77: 75:         Self::new_with_storage(Default::default())
78: 76:     }
79: 77: }
80: 78: 
81: 79: impl<T> ArenaItem<T>
82: 80: where
83: 81:     T: Send + Sync + 'static,
84: 82: {
85: 83:     /// Stores the given value in the arena allocator.
86: 84:     #[track_caller]
87: 85:     pub fn new(value: T) -> Self {
88: 86:         ArenaItem::new_with_storage(value)
89: 87:     }
90: 88: }
91: 89: 
92: 90: impl<T> ArenaItem<T, LocalStorage>
93: 91: where
94: 92:     T: 'static,
95: 93: {
96: 94:     /// Stores the given value in the arena allocator.
97: 95:     #[track_caller]
98: 96:     pub fn new_local(value: T) -> Self {
99: 97:         ArenaItem::new_with_storage(value)
100: 98:     }
101: 99: }
102: 100: 
103: 101: impl<T, S: Storage<T>> ArenaItem<T, S> {
104: 102:     /// Applies a function to a reference to the stored value and returns the result, or `None` if it has already been disposed.
105: 103:     #[track_caller]
106: 104:     pub fn try_with_value<U>(&self, fun: impl FnOnce(&T) -> U) -> Option<U> {
107: 105:         S::try_with(self.node, fun)
108: 106:     }
109: 107: 
110: 108:     /// Applies a function to a mutable reference to the stored value and returns the result, or `None` if it has already been disposed.
111: 109:     #[track_caller]
112: 110:     pub fn try_update_value<U>(
113: 111:         &self,
114: 112:         fun: impl FnOnce(&mut T) -> U,
115: 113:     ) -> Option<U> {
116: 114:         S::try_with_mut(self.node, fun)
117: 115:     }
118: 116: }
119: 117: 
120: 118: impl<T: Clone, S: Storage<T>> ArenaItem<T, S> {
121: 119:     /// Returns a clone of the stored value, or `None` if it has already been disposed.
122: 120:     #[track_caller]
123: 121:     pub fn try_get_value(&self) -> Option<T> {
124: 122:         S::try_with(self.node, Clone::clone)
125: 123:     }
126: 124: }
127: 125: 
128: 126: impl<T, S> IsDisposed for ArenaItem<T, S> {
129: 127:     fn is_disposed(&self) -> bool {
130: 128:         Arena::with(|arena| !arena.contains_key(self.node))
131: 129:     }
132: 130: }
133: 131: 
134: 132: impl<T, S> Dispose for ArenaItem<T, S> {
135: 133:     fn dispose(self) {
136: 134:         Arena::with_mut(|arena| arena.remove(self.node));
137: 135:     }
138: 136: }
139: 137: 
140: 138: impl<T, S: Storage<T>> IntoInner for ArenaItem<T, S> {
141: 139:     type Value = T;
142: 140: 
143: 141:     #[inline(always)]
144: 142:     fn into_inner(self) -> Option<Self::Value> {
145: 143:         S::take(self.node)
146: 144:     }
147: 145: }
148: ```
```
