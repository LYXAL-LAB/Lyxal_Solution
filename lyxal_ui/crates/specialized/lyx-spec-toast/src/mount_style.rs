### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\mount_style.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\mount_style.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\mount_style.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\mount_style.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\mount_style.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\mount_style.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\mount_style.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\mount_style.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\mount_style.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\mount_style.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\mount_style.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\mount_style.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\mount_style.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\mount_style.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\mount_style.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\mount_style.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\mount_style.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\mount_style.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\mount_style.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\mount_style.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\mount_style.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\mount_style.rs
use cfg_if::cfg_if;
pub fn mount_style(id: &str, content: &'static str) {
let id = format!("lyx-core-lyx_core_lyx-core-lyx_core_leptos-color-id-{id}");
cfg_if! {
if #[cfg(feature = "ssr")] {
use lyx-core-lyx_core_lyx-core-lyx_core_leptos::view;
use lyx-core-lyx_core_lyx-core-meta::Style;
let _ = view! {
<Style id=id>
{content}
</Style>
};
} else {
use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::document;
let head = document().head().expect("head no exist");
let style = head
.query_selector(&format!("style#{id}"))
.expect("query style element error");

if style.is_some() {
return;
}

let style = document()
.create_element("style")
.expect("create style element error");
_ = style.set_attribute("id", &id);
style.set_text_content(Some(content));
_ = head.prepend_with_node_1(&style);
}
}
}
