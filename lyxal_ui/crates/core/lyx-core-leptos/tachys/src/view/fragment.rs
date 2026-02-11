### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_tachys\src\view\fragment.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\fragment.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\fragment.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\fragment.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\fragment.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\fragment.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\fragment.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\fragment.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\fragment.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\fragment.rs
18: 16: ```rust
19: 17: use super::{
20: 18:     any_view::{AnyView, IntoAny},
21: 19:     iterators::StaticVec,
22: 20: };
23: 21: use crate::html::element::HtmlElement;
24: 22: 
25: 23: /// A typed-erased collection of different views.
26: 24: pub struct Fragment {
27: 25:     /// The nodes contained in the fragment.
28: 26:     pub nodes: StaticVec<AnyView>,
29: 27: }
30: 28: 
31: 29: /// Converts some view into a type-erased collection of views.
32: 30: pub trait IntoFragment {
33: 31:     /// Converts some view into a type-erased collection of views.
34: 32:     fn into_fragment(self) -> Fragment;
35: 33: }
36: 34: 
37: 35: impl FromIterator<AnyView> for Fragment {
38: 36:     fn from_iter<T: IntoIterator<Item = AnyView>>(iter: T) -> Self {
39: 37:         Fragment::new(iter.into_iter().collect())
40: 38:     }
41: 39: }
42: 40: 
43: 41: impl From<AnyView> for Fragment {
44: 42:     fn from(view: AnyView) -> Self {
45: 43:         Fragment::new(vec![view])
46: 44:     }
47: 45: }
48: 46: 
49: 47: impl From<Fragment> for AnyView {
50: 48:     fn from(value: Fragment) -> Self {
51: 49:         value.nodes.into_any()
52: 50:     }
53: 51: }
54: 52: 
55: 53: impl Fragment {
56: 54:     /// Creates a new [`Fragment`].
57: 55:     #[inline(always)]
58: 56:     pub fn new(nodes: Vec<AnyView>) -> Self {
59: 57:         Self {
60: 58:             nodes: nodes.into(),
61: 59:         }
62: 60:     }
63: 61: }
64: 62: 
65: 63: impl<E, At, Ch> IntoFragment for HtmlElement<E, At, Ch>
66: 64: where
67: 65:     HtmlElement<E, At, Ch>: IntoAny,
68: 66: {
69: 67:     fn into_fragment(self) -> Fragment {
70: 68:         Fragment::new(vec![self.into_any()])
71: 69:     }
72: 70: }
73: 71: 
74: 72: impl IntoFragment for AnyView {
75: 73:     fn into_fragment(self) -> Fragment {
76: 74:         Fragment::new(vec![self])
77: 75:     }
78: 76: }
79: 77: 
80: 78: impl<T> IntoFragment for Vec<T>
81: 79: where
82: 80:     T: IntoAny,
83: 81: {
84: 82:     fn into_fragment(self) -> Fragment {
85: 83:         Fragment::new(self.into_iter().map(IntoAny::into_any).collect())
86: 84:     }
87: 85: }
88: 86: 
89: 87: impl<T> IntoFragment for StaticVec<T>
90: 88: where
91: 89:     T: IntoAny,
92: 90: {
93: 91:     fn into_fragment(self) -> Fragment {
94: 92:         Fragment::new(self.into_iter().map(IntoAny::into_any).collect())
95: 93:     }
96: 94: }
97: 95: 
98: 96: impl<const N: usize, T> IntoFragment for [T; N]
99: 97: where
100: 98:     T: IntoAny,
101: 99: {
102: 100:     fn into_fragment(self) -> Fragment {
103: 101:         Fragment::new(self.into_iter().map(IntoAny::into_any).collect())
104: 102:     }
105: 103: }
106: 104: 
107: 105: macro_rules! tuples {
108: 106: 	($($ty:ident),*) => {
109: 107: 		impl<$($ty),*> IntoFragment for ($($ty,)*)
110: 108: 		where
111: 109: 			$($ty: IntoAny),*,
112: 110: 
113: 111: 		{
114: 112:             fn into_fragment(self) -> Fragment {
115: 113:                 #[allow(non_snake_case)]
116: 114: 			    let ($($ty,)*) = self;
117: 115:                 Fragment::new(vec![$($ty.into_any(),)*])
118: 116:             }
119: 117:         }
120: 118:     }
121: 119: }
122: 120: 
123: 121: tuples!(A);
124: 122: tuples!(A, B);
125: 123: tuples!(A, B, C);
126: 124: tuples!(A, B, C, D);
127: 125: tuples!(A, B, C, D, E);
128: 126: tuples!(A, B, C, D, E, F);
129: 127: tuples!(A, B, C, D, E, F, G);
130: 128: tuples!(A, B, C, D, E, F, G, H);
131: 129: tuples!(A, B, C, D, E, F, G, H, I);
132: 130: tuples!(A, B, C, D, E, F, G, H, I, J);
133: 131: tuples!(A, B, C, D, E, F, G, H, I, J, K);
134: 132: tuples!(A, B, C, D, E, F, G, H, I, J, K, L);
135: 133: tuples!(A, B, C, D, E, F, G, H, I, J, K, L, M);
136: 134: tuples!(A, B, C, D, E, F, G, H, I, J, K, L, M, N);
137: 135: tuples!(A, B, C, D, E, F, G, H, I, J, K, L, M, N, O);
138: 136: tuples!(A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P);
139: 137: tuples!(A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q);
140: 138: tuples!(A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R);
141: 139: tuples!(A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S);
142: 140: tuples!(A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T);
143: 141: tuples!(A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U);
144: 142: tuples!(A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V);
145: 143: tuples!(A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W);
146: 144: tuples!(A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X);
147: 145: tuples!(
148: 146:     A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y
149: 147: );
150: 148: tuples!(
151: 149:     A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y,
152: 150:     Z
153: 151: );
154: 152: ```
155: 153: ```
156: 154: ```
157: 155: ```
158: 156: ```
159: 157: ```
160: 158: ```
161: 159: ```
162: ```
```
