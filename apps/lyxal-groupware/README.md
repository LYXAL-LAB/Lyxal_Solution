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

**État : lots 3 (hôte et socle réseau), 4 (socle courrier) et 5 (réception SMTP) du programme
courrier réalisés.** L'hôte porte les services du courrier (réception SMTP, dépôt d'un message
chiffré au repos, lecture, maintenance exécutée par `lyxal_scheduler`) et les modules dont ils ont
besoin (coffre-fort, stockage, planificateur, §2). Les écoutes `smtp` sont servies par la
réception SMTP de `lyxal_mail` (§4 bis) ; les autres protocoles n'existent pas encore : leurs
ports répondent par un **refus poli et standard** (« service indisponible, réessayez plus
tard ») puis ferment, en clair ou après la poignée de main TLS selon l'écoute. L'hôte offre aux
protocoles le TLS implicite, la mise à niveau STARTTLS, le PROXY protocol, des certificats
rechargés à chaud, les limites, le budget mémoire et la liste de blocage de l'installation. Feuille de
route : [`ROADMAP.md`](ROADMAP.md).

Le démarrage commun aux hôtes (configuration en couches, base et refus de l'accès anonyme,
socle sous bail, modules embarqués, santé, journal, arrêt) vient de
[`lyxal_host`](../../crates/lyxal_host/README.md) ; le contrat des sessions, les limites et le
budget mémoire de [`lyxal_mail::net`](../../crates/lyxal_mail/README.md).

---

## 1. Démarrage

1. Configuration (`config/default.toml`, `config/<LYXAL_ENV>.toml`, variables
   `LYXAL_GROUPWARE__*`), validée en entier ; journal.
2. Base : `connect_database` (pool de `database.connections` connexions sous la session
   système, chacune sondée ; même refus d'une base ouverte aux invités que `lyxal-server`).
3. **Liaison de tous les ports avant toute installation** : chaque adresse de chaque écoute,
   puis le port HTTP. Un port indisponible arrête le démarrage (`GROUPWARE_BIND_FAILED`) :
   rien n'est installé. Puis chargement des certificats (§5) : un certificat illisible ou
   invalide arrête aussi le démarrage (`GROUPWARE_TLS_CERTIFICATE_INVALID`).
4. Runtime de l'hôte `lyxal_groupware` (nœud tiré au sort) : socle sous bail
   (`lyxal_core`, `lyxal_error`, schéma du runtime ; même empreinte que `lyxal-server` quand les
   deux binaires viennent du même commit), définitions `GROUPWARE_*` ; moteur d'événements de
   l'hôte (bail `event_stream_lease:lyxal_groupware`, aucun abonnement) ; sonde du socle ;
   services des modules hébergés (§2) : trousseau maître du coffre-fort et sa sonde, supports et
   antivirus du stockage et sa sonde, planificateur élu et sa sonde, handler de la tâche
   `mail.maintenance`, services du courrier ; workers des écoutes, worker `mail.tls_reload` et
   sonde de `lyxal_mail` (service du courrier, puis écoutes) ; `install_packages` ; **sans clé
   maîtresse du coffre-fort, refus de démarrer si un bucket chiffré existe dans la base**
   (`fn::storage_encrypted_bucket_exists`, `GROUPWARE_MASTER_KEY_MISSING` : rien n'est démarré,
   les ports liés sont refermés) ; seed de l'hôte (tâche `mail.maintenance` et sa permission),
   planification de la tâche si elle est absente, un exécuteur par file du planificateur ;
   `start_all`.
5. Port HTTP de santé ; attente de SIGINT ou SIGTERM.

Arrêt : santé « stopping » (`/ready` répond `503`, le répartiteur retire le nœud), puis
`stop_all` : chaque écoute cesse d'accepter, referme ses sockets, prévient ses sessions (jeton
`shutdown`), les attend au plus `limits.drain_seconds`, puis abandonne les restantes (connexion
fermée) ; modules arrêtés, nœud retiré de `runtime_node` ; enfin le port HTTP est drainé.

## 2. Modules hébergés

`build.rs` embarque (`lyxal_host::build::embed_modules`) : `lyxal_core`, `lyxal_error`,
`lyxal_event`, `lyxal_auth`, `lyxal_secrets`, `lyxal_storage`, `lyxal_scheduler` et `lyxal_mail`
(chaque module ajouté aux dépendances de `lyxal_mail` ou dont il a besoin est hébergé dans le
même lot, décision M13 ; les autres modules arrivent avec le premier lot qui s'en sert).
`lyxal_secrets`, `lyxal_storage`, `lyxal_scheduler` et `lyxal_mail` sont portés par leur
`LyxalModule` (`SecretsModule`, `StorageModule`, `SchedulerModule`, `MailModule`), les autres par
un `ManifestModule` ; aucun hook `install` n'écrit. Un module installé par `lyxal-server` est
trouvé installé (aucun hook `install` rejoué) ; `lyxal_mail` n'est installé que par cet hôte et
apparaît dans `ReconciliationPlan::foreign_modules` de `lyxal-server`.

Services (`src/services.rs`, rendus par `runtime::start` dans `Started::services`) :

| Module | Ce que l'hôte en fait |
| :--- | :--- |
| `lyxal_secrets` | Trousseau maître (clé active et, pendant une rotation, l'ancienne), clés « fichiers » des organisations (`FileKeys`, sans cache), sonde `SecretsHealthCheck` ; la maintenance du coffre-fort (rotation, rescellement) reste exécutée par `lyxal-server` |
| `lyxal_storage` | Supports (disque `default`, S3 nommés) et antivirus, service de stockage sur la session système avec les clés de fichiers, sonde `StorageHealthCheck` (fichier témoin sur chaque support) ; le nettoyage (octets des fichiers supprimés, rescellement) reste exécuté par `lyxal-server` |
| `lyxal_scheduler` | Planificateur élu pour toute la base (bail `leader` du runtime, partagé avec `lyxal-server`), un exécuteur par file, sonde ; registre des handlers avec celui de `mail.maintenance` : seul un nœud de cet hôte réserve cette tâche ; les tâches `handler` de `lyxal-server` ne sont jamais réservées ici |
| `lyxal_mail` | `MailIngest` (dépôt, bucket chiffré `lyxal-mail` de chaque organisation créé sur le support `mail.storage_backend`, sans événements `storage.object.*` : `emit_events` faux, décision S14), `MailContent` (lecture), `MailMaintenance` (tâche `mail.maintenance`, toutes les 10 minutes, chevauchement `skip`), `MailHealthCheck` avec l'hôte requis `lyxal_server` (`RequiredHost`, §9), composée avec la sonde des écoutes |

**Chiffrement obligatoire (décision M1).** Sans clé maîtresse du coffre-fort ou sans support de
stockage, l'hôte démarre sur une base sans bucket chiffré : la sonde de `lyxal_mail` est
« dégradée » (`MAIL_CONTENT_UNAVAILABLE`) et tout dépôt est refusé, à réessayer ; aucun message
n'est jamais rangé en clair. Dès qu'un bucket chiffré existe (le premier dépôt d'une organisation
en crée un), l'hôte refuse de démarrer sans clé maîtresse (`GROUPWARE_MASTER_KEY_MISSING`) :
les messages déjà rangés ne pourraient être ni lus ni complétés.

## 3. Configuration

Fichiers `config/{default,development,production}.toml`, choisis par `LYXAL_ENV`, puis variables
`LYXAL_GROUPWARE__<SECTION>__<CLÉ>` (décision G5 : un réglage de `lyxal-server`, préfixe
`LYXAL__`, ne s'applique jamais ici). Clés inconnues refusées partout. Identifiants de la base
par `LYXAL_GROUPWARE__DATABASE__USERNAME` et `LYXAL_GROUPWARE__DATABASE__PASSWORD` seulement ;
clés maîtresses du coffre-fort et clé secrète d'un support S3 aussi (une valeur dans un fichier
arrête le démarrage, sans être écrite au journal).

| Section | Réglages |
| :--- | :--- |
| `application` | `name`, `environment` |
| `http` | `bind` (port de santé, `127.0.0.1:8090` par défaut : les routes ne demandent aucun jeton), `graceful_shutdown_seconds`, `tls` (`false` par défaut ; `true` : TLS avec les certificats de `[tls]`, ALPN `h2` et `http/1.1`), `proxy_networks` (en-tête PROXY exigé depuis ces réseaux, §5.3) |
| `database` | `endpoint`, `namespace`, `database`, `connect_timeout_seconds` (même base que `lyxal-server`), `connections` (connexions de la session système : par défaut le nombre de cœurs, 16 au plus ; `0` refusé) |
| `runtime` | délais d'installation, de démarrage et d'arrêt d'un module |
| `limits` | voir §6 |
| `tls` | `default = { certificate, private_key }` (certificat par défaut), `[[tls.certificates]]` (`names`, `certificate`, `private_key`), `reload_interval_seconds` (60, de 5 à 86 400), `handshake_timeout_seconds` (30, de 1 à 300) ; voir §5 |
| `[[listeners]]` | `id` (minuscules, chiffres, `_`, 32 caractères au plus, unique), `protocol` (`smtp`, `submission`, `imap`, `pop3`, `managesieve`), `bind` (une ou plusieurs adresses), `tls` (`none`, `starttls`, `implicit`), `tls_min_version` (`"1.2"` par défaut ou `"1.3"`, écoute chiffrée seulement), `proxy_networks` (réseaux des répartiteurs, §5.3), `max_connections` (facultatif) |
| `observability` | `log_filter`, `json_logs`, `include_target`, `include_thread_ids`, `log_client_ip` (`network` par défaut, ou `full`) |
| `secrets` | section commune aux hôtes (`lyxal_host::services`) : `master_key_id`, `previous_master_key_id` ; les clés elles-mêmes **seulement** par `LYXAL_GROUPWARE__SECRETS__MASTER_KEY` et `LYXAL_GROUPWARE__SECRETS__PREVIOUS_MASTER_KEY` (32 octets en Base64 canonique, lues par `lyxal_crypto::EnvironmentKeyProvider`) : **la même clé que `lyxal-server`** (`LYXAL__SECRETS__MASTER_KEY`), sans quoi les fichiers écrits par l'un ne s'ouvrent pas chez l'autre |
| `storage` | section commune aux hôtes (`lyxal_host::services`) : `disk.root` (support `default`, dossier partagé avec `lyxal-server`), `[storage.s3.<nom>]` (`endpoint`, `region`, `bucket`, `access_key_id`, `secret_access_key` par l'environnement seulement, `path_style`, `allow_http`), `antivirus` (`address` ou `socket`, `timeout_seconds`) : **les mêmes supports nommés que `lyxal-server`** |
| `scheduler` | `workers` (places de chaque exécuteur de file sur ce nœud, 4 par défaut, de 1 à 64) |
| `mail` | `storage_backend` (support des fichiers du courrier, `default` par défaut ; doit exister dans `[storage]` dès qu'un support est déclaré) |
| `smtp` | réception SMTP (§4 bis) : `hostname` (**obligatoire** dès qu'une écoute `smtp` existe : bannière, `Received`, `authserv-id` ; nom de domaine en forme ASCII, celui du MX et du DNS inverse de l'adresse publique), `max_message_bytes` (52 428 800, de 1 Mio à 1 Gio, annoncé par `SIZE`), `max_recipients` (100, 1 à 1 000), `max_messages_per_session` (50, 1 à 1 000), `max_errors` (10, 1 à 100), `max_line_bytes` (4 096, 512 à 65 536), `command_timeout_seconds` (300, 30 à 3 600), `data_timeout_seconds` (180, 30 à 3 600), `session_max_seconds` (1 800, 60 à 86 400), `data_min_bytes_per_second` (1 024, 0 à 1 Mio), `messages_per_network_per_minute` (`[60, 180, 540]`, 1 à 1 000 000), `dmarc_enforce` (`true` ; `false` : résultat DMARC seulement, pour une mise en service progressive) |
| `dns` | résolveur du nœud (`hickory-resolver`, sans DNSSEC) : `servers` (`ip` ou `ip:port` ; vide : ceux du système, `/etc/resolv.conf`), `timeout_seconds` (5, 1 à 30), `attempts` (2, 1 à 5), `cache_size` (16 384, 0 à 1 000 000) ; un résolveur récursif local (Unbound) est recommandé |

Listes dans l'environnement (valeurs séparées par `,`) : `LIMITS__CONNECTIONS_PER_NETWORK`,
`LIMITS__CONNECTIONS_PER_MINUTE`, `LIMITS__DENY_NETWORKS`, `LIMITS__ALLOW_NETWORKS`,
`LIMITS__EXEMPT_NETWORKS`. Les écoutes se règlent dans les fichiers.

Validation au démarrage (`GROUPWARE_CONFIGURATION_INVALID`, réglage fautif nommé au journal) :
identifiants d'écoute uniques et bien formés ; aucune adresse liée deux fois (port HTTP compris) ;
au moins une adresse par écoute ; modes TLS par protocole (§5.1) ; au moins un certificat
déclaré dès qu'une écoute est chiffrée ; noms de certificat uniques et non vides ; réseaux
lisibles ; bornes ci-dessous ; `drain_seconds` inférieur à `runtime.module_stop_timeout_seconds` ;
noms de supports S3 (`snake_case`), antivirus (`address` ou `socket`, délai de 1 à 300 s),
`scheduler.workers` (1 à 64), `mail.storage_backend` déclaré, `smtp.hostname` présent avec une
écoute `smtp`, bornes de `[smtp]` et de `[dns]`, serveurs DNS lisibles ; une clé maîtresse sans
identifiant, ou une ancienne clé sans clé active, arrête le démarrage. Avec une écoute `smtp`, un
résolveur impossible à construire (configuration DNS du système illisible, aucun serveur)
arrête le démarrage (`GROUPWARE_DNS_UNAVAILABLE`).

`default.toml` : port HTTP local, **aucune écoute de courrier**. `development.toml` : les huit
écoutes sur `127.0.0.1` et des ports non privilégiés (2525, 2587, 2465, 1143, 1993, 1110, 1995,
4190), avec un certificat de développement **à fournir** (commande `openssl` en tête du
fichier), et `smtp.hostname = "localhost"`. `production.toml` : aucune écoute active ; exemples
commentés (`[tls]`, `[smtp]`, `[dns]`, port 25, 465 au lot 6, 993 derrière un répartiteur au
lot 8).

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
| 2 | PROXY : depuis un réseau de `proxy_networks`, en-tête v1 ou v2 exigé (§5.3) | fermeture, refus `proxy_header` compté |
| 3 | `deny_networks`, puis `allow_networks` si non vide, puis liste de blocage de l'installation (`mail_network_block`, relue toutes les 30 s) | refus `blocked` |
| 4 | Sauf `exempt_networks` : connexions nouvelles par minute, puis connexions ouvertes, par réseau | refus `rate_limited` / `too_many_connections` |
| 5 | Budget mémoire : réservation de base de la connexion | refus `memory_budget` |
| 6 | TLS implicite : poignée de main sous délai | fermeture (alerte TLS envoyée par `rustls`) |
| 7 | Remise à la session du protocole : réception SMTP pour `smtp` (§4 bis), refus « service indisponible » pour les protocoles pas encore écrits | — |

Les étapes 3 et 4 s'appliquent à l'adresse du client : celle de l'en-tête PROXY s'il y en a un.

Sur une écoute `none` ou `starttls`, un refus écrit la ligne du protocole en clair (délai de 5 s)
puis ferme ; sur une écoute `implicit`, il ferme **sans** poignée de main (elle coûterait du
calcul pour un client refusé) et sans écrire en clair. Lignes : SMTP `421 4.7.0`
(limites, blocage) ou `421 4.3.2` (service indisponible, mémoire), IMAP `* BYE`, POP3 `-ERR`,
ManageSieve `BYE`. Les lignes ne contiennent ni l'adresse du client ni le détail interne. Places,
compteurs et réservations sont rendus à la fin de la connexion, quelle qu'en soit l'issue.
Écriture bloquée (client qui ne lit plus) : connexion fermée après 60 s. Délais d'inactivité
transmis aux sessions : SMTP 300 s, IMAP 1 800 s, POP3 600 s, ManageSieve 300 s.

## 4 bis. Réception SMTP (lot 5)

Les écoutes `protocol = "smtp"` sont servies par `lyxal_mail::smtp::SmtpInboundHandler`
(comportement complet : README de `lyxal_mail`, « `lyxal_mail::smtp` »). L'hôte lui remet :

* la session système (`MailStore` du pool) : résolution des destinataires, bannissements ;
* un résolveur DNS par nœud (`HickoryResolver`, section `[dns]`), partagé par toutes les sessions ;
* la chaîne de remise (`DeliveryPipeline`) : antivirus de `[storage.antivirus]` en première étape
  (une analyse par message ; le stockage du courrier n'analyse plus chaque copie, décision S9),
  puis dépôt chiffré par le service du courrier ;
* le budget mémoire des connexions (classe « réception SMTP » pour les messages) ;
* la liste de blocage du nœud, relue toutes les 30 s par le worker `lyxal_mail:mail.block_refresh`
  (criticité `Optional`) et appliquée à l'étape 3 de l'acceptation de toutes les écoutes.

Les clés « fichiers » ouvertes sont gardées 60 s en mémoire (`FileKeys::with_cache`, lectures).
La sonde de `lyxal_mail` passe à « dégradé » si l'antivirus configuré ne répond pas, si le DNS est
en panne sur le nom témoin `smtp.hostname` (une requête par minute au plus) ou si aucun nœud
`lyxal_server` n'est vivant depuis 10 minutes. `/metrics` ajoute, sous `mail.smtp`, les mesures de
la réception (messages acceptés et refusés par motif, destinataires, résultats SPF / DKIM / DMARC,
remises dupliquées évitées, durée des remises, ordre des inscriptions, DNS, bannissements), sans
aucune adresse.

## 5. TLS et PROXY

### 5.1. Modes par écoute (décision G7)

| Mode | Protocoles permis | Ports usuels |
| :--- | :--- | :--- |
| `implicit` (TLS dès la connexion, RFC 8314) | `submission`, `imap`, `pop3` | 465, 993, 995 |
| `starttls` (mise à niveau en session, RFC 3207 et équivalents) | tous | 25, 587, 143, 110, 4190 |
| `none` | `smtp` seulement (réception des autres serveurs, où STARTTLS reste facultatif pour l'expéditeur) | 25 |

Une configuration `rustls::ServerConfig` par écoute chiffrée, construite par
`lyxal_crypto::tls_server_config` seulement (règle 10 du §11.3 : fournisseur `aws-lc-rs`, TLS
1.2 et 1.3 ou 1.3 seul selon `tls_min_version`, pas de 0-RTT, pas de certificat client), sur le
**même** magasin de certificats pour toutes les écoutes ; poignée de main par
`tokio_rustls::TlsAcceptor` (hôte seulement), sous `tls.handshake_timeout_seconds`. **ALPN** par
écoute : `imap`, `pop3`, `managesieve` ; un client qui annonce un autre nom (par exemple `h2`)
est refusé par une alerte TLS, ce qui bloque les attaques qui font passer une connexion d'un
protocole vers un autre. SMTP et la soumission n'ont pas de nom ALPN enregistré : aucun n'est
annoncé (un client sans ALPN est accepté partout).

La session reçoit l'état TLS (`TlsState::Plain`, `Implicit` ou `Upgraded`, avec version, suite,
nom SNI et ALPN). Sur une écoute `starttls`, `Session::start_tls(pending_input)` fait la mise à
niveau (`HostTlsUpgrade`, même accepteur et même délai) ; **toute entrée déjà lue** après la
commande STARTTLS est refusée (`NetError::PipelinedBeforeTls`, connexion fermée : injection de
commandes en clair) ; sur une écoute `none`, ou une seconde fois, `NetError::TlsUnavailable`.

### 5.2. Certificats (décision G8)

Fichiers PEM lus par l'hôte (`lyxal_crypto` ne lit aucun fichier) : un certificat par défaut
(client sans SNI, nom inconnu, adresse IP) et des certificats par nom (nom exact ou joker d'un
niveau, `*.exemple.fr`), chaîne de 64 Kio et clé de 16 Kio au plus, clé non chiffrée. Un
certificat qui ne couvre pas un de ses noms est refusé. **Le fichier de clé ne doit être lisible
ni par le groupe ni par les autres comptes** (mode `& 0o077` nul, Unix ; liens symboliques suivis,
ceux de certbot compris) ; la clé est lue dans un `SecretBytes` et n'apparaît jamais au journal.

Le worker `lyxal_mail:mail.tls_reload` (criticité `Optional`) relit les fichiers toutes les
`tls.reload_interval_seconds` ; un couple (chaîne, clé) dont l'empreinte BLAKE3 a changé est
rechargé et **remplace l'ancien à chaud** : les nouvelles poignées de main voient le nouveau
certificat, les connexions ouvertes gardent l'ancien. Un couple invalide (fichier illisible,
PEM faux, clé qui ne correspond pas, nom non couvert, droits trop larges) est **ignoré** :
l'ancien reste en service, l'erreur est journalisée avec le code
`GROUPWARE_TLS_CERTIFICATE_INVALID` à chaque relecture, et la sonde passe à « dégradé » jusqu'au
prochain passage sans erreur. Pas de signal `SIGHUP` (un seul mécanisme). Certificats du
coffre-fort et ACME : lot 13.

### 5.3. PROXY protocol (décision G9)

Derrière un répartiteur de charge (HAProxy, répartiteur d'un hébergeur), `proxy_networks` déclare
ses réseaux par écoute. Depuis ces réseaux, l'en-tête PROXY v1 (texte) ou v2 (binaire) est
**exigé**, lu par `proxy-header` sous `limits.proxy_header_timeout_seconds` (5 s, de 1 à 60) ;
absent, illisible, hors délai ou d'un transport autre que TCP : fermeture. Ailleurs, il n'est
**jamais lu** (un client ne choisit pas son adresse : l'en-tête reste une donnée du protocole).
L'adresse source de l'en-tête devient l'adresse du client (`ConnectionInfo.remote`,
`via_proxy = true`), sur laquelle s'appliquent listes et limites ; la destination devient
l'adresse locale ; une IPv4 transportée en IPv6 est ramenée à l'IPv4. En-tête `LOCAL` ou
`UNKNOWN` (sonde du répartiteur) : adresse de la connexion gardée. Le PROXY se place avant le TLS
(répartiteur en mode TCP).

Le port HTTP suit la même règle avec `http.proxy_networks`, puis la poignée de main TLS si
`http.tls` (`lyxal_host::http::serve_prepared`) ; l'adresse de l'en-tête est celle que voient
les routes. `X-Forwarded-For` n'est pas lu : les routes de santé n'utilisent pas l'adresse du
client (proxys de confiance du port HTTP : avec les routes du DAV et de JMAP, lot 15).

## 6. Limites (décisions G10, G11)

| Réglage | Défaut | Bornes |
| :--- | -: | :--- |
| `max_connections` (par écoute, surchargeable par écoute) | 4 096 | 1 à 65 536 |
| `connections_per_network` (ouvertes : `/32`, `/26`, `/21` ; IPv6 `/64`, `/48`, `/32`) | 30 / 90 / 270 | 1 à 100 000 |
| `connections_per_minute` (mêmes niveaux) | 300 / 900 / 2 700 | 1 à 1 000 000 |
| `max_tracked_networks` (par fenêtre ; au-delà, refus) | 100 000 | 1 000 à 10 000 000 |
| `memory_budget_bytes` | 512 Mio | 64 Mio au moins |
| `connection_base_bytes` | 64 Kio | 4 Kio à 16 Mio |
| `drain_seconds` | 30 | 1 à 300 |
| `proxy_header_timeout_seconds` | 5 | 1 à 60 |

Le budget a deux classes (réception SMTP, lecture), chacune gardant un quart du budget : les
connexions réservent dans la classe « lecture », soit trois quarts du budget au plus.

**Limite connue** : les compteurs sont en mémoire, **par nœud**, partagés par les écoutes du
nœud. Avec plusieurs nœuds derrière un répartiteur, les limites s'additionnent. Seuls les
bannissements sont partagés, par la liste de blocage de l'installation en base (§4 bis) ; les
limites propres à SMTP (messages par session, par minute et par réseau, erreurs, délais) sont
dans la section `[smtp]` (§3).

## 7. Santé, mesures, journal

* Port HTTP (`127.0.0.1:8090` par défaut) : `/live` (`204`), `/ready` (`204` ; `503` au démarrage,
  à l'arrêt, et quand aucune connexion de la session système ne répond à la sonde), `/health` (`host` : composants `groupware`, `database`, `http` ; `modules` :
  sondes du runtime, sans message interne ; `503` si un module est en panne) — mêmes routes que
  `lyxal-server`, par `lyxal_host` ; `/metrics` (JSON) : par écoute, connexions servies,
  ouvertes, plafond, refus par raison (en-têtes PROXY refusés compris), connexions venues par
  PROXY, poignées de main TLS en échec, sessions en échec, erreurs d'acceptation ; budget mémoire
  utilisé ; réseaux suivis ; certificats (nombre, rechargements réussis et refusés, état
  « dégradé ») ; réception SMTP (`mail.smtp`, §4 bis). Aucune adresse IP.
* Sonde de `lyxal_mail` (une seule par module : `MailListenersHealthCheck` composée avec
  `MailHealthCheck`) : d'abord le service du courrier (« malade » si ses réglages sont
  illisibles, « dégradé » sans support de stockage ou sans clé maîtresse, antivirus configuré
  injoignable, DNS en panne sur le nom témoin `smtp.hostname`, ou quand aucun nœud
  `lyxal_server` vivant n'est listé dans `runtime_node` depuis plus de 10 minutes : message
  « aucun nœud lyxal_server vivant… », §9), puis les écoutes
  (« dégradé » si le dernier rechargement des certificats a échoué, au-delà de 90 % du budget
  mémoire ou du plafond d'une écoute ; « malade » porté par la supervision des workers). Sondes
  de `lyxal_secrets`, `lyxal_storage` et `lyxal_scheduler` comme dans `lyxal-server`.
* Journal (décision G13) : écoute démarrée et arrêtée (adresses locales, protocole, mode TLS),
  refus (raison et **réseau masqué** : IPv4 `/24`, IPv6 `/48`, par `lyxal_host::net::log_network`),
  poignée de main en échec (catégorie de l'erreur, réseau masqué), certificat chargé ou rechargé
  (noms couverts, empreinte BLAKE3 de la chaîne, jamais la clé).
  L'adresse complète n'est écrite qu'au niveau `debug` et avec `log_client_ip = "full"`. Jamais
  d'adresse e-mail, d'identifiant, de contenu ni d'octets reçus.

## 8. Erreurs (`error/groupware.surql`)

Master data rejouable (`IF !record::exists(...) THEN (CREATE ...) END;`), traductions fr / en,
installées avec le socle (hors empreinte du socle), contrôlées contre `src/error.rs` par un test :

| Code | Cas |
| :--- | :--- |
| `GROUPWARE_CONFIGURATION_INVALID` | Configuration absente, illisible ou incohérente |
| `GROUPWARE_DATABASE_UNAVAILABLE` | Base injoignable ou sonde en échec |
| `GROUPWARE_MODULE_INSTALL_FAILED` | Installation d'un module hébergé impossible |
| `GROUPWARE_BIND_FAILED` | Port de courrier ou port HTTP indisponible |
| `GROUPWARE_TLS_CERTIFICATE_INVALID` | Certificat illisible ou invalide, nom non couvert, clé lisible par d'autres comptes : arrêt au démarrage ; au rechargement, l'ancien reste et la santé passe à « dégradé » |
| `GROUPWARE_MASTER_KEY_MISSING` | Aucune clé maîtresse du coffre-fort alors qu'un bucket chiffré existe dans la base : arrêt après l'installation des modules, rien n'est démarré |
| `GROUPWARE_DNS_UNAVAILABLE` | Écoute `smtp` déclarée, mais résolveur DNS impossible à construire (configuration DNS du système illisible, aucun serveur) : arrêt avant l'installation des modules |
| `GROUPWARE_SHUTDOWN_SIGNAL_FAILED` | Signal d'arrêt indisponible |
| `GROUPWARE_TELEMETRY_INIT_FAILED` | Journal non initialisé |

Une erreur du runtime garde son code `RUNTIME_*`. Les erreurs du transport (`NetError` de
`lyxal_mail`) restent internes : jamais renvoyées à un client ni écrites en base. Les codes
`MAIL_*` de la réception ne sont jamais rendus à un serveur expéditeur : la session SMTP les
traduit en réponses SMTP.

## 9. Exploitation

* **Ports privilégiés** (25, 143, 993…, décision G14) : le programme tourne sous un compte sans
  droits, avec la capacité `CAP_NET_BIND_SERVICE` donnée par systemd
  (`AmbientCapabilities=CAP_NET_BIND_SERVICE`) ou par le conteneur ; aucun changement
  d'utilisateur dans le code.
* **Même commit que `lyxal-server`** : deux binaires d'un autre commit installeraient des
  releases différentes sous le même numéro (`RUNTIME_RELEASE_CHECKSUM_MISMATCH`) et l'un des deux
  verrait le socle « dégradé ».
* **Même clé maîtresse et mêmes supports que `lyxal-server`** (décision M13) : sections
  `[secrets]` et `[storage]` communes aux deux hôtes (`lyxal_host::services`), aux mêmes valeurs
  (préfixes `LYXAL__` et `LYXAL_GROUPWARE__`) : la clé maîtresse du coffre-fort (perdue :
  courrier illisible ; ses procédures de sauvegarde sont celles de `lyxal_secrets` ; absente
  alors qu'un bucket chiffré existe : refus de démarrer, `GROUPWARE_MASTER_KEY_MISSING`) et les
  supports nommés (disque partagé ou S3).
* **`lyxal-server` sur la même base, exigence d'exploitation** : `lyxal-groupware` ne fonctionne
  pas seul. Les tâches `storage.cleanup` (octets des messages effacés retirés des supports,
  préfixes des buckets supprimés) et `secrets.maintenance` (rotation des clés « fichiers » des
  organisations, rescellement des clés des fichiers) ne sont exécutées que par les nœuds de
  `lyxal-server`. Sans lui, rien n'est perdu, mais les octets s'accumulent et une clé retirée
  n'est jamais rescellée : la sonde de `lyxal_mail` passe à « dégradé » quand aucun nœud
  `lyxal_server` vivant (battement de moins de 30 s dans `runtime_node`) n'a été vu par ce nœud
  depuis plus de 10 minutes, et le redevient sain au premier battement vu.
* **Port 25 (réception SMTP)** : `smtp.hostname` est le nom du MX du domaine et celui du DNS
  inverse de l'adresse publique ; certains hébergeurs bloquent le port 25 entrant. Résolveur DNS :
  un résolveur récursif local (Unbound ou équivalent) est recommandé (les résolveurs publics
  limitent les requêtes). Mise en service progressive : `smtp.dmarc_enforce = false` donne les
  résultats DMARC sans les appliquer. Vérification : `swaks --to adresse@domaine --server hôte`
  ou `openssl s_client -connect hôte:25 -starttls smtp`. Liste de blocage : entrées manuelles par
  `fn::mail_block_create` (`mail.installation.manage`), relues par chaque nœud en 30 s au plus.
* **Certificats** : fichier de clé en mode 0600 ou 0400, propriété du compte du service ;
  vérification par `openssl s_client -connect hôte:993 -servername mail.exemple.fr` (TLS
  implicite) ou `openssl s_client -connect hôte:587 -starttls smtp` (STARTTLS).
* Liste de mise en production : [`docs/PRODUCTION-CHECKLIST.md`](docs/PRODUCTION-CHECKLIST.md).
* Image : `Dockerfile` (compte `lyxal` sans droits, port de santé 8090 ; ports de courrier à
  publier selon la configuration).

## 10. Vérification

```bash
cargo test -p lyxal-groupware
# Essai à deux hôtes sur un serveur SurrealDB réel (lancé par scripts/ci/test_all.sh)
cargo test -p lyxal-groupware -- --ignored --exact two_hosts::groupware_beside_lyxal_server_on_a_remote_server
```

Essais : configuration (fichiers livrés, préfixe `LYXAL_GROUPWARE__`, chaque refus) ; écoutes
sur de vraies sockets (refus poli par protocole, plafond, limites par réseau partagées entre
écoutes, cadence, réseaux exemptés, listes, budget épuisé, journal sans adresse complète) ;
TLS implicite (TLS 1.2 et 1.3, certificat par nom et par défaut, ALPN négocié et ALPN étranger
refusé, version minimale, poignée de main hors délai, refus sans poignée de main) ; STARTTLS par
un protocole d'essai (mise à niveau, injection refusée, écoute sans STARTTLS, poignée de main en
échec) ; PROXY v1 et v2 (réseau déclaré ou non, en-tête absent ou hors délai, limites appliquées
à l'adresse de l'en-tête) ; rechargement à chaud (nouveau certificat, connexion ouverte
inchangée, fichier invalide écarté puis corrigé, worker de relecture, clé lisible par d'autres
refusée, nom non couvert refusé) ;
cycle de vie complet (santé, mesures, arrêt avec drainage, session qui ignore l'arrêt abandonnée
au délai, port déjà pris) ; services du courrier (`mail_service` : démarrage avec clé maîtresse
et support disque, sonde saine, dépôt puis lecture d'un message chiffré sur le disque,
maintenance exécutée par le planificateur, planification non recréée au redémarrage, aucun
événement `storage.object.*` ; sans clé : sonde « dégradé » et dépôt refusé à réessayer ; sans
clé et avec un bucket chiffré en base : démarrage refusé, `GROUPWARE_MASTER_KEY_MISSING`, aucun
nœud inscrit, puis démarrage avec la clé) ; réglages du coffre-fort et du stockage (clés
refusées dans les fichiers, supports, antivirus, exécuteurs, support du courrier) ; réception
SMTP (`smtp_reception` : message envoyé par le client `lettre` puis lu par le service du
courrier, en-têtes ajoutés, événement sans adresse, mesures ; relais refusé ; réseau de la liste
de blocage refusé à l'acceptation ; STARTTLS réel par `openssl s_client -starttls smtp` et message
marqué `ESMTPS` ; réglages `[smtp]` et `[dns]`) ; **deux hôtes** avec le vrai `lyxal-server`
(décision G16) sur base embarquée et sur `ws://` ; bout en bout du binaire (démarrage, routes
HTTP, accueil SMTP et relais refusé, arrêt par SIGTERM). Les essais n'interrogent jamais le vrai
DNS : un serveur DNS d'essai (réponse « n'existe pas » à toute question) est désigné par `[dns]`.

Les essais TLS utilisent le client `openssl s_client` (outil OpenSSL requis sur la machine
d'essai) : le garde-fou C12 refuse toute configuration `rustls`, même cliente, hors de
`lyxal_crypto`. Certificats d'essai : ceux de `lyxal_crypto`
(`crates/lyxal_crypto/tests/fixtures/tls_test_only/`, réservés aux tests), copiés par chaque
essai dans un dossier temporaire avec des clés en mode 0600 ; chaînes vérifiées à date fixe
(`-attime`, 1er janvier 2027).
