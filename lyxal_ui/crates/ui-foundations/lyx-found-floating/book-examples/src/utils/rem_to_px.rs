1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx-found-floating\book-lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_examples\src\utils\rem_to_px.rs
2: ```rust
3: 1: use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
4: 2: 
5: 3: pub fn rem_to_px(value: f64) -> f64 {
6: 4:     document()
7: 5:         .document_element()
8: 6:         .map(|document_element| {
9: 7:             value
10: 8:                 * window()
11: 9:                     .get_computed_style(&document_element)
12: 10:                     .expect("Valid element.")
13: 11:                     .expect("Element should have computed style.")
14: 12:                     .get_property_value("font-size")
15: 13:                     .expect("Computed style should have font size.")
16: 14:                     .replace("px", "")
17: 15:                     .parse::<f64>()
18: 16:                     .expect("Font size should be a float.")
19: 17:         })
20: 18:         .unwrap_or(value * 16.0)
21: 19: }
22: ```
```

