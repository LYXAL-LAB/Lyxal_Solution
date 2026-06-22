# lyxal_core_config

## Rôle
Crate d'infrastructure responsable de la **configuration globale du moteur Lyxal**. Il centralise toutes les constantes, seuils et paramètres d'exécution de la plateforme, injectés via les variables d'environnement `LYXAL_*`.

## Ce qu'il contient
- **`cnf/mod.rs`** : Toutes les constantes de configuration (`LYXAL_MEMORY_THRESHOLD`, `LYXAL_MAX_CONCURRENT_TASKS`, `LYXAL_REGEX_CACHE_SIZE`, etc.), parsées paresseusement via `LazyLock` et la macro `lazy_env_parse!`.
- **`cnf/dynamic.rs`** : Les configurations dynamiques modifiables à chaud (runtime).
- **`env/mod.rs`** : Les informations sur l'environnement d'exécution (version du package, OS, architecture CPU).

## Pourquoi un crate séparé ?
La configuration ne doit pas être enfermée dans `lyxal_db`. Elle est utilisée par le serveur, le proxy, la télémétrie et la base de données. En l'isolant, chaque composant peut importer ses constantes sans importer le moteur SQL complet.

## Variables d'environnement supportées
| Variable | Défaut | Description |
|---|---|---|
| `LYXAL_MEMORY_THRESHOLD` | `0` | Seuil mémoire avant arrêt forcé des tâches |
| `LYXAL_MAX_CONCURRENT_TASKS` | `64` | Nombre max de tâches concurrentes |
| `LYXAL_MAX_COMPUTATION_DEPTH` | `120` | Profondeur max de récursion SQL |
| `LYXAL_TRANSACTION_CACHE_SIZE` | `10000` | Taille du cache transactionnel |
| `LYXAL_NORMAL_FETCH_SIZE` | `500` | Nombre de clés scannées par requête |
| ... | ... | (voir `cnf/mod.rs` pour la liste complète) |

## Utilisé par
`lyxal_db`, `lyxal_server`, `lyxal_core_telemetry`, `lyxal_functions`.
