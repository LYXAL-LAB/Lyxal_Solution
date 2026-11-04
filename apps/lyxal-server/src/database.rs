use crate::{config::DatabaseConfig, error::ServerError};
use lyxal_surreal::{create_surreal_client, RootCredentials, SurrealConnectOptions};
use std::{sync::Arc, time::Duration};
use surrealdb::{engine::any::Any, types::SurrealValue, Surreal};

pub type Database = Arc<Surreal<Any>>;

#[derive(Debug, SurrealValue)]
struct Probe {
    ok: bool,
}

/// Connecte la base par la fabrique de `lyxal_surreal` (schémas d'URL, identifiants Root,
/// délai, namespace et base), puis vérifie la connexion par une sonde.
pub async fn connect_database(config: &DatabaseConfig) -> Result<Database, ServerError> {
    let credentials = match (&config.username, &config.password) {
        (Some(username), Some(password)) => Some(RootCredentials::new(
            username.clone(),
            password.to_secret()?,
        )),
        _ => None,
    };
    let client = create_surreal_client(SurrealConnectOptions {
        endpoint: config.endpoint.clone(),
        credentials,
        namespace: config.namespace.clone(),
        database: config.database.clone(),
        connect_timeout: Duration::from_secs(config.connect_timeout_seconds),
    })
    .await
    .map_err(|error| ServerError::Database {
        message: error.to_string(),
    })?;

    let database = Arc::new(client);
    probe(&database).await?;
    Ok(database)
}

pub async fn probe(database: &Database) -> Result<(), ServerError> {
    let mut response = database
        .query("RETURN { ok: true };")
        .await
        .map_err(|error| ServerError::Database {
            message: error.to_string(),
        })?;

    let value: Option<Probe> = response.take(0).map_err(|error| ServerError::Database {
        message: error.to_string(),
    })?;

    match value {
        Some(Probe { ok: true }) => Ok(()),
        _ => Err(ServerError::Database {
            message: "la sonde SurrealDB n'a pas retourné le résultat attendu".into(),
        }),
    }
}
