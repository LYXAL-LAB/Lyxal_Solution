### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx-found-floating\packages\core\src\compute_position.rs
```rust
1: use lyx_ui_foundations_utils::{Coords, ElementOrVirtual, Placement, Strategy};
2: 
3: use crate::compute_coords_from_placement::compute_coords_from_placement;
4: use crate::types::{
5:     ComputePositionConfig, ComputePositionReturn, Elements, GetElementRectsArgs, MiddlewareData,
6:     MiddlewareReturn, MiddlewareState, Reset, ResetRects,
7: };
8: 
9: /// Computes the `x` and `y` coordinates that will place the floating element next to a given reference element.
10: ///
11: /// This export does not have any `platform` interface logic. You will need to write one for the platform you are using Floating UI with.
12: ///
13: /// See [`Platform`][`crate::types::Platform`].
14: pub fn compute_position<Element: Clone, Window: Clone>(
15:     reference: ElementOrVirtual<Element>,
16:     floating: &Element,
17:     config: ComputePositionConfig<Element, Window>,
18: ) -> ComputePositionReturn {
19:     let placement = config.placement.unwrap_or(Placement::Bottom);
20:     let strategy = config.strategy.unwrap_or(Strategy::Absolute);
21:     let platform = config.platform;
22:     let middlewares = config.middleware.unwrap_or_default();
23: 
24:     let rtl = platform.is_rtl(floating);
25: 
26:     let mut rects = platform.get_element_rects(GetElementRectsArgs {
27:         reference: reference.clone(),
28:         floating,
29:         strategy,
30:     });
31:     let Coords { mut x, mut y } = compute_coords_from_placement(&rects, placement, rtl);
32:     let mut stateful_placement = placement;
33:     let mut middleware_data = MiddlewareData::default();
34:     let mut reset_count = 0;
35: 
36:     let mut i = 0;
37:     while i < middlewares.len() {
38:         let middleware = &middlewares[i];
39: 
40:         let MiddlewareReturn {
41:             x: next_x,
42:             y: next_y,
43:             data,
44:             reset,
45:         } = middleware.compute(MiddlewareState {
46:             x,
47:             y,
48:             initial_placement: placement,
49:             placement: stateful_placement,
50:             strategy,
51:             middleware_data: &middleware_data,
52:             rects: &rects,
53:             platform,
54:             elements: Elements {
55:                 reference: reference.clone(),
56:                 floating,
57:             },
58:         });
59: 
60:         x = next_x.unwrap_or(x);
61:         y = next_y.unwrap_or(y);
62: 
63:         if let Some(data) = data {
64:             let existing_data = middleware_data.get(middleware.name());
65: 
66:             let new_data = match existing_data {
67:                 Some(existing_data) => {
68:                     let mut a = existing_data
69:                         .as_object()
70:                         .expect("Existing data should be an object.")
71:                         .to_owned();
72: 
73:                     let mut b = data
74:                         .as_object()
75:                         .expect("New data should be an object.")
76:                         .to_owned();
77: 
78:                     b.retain(|_, v| !v.is_null());
79:                     a.extend(b);
80: 
81:                     serde_json::Value::Object(a)
82:                 }
83:                 None => data,
84:             };
85: 
86:             middleware_data.set(middleware.name(), new_data);
87:         }
88: 
89:         if let Some(reset) = reset
90:             && reset_count <= 50
91:         {
92:             reset_count += 1;
93: 
94:             match reset {
95:                 Reset::True => {}
96:                 Reset::Value(value) => {
97:                     if let Some(reset_placement) = value.placement {
98:                         stateful_placement = reset_placement;
99:                     }
100: 
101:                     if let Some(reset_rects) = value.rects {
102:                         rects = match reset_rects {
103:                             ResetRects::True => platform.get_element_rects(GetElementRectsArgs {
104:                                 reference: reference.clone(),
105:                                 floating,
106:                                 strategy,
107:                             }),
108:                             ResetRects::Value(element_rects) => element_rects,
109:                         }
110:                     }
111: 
112:                     let Coords {
113:                         x: next_x,
114:                         y: next_y,
115:                     } = compute_coords_from_placement(&rects, stateful_placement, rtl);
116:                     x = next_x;
117:                     y = next_y;
118:                 }
119:             }
120: 
121:             i = 0;
122:             continue;
123:         }
124: 
125:         i += 1;
126:     }
127: 
128:     ComputePositionReturn {
129:         x,
130:         y,
131:         placement: stateful_placement,
132:         strategy,
133:         middleware_data,
134:     }
135: }
136: 
137: #[cfg(test)]
138: mod tests {
139:     use serde_json::json;
140: 
141:     use crate::test_utils::{FLOATING, PLATFORM, REFERENCE};
142:     use crate::types::Middleware;
143: 
144:     use super::*;
145: 
146:     #[test]
147:     fn test_returned_data() {
148:         #[derive(Clone, PartialEq)]
149:         struct CustomMiddleware {}
150: 
151:         impl<Element: Clone + 'static, Window: Clone + 'static> Middleware<Element, Window>
152:             for CustomMiddleware
153:         {
154:             fn name(&self) -> &'static str {
155:                 "custom"
156:             }
157: 
158:             fn compute(&self, _state: MiddlewareState<Element, Window>) -> MiddlewareReturn {
159:                 MiddlewareReturn {
160:                     x: None,
161:                     y: None,
162:                     data: Some(json!({"property": true})),
163:                     reset: None,
164:                 }
165:             }
166:         }
167: 
168:         let ComputePositionReturn {
169:             x,
170:             y,
171:             placement,
172:             strategy,
173:             middleware_data,
174:         } = compute_position(
175:             (&REFERENCE).into(),
176:             &FLOATING,
177:             ComputePositionConfig {
178:                 platform: &PLATFORM,
179:                 placement: Some(Placement::Top),
180:                 strategy: None,
181:                 middleware: Some(vec![Box::new(CustomMiddleware {})]),
182:             },
183:         );
184: 
185:         assert_eq!(x, 25.0);
186:         assert_eq!(y, -50.0);
187:         assert_eq!(placement, Placement::Top);
188:         assert_eq!(strategy, Strategy::Absolute);
189:         assert_eq!(
190:             middleware_data.get("custom"),
191:             Some(&json!({"property": true}))
192:         );
193:     }
194: 
195:     #[test]
196:     fn test_middleware() {
197:         #[derive(Clone, PartialEq)]
198:         struct TestMiddleware {}
199: 
200:         impl<Element: Clone + 'static, Window: Clone + 'static> Middleware<Element, Window>
201:             for TestMiddleware
202:         {
203:             fn name(&self) -> &'static str {
204:                 "test"
205:             }
206: 
207:             fn compute(
208:                 &self,
209:                 MiddlewareState { x, y, .. }: MiddlewareState<Element, Window>,
210:             ) -> MiddlewareReturn {
211:                 MiddlewareReturn {
212:                     x: Some(x + 1.0),
213:                     y: Some(y + 1.0),
214:                     data: None,
215:                     reset: None,
216:                 }
217:             }
218:         }
219: 
220:         let ComputePositionReturn { x, y, .. } = compute_position(
221:             (&REFERENCE).into(),
222:             &FLOATING,
223:             ComputePositionConfig {
224:                 platform: &PLATFORM,
225:                 placement: None,
226:                 strategy: None,
227:                 middleware: None,
228:             },
229:         );
230: 
231:         let ComputePositionReturn { x: x2, y: y2, .. } = compute_position(
232:             (&REFERENCE).into(),
233:             &FLOATING,
234:             ComputePositionConfig {
235:                 platform: &PLATFORM,
236:                 placement: None,
237:                 strategy: None,
238:                 middleware: Some(vec![Box::new(TestMiddleware {})]),
239:             },
240:         );
241: 
242:         assert_eq!((x2, y2), (x + 1.0, y + 1.0));
243:     }
244: 
245:     #[test]
246:     fn test_middleware_data() {
247:         #[derive(Clone, PartialEq)]
248:         struct TestMiddleware {}
249: 
250:         impl<Element: Clone + 'static, Window: Clone + 'static> Middleware<Element, Window>
251:             for TestMiddleware
252:         {
253:             fn name(&self) -> &'static str {
254:                 "test"
255:             }
256: 
257:             fn compute(&self, _state: MiddlewareState<Element, Window>) -> MiddlewareReturn {
258:                 MiddlewareReturn {
259:                     x: None,
260:                     y: None,
261:                     data: Some(json!({"hello": true})),
262:                     reset: None,
263:                 }
264:             }
265:         }
266: 
267:         let ComputePositionReturn {
268:             middleware_data, ..
269:         } = compute_position(
270:             (&REFERENCE).into(),
271:             &FLOATING,
272:             ComputePositionConfig {
273:                 platform: &PLATFORM,
274:                 placement: None,
275:                 strategy: None,
276:                 middleware: Some(vec![Box::new(TestMiddleware {})]),
277:             },
278:         );
279: 
280:         assert_eq!(middleware_data.get("test"), Some(&json!({"hello": true})));
281:     }
282: }
```
