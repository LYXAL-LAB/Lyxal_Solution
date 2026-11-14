//! Tests d'intégration de `lyxal_secrets` sur le moteur SurrealDB embarqué : valeurs écrites puis
//! relues, taille, enveloppes recopiées ou altérées, écritures concurrentes, rotation des clés
//! d'organisation et de la clé maîtresse, organisation supprimée, fonctionnement sans clé
//! maîtresse, lectures refusées journalisées (sessions de personnes et de programmes), worker et
//! sonde, cycle de vie (rotations, alertes, rotation planifiée des clés), absence de valeur dans
//! les `Debug` et les erreurs ; accès temporaires, demandes approuvées, protections et urgence ; partages à usage unique.

mod access;
mod approvals;
mod keys;
mod module;
mod rotation;
mod shares;
mod support;
mod values;
