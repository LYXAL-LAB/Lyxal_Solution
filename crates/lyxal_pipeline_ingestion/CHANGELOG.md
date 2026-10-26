# 📜 Journal des Modifications — Lyxal Pipeline Ingestion

Toutes les modifications notables de ce projet sont consignées dans ce fichier conformément aux principes de [Keep a Changelog](https://keepachangelog.com/fr/1.0.0/) et au respect de [SemVer](https://semver.org/lang/fr/).

---

## [1.0.0] - 2026-10-25 — Clôture Fonctionnelle V1 & Validation Staging

> **Statut Officiel CTO :** **`FUNCTIONALLY COMPLETE — STAGING VALIDATED — PRODUCTION NOT AUTHORIZED`**

### Ajouté (Added)
- **Inventaire complet des fonctions SurrealQL** : 20 fonctions métier publiques `fn::ingestion_*` (batch, staged, quarantine, manifest, rule, dashboard) et 2 primitives universelles transversales (`fn::result_ok`, `fn::error_result`), totalisant 22 fonctions actives déployées.
- **Intégration Serveur Hôte Officiel (`apps/lyxal-server`)** : Implémentation du trait `LyxalModule` (`IngestionServerModule`), tests des endpoints `/live`, `/ready`, `/health`, `/api/v1/system/modules` et validation de l'arrêt gracieux (`stop_all`).
- **Verrou de Sécurité Production** : Méthodes `is_pilot_or_synthetic` et `is_eligible_for_production` sur `CommercialProof` et blocage strict dans `ControlledPublisher` interdisant toute publication réelle de preuves pilotes ou synthétiques.
- **Banc de Qualification BTP 41 Références** : Traçabilité unitaire complète (10 pilotes, 25 TO_CONFIRM, 1 synthétique, 1 anomalie GTIN, 4 génériques normatives DTU).
- **Déploiement Staging Réel** : Script `deploy_staging.ps1` exécutant une double passe d'idempotence sans altération sur SurrealDB 3.2.0 persistant (`surrealkv`).

### Sécurité (Security)
- Révocation formelle de l'ancien compte staging sur l'instance SurrealDB (`REMOVE USER staging_admin_sec2026 ON ROOT;`).
- Rotation avec nouveaux identifiants forts via `.env.staging` (ignoré par Git) et variables d'environnement `LYXAL_STAGING_USER` / `LYXAL_STAGING_PASS`.
- Masquage documentaire confidentiel strict `[REDACTED_STAGING_KEY]`.
- Maintien du NO-GO Production strict pour toute référence sans justificatif physique authentifié.

---

## [0.1.0] - 2026-10-25 — Réalignement Architectural CTO Lyxal OS

### Ajouté (Added)
- **Fonctions publiques SurrealQL** : Création de 13 fonctions métier `fn::ingestion_*` sous contrat universel `fn::result_ok` / `fn::error_result`.
- **Externalisation des règles métier** :
  - Tables configurables `ingestion_family_rule`, `ingestion_specification`, `ingestion_manufacturer_alias`, `ingestion_unit_alias`, `ingestion_substitution_rule`.
  - Moteur de regroupement technique piloté par les données avec tolérances dynamiques.
- **Référentiel universel d'unités** : Résolution dynamique des unités via `base_unite` et `ingestion_unit_alias`.
- **Contrats inter-modules** : Implémentation du trait `LyxalSurrealCall` et suppression des requêtes SQL inline dans le store Rust.
- **Événements Transactional Outbox** : Déclencheurs `DEFINE EVENT` appelant exclusivement `fn::event_publish`.
- **Structure canonique** : Création de `migrations/`, `functions/`, `seeds/`, `events/`, `README.md`, `CHANGELOG.md` et mise à jour de `manifest.toml`.
- **Seeds industriels & démo** : Configuration initiale des 4 familles clés BTP et démonstration d'extensibilité dynamique sans recompilation avec la famille "Carrelage".

### Modifié (Changed)
- `IngestionStore` : Passage à `self.call_fn(...)` pour l'ensemble des mutations de lots, staging, quarantaine et manifestes.
- `TechnicalGroupingEngine` : Suppression des correspondances en dur de familles et de tolérances.
- Normalisation des unités et fabricants : Raccordement prioritaire aux résolveurs dynamiques SurrealDB.

### Sécurité (Security)
- Renforcement des permissions RLS sur l'ensemble des tables de staging et règles métier.
- Contrôle strict du rôle `steward_admin` pour l'approbation des manifestes et la configuration des règles.
