//! Tests d'intégration de `lyxal_storage` sur le moteur SurrealDB embarqué et les supports
//! mémoire et disque : écriture et lecture en flux, empreinte, échecs nettoyés, vérification
//! d'intégrité, envoi reprenable, worker de nettoyage, sonde de santé, appels typés du store.

mod content;
mod real_s3;
mod service;
mod store;
mod support;
mod upload;
mod worker;
