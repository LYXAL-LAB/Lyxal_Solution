#[tokio::main]
async fn main() -> anyhow::Result<()> {
    lyxal_server::run().await
}
