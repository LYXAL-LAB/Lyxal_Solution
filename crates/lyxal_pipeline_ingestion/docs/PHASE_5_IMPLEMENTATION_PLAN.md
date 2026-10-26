# 📋 PLAN TECHNIQUE DÉTAILLÉ — PHASE 5 : DATA STEWARD & OBSERVABILITÉ
## Module : `lyxal_pipeline_ingestion`
**Statut : EXÉCUTION AUTORISÉE PAR LE CTO — VALIDATION DES SESSIONS & OBSERVABILITÉ**
**Référentiel Obligatoire : `C:\Users\HP\Desktop\Lyxal_OS\.agents\AGENTS.md`**
**Date : 25 Octobre 2026**

---

## 🏛️ 1. Principes Directeurs & Cadre Architectural

Conformément à la Charte d'Architecture Lyxal OS (`AGENTS.md`) :
1. **Les données vivent dans SurrealDB** : persistance des lots, staging, quarantaine, manifestes et métadonnées d'audit.
2. **La logique métier des données vit dans SurrealQL** : toutes les mutations, requalifications et transitions d'état sont exécutées par les fonctions publiques `fn::ingestion_*($params: object)`.
3. **L'UI et l'hôte ne contiennent aucune logique métier** : l'interface Data Steward et les dashboards d'observabilité sont de purs consommateurs de l'API publique.
4. **Pas d'application ou d'infrastructure parallèle** :
   - Réutilisation du binaire hôte `lyxal_server` (handlers Axum existants).
   - Réutilisation de l'authentification et des sessions du runtime Lyxal (rôles `steward_admin`, `catalogue_sync_agent`, `operator`).
   - Réutilisation du bus transactionnel `lyxal_event` (`event_outbox`).
   - Réutilisation du référentiel universel des unités `base_unite` (`lyxal_base`).
5. **Zéro publication dans le Master de production** :
   - Maintien hermétique de `isolated_test_mode`.
   - Les publications de Phase 5 valident le cycle complet jusqu'à `COMMITTED` dans l'espace isolé sans toucher aux tables de production du Catalogue V1.1.
6. **Vérification d'identité stricte basée sur la session authentifiée** :
   - Les permissions et l'identité de l'opérateur sont extraites et validées depuis la session authentifiée (`$auth` / session token), et non depuis de simples paramètres déclarés par le client (`steward_id`, `approver_role`), afin d'interdire toute élévation de privilèges.

---

## 🔍 2. Chantier 1 : Gestion Data Steward des Anomalies, Preuves & Requalifications

### 2.1. Consultation et Filtrage de la Quarantaine
- **Objectif** : Permettre au Data Steward d'inspecter les anomalies bloquées en quarantaine (`ingestion_quarantine_record`).
- **Filtres de consultation** :
  - Par `batch_id`
  - Par niveau de sévérité : `CRITICAL` (syntaxe corrompue, hachage invalide), `ERROR` (GTIN erroné, unité non reconnue), `WARNING` (désignation tronquée, tolérance dépassée).
  - Par code d'erreur normalisé `INGESTION_*`.
- **Fonction SurrealQL publique dédiée** : `fn::ingestion_quarantine_list($params: object)`

### 2.2. Workflow de Requalification d'Articles
- **Règle formelle absolue CTO** :
  - Le passage du statut `TO_CONFIRM` vers `VERIFIED` exige **obligatoirement** une preuve commerciale authentifiée (`CommercialProof`).
  - Si la preuve d'origine fabricant faisait défaut, la requalification manuelle par le Data Steward doit injecter une preuve formelle de type `CommercialProofType::StewardDocumentedValidation` comprenant :
    - `proof_reference` : référence de la pièce justificative (ex: `DOC-STEWARD-2026-VAL-4412`).
    - `source_authority` : `STEWARD_CHIEF_REVIEW` ou organisme habilité.
    - `verified_by` : identifiant du steward (`session.user_id`).
    - `verified_at` : horodatage ISO-8601.
    - Justification d'au moins 10 caractères.
  - La fonction SurrealQL vérifie que l'opérateur détient le rôle `steward_admin`.
- **Fonction SurrealQL publique dédiée** : `fn::ingestion_staged_requalify($params: object)`

### 2.3. Correction Assistée des Anomalies en Quarantaine
- Possibilité pour le Data Steward de corriger une métadonnée erronée (ex: corriger un libellé ou assigner une unité valide issue de `base_unite`).
- La correction republie l'enregistrement corrigé dans la table `ingestion_staged_item` avec archivage de l'anomalie résolue.
- **Fonction SurrealQL publique dédiée** : `fn::ingestion_quarantine_resolve($params: object)`

---

## 📊 3. Chantier 2 : Observabilité des Lots, Checkpoints & Erreurs

### 3.1. Dashboard Temps Réel d'Ingestion
- **Indicateurs clés de performance (KPI)** :
  - Nombre total de lots traités, en cours (`PARSING`, `VALIDATING`) et scellés.
  - Répartition dynamique des qualifications : `% VERIFIED` / `% TO_CONFIRM` / `% REJECTED`.
  - Débit moyen de streaming mesuré (articles par seconde).
  - Progression des lots en cours via curseurs de checkpoints (`cursor_offset` / `total_lignes`).
- **Topologie des erreurs** :
  - Fréquence d'occurrence des codes `INGESTION_*` par fabricant et format source.
  - Taux de conversion après arbitrage steward.
- **Fonction SurrealQL publique dédiée** : `fn::ingestion_dashboard_metrics($params: object)`

### 3.2. Sonde de Santé Système (`HealthEngine`)
- Conformément à AGENTS.md § 5.8.4 :
  - Implémentation du trait `lyxal_runtime::health::HealthCheck` par la structure `IngestionHealthCheck`.
  - Évaluation de l'état :
    - `HealthStatus::Healthy` : pipeline opérationnel, persistance active, débits normaux.
    - `HealthStatus::Degraded` : taux d'anomalies en quarantaine > 25% sur les derniers lots ou latence de checkpoint élevée.
    - `HealthStatus::Unhealthy` : base inaccessible ou échec critique de scellement BLAKE3.

---

## 📜 4. Chantier 3 : Consultation des Manifestes & Audit Trail

### 4.1. Consultation et Intégrité Cryptographique
- Liste et détail des manifestes de publication (`ingestion_publication_manifest`).
- Affichage de l'empreinte de scellement BLAKE3 (`seal_hash`) garantissant le scellement immuable des articles qualifiés.
- Indicateur visuel d'intégrité : vérification automatique que le scellement correspond toujours à l'empreinte canonique calculée des articles du lot.

### 4.2. Historique et Traçabilité des Approbations
- Consultation de la timeline complète des transitions (`transitions` : `from_state`, `to_state`, `triggered_by`, `reason`, `transitioned_at`).
- Contrôle strict de l'action d'approbation :
  - Activée uniquement si le manifeste est en statut `SEALED`.
  - Action restreinte aux utilisateurs ayant le rôle `steward_admin`.
  - Consignation immédiate dans l'audit trail et émission de l'événement Outbox `ingestion.manifest.approved`.
- Consultation du compte-rendu d'exécution ligne par ligne (`execution_items`) avec motif des éventuels échecs.
- **Fonctions SurrealQL publiques dédiées** :
  - `fn::ingestion_manifest_list($params: object)`
  - `fn::ingestion_manifest_get_detail($params: object)`

---

## 🧱 5. Chantier 4 : Traitement Contrôlé des 41 Références BTP Pilotes

### 5.1. Jeu de Données Pilote BTP
Le jeu de 41 références pilotes couvre les grands industriels du BTP :
- **Saint-Gobain Placo** : plaques BA13, BA15, Placoflam, hydrofuges, rails R48, montants M48.
- **Isover** : laine de verre GR32, IBR, panneaux rigides acoustiques.
- **Knauf** : plaques KF, cloisons K-Dalles, profilés.
- **Siniat** : Prégyplac BA13, Prégyflam.
- **Schneider Electric / Legrand** : appareillage Odace, Céliane, prises 2P+T, disjoncteurs.

### 5.2. Protocole de Validation Pilote
1. **Injection du lot pilote** (41 références) avec injection volontaire de cas limites :
   - Références avec preuve EDI certifiée (éligibles `VERIFIED`).
   - Références techniques valides sans preuve formelle (orientées `TO_CONFIRM`).
   - Références avec anomalies (syntaxe GTIN, unité fabricant exotique) (orientées `REJECTED` / quarantaine).
2. **Exercice du rôle Data Steward** :
   - Résolution assistée des unités inconnues via ajout d'alias dans `ingestion_unit_alias`.
   - Rattachement d'une preuve `STEWARD_DOCUMENTED_VALIDATION` sur les articles `TO_CONFIRM`.
   - Requalification traçable via `fn::ingestion_staged_requalify`.
3. **Scellement BLAKE3 et Publication Isolée** :
   - Scellement du manifeste par `fn::ingestion_manifest_save`.
   - Approbation formelle par `fn::ingestion_manifest_approve` sous session `steward_admin`.
   - Exécution sous agent `catalogue_sync_agent` en mode isolé.
   - Validation que 100% des articles vérifiés atteignent `COMMITTED` sans altérer le catalogue de production.

---

## 📐 6. Chantier 5 : Spécification des Nouvelles Fonctions Publiques SurrealQL

Conformément à AGENTS.md § 5.3, toutes les fonctions publiques acceptent un paramètre unique `$params: object` et retournent le contrat universel `fn::result_ok` / `fn::error_result`.

### 6.1. `fn::ingestion_dashboard_metrics`
- **Fichier** : `functions/dashboard/ingestion_dashboard_metrics.surql`
- **Rôle** : Agrège les compteurs globaux du pipeline pour le tableau de bord Data Steward.
- **Paramètres** : `{ batch_id: option<string> }`

### 6.2. `fn::ingestion_staged_list`
- **Fichier** : `functions/staged/ingestion_staged_list.surql`
- **Rôle** : Recherche paginée et filtrée dans la table `ingestion_staged_item`.
- **Paramètres** : `{ batch_id: option<string>, qualification: option<string>, fabricant: option<string>, limit: option<int>, start: option<int> }`

### 6.3. `fn::ingestion_staged_requalify`
- **Fichier** : `functions/staged/ingestion_staged_requalify.surql`
- **Rôle** : Requalification unitaire ou groupée d'articles par le Data Steward avec injection de preuve obligatoire.
- **Paramètres** : `{ item_id: string, new_qualification: string, steward_id: string, approver_role: string, proof_reference: string, justification: string }`

### 6.4. `fn::ingestion_quarantine_list`
- **Fichier** : `functions/quarantine/ingestion_quarantine_list.surql`
- **Rôle** : Consultation paginée de la quarantaine.
- **Paramètres** : `{ batch_id: option<string>, severite: option<string>, limit: option<int>, start: option<int> }`

### 6.5. `fn::ingestion_quarantine_resolve`
- **Fichier** : `functions/quarantine/ingestion_quarantine_resolve.surql`
- **Rôle** : Marque une anomalie comme traitée après correction ou dispense par le steward.
- **Paramètres** : `{ quarantine_id: string, resolution_action: string, steward_id: string, comment: string }`

### 6.6. `fn::ingestion_manifest_list`
- **Fichier** : `functions/manifest/ingestion_manifest_list.surql`
- **Rôle** : Liste l'ensemble des manifestes avec statut, hash BLAKE3, et métriques.
- **Paramètres** : `{ statut: option<string>, limit: option<int>, start: option<int> }`

### 6.7. `fn::ingestion_manifest_get_detail`
- **Fichier** : `functions/manifest/ingestion_manifest_get_detail.surql`
- **Rôle** : Récupère le détail exhaustif d'un manifeste, vérifie l'intégrité de son scellement et liste les transitions et items exécutés.
- **Paramètres** : `{ manifest_ref: string }`
- **Retour** : `{ manifest: object, seal_intact: bool, execution_items: array, transitions: array }`

---

## 📖 7. Chantier 6 : Spécification de l'Évolution de `lyxal_catalogue` V1.2 (Hors Périmètre Phase 5)

Conformément à la décision CTO : *Conserver lyxal_catalogue V1.1 inchangé. Documenter l'évolution envisagée pour Catalogue V1.2 sans l'implémenter maintenant.*

### Diagnostic de la Limitation de `lyxal_catalogue` V1.1
Dans `lyxal_catalogue` V1.1, la table `catalogue_relation` est définie comme suit :
```surql
DEFINE TABLE catalogue_relation SCHEMAFULL;
DEFINE FIELD source ON TABLE catalogue_relation TYPE record<catalogue_item>;
DEFINE FIELD cible ON TABLE catalogue_relation TYPE record<catalogue_item>;
DEFINE FIELD relation_type ON TABLE catalogue_relation TYPE string;
DEFINE INDEX idx_cat_relation_unique ON TABLE catalogue_relation COLUMNS source, cible, relation_type UNIQUE;
```
Cette modélisation interdit d'associer un contexte constructif : une relation `SUBSTITUT` est forcément globale, ce qui contrevient à la réglementation BTP (une plaque BA13 Placo n'est substituable par une BA13 Siniat qu'au sein d'un système cloison testé au feu avec procès-verbal CSTB).

### Spécification Canonique pour `lyxal_catalogue` V1.2 (Future Évolution)
1. **Évolution du schéma déclaratif `schema/catalogue_relation.surql`** :
   ```surql
   DEFINE FIELD context_scope ON TABLE catalogue_relation TYPE option<string>;
   DEFINE FIELD certification_body ON TABLE catalogue_relation TYPE option<string>;
   DEFINE FIELD certification_ref ON TABLE catalogue_relation TYPE option<string>;
   DEFINE FIELD valid_until ON TABLE catalogue_relation TYPE option<datetime>;

   -- Remplacement de l'index unique global par un index contextualisé
   DEFINE INDEX idx_cat_relation_scoped_unique ON TABLE catalogue_relation
       COLUMNS source, cible, relation_type, context_scope UNIQUE;
   ```
2. **Signature de la fonction publique `fn::catalogue_relation_create` V1.2** :
   ```surql
   DEFINE FUNCTION OVERWRITE fn::catalogue_relation_create($params: object) {
       -- Prise en compte optionnelle de context_scope, certification_body, certification_ref, valid_until
   };
   ```
3. **Compatibilité ascendante** : les relations générales sans contexte conservent `context_scope = NONE`, préservant 100% du comportement V1.1.

---

## 🧪 8. Plan de Tests & Critères d'Acceptation de la Phase 5

### 8.1. Critères d'Acceptation Formels (Definition of Done)
1. **Sécurité & Rôles** : Toute tentative de requalification ou d'approbation effectuée sans le rôle `steward_admin` est systématiquement rejetée avec l'erreur `INGESTION_UNAUTHORIZED_APPROVER`.
2. **Garantie de Preuve Inviolable** : Zéro passage au statut `VERIFIED` sans `CommercialProof` valide et auditée.
3. **Observabilité Exhaustive** : Les métriques de dashboard reflètent fidèlement les volumétries réelles de SurrealDB sans divergence.
4. **Scellement Cryptographique** : Tout manifeste approuvé est préalablement scellé par son empreinte BLAKE3 calculée sur les articles éligibles.
5. **Validation Pilote BTP** : Les 41 références pilotes sont traitées de bout en bout et documentées.
6. **Non-régression Globale** : Les 54 tests existants restent 100% au vert.

### 8.2. Nouvelle Suite de Tests Dédiée Phase 5 (8 tests d'intégration, 62 tests au total)
La Phase 5 comprend 8 tests d'intégration répartis en deux suites :
- Dans `tests/integration_phase5_steward.rs` (7 tests) :
  1. `test_1_dashboard_metrics_aggregation` : vérification des calculs agrégés et filtres par lot.
  2. `test_2_staged_listing_and_filtering` : listing paginé des articles staging avec filtres (lot, qualification, fabricant).
  3. `test_3_steward_requalification_session_security` : sécurité d'authentification basée sur la session et interdiction absolue d'élévation par paramètres déclaratifs.
  4. `test_4_requalification_verified_requires_strict_commercial_proof` : exigence absolue de `CommercialProof` traçable pour tout passage en `VERIFIED`.
  5. `test_5_quarantine_listing_and_resolution_forces_to_confirm` : résolution d'anomalie basculant strictement en `TO_CONFIRM` (et jamais directement en `VERIFIED`).
  6. `test_6_manifest_listing_and_detail_integrity` : consultation des manifestes et vérification cryptographique BLAKE3 du scellement.
  7. `test_7_ingestion_health_check_probe` : sonde de santé officielle implémentant `lyxal_runtime::ModuleHealthCheck`.
- Dans `tests/integration_btp_41_qualification.rs` (1 test exhaustif) :
  8. `test_full_pilot_41_btp_references_lifecycle` : cycle de vie complet des 41 références pilotes BTP (10 VERIFIED avec preuve réelle, 25 TO_CONFIRM, 5 anomalies REJECTED en quarantaine, 1 synthétique isolée).

---

## 🏁 9. Statut d'Exécution & Bilan des Tests

- **Exécution Phase 5** : Réalisée et validée.
- **7 Fonctions Publiques SurrealQL** : Implémentées, testées et enregistrées dans `manifest.toml`.
- **Résultat des Tests** : **62 tests exécutés, 62 passés avec succès (100% au vert, 0 échec)**.
- **Master de Production** : Zéro écriture, intégrité totale préservée.
- **Validation Finale** : Soumise à l'arbitrage du CTO via `docs/PHASE_5_EXECUTION_REPORT.md`.
