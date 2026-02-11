### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\viz\lyx_viz_charts\leptos-chartistry\src\debug.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\viz\lyx_viz_charts\leptos-chartistry\src\debug.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\viz\lyx_viz_charts\leptos-chartistry\src\debug.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\viz\lyx_viz_charts\leptos-chartistry\src\debug.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\viz\lyx_viz_charts\leptos-chartistry\src\debug.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\viz\lyx_viz_charts\leptos-chartistry\src\debug.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\viz\lyx_viz_charts\leptos-chartistry\src\debug.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\viz\lyx_viz_charts\leptos-chartistry\src\debug.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\viz\lyx_viz_charts\leptos-chartistry\src\debug.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\viz\lyx_viz_charts\leptos-chartistry\src\debug.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\viz\lyx_viz_charts\leptos-chartistry\src\debug.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\viz\lyx_viz_charts\leptos-chartistry\src\debug.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\viz\lyx_viz_charts\leptos-chartistry\src\debug.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\viz\lyx_viz_charts\leptos-chartistry\src\debug.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\viz\lyx_viz_charts\leptos-chartistry\src\debug.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\viz\lyx_viz_charts\leptos-chartistry\src\debug.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\viz\lyx_viz_charts\leptos-chartistry\src\debug.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\viz\lyx_viz_charts\leptos-chartistry\src\debug.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\viz\lyx_viz_charts\leptos-chartistry\src\debug.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\viz\lyx_viz_charts\leptos-chartistry\src\debug.rs
```rust
use leptos::{either::Either, prelude::*};

use crate::bounds::Bounds;

#[component]
pub fn DebugRect(
    #[prop(into)] label: String,
    #[prop(into)] debug: Signal<bool>,
    #[prop(optional)] bounds: Vec<Signal<Bounds>>,
) -> impl IntoView {
    move || {
        if !debug.get() {
            return Either::Left(());
        };

        log::debug!("rendering {}", label);
        let rects = bounds
            .clone()
            .into_iter()
            .map(|bounds| {
                view! {
                    <rect
                        x=move || bounds.get().left_x()
                        y=move || bounds.get().top_y()
                        width=move || bounds.get().width()
                        height=move || bounds.get().height()
                        fill="none"
                        stroke="red"
                        stroke-width=1
                    />
                }
                .into_any()
            })
            .collect_view();
        Either::Right(rects)
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
```
```
```
```
