### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_lyx-core-lyx_core_lyx-core-lyx_core_client_length.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_lyx-core-lyx_core_lyx-core-lyx_core_client_length.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_lyx-core-lyx_core_lyx-core-lyx_core_client_length.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_lyx-core-lyx_core_lyx-core-lyx_core_client_length.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_lyx-core-lyx_core_lyx-core-lyx_core_client_length.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_lyx-core-lyx_core_lyx-core-lyx_core_client_length.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_lyx-core-lyx_core_lyx-core-lyx_core_client_length.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_lyx-core-lyx_core_lyx-core-lyx_core_client_length.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_lyx-core-lyx_core_lyx-core-lyx_core_client_length.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_lyx-core-lyx_core_lyx-core-lyx_core_client_length.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_lyx-core-lyx_core_lyx-core-lyx_core_client_length.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_lyx-core-lyx_core_lyx-core-lyx_core_client_length.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_lyx-core-lyx_core_lyx-core-lyx_core_client_length.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_lyx-core-lyx_core_lyx-core-lyx_core_client_length.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_lyx-core-lyx_core_lyx-core-lyx_core_client_length.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_lyx-core-lyx_core_lyx-core-lyx_core_client_length.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_lyx-core-lyx_core_lyx-core-lyx_core_client_length.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_lyx-core-lyx_core_lyx-core-lyx_core_client_length.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_lyx-core-lyx_core_lyx-core-lyx_core_client_length.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_lyx-core-lyx_core_lyx-core-lyx_core_client_length.rs
use lyx_ui_foundations_utils::Length;
use web_sys::Element;

pub fn get_lyx-core-lyx_core_lyx-core-lyx_core_client_length(element: &Element, length: Length) -> f64 {
match length {
Length::Width => element.lyx-core-lyx_core_lyx-core-lyx_core_client_width() as f64,
Length::Height => element.lyx-core-lyx_core_lyx-core-lyx_core_client_height() as f64,
}
}
