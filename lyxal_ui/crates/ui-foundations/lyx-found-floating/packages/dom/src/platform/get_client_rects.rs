### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_lyx-core-lyx_core_lyx-core-lyx_core_client_rects.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_lyx-core-lyx_core_lyx-core-lyx_core_client_rects.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_lyx-core-lyx_core_lyx-core-lyx_core_client_rects.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_lyx-core-lyx_core_lyx-core-lyx_core_client_rects.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_lyx-core-lyx_core_lyx-core-lyx_core_client_rects.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_lyx-core-lyx_core_lyx-core-lyx_core_client_rects.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_lyx-core-lyx_core_lyx-core-lyx_core_client_rects.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_lyx-core-lyx_core_lyx-core-lyx_core_client_rects.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_lyx-core-lyx_core_lyx-core-lyx_core_client_rects.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_lyx-core-lyx_core_lyx-core-lyx_core_client_rects.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_lyx-core-lyx_core_lyx-core-lyx_core_client_rects.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_lyx-core-lyx_core_lyx-core-lyx_core_client_rects.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_lyx-core-lyx_core_lyx-core-lyx_core_client_rects.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_lyx-core-lyx_core_lyx-core-lyx_core_client_rects.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_lyx-core-lyx_core_lyx-core-lyx_core_client_rects.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_lyx-core-lyx_core_lyx-core-lyx_core_client_rects.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_lyx-core-lyx_core_lyx-core-lyx_core_client_rects.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_lyx-core-lyx_core_lyx-core-lyx_core_client_rects.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_lyx-core-lyx_core_lyx-core-lyx_core_client_rects.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_lyx-core-lyx_core_lyx-core-lyx_core_client_rects.rs
use lyx_ui_foundations_utils::ClientRectObject;

use crate::types::ElementOrVirtual;

pub fn get_lyx-core-lyx_core_lyx-core-lyx_core_client_rects(element: ElementOrVirtual) -> Vec<ClientRectObject> {
match element {
ElementOrVirtual::Element(element) => {
ClientRectObject::from_dom_rect_list(element.get_lyx-core-lyx_core_lyx-core-lyx_core_client_rects())
}
ElementOrVirtual::VirtualElement(virtual_element) => virtual_element
.get_lyx-core-lyx_core_lyx-core-lyx_core_client_rects()
.expect("Virtual element must implement `get_lyx-core-lyx_core_lyx-core-lyx_core_client_rects`."),
}
}
