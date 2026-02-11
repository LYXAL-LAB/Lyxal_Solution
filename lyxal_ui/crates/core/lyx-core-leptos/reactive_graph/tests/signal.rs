### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_reactive_graph\tests\signal.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\tests\signal.rs
2: ```rust
3: 1: use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::{
4: 2:     owner::Owner,
5: 3:     signal::{arc_signal, signal, ArcRwSignal, RwSignal},
6: 4:     traits::{
7: 5:         Dispose, Get, GetUntracked, IntoInner, Read, Set, Update,
8: 6:         UpdateUntracked, With, WithUntracked, Write,
9: 7:     },
10: 8: };
11: 9: 
12: 10: #[test]
13: 11: fn create_arc_rw_signal() {
14: 12:     let a = ArcRwSignal::new(0);
15: 13:     assert_eq!(a.read(), 0);
16: 14:     assert_eq!(a.get(), 0);
17: 15:     assert_eq!(a.get_untracked(), 0);
18: 16:     assert_eq!(a.with_untracked(|n| n + 1), 1);
19: 17:     assert_eq!(a.with(|n| n + 1), 1);
20: 18:     assert_eq!(format!("{}", a.read()), "0");
21: 19: }
22: 20: 
23: 21: #[test]
24: 22: fn update_arc_rw_signal() {
25: 23:     let a = ArcRwSignal::new(0);
26: 24:     *a.write() += 1;
27: 25:     assert_eq!(a.get(), 1);
28: 26:     a.update(|n| *n += 1);
29: 27:     assert_eq!(a.get(), 2);
30: 28:     a.update_untracked(|n| *n += 1);
31: 29:     assert_eq!(a.get(), 3);
32: 30:     a.set(4);
33: 31:     assert_eq!(a.get(), 4);
34: 32: }
35: 33: 
36: 34: #[test]
37: 35: fn create_arc_signal() {
38: 36:     let (a, _) = arc_signal(0);
39: 37:     assert_eq!(a.read(), 0);
40: 38:     assert_eq!(a.get(), 0);
41: 39:     assert_eq!(a.with_untracked(|n| n + 1), 1);
42: 40:     assert_eq!(a.with(|n| n + 1), 1);
43: 41: }
44: 42: 
45: 43: #[test]
46: 44: fn update_arc_signal() {
47: 45:     let (a, set_a) = arc_signal(0);
48: 46:     *set_a.write() += 1;
49: 47:     assert_eq!(a.get(), 1);
50: 48:     set_a.update(|n| *n += 1);
51: 49:     assert_eq!(a.get(), 2);
52: 50:     set_a.update_untracked(|n| *n += 1);
53: 51:     assert_eq!(a.get(), 3);
54: 52:     set_a.set(4);
55: 53:     assert_eq!(a.get(), 4);
56: 54: }
57: 55: 
58: 56: #[test]
59: 57: fn create_rw_signal() {
60: 58:     let owner = Owner::new();
61: 59:     owner.set();
62: 60: 
63: 61:     let a = RwSignal::new(0);
64: 62:     assert_eq!(a.read(), 0);
65: 63:     assert_eq!(a.get(), 0);
66: 64:     assert_eq!(a.with_untracked(|n| n + 1), 1);
67: 65:     assert_eq!(a.with(|n| n + 1), 1);
68: 66: }
69: 67: 
70: 68: #[test]
71: 69: fn update_rw_signal() {
72: 70:     let owner = Owner::new();
73: 71:     owner.set();
74: 72: 
75: 73:     let a = RwSignal::new(1);
76: 74:     assert_eq!(a.read(), 1);
77: 75:     assert_eq!(a.get(), 1);
78: 76:     a.update(|n| *n += 1);
79: 77:     assert_eq!(a.get(), 2);
80: 78:     a.update_untracked(|n| *n += 1);
81: 79:     assert_eq!(a.get(), 3);
82: 80:     a.set(4);
83: 81:     assert_eq!(a.get(), 4);
84: 82: }
85: 83: 
86: 84: #[test]
87: 85: fn create_signal() {
88: 86:     let owner = Owner::new();
89: 87:     owner.set();
90: 88: 
91: 89:     let (a, _) = signal(0);
92: 90:     assert_eq!(a.read(), 0);
93: 91:     assert_eq!(a.get(), 0);
94: 92:     assert_eq!(a.get_untracked(), 0);
95: 93:     assert_eq!(a.with_untracked(|n| n + 1), 1);
96: 94:     assert_eq!(a.with(|n| n + 1), 1);
97: 95: }
98: 96: 
99: 97: #[test]
100: 98: fn update_signal() {
101: 99:     let owner = Owner::new();
102: 100:     owner.set();
103: 101: 
104: 102:     let (a, set_a) = signal(1);
105: 103:     assert_eq!(a.get(), 1);
106: 104:     set_a.update(|n| *n += 1);
107: 105:     assert_eq!(a.get(), 2);
108: 106:     set_a.update_untracked(|n| *n += 1);
109: 107:     assert_eq!(a.get(), 3);
110: 108:     set_a.set(4);
111: 109:     assert_eq!(a.get(), 4);
112: 110: }
113: 111: 
114: 112: #[test]
115: 113: fn into_inner_signal() {
116: 114:     let owner = Owner::new();
117: 115:     owner.set();
118: 116: 
119: 117:     let rw_signal = RwSignal::new(1);
120: 118:     assert_eq!(rw_signal.get(), 1);
121: 119:     assert_eq!(rw_signal.into_inner(), Some(1));
122: 120: }
123: 121: 
124: 122: #[test]
125: 123: fn into_inner_arc_signal() {
126: 124:     let owner = Owner::new();
127: 125:     owner.set();
128: 126: 
129: 127:     let (a, b) = arc_signal(2);
130: 128:     assert_eq!(a.get(), 2);
131: 129:     std::mem::drop(b);
132: 130:     assert_eq!(a.into_inner(), Some(2));
133: 131: }
134: 132: 
135: 133: #[test]
136: 134: fn into_inner_non_arc_signal() {
137: 135:     let owner = Owner::new();
138: 136:     owner.set();
139: 137: 
140: 138:     let (a, b) = signal(2);
141: 139:     assert_eq!(a.get(), 2);
142: 140:     b.dispose();
143: 141:     assert_eq!(a.into_inner(), Some(2));
144: 142: }
145: ```
```
