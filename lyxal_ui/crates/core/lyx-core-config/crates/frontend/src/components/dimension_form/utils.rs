### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\frontend\src\components\dimension_form\utils.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\frontend\src\components\dimension_form\utils.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\frontend\src\components\dimension_form\utils.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\frontend\src\components\dimension_form\utils.rs
```rust
use serde_json::Value;
use superposition_types::{
    ExtendedMap,
    api::dimension::UpdateRequest,
    database::models::{ChangeReason, Description, cac::Position},
};

pub fn try_update_payload(
    position: u32,
    schema: Value,
    value_validation_function_name: Option<String>,
    value_compute_function_name: Option<String>,
    description: String,
    change_reason: String,
) -> Result<UpdateRequest, String> {
    Ok(UpdateRequest {
        position: Some(Position::from(position)),
        schema: Some(ExtendedMap::try_from(schema)?),
        value_validation_function_name: Some(value_validation_function_name),
        value_compute_function_name: Some(value_compute_function_name),
        description: Some(Description::try_from(description)?),
        change_reason: ChangeReason::try_from(change_reason)?,
    })
}
```
```
```
```
