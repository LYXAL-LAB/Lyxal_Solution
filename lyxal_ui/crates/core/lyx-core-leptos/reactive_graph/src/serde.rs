### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_reactive_graph\src\serde.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\src\serde.rs
2: ```rust
3: 1: #[allow(deprecated)]
4: 2: use crate::wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_appers::read::{MaybeProp, MaybeSignal};
5: 3: use crate::{
6: 4:     computed::{ArcMemo, Memo},
7: 5:     owner::Storage,
8: 6:     signal::{ArcReadSignal, ArcRwSignal, ReadSignal, RwSignal},
9: 7:     traits::With,
10: 8:     wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_appers::read::{Signal, SignalTypes},
11: 9: };
12: 10: use serde::{Deserialize, Serialize};
13: 11: 
14: 12: impl<T, St> Serialize for ReadSignal<T, St>
15: 13: where
16: 14:     T: Serialize + 'static,
17: 15:     St: Storage<ArcReadSignal<T>>,
18: 16: {
19: 17:     fn serialize<S>(&self, serializer: S) -> Result<S::Ok, S::Error>
20: 18:     where
21: 19:         S: serde::Serializer,
22: 20:     {
23: 21:         self.with(|value| value.serialize(serializer))
24: 22:     }
25: 23: }
26: 24: 
27: 25: impl<T, St> Serialize for RwSignal<T, St>
28: 26: where
29: 27:     T: Serialize + 'static,
30: 28:     St: Storage<ArcRwSignal<T>>,
31: 29: {
32: 30:     fn serialize<S>(&self, serializer: S) -> Result<S::Ok, S::Error>
33: 31:     where
34: 32:         S: serde::Serializer,
35: 33:     {
36: 34:         self.with(|value| value.serialize(serializer))
37: 35:     }
38: 36: }
39: 37: 
40: 38: impl<T, St> Serialize for Memo<T, St>
41: 39: where
42: 40:     T: Serialize + 'static,
43: 41:     St: Storage<ArcMemo<T, St>> + Storage<T>,
44: 42: {
45: 43:     fn serialize<S>(&self, serializer: S) -> Result<S::Ok, S::Error>
46: 44:     where
47: 45:         S: serde::Serializer,
48: 46:     {
49: 47:         self.with(|value| value.serialize(serializer))
50: 48:     }
51: 49: }
52: 50: 
53: 51: impl<T: Serialize + 'static> Serialize for ArcReadSignal<T> {
54: 52:     fn serialize<S>(&self, serializer: S) -> Result<S::Ok, S::Error>
55: 53:     where
56: 54:         S: serde::Serializer,
57: 55:     {
58: 56:         self.with(|value| value.serialize(serializer))
59: 57:     }
60: 58: }
61: 59: 
62: 60: impl<T: Serialize + 'static> Serialize for ArcRwSignal<T> {
63: 61:     fn serialize<S>(&self, serializer: S) -> Result<S::Ok, S::Error>
64: 62:     where
65: 63:         S: serde::Serializer,
66: 64:     {
67: 65:         self.with(|value| value.serialize(serializer))
68: 66:     }
69: 67: }
70: 68: 
71: 69: impl<T: Serialize + 'static, St: Storage<T>> Serialize for ArcMemo<T, St> {
72: 70:     fn serialize<S>(&self, serializer: S) -> Result<S::Ok, S::Error>
73: 71:     where
74: 72:         S: serde::Serializer,
75: 73:     {
76: 74:         self.with(|value| value.serialize(serializer))
77: 75:     }
78: 76: }
79: 77: 
80: 78: #[allow(deprecated)]
81: 79: impl<T, St> Serialize for MaybeSignal<T, St>
82: 80: where
83: 81:     T: Clone + Send + Sync + Serialize,
84: 82:     St: Storage<SignalTypes<T, St>> + Storage<T>,
85: 83: {
86: 84:     fn serialize<S>(&self, serializer: S) -> Result<S::Ok, S::Error>
87: 85:     where
88: 86:         S: serde::Serializer,
89: 87:     {
90: 88:         self.with(|value| value.serialize(serializer))
91: 89:     }
92: 90: }
93: 91: 
94: 92: impl<T, St> Serialize for MaybeProp<T, St>
95: 93: where
96: 94:     T: Send + Sync + Serialize,
97: 95:     St: Storage<SignalTypes<Option<T>, St>> + Storage<Option<T>>,
98: 96: {
99: 97:     fn serialize<S>(&self, serializer: S) -> Result<S::Ok, S::Error>
100: 98:     where
101: 99:         S: serde::Serializer,
102: 100:     {
103: 101:         match &self.0 {
104: 102:             None => None::<T>.serialize(serializer),
105: 103:             Some(signal) => signal.with(|value| value.serialize(serializer)),
106: 104:         }
107: 105:     }
108: 106: }
109: 107: 
110: 108: impl<T, St> Serialize for Signal<T, St>
111: 109: where
112: 110:     T: Send + Sync + Serialize + 'static,
113: 111:     St: Storage<SignalTypes<T, St>> + Storage<T>,
114: 112: {
115: 113:     fn serialize<S>(&self, serializer: S) -> Result<S::Ok, S::Error>
116: 114:     where
117: 115:         S: serde::Serializer,
118: 116:     {
119: 117:         self.with(|value| value.serialize(serializer))
120: 118:     }
121: 119: }
122: 120: 
123: 121: /* Deserialization for signal types */
124: 122: 
125: 123: impl<'de, T, S> Deserialize<'de> for RwSignal<T, S>
126: 124: where
127: 125:     T: Send + Sync + Deserialize<'de> + 'static,
128: 126:     S: Storage<ArcRwSignal<T>>,
129: 127: {
130: 128:     fn deserialize<D>(deserializer: D) -> Result<Self, D::Error>
131: 129:     where
132: 130:         D: serde::Deserializer<'de>,
133: 131:     {
134: 132:         T::deserialize(deserializer).map(RwSignal::new_with_storage)
135: 133:     }
136: 134: }
137: 135: 
138: 136: impl<'de, T: Deserialize<'de>> Deserialize<'de> for ArcRwSignal<T> {
139: 137:     fn deserialize<D>(deserializer: D) -> Result<Self, D::Error>
140: 138:     where
141: 139:         D: serde::Deserializer<'de>,
142: 140:     {
143: 141:         T::deserialize(deserializer).map(ArcRwSignal::new)
144: 142:     }
145: 143: }
146: 144: 
147: 145: #[allow(deprecated)]
148: 146: impl<'de, T: Deserialize<'de>, St> Deserialize<'de> for MaybeSignal<T, St>
149: 147: where
150: 148:     St: Storage<T>,
151: 149: {
152: 150:     fn deserialize<D>(deserializer: D) -> Result<Self, D::Error>
153: 151:     where
154: 152:         D: serde::Deserializer<'de>,
155: 153:     {
156: 154:         T::deserialize(deserializer).map(MaybeSignal::Static)
157: 155:     }
158: 156: }
159: ```
```
