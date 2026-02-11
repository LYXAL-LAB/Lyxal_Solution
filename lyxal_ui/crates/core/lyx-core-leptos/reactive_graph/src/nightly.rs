### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_reactive_graph\src\nightly.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\src\nightly.rs
2: ```rust
3: 1: #[allow(deprecated)]
4: 2: use crate::wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_appers::read::{MaybeProp, MaybeSignal};
5: 3: use crate::{
6: 4:     computed::{ArcMemo, Memo},
7: 5:     owner::Storage,
8: 6:     signal::{
9: 7:         ArcReadSignal, ArcRwSignal, ArcWriteSignal, ReadSignal, RwSignal,
10: 8:         WriteSignal,
11: 9:     },
12: 10:     traits::{Get, Set},
13: 11:     wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_appers::{
14: 12:         read::{ArcSignal, Signal, SignalTypes},
15: 13:         write::SignalSetter,
16: 14:     },
17: 15: };
18: 16: 
19: 17: macro_rules! impl_set_fn_traits {
20: 18:     ($($ty:ident),*) => {
21: 19:         $(
22: 20:             #[cfg(feature = "nightly")]
23: 21:             impl<T> FnOnce<(T,)> for $ty<T> where $ty<T>: Set<Value = T> {
24: 22:                 type Output = ();
25: 23: 
26: 24:                 #[inline(always)]
27: 25:                 extern "rust-call" fn call_once(self, args: (T,)) -> Self::Output {
28: 26:                     self.set(args.0);
29: 27:                 }
30: 28:             }
31: 29: 
32: 30:             #[cfg(feature = "nightly")]
33: 31:             impl<T> FnMut<(T,)> for $ty<T> where $ty<T>: Set<Value = T> {
34: 32:                 #[inline(always)]
35: 33:                 extern "rust-call" fn call_mut(&mut self, args: (T,)) -> Self::Output {
36: 34:                     self.set(args.0);
37: 35:                 }
38: 36:             }
39: 37: 
40: 38:             #[cfg(feature = "nightly")]
41: 39:             impl<T> Fn<(T,)> for $ty<T> where $ty<T>: Set<Value = T> {
42: 40:                 #[inline(always)]
43: 41:                 extern "rust-call" fn call(&self, args: (T,)) -> Self::Output {
44: 42:                     self.set(args.0);
45: 43:                 }
46: 44:             }
47: 45:         )*
48: 46:     };
49: 47: }
50: 48: 
51: 49: macro_rules! impl_set_fn_traits_arena {
52: 50:     ($($ty:ident),*) => {
53: 51:         $(
54: 52:             #[cfg(feature = "nightly")]
55: 53:             impl<T, S> FnOnce<(T,)> for $ty<T, S> where $ty<T, S>: Set<Value = T> {
56: 54:                 type Output = ();
57: 55: 
58: 56:                 #[inline(always)]
59: 57:                 extern "rust-call" fn call_once(self, args: (T,)) -> Self::Output {
60: 58:                     self.set(args.0);
61: 59:                 }
62: 60:             }
63: 61: 
64: 62:             #[cfg(feature = "nightly")]
65: 63:             impl<T, S> FnMut<(T,)> for $ty<T, S> where $ty<T, S>: Set<Value = T> {
66: 64:                 #[inline(always)]
67: 65:                 extern "rust-call" fn call_mut(&mut self, args: (T,)) -> Self::Output {
68: 66:                     self.set(args.0);
69: 67:                 }
70: 68:             }
71: 69: 
72: 70:             #[cfg(feature = "nightly")]
73: 71:             impl<T, S> Fn<(T,)> for $ty<T, S> where $ty<T, S>: Set<Value = T> {
74: 72:                 #[inline(always)]
75: 73:                 extern "rust-call" fn call(&self, args: (T,)) -> Self::Output {
76: 74:                     self.set(args.0);
77: 75:                 }
78: 76:             }
79: 77:         )*
80: 78:     };
81: 79: }
82: 80: 
83: 81: macro_rules! impl_get_fn_traits_get {
84: 82:     ($($ty:ident),*) => {
85: 83:         $(
86: 84:             #[cfg(feature = "nightly")]
87: 85:             impl<T> FnOnce<()> for $ty<T> where $ty<T>: Get {
88: 86:                 type Output = <Self as Get>::Value;
89: 87: 
90: 88:                 #[inline(always)]
91: 89:                 extern "rust-call" fn call_once(self, _args: ()) -> Self::Output {
92: 90:                     self.get()
93: 91:                 }
94: 92:             }
95: 93: 
96: 94:             #[cfg(feature = "nightly")]
97: 95:             impl<T> FnMut<()> for $ty<T> where $ty<T>: Get {
98: 96:                 #[inline(always)]
99: 97:                 extern "rust-call" fn call_mut(&mut self, _args: ()) -> Self::Output {
100: 98:                     self.get()
101: 99:                 }
102: 100:             }
103: 101: 
104: 102:             #[cfg(feature = "nightly")]
105: 103:             impl<T> Fn<()> for $ty<T> where $ty<T>: Get {
106: 104:                 #[inline(always)]
107: 105:                 extern "rust-call" fn call(&self, _args: ()) -> Self::Output {
108: 106:                     self.get()
109: 107:                 }
110: 108:             }
111: 109:         )*
112: 110:     };
113: 111: }
114: 112: 
115: 113: macro_rules! impl_get_fn_traits_get_arena {
116: 114:     ($($ty:ident),*) => {
117: 115:         $(
118: 116:             #[cfg(feature = "nightly")]
119: 117:             #[allow(deprecated)]
120: 118:             impl<T, S> FnOnce<()> for $ty<T, S> where $ty<T, S>: Get, S: Storage<T> + Storage<Option<T>> + Storage<SignalTypes<Option<T>, S>> {
121: 119:                 type Output = <Self as Get>::Value;
122: 120: 
123: 121:                 #[inline(always)]
124: 122:                 extern "rust-call" fn call_once(self, _args: ()) -> Self::Output {
125: 123:                     self.get()
126: 124:                 }
127: 125:             }
128: 126: 
129: 127:             #[cfg(feature = "nightly")]
130: 128:             #[allow(deprecated)]
131: 129:             impl<T, S> FnMut<()> for $ty<T, S> where $ty<T, S>: Get, S: Storage<T> + Storage<Option<T>> + Storage<SignalTypes<Option<T>, S>> {
132: 130:                 #[inline(always)]
133: 131:                 extern "rust-call" fn call_mut(&mut self, _args: ()) -> Self::Output {
134: 132:                     self.get()
135: 133:                 }
136: 134:             }
137: 135: 
138: 136:             #[cfg(feature = "nightly")]
139: 137:             #[allow(deprecated)]
140: 138:             impl<T, S> Fn<()> for $ty<T, S> where $ty<T, S>: Get, S: Storage<T> + Storage<Option<T>> + Storage<SignalTypes<Option<T>, S>> {
141: 139:                 #[inline(always)]
142: 140:                 extern "rust-call" fn call(&self, _args: ()) -> Self::Output {
143: 141:                     self.get()
144: 142:                 }
145: 143:             }
146: 144:         )*
147: 145:     };
148: 146: }
149: 147: 
150: 148: impl_get_fn_traits_get![ArcReadSignal, ArcRwSignal];
151: 149: impl_get_fn_traits_get_arena![
152: 150:     ReadSignal,
153: 151:     RwSignal,
154: 152:     ArcMemo,
155: 153:     ArcSignal,
156: 154:     Signal,
157: 155:     MaybeSignal,
158: 156:     Memo,
159: 157:     MaybeProp
160: 158: ];
161: 159: impl_set_fn_traits![ArcRwSignal, ArcWriteSignal];
162: 160: impl_set_fn_traits_arena![RwSignal, WriteSignal, SignalSetter];
163: ```
```
