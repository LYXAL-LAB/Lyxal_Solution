### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\frontend\src\components\toast.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\frontend\src\components\toast.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\frontend\src\components\toast.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\frontend\src\components\toast.rs
```rust
use leptos::*;

use super::alert::Alert;

#[component]
pub fn Toast(alerts: Vec<Alert>) -> impl IntoView {
    view! {
        <div class="toast toast-end z-[999999999]">

            {alerts
                .into_iter()
                .map(|alert| {
                    view! { <Alert alert /> }
                })
                .collect_view()}

        </div>
    }
}
```
```
```
```
