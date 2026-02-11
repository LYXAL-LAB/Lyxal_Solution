### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_or_poisoned\src\lib.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned\src\lib.rs
2: ```rust
3: 1: //! Provides a simple trait that unwraps the locks provide by [`std::sync::RwLock`].
4: 2: //!
5: 3: //! In every case, this is the same as calling `.expect("lock poisoned")`. However, it
6: 4: //! does not use `.unwrap()` or `.expect()`, which makes it easier to distinguish from
7: 5: //! other forms of unwrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apping when reading code.
8: 6: //!
9: 7: //! ```rust
10: 8: //! use lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned::OrPoisoned;
11: 9: //! use std::sync::RwLock;
12: 10: //!
13: 11: //! let lock = RwLock::new(String::from("Hello!"));
14: 12: //!
15: 13: //! let read = lock.read().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned();
16: 14: //! // this is identical to
17: 15: //! let read = lock.read().unwrap();
18: 16: //! ```
19: 17: 
20: 18: #![forbid(unsafe_code)]
21: 19: #![deny(missing_docs)]
22: 20: 
23: 21: use std::sync::{
24: 22:     LockResult, MutexGuard, PoisonError, RwLockReadGuard, RwLockWriteGuard,
25: 23: };
26: 24: 
27: 25: /// Unwraps a lock.
28: 26: pub trait OrPoisoned {
29: 27:     /// The inner guard type.
30: 28:     type Inner;
31: 29: 
32: 30:     /// Unwraps the lock.
33: 31:     ///
34: 32:     /// ## Panics
35: 33:     ///
36: 34:     /// Will panic if the lock is poisoned.
37: 35:     fn lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned(self) -> Self::Inner;
38: 36: }
39: 37: 
40: 38: impl<'a, T: ?Sized> OrPoisoned
41: 39:     for Result<RwLockReadGuard<'a, T>, PoisonError<RwLockReadGuard<'a, T>>>
42: 40: {
43: 41:     type Inner = RwLockReadGuard<'a, T>;
44: 42: 
45: 43:     fn lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned(self) -> Self::Inner {
46: 44:         self.expect("lock poisoned")
47: 45:     }
48: 46: }
49: 47: 
50: 48: impl<'a, T: ?Sized> OrPoisoned
51: 49:     for Result<RwLockWriteGuard<'a, T>, PoisonError<RwLockWriteGuard<'a, T>>>
52: 50: {
53: 51:     type Inner = RwLockWriteGuard<'a, T>;
54: 52: 
55: 53:     fn lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned(self) -> Self::Inner {
56: 54:         self.expect("lock poisoned")
57: 55:     }
58: 56: }
59: 57: 
60: 58: impl<'a, T: ?Sized> OrPoisoned for LockResult<MutexGuard<'a, T>> {
61: 59:     type Inner = MutexGuard<'a, T>;
62: 60: 
63: 61:     fn lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned(self) -> Self::Inner {
64: 62:         self.expect("lock poisoned")
65: 63:     }
66: 64: }
67: ```
```
