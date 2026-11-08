//! Tests d'intégration de `lyxal_auth` sur le moteur SurrealDB embarqué : appels typés
//! (contrats Rust ↔ SurrealQL), service d'invitation (jeton, empreinte, lien scellé publié),
//! vérification des domaines (lecteur TXT de test), connexion et jetons de bout en bout (jeton
//! accepté par l'accès SurrealDB, refusé après révocation), sonde de santé.

mod access;
mod domains;
mod invitations;
mod store;
mod support;
