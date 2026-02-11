### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\frontend\src\components\experiment_form\types.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\frontend\src\components\experiment_form\types.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\frontend\src\components\experiment_form\types.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\frontend\src\components\experiment_form\types.rs
```rust
use serde_json::Map;
use superposition_types::{Exp, Overrides, api::experiments::VariantUpdateRequest};

use crate::types::VariantFormT;

impl TryFrom<VariantFormT> for VariantUpdateRequest {
    type Error = String;
    fn try_from(value: VariantFormT) -> Result<Self, Self::Error> {
        Ok(Self {
            id: value.id,
            overrides: Exp::<Overrides>::try_from(Map::from_iter(value.overrides))?,
        })
    }
}

impl FromIterator<VariantFormT> for Result<Vec<VariantUpdateRequest>, String> {
    fn from_iter<T: IntoIterator<Item = VariantFormT>>(iter: T) -> Self {
        iter.into_iter()
            .map(VariantUpdateRequest::try_from)
            .collect()
    }
}
```
```
```
```
