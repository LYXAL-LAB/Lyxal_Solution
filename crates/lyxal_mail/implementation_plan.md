# Plan d'implémentation — programme courrier, agendas et contacts, lot 6 (envoi)

Plan détaillé du lot 6 du programme courrier, agendas et contacts (`implementation_plan.md` à la
racine, §4, §5 ligne « 6. Envoi », décisions **P2**, **P3**, **P6**, **P11**, **P12** ; décisions
**S1** à **S20** du lot 5) : le serveur envoie enfin du courrier, sans fournisseur.

| Brique | Ce que c'est, en clair | Où |
| :--- | :--- | :--- |
| TLS côté client | Chiffrer la connexion vers un serveur de courrier distant (STARTTLS) | `lyxal_crypto` (extension C8 prévue au lot 2, détail à valider ici) |
| Syntaxe SMTP côté client | Écrire nos commandes, lire les réponses d'un serveur distant, bourrer le `DATA` ; lire `AUTH` côté serveur ; écrire et lire les avis de non-remise | `lyxal_mail_proto::smtp`, `lyxal_mail_proto::dsn` |
| File d'envoi | Garder chaque message à envoyer jusqu'à son envoi, son échec définitif ou son expiration ; tentatives espacées ; reprise après un arrêt brutal | SurrealQL de `lyxal_mail` (tables propres) |
| Envoi vers les MX | Trouver le serveur du destinataire (MX, A, AAAA), s'y connecter, chiffrer si possible, envoyer | `lyxal_mail::outbound`, worker supervisé |
| Dépôt authentifié | Ports 587 et 465 : un logiciel (Thunderbird, Apple Mail…) envoie avec un mot de passe d'application | `lyxal_mail::submission`, hôte `lyxal-groupware` |
| Signature DKIM | Signer chaque message sortant au nom de son domaine | `lyxal_mail::dkim` (cryptographie : `lyxal_crypto::dkim`, clés : `lyxal_secrets`) |
| Avis de non-remise | Prévenir l'expéditeur d'un échec ou d'un retard ; lire les avis reçus | `lyxal_mail::dsn`, `lyxal_mail_proto::dsn` |
| Adresses de retour | Adresse d'enveloppe propre à chaque envoi, seule à recevoir les avis : protège de la rétrodiffusion | SurrealQL et Rust de `lyxal_mail` |
| Contrat public de dépôt | Permettre à `lyxal_notification` (et aux agendas, lot 18) d'envoyer par Lyxal, sans lier de code AGPL | Fonctions `fn::mail_submission_*` et `lyxal_storage` |

**Ce que fait un lot 6 fusionné, concrètement** : un membre d'une organisation configure
Thunderbird avec un mot de passe d'application (lot 1) sur le port 587 ou 465 de
`lyxal-groupware` et envoie un message. Le serveur vérifie qu'il a le droit d'écrire sous
l'adresse de son `From` (une usurpation, même interne, est refusée), signe le message en DKIM au
nom du domaine, le range chiffré dans la file, puis le remet : directement dans la boîte du
destinataire s'il est hébergé sur l'installation (même organisation ou autre), sinon au serveur
MX du destinataire, en STARTTLS quand il est offert. En cas de refus temporaire, le message est
retenté pendant 5 jours au plus ; un échec définitif ou un long retard dépose un avis de
non-remise dans la boîte de l'expéditeur. Les avis qui reviennent d'Internet n'arrivent que sur
l'adresse de retour à jeton propre à l'envoi : un avis forgé adressé à une vraie adresse est
refusé. Un module du noyau (d'abord `lyxal_notification`, dans son propre plan) peut déposer un
message par deux fonctions SurrealQL et une écriture de fichier par `lyxal_storage`, et suit le
sort de son envoi par les événements `mail.submission.*`. Le port 25 ne relaie toujours rien.

Touche : `crates/lyxal_crypto` (TLS côté client), `crates/lyxal_mail_proto` (syntaxe client,
`AUTH`, DSN), `crates/lyxal_mail` (SurrealQL et Rust), `crates/lyxal_auth` (une permission
déclarée par `lyxal_mail`, aucun code), `apps/lyxal-groupware` (écoutes `submission`, worker
d'envoi, configuration), `Cargo.toml`, `deny.toml` (aucune licence nouvelle attendue), documents.
`lyxal_booking/` n'est pas touché. `lyxal_notification` n'est pas touché : son fournisseur
« serveur de courrier Lyxal » est l'objet de son propre plan, après ce lot (programme §9).
Aucune ligne de code avant la validation de ce plan par le CTO (`.agents/AGENTS.md` §3).

Méthode : constats faits **par lecture** du dépôt (programme ; plan du lot 5 au commit
`13cf85ee8` ; `crates/lyxal_mail` : `README.md`, `ROADMAP.md`, `SOURCES.md`, `manifest.toml`,
`Cargo.toml`, schéma, liste des fonctions et des erreurs, `src/dns`, `src/smtp`, `src/delivery`,
`src/ingest.rs` ; `crates/lyxal_mail_proto/src/smtp` et ses documents ;
`crates/lyxal_crypto/API_CONTRACT.md` (DKIM, HMAC, TLS serveur) et `ROADMAP.md` ;
`scripts/ci/check_crypto_dependencies.py`, `scripts/ci/check_agpl_isolation.py`, `deny.toml`,
`Cargo.lock` ; `crates/lyxal_auth` (README §3 ter, `src/services/app_password.rs`,
`src/services/keys.rs`) ; `apps/lyxal-server/src/modules/auth.rs` ; `crates/lyxal_secrets`
(README, `SecretsClient`, `FileKeys`) ; `crates/lyxal_scheduler` (README, réservation) ;
`crates/lyxal_notification` (README : canal SMTP, file `notification_job`) ;
`apps/lyxal-groupware` (configuration, écoutes, services)), des sources figées dans `.sources/`
(copie triée de Stalwart `3adead9`, sans `LicenseRef-SEL` ; Mox `b32f0de`) et de KumoMTA, cloné
pour ce plan depuis GitHub (commit `81f191dff648`, 11 nov. 2026, `Apache-2.0`, clone partiel hors
du dépôt). Fichiers lus en détail : Stalwart `crates/smtp/src/queue/{mod,lease,throttle}.rs`,
tailles et en-têtes de `queue/*` et `outbound/*`, valeurs par défaut de
`crates/common/src/config/smtp/queue.rs` et de `crates/registry/src/schema/structs_impl.rs`
(tentatives, expiration, MX, délais) ; Mox `queue/queue.go` (modèle `Msg`, reculs, nombre de
tentatives, livraisons simultanées), `queue/dsn.go`, `smtpclient/gather.go`,
`smtpclient/client.go` (modes TLS, `PIPELINING`), `mox-/config.go` (en-têtes signés par DKIM) ;
KumoMTA `docs/reference/kumo/make_egress_path/*` (limites par destination, délais, TLS),
`crates/kumod/src/queue/config.rs` (reculs, âge maximal), `crates/kumod/src/ready_queue.rs`
(nom de « site » tiré des MX). **Rien n'a été compilé ni exécuté.** Ce qui n'est pas vérifié est
listé au §23.

**Règle de provenance (programme §4.1, P2)** : tout ce qui vient de Stalwart (AGPL), de Mox
(MIT) ou de KumoMTA (Apache-2.0) ne va que dans `lyxal_mail_proto` et `lyxal_mail`
(`AGPL-3.0-only`) et dans `apps/lyxal-groupware`, inscrit dans leurs `SOURCES.md`. L'extension de
`lyxal_crypto` est écrite pour Lyxal depuis la documentation de `rustls` et reste sous
`MIT OR Apache-2.0`. Aucune partie `LicenseRef-SEL` : `crates/smtp/src/queue/tenant.rs` (quotas
de file par organisation) est absent de la copie triée, et les extraits retirés de
`queue/{mod,spool,encrypt}.rs` ne sont pas recherchés ailleurs ; les quotas d'envoi par compte et
par organisation de ce plan sont écrits pour Lyxal (§9.4).

## Bilan de réutilisation (`AGENTS.md` §3, §5.7)

**Fonctions `lyxal_core` réutilisées** (toutes présentes dans le dépôt, vérifié par la liste des
définitions de `crates/lyxal_core/functions/`) :

| Besoin | Fonction ou règle du Core |
| :--- | :--- |
| Entrées des fonctions publiques nouvelles | `fn::validation_fields_execute` (fonctions du chemin d'envoi, appelées à chaque message, comme au lot 5), `fn::validation_object_execute` et `fn::sanitize_object_execute` (fonctions d'administration), `fn::validation_checks_report` (éléments des lots de la file : fonctions du worker appelées par lots, **sur décision du CTO**, §14.5) |
| Adresses | `fn::validation_email`, `fn::sanitize_email`, `fn::sanitize_email_local`, `fn::sanitize_email_domain`, règles `lowercase`, `trim`, `ascii` |
| Domaines, noms d'hôte, sélecteurs DKIM | `fn::validation_domain`, `fn::validation_hostname`, `fn::sanitize_domain`, règle `slug` (sélecteur) |
| Adresses IP des réponses enregistrées | `fn::validation_ip` |
| Références opaques d'un module (`client_reference`) | `fn::validation_identifier`, `fn::validation_max_length` ; `fn::security_detect_header_injection` (aucun CR ni LF) |
| Clé publique DKIM rangée | `fn::validation_base64`, `max_length` |
| Bornes, identifiants, dates, états | `record`, `integer`, `integer_range`, `non_negative_number`, `enum`, `boolean`, `datetime`, `array_length`, `array_unique`, `max_serialized_length` |
| Journal sans donnée personnelle | `fn::security_redact_email`, `fn::security_redact_ip` (messages d'erreur internes ; jamais dans un événement) |

**Fonctions métier nouvelles** : 21 fonctions publiques `fn::mail_*` nouvelles, 5 étendues et
6 internes (§14.2, §14.3).

**Fonctions Core éventuellement manquantes** (signalées, **non ajoutées**) : aucune pour ce lot.
Le point du lot 5 sur la forme canonique d'une plage CIDR (`ROADMAP.md`) reste ouvert, sans lien
avec l'envoi.

**`lyxal_crypto`** : **une extension**, déjà inscrite à sa feuille de route pour ce lot (« TLS
côté client — lot 6 (C8) ») et détaillée au §4 pour validation : `tls_client_config`. Le reste
utilise des primitives existantes : `lyxal_crypto::dkim` (`DkimBodyHasher`,
`DkimHeaderCanonicalizer`, `DkimSigningKey::sign`, `public_key_record_bytes`, `DkimPublicKey`
pour l'essai de vérification), `RsaSigningKey::generate` (hors de la boucle asynchrone,
`spawn_blocking`, règle 12), `Ed25519SigningKey::generate`, `export_pkcs8` (pour le rangement
dans `lyxal_secrets` seulement), `import_pkcs8`, `hash::blake3` (empreinte courte des destinations
au journal, idempotence de la route locale) ; jetons des adresses de retour tirés par
`rand_core::OsRng` (règle 7). Aucun HMAC n'est nécessaire (décision **E20**). `mail-auth` n'est
jamais une dépendance ; `lettre` (qui sert `lyxal_notification`) n'est pas utilisé par le courrier.

## 0. Écarts au plan du programme

| # | Écart | Raison |
| :- | :--- | :--- |
| X1 | `REQUIRETLS` est la **RFC 8689** (et non 8058, qui décrit `List-Unsubscribe-Post`) ; il est reporté au lot 7 | Un message `REQUIRETLS` exige un TLS **vérifié** par MTA-STS ou DANE (RFC 8689 §4) : sans ces contrôles (lot 7), l'honorer reviendrait à le faire échouer partout. Au lot 6, le paramètre est lu et refusé, l'extension n'est pas annoncée (décision **E26**). Numéro relevé dans Mox (`queue/queue.go`, renvois `../rfc/8689`) |
| X2 | Événements `mail.submission.delivered`, `.delayed`, `.failed`, `.bounced` au lieu de `mail.message.delivered` et `mail.message.bounced` | `mail.message.*` désigne déjà les messages des boîtes (`mail.message.received`) ; l'entité de l'envoi est la soumission (décision **E27**) |
| X3 | Le lot touche `lyxal_crypto` et fait héberger à `lyxal-groupware` le service des mots de passe d'application de `lyxal_auth` | TLS côté client (décision C8 du lot 2) ; `AppPasswordService` signe les jetons d'accès des sessions `app_password`, donc l'hôte doit tenir la clé applicative (décision **E30**, question Q2) |
| X4 | Adresses de retour « à jeton » rangé en base, et non « signées » par HMAC (le programme range les « secrets des adresses signées » dans `lyxal_secrets`) | Un jeton tiré au hasard et rangé sur l'envoi relie exactement un avis à un destinataire, se révoque par la base, n'exige aucune clé ni aucune extension de `lyxal_crypto` (un HMAC tronqué, seul compatible avec les 64 octets d'une partie locale, n'est pas offert : `verify_hmac_sha256` exige 32 octets) (décision **E20**) |
| X5 | Le courrier entre deux organisations de l'installation passe par la file, mais sa remise ne passe pas par le réseau | Route locale de la file (§7) : mêmes étapes qu'un envoi extérieur (file, signature, tentatives, avis), remise par la chaîne de réception du lot 5 au lieu d'une connexion SMTP vers soi-même (décision **E24**) |
| X6 | Code **écrit pour Lyxal** sur le modèle de Stalwart, Mox et KumoMTA, et non porté | Comme la syntaxe et la session du lot 5 (`crates/lyxal_mail_proto/SOURCES.md` §4) : la file de Stalwart repose sur son magasin clé-valeur, `rkyv` et son moteur d'expressions de configuration (`IfBlock`, `registry`), étrangers à la voie B (P4) ; Mox est en Go ; KumoMTA est un modèle de mise en forme du trafic. Les cas d'essai de Mox (MIT) sont transposés (décision **E1**) |
| X7 | Un relais sortant (« smarthost ») facultatif est ajouté | Beaucoup d'hébergeurs ferment le port 25 sortant (risque « Délivrabilité » du programme) : sans relais, aucun envoi possible chez eux (décision **E13**) |

## 1. Périmètre

**Dans le lot 6** :

* `lyxal_crypto` : configuration TLS côté client (§4) ;
* `lyxal_mail_proto::smtp` : écriture des commandes du client, lecture des réponses et de la
  réponse à `EHLO`, bourrage du `DATA` en flux, lecture de `AUTH` côté serveur (`PLAIN`,
  `LOGIN`), paramètres DSN acceptés quand `DSN` est annoncé ; `lyxal_mail_proto::dsn` : écriture
  et lecture des avis de non-remise (§3) ;
* SurrealQL de `lyxal_mail` : envois, destinataires en file, échéancier, destinations, clés DKIM,
  compteurs d'envoi, adresses de retour, expéditeurs des modules, cibles externes des alias,
  réglages, droits, erreurs, événements (§14) ;
* `lyxal_mail::outbound` : file d'envoi côté Rust (réservation, regroupement, limites par
  destination, tentatives), résolution MX, client SMTP, STARTTLS opportuniste, `PIPELINING`,
  réutilisation des connexions, relais sortant facultatif, route locale (§5 à §7) ;
* `lyxal_mail::submission` : session de dépôt authentifié des ports 587 et 465 (§8) ;
* `lyxal_mail::dkim` : clés par domaine, signature, provisionnement et activation (§9) ;
* `lyxal_mail::dsn` : avis produits, avis reçus (§10) ; adresses de retour et règle contre la
  rétrodiffusion (§11) ;
* contrat public de dépôt pour les autres modules (§12) ;
* transfert d'un alias vers des adresses extérieures (§13) ;
* hôte `lyxal-groupware` : écoutes `submission`, worker d'envoi, tâche de provisionnement DKIM,
  configuration `[outbound]` et `[submission]`, mots de passe d'application, sonde, mesures
  (§16).

**Hors lot 6** (lot prévu) : `REQUIRETLS`, MTA-STS, DANE, TLS-RPT, rapports DMARC émis et reçus,
scellement et vérification ARC (7) ; copie automatique dans « Envoyés » (le logiciel la fait par
`APPEND`, lot 8 ; JMAP `EmailSubmission`, lot 12) ; envoi différé `FUTURERELEASE` et retenue
avant envoi (12) ; filtres Sieve et réponse d'absence (10) ; analyse anti-spam des messages
sortants (11) ; routes HTTP d'administration (domaines, clés DKIM et leur rotation, file,
contrôle DNS), certificats automatiques (13) ; liste de suppression des adresses en échec
définitif (elle existe dans `lyxal_notification` ; pour le courrier des personnes, à décider au
lot 13) ; rapports de plainte (ARF, boucles de retour des fournisseurs) ; plusieurs adresses IP
sortantes et montée en charge progressive automatique d'une IP neuve (exploitation, §21) ;
« site » de destination regroupant les domaines qui partagent leurs MX (KumoMTA ; §5.4) ;
`BDAT` sortant ; `LMTP`.

## 2. Chemin d'un message, de bout en bout

```text
Logiciel ──TLS 465 / STARTTLS 587──► lyxal-groupware, écoute `submission` (lot 3 : plafond, cadence, budget, TLS)
 1. EHLO ; STARTTLS (587) ; AUTH PLAIN|LOGIN     mot de passe d'application (AppPasswordService) ; permission mail.send
 2. MAIL FROM:<moi@nous> SIZE= BODY= SMTPUTF8 RET= ENVID=   fn::mail_sender_check : adresse permise au compte
 3. RCPT TO:<x@ailleurs> NOTIFY= ORCPT=  (≤ 100)  syntaxe, limites du compte ; aucun contrôle d'existence distant
 4. DATA                                          budget mémoire, taille, fins de ligne (règles du lot 5)
 5. Contrôles                                     MIME, From / Sender permis, antivirus (facultatif), Message-ID et Date ajoutés, Bcc retiré
 6. Signature DKIM                                préfixe = Received + DKIM-Signature (RSA, Ed25519), gardé en base
 7. fn::mail_submission_begin → StorageService::put (chiffré, `queue/…`) → fn::mail_submission_commit
 8. 250 2.0.0 <identifiant>                       seulement après l'inscription en file (aucun message accepté puis perdu)

Module (lyxal-server, MIT) : fn::mail_submission_begin → StorageService::put → fn::mail_submission_commit ;
                             préparation (jeton, DKIM) par le worker d'envoi à la première réservation

File (SurrealQL) : mail_submission ─< mail_queue_recipient (un par destinataire) ; échéancier mail_queue_due ;
                   destinations mail_queue_destination
 9. Worker `lyxal_mail:mail.outbound` (un par nœud) : fn::mail_queue_claim (bail, jeton de réservation)
10. Regroupement par (envoi, destination) ; limites par destination du nœud
11a. Domaine de l'installation → route locale : DeliveryPipeline du lot 5 (antivirus, filtres, idempotence)
11b. Domaine extérieur → MX / A / AAAA → TCP 25 → EHLO → STARTTLS si annoncé → MAIL / RCPT / DATA (PIPELINING)
     (ou relais sortant configuré : 587 / 465, TLS vérifié, AUTH)
12. fn::mail_queue_complete | fn::mail_queue_fail (prochaine échéance, retard, échec définitif, expiration)
13. Avis de non-remise : remis dans la boîte de l'expéditeur ; événements mail.submission.*
14. Avis reçus d'Internet sur rp=<jeton>@<domaine> → destinataire « bounced », avis remis à l'expéditeur
```

Le modèle de l'unité de file vient de Mox (`queue.Msg` : un enregistrement par destinataire,
regroupés par message de base pour une même transaction) et de Stalwart (`queue::Message` :
destinataires avec état, échéance, compte d'essais et dernière réponse). La séparation « file
programmée » / « file prête par destination » vient de KumoMTA (`ready_queue.rs`).

## 3. Syntaxe (`lyxal_mail_proto`)

Écrit pour Lyxal OS, comme au lot 5 (décision **E1**) ; modèles : Stalwart `smtp-proto`
(`response/parser.rs`, `request/parser.rs` pour `AUTH`), Mox `smtpclient/client.go`,
`dsn/dsn.go`, `dsn/parse.go`. Aucune dépendance nouvelle (Base64 de `AUTH` : crate `base64` 0.22,
`MIT OR Apache-2.0`, déjà dans l'arbre et dans `lyxal_mail`).

### 3.1. Côté client (`smtp::client`)

| Type ou fonction | Rôle |
| :--- | :--- |
| `ReplyReader` | Lit une réponse sur une ou plusieurs lignes (`250-…` puis `250 …`), même code sur chaque ligne, code étendu RFC 3463 facultatif ; lignes bornées (`MAX_REPLY_LINE_BYTES`, 1 000 lignes au plus par réponse) ; CRLF strict (un LF isolé est une erreur de protocole) ; reprend le lecteur des essais du lot 5 (`tests/smtp_support/`), sorti en code comme prévu par `ROADMAP.md` |
| `ServerExtensions` | Lecture de la réponse à `EHLO` : `PIPELINING`, `SIZE <n>`, `8BITMIME`, `SMTPUTF8`, `STARTTLS`, `DSN`, `ENHANCEDSTATUSCODES`, `CHUNKING`, `REQUIRETLS`, `AUTH <mécanismes>` (relais sortant) ; mots inconnus ignorés |
| `ClientCommand` | Écriture de `EHLO`, `HELO`, `STARTTLS`, `AUTH PLAIN` (réponse initiale, relais seulement), `MAIL FROM` (`SIZE`, `BODY=8BITMIME`, `SMTPUTF8`, `RET`, `ENVID`), `RCPT TO` (`NOTIFY`, `ORCPT` en `xtext`, RFC 3461 §4), `DATA`, `RSET`, `NOOP`, `QUIT` ; aucun CR ni LF accepté dans une valeur |
| `DotStuffer` | Encodeur en flux du contenu de `DATA` : point doublé en début de ligne, `CRLF.CRLF` final, refus d'une fin de ligne isolée (le contenu en file est déjà contrôlé ; double garde contre la contrebande SMTP vers l'extérieur) |

### 3.2. Côté serveur : `AUTH` (RFC 4954) et paramètres DSN

* `Request::Auth { mechanism, initial }` lu au lot 5 et refusé ; au lot 6 : `PLAIN` (RFC 4616 :
  `authzid`, `authcid`, mot de passe, séparés par NUL ; `authzid` non vide et différent de
  `authcid` refusé : aucune connexion « au nom de ») et `LOGIN` (brouillon
  `draft-murchison-sasl-login`, demandé par d'anciens Outlook) ; réponse initiale `=` (vide) ;
  annulation `*` (`501 5.0.0`) ; chaque élément Base64 borné à 1 024 octets ; mot de passe rendu
  en `Zeroizing<Vec<u8>>` (la crate `zeroize` est déjà dans l'arbre par `lyxal_crypto`), jamais
  dans un `Debug`.
* Paramètres DSN (`RET`, `ENVID`, `NOTIFY`, `ORCPT`) : lus au lot 5, refusés tant que `DSN` n'est
  pas annoncé ; acceptés sur l'écoute `submission` (décision **E22**). `REQUIRETLS` (paramètre de
  `MAIL FROM`, RFC 8689 §4) lu et refusé (`555 5.5.4`), décision **E26**.

### 3.3. Avis de non-remise (`dsn`)

* **Écriture** (`DsnBuilder`) : `multipart/report; report-type=delivery-status` (RFC 6522), trois
  parties : texte lisible (français et anglais, sans aucun texte venu du serveur distant hors du
  champ `Diagnostic-Code`), `message/delivery-status` (RFC 3464 : `Reporting-MTA`, `Original-
  Envelope-Id`, `Arrival-Date` ; par destinataire `Original-Recipient`, `Final-Recipient`,
  `Action` `failed` / `delayed` / `delivered` / `relayed`, `Status`, `Remote-MTA`,
  `Diagnostic-Code`, `Last-Attempt-Date`, `Will-Retry-Until`), puis les en-têtes du message
  (`text/rfc822-headers`, `RET=HDRS`, défaut) ou le message entier (`message/rfc822`, `RET=FULL`,
  jusqu'à 256 Kio ; au-delà, en-têtes seuls). Variante internationale `message/global-delivery-
  status` et `message/global-headers` (RFC 6533) quand l'envoi exigeait `SMTPUTF8`. Textes
  distants assainis (caractères de contrôle retirés, 998 octets par ligne, 4 096 par champ).
* **Lecture** (`parse_dsn`) : rapport `delivery-status` d'un message reçu (structure MIME du lot
  4) ; champs du message et des destinataires ; `Final-Recipient` et `Original-Recipient` ; états
  et codes. Tolérante aux avis réels mal formés (Mox `dsn/parse.go`), bornée (100 destinataires,
  64 Kio de rapport).
* Fuzzing : cibles `smtp_reply` et `dsn_parse` ; propriétés `proptest` (une réponse écrite par
  `Response::write_to` est relue à l'identique ; un avis écrit est relu à l'identique).

## 4. TLS côté client (`lyxal_crypto`, décision **E12**)

Constat : `lyxal_crypto` ne construit que la configuration des serveurs (`tls_server_config`) ;
`check_crypto_dependencies.py` refuse toute construction `ClientConfig::builder*` hors de
`lyxal_crypto` ; la feuille de route de `lyxal_crypto` réserve « TLS côté client — lot 6 (C8) ».
Extension proposée (écrite pour Lyxal, `MIT OR Apache-2.0`, fournisseur `aws-lc-rs` explicite
comme pour le serveur) :

```rust
pub enum TlsServerVerification {
    /// Chiffrement sans authentification du serveur (RFC 7435, TLS opportuniste du courrier) :
    /// chaîne et nom non vérifiés ; signature de la poignée de main toujours vérifiée.
    Opportunistic,
    /// Chaîne vérifiée contre les autorités de `webpki-roots` et nom vérifié (relais sortant ;
    /// lot 7 : MTA-STS).
    WebPki,
}
pub struct TlsClientOptions { pub verification: TlsServerVerification, pub min_version: TlsMinVersion,
                              pub alpn_protocols: Vec<Vec<u8>>, pub session_cache_entries: usize }
pub fn tls_client_config(&TlsClientOptions) -> Result<Arc<rustls::ClientConfig>, CryptoError>;
pub struct TlsPeerInfo { pub version: &'static str, pub cipher_suite: &'static str, pub verified: bool }
pub fn tls_peer_info(&rustls::ClientConnection) -> TlsPeerInfo;
```

* `Opportunistic` : vérificateur propre à `lyxal_crypto` qui accepte toute chaîne, mais délègue la
  vérification des signatures de la poignée de main (`verify_tls12_signature`,
  `verify_tls13_signature`) au fournisseur `aws-lc-rs` ; c'est le comportement de Postfix
  (`smtp_tls_security_level = may`) et de Mox (`TLSOpportunistic` sans PKIX). Il n'existe qu'à
  l'intérieur de `lyxal_crypto` (aucun vérificateur construit ailleurs).
* `WebPki` : racines de la crate `webpki-roots` 1.0 (déjà dans `Cargo.lock` par
  `lyxal_notification`, licence `CDLA-Permissive-2.0` déjà admise dans `deny.toml`), version figée ;
  nouvelle dépendance directe de `lyxal_crypto` seulement. Les racines du système ne sont pas lues
  (comportement identique d'un nœud à l'autre).
* TLS 1.2 au moins, pas de 0-RTT, pas de certificat client, SNI = nom du MX (jamais une adresse IP).
* Les hôtes branchent la connexion par `tokio_rustls::TlsConnector` (permis aux hôtes ; le crate
  `lyxal_mail` reçoit un trait `TlsConnectorProvider` de l'hôte, comme `TlsUpgrade` au lot 3 :
  `lyxal_mail` ne dépend jamais de `rustls` ni de `tokio-rustls`).
* Essais (dans `lyxal_crypto`) : poignées de main réelles en mémoire contre le serveur de
  `tls_server_config` ; `Opportunistic` accepte un certificat auto-signé et un nom faux, refuse une
  signature de poignée de main falsifiée ; `WebPki` refuse auto-signé, nom faux, certificat échu ;
  TLS 1.2 et 1.3 ; `API_CONTRACT.md`, `SECURITY.md` (le mode opportuniste ne protège que d'une
  écoute passive) et `ROADMAP.md` mis à jour. Taille estimée : moins de 600 lignes, essais compris.

## 5. File d'envoi (décisions **E2** à **E7**)

### 5.1. Place de `lyxal_scheduler` (décision **E2**)

Le programme laisse ce point « à confirmer au plan du lot 6 ». Proposition : **la file a ses
propres tables et son propre worker**, comme `lyxal_notification` (`notification_job`) ;
`lyxal_scheduler` n'exécute que les tâches périodiques :

| Besoin de la file | `lyxal_scheduler` | Table et worker propres |
| :--- | :--- | :--- |
| Une échéance par destinataire, reculs propres à chacun | Une exécution (`scheduler_run`) par essai : volumes de plusieurs centaines de milliers de lignes à 100 messages par seconde | Une ligne par destinataire, échéance mise à jour sur place |
| Limites par destination (connexions, débit) et par nœud | Places par file et par organisation seulement | Limites par domaine, dans le nœud (§5.4) |
| Regrouper les destinataires d'un même domaine dans une transaction SMTP, réutiliser une connexion | Aucun regroupement | Réservation groupée (§5.3) |
| Délai de prise en charge de l'ordre de la seconde | Planificateur élu, un tour par seconde, puis exécuteur | Réveil immédiat du worker du nœud qui a déposé (§5.3) |
| Lecture du message en flux pendant l'envoi | — | Contenu lu par le worker (§6.6) |

Tâches confiées à `lyxal_scheduler` (exécuteur `handler`, réservées par un nœud de
`lyxal-groupware`) : la maintenance existante `mail.maintenance` (toutes les 10 min), étendue à la
purge des envois finis, de leurs contenus et des jetons échus (`fn::mail_queue_purge`), et une
tâche nouvelle `mail.dkim.provision` (toutes les 10 min, §9.3).

### 5.2. Unité de file, états (décision **E3**)

* **Envoi** (`mail_submission`) : un message déposé, son contenu chiffré, son enveloppe, son
  préfixe signé, son adresse de retour ; état `pending` (réservé, fichier en écriture) →
  `queued` → `done` (tous ses destinataires dans un état final) ; `origin` : `submission`
  (dépôt authentifié), `module` (contrat du §12), `forward` (transfert, §13), `dsn` (avis produit
  pour l'extérieur, §10.2).
* **Destinataire en file** (`mail_queue_recipient`) : `scheduled` → `running` (réservé) →
  `delivered` (accepté par le serveur final, ou remis par la route locale), `relayed` (accepté par
  un serveur sans `DSN` avec `NOTIFY=SUCCESS`), `failed` (refus définitif), `expired`, `canceled`
  (annulé par l'expéditeur) ; `bounced` (avis reçu après acceptation, §10.3).
* **Destination** (`mail_queue_destination`) : un domaine de routage (forme ASCII), la
  suspension en cours après un échec de connexion à tous ses MX et le nombre d'échecs de
  connexion consécutifs. Le « site » de KumoMTA (domaines regroupés par leurs MX communs, ex.
  `gmail.com` et `googlemail.com`) n'est pas repris au lot 6 : il demande de résoudre les MX
  avant de mettre en file ; à reprendre si la mesure le justifie.

### 5.3. Réservation, bail, reprise après arrêt (décisions **E4**, **E5**)

* **Réservation** : `fn::mail_queue_claim` rend jusqu'à `limit` destinataires échus (`scheduled`
  et échéance passée, destination non suspendue, domaines saturés du nœud exclus), les passe à
  `running` avec `locked_until = maintenant + 10 min` et un **jeton de réservation** tiré par la
  fonction (`rand::uuid::v7()`), rendu au worker ; ordre : échéance, puis date de dépôt (premier
  déposé, premier servi dans une destination).
* **Échéancier ordonné** (`mail_queue_due`, décision **E5**) : SurrealDB 3.3.4 n'applique pas
  `LIMIT` au parcours d'un index dans une fonction (constat du lot 4, décision P1). Une vue tenue
  par les événements de `mail_queue_recipient` (comme `mail_message_date`) range chaque
  destinataire `scheduled` sous un identifiant ordonné `mail_queue_due:⟨<10^16 + échéance en µs>_
  <clé du destinataire>⟩` ; la réservation lit une **plage d'identifiants bornée** (de l'origine
  à l'instant présent), lue par fenêtres de 1 000 au plus. Repli, si la mesure (§18) montre que
  l'index `(state, next_attempt_at)` tient l'objectif sur une file de 100 000 messages en attente :
  index seul, vue retirée.
* **Garde** (« fencing ») : toute écriture d'un résultat (`fn::mail_queue_complete`, `_fail`,
  `_release`, `_renew`, `_prepare`) exige le jeton de réservation et `locked_until` non échu ;
  sinon `MAIL_QUEUE_CLAIM_LOST`, et le worker abandonne ce destinataire sans rien écrire.
* **Renouvellement** : toutes les 2 min pendant un envoi long (gros message, serveur lent).
* **Reprise après arrêt brutal** : un destinataire `running` dont le bail est échu redevient
  réservable (aucune tâche de secours : la réservation le reprend), sans essai compté si aucun
  résultat n'a été écrit. Arrêt propre : `fn::mail_queue_release` rend aussitôt les destinataires
  non commencés, sans essai compté.
* **Résultat écrit aussitôt** après chaque transaction SMTP (avant la suivante sur la même
  connexion). Fenêtre de doublon : arrêt entre la réponse `250` du serveur distant et l'écriture
  du résultat ; le message est renvoyé après la reprise. La RFC 5321 §6.1 préfère un doublon à une
  perte ; le doublon est borné au nombre de transactions en vol au moment de l'arrêt (§18). La
  route locale n'a pas de doublon : son idempotence est celle de la remise du lot 5 (§7).
* **Réveil** : un dépôt sur un nœud réveille le worker de ce nœud (canal en mémoire) ; les autres
  nœuds lisent l'échéancier toutes les secondes, et toutes les 5 s quand la dernière lecture était
  vide.

### 5.4. Ordre et débit par destination (décision **E7**)

Limites **par nœud**, en mémoire, comme les cadences du lot 3 (sur plusieurs nœuds, elles
s'additionnent ; l'exploitant les divise) :

| Réglage (`[outbound]`) | Défaut | Bornes | Modèle |
| :--- | -: | :--- | :--- |
| `max_connections` (toutes destinations) | 100 | 1 à 10 000 | Mox : 10 livraisons simultanées |
| `connections_per_destination` | 4 | 1 à 100 | Mox : une à la fois par domaine ; KumoMTA `connection_limit` |
| `messages_per_connection` | 100 | 1 à 10 000 | KumoMTA `max_deliveries_per_connection` (1 024) |
| `recipients_per_transaction` | 100 | 1 à 1 000 | RFC 5321 §4.5.3.1.8 ; KumoMTA `max_recipients_per_batch` |
| `[[outbound.destinations]]` : `domain`, `connections`, `messages_per_minute` | — | — | KumoMTA `max_message_rate` (montée en charge d'une IP neuve, domaines exigeants) |

* Dans une destination : ordre de l'échéancier ; un message dépassant la cadence de sa
  destination est rendu à la file avec une échéance à la prochaine place (sans essai compté).
* **Suspension d'une destination** : quand aucun MX ni aucune adresse n'a répondu (connexion
  refusée, délai, `421` d'accueil), la destination est suspendue (5 min, doublé à chaque échec
  consécutif, 2 h au plus) et ses destinataires réservés reprennent à la fin de la suspension, avec
  un essai compté ; une réponse de serveur remet le compteur à zéro. Modèle : KumoMTA
  `consecutive_connection_failures_before_delay`.

### 5.5. Tentatives, reculs, expiration (décision **E6**)

| Réglage (`mail_settings`, installation) | Défaut | Bornes |
| :--- | -: | :--- |
| `retry_intervals` (minutes ; le dernier se répète) | 5, 10, 20, 40, 80, 120 | 1 à 1 440 chacun, 16 au plus |
| `retry_jitter_percent` | 10 | 0 à 50 |
| `delay_notice_hours` (avis de retard, une fois) | 4 | 1 à 72 |
| `expire_hours` | 120 (5 jours, RFC 5321 §4.5.4.1 : « au moins 4 à 5 jours ») | 1 à 720 |

Comparaison : Mox 0, 7,5 min puis doublement, 8 essais (environ 32 h), avis de retard au 5ᵉ
essai ; Stalwart 2, 5, 10, 15, 30 min, 1 h, 2 h…, avis à 1 et 3 jours, expiration 3 jours ;
KumoMTA 20 min doublé, 7 jours. La prochaine échéance est calculée par `fn::mail_queue_fail`
(règle de données, SurrealQL) ; le décalage aléatoire n'a aucun usage cryptographique
(`rand::float`). Une réponse `4xx` reçue après l'expiration rend l'échec définitif
(`Status: 4.4.7`, RFC 3463).

## 6. Envoi vers les MX (`lyxal_mail::outbound`, décisions **E8** à **E11**, **E13**)

### 6.1. Résolution (décision **E8**)

* `MailResolver::mx` du lot 5 (cache du nœud). MX triés par préférence, ordre tiré au hasard
  entre préférences égales (RFC 5321 §5.1) ; 5 MX au plus, 2 adresses par MX (valeurs par défaut
  de Stalwart, `max_mx_hosts`, `max_multihomed`).
* Aucun MX : MX implicite, adresses du domaine lui-même (RFC 5321 §5.1). **MX nul** (`0 .`,
  RFC 7505) : échec définitif `5.1.10`. Domaine inexistant (`NXDOMAIN`) : échec définitif
  `5.1.2`. Panne DNS : échec temporaire, compté.
* Adresses : `ipv4` puis `ipv6` par défaut (`[outbound] ip_families = ["ipv4", "ipv6"]`, modèle
  Stalwart `V4ThenV6`) : une IPv6 sortante sans DNS inverse est souvent refusée par les grands
  fournisseurs ; l'exploitant peut ne garder qu'une famille.
* **Adresses refusées** : boucle locale, privées (RFC 1918, ULA), lien local, réservées,
  multidiffusion, nos propres adresses d'écoute : échec temporaire « MX vers une adresse
  interdite » (configuration du destinataire, il peut la corriger). `allow_private_networks =
  true` seulement pour les essais et le développement (faux MX local).
* Domaines internationaux : forme ASCII (`idna`, décision S16 du lot 5).
* `CNAME` : suivi par `hickory-resolver` dans la réponse MX ; le suivi explicite (Mox
  `GatherDestinations`, utile à DANE) est reporté au lot 7.

### 6.2. Connexion et dialogue

* Adresse source facultative (`source_ipv4`, `source_ipv6`) ; `EHLO <smtp.hostname>` (le nom du
  DNS inverse de l'adresse sortante : exigence d'exploitation documentée) ; repli `HELO` sur
  `500` / `502` à `EHLO`.
* Port 25 (`smtp_port`, réglable pour les essais seulement : faux MX sur un port libre).
* **Délais** (RFC 5321 §4.5.3.2, raccourcis comme Mox pour la connexion) : connexion 30 s,
  accueil 300 s, `EHLO` 300 s, `STARTTLS` et poignée de main 60 s, `MAIL` 300 s, `RCPT` 300 s,
  `DATA` 120 s, bloc de données 180 s, fin des données 600 s ; réglables dans `[outbound]`.
* **`PIPELINING`** (RFC 2920, décision **E10**) : quand il est annoncé, `MAIL`, tous les `RCPT`
  et `DATA` partent en une écriture ; réponses lues dans l'ordre ; aucun destinataire accepté →
  `RSET` (Mox `errNoRecipientsPipelined`). Sans l'extension : une commande à la fois.
* **`SIZE`** : un message plus grand que la taille annoncée échoue définitivement (`5.3.4`) sans
  envoi.
* **8 bits et UTF-8** : un message avec octets 8 bits vers un serveur sans `8BITMIME`, ou exigeant
  `SMTPUTF8` vers un serveur sans `SMTPUTF8`, échoue définitivement (`5.6.3`, `5.6.7`) ; aucune
  conversion (Mox fait de même).
* **DSN** : paramètres `RET`, `ENVID`, `NOTIFY`, `ORCPT` transmis quand le serveur annonce `DSN`
  (RFC 3461 §5.2) ; sinon, `NOTIFY=SUCCESS` donne un avis `relayed` (§10.2).
* Contenu : `DotStuffer` sur le préfixe (en base) puis sur le fichier lu en flux (§6.6).

### 6.3. STARTTLS opportuniste (décision **E9**)

* Annoncé : `STARTTLS` puis `EHLO` de nouveau (RFC 3207 §4.2) ; configuration
  `TlsServerVerification::Opportunistic` (§4) ; version, suite et `verified: false` notés dans le
  résultat et les mesures.
* Échec de la poignée de main : **une** reconnexion en clair au même hôte, comptée
  (`tls_fallbacks`), comme Mox pour le mode opportuniste ; un serveur qui ne parle pas TLS
  correctement ne bloque pas le courrier. Réglage `tls = "opportunistic" | "disabled"`
  (désactivé : essais seulement).
* Non annoncé : envoi en clair, compté. MTA-STS et DANE (lot 7) rendront le TLS obligatoire et
  vérifié pour les domaines qui le publient.

### 6.4. Réponses et classement des échecs

| Réponse ou incident | Effet |
| :--- | :--- |
| `2xx` à la fin des données, par destinataire accepté | `delivered` (ou `relayed`) |
| `5xx` à `RCPT` ou après les données | `failed` pour ce destinataire (code et code étendu gardés) |
| `4xx` | Nouvel essai à l'échéance suivante |
| `421` (fermeture par le serveur), coupure, délai | Nouvel essai ; les destinataires non encore servis de la connexion sont rendus sans essai compté |
| Aucun MX ni aucune adresse joignable | Suspension de la destination (§5.4) |
| Panne DNS | Nouvel essai |
| Refus TLS, fin de flux du fichier en erreur (segment chiffré altéré) | Nouvel essai ; un contenu illisible deux fois de suite échoue définitivement (`5.3.0`) et est signalé à la sonde |

Le texte d'une réponse distante est gardé assaini et coupé à 512 octets (enregistrement et avis),
jamais dans un événement.

### 6.5. Réutilisation des connexions (décision **E11**)

Pool du nœud par (MX, adresse, mode TLS) : une connexion qui a fini une transaction reste ouverte
60 s (`idle_timeout`, valeur de KumoMTA) pour le prochain envoi de la même destination ; `RSET`
seulement après une transaction en échec ; fermée après `messages_per_connection` messages, à
l'arrêt du nœud (`QUIT`), ou sur toute erreur de protocole.

### 6.6. Contenu lu en flux

Le contenu en file est lu par `StorageService` en flux (déchiffrement par segments de 64 Kio,
`lyxal_storage`) et écrit vers la connexion au fil de l'eau : la mémoire d'un envoi ne dépend pas
de la taille du message (budget du lot 3 : nouvelle classe « envoi », 64 Kio par envoi en cours).
Un segment altéré arrête l'envoi avant la fin des données (`.` jamais écrit : le serveur distant
ne peut pas accepter un message tronqué).

### 6.7. Relais sortant facultatif (décision **E13**)

`[outbound.relay]` : `host`, `port` (587 ou 465), `tls` (`starttls` ou `implicit`, **vérifié**
par `WebPki` ; jamais en clair), `credentials_path` (chemin `lyxal_secrets` de l'installation,
`{ username, password }`, lu par `SecretsClient` à chaque nouvelle connexion, jamais gardé hors
`SecretString`), `AUTH PLAIN`. Quand il est réglé, tout envoi extérieur passe par lui (aucune
résolution MX) ; la route locale ne change pas. Limites par destination appliquées au relais
comme destination unique.

## 7. Route locale : courrier entre organisations de l'installation (décision **E24**)

* Un destinataire dont le domaine est un domaine de courrier **actif de l'installation**, quelle
  que soit son organisation (programme §4.5), est mis en file comme les autres puis remis par le
  worker d'envoi par la **chaîne de réception du lot 5** (`DeliveryPipeline` : antivirus, filtres,
  dossier, chiffrement, `fn::mail_delivery_begin` / `_commit`, événement
  `mail.message.received`), sans connexion réseau.
* Résolution du destinataire par `fn::mail_recipient_resolve` (lot 5) au moment de la remise :
  inconnu, désactivé → échec définitif (`5.1.1`, `5.2.1`) et avis ; quota plein → nouvel essai
  (`4.2.2`), comme un serveur extérieur.
* Résultats de réception (`mail_message.reception`) : `dkim` vérifié par le vérificateur du lot 5
  contre la clé enregistrée du domaine expéditeur (`mail_dkim_key`, sans DNS ; même résultat que
  le DNS une fois la clé publiée), `dmarc` calculé sur ce résultat (alignement du `From`), `spf`
  `none`, `iprev` `none`, `tls` vrai ; `Authentication-Results` écrit avec ces valeurs. Une
  organisation destinataire voit donc ce que verrait un serveur extérieur, sans le faux « pass »
  d'un raccourci.
* **Idempotence** : l'empreinte de remise du lot 5 (`delivery_key` : adresse inscrite,
  expéditeur de l'enveloppe, octets) rend sans doublon une remise reprise après un arrêt.
* Aucun raccourci hors file : un envoi vers sa propre organisation suit le même chemin (limites,
  signature, avis), ce qui garde une seule règle.

## 8. Dépôt authentifié, ports 587 et 465 (`lyxal_mail::submission`, décisions **E14** à **E17**)

Écrit pour Lyxal OS sur le modèle de la session du lot 5 (même machine d'états, mêmes lectures de
`DATA` et de `BDAT`, mêmes limites mémoire et mêmes règles de fins de ligne) et de Stalwart
`inbound/auth.rs` (modèle) ; RFC 6409 (soumission), 4954 (`AUTH`), 8314 (TLS implicite, port
465), 3207.

### 8.1. Écoutes et TLS

* Écoute `protocol = "submission"` déjà déclarée par l'hôte (lot 3) : port 587 avec `tls =
  "starttls"`, port 465 avec `tls = "implicit"` (RFC 8314) ; le refus poli actuel
  (`UnavailableHandler`) est remplacé par `SubmissionHandler`.
* **TLS exigé avant `AUTH`** : sur 587, `AUTH` n'est annoncé qu'après `STARTTLS` ; `AUTH`, `MAIL`
  avant TLS → `530 5.7.0 Must issue a STARTTLS command first`. Une écoute `submission` en
  `tls = "none"` est refusée par la configuration de l'hôte (`GROUPWARE_CONFIGURATION_INVALID`),
  sauf `allow_plaintext_auth = true`, réservé au développement sur `127.0.0.1`.
* Extensions après TLS : `PIPELINING`, `SIZE <max>`, `8BITMIME`, `SMTPUTF8`,
  `ENHANCEDSTATUSCODES`, `CHUNKING`, `DSN`, `AUTH PLAIN LOGIN` ; jamais `REQUIRETLS` (X1),
  `BINARYMIME`, `DELIVERBY`, `FUTURERELEASE` (lot 12).

### 8.2. Authentification (décision **E14**)

* `AUTH PLAIN` ou `AUTH LOGIN` → `AppPasswordService::authenticate` de `lyxal_auth`
  (`AppProtocol::Smtp`, adresse IP réelle du client après PROXY, `secure: true`, logiciel :
  aucun) : identifiant = adresse de connexion du compte, mot de passe d'application (lot 1) ;
  droits recalculés par la base.
* **Permission nouvelle `mail.send`** (portée organisation, `app_password: true`, attribuée aux
  rôles membre et administrateur d'organisation par le seed du module) : envoyer sous ses propres
  adresses. Un mot de passe d'application créé sans elle ne permet pas d'envoyer (lecture seule
  d'un appareil). `AUTH` réussi sans `mail.send` dans les droits → `535 5.7.8` (aucun détail).
* Réponses : `235 2.7.0` ; mot de passe faux ou révoqué `535 5.7.8` ; panne de la base `454
  4.7.0` ; adresse bloquée par `lyxal_auth` (`AUTH_TOO_MANY_ATTEMPTS`) `421 4.7.0` et fermeture ;
  3 échecs dans une session `421 4.7.0` et fermeture ; `AUTH` déjà fait `503 5.5.1`.
* **Aucun bannissement réseau** pour les échecs d'authentification : `lyxal_auth` bloque déjà
  l'adresse IP pour les seuls mots de passe d'application (et jamais un identifiant : un tiers ne
  coupe pas la messagerie de quelqu'un) ; bannir l'adresse d'un bureau à toutes les écoutes du
  courrier serait pire.
* **Session de l'utilisateur** : l'hôte ouvre, pour la session SMTP, un client SurrealDB
  authentifié par le jeton d'accès rendu (accès `lyxal_auth_<emplacement>`, modèle du lot 1 :
  « l'hôte ouvre une connexion SurrealDB au nom de l'utilisateur ») ; les fonctions de dépôt
  s'exécutent sous ce client : `fn::mail_can` et les permissions de table s'appliquent sans
  règle recopiée. Jeton renouvelé par `AppPasswordService::renew` quand il expire pendant la
  session. Coût d'ouverture mesuré en 6e (§18) ; repli si trop cher : session système et
  paramètre `session` contrôlé par la base (`fn::auth_session_check`, contrat de `lyxal_auth`).

### 8.3. Droit d'envoyer sous une adresse (décision **E15**)

Règle en SurrealQL (`fn::mail_sender_check`, sous la session de l'utilisateur), appliquée à
`MAIL FROM` dès la commande, puis à la fin des données à chaque adresse des champs `From`,
`Sender`, `Resent-From` et `Resent-Sender`, puis une dernière fois dans
`fn::mail_submission_begin` (une seule règle, trois appels) :

* adresse d'un domaine de courrier **actif** de l'organisation de la session ;
* adresse inscrite (`mail_address`) **active**, soit du compte de la session (adresse principale
  ou supplémentaire), soit un alias dont la liste nouvelle `senders` contient ce compte (aucun
  par défaut : faire partie d'un alias ne donne pas le droit d'écrire en son nom) ;
* sous-adresse (`moi+liste@nous`) permise quand l'adresse de base l'est et que le domaine a un
  séparateur ;
* `MAIL FROM:<>` permis (accusés de lecture, RFC 8098), les champs d'en-tête restant contrôlés.

Refus : `550 5.7.1 Sender address not allowed` (code interne `MAIL_SENDER_FORBIDDEN`), compté
(`submission_spoofing`) et journalisé sans adresse. Les noms affichés et `Reply-To` sont libres.

### 8.4. Limites (décision **E16**)

| Réglage (`mail_settings`, organisation, plafonné par l'installation) | Défaut | Bornes | Refus |
| :--- | -: | :--- | :--- |
| `send_recipients_per_message` | 100 | 1 à 1 000 | `452 4.5.3` au-delà (RFC 5321 §4.5.3.1.8) |
| `send_messages_per_day` (par compte) | 1 000 | 1 à 1 000 000 | `451 4.7.1` (`MAIL_SEND_LIMIT_EXCEEDED`) |
| `send_recipients_per_day` (par compte) | 2 000 | 1 à 10 000 000 | `451 4.7.1` |
| `module_messages_per_hour` (par organisation, §12) | 10 000 | 1 à 10 000 000 | `MAIL_SEND_LIMIT_EXCEEDED` |
| `forward_messages_per_day` (par organisation, §13) | 10 000 | 0 à 10 000 000 | transfert non fait, compté |

Valeur de Mox pour les messages par jour d'un compte (`MaxOutgoingMessagesPerDay`, 1 000).
Compteur `mail_send_counter` par compte (ou organisation) et par jour UTC, réservé par
`fn::mail_submission_begin` et rendu par `fn::mail_submission_abort` ; limites de session
(`[submission]` : erreurs, délais, messages par session) reprises de `SmtpConfig` du lot 5.
Taille : celle de l'organisation (`max_message_bytes`, 50 Mio par défaut).

### 8.5. Traitement du message déposé (décision **E17**)

Dans l'ordre, sur le message en mémoire (budget du lot 3, classe « réception SMTP ») :

1. lecture MIME (`lyxal_mail_proto::mime`), refus `554 5.6.0` ;
2. exactement un `From` (`550 5.6.0`), adresses permises (§8.3) ;
3. `Bcc` retiré ; `Message-ID` (`<UUID v7@smtp.hostname>`) et `Date` ajoutés s'ils manquent
   (RFC 6409 §8) ; aucun autre en-tête modifié ;
4. antivirus de la chaîne du lot 5 s'il est configuré (un compte compromis n'envoie pas un
   fichier infecté) : `554 5.7.1` ;
5. `Received: from <EHLO> by <hostname> with ESMTPSA id <session> ; <date>` (`ESMTPSA` /
   `UTF8SMTPSA`, RFC 3848), **sans** l'adresse IP du client ni le compte (vie privée de
   l'expéditeur, comme les grands fournisseurs) ;
6. signature DKIM (§9.2) ;
7. adresse de retour `rp=<jeton>@<domaine du MAIL FROM>` (§11) ;
8. `fn::mail_submission_begin` → `StorageService::put` (chiffré, bucket `lyxal-mail` de
   l'organisation, clé `queue/<UUID v7>.eml`, décision **E29**) → `fn::mail_submission_commit` ;
   le préfixe (`Received`, `DKIM-Signature`) est rangé en base sur l'envoi (modèle Mox
   `MsgPrefix`), le fichier garde les octets reçus modifiés par les étapes 3 seulement ;
9. `250 2.0.0 Ok <identifiant>` après l'inscription ; toute panne avant : `451 4.3.0` (le
   logiciel réessaie) ; aucun message accepté puis perdu.

Destinataires : aucune vérification d'existence pendant la session pour un domaine extérieur ;
un destinataire d'un domaine de l'installation est résolu dès `RCPT TO` (`fn::mail_recipient_resolve`) et
refusé tout de suite s'il est inconnu (`550 5.1.1`), pour une erreur immédiate dans le
logiciel plutôt qu'un avis.

## 9. Signature DKIM par domaine (`lyxal_mail::dkim`, décision **E18**)

### 9.1. Clés

* **Deux clés par domaine** : RSA 2048 bits (`rsa-sha256`) et Ed25519 (`ed25519-sha256`, RFC
  8463) ; deux signatures par message : les vérificateurs qui ignorent Ed25519 lisent la
  signature RSA (RFC 8463 §4 recommande la double signature pendant la transition).
* **Sélecteurs** : `lyx<aaaamm>r` et `lyx<aaaamm>e` (date de création ; la rotation du lot 13
  créera un nouveau mois sans réutiliser un nom).
* **Clé privée** : générée par `RsaSigningKey::generate(RsaModulusBits::Rsa2048)` (dans
  `spawn_blocking`, règle 12) ou `Ed25519SigningKey::generate`, exportée **uniquement** par
  `export_pkcs8` pour être rangée dans `lyxal_secrets` par `SecretsClient::write`, organisation
  du domaine, chemin `mail/dkim/<domaine>/<sélecteur>`, consommateur `lyxal_mail` ; jamais en
  base, au journal ni dans un événement.
* **Fiche publique** `mail_dkim_key` : domaine, sélecteur, algorithme, valeur `p=` (Base64 de
  `public_key_record_bytes`), chemin du secret, état `pending` → `active` (lot 13 : `retiring`,
  `retired`), dates. Enregistrement à publier rendu par `fn::mail_dkim_key_list`
  (`v=DKIM1; k=rsa|ed25519; p=…`), lisible par `mail.domain.manage`.
* **Cache** : clés ouvertes gardées 10 minutes dans le nœud (`DkimKeyCache`, 1 024 entrées au
  plus, `DkimSigningKey` dont la mémoire est tenue par `aws-lc-rs`, retirées à l'éviction),
  sinon chaque message ferait deux lectures tracées du coffre-fort ; mêmes règles que le cache des
  clés « fichiers » (S13). Une clé qui n'est plus `active` n'est jamais servie (état relu par
  `fn::mail_dkim_signers` à chaque message, en un appel pour tous les domaines du `From`).

### 9.2. Signature

* Canonicalisation `relaxed/relaxed` ; `t=` posé ; ni `x=`, ni `l=` (jamais produit, règle 13),
  ni `i=`.
* **En-têtes signés** (liste de Mox, `mox-/config.go`, étendue) : `From`, `To`, `Cc`, `Reply-To`,
  `Subject`, `Date`, `Message-ID`, `In-Reply-To`, `References`, `Content-Type`, `MIME-Version`,
  `Content-Transfer-Encoding`, `Sender`, `List-Id`, `List-Unsubscribe`, `List-Unsubscribe-Post`
  (RFC 8058 : la signature doit couvrir ces deux derniers pour le désabonnement en un clic), quand
  ils sont présents ; **sur-signature** (nom répété une fois de plus que ses occurrences dans
  `h=`) de `From`, `To`, `Cc`, `Subject`, `Date`, `Message-ID`, `Reply-To`, `Content-Type`,
  `MIME-Version` : un en-tête ajouté en chemin casse la signature (Mox : « seal signed headers »).
  Jamais `Received`, `Return-Path`, `DKIM-Signature` (RFC 6376 §5.4).
* Domaine signataire : celui du `From` (un seul domaine d'auteur : un `From` à plusieurs domaines
  est signé pour chacun de ceux qui ont des clés, 2 au plus). Sans clé active pour ce domaine : le
  message part non signé, compté (`dkim_unsigned`) et signalé par la sonde (« domaine sans clé
  DKIM active ») : refuser l'envoi bloquerait un domaine tant que son DNS n'est pas publié.
* Octets signés : `DkimBodyHasher` en flux sur le corps, `DkimHeaderCanonicalizer` sur les
  en-têtes choisis, `DkimSigningKey::sign` ; aucune canonicalisation recopiée hors de
  `lyxal_crypto` (règle 13). L'écriture des balises (`v`, `a`, `c`, `d`, `s`, `t`, `h`, `bh`,
  `b`, repliement à 78 colonnes) est dans `lyxal_mail`.
* Moment : à l'entrée en file (dépôt authentifié : dans la session ; contrat de module : à la
  préparation par le worker d'envoi, §12) ; jamais à chaque essai : la signature est la même pour
  tous les essais et tous les destinataires.

### 9.3. Provisionnement et activation (tâche `mail.dkim.provision`)

Exécutée toutes les 10 minutes par `lyxal_scheduler` (handler de `lyxal-groupware`, comme
`mail.maintenance`) :

1. pour chaque domaine actif sans clé `pending` ou `active` d'un algorithme : clé générée,
   secret écrit, puis `fn::mail_dkim_key_create` (un arrêt entre les deux laisse un secret sans
   fiche, réécrit au passage suivant : le chemin est déterminé par le domaine et le sélecteur) ;
2. pour chaque clé `pending` : `TXT <sélecteur>._domainkey.<domaine>` par le résolveur du nœud ;
   enregistrement trouvé et `p=` identique → `fn::mail_dkim_key_activate` ; sinon rien (attente de
   la publication par l'administrateur, mesure `dkim_pending`).

L'activation après publication évite de signer avec une clé que les destinataires ne trouvent
pas (`permerror` qui ferait échouer DMARC alors que SPF passerait). Les routes d'administration,
la rotation et le contrôle complet du DNS restent au lot 13.

## 10. Avis de non-remise (`lyxal_mail::dsn`, décisions **E22**, **E23**)

### 10.1. Quand un avis est produit

| Cas | `NOTIFY` absent (défaut RFC 3461 §4.1) | `NOTIFY` donné |
| :--- | :--- | :--- |
| Échec définitif, expiration | avis `failed` | si `FAILURE` |
| Toujours en file après `delay_notice_hours` | avis `delayed`, une fois, avec `Will-Retry-Until` | si `DELAY` |
| Remis par la route locale, ou accepté par un serveur qui annonce `DSN` | rien | si `SUCCESS` : `delivered` (route locale) ; serveur `DSN` : rien, il s'en charge |
| Accepté par un serveur sans `DSN` | rien | si `SUCCESS` : `relayed` |
| `NOTIFY=NEVER`, `MAIL FROM:<>`, envoi d'origine `dsn` | jamais | jamais |

Un avis groupe les destinataires d'un même envoi qui changent d'état dans un même passage du
worker ; `fn::mail_queue_dsn_done` marque chaque destinataire servi (`dsn_sent`, `delay_sent`) :
un avis n'est jamais produit deux fois, même après une reprise.

### 10.2. À qui

| Origine de l'envoi | Avis |
| :--- | :--- |
| `submission` (dépôt authentifié) | **Déposé directement dans la boîte de réception du compte expéditeur** par la chaîne de remise du lot 5 (expéditeur `MAILER-DAEMON@<smtp.hostname>`, idempotence par empreinte), jamais envoyé sur Internet. Compte désactivé ou supprimé : aucun avis, compté |
| `module` (contrat du §12) | Aucun message : événements `mail.submission.*` seulement |
| `forward` (transfert, §13) | Envoyé à l'expéditeur d'origine par la file (envoi d'origine `dsn`, `MAIL FROM:<>`), **seulement si** la réception d'origine avait SPF `pass` ou DMARC `pass` (expéditeur authentifié) ; sinon aucun avis, compté (`dsn_suppressed`) : un avis vers une adresse forgée serait de la rétrodiffusion |
| `dsn` | Jamais d'avis sur un avis |

### 10.3. Avis reçus (décision **E23**)

Un message arrivé sur le port 25 pour une adresse de retour valide (§11) passe la réception du
lot 5 (SPF, DKIM, DMARC, antivirus), puis :

* rapport `delivery-status` lu (`lyxal_mail_proto::dsn`) : pour chaque destinataire `failed` qui
  correspond (adresse finale ou d'origine) à un destinataire de l'envoi, `fn::mail_return_record`
  le passe à `bounced` s'il était `delivered` ou `relayed` (rejet après acceptation) ; événement
  `mail.submission.bounced` ; `delayed` et `delivered` sont seulement comptés ;
* envoi `submission` : l'avis est remis dans la boîte du compte expéditeur (il le voit comme
  chez tout fournisseur) ; envoi `module` ou `forward` : accepté puis écarté, compté (réponses
  automatiques et avis n'ont aucune boîte où aller) ;
* message qui n'est pas un rapport (réponse automatique, RFC 3834, qui vise le `Return-Path`) :
  remis à l'expéditeur d'un envoi `submission`, écarté sinon.

## 11. Adresses de retour et rétrodiffusion (décisions **E20**, **E21**)

* **Adresse de retour à jeton** : chaque envoi (sauf `MAIL FROM:<>`) part avec
  `MAIL FROM:<rp=<jeton>@<domaine>>`, où le domaine est celui de l'adresse d'expéditeur (aligné
  sur le `From` pour SPF et DMARC), et le jeton 26 caractères en base 32 (alphabet de Crockford,
  minuscules) de 128 bits tirés par `rand_core::OsRng` dans `lyxal-groupware` ; 29 caractères de
  partie locale (64 au plus, RFC 5321 §4.5.3.1.1). Rangé sur l'envoi (index unique), valable
  jusqu'à 14 jours après la fin de l'envoi, puis effacé par la maintenance. Modèle : Mox
  (`FromID` dans l'adresse d'enveloppe pour relier un avis à un message), BATV (brouillon
  `draft-levine-smtp-batv`) pour l'idée ; aucun HMAC (écart X4).
* **Réception** : `fn::mail_recipient_resolve` reconnaît `rp=<jeton>` sur un domaine actif et
  rend `{ kind: "return", submission, tenant, account }` ; jeton inconnu ou échu → `550 5.1.1`,
  comme une adresse inconnue. Le préfixe `rp=` est **réservé** : une adresse ou un alias qui
  commence par lui est refusé à la création (`MAIL_ADDRESS_RESERVED`).
* **Avis forgés vers une vraie adresse** (décision **E21**) : nos envois n'utilisant jamais une
  adresse ordinaire comme adresse d'enveloppe, un **rapport `delivery-status` à expéditeur vide**
  adressé à une adresse ordinaire est forcément forgé (rétrodiffusion d'un spam qui a usurpé notre
  domaine) : refusé à la fin des données (`550 5.7.1`, `MAIL_DELIVERY_REJECTED`, motif
  `backscatter`), compté. Les autres messages à expéditeur vide (accusés de lecture RFC 8098,
  réponses d'agenda) restent acceptés. Réglage par domaine `backscatter_protection` (vrai par
  défaut) : à couper pour un domaine dont une partie du courrier part par un autre serveur avec
  ses vraies adresses en enveloppe (par exemple une intégration SMTP de `lyxal_notification`
  vers un relais extérieur).
* **Transfert** (§13) : l'adresse de retour à jeton remplace la réécriture SRS (sans signature,
  l'adresse d'origine restant en base) ; un avis revenu est relié à l'envoi de transfert et, s'il
  est permis (§10.2), renvoyé à l'expéditeur d'origine.

## 12. Contrat public de dépôt pour les autres modules (décision **E19**)

### 12.1. Besoin et contrainte

`lyxal_notification` (hébergé par `lyxal-server`, `MIT OR Apache-2.0`) doit pouvoir envoyer par
le serveur de courrier Lyxal sans fournisseur ; plus tard `lyxal_calendar` (invitations iMIP,
lot 18). `scripts/ci/check_agpl_isolation.py` refuse qu'un paquet permissif dépende, même pour
ses essais, d'un paquet AGPL : aucun type Rust de `lyxal_mail` ne peut être utilisé par
`lyxal_notification`. Le programme (§4.2) prévoit déjà « la fonction publique SurrealQL de dépôt
de `lyxal_mail`, sans dépendance Cargo ».

### 12.2. Solutions étudiées

| Solution | Pour | Contre |
| :--- | :--- | :--- |
| A — une fonction SurrealQL qui reçoit le message entier en paramètre | Un seul appel | Message en clair dans une ligne de la base jusqu'à sa reprise par `lyxal-groupware` : contraire au chiffrement au repos (niveau A) ; taille d'un paramètre bornée ; aucune écriture en flux |
| **B — deux fonctions SurrealQL et l'écriture du fichier par `lyxal_storage`** | Même chemin que la remise du lot 5 (`begin` → `StorageService::put` chiffré → `commit`) ; `lyxal_storage` et `lyxal_secrets` sont permissifs et déjà liés par `lyxal-server` ; contenu chiffré dès l'écriture ; message de toute taille ; une seule règle d'envoi pour tous les appelants | Trois appels ; l'appelant doit avoir le service de stockage et la clé maîtresse (c'est déjà le cas de `lyxal-server`) |
| C — un événement publié par le module, consommé par `lyxal_mail` | Découplage apparent | Commande déguisée en événement (le producteur saurait qui le consomme, §5.6.1) ; message à faire passer dans la charge utile, en clair dans `event_outbox` ; aucun refus synchrone |
| D — table de dépôt écrite par le module, lue par `lyxal-groupware` | Simple | Même défaut que A (clair en base), et une table d'un autre module écrite directement (interdit, §1) |

**Recommandation : B.** Aucune dépendance Cargo ni de manifeste (`lyxal_notification` ne déclare
pas `lyxal_mail` : un fournisseur « serveur de courrier Lyxal » vérifie à l'essai de son
intégration que la fonction existe, sinon refus clair) ; le contrat est le texte des deux
fonctions et de leurs résultats, documenté dans le `README.md` comme contrat public stable ; les
résultats reviennent par les événements `mail.submission.*` (le producteur ignore qui écoute) et
par `fn::mail_submission_get`. Le point de licence des fichiers `.surql` installés dans la même
base (programme, P2 point 4) est posé au CTO (question Q3).

### 12.3. Règles du contrat

* **Appelant** : session système d'un hôte ou compte de service qui a la permission nouvelle
  `mail.relay` (portée installation, attribuée à aucun rôle).
* **Expéditeur** : adresse d'un domaine de courrier actif dont la partie locale figure dans la
  liste nouvelle `module_senders` du domaine (par exemple `noreply`, `notifications`), réglée par
  `mail.domain.manage` ; une partie locale de cette liste ne peut pas être une adresse inscrite
  (et inversement) : un module n'écrit jamais au nom d'une personne. Organisation de l'envoi =
  celle du domaine.
* **Message** : message RFC 5322 complet, contrôlé à la préparation (lecture MIME ; `From`
  égal à l'expéditeur annoncé ; `Message-ID` et `Date` ajoutés s'ils manquent) ; un message
  illisible fait échouer ses destinataires (`5.6.0`, événement `failed`).
* **Préparation** par le worker d'envoi, à la première réservation : jeton de retour, signature
  DKIM, préfixe, par `fn::mail_queue_prepare` (sous la garde de la réservation).
* **Limites** : 100 destinataires par envoi, `module_messages_per_hour` par organisation, taille
  de l'organisation.
* **Référence de l'appelant** (`client_reference`) : identifiant opaque de 1 à 128 caractères
  (`fn::validation_identifier`), jamais une adresse ; rendu dans les événements pour que le
  module relie l'issue à son propre travail (étape d'un parcours de notification).

Signatures exactes au §14.2 (`fn::mail_submission_begin`, `fn::mail_submission_commit`,
`fn::mail_submission_abort`, `fn::mail_submission_get`).

## 13. Transfert d'un alias vers l'extérieur (décision **E25**)

* Champ nouveau `mail_address.forward_to` (alias seulement) : 0 à 10 adresses **extérieures**
  (un domaine de l'installation passe par `targets`), contrôlées par `fn::validation_email` ;
  réglé par `mail.domain.manage`. Une adresse de compte ne se transfère pas (Sieve, lot 10).
* À la réception (lot 5), un message accepté pour un alias à cibles extérieures est remis aux
  comptes de `targets` comme aujourd'hui **et** mis en file vers `forward_to` (envoi d'origine
  `forward`) : contenu tel que rangé (avec nos `Received` et `Authentication-Results`), adresse de
  retour à jeton (§11), adresse d'enveloppe d'origine et résultats de réception gardés pour
  l'avis (§10.2). La réponse `250` au serveur expéditeur n'est donnée qu'après l'inscription de la
  remise **et** du transfert.
* Pas de signature DKIM ajoutée ni de scellement ARC (lot 7) : la signature de l'auteur, si le
  message n'est pas modifié, garde DMARC `pass` chez le destinataire final.
* Boucle : la limite de 50 `Received` du lot 5 s'applique ; un alias ne transfère jamais vers une
  adresse de retour (`rp=`).
* Limite : `forward_messages_per_day` par organisation ; au-delà, transfert non fait, remise aux
  comptes locaux seulement, compté et signalé par la sonde.

## 14. SurrealQL (`crates/lyxal_mail/`)

Schéma réécrit en place (§0.3), une seule migration, version `0.1.0`. Règles de SurrealDB 3.3.4
tenues (skill `lyxal-surrealdb`) : jamais `LET $event`, `$before`, `$after`, `$value`, `$input`,
`$parent`, `$self` ni `$this` ; lectures par plages d'identifiants bornées (décision P1 du lot 4) ;
écriture principale de chaque fonction vérifiée (`MAIL_WRITE_FORBIDDEN`).

### 14.1. Tables et champs

| Table | Contenu |
| :--- | :--- |
| `mail_submission` (nouvelle) | `mail_submission:⟨<UUID v7>⟩` ; `tenant` ; `origin` (`submission`, `module`, `forward`, `dsn`, immuable) ; `account` (dépôt authentifié) et `owner` (titulaire, recopié, règle de lecture P1 du lot 4) ; `sender` (adresse annoncée), `header_from` (1 à 10 adresses), `envelope_from` (adresse de retour, ou vide pour `<>`), `return_token` (index unique, `option`), `return_expires_at` ; `client_reference` (`option`, module) ; `content` (`bucket`, `object`, `key`, `size`) ; `prefix` (`option<string>`, 16 Kio au plus, lisible par le compte de service seulement) ; `smtputf8`, `eight_bit` ; `dsn` (`ret` `hdrs` / `full`, `envid` en `xtext` décodé, 100 caractères au plus) ; `require_tls` (`option<bool>`, réservé au lot 7) ; `forward` (`option<object>` : adresse d'enveloppe d'origine, `spf`, `dmarc` de la réception) ; `state` (`pending`, `queued`, `done`) ; `recipient_count`, `open_count` ; `created_at`, `queued_at`, `done_at`, `expires_at` (dépôt + `expire_hours`) |
| `mail_queue_recipient` (nouvelle) | `mail_queue_recipient:⟨<clé de l'envoi>_<10^3 + rang>⟩` ; `tenant`, `owner`, `submission`, `rank` ; `address`, `domain` (forme ASCII), `local` (domaine de l'installation au dépôt) ; `notify` (`never` ou sous-ensemble de `success`, `failure`, `delay` ; absent = défaut), `orcpt` ; `state` (§5.2) ; `attempts`, `next_attempt_at`, `locked_until`, `claim` (jeton de réservation, lisible par le compte de service seulement) ; `last_result` (`stage` : `dns`, `connect`, `tls`, `greeting`, `mail`, `rcpt`, `data`, `local`, `content`, `expired` ; `code`, `enhanced`, `text` assaini de 512 octets, `host`, `tls` { `version`, `verified` }, `at`) ; `delay_sent`, `dsn_sent`, `final_at` |
| `mail_queue_due` (nouvelle, vue) | Échéancier ordonné (décision **E5**) : `mail_queue_due:⟨<10^16 + échéance en µs>_<clé du destinataire>⟩`, `recipient`, `domain` ; tenu par l'événement de `mail_queue_recipient` (ligne posée pour `scheduled`, retirée sinon), fermé à l'écriture directe |
| `mail_queue_destination` (nouvelle) | `mail_queue_destination:⟨<domaine>⟩` ; `suspended_until`, `consecutive_failures`, `last_failure` (`stage`, `at`) ; compte de service et session système seulement |
| `mail_dkim_key` (nouvelle) | `mail_dkim_key:⟨<clé du domaine>_<sélecteur>⟩` ; `tenant`, `domain`, `selector` (`slug`, 63 caractères au plus), `algorithm` (`rsa-sha256`, `ed25519-sha256`), `bits` (2048 pour RSA), `public_key` (Base64 de `p=`, 1 Kio au plus), `secret_path`, `state` (`pending`, `active` ; lot 13 : `retiring`, `retired`), `dns_checked_at`, `activated_at`, `created_at` ; supprimée avec le domaine |
| `mail_send_counter` (nouvelle) | `mail_send_counter:⟨<portée>_<fenêtre>⟩` ; `kind` (`account_messages`, `account_recipients`, `module_messages`, `forward_messages`), `count`, `expires_at` ; écrite par les fonctions de dépôt, purgée par la maintenance |
| `mail_domain` | `module_senders` (0 à 20 parties locales, §12.3), `backscatter_protection` (vrai par défaut, §11) |
| `mail_address` | `senders` (alias : 0 à 50 comptes de l'organisation qui peuvent écrire sous l'alias, §8.3), `forward_to` (alias : 0 à 10 adresses extérieures, §13) ; préfixe `rp=` refusé |
| `mail_settings` | Organisation (plafonnée par l'installation) : `send_recipients_per_message`, `send_messages_per_day`, `send_recipients_per_day`, `module_messages_per_hour`, `forward_messages_per_day` ; installation seulement : `retry_intervals`, `retry_jitter_percent`, `delay_notice_hours`, `expire_hours` (§5.5) |

Index : `mail_submission(return_token)` unique ; `mail_submission(state, done_at)` (purge) ;
`mail_queue_recipient(submission)` ; `mail_dkim_key(domain, state)`. Permissions : lecture d'un
envoi et de ses destinataires par son titulaire (règle par fiche de P1 : `tenant`, `owner`) et par
le compte de service ; jamais par un administrateur d'organisation (M11 : ce sont des
correspondances) ; écritures par les fonctions et les gardes seulement (`fn::mail_write_refusal`
étendue : états, champs immuables, jeton de réservation et préfixe jamais écrits par un
titulaire).

### 14.2. Fonctions publiques nouvelles

| Fonction | Paramètres → résultat | Droit |
| :--- | :--- | :--- |
| `fn::mail_sender_check` | `{ addresses: [1..10], language }` → `{ allowed, refused: [rang] }` (§8.3) | `mail.send` (compte de la session) |
| `fn::mail_submission_begin` | `{ origin (submission, module ; forward, dsn : système et mail.worker), from, header_from: [1..10], recipients: [1..1000 × { address, notify, orcpt }], size, smtputf8, eight_bit, dsn: { ret, envid }, client_reference, return_token, prefix, forward, language }` → `{ submission, tenant, bucket, key, object, return_address }` ; contrôles : droit, expéditeur (§8.3 ou §12.3), limites et compteurs réservés (§8.4), taille de l'organisation, bucket `lyxal-mail` créé s'il manque (chiffré, sans événements, S14), réservation `storage_object_begin` ; `return_token` et `prefix` acceptés du compte de service et de la session système seulement | `mail.send` ; `mail.relay` ou session système (module) ; `mail.worker` (transfert, avis) |
| `fn::mail_submission_commit` | `{ submission, language }` → `{ submission, recipients, queued_at }` ; **une transaction** : fichier écrit et clos (`storage_object_commit` vérifié), destinataires créés (`local` posé par la résolution des domaines de l'installation), échéancier, état `queued` | le même appelant que `begin` |
| `fn::mail_submission_abort` | `{ submission, language }` → `{ released }` ; compteurs rendus, fichier supprimé ; un envoi `pending` non clos est retiré par la maintenance après 1 h | idem |
| `fn::mail_submission_get` | `{ submission, language }` → envoi (sans préfixe ni contenu) et ses destinataires (`state`, `attempts`, `last_result` sans texte distant pour un appelant module, `final_at`) | titulaire ; `mail.relay` pour ses envois `module` ; `mail.worker` |
| `fn::mail_submission_cancel` | `{ submission, language }` → `{ canceled }` : destinataires `scheduled` → `canceled` (un destinataire en cours d'envoi n'est pas interrompu) | idem |
| `fn::mail_queue_claim` | `{ node, limit (1..500), lease_seconds (60..1800), exclude_domains: [0..1000], language }` → `{ claim, items: [{ recipient, submission, tenant, origin, rank, address, domain, local, notify, orcpt, attempts, envelope_from, content, prefix, smtputf8, eight_bit, dsn, size, created_at }] }` ; lecture par l'échéancier (§5.3) | `mail.worker`, session système |
| `fn::mail_queue_renew` | `{ claim, recipients: [1..500], lease_seconds, language }` → `{ renewed }` | idem |
| `fn::mail_queue_prepare` | `{ claim, submission, return_token, prefix, malformed, language }` → `{ prepared }` (envoi `module`, §12.3) | idem |
| `fn::mail_queue_complete` | `{ claim, items: [1..100 × { recipient, outcome (delivered, relayed), host, code, enhanced, tls, at }], language }` → `{ dsn: [{ submission, action, recipients }] }` | idem |
| `fn::mail_queue_fail` | `{ claim, items: [1..100 × { recipient, permanent, stage, code, enhanced, text, host }], destination: { domain, unreachable }, language }` → `{ items: [{ recipient, state, next_attempt_at }], dsn: [...] }` ; échéance suivante, retard, expiration, suspension de la destination (§5.4, §5.5) | idem |
| `fn::mail_queue_release` | `{ claim, recipients: [1..500], not_before, language }` → `{ released }` (arrêt propre, cadence : sans essai compté) | idem |
| `fn::mail_queue_dsn_done` | `{ submission, action (failed, delayed, delivered, relayed), recipients: [1..1000], language }` → `{ marked }` | idem |
| `fn::mail_queue_stats` | `{ language }` → `{ scheduled, running, due, oldest_due_at, suspended_destinations }` (lectures bornées ; pour la sonde et les mesures) | idem |
| `fn::mail_queue_purge` | `{ limit, language }` → `{ submissions, contents, tokens, counters }` (envois finis depuis plus de 14 jours, contenus des envois finis, compteurs échus) ; appelée par `MailMaintenance` | idem |
| `fn::mail_return_record` | `{ submission, items: [1..100 × { recipient, action, status, diagnostic }], language }` → `{ bounced }` (§10.3) | idem |
| `fn::mail_dkim_key_create` | `{ domain, selector, algorithm, bits, public_key, secret_path, language }` → fiche `pending` | `mail.worker`, session système |
| `fn::mail_dkim_key_activate` | `{ key, language }` → fiche `active` | idem |
| `fn::mail_dkim_key_list` | `{ domain, language }` → `{ items: [{ selector, algorithm, state, dns_name, dns_value }] }` | `mail.domain.manage`, `mail.worker` |
| `fn::mail_dkim_signers` | `{ domains: [1..2], language }` → `{ items: [{ domain, selector, algorithm, secret_path }] }` (clés `active`) | `mail.worker`, session système |
| `fn::mail_dkim_pending` | `{ limit, language }` → `{ missing: [{ domain, tenant, algorithm }], pending: [{ key, domain, selector, public_key }] }` (tâche `mail.dkim.provision`) | idem |

**Fonctions étendues** : `fn::mail_recipient_resolve` (adresse de retour `rp=` → `kind:
"return"` ; cibles extérieures d'un alias `forward_to` ; `backscatter_protection` du domaine),
`fn::mail_domain_update` (`module_senders`, `backscatter_protection`), `fn::mail_address_create`
et `fn::mail_address_update` (`senders`, `forward_to`, préfixe réservé), `fn::mail_settings_set`
(§14.1).

**Fonctions internes** (`COMMENT` « Interne ») : `fn::mail_sender_allowed` (règle du §8.3, commune
à `fn::mail_sender_check` et `fn::mail_submission_begin`), `fn::mail_send_counter_take`,
`fn::mail_queue_next_attempt` (échéance suivante, §5.5), `fn::mail_queue_due_key`,
`fn::mail_queue_item_check` (contrôle d'un élément d'un lot du worker), `fn::mail_submission_finish`
(passage à `done`, fichier rendu à la maintenance).

Toutes : `$params: object`, entrées par le moteur de `lyxal_core` (§5.7.8), `fn::result_ok` /
`fn::error_result`, `COMMENT`, écriture principale vérifiée, moins de 300 lignes (la réservation
et l'échec sont découpés en sous-fonctions internes si besoin).

### 14.3. Contrôle des lots du worker (décision **E32**)

`fn::mail_queue_complete`, `_fail`, `_renew`, `_release`, `_dsn_done` et `fn::mail_return_record`
reçoivent des lots (jusqu'à 100 ou 500 éléments) du seul worker d'envoi : comme
`fn::mail_delivery_commit` au lot 5 (décisions S12 et P4), leurs éléments sont contrôlés par appels
directs des primitives du Core et rapport par `fn::validation_checks_report`
(`fn::mail_queue_item_check`), cas que `.agents/AGENTS.md` §5.7.8 réserve à une **décision du
CTO** ; les champs du lot lui-même passent par `fn::validation_fields_execute`. Les fonctions
appelées par un titulaire ou un module (`fn::mail_sender_check`, `fn::mail_submission_*`) gardent
le moteur complet (`fn::validation_fields_execute`, validateurs nommés).

### 14.4. Événements (décision **E27**)

`DEFINE EVENT` sur `mail_queue_recipient`, à l'entrée dans l'état final ou au premier retard,
publication par `fn::event_publish`, résultat vérifié (`THROW` sinon : l'écriture du résultat
est annulée, le worker la refait) ; un événement par destinataire :

| Événement | Quand |
| :--- | :--- |
| `mail.submission.delivered` | `delivered` ou `relayed` (charge : `outcome`) |
| `mail.submission.delayed` | premier passage du délai `delay_notice_hours` |
| `mail.submission.failed` | `failed` ou `expired` |
| `mail.submission.bounced` | avis reçu après acceptation (`bounced`) |

Charge utile, **sans adresse, domaine, sujet ni texte distant** :

```json
{ "tenant": "auth_organization:…", "submission": "mail_submission:…",
  "recipient": "mail_queue_recipient:…", "rank": 0, "origin": "module",
  "client_reference": "notification_job:…", "status": "5.1.1", "attempts": 3,
  "local": false, "at": "…" }
```

Producteur sans consommateur connu (§5.6.1) ; `lyxal_notification` s'y abonnera dans son propre
plan. Aucun événement à la mise en file ni pour un envoi `dsn`.

### 14.5. Erreurs `MAIL_*` nouvelles (`error/<thème>/`)

| Code | Thème | Cas |
| :--- | :--- | :--- |
| `MAIL_SENDER_FORBIDDEN` | `envoi` (nouveau) | Adresse d'expéditeur (`MAIL FROM`, `From`, `Sender`, `Resent-*`) que le compte ou le module ne peut pas utiliser |
| `MAIL_SEND_LIMIT_EXCEEDED` | `envoi` | Limite d'envoi du compte, du module ou des transferts atteinte |
| `MAIL_SUBMISSION_TOO_MANY_RECIPIENTS` | `envoi` | Plus de destinataires que la limite de l'organisation |
| `MAIL_SUBMISSION_NOT_FOUND` | `envoi` | Envoi absent ou invisible |
| `MAIL_SUBMISSION_STATE_INVALID` | `envoi` | Clôture d'un envoi qui n'est pas `pending`, annulation d'un envoi fini |
| `MAIL_QUEUE_CLAIM_LOST` | `file` (nouveau) | Jeton de réservation périmé ou bail échu (garde du §5.3) |
| `MAIL_QUEUE_BATCH_TOO_LARGE` | `file` | Lot du worker au-delà de sa borne |
| `MAIL_DKIM_KEY_EXISTS` | `dkim` (nouveau) | Sélecteur déjà pris pour le domaine |
| `MAIL_DKIM_KEY_NOT_FOUND` | `dkim` | Clé absente |
| `MAIL_ADDRESS_RESERVED` | `adresses` | Adresse qui commence par le préfixe réservé `rp=` |
| `MAIL_MODULE_SENDER_CONFLICT` | `domaines` | Partie locale de `module_senders` déjà inscrite comme adresse, ou l'inverse |

Master data rejouable, français et anglais ; jamais rendus tels quels à un client SMTP (traduits
en codes SMTP). Total : 58 codes `MAIL_*`. Hôte : `GROUPWARE_APPLICATION_KEY_MISSING` (écoute
`submission` sans clé applicative, §16).

### 14.6. Permissions (`seeds/mail_auth.surql`, rejouable)

| Permission | Portée | Mot de passe d'application | Rôles | Donne |
| :--- | :--- | :-: | :--- | :--- |
| `mail.send` (nouvelle) | organisation | oui | membre, administrateur d'organisation | envoyer sous ses propres adresses (§8.3) ; lire et annuler ses envois |
| `mail.relay` (nouvelle) | installation | non | aucun (compte de service d'un module) | déposer par le contrat du §12 sous les `module_senders` d'un domaine ; lire et annuler ses envois `module` |
| `mail.worker` (existante) | installation | non | aucun | en plus : file d'envoi, clés DKIM, retours |
| `mail.domain.manage` (existante) | organisation | non | administrateur d'organisation | en plus : `module_senders`, `backscatter_protection`, `senders` et `forward_to` des alias, lecture des enregistrements DKIM à publier ; **jamais** les envois de ses membres (M11) |

## 15. Types Rust et wrappers (`lyxal_mail`)

| Élément | Contenu |
| :--- | :--- |
| `models/submission.rs` | `SenderCheckParams` / `SenderCheck` ; `SubmissionBeginParams { origin, from, header_from, recipients: Vec<SubmissionRecipient { address, notify, orcpt }>, size, smtputf8, eight_bit, dsn: Option<DsnRequest { ret, envid }>, client_reference, return_token, prefix, forward }` / `SubmissionReservation { submission, tenant, bucket, key, object, return_address }` ; `SubmissionCommitParams` / `SubmissionQueued` ; `SubmissionAbortParams` / `SubmissionReleased` ; `SubmissionGetParams` / `Submission { …, recipients: Vec<QueuedRecipient> }` ; `SubmissionCancelParams` / `SubmissionCanceled` |
| `models/queue.rs` | `QueueClaimParams` / `QueueClaim { claim, items: Vec<ClaimedRecipient> }` ; `QueueRenewParams` / `QueueRenewed` ; `QueuePrepareParams` / `QueuePrepared` ; `QueueCompleteParams { items: Vec<DeliveredItem> }` / `QueueCompleted { dsn: Vec<DsnDue> }` ; `QueueFailParams { items: Vec<FailedItem>, destination: Option<DestinationFailure> }` / `QueueFailed` ; `QueueReleaseParams` / `QueueReleased` ; `DsnDoneParams` / `DsnMarked` ; `QueueStatsParams` / `QueueStats` ; `QueuePurgeParams` / `QueuePurged` ; `ReturnRecordParams` / `ReturnRecorded` |
| `models/dkim.rs` | `DkimKeyCreateParams` / `DkimKey` ; `DkimKeyActivateParams` ; `DkimKeyListParams` / `DkimKeyPage` ; `DkimSignersParams` / `DkimSigners` ; `DkimPendingParams` / `DkimPending` |
| `MailStore` | Un wrapper d'une ligne par fonction du §14.2 (`self.call_fn("mail_queue_claim", params).await`) |
| `outbound` | `OutboundConfig`, `DestinationOverride`, `RelayConfig` ; `OutboundDispatcher` (`LyxalWorker` `lyxal_mail:mail.outbound`, criticité `Required`, envois en cours dans un `JoinSet` du worker, drainés à l'arrêt dans un délai puis rendus par `fn::mail_queue_release`) ; `DestinationLimiter` ; `MxPlan` (§6.1) ; `SmtpClient` (dialogue du §6.2 sur `lyxal_mail_proto::smtp::client`) ; `ConnectionPool` ; `TlsConnectorProvider` (trait, fourni par l'hôte) ; `LocalRoute` (§7) ; `AttemptOutcome` ; `OutboundMetrics` |
| `submission` | `SubmissionHandler` (`SessionHandler` des écoutes `submission`), `SubmissionConfig`, `SubmissionServices` ; traits `SubmissionAuthenticator` (vérification du mot de passe d'application) et `UserSessionOpener` (client SurrealDB au nom de l'utilisateur), implémentés par l'hôte : `lyxal_mail` ne dépend pas du service de `lyxal_auth` |
| `dkim` | `DkimSigner` (en-têtes du §9.2, écriture de `DKIM-Signature`), `DkimKeyCache`, `DkimProvisioner` (logique de la tâche `mail.dkim.provision`) |
| `dsn` | `DsnComposer` (avis du §10.1, sur `lyxal_mail_proto::dsn`), `BounceProcessor` (§10.3), `ReturnToken` (tirage `OsRng`, base 32, `Debug` masqué) |
| `MailError` | Codes du §14.5 ; `is_retryable()` vrai pour `MAIL_QUEUE_CLAIM_LOST` (le worker relit la file) |

Aucun `panic!`, aucun `raw_query()`, aucune tâche hors `LyxalWorker` et `JoinSet` des écoutes et
du worker d'envoi. Dépendances nouvelles de `lyxal_mail` : `lyxal_secrets` (déjà en dépendance
d'essai, devient normale : `SecretsClient` pour les clés DKIM et les identifiants du relais),
`rand_core` (`OsRng`, déjà dans l'arbre), `zeroize` (déjà dans l'arbre). Aucune crate
cryptographique directe (`check_crypto_dependencies.py`).

## 16. Hôte `lyxal-groupware`

### 16.1. Branchement

* Écoutes `protocol = "submission"` : `SubmissionHandler` au lieu de `UnavailableHandler`.
* **Mots de passe d'application** (décision **E30**) : l'hôte construit `AppPasswordService`
  (`AuthStore` sur la session système, `SigningKeyService` sur un `CryptoEngine` de la **clé
  applicative**, même construction que `apps/lyxal-server/src/modules/auth.rs`) ; clé lue de
  `LYXAL_GROUPWARE__CRYPTO__APPLICATION_KEY` (la même valeur que `LYXAL__CRYPTO__APPLICATION_KEY`
  de `lyxal-server`, par l'environnement seulement) ; absente alors qu'une écoute `submission`
  existe : démarrage refusé (`GROUPWARE_APPLICATION_KEY_MISSING`). Nouvelle dépendance de l'hôte :
  `lyxal_auth` (`MIT OR Apache-2.0`, sens permis par `check_agpl_isolation.py`).
* `TlsConnectorProvider` : `tokio_rustls::TlsConnector` sur `lyxal_crypto::tls_client_config`
  (règle 10 : seul l'hôte tient `tokio-rustls`).
* Worker `lyxal_mail:mail.outbound` enregistré quand `[outbound] enabled = true` ; tâche
  `mail.dkim.provision` déclarée dans `seeds/groupware_tasks.surql` et sa planification créée au
  démarrage (comme `mail.maintenance`) ; `MailMaintenance` étendue (`fn::mail_queue_purge`).
* Réception (lot 5) : `fn::mail_recipient_resolve` étendue (retours, transferts), `BounceProcessor`
  et règle `backscatter_protection` branchés dans la chaîne du lot 5 (6f).

### 16.2. Configuration

| Section | Réglages |
| :--- | :--- |
| `smtp` | `hostname` désormais obligatoire aussi dès qu'une écoute `submission` existe ou que `outbound.enabled` est vrai (`EHLO`, `Message-ID`, `Reporting-MTA`) |
| `submission` | Limites de session du §8 (reprises de `SmtpConfig`), `allow_plaintext_auth` (faux ; vrai refusé hors `127.0.0.1`) |
| `outbound` | `enabled`, `source_ipv4`, `source_ipv6`, `ip_families`, `smtp_port` (25), `allow_private_networks` (faux), `tls` (`opportunistic`), `max_connections`, `connections_per_destination`, `messages_per_connection`, `recipients_per_transaction`, délais du §6.2, `idle_timeout_seconds` (60) ; `[[outbound.destinations]]` ; `[outbound.relay]` (§6.7) |
| `observability` | `log_recipient_domain` (`hash` par défaut, `full` pour le débogage, décision **E28**) |

`development.toml` : écoutes `submission` existantes (2587, 2465) servies,
`outbound.allow_private_networks = true`, `outbound.enabled = false` (aucun envoi sur Internet
depuis un poste de développement) ; `production.toml` : exemples des ports 587 et 465 décommentés,
`[outbound]` documentée, rappel des exigences (DNS inverse, SPF, DKIM, DMARC).

### 16.3. Santé, mesures, journal

* Sonde de `lyxal_mail` : « dégradé » si l'échéance la plus ancienne de la file a plus de 15 min
  de retard (file bloquée ou trop lente), si un domaine actif n'a aucune clé DKIM active depuis
  plus de 24 h, si le contenu d'un envoi est illisible, si la limite des transferts est atteinte.
* `/metrics` : file (`scheduled`, `running`, `due`, âge de la plus ancienne échéance), envois
  acceptés et refusés par motif (authentification, usurpation, limites, taille, antivirus,
  illisible), destinataires remis, relayés, retentés, en échec, expirés par étape, avis produits
  et supprimés, avis reçus, rétrodiffusion refusée, connexions ouvertes et réutilisées, TLS
  utilisé, non offert, en repli, durée des transactions, destinations suspendues, messages non
  signés, clés DKIM en attente. Aucune adresse ni aucun domaine.
* Journal (décision **E28**) : une ligne par transaction sortante (envoi, nombre de destinataires,
  destination désignée par une empreinte courte BLAKE3 du domaine, 12 caractères hexadécimaux,
  étape, code, TLS, durée) et par dépôt (session, nombre de destinataires, taille, décision,
  code) ; ni adresse, ni sujet, ni contenu, ni nom de domaine ou de MX sauf
  `log_recipient_domain = "full"` (niveau `debug`).

## 17. Essais

Aucun essai automatique n'appelle un service réel (programme §8) : faux MX, faux relais, résolveur
`StaticResolver`, base embarquée et serveur SurrealDB 3.3.4 (`ws://`) pour les mesures.

**SurrealQL** (`crates/lyxal_mail/tests/`) : `envoi.test.surql` (droit d'expéditeur : adresse du
compte, sous-adresse, alias avec et sans `senders`, adresse d'un autre compte, d'une autre
organisation, domaine désactivé ; limites par message et par jour, compteurs rendus par
`abort` ; `begin` → `commit` crée un destinataire par adresse, `local` juste ; module : sous
`mail.relay` et sous la session système, `module_senders` exigé, conflit avec une adresse
inscrite ; `return_token` et `prefix` refusés d'un titulaire ; annulation), `file.test.surql`
(réservation dans l'ordre de l'échéancier, bail, garde du jeton (`MAIL_QUEUE_CLAIM_LOST` après
expiration et après une autre réservation), reprise d'un destinataire au bail échu sans essai
compté, échéances suivantes et décalage borné, retard une fois, expiration `4.4.7`, suspension
d'une destination puis remise à zéro, `release` sans essai, échéancier égal à la table après
chaque opération, 100 000 destinataires en attente : réservation bornée), `dkim.test.surql`
(création, sélecteur pris, activation, signataires actifs seulement, liste pour l'administrateur
d'organisation, rien pour un membre), `retours.test.surql` (jeton résolu, inconnu, échu ; préfixe
réservé refusé à la création d'une adresse ; `bounced` après `delivered` ; événement), événements
(`mail.submission.*` une fois par destinataire, sans adresse ni domaine ; aucun pour `dsn`),
`droits` et `organisations` complétés (aucune fonction de file pour un membre ou un
administrateur ; un titulaire ne lit que ses envois ; un administrateur ne lit aucun envoi ;
isolement entre organisations), écritures filtrées (`MAIL_WRITE_FORBIDDEN`).

**Rust** :

* `lyxal_crypto` (6a) : §4.
* `lyxal_mail_proto` (6b) : réponses sur une et plusieurs lignes, codes étendus, lignes trop
  longues, LF isolé ; extensions d'`EHLO` (cas de Mox `smtpclient/client_test.go` transposés) ;
  commandes écrites (paramètres DSN en `xtext`, refus de CR et LF) ; bourrage (point en début de
  ligne, dernier octet, `CRLF.CRLF`, propriétés `proptest` : bourrer puis lire par le
  `DataReceiver` du lot 5 redonne les octets) ; `AUTH PLAIN` et `LOGIN` (Base64 invalide,
  `authzid` différent, annulation, longueurs) ; avis écrits puis relus, avis réels de Mox
  `dsn/dsn_test.go` transposés, variante internationale ; cibles de fuzzing.
* `lyxal_mail::outbound` (6d), contre un **faux MX** (serveur SMTP d'essai scripté sur une vraie
  socket, réponses programmables par commande, STARTTLS par le certificat d'essai) : envoi de bout
  en bout et octets reçus identiques (préfixe + fichier) ; `PIPELINING` avec et sans ; 4xx puis
  succès ; 5xx à `RCPT` pour un destinataire sur trois ; 421 d'accueil puis suspension ; aucun MX
  joignable ; MX nul ; `NXDOMAIN` ; MX vers une adresse privée refusé ; `SIZE` dépassé ; 8 bits
  vers un serveur sans `8BITMIME` ; STARTTLS réussi, certificat auto-signé accepté
  (`verified: false`), poignée de main ratée puis repli en clair ; réutilisation d'une connexion ;
  limites par destination et totale ; relais sortant (TLS vérifié exigé, `AUTH PLAIN`, refus d'un
  certificat non vérifié) ; route locale (remise dans une boîte de l'autre organisation,
  `Authentication-Results` attendu, aucun doublon après reprise) ; tentatives et expiration en
  temps simulé ; **arrêt brutal** (§18) ; arrêt propre (destinataires rendus, aucun essai
  compté) ; deux nœuds sur la même base (aucun destinataire envoyé deux fois hors fenêtre de
  doublon, gardes de réservation).
* `lyxal_mail::submission` (6e), dialogues scriptés : `AUTH` avant TLS refusé ; `AUTH` réussi,
  mot de passe faux, révoqué, sans `mail.send` ; trois échecs ; `MAIL` sans `AUTH` (`530`) ;
  **usurpation** : `MAIL FROM` d'un autre compte, `From` d'un autre compte de la même
  organisation, `From` d'un autre domaine, `Sender` usurpé, `From` à deux adresses dont une
  interdite, alias sans `senders`, `Resent-From` ; limites ; `Bcc` retiré, `Message-ID` et
  `Date` ajoutés ; `Received` sans adresse IP ; antivirus ; `250` seulement après inscription
  (panne simulée de la base → `451`, rien en file) ; client `lettre` (déjà en dépendance d'essai
  de l'hôte) en STARTTLS et en TLS implicite.
* **Aucun relais ouvert** : port 25 — un domaine extérieur reste refusé (`550 5.7.1`) avec et sans
  `AUTH` (non annoncé), une adresse `rp=` ne peut pas servir de relais (seuls les jetons valides
  sont acceptés et ils ne sont jamais réexpédiés vers l'extérieur) ; port 587 — aucun envoi sans
  authentification.
* **DKIM vérifié par notre propre vérificateur** : chaque message reçu par le faux MX est vérifié
  par `lyxal_mail::auth` (lot 5) avec la clé publique publiée dans un `StaticResolver` : `pass`
  pour les deux signatures, DMARC `pass` aligné, sur un corpus (en-têtes repliés, 8 bits, UTF-8,
  pièces jointes, 10 Mio) ; un en-tête signé modifié ou ajouté (sur-signature) donne `fail`.
  L'oracle différentiel du lot 5 (`tools/dkim_oracle/`) est étendu pour faire vérifier nos
  signatures par `mail-auth`, à la main.
* **Avis** : échec définitif → avis dans la boîte de l'expéditeur, relu par `parse_dsn` ; retard
  après le délai, une fois ; `NOTIFY=NEVER` ; `NOTIFY=SUCCESS` → `relayed` ; `RET=FULL` ;
  transfert : avis à l'expéditeur d'origine authentifié, aucun sinon ; jamais deux fois après une
  reprise.
* **Retours et rétrodiffusion** (6f) : avis reçu sur `rp=` → `bounced`, événement, avis remis ;
  jeton inconnu → `550 5.1.1` ; avis forgé vers une vraie adresse → `550 5.7.1` ; accusé de
  lecture à expéditeur vide accepté ; `backscatter_protection = false` ; réponse automatique.
* **Transfert** : alias à cibles locales et extérieures ; `250` après les deux inscriptions ;
  limite par jour ; boucle.
* `lyxal-groupware` : configuration (`[outbound]`, `[submission]`, refus sans clé applicative,
  `tls = "none"` refusé) ; bout en bout du binaire : dépôt sur 2587 en STARTTLS, envoi vers un faux
  MX local, avis ; tâche `mail.dkim.provision` (clés créées, activées quand le `StaticResolver`
  montre l'enregistrement) ; deux hôtes.
* **Contrat de module** : essai qui n'utilise **aucun type de `lyxal_mail`** (appels
  `call_fn` par nom, `StorageService` de `lyxal_storage`), comme le fera `lyxal_notification` :
  dépôt, préparation, envoi au faux MX, événements reçus.

`scripts/ci/ci_local.sh` vert avant chaque demande de fusion ; `cargo deny check licenses`
(`webpki-roots` dans `lyxal_crypto`) ; `check_crypto_dependencies.py` ; `check_agpl_isolation.py`
(`lyxal_auth` lié par l'hôte AGPL seulement).

## 18. Mesures et objectifs

Machine de développement à 4 cœurs partagés (référence des lots 4 et 5 ; à refaire sur la machine
de référence), serveur SurrealDB 3.3.4 en mémoire par `ws://`, pool de 8 connexions, messages de
10 Kio, faux MX sur la même machine. Banc : `tests/it/outbound_load.rs` et
`tests/it/submission_load.rs` (binaire d'essai optimisé, hors CI, comme `smtp_load.rs`).

| Mesure | Objectif |
| :--- | :--- |
| Dépôt authentifié, 20 clients, 1 000 messages | ≥ 80 messages acceptés par seconde ; fin des données → `250` p95 ≤ 150 ms (signature DKIM et écriture chiffrée comprises) |
| Envoi vers le faux MX, 100 domaines, file de 10 000 destinataires | ≥ 150 destinataires remis par seconde par nœud ; ≥ 300 sur la machine de référence |
| Délai de prise en charge : `250` du dépôt → début du premier essai | p95 ≤ 1 s sur le nœud qui a reçu, ≤ 3 s depuis un autre nœud ; contrat de module : ≤ 3 s |
| Réservation dans une file de 100 000 destinataires en attente (aucun échu) puis 500 échus | `fn::mail_queue_claim` p95 ≤ 20 ms (sinon repli de l'échéancier, §5.3) |
| **Arrêt brutal** : 20 arrêts `kill -9` du nœud à des instants tirés au hasard pendant l'envoi de 1 000 messages, redémarrage | **0 destinataire perdu** (chacun finit `delivered`, `failed` avec avis, ou `expired`) ; doublons au faux MX ≤ transactions en vol à l'arrêt (relevé) ; 0 doublon par la route locale |
| Relais | **0** message relayé sans authentification (port 25 et 587), sur toute la matrice du §17 |
| Usurpation | **100 %** des cas du §17 refusés |
| DKIM | **100 %** des messages du corpus vérifiés `pass` par notre vérificateur |
| Mémoire | 200 envois simultanés de messages de 25 Mio : mémoire du nœud sous le budget, sans croissance après la fin (lecture en flux) |
| Ouverture d'une session de l'utilisateur au dépôt (§8.2) | ≤ 20 ms p95 (sinon repli sur la session système) |

Résultats et date dans `crates/lyxal_mail/README.md` (« Mesures de l'envoi »).

## 19. Découpage en demandes de fusion (décision **E31**)

| PR | Contenu | Touche | Taille estimée |
| :- | :--- | :--- | :-: |
| **6a** | TLS côté client (§4), essais, `API_CONTRACT.md`, `SECURITY.md` | `lyxal_crypto` | S (≈ 600 lignes) |
| **6b** | Syntaxe du client, `AUTH` côté serveur, paramètres DSN, avis écrits et lus, fuzzing, `SOURCES.md` (§3) | `lyxal_mail_proto` | M (≈ 3 000) |
| **6c** | SurrealQL (§14) : tables, fonctions, gardes, échéancier, événements, erreurs, permissions, banc ; wrappers et modèles Rust ; mesure de la réservation | `lyxal_mail` | M (≈ 5 000) |
| **6d** | Envoi : worker, résolution, client, TLS opportuniste, `PIPELINING`, pool, limites, relais, route locale, avis produits, préparation du contrat de module ; DKIM (§9 : clés, tâche `mail.dkim.provision`, activation par le DNS, signature) ; hôte (`[outbound]`, connecteur TLS, worker, tâche) ; faux MX, essais d'arrêt brutal, mesures | `lyxal_mail`, `lyxal-groupware` | L (≈ 7 500) |
| **6e** | Dépôt 587 / 465, mots de passe d'application dans l'hôte, droit d'expéditeur, limites, traitement et signature du message déposé, essais d'usurpation, mesures | `lyxal_mail`, `lyxal-groupware` | L (≈ 4 500) |
| **6f** | Avis reçus, adresses de retour à la réception, rétrodiffusion, transfert d'alias vers l'extérieur, documents finaux | `lyxal_mail`, `lyxal-groupware` | M (≈ 3 000) |

Ordre : 6a, 6b et 6c en parallèle ; puis 6d ; puis 6e ; puis 6f. Chaque demande compile, passe la
CI et laisse le dépôt cohérent ; **utilisable seule** : après 6d, un module envoie par le contrat
du §12, messages signés en DKIM ; après 6e, les personnes envoient depuis leur logiciel ; 6f
ajoute les retours et le transfert. Taille totale : **XL** (≈ 23 000 lignes, essais compris), conforme au programme.

## 20. Documents mis à jour

`crates/lyxal_mail/{README,ROADMAP,SOURCES}.md` (envoi, contrat public de dépôt documenté comme
stable, mesures, points ouverts de l'envoi, essais réels du lot 6 ; KumoMTA ajouté aux sources
figées du §1 de `SOURCES.md`, commit `81f191dff64876f84ca949b7e1d7771ba335800b`, `Apache-2.0`,
et à `scripts/sources/fetch_sources.sh`, décision P14) ;
`crates/lyxal_mail_proto/{README,ROADMAP,SOURCES}.md` (client SMTP, `AUTH`, DSN) ;
`crates/lyxal_crypto/{README,API_CONTRACT,SECURITY,ROADMAP}.md` (TLS côté client fait) ;
`crates/lyxal_auth/README.md` (permissions `mail.send`, `mail.relay` déclarées par le courrier ;
mots de passe vérifiés par `lyxal-groupware`) ; `apps/lyxal-groupware/{README,ROADMAP,SOURCES}.md`
et `docs/PRODUCTION-CHECKLIST.md` (ports 587 et 465, port 25 sortant, DNS inverse, SPF, DKIM,
DMARC, clé applicative partagée, relais) ; `crates/lyxal_notification/ROADMAP.md` (fournisseur
« serveur de courrier Lyxal » : contrat disponible, plan à écrire) ; `.agents/AGENTS.md` §6
(`lyxal_mail` : envoi ; `lyxal_mail_proto` : client SMTP, DSN ; `lyxal_crypto` : TLS côté client)
et §11.3 (tableau des primitives : TLS client ; règle 10 étendue au client) ;
`.agents/rules/lyxal_standards_and_checklist.md` §11.3 et §13 (même mise à jour) ;
`scripts/ci/check_crypto_dependencies.py` (commentaire : `ClientConfig` construit par
`lyxal_crypto`) ; `docs/14-roadmap/ROADMAP_NOYAU.md` ; `implementation_plan.md` racine (lot 6
réalisé ; numéro de `REQUIRETLS` corrigé). Ce plan est supprimé après la fusion de 6f.

## 21. Risques

| Risque | Ce qu'il faut savoir | Parade |
| :--- | :--- | :--- |
| **Relais ouvert** | Le pire défaut d'un serveur de courrier : listes noires en quelques heures | Port 25 inchangé (aucun relais) ; dépôt seulement après `AUTH` sous TLS ; adresses de retour jamais réexpédiées ; transfert limité aux alias réglés par un administrateur et compté ; matrice d'essais (§17, §18) |
| **Usurpation interne** | Un membre écrit au nom d'un autre membre ou d'un dirigeant | Règle unique en SurrealQL (§8.3), appliquée à l'enveloppe et aux en-têtes, trois fois ; essais (§17) |
| **Compte compromis** | Un mot de passe d'application volé envoie du spam | Limites par compte (§8.4), révocation immédiate par `lyxal_auth`, antivirus, mesures d'envoi par compte ; anti-spam sortant au lot 11 |
| **Délivrabilité** | Sans DNS inverse, SPF, DKIM et DMARC alignés, réputation d'IP et montée progressive, le courrier part en indésirables | DKIM double et aligné, adresse de retour alignée, `EHLO` = DNS inverse ; limites par destination pour la montée en charge ; documentation d'exploitation ; essais réels (§22). Reste un travail d'exploitation continu (programme §10) |
| **Port 25 sortant fermé** | Fréquent chez les hébergeurs | Relais sortant (§6.7) |
| **Perte de messages** | Un `250` donné avant l'inscription, ou un résultat perdu dans un arrêt | `250` après `commit` seulement ; bail et reprise (§5.3) ; essai d'arrêt brutal (§18) |
| **Doublons** | Arrêt entre le `250` distant et l'écriture du résultat | Fenêtre bornée et mesurée ; route locale idempotente ; RFC 5321 §6.1 |
| **Rétrodiffusion** | Avis envoyés à des adresses forgées | Avis jamais envoyés sur Internet pour un dépôt (boîte de l'expéditeur) ; transferts : avis seulement à un expéditeur authentifié ; avis forgés refusés (§11) |
| **TLS opportuniste** | Sans vérification, une interception active reste possible | Conforme à la RFC 7435 et à la pratique (Postfix, Mox) ; MTA-STS et DANE au lot 7 ; `verified` mesuré |
| **Clé applicative dans l'hôte exposé** | `lyxal-groupware` peut signer des jetons d'accès de `lyxal_auth` | Nécessaire aux mots de passe d'application (aussi pour IMAP, lot 8) ; question Q2 |
| **Charge de la base** | Une ligne par destinataire et plusieurs écritures par essai | Échéancier borné, lots, mesures (§18) ; purge à 14 jours |
| **Limites par nœud** | Sur plusieurs nœuds, les limites par destination s'additionnent | Documenté ; partage en base possible plus tard si nécessaire (comme les cadences du lot 3) |
| **Licence du contrat SurrealQL** | `lyxal_notification` (MIT) appellera des fonctions SurrealQL installées par un module AGPL | Aucune liaison Cargo (contrôle CI) ; portée de la licence sur les `.surql` : question Q3 (programme P2, point 4) |

## 22. Essais réels (ROADMAP, décisions P11, P12)

**Ils attendent les moyens que seul le CTO peut fournir (P11)** : un nom de domaine d'essai et la
main sur son DNS (MX, SPF, DKIM, DMARC), une adresse IP publique avec le **port 25 ouvert en
sortie** et la main sur son **DNS inverse**, des boîtes d'essai chez Gmail, Outlook.com et Yahoo,
et, si l'hébergeur ferme le port 25, un compte de relais SMTP. Aucun essai réel n'est fait sans
eux ; les essais automatiques du §17 ne touchent aucun service réel. Ajouts à
`crates/lyxal_mail/ROADMAP.md` (les deux lignes du lot 6 y sont déjà) :

| Préalable | Action | Résultat attendu |
| :--- | :--- | :--- |
| Domaine, IP, DNS inverse, SPF, DKIM (enregistrements rendus par `fn::mail_dkim_key_list`), DMARC | Envoyer depuis Thunderbird (587 et 465) vers Gmail, Outlook.com, Yahoo | En boîte de réception ; SPF, DKIM (RSA ; Ed25519 là où il est lu) et DMARC `pass` dans les en-têtes reçus ; TLS utilisé |
| Idem | Envoyer vers une adresse inexistante de chaque fournisseur | Refus à `RCPT` ou avis reçu sur `rp=` ; avis dans la boîte de l'expéditeur ; `mail.submission.failed` ou `.bounced` |
| Idem, serveur de destination arrêté | Envoyer vers un domaine d'essai dont le MX ne répond pas | Tentatives espacées, avis de retard après 4 h, échec après 5 jours |
| Idem | Apple Mail, Outlook, client Android | Dépôt accepté ; `AUTH LOGIN` d'Outlook ; usurpation refusée avec un message lisible |
| Relais du fournisseur | Envoi par `[outbound.relay]` | TLS vérifié, message reçu |
| Alias transféré vers Gmail | Recevoir d'un domaine en `p=reject` signé, transférer | Remis chez Gmail (DKIM de l'auteur intact) ; avis renvoyé à l'expéditeur authentifié seulement |
| Outils publics de contrôle (`mail-tester` ou équivalent, à choisir par le CTO) | Envoyer un message type | Score sans pénalité d'authentification |

## 23. Ce qui n'a pas pu être vérifié

* **Rien n'a été compilé ni exécuté** ; tailles et objectifs sont des estimations.
* Stalwart : `outbound/{delivery,client,session,lookup}.rs`, `queue/{spool,manager,dsn}.rs`,
  `inbound/{auth,dkim}.rs` lus par leur liste de fonctions et leurs valeurs par défaut seulement,
  pas ligne à ligne ; la file de Stalwart reste un modèle (X6).
* KumoMTA : documentation et deux fichiers lus ; valeur par défaut de `connection_limit`, calcul
  exact du nom de « site » et règles de mise en forme du trafic (« shaping ») non relus.
* Mox : `queue/direct.go` (choix des IP, repli TLS en clair) lu en partie ; le comportement exact
  de repli en clair après un échec de poignée de main en mode opportuniste est à confirmer en 6d
  sur `smtpclient/client.go`.
* `rustls` 0.23.46 (version de `Cargo.lock`) : forme exacte de l'interface du vérificateur de
  certificat (`ServerCertVerifier`, `danger`) et accès à la version et à la suite négociées : à
  confirmer en 6a.
* SurrealDB 3.3.4 : coût d'un client authentifié par jeton ouvert par session SMTP (§8.2) ;
  application des permissions de table dans `fn::mail_submission_begin` appelée par un
  titulaire ; création d'un bucket de `lyxal_storage` depuis une fonction de `lyxal_mail`
  (`fn::storage_bucket_create` sous la session de l'appelant) ; rendement de l'échéancier ordonné
  (§5.3) : à mesurer en 6c.
* Qualité du générateur de `rand::uuid::v7()` (jeton de réservation : sert de garde, pas de
  secret) : non vérifiée ; aucun secret n'est tiré en SurrealQL.
* Prise en charge d'Ed25519-SHA256 (RFC 8463) par Gmail, Outlook.com et Yahoo : non vérifiée
  (d'où la double signature) ; `AUTH LOGIN` encore exigé par Outlook : de mémoire.
* RFC citées : 3207, 3461, 3463, 3464, 3834, 3848, 4616, 4954, 5321, 6376, 6409, 6522, 6531,
  6533, 7435, 7505, 8058, 8098, 8301, 8314, 8463, 8689 ; numéro de `REQUIRETLS` (8689) vérifié dans
  Mox ; les autres sont de mémoire, à revérifier pendant l'écriture (comme au lot 5).

## 24. Décisions soumises au CTO

| N° | Question | Recommandation |
| :- | :--- | :--- |
| **E1** | Porter ou écrire sur le modèle ? | Écrire pour Lyxal sur le modèle de Stalwart (`smtp/queue`, `smtp/outbound`, `inbound/auth.rs`), Mox (`queue`, `smtpclient`, `dsn`) et KumoMTA ; cas d'essai de Mox transposés (MIT) ; tout inscrit dans les `SOURCES.md` (X6) |
| **E2** | Place de `lyxal_scheduler` | File à tables et worker propres ; `lyxal_scheduler` pour la maintenance (étendue) et la tâche `mail.dkim.provision` seulement (§5.1) |
| **E3** | Unité de file | Un enregistrement par destinataire, regroupés par (envoi, domaine) pour une transaction ; destination = domaine de routage (pas de « site » MX au lot 6) |
| **E4** | Reprise après arrêt | Réservation sous bail de 10 min renouvelé, jeton de réservation exigé par toute écriture, reprise par expiration, résultat écrit après chaque transaction ; doublon borné accepté (RFC 5321 §6.1) |
| **E5** | Lecture de la file sous SurrealDB 3.3.4 | Échéancier ordonné `mail_queue_due` lu par plages bornées ; repli sur l'index seul si la mesure le permet |
| **E6** | Tentatives et expiration | 5, 10, 20, 40, 80 min puis toutes les 2 h, ± 10 % ; avis de retard à 4 h ; expiration à 5 jours ; réglables par l'installation |
| **E7** | Limites par destination | Par nœud : 100 connexions, 4 par destination, 100 messages par connexion, 100 destinataires par transaction, débit facultatif par domaine ; suspension d'une destination injoignable (5 min doublé, 2 h au plus) |
| **E8** | Résolution et adresses | MX (5), 2 adresses par MX, IPv4 puis IPv6 (réglable), MX implicite, MX nul et `NXDOMAIN` définitifs, adresses privées et réservées refusées hors essais |
| **E9** | TLS opportuniste | STARTTLS quand il est annoncé, certificat non vérifié mais noté, une reconnexion en clair après un échec de poignée de main ; vérification au lot 7 |
| **E10** | Extensions du client | `PIPELINING` utilisé ; `DATA` (pas `BDAT`) ; `SIZE` respecté ; aucune conversion 8 bits ni UTF-8 (échec définitif) ; paramètres DSN transmis quand ils sont annoncés |
| **E11** | Connexions | Pool par MX, adresse et mode TLS, 60 s d'inactivité, `RSET` après un échec seulement |
| **E12** | TLS côté client dans `lyxal_crypto` (C8) | `tls_client_config` avec deux modes, `Opportunistic` (RFC 7435) et `WebPki` (`webpki-roots` 1.0, déjà admis) ; `tokio-rustls` dans l'hôte seulement (§4, question Q1) |
| **E13** | Relais sortant | Facultatif, TLS vérifié obligatoire, `AUTH PLAIN`, identifiants dans `lyxal_secrets` (X7) |
| **E14** | Authentification du dépôt | 587 (STARTTLS exigé) et 465 (TLS implicite) ; `AUTH PLAIN` et `LOGIN` après TLS ; mot de passe d'application ; permission nouvelle `mail.send` ; aucun bannissement réseau pour les échecs ; fonctions sous la session de l'utilisateur |
| **E15** | Droit d'envoyer sous une adresse | Adresses du compte, sous-adresses, alias qui le nomment dans `senders` ; contrôle de `MAIL FROM`, `From`, `Sender`, `Resent-*` en SurrealQL ; `550 5.7.1` |
| **E16** | Limites d'envoi | 100 destinataires par message, 1 000 messages et 2 000 destinataires par compte et par jour ; 10 000 messages par heure pour les modules d'une organisation ; réglables par organisation sous le plafond de l'installation |
| **E17** | Message déposé | Lecture MIME, `Bcc` retiré, `Message-ID` et `Date` ajoutés, antivirus si configuré, `Received` sans adresse IP du client |
| **E18** | DKIM | Deux clés par domaine (RSA 2048 et Ed25519), deux signatures, `relaxed/relaxed`, en-têtes de Mox étendus et sur-signés, ni `l=` ni `x=` ; clés générées par la tâche `mail.dkim.provision`, rangées dans `lyxal_secrets`, activées quand le DNS les montre ; signature à l'entrée en file ; cache des clés ouvertes de 10 min ; rotation au lot 13 |
| **E19** | Contrat public de dépôt | Solution B : `fn::mail_submission_begin` / `_commit` + écriture par `lyxal_storage`, issue par les événements `mail.submission.*` ; appelant `mail.relay` ou session système ; expéditeurs `module_senders` ; aucune dépendance Cargo ni de manifeste (§12, question Q3) |
| **E20** | Adresses de retour | `rp=<jeton>@<domaine>`, jeton de 128 bits tiré par `OsRng`, rangé sur l'envoi, 14 jours ; préfixe réservé ; aucun HMAC (X4) |
| **E21** | Rétrodiffusion | Rapport `delivery-status` à expéditeur vide adressé à une adresse ordinaire refusé (`550 5.7.1`) ; réglage `backscatter_protection` par domaine (vrai par défaut) |
| **E22** | Avis produits | Dépôt authentifié : avis dans la boîte de l'expéditeur, jamais sur Internet ; module : événements seulement ; transfert : avis à l'expéditeur d'origine authentifié seulement ; `NOTIFY` par défaut `FAILURE,DELAY`, `RET=HDRS` ; `DSN` annoncé sur 587 / 465, toujours pas sur 25 |
| **E23** | Avis reçus | Lus, destinataire `bounced`, événement, avis remis à l'expéditeur d'un dépôt authentifié |
| **E24** | Courrier entre organisations de l'installation | Par la file, remis par la chaîne de réception du lot 5 sans réseau ; DKIM vérifié contre la clé enregistrée, DMARC calculé, SPF et `iprev` `none` (X5) |
| **E25** | Transfert d'un alias vers l'extérieur | 10 cibles extérieures au plus, par la file, adresse de retour à jeton, sans ARC (lot 7), limite par organisation (question Q4) |
| **E26** | `REQUIRETLS` (RFC 8689) | Au lot 7 ; paramètre refusé et extension non annoncée au lot 6 (X1) |
| **E27** | Événements | `mail.submission.delivered`, `.delayed`, `.failed`, `.bounced`, un par destinataire, sans adresse ni domaine, avec `client_reference` (X2) |
| **E28** | Journal | Destination par empreinte courte ; aucun domaine ni MX en clair sauf réglage de débogage |
| **E29** | Contenu en file | Chiffré dans le bucket `lyxal-mail` de l'organisation (`queue/…`), lu en flux, supprimé à la fin de l'envoi ; préfixe signé en base |
| **E30** | Mots de passe d'application dans `lyxal-groupware` | L'hôte construit `AppPasswordService` avec la clé applicative partagée avec `lyxal-server` ; démarrage refusé sans elle quand une écoute `submission` existe (question Q2) |
| **E31** | Découpage | Six demandes de fusion 6a à 6f (§19) |
| **E32** | Contrôle des lots du worker | Primitives du Core appelées directement et `fn::validation_checks_report` pour les éléments des lots du worker d'envoi (cas réservé à la décision du CTO par §5.7.8) ; moteur complet pour toutes les autres fonctions |

## 25. Questions au CTO

Peu de questions : les autres points sont tranchés par les décisions du §24, que le CTO valide
ou corrige en bloc.

| N° | Question | Recommandation |
| :- | :--- | :--- |
| **Q1** | Extension de `lyxal_crypto` pour le TLS côté client (E12) : accepter un mode **opportuniste sans vérification du certificat** (seule la signature de la poignée de main est contrôlée) et les racines figées de `webpki-roots` pour le mode vérifié ? | **Oui.** C'est la pratique de tous les serveurs de courrier tant que le domaine destinataire ne publie ni MTA-STS ni DANE (lot 7) ; refuser les certificats non vérifiés ferait échouer une part importante des envois. Le vérificateur reste dans `lyxal_crypto`, le mode est noté à chaque envoi ; `webpki-roots` est déjà dans l'arbre et sa licence déjà admise |
| **Q2** | `lyxal-groupware` doit-il recevoir la **clé applicative** de `lyxal-server` (E30) pour vérifier les mots de passe d'application et signer les jetons de leurs sessions ? | **Oui**, par l'environnement seulement, comme la clé maîtresse au lot 5. IMAP (lot 8), POP3 et CalDAV en auront le même besoin. L'autre voie (faire vérifier les mots de passe par `lyxal-server` sur un appel réseau interne) ajoute un service et un point de panne sans réduire vraiment le risque : un hôte qui vérifie des mots de passe est de toute façon une cible |
| **Q3** | Contrat public de dépôt (E19) : valider la solution B, et trancher le point de licence des fonctions SurrealQL d'un module AGPL appelées par un module `MIT OR Apache-2.0` installé dans la même base (programme, P2 point 4) ? | **Valider B.** Aucun code AGPL n'est lié (contrôle `check_agpl_isolation.py`), le contrat passe par la base comme pour tout module. Le point de licence reste une décision du CTO (F2) ; tant qu'il n'est pas tranché, `lyxal_notification` ne commence pas son fournisseur « serveur de courrier Lyxal », mais le contrat est livré et essayé dans `lyxal_mail` |
| **Q4** | Garder le **transfert d'un alias vers l'extérieur** (E25) dans le lot 6, ou le reporter au lot 13 avec ARC (lot 7) et les alias à la SimpleLogin ? | **Le garder en 6f**, dernière demande de fusion, retirable seule : il réutilise la file et les adresses de retour, et la feuille de route l'attend au lot 6. Sans ARC, un message transféré garde DMARC `pass` chez le destinataire tant que l'auteur l'a signé et qu'il n'est pas modifié ; les autres cas échouent comme chez tout transfert sans ARC |
| **Q5** | Moyens réels du §22 (P11) : quand le CTO peut-il fournir domaine, IP avec port 25 sortant et DNS inverse, boîtes d'essai, et au besoin un compte de relais ? | **À la fusion de 6d**, pour essayer l'envoi par le contrat de module dès qu'il existe, puis le dépôt à la fusion de 6e. Sans ces moyens, le lot se ferme sur les essais automatiques seulement, et la délivrabilité réelle reste non mesurée |

## Checklist (`.agents/rules/lyxal_standards_and_checklist.md` §13)

* [ ] **Architecture** : syntaxe dans `lyxal_mail_proto` ; file, envoi, dépôt, DKIM, avis dans
  `lyxal_mail` ; TLS côté client dans `lyxal_crypto` ; mots de passe d'application par le service
  de `lyxal_auth`, branché par l'hôte ; aucun cycle (`lyxal_mail` → `lyxal_secrets` ;
  `lyxal-groupware` → `lyxal_auth`) ; aucun code AGPL dans un crate permissif ; contrat de module
  sans dépendance Cargo.
* [ ] **Core** : entrées par `fn::validation_fields_execute` (chemin d'envoi) et par le moteur
  complet (administration) ; `fn::validation_checks_report` pour les lots du worker sur décision
  E32 ; aucune règle générique réécrite ; aucune extension du Core.
* [ ] **SurrealQL** : `fn::mail_<action>($params: object)`, `fn::result_ok` / `fn::error_result`,
  `COMMENT`, moins de 300 lignes, écritures vérifiées (`MAIL_WRITE_FORBIDDEN`), lectures bornées,
  variables réservées de SurrealDB 3.3.4 jamais déclarées, banc complet.
* [ ] **Rust** : `XxxParams` / `XxxResult`, wrappers `store.call_fn`, aucun `panic!`, aucun
  `raw_query()` métier, aucun secret exposé (`Zeroizing`, `SecretString`, `Debug` masqué), workers
  `LyxalWorker` seulement.
* [ ] **Erreurs** : 11 codes `MAIL_*` et 1 code `GROUPWARE_*` nouveaux en master data ; aucune
  erreur silencieuse (chaque refus, échec d'envoi et avis supprimé journalisé et compté).
* [ ] **Événements** : `mail.submission.*` par `fn::event_publish` vérifié ; charge sans donnée
  personnelle ; aucun consommateur connu.
* [ ] **Cryptographie** : TLS côté client, DKIM, génération des clés et BLAKE3 par
  `lyxal_crypto` ; `OsRng` pour les jetons ; clés privées rangées dans `lyxal_secrets` par
  `export_pkcs8` seulement ; aucune crate cryptographique directe ; extension Q1 validée avant
  tout code.
* [ ] **Chiffrement des boîtes** : contenu en file chiffré (niveau A) ; aucun contrat ne suppose le
  contenu des boîtes lisible au-delà de la remise `platform`.
* [ ] **Zéro dette** : schéma réécrit en place ; événements nommés sans alias ; plan supprimé après
  fusion ; `ROADMAP.md` tenue ; versions `0.y.z`.
* [ ] **Provenance** : `SOURCES.md` de `lyxal_mail`, `lyxal_mail_proto` et de l'hôte (Stalwart,
  Mox, KumoMTA avec son commit et sa licence) ; aucune partie `LicenseRef-SEL`.
* [ ] **Validation CTO** : ce plan, décisions E1 à E32, questions Q1 à Q5.
