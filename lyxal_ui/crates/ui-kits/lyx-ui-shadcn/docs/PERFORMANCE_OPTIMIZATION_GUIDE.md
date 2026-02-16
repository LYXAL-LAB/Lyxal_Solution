# Performance Optimization Guide

This guide provides comprehensive best practices for optimizing performance in Leptos ShadCN UI applications. It covers profiling methodologies, implementation strategies, and measurement techniques to ensure your applications run efficiently.

## Table of Contents

1. [Profiling to Identify Bottlenecks](#profiling-to-identify-bottlenecks)
2. [Implementing Optimizations](#implementing-optimizations)
3. [Measuring Performance Improvements](#measuring-performance-improvements)
4. [Common Performance Patterns](#common-performance-patterns)
5. [Tooling and Resources](#tooling-and-resources)

---

## 1. Profiling to Identify Bottlenecks

### 1.1 Browser DevTools Profiling

#### Chrome/Firefox DevTools Performance Tab

**When to use:** For identifying runtime performance issues, long tasks, and rendering bottlenecks.

**Key Metrics to Monitor:**
- **Frame Rate**: Target 60fps (16.67ms per frame)
- **Long Tasks**: Tasks taking >50ms indicate blocking operations
- **Layout Thrashing**: Repeated forced synchronous layouts
- **Paint Time**: Excessive paint operations

**Profiling Workflow:**

1. **Open DevTools** → Performance tab
2. **Start Recording**
3. **Interact with your application** (navigate, click, type)
4. **Stop Recording**
5. **Analyze the flame graph** for:
   - Red tall bars (long tasks)
   - Recurring patterns (indicates loops)
   - Script execution vs. rendering

**Example Analysis:**
```javascript
// Look for patterns like this in flame graph:
// Evaluate Script (50ms+) → Long task needs optimization
// Layout (10ms+) → Consider virtualization
// Paint (15ms+) → Reduce DOM complexity
```

#### React/Leptos DevTools Profiler

Use the performance audit system in this project:

```bash
# Run the performance audit
cd performance-audit
cargo run
```

**What it measures:**
- Component render times
- Bundle size per component
- Memory usage patterns
- Signal update frequencies

### 1.2 WebAssembly Profiling

#### WASM Memory Profiling

**Check memory usage:**

```rust
// Add to your main.rs for development
#[cfg(debug_assertions)]
leptos::logging::log!("WASM Memory: {:?}", wasm_bindgen::memory());
```

**Common memory issues:**
- Memory leaks from unclosed signals
- Excessive string allocations
- Unoptimized data structures

#### Performance Timeline Analysis

```rust
// Use console timing for profiling specific operations
use web_sys::console;

console::time_with_label("component_render");
// ... component code
console::time_end_with_label("component_render");
```

### 1.3 Signal Granularity Analysis

**Identify over-reactive signals:**

```rust
// BAD: Signal updates too frequently
let items = Signal::derive(move || {
    // Recalculates on ANY state change
    expensive_operation(&state.get())
});

// GOOD: Memoized with specific dependencies
let items = ArcMemo::new(move |_| {
    // Only recalculates when relevant data changes
    expensive_operation(&specific_data.get())
});
```

**Profile signal performance:**

```rust
use std::time::Instant;

let start = Instant::now();
let derived = Signal::derive(move || { /* ... */ });
let elapsed = start.elapsed();
log::warn!("Signal derivation took: {:?}", elapsed);
```

### 1.4 Bundle Size Analysis

**Analyze component bundle sizes:**

```bash
# Build with wasm optimization
cargo build --release --target wasm32-unknown-unknown

# Check size
ls -lh target/wasm32-unknown-unknown/release/*.wasm
```

**Use wasm-snip for dead code elimination:**

```bash
cargo install wasm-snip
wasm-snip target/wasm32-unknown-unknown/release/*.wasm -o snipped.wasm
```

### 1.5 Network Performance

**Profile lazy loading:**

```rust
// Add timing instrumentation
Effect::new(move |_| {
    let start = Instant::now();

    // Load component
    load_component();

    let elapsed = start.elapsed();
    log::info!("Component loaded in {:?}", elapsed);
});
```

---

## 2. Implementing Optimizations

### 2.1 Signal Optimization

#### Use ArcMemo for Expensive Computations

**Pattern: Cache derived values**

```rust
use lyx_ui_shadcn_signal_management::ArcMemo;

// BEFORE: Recalculates on every access
let filtered_data = Signal::derive(move || {
    data.get()
        .into_iter()
        .filter(|x| complex_filter(x))
        .collect::<Vec<_>>()
});

// AFTER: Cached until dependencies change
let filtered_data = ArcMemo::new(move |_| {
    data.get()
        .into_iter()
        .filter(|x| complex_filter(x))
        .collect::<Vec<_>>()
});
```

**When to use ArcMemo:**
- Expensive calculations (>1ms)
- Complex transformations
- Filtering large lists (>100 items)
- Sorting operations
- Data aggregations

#### Batch Signal Updates

**Pattern: Reduce re-renders with batching**

```rust
use leptos::*;

// BEFORE: Triggers multiple re-renders
set_a.update(|a| *a += 1);
set_b.update(|b| *b += 1);
set_c.update(|c| *c += 1);

// AFTER: Single re-render
batch(move || {
    set_a.update(|a| *a += 1);
    set_b.update(|b| *b += 1);
    set_c.update(|c| *c += 1);
});
```

#### Use Signal-managed Components

**Pattern: Leverage the signal management system**

```rust
use lyx_ui_shadcn_signal_management::{ArcRwSignal, ArcMemo};

#[component]
pub fn OptimizedComponent(
    #[prop(into, optional)] value: Signal<i32>,
) -> impl IntoView {
    // Persistent state across renders
    let state = ArcRwSignal::new(ComponentState::default());

    // Memoized computed values
    let display_value = ArcMemo::new(move |_| {
        format!("Value: {}", value.get())
    });

    view! {
        <div class={move || display_value.get()} />
    }
}
```

### 2.2 Rendering Optimization

#### Implement Virtual Scrolling

**For large lists (>100 items):**

```rust
use leptos::*;

#[component]
pub fn VirtualList<T>(
    items: Signal<Vec<T>>,
    #[prop(default = 20)] item_height: usize,
    #[prop(default = 400)] viewport_height: usize,
) -> impl IntoView
where
    T: Clone + 'static,
{
    let (scroll_top, set_scroll_top) = signal(0);

    let visible_range = Signal::derive(move || {
        let start = (scroll_top.get() / item_height) as usize;
        let visible_count = (viewport_height / item_height) + 2;
        let end = (start + visible_count).min(items.get().len());
        (start, end)
    });

    view! {
        <div
            style:height={format!("{}px", viewport_height)}
            style:overflow="auto"
            on:scroll=move |e| {
                let target = e.target().unwrap();
                set_scroll_top.set(target.unchecked_ref::<web_sys::Element>().scroll_top() as usize);
            }
        >
            <div style:height={format!("{}px", items.get().len() * item_height)}>
                <div style:transform=move || format!("translateY({}px)", visible_range.get().0 * item_height)>
                    {move || {
                        let (start, end) = visible_range.get();
                        items.get()[start..end].to_vec()
                    }}
                </div>
            </div>
        </div>
    }
}
```

#### Use View Transition API

**Smooth state transitions:**

```rust
Effect::new(move |_| {
    if let Some(document) = web_sys::window().and_then(|w| w.document()) {
        if document.start_view_transition().is_ok() {
            // Update state during transition
            batch(move || {
                // Update multiple signals
            });
        }
    }
});
```

#### Key Elements for List Optimization

```rust
// Always provide stable keys for list items
view! {
    <ul>
        <For
            each=move || items.get()
            key=|item| item.id // Stable key
            children=|item| view! { <li>{item.name}</li> }
        />
    </ul>
}
```

### 2.3 Lazy Loading

#### Component Lazy Loading

**Use the lazy-loading system:**

```rust
use lyx_ui_shadcn_lazy_loading::LazyComponent;

view! {
    <LazyComponent
        name="heavy-component"
        fallback=move || view! { <div>"Loading..."</div> }
    />
}
```

**Route-based code splitting:**

```rust
use leptos_router::*;

#[component]
pub fn App() -> impl IntoView {
    view! {
        <Router>
            <Routes>
                <Route path="/" view=Home />
                // Lazy load heavy dashboard
                <Route
                    path="/dashboard"
                    view=move || {
                        let dashboard = leptos::lazy(|| {
                            view! { <Dashboard /> }
                        });
                        dashboard
                    }
                />
            </Routes>
        </Router>
    }
}
```

#### Image Lazy Loading

```rust
// Use native lazy loading
view! {
    <img
        src="image.jpg"
        loading="lazy"
        decoding="async"
        alt="Description"
    />
}
```

### 2.4 Memory Optimization

#### Clean Up Effects and Resources

```rust
use leptos::*;

let cleanup = Effect::new(move |_| {
    let observer = setup_observer();

    // Return cleanup function
    move || {
        observer.disconnect();
    }
});

// Explicit cleanup when needed
on_cleanup(move || {
    cleanup.dispose();
});
```

#### Use Efficient Data Structures

```rust
// For large collections, use indexed access
let items = ArcRwSignal::new(Vec::new()); // Fast iteration, indexed access

// For lookups, use HashMap
let item_map = ArcRwSignal::new(HashMap::new()); // Fast lookups

// For ordered data, use BTreeMap
let ordered_items = ArcRwSignal::new(BTreeMap::new()); // Sorted iteration
```

#### Avoid Closure Allocations in Hot Paths

```rust
// BAD: Creates new closure each call
fn process_item<F: Fn(&Item) -> bool>(items: &[Item], filter: F) -> Vec<&Item> {
    items.iter().filter(|x| filter(x)).collect()
}

// GOOD: Reuse closure where possible
let filter_closure = |item: &Item| -> bool { item.active };

for batch in items.chunks(100) {
    let filtered: Vec<_> = batch.iter()
        .filter(|x| filter_closure(x))
        .collect();
}
```

### 2.5 WASM-Specific Optimizations

#### Enable Link-Time Optimization

```toml
# Cargo.toml
[profile.release]
opt-level = "z"     # Optimize for size
lto = "fat"         # Full link-time optimization
codegen-units = 1   # Single codegen unit for better optimization
```

#### Use wasm-opt

```bash
# Install binaryen
cargo install wasm-opt

# Optimize WASM
wasm-opt -Oz -o output.wasm input.wasm
```

#### Minimize Dependencies

```toml
# Only include what you need
[dependencies]
leptos = { version = "0.8", features = ["csr"], default-features = false }

# For SSR builds
[dependencies.leptos]
version = "0.8"
features = ["ssr"]
```

---

## 3. Measuring Performance Improvements

### 3.1 Benchmarking Framework

**Use the performance-testing package:**

```rust
use lyx_ui_shadcn_performance_testing::*;

#[bench]
fn bench_component_render(b: &mut Bencher) {
    b.iter(|| {
        let component = view! { <MyComponent /> };
        // Measure render time
    });
}
```

### 3.2 Real User Monitoring (RUM)

**Track metrics in production:**

```rust
use web_sys::window;

Effect::new(move |_| {
    let start = performance_now();

    // Perform operation

    let duration = performance_now() - start;

    // Send to analytics
    log_performance_metric("operation_name", duration);
});

fn performance_now() -> f64 {
    window()
        .and_then(|w| w.performance())
        .map(|p| p.now())
        .unwrap_or(0.0)
}
```

### 3.3 Core Web Vitals

**Track essential metrics:**

```rust
// Largest Contentful Paint (LCP)
let lcp_observer = web_sys::PerformanceObserver::new(&observer);
lcp_observer.observe(&web_sys::PerformanceObserverInit::new(
    web_sys::PerformanceEntryType::LargestContentfulPaint,
));

// First Input Delay (FID)
let fid_observer = web_sys::PerformanceObserver::new(&observer);
fid_observer.observe(&web_sys::PerformanceObserverInit::new(
    web_sys::PerformanceEntryType::FirstInput,
));

// Cumulative Layout Shift (CLS)
let cls_observer = web_sys::PerformanceObserver::new(&observer);
cls_observer.observe(&web_sys::PerformanceObserverInit::new(
    web_sys::PerformanceEntryType::LayoutShift,
));
```

### 3.4 Before/After Comparison

**Document your improvements:**

```markdown
## Optimization: List Rendering

### Before
- Render time: 450ms for 1000 items
- Frame rate: 12fps
- Memory: 45MB

### After (Virtual Scrolling)
- Render time: 15ms for 1000 items
- Frame rate: 60fps
- Memory: 12MB

### Improvement
- **30x faster rendering**
- **5x frame rate improvement**
- **73% memory reduction**
```

### 3.5 Performance Budgets

**Set budgets in your project:**

```json
// .lighthouserc.json
{
  "budgets": [
    {
      "path": "./pkg/*.wasm",
      "sizes": [
        {
          "maxSize": "500KB",
          "label": "WASM bundle"
        }
      ]
    },
    {
      "path": "./pkg/*.js",
      "sizes": [
        {
          "maxSize": "200KB",
          "label": "JS bundle"
        }
      ]
    }
  ]
}
```

---

## 4. Common Performance Patterns

### 4.1 Throttling and Debouncing

**Debounce user input:**

```rust
use std::time::Duration;

#[component]
pub fn SearchInput() -> impl IntoView {
    let (query, set_query) = signal(String::new());
    let (debounced_query, set_debounced) = signal(String::new());

    // Debounce with timer
    let debounce_timer = ArcRwSignal::new(None::<TimeoutHandle>);

    Effect::new(move |_| {
        let q = query.get();

        debounce_timer.update(|timer| {
            if let Some(handle) = timer.take() {
                handle.clear();
            }

            *timer = Some(set_timeout_with_handle(
                move || {
                    set_debounced.set(q);
                },
                Duration::from_millis(300),
            ).ok());
        });
    });

    view! {
        <input
            type="text"
            on:input=move |e| {
                set_query.set(event_target_value(&e));
            }
            prop:value=move || query.get()
        />
    }
}
```

### 4.2 Request Optimization

**Batch API requests:**

```rust
let pending_requests = ArcRwSignal::new(Vec::new());

Effect::new(move |_| {
    let requests = pending_requests.get();

    if !requests.is_empty() {
        // Batch fetch
        spawn_local(async move {
            let results = fetch_batch(&requests).await;
            // Process results
            pending_requests.set(Vec::new());
        });
    }
});
```

### 4.3 Selective Re-rendering

**Use components to isolate updates:**

```rust
#[component]
pub fn ExpensiveRow(
    data: Signal<Item>,
) -> impl IntoView {
    // Only re-renders when data changes
    view! {
        <div class="row">
            {move || data.get().name}
        </div>
    }
}

#[component]
pub fn Table(
    items: Signal<Vec<Item>>,
) -> impl IntoView {
    view! {
        <div class="table">
            <For
                each=move || items.get()
                key=|item| item.id
                children=|item| view! {
                    <ExpensiveRow data=Signal::derive(move || item.clone()) />
                }
            />
        </div>
    }
}
```

### 4.4 SSR Optimization

**Preload critical data:**

```rust
#[server]
async fn prefetch_data(id: String) -> Result<Data, ServerFnError> {
    // Fetch data on server
    fetch_data(&id).await
}

// In component
let data = create_resource(
    move || props.id.get(),
    |id| prefetch_data(id)
);
```

---

## 5. Tooling and Resources

### 5.1 Built-in Tools

This project includes comprehensive performance tooling:

- **Performance Audit**: `performance-audit/` - Comprehensive monitoring
- **Performance Testing**: `packages/performance-testing/` - Benchmarking framework
- **Signal Management**: `packages/signal-management/` - Advanced signal lifecycle

### 5.2 External Tools

#### Chrome DevTools
- Performance Profiler
- Memory Profiler
- Coverage Analysis

#### Firefox DevTools
- Performance Profiler
- Memory Profiler
- WebIDE for debugging

#### CLI Tools

```bash
# Bundle analysis
cargo install wasm-snip
wasm-snip input.wasm -o output.wasm

# Tree shaking
wasm-opt -Oz -o optimized.wasm input.wasm

# Performance audit
npm install -g lighthouse
lighthouse https://your-app.com --view
```

### 5.3 VS Code Extensions

- `rust-analyzer` - Rust language support
- `WASM` - WebAssembly support
- `Error Lens` - Inline error display

### 5.4 Additional Resources

- [Leptos Performance Guide](https://book.leptos.dev/performance.html)
- [MDN Web Performance](https://developer.mozilla.org/en-US/docs/Web/Performance)
- [WebAssembly Performance](https://webassembly.org/docs/future-features)

---

## Quick Reference Checklist

### Before Optimizing
- [ ] Profile with browser DevTools
- [ ] Identify actual bottlenecks
- [ ] Establish baseline metrics
- [ ] Set performance budgets

### While Optimizing
- [ ] Use `ArcMemo` for expensive computations
- [ ] Batch signal updates
- [ ] Implement virtual scrolling for lists
- [ ] Lazy load components and routes
- [ ] Clean up effects and resources

### After Optimizing
- [ ] Re-profile with DevTools
- [ ] Compare metrics to baseline
- [ ] Document improvements
- [ ] Run performance tests
- [ ] Monitor in production

---

## Summary

Performance optimization is an iterative process:

1. **Profile First** - Always identify actual bottlenecks before optimizing
2. **Optimize Strategically** - Focus on high-impact changes
3. **Measure Everything** - Validate improvements with metrics
4. **Iterate Continuously** - Performance is an ongoing concern

The Leptos ShadCN UI framework provides excellent tools and patterns for building high-performance applications. By following the patterns in this guide and leveraging the built-in performance infrastructure, you can ensure your applications remain fast and responsive as they scale.
