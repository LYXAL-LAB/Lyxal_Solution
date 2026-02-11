### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_reactive_graph\src\owner\storage.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\src\owner\storage.rs
2: ```rust
3: 1: use super::arena::{Arena, NodeId};
4: 2: use send_wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper::SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper;
5: 3: 
6: 4: /// A trait for borrowing and taking data.
7: 5: pub trait StorageAccess<T> {
8: 6:     /// Borrows the value.
9: 7:     fn as_borrowed(&self) -> &T;
10: 8: 
11: 9:     /// Takes the value.
12: 10:     fn into_taken(self) -> T;
13: 11: }
14: 12: 
15: 13: impl<T> StorageAccess<T> for T {
16: 14:     fn as_borrowed(&self) -> &T {
17: 15:         self
18: 16:     }
19: 17: 
20: 18:     fn into_taken(self) -> T {
21: 19:         self
22: 20:     }
23: 21: }
24: 22: 
25: 23: impl<T> StorageAccess<T> for SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper<T> {
26: 24:     fn as_borrowed(&self) -> &T {
27: 25:         self
28: 26:     }
29: 27: 
30: 28:     fn into_taken(self) -> T {
31: 29:         self.take()
32: 30:     }
33: 31: }
34: 32: 
35: 33: /// A way of storing an [`ArenaItem`](super::arena_item::ArenaItem), either as itself or with a wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper to make it threadsafe.
36: 34: ///
37: 35: /// This exists because all items stored in the arena must be `Send + Sync`, but in single-threaded
38: 36: /// environments you might want or need to use thread-unsafe types.
39: 37: pub trait Storage<T>: Send + Sync + 'static {
40: 38:     /// The type being stored, once it has been wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apped.
41: 39:     type Wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apped: StorageAccess<T> + Send + Sync + 'static;
42: 40: 
43: 41:     /// Adds any needed wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper to the type.
44: 42:     fn wrap(value: T) -> Self::Wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apped;
45: 43: 
46: 44:     /// Applies the given function to the stored value, if it exists and can be accessed from this
47: 45:     /// thread.
48: 46:     fn try_with<U>(node: NodeId, fun: impl FnOnce(&T) -> U) -> Option<U>;
49: 47: 
50: 48:     /// Applies the given function to a mutable reference to the stored value, if it exists and can be accessed from this
51: 49:     /// thread.
52: 50:     fn try_with_mut<U>(
53: 51:         node: NodeId,
54: 52:         fun: impl FnOnce(&mut T) -> U,
55: 53:     ) -> Option<U>;
56: 54: 
57: 55:     /// Sets a new value for the stored value. If it has been disposed, returns `Some(T)`.
58: 56:     fn try_set(node: NodeId, value: T) -> Option<T>;
59: 57: 
60: 58:     /// Takes an item from the arena if it exists and can be accessed from this thread.
61: 59:     /// If it cannot be casted, it will still be removed from the arena.
62: 60:     fn take(node: NodeId) -> Option<T>;
63: 61: }
64: 62: 
65: 63: /// A form of [`Storage`] that stores the type as itself, with no wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper.
66: 64: #[derive(Debug, Copy, Clone)]
67: 65: pub struct SyncStorage;
68: 66: 
69: 67: impl<T> Storage<T> for SyncStorage
70: 68: where
71: 69:     T: Send + Sync + 'static,
72: 70: {
73: 71:     type Wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apped = T;
74: 72: 
75: 73:     #[inline(always)]
76: 74:     fn wrap(value: T) -> Self::Wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apped {
77: 75:         value
78: 76:     }
79: 77: 
80: 78:     fn try_with<U>(node: NodeId, fun: impl FnOnce(&T) -> U) -> Option<U> {
81: 79:         Arena::try_with(|arena| {
82: 80:             let m = arena.get(node);
83: 81:             m.and_then(|n| n.downcast_ref::<T>()).map(fun)
84: 82:         })
85: 83:         .flatten()
86: 84:     }
87: 85: 
88: 86:     fn try_with_mut<U>(
89: 87:         node: NodeId,
90: 88:         fun: impl FnOnce(&mut T) -> U,
91: 89:     ) -> Option<U> {
92: 90:         Arena::try_with_mut(|arena| {
93: 91:             let m = arena.get_mut(node);
94: 92:             m.and_then(|n| n.downcast_mut::<T>()).map(fun)
95: 93:         })
96: 94:         .flatten()
97: 95:     }
98: 96: 
99: 97:     fn try_set(node: NodeId, value: T) -> Option<T> {
100: 98:         Arena::try_with_mut(|arena| {
101: 99:             let m = arena.get_mut(node);
102: 100:             match m.and_then(|n| n.downcast_mut::<T>()) {
103: 101:                 Some(inner) => {
104: 102:                     *inner = value;
105: 103:                     None
106: 104:                 }
107: 105:                 None => Some(value),
108: 106:             }
109: 107:         })
110: 108:         .flatten()
111: 109:     }
112: 110: 
113: 111:     fn take(node: NodeId) -> Option<T> {
114: 112:         Arena::with_mut(|arena| {
115: 113:             let m = arena.remove(node)?;
116: 114:             match m.downcast::<T>() {
117: 115:                 Ok(inner) => Some(*inner),
118: 116:                 Err(_) => None,
119: 117:             }
120: 118:         })
121: 119:     }
122: 120: }
123: 121: 
124: 122: /// A form of [`Storage`] that stores the type with a wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper that makes it `Send + Sync`, but only
125: 123: /// allows it to be accessed from the thread on which it was created.
126: 124: #[derive(Debug, Copy, Clone)]
127: 125: pub struct LocalStorage;
128: 126: 
129: 127: impl<T> Storage<T> for LocalStorage
130: 128: where
131: 129:     T: 'static,
132: 130: {
133: 131:     type Wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apped = SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper<T>;
134: 132: 
135: 133:     fn wrap(value: T) -> Self::Wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apped {
136: 134:         SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper::new(value)
137: 135:     }
138: 136: 
139: 137:     fn try_with<U>(node: NodeId, fun: impl FnOnce(&T) -> U) -> Option<U> {
140: 138:         Arena::with(|arena| {
141: 139:             let m = arena.get(node);
142: 140:             m.and_then(|n| n.downcast_ref::<SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper<T>>())
143: 141:                 .map(|inner| fun(inner))
144: 142:         })
145: 143:     }
146: 144: 
147: 145:     fn try_with_mut<U>(
148: 146:         node: NodeId,
149: 147:         fun: impl FnOnce(&mut T) -> U,
150: 148:     ) -> Option<U> {
151: 149:         Arena::with_mut(|arena| {
152: 150:             let m = arena.get_mut(node);
153: 151:             m.and_then(|n| n.downcast_mut::<SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper<T>>())
154: 152:                 .map(|inner| fun(&mut *inner))
155: 153:         })
156: 154:     }
157: 155: 
158: 156:     fn try_set(node: NodeId, value: T) -> Option<T> {
159: 157:         Arena::with_mut(|arena| {
160: 158:             let m = arena.get_mut(node);
161: 159:             match m.and_then(|n| n.downcast_mut::<SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper<T>>()) {
162: 160:                 Some(inner) => {
163: 161:                     *inner = SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper::new(value);
164: 162:                     None
165: 163:                 }
166: 164:                 None => Some(value),
167: 165:             }
168: 166:         })
169: 167:     }
170: 168: 
171: 169:     fn take(node: NodeId) -> Option<T> {
172: 170:         Arena::with_mut(|arena| {
173: 171:             let m = arena.remove(node)?;
174: 172:             match m.downcast::<SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper<T>>() {
175: 173:                 Ok(inner) => Some(inner.take()),
176: 174:                 Err(_) => None,
177: 175:             }
178: 176:         })
179: 177:     }
180: 178: }
181: ```
```
