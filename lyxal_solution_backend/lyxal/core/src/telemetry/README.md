# lyxal_core_telemetry

## Rôle
Crate d'infrastructure regroupant la **télémétrie système** et le **stockage objet** de Lyxal Solution. Il fournit à l'ensemble de la plateforme les outils de supervision et de gestion des fichiers.

## Ce qu'il contient

### `obs/` — Object Store (Stockage Objet)
Gère le stockage et la récupération de fichiers via le crate `object_store`. Supporte :
- **Stockage local** (système de fichiers)
- **Stockage mémoire** (pour WASM ou les tests)
- **Stockage cloud** (S3, GCS) via URL configurée par variable d'environnement

| Variable | Défaut | Description |
|---|---|---|
| `LYXAL_OBJECT_STORE` | `./store` (local) | URL du backend de stockage principal |
| `LYXAL_CACHE_STORE` | `./cache` (local) | URL du backend de cache |

Fonctions principales : `get()`, `put()`, `del()`, `stream()`, `hash()`.

### `sys/` — System Metrics (Métriques Système)
Collecte périodiquement les informations matérielles du processus Lyxal :
- Utilisation CPU (%) via `sysinfo`
- Consommation RAM (octets) via `sysinfo` + `lyxal_core_allocator`
- Charge système (load average 1/5/15 min)
- Nombre de cœurs physiques et parallélisme disponible

Les métriques sont exposées via deux `LazyLock<Mutex>` globaux : `ENVIRONMENT` et `INFORMATION`.

## Pourquoi un crate séparé ?
La télémétrie est consommée par `lyxal_server` (pour le endpoint `/health`), par `lyxal_proxy` (pour le load balancing), et par `lyxal_db` (pour les limites mémoire). En l'isolant, on évite de compiler `sysinfo` et `object_store` dans des crates qui n'en ont pas besoin.

## Dépendances clés
- `object_store` : Abstraction multi-backend pour le stockage de fichiers.
- `sysinfo` : Lecture des métriques CPU/RAM du processus.
- `sha1` + `hex` : Hachage des fichiers stockés.

## Utilisé par
`lyxal_server`, `lyxal_db`, `lyxal_proxy`.
