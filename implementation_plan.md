# Plan d'implémentation — petits manques des feuilles de route

Quatre points déjà inscrits aux feuilles de route des modules, à faire avant tout nouveau module
(ordre du CTO du 18 novembre 2026) : conversions d'unités (`lyxal_base`), remplacement de
caractères (`lyxal_core`), bascule des trois tâches de fond périodiques sur `lyxal_scheduler`,
reprise guidée d'une migration interrompue (`lyxal_runtime`). Aucune ligne de code avant la
validation du CTO (`.agents/AGENTS.md` §3).

Trois lots, une demande de fusion par lot :

| Lot | Contenu | Touche |
| :- | :--- | :--- |
| **A** | Règle de remplacement de caractères ; conversions d'unités | `lyxal_core`, `lyxal_pipeline_ingestion`, `lyxal_base` |
| **B** | Purge de `lyxal_auth`, nettoyage de `lyxal_storage`, maintenance de `lyxal_secrets` exécutés par `lyxal_scheduler` | `lyxal_auth`, `lyxal_storage`, `lyxal_secrets`, `lyxal_scheduler`, `apps/lyxal-server` |
| **C** | Reprise guidée d'une migration interrompue | `lyxal_runtime`, `apps/lyxal-server` |

## 1. Décisions du CTO

Décisions P1 à P6 **validées par le CTO** le 18 novembre 2026, telles que proposées ci-dessous.

| N° | Question | Proposition |
| :- | :--- | :--- |
| **P1** | Règle du Core (extension, §5.7.7) | Nouvelle règle `sanitize` **`replace_chars`** : `fn::sanitize_replace_chars($value, $remove, $replace)` — `remove` : liste de caractères à retirer ; `replace` : liste de couples `{ from, to }` (un caractère vers une chaîne de 8 caractères au plus) ; au catalogue `fn::sanitize_step_catalog()` (options `remove`, `replace`, l'une au moins), donc utilisable dans les pipelines et schémas d'objet ; option mal formée : `CORE_INVALID_ARGUMENT`. L'ingestion l'utilise pour la clé de ses unités (« m.l. » → « ML ») et n'appelle plus `string::replace`. Les autres `string::replace` du dépôt fabriquent des identifiants (tirets d'un UUID) : ce n'est pas du nettoyage de données reçues, ils restent. |
| **P2** | Conversions d'unités | Chaque **type** d'unité désigne son **unité de base** (`base_unite_type.base_unit`, ex. `M` pour les longueurs) ; chaque **unité** porte son **facteur** vers cette base (`base_unite.factor`, décimal strictement positif, ex. `CM` : 0,01). Pas de facteur = unité **non convertible** (`FORFAIT`, `ENS`, conditionnements). Conversions par simple facteur seulement (aucune unité à décalage, comme °C / °F, n'est au référentiel). Calcul en `decimal` (pas d'erreur d'arrondi binaire) ; le résultat n'est pas arrondi (l'appelant arrondit selon son usage). Socle livré : facteurs des 30 unités du seed. |
| **P3** | Fonction de conversion | `fn::base_unite_convert({ quantity, from, to })` → `{ quantity, from, to }`. Refus : unité inconnue ou inactive (erreurs existantes), **types différents** (`BASE_UNITE_TYPE_MISMATCH`), unité **non convertible** (`BASE_UNITE_NOT_CONVERTIBLE`). Lecture ouverte comme le référentiel (aucun droit particulier). `fn::base_unite_create` / `_update` acceptent `factor` ; `fn::base_unite_type_update` accepte `base_unit` (unité du même type, de facteur 1). |
| **P4** | Tâches de fond sur le planificateur : qui déclare quoi | `lyxal_scheduler` dépend déjà de `lyxal_auth` : `lyxal_auth` **ne peut pas** dépendre du planificateur (dépendance circulaire interdite, §6). **Proposition** : les trois tâches (`auth.purge`, `storage.cleanup`, `secrets.maintenance`) sont **déclarées et inscrites par l'hôte** `lyxal-server`, qui connaît déjà tous les modules : il déclare la tâche (`scheduler_task`, exécuteur Rust), inscrit le handler qui appelle le `run_once` existant du module, et crée la planification à l'installation si elle est absente. Les trois modules gardent leur logique (`run_once`) et **perdent leur boucle** `LyxalWorker` ; aucun ne dépend de `lyxal_scheduler`. |
| **P5** | Réglages des trois planifications | Mêmes rythmes qu'aujourd'hui : purge `lyxal_auth` toutes les 15 min, nettoyage `lyxal_storage` et maintenance `lyxal_secrets` toutes les 10 min ; chevauchement `skip` (pas deux exécutions à la fois) ; file `default` ; 3 tentatives ; permission propre de chaque tâche réservée au compte de service de l'hôte. Gain : **une seule exécution pour toute l'installation** (planificateur élu) au lieu d'une boucle par serveur, avec journal, tentatives et suivi dans `lyxal_scheduler`. |
| **P6** | Reprise d'une migration interrompue | Une migration restée à l'état « en cours » après une coupure bloque aujourd'hui l'installation, sans outil. Ajout : `fn::runtime_migration_interrupted_list($params)` (module, version, script, nœud, date) et `fn::runtime_migration_resolve({ module, migration, action, reason })` avec `action` = `retry` (la migration sera rejouée au prochain démarrage) ou `abandon` (marquée abandonnée ; l'installation du module reste refusée tant qu'elle n'est pas rejouée), **sous bail d'installation** du module et avec **trace** au journal du runtime (qui, quand, pourquoi). Opération d'administration de l'installation : exposée par l'API système de l'hôte, réservée au droit d'administration de l'installation. Erreurs `RUNTIME_MIGRATION_NOT_INTERRUPTED`, `RUNTIME_LEASE_FENCED` (existante) si le bail n'est pas tenu. |

## 2. Lot A — `lyxal_core`, `lyxal_pipeline_ingestion`, `lyxal_base`

**Core** (P1) : `functions/sanitize/functions/replace_chars.surql`, entrée au catalogue et à
`step_apply`, `manifest.toml`, `Readme.md` (compte des règles), tests de la règle seule et dans un
pipeline (`functions/sanitize/tests/`). Fonctions Core réutilisées : `fn::sanitize_uppercase`,
moteur `fn::sanitize_pipeline_execute`.

**Ingestion** : `fn::ingestion_resolve_units` calcule sa clé par le pipeline `uppercase` puis
`replace_chars` (`remove` : `.`, `-`, `_`) ; test existant inchangé (mêmes résultats).

**Base** (P2, P3) :

| Élément | Changement |
| :--- | :--- |
| `schema/base_unite.surql` | champ `factor` (`option<decimal>`, > 0) |
| `schema/base_unite_type.surql` | champ `base_unit` (`option<record<base_unite>>`) |
| `functions/unite/unite_convert.surql` | `fn::base_unite_convert($params: object)` ; entrées par `fn::validation_object_execute` (`quantity` : nombre fini ≥ 0 ; `from`, `to` : codes d'unité) |
| `fn::base_unite_create`, `_update`, `fn::base_unite_type_update`, vues `_get` / `_list` | `factor`, `base_unit` acceptés et renvoyés ; garde : l'unité de base d'un type appartient à ce type et a le facteur 1 ; une unité de base ne perd pas son facteur |
| `error/unite/` | `BASE_UNITE_TYPE_MISMATCH`, `BASE_UNITE_NOT_CONVERTIBLE`, `BASE_UNITE_BASE_INVALID` |
| `seeds/` | facteurs des 30 unités, unité de base des 11 types (réécrits en place, régime §0) |
| `tests/conversions.test.surql` | conversions nominales (`CM` → `M`, `KG` → `T`, `HA` → `M2`, `LTR` → `M3`), refus entre types, unité non convertible, unité inactive, gardes de l'unité de base |

`lyxal_base` est en SurrealQL seul : pas de `XxxParams` Rust. README et feuilles de route de
`lyxal_core` et `lyxal_base` mis à jour (étapes réalisées retirées).

## 3. Lot B — tâches de fond sur `lyxal_scheduler`

| Élément | Changement |
| :--- | :--- |
| `lyxal_auth`, `lyxal_storage`, `lyxal_secrets` (`src/worker.rs`) | la boucle `LyxalWorker` est retirée ; la logique reste une opération publique (`run_once`, renommée selon le module : purge, nettoyage, maintenance) qui rend son rapport ; `lib.rs`, README mis à jour |
| `apps/lyxal-server/src/modules/` | pour chaque module : handler `TaskHandler` qui appelle l'opération (échec temporaire : nouvelle tentative ; arrêt demandé : interruption entre deux paquets) ; déclaration de la tâche et création de la planification à l'installation (P4, P5) ; plus d'enregistrement des trois workers |
| `lyxal_scheduler` | aucune modification du moteur ; README : les trois tâches de l'hôte ; feuille de route : ligne « bascule » retirée |
| Permissions | une permission par tâche (`auth.purge.run`, `storage.cleanup.run`, `secrets.maintenance.run`), déclarée par l'hôte avec la tâche et accordée à son compte de service |
| Tests | tests existants des trois opérations conservés (ils appellent déjà `run_once`) ; hôte : les trois tâches sont déclarées et planifiées après installation, rejeu de l'installation sans doublon, une exécution déclenchée fait bien le travail (une session expirée est purgée, un fichier abandonné est nettoyé, un secret échu est traité) |

Contrat rompu et répercuté (§0.3) : `AuthPurgeWorker`, `StorageCleanupWorker` et
`SecretsMaintenanceWorker` disparaissent ; seuls l'hôte et les tests les utilisent.

Si la déclaration d'une tâche par l'hôte (et non par un seed de module) demande un changement du
contrat de `lyxal_scheduler`, il est signalé au CTO avant d'être fait.

## 4. Lot C — `lyxal_runtime`

| Élément | Changement |
| :--- | :--- |
| `functions/runtime_migration.surql` | `fn::runtime_migration_interrupted_list`, `fn::runtime_migration_resolve` (P6), entrées par le moteur du Core, retour `fn::result_ok` / `fn::error_result` |
| Rust | `MigrationInterruptedParams` / `InterruptedMigration`, `MigrationResolveParams` / `MigrationResolved` ; opération du runtime qui prend le bail d'installation du module, appelle la fonction et écrit la trace ; le `runner` rejoue une migration marquée `retry` |
| Erreurs | `RUNTIME_MIGRATION_NOT_INTERRUPTED` (master data du runtime) |
| Hôte | routes système : liste des migrations interrompues, résolution ; droit d'administration de l'installation |
| Tests | interruption simulée (migration laissée « en cours »), liste, reprise puis rejeu réussi, abandon, refus sans bail, refus sans droit |
| Documents | README §7 (limite retirée, procédure décrite), feuille de route (étape 1 retirée) |

## 5. Vérification

`scripts/ci/ci_local.sh` complet avant chaque demande de fusion (formatage, `clippy`, validation
SurrealQL, bancs `lyxal_core` et modules, tous les tests contre SurrealDB 3.3.4).

## 6. Checklist (§13)

* Core : P1 soumis au CTO ; aucune primitive dupliquée ; entrées par le moteur du Core.
* SurrealQL : `$params: object`, `result_ok` / `error_result`, `COMMENT`, écritures vérifiées.
* Dépendances : aucune dépendance circulaire (P4) ; aucun `tokio::spawn` hors supervision.
* Zéro dette : workers retirés sans alias ; seeds et schémas réécrits en place ; feuilles de route
  à jour ; ce plan supprimé une fois exécuté.
* Aucun besoin cryptographique.
