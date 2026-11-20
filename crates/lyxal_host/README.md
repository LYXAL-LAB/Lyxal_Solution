# `lyxal_host` — Bibliothèque des hôtes de Lyxal OS

`lyxal_host` contient le code commun aux binaires hôtes de Lyxal OS (`apps/lyxal-server`,
demain `apps/lyxal-groupware`) : tout ce qu'un hôte fait pour démarrer, servir sa santé et
s'arrêter, sans rien de propre à ses routes ni à ses modules. Il n'est ni un module du runtime ni
un service du Noyau : il est utilisé par les seuls hôtes (`AGENTS.md` §5.8.5, §6).

Version `0.1.0` (régime pré-production, `.agents/AGENTS.md` §0). Licence `MIT OR Apache-2.0`.

Évolutions prévues : [`ROADMAP.md`](ROADMAP.md).

> **Règle de provenance** : ce crate ne reçoit **que** du code écrit pour Lyxal. Aucun fichier
> porté d'un projet sous AGPL ou GPL (Stalwart, RustiCal…) n'y entre, même transformé : il est
> lié par `lyxal-server`, qui ne lie aucun code AGPL (décision P3 du programme courrier). Le code
> porté va dans les paquets qui déclarent `AGPL-3.0-only`.

---

## 1. Contenu

| Module | Rôle |
| :--- | :--- |
| `config` | `DatabaseConfig`, `SecretPassword` (secret masqué dans `Debug`, effacé de la mémoire), `RuntimeTimeouts`, `ObservabilityConfig` ; `load_layered` : `<dossier>/default.toml`, puis `<dossier>/<LYXAL_ENV>.toml` (`development` par défaut), puis variables `<préfixe>__<SECTION>__<CLÉ>` ; clés secrètes refusées dans les fichiers (`a.b`, ou `a.*.b` pour toute entrée d'une table) avec le nom de la variable à utiliser ; clés lues comme listes (séparateur `,`) |
| `database` | `connect_database` (fabrique de `lyxal_surreal`, sonde), `refuse_anonymous_access` (base distante ouverte aux invités refusée : un invité y aurait les droits de la session système), `probe` |
| `health` | `HealthRegistry`, `HealthState`, `HealthSnapshot` : composants de l'hôte (processus, base…) agrégés en un état |
| `http` | `bind` (port HTTP), `serve` (boucle d'acceptation, arrêt gracieux avec délai de drainage), `serve_connection` (une connexion, délai d'écriture : un client qui ne lit plus est déconnecté), `health_routes` et `HostHealth` (`/live`, `/ready`, `/health` : composants de l'hôte et sondes du runtime, sans message interne) |
| `metrics` | `Metrics`, `MetricsSnapshot` : requêtes HTTP (total, en cours, en échec), durée de vie |
| `modules` | `EmbeddedModule`, `ManifestModule` (module sans code Rust), `FOUNDATION`, `manifest`, `install_foundation` (socle sous bail au nom du nœud, puis définitions d'erreurs de l'hôte hors empreinte du socle), `install_host_seeds` |
| `net` | `IpNetwork`, `client_ip` (adresse réelle derrière des proxys de confiance, `X-Forwarded-For` lu de droite à gauche), `normalize_ip` |
| `shutdown` | `signal` : SIGINT, ou SIGTERM sous Unix |
| `telemetry` | `init` : journal `tracing`, texte ou JSON |
| `build` | `embed_modules` : corps du `build.rs` d'un hôte, qui embarque le manifeste et les fichiers `[resources]` de chaque module hébergé (constante `EMBEDDED_MODULES`) ; compilation en échec si un fichier déclaré manque |

## 2. Erreurs

`HostError` n'a pas de code d'erreur : chaque hôte la traduit dans les siens (`From<HostError>`
pour `ServerError` de `lyxal-server` : `Configuration` → `SERVER_CONFIGURATION_INVALID`,
`Database` → `SERVER_DATABASE_UNAVAILABLE`, `ModuleInstall`, `Bind`, `ShutdownSignal`,
`Telemetry` de même). Une erreur du runtime (`HostError::Runtime`) garde son code `RUNTIME_*`.
Les routes de santé rendent une erreur du runtime par le type d'erreur de l'hôte
(`health_routes::<S, E>`), au contrat `LyxalResult`.

## 3. Fonctionnalités Cargo

| Fonctionnalité | Contenu |
| :--- | :--- |
| `host` (par défaut) | Toute la bibliothèque des hôtes |
| `build` | `build::embed_modules` seulement ; n'amène que `toml` (dépendance de compilation d'un hôte) |

La dépendance du workspace est déclarée sans fonctionnalité par défaut : un hôte demande `host`
dans `[dependencies]` et `build` dans `[build-dependencies]`.

## 4. Vérification

```bash
cargo test -p lyxal_host
```

Tests unitaires : réseaux et adresse du client (`net`), chargement en couches (environnement
prioritaire, listes, clé secrète refusée dans un fichier, y compris dans une entrée de table,
fichier par défaut obligatoire), secret masqué. `tests/serve.rs` : adresse du client transmise
aux routes, client qui cesse de lire déconnecté après le délai d'écriture, arrêt qui laisse
finir les requêtes en cours. Le reste (base, santé, socle, modules embarqués) est exercé par la
suite de `lyxal-server` (`cargo test -p lyxal-server`), qui démarre l'hôte réel.
