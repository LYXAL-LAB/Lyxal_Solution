# `lyxal_mail_proto` — syntaxes du courrier

**État : lot 6 du programme courrier, sous-lot 6b réalisé (client SMTP, `AUTH`, avis).** Crate
Rust membre du workspace, sous licence `AGPL-3.0-only`. Il contient trois modules : `mime`, la
lecture d'un message (lot 4) ; `smtp`, la syntaxe SMTP côté serveur (lot 5, `AUTH` au lot 6) et
côté client (lot 6) ; `dsn`, l'écriture et la lecture des avis de non-remise (lot 6). Les
syntaxes des autres protocoles arrivent avec les lots qui les servent (voir
[`ROADMAP.md`](ROADMAP.md)).

Le programme courrier, agendas et contacts (architecture, 23 lots, décisions F1 à F5 et P1 à P15
du CTO) est décrit par `implementation_plan.md` à la racine du dépôt. Utilisé par le dépôt d'un
message de `lyxal_mail` (`MailIngest`), qui range enveloppe et structure en base, et par la
session SMTP entrante de `lyxal_mail` (`lyxal_mail::smtp`, lot 5) ; le client d'envoi, le dépôt
authentifié et les avis de `lyxal_mail` (sous-lots 6d à 6f) s'appuient sur la syntaxe du lot 6.

## Objet

Crate **Rust pur, sans base de données ni logique métier** (comme `lyxal_parsing`) : il lit les
langages du courrier et rend des types Lyxal, rien d'autre. Il n'écoute aucun port, n'ouvre
aucune session, ne touche pas à SurrealDB et ne décide d'aucune règle (accepter un destinataire,
ranger un message) : tout cela appartient à [`lyxal_mail`](../lyxal_mail/README.md). Pas de
`tokio`, pas de cryptographie, aucune clé lue ; les mots de passe lus par `AUTH` sont seulement
gardés dans des tampons effacés à leur libération (`zeroize`).

## Lecture MIME (`lyxal_mail_proto::mime`)

```rust
pub fn parse(raw: &[u8], limits: &MimeLimits) -> Result<ParsedMessage, MimeError>;
```

`ParsedMessage` porte ce dont IMAP (`ENVELOPE`, `BODYSTRUCTURE`) et JMAP ont besoin pour lister
un message sans ouvrir son fichier, et rien de plus (ni corps, ni texte des pièces jointes, ni
aperçu, décision M8) :

| Champ | Contenu |
| :--- | :--- |
| `envelope` | Valeur brute de `Date`, sujet décodé, adresses de `From`, `Sender`, `Reply-To`, `To`, `Cc`, `Bcc` (groupes compris), `Message-ID`, `In-Reply-To`, `References` (sans `<>`) |
| `structure` | Arbre des parties : type et sous-type en minuscules, paramètres, disposition, nom de fichier (RFC 2231 décodé), `Content-ID`, description, langues, emplacement, encodage de transfert, positions dans le message brut (`header_offset`, `body_offset`, `end_offset`), taille et nombre de lignes du corps transmis, pièce jointe ou non, réparation signalée (`malformed`) ; messages joints lus avec leur enveloppe |
| `thread` | `Message-ID` et ancêtres sans doublon, du plus proche au plus lointain (`In-Reply-To`, puis `References` de la fin vers le début) |
| `base_subject` | Sujet de base (RFC 5256 §2.1) : préfixes de réponse et de transfert retirés par `mail-parser` (`thread_name`), blancs ramenés à une espace |
| `sent_at` | Date de `Date` (`time::OffsetDateTime`), `None` si absente ou illisible |
| `has_attachment` | Au moins une pièce jointe : disposition `attachment`, message joint, ou nom de fichier sans disposition `inline` ; un `multipart` par sa seule disposition `attachment` (parties des messages joints exclues) |
| `is_report` | Partie racine `multipart/report` (avis de non-remise : pas de rapprochement de fil par le sujet) |

`parse` ne rejette presque rien : un message reçu se garde même mal formé (frontière absente,
partie coupée, type incomplet, date illisible). `MimeError` seulement pour un message vide, sans
aucun champ d'en-tête lisible, ou au-delà des limites ; `lyxal_mail` la traduit en
`MAIL_MESSAGE_MALFORMED`. Les erreurs ne contiennent aucune donnée du message.

### Limites

| Limite (`MimeLimits`) | Défaut | Effet |
| :--- | -: | :--- |
| `max_depth` | 20 | Profondeur de la structure (racine 0, +1 par partie de `multipart` et par message joint) |
| `max_parts` | 1 000 | Parties, messages joints compris (jusqu'à 65 535) |
| `max_addresses` | 1 000 | Adresses de l'enveloppe du message et de ses messages joints |

La taille du message est bornée par l'appelant (taille maximale et budget mémoire de
`lyxal_mail`). `mail-parser` lit le message en place sans décoder les corps ; seul le contenu
des messages joints encodés est décodé pour être lu.

### Comment `mail-parser` est utilisé

* Version **1.0.1** (Rust 1.98, décision du CTO du 21 novembre 2026), fonction `full_encoding`
  (jeux de caractères à plusieurs octets par `encoding_rs`) ; champs non utilisés ignorés.
* `mail-parser` 1.0 range parties et messages joints dans des tables plates et borne lui-même la
  profondeur, le nombre de parties et l'imbrication des messages joints encodés (trois niveaux ;
  au-delà, la partie reste une feuille marquée `malformed`). Il est réglé un cran au-dessus de
  `MimeLimits` : la partie de trop est lue, puis refusée par ce crate (`TooDeep`,
  `TooManyParts`).
* La projection en types Lyxal n'est pas récursive (pile explicite) : sa pile d'appel ne dépend
  pas de la profondeur du message, même sous `max_depth = 255`.
* **Messages joints encodés** (`message/rfc822` ou `message/global` en `base64` ou
  `quoted-printable`) : décodés et lus par `mail-parser` ; leurs parties n'ont pas de positions
  (`position: None`) : elles ne sont pas lisibles par plage dans le fichier.

## Syntaxe SMTP (`lyxal_mail_proto::smtp`)

Lecture des commandes d'un serveur expéditeur et écriture de nos réponses (RFC 5321), pour la
réception sur le port 25 (§4 du plan du lot 5). Aucune décision
de session ici : états, destinataires, politique et délais appartiennent à `lyxal_mail::smtp`.

| Élément | Rôle |
| :--- | :--- |
| `CommandReceiver` | Accumule une ligne de commande, la contrôle et la lit ; consomme **une ligne au plus** par appel (`Ingested { consumed, item }`) : le reste de l'entrée revient à l'appelant |
| `parse_command`, `Request` | `EHLO`, `HELO`, `MAIL`, `RCPT`, `DATA`, `BDAT`, `RSET`, `NOOP`, `QUIT`, `STARTTLS`, `VRFY`, `EXPN`, `HELP`, `AUTH <mécanisme> [réponse initiale]` (nom de mécanisme SASL contrôlé, réponse initiale gardée dans un `SaslData`) ; `LHLO`, `ETRN`, `ATRN`, `BURL` reconnus pour être refusés (`502`) |
| `MailFrom`, `RcptTo` | Chemin (`<>`, `<Postmaster>`, boîte, adresse littérale `[IPv4]` / `[IPv6:…]`, route source lue puis signalée), `SIZE`, `BODY` (`7BIT`, `8BITMIME`, `BINARYMIME`), `SMTPUTF8`, `AUTH=` (RFC 4954 §5, `uses_auth`) ; paramètres DSN (`RET`, `ENVID`, `NOTIFY`, `ORCPT`, `uses_dsn`) acceptés par la session seulement là où `DSN` est annoncé (dépôt authentifié, décision E22) ; `ENVID` décodé par `decoded_envid`, `ORCPT` par `DsnOrcpt::decode` ; `REQUIRETLS` et tout autre paramètre : `555 5.5.4` (décision E26) |
| `Mailbox::parse`, `Domain::parse` | Boîte et domaine lus d'une chaîne (adresses en base, nom `EHLO` du client) |
| `DataReceiver` | Contenu de `DATA` jusqu'à la seule fin `CRLF.CRLF`, bourrage retiré |
| `BdatReceiver` | Morceaux `BDAT` (RFC 3030) : exactement la taille annoncée, fins de ligne contrôlées sur tout le message |
| `DataOutcome` | Taille, dépassement de `max_message_bytes`, CR isolé, LF isolé, octet nul |
| `Response`, `EnhancedStatus` | Réponse sur une ou plusieurs lignes, code étendu (RFC 3463) ; texte assaini (ASCII imprimable, 512 octets par ligne) |
| `ehlo_response`, `Extensions` | Réponse à `EHLO` : `PIPELINING`, `SIZE`, `8BITMIME`, `SMTPUTF8`, `ENHANCEDSTATUSCODES`, `STARTTLS` (selon l'écoute), `CHUNKING` (`Extensions::inbound`, décision S5) ; plus `DSN` et `AUTH PLAIN LOGIN` (session chiffrée) pour le dépôt authentifié (`Extensions::submission`, décisions E14, E22) ; `Response::greeting` : `220 <hostname> ESMTP` ; `Response::diagnostic` : la réponse sur une ligne, pour `Diagnostic-Code` |
| `AuthExchange`, `AuthStep`, `Credentials`, `AuthError` | Échange `AUTH PLAIN` (RFC 4616) et `AUTH LOGIN` : voir plus bas |
| `CommandReceiver::ingest_line` | Ligne de réponse du client pendant `AUTH`, mêmes contrôles qu'une commande, rendue en `SaslData` |
| `xtext` | Codage `xtext` (RFC 3461 §4) et adresses `utf-8-addr-xtext` / `utf-8-addr-unitext` (RFC 6533 §3) |
| `SmtpError` | Refus sans donnée du client ; `response()` donne le code (`500 5.5.1`, `501 5.5.4`, `501 5.1.7`, `501 5.1.3`, `555 5.5.4`, `553 5.6.7`, `500 5.5.2`) |
| `SmtpLimits` | `max_line_bytes` (4 096 ; 512 à 65 536) et `max_message_bytes` (50 Mio ; 1 Mio à 1 Gio), décision S19 |

### Fins de ligne et contrebande SMTP (décision S7)

* Une commande ne se termine que par CRLF : un LF seul, un CR isolé ou un octet nul fait refuser
  la ligne (`500 5.5.2`), qui est entièrement consommée ; le dialogue reste synchronisé.
* La fin de `DATA` n'est reconnue que sur `CRLF.CRLF` (le CRLF de la commande `DATA` compte :
  un message vide est `.` CRLF). Tout CR isolé ou LF isolé dans les données est signalé
  (`DataOutcome::line_ending_error`) ; la lecture continue jusqu'à la vraie fin et la session
  refuse le message (`500 5.5.2`). Variantes essayées : `LF.LF`, `LF.CRLF`, `CRLF.LF`, `CR.CR`,
  `CRLF.CR`, `CR.CRLF`, octet nul avant ou après le point. `BDAT` suit la même règle (CRLF coupé
  entre deux morceaux accepté, CR final isolé refusé).
* Plus strict que Mox, qui accepte un LF isolé loin d'un point (point à vérifier par les essais
  réels, ROADMAP).

### PIPELINING, STARTTLS, BDAT

`CommandReceiver` ne lit jamais au-delà d'une ligne : la session traite les commandes une à une
et garde le reste de l'entrée. `Request::ends_pipeline_group` dit quand envoyer les réponses en
attente (RFC 2920 §3.1) ; `Request::forbids_pipelined_input` vaut pour `STARTTLS` (octets reçus
en clair avant la négociation : injection, fermeture) et `DATA` (données avant `354` :
`554 5.5.0`). Après `BDAT`, l'appelant remet le reste de l'entrée à `BdatReceiver`, qui ne lit
que la taille annoncée, même si le morceau ressemble à des commandes.

### Mémoire

Au plus `max_line_bytes` octets gardés par ligne ; une ligne plus longue est lue sans être
gardée jusqu'à son LF, puis refusée (`500 5.5.2`). Le contenu au-delà de `max_message_bytes` est
lu et compté sans être gardé (`552 5.3.4` par la session). Aucune autre accumulation : le
nombre de destinataires, de messages et d'erreurs est borné par la session (S19).

### Adresses internationales

UTF-8 permis dans les parties locales et les domaines (U-label) ; `MAIL FROM` non ASCII sans
`SMTPUTF8` refusé (`553 5.6.7`) ; pour `RCPT TO`, la session contrôle `ForwardPath::is_ascii`
selon sa transaction. UTF-8 invalide toujours refusé, jamais converti avec perte. La conversion
en A-label (`idna`) est faite par `lyxal_mail` (décision S16).

### `AUTH` côté serveur (lot 6, décision E14)

`AuthExchange::start(mécanisme, réponse initiale)` puis, tant qu'il rend un défi `334`,
`AuthExchange::step` sur la ligne suivante (`CommandReceiver::ingest_line`). Le module ne vérifie
aucun mot de passe : il rend `Credentials` (identifiant UTF-8, mot de passe en octets), vérifiés
par `lyxal_mail` (mots de passe d'application de `lyxal_auth`).

* `PLAIN` : `[authzid] NUL authcid NUL passwd` ; `authzid` non vide et différent de `authcid`
  refusé (`535 5.7.8` : aucune connexion « au nom de ») ; sans réponse initiale, défi `334 ` vide.
* `LOGIN` : défis `Username:` et `Password:` en Base64 ; l'identifiant peut venir en réponse
  initiale (anciens Outlook).
* Réponse initiale `=` : réponse vide ; `*` : annulation (`501 5.0.0`) ; Base64 invalide
  (`501 5.5.2`) ; élément de plus de 1 024 octets encodés (`500 5.5.6`) ; mécanisme inconnu
  (`504 5.5.4`) ; échange terminé (`503 5.5.1`).
* Secrets : réponse initiale, lignes de l'échange et mot de passe dans des tampons effacés à leur
  libération, masqués dans tout `Debug` (`[REDACTED]`) ; le tampon de ligne du
  `CommandReceiver` est effacé après chaque ligne et réservé d'un coup (aucune copie laissée par
  une réallocation).

## Client SMTP (`lyxal_mail_proto::smtp::client`, lot 6)

Syntaxe du client d'envoi de `lyxal_mail::outbound` (plan du lot 6, §3.1) ; aucune connexion
ouverte, aucune décision (extensions employées, `PIPELINING`, `STARTTLS`, classement des échecs).

| Élément | Rôle |
| :--- | :--- |
| `ReplyReader` | Lit une réponse sur une ou plusieurs lignes, **une à la fois** (réponses en `PIPELINING` dans l'ordre ; octets restés après le `220` de `STARTTLS` visibles par l'appelant, `has_partial_reply`) ; même code sur chaque ligne ; code étendu lu seulement si `ENHANCEDSTATUSCODES` est annoncé (`set_enhanced_status_codes`) et si sa classe est celle du code (comme Mox) ; `250` sans texte accepté ; CRLF strict (CR ou LF isolé : erreur de protocole) ; 512 octets par ligne, 1 000 lignes ; rend une `Response` au texte assaini |
| `ServerExtensions::from_ehlo` | `PIPELINING`, `SIZE [n]`, `8BITMIME`, `SMTPUTF8`, `STARTTLS`, `DSN`, `ENHANCEDSTATUSCODES`, `CHUNKING`, `REQUIRETLS`, `AUTH <mécanismes>` (et forme ancienne `AUTH=`, 32 mécanismes au plus) ; mots inconnus ignorés |
| `ClientCommand`, `MailCommand`, `RcptCommand` | `EHLO`, `HELO`, `STARTTLS`, `AUTH PLAIN` (relais), `MAIL FROM` (`SIZE`, `BODY`, `SMTPUTF8`, `RET`, `ENVID` en xtext), `RCPT TO` (`NOTIFY`, `ORCPT` relayé tel que reçu ou construit par `DsnOrcpt::for_mailbox`), `DATA`, `RSET`, `NOOP`, `QUIT` ; aucun CR ni LF possible (chemins typés, nom `EHLO` relu, valeurs codées), `BODY=BINARYMIME` refusé (pas de `BDAT`, décision E10) ; mot de passe masqué dans le `Debug` |
| `DotStuffer` | Bourrage de `DATA` **en flux** : point doublé en début de ligne, `CRLF.CRLF` final (CRLF ajouté si la dernière ligne n'en a pas) ; CR ou LF isolé **refusé** (seconde garde contre la contrebande SMTP vers l'extérieur) |

## Avis de non-remise (`lyxal_mail_proto::dsn`, lot 6)

Plan du lot 6, §3.3. Le module écrit et lit ; il ne décide d'aucun avis (`lyxal_mail::dsn`).

* **Écriture** (`DsnBuilder::build`) : `multipart/report; report-type=delivery-status`
  (RFC 6522) en trois parties — texte lisible en français puis en anglais (UTF-8,
  quoted-printable ; nos seules données : adresses, codes étendus, dates), rapport
  `message/delivery-status` (RFC 3464 : `Reporting-MTA`, `Original-Envelope-Id`, `Arrival-Date` ;
  par destinataire `Original-Recipient`, `Final-Recipient`, `Action`, `Status`, `Remote-MTA`,
  `Diagnostic-Code`, `Last-Attempt-Date`, `Will-Retry-Until`), puis les en-têtes du message
  (`text/rfc822-headers`, `RET=HDRS`) ou le message entier (`message/rfc822`, `RET=FULL`,
  256 Kio au plus ; au-delà, en-têtes seuls). Variante internationale (RFC 6533) quand l'envoi
  exigeait `SMTPUTF8` : `message/global-delivery-status`, `message/global-headers`,
  `message/global`, adresses `utf-8` en clair ; sinon une adresse non ASCII s'écrit en
  `utf-8-addr-xtext`. En-têtes `From: Mail Delivery System <…>`, `In-Reply-To` et `References`
  (fil du message d'origine), `Auto-Submitted: auto-replied`. Textes distants (`Remote-MTA`,
  `Diagnostic-Code`) assainis : caractères de commande retirés, 4 096 octets par champ, lignes
  repliées sous 998 octets ; aucun ne peut créer un champ.
* **Lecture** (`parse_dsn(brut, &ParsedMessage)`) : première partie `delivery-status` (ou
  `global-delivery-status`) de la structure MIME du lot 4, sous `multipart/report` ou non ;
  codages `7bit`, `8bit`, `base64`, `quoted-printable`. Tolérante aux avis réels : casse des
  champs, commentaires, fins de ligne LF, groupe du message absent, `Status` absent (déduit de
  l'action), chevrons autour d'une adresse, groupes illisibles ignorés et comptés
  (`ignored_recipients`). Bornée : rapport de 64 Kio, 100 destinataires.
* Dates des champs : `format_date`, `parse_date` (lecteur de `mail-parser`).

## Essais

`cargo test -p lyxal_mail_proto` :

* `tests/mime_messages.rs` : messages écrits pour Lyxal — enveloppe, groupes, mots encodés
  (UTF-8, ISO-8859-1, Shift_JIS), en-têtes repliés, date et décalage, `multipart` imbriqués et
  positions relues dans le message brut, RFC 2231, message joint non encodé et encodé, digest,
  avis de non-remise, messages tronqués ou mal formés, refus, limites (5 000 parties sous une
  limite relevée), imbrication profonde (200 000 messages joints en clair, 50 000 cachés dans un
  message joint en base64, 990 `multipart`) sur une pile de 2 Mio, sous les limites par défaut
  et les plus hautes ;
* `tests/mime_corpus.rs` : corpus de `mail-parser` 0.11.9 (`tests/corpus/mail-parser/`, messages des
  RFC et mal formés), y compris chaque préfixe des premiers messages ;
* `tests/mime_properties.rs` : propriétés `proptest` (aucun arrêt, positions dans les bornes,
  limites tenues) sur des octets quelconques et sur des assemblages de fragments MIME ;
  `PROPTEST_CASES` augmente le nombre de cas (200 000 passés lors de la création) ;
* `tests/smtp_commands.rs` : toutes les commandes et leurs paramètres, chemins (guillemets, route
  source, adresses littérales, `Postmaster`, longueurs), `SMTPUTF8`, refus et réponses d'erreur ;
* `tests/smtp_receiver.rs` : CRLF strict, chaque point de découpage d'un flux, limite de ligne
  exacte, 64 Mio sans LF sans croissance de la mémoire, `PIPELINING`, aucune lecture au-delà de
  `STARTTLS`, `DATA` et `BDAT` ;
* `tests/smtp_data.rs` : bourrage, fin `CRLF.CRLF` seule, variantes de contrebande, octet nul,
  dépassement de taille, morceaux `BDAT`, cas de Mox `smtp/data_test.go` transposés ;
* `tests/smtp_responses.rs` : réponses sur une et plusieurs lignes, codes étendus, assainissement,
  réponse à `EHLO` (S5, dépôt authentifié), forme `Diagnostic-Code` ;
* `tests/smtp_corpus.rs` : dialogues tirés des RFC 5321, 2920, 3030, 1870, 3207, 3461, 6531
  (`tests/corpus/smtp/`) lus sous plusieurs découpages ; réponses du serveur relues par le
  `ReplyReader` du client ;
* `tests/smtp_client.rs` (lot 6) : réponses sur une et plusieurs lignes, codes étendus annoncés ou
  non, lignes trop longues, 1 000 lignes, CR et LF isolés, une réponse à la fois ; extensions de
  `EHLO` ; commandes écrites (paramètres DSN en xtext, `ORCPT` relayé puis décodé, refus de CR
  et LF, `AUTH PLAIN`) ; bourrage ; cas de Mox `smtpclient/client_test.go` transposés ;
  propriétés `proptest` (bourrer puis lire par le `DataReceiver` du lot 5 redonne les octets ;
  aucune fin isolée ne passe ; une réponse écrite par `Response::write_to` est relue à
  l'identique ; aucun arrêt du lecteur) ;
* `tests/smtp_auth.rs` (lot 6) : commande `AUTH`, échanges `PLAIN` et `LOGIN`, Base64 invalide,
  `authzid` différent, annulation, longueurs, masquage, `AUTH=`, `REQUIRETLS` refusé ;
* `tests/dsn.rs` (lot 6) : avis écrits puis relus (cas de Mox `dsn/dsn_test.go` transposés,
  variante internationale, tous les champs et actions, `RET=FULL` et sa limite, textes distants
  injectés), avis de forme Postfix, lectures tolérantes (Base64, quoted-printable, LF, groupes
  illisibles), refus et limites ; propriétés `proptest` (un avis écrit est relu à l'identique ;
  aucun arrêt de la lecture) ;
* `tests/smtp_properties.rs` : propriétés `proptest` (aucun arrêt ; une commande par LF quel que
  soit le découpage ; fin de `DATA` sur la première occurrence de `CRLF.CRLF` seulement, contenu
  et fins isolées conformes à un modèle ; aller-retour du bourrage ; `BDAT` exact ; limite de
  ligne) ; 50 000 cas passés lors de la création ;
* `fuzz/` : cibles `cargo fuzz` `mime_parse` (lot 4), `smtp_request` et `smtp_data` (lot 5),
  `smtp_reply` (réponses, extensions, réécriture relue à l'identique, bourrage relu par le
  serveur) et `dsn_parse` (avis, échanges `AUTH`) (lot 6), paquet hors du workspace ; cibles
  SMTP et d'avis lancées 60 s chacune à leur création (sans incident), longuement au lot 21
  (`cargo +nightly-2026-10-20 fuzz run <cible>`).

## Licence

`license = "AGPL-3.0-only"` dans son propre `Cargo.toml` (décision P2), et non la licence
`MIT OR Apache-2.0` du workspace : le crate reçoit le code écrit sur le modèle des crates de
Stalwart (`smtp-proto` au lot 5 ; `imap-proto`, `sieve`, `smtp-report`, `jmap-proto` ensuite,
publiés sous `AGPL-3.0-only OR LicenseRef-SEL`, option AGPL retenue) et de Mox (MIT). Les
parties de Stalwart sous `LicenseRef-SEL` seule ne sont jamais utilisées (décision F5). La
syntaxe SMTP ne recopie aucune ligne de Stalwart (`SOURCES.md` §4) ; le corpus d'essai repris de
`mail-parser` reste sous MIT (`LICENSES/MIT-mail-parser.txt`), les cas d'essai transposés de Mox
aussi (`LICENSES/MIT-Mox.txt`). Exception nommée dans `deny.toml` ; aucun paquet sous licence
permissive ne dépend de ce crate (`scripts/ci/check_agpl_isolation.py`).

## Dépendances

`mail-parser` 1.0.1 (`Apache-2.0 OR MIT` ; dépendances `encodify`, `hashify`, `memchr`,
`simdutf8`, `encoding_rs`), `memchr` 2 (`Unlicense OR MIT`, syntaxe SMTP), `base64` 0.22
(`MIT OR Apache-2.0`, `AUTH` et avis), `zeroize` 1 (`Apache-2.0 OR MIT`, effacement des mots de
passe lus), `time`, `thiserror` ; en essai, `proptest`. Aucun crate Lyxal, aucune crate
cryptographique (`mail-auth` n'est jamais une dépendance).

Consommateurs : `lyxal_mail` (dépôt d'un message, lot 4 ; session SMTP, lot 5 ; envoi, dépôt
authentifié et avis, lot 6) et `apps/lyxal-groupware`. `lyxal-server`
ne le lie pas.

## Documents

* [`SOURCES.md`](SOURCES.md) — provenance : sources figées, tri du code propriétaire, éléments repris.
* [`ROADMAP.md`](ROADMAP.md) — lots à venir, essais réels à faire.
* Étude des sources : [`crates/lyxal_mail/RECHERCHE_SOURCES.md`](../lyxal_mail/RECHERCHE_SOURCES.md).
