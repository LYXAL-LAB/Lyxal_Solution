//! Connexion de l'hôte à SurrealDB : pool de connexions de `lyxal_surreal` sous la session
//! système, chaque connexion sondée (`SurrealPool::probe`), refus d'une base qui accepte les
//! connexions anonymes.

use crate::{config::DatabaseConfig, HostError};
use lyxal_surreal::{is_embedded_endpoint, RootCredentials, SurrealConnectOptions, SurrealPool};
use std::time::Duration;

/// Session système de l'hôte sur la base : `[database] connections` connexions ouvertes sous
/// les mêmes identifiants (une seule pour une base embarquée). Les stores de la session système
/// reçoivent le pool ; ce qui tient à une connexion (session d'un utilisateur, requête `LIVE`,
/// installation, moteur du runtime) prend sa connexion fixe (`SurrealPool::fixed`).
pub type Database = SurrealPool;

/// Ouvre les connexions de la session système par `lyxal_surreal` (schémas d'URL, identifiants
/// Root, délai, namespace et base), puis vérifie que chacune répond à la sonde : une connexion
/// muette au démarrage arrête l'hôte.
pub async fn connect_database(config: &DatabaseConfig) -> Result<Database, HostError> {
    let credentials = match (&config.username, &config.password) {
        (Some(username), Some(password)) => Some(RootCredentials::new(
            username.clone(),
            password.to_secret()?,
        )),
        _ => None,
    };
    let within = Duration::from_secs(config.connect_timeout_seconds);
    let database = SurrealPool::connect(
        &SurrealConnectOptions {
            endpoint: config.endpoint.clone(),
            credentials,
            namespace: config.namespace.clone(),
            database: config.database.clone(),
            connect_timeout: within,
        },
        config.connections,
    )
    .await
    .map_err(|error| HostError::Database {
        message: error.to_string(),
    })?;

    let state = database.probe(within).await;
    if !state.complete() {
        return Err(HostError::Database {
            message: format!(
                "{} connexion(s) sur {} répondent à la sonde SurrealDB : {}",
                state.responding,
                state.clients,
                state.error.as_deref().unwrap_or("aucun détail")
            ),
        });
    }
    refuse_anonymous_access(config).await?;
    Ok(database)
}

/// Une base distante qui accepte les connexions anonymes (`surreal start --allow-guests`) est
/// refusée : SurrealDB n'y distingue pas un invité de la session système de l'hôte (`$session`
/// et `$auth` identiques), et `lyxal_auth` accorderait à l'invité tous les droits. Une base
/// embarquée (`mem://`) n'a pas de connexion externe.
pub async fn refuse_anonymous_access(config: &DatabaseConfig) -> Result<(), HostError> {
    let endpoint = config.endpoint.trim();
    if is_embedded_endpoint(endpoint) {
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
        Ok(Ok(_)) => Err(HostError::Configuration {
            message: "SurrealDB accepte les connexions anonymes (--allow-guests) : interdit, \
                      un invité y aurait les droits de la session système"
                .into(),
        }),
        // Refus d'autorisation explicite (attendu) : accès anonyme fermé
        Ok(Err(error)) if error.is_not_allowed() => Ok(()),
        // Autre échec (réseau, coupure, erreur inattendue) : rien n'est prouvé, on ne démarre pas
        Ok(Err(error)) => Err(HostError::Configuration {
            message: format!(
                "impossible de vérifier que SurrealDB refuse les connexions anonymes : {error}"
            ),
        }),
        // Vérification impossible : on ne démarre pas sans savoir
        Err(_) => Err(HostError::Configuration {
            message: "impossible de vérifier que SurrealDB refuse les connexions anonymes \
                      (délai dépassé)"
                .into(),
        }),
    }
}
