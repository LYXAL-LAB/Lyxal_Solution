# 📦 Module Lyxal Pipeline Ingestion

> **Module ID :** `lyxal_pipeline_ingestion`  
> **Version :** `1.0.0`  
> **Statut Officiel CTO :** **`FUNCTIONALLY COMPLETE — STAGING VALIDATED — PRODUCTION NOT AUTHORIZED`**  


Le module **Lyxal Pipeline Ingestion** assure l'ingestion industrielle, la normalisation, la qualification multi-niveaux et la publication strictement contrôlée des flux catalogues fabricants (FAB-DIS, CSV, XML/BMEcat, JSON) vers le Master Catalogue de Lyxal OS.

---

## 🏛️ Architecture & Respect des Frontières

Conformément à `AGENTS.md` :

1. **Persistance & Règles Métier dans SurrealDB** :
   - 11 tables `SCHEMAFULL` déclaratives sécurisées par RLS.
   - Fonctions publiques `fn::ingestion_*` respectant le contrat universel `fn::result_ok` / `fn::error_result`.
   - Externalisation complète des règles métier configurables :
     - Familles BTP (`ingestion_family_rule`)
     - Spécifications patronnes et tolérances (`ingestion_specification`)
     - Alias fabricants et holdings (`ingestion_manufacturer_alias`)
     - Alias unités raccordés à `base_unite` (`ingestion_unit_alias`)
     - Substitutions contextualisées et révocables (`ingestion_substitution_rule`)
2. **Rust comme Moteur Technique & Adaptateurs** :
   - Streaming et parsing zéro allocation.
   - Empreintes cryptographiques BLAKE3 (`lyxal_crypto`).
   - Appels SurrealDB systématiquement enveloppés via le trait `LyxalSurrealCall` et `store.call_fn(...)`.
   - Worker supervisé coopérant avec `CancellationToken` (`lyxal_runtime`).
   - Événements publiés sur `lyxal_event` Transactional Outbox.
3. **Publication Contrôlée vers Catalogue V1.1** :
   - Scellement BLAKE3 obligatoire et approbation formelle du Data Steward (`steward_admin`).
   - Utilisation exclusive des fonctions publiques de `lyxal_catalogue` (`fn::catalogue_relation_create`).
   - Distinction stricte entre référence commerciale vérifiée, similarité technique, équivalence fonctionnelle et substitution contextualisée.

---

## 📂 Structure Canonique

```text
lyxal_pipeline_ingestion/
├── manifest.toml            <-- Déclaration formelle du runtime, ressources et dépendances
├── schema/                  <-- 12 schémas déclaratifs (11 tables SCHEMAFULL + 00_core_primitives.surql)
├── migrations/              <-- Scripts de migration ordonnés
├── functions/               <-- 20 fonctions métier SurrealQL fn::ingestion_*
│   ├── batch/               <-- 3 fonctions : create, checkpoint, transition
│   ├── staged/              <-- 3 fonctions : save, list, requalify
│   ├── quarantine/          <-- 3 fonctions : log, list, resolve
│   ├── manifest/            <-- 5 fonctions : save, approve, record_exec, list, get_detail
│   ├── rule/                <-- 5 fonctions : resolve_manufacturer, resolve_unit, rule_family_add, rule_spec_add, rule_substitution_add
│   └── dashboard/           <-- 1 fonction  : dashboard_metrics
├── events/                  <-- DEFINE EVENT raccordés à fn::event_publish
├── seeds/                   <-- Données initiales et démo (Familles, Specs, Alias, Carrelage)
├── error/                   <-- Définitions d'erreurs master data INGESTION_*
├── src/                     <-- Code source Rust (Store call_fn, Workers, Grouping Engine, Adapters)
├── docs/                    <-- Dossier documentaire de recette (STAGING_RECETTE_REPORT.md, V1_CLOSURE_REPORT.md)
├── README.md                <-- Documentation officielle du module
├── CHANGELOG.md             <-- Historique des versions et réalignements
└── implementation_plan.md   <-- Plan de cadrage et validation CTO
```

---

## 📋 Inventaire Officiel des 22 Fonctions SurrealQL Déployées

L'environnement Staging réel instancie **22 fonctions SurrealQL** réparties en deux catégories strictement délimitées :

### 1. Primitives Communes Transversales (2 fonctions — `schema/00_core_primitives.surql`)
* `fn::result_ok($data)` : Enveloppe canonique de succès universel (`{ success: true, data: $data }`).
* `fn::error_result($code, $language, $details)` : Enveloppe canonique d'erreur universelle conforme à `lyxal_error`.

### 2. Fonctions Métier Dédiées au Pipeline (20 fonctions — `functions/`)
* **Gestion des Lots (`batch/`) :** `fn::ingestion_batch_create`, `fn::ingestion_batch_checkpoint`, `fn::ingestion_batch_transition`.
* **Articles en Staging (`staged/`) :** `fn::ingestion_staged_save`, `fn::ingestion_staged_list`, `fn::ingestion_staged_requalify`.
* **Gestion de la Quarantaine (`quarantine/`) :** `fn::ingestion_quarantine_log`, `fn::ingestion_quarantine_list`, `fn::ingestion_quarantine_resolve`.
* **Manifestes de Publication (`manifest/`) :** `fn::ingestion_manifest_save`, `fn::ingestion_manifest_approve`, `fn::ingestion_manifest_record_exec`, `fn::ingestion_manifest_list`, `fn::ingestion_manifest_get_detail`.
* **Règles & Référentiels Dynamiques (`rule/`) :** `fn::ingestion_resolve_manufacturer`, `fn::ingestion_resolve_unit`, `fn::ingestion_rule_family_add`, `fn::ingestion_rule_spec_add`, `fn::ingestion_rule_substitution_add`.
* **Pilotage & Métriques (`dashboard/`) :** `fn::ingestion_dashboard_metrics`.

---

## 🧪 Tests & Recette Industrielle Staging

- **70 tests automatisés exécutés, 70 tests passés avec succès (100% au vert)** :
  - 30 tests unitaires internes (`src/lib.rs`).
  - 39 tests d'intégration industrielle (dont benchmark de 1 600 articles à 98 ops/sec, RLS 4 rôles, résilience et checkpoints worker).
  - 1 test d'intégration du serveur hôte officiel (`apps/lyxal-server`) couvrant le cycle de vie complet (`install_and_start` -> endpoints HTTP `/live`, `/ready`, `/health`, `/api/v1/system/modules` -> `stop_all`).
- **Déploiement réel** : SurrealDB 3.2.0 persistant (`surrealkv`), double passe d'idempotence 100% validée.

---

## 🔒 Gouvernance & Conditions de Mise en Production Future (CTO)

1. **Gel Fonctionnel V1.0.0 :** Le périmètre fonctionnel est gelé. Le module entre en phase de maintenance corrective et d'intégration globale Lyxal OS.
2. **Condition Stricte de Production :** Les références du banc pilote BTP possèdent des identifiants techniques (`PROOF-AUTH-2026-*`), et non des pièces justificatives fabricant physiquement authentifiées.
3. **Exigence de Preuve Positive :** L'ouverture future de la publication vers le Master réel (`lyxal_catalogue`) exigera impérativement une vérification positive de la provenance physique (flux EDI certifié, tiers certificateur ou audit physique documenté par le Data Steward). Le verrou automatique par préfixe demeure actif pour bloquer toute mise en production prématurée.

---

## 🗺️ 7. Feuille de Route & Évolutions Stratégiques

Pour le détail des versions, objectifs et critères d'acceptation de `lyxal_pipeline_ingestion` (V1.0.0 clôturée, V1.1 à V2.0 planifiées) :
* 📄 **Feuille de Route Officielle du Module :** [`ROADMAP.md`](./ROADMAP.md)
* 🌐 **Intégration Transversale LYXAL SPACE :** [`docs/14-roadmap/ROADMAP_LYXAL_SPACE.md`](file:///c:/Users/HP/Desktop/Lyxal_OS/docs/14-roadmap/ROADMAP_LYXAL_SPACE.md)

