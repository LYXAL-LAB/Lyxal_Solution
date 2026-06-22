use lyxal::engine::remote::ws::Ws;
use lyxal::Lyxal;

#[tokio::main]
async fn main() -> lyxal::Result<()> {
	let db = Lyxal::new::<Ws>("localhost:8000").await?;
	let _ = db.query("INFO FOR ROOT").await.unwrap().check().is_ok();
	Ok(())
}
