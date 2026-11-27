# `lyxal_host` — Bibliothèque des hôtes de Lyxal OS

`lyxal_host` contient le code commun aux binaires hôtes de Lyxal OS (`apps/lyxal-server` et
`apps/lyxal-groupware`) : tout ce qu'un hôte fait pour démarrer, servir sa santé et
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
| `config` | `DatabaseConfig` (dont `connections` : connexions de la session système, par défaut `default_connections()` — le nombre de cœurs, 16 au plus — et `0` refusé à la lecture), `SecretPassword` (secret masqué dans `Debug`, effacé de la mémoire), `RuntimeTimeouts`, `ObservabilityConfig` ; `load_layered` : `<dossier>/default.toml`, puis `<dossier>/<LYXAL_ENV>.toml` (`development` par défaut), puis variables `<préfixe>__<SECTION>__<CLÉ>` ; clés secrètes refusées dans les fichiers (`a.b`, ou `a.*.b` pour toute entrée d'une table) avec le nom de la variable à utiliser ; clés lues comme listes (séparateur `,`) |
| `database` | `Database` (session système de l'hôte : le pool de connexions `lyxal_surreal::SurrealPool`), `connect_database` (ouvre `database.connections` connexions par `lyxal_surreal`, une seule sur `mem://` ; chacune doit répondre à la sonde, sinon l'hôte ne démarre pas), `refuse_anonymous_access` (base distante ouverte aux invités refusée : un invité y aurait les droits de la session système) |
| `health` | `HealthRegistry`, `HealthState`, `HealthSnapshot` : composants de l'hôte (processus, base…) agrégés en un état |
| `http` | `bind` (port HTTP), `serve` (boucle d'acceptation, arrêt gracieux avec délai de drainage), `serve_prepared` (même boucle, chaque connexion passant d'abord par une préparation de l'hôte : en-tête PROXY, poignée de main TLS ; `PrepareConnection`, `HttpStream`), `serve_connection` (une connexion, délai d'écriture : un client qui ne lit plus est déconnecté), `health_routes` et `HostHealth` (`/live`, `/ready`, `/health` : composants de l'hôte et sondes du runtime, sans message interne ; champs `host` et `modules` de `/health` ; `/ready` sonde aussi les connexions de la session système et répond `204` si une au moins répond dans le délai remis à `HostHealth::new`) |
| `metrics` | `Metrics`, `MetricsSnapshot` : requêtes HTTP (total, en cours, en échec), durée de vie |
| `modules` | `EmbeddedModule`, `ManifestModule` (module sans code Rust), `FOUNDATION`, `manifest`, `install_foundation` (socle sous bail au nom du nœud, puis définitions d'erreurs de l'hôte hors empreinte du socle), `install_host_seeds` |
| `services` | Sections `[crypto]`, `[secrets]` et `[storage]` communes aux hôtes, reçues avec les mêmes valeurs par `lyxal-server` et `lyxal-groupware` sur une même base : `CryptoConfig` (clé applicative, par l'environnement seulement, et son identifiant) et `application_crypto(config, préfixe)` (trousseau applicatif lu dans `<préfixe>__CRYPTO__APPLICATION_KEY` : clés de signature de `lyxal_auth`) ; `SecretsConfig` (clé maîtresse du coffre-fort et, pendant une rotation, l'ancienne), `StorageConfig` (`disk`, `s3.<nom>`, `antivirus`), `DiskStorageConfig`, `S3StorageConfig`, `AntivirusConfig` ; `SECRET_KEYS` (clés lues dans l'environnement seulement) ; `validate_storage` (noms des supports, support `default` déclaré deux fois, antivirus) ; `master_keys(config, préfixe)` (trousseau maître lu par `lyxal_crypto::EnvironmentKeyProvider` dans `<préfixe>__SECRETS__MASTER_KEY` et `__PREVIOUS_MASTER_KEY`) ; `storage_backends` (supports de `lyxal_storage`) ; `storage_scanner` (antivirus ClamAV) |
| `net` | `IpNetwork`, `client_ip` (adresse réelle derrière des proxys de confiance, `X-Forwarded-For` lu de droite à gauche), `normalize_ip`, `log_network` (réseau d'un client pour le journal : IPv4 `/24`, IPv6 `/48`, jamais l'adresse complète) |
| `shutdown` | `signal` : SIGINT, ou SIGTERM sous Unix |
| `telemetry` | `init` : journal `tracing`, texte ou JSON |
| `build` | `embed_modules` : corps du `build.rs` d'un hôte, qui embarque le manifeste et les fichiers `[resources]` de chaque module hébergé (constante `EMBEDDED_MODULES`) ; compilation en échec si un fichier déclaré manque |

## 2. Session système et pool de connexions

Un serveur SurrealDB ne répartit pas sur ses cœurs les requêtes d'une même connexion. La session
système d'un hôte est donc un pool (`Database`, `[database] connections`) :

| Qui | Reçoit |
| :--- | :--- |
| Stores des modules sur la session système (`lyxal_auth`, `lyxal_i18n`, `lyxal_secrets`, `lyxal_storage`, `lyxal_scheduler`, `lyxal_notification`, `lyxal_pipeline_ingestion`, `lyxal_mail`) | Le pool (`Store::new(database.clone())`) : chaque appel prend la connexion du tour suivant |
| Runtime (`LyxalRuntime::with_client`, store, baux d'installation et `leader`, présence des nœuds), moteur d'événements, installation du socle, des modules et des seeds | La connexion fixe (`database.fixed()`) |
| Requête `LIVE SELECT` du fil de `lyxal_notification` (ouverture et vérification) | La connexion fixe |
| Session d'un utilisateur ou d'un compte de service (`authenticate`) | Une copie de la connexion fixe (`database.fixed().clone()`), authentifiée par son jeton ; ses stores gardent ce client unique |

Aucun client du pool ne reçoit de changement d'état de session. Deux appels simultanés d'un même
nœud peuvent se heurter dans la base comme ceux de deux nœuds, sur plusieurs connexions comme sur
une seule (ses requêtes s'entrelacent) : les modules rejouent ces conflits (`lyxal_scheduler`,
`lyxal_notification`, `lyxal_storage`, `lyxal_secrets`, `lyxal_mail`, `lyxal_pipeline_ingestion`).
`/ready` reste `204` tant qu'une connexion répond ; une connexion coupée est rouverte par le SDK,
seuls ses appels en cours échouent.

## 3. Erreurs

`HostError` n'a pas de code d'erreur : chaque hôte la traduit dans les siens (`From<HostError>`
pour `ServerError` de `lyxal-server` : `Configuration` → `SERVER_CONFIGURATION_INVALID`,
`Database` → `SERVER_DATABASE_UNAVAILABLE`, `ModuleInstall`, `Bind`, `ShutdownSignal`,
`Telemetry` de même ; pour `GroupwareError` de `lyxal-groupware` : codes `GROUPWARE_*`
correspondants). Une erreur du runtime (`HostError::Runtime`) garde son code `RUNTIME_*`.
Les routes de santé rendent une erreur du runtime par le type d'erreur de l'hôte
(`health_routes::<S, E>`), au contrat `LyxalResult`.

## 4. Fonctionnalités Cargo

| Fonctionnalité | Contenu |
| :--- | :--- |
| `host` (par défaut) | Toute la bibliothèque des hôtes |
| `build` | `build::embed_modules` seulement ; n'amène que `toml` (dépendance de compilation d'un hôte) |

`host` amène `lyxal_crypto`, `lyxal_secrets` et `lyxal_storage` (pour `services`), tous sous
licence `MIT OR Apache-2.0` et sans dépendance vers `lyxal_host` : aucun cycle, aucun paquet AGPL
(`scripts/ci/check_agpl_isolation.py`).

La dépendance du workspace est déclarée sans fonctionnalité par défaut : un hôte demande `host`
dans `[dependencies]` et `build` dans `[build-dependencies]`.

## 5. Vérification

```bash
cargo test -p lyxal_host
```

Tests unitaires : réseaux, adresse du client et réseau masqué pour le journal (`net`), chargement en couches (environnement
prioritaire, listes, clé secrète refusée dans un fichier, y compris dans une entrée de table,
fichier par défaut obligatoire), secret masqué, `database.connections` (défaut, fichier,
environnement, `0` refusé) ; sections communes (`services` : noms de
supports, antivirus, support `default` déclaré deux fois, clé secrète S3 refusée dans un fichier,
supports construits, trousseau maître sans identifiant ou sans clé active refusé). `tests/serve.rs` : adresse du client transmise
aux routes, client qui cesse de lire déconnecté après le délai d'écriture, arrêt qui laisse
finir les requêtes en cours. Le reste (base, santé, socle, modules embarqués) est exercé par la
suites de `lyxal-server` et de `lyxal-groupware` (`cargo test -p lyxal-server -p
lyxal-groupware`), qui démarrent les hôtes réels.
