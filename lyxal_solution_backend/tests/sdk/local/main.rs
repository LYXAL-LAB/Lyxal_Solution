use lyxal::engine::local::Mem;
use lyxal::Lyxal;

#[tokio::main]
async fn main() -> lyxal::Result<()> {
	let db = Lyxal::new::<Mem>(()).await?;
	let _ = db.query("INFO FOR ROOT").await.unwrap().check().is_ok();
	Ok(())
}
