### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\viz\lyx_viz_bevy\src\plugin.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\viz\lyx_viz_bevy\src\plugin.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\viz\lyx_viz_bevy\src\plugin.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\viz\lyx_viz_bevy\src\plugin.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\viz\lyx_viz_bevy\src\plugin.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\viz\lyx_viz_bevy\src\plugin.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\viz\lyx_viz_bevy\src\plugin.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\viz\lyx_viz_bevy\src\plugin.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\viz\lyx_viz_bevy\src\plugin.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\viz\lyx_viz_bevy\src\plugin.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\viz\lyx_viz_bevy\src\plugin.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\viz\lyx_viz_bevy\src\plugin.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\viz\lyx_viz_bevy\src\plugin.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\viz\lyx_viz_bevy\src\plugin.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\viz\lyx_viz_bevy\src\plugin.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\viz\lyx_viz_bevy\src\plugin.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\viz\lyx_viz_bevy\src\plugin.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\viz\lyx_viz_bevy\src\plugin.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\viz\lyx_viz_bevy\src\plugin.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\viz\lyx_viz_bevy\src\plugin.rs
```rust
use bevy::prelude::*;

pub struct LeptosBevyCanvasPlugin;
impl Plugin for LeptosBevyCanvasPlugin {
    fn build(&self, app: &mut App) {
        app.add_message::<LeptosBevyCanvasCleanup>();
        app.add_systems(First, cleanup);
    }
}

#[derive(Message, Debug)]
pub struct LeptosBevyCanvasCleanup;
fn cleanup(
    mut cleanup_messages: MessageReader<LeptosBevyCanvasCleanup>,
    mut exit: MessageWriter<AppExit>,
) {
    for _ in cleanup_messages.read() {
        exit.write(AppExit::Success);
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
