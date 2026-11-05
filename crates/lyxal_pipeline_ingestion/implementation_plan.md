# Plan d'implémentation — reprise de `lyxal_pipeline_ingestion`

Suite de `AUDIT.md`. **Q1 à Q4 validées par le CTO (option A pour chacune).**

> Ce fichier remplace l'ancien `implementation_plan.md` du module (plan de réalignement déjà
> exécuté), document historique supprimé par cette reprise (§0.2).

## 1. Décisions demandées

| # | Question | Options | Recommandation |
| :- | :--- | :--- | :--- |
| Q1 | Publication vers le catalogue (I-04) : le catalogue n'accepte un article maître que d'une identité `catalogue_sync_agent` (jeton `aud = lyxal-catalogue`, `iss = lyxal-os`, scope `catalogue:sync:write`). Le worker se connecte en session système et n'a pas cette identité. | **A.** Publication réelle par jeton de service : l'hôte (`lyxal-server`) définit l'accès JWT du catalogue (`DEFINE ACCESS`, clé lue dans la configuration, jamais dans le dépôt) et signe un jeton court `catalogue_sync_agent` (HS256 par `lyxal_crypto::hmac`, primitive existante) ; le publisher ouvre une session authentifiée et appelle `fn::catalogue_item_create` / `_update` avec le contrat documenté du catalogue ; simulation supprimée ; dépendance `lyxal_catalogue` déclarée. **B.** Pas de publication dans ce module : il s'arrête au manifeste approuvé et à l'événement `ingestion.manifest.approved` ; la simulation est supprimée ; la publication relèvera d'un service à venir (`lyxal_auth` ou agent de synchronisation). | **A** : seule option qui rend le pipeline utile de bout en bout et vérifiable par le banc (identités simulées) ; aucune primitive crypto nouvelle. Le contrat d'identité reste celui du catalogue. |
| Q2 | Validation GTIN (I-10) : clé GS1 réimplémentée en Rust. | **A.** Supprimée du Rust ; `fn::ingestion_staged_save` valide le code-barres par `fn::validation_gtin` et renvoie `INGESTION_GTIN_INVALID`, que le worker oriente vers la quarantaine. **B.** Le Rust appelle `fn::validation_gtin` par `call_fn` pour chaque ligne. **C.** Conserver le Rust (exception « parsing »). | **A** : une seule implémentation, dans le Core (§5.7.6), sans aller-retour supplémentaire par ligne. |
| Q3 | Tests (I-08, I-14) : schéma recopié dans le Rust pour les tests ; secret de staging dans le dépôt. | **A.** `init_schema` et `create_in_memory` supprimés ; tests Rust sur le module installé depuis son manifeste (comme `integration_manifest_install.rs`) ; banc SurrealQL `tests/*.test.surql` exécuté en CI par `test_lyxal_modules.py`, sous identités simulées (`ingestion_agent`, `qualification_agent`, `steward_admin`, `catalogue_sync_agent`) ; tests serveur réel sans secret par défaut ; suite PowerShell supprimée. **B.** Garder le schéma recopié. | **A** : les tests doivent prouver le SurrealQL réellement installé, permissions comprises. |
| Q4 | Seed de démonstration `seeds/04_carrelage_demo.surql` (I-17), installé partout. | **A.** Déplacé dans `tests/fixtures/`, jamais installé. **B.** Gardé en seed. **C.** Supprimé. | **A** : même décision que pour le catalogue. |

Appliqué sans question (règles déjà fixées) :

* **Identités** (I-01, I-02) : rôle et opérateur lus uniquement dans la session (`$token` /
  `$auth`) ; `_session_auth`, `approver_role` et `approved_by` sortent du contrat ; la garde du
  manifeste vérifie la session.
* **Entrées** (I-07), selon l'option B déjà retenue par le CTO : moteur
  `fn::validation_object_execute` / `fn::sanitize_object_execute` pour les fonctions appelées
  de l'extérieur (console du Data Steward, référentiels, listes, approbation) ; primitives du
  Core pour les fonctions internes appelées ligne à ligne par le worker (`staged_save`,
  `quarantine_log`, `batch_checkpoint`, enregistrement des lignes brutes). Donnée invalide →
  `INGESTION_INVALID_PARAMETERS`.

## 2. Contrat cible

### SurrealQL

* Fonctions existantes conservées dans leur nom ; ajouts pour remplacer les requêtes Rust
  (I-09) : `fn::ingestion_batch_get`, `_raw_records_save`, `_manifest_execution_item_update`,
  `_rules_load` (familles, spécifications, substitutions). Les lectures par lot passent par les
  listes existantes (`_staged_list`, `_quarantine_list`, `_manifest_get_detail`), typées ; la
  recherche par empreinte est faite par `_batch_create` (`INGESTION_BATCH_DUPLICATE`).
* Écriture principale vérifiée, `INGESTION_WRITE_FORBIDDEN` sinon (§11.4).
* `DEFINE EVENT OVERWRITE` sur les statuts réels : `ingestion.batch.published` (passage à
  `PUBLISHED`) et `ingestion.manifest.approved` (passage à `APPROVED`) ; nom de l'événement de
  lot à valider avec le contrat ci-dessous.
* `TYPE NORMAL SCHEMAFULL` explicite ; une seule migration `migrations/0001_initial.surql`.

### Erreurs

* `error/<thème>/*.surql` : les 40 codes utilisés définis (lots, lignes, staging, quarantaine,
  manifestes, référentiels, preuves, paramètres, permissions, techniques), protégés par
  `record::exists`.
* `src/error.rs` : catalogue Rust aligné sur les définitions, test de correspondance (comme
  `lyxal_runtime`) ; catégories du référentiel `lyxal_error`.
* Module retiré de `PENDING_TAKEOVER` dans le test serveur `every_emitted_error_code_is_defined`.

### Rust

* `_session_auth` et `SessionAuthContext` supprimés ; `approver_role` / `approved_by` retirés
  des DTO d'approbation.
* Aucune erreur masquée : `resolve_unit`, passage en `FAILED`, événements d'échec, sérialisation
  des empreintes (I-03, I-12).
* Aucun `unwrap()` / `panic!` en exécution (I-11) ; un lot en échec ne fait plus s'arrêter le
  worker.
* Requêtes métier remplacées par `call_fn` (I-09) ; `schema/00_core_primitives.surql` supprimé
  (I-15).
* Q1-A : publisher réel (contrat du catalogue : `code`, `type`, `unite_reference` résolue en
  `base_unite:<CODE>`, `code_barre`, `nature_reference = COMMERCIALE`, `master_id`) ; session de
  service ouverte par l'hôte.

### `lyxal_core`

* Réutilisées : `fn::validation_object_execute`, `fn::sanitize_object_execute`, primitives
  (`required_string`, `record`, `integer`, `enum`, `gtin`, `uppercase`, `trim`…).
* Aucune fonction Core nouvelle prévue ; aucun besoin crypto nouveau.

## 3. Lots

| Lot | Contenu |
| :- | :--- |
| 1 ✅ | **Sécurité, erreurs masquées, tests sur le module installé** (P0) : identité lue uniquement dans la session par `fn::ingestion_session_identity` (interne ; session système de l'hôte = `system`, invités refusés par `PERMISSIONS`), `_session_auth` et `approver_role` / `approved_by` sortis des contrats ; approbation des articles et des manifestes impossible par paramètre, à la création ou par écriture directe (gardes sur la session) ; justification de l'approbation transmise au journal (I-01, I-02). Erreurs propagées : `resolve_unit`, passage en `FAILED`, événements, sérialisations (I-03, I-12). Identifiants de staging retirés du dépôt (I-14 ; à changer sur le serveur). `schema/00_core_primitives.surql` supprimé (I-15). Tests Rust basculés sur le module installé depuis son manifeste (`tests/it/support.rs`), `init_schema` / `create_in_memory` supprimés (partie Rust de Q3) ; banc SurrealQL `tests/securite.test.surql` (quatre rôles) et `tests/fonctions.test.surql`. Défauts révélés et corrigés : quarantaine sans `ligne_numero` et sévérité `CRITIQUE` (aucune ligne rejetée ne pouvait être consignée), requalification en `VERIFIED` toujours refusée, exécution de manifeste sans l'état `EXECUTING`, recherche d'article hors index (débit divisé par deux). |
| 2 ✅ | **Master data, événements, installation** : 40 définitions `INGESTION_*` par thème (`error/<thème>/`), une par code utilisé par les fonctions, les gardes ou le Rust ; doublons fusionnés (`INGESTION_MISSING_PROOF` → `INGESTION_PROOF_MISSING`, `INGESTION_MANIFEST_SEAL_REQUIRED` → `INGESTION_MANIFEST_UNSEALED`) ; `IngestionError::info()` aligné (catégories du référentiel, statut HTTP, réessayable) avec test de correspondance (I-06). Événement `ingestion.manifest.approved` sur le statut réel `APPROVED`, en `OVERWRITE`, publication vérifiée par le banc ; `ingestion.batch.completed` supprimé (état inexistant, faits déjà publiés par le worker) (I-05). Défauts conformes au schéma (I-13). Démonstration carrelage dans `tests/fixtures/` (Q4). `TYPE NORMAL` explicite (I-18). Migration sans contenu supprimée. Test serveur : module retiré de `PENDING_TAKEOVER`, codes levés par `THROW` désormais contrôlés (7 codes du catalogue définis à cette occasion). |
| 3 ✅ | **Entrées et persistance par SurrealQL** : entrées contrôlées par `lyxal_core` — moteur `fn::validation_object_execute` / `fn::sanitize_object_execute` (`unknown_keys: "reject"`) pour les fonctions de la console, des référentiels et de la publication, primitives pour les fonctions internes du worker ; `INGESTION_INVALID_PARAMETERS` défini, `INGESTION_INVALID_QUALIFICATION` et `INGESTION_RULE_FAMILY_INVALID` supprimés (cas couverts par le contrôle des paramètres ; 39 définitions) (I-07). Toute écriture vérifiée (`INGESTION_WRITE_FORBIDDEN`) ; transitions d'état construites par SurrealQL au nom de l'identité de session, horodatages écrits en dur supprimés du Rust ; lot créé à l'état `RECEIVED` (doublon de fichier : `INGESTION_BATCH_DUPLICATE`) ; manifeste modifiable seulement en `DRAFT` / `SEALED` ; compte rendu d'exécution réservé à `catalogue_sync_agent` et refusé hors `APPROVED` / `EXECUTING` (I-13). Requêtes Rust remplacées par `call_fn` : `fn::ingestion_batch_get`, `_raw_records_save` (bloc, ligne existante jamais réécrite), `_manifest_execution_item_update`, `_rules_load` ; listes typées (`StagedItem`, `QuarantineRecord`, `PublicationManifest`) ; erreur métier transmise avec son code (`IngestionError::Surreal`) (I-09). Code-barres contrôlé par `fn::validation_gtin` dans `fn::ingestion_staged_save`, qui enregistre un bloc d'articles et renvoie le résultat de chacun ; un code-barres invalide est consigné en quarantaine par le worker ; `gtin.rs` supprimé (I-10, Q2). Moteur de quarantaine en mémoire supprimé (doublon de la table SurrealQL) ; `unwrap()` / `panic!` retirés ; un lot en échec passe en `FAILED` sans arrêter le worker (I-11). Consignation en quarantaine rejouable (une anomalie ouverte par ligne et par code). Débit : les contrôles du Core ramenaient le banc Rust (build de debug) de 91 à 46 articles/s ; décision CTO : `fn::validation_gtin` réécrit dans `lyxal_core` (somme pondérée par `vector::multiply`, même contrat, 4 fois plus rapide, tests complétés) et dépendances compilées en `opt-level = 1` dans le profil de développement du workspace (sans effet en release) ; banc à 180 articles/s. |
| 4 | **Tests** (Q3) : banc SurrealQL complété (lots, qualification, quarantaine, manifestes, référentiels, permissions de lecture) ; suite PowerShell supprimée. |
| 5 | **Publication vers le catalogue** (Q1) : I-04. |
| 6 | **Clôture** : `README.md` à l'état actuel, `ROADMAP.md` mise à jour (étapes réalisées retirées, références corrigées), `docs/ARCHITECTURE_DESIGN.md` confronté au code (mis à jour ou repris dans le README), suppression de `CHANGELOG.md`, des rapports et plans de `docs/`, d'`AUDIT.md` et de ce plan ; `AGENTS.md` (§6 : statut « Clôturé Staging ») et skills alignés. |

Chaque lot fait l'objet d'une PR, fusionnée quand la CI est verte.
