# WASM Bundle Size Optimization

This document describes the optimizations applied to reduce the WASM bundle size below 2MB.

## Overview

The leptos-shadcn-ui-wasm package has been optimized to produce a WASM bundle under 2MB. The current optimized size is approximately **1.89 MB** (1,910,770 bytes).

## Build Configuration

### 1. Cargo Config (`.cargo/config.toml`)

The project uses a custom cargo configuration with aggressive size optimizations:

```toml
[target.wasm32-unknown-unknown]
rustflags = [
    "-C", "link-arg=-s",               # Strip symbols
    "-C", "opt-level=z",               # Optimize for size
    "-C", "embed-bitcode=no",          # Don't embed bitcode
    "-C", "debuginfo=0",               # No debug info
    "-C", "debug-assertions=off",      # Disable debug assertions
    "-C", "overflow-checks=off",       # Disable overflow checks
    "-C", "panic=abort",               # Reduce panic table size
    "-C", "strip=symbols",             # Strip all symbols
    "-C", "inline-threshold=32",       # Aggressive inlining
    "-C", "linker-plugin-lto",         # Enable LTO
]
```

### 2. Profile Configuration (Cargo.toml)

Multiple optimization profiles are configured:

#### wasm-release profile
```toml
[profile.wasm-release]
inherits = "release"
opt-level = "z"        # Maximum size optimization
lto = "fat"            # Full link-time optimization
codegen-units = 1      # Single codegen unit for maximum optimization
panic = "abort"        # Abort on panic (smaller code)
strip = "symbols"      # Strip everything
debug = false
incremental = false    # Disable incremental for smaller builds
```

### 3. Library Configuration

The `leptos-shadcn-ui-wasm/Cargo.toml` is configured to produce both library and WASM outputs:

```toml
[lib]
crate-type = ["cdylib", "rlib"]
```

## Optimization Techniques

### Compiler Optimizations

1. **Link-Time Optimization (LTO)**: `lto = "fat"` enables full LTO across all crates
2. **Optimize for Size**: `opt-level = "z"` uses the most aggressive size optimization
3. **Single Codegen Unit**: `codegen-units = 1` allows maximum optimization but slower builds
4. **Panic Strategy**: `panic = "abort"` eliminates unwinding tables
5. **Symbol Stripping**: Removes all debug symbols and metadata
6. **Disable Incremental**: Reduces binary size at the cost of rebuild speed

### wasm-opt Post-Processing

Using `wasm-opt` from the binaryen package provides additional size reduction:

```bash
wasm-opt --enable-bulk-memory -Oz -o output.wasm input.wasm
```

This provides approximately 9% additional size reduction.

## Building Optimized WASM

### Quick Build

```bash
make build-wasm-optimized
```

This runs the optimization script which:
1. Cleans previous builds
2. Builds with wasm-release profile
3. Applies wasm-opt optimizations (if available)
4. Reports final size

### Manual Build

```bash
# Build with optimization profile
cargo build --profile wasm-release --target wasm32-unknown-unknown -p leptos-shadcn-ui-wasm

# Apply wasm-opt manually (optional but recommended)
wasm-opt --enable-bulk-memory -Oz -o optimized.wasm \
    target/wasm32-unknown-unknown/wasm-release/leptos_shadcn_ui_wasm.wasm
```

## Results

| Metric | Value |
|--------|-------|
| Target Size | 2,097,152 bytes (2 MB) |
| Current Size | 1,910,770 bytes (1.89 MB) |
| Margin | 186,382 bytes (9% under target) |
| Reduction from Original | ~191,031 bytes (~9%) |

## Further Optimization Options

If you need to reduce size further:

### 1. Use Feature Flags

Build only with the components you need:

```toml
[dependencies]
leptos-shadcn-ui-wasm = {
    version = "0.2",
    features = ["button", "input", "card"],  # Only what you need
    default-features = false
}
```

### 2. Use Core Components Only

The `core-components` feature includes only essential components:

```bash
cargo build --profile wasm-release --target wasm32-unknown-unknown \
    -p leptos-shadcn-ui-wasm --no-default-features --features core-components
```

### 3. Dependency Reduction

Review and remove unused dependencies from your own code.

## Installation Requirements

### Required

- Rust stable toolchain
- `wasm32-unknown-unknown` target: `rustup target add wasm32-unknown-unknown`

### Optional (Recommended)

- **binaryen**: Provides `wasm-opt` for additional 9% size reduction
  - Ubuntu/Debian: `sudo apt-get install binaryen`
  - macOS: `brew install binaryen`

## Troubleshooting

### Build exceeds 2MB

1. Ensure wasm-opt is installed and being used
2. Check that you're using the `wasm-release` profile
3. Verify no debug features are enabled
4. Consider using feature flags to exclude unused components

### Slow builds

The `wasm-release` profile is optimized for size, not build speed. For development:

```bash
cargo build --target wasm32-unknown-unknown -p leptos-shadcn-ui-wasm
```

Use the optimized profile only for production builds.

## Related Files

- `.cargo/config.toml` - Global cargo configuration
- `Cargo.toml` - Workspace optimization profiles
- `packages/leptos-shadcn-ui-wasm/Cargo.toml` - WASM package configuration
- `scripts/build-wasm-optimized.sh` - Automated build script
- `Makefile` - Build targets (`make build-wasm-optimized`)
