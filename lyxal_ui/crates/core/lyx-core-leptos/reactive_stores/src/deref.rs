### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_reactive_stores\src\deref.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_reactive_stores\src\deref.rs
2: ```rust
3: 1: use crate::{
4: 2:     path::{StorePath, StorePathSegment},
5: 3:     store_field::StoreField,
6: 4:     KeyMap, StoreFieldTrigger,
7: 5: };
8: 6: use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::{
9: 7:     signal::guards::{Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_apped, Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedMut},
10: 8:     traits::{
11: 9:         DefinedAt, IsDisposed, Notify, ReadUntracked, Track, UntrackableGuard,
12: 10:         Write,
13: 11:     },
14: 12: };
15: 13: use std::{
16: 14:     ops::{Deref, DerefMut},
17: 15:     panic::Location,
18: 16: };
19: 17: 
20: 18: /// Maps a store field that is a smart pointer to a subfield of the dereferenced inner type.
21: 19: pub trait DerefField
22: 20: where
23: 21:     Self: StoreField,
24: 22:     Self::Value: Deref + DerefMut,
25: 23:     <Self::Value as Deref>::Target: Sized + 'static,
26: 24: {
27: 25:     /// Returns a new store field with the value mlyx-platform-lyx_platform_lyx-platform-lyx_platform_apped to the target type of dereferencing this
28: 26:     /// field
29: 27:     ///
30: 28:     /// For lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_example, if you have a store field with a `Box<T>`, `.deref_field()` will return a
31: 29:     /// new store field containing a `T`.
32: 30:     fn deref_field(self) -> DerefedField<Self>;
33: 31: }
34: 32: 
35: 33: impl<S> DerefField for S
36: 34: where
37: 35:     S: StoreField,
38: 36:     S::Value: Deref + DerefMut,
39: 37:     <S::Value as Deref>::Target: Sized + 'static,
40: 38: {
41: 39:     #[track_caller]
42: 40:     fn deref_field(self) -> DerefedField<Self> {
43: 41:         DerefedField {
44: 42:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
45: 43:             defined_at: Location::caller(),
46: 44:             inner: self,
47: 45:         }
48: 46:     }
49: 47: }
50: 48: 
51: 49: /// A wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper from a store field containing a smart pointer to a store field containing the
52: 50: /// dereferenced target type of that smart pointer.
53: 51: #[derive(Debug, Copy, Clone)]
54: 52: pub struct DerefedField<S> {
55: 53:     inner: S,
56: 54:     #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
57: 55:     defined_at: &'static Location<'static>,
58: 56: }
59: 57: 
60: 58: impl<S> StoreField for DerefedField<S>
61: 59: where
62: 60:     S: StoreField,
63: 61:     S::Value: Deref + DerefMut,
64: 62:     <S::Value as Deref>::Target: Sized + 'static,
65: 63: {
66: 64:     type Value = <S::Value as Deref>::Target;
67: 65:     type Reader = Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_apped<S::Reader, Self::Value>;
68: 66:     type Writer = Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedMut<S::Writer, Self::Value>;
69: 67: 
70: 68:     fn get_trigger(&self, path: StorePath) -> StoreFieldTrigger {
71: 69:         self.inner.get_trigger(path)
72: 70:     }
73: 71: 
74: 72:     fn get_trigger_unkeyed(&self, path: StorePath) -> StoreFieldTrigger {
75: 73:         self.inner.get_trigger_unkeyed(path)
76: 74:     }
77: 75: 
78: 76:     fn path(&self) -> impl IntoIterator<Item = StorePathSegment> {
79: 77:         self.inner.path()
80: 78:     }
81: 79: 
82: 80:     fn path_unkeyed(&self) -> impl IntoIterator<Item = StorePathSegment> {
83: 81:         self.inner.path_unkeyed()
84: 82:     }
85: 83: 
86: 84:     fn reader(&self) -> Option<Self::Reader> {
87: 85:         let inner = self.inner.reader()?;
88: 86:         Some(Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_apped::new_with_guard(inner, |n| n.deref()))
89: 87:     }
90: 88:     fn writer(&self) -> Option<Self::Writer> {
91: 89:         let inner = self.inner.writer()?;
92: 90:         Some(Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedMut::new(inner, |n| n.deref(), |n| n.deref_mut()))
93: 91:     }
94: 92:     #[inline(always)]
95: 93:     fn keys(&self) -> Option<KeyMap> {
96: 94:         self.inner.keys()
97: 95:     }
98: 96: }
99: 97: 
100: 98: impl<S> DefinedAt for DerefedField<S>
101: 99: where
102: 100:     S: StoreField,
103: 101:     S::Value: Deref + DerefMut,
104: 102:     <S::Value as Deref>::Target: Sized + 'static,
105: 103: {
106: 104:     fn defined_at(&self) -> Option<&'static Location<'static>> {
107: 105:         #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
108: 106:         {
109: 107:             Some(self.defined_at)
110: 108:         }
111: 109:         #[cfg(not(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo)))]
112: 110:         {
113: 111:             None
114: 112:         }
115: 113:     }
116: 114: }
117: 115: impl<S> IsDisposed for DerefedField<S>
118: 116: where
119: 117:     S: IsDisposed,
120: 118: {
121: 119:     fn is_disposed(&self) -> bool {
122: 120:         self.inner.is_disposed()
123: 121:     }
124: 122: }
125: 123: impl<S> Notify for DerefedField<S>
126: 124: where
127: 125:     S: StoreField,
128: 126:     S::Value: Deref + DerefMut,
129: 127:     <S::Value as Deref>::Target: Sized + 'static,
130: 128: {
131: 129:     fn notify(&self) {
132: 130:         let trigger = self.get_trigger(self.path().into_iter().collect());
133: 131:         trigger.this.notify();
134: 132:         trigger.children.notify();
135: 133:     }
136: 134: }
137: 135: impl<S> Track for DerefedField<S>
138: 136: where
139: 137:     S: StoreField,
140: 138:     S::Value: Deref + DerefMut,
141: 139:     <S::Value as Deref>::Target: Sized + 'static,
142: 140: {
143: 141:     fn track(&self) {
144: 142:         self.track_field();
145: 143:     }
146: 144: }
147: 145: impl<S> ReadUntracked for DerefedField<S>
148: 146: where
149: 147:     S: StoreField,
150: 148:     S::Value: Deref + DerefMut,
151: 149:     <S::Value as Deref>::Target: Sized + 'static,
152: 150: {
153: 151:     type Value = <Self as StoreField>::Reader;
154: 152:     fn try_read_untracked(&self) -> Option<Self::Value> {
155: 153:         self.reader()
156: 154:     }
157: 155: }
158: 156: impl<S> Write for DerefedField<S>
159: 157: where
160: 158:     S: StoreField,
161: 159:     S::Value: Deref + DerefMut,
162: 160:     <S::Value as Deref>::Target: Sized + 'static,
163: 161: {
164: 162:     type Value = <S::Value as Deref>::Target;
165: 163: 
166: 164:     fn try_write(&self) -> Option<impl UntrackableGuard<Target = Self::Value>> {
167: 165:         self.writer()
168: 166:     }
169: 167:     fn try_write_untracked(
170: 168:         &self,
171: 169:     ) -> Option<impl DerefMut<Target = Self::Value>> {
172: 170:         self.writer().map(|mut writer| {
173: 171:             writer.untrack();
174: 172:             writer
175: 173:         })
176: 174:     }
177: 175: }
178: ```
```
