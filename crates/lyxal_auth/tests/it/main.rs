//! Tests d'intégration de `lyxal_auth` sur le moteur SurrealDB embarqué : appels typés
//! (contrats Rust ↔ SurrealQL), service d'invitation (jeton, empreinte, lien scellé publié),
//! vérification des domaines (lecteur TXT de test), sonde de santé.

mod domains;
mod invitations;
mod store;
mod support;
