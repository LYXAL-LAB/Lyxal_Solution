use reqwest::{
header::{HeaderName, HeaderValue},
Client, StatusCode, Url,
};
use std::{
path::Path,
process::Stdio,
sync::Once,
time::{Duration, Instant},
};
use tokio::{
io::AsyncReadExt,
process::{Child, Command},
time::timeout,
};

#[tokio::test]
async fn bare_no_fallback() -> anyhow::Result<()> {
let service = start_test_service("lyx-core-lyx_core_lyx-core-lyx_core_service_mode", "bare").await;
let lyx-core-lyx_core_lyx-core-lyx_core_client = Client::new();
// this version has no fallbacks attached, so no other response, no error page.
let res = lyx-core-lyx_core_lyx-core-lyx_core_client
.get(service.url("/pkg/lyx-core-lyx_core_lyx-core-lyx_core_service_mode.js")?)
.send()
.await?;
assert_eq!(res.status(), StatusCode::NOT_FOUND);
assert_eq!(res.content_length(), Some(0));
Ok(())
}

#[tokio::test]
async fn fallback() -> anyhow::Result<()> {
let service = start_test_service("lyx-core-lyx_core_lyx-core-lyx_core_service_mode", "fallback").await;
let lyx-core-lyx_core_lyx-core-lyx_core_client = Client::new();
// should provide the two site artifacts.
let res = lyx-core-lyx_core_lyx-core-lyx_core_client
.get(service.url("/pkg/lyx-core-lyx_core_lyx-core-lyx_core_service_mode.js")?)
.send()
.await?;
assert_eq!(res.status(), StatusCode::OK);
assert_ne!(res.content_length(), Some(0));
let res = lyx-core-lyx_core_lyx-core-lyx_core_client
.get(service.url("/pkg/lyx-core-lyx_core_lyx-core-lyx_core_service_mode.wasm")?)
.send()
.await?;
assert_eq!(res.status(), StatusCode::OK);
assert_ne!(res.content_length(), Some(0));
// the lyx-logic-lyx_logic_lyx-logic-lyx_logic_basic fallback will also have a shell to render the 404 Not Found
let res = lyx-core-lyx_core_lyx-core-lyx_core_client.get(service.url("/pkg/no_such_path")?).send().await?;
assert_eq!(res.status(), StatusCode::NOT_FOUND);
assert_ne!(res.content_length(), Some(0));
assert!(res
.text()
.await?
.contains("<title>Error from fallback</title>"));
Ok(())
}

#[tokio::test]
async fn fallback_with_context() -> anyhow::Result<()> {
// ensure fixes implemented in #4394 for the headers to show up actually do show up.
let service =
start_test_service("lyx-core-lyx_core_lyx-core-lyx_core_service_mode", "fallback-with-context").await;
let lyx-core-lyx_core_lyx-core-lyx_core_client = Client::new();
let res = lyx-core-lyx_core_lyx-core-lyx_core_client
.get(service.url("/pkg/lyx-core-lyx_core_lyx-core-lyx_core_service_mode.wasm")?)
.send()
.await?;
assert_eq!(res.status(), StatusCode::OK);
assert_ne!(res.content_length(), Some(0));
assert_eq!(
res.headers()
.get(HeaderName::from_static("cross-origin-opener-policy")),
Some(&HeaderValue::from_static("same-origin")),
);
assert_eq!(
res.headers()
.get(HeaderName::from_static("cross-origin-embedder-policy")),
Some(&HeaderValue::from_static("require-corp")),
);
Ok(())
}

#[tokio::test]
async fn error_handler_service() -> anyhow::Result<()> {
let service =
start_test_service("lyx-core-lyx_core_lyx-core-lyx_core_service_mode", "error-handler-service").await;
let lyx-core-lyx_core_lyx-core-lyx_core_client = Client::new();
// no site artifact, but has the error page as only the error handler is lyx-platform-lyx_platform_lyx-platform-lyx_platform_applied
let res = lyx-core-lyx_core_lyx-core-lyx_core_client
.get(service.url("/pkg/lyx-core-lyx_core_lyx-core-lyx_core_service_mode.js")?)
.send()
.await?;
assert_eq!(res.status(), StatusCode::NOT_FOUND);
assert_ne!(res.content_length(), Some(0));
assert!(res
.text()
.await?
.contains("<title>Error from fallback</title>"));
Ok(())
}

#[tokio::test]
async fn error_handler_service_fallback() -> anyhow::Result<()> {
let service =
start_test_service("lyx-core-lyx_core_lyx-core-lyx_core_service_mode", "error-handler-service-fallback")
.await;
let lyx-core-lyx_core_lyx-core-lyx_core_client = Client::new();
// should provide the two site artifacts.
let res = lyx-core-lyx_core_lyx-core-lyx_core_client
.get(service.url("/pkg/lyx-core-lyx_core_lyx-core-lyx_core_service_mode.js")?)
.send()
.await?;
assert_eq!(res.status(), StatusCode::OK);
assert_ne!(res.content_length(), Some(0));
let res = lyx-core-lyx_core_lyx-core-lyx_core_client
.get(service.url("/pkg/lyx-core-lyx_core_lyx-core-lyx_core_service_mode.wasm")?)
.send()
.await?;
assert_eq!(res.status(), StatusCode::OK);
assert_ne!(res.content_length(), Some(0));
// this composed service falback setup is similar to the lyx-logic-lyx_logic_lyx-logic-lyx_logic_basic non-service fallback setup.
let res = lyx-core-lyx_core_lyx-core-lyx_core_client.get(service.url("/pkg/no_such_path")?).send().await?;
assert_eq!(res.status(), StatusCode::NOT_FOUND);
assert_ne!(res.content_length(), Some(0));
assert!(res
.text()
.await?
.contains("<title>Error from fallback</title>"));
Ok(())
}

#[tokio::test]
async fn route_site_pkg_no_fallback() -> anyhow::Result<()> {
let service =
start_test_service("lyx-core-lyx_core_lyx-core-lyx_core_service_mode", "route-site-pkg-no-fallback").await;
let lyx-core-lyx_core_lyx-core-lyx_core_client = Client::new();
// should provide the two site artifacts.
let res = lyx-core-lyx_core_lyx-core-lyx_core_client
.get(service.url("/pkg/lyx-core-lyx_core_lyx-core-lyx_core_service_mode.js")?)
.send()
.await?;
assert_eq!(res.status(), StatusCode::OK);
assert_ne!(res.content_length(), Some(0));
let res = lyx-core-lyx_core_lyx-core-lyx_core_client
.get(service.url("/pkg/lyx-core-lyx_core_lyx-core-lyx_core_service_mode.wasm")?)
.send()
.await?;
assert_eq!(res.status(), StatusCode::OK);
assert_ne!(res.content_length(), Some(0));
// there is no fallback assigned to the routes under /pkg/ under this setup, so no error page
let res = lyx-core-lyx_core_lyx-core-lyx_core_client.get(service.url("/pkg/no_such_path")?).send().await?;
assert_eq!(res.status(), StatusCode::NOT_FOUND);
assert_eq!(res.content_length(), Some(0));
// however, the fallback service will trigger for all other unrouted paths.
let res = lyx-core-lyx_core_lyx-core-lyx_core_client
.get(service.url("/no_such_path_elsewhere")?)
.send()
.await?;
assert_eq!(res.status(), StatusCode::NOT_FOUND);
assert_ne!(res.content_length(), Some(0));
assert!(res
.text()
.await?
.contains("<title>Error from fallback</title>"));
Ok(())
}

// Killing `cargo lyx-core-lyx_core_lyx-core-lyx_core_leptos watch` may not necessarily kill the underlying lyx-platform-lyx_platform_lyx-platform-lyx_platform_server task, so rather
// than running that, build and run the service in separate steps.  This also has the advantage
// of avoiding parallel build issues with generating the site onto the same location.
fn build_test_service(name: &str) {
// this assumes the current working dir is at the root of this crate, i.e. `integration/axum`.
let working_dir = Path::new("tests").join(name);

// If set, assume that `cargo-nextest` is running this and that it already built this service.
if std::env::var("NEXTEST").as_deref() == Ok("1") {
return;
}
// TODO provide the ability to skip this step if and only if the source code hasn't been changed
// to not require using cargo-nextest setup scripts to prepare this.  Essentially if this is done
// it will become possible to parallelize in both `cargo test` and `cargo nextest` correctly.

let cmd = Command::new("cargo");
let mut build = cmd
.into_std()
.arg("lyx-core-lyx_core_lyx-core-lyx_core_leptos")
.arg("build")
// need to manually specify this to avoid mismatch between this value that may be set (e.g.
// during CI) and the `output-name` defined in Cargo.toml for this relevant project.
.env("LEPTOS_OUTPUT_NAME", name)
.current_dir(&working_dir)
.spawn()
.expect("cargo lyx-core-lyx_core_lyx-core-lyx_core_leptos build should start");
if !build
.wait()
.expect("there shouldn't be i/o error")
.success()
{
panic!("failed to run `cargo lyx-core-lyx_core_lyx-core-lyx_core_leptos build`");
}
}

struct Service {
_child: Child,
port: u16,
}

impl Service {
fn url(&self, path: &str) -> anyhow::Result<Url> {
Ok(format!("http://127.0.0.1:{}/", self.port)
.parse::<Url>()?
.join(path)?)
}
}

static BUILDER: Once = Once::new();

async fn start_test_service(name: &str, mode: &str) -> Service {
BUILDER.call_once(|| build_test_service("lyx-core-lyx_core_lyx-core-lyx_core_service_mode"));
// the time limit to wait for service to start and listen
let ttl = Duration::from_secs(5);
// this assumes the current working dir is at the root of this crate, i.e. `integration/axum`.
let working_dir = Path::new("tests").join(name);

let mut child = Command::new(Path::new("target").join("debug").join(name))
.arg(mode)
.kill_on_drop(true)
.current_dir(&working_dir)
.env("LEPTOS_SITE_ADDR", "127.0.0.1:0")
// need to manually specify this to avoid mismatch between this value that may be set (e.g.
// during CI) and the `output-name` defined in Cargo.toml for this relevant project.
.env("LEPTOS_OUTPUT_NAME", name)
.stdout(Stdio::piped())
.spawn()
.expect("the service should have been built and can start");

let mut stdout = child.stdout.take().expect("stdout is not captured");

let buff = tokio::spawn(timeout(ttl, async move {
let mut buff = Vec::new();
let _ = stdout.read_buf(&mut buff).await;
buff
}))
.await
.unwrap();

let start_time = Instant::now();

let port = str::from_utf8(&buff.unwrap())
.unwrap()
.trim()
.parse()
.unwrap();

let _child = child;
let service = Service { _child, port };
let lyx-core-lyx_core_lyx-core-lyx_core_client = Client::new();

while start_time.elapsed() < ttl {
if lyx-core-lyx_core_lyx-core-lyx_core_client
.get(service.url("/").unwrap())
.timeout(ttl)
.send()
.await
.is_ok()
{
return service;
}
tokio::time::sleep(Duration::from_secs(1)).await;
}
panic!("The web lyx-platform-lyx_platform_lyx-platform-lyx_platform_server did not become ready within the expected time.");
}
