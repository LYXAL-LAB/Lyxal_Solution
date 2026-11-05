use std::time::Duration;
use surrealdb::engine::any::Any;
use surrealdb::opt::auth::Root;
use surrealdb::Surreal;

#[tokio::main]
async fn main() {
    println!("Connecting to http://127.0.0.1:8001 ...");
    let connect_res = tokio::time::timeout(Duration::from_secs(5), surrealdb::engine::any::connect("http://127.0.0.1:8001")).await;
    match connect_res {
        Ok(Ok(db)) => {
            println!("Connected successfully! Trying signin...");
            let user = std::env::var("LYXAL_STAGING_USER").expect("LYXAL_STAGING_USER requis");
            let pass = std::env::var("LYXAL_STAGING_PASS").expect("LYXAL_STAGING_PASS requis");
            let signin_res = tokio::time::timeout(Duration::from_secs(5), db.signin(Root {
                username: &user,
                password: &pass,
            })).await;
            println!("Signin result: {:?}", signin_res);
        }
        Ok(Err(e)) => println!("Connect error: {:?}", e),
        Err(_) => println!("Connect timed out after 5s!"),
    }
}
