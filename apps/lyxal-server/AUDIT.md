# Audit de reprise — `lyxal-server`

Audit en lecture seule (skill `lyxal-audit`), réalisé sur `main` après la clôture de
`lyxal_runtime` (#46 à #53).

## 1. Périmètre et position dans le graphe

* **Crate** : `apps/lyxal-server`, version `0.1.0` (workspace), binaire `lyxal-server` et
  bibliothèque `lyxal_server`. Environ 1 400 lignes de Rust dans 21 fichiers `src/`, 4 fichiers de
  tests, 3 fichiers de configuration, 3 documents dans `docs/`, un `Dockerfile`.
* **Niveau** : hôte de processus (`AGENTS.md` §6, « UI / Process Host »). Il n'est pas un module
  et n'a donc ni `manifest.toml`, ni SurrealQL propre ; c'est attendu.
* **Dépendances** : `lyxal_surreal` et, en option (`module-ingestion`, par défaut),
  `lyxal_pipeline_ingestion`. **Aucune dépendance vers `lyxal_runtime`, `lyxal_event`,
  `lyxal_error` ni `lyxal_core`.** Pas de dépendance circulaire.

Fichiers lus intégralement : `Cargo.toml`, tous les fichiers de `src/`, `tests/it/*`,
`config/*.toml`, `.env.example`, `Dockerfile`, `README.md`, `CHANGELOG.md`, `docs/*`. Lus par
extraits : `crates/lyxal_pipeline_ingestion/{manifest.toml, src/module.rs,
src/storage/store.rs}`, API hôte de `crates/lyxal_runtime/src/runtime.rs`.

## 2. Synthèse et verdict

**NON CONFORME (P0 et P1 bloquants).**

Le serveur est propre sur sa couche HTTP (limites, délais, CORS, arrêt sur signal, identifiant
de requête, connexion par `lyxal_surreal`, mot de passe en `SecretString`). Mais :

1. il réimplémente un **runtime parallèle** (contrat de module, cycle de vie, ordre des
   dépendances, santé, migrations) au lieu d'instancier `LyxalRuntime`, contrairement au §5.8.5 ;
2. ses migrations ne prennent **aucun bail** et **ne vérifient jamais l'empreinte** : deux
   instances peuvent appliquer la même migration, et une migration modifiée passe inaperçue ;
3. en installant l'ingestion, il exécute `IngestionStore::init_schema`, qui **écrase
   `fn::error_result`** de `lyxal_error` par une version simplifiée (et définit
   `fn::result_ok` s'il manque) ;
4. il n'installe ni `lyxal_core`, ni `lyxal_error`, ni `lyxal_event`, ni le schéma du runtime,
   et ne démarre ni les workers ni le moteur d'événements : le module d'ingestion tourne sans
   son worker ni sa sonde de santé ;
5. la configuration par défaut, héritée en production, contient l'identifiant `root` / `root`.

## 3. Écarts constatés

| ID | Sév. | Règle | Fichier & lignes | Preuve | Correction recommandée |
| :- | :- | :--- | :--- | :--- | :--- |
| S-01 | P0 | §5.6.4 / §5.8.1 (exécution unique des migrations), §11.4 | `src/runtime.rs:198-241` | `run_migrations` lit `lyxal_module_migration`, puis exécute la migration sans bail : deux instances qui démarrent ensemble l'appliquent toutes deux. L'empreinte (`checksum`) est écrite mais jamais comparée : une migration modifiée après application est ignorée sans erreur. | Migrations exécutées par `lyxal_runtime` (`MigrationRunner` : bail renouvelé, garde `RUNTIME_LEASE_FENCED`, dérive `RUNTIME_MIGRATION_CHECKSUM_MISMATCH`). |
| S-02 | P0 | §5.3 (`fn::error_result` unique), §5.1 | `src/modules/ingestion.rs:58-62` → `crates/lyxal_pipeline_ingestion/src/storage/store.rs:385-400` | L'adaptateur appelle `IngestionStore::init_schema`, qui exécute `DEFINE FUNCTION OVERWRITE fn::error_result(...)` (version réduite : `message`, `label` = code, catégorie `BUSINESS`) et `fn::result_ok` : toute erreur de la suite perd ses définitions master data une fois l'ingestion installée par le serveur. | Le serveur n'appelle plus `init_schema` ; l'ingestion est installée depuis son manifeste par le runtime. La suppression de `init_schema` relève de la reprise de `lyxal_pipeline_ingestion` (Q3). |
| S-03 | P1 | §5.8.5 (l'hôte instancie `LyxalRuntime`), §5.1 | `src/modules/contract.rs` (tout) ; `src/runtime.rs` (tout) ; `src/health.rs` | Contrat de module local (`LyxalModule`, `ModuleContext`, `ModuleDescriptor`, `ModuleState`, `ModuleId`), cycle de vie, sélection et ordre topologique, registre de santé : tous dupliquent `lyxal_runtime` (`LyxalModule`, `LifecycleManager`, `DependencyResolver`, `HealthEngine`). Le `README` et `docs/INTEGRATION.md` le présentent comme « temporaire » en attendant un contrat qui existe désormais. | Hôte réduit à : configuration, connexion, `LyxalRuntime` (store SurrealDB, baux, workers, santé, événements), HTTP. Suppression du contrat et du runtime locaux. |
| S-04 | P1 | §5.8 (installation par manifeste), §5.6 | `src/bootstrap.rs` ; `src/modules/mod.rs` | Aucune installation de `lyxal_core`, `lyxal_error`, `lyxal_event` ni du schéma `runtime_*`. Le module d'ingestion dépend de `lyxal_core`, `lyxal_base`, `lyxal_crypto`, `lyxal_error`, `lyxal_event` (manifeste) : ces dépendances ne sont ni installées ni vérifiées. Ni `WorkerSupervisor`, ni `EventWorker` : `IngestionWorker` et `IngestionHealthCheck`, implémentés dans le crate d'ingestion, ne sont jamais exécutés. `LyxalModule::health` (contrat local) n'est appelé nulle part. | Installation en lot (`install_packages`) des modules du noyau puis des modules hébergés ; démarrage des workers et du moteur d'événements par le runtime ; sondes enregistrées dans le `HealthRegistry`. |
| S-05 | P1 | §11.3 / checklist de production | `config/default.toml:21-22`, `config/production.toml` ; `.env.example:9-10` | `username = "root"`, `password = "root"` dans le fichier par défaut, hérités par l'environnement `production` qui ne les remplace pas : sans variable d'environnement, la production se connecte en Root avec un mot de passe connu. | Aucun secret dans les TOML ; identifiants obligatoires par variables d'environnement hors `development` (refus au démarrage sinon). |
| S-06 | P1 | §5.5, §7 (codes préfixés, master data), contrat `LyxalResult` | `src/error.rs` | Codes `LYXAL_*` sans préfixe de module ni définition en master data ; variantes génériques à texte libre (`Runtime(String)`, `Module`, `Internal`, `Database`) ; enveloppe HTTP propre (`{ error: { code, message, trace_id } }`) au lieu de `{ ok, data, error }` ; le message renvoyé au client contient le texte brut des erreurs internes (base, module) ; `trace_id` aléatoire, sans lien avec `x-request-id`. | Variantes typées `SERVER_*`, définitions dans `error/`, réponse `LyxalResult` ; message client sans détail interne ; `trace_id` = identifiant de requête. |
| S-07 | P1 | §5.3 (zéro `panic!`) | `src/modules/system.rs:11`, `src/modules/ingestion.rs:25,37` | `panic!` dans les constructeurs (identifiants constants), malgré `#![deny(clippy::unwrap_used, clippy::expect_used)]`. | Disparaît avec S-03 (descripteurs du runtime) ; sinon constantes vérifiées par test. |
| S-08 | P1 | Construction | `Dockerfile:1` | Image `rust:1.85` alors que le workspace exige `rust-version = "1.97"` : l'image ne compile pas. Elle construit avec `--features full`, qui active des modules sans crate (S-09). | Image alignée sur la version du workspace ; fonctionnalités réelles uniquement. |
| S-09 | P2 | §0.2 (code mort) | `Cargo.toml:21-34` ; `src/config.rs` ; `src/modules/contract.rs:63` ; `src/bootstrap.rs:39-47` | Fonctionnalités `module-timezone`, `module-scheduler`, `module-calendar`, `module-booking` sans crate ; champs de configuration jamais lus (`runtime.parallel_start`, `server.trust_proxy_headers`) ; `api_version` jamais lu ; `database.required = false` mène toujours à une erreur (« adaptateur NullDatabase non activé »). | Suppression. |
| S-10 | P2 | §0.2, §0.3.4 (documents historiques, état actuel) | `CHANGELOG.md` ; `README.md:47-61` ; `docs/INTEGRATION.md` ; `docs/ARCHITECTURE.md` | Changelog d'une version jamais livrée ; section « Défauts connus » ; guide d'intégration décrivant un contrat temporaire, `surrealdb 3.2`, `edition 2024`, `rust-version 1.85` ; schéma d'architecture citant des modules inexistants (Timezone, Scheduler, Calendar, Booking). | Suppression de `CHANGELOG.md` ; `README.md` et `docs/` réécrits à l'état actuel. |
| S-11 | P2 | Cohérence des identifiants | `src/modules/contract.rs:12-17` | `ModuleId` local n'accepte que `a-z0-9-` (`lyxal-pipeline-ingestion`) alors que les manifestes utilisent `lyxal_pipeline_ingestion` : les deux registres ne peuvent pas partager leurs identifiants. | Disparaît avec S-03 (`ModuleId` du runtime, identifiant du manifeste). |
| S-12 | P2 | Tests | `tests/it/runtime_graph.rs` | Le seul test du « runtime » ne vérifie rien (aucune assertion). Aucun test des migrations, de l'ordre d'arrêt ni des échecs de démarrage. | Tests de démarrage de bout en bout sur `mem://` : installation en lot, migration unique, arrêt ordonné, échec d'un module requis. |
| S-13 | P2 | Exposition | `src/http/router.rs:30-34` ; `src/http/handlers.rs:33-45` | `/health` renvoie les messages d'erreur internes de chaque composant et `/metrics` est public, sans authentification. | Détail réservé au journal ; décision d'exposition à prendre avec l'authentification (hors périmètre). |

## 4. Correspondance DTO ↔ SurrealQL

Sans objet : le serveur ne définit ni n'appelle de fonction `fn::*`. Ses deux accès à la base
sont la sonde de connexion (`RETURN { ok: true }`, `src/database.rs:40`) et les requêtes de
migration écrites en dur (S-01), qui disparaissent avec la reprise.

## 5. Preuves d'exécution et points non vérifiés

* **Exécuté et réussi** : `cargo test -p lyxal-server` : 4 tests réussis (configuration ×2,
  intégration HTTP sur `mem://`, test de graphe sans assertion). La CI (formatage, clippy) passe
  sur `main` (#53).
* **Contrôles statiques** : recherches de `.query(`, `.select(`, `tokio::spawn`, `panic!`,
  `unwrap`, `expect`, `let _ =`, `.ok()`, champs de configuration lus ; comparaison des contrats
  locaux avec l'API hôte de `lyxal_runtime` ; lecture de l'`init_schema` appelé par l'adaptateur
  d'ingestion.
* **Non vérifié** :
  * le démarrage réel contre un serveur SurrealDB 3.3.4 (`ws://`) et l'image Docker ;
  * la double application d'une migration par deux instances (S-01) est déduite du code, sans
    test.

## 6. Éléments conformes

* **Connexion** : `lyxal_surreal::create_surreal_client` (schémas d'URL, Root uniquement à
  distance, délai) et sonde de connexion ; aucun `Surreal` construit à la main.
* **Secret** : mot de passe lu en `SecretString`, masqué dans `Debug`.
* **HTTP** : limite de corps, délai, limite de concurrence, rattrapage des paniques, CORS
  paramétré, identifiant de requête propagé, `/live` et `/ready` distincts.
* **Arrêt** : `SIGINT` / `SIGTERM`, arrêt des modules en ordre inverse avec délai.
* **Crypto** : aucun import de crate cryptographique, aucun `thread_rng`.
* **Pas de `tokio::spawn`**, `#![forbid(unsafe_code)]`.

## 7. Plan correctif

Voir `implementation_plan.md` : quatre décisions à prendre, puis les lots ordonnés.
