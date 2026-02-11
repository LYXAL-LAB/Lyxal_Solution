### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\viz\lyx_viz_trading\trading-charts\src\data\options\tracking_mode\tracking_mode.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\viz\lyx_viz_trading\trading-charts\src\data\options\tracking_mode\tracking_mode.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\viz\lyx_viz_trading\trading-charts\src\data\options\tracking_mode\tracking_mode.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\viz\lyx_viz_trading\trading-charts\src\data\options\tracking_mode\tracking_mode.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\viz\lyx_viz_trading\trading-charts\src\data\options\tracking_mode\tracking_mode.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\viz\lyx_viz_trading\trading-charts\src\data\options\tracking_mode\tracking_mode.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\viz\lyx_viz_trading\trading-charts\src\data\options\tracking_mode\tracking_mode.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\viz\lyx_viz_trading\trading-charts\src\data\options\tracking_mode\tracking_mode.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\viz\lyx_viz_trading\trading-charts\src\data\options\tracking_mode\tracking_mode.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\viz\lyx_viz_trading\trading-charts\src\data\options\tracking_mode\tracking_mode.rs
```rust
use super::TrackingModeExitMode;
use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize, Default, Clone)]
pub struct TrackingModeOptions {
    #[serde(rename = "exitMode", default)]
    exit_mode: TrackingModeExitMode,
}

impl TrackingModeOptions {
    pub fn new() -> Self {
        Self::default()
    }

    pub fn new_with_exit_mode(exit_mode: TrackingModeExitMode) -> Self {
        Self {
            exit_mode,
        }
    }

    pub fn exit_mode(&self) -> &TrackingModeExitMode {
        &self.exit_mode
    }

    pub fn set_exit_mode(&mut self, exit_mode: TrackingModeExitMode) {
        self.exit_mode = exit_mode;
    }
}
```
```
```
```
```
```
```
```
```
```
