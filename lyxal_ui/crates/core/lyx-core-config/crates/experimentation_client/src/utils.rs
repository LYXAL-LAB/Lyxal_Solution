### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_experimentation_lyx-core-lyx_core_lyx-core-lyx_core_client\src\utils.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_experimentation_lyx-core-lyx_core_lyx-core-lyx_core_client\src\utils.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_experimentation_lyx-core-lyx_core_lyx-core-lyx_core_client\src\utils.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_experimentation_lyx-core-lyx_core_lyx-core-lyx_core_client\src\utils.rs
use std::fmt;

pub trait MapError<T> {
fn map_err_to_string(self) -> Result<T, String>;
}

impl<T, E> MapError<T> for Result<T, E>
where
E: fmt::Display,
{
fn map_err_to_string(self) -> Result<T, String> {
self.map_err(|e| e.to_string())
}
}
