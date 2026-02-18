### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\lib.rs
//! Rust port of [Floating UI](https://floating-ui.com/).
//!
//! This is the library to use Floating UI on the web, wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apping [`lyx_ui_foundations_core`] with DOM interface logic.
//!
//! See [the Rust Floating UI book](https://floating-ui.rustforweb.org/) for more documenation.
//!
//! See [@floating-ui/dom](https://www.npmjs.com/package/@floating-ui/dom) for the original package.

mod auto_update;
mod middleware;
mod platform;
mod types;
mod utils;

pub use self::platform::Platform;
pub use crate::auto_update::*;
pub use crate::middleware::*;
pub use crate::types::*;
pub use lyx_ui_foundations_core::{
Boundary, ComputePositionReturn, Derivable, DerivableFn, DetectOverflowOptions, ElementContext,
Middleware, MiddlewareData, MiddlewareReturn, MiddlewareState, MiddlewareWithOptions,
RootBoundary,
};
#[doc(no_inline)]
pub use lyx_ui_foundations_utils::{
AlignedPlacement, Alignment, Axis, ClientRectObject, Coords, Dimensions, ElementRects, Length,
Padding, PartialSideObject, Placement, Rect, Side, SideObject, Strategy, VirtualElement, dom,
};

use lyx_ui_foundations_core::{
ComputePositionConfig as CoreComputePositionConfig, compute_position as compute_position_core,
};
use web_sys::Element;

const PLATFORM: Platform = Platform {};

/// Options for [`compute_position`].
#[derive(Clone, Default)]
pub struct ComputePositionConfig {
/// Where to place the floating element relative to the reference element.
///
/// Defaults to [`Placement::Bottom`].
pub placement: Option<Placement>,

/// The strategy to use when positioning the floating element.
///
/// Defaults to [`Strategy::Absolute`].
pub strategy: Option<Strategy>,

/// Vector of middleware objects to modify the positioning or provide data for rendering.
///
/// Defaults to an empty vector.
pub middleware: Option<MiddlewareVec>,
}

impl ComputePositionConfig {
/// Set `placement` option.
pub fn placement(mut self, value: Placement) -> Self {
self.placement = Some(value);
self
}

/// Set `strategy` option.
pub fn strategy(mut self, value: Strategy) -> Self {
self.strategy = Some(value);
self
}

/// Set `middleware` option.
pub fn middleware(mut self, value: MiddlewareVec) -> Self {
self.middleware = Some(value);
self
}
}

/// Computes the `x` and `y` coordinates that will place the floating element next to a given reference element.
pub fn compute_position(
reference: ElementOrVirtual,
floating: &Element,
config: ComputePositionConfig,
) -> ComputePositionReturn {
// TODO: cache

compute_position_core(
reference,
floating,
CoreComputePositionConfig {
platform: &PLATFORM,
placement: config.placement,
strategy: config.strategy,
middleware: config.middleware,
},
)
}
