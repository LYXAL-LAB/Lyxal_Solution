# Plan d'implémentation — programme courrier, agendas et contacts, lot 5 (réception SMTP)

Plan détaillé du lot 5 du programme courrier, agendas et contacts (`implementation_plan.md` à la
racine, §4, §5 et décisions **P5**, **P6**, **P7**, **P13**, **P15** ; décisions **M1** à **M20**
et **P1** à **P7** du lot 4) : le serveur reçoit enfin du courrier venu d'Internet.

| Brique | Ce que c'est, en clair | Où |
| :--- | :--- | :--- |
| Préalable 5-0 | Configuration commune des hôtes, refus de démarrer sans clé maîtresse, exploitation à deux hôtes, cache des clés (décisions du CTO du 22 novembre 2026) | `lyxal_host`, `lyxal_storage`, `lyxal_secrets`, hôtes |
| Syntaxe SMTP | Lire les commandes d'un serveur expéditeur et écrire nos réponses | `lyxal_mail_proto::smtp` (porté de Stalwart `smtp-proto`) |
| Résolveur DNS | Interroger le DNS (TXT, MX, A, AAAA, PTR) avec un cache | `lyxal_mail::dns` |
| Authenticité | Dire si l'expéditeur a le droit d'écrire au nom de son domaine : SPF, DKIM, DMARC, nom inverse ; en-tête `Authentication-Results` | `lyxal_mail::auth` |
| Session SMTP entrante | Le dialogue du port 25 : accueil, `EHLO`, `MAIL FROM`, `RCPT TO` (refus immédiat d'un destinataire inconnu), `DATA` | `lyxal_mail::smtp` (porté de Stalwart `smtp/inbound`, comportements de Mox) |
| Remise en boîte | Chaîne fixe antivirus → anti-spam → filtres → index → chiffrement, puis dépôt chiffré et événement `mail.message.received` | `lyxal_mail::delivery`, SurrealQL |
| Débit (P7) | Atteindre 300 remises par seconde sans conflits du compteur de compte | SurrealQL et Rust de `lyxal_mail` |

**Ce que fait un lot 5 fusionné, concrètement** : un domaine de courrier déclaré au lot 4 reçoit
du courrier sur le port 25 de `lyxal-groupware`. Un serveur expéditeur (Gmail, Postfix…) se
connecte, éventuellement en STARTTLS ; une adresse inconnue est refusée dès `RCPT TO` ; un domaine
qui n'est pas à nous est refusé (aucun relais) ; le message reçu est contrôlé (SPF, DKIM, DMARC),
analysé par l'antivirus s'il y en a un, rangé chiffré dans la boîte de réception (ou dans
« Junk » si la politique DMARC de l'expéditeur demande la quarantaine), et l'événement
`mail.message.received` est publié. Rien n'est encore envoyé vers l'extérieur (lot 6) : aucun avis
de non-remise n'est produit, tout refus se fait pendant la session.

Touche : `crates/lyxal_mail_proto` (syntaxe SMTP), `crates/lyxal_mail` (SurrealQL et Rust),
`crates/lyxal_storage` (une fonction, une option de bucket), `crates/lyxal_secrets` (cache
facultatif des clés « fichiers »), `crates/lyxal_host` (configuration commune), `apps/lyxal-groupware`,
`apps/lyxal-server` (configuration commune, sans changement de comportement), `Cargo.toml`,
`deny.toml`, documents. `lyxal_booking/` n'est pas touché. Aucune ligne de code avant la
validation de ce plan par le CTO (`.agents/AGENTS.md` §3).

Méthode : constats faits **par lecture** du dépôt (programme, plans des lots 3 et 4 dans
l'historique Git, `crates/lyxal_mail` dont ses fonctions `mail_address_resolve`,
`mail_message_create`, `mail_modseq_next` et ses mesures, `crates/lyxal_mail_proto`,
`crates/lyxal_crypto/API_CONTRACT.md` et `ROADMAP.md`, `scripts/ci/check_crypto_dependencies.py`,
`crates/lyxal_storage`, `crates/lyxal_secrets/src/files.rs`, `crates/lyxal_runtime` (présence des
nœuds), `apps/lyxal-groupware`, `apps/lyxal-server/src/config.rs`, `deny.toml`, `Cargo.lock`), de
la copie triée de Stalwart `3adead9` (sans `LicenseRef-SEL`) et de Mox `b32f0de` présentes dans
`.sources/` (fichiers lus : `crates/smtp-proto/src/**`, liste et en-têtes de
`crates/smtp/src/inbound/**`, `data.rs` pour l'usage de `mail-auth` ; Mox
`smtpserver/server.go` pour les fins de ligne isolées et les échecs partiels), et de l'index
crates.io (22 novembre 2026 : `mail-auth` 0.15.1 est toujours la dernière version publiée,
`hickory-resolver` 0.26.3, `smtp-proto` 0.2.5). **Rien n'a été compilé ni exécuté.** Ce qui n'est
pas vérifié est listé au §19.

**Règle de provenance (programme §4.1, P2)** : le code porté de Stalwart (AGPL) et de Mox (MIT) ne
va que dans `lyxal_mail_proto` et `lyxal_mail` (`AGPL-3.0-only`) ; les parties non
cryptographiques de `mail-auth` (`Apache-2.0 OR MIT`) qui sont portées vont aussi dans
`lyxal_mail`, avec leur avis. Les évolutions de `lyxal_host`, `lyxal_storage` et `lyxal_secrets`
sont écrites pour Lyxal et restent sous `MIT OR Apache-2.0`. Aucune partie `LicenseRef-SEL` : dans
`crates/smtp/src/inbound/data.rs`, l'extrait propriétaire de 6 lignes est déjà retiré de la copie
triée (`crates/lyxal_mail/SOURCES.md` §2.3) et n'est pas recherché ailleurs.

## Bilan de réutilisation (`AGENTS.md` §3, §5.7)

**Fonctions `lyxal_core` réutilisées** (toutes présentes dans le dépôt, vérifié) :

| Besoin | Fonction ou règle du Core |
| :--- | :--- |
| Entrées des fonctions publiques nouvelles | moteur unique `fn::validation_object_execute`, `fn::sanitize_object_execute` |
| Adresse d'un destinataire | `fn::validation_email`, `fn::sanitize_email`, `fn::sanitize_email_local`, `fn::sanitize_email_domain`, `lowercase`, `trim`, `ascii` |
| Domaine | `fn::validation_domain`, `fn::sanitize_domain` |
| Liste de blocage | `fn::validation_ip`, `fn::validation_cidr` (règles `ip`, `cidr` des catalogues) |
| Bornes, identifiants, dates | `record`, `integer`, `non_negative_number`, `enum`, `boolean`, `datetime`, `array_length`, `max_serialized_length` |
| Journal sans donnée personnelle | `fn::security_redact_email`, `fn::security_redact_ip` (messages d'erreur internes ; jamais dans un événement) |

**Fonctions métier nouvelles** : 8 fonctions publiques `fn::mail_*` nouvelles (dont
`fn::mail_recipient_resolve`, qui remplace `fn::mail_address_resolve`), 2 étendues et 3 internes
(§9) ; une fonction publique dans `lyxal_storage` (§1.2).

**Fonctions Core éventuellement manquantes** (signalées, **non ajoutées**) : conversion IDNA et
validation d'une partie locale UTF-8 (décision M10 du lot 4) — instruites au §8 : aucune
extension du Core au lot 5 (décision **S16**).

**`lyxal_crypto`** : aucune extension. Le lot utilise `lyxal_crypto::dkim` (`DkimAlgorithm`,
`DkimCanonicalization`, `DkimBodyHasher`, `DkimHeaderCanonicalizer`, `DkimKeyType`,
`DkimPublicKey`, lot 2b), `hash::blake3` (clé d'idempotence d'une remise, §9.4) et, par
`lyxal_storage`, le chiffrement en flux. La règle 13 du §11.3 est tenue : lecture des balises
`DKIM-Signature`, choix des en-têtes de `h=`, DNS, `t=` / `x=`, `i=` / `d=`, politique de `l=` et
résultats sont écrits dans `lyxal_mail` ; les octets signés et la vérification restent dans
`lyxal_crypto`. `mail-auth` n'est **jamais** une dépendance (interdite par
`check_crypto_dependencies.py`, y compris pour `lyxal_crypto`).

## 0. Écarts au plan du programme

| # | Écart | Raison |
| :- | :--- | :--- |
| E1 | SPF, DKIM et DMARC sont écrits dans `lyxal_mail` (portés des parties non cryptographiques de `mail-auth` 0.16.0), et non pris de `mail-auth` en dépendance | `mail-auth` fait sa propre cryptographie ; il est interdit en dépendance directe partout, `lyxal_crypto` compris (décisions C4, C12 du lot 2, contrôle `check_crypto_dependencies.py`) (décision **S1**) |
| E2 | Partie préalable **5-0** (configuration commune des hôtes, refus de démarrer, exploitation à deux hôtes, cache des clés) | Décisions du CTO du 22 novembre 2026 sur les points ouverts du lot 4 |
| E3 | `lyxal_storage` et `lyxal_secrets` sont modifiés | Fonction « un bucket chiffré existe-t-il » (5-0), option « bucket sans événements » (S14), cache facultatif des clés (S13) |
| E4 | ARC n'est **pas** vérifié au lot 5 ; ses en-têtes sont gardés tels quels | Vérification ARC prévue au lot 7 (P6 e) ; `Authentication-Results` ne contient pas `arc=` au lot 5 |
| E5 | Aucun avis de non-remise ; un échec partiel après `DATA` est rendu temporaire à tous les destinataires, avec idempotence (S8) | La file d'envoi n'existe qu'au lot 6 ; Mox, lui, accepte et envoie un avis pour les destinataires en échec |
| E6 | Le compteur de modifications reste **par compte** (M6), contrairement au mot « compteur par dossier » de P7 ; la contention est traitée par l'ordre des remises dans le nœud et l'écriture groupée (S11) | Un compteur par dossier ne supprime pas la contention de la boîte de réception (UID) et l'état JMAP exige une suite croissante par compte (§10.2) ; repli décrit, déclenché par la mesure |

## 1. Partie préalable 5-0 (décisions du CTO du 22 novembre 2026)

Décisions déjà prises, appliquées telles quelles. Livrées en premier (demande de fusion **5-0**).

### 1.1. Configuration commune des hôtes dans `lyxal_host`

Constat : `apps/lyxal-server/src/config.rs` et `apps/lyxal-groupware/src/config.rs` déclarent les
mêmes structures `SecretsConfig`, `StorageConfig`, `DiskStorageConfig`, `S3StorageConfig`,
`AntivirusConfig`, à une différence près (`storage.idle_timeout_seconds`, propre aux envois HTTP de
`lyxal-server`), et `apps/lyxal-groupware/src/services.rs` refait la construction du trousseau
maître, des supports et de l'antivirus.

* `crates/lyxal_host` (`MIT OR Apache-2.0`) reçoit un module `services` (fonctionnalité Cargo
  `host`) : structures de configuration `SecretsConfig`, `StorageConfig` (`disk`, `s3`,
  `antivirus`), `DiskStorageConfig`, `S3StorageConfig`, `AntivirusConfig` (`deny_unknown_fields`,
  mêmes champs et bornes qu'aujourd'hui) ; fonctions `master_keys(&SecretsConfig, env_prefix) ->
  Result<Option<MasterKeys>, HostError>` (lecture par `lyxal_crypto::EnvironmentKeyProvider` des
  variables `<préfixe>SECRETS__MASTER_KEY` et `__PREVIOUS_MASTER_KEY`), `storage_backends(&StorageConfig)
  -> Result<Backends, HostError>`, `storage_scanner(&StorageConfig) -> Option<Arc<dyn
  ContentScanner>>`, `validate_storage(&StorageConfig) -> Result<(), HostError>`. Erreurs sans code
  (règle du §5.8.5), traduites par chaque hôte (`SERVER_CONFIGURATION_INVALID`,
  `GROUPWARE_CONFIGURATION_INVALID`).
* Nouvelles dépendances de `lyxal_host` : `lyxal_secrets`, `lyxal_storage` (toutes deux
  `MIT OR Apache-2.0`, sans dépendance vers `lyxal_host` : aucun cycle ; seuls les hôtes dépendent
  de `lyxal_host`).
* **Rupture coordonnée (§0.3)** : `storage.idle_timeout_seconds` de `lyxal-server` passe dans sa
  section `[http]` sous le nom `transfer_idle_timeout_seconds` (variable
  `LYXAL__HTTP__TRANSFER_IDLE_TIMEOUT_SECONDS`), pour que `[storage]` soit identique dans les deux
  hôtes ; fichiers `config/*.toml`, README et essais de `lyxal-server` mis à jour dans le même
  changement.
* Préfixes d'environnement inchangés (`LYXAL__` pour `lyxal-server`, `LYXAL_GROUPWARE__` pour
  `lyxal-groupware`, décision G5 du lot 3).

### 1.2. `lyxal-groupware` refuse de démarrer sans clé maîtresse si un bucket chiffré existe

Nouvelle fonction publique de `lyxal_storage` (`functions/storage_worker.surql`) :

```surql
DEFINE FUNCTION OVERWRITE fn::storage_encrypted_bucket_exists($params: object)
-- { language } → fn::result_ok({ exists: bool })
-- Droit : session système ou storage.worker (STORAGE_PERMISSION_DENIED sinon)
```

Lecture : `SELECT VALUE id FROM storage_bucket WHERE encrypted = true LIMIT 1`, toutes portées
confondues, sur un nouvel index `storage_bucket_encrypted` (`encrypted`). Entrées par le moteur du
Core (`unknown_keys: "reject"`). Wrapper Rust : `StorageStore::encrypted_bucket_exists(&self,
params: EncryptedBucketExistsParams) -> Result<EncryptedBucketExists, LyxalSurrealError>`. Banc
SurrealQL de `lyxal_storage` complété (aucun bucket, bucket en clair, bucket chiffré dans une
organisation, appelant sans droit).

`lyxal-groupware`, au démarrage, **après** `install_packages` et **avant** `start_all` : sans clé
maîtresse configurée, si la fonction rend `exists: true`, arrêt avec un nouveau code
`GROUPWARE_MASTER_KEY_MISSING` (« un bucket chiffré existe : la clé maîtresse du coffre-fort est
obligatoire ») ; rien n'est démarré, les ports liés sont refermés. Base neuve sans bucket chiffré :
démarrage « dégradé » comme aujourd'hui (premier dépôt refusé, à réessayer). `lyxal-server`
inchangé.

### 1.3. `lyxal-server` sur la même base : exigence d'exploitation

`storage.cleanup` et `secrets.maintenance` restent exécutées par `lyxal-server`. Documenté dans
`apps/lyxal-groupware/README.md` (§9), `docs/PRODUCTION-CHECKLIST.md` et
`crates/lyxal_mail/README.md`. En plus, la sonde de `lyxal_mail` passe à « dégradé » (message
« aucun nœud lyxal_server vivant ») quand `LyxalRuntime::nodes()` ne montre aucun nœud de l'hôte
`lyxal_server` depuis plus de 10 minutes : l'exploitant voit que les octets des messages effacés et
le rescellement attendent.

### 1.4. Cache des clés « fichiers » (M19)

Décidé dans ce lot, sur mesures : décision **S13** (§10.4).

## 2. Périmètre

**Dans le lot 5** :

* `lyxal_mail_proto::smtp` : syntaxe des commandes et des réponses SMTP, lecture de `DATA` et de
  `BDAT`, porté de Stalwart `smtp-proto` (§4) ;
* `lyxal_mail::dns` : résolveur DNS par nœud et son cache (§5) ;
* `lyxal_mail::auth` : SPF, DKIM, DMARC, nom inverse (`iprev`), `Authentication-Results` (§6) ;
* `lyxal_mail::smtp` : session SMTP entrante, limites, refus, liste de blocage et bannissement (§7) ;
* `lyxal_mail::delivery` : chaîne de remise et dépôt groupé (§9, §10) ;
* SurrealQL de `lyxal_mail` : résolution des destinataires (relais, attrape-tout, `postmaster`,
  quota), remise groupée et idempotente, origine des messages, événement `mail.message.received`,
  liste de blocage (§9) ;
* hôte `lyxal-groupware` : écoute `smtp` servie par la session SMTP, configuration `[smtp]` et
  `[dns]`, sonde, mesures (§11) ;
* partie 5-0 (§1).

**Hors lot 5** (lot prévu) : dépôt authentifié 587 / 465, `AUTH`, envoi, file, avis de
non-remise, alias vers l'extérieur, réécriture SRS (6) ; vérification ARC, MTA-STS, DANE,
rapports DMARC et TLS (7) ; filtres Sieve (10) ; anti-spam (11) ; index (9) ; chiffrement de niveau
B (12 bis) ; administration des domaines et du DNS, certificats automatiques (13) ; `LMTP` (aucun
besoin à ce jour).

## 3. Chemin d'un message, de bout en bout

```text
Serveur expéditeur ──TCP 25──► lyxal-groupware (écoute `smtp`, lot 3 : plafond, PROXY, listes, cadence, budget, TLS)
 1. 220 <hostname> ESMTP                        liste de blocage (§7.6) ; nom inverse demandé en tâche de fond
 2. EHLO <nom>                                  syntaxe ; SPF du nom (identité HELO), en tâche de fond
 3. STARTTLS (facultatif)                       Session::start_tls (lot 3), état remis à zéro
 4. MAIL FROM:<a@b> SIZE= BODY= SMTPUTF8        syntaxe, taille annoncée ; SPF de l'expéditeur lancé
 5. RCPT TO:<x@nous>   (≤ 100)                  fn::mail_recipient_resolve : relais refusé, inconnu refusé, quota plein → 452
 6. DATA / BDAT                                 octets lus sous budget mémoire (classe « réception SMTP »), taille, fins de ligne
 7. Contrôles du message                         MIME (lot 4), From unique, boucle (Received), DKIM, DMARC (avec SPF), iprev
 8. Chaîne de remise                             antivirus → anti-spam (vide) → filtres → index (vide) → chiffrement (niveau A)
 9. Par compte destinataire (ordre du nœud) :   fn::mail_delivery_begin → StorageService::put (chiffré) → fn::mail_delivery_commit (groupé)
10. 250 2.0.0 ou un refus unique                 mail.message.received publié dans la transaction de chaque inscription
```

Les étapes 2 à 6 suivent la machine d'états de Stalwart (`session.rs`, `ehlo.rs`, `mail.rs`,
`rcpt.rs`) ; l'étape 6 la lecture de `smtp-proto` ; les étapes 7 à 9 remplacent la mise en file de
Stalwart (`data.rs`, `queue_message`) par une remise directe en boîte, comme Mox
(`smtpserver/server.go`, `deliver`). La réponse finale n'est donnée qu'après l'inscription de
tous les destinataires (aucun message n'est accepté puis perdu).

## 4. Syntaxe SMTP (`lyxal_mail_proto::smtp`)

**Source** : Stalwart `crates/smtp-proto` (9 fichiers, 4 393 lignes, aucune partie propriétaire,
constaté), version du serveur conformément à P5 : `lib.rs` (types), `request/{parser, receiver,
scan, mod}.rs`, `response/{generate, parser, mod}.rs`, `tokens.rs`. Porté presque tel quel ;
adaptations : erreurs `thiserror` sans donnée du client, aucun `panic!` ni `unwrap` sur une entrée,
limites explicites, `response/parser.rs` (lecture des réponses, utile au client du lot 6) gardé
pour les essais seulement jusqu'au lot 6. Dépendance de la source : `memchr` (déjà dans l'arbre).

| Type | Rôle |
| :--- | :--- |
| `Request` | `Ehlo`, `Helo`, `Lhlo` (refusé), `Mail { from }`, `Rcpt { to }`, `Data`, `Bdat { size, last }`, `Rset`, `Noop`, `Quit`, `StartTls`, `Vrfy`, `Expn`, `Help`, `Auth` (lu, refusé au lot 5), `Etrn`, `Atrn`, `Burl` (lus, refusés) |
| `MailFrom`, `RcptTo`, `Parameter` | Adresse (vide permise pour `MAIL FROM:<>`), paramètres `SIZE`, `BODY` (`7BIT`, `8BITMIME`, `BINARYMIME`), `SMTPUTF8`, paramètres DSN (lus, refusés tant que DSN n'est pas annoncé) |
| `RequestReceiver` | Accumule une ligne de commande ; longueur bornée (`max_line`, 4 096 octets par défaut, RFC 5321 §4.5.3.1.4 : 512 au moins) ; signale CR ou LF isolé, octet nul |
| `DataReceiver` | Lit `DATA` jusqu'à la seule fin `CRLF.CRLF`, retire le point de bourrage, **signale** tout CR ou LF isolé (contrebande SMTP, §7.4) |
| `BdatReceiver` | Lit exactement `size` octets d'un morceau `BDAT` |
| `Response`, `EhloResponse` | Code, code étendu (RFC 3463), texte sur une ou plusieurs lignes ; liste des extensions annoncées |

Fuzzing : cibles `smtp_request` et `smtp_data` dans `crates/lyxal_mail_proto/fuzz/` (lancées
brièvement en 5a, longuement au lot 21) ; propriétés `proptest` (aucun arrêt ; la fin de `DATA`
n'est reconnue que sur `CRLF.CRLF` ; une ligne de plus de `max_line` est refusée sans croissance de
la mémoire). Essais transposés de Mox `smtp/` et `smtpserver/server_test.go` (MIT) pour la
syntaxe, de `smtp-proto` 0.2.5 (`Apache-2.0 OR MIT`) si ses essais couvrent des cas absents.

## 5. Résolveur DNS (`lyxal_mail::dns`)

Reporté du lot 3 (écart E2 du plan du lot 3). **Décision S3.**

* `hickory-resolver` 0.26 (`MIT OR Apache-2.0`, déjà dans l'arbre par `lyxal_auth`, version 0.26.3),
  fonctionnalités `tokio` et `system-config` seulement : **pas de DNSSEC** au lot 5 (DANE, lot 7 ;
  les fonctionnalités DNSSEC de `hickory` tirent `ring` ou `aws-lc-rs` et seront examinées avec le
  plan du lot 7), pas de DNS sur TLS ou HTTPS.
* **Une instance par nœud**, construite par l'hôte et partagée par toutes les sessions ;
  configuration `[dns]` (§11.2) : serveurs du système (`/etc/resolv.conf`) par défaut ou liste
  explicite, délai par requête (5 s), essais (2).
* **Cache** : celui de `hickory` (respect des TTL), 16 384 entrées, TTL positif borné à
  [0 s, 1 h], TTL négatif à [0 s, 5 min] ; aucun cache en base (les nœuds ne partagent pas leurs
  réponses ; un TTL court reste court). Aucun cache des résultats SPF, DKIM ou DMARC eux-mêmes : la
  lecture d'un enregistrement est peu coûteuse.
* Trait `MailResolver` : `txt(name)`, `mx(name)`, `ipv4(name)`, `ipv6(name)`, `ptr(ip)`, chacun
  `Result<Answer<T>, DnsError>` ; `DnsError::{NotFound (NXDOMAIN), NoRecords, Temporary,
  Refused}` distingue « absent » (résultat définitif) et « panne » (résultat `temperror`).
  Implémentations : `HickoryResolver` (production) et `StaticResolver` (essais : table de
  réponses, pannes et délais simulés). Aucun essai automatique n'interroge le vrai DNS (§8 du
  programme).
* Bornes : 255 octets par nom, TXT concaténés de 4 096 octets au plus pour SPF et DMARC, 16 384 pour
  une clé DKIM.

Recommandation d'exploitation (documentée, non imposée) : un résolveur récursif local (Unbound ou
équivalent) sur la machine ; les résolveurs publics limitent les requêtes vers les listes DNS
(lot 11).

## 6. Authenticité du courrier (`lyxal_mail::auth`)

**Décision S1.** Code écrit dans `lyxal_mail`, porté des parties **non cryptographiques** de
`mail-auth` 0.16.0 (commit `c862df2`, `Apache-2.0 OR MIT`, même auteur que Stalwart et même
interface que celle qu'appelle `smtp/inbound/data.rs`), avec les cas d'essai de Mox (`spf/`,
`dkim/`, `dmarc/`, `iprev/`, MIT). Toute la cryptographie passe par `lyxal_crypto::dkim`.

| Partie | Norme | Contenu au lot 5 |
| :--- | :--- | :--- |
| **SPF** | RFC 7208 | `check_host()` sur l'identité `MAIL FROM` (ou `postmaster@<HELO>` pour un expéditeur vide) et sur l'identité HELO ; mécanismes `all`, `include`, `a`, `mx`, `ptr` (lu, déconseillé), `ip4`, `ip6`, `exists`, modificateurs `redirect`, `exp` (non utilisé : aucun texte d'explication renvoyé) ; macros ; limites de la RFC : 10 mécanismes qui interrogent le DNS, 2 réponses vides, 10 noms par `mx` ou `ptr` ; délai total 20 s ; résultats `none`, `neutral`, `pass`, `fail`, `softfail`, `temperror`, `permerror` |
| **DKIM** | RFC 6376, 8301, 8463 | En-têtes `DKIM-Signature` lus (balises, `v=1`, `a=`, `c=`, `d=`, `s=`, `h=` qui doit contenir `From`, `bh=`, `b=`, `l=`, `t=`, `x=`, `i=` sous `d=`) ; 5 signatures vérifiées au plus, les autres « ignorées » ; clé `<s>._domainkey.<d>` (TXT, balises `v`, `k`, `p`, `h`, `t`, `s`) ; `rsa-sha1` refusé (`lyxal_crypto`) ; empreinte du corps par `DkimBodyHasher`, données signées par `DkimHeaderCanonicalizer`, vérification par `DkimPublicKey::verify` ; résultats `none`, `pass`, `fail`, `neutral`, `policy`, `temperror`, `permerror` ; `l=` plus court que le corps : `policy` (contenu ajouté non signé, aucun `pass`) |
| **DMARC** | RFC 7489 | Domaine de l'adresse `From` ; enregistrement `_dmarc.<domaine>`, sinon celui du domaine d'organisation (liste des suffixes publics, décision **S4**) ; alignement souple ou strict de SPF (`MAIL FROM`) et de DKIM (`d=`) ; politique `p`, `sp`, `pct` ; résultats `none`, `pass`, `fail`, `temperror`, `permerror` ; adresses `rua` / `ruf` lues et **non utilisées** (rapports au lot 7) |
| **Nom inverse** (`iprev`) | RFC 8601 §3 | PTR de l'adresse du client puis confirmation A / AAAA ; `pass`, `fail`, `temperror`, `permerror` ; informatif, jamais un motif de refus par défaut |
| **`Authentication-Results`** | RFC 8601 | Un en-tête ajouté en tête du message : `authserv-id` = nom de l'hôte (`smtp.hostname`), méthodes `spf` (`smtp.mailfrom`, `smtp.helo`), `dkim` (une entrée par signature : `header.d`, `header.s`, `header.b` abrégé), `dmarc` (`header.from`, `policy.dmarc`), `iprev` (`policy.iprev`) ; valeurs tirées de nos seuls contrôles, échappées (aucun CR, LF ni caractère de contrôle venu du client) |

* **En-têtes falsifiés** : tout `Authentication-Results` reçu qui porte notre `authserv-id` est
  retiré du message rangé avant l'ajout du nôtre (RFC 8601 §5) ; les autres sont gardés.
* **`From`** : un message sans champ `From`, ou avec plusieurs champs `From`, est refusé
  (`550 5.6.0`, RFC 5322 §3.6 : exactement un) ; plusieurs adresses dans un seul `From` : DMARC
  évalué pour chaque domaine, le résultat le plus sévère l'emporte (modèle :
  `conflicting_author_domains` de Stalwart `data.rs`).
* **Internationalisation** (RFC 8616) : domaines convertis en forme ASCII (A-label) avant toute
  requête DNS (§8).
* Les contrôles DKIM et DMARC portent sur le message en mémoire (déjà lu et borné par le budget du
  lot 3) ; SPF et `iprev` sont lancés dès `MAIL FROM` et la connexion, et attendus à la fin de
  `DATA` (aucun délai ajouté au dialogue).

**Décision S2 — oracle différentiel.** `crates/lyxal_crypto/ROADMAP.md` prévoit une comparaison de
la canonicalisation DKIM avec `mail-auth` « au plus tard avec le lot 5 ». `mail-auth` 0.16.0
n'étant toujours pas publié, outil `crates/lyxal_mail/tools/dkim_oracle/` **hors du workspace**
(comme les dossiers `fuzz/` ; côté `AGPL-3.0-only`, puisqu'il lie `lyxal_mail`), qui dépend de `mail-auth` par le commit Git `c862df2` : il compare, sur le corpus de
`mail-auth` et sur un corpus de messages signés écrit pour Lyxal, (a) les octets canonicalisés de
`lyxal_crypto` et (b) les résultats complets de vérification de `lyxal_mail::auth` (même
`StaticResolver`) à ceux de `mail-auth`. Lancé à la main avant la fusion de 5b et avant le lot 22
(aucun accès à Internet en CI, décision P10) ; résultat consigné dans les README de `lyxal_crypto`
et de `lyxal_mail`. Le contrôle `check_crypto_dependencies.py` ne lit que les paquets du workspace :
l'outil y échappe par construction, ce qui est noté dans le script.

## 7. Session SMTP entrante (`lyxal_mail::smtp`)

**Source** : Stalwart `crates/smtp/src/inbound/` — portés : `session.rs` (736 lignes), `ehlo.rs`
(225), `mail.rs` (559), `rcpt.rs` (453), `data.rs` (1 288, sans la mise en file ni DKIM2),
`vrfy.rs` (131, réduit à des refus), `spawn.rs` (276, adapté au contrat `SessionHandler` du lot 3),
`mod.rs` (143). Non portés : `auth.rs` (lot 6), `dkim.rs` (signature, lot 6), `spam.rs`
(lot 11), `milter/` et `hooks/` (appels à des services extérieurs : hors programme). Modèle et
essais : Mox `smtpserver/server.go`, `server_test.go` (MIT).

### 7.1. Machine d'états

| État | Commandes permises | Hors état |
| :--- | :--- | :--- |
| Accueil | `EHLO`, `HELO`, `QUIT`, `NOOP`, `RSET`, `HELP` | `503 5.5.1` |
| Prêt | `MAIL`, `STARTTLS` (une fois, écoute `starttls`), `EHLO` (remise à zéro), `VRFY` (`252 2.5.0`), `EXPN` (`502 5.5.1`) | `503 5.5.1` |
| Transaction | `RCPT` (100 au plus), `DATA` / `BDAT` (au moins un destinataire accepté), `RSET` | `503 5.5.1` ; `DATA` sans destinataire : `554 5.5.1` |
| Données | lecture `DATA` ou morceaux `BDAT` | — |

* Après `STARTTLS`, l'état revient à « Accueil » (RFC 3207 §4.2) ; toute entrée lue avant la mise
  à niveau ferme la connexion (`NetError::PipelinedBeforeTls`, lot 3).
* Données envoyées avant la réponse `354` à `DATA` (interdit par la RFC 2920 §3.1) : `554 5.5.0`,
  transaction annulée.
* `HELO` / `EHLO` : syntaxe d'un nom de domaine ou d'une adresse entre crochets exigée
  (`501 5.5.4` sinon) ; un nom qui ne correspond pas à l'adresse n'est jamais un motif de refus
  (RFC 5321 §4.1.4).
* `AUTH`, `LHLO`, `ETRN`, `ATRN`, `BURL` : `502 5.5.1` (non annoncés).

### 7.2. Extensions annoncées (décision S5)

`PIPELINING` (RFC 2920), `SIZE <max>` (RFC 1870), `8BITMIME` (RFC 6152), `SMTPUTF8` (RFC 6531),
`ENHANCEDSTATUSCODES` (RFC 2034, codes RFC 3463), `STARTTLS` (RFC 3207, si l'écoute est
`starttls` et un certificat chargé), `CHUNKING` (RFC 3030, `BDAT`). **Non annoncées** : `DSN`
(lot 6), `AUTH` (lot 6, port 587), `BINARYMIME`, `REQUIRETLS`, `DELIVERBY`, `MT-PRIORITY`,
`FUTURERELEASE`, `VRFY` réel. Bannière `220 <hostname> ESMTP` : aucun nom ni version de logiciel.

### 7.3. Destinataires (`RCPT TO`)

Chaque destinataire est résolu par `fn::mail_recipient_resolve` (§9.2) sous la session système de
l'hôte, avant de répondre :

| Cas | Réponse |
| :--- | :--- |
| Domaine qui n'est pas un domaine de courrier actif de l'installation, adresse littérale `[1.2.3.4]`, route source | `550 5.7.1 relaying denied` (aucun relais : rien n'est jamais réexpédié au lot 5) |
| Adresse inconnue ou désactivée, partie locale UTF-8 (§8) | `550 5.1.1` |
| Compte désactivé ou en suppression | `550 5.2.1` |
| Quota plein (au moins un compte de l'alias) | `452 4.2.2` (temporaire) |
| Taille annoncée (`SIZE`) au-delà de la taille maximale de l'organisation | `552 5.3.4` |
| 100 destinataires déjà acceptés | `452 4.5.3` (RFC 5321 §4.5.3.1.8 : le client réessaie le reste) |
| Base indisponible | `451 4.3.0` |
| Accepté | `250 2.1.5` |

Recherche d'adresses (« directory harvest ») : à partir du 5ᵉ destinataire refusé d'une session,
chaque réponse est retardée d'une seconde ; au 20ᵉ, `421 4.7.0` et fermeture, et l'adresse compte
pour le bannissement automatique (§7.6).

### 7.4. Données (`DATA`, `BDAT`)

* Mémoire réservée pas à pas (64 Kio) dans la classe « réception SMTP » du budget du lot 3 ; budget
  épuisé : `452 4.3.1` et transaction annulée.
* Taille : au-delà de `SIZE` du serveur, lecture poursuivie sans garder les octets jusqu'à la fin,
  puis `552 5.3.4` ; au-delà de la taille maximale de l'organisation d'un destinataire,
  `552 5.3.4` (un seul plafond par message : le plus petit des destinataires, connu dès
  `RCPT TO`).
* **Fins de ligne (décision S7)** : la fin de `DATA` n'est reconnue que sur `CRLF.CRLF` ; un CR ou
  un LF isolé dans les données fait refuser le message (`500 5.5.2`, modèle de Mox : « bare CR or
  LF, possible SMTP smuggling ») après lecture jusqu'à la vraie fin ; le message n'est pas
  remis, la session continue, l'erreur compte pour `max_errors`. Couvre les variantes publiées en
  décembre 2023 (`LF.LF`, `LF.CRLF`, `CR.CR`, `CRLF.CR`, octet nul avant le point). Même règle pour
  `BDAT` (aucune fin à reconnaître, mais les fins isolées sont refusées pour tenir le contrat de
  `lyxal_crypto::dkim`).
* Contrôles après lecture, dans l'ordre : lecture MIME (`lyxal_mail_proto::mime`, refus
  `554 5.6.0` si `MimeError`) ; exactement un `From` ; boucle (plus de 50 en-têtes `Received` :
  `554 5.4.6`) ; DKIM, DMARC (avec le SPF déjà obtenu), `iprev` ; décision de politique (§7.5) ;
  chaîne de remise (§9).
* En-têtes ajoutés en tête du message rangé : `Return-Path` (RFC 5321 §4.4), `Received` (`from
  <HELO> (<nom inverse> [<ip>]) by <hostname> with ESMTP[S][A] id <identifiant de session> ;
  <date>`, version et suite TLS en commentaire, aucun destinataire nommé), `Authentication-Results`.
  Les valeurs venues du client sont reprises seulement si leur syntaxe est valide, sinon remplacées
  par `unknown` (aucune injection d'en-tête).

### 7.5. Politique de refus (décision S6)

| Résultat | Effet |
| :--- | :--- |
| SPF `fail` ou `softfail` seul | Aucun refus ; résultat dans `Authentication-Results` et transmis à DMARC |
| DKIM `fail` seul | Aucun refus |
| DMARC `fail` et politique `reject` (après `pct`) | `550 5.7.1` à la fin de `DATA` ; message non remis |
| DMARC `fail` et politique `quarantine` | Remis dans le dossier de rôle `junk` |
| DMARC `temperror` et politique `reject` | `451 4.7.5` (l'expéditeur réessaie) |
| DMARC `none`, `pass`, `permerror` | Remise normale |
| `iprev` | Informatif seulement |

Aucun contournement local (liste d'expéditeurs autorisés, ARC) au lot 5 : listes mêlées aux
filtres (lot 10) et ARC (lot 7). Le refus d'un message transféré par une liste de diffusion dont
l'expéditeur publie `p=reject` est le comportement attendu de DMARC sans ARC (risque §17).

### 7.6. Limites, délais, blocage et bannissement

Limites du lot 3 inchangées (connexions, cadence, plafond, budget). Ajouts (décision **S19**,
réglables dans `[smtp]`, §11.2) :

| Réglage | Défaut | Bornes | Source |
| :--- | -: | :--- | :--- |
| `max_message_bytes` (annoncé par `SIZE`) | 52 428 800 (50 Mio, M18) | 1 Mio à 1 Gio | Mox, M18 |
| `max_recipients` | 100 | 1 à 1 000 | RFC 5321 §4.5.3.1.8 |
| `max_messages_per_session` | 50 | 1 à 1 000 | Stalwart (valeur à relire) |
| `max_errors` (puis `421 4.7.0`) | 10 | 1 à 100 | Mox |
| `max_line_bytes` | 4 096 | 512 à 65 536 | RFC 5321 §4.5.3.1.4 |
| `command_timeout_seconds` | 300 | 30 à 3 600 | RFC 5321 §4.5.3.2 (le client attend 5 min) |
| `data_timeout_seconds` (entre deux blocs) | 180 | 30 à 3 600 | RFC 5321 §4.5.3.2.5 |
| `session_max_seconds` | 1 800 | 60 à 86 400 | — |
| `data_min_bytes_per_second` (après 30 s) | 1 024 | 0 à 1 Mio | lenteur volontaire (« slowloris ») |
| `messages_per_network_per_minute` (`/32`, `/26`, `/21` ; IPv6 `/64`, `/48`, `/32`) | 60 / 180 / 540 | 1 à 1 000 000 | nouvelle fenêtre de `IpRateLimiter` |

**Liste de blocage et bannissement (décision S18)** : table `mail_network_block` (§9.1) à
l'échelle de l'installation. Chaque nœud la lit au démarrage puis toutes les 30 s
(`fn::mail_block_active`) et l'ajoute aux `deny_networks` du lot 3 (un réseau bloqué est refusé à
l'acceptation, `421 4.7.0`, sans dialogue). Bannissement automatique d'une adresse (`/32` ou `/64`)
pour 1 h, doublé à chaque récidive jusqu'à 24 h, après 3 sessions fermées en 10 minutes pour
`max_errors`, recherche d'adresses ou contrebande. Les compteurs de cadence restent **par nœud**
(lot 3) ; seuls les bannissements sont partagés, par la base.

## 8. Adresses internationales (`SMTPUTF8`, décision M10 → S16)

* `SMTPUTF8` et `8BITMIME` sont annoncés : un expéditeur, des en-têtes et un corps en UTF-8 sont
  acceptés et rangés tels quels (RFC 6531, 6532).
* Un domaine en Unicode (U-label) dans `MAIL FROM` ou `RCPT TO` est converti en forme ASCII
  (A-label) **en Rust**, dans la couche de protocole, par la crate `idna` 1.1 (traitement UTS 46,
  `MIT OR Apache-2.0`, données `Unicode-3.0` ; déjà dans l'arbre, à déclarer en dépendance
  directe de `lyxal_mail`), avant la résolution et le DNS. C'est une lecture de protocole (§10 des
  règles : le parsing reste en Rust), pas une validation métier.
* Les adresses de Lyxal restent ASCII (lot 4) : une partie locale UTF-8 ne peut correspondre à
  aucune adresse et reçoit `550 5.1.1` (aucune information sur l'existence d'autres adresses).
* **Aucune extension de `lyxal_core` au lot 5** : une conversion IDNA en SurrealQL n'est pas
  raisonnable (tables Unicode, Punycode). Le besoin réel apparaîtra quand un administrateur voudra
  saisir un domaine ou une adresse en Unicode (lot 13) : son plan proposera alors soit une
  conversion faite par l'hôte avant l'appel, soit une primitive du Core, au choix du CTO.

## 9. SurrealQL (`crates/lyxal_mail/`)

Schéma réécrit en place (§0.3), version `0.1.0`.

### 9.1. Tables et champs

| Table | Changement |
| :--- | :--- |
| `mail_domain` | `catch_all` (`option<record<mail_account>>` : compte qui reçoit les adresses inconnues du domaine, **aucun par défaut**, décision **S17**) ; `postmaster` (`option<record<mail_account>>` : compte qui reçoit `postmaster@<domaine>` quand aucune adresse `postmaster` n'est inscrite) ; tous deux comptes actifs de la même organisation, gardés par `fn::mail_write_refusal` |
| `mail_settings` | Portée installation : `postmaster` (`option<string>`, adresse inscrite qui reçoit `RCPT TO:<postmaster>` sans domaine, RFC 5321 §4.5.1) |
| `mail_message` | `origin` (`delivery`, `append`, `copy`, `move`, `import`), immuable, posé par la fonction qui inscrit ; `reception` (`option<object>`, messages reçus seulement) : `{ spf, dkim, dmarc, iprev }` (mots de résultat RFC 8601, sans domaine ni adresse), `antivirus` (`clean`, `not_scanned`), `spam` (réservé au lot 11 : `none` au lot 5), `tls` (vrai si reçu sous TLS) |
| `mail_delivery` (nouvelle) | Idempotence d'une remise (décision **S8**) : identifiant `mail_delivery:⟨<clé du compte>_<empreinte>⟩`, `tenant`, `account`, `message` (fiche inscrite), `expires_at` (7 jours) ; permission : session système et `mail.worker` seulement ; purgée par la maintenance |
| `mail_network_block` (nouvelle) | Liste de blocage de l'installation : `network` (CIDR, validé par `fn::validation_cidr`, unique), `reason` (`manual`, `errors`, `harvest`, `smuggling`), `strikes`, `expires_at` (`option` : manuel sans fin), `created_by`, dates ; permission : `mail.installation.manage` pour les entrées manuelles, `mail.worker` et session système pour les bannissements |

Événements de garde (`events/mail_guards.surql`) complétés pour ces champs ; aucun champ de
compteur nouveau.

### 9.2. Fonctions publiques nouvelles ou changées

| Fonction | Paramètres → résultat | Droit |
| :--- | :--- | :--- |
| `fn::mail_recipient_resolve` (remplace `fn::mail_address_resolve`, **rupture coordonnée**, seul appelant : `MailStore`) | `{ address (ASCII, domaine en A-label), language }` → `{ address (inscrite), domain, tenant, max_message_bytes, accounts: [{ account, quota_full }] }` ; règle : domaine actif sinon `MAIL_RELAY_DENIED` ; adresse exacte, sans sous-adresse, `postmaster` (champ du domaine, ou réglage de l'installation sans domaine), attrape-tout ; comptes actifs ; `MAIL_RECIPIENT_UNKNOWN`, `MAIL_RECIPIENT_DISABLED` | session système, `mail.worker` |
| `fn::mail_delivery_begin` | `{ account, size, delivery_key (BLAKE3 hex, 64), language }` → `{ duplicate: false, content, storage_key }` ou `{ duplicate: true, message }` ; contrôle état du compte, taille, quota (comme `fn::mail_content_begin`) | session système, `mail.worker` |
| `fn::mail_delivery_commit` | `{ account, items: [1..32 × { content, object, role (inbox, junk), received_at, delivery_key, message_id, in_reply_to, references, base_subject, is_report, envelope, structure, has_attachment, reception }], language }` → `{ items: [{ message, uid, mailbox } ou { error }] }` ; **une transaction** : lien de chaque contenu (comme `fn::mail_content_attach`), inscription (comme `fn::mail_message_create`, `origin: "delivery"`), fiche `mail_delivery`, compteurs ; une erreur d'élément n'annule pas les autres | session système, `mail.worker` |
| `fn::mail_domain_update` (étendue) | `catch_all`, `postmaster` en plus | `mail.domain.manage` |
| `fn::mail_settings_set` (étendue) | `postmaster` (portée installation) | `mail.installation.manage` |
| `fn::mail_block_create` | `{ network, reason, expires_at, language }` → fiche ; manuel : `mail.installation.manage` ; automatique (`reason` ≠ `manual`) : `mail.worker`, `strikes` incrémenté si le réseau existe | voir colonne |
| `fn::mail_block_list` | `{ after, limit, language }` → `{ items, next }` (curseur : réseau) | `mail.installation.manage` |
| `fn::mail_block_delete` | `{ network, language }` | `mail.installation.manage` |
| `fn::mail_block_active` | `{ language }` → `{ networks: [string] }` (non expirées, 100 000 au plus) | session système, `mail.worker` |
| `fn::mail_delivery_purge` | `{ limit, language }` → `{ removed }` (fiches `mail_delivery` échues), appelée par `MailMaintenance` | session système, `mail.worker` |

Fonctions internes : `fn::mail_recipient_accounts` (comptes d'une adresse, alias développé),
`fn::mail_delivery_item` (un élément de `fn::mail_delivery_commit`, pour rester sous 300 lignes),
`fn::mail_reception_rule` (règle du moteur pour `reception`). `fn::mail_content_begin`,
`fn::mail_content_attach` et `fn::mail_message_create` restent pour `APPEND` (lot 8) et les
essais ; `fn::mail_message_create` pose `origin: "append"`.

Toutes : `$params: object`, entrées par le moteur du Core, `fn::result_ok` / `fn::error_result`,
`COMMENT`, écriture principale vérifiée (`MAIL_WRITE_FORBIDDEN`), moins de 300 lignes.

### 9.3. Contrôle allégé des paramètres de remise (décision S12)

Mesure du lot 4 : 38 à 40 ms de validation par `fn::mail_message_create`, presque tout dans les
listes d'adresses de l'enveloppe (`each` + `object` sur 1 000 éléments possibles). Pour
`fn::mail_delivery_commit` (appelée seulement par le service de remise, sous la session système) :

* le moteur du Core valide les champs scalaires et la forme de `items` (`array_length`, `record`,
  `datetime`, `enum`, longueurs) et `max_serialized_length` sur `envelope` (256 Kio) et `structure`
  (1 Mio) ;
* la forme détaillée de `envelope` et de `structure` est garantie par le **schéma** de
  `mail_message` (champs typés `SCHEMAFULL`, `ASSERT` de longueur), déjà en place au lot 4 :
  aucune règle générique n'est réécrite dans le module (§5.7.8), et une valeur hors schéma fait
  échouer l'écriture (`MAIL_MESSAGE_MALFORMED`) ;
* `fn::mail_message_create` (appelable par un titulaire, lot 8) garde la validation complète.

Objectif : validation sous 2 ms par élément. Si le CTO juge que §5.7.8 exige le moteur sur chaque
champ imbriqué, repli : validation complète, et le débit repose sur S11 seul (mesuré des deux
façons en 5c).

### 9.4. Idempotence d'une remise (décision S8)

`delivery_key` = BLAKE3 (`lyxal_crypto::hash`) de : adresse inscrite du destinataire, expéditeur
de l'enveloppe, octets reçus **avant** nos en-têtes. Un expéditeur qui réessaie après un `451`
renvoie les mêmes octets : les comptes déjà servis répondent `duplicate: true` et ne reçoivent pas
de doublon ; les autres sont servis. Un expéditeur qui modifie le message à chaque essai
(rare) peut produire un doublon : la RFC 5321 §6.1 préfère un doublon à une perte. Conservation :
7 jours (au-delà de la durée habituelle des nouvelles tentatives, 5 jours).

### 9.5. Événement `mail.message.received` (décision S15)

`DEFINE EVENT mail_message_received_event ON TABLE mail_message WHEN $event = "CREATE" AND
$after.origin = "delivery"` → `fn::event_publish`, résultat vérifié (`THROW` sinon : l'inscription
est annulée). Un événement **par compte destinataire**. Charge utile, sans donnée personnelle :

```json
{ "tenant": "auth_organization:…", "account": "mail_account:…", "mailbox": "mail_mailbox:…",
  "message": "mail_message:…", "email_id": "<uuid v7>", "size": 12345,
  "received_at": "…", "has_attachment": true, "protection": "platform",
  "reception": { "spf": "pass", "dkim": "pass", "dmarc": "pass", "iprev": "pass",
                 "antivirus": "clean", "spam": "none", "tls": true } }
```

Ni adresse, ni domaine, ni sujet, ni `Message-ID`. Un consommateur (agendas : pièce
`text/calendar`, lot 18 ; `lyxal_notification`) lit le message par les fonctions publiques, sous
ses propres droits.

### 9.6. Erreurs `MAIL_*` nouvelles (`error/<thème>/`)

| Code | Thème | Cas |
| :--- | :--- | :--- |
| `MAIL_RELAY_DENIED` | `adresses` | Domaine du destinataire qui n'est pas un domaine de courrier actif |
| `MAIL_RECIPIENT_DISABLED` | `adresses` | Adresse vers un compte désactivé ou en suppression |
| `MAIL_DELIVERY_REJECTED` | `reception` (nouveau) | Message refusé par la politique (DMARC `reject`, `From` absent ou multiple, boucle) ; détail : motif seulement |
| `MAIL_MESSAGE_INFECTED` | `reception` | Antivirus : message infecté |
| `MAIL_SCANNER_UNAVAILABLE` | `reception` | Antivirus configuré mais injoignable (à réessayer) |
| `MAIL_DELIVERY_BATCH_TOO_LARGE` | `reception` | Plus de 32 éléments dans `fn::mail_delivery_commit` |
| `MAIL_BLOCK_EXISTS` | `blocage` (nouveau) | Réseau déjà bloqué (entrée manuelle) |
| `MAIL_BLOCK_NOT_FOUND` | `blocage` | Réseau absent de la liste |

Master data rejouable, français et anglais. Les réponses SMTP ne renvoient jamais ces codes au
client : la session les traduit en codes SMTP (§7) ; ils servent au journal, aux essais et aux
mesures. Total : 47 codes `MAIL_*`.

## 10. Débit de remise (P7) et contention du compteur (M6)

### 10.1. Point de départ (mesures du lot 4)

Remise unitaire (`fn::mail_message_create`) : 28 ms p50 sous la session d'un membre (35 par
seconde et par connexion), 45 ms sous la session système, dont 38 à 40 ms de validation ; quatre écrivains dans un même compte : 101 à 115 conflits et un tiers des
remises refusées après trois rejeux. Une remise SMTP fait en plus : `fn::mail_content_begin`,
`storage_object_begin`, écriture chiffrée, `storage_object_commit`, `fn::mail_content_attach`,
`fn::mail_message_create`, soit six allers-retours et un scellement de clé.

### 10.2. Pourquoi pas un compteur par dossier (écart E6)

* Les UID d'un dossier sont strictement croissants : deux remises simultanées dans la même boîte
  de réception se heurtent sur `uid_next` du dossier, compteur par dossier ou non. Le cas mesuré
  (un seul dossier) reste en conflit.
* L'état JMAP (`Email/changes`) et le plancher des changements demandent une suite **croissante
  par compte** ; un journal du compte à identifiants tirés par les nœuds (UUID v7) peut laisser
  passer une écriture validée après une lecture qui la précède dans l'ordre (perte d'un
  changement) ; un journal à numéro croissant ramène un compteur par compte.
* Ce qui coûte n'est pas le compteur mais le **conflit** (transaction refusée puis rejouée). Le
  supprimer revient à ordonner les écritures d'un même compte.

### 10.3. Solution retenue (décision S11)

1. **Ordre par compte dans le nœud** : les remises d'un même compte passent par une file en
   mémoire du nœud (table de verrous asynchrones par compte, 1 024 compartiments) : aucun conflit
   entre remises d'un même nœud ; entre deux nœuds, le rejeu sur conflit du lot 4 reste (rare).
2. **Écriture groupée** : quand plusieurs remises attendent le même compte, jusqu'à 32 sont
   inscrites par un seul `fn::mail_delivery_commit` (une transaction, un seul passage sur la fiche
   du compte). Délai d'attente ajouté : aucun (on groupe ce qui attend déjà).
3. **Moins d'allers-retours** : `fn::mail_delivery_begin` (réservation et idempotence en un appel),
   `fn::mail_delivery_commit` (lien et inscription en un appel) : de six à quatre allers-retours
   par compte, et deux par lot pour la partie `lyxal_mail`.
4. **Contrôle allégé** (S12, §9.3).
5. **Événements du stockage** : bucket `lyxal-mail` sans événements `storage.object.*` (S14) : une
   écriture de moins dans `event_outbox` par remise.
6. **Clés** : cache des clés « fichiers » selon la mesure (S13).

**Repli** (lot 4 §19, conservé) : compteur par dossier et journal des changements à numéro
croissant par compte, mis en œuvre **seulement** si la mesure à deux nœuds (§10.5) montre plus de
1 % de remises refusées après rejeu ; sur nouvelle décision du CTO.

### 10.4. Cache des clés « fichiers » (M19 → décision S13)

Chaque dépôt scelle une clé de fichier par la clé « fichiers » de l'organisation, reconstruite à
chaque appel (une lecture en base, une ouverture `enc:v2` par la clé maîtresse). Mesure en 5c :
coût de `FileKeys::seal` et `FileKeys::open` par message, avec et sans cache.

Recommandation : cache **dans `FileKeys`** (`lyxal_secrets`, écrit pour Lyxal), activé par
l'hôte, si la mesure montre plus de 2 ms ou plus de 10 % du temps d'une remise :

* clé « fichiers » ouverte gardée en mémoire (`SecretBytes`, effacée à l'éviction) par
  (organisation, identifiant de clé), **60 s** au plus, 1 024 entrées au plus ;
* usage `files` seulement, jamais la clé « secrets » du coffre-fort ;
* une clé dont l'état n'est plus `active` n'est jamais servie depuis le cache pour **sceller**
  (relue en base) ; l'ouverture d'une clé `decrypt_only` reste permise jusqu'à l'expiration de
  l'entrée ; une clé détruite disparaît au plus tard 60 s après sa destruction, bien avant la fin
  du rescellement qui la précède ;
* mesures exposées (succès, échecs du cache) ; aucun contenu de clé au journal.

Sous le seuil : pas de cache, la règle actuelle de `lyxal_secrets` reste.

### 10.5. Objectifs et mesures

| Mesure | Objectif |
| :--- | :--- |
| Remises par seconde, un nœud, 100 comptes, 50 clients SMTP, messages de 10 Kio, base en mémoire | **≥ 300** (seuil C5) |
| Idem sur un serveur SurrealDB 3.3.4 (`ws://`) | ≥ 200, à confirmer sur la machine de référence |
| Un compte, 20 clients simultanés | ≥ 100 par seconde, **0** remise refusée |
| Deux nœuds, un compte, 20 clients | ≤ 1 % de remises refusées après rejeu (sinon repli §10.3) |
| Latence de la fin de `DATA` à `250`, un destinataire | p95 ≤ 100 ms |
| Mémoire d'un nœud, 1 000 sessions ouvertes et lentes | sous le budget, aucune croissance après la fin |

Banc : `scripts/bench/mailbox/` étendu d'un générateur SMTP (Python, bibliothèque standard
`smtplib` et `asyncio`, hors CI) qui parle au vrai binaire ; relevés p50 / p95, débit, conflits,
rejeux, refus, temps par étape (validation, stockage, clés, inscription). Résultats et date dans
`crates/lyxal_mail/README.md` (« Mesures »).

## 11. Hôte `lyxal-groupware`

### 11.1. Branchement

* Écoute `protocol = "smtp"` : `SmtpInboundHandler` (de `lyxal_mail::smtp`) à la place de
  `UnavailableHandler` ; `submission`, `imap`, `pop3`, `managesieve` inchangés (refus poli).
* L'hôte construit et remet au handler : `HickoryResolver` (un par nœud), `DeliveryPipeline`
  (§12), `MailStore` de la **session système** (comme la maintenance : la session système passe
  `fn::mail_can({ action: "worker" })` ; aucun compte de service à créer), `MemoryBudget`,
  liste de blocage partagée (`BlockList`, rafraîchie par un worker `lyxal_mail:mail.block_refresh`,
  criticité `Optional`, toutes les 30 s).
* `MailIngest` : antivirus retiré de son `StorageService` (l'antivirus passe une fois par message
  dans la chaîne, S9) ; bucket `lyxal-mail` créé avec `emit_events: false` (S14).
* Tâche `mail.maintenance` : `fn::mail_delivery_purge` ajoutée au passage.
* `GROUPWARE_MASTER_KEY_MISSING` (5-0), `GROUPWARE_DNS_UNAVAILABLE` (configuration DNS du système
  illisible, ou aucun serveur DNS, quand une écoute `smtp` existe).

### 11.2. Configuration

| Section | Réglages |
| :--- | :--- |
| `smtp` | `hostname` (**obligatoire** dès qu'une écoute `smtp` existe : bannière, `Received`, `authserv-id` ; nom de domaine valide, forme ASCII), limites du §7.6, `dmarc_enforce` (`true` : applique `reject` et `quarantine` ; `false` : résultat seulement, pour une mise en service progressive) |
| `dns` | `servers` (liste `ip[:port]`, vide = configuration du système), `timeout_seconds` (5, 1 à 30), `attempts` (2, 1 à 5), `cache_size` (16 384, 0 à 1 000 000) |
| `storage.antivirus` | Inchangé (§1.1) : sert à la chaîne de remise |

`development.toml` : `smtp.hostname = "localhost"` ; `production.toml` : écoute du port 25
décommentée en exemple, `hostname` à renseigner.

### 11.3. Santé, mesures, journal

* Sonde de `lyxal_mail` : « dégradé » si l'antivirus configuré est injoignable, si le DNS échoue
  sur un nom témoin de l'installation (`hostname`, toutes les minutes), si aucun nœud
  `lyxal_server` n'est vivant (§1.3).
* `/metrics` : par écoute SMTP, sessions, messages acceptés, refusés par motif (relais, inconnu,
  quota, taille, DMARC, antivirus, contrebande, limites), destinataires acceptés, résultats SPF /
  DKIM / DMARC, remises dupliquées évitées, conflits et rejeux, durée de la remise ; DNS
  (requêtes, pannes, cache) ; bannissements actifs. Aucune adresse.
* Journal : une ligne par transaction (identifiant de session, réseau masqué, résultats des
  contrôles, nombre de destinataires, taille, décision, code SMTP) ; **ni adresse e-mail, ni
  sujet, ni contenu** ; les adresses complètes seulement au niveau `debug` avec `log_client_ip =
  "full"`, comme au lot 3.

## 12. Chaîne de remise (`lyxal_mail::delivery`, décisions S9, S10)

Ordre **fixé par le type** (structure à champs nommés appelés dans cet ordre, jamais une liste
reconfigurable), décision P15 :

| # | Étape | Au lot 5 | Plus tard |
| :- | :--- | :--- | :--- |
| 1 | **Antivirus** | Une analyse par message (pas par destinataire) par le `ContentScanner` de `lyxal_storage` (`ClamAvScanner`), sur le message en clair, avant tout dépôt. Infecté : `554 5.7.1`, aucun dépôt, aucune quarantaine. Antivirus configuré mais injoignable : `451 4.3.0`. Sans antivirus : `not_scanned` | — |
| 2 | **Anti-spam** | Étape posée, vide : verdict `none`, score absent | lot 11 |
| 3 | **Filtres** | Choix du dossier : `junk` si DMARC `quarantine` appliqué (§7.5), sinon `inbox` ; aucune règle d'utilisateur | Sieve, lot 10 ; verdict anti-spam, lot 11 |
| 4 | **Index** | Étape posée, vide | lot 9 |
| 5 | **Chiffrement** | Niveau A : `MailIngest` écrit chaque copie chiffrée par `lyxal_storage` (clé par fichier) ; `protection = "platform"` | niveau B (OpenPGP), lot 12 bis |

Puis le dépôt par compte : `fn::mail_delivery_begin` → `StorageService::put` → `fn::mail_delivery_commit`
(groupé, §10.3). Un contenu par compte (M14). Réponse unique au client (décision **S8**) :

| Résultat des comptes | Réponse |
| :--- | :--- |
| Tous inscrits (ou déjà inscrits : `duplicate`) | `250 2.0.0 <identifiant de session>` |
| Au moins un échec, quel qu'il soit | `451 4.3.0` ; l'expéditeur réessaie ; les comptes déjà servis sont reconnus par l'idempotence (§9.4) ; un destinataire devenu invalide est alors refusé dès `RCPT TO` |
| Refus par la politique ou l'antivirus (avant tout dépôt) | le code du §7.5 ou de l'étape 1 |

Types Rust : `DeliveryPipeline { antivirus, spam, filters, index, encryption }`, `ReceivedMessage`
(octets, enveloppe SMTP, résultats d'authenticité, état TLS), `DeliveryVerdict` (`Deliver { role
}`, `Reject { code }`, `TempFail`), `DeliveryOutcome` (par compte), `AccountQueue` (ordre par
compte, §10.3).

## 13. Types Rust et wrappers (`lyxal_mail`)

| Élément | Contenu |
| :--- | :--- |
| `models/reception.rs` | `RecipientResolveParams` / `ResolvedRecipient { address, domain, tenant, max_message_bytes, accounts: Vec<RecipientAccount { account, quota_full }> }` ; `DeliveryBeginParams` / `DeliveryReservation` (`Reserved { content, storage_key }` ou `Duplicate { message }`) ; `DeliveryCommitParams { account, items: Vec<DeliveryItem> }` / `DeliveryCommitResult { items: Vec<DeliveryItemResult> }` ; `Reception { spf, dkim, dmarc, iprev, antivirus, spam, tls }` |
| `models/block.rs` | `BlockCreateParams` / `NetworkBlock`, `BlockListParams` / `BlockPage`, `BlockDeleteParams`, `BlockActiveParams` / `ActiveBlocks` |
| `MailStore` | Un wrapper d'une ligne par fonction : `recipient_resolve`, `delivery_begin`, `delivery_commit`, `delivery_purge`, `block_create`, `block_list`, `block_delete`, `block_active` (`self.call_fn("mail_delivery_commit", params).await`) ; `address_resolve` retiré |
| `dns` | `MailResolver`, `HickoryResolver`, `StaticResolver` (essais), `DnsError`, `DnsConfig` |
| `auth` | `SpfVerifier`, `SpfOutput`, `SpfResult` ; `DkimVerifier`, `DkimOutput`, `DkimResult` ; `DmarcVerifier`, `DmarcRecord`, `DmarcOutput`, `DmarcPolicy`, `Alignment` ; `Iprev` ; `AuthenticationResults` (écriture) ; `OrganizationalDomain` (S4) |
| `smtp` | `SmtpInboundHandler` (`SessionHandler`), `SmtpConfig`, `SmtpLimits`, `SmtpSession` (états du §7.1), `TransactionEnvelope`, `BlockList`, `SmtpMetrics` |
| `delivery` | §12 |
| `MailError` | Codes du §9.6 ajoutés ; `is_retryable()` vrai pour `MAIL_SCANNER_UNAVAILABLE` |

Aucun `panic!`, aucun `raw_query()`, aucune tâche hors `LyxalWorker` et `JoinSet` de l'écoute.
Nouvelles dépendances de `lyxal_mail` : `lyxal_mail_proto` (déjà), `hickory-resolver` 0.26,
`idna` 1.1, `lyxal_crypto` (DKIM, BLAKE3 : `lyxal_crypto` est permis dans un module, seules les
crates cryptographiques directes sont interdites), crate de la liste des suffixes publics (S4).

## 14. Banc de tests

**SurrealQL** (`crates/lyxal_mail/tests/`) : `reception.test.surql` (résolution : relais refusé,
inconnu, désactivé, sous-adresse, alias, attrape-tout, `postmaster` avec et sans domaine, quota
plein, taille de l'organisation ; remise : début, doublon, lot de 32, élément en erreur sans
annuler les autres, lot de 33 refusé, `origin`, `reception`, compteurs égaux au contenu ;
événement `mail.message.received` publié une fois par compte, sans adresse ni sujet ; aucun
événement pour une copie, un déplacement ou un `append`), `blocages.test.surql` (CIDR valide et
invalide, doublon, expiration, droits manuel / automatique), `droits` complété (aucune des
nouvelles fonctions pour un membre, un administrateur d'organisation ou une autre organisation),
`organisations` complété. `lyxal_storage` : `fn::storage_encrypted_bucket_exists`, option
`emit_events`.

**Rust** :

* `lyxal_mail_proto` : syntaxe (toutes les commandes et paramètres, erreurs), `DATA` (bourrage,
  fins isolées, toutes les variantes de contrebande, octet nul), `BDAT`, réponses ; propriétés ;
  cibles de fuzzing.
* `lyxal_mail::auth` : SPF (cas de Mox `spf_test.go` transposés, macros, limites, boucles
  d'`include`, réponses vides, pannes) ; DKIM (vecteurs RFC 6376 et 8463, corpus de `mail-auth`
  déjà dans `lyxal_crypto`, cas de Mox, `l=`, `x=` échu, `t=` futur, clé révoquée, plusieurs
  signatures, `h=` sans `From`) ; DMARC (cas de Mox, matrice d'alignement souple / strict × SPF /
  DKIM, domaine d'organisation, `sp`, `pct`, plusieurs `From`) ; `iprev` ;
  `Authentication-Results` (syntaxe RFC 8601, échappement) ; oracle S2 (à la main).
* `lyxal_mail::smtp` (dialogues scriptés sur une vraie socket, base embarquée, `StaticResolver`) :
  conformité par commande et par état (codes du §7) ; `PIPELINING` (réponses dans l'ordre, groupe
  qui finit par `DATA`) ; `SIZE`, `8BITMIME`, `SMTPUTF8` (domaine U-label, partie locale UTF-8),
  `CHUNKING` ; STARTTLS (mise à niveau, injection refusée) ; limites et délais ; recherche
  d'adresses puis bannissement ; liste de blocage lue par un second nœud.
* **Usurpation** : `From` de notre domaine publié en `p=reject` depuis une adresse étrangère sans
  DKIM (refus) ; signature DKIM valide d'un autre domaine (DMARC `fail`) ; `Authentication-Results`
  forgé avec notre `authserv-id` (retiré) ; injection d'en-tête par `HELO` et par le nom inverse ;
  `From` multiple ; contrebande SMTP ; relais vers un domaine extérieur, `user%autre@nous`,
  `@a,@b:x@nous`, `[127.0.0.1]` (tous refusés).
* **Interopérabilité automatique** : client `lettre` 0.11 (déjà dans l'arbre, MIT, en dépendance
  d'essai de l'hôte) en clair et en STARTTLS ; client scripté qui reproduit les dialogues de Postfix
  et d'Exim (dialogues relevés dans leurs documentations, à vérifier) ; client `swaks` et serveur
  Postfix en conteneur, **à la main** (licences des outils non vérifiées, P10).
* **Remise** : chaîne complète (antivirus sur faux `clamd` des essais de `lyxal_storage` : sain,
  EICAR refusé, service muet → `451`) ; échec partiel → `451`, puis nouvel essai sans doublon ;
  dossier `junk` sur DMARC `quarantine` ; remises concurrentes dans un compte sur deux nœuds (UID
  uniques, compteurs exacts).
* `lyxal-groupware` : configuration (`[smtp]`, `[dns]`, refus) ; démarrage refusé sans clé
  maîtresse quand un bucket chiffré existe ; bout en bout du binaire (port 25 de développement,
  message reçu, lu par le service du courrier, événement publié) ; deux hôtes.
* `lyxal_host` et `lyxal-server` (5-0) : configuration commune, essais existants inchangés.
* **Charge** : §10.5, hors CI.

`scripts/ci/ci_local.sh` vert avant chaque demande de fusion ; `cargo deny check licenses` (arbre
de `hickory-resolver`, `idna`, liste des suffixes publics) ; `check_crypto_dependencies.py` ;
`check_agpl_isolation.py`.

## 15. Découpage en demandes de fusion (décision S20)

| PR | Contenu | Touche | Taille estimée |
| :- | :--- | :--- | :-: |
| **5-0** | Configuration commune (§1.1), `fn::storage_encrypted_bucket_exists` et refus de démarrer (§1.2), option `emit_events` (S14), exploitation à deux hôtes (§1.3) | `lyxal_host`, `lyxal_storage`, `lyxal-server`, `lyxal-groupware` | M |
| **5a** | `lyxal_mail_proto::smtp`, fuzzing, essais, `SOURCES.md` | `lyxal_mail_proto` | M |
| **5b** | `lyxal_mail::dns`, `lyxal_mail::auth`, oracle S2, `SOURCES.md` | `lyxal_mail`, `crates/lyxal_mail/tools/dkim_oracle` | M |
| **5c** | SurrealQL (§9), dépôt groupé et ordre par compte (§10.3), mesure et cache des clés (S13), banc SurrealQL, mesures | `lyxal_mail`, `lyxal_secrets` | M |
| **5d** | Session SMTP, chaîne de remise, branchement de l'hôte, essais de bout en bout et d'usurpation, mesures de charge, documents | `lyxal_mail`, `lyxal-groupware` | L |

Ordre : 5-0, 5a et 5b en parallèle, puis 5c, puis 5d. Chaque demande compile, passe la CI et
laisse le dépôt cohérent. Taille totale : **L** (6 000 à 12 000 lignes, tests compris), conforme
au programme.

## 16. Documents mis à jour

`crates/lyxal_mail/{README,ROADMAP,SOURCES}.md` (réception, mesures, points du lot 4 traités
retirés, essais réels du lot 5 gardés) ; `crates/lyxal_mail_proto/{README,ROADMAP,SOURCES}.md`
(syntaxe SMTP portée) ; `crates/lyxal_storage/README.md` (fonction, option) ;
`crates/lyxal_secrets/README.md` (cache, si retenu) ; `crates/lyxal_crypto/{README,ROADMAP}.md`
(oracle fait) ; `crates/lyxal_host/README.md` ; `apps/lyxal-groupware/{README,ROADMAP,SOURCES}.md`
et `docs/PRODUCTION-CHECKLIST.md` (port 25, DNS, `hostname`, deux hôtes) ;
`apps/lyxal-server/README.md` (réglage déplacé) ; `.agents/AGENTS.md` §6 (`lyxal_mail` : réception
SMTP ; `lyxal_mail_proto` : SMTP) ; `docs/14-roadmap/ROADMAP_NOYAU.md` ; `implementation_plan.md`
racine (lot 5 réalisé). Ce plan est supprimé après la fusion de 5d.

## 17. Risques

| Risque | Ce qu'il faut savoir | Parade |
| :--- | :--- | :--- |
| **Relais ouvert** | Un serveur qui réexpédie pour n'importe qui est sur les listes noires en quelques heures | Aucun envoi au lot 5 ; seuls les domaines actifs de l'installation sont acceptés ; alias internes seulement ; essais d'usurpation et de relais (§14) ; essai réel d'une semaine (ROADMAP) |
| **Rétrodiffusion** (« backscatter ») | Accepter puis renvoyer un avis à une adresse forgée fait de nous un émetteur de spam | Tout refus pendant la session ; aucun avis produit ; S8 préfère `451` à l'acceptation partielle |
| **Contrebande SMTP et fins de ligne** | Un message caché dans un autre par une fin de `DATA` lue différemment de part et d'autre | Fin reconnue sur `CRLF.CRLF` seulement, refus de toute fin isolée (S7), fuzzing, variantes publiées essayées |
| **Épuisement des ressources** | Connexions lentes, `DATA` géants, milliers de destinataires, SPF qui multiplie les requêtes DNS, signatures DKIM en nombre, messages MIME piégés | Budget mémoire du lot 3, délais et débit minimal, plafonds du §7.6, limites de la RFC 7208, 5 signatures au plus, limites MIME du lot 4, bannissement |
| **Usurpation et faux positifs DMARC** | Listes de diffusion et transferts cassent SPF et parfois DKIM ; sans ARC (lot 7), un message légitime peut être refusé pour un domaine en `p=reject` | `dmarc_enforce` désactivable pour la mise en service ; ARC au lot 7 ; essais réels |
| **Débit non tenu** | L'objectif de 300 par seconde n'est pas garanti sur un serveur SurrealDB distant | Mesures en 5c et 5d sur les deux moteurs ; repli §10.3 sur décision |
| **Perte de message** | Un `250` donné avant l'inscription durable serait une perte en cas de panne | `250` seulement après l'inscription de tous les comptes ; panne entre deux étapes : `451` et maintenance du lot 4 |
| **Doublons** | `451` après un succès partiel fait réessayer l'expéditeur | Idempotence par empreinte (§9.4), 7 jours |
| **Dépendance au DNS** | Résolveur lent ou en panne : `temperror`, messages différés | Délais, cache, `451` seulement quand DMARC `reject` est en jeu ; sonde « dégradé » |
| **Licence de la liste des suffixes publics** | La liste est sous MPL-2.0, absente de `deny.toml` | Décision S4 |
| **Port 25** | Attaqué en permanence ; certains hébergeurs le bloquent | Hôte dédié (P3), limites, essais réels sur ordre du CTO (P11) |

## 18. Essais réels (ROADMAP, décision P12)

Ceux de `crates/lyxal_mail/ROADMAP.md` pour le lot 5 sont gardés (réception depuis Gmail,
Outlook.com, Yahoo ; port 25 ouvert une semaine). Ajouts : envoi depuis un domaine en
`p=reject` par une liste de diffusion (refus attendu sans ARC, puis remise avec
`dmarc_enforce = false`) ; envoi depuis un serveur Postfix et un serveur Exim réels ; `swaks`
avec contrebande SMTP contre le serveur exposé ; antivirus ClamAV réel avec la signature EICAR.

## 19. Ce qui n'a pas pu être vérifié

* Contenu exact des fonctions de `mail-auth` 0.16.0 à porter (SPF, DMARC, lecture DKIM,
  `Authentication-Results`) : non relu dans ce plan (clone absent de `.sources/`) ; taille à mesurer
  en 5b.
* Comportement de Stalwart et de Mox sur les `Authentication-Results` portant notre `authserv-id`
  (retrait ou renommage) ; valeur de `max_messages_per_session` chez Stalwart.
* Crate de la liste des suffixes publics : nom (`psl` ou autre), licence déclarée et licence des
  données (MPL-2.0 dans Mox, `LICENSE.MPLv2.0`), mode de mise à jour ; `psl-types` 2.0.11 est déjà
  dans `Cargo.lock` (origine non relevée).
* Fonctionnalités exactes de `hickory-resolver` 0.26.3 (bornes de TTL, taille du cache, lecture de
  `/etc/resolv.conf` sous conteneur) ; coût des fonctionnalités DNSSEC (lot 7).
* État de DMARCbis (remplaçant de la RFC 7489, sans liste des suffixes publics) : publication non
  vérifiée ; le lot 5 suit la RFC 7489.
* Numéros des avis de contrebande SMTP de décembre 2023 (Postfix, Sendmail, Exim) et liste exacte
  des variantes : de mémoire.
* Suite d'essais SPF de la RFC 7208 (projet `pyspf`, format YAML) : licence non vérifiée, non
  retenue tant qu'elle ne l'est pas.
* Licences de `swaks` et des images Postfix / Exim pour les essais à la main (P10).
* Possibilité, dans SurrealDB 3.3.4, de garantir par le seul schéma la forme de `envelope` et
  `structure` (S12) avec le même message d'erreur ; à essayer en 5c.
* Gain réel de l'ordre par compte et de l'écriture groupée : estimé, à mesurer (§10.5).

## 20. Décisions du CTO

| N° | Question | Recommandation |
| :- | :--- | :--- |
| **S1** | SPF, DKIM, DMARC : bibliothèque `mail-auth` ou code propre ? | **Code propre dans `lyxal_mail`**, porté des parties non cryptographiques de `mail-auth` 0.16.0 (`Apache-2.0 OR MIT`, avis gardés), cas d'essai de Mox ; toute la cryptographie par `lyxal_crypto::dkim` (règle 13) ; `mail-auth` reste interdit en dépendance |
| **S2** | Comparaison avec `mail-auth` (point ouvert de `lyxal_crypto`) | Outil `crates/lyxal_mail/tools/dkim_oracle/` hors workspace, `mail-auth` au commit `c862df2`, lancé à la main avant la fusion de 5b et avant le lot 22 ; résultats dans les README |
| **S3** | Résolveur DNS et cache | `hickory-resolver` 0.26 sans DNSSEC (lot 7), une instance par nœud, cache intégré de 16 384 entrées, TTL bornés (1 h, 5 min en négatif), aucun cache en base ; résolveur récursif local recommandé en production |
| **S4** | Domaine d'organisation (DMARC) : liste des suffixes publics | Crate permissive embarquant la liste si sa licence le permet, sinon fichier de la liste copié sous MPL-2.0 avec exception nommée dans `deny.toml` ; version figée, mise à jour par plan (P14) |
| **S5** | Extensions annoncées | `PIPELINING`, `SIZE`, `8BITMIME`, `SMTPUTF8`, `ENHANCEDSTATUSCODES`, `STARTTLS`, `CHUNKING` ; pas de `DSN` ni `AUTH` (lot 6), ni `BINARYMIME`, `REQUIRETLS` |
| **S6** | Politique de refus | Jamais de refus sur SPF ou DKIM seuls ; DMARC `reject` → `550` ; `quarantine` → dossier « Junk » ; `temperror` avec `reject` → `451` ; `iprev` informatif ; `From` absent ou multiple → `550` ; `dmarc_enforce` désactivable par l'exploitant |
| **S7** | Fins de ligne isolées (contrebande SMTP) | Refus du message (`500 5.5.2`, comme Mox), session poursuivie, erreur comptée, bannissement après récidive |
| **S8** | Échec partiel après `DATA` sans file d'envoi | `451` à tous et **idempotence** par empreinte (table `mail_delivery`, 7 jours) ; aucun avis de non-remise avant le lot 6 |
| **S9** | Antivirus | Une analyse par message, première étape, sur le clair ; infecté → `554 5.7.1` (aucune quarantaine) ; antivirus configuré injoignable → `451` ; plus de seconde analyse par copie dans `lyxal_storage` |
| **S10** | Ordre de remise et étapes vides | Ordre fixé par le type : antivirus → anti-spam (vide) → filtres (choix « Junk » par DMARC) → index (vide) → chiffrement (niveau A) |
| **S11** | Débit et contention (P7, M6) | Garder le compteur **par compte** ; ordre des remises par compte dans le nœud, écriture groupée (32), deux fonctions de remise ; repli « compteur par dossier et journal » seulement si la mesure à deux nœuds dépasse 1 % de refus |
| **S12** | Contrôle allégé des paramètres de remise | Moteur du Core sur les champs scalaires ; forme détaillée de l'enveloppe et de la structure garantie par le schéma de la table, pour la seule fonction du service de remise ; validation complète gardée pour `fn::mail_message_create` |
| **S13** | Cache des clés « fichiers » (M19) | Mesurer en 5c ; si plus de 2 ms ou 10 % d'une remise : cache dans `FileKeys`, 60 s, 1 024 entrées, usage `files` seulement, jamais pour sceller avec une clé qui n'est plus active ; sinon pas de cache |
| **S14** | Événements `storage.object.*` du courrier | Option de bucket `emit_events` (vrai par défaut, fixée à la création) dans `lyxal_storage` ; faux pour `lyxal-mail` |
| **S15** | Événement `mail.message.received` | Un par compte destinataire, publié par un `DEFINE EVENT` sur `origin = "delivery"`, sans adresse ni sujet (charge utile du §9.5) |
| **S16** | Adresses internationales (M10) | `SMTPUTF8` annoncé ; domaines convertis en A-label en Rust (`idna`) ; parties locales UTF-8 inconnues (`550 5.1.1`) ; **aucune extension du Core** au lot 5, question rouverte au lot 13 |
| **S17** | Attrape-tout et `postmaster` | Attrape-tout par domaine, **désactivé par défaut** ; champ `postmaster` par domaine et réglage d'installation pour `<postmaster>` sans domaine (RFC 5321 §4.5.1) |
| **S18** | Liste de blocage, bannissement, limites entre nœuds | Table de l'installation lue toutes les 30 s par chaque nœud ; bannissement automatique de 1 h à 24 h ; compteurs de cadence par nœud (lot 3) |
| **S19** | Limites SMTP par défaut | Valeurs du §7.6 |
| **S20** | Découpage | Cinq demandes de fusion 5-0, 5a à 5d (§15) |

## Checklist (`.agents/rules/lyxal_standards_and_checklist.md` §13)

* [ ] **Architecture** : syntaxe dans `lyxal_mail_proto` ; session, DNS, authenticité, remise et
  données dans `lyxal_mail` ; configuration commune dans `lyxal_host` ; aucun cycle
  (`lyxal_host` → `lyxal_storage`, `lyxal_secrets` ; `lyxal_mail` → `lyxal_crypto`) ; aucun code
  AGPL dans un crate permissif.
* [ ] **Core** : entrées par `fn::validation_object_execute` / `fn::sanitize_object_execute` ;
  IP et réseaux par `fn::validation_ip` / `fn::validation_cidr` ; IDNA traité en Rust (S16),
  rien d'ajouté au Core ; S12 soumis au CTO.
* [ ] **SurrealQL** : `fn::mail_<action>($params: object)`, `fn::result_ok` / `fn::error_result`,
  `COMMENT`, moins de 300 lignes, écritures vérifiées (`MAIL_WRITE_FORBIDDEN`), banc complet.
* [ ] **Rust** : `XxxParams` / `XxxResult`, wrappers `store.call_fn`, aucun `panic!`, aucun
  `raw_query()` métier, aucun secret exposé, workers supervisés seulement.
* [ ] **Erreurs** : 8 codes `MAIL_*` et 2 codes `GROUPWARE_*` nouveaux en master data ; aucune
  erreur silencieuse (chaque refus SMTP journalisé et compté).
* [ ] **Événements** : `mail.message.received` par `fn::event_publish` vérifié ; charge sans donnée
  personnelle ; aucun consommateur connu.
* [ ] **Cryptographie** : DKIM par `lyxal_crypto::dkim`, BLAKE3 par `lyxal_crypto::hash` ;
  aucune crate cryptographique directe (`mail-auth` exclu) ; cache de clés en `SecretBytes`.
* [ ] **Chiffrement des boîtes** : ordre de remise posé ; niveau A appliqué ; aucun contrat ne
  suppose le contenu lisible au-delà de la remise `platform`.
* [ ] **Zéro dette** : `fn::mail_address_resolve` remplacé sans alias ; réglage de stockage de
  `lyxal-server` déplacé sans alias ; schéma réécrit en place ; plan supprimé après fusion ;
  `ROADMAP.md` tenue.
* [ ] **Provenance** : `SOURCES.md` des deux crates (Stalwart `smtp-proto`, `smtp/inbound` ;
  `mail-auth` ; Mox) ; aucune partie `LicenseRef-SEL`.
* [ ] **Validation CTO** : ce plan, décisions S1 à S20.

À valider par le CTO.
