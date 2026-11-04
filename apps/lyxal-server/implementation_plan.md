# Plan d'implémentation — reprise de `lyxal-server`

Suite de `AUDIT.md`. **Q1 à Q4 validées par le CTO** (Q3 : option B, voir ci-dessous).

## 1. Décisions demandées

| # | Question | Options | Recommandation |
| :- | :--- | :--- | :--- |
| Q1 | Que devient le runtime local (S-01, S-03, S-04) ? | **A.** Supprimé : l'hôte instancie `LyxalRuntime` (store SurrealDB, baux, migrations, workers, santé, événements). **B.** Conservé et corrigé. | **A** : §5.8.5, et c'est la seule voie qui donne les baux, la garde de migration et la dérive sans les recopier. |
| Q2 | D'où viennent les fichiers SurrealQL des modules installés ? | **A.** Embarqués dans le binaire : un `build.rs` du serveur lit le `manifest.toml` de chaque module hébergé et embarque exactement les fichiers déclarés (échec de compilation si un fichier manque). **B.** Lus sur disque au démarrage (`FilesystemResourceProvider`, répertoire configuré, copié dans l'image). | **A** : un binaire autonome, sans écart possible entre le code et les fichiers installés ; marche aussi pour `lyxal_core`, qui n'a pas de crate Rust. |
| Q3 | Le module d'ingestion (S-02) ? Son manifeste dépend de `lyxal_base >=1.0.0`, qui n'a **pas de manifeste**, et son adaptateur actuel écrase `fn::error_result`. | **A.** Retirer l'ingestion des fonctionnalités par défaut jusqu'à sa reprise. **B.** Garder l'ingestion et la rendre installable par le runtime. | **Décision CTO : B.** L'ingestion reste active par défaut (pas de régression fonctionnelle). `lyxal_base` reçoit un `manifest.toml` (version `0.1.0`, ressources existantes), les contraintes `lyxal_base >=1.0.0` de l'ingestion et du catalogue passent à `>=0.1.0` (§0.3.3) ; le serveur héberge `PipelineIngestionModule` installé depuis son manifeste et n'appelle plus jamais `init_schema`. La suppression d'`init_schema` dans l'ingestion relève de sa propre reprise. |
| Q4 | Erreurs HTTP (S-06) ? | **A.** Variantes typées préfixées `SERVER_`, définitions dans `error/server.surql`, réponses au format `LyxalResult` (`{ ok, data, error }`), `trace_id` = `x-request-id`, aucun détail interne au client. **B.** Garder l'enveloppe actuelle et ajouter seulement les définitions. | **A** : même contrat que le reste de la suite (`lyxal_error`, `lyxal_surreal`). |

## 2. Contrat cible (Q1-A, Q2-A, Q3-B, Q4-A)

### Démarrage

```text
configuration → connexion (lyxal_surreal)
  → LyxalRuntime (SurrealRuntimeStore, baux SurrealDB, NodeId, bus et journal)
  → installation en lot : lyxal_core, lyxal_error, schéma du runtime, lyxal_event,
    puis modules hébergés (manifestes embarqués, ordre des dépendances)
  → enregistrement des modules, consommateurs d'événements, workers, sondes
  → init_event_engine, démarrage des modules et des workers
  → HTTP
arrêt : signal → arrêt des workers puis des modules (ordre inverse) → fin
```

### Rust

* Supprimés : `src/modules/contract.rs`, `src/runtime.rs` (runtime local), `src/health.rs` (le
  registre de santé des composants serveur passe par `ModuleHealthCheck` du runtime pour les
  modules ; les composants « server » et « database » restent dans un état serveur minimal).
* `src/modules/mod.rs` : liste des modules hébergés = `ModulePackage` (manifeste et ressources
  embarqués par `build.rs`, implémentation `LyxalModule` du crate du module).
* `build.rs` : pour chaque module hébergé, génère `MANIFEST` et `EMBEDDED_RESOURCES`
  (`include_str!` de chaque fichier déclaré dans `[resources]`).
* `src/error.rs` : `ServerError` en variantes typées ; `code()`, `info()` sur un catalogue unique
  (modèle `lyxal_runtime` / `lyxal_surreal`) ; réponse HTTP `LyxalResult`.
* Configuration : suppression de `runtime.parallel_start`, `server.trust_proxy_headers`,
  `database.required` ; `runtime` réduit à ce que `LyxalRuntime` consomme (délais, migrations,
  `fail_fast`) ; aucun secret dans les TOML, identifiants Root exigés par variables
  d'environnement hors `development`.

### SurrealQL et erreurs

* Pas de fonction SurrealQL propre (hôte). `error/server.surql` : définitions `SERVER_*`
  (configuration, base, démarrage d'un module, HTTP, arrêt, interne), vérifiées par test contre
  le catalogue Rust. Installées comme les autres ressources, depuis un `manifest.toml` du
  serveur limité à `[resources] error_definitions` (le serveur n'est pas un module du runtime :
  ce manifeste ne sert qu'à l'installation de ses définitions — à confirmer avec Q4).

### `lyxal_core`

Aucune fonction utilisée ni créée.

## 3. Tests

* Démarrage de bout en bout sur `mem://` : installation en lot du noyau, migration d'un module
  de test appliquée une seule fois (deux hôtes sur la même base), arrêt ordonné, échec d'un
  module requis qui empêche le démarrage.
* HTTP : `/live`, `/ready`, `/health`, `/api/v1/system/modules` alimentés par le runtime ;
  erreur au format `LyxalResult` sans détail interne, `trace_id` = `x-request-id`.
* Configuration : refus d'un démarrage hors `development` sans identifiants.
* Définitions `SERVER_*` conformes au catalogue.

## 4. Lots

| Lot | Contenu |
| :- | :--- |
| 1 | **Nettoyage** (S-05, S-08, S-09, S-10 en partie) : secrets retirés des TOML, `Dockerfile` aligné, fonctionnalités et champs morts supprimés, `CHANGELOG.md` supprimé. |
| 2 | **Hôte sur `LyxalRuntime`** (Q1, Q2, Q3 ; S-01, S-02, S-03, S-04, S-07, S-11) : `build.rs`, installation en lot, workers, événements, santé, arrêt ; runtime et contrat locaux supprimés ; `manifest.toml` de `lyxal_base`, contraintes `lyxal_base >=0.1.0` ; ingestion installée depuis son manifeste, toujours active par défaut. |
| 3 | **Erreurs** (Q4 ; S-06, S-13) : `ServerError` typé, `error/server.surql`, réponses `LyxalResult`, détail interne retiré des réponses. |
| 4 | **Clôture** : tests de bout en bout (S-12), `README.md` et `docs/` à l'état actuel, `AGENTS.md` (§5.8.5) et skills alignés, audit de contrôle, suppression de `AUDIT.md` et de ce plan. |

Chaque lot fait l'objet d'une PR, fusionnée quand la CI est verte.

## 5. Checklist §13 (extraits)

* Architecture : nouvelles dépendances `lyxal_runtime`, `lyxal_event`, `lyxal_error` (couches
  inférieures, DAG respecté) ; aucune dépendance d'un module vers le serveur.
* Erreurs : aucune erreur silencieuse ; codes préfixés `SERVER_` en master data.
* Crypto : inchangé (aucun usage).
* Zéro dette : runtime local, contrat local, fonctionnalités et champs morts, documents
  historiques supprimés.
