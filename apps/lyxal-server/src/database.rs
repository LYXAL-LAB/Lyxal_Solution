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
    refuse_anonymous_access(config).await?;
    Ok(database)
}

/// Une base distante qui accepte les connexions anonymes (`surreal start --allow-guests`) est
/// refusée : SurrealDB n'y distingue pas un invité de la session système de l'hôte (`$session`
/// et `$auth` identiques), et `lyxal_auth` accorderait à l'invité tous les droits. Une base
/// embarquée (`mem://`) n'a pas de connexion externe.
pub async fn refuse_anonymous_access(config: &DatabaseConfig) -> Result<(), ServerError> {
    let endpoint = config.endpoint.trim();
    if endpoint == "memory" || endpoint.starts_with("mem://") {
        return Ok(());
    }
    let attempt = async {
        let anonymous = surrealdb::engine::any::connect(endpoint).await?;
        anonymous
            .use_ns(config.namespace.as_str())
            .use_db(config.database.as_str())
            .await?;
        let mut response = anonymous.query("RETURN 1;").await?;
        response.take::<Option<i64>>(0)
    };
    match tokio::time::timeout(Duration::from_secs(config.connect_timeout_seconds), attempt).await {
        // Requête exécutée sans identifiants : accès anonyme ouvert
        Ok(Ok(_)) => Err(ServerError::Configuration {
            message: "SurrealDB accepte les connexions anonymes (--allow-guests) : interdit, \
                      un invité y aurait les droits de la session système"
                .into(),
        }),
        // Requête refusée (attendu) : accès anonyme fermé
        Ok(Err(_)) => Ok(()),
        // Vérification impossible : on ne démarre pas sans savoir
        Err(_) => Err(ServerError::Configuration {
            message: "impossible de vérifier que SurrealDB refuse les connexions anonymes \
                      (délai dépassé)"
                .into(),
        }),
    }
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
