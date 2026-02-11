### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx-found-floating\book-lyx-ui-foundations-lyx_ui_foundations_examples\src\positioning\placement.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx-found-floating\book-lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_examples\src\positioning\placement.rs
2: ```rust
3: 1: use convert_case::{Case, Casing};
4: 2: use floating_ui_lyx-core-lyx_core_lyx-core-lyx_core_leptos::{MiddlewareVec, Offset, OffsetOptions, Placement};
5: 3: use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
6: 4: use send_wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper::SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper;
7: 5: use tailwind_fuse::tw_merge;
8: 6: 
9: 7: use crate::components::{Chrome, Floating, GridItem, Reference};
10: 8: 
11: 9: struct PlacementData {
12: 10:     placement: Placement,
13: 11:     top: Option<String>,
14: 12:     right: Option<String>,
15: 13:     bottom: Option<String>,
16: 14:     left: Option<String>,
17: 15: }
18: 16: 
19: 17: #[component]
20: 18: pub fn PlacementDemo() -> impl IntoView {
21: 19:     let (placement, set_placement) = signal(Placement::Top);
22: 20: 
23: 21:     view! {
24: 22:         <GridItem
25: 23:             title="Placement"
26: 24:             description="Places your floating element relative to another element."
27: 25:             chrome=move || view! {
28: 26:                 <Chrome
29: 27:                     label="Click the dots"
30: 28:                     center=true
31: 29:                     shadow=false
32: 30:                 >
33: 31:                     <For
34: 32:                         each=|| [
35: 33:                             PlacementData {
36: 34:                                 placement: Placement::Top,
37: 35:                                 top: Some("0px".to_owned()),
38: 36:                                 right: None,
39: 37:                                 bottom: None,
40: 38:                                 left: Some("calc(50% - 10px - 1rem)".to_owned()),
41: 39:                             },
42: 40:                             PlacementData {
43: 41:                                 placement: Placement::TopStart,
44: 42:                                 top: Some("0px".to_owned()),
45: 43:                                 right: None,
46: 44:                                 bottom: None,
47: 45:                                 left: Some("calc(50% - 70px - 1rem)".to_owned()),
48: 46:                             },
49: 47:                             PlacementData {
50: 48:                                 placement: Placement::TopEnd,
51: 49:                                 top: Some("0px".to_owned()),
52: 50:                                 right: None,
53: 51:                                 bottom: None,
54: 52:                                 left: Some("calc(50% + 50px - 1rem)".to_owned()),
55: 53:                             },
56: 54:                             PlacementData {
57: 55:                                 placement: Placement::Bottom,
58: 56:                                 top: None,
59: 57:                                 right: None,
60: 58:                                 bottom: Some("0px".to_owned()),
61: 59:                                 left: Some("calc(50% - 10px - 1rem)".to_owned()),
62: 60:                             },
63: 61:                             PlacementData {
64: 62:                                 placement: Placement::BottomStart,
65: 63:                                 top: None,
66: 64:                                 right: None,
67: 65:                                 bottom: Some("0px".to_owned()),
68: 66:                                 left: Some("calc(50% - 70px - 1rem)".to_owned()),
69: 67:                             },
70: 68:                             PlacementData {
71: 69:                                 placement: Placement::BottomEnd,
72: 70:                                 top: None,
73: 71:                                 right: None,
74: 72:                                 bottom: Some("0px".to_owned()),
75: 73:                                 left: Some("calc(50% + 50px - 1rem)".to_owned()),
76: 74:                             },
77: 75:                             PlacementData {
78: 76:                                 placement: Placement::Right,
79: 77:                                 top: Some("calc(50% - 10px - 1rem)".to_owned()),
80: 78:                                 right: Some("min(50px, 5%)".to_owned()),
81: 79:                                 bottom: None,
82: 80:                                 left: None,
83: 81:                             },
84: 82:                             PlacementData {
85: 83:                                 placement: Placement::RightStart,
86: 84:                                 top: Some("calc(50% - 70px - 1rem)".to_owned()),
87: 85:                                 right: Some("min(50px, 5%)".to_owned()),
88: 86:                                 bottom: None,
89: 87:                                 left: None,
90: 88:                             },
91: 89:                             PlacementData {
92: 90:                                 placement: Placement::RightEnd,
93: 91:                                 top: Some("calc(50% + 50px - 1rem)".to_owned()),
94: 92:                                 right: Some("min(50px, 5%)".to_owned()),
95: 93:                                 bottom: None,
96: 94:                                 left: None,
97: 95:                             },
98: 96:                             PlacementData {
99: 97:                                 placement: Placement::Left,
100: 98:                                 top: Some("calc(50% - 10px - 1rem)".to_owned()),
101: 99:                                 right: None,
102: 100:                                 bottom: None,
103: 101:                                 left: Some("min(50px, 5%)".to_owned()),
104: 102:                             },
105: 103:                             PlacementData {
106: 104:                                 placement: Placement::LeftStart,
107: 105:                                 top: Some("calc(50% - 70px - 1rem)".to_owned()),
108: 106:                                 right: None,
109: 107:                                 bottom: None,
110: 108:                                 left: Some("min(50px, 5%)".to_owned()),
111: 109:                             },
112: 110:                             PlacementData {
113: 111:                                 placement: Placement::LeftEnd,
114: 112:                                 top: Some("calc(50% + 50px - 1rem)".to_owned()),
115: 113:                                 right: None,
116: 114:                                 bottom: None,
117: 115:                                 left: Some("min(50px, 5%)".to_owned()),
118: 116:                             },
119: 117:                         ]
120: 118:                         key=|data| format!("{:?}", data.placement).to_case(Case::Kebab)
121: 119:                         children=move |data| view! {
122: 120:                             <button
123: 121:                                 class="absolute p-4 transition hover:scale-125"
124: 122:                                 aria-label={format!("{:?}", data.placement).to_case(Case::Kebab)}
125: 123:                                 style:top=data.top.unwrap_or_default()
126: 124:                                 style:right=data.right.unwrap_or_default()
127: 125:                                 style:bottom=data.bottom.unwrap_or_default()
128: 126:                                 style:left=data.left.unwrap_or_default()
129: 127:                                 on:click={move |_| set_placement.set(data.placement)}
130: 128:                             >
131: 129:                                 <div
132: 130:                                     class={tw_merge!(
133: 131:                                         "h-5 w-5 rounded-full border-2 border-solid",
134: 132:                                         if placement.get() == data.placement {
135: 133:                                             "border-gray-800 bg-gray-800"
136: 134:                                         } else {
137: 135:                                             "border-gray-900"
138: 136:                                         }
139: 137:                                     )}
140: 138:                                 />
141: 139:                             </button>
142: 140:                         }
143: 141:                     />
144: 142:                     <Floating
145: 143:                         placement=placement
146: 144:                         middleware={
147: 145:                             let middleware: MiddlewareVec = vec![Box::new(Offset::new(OffsetOptions::Value(5.0)))];
148: 146: 
149: 147:                             SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper::new(middleware)
150: 148:                         }
151: 149:                         content=move || view! {
152: 150:                             <div
153: 151:                                 class="text-center text-sm font-bold"
154: 152:                                 style:min-width=move || matches!(
155: 153:                                     placement.get(),
156: 154:                                     Placement::TopStart | Placement::TopEnd | Placement::BottomStart | Placement::BottomEnd
157: 155:                                 ).then_some("8rem").unwrap_or_default()
158: 156:                             >
159: 157:                                 {move || format!("{:?}", placement.get()).to_case(Case::Kebab)}
160: 158:                             </div>
161: 159:                         }
162: 160:                         reference=move |node_ref| view! {
163: 161:                             <Reference node_ref=node_ref />
164: 162:                         }
165: 163:                     />
166: 164:                 </Chrome>
167: 165:             }
168: 166:         />
169: 167:     }
170: 168: }
171: ```
```
