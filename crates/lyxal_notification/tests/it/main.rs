//! Tests d'intégration de `lyxal_notification` sur le moteur SurrealDB embarqué : de
//! l'invitation de `lyxal_auth` à l'e-mail reçu par un serveur SMTP de test (secret ouvert,
//! rescellé, rendu, envoyé), rejeu idempotent, enveloppe d'un autre événement refusée, nouvelles
//! tentatives, destinataire refusé, sonde de santé ; e-mails du système rendus en français et en
//! anglais avec les textes de `lyxal_i18n`.

mod flow;
mod smtp_server;
mod support;
mod texts;
