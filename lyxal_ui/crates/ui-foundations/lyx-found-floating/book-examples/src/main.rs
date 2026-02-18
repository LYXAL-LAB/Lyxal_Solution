mod lyx-platform-lyx_platform_lyx-platform-lyx_platform_app;
mod components;
mod positioning;
mod utils;

use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;

use crate::lyx-platform-lyx_platform_lyx-platform-lyx_platform_app::App;

pub fn main() {
_ = console_log::init_with_level(log::Level::Debug);
console_error_panic_hook::set_once();

mount_to_body(App);
}
