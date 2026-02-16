1: use lyx_ui_foundations_utils::{
2:     Alignment, Axis, Coords, ElementRects, Placement, Side, get_alignment, get_alignment_axis,
3:     get_axis_length, get_side, get_side_axis,
4: };
5: 
6: /// Computes the `x` and `y` coordinates that will place the floating element next to a given reference element based on a `placement`.
7: pub fn compute_coords_from_placement(
8:     ElementRects {
9:         reference,
10:         floating,
11:     }: &ElementRects,
12:     placement: Placement,
13:     rtl: Option<bool>,
14: ) -> Coords {
15:     let side_axis = get_side_axis(placement);
16:     let alignment_axis = get_alignment_axis(placement);
17:     let align_length = get_axis_length(alignment_axis);
18:     let side = get_side(placement);
19:     let is_vertical = side_axis == Axis::Y;
20: 
21:     let common_x = reference.x + reference.width / 2.0 - floating.width / 2.0;
22:     let common_y = reference.y + reference.height / 2.0 - floating.height / 2.0;
23:     let common_align = reference.length(align_length) / 2.0 - floating.length(align_length) / 2.0;
24: 
25:     let mut coords = match side {
26:         Side::Top => Coords {
27:             x: common_x,
28:             y: reference.y - floating.height,
29:         },
30:         Side::Right => Coords {
31:             x: reference.x + reference.width,
32:             y: common_y,
33:         },
34:         Side::Bottom => Coords {
35:             x: common_x,
36:             y: reference.y + reference.height,
37:         },
38:         Side::Left => Coords {
39:             x: reference.x - floating.width,
40:             y: common_y,
41:         },
42:     };
43: 
44:     let rtl = rtl.unwrap_or(false);
45:     match get_alignment(placement) {
46:         Some(Alignment::Start) => {
47:             coords.update_axis(alignment_axis, |value| {
48:                 value - common_align * (if rtl && is_vertical { -1.0 } else { 1.0 })
49:             });
50:         }
51:         Some(Alignment::End) => {
52:             coords.update_axis(alignment_axis, |value| {
53:                 value + common_align * (if rtl && is_vertical { -1.0 } else { 1.0 })
54:             });
55:         }
56:         None => {}
57:     }
58: 
59:     coords
60: }
61: 
62: #[cfg(test)]
63: mod tests {
64:     use lyx_ui_foundations_utils::Rect;
65: 
66:     use super::*;
67: 
68:     const ELEMENT_RECTS: ElementRects = ElementRects {
69:         reference: Rect {
70:             x: 0.0,
71:             y: 0.0,
72:             width: 100.0,
73:             height: 100.0,
74:         },
75:         floating: Rect {
76:             x: 0.0,
77:             y: 0.0,
78:             width: 50.0,
79:             height: 50.0,
80:         },
81:     };
82: 
83:     #[test]
84:     fn test_top() {
85:         assert_eq!(
86:             compute_coords_from_placement(&ELEMENT_RECTS, Placement::Top, None),
87:             Coords { x: 25.0, y: -50.0 }
88:         )
89:     }
90: 
91:     #[test]
92:     fn test_top_start() {
93:         assert_eq!(
94:             compute_coords_from_placement(&ELEMENT_RECTS, Placement::TopStart, None),
95:             Coords { x: 0.0, y: -50.0 }
96:         )
97:     }
98: 
99:     #[test]
100:     fn test_top_end() {
101:         assert_eq!(
102:             compute_coords_from_placement(&ELEMENT_RECTS, Placement::TopEnd, None),
103:             Coords { x: 50.0, y: -50.0 }
104:         )
105:     }
106: 
107:     #[test]
108:     fn test_right() {
109:         assert_eq!(
110:             compute_coords_from_placement(&ELEMENT_RECTS, Placement::Right, None),
111:             Coords { x: 100.0, y: 25.0 }
112:         )
113:     }
114: 
115:     #[test]
116:     fn test_right_start() {
117:         assert_eq!(
118:             compute_coords_from_placement(&ELEMENT_RECTS, Placement::RightStart, None),
119:             Coords { x: 100.0, y: 0.0 }
120:         )
121:     }
122: 
123:     #[test]
124:     fn test_right_end() {
125:         assert_eq!(
126:             compute_coords_from_placement(&ELEMENT_RECTS, Placement::RightEnd, None),
127:             Coords { x: 100.0, y: 50.0 }
128:         )
129:     }
130: 
131:     #[test]
132:     fn test_bottom() {
133:         assert_eq!(
134:             compute_coords_from_placement(&ELEMENT_RECTS, Placement::Bottom, None),
135:             Coords { x: 25.0, y: 100.0 }
136:         )
137:     }
138: 
139:     #[test]
140:     fn test_bottom_start() {
141:         assert_eq!(
142:             compute_coords_from_placement(&ELEMENT_RECTS, Placement::BottomStart, None),
143:             Coords { x: 0.0, y: 100.0 }
144:         )
145:     }
146: 
147:     #[test]
148:     fn test_bottom_end() {
149:         assert_eq!(
150:             compute_coords_from_placement(&ELEMENT_RECTS, Placement::BottomEnd, None),
151:             Coords { x: 50.0, y: 100.0 }
152:         )
153:     }
154: 
155:     #[test]
156:     fn test_left() {
157:         assert_eq!(
158:             compute_coords_from_placement(&ELEMENT_RECTS, Placement::Left, None),
159:             Coords { x: -50.0, y: 25.0 }
160:         )
161:     }
162: 
163:     #[test]
164:     fn test_left_start() {
165:         assert_eq!(
166:             compute_coords_from_placement(&ELEMENT_RECTS, Placement::LeftStart, None),
167:             Coords { x: -50.0, y: 0.0 }
168:         )
169:     }
170: 
171:     #[test]
172:     fn test_left_end() {
173:         assert_eq!(
174:             compute_coords_from_placement(&ELEMENT_RECTS, Placement::LeftEnd, None),
175:             Coords { x: -50.0, y: 50.0 }
176:         )
177:     }
178: }
```

