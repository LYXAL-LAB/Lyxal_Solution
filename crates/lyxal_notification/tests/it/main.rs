//! Tests d'intégration de `lyxal_notification` sur le moteur SurrealDB embarqué : de
//! l'invitation de `lyxal_auth` à l'e-mail reçu par un serveur SMTP de test (secret ouvert,
//! rescellé, rendu, envoyé), rejeu idempotent, enveloppe d'un autre événement refusée, nouvelles
//! tentatives, destinataire refusé, sonde de santé ; e-mails du système rendus en français et en
//! anglais avec les textes de `lyxal_i18n` ; abonnés, désabonnement en un clic, heures calmes et
//! diffusion par paquets ; parcours à étapes avec le moteur de lyxal_scheduler (attente reprise,
//! regroupement, annulation, planification de la purge, aperçu) ; fournisseurs HTTP contre de
//! faux fournisseurs locaux, intégrations (choix, bascule, identifiants lus du coffre-fort) et
//! retours des fournisseurs vérifiés ; fil dans l'application (rendu échappé, liens contrôlés à
//! la livraison, contenu en lecture seule).

mod audience;
mod channels;
mod fake_apns;
mod fake_provider;
mod feed;
mod flow;
mod integrations;
mod providers;
mod push;
mod smtp_server;
mod steps;
mod support;
mod texts;
