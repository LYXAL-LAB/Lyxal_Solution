use crate::{config::DatabaseConfig, error::ServerError};
use serde::Deserialize;
use std::{sync::Arc, time::Duration};
use surrealdb::{
    Surreal,
    engine::any::{Any, connect},
    opt::auth::Root,
};
use tokio::time::timeout;

pub type Database = Arc<Surreal<Any>>;

#[derive(Debug, Deserialize)]
struct Probe {
    ok: bool,
}

pub async fn connect_database(config: &DatabaseConfig) -> Result<Database, ServerError> {
    let client = timeout(
        Duration::from_secs(config.connect_timeout_seconds),
        connect(&config.endpoint),
    )
    .await
    .map_err(|_| ServerError::Database("délai de connexion dépassé".into()))?
    .map_err(|error| ServerError::Database(error.to_string()))?;

    if let (Some(username), Some(password)) = (&config.username, &config.password) {
        client
            .signin(Root {
                username: username.clone(),
                password: password.clone(),
            })
            .await
            .map_err(|error| ServerError::Database(error.to_string()))?;
    }

    client
        .use_ns(&config.namespace)
        .use_db(&config.database)
        .await
        .map_err(|error| ServerError::Database(error.to_string()))?;

    let database = Arc::new(client);
    probe(&database).await?;
    Ok(database)
}

pub async fn probe(database: &Database) -> Result<(), ServerError> {
    let mut response = database
        .query("RETURN { ok: true };")
        .await
        .map_err(|error| ServerError::Database(error.to_string()))?;

    let value: Option<Probe> = response
        .take(0)
        .map_err(|error| ServerError::Database(error.to_string()))?;

    match value {
        Some(Probe { ok: true }) => Ok(()),
        _ => Err(ServerError::Database(
            "la sonde SurrealDB n'a pas retourné le résultat attendu".into(),
        )),
    }
}
