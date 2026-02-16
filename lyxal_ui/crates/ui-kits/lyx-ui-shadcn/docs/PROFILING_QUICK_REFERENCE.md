# Profiling Quick Reference

A quick reference guide for profiling Leptos ShadCN UI applications to identify performance bottlenecks.

## Table of Contents
1. [Quick Start](#quick-start)
2. [Browser DevTools](#browser-devtools)
3. [WASM Profiling](#wasm-profiling)
4. [Signal Analysis](#signal-analysis)
5. [Network Analysis](#network-analysis)
6. [Common Bottlenecks](#common-bottlenecks)

---

## Quick Start

### 5-Minute Performance Check

```bash
# 1. Build optimized release
cargo build --release --target wasm32-unknown-unknown

# 2. Run performance audit
cd performance-audit && cargo run

# 3. Open browser DevTools and record interaction
# 4. Check results
```

### Essential Metrics

| Metric | Good | Needs Work |
|--------|------|------------|
| Frame Rate | ≥55fps | <30fps |
| Long Tasks | <50ms | >100ms |
| First Paint | <1s | >3s |
| WASM Size | <500KB | >2MB |
| Memory | <50MB | >100MB |

---

## Browser DevTools

### Chrome Performance Tab

**Keyboard Shortcut**: `Ctrl+Shift+I` → Performance tab

**Recording Workflow**:

1. Click **Record** (or press `Ctrl+E`)
2. Perform action to profile
3. Click **Stop**
4. Analyze the timeline

**Key Sections**:

```
┌─────────────────────────────────────────┐
│ Frames                                   │ ← Look for >16ms gaps
├─────────────────────────────────────────┤
│ Main Thread                             │ ← Tall red bars = long tasks
│   ├─ Evaluate Script                    │ ← JavaScript execution
│   ├─ Compile Script                     │ ← WASM compilation
│   ├─ Parse HTML                         │ ← HTML parsing
│   ├─ Layout                             │ ← Reflows (expensive)
│   └─ Paint                              │ ← Rendering
├─────────────────────────────────────────┤
│ GPU                                     │ ← Composite layers
└─────────────────────────────────────────┘
```

**What to Look For**:

| Pattern | Issue | Solution |
|---------|-------|----------|
| Tall red bars | Blocking tasks | Break into smaller chunks |
| Frequent layouts | Layout thrashing | Batch DOM reads/writes |
| Long compile times | Large WASM | Code splitting |
| Choppy frames | Heavy rendering | Virtualization |

### Firefox Performance Tools

**Firefox-Specific Features**:

- **Call Tree**: Hierarchical view of function calls
- **Flame Chart**: Visual timeline of execution
- **JavaScript Tracer**: Step-by-step execution
- **Memory Snapshots**: Heap analysis

### Memory Profiling

**Chrome Memory Tab Workflow**:

1. Open DevTools → **Memory** tab
2. Select **Heap snapshot**
3. Take baseline snapshot
4. Perform actions
5. Take second snapshot
6. Compare for leaks

**Memory Leak Checklist**:

```javascript
// Check for:
// 1. Detached DOM nodes
// 2. Event listeners not removed
// 3. Unclosed intervals/timeouts
// 4. Growing object graphs
// 5. Unreleased signals
```

### Network Profiling

**Network Tab Analysis**:

```bash
# Check for:
- Large WASM files (>500KB)
- Missing compression (gzip/brotli)
- Slow API responses
- Too many requests (waterfall)
- Missing caching headers
```

---

## WASM Profiling

### Build with Profiling Symbols

```bash
# Build with debug info
cargo build --profile release-debug

# Or build for profiling
RUSTFLAGS='-g' cargo build --release
```

### Use Chrome's WASM Profiler

```javascript
// In browser console
performance.mark('wasm-start');
// Run WASM operation
performance.mark('wasm-end');
performance.measure('wasm-operation', 'wasm-start', 'wasm-end');

const measure = performance.getEntriesByName('wasm-operation')[0];
console.log(`WASM took ${measure.duration}ms`);
```

### WASM Memory Inspection

```rust
// Add to main.rs or lib.rs
#[cfg(debug_assertions)]
fn log_wasm_memory() {
    use wasm_bindgen::JsCast;

    if let Some(memory) = wasm_bindgen::memory() {
        let buffer = memory.buffer();
        let byte_length = buffer.byte_length();
        log::info!("WASM Memory: {} MB", byte_length / 1024 / 1024);
    }
}

// Call periodically
set_interval_with_handle(
    || log_wasm_memory(),
    Duration::from_secs(10),
    &mut timer_handle
);
```

### Flamegraph Generation

```bash
# Install inferno for flamegraphs
cargo install inferno

# Record with perf (Linux)
cargo flamegraph --bin your-app

# Or use Firefox Profiler
# 1. Open about:profiling
# 2. Start recording
# 3. Run your app
# 4. Stop and export flamegraph
```

---

## Signal Analysis

### Identify Over-Reactive Signals

```rust
use std::time::Instant;

// Wrap signal derivation for timing
fn timed_signal<F, T>(name: &str, f: F) -> Signal<T>
where
    F: Fn() -> T + 'static,
    T: 'static,
{
    Signal::derive(move || {
        let start = Instant::now();
        let result = f();
        let elapsed = start.elapsed();

        if elapsed.as_millis() > 1 {
            log::warn!("Signal '{}' took {:?}", name, elapsed);
        }

        result
    })
}

// Usage
let filtered = timed_signal("filter_items", || {
    items.get()
        .into_iter()
        .filter(|x| x.active)
        .collect::<Vec<_>>()
});
```

### Signal Update Frequency

```rust
use std::collections::HashMap;

struct SignalTracker {
    update_counts: HashMap<String, usize>,
}

impl SignalTracker {
    fn track(&mut self, name: &str) {
        *self.update_counts.entry(name.to_string()).or_insert(0) += 1;
    }

    fn report(&self) {
        for (name, count) in &self.update_counts {
            log::info!("Signal '{}' updated {} times", name, count);
        }
    }
}
```

### Signal Dependency Analysis

```rust
// Check signal dependencies manually
// Use leptos-devtools to visualize signal graph

// In development mode
#[cfg(debug_assertions)]
fn log_signal_dependencies() {
    log::info!("Signal graph available in leptos-devtools");
}
```

---

## Network Analysis

### Lazy Loading Timing

```rust
use leptos::*;

#[component]
pub fn LazyComponent(
    name: String,
) -> impl IntoView {
    let (loaded, set_loaded) = signal(false);
    let (load_time, set_load_time) = signal(0.0);

    Effect::new(move |_| {
        let start = performance_now();

        // Simulate/component load
        spawn_local(async move {
            load_component(&name).await;
            let elapsed = performance_now() - start;
            set_load_time.set(elapsed);
            set_loaded.set(true);
        });
    });

    view! {
        <div>
            {move || if loaded.get() {
                format!("Loaded in {:.2}ms", load_time.get())
            } else {
                "Loading...".to_string()
            }}
        </div>
    }
}

fn performance_now() -> f64 {
    web_sys::window()
        .and_then(|w| w.performance())
        .map(|p| p.now())
        .unwrap_or(0.0)
}
```

### API Request Profiling

```rust
use leptos::*;

#[component]
pub fn DataFetcher() -> impl IntoView {
    let data = create_resource(
        || (),
        |_| async move {
            let start = performance_now();

            let result = fetch_data().await;

            let elapsed = performance_now() - start;
            log::info!("API call took {:.2}ms", elapsed);

            result
        }
    );

    view! {
        {move || data.get().map(|d| view! { <div>{d}</div> })}
    }
}
```

---

## Common Bottlenecks

### 1. Large List Rendering

**Symptoms**:
- Long scripts in timeline
- Choppy scrolling
- High memory usage

**Detection**:
```javascript
// In console
performance.mark('render-start');
// Trigger list render
performance.mark('render-end');
performance.measure('list-render', 'render-start', 'render-end');
```

**Solution**: Virtual scrolling (see main guide)

### 2. Excessive Signal Updates

**Symptoms**:
- Constant re-renders
- High CPU usage
- Low frame rate

**Detection**:
```rust
let update_count = ArcRwSignal::new(0);

Effect::new(move |_| {
    let _ = some_signal.get();
    update_count.update(|c| *c += 1);

    log::warn!("Signal updated {} times", update_count.get());
});
```

**Solution**: Memoization and batching

### 3. Layout Thrashing

**Symptoms**:
- Frequent layout calculations
- Reading DOM after writing
- Recurring layouts in timeline

**Detection**:
```javascript
// Look for pattern in profiler:
// Layout (read) → Script (write) → Layout (read)
// = Layout thrashing
```

**Solution**: Batch DOM reads/writes

### 4. Memory Leaks

**Symptoms**:
- Growing memory usage
- Detached DOM nodes
- Unclosed resources

**Detection**:
```bash
# Take multiple heap snapshots and compare
# Look for:
# - Increasing number of detached DOM nodes
# - Growing object graphs
# - Event listeners with retained references
```

**Solution**: Proper cleanup in effects

### 5. Large WASM Bundle

**Symptoms**:
- Long initial load
- Slow WASM compilation
- High memory on load

**Detection**:
```bash
ls -lh target/wasm32-unknown-unknown/release/*.wasm

# Analyze contents
wasm-objdump -x -d input.wasm | head -n 100

# Check for unused code
wasm-snip input.wasm -o output.wasm
```

**Solution**: Code splitting, lazy loading

---

## Profiling Checklist

### Before Starting
- [ ] Reproduce issue in isolation
- [ ] Create reproducible test case
- [ ] Set up performance budgets
- [ ] Choose profiling tools

### During Profiling
- [ ] Record baseline metrics
- [ ] Profile with realistic data
- [ ] Capture multiple scenarios
- [ ] Save profiles for comparison

### After Profiling
- [ ] Identify top 3 bottlenecks
- [ ] Prioritize by impact
- [ ] Document findings
- [ ] Plan optimizations

---

## Quick Commands Reference

```bash
# Build and size
cargo build --release --target wasm32-unknown-unknown
ls -lh target/wasm32-unknown-unknown/release/*.wasm

# Optimize WASM
wasm-opt -Oz -o optimized.wasm input.wasm

# Tree shaking check
wasm-snip input.wasm -o output.wasm

# Run performance audit
cd performance-audit && cargo run

# Generate flamegraph
cargo flamegraph --bin your-app

# Check bundle
cargo install cargo-bloat
cargo bloat --release --crates
```

---

## Tooling Reference

### Built-in Tools

| Tool | Location | Purpose |
|------|----------|---------|
| Performance Audit | `performance-audit/` | Comprehensive monitoring |
| Performance Testing | `packages/performance-testing/` | Benchmarking |
| Signal Management | `packages/signal-management/` | Signal lifecycle |

### Browser Tools

| Browser | Tools | Best For |
|---------|-------|----------|
| Chrome | Performance, Memory, Network | General profiling |
| Firefox | Performance, Memory, Debugger | WASM debugging |
| Safari | Timelines, Web Inspector | iOS testing |

### External Tools

| Tool | Install | Use |
|------|---------|-----|
| wasm-opt | `cargo install wasm-opt` | WASM optimization |
| wasm-snip | `cargo install wasm-snip` | Dead code elimination |
| flamegraph | `cargo install inferno` | Flamegraph generation |
| lighthouse | `npm install -g lighthouse` | Performance audit |

---

## Tips and Tricks

### 1. Profile Early and Often

Don't wait until the end to profile. Make profiling part of your development workflow.

### 2. Use Real Data

Synthetic data can hide performance issues. Test with realistic data sizes and structures.

### 3. Profile on Low-End Devices

Your high-end machine might mask issues. Test on slower devices to catch problems.

### 4. Measure What Matters

Focus on metrics that affect user experience: frame rate, interaction latency, load time.

### 5. Document Everything

Keep a record of your profiles and findings. They'll be invaluable when issues resurface.

---

## Next Steps

After identifying bottlenecks:

1. Review the [Performance Optimization Guide](./PERFORMANCE_OPTIMIZATION_GUIDE.md)
2. Implement targeted optimizations
3. Re-profile to measure improvements
4. Document your findings

---

*For detailed optimization strategies, see the [Performance Optimization Guide](./PERFORMANCE_OPTIMIZATION_GUIDE.md).*
