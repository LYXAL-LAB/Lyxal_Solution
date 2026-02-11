### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_next_tuple\src\lib.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_next_tuple\src\lib.rs
2: ```rust
3: 1: //! Defines a trait that allows you to extend a tuple, by returning
4: 2: //! a new tuple with an element of an arbitrary type added.
5: 3: 
6: 4: #![no_std]
7: 5: #![allow(non_snake_case)]
8: 6: #![forbid(unsafe_code)]
9: 7: #![deny(missing_docs)]
10: 8: 
11: 9: /// Allows extending a tuple, or creating a new tuple, by adding the next value.
12: 10: pub trait NextTuple {
13: 11:     /// The type that will be returned by adding another value of type `Next` to the end of the current type.
14: 12:     type Output<Next>;
15: 13: 
16: 14:     /// Adds the next value and returns the result.
17: 15:     fn lyx-core-lyx_core_lyx-core-lyx_core_next_tuple<Next>(self, next: Next) -> Self::Output<Next>;
18: 16: }
19: 17: 
20: 18: macro_rules! impl_tuple_builder {
21: 19:     ($($ty:ident),*) => {
22: 20: 		impl<$($ty),*> NextTuple for ($($ty,)*) {
23: 21: 			type Output<Next> = ($($ty,)* Next);
24: 22: 
25: 23: 			fn lyx-core-lyx_core_lyx-core-lyx_core_next_tuple<Next>(self, next: Next) -> Self::Output<Next> {
26: 24: 				let ($($ty,)*) = self;
27: 25: 				($($ty,)* next)
28: 26: 			}
29: 27: 		}
30: 28:     };
31: 29: }
32: 30: 
33: 31: impl NextTuple for () {
34: 32:     type Output<Next> = (Next,);
35: 33: 
36: 34:     fn lyx-core-lyx_core_lyx-core-lyx_core_next_tuple<Next>(self, next: Next) -> Self::Output<Next> {
37: 35:         (next,)
38: 36:     }
39: 37: }
40: 38: 
41: 39: impl_tuple_builder!(A);
42: 40: impl_tuple_builder!(A, B);
43: 41: impl_tuple_builder!(A, B, C);
44: 42: impl_tuple_builder!(A, B, C, D);
45: 43: impl_tuple_builder!(A, B, C, D, E);
46: 44: impl_tuple_builder!(A, B, C, D, E, F);
47: 45: impl_tuple_builder!(A, B, C, D, E, F, G);
48: 46: impl_tuple_builder!(A, B, C, D, E, F, G, H);
49: 47: impl_tuple_builder!(A, B, C, D, E, F, G, H, I);
50: 48: impl_tuple_builder!(A, B, C, D, E, F, G, H, I, J);
51: 49: impl_tuple_builder!(A, B, C, D, E, F, G, H, I, J, K);
52: 50: impl_tuple_builder!(A, B, C, D, E, F, G, H, I, J, K, L);
53: 51: impl_tuple_builder!(A, B, C, D, E, F, G, H, I, J, K, L, M);
54: 52: impl_tuple_builder!(A, B, C, D, E, F, G, H, I, J, K, L, M, N);
55: 53: impl_tuple_builder!(A, B, C, D, E, F, G, H, I, J, K, L, M, N, O);
56: 54: impl_tuple_builder!(A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P);
57: 55: impl_tuple_builder!(A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q);
58: 56: impl_tuple_builder!(A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R);
59: 57: impl_tuple_builder!(A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S);
60: 58: impl_tuple_builder!(A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T);
61: 59: impl_tuple_builder!(
62: 60:     A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U
63: 61: );
64: 62: impl_tuple_builder!(
65: 63:     A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V
66: 64: );
67: 65: impl_tuple_builder!(
68: 66:     A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W
69: 67: );
70: 68: impl_tuple_builder!(
71: 69:     A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X
72: 70: );
73: 71: impl_tuple_builder!(
74: 72:     A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y
75: 73: );
76: 74: impl_tuple_builder!(
77: 75:     A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y,
78: 76:     Z
79: 77: );
80: ```
```
