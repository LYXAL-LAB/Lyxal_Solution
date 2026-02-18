### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\utils\round_by_dpr.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\utils\round_by_dpr.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\utils\round_by_dpr.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\utils\round_by_dpr.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\utils\round_by_dpr.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\utils\round_by_dpr.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\utils\round_by_dpr.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\utils\round_by_dpr.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\utils\round_by_dpr.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\utils\round_by_dpr.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\utils\round_by_dpr.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\utils\round_by_dpr.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\utils\round_by_dpr.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\utils\round_by_dpr.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\utils\round_by_dpr.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\utils\round_by_dpr.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\utils\round_by_dpr.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\utils\round_by_dpr.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\utils\round_by_dpr.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\utils\round_by_dpr.rs
use web_sys::Element;

use crate::utils::get_dpr::get_dpr;

pub fn round_by_dpr(element: &Element, value: f64) -> f64 {
let dpr = get_dpr(element);
(value * dpr).round() / dpr
}
