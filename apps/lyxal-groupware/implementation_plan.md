# Plan d'implémentation — programme courrier, agendas et contacts, lot 3 (hôte et socle réseau)

Plan détaillé du lot 3 du programme courrier, agendas et contacts (`implementation_plan.md` à la
racine, §4.3, §5 et décisions **P2**, **P3**, **P7**) : création de l'hôte dédié
`apps/lyxal-groupware`, de ses écoutes réseau supervisées et du squelette de `lyxal_mail`.

| Brique | Ce que c'est, en clair | Premier lot qui s'en sert vraiment |
| :--- | :--- | :--- |
| Hôte `lyxal-groupware` | Le second programme de Lyxal OS : il rejoint la même base que `lyxal-server`, installe ses modules et ouvre les ports du courrier | lot 3 (lui-même), puis 5, 6, 8, 10, 12, 15 |
| Écoutes supervisées | Une écoute par port (25, 587, 465, 143, 993, 110, 995, 4190), surveillée et redémarrée par le runtime | lot 5 (SMTP) |
| TLS implicite et STARTTLS | Le cadenas posé dès la connexion (465, 993, 995) ou demandé en cours de session (25, 587, 143, 110, 4190) | lots 5, 6, 8, 10 |
| Limites | Nombre de connexions et cadence par adresse IP et par réseau, plafond par écoute, budget mémoire, délais | lots 5 à 12 |
| Santé | `/live`, `/ready`, `/health`, `/metrics` de l'hôte ; sonde des écoutes | dès ce lot |

Ce lot ne contient **aucun protocole** : pas de SMTP, d'IMAP, de POP3 ni de ManageSieve (lots 5,
8, 9, 10). Il pose tout ce qui se trouve **sous** les protocoles, pour que chaque lot suivant
n'ait plus qu'à brancher sa session.

Touche : `apps/lyxal-groupware` (nouveau), `crates/lyxal_mail` (squelette Rust, manifeste),
`crates/lyxal_host` (nouveau, extrait de `lyxal-server`, décision G1), `apps/lyxal-server`
(remplacement du code extrait, **sans changement de comportement**), `Cargo.toml` et
`deny.toml` (racine), `scripts/ci/test_all.sh`, `.agents/AGENTS.md` (§5.8.5, §6), documents du
programme. Aucune ligne de code avant la validation de ce plan par le CTO (`.agents/AGENTS.md`
§3).

Méthode : constats faits **par lecture** du dépôt (`apps/lyxal-server`, `crates/lyxal_runtime`,
`crates/lyxal_crypto/src/tls.rs`, `scripts/ci/`, `deny.toml`, `Cargo.lock`, documents du
programme et de `lyxal_mail`), des sources figées clonées le 20 novembre 2026 par
`scripts/sources/fetch_sources.sh` (Stalwart `3adead9`, copie triée sans `LicenseRef-SEL` ; Mox
`b32f0de`), de la bibliothèque `mail-auth` au commit `c862df2` (lecture de fichiers isolés sur
GitHub) et de l'index crates.io (licence et versions de `proxy-header`). **Rien n'a été compilé
ni exécuté.** Ce qui n'est pas vérifié est marqué « non vérifié » (liste au §17).

**Fichiers sources lus** (chemins de la copie triée de Stalwart, tous à double licence
`AGPL-3.0-only OR LicenseRef-SEL`, aucun extrait propriétaire restant dans ces fichiers,
constaté) : `crates/common/src/network/{mod.rs, listen.rs, limiter.rs, memory.rs, security.rs,
tls.rs}`, `crates/common/src/config/server/{listener.rs, mod.rs}` ; Mox (MIT) :
`ratelimit/ratelimit.go`, `mox-/lifecycle.go`, `smtpserver/server.go` (limites et délais),
`imapserver/server.go` (délais).

**Règle de provenance (programme §4.1, P2)** : le code porté de Stalwart (AGPL) ne va que dans
`apps/lyxal-groupware` et `crates/lyxal_mail`, qui déclarent `AGPL-3.0-only`. Le nouveau crate
`lyxal_host` ne reçoit **que** du code déjà écrit pour Lyxal dans `lyxal-server` et reste sous
`MIT OR Apache-2.0` ; aucun fichier de Stalwart ou de Mox n'y entre. Le code de Mox (MIT) repris
dans `lyxal_mail` garde sa mention de licence.

**Bilan de réutilisation (§3 de `AGENTS.md`)** :

* `lyxal_core` — **aucune fonction appelée** : ce lot n'a ni table, ni fonction SurrealQL, ni
  entrée utilisateur en base. La configuration de l'hôte est lue et validée en Rust **avant**
  toute connexion à la base, comme celle de `lyxal-server` (même pratique : `IpNetwork`,
  bornes, schémas d'URL). Les fonctions `fn::validation_ip`, `fn::validation_cidr`,
  `fn::validation_socket_address` et `fn::security_redact_ip` existent et ont été vérifiées :
  elles serviront dès qu'une adresse ou un réseau entrera en base (liste de blocage, lot 5).
  Besoin `lyxal_core` manquant : aucun.
* `lyxal_crypto` — `tls_server_config`, `TlsCertificateStore`, `TlsCertifiedKey`,
  `TlsServerOptions`, `rustls` réexporté (lot 2a) ; `hash::blake3` pour détecter le changement
  d'un fichier de certificat. Aucune extension (§9).
* `lyxal_runtime` — `LyxalWorker` / `CancellationToken` / `RestartPolicy`, `ModuleHealthCheck`,
  `HostId`, présence (`runtime_node`), `install_foundation`, `install_packages`, moteur
  d'événements par hôte (`EventEngineConfig::new(&host)`).
* `lyxal-server` — démarrage, base, santé, journal, arrêt, modules embarqués : **extraits** dans
  `lyxal_host` et partagés (G1), pas recopiés.
* `XxxParams` / `XxxResult`, fonctions `fn::*`, master data `MAIL_*`, événements, permissions :
  **sans objet** dans ce lot (§8). Master data : 7 codes `GROUPWARE_*` de l'hôte.

## 0. Écarts au plan du programme

| # | Écart | Raison |
| :- | :--- | :--- |
| E1 | Nouveau crate **`crates/lyxal_host`** (bibliothèque des hôtes, `MIT OR Apache-2.0`) extrait de `lyxal-server` ; `lyxal-server` est modifié (remplacement par des appels à `lyxal_host`, comportement inchangé), alors que P3 le disait « inchangé » | Le second hôte a besoin du même démarrage (base et refus de l'accès anonyme, socle sous bail, modules embarqués, santé, journal, arrêt) : le recopier ferait deux propriétaires d'une même responsabilité (§5.1). Le faire dépendre du binaire `lyxal-server` lierait toutes ses routes et tous ses modules dans le binaire AGPL. P3 visait l'isolement des ports et de la licence, qui est tenu : `lyxal-server` ne lie toujours aucun crate AGPL (G1) |
| E2 | **DNS** : choix arrêté (`hickory-resolver` 0.26), mais le résolveur est construit au **lot 5**, pas au lot 3 | Rien dans ce lot ne résout de nom (aucun protocole, pas de journal des noms inverses). Au lot 5, SPF, DKIM et DMARC passent par `mail-auth`, qui construit lui-même son résolveur `hickory` (champ `pub(crate)` de `MessageAuthenticator`, constaté) : en créer un au lot 3 ferait du code mort ou un second résolveur (G12) |
| E3 | Le squelette de `lyxal_mail` est **du Rust seul** : le contrat réseau des sessions (`lyxal_mail::net`), les limites et le budget mémoire ; manifeste sans ressource SurrealQL ; aucune table, aucune fonction, aucun code `MAIL_*` | Le programme parle de « squelette » sans le définir. Le lot 3 n'a aucune donnée à garder : des tables ou des codes d'erreurs sans appelant seraient du code mort (§0.2). Le modèle des boîtes est figé au lot 4 |
| E4 | **PROXY protocol** (v1 et v2) ajouté au lot, avec une dépendance nouvelle `proxy-header` 0.1.3 (MIT) | Derrière un répartiteur de charge (HAProxy, répartiteur d'un hébergeur), l'hôte ne voit sinon que l'adresse du répartiteur : limites par IP inopérantes et, au lot 5, SPF faux. Stalwart le fait avec la même bibliothèque (G9) |
| E5 | Réglages des écoutes et des limites dans les **fichiers de configuration** du nœud, pas en base ; **liste de blocage persistante** (bannissement après échecs) reportée au lot 5 | Un port est ouvert par un processus : c'est un réglage du nœud, comme `server.port` de `lyxal-server`. Les raisons de bannir (destinataires inconnus en rafale, échecs d'authentification) n'existent qu'avec les protocoles (G5, G10) |
| E6 | `lyxal-groupware` n'héberge au lot 3 que le socle, `lyxal_event` et `lyxal_mail` ; `lyxal_auth`, `lyxal_storage`, `lyxal_secrets`, `lyxal_scheduler` arrivent avec le premier lot qui s'en sert | Le runtime exige que les dépendances d'un module soient dans le même registre (`DependencyResolver`, constaté) : chaque module ajouté au manifeste de `lyxal_mail` est ajouté à l'hôte dans le même lot (G4) |
| E7 | Livraison en **trois demandes de fusion** sous ce plan : 3a (extraction `lyxal_host`), 3b (hôte, écoutes, limites, santé, deux hôtes), 3c (TLS, STARTTLS, PROXY, rechargement des certificats) | 3a est un remaniement pur de `lyxal-server`, relu à part ; 3b et 3c séparent la mécanique des connexions de la couche TLS (G15) |

## 1. Périmètre

**Dans le lot 3** :

* `crates/lyxal_host` : code commun des hôtes, extrait de `lyxal-server` (§4) ;
* `crates/lyxal_mail` : paquet Cargo `AGPL-3.0-only`, manifeste du module, contrat réseau des
  sessions (`lyxal_mail::net`), limiteur par IP, plafond de connexions, budget mémoire, lignes
  de refus poli par protocole (§5) ;
* `apps/lyxal-groupware` : binaire hôte `lyxal_groupware` (nom fixe), démarrage sur la base
  partagée (socle sous bail, modules, présence, moteur d'événements de l'hôte), écoutes TCP
  supervisées (`LyxalWorker`), pipeline d'acceptation (PROXY, listes, limites, budget, TLS),
  TLS implicite (RFC 8314) et mise à niveau STARTTLS (RFC 3207) offerte aux sessions,
  certificats fournis par fichiers et rechargés à chaud, délais, arrêt avec drainage, port HTTP
  de santé, journal sans donnée personnelle, erreurs `GROUPWARE_*`, `Dockerfile` (§6, §7) ;
* preuves : deux hôtes sur une même base (`lyxal-server` réel et `lyxal-groupware`), sur le
  moteur embarqué et sur un serveur SurrealDB 3.3.4 réel (`ws://`) (§10).

**Ce que fait un lot 3 fusionné, concrètement** : on lance `lyxal-groupware` à côté de
`lyxal-server` sur la même base. Il installe ou retrouve le socle, installe `lyxal_mail`, se
déclare dans `runtime_node` (visible dans `/api/v1/system/modules` de `lyxal-server`), élit son
propre chef des événements, ouvre les ports configurés avec le certificat fourni, applique les
limites et répond sur chaque port de courrier par un **refus poli et standard** (« service pas
encore disponible » : `421` en SMTP, `* BYE` en IMAP, `-ERR` en POP3, `BYE` en ManageSieve), en
clair ou après la poignée de main TLS selon le port. Un exploitant peut donc valider dès ce lot
pare-feu, certificat (`openssl s_client -connect hôte:993`), limites et santé. L'arrêt draine
les connexions. Les sessions STARTTLS sont prouvées par un protocole d'essai des tests (§10).

**Hors lot 3** (lot prévu entre parenthèses) :

* protocoles SMTP (5, 6), IMAP (8), POP3 (9), ManageSieve (10), JMAP (12), DAV (15) ; routes
  HTTP du DAV et de JMAP, découverte `/.well-known/…` (12, 15) ;
* résolveur DNS, noms inverses (5), DNSSEC (7) ;
* liste de blocage persistante et bannissement automatique (5 pour SMTP, 8 pour IMAP), limites
  partagées entre nœuds (21, si les mesures l'exigent) ;
* certificats tirés de `lyxal_secrets`, ACME, dates d'expiration, agrafage OCSP (13, P6 g) ;
* TLS sortant (6, C8 du lot 2), MTA-STS, DANE (7) ;
* authentification (SASL, mots de passe d'application) : décidée et appliquée par chaque
  protocole (5, 6, 8) ; ce lot leur donne l'état TLS de la connexion ;
* LMTP et sockets Unix (non demandés par le programme) ; abandon des privilèges dans le code
  (G14) ; ligne de commande d'administration de l'hôte.

## 2. Point de départ (constats)

### 2.1. `lyxal-server` aujourd'hui

12 100 lignes de Rust (`src/`, hors tests), bibliothèque `lyxal_server` + binaire. Démarrage
(`bootstrap.rs`) : configuration (`config` 0.14, fichiers `config/{default,<env>}.toml` puis
variables `LYXAL__*`, `deny_unknown_fields`, secrets refusés dans les fichiers), journal
(`telemetry.rs`), base (`database.rs` : fabrique de `lyxal_surreal`, sonde, **refus d'une base
qui accepte les invités**), runtime (`runtime.rs` : socle sous bail par
`install_foundation`, définitions `SERVER_*` hors empreinte du socle, `install_packages`,
`start_all`), HTTP (`serve.rs` : hyper 1, délai d'écriture `tokio-io-timeout`, arrêt gracieux),
santé (`health.rs`, `http/handlers.rs` : `/live`, `/ready`, `/health` agrégeant les sondes du
runtime, `/metrics`), arrêt (`shutdown.rs` : SIGINT / SIGTERM, puis `stop_all`), proxys de
confiance (`net.rs` : `IpNetwork`, `client_ip`). Modules embarqués : `build.rs` lit chaque
`manifest.toml` et inclut les fichiers de `[resources]` ; `modules/mod.rs` : `EmbeddedModule`,
`ManifestModule` (module sans Rust), `HOST_ID = "lyxal_server"`. Erreurs : 9 codes `SERVER_*`
(`error/server.surql`, contrôlés contre `src/error.rs` par un test).

Code **générique** (sans rien de propre aux routes de `lyxal-server`), candidat à l'extraction
(G1) : `database.rs` (101 lignes), `health.rs` (91), `telemetry.rs` (37), `shutdown.rs` (30),
`net.rs` (185), `serve.rs` (78), `metrics.rs` (66), la partie générique de `modules/mod.rs`
(≈ 150) et de `config.rs` (≈ 200 : `SecretPassword`, `DatabaseConfig`, `ObservabilityConfig`,
chargement en couches), `/live` `/ready` `/health` (≈ 60), `build.rs` (93) : ≈ 1 100 lignes.

### 2.2. Plusieurs hôtes sur une base (prérequis, fait)

Constaté dans `lyxal_runtime` : `HostId`, nœud tiré au sort et présence (`runtime_node`,
battement 10 s), hook `install` une fois par release, socle sous bail, réconciliation stricte
par hôte (`foreign_modules`), chef des événements par hôte (`event_stream_lease:<hôte>`).
Essais existants : `crates/lyxal_runtime/tests/it/two_hosts_shared_database_tests.rs`,
`apps/lyxal-server/tests/it/two_hosts.rs` (avec un hôte d'essai `lyxal_peer`). **Restes notés**
(`crates/lyxal_event/ROADMAP.md`, `crates/lyxal_runtime/ROADMAP.md`) : un seul handler par type
d'événement et par processus ; files du planificateur réservées à un hôte ; exécuteur créé à
chaud. **Aucun n'est nécessaire au lot 3** (aucun abonnement, aucun planificateur dans
`lyxal-groupware`) ; ils deviennent des prérequis des lots qui hébergeront des handlers ou des
tâches dans `lyxal-groupware` (§18).

Workers : `LyxalRuntime::register_worker`, `WorkerDescriptor` (criticité `Required` /
`Optional`, `RestartPolicy`, `shutdown_timeout`), `WorkerContext::cancellation`. `stop_all`
arrête d'abord tous les workers (coopératif, délai par worker), puis les modules, puis retire le
nœud de `runtime_node`.

### 2.3. TLS disponible (lot 2a, fusionné)

`lyxal_crypto::tls` (constaté) : `TlsCertifiedKey::from_pem(chain, SecretBytes)` (PEM 64 Kio,
clé 16 Kio, clé chiffrée refusée, paire clé/certificat vérifiée), `TlsCertificateStore` (un
certificat par nom SNI, joker sur un niveau, défaut ; `insert` refuse un certificat qui ne
couvre pas le nom ; remplacement atomique), `TlsServerOptions` (version minimale, ALPN, cache
de sessions), `tls_server_config` (fournisseur `aws-lc-rs` explicite, pas de 0-RTT, pas de
certificat client), `pub use rustls`. Garde-fou `scripts/ci/check_crypto_dependencies.py` :
`tokio-rustls` permis aux seuls paquets `apps/*` (`HOST_ONLY`), aucun
`ServerConfig::builder` hors de `lyxal_crypto`.

### 2.4. Bibliothèques

| Crate | Version | Déjà dans `Cargo.lock` | Licence | Usage au lot 3 |
| :--- | :--- | :--- | :--- | :--- |
| `tokio-rustls` | 0.26.4 | oui (par `reqwest`, `lettre`) | MIT OR Apache-2.0 | Poignée de main serveur, STARTTLS (hôte seulement) |
| `socket2` | 0.6.5 | oui | MIT OR Apache-2.0 | Options des sockets (keepalive, `SO_REUSEADDR`, file d'attente) |
| `proxy-header` | 0.1.3 (23 sept. 2026) | **non** | MIT (crates.io, constaté) | PROXY protocol v1 / v2 (G9) |
| `hyper`, `hyper-util`, `tokio-io-timeout`, `axum` | — | oui (`lyxal-server`) | MIT | Port HTTP de santé |
| `config`, `toml` | — | oui | MIT OR Apache-2.0 | Configuration, `build.rs` |
| `hickory-resolver` | 0.26.3 | oui (`lyxal_auth`) | MIT OR Apache-2.0 | **Pas au lot 3** (E2) |

Une seule entrée nouvelle dans `Cargo.lock` (`proxy-header`, sans dépendance nouvelle d'après
son manifeste : `tokio`, `pin-project-lite` — non vérifié) ; licence MIT déjà permise par
`deny.toml`.

### 2.5. Ce que font Stalwart et Mox (sources lues)

| Sujet | Stalwart (`common/src/network`, AGPL) | Mox (MIT) | Retenu pour Lyxal |
| :--- | :--- | :--- | :--- |
| Boucle d'acceptation | `listen.rs` : une tâche par adresse, recul exponentiel 5 ms → 1 s sur erreur d'acceptation, erreurs `ConnectionAborted` / `Reset` / `Interrupted` ignorées ; arrêt par `watch` | — | Porté dans un `LyxalWorker` ; arrêt par `CancellationToken` ; sessions dans un `JoinSet` (pas de `tokio::spawn` libre, §5.8.3) |
| Sockets | `config/server/listener.rs` : repli IPv4 si IPv6 absent, `SO_REUSEADDR`, `SO_REUSEPORT`, tampons, file d'attente 1 024, contrôle de l'adresse liée ; `TCP_NODELAY`, keepalive 300 s / 30 s / 4 essais | keepalive 5 min (IMAP) | Porté (sans les réglages `TOS` / `TTL`, non demandés) |
| Plafond | `limiter.rs` : `ConcurrencyLimiter` global par écoute, jeton `InFlight` rendu à la fermeture | — | Porté |
| Par IP | Débits en base (`RateWindow`), bannissement (`security.rs` : `fail2ban`, IP bloquées en mémoire et en base) | `ratelimit.go` : fenêtres fixes sur **trois niveaux de réseau** (IPv4 /32, /26, /21 ; IPv6 /64, /48, /32) ; SMTP : 300 / 900 / 2 700 connexions par minute, 30 / 90 / 270 connexions ouvertes | Limiteur de Mox transposé, en mémoire ; bannissement : lot 5 (E5) |
| Mémoire | `memory.rs` : budget global en deux classes (réception SMTP, lecture), réservation par pas de 64 Kio, plancher d'un quart par classe, portée annulable | — | Porté |
| TLS | `mod.rs` : `TcpAcceptor::{Tls { implicit }, Plain}`, poignée de main sous délai (60 s par défaut), `SessionResult::UpgradeTls` pour STARTTLS ; `tls.rs` : choix du certificat par SNI (fait par `lyxal_crypto` chez nous) | — | Modes `none` / `starttls` / `implicit` ; mise à niveau offerte aux sessions par un trait (§5) ; délai 30 s |
| PROXY | `proxy-header`, seulement depuis `proxy_networks`, sous délai | — | Retenu (G9) |
| Arrêt | `SessionManager::shutdown` | `lifecycle.go` : registre des connexions ; à l'arrêt, échéance immédiate sur toutes | Jeton d'annulation transmis à chaque session, délai de drainage, puis abandon |
| Privilèges | `privdrop` après la liaison des ports | — | Non : capacité système (G14) |

Aucun des fichiers lus ne contient encore d'extrait propriétaire après le tri (constaté :
aucune ligne `Snippet`). Le module ACME (`network/acme`) et la découverte (`network/autoconfig`)
restent pour le lot 13.

## 3. Architecture

### 3.1. Crates et licences

| Paquet | Nature | Contenu au lot 3 | Licence (F4, P2) |
| :--- | :--- | :--- | :--- |
| `crates/lyxal_host` (**nouveau**) | Bibliothèque des hôtes | Démarrage commun extrait de `lyxal-server` (§4) | `MIT OR Apache-2.0` (code Lyxal ; **jamais** de code porté) |
| `crates/lyxal_mail` (squelette) | Module du Noyau (Rust au lot 3) | `manifest.toml` ; `src/net/` : contrat des sessions, limites, budget mémoire, refus (§5) | `AGPL-3.0-only` |
| `apps/lyxal-groupware` (**nouveau**) | Hôte (bibliothèque + binaire) | Démarrage, écoutes, TLS, PROXY, santé, erreurs `GROUPWARE_*` (§6) | `AGPL-3.0-only` |
| `apps/lyxal-server` | Hôte existant | Code générique remplacé par `lyxal_host` | inchangée (`MIT OR Apache-2.0`) |

Pourquoi le code réseau est partagé ainsi (G2) : `tokio-rustls` n'est permis qu'aux hôtes
(règle 10 du §11.3) ; la poignée de main et la mise à niveau TLS vivent donc dans l'hôte. Les
sessions des protocoles (lots 5 à 10) vivront dans `lyxal_mail` : elles ont besoin d'un contrat
commun (flux, informations de connexion, mise à niveau TLS, jeton d'arrêt, réservation
mémoire, délais) que l'hôte implémente. Ce contrat est dans `lyxal_mail::net`, seul crate qui
en a besoin (le DAV et JMAP passent par HTTP). Les limites et le budget sont aussi dans
`lyxal_mail::net` : l'hôte les applique à l'acceptation, les sessions les prolongent (débit de
messages, taille d'un `DATA`).

### 3.2. Graphe des dépendances (aucun cycle)

```text
lyxal_error · lyxal_surreal · lyxal_crypto · lyxal_runtime
        ▲
lyxal_host ──────────────────────────────┐
        ▲                                │
apps/lyxal-server (MIT/Apache)    apps/lyxal-groupware (AGPL) ──► lyxal_mail (AGPL, lot 3 : tokio, tokio-util, async-trait, thiserror)
                                         └─► lyxal_crypto (TLS), tokio-rustls, proxy-header, socket2
apps/lyxal-groupware [dev] ──► apps/lyxal-server (bibliothèque, essais à deux hôtes seulement, G16)
```

* `lyxal_host` dépend de `lyxal_runtime`, `lyxal_surreal`, `lyxal_error` et des crates HTTP déjà
  utilisées ; aucun crate du Noyau ne dépend de lui ; il ne dépend d'aucun module.
* `lyxal_mail` (lot 3) ne dépend d'aucun crate Lyxal : il en ajoutera au lot 4
  (`lyxal_surreal`, `lyxal_auth`, `lyxal_storage`…).
* `lyxal-server` ne lie toujours **aucun** paquet AGPL (P3) ; seul le banc d'essai de
  `lyxal-groupware` lie `lyxal-server`, dans ce sens.
* Place dans `AGENTS.md` §6 : `lyxal_host` sous « UI / Process Host », bibliothèque des hôtes.

### 3.3. Ce qui tourne dans `lyxal-groupware` au lot 3

```text
processus lyxal-groupware (hôte « lyxal_groupware », un nœud par processus)
├── LyxalRuntime : socle (lyxal_core, lyxal_error) + lyxal_event + lyxal_mail (ManifestModule)
│   ├── moteur d'événements de l'hôte (bail event_stream_lease:lyxal_groupware, aucun abonnement)
│   ├── présence (runtime_node)
│   └── workers de lyxal_mail : mail.listener.<id> (un par écoute), mail.tls_reload
├── port HTTP (boucle principale, comme lyxal-server) : /live /ready /health /metrics
└── arrêt : SIGTERM → santé « stopping » → stop_all (écoutes drainées) → HTTP drainé
```

## 4. `lyxal_host` : code commun des hôtes (3a, décision G1)

Extraction **à comportement constant**. Chaque fonction garde sa logique, ses tests (déplacés)
et ses messages ; `lyxal-server` est mis à jour dans le même changement (§0.3 de `AGENTS.md`).

```rust
pub enum HostError {                       // erreurs sans code : chaque hôte les traduit
    Configuration { message: String },     //   SERVER_* / GROUPWARE_* (G6)
    Database { message: String },
    ModuleInstall { module: String, message: String },
    Bind { address: String, message: String },
    ShutdownSignal { message: String },
    Telemetry { message: String },
    Runtime(lyxal_runtime::RuntimeError),
}

pub mod config {
    pub struct SecretPassword;             // inchangé (SecretString, Debug masqué)
    pub struct DatabaseConfig;             // endpoint, ns, db, délai, identifiants (env seulement)
    pub struct ObservabilityConfig;
    pub struct RuntimeTimeouts;            // install / start / stop
    /// Fichiers `<dir>/default.toml`, `<dir>/<LYXAL_ENV>.toml`, puis variables `<prefix>__*` ;
    /// `secret_keys` : clés refusées dans les fichiers (ex. "secrets.master_key",
    /// "storage.s3.*.secret_access_key") ; `list_keys` : clés lues comme listes.
    pub fn load_layered<T: DeserializeOwned>(dir: &Path, env_prefix: &str, secret_keys: &[&str],
        list_keys: &[&str], variables: Option<Map<String, String>>) -> Result<T, HostError>;
}
pub mod database { connect_database, refuse_anonymous_access, probe }    // inchangés
pub mod telemetry { init }
pub mod shutdown { signal }
pub mod health { HealthRegistry, HealthState, HealthSnapshot }
pub mod net { IpNetwork, client_ip, normalize_ip, log_network /* §6.12 */ }
pub mod metrics { Metrics, MetricsSnapshot }                             // requêtes HTTP
pub mod http {
    /// `/live`, `/ready`, `/health` (composants de l'hôte + sondes du runtime, sans message
    /// interne), pour l'hôte `host`.
    pub fn health_routes(state: HostHealth) -> axum::Router;
    /// Boucle de `serve.rs` (inchangée) et son cœur par connexion, réutilisé par
    /// `lyxal-groupware` sur un flux déjà passé par PROXY / TLS.
    pub async fn serve(listener: TcpListener, router: Router, write_idle: Duration,
        drain: Duration, shutdown: impl Future<Output = ()>);
    pub fn serve_connection<S: AsyncRead + AsyncWrite + Send + Unpin + 'static>(stream: S,
        remote: SocketAddr, router: Router, write_idle: Duration, graceful: &GracefulShutdown)
        -> impl Future<Output = ()>;
}
pub mod modules {
    pub struct EmbeddedModule { pub id, pub manifest, pub files }        // inchangé
    pub struct ManifestModule;                                           // inchangé
    /// Socle sous bail, puis définitions d'erreurs de l'hôte (hors empreinte du socle).
    pub async fn install_foundation(client, host: &HostId, node: &NodeId,
        embedded: &[EmbeddedModule], host_module: &EmbeddedModule) -> Result<FoundationInstallation, HostError>;
    pub fn install_host_seeds(...);                                      // inchangé, paramétré
}
#[cfg(feature = "build")]
pub mod build {
    /// Corps de `build.rs` (inchangé) : `(module, fonctionnalité Cargo facultative)`.
    pub fn embed_modules(crates_dir: &Path, modules: &[(&str, Option<&str>)]);
}
```

`lyxal-server` garde ce qui lui est propre : ses routes, `AppContext`, ses modules et leurs
services, `ServerError` et ses codes `SERVER_*` (avec `From<HostError>`), sa ligne de commande,
sa configuration (qui embarque les sections communes de `lyxal_host::config`). Son `build.rs`
devient un appel à `lyxal_host::build::embed_modules` (dépendance de compilation avec la
fonctionnalité `build`, qui n'amène que `toml`).

Preuve de non-régression : toute la suite de `lyxal-server` passe sans modification de ses
assertions (seuls les chemins d'import changent) ; les tests unitaires déplacés passent dans
`lyxal_host`.

## 5. `lyxal_mail` : squelette et contrat réseau (3b)

### 5.1. Paquet et module

* `Cargo.toml` : `license = "AGPL-3.0-only"`, version `0.1.0`, `#![forbid(unsafe_code)]`,
  `#![deny(missing_docs)]`, dépendances `tokio` (`io-util`, `sync`, `time`), `tokio-util`,
  `async-trait`, `thiserror`.
* `manifest.toml` : `id = "lyxal_mail"`, `version = "0.1.0"`, `capabilities = ["mail"]`,
  dépendances : aucune au lot 3, `[resources]` vide (E3). Le module est porté dans l'hôte par un
  `ManifestModule` ; ses workers (écoutes) y sont rattachés.
* `LICENSES/` : texte de l'AGPL-3.0 et avis MIT de Mox ; chaque fichier porté garde son en-tête
  `SPDX-FileCopyrightText` d'origine, déclare `SPDX-License-Identifier: AGPL-3.0-only` (option
  retenue) et porte la mention « modifié pour Lyxal OS » ; le fichier transposé de Mox garde
  l'avis de copyright de Mox.
* `SOURCES.md` complété (§12).

### 5.2. Contrat des sessions (`src/net/session.rs`)

```rust
/// Protocole servi par une écoute.
pub enum MailProtocol { Smtp, Submission, Imap, Pop3, ManageSieve }

/// TLS d'une écoute : aucun, demandé en session (RFC 3207 et équivalents), dès la connexion (RFC 8314).
pub enum TlsMode { None, StartTls, Implicit }

/// État TLS d'une connexion, lu par les sessions (ex. refuser SASL PLAIN en clair, P8).
pub enum TlsState { Plain, Implicit(TlsInfo), Upgraded(TlsInfo) }
pub struct TlsInfo { pub version: &'static str, pub cipher: &'static str,
                     pub server_name: Option<String>, pub alpn: Option<Vec<u8>> }

/// Ce que la session sait de sa connexion. `remote` est l'adresse du client (après PROXY).
pub struct ConnectionInfo {
    pub listener_id: String, pub protocol: MailProtocol, pub session_id: u64,
    pub local: SocketAddr, pub remote: SocketAddr, pub via_proxy: bool, pub tls: TlsState,
}

/// Flux d'octets d'une connexion (TCP, ou TLS par-dessus).
pub trait MailStream: AsyncRead + AsyncWrite + Send + Unpin + 'static {}
pub type BoxedStream = Box<dyn MailStream>;

/// Mise à niveau TLS offerte par l'hôte (seul détenteur de tokio-rustls).
#[async_trait]
pub trait TlsUpgrade: Send + Sync {
    async fn upgrade(&self, stream: BoxedStream) -> Result<(BoxedStream, TlsInfo), NetError>;
}

/// Délais d'une session, fixés par l'écoute (§6.9).
pub struct SessionLimits { pub idle: Duration, pub write_stall: Duration }

/// Une connexion acceptée, remise au protocole.
pub struct Session {
    pub info: ConnectionInfo,
    pub limits: SessionLimits,
    /// Annulé à l'arrêt du nœud : le protocole dit au revoir à la prochaine commande.
    pub shutdown: CancellationToken,
    /// Mémoire réservée pour cette connexion (base de 64 Kio), à agrandir par le protocole.
    pub memory: MemoryReservation,
    /* flux et mise à niveau : privés */
}
impl Session {
    pub fn stream(&mut self) -> &mut BoxedStream;
    /// STARTTLS. `pending_input` : octets déjà lus après la commande STARTTLS. Non vide →
    /// `NetError::PipelinedBeforeTls` et la connexion doit être fermée (injection de commandes
    /// en clair, faille connue « STARTTLS command injection »). Écoute sans STARTTLS ou déjà en
    /// TLS → `NetError::TlsUnavailable`. Délai : celui de la poignée de main.
    pub async fn start_tls(&mut self, pending_input: &[u8]) -> Result<(), NetError>;
}

/// Ce qu'un protocole implémente (lots 5, 6, 8, 9, 10).
#[async_trait]
pub trait SessionHandler: Send + Sync + 'static {
    fn protocol(&self) -> MailProtocol;
    async fn handle(&self, session: Session) -> SessionEnd;
}
pub enum SessionEnd { Closed, ClosedOnShutdown, Failed(NetError) }

/// Erreurs du transport (énumération Rust, jamais renvoyée à un client ni en base).
pub enum NetError { Io(..), Timeout, TlsHandshake(..), TlsUnavailable, PipelinedBeforeTls, MemoryBudget }
```

### 5.3. Refus poli (`src/net/refusal.rs`)

```rust
pub enum RefusalReason { TooManyConnections, RateLimited, Blocked, MemoryBudget, ShuttingDown, Unavailable }
/// Ligne complète (CRLF compris) à écrire avant de fermer.
pub fn refusal_line(protocol: MailProtocol, reason: RefusalReason) -> &'static [u8];
/// Handler du lot 3 pour tout protocole sans session : refus `Unavailable` puis fermeture.
pub struct UnavailableHandler { protocol: MailProtocol }
```

Lignes : SMTP et soumission `421 4.3.2 …` (service indisponible), `421 4.7.0 …` (limites, IP
bloquée) — RFC 5321 §3.8 et §4.2.3, codes étendus RFC 3463 ; IMAP `* BYE …` (RFC 9051) ; POP3
`-ERR [SYS/TEMP] …` (RFC 2449, 3206) ; ManageSieve `BYE "…"` (RFC 5804). Les messages ne
reprennent ni l'adresse du client ni la raison interne exacte. `UnavailableHandler` sera retiré
quand le dernier protocole aura sa session (lot 10).

### 5.4. Limites (`src/net/limit.rs`, `src/net/ratelimit.rs`)

```rust
/// Plafond de connexions simultanées d'une écoute (porté de Stalwart `limiter.rs`).
pub struct ConnectionLimiter;
impl ConnectionLimiter { pub fn new(max: u32) -> Self; pub fn try_acquire(&self) -> Option<InFlight>; pub fn in_use(&self) -> u32; }
pub struct InFlight;                      // rend sa place à la libération (Drop)

/// Limiteur par réseau (transposé de Mox `ratelimit.go`) : fenêtres fixes, trois niveaux de
/// réseau (IPv4 /32, /26, /21 ; IPv6 /64, /48, /32), limites par niveau.
pub struct IpRateLimiter;
pub struct WindowLimit { pub window: Duration, pub limits: [u64; 3] }
impl IpRateLimiter {
    pub fn new(windows: Vec<WindowLimit>) -> Self;
    pub fn try_add(&self, ip: IpAddr, now: Instant, n: u64) -> bool;    // tout ou rien
    pub fn can_add(&self, ip: IpAddr, now: Instant, n: u64) -> bool;
    pub fn release(&self, ip: IpAddr, now: Instant, n: u64);            // connexions ouvertes
}
```

Différences avec Mox : compteurs bornés (au plus `max_tracked_networks` entrées par fenêtre,
défaut 100 000 ; au-delà, refus « surcharge » plutôt qu'allocation sans limite) ; aucun
`panic!` (Mox en a deux sur des cas impossibles) ; adresse IPv4 transportée en IPv6 ramenée à
l'IPv4 avant masquage.

### 5.5. Budget mémoire (`src/net/memory.rs`, porté de Stalwart `memory.rs`)

```rust
pub enum MemoryClass { SmtpInbound, Read }
pub struct MemoryBudget;                  // Arc, compteurs atomiques par classe
impl MemoryBudget { pub fn new(limit_bytes: u64) -> Self; pub fn used(&self) -> u64; pub fn limit(&self) -> u64;
                    pub fn reservation(&self, class: MemoryClass, per_session_limit: u64) -> MemoryReservation; }
pub struct MemoryReservation;             // reserve_to, try_reserve_within_limit, scope, shrink_to ; rendue à la libération
```

Règles reprises : réservation par pas de 64 Kio ; plancher d'un quart du budget par classe ;
portée (`scope`) annulée si non validée. Usage au lot 3 : chaque connexion réserve sa **base**
(`connection_base_bytes`, défaut 64 Kio : tampons de lecture et TLS) à l'acceptation ; budget
épuisé → refus `MemoryBudget`. Les sessions agrandiront leur réservation (corps d'un `DATA`,
lot 5 ; réponses volumineuses, lot 8).

## 6. Hôte `apps/lyxal-groupware` (3b, 3c)

### 6.1. Démarrage

Même déroulé que `lyxal-server`, par `lyxal_host` :

1. configuration (§7), journal ;
2. base : `connect_database` (même refus d'une base ouverte aux invités) ;
3. runtime : `HostId::new("lyxal_groupware")` (constante du code, = `id` de
   `apps/lyxal-groupware/manifest.toml`), socle sous bail (`install_foundation`, même empreinte
   que `lyxal-server` quand les deux viennent du même commit), définitions `GROUPWARE_*` ;
   moteur d'événements de l'hôte (`EventEngineConfig::new(&host).with_auto_init_schema(false)`)
   ; sonde du socle ;
4. **liaison des ports avant tout démarrage** : chaque adresse de chaque écoute est liée
   (socket `socket2`, options du §2.5) ; un échec arrête le démarrage (`GROUPWARE_BIND_FAILED`)
   ; certificats chargés (`GROUPWARE_TLS_CERTIFICATE_INVALID`) ;
5. inscription des workers `mail.listener.<id>` et `mail.tls_reload`, de la sonde
   `MailListenersHealthCheck` ; `install_packages` (socle, `lyxal_event`, `lyxal_mail`) ;
   `start_all` ;
6. port HTTP de santé ; attente du signal d'arrêt (§6.10).

`build.rs` : `lyxal_host::build::embed_modules(&["lyxal_core", "lyxal_error", "lyxal_event",
"lyxal_mail"])`.

### 6.2. Écoutes supervisées (`src/net/listener.rs`)

Un `LyxalWorker` par écoute, rattaché au module `lyxal_mail` :

* descripteur : `mail.listener.<id>`, criticité `Required` (une écoute arrêtée rend le module
  « malade »), `RestartPolicy::OnFailure` (5 essais, recul exponentiel), `shutdown_timeout` =
  délai de drainage + 5 s ;
* le worker reçoit ses sockets **déjà liées** (§6.1), gardées dans un `Arc` : un redémarrage
  reprend la même socket, sans fenêtre où le port serait libre ;
* boucle (portée de Stalwart `listen.rs`) : `select!` entre `accept()` et
  `ctx.cancellation.cancelled()` ; erreurs passagères ignorées, autres erreurs : recul de 5 ms à
  1 s ;
* chaque connexion est une tâche d'un **`JoinSet` possédé par le worker** (aucun
  `tokio::spawn` libre, §5.8.3) ; les tâches terminées sont récoltées au fil de l'eau.

### 6.3. Pipeline d'acceptation (`src/net/accept.rs`)

Dans l'ordre, pour chaque connexion :

| Étape | Contrôle | Échec |
| :- | :--- | :--- |
| 1 | Plafond de l'écoute (`ConnectionLimiter`), dans la boucle d'acceptation | fermeture immédiate (aucune écriture : le client n'a encore rien prouvé) |
| 2 | PROXY : si l'adresse de la connexion est dans `proxy_networks`, en-tête v1 ou v2 **obligatoire**, sous délai (§6.6) | fermeture |
| 3 | Listes statiques : `deny_networks`, puis `allow_networks` si non vide | refus `Blocked` |
| 4 | Par IP (sauf `exempt_networks`) : cadence (`try_add` sur la fenêtre d'une minute) puis connexions ouvertes | refus `RateLimited` / `TooManyConnections` |
| 5 | Budget mémoire : réservation de base | refus `MemoryBudget` |
| 6 | TLS implicite : poignée de main sous délai | fermeture (alerte TLS envoyée par rustls) |
| 7 | Remise au `SessionHandler` du protocole (`UnavailableHandler` au lot 3) | — |

Refus en écoute **implicite** : fermeture **sans** poignée de main (une poignée de main coûte du
calcul pour un client refusé) ; en écoute `none` ou `starttls` : ligne de refus en clair puis
fermeture, sous délai d'écriture de 5 s. Les jetons (`InFlight`, compteur par IP, réservation)
sont rendus à la fin de la tâche, quelle qu'en soit l'issue.

### 6.4. TLS implicite et STARTTLS (3c, `src/net/tls.rs`)

* Une `rustls::ServerConfig` par écoute TLS, construite par `lyxal_crypto::tls_server_config`
  sur le **même** `TlsCertificateStore` (un seul rechargement pour toutes les écoutes) ;
  options : version minimale TLS 1.2 (réglable à 1.3 par écoute), ALPN du protocole (G7).
* `tokio_rustls::TlsAcceptor` (`default-features = false`, fonctionnalités `tls12` et
  `aws_lc_rs` — fournisseur déjà choisi par `lyxal_crypto`) ; aucune construction de
  configuration TLS dans l'hôte (garde-fou C12 inchangé).
* `HostTlsUpgrade` implémente `TlsUpgrade` : même accepteur, même délai ; `Session::start_tls`
  refuse toute entrée déjà lue (§5.2) — c'est la protection contre l'injection de commandes en
  clair avant la mise à niveau.
* `TlsState` renseigné (version, suite, nom SNI, ALPN) pour les sessions et les mesures.
* Règles de configuration (G7) : `implicit` pour 465, 993, 995 (RFC 8314) ; `starttls` pour 25,
  587, 143, 110, 4190 ; `none` permis seulement pour `smtp` (réception des autres serveurs, où
  STARTTLS reste facultatif pour l'expéditeur) et pour le port HTTP derrière un proxy local ;
  une écoute `starttls` ou `implicit` sans certificat est refusée au démarrage.

### 6.5. Certificats et rechargement (3c, `src/net/certificates.rs`)

Configuration (§7) : un certificat **par défaut** et des certificats par nom, chacun donné par
deux chemins PEM (chaîne, clé), lus par l'hôte (C7 du lot 2 : `lyxal_crypto` ne lit aucun
fichier). Règles :

* la clé privée est lue dans un `SecretBytes`, jamais journalisée ; un fichier de clé lisible
  par le groupe ou les autres (mode `& 0o077 != 0`, Unix) est **refusé** ;
* `TlsCertificateStore::insert(nom, clé)` pour chaque nom déclaré (refus si le certificat ne
  couvre pas le nom), `set_default` pour le défaut ;
* worker `mail.tls_reload` (`Optional`) : toutes les `reload_interval_seconds` (défaut 60), relit
  les fichiers dont l'empreinte BLAKE3 du contenu a changé (les liens symboliques de certbot
  sont suivis) ; un nouveau couple valide remplace l'ancien à chaud (les connexions ouvertes
  gardent l'ancien) ; un couple invalide est **ignoré** : l'ancien reste en service, l'erreur
  est journalisée (`GROUPWARE_TLS_CERTIFICATE_INVALID`) et la sonde passe à « dégradé » jusqu'au
  prochain chargement réussi ;
* pas de signal `SIGHUP` au lot 3 (un seul mécanisme ; G8).

Les certificats de `lyxal_secrets` et ACME arrivent au lot 13 : ils alimenteront le même
`TlsCertificateStore`.

### 6.6. PROXY protocol (3c, `src/net/proxy.rs`, décision G9)

* Par écoute, `proxy_networks` (réseaux du répartiteur de charge). Depuis ces réseaux, l'en-tête
  PROXY v1 (texte) ou v2 (binaire) est **exigé** ; ailleurs, il n'est jamais lu (un client ne
  peut pas choisir son adresse).
* Lecture par `proxy-header` (`ProxiedStream::create_from_tokio`, comme Stalwart), délai
  `proxy_header_timeout_seconds` (défaut 5) ; en-tête absent, illisible ou hors délai :
  fermeture.
* Adresse source de l'en-tête → `ConnectionInfo.remote` ; adresse de destination → `local` ;
  `via_proxy = true`. IPv4 transportée en IPv6 ramenée à l'IPv4. En-tête `LOCAL` (sonde du
  répartiteur) : adresse de la connexion gardée.
* Pour le port HTTP, la règle de `lyxal-server` (`trusted_proxies` + `X-Forwarded-For`) reste
  celle de `lyxal_host::net::client_ip` ; PROXY y est aussi possible, au choix de l'exploitant.

### 6.7. Limites (valeurs par défaut, G10)

| Réglage | Défaut | Bornes | Origine |
| :--- | -: | :--- | :--- |
| `max_connections` par écoute | 4 096 | 1 à 65 536 | Stalwart (plafond par écoute) |
| Connexions ouvertes par réseau (`/32`, `/26`, `/21` ; IPv6 `/64`, `/48`, `/32`) | 30 / 90 / 270 | 1 à 100 000 | Mox (SMTP) |
| Connexions nouvelles par minute et par réseau | 300 / 900 / 2 700 | 1 à 1 000 000 | Mox (SMTP) |
| Réseaux suivis par fenêtre | 100 000 | 1 000 à 10 000 000 | Lyxal (borne mémoire) |

Les compteurs sont **par nœud** et **partagés entre les écoutes** du nœud (un client qui ouvre
30 connexions IMAP n'en ouvre pas 30 de plus en POP3). Plusieurs nœuds derrière un répartiteur :
les limites s'additionnent (limite connue, notée au `README.md`). Les réglages sont globaux au
lot 3 ; une surcharge par écoute est permise pour `max_connections` seulement.

### 6.8. Budget mémoire

`limits.memory_budget_bytes` (défaut 512 Mio, au moins 64 Mio), `connection_base_bytes` (défaut
64 Kio). Mesure exposée dans `/metrics` et dans la sonde (« dégradé » au-delà de 90 %).

### 6.9. Délais

| Délai | Défaut | Appliqué par |
| :--- | -: | :--- |
| Poignée de main TLS (implicite et STARTTLS) | 30 s | hôte |
| En-tête PROXY | 5 s | hôte |
| Écriture bloquée (client qui ne lit plus) | 60 s | hôte (flux à délai d'écriture, comme `lyxal-server`) |
| Écriture d'une ligne de refus | 5 s | hôte |
| Inactivité d'une session : SMTP / soumission | 300 s | protocole (RFC 5321 §4.5.3.2) |
| Inactivité : IMAP | 1 800 s | protocole (RFC 9051 : déconnexion après 30 min au moins) |
| Inactivité : POP3 | 600 s | protocole (RFC 1939 §3 : 10 min au moins) |
| Inactivité : ManageSieve | 300 s | protocole |
| Drainage à l'arrêt | 30 s | hôte |

Les délais d'inactivité sont transmis aux sessions (`SessionLimits`) ; au lot 3 seul le protocole
d'essai des tests les exerce. Keepalive TCP : 300 s, 30 s, 4 essais (Stalwart).

### 6.10. Arrêt et drainage

SIGINT / SIGTERM (`lyxal_host::shutdown`) → santé « stopping » (`/ready` répond 503 : le
répartiteur retire le nœud) → `runtime.stop_all()` :

1. chaque `mail.listener.*` cesse d'accepter (la socket reste liée jusqu'à la fin du worker),
   annule le jeton `shutdown` de ses sessions, attend la fin du `JoinSet` au plus
   `drain_seconds`, puis abandonne les tâches restantes (connexion fermée) ;
2. modules arrêtés, nœud retiré de `runtime_node` ;
3. port HTTP drainé (`GracefulShutdown`, comme `lyxal-server`).

Le protocole décide de son au revoir (`421` SMTP à la commande suivante, `* BYE` IMAP…) ; le
`UnavailableHandler` du lot 3 se termine aussitôt.

### 6.11. Santé et mesures

* Composants de l'hôte (`HealthRegistry`) : `groupware` (processus), `database`, `http`.
* `MailListenersHealthCheck` (`ModuleHealthCheck` de `lyxal_mail`) : « sain » si toutes les
  écoutes tournent ; « dégradé » si le dernier rechargement de certificat a échoué, si le
  budget mémoire dépasse 90 % ou si une écoute est à plus de 90 % de son plafond ; « malade » est
  porté par la supervision des workers `Required`.
* `/metrics` (JSON, comme `lyxal-server`) : par écoute, connexions acceptées, actives, refusées
  par raison, échecs de poignée de main, en-têtes PROXY refusés ; budget mémoire utilisé ;
  rechargements de certificats réussis et échoués. Aucune adresse IP.
* `/live`, `/ready`, `/health` : ceux de `lyxal_host` (même contrat que `lyxal-server`).

### 6.12. Journal sans donnée personnelle (G13)

* Niveau `info` et au-dessus : écoute démarrée / arrêtée (adresse locale, protocole, mode TLS),
  refus (raison, **réseau masqué** : IPv4 `/24`, IPv6 `/48`), poignée de main échouée
  (catégorie d'erreur, réseau masqué), certificat rechargé (noms couverts, empreinte du
  certificat, jamais la clé).
* Adresse complète seulement au niveau `debug` **et** si `observability.log_client_ip = "full"`
  (défaut `"network"`).
* Jamais : adresse e-mail, identifiant, mot de passe, contenu, nom SNI d'un client refusé avant
  TLS, octets reçus.
* Masquage par `lyxal_host::net::log_network` (Rust) : le journal ne peut pas appeler
  `fn::security_redact_ip` à chaque ligne ; même règle de masque, notée comme telle.

### 6.13. DNS

Non construit au lot 3 (E2, G12). Choix arrêté pour le lot 5 : `hickory-resolver` 0.26 (déjà
dans l'arbre, celui de `mail-auth`), configuration système par défaut, une seule instance par
nœud, faux résolveur dans les tests.

## 7. Configuration

Fichiers `apps/lyxal-groupware/config/{default,development,production}.toml`, choisis par
`LYXAL_ENV`, puis variables `LYXAL_GROUPWARE__*` (G5) ; `deny_unknown_fields` partout ; mots de
passe de la base par variable d'environnement seulement. Exemple (`production.toml`) :

```toml
[application]
name = "Lyxal Groupware"
environment = "production"

[http]                       # santé et mesures (plus tard : DAV, JMAP)
bind = "127.0.0.1:8090"
graceful_shutdown_seconds = 30
trusted_proxies = []

[database]                   # même base que lyxal-server
endpoint = "wss://db.interne:8000"
namespace = "lyxal"
database = "system"
connect_timeout_seconds = 15

[runtime]
module_install_timeout_seconds = 120
module_start_timeout_seconds = 30
module_stop_timeout_seconds = 45

[tls]
default = { certificate = "/etc/lyxal/tls/mail.pem", private_key = "/etc/lyxal/tls/mail.key" }
reload_interval_seconds = 60
handshake_timeout_seconds = 30
# [[tls.certificates]]
# names = ["mail.exemple.fr", "imap.exemple.fr"]
# certificate = "…" ; private_key = "…"

[limits]
memory_budget_bytes = 536870912
connection_base_bytes = 65536
connections_per_network = [30, 90, 270]
connections_per_minute = [300, 900, 2700]
max_tracked_networks = 100000
deny_networks = []
allow_networks = []
exempt_networks = []
drain_seconds = 30

[[listeners]]
id = "smtp"
protocol = "smtp"
bind = ["0.0.0.0:25", "[::]:25"]
tls = "starttls"

[[listeners]]
id = "submissions"
protocol = "submission"
bind = ["[::]:465"]
tls = "implicit"

[[listeners]]
id = "imaps"
protocol = "imap"
bind = ["[::]:993"]
tls = "implicit"
proxy_networks = ["10.0.0.0/8"]

[observability]
log_filter = "info"
json_logs = true
log_client_ip = "network"
```

`default.toml` : port HTTP `127.0.0.1:8090`, **aucune écoute de courrier** ; `development.toml`
: écoutes sur `127.0.0.1` et ports non privilégiés (2525, 2587, 2465, 1143, 1993, 1110, 1995,
4190) avec un certificat de développement à fournir.

Validation au démarrage (`GROUPWARE_CONFIGURATION_INVALID`, message précis au journal) :
identifiants d'écoute uniques (minuscules, chiffres, `_`, 32 caractères au plus) ; aucune
adresse liée deux fois ; `protocol` / `tls` cohérents (§6.4) ; certificat présent si une écoute
TLS existe ; réseaux lisibles (`IpNetwork`) ; bornes du §6.7 à §6.9 ; `drain_seconds` <
`module_stop_timeout_seconds`.

## 8. Standards Lyxal

| Sujet | Au lot 3 |
| :--- | :--- |
| Tables, fonctions `fn::mail_*`, `$params`, `COMMENT`, `*_WRITE_FORBIDDEN` | **Aucune** (E3, E5) ; la première table de `lyxal_mail` vient au lot 4, la liste de blocage au lot 5 |
| `lyxal_core` | Aucun appel (aucune donnée en base) ; voir le bilan en tête |
| `XxxParams` / `XxxResult`, `store.call_fn` | Sans objet (aucune fonction SurrealQL) |
| Codes d'erreurs | 7 codes `GROUPWARE_*` en master data (`apps/lyxal-groupware/error/groupware.surql`, forme `IF !record::exists(...) THEN (CREATE ...) END;`, traductions fr / en), contrôlés contre le catalogue Rust par un test, comme `SERVER_*` : `GROUPWARE_CONFIGURATION_INVALID`, `_DATABASE_UNAVAILABLE`, `_MODULE_INSTALL_FAILED`, `_BIND_FAILED`, `_TLS_CERTIFICATE_INVALID`, `_SHUTDOWN_SIGNAL_FAILED`, `_TELEMETRY_INIT_FAILED`. Aucun code `MAIL_*` : les erreurs du transport (`NetError`) restent internes, jamais renvoyées à un client ni écrites en base |
| Manifeste de l'hôte | `apps/lyxal-groupware/manifest.toml` : `id = "lyxal_groupware"`, dépendance `lyxal_error`, `error_definitions = ["error/groupware.surql"]`, aucun seed (aucun droit, aucune tâche au lot 3) |
| Événements | Aucun émis, aucun consommé ; moteur d'événements de l'hôte actif sans abonnement (G4) |
| Permissions | Aucune route protégée ; `/health` et `/metrics` sans authentification, comme `lyxal-server` : le port HTTP se lie par défaut à `127.0.0.1` |
| Workers | `LyxalWorker` seulement, `CancellationToken` respecté, sessions dans un `JoinSet` |
| Erreurs silencieuses | Erreurs d'acceptation, de poignée de main, d'en-tête PROXY, de rechargement : comptées et journalisées ; aucune transformée en succès |
| `panic!` / `unwrap` | Interdits hors tests (`#![deny(clippy::unwrap_used, clippy::expect_used)]`, comme `lyxal-server`) ; `build.rs` excepté (échec de compilation voulu) |
| Zéro dette (§0) | Code extrait de `lyxal-server` supprimé de `lyxal-server` (pas d'alias) ; versions `0.1.0` ; pas de `CHANGELOG.md` ; ce plan supprimé une fois exécuté |

## 9. Cryptographie

**Aucune extension de `lyxal_crypto` n'est demandée.** Utilisé : `tls_server_config`,
`TlsCertificateStore`, `TlsCertifiedKey::from_pem`, `TlsServerOptions` (ALPN, version minimale),
`SecretBytes`, `hash::blake3`. `tokio-rustls` dans l'hôte seulement (règle 10, garde-fou C12
qui le permet déjà aux paquets `apps/*`) ; jamais `ServerConfig::builder()`. `lyxal_mail` et
`lyxal_host` ne dépendent d'aucune crate cryptographique.

À signaler pour plus tard, sans demande au lot 3 : lecture des dates d'un certificat (alerte
d'expiration) et agrafage OCSP (lot 13, P6 g) ; TLS sortant (lot 6, C8).

## 10. Tests

* **Unitaires `lyxal_mail::net`** : limiteur par réseau (cas de `ratelimit_test.go` de Mox
  transposés : fenêtres, trois niveaux, `release`, IPv4 et IPv6, IPv4 transportée en IPv6) ;
  borne des réseaux suivis ; plafond (`InFlight` rendu à la libération, y compris sur
  annulation) ; budget mémoire (pas de 64 Kio, plancher par classe, portée annulée, libération)
  avec `proptest` (déjà en dépendance de test du dépôt) : la somme réservée ne dépasse jamais le
  budget ; lignes de refus (format exact, CRLF, aucune donnée variable).
* **Unitaires `lyxal-groupware`** : validation de la configuration (chaque refus du §7) ;
  masquage des adresses pour le journal ; catalogue `GROUPWARE_*` = `error/groupware.surql`.
* **Intégration avec de vraies sockets** (`127.0.0.1:0`, client `tokio` de test) :
  * acceptation et refus poli par protocole ; plafond d'écoute ; connexions ouvertes et cadence
    par réseau (refus `421 4.7.0` en SMTP) ; `exempt_networks` ; `deny_networks` /
    `allow_networks` ; budget mémoire épuisé ;
  * TLS implicite (client `rustls` de test, certificats d'essai des fixtures de `lyxal_crypto`
    ou générés par `openssl`, commandes notées) : TLS 1.2 et 1.3, SNI et certificat par défaut,
    ALPN négocié et ALPN étranger refusé, poignée de main hors délai fermée ;
  * STARTTLS par un **protocole d'essai** des tests (`STARTTLS` → `220` → mise à niveau →
    `TlsState::Upgraded`) ; données envoyées à la suite de `STARTTLS` dans le même paquet →
    `PipelinedBeforeTls` et fermeture ; `start_tls` sur une écoute `none` refusé ;
  * PROXY v1 et v2 depuis un réseau de confiance (adresse vue = adresse de l'en-tête, limites
    appliquées à elle) ; en-tête absent ou hors délai → fermeture ; en-tête envoyé depuis un
    réseau non déclaré → traité comme des données (jamais lu comme adresse) ;
  * rechargement à chaud : fichiers remplacés → nouvelle poignée de main avec le nouveau
    certificat, connexion ouverte inchangée ; fichier invalide → ancien gardé, sonde
    « dégradé », puis retour à « sain » ; clé lisible par les autres refusée ;
  * arrêt : session d'essai ouverte, `stop_all` → jeton annulé, plus aucune acceptation, fin
    dans le délai de drainage ; session qui ignore le jeton → abandonnée au délai ;
  * supervision : écoute dont la boucle échoue → redémarrée sur la même socket ; port déjà pris
    au démarrage → `GROUPWARE_BIND_FAILED`, rien n'est installé ;
  * journal : capture `tracing` d'un refus au niveau `info` sans adresse complète.
* **Deux hôtes sur une base** (`tests/it/two_hosts.rs`, G16) : `lyxal-server` réel (bibliothèque,
  dépendance de test) et `lyxal-groupware` sur la même base embarquée : socle installé une fois
  (même empreinte), `lyxal_mail` installé par `lyxal-groupware` seulement ; deux nœuds de deux
  hôtes dans `runtime_node` et dans `/api/v1/system/modules` de `lyxal-server` ; baux
  `event_stream_lease:lyxal_server` et `event_stream_lease:lyxal_groupware` distincts ;
  réconciliation stricte de `lyxal-server` : `lyxal_mail` dans `foreign_modules`, aucune
  action ; arrêt de `lyxal-groupware` → `lyxal-server` reste sain, nœud retiré ; redémarrage →
  aucun hook `install` rejoué. Même scénario sur un serveur SurrealDB 3.3.4 réel (`ws://`),
  test ignoré par défaut, ajouté à la liste nommée de `scripts/ci/test_all.sh`.
* **Bout en bout du binaire** : démarrage avec une configuration de test, `/live` `/ready`
  `/health` (composants et module `lyxal_mail`), `/metrics`.
* **Non-régression `lyxal-server`** (3a) : suite existante inchangée.
* **Fuzzing** : aucune cible au lot 3 (le seul analyseur, l'en-tête PROXY, est celui de
  `proxy-header`) ; cibles des analyseurs de protocole au lot 21 (P10).
* `cargo clippy --all-targets --all-features -D warnings` sur les trois nouveaux paquets ;
  `scripts/ci/ci_local.sh` complet avant chaque fusion.

## 11. CI et contrôles

* `Cargo.toml` (racine) : membres `crates/lyxal_host`, `crates/lyxal_mail`,
  `apps/lyxal-groupware` ; `[workspace.dependencies]` : `lyxal_host`, `lyxal_mail`. Les jobs
  existants (formatage, clippy par paquet, tests du workspace) les prennent sans changement.
* `deny.toml` : exceptions `AGPL-3.0-only` **décommentées** pour `lyxal_mail` et
  `lyxal-groupware` (prévu au lot 0) ; `proxy-header` passe par la licence MIT déjà permise.
* `scripts/ci/check_crypto_dependencies.py` : inchangé (constat : `tokio-rustls` déjà permis
  aux `apps/*`) ; vérifié par son passage.
* `scripts/ci/test_all.sh` : nom exact du test à deux hôtes sur serveur réel ajouté à la liste
  des tests ignorés lancés.
* Nouveau contrôle proposé (petit, dans le job « Licences et sources ») : aucun paquet du
  workspace sous `MIT OR Apache-2.0` ne dépend (même en développement) d'un paquet
  `AGPL-3.0-only` — protège la règle P3 (`lyxal-server` ne lie aucun crate AGPL) au-delà de la
  relecture ; lecture de `cargo metadata`, ≈ 60 lignes de Python (G16).
* `scripts/ci/test_lyxal_modules.py` : rien à faire (pas de `tests/*.test.surql` dans
  `lyxal_mail` au lot 3).

## 12. Documents

| Document | Changement |
| :--- | :--- |
| `apps/lyxal-groupware/README.md`, `ROADMAP.md`, `SOURCES.md` (nouveaux) | Rôle, démarrage, configuration, écoutes, limites, TLS, PROXY, santé, exploitation (ports privilégiés, G14), limites connues (compteurs par nœud) ; feuille de route (protocoles par lot, essais réels) ; provenance (Stalwart `listen.rs`, `listener.rs`, `mod.rs` : parties portées, commit, licence) |
| `apps/lyxal-groupware/docs/PRODUCTION-CHECKLIST.md` (nouveau, court) | Ports, pare-feu, certificat et droits du fichier de clé, base partagée et même commit que `lyxal-server`, `LYXAL_GROUPWARE__*` |
| `crates/lyxal_host/README.md`, `ROADMAP.md` (nouveaux) | Contenu, règle « jamais de code porté AGPL / GPL » |
| `crates/lyxal_mail/README.md`, `ROADMAP.md`, `SOURCES.md` | « État : squelette » (contrat réseau, limites, budget) ; lot 3 retiré de la feuille de route ; prérequis « correctifs du runtime » notés faits ; `SOURCES.md` : Stalwart `limiter.rs`, `memory.rs` ; Mox `ratelimit.go` (MIT) |
| `apps/lyxal-server/README.md` | Code commun dans `lyxal_host` |
| `.agents/AGENTS.md` §5.8.5 | Liste des hôtes (`lyxal_server`, `lyxal_groupware`) ; préfixe des erreurs de l'hôte : celui de son nom (`SERVER_`, `GROUPWARE_`) ; code commun dans `lyxal_host` ; écoutes non HTTP supervisées par `LyxalWorker` |
| `.agents/AGENTS.md` §6 | `lyxal-groupware` sans « à créer » ; `lyxal_host` sous « UI / Process Host » ; `lyxal_mail` : « squelette (lot 3) » |
| `docs/14-roadmap/ROADMAP_NOYAU.md` | Rang 1 (`apps/lyxal-groupware`) retiré ; rang 2 : squelette créé |
| `crates/lyxal_runtime/ROADMAP.md` | Point « création de `apps/lyxal-groupware` » retiré |
| `implementation_plan.md` (racine) | Lot 3 noté réalisé ; écarts E1, E2 reportés au §5 (lot 5 : DNS) |

Ce plan est supprimé une fois exécuté (§0.4 de `AGENTS.md`).

## 13. Fichiers

`crates/lyxal_host/` (3a) : `Cargo.toml`, `src/{lib.rs, error.rs, config.rs, database.rs,
telemetry.rs, shutdown.rs, health.rs, net.rs, metrics.rs, http.rs, modules.rs, build.rs}`,
`README.md`, `ROADMAP.md`.

`apps/lyxal-server/` (3a) : `Cargo.toml`, `build.rs`, `src/{lib.rs, bootstrap.rs, config.rs,
error.rs, runtime.rs, cli.rs, context.rs, http/handlers.rs, http/router.rs, modules/mod.rs}` ;
suppression de `src/{database.rs, health.rs, telemetry.rs, shutdown.rs, net.rs, serve.rs,
metrics.rs}` ; imports des tests.

`crates/lyxal_mail/` (3b) : `Cargo.toml`, `manifest.toml`, `src/lib.rs`,
`src/net/{mod.rs, session.rs, refusal.rs, limit.rs, ratelimit.rs, memory.rs}`, `LICENSES/`,
documents (§12).

`apps/lyxal-groupware/` (3b, 3c) : `Cargo.toml`, `build.rs`, `manifest.toml`,
`error/groupware.surql`, `config/{default,development,production}.toml`, `Dockerfile`,
`src/{main.rs, lib.rs, bootstrap.rs, config.rs, error.rs, runtime.rs, modules.rs, health.rs,
http.rs}`, `src/net/{mod.rs, bind.rs, listener.rs, accept.rs, tls.rs, certificates.rs,
proxy.rs, metrics.rs}`, `tests/it/{main.rs, config.rs, listeners.rs, limits.rs, tls.rs,
starttls.rs, proxy.rs, reload.rs, shutdown.rs, two_hosts.rs, binary.rs}`, `tests/fixtures/`
(certificats d'essai et leurs commandes), documents (§12).

Ailleurs : `Cargo.toml`, `Cargo.lock`, `deny.toml`, `scripts/ci/test_all.sh`, contrôle P3 du
§11 (`scripts/ci/check_agpl_isolation.py`, si G16 validée), `.github/workflows/ci.yml` (une
ligne), `.agents/AGENTS.md`, documents du §12.

## 14. Taille et découpage

| Demande de fusion | Contenu | Rust | Tests | Autres | Total |
| :--- | :--- | -: | -: | -: | -: |
| **3a** | `lyxal_host` (extraction) et `lyxal-server` adapté | +1 250 / −1 100 | 350 (déplacés) | 100 | ≈ 1 600 lignes touchées, ≈ 300 nettes |
| **3b** | `lyxal_mail::net` ; hôte : démarrage, configuration, écoutes, acceptation, limites, budget, santé, erreurs, deux hôtes | 2 300 (dont ≈ 650 portées ou transposées) | 1 500 | 600 (SurrealQL des erreurs, configuration, documents) | ≈ 4 400 |
| **3c** | TLS implicite, STARTTLS, certificats et rechargement, PROXY | 700 | 900 | 150 | ≈ 1 750 |

**Taille estimée : M haut** (≈ 6 000 lignes nouvelles, tests compris, hors lignes déplacées).
3a peut être relue et fusionnée seule ; 3b donne un hôte utilisable sans TLS (écoutes `none`
seulement : la configuration refuse `starttls` / `implicit` tant que 3c n'est pas fusionnée) ;
3c complète.

## 15. Décisions du CTO

| N° | Question | Proposition |
| :- | :--- | :--- |
| **G1** | Comment le second hôte réutilise-t-il le démarrage de `lyxal-server` ? | **Extraire le code générique dans un nouveau crate `lyxal_host`** (licence `MIT OR Apache-2.0`, code Lyxal seulement), utilisé par les deux hôtes ; `lyxal-server` est adapté sans changer son comportement. Autres choix : recopier ≈ 1 000 lignes (deux endroits à corriger à chaque faille, contraire au §5.1) ; faire dépendre `lyxal-groupware` du binaire `lyxal-server` (il embarquerait toutes ses routes et tous ses modules). |
| **G2** | Où vit le code réseau ? | **Les écoutes, le TLS et le PROXY dans l'hôte** (seul autorisé à utiliser `tokio-rustls`) ; **le contrat des sessions, les limites et le budget mémoire dans `lyxal_mail::net`**, que les protocoles (lots 5 à 10) utiliseront. Autre choix : un crate `lyxal_net` à part (un septième élément AGPL à suivre, et une exception au garde-fou TLS s'il fait la poignée de main). |
| **G3** | Que répondent les ports du courrier tant qu'aucun protocole n'existe ? | **Un refus poli et standard** (« service indisponible, réessayez plus tard ») : l'exploitant peut déjà vérifier pare-feu, certificat et limites, et les serveurs qui écriraient au port 25 réessaieront plus tard. Ce même code sert ensuite aux refus pour surcharge et à l'arrêt. Autre choix : interdire toute écoute de courrier avant le lot 5 (seul le port de santé tourne ; la preuve des écoutes reste dans les tests). |
| **G4** | Quels modules l'hôte héberge-t-il au lot 3, et faut-il son moteur d'événements ? | **Le socle, `lyxal_event` et `lyxal_mail`**, avec **le moteur d'événements de l'hôte actif sans abonnement** : c'est exactement le risque « deux hôtes sur une base » du programme, prouvé dès maintenant et pas au lot 18. Les autres modules (`lyxal_auth`, `lyxal_storage`…) arrivent avec le lot qui en a besoin. |
| **G5** | Où se règlent les écoutes, et sous quel préfixe ? | **Dans les fichiers de configuration du nœud** (un port appartient à un processus), avec des variables **`LYXAL_GROUPWARE__*`**, distinctes de `LYXAL__*` de `lyxal-server` : sur une machine qui fait tourner les deux, un réglage de l'un ne s'applique jamais à l'autre par erreur. Autre choix : préfixe commun `LYXAL__` (base et journal réglés une fois, mais `LYXAL__HTTP__BIND` ambigu). |
| **G6** | Quels codes d'erreurs pour le nouvel hôte ? | **`GROUPWARE_*`** (7 codes, master data comme `SERVER_*`) ; la règle §5.8.5 devient « préfixe du nom de l'hôte ». `lyxal_host` renvoie des erreurs sans code, traduites par chaque hôte. Autre choix : des codes communs `HOST_*` dans `lyxal_host` (moins de définitions, mais renommage des codes `SERVER_*` existants). |
| **G7** | Quelles règles TLS par port ? | **Trois modes par écoute** : chiffré dès la connexion pour 465, 993, 995 (recommandé par la RFC 8314), STARTTLS pour 25, 587, 143, 110, 4190, sans chiffrement seulement pour la réception SMTP (port 25, où les autres serveurs ne chiffrent pas toujours) et le port de santé. Protection contre l'injection de commandes avant STARTTLS. Nom de protocole (ALPN) annoncé par écoute, ce qui bloque les attaques qui font passer une connexion d'un protocole vers un autre. L'interdiction des mots de passe en clair reste appliquée par chaque protocole (P8). |
| **G8** | Comment sont fournis et rechargés les certificats ? | **Fichiers PEM** (ceux de certbot, par exemple), plusieurs noms et un certificat par défaut ; **relecture toutes les 60 s** si le contenu a changé, remplacement sans couper les connexions ; un fichier invalide est ignoré (l'ancien reste, la santé passe à « dégradé ») ; clé lisible par d'autres utilisateurs refusée. Pas de signal `SIGHUP` (un seul mécanisme). Coffre-fort et certificats automatiques : lot 13. |
| **G9** | Faut-il gérer le PROXY protocol maintenant ? | **Oui**, v1 et v2, **uniquement** depuis les réseaux déclarés du répartiteur, où il est alors obligatoire ; bibliothèque `proxy-header` 0.1.3 (MIT, celle de Stalwart). Sans lui, derrière un répartiteur, toutes les connexions semblent venir d'une seule adresse : limites par IP inutiles, et au lot 5 contrôles SPF faux. Autre choix : le reporter (déploiement sans répartiteur imposé jusque-là). |
| **G10** | Quelles limites par adresse ? | **Le modèle de Mox** : on compte par adresse et aussi par petit et grand réseau voisin (un attaquant change facilement d'adresse dans son réseau), connexions ouvertes 30 / 90 / 270 et nouvelles connexions 300 / 900 / 2 700 par minute, plafond de 4 096 par écoute ; **compteurs en mémoire, par nœud** ; listes fixes d'adresses refusées, permises ou exemptées. Le **bannissement automatique** et la liste de blocage en base viennent au lot 5 (table de `lyxal_mail`), quand il existe des raisons de bannir. Limite connue : avec plusieurs nœuds, les limites s'additionnent. |
| **G11** | Quel budget mémoire ? | **Celui de Stalwart**, porté : un budget global (512 Mio par défaut), chaque connexion en réserve 64 Kio à l'arrivée, refus poli quand il est épuisé ; les protocoles réserveront davantage (gros messages). Protège le processus d'une saturation par connexions massives. |
| **G12** | Quel DNS, et quand ? | **`hickory-resolver` 0.26** (déjà dans le projet et utilisé par `mail-auth`), **construit au lot 5**, premier lot qui résout des noms. Le construire au lot 3 ferait un résolveur sans usage, ou un second résolveur à côté de celui de `mail-auth`. |
| **G13** | Que peut-on écrire au journal ? | **Jamais d'adresse e-mail, d'identifiant, de contenu ni de secret** ; l'adresse IP d'un client est **raccourcie à son réseau** (`/24` en IPv4, `/48` en IPv6) en temps normal ; l'adresse complète seulement en mode débogage, sur option explicite. Les mesures ne contiennent aucune adresse. |
| **G14** | Comment ouvrir les ports 25, 143, 993… sans être `root` ? | **Par une capacité du système** (`CAP_NET_BIND_SERVICE` donnée par systemd ou le conteneur), le programme tournant sous un compte sans droits ; pas de changement d'utilisateur dans le code (Stalwart le fait, mais c'est du code `unsafe` de plus et une étape qui peut échouer à moitié). Documenté dans le `README.md` et le `Dockerfile`. |
| **G15** | En combien de demandes de fusion ? | **Trois** : 3a (extraction, pur remaniement de `lyxal-server`), 3b (hôte, écoutes, limites, santé, deux hôtes), 3c (TLS, STARTTLS, PROXY, rechargement). |
| **G16** | Comment prouver la cohabitation avec `lyxal-server` et protéger la règle de licence ? | **Les essais de `lyxal-groupware` lancent le vrai `lyxal-server`** (dépendance de test, dans ce sens seulement : du code MIT dans un banc AGPL), sur base embarquée et sur un vrai serveur SurrealDB ; **et un petit contrôle de CI** refuse qu'un paquet `MIT OR Apache-2.0` dépende, même pour ses tests, d'un paquet AGPL (aujourd'hui seule la relecture le garantit). |

## 16. Risques

| Risque | Ce qu'il faut savoir | Réponse |
| :--- | :--- | :--- |
| Deux hôtes sur une base | Le correctif est fait et essayé avec un hôte d'essai ; c'est la première fois qu'un **vrai** second binaire le fait | Essais du §10 sur moteur embarqué et `ws://` ; même commit imposé aux deux binaires (sinon refus `RUNTIME_RELEASE_CHECKSUM_MISMATCH` et socle « dégradé ») — écrit dans la liste de mise en production |
| Remaniement de `lyxal-server` (3a) | Une erreur d'extraction touche l'hôte principal | Comportement constant, suite existante inchangée, demande de fusion séparée |
| Exposition des ports | Dès le lot 3, des ports publics reçoivent des balayages | Refus poli, limites, budget, délais dès l'acceptation ; `default.toml` sans écoute de courrier ; ne pas ouvrir le port 25 en production avant le lot 5 (`README.md`) |
| Injection avant STARTTLS | Des octets envoyés en clair avec `STARTTLS` exécutés après la mise à niveau | Refus imposé par le contrat (`pending_input` non vide → fermeture) ; test dédié |
| Limites par nœud | Avec N nœuds, un client a N fois les limites | Connu et documenté ; limites partagées en base à décider si les essais du lot 21 le demandent |
| Mémoire des compteurs par IP | Un balayage depuis des millions d'adresses ferait grossir les tables | Nombre de réseaux suivis borné (refus « surcharge » au-delà) ; fenêtres remises à zéro |
| Couplage à `rustls` et `tokio-rustls` | Une montée de `rustls` change aussi l'hôte | Versions alignées sur `lyxal_crypto` ; `tokio-rustls` sans fonctionnalité de fournisseur propre |
| Licence | Le binaire `lyxal-groupware` est sous AGPL en entier (P2) | Contrôle G16 ; `lyxal_host` sans code porté ; question de l'offre du code source (point ouvert) |
| Comportement d'un `ManifestModule` porteur de workers | `lyxal_mail` est un module sans Rust propre au runtime, mais ses écoutes sont des workers rattachés à lui | Vérifié au premier essai (§17) ; repli : une implémentation `LyxalModule` minimale de `lyxal_mail` dans l'hôte |

## 17. Faits non vérifiés

* Acceptation par le runtime d'un manifeste à `[resources]` vide et de workers rattachés à un
  `ManifestModule` (démarrés par `start_module_workers`) : lu, pas exécuté.
* API exacte de `proxy-header` 0.1.3 (`ProxiedStream::create_from_tokio`, en-tête `LOCAL`,
  dépendances) : lue dans l'usage de Stalwart, pas dans la bibliothèque.
* Comportement de `rustls` côté serveur quand le client annonce un ALPN que l'écoute ne connaît
  pas (refus attendu) ; identifiants ALPN enregistrés pour `imap`, `pop3`, `smtp`,
  `managesieve` (registre de l'IANA à revérifier).
* Fonctionnalités de `tokio-rustls` 0.26.4 sans fournisseur par défaut, avec les fonctionnalités
  `rustls` unifiées par Cargo.
* `SO_REUSEPORT` et repli IPv4 sous Windows et macOS (copié de Stalwart, essayé seulement sous
  Linux en CI).
* Constructeurs de `MessageAuthenticator` de `mail-auth` 0.16 (résolveur injectable ou non) :
  sans effet au lot 3, à trancher au lot 5.
* Réutilisation des certificats d'essai de `crates/lyxal_crypto/tests/fixtures` (noms couverts)
  par les tests de l'hôte.
* Numéros et sections de RFC cités (3207, 8314, 5321 §3.8, §4.2.3, §4.5.3.2, 3463, 9051, 1939,
  2449, 3206, 5804, 8996) et spécification du PROXY protocol (document de HAProxy) : de mémoire,
  à revérifier en écrivant les documents.
* Durée de compilation ajoutée par la dépendance de test vers `lyxal-server` (dossier `target`
  partagé : surtout l'édition des liens).

## 18. Points ouverts

* **Offre du code source (AGPL, article 13)** : les utilisateurs d'une version modifiée servie
  par le réseau doivent pouvoir obtenir son source. Le moyen (lien dans l'accueil des
  protocoles, page HTTP, documentation) relève du CTO (F2) ; rien n'est codé au lot 3.
* **Prérequis des lots suivants** (pas du lot 3) : un seul handler par type d'événement et par
  processus (`lyxal_event`) avant que `lyxal-groupware` porte deux consommateurs du même
  événement (lot 18 au plus tôt) ; files du planificateur réservées à un hôte avant les tâches
  `handler` du courrier (purges, lot 4 ou 5). À planifier avant ces lots.
* **Port HTTP public** : au lot 15, le DAV et JMAP seront servis par ce port ; il faudra alors
  séparer `/health` et `/metrics` (port interne) des routes publiques. Au lot 3, le port est
  local par défaut.
* **Limites partagées entre nœuds et bannissement** : modèle à décider au lot 5 (table de
  `lyxal_mail`, entrées validées par `fn::validation_ip` / `fn::validation_cidr`).
* **LMTP et sockets Unix** : non demandés ; à ouvrir si un besoin d'exploitation apparaît.

## 19. Checklist (§13)

* [ ] **Architecture** : écoutes et TLS dans l'hôte, contrat et limites dans `lyxal_mail`, code
  commun dans `lyxal_host` ; aucun cycle (§3.2) ; `lyxal-server` ne lie aucun crate AGPL.
* [ ] **Core** : aucune fonction appelée, aucune primitive dupliquée (configuration validée avant
  la base, comme `lyxal-server`) ; aucun besoin manquant.
* [ ] **SurrealQL** : seulement les définitions `GROUPWARE_*` (forme rejouable) ; aucune
  fonction, aucune table.
* [ ] **Rust** : aucun `panic!` ni `unwrap` hors tests et `build.rs` ; workers `LyxalWorker`,
  sessions en `JoinSet` ; aucun secret au journal (clé TLS en `SecretBytes`).
* [ ] **Erreurs** : 7 codes `GROUPWARE_*` en master data, contrôlés contre le catalogue Rust ;
  aucune erreur réseau masquée.
* [ ] **Événements** : sans objet ; moteur de l'hôte actif sans abonnement.
* [ ] **Cryptographie** : `lyxal_crypto` seul fabrique la configuration TLS ; `tokio-rustls`
  dans l'hôte seulement ; aucune extension demandée.
* [ ] **Zéro dette** (§0) : code extrait retiré de `lyxal-server` ; `UnavailableHandler` retiré au
  dernier protocole ; versions `0.1.0` ; `ROADMAP.md` tenues ; plan supprimé une fois exécuté.
* [ ] **Provenance** (F4, F5) : `SOURCES.md` de `lyxal_mail` et de `lyxal-groupware` ; en-têtes
  SPDX conservés ; aucune partie `LicenseRef-SEL` ; `lyxal_host` sans code porté ; exceptions
  `deny.toml` nommées.
* [ ] **Validation CTO** : écarts E1 à E7, décisions G1 à G16.

À valider par le CTO.
