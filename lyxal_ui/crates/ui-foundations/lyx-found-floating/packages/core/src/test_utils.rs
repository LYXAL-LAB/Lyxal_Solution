1: use lyx_ui_foundations_utils::{Dimensions, ElementRects, Rect};
2: 
3: use crate::types::{GetClippingRectArgs, GetElementRectsArgs, Platform};
4: 
5: #[derive(Clone, Debug)]
6: pub struct Element {}
7: 
8: #[derive(Clone, Debug)]
9: pub struct Window {}
10: 
11: pub const REFERENCE: Element = Element {};
12: pub const FLOATING: Element = Element {};
13: pub const REFERENCE_RECT: Rect = Rect {
14:     x: 0.0,
15:     y: 0.0,
16:     width: 100.0,
17:     height: 100.0,
18: };
19: pub const FLOATING_RECT: Rect = Rect {
20:     x: 0.0,
21:     y: 0.0,
22:     width: 50.0,
23:     height: 50.0,
24: };
25: 
26: #[derive(Debug)]
27: pub struct TestPlatform {}
28: 
29: impl Platform<Element, Window> for TestPlatform {
30:     fn get_element_rects(&self, _args: GetElementRectsArgs<Element>) -> ElementRects {
31:         ElementRects {
32:             reference: REFERENCE_RECT,
33:             floating: FLOATING_RECT,
34:         }
35:     }
36: 
37:     fn get_clipping_rect(&self, _args: GetClippingRectArgs<Element>) -> Rect {
38:         Rect {
39:             x: 0.0,
40:             y: 0.0,
41:             width: 1000.0,
42:             height: 1000.0,
43:         }
44:     }
45: 
46:     fn get_dimensions(&self, _element: &Element) -> Dimensions {
47:         Dimensions {
48:             width: 10.0,
49:             height: 10.0,
50:         }
51:     }
52: }
53: 
54: pub const PLATFORM: TestPlatform = TestPlatform {};
```

