### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\types.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\types.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\types.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\types.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\types.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\types.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\types.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\types.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\types.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\types.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\types.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\types.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\types.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\types.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\types.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\types.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\types.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\types.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\types.rs
use lyx_ui_foundations_core::{Boundary as CoreBoundary, Middleware};
use lyx_ui_foundations_utils::{
DefaultVirtualElement as CoreDefaultVirtualElement, ElementOrVirtual as CoreElementOrVirtual,
OwnedElementOrVirtual as CoreOwnedElementOrVirtual,
};
use web_sys::{Element, Window};

pub type Boundary = CoreBoundary<Element>;

pub type DefaultVirtualElement = CoreDefaultVirtualElement<Element>;
pub type ElementOrVirtual<'a> = CoreElementOrVirtual<'a, Element>;
pub type OwnedElementOrVirtual = CoreOwnedElementOrVirtual<Element>;

/// Vector of middleware used in [`ComputePositionConfig`][`crate::ComputePositionConfig`].
pub type MiddlewareVec = Vec<Box<dyn Middleware<Element, Window>>>;
