#![recursion_limit = "256"]

use dotenv::dotenv;
use leptos::prelude::*;

mod app_router;
mod fallback;

use app_router::build_app_router::build_app_router;

#[tokio::main(flavor = "multi_thread")]
async fn main() -> anyhow::Result<()> {
    dotenv().ok();

    let conf = get_configuration(None)?;
    let addr = conf.leptos_options.site_addr;

    let app = build_app_router(conf).await?;
    println!("listening on http://{addr}");
    let listener = tokio::net::TcpListener::bind(addr).await?;
    axum::serve(listener, app).await.unwrap();
    Ok(())
}
