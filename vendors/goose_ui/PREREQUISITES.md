# Prerequisites

## Rust (Nightly)

```bash
# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Switch to nightly
rustup default nightly
```

## Leptos

```bash
# Install cargo-leptos
cargo install cargo-leptos

# Add WASM target
rustup target add wasm32-unknown-unknown
```

## Tauri

```bash
# Install Tauri CLI
cargo install tauri-cli

# macOS dependencies (if needed)
xcode-select --install
```

For other platforms, see [Tauri Prerequisites](https://v2.tauri.app/start/prerequisites/).

## pnpm

```bash
# Install pnpm
npm install -g pnpm
```
