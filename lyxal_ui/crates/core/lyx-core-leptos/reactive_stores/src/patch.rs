### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_reactive_stores\src\patch.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_reactive_stores\src\patch.rs
2: ```rust
3: 1: use crate::{path::StorePath, StoreField};
4: 2: use itertools::{EitherOrBoth, Itertools};
5: 3: use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::traits::{Notify, UntrackableGuard};
6: 4: use std::{
7: 5:     borrow::Cow,
8: 6:     net::{IpAddr, Ipv4Addr, Ipv6Addr, SocketAddr, SocketAddrV4, SocketAddrV6},
9: 7:     num::{
10: 8:         NonZeroI128, NonZeroI16, NonZeroI32, NonZeroI64, NonZeroI8,
11: 9:         NonZeroIsize, NonZeroU128, NonZeroU16, NonZeroU32, NonZeroU64,
12: 10:         NonZeroU8, NonZeroUsize,
13: 11:     },
14: 12:     rc::Rc,
15: 13:     sync::Arc,
16: 14: };
17: 15: 
18: 16: /// Allows updating a store or field in place with a new value.
19: 17: pub trait Patch {
20: 18:     /// The type of the new value.
21: 19:     type Value;
22: 20: 
23: 21:     /// Patches a store or field with a new value, only notifying fields that have changed.
24: 22:     fn patch(&self, new: Self::Value);
25: 23: }
26: 24: 
27: 25: impl<T> Patch for T
28: 26: where
29: 27:     T: StoreField,
30: 28:     T::Value: PatchField,
31: 29: {
32: 30:     type Value = T::Value;
33: 31: 
34: 32:     fn patch(&self, new: Self::Value) {
35: 33:         let path = self.path_unkeyed().into_iter().collect::<StorePath>();
36: 34:         if let Some(mut writer) = self.writer() {
37: 35:             // don't track the writer for the whole store
38: 36:             writer.untrack();
39: 37:             let mut notify = |path: &StorePath| {
40: 38:                 self.triggers_for_path_unkeyed(path.to_owned()).notify();
41: 39:             };
42: 40:             writer.patch_field(new, &path, &mut notify);
43: 41:         }
44: 42:     }
45: 43: }
46: 44: 
47: 45: /// Allows patching a store field with some new value.
48: 46: pub trait PatchField {
49: 47:     /// Patches the field with some new value, only notifying if the value has changed.
50: 48:     fn patch_field(
51: 49:         &mut self,
52: 50:         new: Self,
53: 51:         path: &StorePath,
54: 52:         notify: &mut dyn FnMut(&StorePath),
55: 53:     );
56: 54: }
57: 55: 
58: 56: macro_rules! patch_primitives {
59: 57:     ($($ty:ty),*) => {
60: 58:         $(impl PatchField for $ty {
61: 59:             fn patch_field(
62: 60:                 &mut self,
63: 61:                 new: Self,
64: 62:                 path: &StorePath,
65: 63:                 notify: &mut dyn FnMut(&StorePath),
66: 64:             ) {
67: 65:                 if new != *self {
68: 66:                     *self = new;
69: 67:                     notify(path);
70: 68:                 }
71: 69:             }
72: 70:         })*
73: 71:     };
74: 72: }
75: 73: 
76: 74: patch_primitives! {
77: 75:     &str,
78: 76:     String,
79: 77:     Arc<str>,
80: 78:     Rc<str>,
81: 79:     Cow<'_, str>,
82: 80:     usize,
83: 81:     u8,
84: 82:     u16,
85: 83:     u32,
86: 84:     u64,
87: 85:     u128,
88: 86:     isize,
89: 87:     i8,
90: 88:     i16,
91: 89:     i32,
92: 90:     i64,
93: 91:     i128,
94: 92:     f32,
95: 93:     f64,
96: 94:     char,
97: 95:     bool,
98: 96:     IpAddr,
99: 97:     SocketAddr,
100: 98:     SocketAddrV4,
101: 99:     SocketAddrV6,
102: 100:     Ipv4Addr,
103: 101:     Ipv6Addr,
104: 102:     NonZeroI8,
105: 103:     NonZeroU8,
106: 104:     NonZeroI16,
107: 105:     NonZeroU16,
108: 106:     NonZeroI32,
109: 107:     NonZeroU32,
110: 108:     NonZeroI64,
111: 109:     NonZeroU64,
112: 110:     NonZeroI128,
113: 111:     NonZeroU128,
114: 112:     NonZeroIsize,
115: 113:     NonZeroUsize
116: 114: }
117: 115: 
118: 116: impl<T> PatchField for Option<T>
119: 117: where
120: 118:     T: PatchField,
121: 119: {
122: 120:     fn patch_field(
123: 121:         &mut self,
124: 122:         new: Self,
125: 123:         path: &StorePath,
126: 124:         notify: &mut dyn FnMut(&StorePath),
127: 125:     ) {
128: 126:         match (self, new) {
129: 127:             (None, None) => {}
130: 128:             (old @ Some(_), None) => {
131: 129:                 old.take();
132: 130:                 notify(path);
133: 131:             }
134: 132:             (old @ None, new @ Some(_)) => {
135: 133:                 *old = new;
136: 134:                 notify(path);
137: 135:             }
138: 136:             (Some(old), Some(new)) => {
139: 137:                 let mut new_path = path.to_owned();
140: 138:                 new_path.push(0);
141: 139:                 old.patch_field(new, &new_path, notify);
142: 140:             }
143: 141:         }
144: 142:     }
145: 143: }
146: 144: 
147: 145: impl<T> PatchField for Vec<T>
148: 146: where
149: 147:     T: PatchField,
150: 148: {
151: 149:     fn patch_field(
152: 150:         &mut self,
153: 151:         new: Self,
154: 152:         path: &StorePath,
155: 153:         notify: &mut dyn FnMut(&StorePath),
156: 154:     ) {
157: 155:         if self.is_empty() && new.is_empty() {
158: 156:             return;
159: 157:         }
160: 158: 
161: 159:         if new.is_empty() {
162: 160:             self.clear();
163: 161:             notify(path);
164: 162:         } else if self.is_empty() {
165: 163:             self.extend(new);
166: 164:             notify(path);
167: 165:         } else {
168: 166:             let mut adds = vec![];
169: 167:             let mut removes_at_end = 0;
170: 168:             let mut new_path = path.to_owned();
171: 169:             new_path.push(0);
172: 170:             for (idx, item) in
173: 171:                 new.into_iter().zip_longest(self.iter_mut()).enumerate()
174: 172:             {
175: 173:                 match item {
176: 174:                     EitherOrBoth::Both(new, old) => {
177: 175:                         old.patch_field(new, &new_path, notify);
178: 176:                     }
179: 177:                     EitherOrBoth::Left(new) => {
180: 178:                         adds.push(new);
181: 179:                     }
182: 180:                     EitherOrBoth::Right(_) => {
183: 181:                         removes_at_end += 1;
184: 182:                     }
185: 183:                 }
186: 184:                 new_path.replace_last(idx + 1);
187: 185:             }
188: 186: 
189: 187:             let length_changed = removes_at_end > 0 || !adds.is_empty();
190: 188:             self.truncate(self.len() - removes_at_end);
191: 189:             self.lyx-platform-lyx_platform_lyx-platform-lyx_platform_append(&mut adds);
192: 190: 
193: 191:             if length_changed {
194: 192:                 notify(path);
195: 193:             }
196: 194:         }
197: 195:     }
198: 196: }
199: 197: 
200: 198: macro_rules! patch_tuple {
201: 199: 	($($ty:ident),*) => {
202: 200: 		impl<$($ty),*> PatchField for ($($ty,)*)
203: 201: 		where
204: 202: 			$($ty: PatchField),*,
205: 203: 		{
206: 204:             fn patch_field(
207: 205:                 &mut self,
208: 206:                 new: Self,
209: 207:                 path: &StorePath,
210: 208:                 notify: &mut dyn FnMut(&StorePath),
211: 209:             ) {
212: 210:                 let mut idx = 0;
213: 211:                 let mut new_path = path.to_owned();
214: 212:                 new_path.push(0);
215: 213: 
216: 214:                 paste::paste! {
217: 215:                     #[allow(non_snake_case)]
218: 216:                     let ($($ty,)*) = self;
219: 217:                     let ($([<new_ $ty:lower>],)*) = new;
220: 218:                     $(
221: 219:                         $ty.patch_field([<new_ $ty:lower>], &new_path, notify);
222: 220:                         idx += 1;
223: 221:                         new_path.replace_last(idx);
224: 222:                     )*
225: 223:                 }
226: 224:             }
227: 225:         }
228: 226:     }
229: 227: }
230: 228: 
231: 229: impl PatchField for () {
232: 230:     fn patch_field(
233: 231:         &mut self,
234: 232:         _new: Self,
235: 233:         _path: &StorePath,
236: 234:         _notify: &mut dyn FnMut(&StorePath),
237: 235:     ) {
238: 236:     }
239: 237: }
240: 238: 
241: 239: patch_tuple!(A);
242: 240: patch_tuple!(A, B);
243: 241: patch_tuple!(A, B, C);
244: 242: patch_tuple!(A, B, C, D);
245: 243: patch_tuple!(A, B, C, D, E);
246: 244: patch_tuple!(A, B, C, D, E, F);
247: 245: patch_tuple!(A, B, C, D, E, F, G);
248: 246: patch_tuple!(A, B, C, D, E, F, G, H);
249: 247: patch_tuple!(A, B, C, D, E, F, G, H, I);
250: 248: patch_tuple!(A, B, C, D, E, F, G, H, I, J);
251: 249: patch_tuple!(A, B, C, D, E, F, G, H, I, J, K);
252: 250: patch_tuple!(A, B, C, D, E, F, G, H, I, J, K, L);
253: 251: patch_tuple!(A, B, C, D, E, F, G, H, I, J, K, L, M);
254: 252: patch_tuple!(A, B, C, D, E, F, G, H, I, J, K, L, M, N);
255: 253: patch_tuple!(A, B, C, D, E, F, G, H, I, J, K, L, M, N, O);
256: 254: patch_tuple!(A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P);
257: 255: patch_tuple!(A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q);
258: 256: patch_tuple!(A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R);
259: 257: patch_tuple!(A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S);
260: 258: patch_tuple!(A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T);
261: 259: patch_tuple!(A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U);
262: 260: patch_tuple!(A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V);
263: 261: patch_tuple!(
264: 262:     A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W
265: 263: );
266: 264: patch_tuple!(
267: 265:     A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X
268: 266: );
269: 267: patch_tuple!(
270: 268:     A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y
271: 269: );
272: 270: patch_tuple!(
273: 271:     A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y,
274: 272:     Z
275: 273: );
276: ```
```
