### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_leptos\src\text_prop.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\text_prop.rs
2: ```rust
3: 1: use lyx-core-oco::Oco;
4: 2: use std::sync::Arc;
5: 3: use lyx-core-lyx_core_lyx-core-lyx_core_tachys::prelude::IntoAttributeValue;
6: 4: 
7: 5: /// Describes a value that is either a static or a reactive string, i.e.,
8: 6: /// a [`String`], a [`&str`], a `Signal` or a reactive `Fn() -> String`.
9: 7: #[derive(Clone)]
10: 8: pub struct TextProp(Arc<dyn Fn() -> Oco<'static, str> + Send + Sync>);
11: 9: 
12: 10: impl TextProp {
13: 11:     /// Accesses the current value of the property.
14: 12:     #[inline(always)]
15: 13:     pub fn get(&self) -> Oco<'static, str> {
16: 14:         (self.0)()
17: 15:     }
18: 16: }
19: 17: 
20: 18: impl core::fmt::Debug for TextProp {
21: 19:     fn fmt(&self, f: &mut core::fmt::Formatter<'_>) -> core::fmt::Result {
22: 20:         f.debug_tuple("TextProp").finish()
23: 21:     }
24: 22: }
25: 23: 
26: 24: impl From<String> for TextProp {
27: 25:     fn from(s: String) -> Self {
28: 26:         let s: Oco<'_, str> = Oco::Counted(Arc::from(s));
29: 27:         TextProp(Arc::new(move || s.clone()))
30: 28:     }
31: 29: }
32: 30: 
33: 31: impl From<&'static str> for TextProp {
34: 32:     fn from(s: &'static str) -> Self {
35: 33:         let s: Oco<'_, str> = s.into();
36: 34:         TextProp(Arc::new(move || s.clone()))
37: 35:     }
38: 36: }
39: 37: 
40: 38: impl From<Arc<str>> for TextProp {
41: 39:     fn from(s: Arc<str>) -> Self {
42: 40:         let s: Oco<'_, str> = s.into();
43: 41:         TextProp(Arc::new(move || s.clone()))
44: 42:     }
45: 43: }
46: 44: 
47: 45: impl From<Oco<'static, str>> for TextProp {
48: 46:     fn from(s: Oco<'static, str>) -> Self {
49: 47:         TextProp(Arc::new(move || s.clone()))
50: 48:     }
51: 49: }
52: 50: 
53: 51: // TODO
54: 52: /*impl<T> From<T> for MaybeProp<TextProp>
55: 53: where
56: 54:     T: Into<Oco<'static, str>>,
57: 55: {
58: 56:     fn from(s: T) -> Self {
59: 57:         Self(Some(MaybeSignal::from(Some(s.into().into()))))
60: 58:     }
61: 59: }*/
62: 60: 
63: 61: impl<F, S> From<F> for TextProp
64: 62: where
65: 63:     F: Fn() -> S + 'static + Send + Sync,
66: 64:     S: Into<Oco<'static, str>>,
67: 65: {
68: 66:     #[inline(always)]
69: 67:     fn from(s: F) -> Self {
70: 68:         TextProp(Arc::new(move || s().into()))
71: 69:     }
72: 70: }
73: 71: 
74: 72: impl Default for TextProp {
75: 73:     fn default() -> Self {
76: 74:         Self(Arc::new(|| Oco::Borrowed("")))
77: 75:     }
78: 76: }
79: 77: 
80: 78: impl IntoAttributeValue for TextProp {
81: 79:     type Output = Arc<dyn Fn() -> Oco<'static, str> + Send + Sync>;
82: 80: 
83: 81:     fn into_attribute_value(self) -> Self::Output {
84: 82:         self.0
85: 83:     }
86: 84: }
87: 85: 
88: 86: macro_rules! textprop_reactive {
89: 87:     ($name:ident, <$($gen:ident),*>, $v:ty, $( $where_clause:tt )*) =>
90: 88:     {
91: 89:         #[allow(deprecated)]
92: 90:         impl<$($gen),*> From<$name<$($gen),*>> for TextProp
93: 91:         where
94: 92:             $v: Into<Oco<'static, str>>  + Clone + Send + Sync + 'static,
95: 93:             $($where_clause)*
96: 94:         {
97: 95:             #[inline(always)]
98: 96:             fn from(s: $name<$($gen),*>) -> Self {
99: 97:                 TextProp(Arc::new(move || s.get().into()))
100: 98:             }
101: 99:         }
102: 100:     };
103: 101: }
104: 102: 
105: 103: #[cfg(not(feature = "nightly"))]
106: 104: mod stable {
107: 105:     use super::TextProp;
108: 106:     use lyx-core-oco::Oco;
109: 107:     #[allow(deprecated)]
110: 108:     use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_appers::read::MaybeSignal;
111: 109:     use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::{
112: 110:         computed::{ArcMemo, Memo},
113: 111:         owner::Storage,
114: 112:         signal::{ArcReadSignal, ArcRwSignal, ReadSignal, RwSignal},
115: 113:         traits::Get,
116: 114:         wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_appers::read::{ArcSignal, Signal},
117: 115:     };
118: 116:     use std::sync::Arc;
119: 117: 
120: 118:     textprop_reactive!(
121: 119:         RwSignal,
122: 120:         <V, S>,
123: 121:         V,
124: 122:         RwSignal<V, S>: Get<Value = V>,
125: 123:         S: Storage<V> + Storage<Option<V>>,
126: 124:         S: Send + Sync + 'static,
127: 125:     );
128: 126:     textprop_reactive!(
129: 127:         ReadSignal,
130: 128:         <V, S>,
131: 129:         V,
132: 130:         ReadSignal<V, S>: Get<Value = V>,
133: 131:         S: Storage<V> + Storage<Option<V>>,
134: 132:         S: Send + Sync + 'static,
135: 133:     );
136: 134:     textprop_reactive!(
137: 135:         Memo,
138: 136:         <V, S>,
139: 137:         V,
140: 138:         Memo<V, S>: Get<Value = V>,
141: 139:         S: Storage<V> + Storage<Option<V>>,
142: 140:         S: Send + Sync + 'static,
143: 141:     );
144: 142:     textprop_reactive!(
145: 143:         Signal,
146: 144:         <V, S>,
147: 145:         V,
148: 146:         Signal<V, S>: Get<Value = V>,
149: 147:         S: Storage<V> + Storage<Option<V>>,
150: 148:         S: Send + Sync + 'static,
151: 149:     );
152: 150:     textprop_reactive!(
153: 151:         MaybeSignal,
154: 152:         <V, S>,
155: 153:         V,
156: 154:         MaybeSignal<V, S>: Get<Value = V>,
157: 155:         S: Storage<V> + Storage<Option<V>>,
158: 156:         S: Send + Sync + 'static,
159: 157:     );
160: 158:     textprop_reactive!(ArcRwSignal, <V>, V, ArcRwSignal<V>: Get<Value = V>);
161: 159:     textprop_reactive!(ArcReadSignal, <V>, V, ArcReadSignal<V>: Get<Value = V>);
162: 160:     textprop_reactive!(ArcMemo, <V>, V, ArcMemo<V>: Get<Value = V>);
163: 161:     textprop_reactive!(ArcSignal, <V>, V, ArcSignal<V>: Get<Value = V>);
164: 162: }
165: 163: 
166: 164: /// Extension trait for `Option<TextProp>`
167: 165: pub trait OptionTextPropExt {
168: 166:     /// Accesses the current value of the `Option<TextProp>` as an `Option<Oco<'static, str>>`.
169: 167:     fn get(&self) -> Option<Oco<'static, str>>;
170: 168: }
171: 169: 
172: 170: impl OptionTextPropExt for Option<TextProp> {
173: 171:     fn get(&self) -> Option<Oco<'static, str>> {
174: 172:         self.as_ref().map(|text_prop| text_prop.get())
175: 173:     }
176: 174: }
177: ```
```
