### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx-found-floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\tests\visual\src\spec\virtual_element.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx-found-floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\tests\visual\src\spec\virtual_element.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\tests\visual\src\spec\virtual_element.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\tests\visual\src\spec\virtual_element.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\tests\visual\src\spec\virtual_element.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\tests\visual\src\spec\virtual_element.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\tests\visual\src\spec\virtual_element.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\tests\visual\src\spec\virtual_element.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\tests\visual\src\spec\virtual_element.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\tests\visual\src\spec\virtual_element.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\tests\visual\src\spec\virtual_element.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\tests\visual\src\spec\virtual_element.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\tests\visual\src\spec\virtual_element.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\tests\visual\src\spec\virtual_element.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\tests\visual\src\spec\virtual_element.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\tests\visual\src\spec\virtual_element.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\tests\visual\src\spec\virtual_element.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\tests\visual\src\spec\virtual_element.rs
use std::rc::Rc;

use floating_ui_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos::{
DefaultVirtualElement, Strategy, UseFloatingOptions, UseFloatingReturn, VirtualElement,
use_floating,
};
use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_node_ref::AnyNodeRef;

use crate::utils::use_scroll::{UseScrollOptions, UseScrollReturn, use_scroll};

#[component]
pub fn VirtualElement() -> impl IntoView {
let reference_ref = AnyNodeRef::new();
let floating_ref = AnyNodeRef::new();
let virtual_element = MaybeProp::derive(move || {
let context_element = reference_ref.get();
context_element.map(|context_element| {
let element: &web_sys::Element = context_element.as_ref();
(Box::new(
DefaultVirtualElement::new(Rc::new({
let context_element = context_element.clone();

move || context_element.get_bounding_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_client_rect().into()
}))
.context_element(element.clone()),
) as Box<dyn VirtualElement<web_sys::Element>>)
.into()
})
});

let UseFloatingReturn {
x,
y,
strategy,
update,
..
} = use_floating(
virtual_element,
floating_ref,
UseFloatingOptions::default()
.strategy(Strategy::Fixed)
.while_elements_mounted_auto_update(),
);

let UseScrollReturn { scroll_ref, .. } = use_scroll(UseScrollOptions {
reference_ref,
floating_ref,
update,
rtl: None::<bool>.into(),
disable_ref_updates: None,
});

view! {
<h1>Virtual Element</h1>
<p></p>
<div class="container">
<div node_ref=scroll_ref class="scroll" data-x="" style:position="relative">
<div node_ref=reference_ref class="reference">
Reference
</div>
</div>
</div>

<div
node_ref=floating_ref
class="floating"
style:position=move || format!("{:?}", strategy.get()).to_lowercase()
style:top=move || format!("{}px", y.get())
style:left=move || format!("{}px", x.get())
>
Floating
</div>
}
}
