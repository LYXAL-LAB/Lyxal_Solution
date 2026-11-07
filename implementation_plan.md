# Plan d'implémentation — audit externe, lot 1 (A09, A08, A03)

Premier lot de correction de l'audit externe
[`audit_externe/2026-11-07_audit_crates_cto_chatgpt_codex.md`](audit_externe/2026-11-07_audit_crates_cto_chatgpt_codex.md).
Constats vérifiés sur `main` (après #87) en lecture seule. Changement sur trois crates du noyau
(`lyxal_error`, `lyxal_event`, `lyxal_runtime`), sans dépendance entre les trois corrections ;
aucun autre module ne les appelle (vérifié par recherche dans le dépôt). Ce plan est placé à la
racine parce qu'il couvre plusieurs crates ; il est supprimé une fois exécuté et fusionné
(`.agents/AGENTS.md` §0.3).

**En attente de validation du CTO (Q1 à Q3).**

## 1. Constats

| ID | Crate | Constat | Preuve |
| :- | :- | :--- | :--- |
| A09 | `lyxal_error` | Sept fonctions annoncent un succès sans vérifier leur écriture. Les tables `error_definition`, `error_external_mapping` et `error_occurrence` refusent l'écriture aux identités d'enregistrement : `CREATE` / `UPDATE ONLY` renvoient alors `NONE` (ou `[]`), et la fonction répond `ok: true` (§11.4). | `error_definition_create.surql:57`, `error_definition_update.surql:49`, `error_definition_disable.surql:35`, `error_mapping_create.surql:56`, `error_mapping_update.surql:64`, `error_mapping_disable.surql:33`, `error_log.surql:53` |
| A09 bis | `lyxal_error` | `fn::error_log` renvoie `data: NONE` dans deux cas différents : journalisation désactivée par la définition (voulu) et écriture refusée (erreur masquée). | `error_log.surql:52-53` |
| A09 ter | `lyxal_error` | `fn::error_occurrence_purge_before` renvoie `count: 0` aussi quand la suppression est refusée. | `error_occurrence_purge_before.surql:32` |
| A08 | `lyxal_event` | La purge supprime les livraisons `delivered` anciennes sans regarder le curseur durable de leur abonnement. Une livraison livrée **après** une séquence encore en retry peut être purgée ; quand le trou se résout, `fn::event_flush_batch` compte une séquence manquante et lève `EVENT_CURSOR_MISSING_SEQUENCE_HOLE` à chaque tentative : l'abonnement est **bloqué définitivement**. Il suffit qu'une livraison reste en retry plus longtemps que la rétention (7 jours par défaut). | `event_purge_garbage.surql:25`, `event_flush_batch.surql:123` |
| A03 | `lyxal_runtime` | `FilesystemResourceProvider` annonce une protection contre les liens symboliques qu'il n'applique pas (`is_file`, `metadata`, `fs::read` suivent les liens). Il n'est utilisé par aucun code de production : `lyxal-server` embarque les ressources (`EmbeddedResourceProvider`) et `ModulePackage::from_filesystem`, seul appelant, n'est appelé nulle part. | `resource/filesystem.rs:12`, `package/model.rs:39` |

## 2. Décisions demandées

| # | Question | Options | Recommandation |
| :- | :--- | :--- | :--- |
| Q1 | Contrat de `fn::error_log` (A09 bis) | **A.** `result_ok({ logged: true, occurrence })` si écrite, `result_ok({ logged: false, occurrence: NONE })` si la définition désactive la journalisation, `ERROR_WRITE_FORBIDDEN` si refusée. **B.** Garder `data` = occurrence ou `NONE`, et ajouter seulement `ERROR_WRITE_FORBIDDEN`. | **A** : l'appelant distingue explicitement « non journalisé par choix » de « refusé ». Rupture sans appelant à mettre à jour (aucun wrapper Rust ni module n'appelle `fn::error_log`, seuls les tests). |
| Q2 | Tests des refus d'écriture de `lyxal_error` | **A.** Ajouter un banc SurrealQL `crates/lyxal_error/tests/*.test.surql` exécuté par `scripts/ci/test_lyxal_modules.py` : identités simulées, chaque fonction publique `fn::error_*` appelée (exigence du banc). **B.** Tests Rust d'intégration seulement, avec un accès d'enregistrement créé dans le test. | **A** : c'est le standard de la checklist (§13, « Tests `tests/*.test.surql` … identités et permissions ») et le banc fournit déjà les identités ; `lyxal_error` est le seul module SurrealQL du noyau sans banc. |
| Q3 | A03 | **A.** Supprimer `FilesystemResourceProvider`, `ModulePackage::from_filesystem` et ce qui ne sert qu'à eux. **B.** Les conserver et implémenter le refus des liens symboliques et le confinement réel. | **A** (accord CTO du 7 novembre) : code sans appelant (§0.2) ; s'il faut un jour charger un module depuis le disque, il sera conçu avec son modèle de confiance. |

## 3. Contrat cible (si Q1-A, Q2-A, Q3-A)

### `lyxal_error` (A09)

* Nouveau code `ERROR_WRITE_FORBIDDEN` (master data `error/error_definitions.surql`, forme
  rejouable, fr/en, catégorie `authorization`, HTTP 403, non réessayable), détail
  `{ table }`.
* Chaque écriture principale est vérifiée ; si elle est filtrée, la fonction renvoie
  `fn::error_result("ERROR_WRITE_FORBIDDEN", $p.language, { table: "<table>" })` :
  * `error_definition_create`, `error_mapping_create` : `CREATE ONLY` dans une variable, refus si
    `NONE` ;
  * `error_definition_update`, `error_mapping_update` : `UPDATE ONLY`, refus si `NONE` ;
  * `error_definition_disable`, `error_mapping_disable` : `UPDATE ONLY … RETURN AFTER`, refus si
    `NONE` (aujourd'hui `UPDATE` non vérifié) ;
  * `error_occurrence_purge_before` : nombre d'occurrences visibles avant suppression comparé au
    nombre supprimé (`DELETE … RETURN BEFORE`) ; refus si des occurrences visibles n'ont pas été
    supprimées ;
  * `error_log` : contrat Q1-A ; refus si le `CREATE` renvoie `NONE`.
* `COMMENT` et en-têtes des fonctions mis à jour ; `README.md` de `lyxal_error` (contrat de
  `fn::error_log`, liste des codes).
* Aucun changement des DTO Rust (`ErrorLogParams` et les autres paramètres restent identiques) ;
  aucune fonction Core nouvelle.

### `lyxal_event` (A08)

* `fn::event_purge_garbage` ne supprime une livraison `delivered` ancienne que si sa séquence est
  couverte par le curseur durable de son abonnement :
  `delivery_seq != NONE AND delivery_seq <= last_persisted_cursor` de
  `event_subscription_progress` pour `subscription`. Une livraison sans progression enregistrée
  n'est pas purgée.
* Un événement d'outbox n'est supprimé que si **aucune** livraison restante ne le référence
  (aujourd'hui : aucune livraison non livrée), puisque des livraisons livrées non couvertes par le
  curseur sont désormais conservées.
* Contrat public inchangé (`PurgeGarbageParams`, retour `true`).

### `lyxal_runtime` (A03)

* Supprimés : `resource/filesystem.rs` (`FilesystemResourceProvider`,
  `DEFAULT_MAX_RESOURCE_SIZE`), `ModulePackage::from_filesystem`, leurs réexports (`resource/mod.rs`,
  `lib.rs`) et la mention dans la documentation du crate (`lib.rs:10`, `README.md` s'il les cite).
* Supprimés car utilisés seulement par ce lecteur : variantes `RuntimeError::InvalidResourcePath`,
  `ResourceTooLarge`, `ResourceEncodingError`, `ResourceReadFailed`, leurs entrées du catalogue
  (`error/catalog.rs`) et leurs définitions `RUNTIME_RESOURCE_INVALID_PATH`,
  `RUNTIME_RESOURCE_TOO_LARGE`, `RUNTIME_RESOURCE_ENCODING_ERROR`, `RUNTIME_RESOURCE_READ_FAILED`
  (`error/runtime.surql`). `ResourceNotFound` reste (lecteur embarqué).
* Tests du lecteur de fichiers retirés de `tests/it/resource_provider_tests.rs` ; ceux du lecteur
  embarqué et de la découverte restent.

## 4. Tests

| Constat | Preuve attendue |
| :- | :--- |
| A09 | Banc `crates/lyxal_error/tests/` : sous une identité d'enregistrement, chacune des sept fonctions renvoie `ERROR_WRITE_FORBIDDEN` et rien n'est écrit ; en session root, cas nominaux et `error_log` → `logged: true` / `logged: false` ; chaque fonction publique `fn::error_*` appelée. |
| A08 | Test d'intégration `lyxal_event` (moteur embarqué) : séquences 1 à 3, la 2 en retry, la 3 livrée et ancienne ; purge ; la 3 est conservée ; la 2 livrée puis flush jusqu'à 3 sans `EVENT_CURSOR_MISSING_SEQUENCE_HOLE`. Une livraison couverte par le curseur est bien purgée ; le test existant `test_purge_keeps_events_of_unresolved_deliveries` passe toujours. |
| A03 | Compilation du workspace et suites `lyxal_runtime` / `lyxal-server` vertes ; test de parité catalogue ↔ `runtime.surql` vert après retrait des quatre codes. |

Contrôle complet : `scripts/ci/ci_local.sh` (formatage, clippy, `surreal validate`, bancs, tests
contre SurrealDB 3.3.4).

## 5. Checklist (§13)

* Core : aucune fonction Core nouvelle ; entrées déjà validées par
  `fn::validation_object_execute` dans les fonctions modifiées.
* SurrealQL : signatures `$params: object` inchangées ; écriture principale vérifiée ; codes
  préfixés `ERROR_` ; master data rejouable.
* Rust : aucun DTO modifié ; aucune logique dupliquée ; code mort supprimé (A03).
* Événements : invariant de contiguïté de §5.6.4 préservé par la purge (A08).
* Zéro dette : aucune migration ajoutée, aucun alias ; plan supprimé après exécution.

## 6. Hors lot (documentation, même PR que ce plan)

Accord du CTO du 7 novembre : crate de fondation **`lyxal_parsing`** (lecture CSV, XML et JSON
avec rejets explicites, sans logique métier ; bibliothèques `csv` et `quick-xml`), prérequis du
lot 5 (A05). Inscription dans `.agents/AGENTS.md` §6 et dans
`docs/14-roadmap/ROADMAP_NOYAU.md` (sans dépendance dans le noyau, à créer avant le lot 5).

## 7. Lots suivants (rappel, plans séparés)

2 : A04 (événements finaux par l'outbox) · 3 : A01 (sceau du contenu publié) · 4 : A02
(personnalisations par locataire, table séparée) · 5 : A05 (adaptateurs sur `lyxal_parsing`) ·
6 : A07 puis A06 (exclusion concurrente, source persistée — dépend de `lyxal_storage`).
