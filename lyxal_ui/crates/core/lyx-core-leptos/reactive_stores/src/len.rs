### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_reactive_stores\src\len.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_reactive_stores\src\len.rs
2: ```rust
3: 1: use std::{
4: 2:     borrow::Cow,
5: 3:     collections::{LinkedList, VecDeque},
6: 4: };
7: 5: 
8: 6: /// A trait for getting the length of a collection.
9: 7: pub trait Len {
10: 8:     /// Returns the length of the collection.
11: 9:     fn len(&self) -> usize;
12: 10: 
13: 11:     /// Returns true if the collection is empty
14: 12:     #[inline(always)]
15: 13:     fn is_empty(&self) -> bool {
16: 14:         self.len() == 0
17: 15:     }
18: 16: }
19: 17: 
20: 18: macro_rules! delegate_impl_len {
21: 19:     (<$($lt: lifetime,)*$($generics: ident,)*> $ty:ty) => {
22: 20:         impl<$($lt,)*$($generics,)*> Len for $ty {
23: 21:             #[inline(always)]
24: 22:             fn len(&self) -> usize {
25: 23:                 <$ty>::len(self)
26: 24:             }
27: 25: 
28: 26:             #[inline(always)]
29: 27:             fn is_empty(&self) -> bool {
30: 28:                 <$ty>::is_empty(self)
31: 29:             }
32: 30:         }
33: 31: 
34: 32:         impl<$($lt,)*$($generics,)*> Len for &$ty {
35: 33:             #[inline(always)]
36: 34:             fn len(&self) -> usize {
37: 35:                 Len::len(*self)
38: 36:             }
39: 37: 
40: 38:             #[inline(always)]
41: 39:             fn is_empty(&self) -> bool {
42: 40:                 Len::is_empty(*self)
43: 41:             }
44: 42:         }
45: 43: 
46: 44:         impl<$($lt,)*$($generics,)*> Len for &mut $ty {
47: 45:             #[inline(always)]
48: 46:             fn len(&self) -> usize {
49: 47:                 Len::len(*self)
50: 48:             }
51: 49: 
52: 50:             #[inline(always)]
53: 51:             fn is_empty(&self) -> bool {
54: 52:                 Len::is_empty(*self)
55: 53:             }
56: 54:         }
57: 55:     };
58: 56:     ($ty:ty) => {
59: 57:         delegate_impl_len!(<> $ty);
60: 58:     };
61: 59: }
62: 60: 
63: 61: delegate_impl_len!(<T,> [T]);
64: 62: delegate_impl_len!(<T,> Vec<T>);
65: 63: delegate_impl_len!(str);
66: 64: delegate_impl_len!(String);
67: 65: 
68: 66: impl Len for Cow<'_, str> {
69: 67:     #[inline(always)]
70: 68:     fn len(&self) -> usize {
71: 69:         <str>::len(self)
72: 70:     }
73: 71: 
74: 72:     #[inline(always)]
75: 73:     fn is_empty(&self) -> bool {
76: 74:         <str>::is_empty(self)
77: 75:     }
78: 76: }
79: 77: 
80: 78: impl Len for &Cow<'_, str> {
81: 79:     #[inline(always)]
82: 80:     fn len(&self) -> usize {
83: 81:         Len::len(*self)
84: 82:     }
85: 83: 
86: 84:     #[inline(always)]
87: 85:     fn is_empty(&self) -> bool {
88: 86:         Len::is_empty(*self)
89: 87:     }
90: 88: }
91: 89: 
92: 90: impl Len for &mut Cow<'_, str> {
93: 91:     #[inline(always)]
94: 92:     fn len(&self) -> usize {
95: 93:         Len::len(*self)
96: 94:     }
97: 95: 
98: 96:     #[inline(always)]
99: 97:     fn is_empty(&self) -> bool {
100: 98:         Len::is_empty(*self)
101: 99:     }
102: 100: }
103: 101: 
104: 102: impl<T> Len for Cow<'_, [T]>
105: 103: where
106: 104:     [T]: ToOwned,
107: 105: {
108: 106:     #[inline(always)]
109: 107:     fn len(&self) -> usize {
110: 108:         <[T]>::len(self)
111: 109:     }
112: 110: 
113: 111:     #[inline(always)]
114: 112:     fn is_empty(&self) -> bool {
115: 113:         <[T]>::is_empty(self)
116: 114:     }
117: 115: }
118: 116: 
119: 117: impl<T> Len for &Cow<'_, [T]>
120: 118: where
121: 119:     [T]: ToOwned,
122: 120: {
123: 121:     #[inline(always)]
124: 122:     fn len(&self) -> usize {
125: 123:         Len::len(*self)
126: 124:     }
127: 125: 
128: 126:     #[inline(always)]
129: 127:     fn is_empty(&self) -> bool {
130: 128:         Len::is_empty(*self)
131: 129:     }
132: 130: }
133: 131: 
134: 132: impl<T> Len for &mut Cow<'_, [T]>
135: 133: where
136: 134:     [T]: ToOwned,
137: 135: {
138: 136:     #[inline(always)]
139: 137:     fn len(&self) -> usize {
140: 138:         Len::len(*self)
141: 139:     }
142: 140: 
143: 141:     #[inline(always)]
144: 142:     fn is_empty(&self) -> bool {
145: 143:         Len::is_empty(*self)
146: 144:     }
147: 145: }
148: 146: 
149: 147: impl<T> Len for VecDeque<T> {
150: 148:     #[inline(always)]
151: 149:     fn len(&self) -> usize {
152: 150:         <VecDeque<T>>::len(self)
153: 151:     }
154: 152: 
155: 153:     #[inline(always)]
156: 154:     fn is_empty(&self) -> bool {
157: 155:         <VecDeque<T>>::is_empty(self)
158: 156:     }
159: 157: }
160: 158: 
161: 159: impl<T> Len for &VecDeque<T> {
162: 160:     #[inline(always)]
163: 161:     fn len(&self) -> usize {
164: 162:         Len::len(*self)
165: 163:     }
166: 164: 
167: 165:     #[inline(always)]
168: 166:     fn is_empty(&self) -> bool {
169: 167:         Len::is_empty(*self)
170: 168:     }
171: 169: }
172: 170: 
173: 171: impl<T> Len for &mut VecDeque<T> {
174: 172:     #[inline(always)]
175: 173:     fn len(&self) -> usize {
176: 174:         Len::len(&**self)
177: 175:     }
178: 176: 
179: 177:     #[inline(always)]
180: 178:     fn is_empty(&self) -> bool {
181: 179:         Len::is_empty(*self)
182: 180:     }
183: 181: }
184: 182: 
185: 183: impl<T> Len for LinkedList<T> {
186: 184:     #[inline(always)]
187: 185:     fn len(&self) -> usize {
188: 186:         <LinkedList<T>>::len(self)
189: 187:     }
190: 188: 
191: 189:     #[inline(always)]
192: 190:     fn is_empty(&self) -> bool {
193: 191:         <LinkedList<T>>::is_empty(self)
194: 192:     }
195: 193: }
196: 194: 
197: 195: impl<T> Len for &LinkedList<T> {
198: 196:     #[inline(always)]
199: 197:     fn len(&self) -> usize {
200: 198:         Len::len(*self)
201: 199:     }
202: 200: 
203: 201:     #[inline(always)]
204: 202:     fn is_empty(&self) -> bool {
205: 203:         Len::is_empty(*self)
206: 204:     }
207: 205: }
208: 206: 
209: 207: impl<T> Len for &mut LinkedList<T> {
210: 208:     #[inline(always)]
211: 209:     fn len(&self) -> usize {
212: 210:         Len::len(&**self)
213: 211:     }
214: 212: 
215: 213:     #[inline(always)]
216: 214:     fn is_empty(&self) -> bool {
217: 215:         Len::is_empty(*self)
218: 216:     }
219: 217: }
220: ```
```
