# Plan d'implémentation — reprise de `lyxal_runtime`

> **Statut : soumis au CTO.** Constats : `AUDIT.md` (R-01 à R-18). Les deux documents seront
> supprimés à la clôture (§0.3.4).

## 1. Décisions demandées

| # | Question | Recommandation |
| :- | :--- | :--- |
| Q1 | **Manifeste et installation des ressources (R-04)** : le runtime doit-il lire `[resources]` et installer les fichiers déclarés ? | **Oui.** `ModuleManifest` reçoit `resources` (`schemas`, `functions`, `events`, `error_definitions`, `migrations`, `seeds`) avec `deny_unknown_fields`. L'installation exécute ces fichiers dans l'ordre du manifeste, phase par phase, et la découverte par noms fixes dans `schema/` est supprimée. Le runtime reçoit son propre `manifest.toml`. `lyxal_event` abandonne alors `EventStore::install` au profit de l'installation par le runtime : c'est l'alternative laissée ouverte à sa reprise (Q3). Les installateurs de test de `lyxal_error`, `lyxal_surreal` et `lyxal_event` restent tels quels : un crate placé sous le runtime ne peut pas en dépendre, même en test, sans dupliquer ses types. |
| Q2 | **Persistance du runtime (R-01, R-05, R-06, R-07, R-13)** | **Fonctions SurrealQL `fn::runtime_*($params: object)`**, appelées par `call_fn`, entrées validées par les primitives de `lyxal_core` (chemin interne, comme les fonctions internes de `lyxal_event`). Un seul schéma dans `schema/`, tables renommées `runtime_*` en `TYPE NORMAL SCHEMAFULL PERMISSIONS NONE`. Les baux de migration et d'installation passent dans ces fonctions et prennent l'heure de la base (`time::now()`), ce qui corrige R-07. *Alternative moins coûteuse* : garder les requêtes en Rust, mais installer le schéma depuis `schema/` (une seule source), ajouter les permissions et passer l'heure de la base dans les requêtes. Elle laisse la logique de persistance hors de SurrealQL (§10). |
| Q3 | **Bus d'événements interne et journal (`RuntimeEventBus`, `system_runtime_event`)** : est-ce un doublon de `lyxal_event` ? | **Non, à garder.** Ce sont des événements techniques du runtime (cycle de vie, migrations, workers), diffusés localement et journalisés pour audit. Ils ne traversent pas les modules et n'ont pas besoin de la livraison garantie de l'outbox. La table devient `runtime_event_journal`, sa tâche de journalisation est rattachée au runtime, et les abandons sont journalisés (R-12, R-17). *Alternative* : publier ces événements dans `lyxal_event` sous `runtime.*`, au prix d'un coût de livraison garantie inutile pour de la télémétrie. |

**Hors périmètre, à signaler** : `apps/lyxal-server` n'instancie pas le runtime (§5.8.5). Ce
branchement appartient à la reprise de `lyxal-server`.

## 2. Contrat cible

### SurrealQL (si Q2 est validée)

* `manifest.toml` du runtime : dépendances `lyxal_core` et `lyxal_error` ; ressources `schema/*`,
  `functions/*`, `error/runtime.surql`.
* Fonctions internes `fn::runtime_*($params: object)`, qui renvoient `fn::result_ok` ou
  `fn::error_result`, avec `PERMISSIONS FULL` et un `COMMENT` :
  * releases et modules ;
  * migrations : enregistrement gardé par la génération du bail ;
  * baux : prise, renouvellement, libération et inspection, à l'heure de la base ;
  * santé, workers et journal.
* `THROW` réservé, comme dans `lyxal_event`, aux échecs qui suivent l'écriture de garde du bail.

### Rust (rupture coordonnée, §0.3.1)

* `ModuleManifest` avec `resources`, clés inconnues refusées.
* `NodeId::generate` en UUID v7 (R-08).
* Migration : bail renouvelé pendant l'exécution, enregistrement refusé si le bail est perdu (R-09).
* Erreurs :
  * aucune erreur de persistance ou d'enregistrement jetée : propagée, ou journalisée et comptée (R-02) ;
  * `WorkerBatchReport.failed` remonté (R-03) ;
  * codes ad hoc remplacés par des variantes typées `RUNTIME_*` (R-10).
* Structures nommées à la place des tuples publics (R-11).
* Tâches du bus et du moteur de santé rattachées à leur propriétaire (R-12).

### Appelants à mettre à jour dans le même changement

* `lyxal_event` : suppression d'`EventStore::install` et de `INSTALL_RESOURCES` si Q1 est validée ;
  `EventEngineConfig::auto_init_schema` installe alors `lyxal_event` depuis son manifeste.
* `lyxal_pipeline_ingestion` : types touchés (`ModuleManifest`, rapports à tuples). Ses appels
  sont mis à jour sans reprendre le module.

### `lyxal_core`

Fonctions réutilisées : `fn::validation_record_id`, `fn::validation_required_string`,
`fn::validation_integer`, `fn::validation_object`, `fn::validation_language_code`. Aucune
fonction du Core à créer.

## 3. Tests

* **Manifeste** : `[resources]` lu ; clé inconnue refusée ; installation de `lyxal_core`,
  `lyxal_error` et `lyxal_event` depuis leurs manifestes, rejouable sans doublon.
* **Baux** : deux nœuds aux horloges décalées ne détiennent jamais le même bail ; identifiants de
  nœud distincts ; migration plus longue que le bail sans double exécution.
* **Erreurs** :
  * un échec de démarrage de worker est remonté ;
  * une écriture de santé, de statut ou de worker qui échoue est journalisée et comptée ;
  * chaque code émis est défini dans `error/`.
* **Permissions** : déclaration des tables vérifiée par `INFO FOR TABLE`.

## 4. Lots

| Lot | Contenu |
| :- | :--- |
| 1 | **Nettoyage et erreurs silencieuses** : suppression des rapports historiques, du `Cargo.lock` du crate et de `fastrand` ; `README.md` (réécrit au dernier lot) ; R-02, R-03, R-11, R-12, R-17, R-18 ; `NodeId` en UUID v7 (R-08). |
| 2 | **Manifeste** (Q1, R-04) : `resources`, installation par phases, `manifest.toml` du runtime ; `lyxal_event` installé par le runtime. |
| 3 | **Persistance en SurrealQL** (Q2, R-01, R-05, R-06, R-13) : schéma unique `runtime_*`, fonctions `fn::runtime_*`, `call_fn`. |
| 4 | **Baux et migrations sûrs** (R-07, R-09) ; **erreurs en master data** (R-10). |
| 5 | **Clôture** : README à l'état actuel, convention `0001_initial.surql` (R-16), audit de contrôle, suppression de `AUDIT.md` et de ce plan. |

Chaque lot fait l'objet d'une PR, fusionnée quand la CI est verte.

## 5. Checklist §13 (extraits)

* Architecture : aucune dépendance nouvelle hors `uuid` (déjà déclarée) ; DAG inchangé.
* Core : entrées des fonctions `fn::runtime_*` validées par les primitives de `lyxal_core`.
* SurrealQL : `$params: object`, `result_ok` / `error_result`, `COMMENT`, `PERMISSIONS`.
* Rust : aucune erreur masquée, aucun `panic!` ni `expect` hors tests, aucun tuple public.
* Erreurs : codes `RUNTIME_*` définis en master data dans `lyxal_runtime/error/`.
* Zéro dette : rapports historiques et commentaires de versions supprimés, version `0.1.0`.
