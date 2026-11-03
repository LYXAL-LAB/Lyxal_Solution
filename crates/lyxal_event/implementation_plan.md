# Plan d'implémentation — reprise de `lyxal_event`

> **Statut : ✅ validé par le CTO** (recommandations Q1 à Q3 acceptées).
> Constats : `AUDIT.md` (V-01 à V-13). Supprimé avec `AUDIT.md` à la clôture (§0.3.4).

## 1. Décisions demandées

| # | Question | Recommandation |
| :- | :--- | :--- |
| Q1 | **Chemin de livraison hérité (V-04)** : faut-il supprimer `EventWorker::poll_cycle` et ce qui ne sert qu'à lui ? | **Supprimer.** Sont concernés : `poll_cycle`, `dispatch_delivery`, `EventStore::claim_batch` et `delivery_success`, `compute_lease_duration`, ainsi que `fn::event_claim_batch` et `fn::event_delivery_success`. Les tests d'intégration sont réécrits sur `EventWorker::run`, le chemin de production : publication, fan-out, livraison, retry, DLQ, rejeu, reprise après crash, isolation par instance, `DEFINE EVENT`, et un test de concurrence à plusieurs workers qui remplace `integration_concurrency_1000`. `fn::event_delivery_failure` reste : `feeder` l'utilise pour les retries. |
| Q2 | **`THROW` dans les fonctions protégées par le bail (V-08)** | **Garder `THROW` comme exception documentée**, uniquement quand l'échec suit une écriture de la même fonction et doit tout annuler : fencing, monotonie et contiguïté du curseur dans `event_flush_batch`, `event_delivery_assign_seq`, `event_dead_letter_transfer`. Côté Rust, ces codes sont reconnus en un seul endroit et convertis en variantes typées de `LyxalEventError` (`StaleLeaderFenced`, `CursorInvariant { code }`), au lieu de recherches de texte. Les autres erreurs (entrée invalide, livraison inconnue détectée avant toute écriture) passent par `fn::error_result`. *Alternative* : réécrire `event_flush_batch` pour tout contrôler avant d'écrire, ce qui demande de recalculer en mémoire l'état après marquage. |
| Q3 | **Installation par `EventStore::init_schema` (V-07)** | **Garder la méthode**, utilisée par `lyxal_runtime` (`auto_init_schema`), mais sans liste recopiée : renommée `install`, elle installe les ressources dans l'ordre du manifeste. Un test vérifie que la liste compilée (`include_str!`) est exactement celle de `manifest.toml` : un oubli fait échouer la CI. *Alternative* : retirer la méthode et faire installer `lyxal_runtime` depuis le manifeste. Le runtime ne lit pas aujourd'hui `[resources]` : ce chantier appartient à sa reprise. |

## 2. Contrat cible

### SurrealQL

Toutes les fonctions publiques :
* prennent `$params: object`, validé par `fn::validation_object_execute` (`unknown_keys: "reject"`) ;
* acceptent `language` (défaut `fr`) ;
* renvoient `EVENT_INVALID_PARAMETERS` avec `details.fields` en cas d'entrée invalide ;
* déclarent `PERMISSIONS FULL` explicitement.

Les identifiants sont des `record<table>` (règle `record_id` avec `allowed_tables`) ; il n'y a
plus de conversion `<record<…>>` d'une chaîne. Les champs obligatoires le sont réellement :
plus de `worker_id` par défaut, plus de `result_ok(false)` sur une entrée manquante.

Les 6 tables sont en `TYPE NORMAL SCHEMAFULL PERMISSIONS NONE` (V-01). Les codes d'erreur
jamais émis sont supprimés (V-10). Les codes émis sont listés dans le README.

### Rust (rupture coordonnée, §0.3.1)

* DTO du moteur : identifiants en `RecordId` (`DeliveryAssignSeqParams`, `FlushBatchParams`,
  `DeadLetterTransferParams`, `ProgressGetParams`, `DeliveryFetchPendingParams`).
* Un seul `DeliveryFailureParams` typé, utilisé par `EventStore` et par `feeder` (V-06).
* `LyxalEventError` reçoit des variantes typées pour les `THROW` gardés (Q2).
* Le worker propage l'erreur de reprise des fan-outs. Une livraison sans métadonnées
  d'événement est une donnée corrompue : DLQ avec motif explicite, jamais un événement
  fabriqué (V-05).
* Toutes les tâches lancées par le worker sont conservées et attendues à l'arrêt (V-09).
* Suppression du chemin hérité (Q1) et `install` à la place d'`init_schema` (Q3).

### Appelants à mettre à jour dans le même changement

* `crates/lyxal_runtime/src/runtime.rs` : `init_schema` devient `install`, et le runtime
  n'utilise plus aucun export supprimé.
* `crates/lyxal_runtime/tests/it/common/mod.rs` et `crates/lyxal_runtime/tests` : installation
  des ressources de `lyxal_event`.

Aucun autre crate du workspace n'appelle les fonctions `fn::event_*` modifiées. Les
producteurs passent par `fn::event_publish`, dont les champs ne changent pas ; seule la
validation est ajoutée.

### `lyxal_core`

Fonctions réutilisées : `fn::validation_object_execute`, avec les règles `required_string`,
`regex`, `integer` (bornes), `boolean`, `record_id` (`allowed_tables`), `is_object`,
`array_of_records`, `enum`, `language_code`, `uuid`. Aucune fonction du Core n'est à créer.

## 3. Tests

* **Entrées** : chaque fonction refuse un champ manquant, inconnu ou mal typé (`details.fields`).
* **Chemin de production** (Q1) : tests d'intégration sur `EventWorker::run`, dont la
  concurrence à plusieurs workers et la reprise après interruption.
* **Fencing et invariants** : variantes typées de `LyxalEventError` (Q2).
* **Données corrompues** : une livraison sans métadonnées part en DLQ avec son motif.
* **Installation** : la liste d'`install` est égale à celle du manifeste (Q3), et le rejeu
  est idempotent.
* **Permissions** : déclaration des 6 tables vérifiée par `INFO FOR TABLE`.

## 4. Lots

| Lot | Contenu |
| :- | :--- |
| 1 ✅ | **Nettoyage** : manifeste `0.1.0` ; suppression de `CHANGELOG.md` et `ROADMAP.md` ; `readme.md` renommé `README.md` (README et `docs/` réécrits à l'état final au lot 5, après les changements de contrat) ; codes d'erreur inutilisés ; `TYPE NORMAL … PERMISSIONS NONE` sur les tables, `PERMISSIONS FULL` sur les fonctions (V-01, V-10, V-11, V-12). |
| 2 ✅ | **Suppression du chemin hérité et tests sur `run`** (Q1, V-04, V-13). Les tests sur le chemin de production ont révélé quatre bugs, corrigés dans ce lot (décision CTO : une file par abonnement) : multi-abonnements (V-14), DLQ jamais atteinte (V-15), bail gardé par une tâche orpheline (V-16), curseur bloqué après un conflit d'écriture (V-17). |
| 3 ✅ | **Contrat SurrealQL et DTO, ensemble** : validation par le Core, `language`, champs obligatoires, identifiants `RecordId`, `DeliveryFailureParams` unique, erreurs typées pour les `THROW` gardés (V-02, V-03, V-06, Q2). Décision CTO (option B, coût du moteur de validation ≈ 23 ms par appel) : moteur `fn::validation_object_execute` pour les fonctions appelées de l'extérieur, primitives de `lyxal_core` pour les 11 fonctions internes du chemin chaud. Corrigés au passage : V-18, V-19, V-20. |
| 4 ✅ | **Robustesse du worker et installation** : erreurs propagées, livraisons corrompues en DLQ, tâches attendues, `install` vérifié contre le manifeste ; appelants de `lyxal_runtime` (V-05, V-07, V-09, Q3). |
| 5 | **Clôture** : README et `docs/` à l'état actuel, audit de contrôle, suppression de `AUDIT.md` et de ce plan. |

Chaque lot fait l'objet d'une PR, fusionnée quand la CI est verte.

## 5. Checklist §13 (extraits)

* Architecture : aucune dépendance nouvelle ; `lyxal_event` reste sous `lyxal_runtime`.
* Core : entrées validées par `lyxal_core` ; aucun validateur local.
* SurrealQL : `$params: object`, `result_ok` / `error_result`, sauf les `THROW` gardés (Q2) ;
  `COMMENT` et `PERMISSIONS` explicites.
* Rust : DTO typés, aucun `json!` comme paramètre, aucune erreur masquée, aucun `panic!`.
* Événements : fencing, contiguïté et DLQ avant curseur conservés.
* Zéro dette : chemin hérité supprimé, codes inutilisés supprimés, version `0.1.0`.
