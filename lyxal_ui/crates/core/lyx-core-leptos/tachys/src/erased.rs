### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_tachys\src\erased.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\erased.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\erased.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\erased.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\erased.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\erased.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\erased.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\erased.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\erased.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\erased.rs
18: 16: ```rust
19: 17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\erased.rs
20: 18: ```rust
21: 19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\erased.rs
22: 20: ```rust
23: 21: use erased::ErasedBox;
24: 22: 
25: 23: #[cfg(not(erase_components))]
26: 24: fn check(id_1: &std::any::TypeId, id_2: &std::any::TypeId) {
27: 25:     if id_1 != id_2 {
28: 26:         panic!("Erased: type mismatch")
29: 27:     }
30: 28: }
31: 29: 
32: 30: macro_rules! erased {
33: 31:     ([$($new_t_params:tt)*], $name:ident) => {
34: 32:         /// A type-erased item. This is slightly more efficient than using `Box<dyn Any (+ Send)>`.
35: 33:         ///
36: 34:         /// With the caveat that T must always be correct upon retrieval.
37: 35:         /// In erased mode T retrieval is unchecked to minimise codegen, in other modes T will be verified and a panic otherwise.
38: 36:         pub struct $name {
39: 37:             #[cfg(not(erase_components))]
40: 38:             type_id: std::any::TypeId,
41: 39:             value: Option<ErasedBox>,
42: 40:             drop: fn(ErasedBox),
43: 41:         }
44: 42: 
45: 43: 
46: 44:         impl $name {
47: 45:             /// Create a new type-erased item.
48: 46:             pub fn new<T: $($new_t_params)*>(item: T) -> Self {
49: 47:                 Self {
50: 48:                     #[cfg(not(erase_components))]
51: 49:                     type_id: std::any::TypeId::of::<T>(),
52: 50:                     value: Some(ErasedBox::new(Box::new(item))),
53: 51:                     drop: |value| {
54: 52:                         let _ = unsafe { value.into_inner::<T>() };
55: 53:                     },
56: 54:                 }
57: 55:             }
58: 56: 
59: 57:             /// Get a reference to the inner value.
60: 58:             pub fn get_ref<T: 'static>(&self) -> &T {
61: 59:                 #[cfg(not(erase_components))]
62: 60:                 check(&self.type_id, &std::any::TypeId::of::<T>());
63: 61:                 unsafe { self.value.as_ref().unwrap().get_ref::<T>() }
64: 62:             }
65: 63: 
66: 64:             /// Get a mutable reference to the inner value.
67: 65:             pub fn get_mut<T: 'static>(&mut self) -> &mut T {
68: 66:                 #[cfg(not(erase_components))]
69: 67:                 check(&self.type_id, &std::any::TypeId::of::<T>());
70: 68:                 unsafe { self.value.as_mut().unwrap().get_mut::<T>() }
71: 69:             }
72: 70: 
73: 71:             /// Consume the item and return the inner value.
74: 72:             pub fn into_inner<T: 'static>(mut self) -> T {
75: 73:                 #[cfg(not(erase_components))]
76: 74:                 check(&self.type_id, &std::any::TypeId::of::<T>());
77: 75:                 *unsafe { self.value.take().unwrap().into_inner::<T>() }
78: 76:             }
79: 77:         }
80: 78: 
81: 79:         /// If into_inner() wasn't called, the value would leak and destructors wouldn't run, this prevents that from hlyx-platform-lyx_platform_lyx-platform-lyx_platform_appening.
82: 80:         impl Drop for $name {
83: 81:             fn drop(&mut self) {
84: 82:                 if let Some(value) = self.value.take() {
85: 83:                     (self.drop)(value);
86: 84:                 }
87: 85:             }
88: 86:         }
89: 87:     };
90: 88: 
91: 89: }
92: 90: 
93: 91: erased!([Send + 'static], Erased);
94: 92: erased!(['static], ErasedLocal);
95: 93: 
96: 94: /// SAFETY: `Erased::new` ensures that `T` is `Send` and `'static`.
97: 95: unsafe impl Send for Erased {}
98: 96: ```
99: 97: ```
100: 98: ```
101: 99: ```
102: 100: ```
103: 101: ```
104: 102: ```
105: 103: ```
106: 104: ```
107: 105: ```
108: ```
```
