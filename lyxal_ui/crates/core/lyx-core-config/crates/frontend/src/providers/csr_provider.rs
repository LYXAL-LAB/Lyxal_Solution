### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\frontend\src\providers\csr_provider.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\frontend\src\providers\csr_provider.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\frontend\src\providers\csr_provider.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\frontend\src\providers\csr_provider.rs
```rust
use derive_more::Deref;
use leptos::*;

#[derive(Deref, Clone, Copy)]
pub struct Csr(bool);

#[component]
pub fn ClientSideReadyProvider(children: Children) -> impl IntoView {
    let csr_rws = RwSignal::new(Csr(false));
    Effect::new(move |_| csr_rws.set(Csr(true)));
    provide_context(Signal::<Csr>::from(csr_rws));

    children()
}

pub fn use_client_side_ready() -> Signal<Csr> {
    use_context::<Signal<Csr>>().unwrap()
}
```
```
```
```
