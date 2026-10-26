# 🗺️ Feuille de Route Officielle — Module `lyxal_pipeline_ingestion`

> **Moteur d'ingestion industrielle, normalisation, qualification multi-niveaux et publication contrôlée de catalogues.**  
> **Référence d'architecture :** [`.agents/AGENTS.md`](file:///c:/Users/HP/Desktop/Lyxal_OS/.agents/AGENTS.md) & [`LYXAL_ARCHITECTURE.md`](file:///c:/Users/HP/Desktop/Lyxal_OS/LYXAL_ARCHITECTURE.md).  
> **Gouvernance :** Toute évolution ultérieure requiert un plan d'implémentation préalable et une validation formelle du CTO.

---

## 📊 Matrice d'Avancement & Statuts des Versions

| Version | Thématique Principale | Statut Officiel | Condition / Dépendance |
| :---: | :--- | :---: | :--- |
| **V1.0.0** | **Socle Industriel d'Ingestion & Banc Pilote BTP** | **`DONE` ✅** | **FUNCTIONALLY COMPLETE — STAGING VALIDATED — PRODUCTION NOT AUTHORIZED** |
| **V1.1** | **Connecteurs Fabricants & Preuves Documentaires** | **`PLANNED` 📋** | En attente d'ordre CTO de lancement — Services de stockage de fichiers & secrets |
| **V1.2** | **Synchronisation Incrémentale & Différentielle** | **`PLANNED` 📋** | En attente de V1.1 — Dépend de `lyxal_crypto` (BLAKE3) et `lyxal_catalogue` |
| **V1.3** | **Résolution Avancée des Conflits Multisources** | **`PLANNED` 📋** | En attente de V1.2 — Matrice de scoring et file d'arbitrage Data Steward |
| **V2.0** | **Ingestion Autonome Assistée par Agents IA** | **`PLANNED` 📋** | En attente de V1.3 et bus `lyxal_event` — Validation humaine obligatoire |

---

## 🟢 V1.0.0 — Socle Industriel d'Ingestion & Banc Pilote BTP (`DONE` ✅)

**Statut Officiel :** **FUNCTIONALLY COMPLETE — STAGING VALIDATED — PRODUCTION NOT AUTHORIZED**  
**Rôle :** Moteur d'extraction, normalisation, contrôle d'intégrité, quarantaine et publication contrôlée avec scellement cryptographique BLAKE3.  
**Directive d'Architecture SurrealDB :**  
- **Conserver les 11 tables existantes en `TYPE NORMAL`** (conforme aux conclusions de l'[`audit d'architecture`](file:///c:/Users/HP/Desktop/Lyxal_OS/docs/architecture/AUDIT_SURREALDB_RELATION_TABLES.md)).  
- **Modèle de Traitement :** Le pipeline repose principalement sur des flux séquentiels transactionnels par blocs (chunks) et des relations de traçabilité immuables (`batch -> raw_record -> staged_item -> manifest`).  
- **Aucune conversion en `TYPE RELATION`** n'est prévue ni autorisée sans nouveau besoin fonctionnel formellement démontré et validé par le CTO.  
- **Maintien strict du statut de gouvernance :** Le statut `FUNCTIONALLY COMPLETE — STAGING VALIDATED — PRODUCTION NOT AUTHORIZED` reste scellé et inchangé.

### Capacités Déjà Implémentées & Disponibles
- ✅ **11 Schémas SurrealQL SCHEMAFULL Déclaratifs** ([`schema/`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_pipeline_ingestion/schema/)) : `ingestion_session`, `ingestion_batch`, `ingestion_raw_record`, `ingestion_staged_item`, `ingestion_quarantine_record`, `ingestion_publication_manifest`, `ingestion_family_rule`, `ingestion_specification`, `ingestion_manufacturer_alias`, `ingestion_unit_alias`, `ingestion_substitution_rule`.
- ✅ **22 Fonctions Métier SurrealQL** ([`functions/`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_pipeline_ingestion/functions/)) : Gestion des lots (`batch/`), articles en staging (`staged/`), quarantaine avec traçabilité (`quarantine/`), manifestes avec scellement BLAKE3 (`manifest/`), référentiels dynamiques (`rule/`), dashboard KPIs (`dashboard/`).
- ✅ **10 Définitions d'Erreurs Master Data Canoniques** ([`error/ingestion/`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_pipeline_ingestion/error/ingestion/error_definitions.surql)) : 100% `CREATE` protégées par `!record::exists` (dont `INGESTION_UNAUTHORIZED_APPROVER`).
- ✅ **4 Adaptateurs Rust Streaming Zéro-Allocation** ([`src/adapters/`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_pipeline_ingestion/src/adapters/)) : FAB-DIS 3.0, CSV (délimiteurs configurables), XML / BMEcat, JSON / NDJSON.
- ✅ **Sécurité & RLS sur 4 Rôles Spécialisés** : Cloisonnement strict entre `ingestion_agent`, `qualification_agent`, `steward_admin` et `catalogue_sync_agent`.
- ✅ **Supervision & Résilience Worker** ([`src/worker/`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_pipeline_ingestion/src/worker/)) : Coopération avec `CancellationToken`, reprise après incident avec sauvegarde atomique de `cursor_offset`.
- ✅ **Banc Pilote BTP de 41 Références & 70 Tests Réussis (100%)** :
  - 10 références réelles vérifiées avec preuves pilotes (`VERIFIED`).
  - 25 références à confirmer (`TO_CONFIRM`).
  - 1 référence synthétique de test (`SYNTHETIC`).
  - 1 anomalie GTIN corrompue en quarantaine (`REJECTED`).
  - 4 références génériques normatives DTU 25.41 (`GENERIQUE`).
- ✅ **Verrou de Production par Préfixe** : Interdiction absolue et automatique de publication si une référence contient une preuve pilote (`PROOF-AUTH-2026-*`) ou synthétique (`SYNTH-*`).

---

## 📋 V1.1 — Connecteurs Fabricants et Preuves Documentaires (`PLANNED` 📋)

> **Directive CTO :** Développement non autorisé sans ordre de démarrage spécifique.

### Objectifs Stratégiques
1. **Connecteurs Automatisés Distants :** Développer des adaptateurs de collecte capables d'interroger directement les serveurs fabricants et distributeurs (SFTP sécurisé, API REST partenaires, boîtes aux lettres EDI, dépôts S3/Object Storage).
2. **Gestion Authentifiée des Flux :** Prise en charge des protocoles d'authentification fournisseurs (OAuth2 M2M, certificats mTLS, clés API sécurisées via le gestionnaire de secrets Lyxal OS).
3. **Collecte & Stockage Sécurisé des Preuves Réelles :** Téléchargement, hachage BLAKE3 et archivage des pièces justificatives commerciales officielles (fiches techniques PDF, déclarations de performance DoP, fiches FDES INIES, attestations de conformité CE/NF).
4. **Vérification Positive de Provenance :** Transition des préfixes de simulation vers une chaîne de confiance cryptographique prouvant l'origine légitime du catalogue (signature numérique fournisseur ou validation par tiers de confiance).
5. **Workflow de Validation Data Steward :** Interface et fonctions permettant à un utilisateur authentifié `steward_admin` d'inspecter visuellement les pièces justificatives avant d'autoriser la publication vers le Master Catalogue.
6. **Réutilisation des Services Lyxal OS :** Dépendance exclusive envers les composants d'infrastructure transversaux (gestion des fichiers, coffre-fort de clés, ordonnanceur de tâches).

### Critères d'Acceptation
- [ ] Connecteurs d'acquisition asynchrones supervisés sans blocage des workers.
- [ ] Raccordement natif aux fonctions existantes `fn::ingestion_staged_requalify`.
- [ ] Suppression des tokens de simulation au profit de références vers des documents physiques hachés.
- [ ] Levée du verrou de production uniquement sur justification formelle auditée.

---

## 📋 V1.2 — Synchronisation Incrémentale (`PLANNED` 📋)

> **Directive CTO :** Développement non autorisé sans ordre de démarrage spécifique.

### Objectifs Stratégiques
1. **Détection Différentielle d'Articles :** Comparaison entre le catalogue précédemment publié et la nouvelle version ingérée (articles nouveaux, modifiés dans leurs caractéristiques, ou supprimés de l'offre fabricant).
2. **Import Différentiel Optimisé :** Éviter le re-traitement et la re-qualification des références dont l'empreinte canonique BLAKE3 est strictement inchangée, réduisant la consommation CPU et mémoire de plus de 90%.
3. **Historisation Complète des Mouvements :** Journalisation de chaque synchronisation avec compteurs d'ajouts, de modifications et d'annulations.
4. **Gestion Contrôlée des Retraits :** Si un fabricant retire un produit de sa gamme, la référence dans le Master Catalogue n'est jamais supprimée (intégrité des devis/factures passés) mais bascule vers un état commercial déprécié (`WITHDRAWN` / `OBSOLETE`).
5. **Reprise sur Incident & Idempotence :** Capacité d'interrompre et de reprendre une synchronisation différentielle sans risque de doublon ni d'incohérence d'état.

### Critères d'Acceptation
- [ ] Table de suivi différentiel par lot d'import.
- [ ] Temps de calcul différentiel < 1 seconde pour 10 000 références.
- [ ] Garantie absolue de non-suppression destructrice sur les tables du Master Catalogue (`catalogue_item`).

---

## 📋 V1.3 — Résolution Avancée des Conflits Multisources (`PLANNED` 📋)

> **Directive CTO :** Développement non autorisé sans ordre de démarrage spécifique.

### Objectifs Stratégiques
1. **Rapprochement Multisources :** Identification et mise en correspondance d'un même article industriel distribué par plusieurs grossistes ou négociants BTP (ex: même plaque de plâtre sous 3 références commerciales distributeurs distinctes).
2. **Détection des Divergences :** Identification des conflits de données (divergence de libellés, conditionnements contradictoires, désaccord sur les cotes ou les unités de vente).
3. **Hiérarchie & Scoring de Confiance des Sources :** Attribution d'un indice de fiabilité aux sources (ex: données directes de l'usine fabricant prioritaires sur les données du distributeur).
4. **Arbitrage Humain Data Steward :** Mise en file d'attente d'arbitrage en quarantaine des conflits insolubles automatiquement, avec traçabilité complète de la décision humaine retenue.
5. **Interdiction de Publication Ambiguë :** Verrou technique bloquant toute publication automatique vers le Master Catalogue tant qu'un conflit sur une caractéristique structurante n'a pas été formellement tranché.

### Critères d'Acceptation
- [ ] Moteur de réconciliation attributaire avec matrice de priorité des sources.
- [ ] Extension de `fn::ingestion_quarantine_resolve` pour enregistrer l'arbitrage multisources.
- [ ] Impossibilité pour un lot contenant des conflits non résolus de générer un manifeste approuvé.

---

## 📋 V2.0 — Ingestion Autonome Assistée par Agents IA (`PLANNED` 📋)

> **Directive CTO :** Développement non autorisé sans ordre de démarrage spécifique.

### Objectifs Stratégiques
1. **Découverte Proactive de Sources :** Veille et proposition automatique de nouveaux tarifs et catalogues fabricants disponibles en ligne.
2. **Normalisation Assistée par LLM :** Extraction et structuration de données techniques à partir de formats non standardisés (catalogues PDF non structurés, pages web, fiches de spécifications disparates).
3. **Détection Intelligente d'Anomalies :** Détection d'erreurs sémantiques ou physiques que les règles statiques ne peuvent capter (ex: incohérence entre une dénomination de cloison acoustique et une masse surfacique aberrante).
4. **Suggestions de Rapprochement & Explicabilité :** Propositions argumentées de correspondance avec fiches patronnes BTP existantes, accompagnées de l'explication du raisonnement.
5. **Validation Humaine Obligatoire :**
   - Aucune modification, validation ou publication ne peut être exécutée de manière totalement autonome par un modèle d'IA.
   - Les agents IA proposent des arbitrages pré-remplis ; le Data Steward (`steward_admin`) conserve la responsabilité légale et technique de la validation finale.

### Critères d'Acceptation
- [ ] Interface d'inspection des propositions d'enrichissement IA avec score de confiance.
- [ ] Journalisation immuable de l'empreinte du modèle et des paramètres d'inférence.
- [ ] Verrou interdisant toute publication non contresignée par une session humaine active.

---

## 🔗 Liens & Documents Associés
- Audit architectural des tables relationnelles SurrealDB : [`docs/architecture/AUDIT_SURREALDB_RELATION_TABLES.md`](file:///c:/Users/HP/Desktop/Lyxal_OS/docs/architecture/AUDIT_SURREALDB_RELATION_TABLES.md)
- Documentation officielle du module : [`README.md`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_pipeline_ingestion/README.md)
- Rapport de clôture fonctionnelle V1.0.0 : [`docs/V1_CLOSURE_REPORT.md`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_pipeline_ingestion/docs/V1_CLOSURE_REPORT.md)
- Charte d'architecture du workspace : [`.agents/AGENTS.md`](file:///c:/Users/HP/Desktop/Lyxal_OS/.agents/AGENTS.md)
- Roadmap transversale d'intégration : [`docs/14-roadmap/ROADMAP_LYXAL_SPACE.md`](file:///c:/Users/HP/Desktop/Lyxal_OS/docs/14-roadmap/ROADMAP_LYXAL_SPACE.md)
