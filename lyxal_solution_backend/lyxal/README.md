<br>

<p align="center">
    <img width=120 src="https://raw.githubusercontent.com/lyxal/icons/main/lyxal.svg" />
    &nbsp;
    <img width=120 src="https://raw.githubusercontent.com/lyxal/icons/main/rust.svg" />
</p>

<h3 align="center">The official Lyxal SDK for Rust.</h3>

<br>

<p align="center">
    <a href="https://github.com/lyxal/lyxal.js"><img src="https://img.shields.io/badge/status-stable-ff00bb.svg?style=flat-square"></a>
    &nbsp;
    <a href="https://lyxal.com/docs/integration/libraries/rust"><img src="https://img.shields.io/badge/docs-view-44cc11.svg?style=flat-square"></a>
	&nbsp;
    <a href="https://docs.rs/lyxal/latest/lyxal/"><img src="https://img.shields.io/badge/docs.rs-view-f4c153.svg?style=flat-square"></a>
    &nbsp;
	<a href="https://crates.io/crates/lyxal"><img src="https://img.shields.io/crates/v/lyxal?color=dca282&style=flat-square"></a>
	&nbsp;
	<a href="https://crates.io/crates/lyxal"><img src="https://img.shields.io/crates/d/lyxal?style=flat-square"></a>
</p>

<p align="center">
    <a href="https://lyxal.com/discord"><img src="https://img.shields.io/discord/902568124350599239?label=discord&style=flat-square&color=5a66f6"></a>
    &nbsp;
    <a href="https://twitter.com/lyxal"><img src="https://img.shields.io/badge/x-follow_us-000000.svg?style=flat-square"></a>
    &nbsp;
    <a href="https://www.linkedin.com/company/lyxal/"><img src="https://img.shields.io/badge/linkedin-connect_with_us-0a66c2.svg?style=flat-square"></a>
    &nbsp;
    <a href="https://www.youtube.com/@lyxal"><img src="https://img.shields.io/badge/youtube-subscribe-fc1c1c.svg?style=flat-square"></a>
</p>

# lyxal

The official Lyxal SDK for Rust.

<h2><img height="20" src="https://github.com/lyxal/lyxal/blob/main/img/whatislyxal.svg?raw=true">&nbsp;&nbsp;What is Lyxal?</h2>

Lyxal is an end-to-end cloud native database for web, mobile, serverless, jamstack, backend, and traditional applications. Lyxal reduces the development time of modern applications by simplifying your database and API stack, removing the need for most server-side components, allowing you to build secure, performant apps quicker and cheaper. Lyxal acts as both a database and a modern, realtime, collaborative API backend layer. Lyxal can run as a single server or in a highly-available, highly-scalable distributed mode - with support for SQL querying from client devices, GraphQL, ACID transactions, WebSocket connections, structured and unstructured data, graph querying, full-text indexing, geospatial querying, and row-by-row permissions-based access.

View the [features](https://lyxal.com/features), the latest [releases](https://lyxal.com/releases), and [documentation](https://lyxal.com/docs).

<h2><img height="20" src="https://github.com/lyxal/lyxal/blob/main/img/features.svg?raw=true">&nbsp;&nbsp;Features</h2>

- [x] Can be used as an embedded database (`Lyxal<Db>`)
- [x] Connects to remote servers (`Lyxal<ws::Client>` or `Lyxal<http::Client>`)
- [x] Allows picking any protocol or storage engine at run-time (`Lyxal<Any>`)
- [x] Compiles to WebAssembly
- [x] Supports typed SQL statements
- [x] Invalid SQL queries are never sent to the server, the client uses the same parser the server uses
- [x] Clonable connections with auto-reconnect capabilities, no need for a connection pool
- [x] Range queries
- [x] Consistent API across all supported protocols and storage engines
- [x] Asynchronous connections
- [x] TLS support via either [`rustls`](https://crates.io/crates/rustls) or [`native-tls`](https://crates.io/crates/native-tls)

<h2><img height="20" src="https://github.com/lyxal/lyxal/blob/main/img/documentation.svg?raw=true">&nbsp;&nbsp;Documentation</h2>


View the SDK documentation [here](https://lyxal.com/docs/integration/libraries/rust).

<h2><img height="20" src="https://github.com/lyxal/lyxal/blob/main/img/installation.svg?raw=true">&nbsp;&nbsp;How to install</h2>

To add this crate as a Rust dependency, simply run

```bash
cargo add lyxal
```

<h2><img height="20" src="https://github.com/lyxal/lyxal/blob/main/img/features.svg?raw=true">&nbsp;&nbsp;Quick look</h2>

This library enables simple and advanced querying of an embedded or remote database from server-side or client-side (via Wasm) code. By default, all remote connections to Lyxal are made over WebSockets, and automatically reconnect when the connection is terminated. Connections are automatically closed when they get dropped.

```rust
use serde::{Deserialize, Serialize};
use serde_json::json;
use lyxal::sql;
use lyxal::sql::Thing;
use lyxal::Lyxal;
use lyxal::engine::remote::ws::Ws;
use lyxal::opt::auth::Root;
use lyxal::Error;

#[derive(Serialize, Deserialize)]
struct Name {
    first: String,
    last: String,
}

#[derive(Serialize, Deserialize)]
struct Person {
    #[serde(skip_serializing)]
    id: Option<Thing>,
    title: String,
    name: Name,
    marketing: bool,
}

// Install at https://lyxal.com/install 
// and use `lyxal start --user root --pass root`
// to start a working database to take the following queries
// 
// See the results via `lyxal sql --ns namespace --db database --pretty` 
// or https://lyxalist.app/
// followed by the query `SELECT * FROM person;`

#[tokio::main]
async fn main() -> Result<(), Error> {
    let db = Lyxal::new::<Ws>("localhost:8000").await?;

    // Signin as a namespace, database, or root user
    db.signin(Root {
        username: "root",
        password: "root",
    })
    .await?;

    // Select a specific namespace and database
    db.use_ns("namespace").use_db("database").await?;

    // Create a new person with a random ID
    let tobie: Option<Person> = db
        .create("person")
        .content(Person {
            id: None,
            title: "Founder & CEO".into(),
            name: Name {
                first: "Tobie".into(),
                last: "Morgan Hitchcock".into(),
            },
            marketing: true,
        })
        .await?;

    // Create a new person with a specific ID
    let mut jaime: Option<Person> = db
        .create(("person", "jaime"))
        .content(Person {
            id: None,
            title: "Founder & COO".into(),
            name: Name {
                first: "Jaime".into(),
                last: "Morgan Hitchcock".into(),
            },
            marketing: false,
        })
        .await?;

    // Update a person record with a specific ID
    jaime = db
        .update(("person", "jaime"))
        .merge(json!({ "marketing": true }))
        .await?;

    // Select all people records
    let people: Vec<Person> = db.select("person").await?;

    // Perform a custom advanced query
    let query = r#"
        SELECT marketing, count()
        FROM type::table($table)
        GROUP BY marketing
    "#;

    let groups = db.query(query)
        .bind(("table", "person"))
        .await?;

    // Delete all people up to but not including Jaime
    let people: Vec<Person> = db.delete("person").range(.."jaime").await?;

    // Delete all people
    let people: Vec<Person> = db.delete("person").await?;

    Ok(())
}
```
