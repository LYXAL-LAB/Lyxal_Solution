# `lyxal-groupware` — Hôte du courrier, des agendas et des contacts

Second binaire hôte de Lyxal OS (nom d'hôte fixe `lyxal_groupware`, égal à l'`id` de son
`manifest.toml`), à côté de `lyxal-server` sur la **même base** (`.agents/AGENTS.md` §5.8.5,
décision P3 du programme courrier). Il installe ou retrouve le socle, installe ses modules, se
déclare dans `runtime_node`, élit son propre chef des événements et ouvre les ports de courrier
configurés, chacun supervisé par le runtime.

Version `0.1.0` (régime pré-production, `.agents/AGENTS.md` §0). **Licence `AGPL-3.0-only`** :
seul binaire de Lyxal OS qui lie des crates AGPL (`lyxal_mail`) et porte du code de Stalwart
(provenance : [`SOURCES.md`](SOURCES.md)). Aucun paquet sous licence permissive ne dépend de lui
(contrôle `scripts/ci/check_agpl_isolation.py`).

**État : lot 3 du programme courrier, partie 3b.** Aucun protocole n'existe encore : chaque port
de courrier répond par un **refus poli et standard** (« service indisponible, réessayez plus
tard ») puis ferme. TLS implicite, STARTTLS, PROXY protocol et rechargement des certificats
arrivent avec la partie 3c ; d'ici là, seules des écoutes SMTP en clair sont permises. Feuille de
route : [`ROADMAP.md`](ROADMAP.md).

Le démarrage commun aux hôtes (configuration en couches, base et refus de l'accès anonyme,
socle sous bail, modules embarqués, santé, journal, arrêt) vient de
[`lyxal_host`](../../crates/lyxal_host/README.md) ; le contrat des sessions, les limites et le
budget mémoire de [`lyxal_mail::net`](../../crates/lyxal_mail/README.md).

---

## 1. Démarrage

1. Configuration (`config/default.toml`, `config/<LYXAL_ENV>.toml`, variables
   `LYXAL_GROUPWARE__*`), validée en entier ; journal.
2. Base : `connect_database` (même refus d'une base ouverte aux invités que `lyxal-server`).
3. **Liaison de tous les ports avant toute installation** : chaque adresse de chaque écoute,
   puis le port HTTP. Un port indisponible arrête le démarrage (`GROUPWARE_BIND_FAILED`) :
   rien n'est installé.
4. Runtime de l'hôte `lyxal_groupware` (nœud tiré au sort) : socle sous bail
   (`lyxal_core`, `lyxal_error`, schéma du runtime ; même empreinte que `lyxal-server` quand les
   deux binaires viennent du même commit), définitions `GROUPWARE_*` ; moteur d'événements de
   l'hôte (bail `event_stream_lease:lyxal_groupware`, aucun abonnement) ; sonde du socle ;
   workers des écoutes et sonde de `lyxal_mail` ; `install_packages` ; `start_all`.
5. Port HTTP de santé ; attente de SIGINT ou SIGTERM.

Arrêt : santé « stopping » (`/ready` répond `503`, le répartiteur retire le nœud), puis
`stop_all` : chaque écoute cesse d'accepter, referme ses sockets, prévient ses sessions (jeton
`shutdown`), les attend au plus `limits.drain_seconds`, puis abandonne les restantes (connexion
fermée) ; modules arrêtés, nœud retiré de `runtime_node` ; enfin le port HTTP est drainé.

## 2. Modules hébergés

`build.rs` embarque (`lyxal_host::build::embed_modules`) : `lyxal_core`, `lyxal_error`,
`lyxal_event`, `lyxal_mail` (écart E6 : les autres modules arrivent avec le premier lot qui s'en
sert). Tous sont portés par un `ManifestModule` ; les écoutes sont des workers rattachés à
`lyxal_mail`. Un module installé par `lyxal-server` est trouvé installé (aucun hook `install`
rejoué) ; `lyxal_mail` n'est installé que par cet hôte et apparaît dans
`ReconciliationPlan::foreign_modules` de `lyxal-server`.

## 3. Configuration

Fichiers `config/{default,development,production}.toml`, choisis par `LYXAL_ENV`, puis variables
`LYXAL_GROUPWARE__<SECTION>__<CLÉ>` (décision G5 : un réglage de `lyxal-server`, préfixe
`LYXAL__`, ne s'applique jamais ici). Clés inconnues refusées partout. Identifiants de la base
par `LYXAL_GROUPWARE__DATABASE__USERNAME` et `LYXAL_GROUPWARE__DATABASE__PASSWORD` seulement
(un mot de passe dans un fichier arrête le démarrage).

| Section | Réglages |
| :--- | :--- |
| `application` | `name`, `environment` |
| `http` | `bind` (port de santé, `127.0.0.1:8090` par défaut : les routes ne demandent aucun jeton), `graceful_shutdown_seconds` |
| `database` | `endpoint`, `namespace`, `database`, `connect_timeout_seconds` (même base que `lyxal-server`) |
| `runtime` | délais d'installation, de démarrage et d'arrêt d'un module |
| `limits` | voir §5 |
| `[[listeners]]` | `id` (minuscules, chiffres, `_`, 32 caractères au plus, unique), `protocol` (`smtp`, `submission`, `imap`, `pop3`, `managesieve`), `bind` (une ou plusieurs adresses), `tls` (`none` ; `starttls` et `implicit` en 3c), `max_connections` (facultatif) |
| `observability` | `log_filter`, `json_logs`, `include_target`, `include_thread_ids`, `log_client_ip` (`network` par défaut, ou `full`) |

Listes dans l'environnement (valeurs séparées par `,`) : `LIMITS__CONNECTIONS_PER_NETWORK`,
`LIMITS__CONNECTIONS_PER_MINUTE`, `LIMITS__DENY_NETWORKS`, `LIMITS__ALLOW_NETWORKS`,
`LIMITS__EXEMPT_NETWORKS`. Les écoutes se règlent dans les fichiers.

Validation au démarrage (`GROUPWARE_CONFIGURATION_INVALID`, réglage fautif nommé au journal) :
identifiants d'écoute uniques et bien formés ; aucune adresse liée deux fois (port HTTP compris) ;
au moins une adresse par écoute ; `tls = "none"` seulement, et seulement pour `smtp` (décision
G7 : réception des autres serveurs, où STARTTLS reste facultatif) — les autres protocoles
attendent le TLS (3c) ; réseaux lisibles ; bornes ci-dessous ; `drain_seconds` inférieur à
`runtime.module_stop_timeout_seconds`.

`default.toml` : port HTTP local, **aucune écoute de courrier**. `development.toml` : réception
SMTP sur `127.0.0.1:2525`. `production.toml` : aucune écoute (le port 25 ne s'ouvre qu'au lot 5,
avec la réception SMTP).

## 4. Écoutes et acceptation

Un worker `lyxal_mail:mail.listener.<id>` par écoute : criticité `Required` (une écoute arrêtée
rend `lyxal_mail` « malade »), redémarrage sur échec (5 essais, recul exponentiel), délai d'arrêt
= drainage + 5 s. Les sockets sont liées au démarrage et gardées à travers les redémarrages du
worker (aucune fenêtre où le port serait libre). Options : `SO_REUSEADDR`, file d'attente de
1 024, `IPV6_V6ONLY` quand la même configuration lie aussi l'IPv4 sur le même port, repli sur
`0.0.0.0` si l'IPv6 manque ; par connexion `TCP_NODELAY` et keepalive (300 s, 30 s, 4 essais).
`SO_REUSEPORT` n'est pas posé : deux processus ne se partagent jamais un port sans le savoir.
Erreurs d'acceptation passagères ignorées ; autres erreurs comptées, journalisées, recul de
5 ms à 1 s. Chaque connexion est une tâche du `JoinSet` du worker (aucun `tokio::spawn` libre).

Pipeline, dans l'ordre :

| Étape | Contrôle | Échec |
| :- | :--- | :--- |
| 1 | Plafond de l'écoute | fermeture immédiate, sans écriture |
| 2 | `deny_networks`, puis `allow_networks` si non vide | refus `blocked` |
| 3 | Sauf `exempt_networks` : connexions nouvelles par minute, puis connexions ouvertes, par réseau | refus `rate_limited` / `too_many_connections` |
| 4 | Budget mémoire : réservation de base de la connexion | refus `memory_budget` |
| 5 | Remise à la session du protocole (au lot 3 : refus « service indisponible ») | — |

Un refus écrit la ligne du protocole en clair (délai de 5 s) puis ferme : SMTP `421 4.7.0`
(limites, blocage) ou `421 4.3.2` (service indisponible, mémoire), IMAP `* BYE`, POP3 `-ERR`,
ManageSieve `BYE`. Les lignes ne contiennent ni l'adresse du client ni le détail interne. Places,
compteurs et réservations sont rendus à la fin de la connexion, quelle qu'en soit l'issue.
Écriture bloquée (client qui ne lit plus) : connexion fermée après 60 s. Délais d'inactivité
transmis aux sessions : SMTP 300 s, IMAP 1 800 s, POP3 600 s, ManageSieve 300 s.

## 5. Limites (décisions G10, G11)

| Réglage | Défaut | Bornes |
| :--- | -: | :--- |
| `max_connections` (par écoute, surchargeable par écoute) | 4 096 | 1 à 65 536 |
| `connections_per_network` (ouvertes : `/32`, `/26`, `/21` ; IPv6 `/64`, `/48`, `/32`) | 30 / 90 / 270 | 1 à 100 000 |
| `connections_per_minute` (mêmes niveaux) | 300 / 900 / 2 700 | 1 à 1 000 000 |
| `max_tracked_networks` (par fenêtre ; au-delà, refus) | 100 000 | 1 000 à 10 000 000 |
| `memory_budget_bytes` | 512 Mio | 64 Mio au moins |
| `connection_base_bytes` | 64 Kio | 4 Kio à 16 Mio |
| `drain_seconds` | 30 | 1 à 300 |

Le budget a deux classes (réception SMTP, lecture), chacune gardant un quart du budget : les
connexions réservent dans la classe « lecture », soit trois quarts du budget au plus.

**Limite connue** : les compteurs sont en mémoire, **par nœud**, partagés par les écoutes du
nœud. Avec plusieurs nœuds derrière un répartiteur, les limites s'additionnent. Bannissement
automatique et liste de blocage en base : lot 5.

## 6. Santé, mesures, journal

* Port HTTP (`127.0.0.1:8090` par défaut) : `/live` (`204`), `/ready` (`204`, `503` au démarrage
  et à l'arrêt), `/health` (`host` : composants `groupware`, `database`, `http` ; `modules` :
  sondes du runtime, sans message interne ; `503` si un module est en panne) — mêmes routes que
  `lyxal-server`, par `lyxal_host` ; `/metrics` (JSON) : par écoute, connexions servies,
  ouvertes, plafond, refus par raison, sessions en échec, erreurs d'acceptation ; budget mémoire
  utilisé ; réseaux suivis. Aucune adresse IP.
* Sonde `MailListenersHealthCheck` (`lyxal_mail`) : « dégradé » au-delà de 90 % du budget mémoire
  ou du plafond d'une écoute ; « malade » porté par la supervision des workers.
* Journal (décision G13) : écoute démarrée et arrêtée (adresses locales, protocole, mode TLS),
  refus (raison et **réseau masqué** : IPv4 `/24`, IPv6 `/48`, par `lyxal_host::net::log_network`).
  L'adresse complète n'est écrite qu'au niveau `debug` et avec `log_client_ip = "full"`. Jamais
  d'adresse e-mail, d'identifiant, de contenu ni d'octets reçus.

## 7. Erreurs (`error/groupware.surql`)

Master data rejouable (`IF !record::exists(...) THEN (CREATE ...) END;`), traductions fr / en,
installées avec le socle (hors empreinte du socle), contrôlées contre `src/error.rs` par un test :

| Code | Cas |
| :--- | :--- |
| `GROUPWARE_CONFIGURATION_INVALID` | Configuration absente, illisible ou incohérente |
| `GROUPWARE_DATABASE_UNAVAILABLE` | Base injoignable ou sonde en échec |
| `GROUPWARE_MODULE_INSTALL_FAILED` | Installation d'un module hébergé impossible |
| `GROUPWARE_BIND_FAILED` | Port de courrier ou port HTTP indisponible |
| `GROUPWARE_SHUTDOWN_SIGNAL_FAILED` | Signal d'arrêt indisponible |
| `GROUPWARE_TELEMETRY_INIT_FAILED` | Journal non initialisé |

Une erreur du runtime garde son code `RUNTIME_*`. Les erreurs du transport (`NetError` de
`lyxal_mail`) restent internes : jamais renvoyées à un client ni écrites en base.
`GROUPWARE_TLS_CERTIFICATE_INVALID` arrive avec les certificats (3c).

## 8. Exploitation

* **Ports privilégiés** (25, 143, 993…, décision G14) : le programme tourne sous un compte sans
  droits, avec la capacité `CAP_NET_BIND_SERVICE` donnée par systemd
  (`AmbientCapabilities=CAP_NET_BIND_SERVICE`) ou par le conteneur ; aucun changement
  d'utilisateur dans le code.
* **Même commit que `lyxal-server`** : deux binaires d'un autre commit installeraient des
  releases différentes sous le même numéro (`RUNTIME_RELEASE_CHECKSUM_MISMATCH`) et l'un des deux
  verrait le socle « dégradé ».
* Liste de mise en production : [`docs/PRODUCTION-CHECKLIST.md`](docs/PRODUCTION-CHECKLIST.md).
* Image : `Dockerfile` (compte `lyxal` sans droits, port de santé 8090 ; ports de courrier à
  publier selon la configuration).

## 9. Vérification

```bash
cargo test -p lyxal-groupware
# Essai à deux hôtes sur un serveur SurrealDB réel (lancé par scripts/ci/test_all.sh)
cargo test -p lyxal-groupware -- --ignored --exact two_hosts::groupware_beside_lyxal_server_on_a_remote_server
```

Essais : configuration (fichiers livrés, préfixe `LYXAL_GROUPWARE__`, chaque refus) ; écoutes
sur de vraies sockets (refus poli par protocole, plafond, limites par réseau partagées entre
écoutes, cadence, réseaux exemptés, listes, budget épuisé, journal sans adresse complète) ;
cycle de vie complet (santé, mesures, arrêt avec drainage, session qui ignore l'arrêt abandonnée
au délai, port déjà pris) ; **deux hôtes** avec le vrai `lyxal-server` (décision G16) sur base
embarquée et sur `ws://` ; bout en bout du binaire (démarrage, routes HTTP, refus SMTP, arrêt par
SIGTERM).
