# 📋 PLAN TECHNIQUE DÉTAILLÉ (RÉVISÉ) — INTÉGRATION STAGING & RECETTE FINALE V1
## Module : `lyxal_pipeline_ingestion`
**Statut : PLAN RÉVISÉ CONFORME À LA DIRECTIVE DU CTO — EXÉCUTION STRICTEMENT SUSPENDUE**  
**Référentiel Obligatoire : `.agents/AGENTS.md` & Directive CTO du 25 Octobre 2026**  
**Auteur : Antigravity Lead Engineer & Pair Architect**  

---

## 🏛️ 1. Principes Directeurs & Cadre de Rigueur

Conformément à la directive formelle du CTO :
1. **Règle N°1 Inviolable** : Aucune intervention sur le code, les dépendances ou l'infrastructure n'est entreprise avant l'approbation formelle de ce plan révisé.
2. **Refus de Toute Simulation** :
   - Pas de déploiement fictif, pas d'assertions de performance factices, pas de fabrication artificielle de documents EDI.
   - Les résultats présentés seront mesurés empiriquement sur environnement réel avec documentation de la configuration.
3. **Respect Strict de la Hiérarchie et Frontières Lyxal OS** :
   - Pas de serveur Axum parallèle. Utilisation exclusive de l'hôte officiel `apps/lyxal-server`.
   - Zéro modification de `lyxal_catalogue` V1.1.
   - Zéro modification de `lyxal_base` et aucune création non autorisée d'un crate `lyxal_normes`.
   - Maintien étanche du **NO-GO Production** : environnement staging complètement cloisonné.

---

## 🔍 2. Inventaire Réel et Exhaustif du Code (`lyxal_pipeline_ingestion`)

Le scan complet et vérifié des fichiers réels du module établit l'inventaire strict suivant (aucun renommage ni invention) :

### 2.1. Schémas Déclaratifs SurrealQL (`schema/`) & Ordre d'Installation Déterministe
Les 11 fichiers schémas doivent être appliqués dans l'ordre strict de leurs dépendances relationnelles :
1. `schema/00_ingestion_session.surql` : Table `ingestion_session` pour l'authentification et les contextes d'agents.
2. `schema/01_ingestion_batch.surql` : Table `ingestion_batch` (métadonnées, état, checkpoints, curseur d'offset).
3. `schema/02_ingestion_raw_record.surql` : Table `ingestion_raw_record` (lignes brutes immuables avec hachage).
4. `schema/03_ingestion_staged_item.surql` : Table `ingestion_staged_item` (articles normalisés, qualifications, preuves commerciales, audit).
5. `schema/04_ingestion_quarantine_record.surql` : Table `ingestion_quarantine_record` (anomalies, sévérités, traçabilité de résolution).
6. `schema/05_ingestion_publication_manifest.surql` : Table `ingestion_publication_manifest` (manifestes, scellement BLAKE3, items d'exécution).
7. `schema/06_ingestion_family_rule.surql` : Table `ingestion_family_rule` (familles techniques et attributs requis).
8. `schema/07_ingestion_specification.surql` : Table `ingestion_specification` (spécifications techniques et tolérances).
9. `schema/08_ingestion_manufacturer_alias.surql` : Table `ingestion_manufacturer_alias` (normalisation canonique des fabricants).
10. `schema/09_ingestion_unit_alias.surql` : Table `ingestion_unit_alias` (normalisation des unités vers `base_unite`).
11. `schema/10_ingestion_substitution_rule.surql` : Table `ingestion_substitution_rule` (substitutions contextualisées et révocables).

### 2.2. Fonctions Publiques SurrealQL Réelles (`functions/`)
Exactement **20 fonctions publiques**, réparties en 6 domaines :
- **Domaine Lot (`functions/batch/`)** :
  1. `fn::ingestion_batch_create($params: object)` : Initialisation d'un lot d'ingestion.
  2. `fn::ingestion_batch_checkpoint($params: object)` : Sauvegarde atomique du curseur d'offset et compteurs.
  3. `fn::ingestion_batch_transition($params: object)` : Mutation surveillée de l'état du lot.
- **Domaine Staging (`functions/staged/`)** :
  4. `fn::ingestion_staged_save($params: object)` : Persistance atomique d'un article normalisé.
  5. `fn::ingestion_staged_list($params: object)` : Recherche paginée et filtrée pour le Data Steward.
  6. `fn::ingestion_staged_requalify($params: object)` : Requalification sécurisée par session avec attachement de preuve.
- **Domaine Quarantaine (`functions/quarantine/`)** :
  7. `fn::ingestion_quarantine_log($params: object)` : Enregistrement d'une anomalie.
  8. `fn::ingestion_quarantine_list($params: object)` : Consultation paginée de la quarantaine.
  9. `fn::ingestion_quarantine_resolve($params: object)` : Résolution d'anomalie basculant strictement vers `TO_CONFIRM`.
- **Domaine Manifestes & Publication (`functions/manifest/`)** :
  10. `fn::ingestion_manifest_save($params: object)` : Scellement cryptographique BLAKE3 du manifeste.
  11. `fn::ingestion_manifest_approve($params: object)` : Approbation formelle sous session `steward_admin`.
  12. `fn::ingestion_manifest_record_exec($params: object)` : Consignation du compte-rendu de publication.
  13. `fn::ingestion_manifest_list($params: object)` : Listing paginé des manifestes.
  14. `fn::ingestion_manifest_get_detail($params: object)` : Détail et vérification d'intégrité du scellement.
- **Domaine Règles & Référentiels (`functions/rule/`)** :
  15. `fn::ingestion_resolve_unit($params: object)` : Résolution d'unité via alias et `base_unite`.
  16. `fn::ingestion_resolve_manufacturer($params: object)` : Résolution canonique de raison sociale fabricant.
  17. `fn::ingestion_rule_family_add($params: object)` : Enregistrement dynamique d'une famille technique.
  18. `fn::ingestion_rule_spec_add($params: object)` : Enregistrement de tolérances dimensionnelles.
  19. `fn::ingestion_rule_substitution_add($params: object)` : Déclaration d'une règle de substitution contextualisée.
- **Domaine Dashboard & Observabilité (`functions/dashboard/`)** :
  20. `fn::ingestion_dashboard_metrics($params: object)` : KPIs temps réel consolidés.

### 2.3. Ressources Complémentaires
- **Migrations** : `migrations/0001_initial_schema.surql` (contrat initial de schéma).
- **Événements** : `events/01_events.surql` (trigger `DEFINE EVENT` publiant vers `fn::event_publish`).
- **Seeds** :
  - `seeds/01_initial_families.surql` (familles BTP standard).
  - `seeds/02_initial_specifications.surql` (spécifications techniques BA13, isolants, profilés).
  - `seeds/03_initial_aliases.surql` (alias unités et industriels BTP).
  - `seeds/04_carrelage_demo.surql` (données de démonstration carrelage).
- **Master Data d'Erreurs** : `error/ingestion/error_definitions.surql` (codes d'erreur `INGESTION_*`).

### 2.4. Contrats Rust et Composants Runtime
- `PipelineIngestionModule` ([`src/module.rs`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_pipeline_ingestion/src/module.rs)) : Implémente le contrat universel `lyxal_runtime::LyxalModule`.
- `IngestionWorker` ([`src/worker/ingestion_worker.rs`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_pipeline_ingestion/src/worker/ingestion_worker.rs)) : Implémente le contrat supervisé `lyxal_runtime::worker::LyxalWorker`.
- `IngestionHealthCheck` ([`src/health.rs`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_pipeline_ingestion/src/health.rs)) : Implémente le contrat officiel `lyxal_runtime::ModuleHealthCheck`.
- `IngestionStore` ([`src/storage/store.rs`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_pipeline_ingestion/src/storage/store.rs)) : Implémente le transport 1-ligne unifié `lyxal_surreal::LyxalSurrealCall`.

---

## 🔒 3. Statut Réel des Preuves Commerciales & Transparence Totale

En application directe de la consigne du CTO :
> *"Distinguer : Preuve documentaire réellement vérifiée, Simple identifiant de preuve enregistré, Preuve synthétique ou de démonstration. Ne pas créer artificiellement des documents EDI fabricant."*

### 3.1. Diagnostic Exhaustif des 10 Références Déclarées `VERIFIED`
Dans le banc d'essai pilote actuel :
- **Nature exacte** : Les structures `CommercialProof` rattachées à ces 10 références (Placo, Knauf, Siniat, Isover) contiennent des **identifiants de preuve enregistrés** (ex: `PROOF-AUTH-2026-P01302500`).
- **Absence de pièces documentaires originales physiques** : Il n'existe pas dans le dépôt de pièces justificatives physiques originales (ex: fichiers PDF officiels d'attestation, messages EDIFACT `DESADV`/`PRICAT` signés cryptographiquement, ou flux X.509 directs avec les serveurs des industriels).
- **Règle d'inviolabilité pour le Staging et la Production** :
  - Pour la recette technique en Staging, ces références valident le comportement du moteur face à un contrat `CommercialProof` conforme.
  - **Pour toute publication réelle dans le Master Catalogue, ces 10 références NE SONT PAS considérées comme commercialement vérifiées** tant qu'une convention de raccordement EDI fabricant réelle n'est pas scellée et que des attestations authentifiées ne sont pas rattachées par un Data Steward physique assermenté.
  - **Zéro fabrication artificielle** : Aucun faux document EDI ou attestation factice ne sera généré.

### 3.2. Répartition Définitive des 41 Références du Pilote BTP
1. **10 Références Industrielles avec Identifiant Pilote** : Maintenues en statut technique de validation du flux en staging, mais interdites de publication réelle sans attestation documentaire originale.
2. **25 Références Industrielles sans Preuve** : Maintenues strictement en **`TO_CONFIRM`**.
3. **1 Référence Synthétique de Banc d'Essai** (`SYNTH-PLACO-99`) : Exclue formellement de toute publication.
4. **1 Référence de Test Anomalie** (`ERR-GTIN-001`) : Maintenue en quarantaine (`INGESTION_GTIN_INVALID`).
5. **4 Références Normatives DTU 25.41** (`GEN-*`) : Traitement spécifique détaillé ci-dessous.

---

## 📐 4. Traitement des 4 Références Génériques DTU

Conformément à la directive du CTO :
> *"Ne pas assimiler automatiquement une absence de GTIN à une erreur pour une spécification technique générique. Maintenir les quatre références hors publication commerciale fabricant et déterminer leur rattachement approprié après examen des référentiels existants. Ne pas modifier lyxal_base ni créer lyxal_normes sans mandat spécifique."*

### 4.1. Qualification Métier
- Les références `GEN-HYDRO-2500`, `GEN-FEU-2500`, `GEN-PHONIQUE-2500`, `GEN-HD-2500` représentent des désignations de prescription issues des normes françaises DTU 25.41 et NF EN 520 (plaques de plâtre hydrofugées type H1, résistantes au feu type F, acoustiques, haute dureté type I).
- L'absence de GTIN n'est pas une anomalie syntaxique ou une corruption de données, mais le propre d'un article normatif générique universel n'émanant d'aucun industriel particulier.

### 4.2. Traitement d'Ingestion
- **Non-publication dans le catalogue commercial fabricant** : Le pipeline d'ingestion commercial est dédié aux catalogues marchands d'industriels (qui exigent un code GS1 et un fabricant identifié). Ces 4 articles ne doivent donc pas être injectés dans la publication des catalogues marchands.
- **Rétention neutre** : Elles sont isolées dans le staging sous la qualification `GENERIC_SPECIFICATION` ou en table de quarantaine dédiée sans déclencher d'alerte critique.
- **Respect du périmètre** : `lyxal_base` demeure inchangé et aucun crate `lyxal_normes` n'est créé. L'orientation définitive vers un module de normes fera l'objet d'un mandat ultérieur du CTO.

---

## 🏗️ 5. Stratégie d'Intégration Réaliste avec `lyxal-server`

Conformément à la directive du CTO :
> *"Inspecter les dépendances manquantes du workspace. Proposer et appliquer uniquement les ajustements nécessaires à la compilation de l'hôte existant, après validation du périmètre exact dans le plan corrigé. Ne pas créer d'hôte parallèle."*

### 5.1. Diagnostic Précis du Workspace
`apps/lyxal-server/Cargo.toml` hérite de dépendances via `workspace = true`, mais le `Cargo.toml` racine ne déclare actuellement pas ces dépendances. Pour permettre la compilation de l'hôte officiel existant sans duplication, les dépendances suivantes doivent être déclarées au niveau racine dans `[workspace.dependencies]` :

```toml
# Dépendances requises par apps/lyxal-server
anyhow = "1.0"
axum = "0.7"
chrono = { version = "0.4", features = ["serde"] }
config = "0.14"
http = "1.1"
tower = "0.4"
tower-http = { version = "0.5", features = ["trace", "cors"] }
tracing-subscriber = { version = "0.3", features = ["env-filter", "json"] }
```

Et dans `[workspace]` racine :
```toml
members = [
    "crates/lyxal_error",
    "lyxal_surreal",
    "crates/lyxal_runtime",
    "crates/lyxal_event",
    "crates/lyxal_crypto",
    "crates/lyxal_pipeline_ingestion",
    "apps/lyxal-server",              # <-- Ajout de l'hôte officiel
]
```

### 5.2. Périmètre Strict des Fichiers à Modifier pour l'Intégration Serveur
1. `c:\Users\HP\Desktop\Lyxal_OS\Cargo.toml` : Ajout des 8 dépendances partagées et déclaration de `"apps/lyxal-server"` dans `members`.
2. `apps/lyxal-server/src/modules/contract.rs` : Alignement mineur éventuel sur les types d'identifiants de `lyxal_runtime`.
3. `apps/lyxal-server/src/modules/mod.rs` : Enregistrement de `PipelineIngestionModule` dans la liste `compiled_modules()`.
4. `apps/lyxal-server/src/modules/ingestion.rs` (nouveau connecteur fin) : Adaptateur reliant `PipelineIngestionModule` au contrat de serveur hôte existant (environ 60 lignes), sans logique métier.

### 5.3. Distinction des 3 Niveaux d'Intégration
- **Niveau 1 — Intégration Runtime Validée** : Déjà effective. `IngestionWorker` implémente `LyxalWorker`, `IngestionHealthCheck` implémente `ModuleHealthCheck`. Supervisé par `LyxalRuntime`.
- **Niveau 2 — Compilation Serveur Validée** : Obtention d'un `cargo check -p lyxal-server` sans erreur ni warning après ajout des dépendances workspace.
- **Niveau 3 — Intégration HTTP et Cycle de Vie Réellement Testés** : Validation dans un test d'intégration que `lyxal_server::run()` ou son initialiseur démarre l'application, monte le routeur HTTP sur le port configuré, expose les sondes de santé de l'ingestion, et s'arrête gracieusement sur signal sans laisser de worker orphelin.

---

## ⚡ 6. Environnement Staging SurrealDB & Déploiement Réel

### 6.1. Architecture de l'Instance Locale Dédiée
- **Processus Réel** : Démarrage du binaire local `.\surreal.exe` sur le port WebSocket `127.0.0.1:8001` avec stockage persistant fichier :
  ```powershell
  .\surreal.exe start --bind 127.0.0.1:8001 --user $env:LYXAL_STAGING_USER --pass $env:LYXAL_STAGING_PASS file:staging_db/data.db
  ```
- **Configuration Externe Sécurisée** : Les identifiants de test ne sont pas codés en dur, mais fournis via les variables d'environnement `LYXAL_STAGING_USER` et `LYXAL_STAGING_PASS` (avec fallback sécurisé pour tests locaux).
- **Isolation Totale** : Namespace `lyxal_staging`, Database `pipeline_staging`.

### 6.2. Procédure Déclarative de Déploiement Idempotent
Un script PowerShell reproductible [`scripts/staging/deploy_staging.ps1`](file:///c:/Users/HP/Desktop/Lyxal_OS/scripts/staging/deploy_staging.ps1) appliquera :
1. Connexion et initialisation du Namespace / Database.
2. Déploiement dans l'ordre strict des 11 schémas (`schema/00_*.surql` à `10_*.surql`).
3. Déploiement ordonné des 20 fonctions SurrealQL.
4. Déploiement des événements (`events/01_events.surql`).
5. Déploiement des seeds (`seeds/01_*.surql` à `04_*.surql`).
6. Déploiement des définitions d'erreurs (`error/ingestion/error_definitions.surql`).
7. **Test d'Idempotence** : Réexécution intégrale immédiate du script sur la base peuplée pour vérifier l'absence d'erreur `already exists` ou de mutation destructive.

---

## 📊 7. Critères de Recette Mesurables & Méthodologie Empirique

Conformément à la directive du CTO :
> *"Mesurer les performances réelles sans imposer artificiellement les seuils de 5 ms et 200 articles/s comme conditions universelles. Présenter les résultats avec leur environnement et leur méthodologie."*

### 7.1. Protocole de Recette End-to-End
La suite de test réelle [`tests/integration_staging_live_server.rs`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_pipeline_ingestion/tests/integration_staging_live_server.rs) exécutera le scénario complet suivant via WebSocket réel :
1. **Démarrage & Connexion** : Connexion client WebSocket sur `ws://127.0.0.1:8001`.
2. **Authentification des Rôles** :
   - Session `ingestion_agent` : Injection d'un lot brut FAB-DIS de 100 lignes.
   - Session `qualification_agent` : Déclenchement du worker d'ingestion.
   - Session `steward_admin` : Requalification assistée et approbation formelle du manifeste scellé par BLAKE3.
   - Session non autorisée (`operator`) : Tentative de requalification rejetée avec code `INGESTION_UNAUTHORIZED_APPROVER`.
3. **Reprise Après Panne & Checkpoint** :
   - Interruption artificielle du traitement à 50% du lot via `CancellationToken`.
   - Redémarrage du worker : vérification que le traitement reprend à l'offset 50 sans dupliquer les 50 premières lignes en base.
4. **Coupure Réseau & Reconnexion** :
   - Déconnexion brève du socket client, vérification de la reconnexion automatique du pool SurrealDB et de la cohérence des compteurs.

### 7.2. Mesures de Performances Réelles Observées
Les métriques suivantes seront relevées et documentées sans filtre :
- **Configuration Machine** : CPU, Mémoire RAM, Version de l'OS (Windows), Version de SurrealDB (`surreal.exe 3.2.0`).
- **Latence par Requête** : Mesure sur 100 insertions et lectures (valeur médiane p50, p95, p99).
- **Débit Réel Observé** : Nombre réel de lignes brutes ingérées, normalisées et persistées par seconde.
- **Empreinte Mémoire** : Relevé de l'utilisation mémoire (Working Set / RSS) avant, pendant et après l'ingestion.

---

## 🛑 8. Statut d'Exécution

Conformément à la Règle N°1 de `.agents/AGENTS.md` :
- **L'exécution demeure strictement suspendue.**
- Aucune modification de code ou de configuration ne sera effectuée avant l'accord explicite du CTO sur ce plan révisé.
