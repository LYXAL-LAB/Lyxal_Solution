### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_window_scroll_bar_x.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_window_scroll_bar_x.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_window_scroll_bar_x.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_window_scroll_bar_x.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_window_scroll_bar_x.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_window_scroll_bar_x.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_window_scroll_bar_x.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_window_scroll_bar_x.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_window_scroll_bar_x.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_window_scroll_bar_x.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_window_scroll_bar_x.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_window_scroll_bar_x.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_window_scroll_bar_x.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_window_scroll_bar_x.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_window_scroll_bar_x.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_window_scroll_bar_x.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_window_scroll_bar_x.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_window_scroll_bar_x.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_window_scroll_bar_x.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_window_scroll_bar_x.rs
use lyx_ui_foundations_utils::dom::{get_document_element, get_node_scroll};
use web_sys::{DomRect, Element};

use crate::utils::get_bounding_lyx-core-lyx_core_lyx-core-lyx_core_client_rect::get_bounding_lyx-core-lyx_core_lyx-core-lyx_core_client_rect;

// If <html> has a CSS width greater than the viewport, then this will be incorrect for RTL.
pub fn get_window_scroll_bar_x(element: &Element, rect: Option<&DomRect>) -> f64 {
let left_scroll = get_node_scroll(element.into()).scroll_left;

if let Some(rect) = rect {
rect.left() + left_scroll
} else {
get_bounding_lyx-core-lyx_core_lyx-core-lyx_core_client_rect(
(&get_document_element(Some(element.into()))).into(),
false,
false,
None,
)
.left
+ left_scroll
}
}
