# Measurement and Benchmarking Guide

A comprehensive guide to measuring performance improvements and validating optimizations in Leptos ShadCN UI applications.

## Table of Contents

1. [Measurement Fundamentals](#measurement-fundamentals)
2. [Benchmarking Tools](#benchmarking-tools)
3. [Performance Metrics](#performance-metrics)
4. [Real-User Monitoring](#real-user-monitoring)
5. [A/B Testing](#ab-testing)
6. [Continuous Monitoring](#continuous-monitoring)

---

## 1. Measurement Fundamentals

### 1.1 Establishing a Baseline

Before making optimizations, establish baseline measurements:

```rust
use std::time::Instant;

pub struct PerformanceBaseline {
    pub initial_load_ms: f64,
    pub first_paint_ms: f64,
    pub frame_rate_fps: f64,
    pub memory_mb: f64,
    pub wasm_size_kb: f64,
}

pub async fn measure_baseline() -> PerformanceBaseline {
    let start = Instant::now();

    // Simulate user journey
    perform_initial_actions().await;

    let elapsed = start.elapsed();

    PerformanceBaseline {
        initial_load_ms: elapsed.as_millis() as f64,
        first_paint_ms: measure_first_paint().await,
        frame_rate_fps: measure_frame_rate().await,
        memory_mb: measure_memory_usage().await,
        wasm_size_kb: measure_wasm_size().await,
    }
}
```

### 1.2 Measuring Specific Operations

**Component Render Time**:

```rust
use leptos::*;
use web_sys::window;

pub fn measure_render<T, F>(name: &str, f: F) -> T
where
    F: FnOnce() -> T,
{
    let start = performance_now();
    let result = f();
    let elapsed = performance_now() - start;

    log::info!("{}: {:.2}ms", name, elapsed);

    if elapsed > 16.67 {
        // More than one frame at 60fps
        log::warn!("{} exceeded frame budget!", name);
    }

    result
}

fn performance_now() -> f64 {
    window()
        .and_then(|w| w.performance())
        .map(|p| p.now())
        .unwrap_or(0.0)
}

// Usage
view! {
    <div>
        {measure_render("header", || {
            view! { <Header /> }
        })}
    </div>
}
```

**Signal Update Performance**:

```rust
use std::time::Instant;

pub fn measure_signal_updates<T, F>(iterations: usize, f: F) -> Vec<f64>
where
    F: Fn() -> T,
{
    let mut timings = Vec::with_capacity(iterations);

    for _ in 0..iterations {
        let start = Instant::now();
        f();
        let elapsed = start.elapsed().as_secs_f64() * 1000.0;
        timings.push(elapsed);
    }

    timings
}

// Usage
let timings = measure_signal_updates(100, || {
    filtered_data.get();
});

let avg: f64 = timings.iter().sum::<f64>() / timings.len() as f64;
log::info!("Average signal access: {:.3}ms", avg);
```

### 1.3 Before/After Comparison Template

```rust
#[derive(Clone, Debug)]
pub struct OptimizationResult {
    pub optimization_name: String,
    pub before_ms: f64,
    pub after_ms: f64,
    pub improvement_percent: f64,
}

impl OptimizationResult {
    pub fn new(name: &str, before: f64, after: f64) -> Self {
        let improvement = ((before - after) / before) * 100.0;

        OptimizationResult {
            optimization_name: name.to_string(),
            before_ms: before,
            after_ms: after,
            improvement_percent: improvement,
        }
    }

    pub fn print_report(&self) {
        println!("=== {} ===", self.optimization_name);
        println!("Before: {:.2}ms", self.before_ms);
        println!("After:  {:.2}ms", self.after_ms);
        println!("Improvement: {:.1}%", self.improvement_percent);
        println!();
    }
}
```

---

## 2. Benchmarking Tools

### 2.1 Using the Performance Testing Package

This project includes a comprehensive benchmarking framework:

```bash
cd packages/performance-testing
cargo test --release -- --nocapture
```

**Writing Benchmarks**:

```rust
use lyx_ui_shadcn_performance_testing::*;

#[bench]
fn bench_button_render(b: &mut Bencher) {
    b.iter(|| {
        let view = view! { <Button /> };
        // Measure render time
    });
}

#[bench]
fn bench_signal_update(b: &mut Bencher) {
    let (signal, _) = signal(0);

    b.iter(|| {
        signal.update(|n| *n += 1);
    });
}
```

### 2.2 Criterion Benchmarks

**Add to Cargo.toml**:

```toml
[dev-dependencies]
criterion = "0.5"

[[bench]]
name = "component_benchmark"
harness = false
```

**Create benchmarks/benchmarks.rs**:

```rust
use criterion::{black_box, criterion_group, criterion_main, Criterion};
use leptos::*;

fn benchmark_button_click(c: &mut Criterion) {
    c.bench_function("button_click", |b| {
        b.iter(|| {
            let view = view! { <Button>"Click me"</Button> };
            black_box(view);
        });
    });
}

fn benchmark_list_render(c: &mut Criterion) {
    let items: Vec<i32> = (0..1000).collect();

    c.bench_function("list_render_1000", |b| {
        b.iter(|| {
            let view = view! {
                <For
                    each=move || items.clone()
                    key=|item| *item
                    children=|item| view! { <div>{item}</div> }
                />
            };
            black_box(view);
        });
    });
}

criterion_group!(
    benches,
    benchmark_button_click,
    benchmark_list_render
);
criterion_main!(benches);
```

**Run benchmarks**:

```bash
cargo bench
```

### 2.3 Custom Benchmark Harness

```rust
use std::time::{Duration, Instant};

pub struct Benchmark {
    name: String,
    iterations: usize,
    warmup_iterations: usize,
}

impl Benchmark {
    pub fn new(name: &str, iterations: usize) -> Self {
        Benchmark {
            name: name.to_string(),
            iterations,
            warmup_iterations: iterations / 10,
        }
    }

    pub fn run<T, F>(&self, f: F) -> BenchmarkResult
    where
        F: Fn() -> T,
    {
        // Warmup
        for _ in 0..self.warmup_iterations {
            f();
        }

        // Actual benchmark
        let mut timings = Vec::with_capacity(self.iterations);

        for _ in 0..self.iterations {
            let start = Instant::now();
            f();
            timings.push(start.elapsed());
        }

        BenchmarkResult::new(&self.name, timings)
    }
}

#[derive(Clone, Debug)]
pub struct BenchmarkResult {
    pub name: String,
    pub min_ms: f64,
    pub max_ms: f64,
    pub avg_ms: f64,
    pub median_ms: f64,
    pub p95_ms: f64,
    pub p99_ms: f64,
}

impl BenchmarkResult {
    fn new(name: &str, timings: Vec<Duration>) -> Self {
        let mut ms_timings: Vec<f64> = timings
            .into_iter()
            .map(|d| d.as_secs_f64() * 1000.0)
            .collect();

        ms_timings.sort_by(|a, b| a.partial_cmp(b).unwrap());

        let len = ms_timings.len();

        BenchmarkResult {
            name: name.to_string(),
            min_ms: ms_timings[0],
            max_ms: ms_timings[len - 1],
            avg_ms: ms_timings.iter().sum::<f64>() / len as f64,
            median_ms: ms_timings[len / 2],
            p95_ms: ms_timings[(len as f64 * 0.95) as usize],
            p99_ms: ms_timings[(len as f64 * 0.99) as usize],
        }
    }

    pub fn print(&self) {
        println!("=== {} ===", self.name);
        println!("Min:    {:.3}ms", self.min_ms);
        println!("Avg:    {:.3}ms", self.avg_ms);
        println!("Median: {:.3}ms", self.median_ms);
        println!("P95:    {:.3}ms", self.p95_ms);
        println!("P99:    {:.3}ms", self.p99_ms);
        println!("Max:    {:.3}ms", self.max_ms);
        println!();
    }
}

// Usage
let bench = Benchmark::new("signal_update", 1000);
let (signal, _) = signal(0);
let result = bench.run(|| {
    signal.update(|n| *n += 1);
});
result.print();
```

---

## 3. Performance Metrics

### 3.1 Core Web Vitals

**Measurement Implementation**:

```rust
use web_sys::{PerformanceObserver, PerformanceObserverEntry};

pub fn observe_core_web_vitals() {
    let window = web_sys::window().unwrap();
    let performance = window.performance().unwrap();

    // LCP (Largest Contentful Paint)
    let lcp_callback = Closure::wrap(Box::new(move |entries: Vec<PerformanceObserverEntry>| {
        for entry in entries {
            log::info!("LCP: {:.2}ms", entry.duration());
        }
    }) as Box<dyn Fn(Vec<PerformanceObserverEntry>)>);

    let lcp_observer = PerformanceObserver::new(&lcp_callback).unwrap();
    lcp_observer.observe_with_options(
        &web_sys::PerformanceObserverInit::new(
            web_sys::PerformanceEntryType::LargestContentfulPaint
        )
    ).unwrap();
    lcp_callback.forget();

    // FID (First Input Delay)
    let fid_callback = Closure::wrap(Box::new(move |entries: Vec<PerformanceObserverEntry>| {
        for entry in entries {
            log::info!("FID: {:.2}ms", entry.duration());
        }
    }) as Box<dyn Fn(Vec<PerformanceObserverEntry>)>);

    let fid_observer = PerformanceObserver::new(&fid_callback).unwrap();
    fid_observer.observe_with_options(
        &web_sys::PerformanceObserverInit::new(
            web_sys::PerformanceEntryType::FirstInput
        )
    ).unwrap();
    fid_callback.forget();

    // CLS (Cumulative Layout Shift)
    let cls_callback = Closure::wrap(Box::new(move |entries: Vec<PerformanceObserverEntry>| {
        for entry in entries {
            if let Some(value) = entry.value() {
                log::info!("CLS: {:.4}", value);
            }
        }
    }) as Box<dyn Fn(Vec<PerformanceObserverEntry>)>);

    let cls_observer = PerformanceObserver::new(&cls_callback).unwrap();
    cls_observer.observe_with_options(
        &web_sys::PerformanceObserverInit::new(
            web_sys::PerformanceEntryType::LayoutShift
        )
    ).unwrap();
    cls_callback.forget();
}
```

### 3.2 Custom Metrics

**Time to Interactive (TTI)**:

```rust
pub async fn measure_tti() -> f64 {
    let start = performance_now();

    // Wait for network to be quiet (no requests for 5 seconds)
    let mut last_request_time = start;
    let mut quiet_period = 0.0;

    while quiet_period < 5000.0 {
        // Check for network activity
        if has_pending_requests() {
            last_request_time = performance_now();
        }

        quiet_period = performance_now() - last_request_time;
        gloo_timers::future::sleep(Duration::from_millis(100)).await;
    }

    performance_now() - start
}
```

**First Meaningful Paint (FMP)**:

```rust
pub fn measure_fmp() -> f64 {
    // Use performance API to find layout changes
    let window = web_sys::window().unwrap();
    let performance = window.performance().unwrap();

    let entries = performance.get_entries_by_type("paint").unwrap();
    let mut fmp = 0.0;

    for entry in entries {
        let name = entry.name();
        if name == "first-contentful-paint" {
            fmp = entry.start_time();
        }
    }

    fmp
}
```

### 3.3 Memory Metrics

```rust
use web_sys::window;

#[derive(Clone, Debug)]
pub struct MemoryMetrics {
    pub used_js_heap_size_mb: f64,
    pub total_js_heap_size_mb: f64,
    pub js_heap_size_limit_mb: f64,
}

pub fn measure_memory() -> Option<MemoryMetrics> {
    let window = web_sys::window()?;
    let performance = window.performance()?;

    if let Some(memory) = performance.memory() {
        Some(MemoryMetrics {
            used_js_heap_size_mb: memory.used_js_heap_size() as f64 / 1024.0 / 1024.0,
            total_js_heap_size_mb: memory.total_js_heap_size() as f64 / 1024.0 / 1024.0,
            js_heap_size_limit_mb: memory.js_heap_size_limit() as f64 / 1024.0 / 1024.0,
        })
    } else {
        None
    }
}

// Memory leak detection
pub async fn detect_memory_leaks(duration_secs: u64) -> Vec<f64> {
    let mut measurements = Vec::new();
    let interval = Duration::from_secs(5);
    let iterations = duration_secs / 5;

    for _ in 0..iterations {
        if let Some(memory) = measure_memory() {
            measurements.push(memory.used_js_heap_size_mb);
        }
        gloo_timers::future::sleep(interval).await;
    }

    measurements
}
```

---

## 4. Real-User Monitoring (RUM)

### 4.1 Client-Side Telemetry

```rust
use serde::{Deserialize, Serialize};

#[derive(Clone, Serialize, Deserialize)]
pub struct TelemetryEvent {
    pub event_type: String,
    pub duration_ms: f64,
    pub timestamp: f64,
    pub url: String,
    pub user_agent: String,
}

pub fn send_telemetry(event: TelemetryEvent) {
    let window = web_sys::window().unwrap();
    let navigator = window.navigator();

    let mut event_with_context = event.clone();
    event_with_context.user_agent = navigator.user_agent().unwrap_or_default();
    event_with_context.url = window.location().href().unwrap_or_default();
    event_with_context.timestamp = performance_now();

    // Send to analytics endpoint
    spawn_local(async move {
        if let Ok(client) = reqwest::Client::new().post("/api/telemetry") {
            if let Ok(_) = client.json(&event_with_context).send().await {
                log::info!("Telemetry sent");
            }
        }
    });
}

// Usage wrapper
pub fn track_operation<F, T>(name: &str, f: F) -> T
where
    F: FnOnce() -> T,
{
    let start = performance_now();
    let result = f();
    let duration = performance_now() - start;

    send_telemetry(TelemetryEvent {
        event_type: name.to_string(),
        duration_ms: duration,
        timestamp: performance_now(),
        url: String::new(),
        user_agent: String::new(),
    });

    result
}
```

### 4.2 Error Tracking

```rust
#[derive(Clone, Serialize, Deserialize)]
pub struct ErrorEvent {
    pub message: String,
    pub stack: String,
    pub url: String,
    pub line: u32,
    pub column: u32,
}

pub fn setup_error_tracking() {
    let window = web_sys::window().unwrap();

    let error_handler = Closure::wrap(Box::new(move |event: ErrorEvent| {
        let error = ErrorEvent {
            message: event.message().unwrap_or_default(),
            stack: String::new(), // Browser-dependent
            url: event.filename().unwrap_or_default(),
            line: event.lineno(),
            column: event.colno(),
        };

        log::error!("Error tracked: {:?}", error);
        send_error_report(error);
    }) as Box<dyn Fn(ErrorEvent)>);

    window.set_onerror(Some(error_handler.as_ref().unchecked_ref()));
    error_handler.forget();
}
```

---

## 5. A/B Testing

### 5.1 Feature Flag System

```rust
use std::collections::HashMap;

#[derive(Clone, Debug)]
pub struct FeatureFlags {
    flags: HashMap<String, bool>,
}

impl FeatureFlags {
    pub fn new() -> Self {
        FeatureFlags {
            flags: HashMap::new(),
        }
    }

    pub fn is_enabled(&self, flag: &str) -> bool {
        self.flags.get(flag).copied().unwrap_or(false)
    }

    pub async fn load_from_remote() -> Self {
        // Fetch from remote config
        let response = reqwest::get("/api/feature-flags").await;
        let mut flags = FeatureFlags::new();

        if let Ok(resp) = response {
            if let Ok(data) = resp.json::<HashMap<String, bool>>().await {
                flags.flags = data;
            }
        }

        flags
    }
}

// Usage in components
#[component]
pub fn OptimizedComponent() -> impl IntoView {
    let flags = create_resource(
        || (),
        |_| FeatureFlags::load_from_remote()
    );

    view! {
        {move || {
            flags.get().map(|f| {
                if f.is_enabled("new-optimized-renderer") {
                    view! { <OptimizedVersion /> }
                } else {
                    view! { <StandardVersion /> }
                }
            })
        }}
    }
}
```

### 5.2 Experiment Tracking

```rust
#[derive(Clone, Serialize, Deserialize)]
pub struct ExperimentEvent {
    pub experiment_name: String,
    pub variant: String,
    pub metrics: HashMap<String, f64>,
}

pub fn track_experiment_metrics(
    experiment: &str,
    variant: &str,
    metrics: HashMap<String, f64>,
) {
    let event = ExperimentEvent {
        experiment_name: experiment.to_string(),
        variant: variant.to_string(),
        metrics,
    };

    spawn_local(async move {
        if let Ok(client) = reqwest::Client::new().post("/api/experiments") {
            let _ = client.json(&event).send().await;
        }
    });
}
```

---

## 6. Continuous Monitoring

### 6.1 Performance Audit Integration

```bash
# Run the built-in performance audit
cd performance-audit
cargo run
```

**Automated Audits**:

```rust
#[cfg(test)]
mod performance_tests {
    use super::*;

    #[tokio::test]
    async fn test_render_time_under_16ms() {
        let start = Instant::now();
        let component = render_test_component();
        let elapsed = start.elapsed();

        assert!(elapsed.as_millis() < 16, "Component render exceeded frame budget");
    }

    #[tokio::test]
    async fn test_memory_growth_acceptable() {
        let initial = measure_memory().unwrap().used_js_heap_size_mb;

        // Run operations
        perform_many_operations();

        let final_memory = measure_memory().unwrap().used_js_heap_size_mb;
        let growth = final_memory - initial;

        assert!(growth < 10.0, "Memory growth exceeded 10MB");
    }
}
```

### 6.2 CI/CD Integration

**GitHub Actions Workflow**:

```yaml
name: Performance Tests

on:
  pull_request:
    branches: [main]

jobs:
  benchmark:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions-rs/toolchain@v1
        with:
          toolchain: stable

      - name: Run benchmarks
        run: |
          cargo bench -- --output-format bencher | tee benchmark.txt

      - name: Store benchmark result
        uses: benchmark-action/github-action-benchmark@v1
        with:
          tool: 'cargo'
          output-file-path: benchmark.txt
          github-token: ${{ secrets.GITHUB_TOKEN }}
          auto-push: false
          alert-threshold: '150%'
```

### 6.3 Performance Dashboard

```rust
#[derive(Clone, Serialize, Deserialize)]
pub struct DashboardMetrics {
    pub p50_load_time: f64,
    pub p95_load_time: f64,
    pub p99_load_time: f64,
    pub error_rate: f64,
    pub avg_frame_rate: f64,
}

pub async fn aggregate_metrics(days: u32) -> DashboardMetrics {
    // Fetch metrics from analytics
    // Calculate percentiles
    // Return dashboard data

    DashboardMetrics {
        p50_load_time: 1200.0,
        p95_load_time: 3400.0,
        p99_load_time: 5100.0,
        error_rate: 0.02,
        avg_frame_rate: 58.5,
    }
}
```

---

## Measurement Checklist

### Pre-Optimization
- [ ] Establish baseline metrics
- [ ] Set performance budgets
- [ ] Configure measurement tools
- [ ] Document current state

### During Measurement
- [ ] Run multiple iterations
- [ ] Test on various devices
- [ ] Use realistic data
- [ ] Record environmental conditions

### Post-Measurement
- [ ] Calculate improvements
- [ ] Compare to baseline
- [ ] Document findings
- [ ] Share results

---

## Quick Reference

### Common Performance Budgets

| Metric | Budget | Measurement |
|--------|--------|-------------|
| First Paint | <1s | DevTools Performance |
| Time to Interactive | <3s | Custom measurement |
| Frame Rate | ≥55fps | requestAnimationFrame |
| Memory | <50MB | performance.memory |
| WASM Size | <500KB | ls -lh |
| API Latency | <500ms | Performance API |

### Measurement Commands

```bash
# Component benchmarks
cargo bench

# Size analysis
cargo build --release
ls -lh target/wasm32-unknown-unknown/release/*.wasm

# Performance audit
cd performance-audit && cargo run

# Lighthouse score
npx lighthouse https://your-app.com
```

---

## Summary

Effective performance measurement requires:

1. **Baseline Establishment**: Know where you start
2. **Consistent Methodology**: Use the same measurements
3. **Multiple Metrics**: Don't focus on just one number
4. **Real Conditions**: Test with realistic data and devices
5. **Continuous Monitoring**: Make measurement ongoing

By following the patterns in this guide, you can accurately measure performance improvements and validate that your optimizations have the intended impact.

---

*For optimization strategies, see the [Performance Optimization Guide](./PERFORMANCE_OPTIMIZATION_GUIDE.md). For profiling techniques, see the [Profiling Quick Reference](./PROFILING_QUICK_REFERENCE.md).*
