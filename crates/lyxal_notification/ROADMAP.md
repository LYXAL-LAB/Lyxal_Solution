# Feuille de route — `lyxal_notification`

Évolutions à venir ; l'état actuel est décrit par [`README.md`](README.md). Correspondance
détaillée avec Novu : [`MODELE_SOURCES.md`](MODELE_SOURCES.md) §1 et §2. Chaque lot démarre sur
ordre du CTO avec un `implementation_plan.md` validé.

| Lot | Contenu | Prérequis |
| :--- | :--- | :--- |
| **V1-b — Destinataires et préférences** | Abonnés (création à la volée, import), adresses de canal, sujets et abonnements conditionnels, catégories, préférences à tous les niveaux, heures calmes, désabonnement (lien signé), diffusion, exclusion de l'acteur, annulation ; tables de relation (abonné ↔ sujet, préférences) | moteur de conditions (point 1) |
| **V1-c — Parcours complets** | Délais, digest, throttle (`notification_rate_limit`), conditions d'étape, surcharges, contrôles, envoi groupé, aperçu et test | V1-b ; délais longs : `lyxal_scheduler` |
| **V1-d — Fil in-app** | États, compteurs, actions, onglets, snooze, temps réel | V1-b ; point 2 |
| **V1-e — Autres canaux** | `notification_integration` (fournisseurs par locataire, identifiants dans `lyxal_secrets`), fournisseurs e-mail par API (SES, Postmark…), retours de rejets asynchrones (`notification_provider_event`), SMS, chat par webhook (Slack, Teams), puis push (point 5) | `lyxal_secrets` |
| **V2 — Observabilité et console** | Écrans de la console, aperçu, statistiques horaires, suivi des ouvertures et clics (désactivé par défaut, décision N7), webhooks sortants signés (point 3), traductions `lyxal_i18n`, révisions publiées, contrôle des domaines d'envoi, étape HTTP (point 7) | `lyxal_i18n`, `lyxal_secrets` |
| **V3 — Événementiel avancé** | Interactions humaines (approuver / choisir par message), courrier entrant (point 6), connexions chat OAuth, outils IA | `lyxal_connect` |

## Solutions d'attente du lot V1-a à remplacer

* Relais SMTP unique dans la configuration de l'hôte → intégrations par locataire avec
  `lyxal_secrets` (V1-e), sans migration (régime zéro dette).
* Une version de gabarit par langue → clés de traduction `lyxal_i18n` (V2).
* Purge et nouvelles tentatives par `LyxalWorker` → envois différés et délais longs par
  `lyxal_scheduler` (V1-c).

## Points à décider par le CTO

1. **Moteur de conditions** (conditions d'étape, abonnements conditionnels, choix
   d'intégration) : extension de `lyxal_core` (§5.7.7) ou fonction du module.
2. **Temps réel du fil in-app** : `LIVE SELECT` SurrealDB exposé par `lyxal-server`, ou flux SSE /
   WebSocket de l'hôte.
3. **Webhooks sortants** : dans ce module, ou dans un module commun à tous les producteurs.
4. **Environnements** : remplacés par brouillon / publication avec révisions (à confirmer).
5. **Cryptographie hors `lyxal_crypto`** (§11.3) : push web (VAPID, ECDSA P-256), APNs (ES256).
6. **Courrier entrant** : serveur SMTP entrant, relais par un fournisseur, ou abandon.
7. **Étape HTTP** : hôtes autorisés par locataire (protection SSRF) avant toute activation.
