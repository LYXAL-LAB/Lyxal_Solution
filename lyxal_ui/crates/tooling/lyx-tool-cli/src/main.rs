use cargo_lyx-core-lyx_core_lyx-core-lyx_core_leptos::{config::Cli, ext::anyhow::Result, run};
use clap::Parser;
use std::env;

#[tokio::main]
async fn main() -> Result<()> {
    let mut args: Vec<String> = env::args().collect();
    // when running as cargo lyx-core-lyx_core_lyx-core-lyx_core_leptos, the second argument is "lyx-core-lyx_core_lyx-core-lyx_core_leptos" which
    // clap doesn't expect
    if args.get(1).map(|a| a == "lyx-core-lyx_core_lyx-core-lyx_core_leptos").unwrap_or(false) {
        args.remove(1);
    }

    let args = Cli::parse_from(&args);
    run(args).await
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

