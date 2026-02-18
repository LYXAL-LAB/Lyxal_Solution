### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_element_rects.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_element_rects.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_element_rects.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_element_rects.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_element_rects.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_element_rects.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_element_rects.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_element_rects.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_element_rects.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_element_rects.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_element_rects.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_element_rects.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_element_rects.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_element_rects.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_element_rects.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_element_rects.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_element_rects.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_element_rects.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_element_rects.rs
use lyx_ui_foundations_core::{GetElementRectsArgs, Platform as CorePlatform};
use lyx_ui_foundations_utils::{ElementOrWindow, ElementRects, Rect};
use web_sys::{Element, Window};

use crate::{
platform::Platform,
utils::get_rect_relative_to_offset_parent::get_rect_relative_to_offset_parent,
};

pub fn get_element_rects(platform: &Platform, args: GetElementRectsArgs<Element>) -> ElementRects {
let offset_parent = platform
.get_offset_parent(args.floating)
.expect("Platform implements get_offset_parent.");
let dimensions = platform.get_dimensions(args.floating);

let offset_parent_ref: ElementOrWindow<Element, Window> = (&offset_parent).into();

ElementRects {
reference: get_rect_relative_to_offset_parent(
args.reference,
offset_parent_ref.into(),
args.strategy,
),
floating: Rect {
x: 0.0,
y: 0.0,
width: dimensions.width,
height: dimensions.height,
},
}
}
