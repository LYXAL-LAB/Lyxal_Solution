### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\viz\lyx_viz_map\leptos-leaflet\src\core\mod.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\viz\lyx_viz_map\leptos-leaflet\src\core\mod.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\viz\lyx_viz_map\leptos-leaflet\src\core\mod.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\viz\lyx_viz_map\leptos-leaflet\src\core\mod.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\viz\lyx_viz_map\leptos-leaflet\src\core\mod.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\viz\lyx_viz_map\leptos-leaflet\src\core\mod.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\viz\lyx_viz_map\leptos-leaflet\src\core\mod.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\viz\lyx_viz_map\leptos-leaflet\src\core\mod.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\viz\lyx_viz_map\leptos-leaflet\src\core\mod.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\viz\lyx_viz_map\leptos-leaflet\src\core\mod.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\viz\lyx_viz_map\leptos-leaflet\src\core\mod.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\viz\lyx_viz_map\leptos-leaflet\src\core\mod.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\viz\lyx_viz_map\leptos-leaflet\src\core\mod.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\viz\lyx_viz_map\leptos-leaflet\src\core\mod.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\viz\lyx_viz_map\leptos-leaflet\src\core\mod.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\viz\lyx_viz_map\leptos-leaflet\src\core\mod.rs
```rust
/*
 * Copyright (c) HeadlessStudio  2023.
 */
mod js_signals;
mod thread_safe_jsvalue;

pub use js_signals::*;
pub use thread_safe_jsvalue::{ThreadSafeJsValue, IntoThreadSafeJsValue};

pub trait IntoLatLng {
    fn into_lat_lng(self) -> leaflet::LatLng;
}

impl IntoLatLng for (f64, f64) {
    fn into_lat_lng(self) -> leaflet::LatLng {
        leaflet::LatLng::new(self.0, self.1)
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
```
```
```
```
```
```
