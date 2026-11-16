# Feuille de route — `lyxal_notification`

Évolutions à venir ; l'état actuel est décrit par [`README.md`](README.md). Correspondance
détaillée avec Novu : [`MODELE_SOURCES.md`](MODELE_SOURCES.md) §1 et §2. Chaque lot démarre sur
ordre du CTO avec un `implementation_plan.md` validé.

| Lot | Contenu | Prérequis |
| :--- | :--- | :--- |
| **V1-d — Fil in-app** | États, compteurs, actions, onglets, snooze, temps réel ; valeur « lu » d'un message du fil fournie aux conditions d'étape (« sauter si déjà lu », décision C6) | point 1 |
| **V1-e — Autres canaux** | `notification_integration` (fournisseurs par locataire, identifiants dans `lyxal_secrets`), fournisseurs e-mail par API (SES, Postmark…), retours de rejets asynchrones (`notification_provider_event`), adresses des abonnés par canal (appareils push, messageries), SMS, chat par webhook (Slack, Teams), puis push (point 4) | `lyxal_secrets` |
| **V2 — Observabilité et console** | Écrans de la console (dont l'aperçu des étapes), regroupement à heure fixe (ex. chaque jour à 9 h), statistiques horaires, suivi des ouvertures et clics (désactivé par défaut, décision N7), webhooks sortants signés (point 2), révisions publiées, contrôle des domaines d'envoi, étape HTTP (point 6) | `lyxal_secrets` |
| **V3 — Événementiel avancé** | Interactions humaines (approuver / choisir par message), courrier entrant (point 5), connexions chat OAuth, outils IA | `lyxal_connect` |

## Solutions d'attente du lot V1-a à remplacer

* Relais SMTP unique dans la configuration de l'hôte → intégrations par locataire avec
  `lyxal_secrets` (V1-e), sans migration (régime zéro dette). Le choix du fournisseur s'ajoutera
  alors aux surcharges d'un déclenchement (décision C5).

## Points à décider par le CTO

1. **Temps réel du fil in-app** : `LIVE SELECT` SurrealDB exposé par `lyxal-server`, ou flux SSE /
   WebSocket de l'hôte.
2. **Webhooks sortants** : dans ce module, ou dans un module commun à tous les producteurs.
3. **Environnements** : remplacés par brouillon / publication avec révisions (à confirmer).
4. **Cryptographie hors `lyxal_crypto`** (§11.3) : push web (VAPID, ECDSA P-256), APNs (ES256).
5. **Courrier entrant** : serveur SMTP entrant, relais par un fournisseur, ou abandon.
6. **Étape HTTP** : hôtes autorisés par locataire (protection SSRF) avant toute activation.
