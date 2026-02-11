### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_reactive_stores\src\path.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_reactive_stores\src\path.rs
2: ```rust
3: 1: /// The path of a field within some store.
4: 2: #[derive(Clone, Debug, Default, PartialEq, Eq, Hash)]
5: 3: pub struct StorePath(Vec<StorePathSegment>);
6: 4: 
7: 5: impl IntoIterator for StorePath {
8: 6:     type Item = StorePathSegment;
9: 7:     type IntoIter = std::vec::IntoIter<StorePathSegment>;
10: 8: 
11: 9:     fn into_iter(self) -> Self::IntoIter {
12: 10:         self.0.into_iter()
13: 11:     }
14: 12: }
15: 13: 
16: 14: impl<'a> IntoIterator for &'a StorePath {
17: 15:     type Item = &'a StorePathSegment;
18: 16:     type IntoIter = std::slice::Iter<'a, StorePathSegment>;
19: 17: 
20: 18:     fn into_iter(self) -> Self::IntoIter {
21: 19:         self.0.iter()
22: 20:     }
23: 21: }
24: 22: 
25: 23: impl From<Vec<StorePathSegment>> for StorePath {
26: 24:     fn from(value: Vec<StorePathSegment>) -> Self {
27: 25:         Self(value)
28: 26:     }
29: 27: }
30: 28: 
31: 29: impl StorePath {
32: 30:     /// Creates a new path.
33: 31:     pub fn new() -> Self {
34: 32:         Self(Vec::new())
35: 33:     }
36: 34: 
37: 35:     /// Creates a new path with storage capacity for `capacity` segments.
38: 36:     pub fn with_capacity(capacity: usize) -> Self {
39: 37:         Self(Vec::with_capacity(capacity))
40: 38:     }
41: 39: 
42: 40:     /// Adds a new segment to the path.
43: 41:     pub fn push(&mut self, segment: impl Into<StorePathSegment>) {
44: 42:         self.0.push(segment.into());
45: 43:     }
46: 44: 
47: 45:     /// Removes a segment from the path and returns it.
48: 46:     pub fn pop(&mut self) -> Option<StorePathSegment> {
49: 47:         self.0.pop()
50: 48:     }
51: 49: 
52: 50:     /// Updates the last segment in the place in place.
53: 51:     pub fn replace_last(&mut self, segment: impl Into<StorePathSegment>) {
54: 52:         if let Some(last) = self.0.last_mut() {
55: 53:             *last = segment.into();
56: 54:         }
57: 55:     }
58: 56: 
59: 57:     /// Returns `true` if the path contains no elements.
60: 58:     pub fn is_empty(&self) -> bool {
61: 59:         self.0.is_empty()
62: 60:     }
63: 61: 
64: 62:     /// Returns the number of elements in the path.
65: 63:     pub fn len(&self) -> usize {
66: 64:         self.0.len()
67: 65:     }
68: 66: }
69: 67: 
70: 68: /// One segment of a [`StorePath`].
71: 69: #[derive(Copy, Clone, Debug, PartialEq, Eq, Hash)]
72: 70: pub struct StorePathSegment(pub(crate) usize);
73: 71: 
74: 72: impl From<usize> for StorePathSegment {
75: 73:     fn from(value: usize) -> Self {
76: 74:         Self(value)
77: 75:     }
78: 76: }
79: 77: 
80: 78: impl From<&usize> for StorePathSegment {
81: 79:     fn from(value: &usize) -> Self {
82: 80:         Self(*value)
83: 81:     }
84: 82: }
85: 83: 
86: 84: impl FromIterator<StorePathSegment> for StorePath {
87: 85:     fn from_iter<T: IntoIterator<Item = StorePathSegment>>(iter: T) -> Self {
88: 86:         Self(Vec::from_iter(iter))
89: 87:     }
90: 88: }
91: ```
```
