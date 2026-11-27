# `lyxal_mail_proto` — provenance des sources

Registre de provenance exigé par les décisions F4 et P2 du programme courrier, agendas et
contacts. **Règle : tout élément porté d'un projet extérieur est inscrit ici** — fichier ou
dossier de Lyxal, projet d'origine, commit, licence, chemin d'origine — dans le même changement
que le code. Un élément absent de ce registre ne doit pas exister dans le crate.

## 1. Sources figées (décision C2)

Les sources ne sont pas versées dans le dépôt. `scripts/sources/fetch_sources.sh` les clone dans
`.sources/` (ignoré par Git) et vérifie le commit. Changer de commit est un changement comme un
autre : plan, registre mis à jour, validation du CTO (décision P14).

| Source | Adresse | Commit figé | Licence | Usage pour ce crate |
| :--- | :--- | :--- | :--- | :--- |
| Stalwart 1.1.1 | <https://github.com/stalwartlabs/stalwart> | `3adead91f3c87e7415b58c9ed8e6ec05a5dda521` | `AGPL-3.0-only OR LicenseRef-SEL` (option AGPL retenue) | Source principale : `crates/smtp-proto`, `imap-proto`, `sieve`, `smtp-report`, `jmap-proto` |
| Mox | <https://github.com/mjl-/mox> | `b32f0def9763b2644ad7bd1e8b3894786e80858b` | MIT | Complément : comportements, cas de test |
| `mail-parser` | <https://crates.io/crates/mail-parser> | version 1.0.1 (dépendance ; commit du paquet `a56d5f1dc0050a9de123df926081e436334ba9e5`) ; corpus d'essai copié de la version 0.11.9 (commit `918cc0c891f5e2a0009ccab4e935e91f68c673be`) | Apache-2.0 OR MIT | Lecture des messages (lot 4) ; corpus d'essai (§3) |

## 2. Code propriétaire de Stalwart : jamais utilisé (décisions F5 et C3)

Seule la copie de travail triée par `scripts/sources/strip_sel.py` sert de source. Résultat du
tri pour les crates de Stalwart qui alimentent ce crate (commit figé ; rapport complet dans
[`crates/lyxal_mail/SOURCES.md`](../lyxal_mail/SOURCES.md)) :

| Crate Stalwart | Fichiers `.rs` après tri | Lignes après tri | Fichiers sous `LicenseRef-SEL` seule (supprimés) | Extraits sous `LicenseRef-SEL` (retirés) |
| :--- | -: | -: | -: | -: |
| `smtp-proto` | 9 | 4 393 | 0 | 0 |
| `imap-proto` | 51 | 8 771 | 0 | 0 |
| `sieve` | 100 | 24 113 | 0 | 0 |
| `smtp-report` | 14 | 3 891 | 0 | 0 |
| `jmap-proto` | 60 | 18 023 | 0 | 1 (`src/error/request.rs`, 12 lignes) |

`mail-parser` 1.0.1 exige Rust 1.98 : le workspace y est passé au lot 4 (décision du CTO du
21 novembre 2026). Arbre ajouté : `mail-parser` 1.0.1, `encodify` 1.0.2, `hashify` 0.3.2
(`Apache-2.0 OR MIT`), `memchr`, `simdutf8` et `encoding_rs` (déjà présents) ; contrôlé par
`cargo deny check licenses`.

Lot 5 (`smtp`) : `memchr` 2 (`Unlicense OR MIT`, déjà dans l'arbre par `mail-parser`) devient
une dépendance directe ; aucune autre dépendance.

Lot 6 (`smtp::client`, `AUTH`, `dsn`) : `base64` 0.22 (`MIT OR Apache-2.0`) et `zeroize` 1
(`Apache-2.0 OR MIT`), déjà dans l'arbre par `lyxal_mail` et `lyxal_crypto`, deviennent des
dépendances directes ; aucune autre dépendance, aucun paquet ajouté à l'arbre. `mail-auth` n'est
jamais utilisé.

## 3. Éléments repris

La lecture MIME (lot 4) est écrite pour Lyxal OS autour de la dépendance `mail-parser`. La
syntaxe SMTP (lots 5 et 6) et les avis de non-remise (lot 6) sont écrits pour Lyxal OS sur le
**modèle** de Stalwart `smtp-proto` et de Mox : aucune ligne de code n'est recopiée (voir §4 et
§5). Chaque lot ajoute ses lignes.

| Élément de Lyxal (fichier ou dossier) | Projet | Commit | Licence | Chemin d'origine | Nature (porté / modèle / copié) | Lot |
| :--- | :--- | :--- | :--- | :--- | :--- | :- |
| `tests/corpus/mail-parser/rfc/*.eml` (10 messages) | `mail-parser` | 0.11.9 (`918cc0c`) | `Apache-2.0 OR MIT`, option MIT retenue (avis : `LICENSES/MIT-mail-parser.txt`) | `resources/eml/rfc/*.eml` | copié (données d'essai, sans modification) | 4 |
| `tests/corpus/mail-parser/malformed/*.eml` (23 messages) | `mail-parser` | 0.11.9 (`918cc0c`) | idem | `resources/eml/malformed/*.eml` | copié (données d'essai, sans modification) | 4 |
| `src/smtp/command.rs` (jeu de commandes, paramètres `SIZE`, `BODY`, `SMTPUTF8`, DSN), `src/smtp/receiver.rs` (récepteur de lignes) | Stalwart `smtp-proto` | `3adead9` | `AGPL-3.0-only OR LicenseRef-SEL`, option AGPL retenue | `crates/smtp-proto/src/request/{parser,receiver,mod}.rs`, `src/lib.rs` | modèle | 5 |
| `src/smtp/data.rs` (`DATA`, `BDAT`) | Stalwart `smtp-proto` ; Mox | `3adead9` ; `b32f0de` | idem ; MIT | `crates/smtp-proto/src/request/receiver.rs` ; `smtp/data.go` (`DataReader`, refus des fins isolées) | modèle | 5 |
| `src/smtp/response.rs` (réponses, réponse à `EHLO`) | Stalwart `smtp-proto` ; Mox | `3adead9` ; `b32f0de` | idem ; MIT | `crates/smtp-proto/src/response/generate.rs` ; `smtpserver/server.go` (`cmdHello`) | modèle | 5 |
| `src/smtp/address.rs` (chemins, boîtes, domaines, adresses littérales, route source) | Mox | `b32f0de` | MIT | `smtpserver/parse.go` (`xpath`, `xbarePath`, `xlocalpart`, `xipdomain`) | modèle | 5 |
| `src/smtp/error.rs` (codes de réponse et codes étendus) | Mox | `b32f0de` | MIT | `smtp/codes.go`, `smtpserver/server.go` | modèle | 5 |
| `tests/smtp_data.rs` (`mox_data_reader_cases`) | Mox | `b32f0de` | MIT | `smtp/data_test.go` (`TestDataReader`) | porté (cas d'essai transposés ; un cas inversé par la décision S7) | 5 |
| `tests/corpus/smtp/rfc*.txt` (11 dialogues) | RFC 5321 (annexe D, §3.3, §4.1), 2920 (§3.2), 3030 (§4.1, §4.2), 1870 (§8), 3207 (§5), 3461, 6531 | — | IETF Trust (Legal Provisions, extraits courts cités) | exemples des RFC | copié (dialogues transcrits, mis au format du corpus) ; `rfc5321-paths` et `rfc3461-dsn` assemblés à partir des adresses et paramètres des normes, `rfc6531`, fin de `rfc3030` et adresses non ASCII écrits pour Lyxal | 5 |
| `src/smtp/client/reply.rs` (`ReplyReader`) | Stalwart `smtp-proto` ; Mox | `3adead9` ; `b32f0de` | `AGPL-3.0-only OR LicenseRef-SEL`, option AGPL retenue ; MIT | `crates/smtp-proto/src/response/parser.rs` ; `smtpclient/client.go` (`read1`, `readecode`, `parseEcode`) | modèle | 6 |
| `src/smtp/client/extensions.rs` (`ServerExtensions`) | Stalwart `smtp-proto` ; Mox | `3adead9` ; `b32f0de` | idem ; MIT | `crates/smtp-proto/src/response/parser.rs` (`EhloResponse::parse`) ; `smtpclient/client.go` (`hello`) | modèle | 6 |
| `src/smtp/client/command.rs` (`ClientCommand`) | Stalwart `smtp-proto` ; Mox | `3adead9` ; `b32f0de` | idem ; MIT | `crates/smtp-proto/src/request/mod.rs` ; `smtpclient/client.go` (`DeliverMultiple`) | modèle | 6 |
| `src/smtp/client/stuffer.rs` (`DotStuffer`) | Mox | `b32f0de` | MIT | `smtp/data.go` (`DataWrite`) | modèle (CRLF final ajouté au lieu d'être exigé) | 6 |
| `src/smtp/auth.rs` (`AuthExchange`), commande `AUTH` de `src/smtp/command.rs` | Stalwart `smtp-proto` et `smtp` ; Mox | `3adead9` ; `b32f0de` | idem ; MIT | `crates/smtp-proto/src/request/parser.rs` (`AUTH`) et `crates/smtp/src/inbound/auth.rs` (`handle_sasl_response` : défis `334` de `PLAIN` et `LOGIN` ; fichier `AGPL-3.0-only OR LicenseRef-SEL` de la copie triée) ; `smtpserver/server.go` (`cmdAuth`) | modèle | 6 |
| `src/smtp/xtext.rs` (xtext, `utf-8-addr-xtext`) | Mox | `b32f0de` | MIT | `dsn/parse.go` (`parseAddress`, séquences `\x{...}`) | modèle | 6 |
| `src/dsn/` (`DsnBuilder`, `parse_dsn`) | Mox | `b32f0de` | MIT | `dsn/dsn.go` (`Compose`), `dsn/parse.go` (`Parse`, `Decode`, `parseRecipientHeader`, `removeComments`) | modèle | 6 |
| `tests/smtp_client.rs` (`mox_error_cases`, `ehlo_extensions_mox`) | Mox | `b32f0de` | MIT | `smtpclient/client_test.go` (`TestErrors`, `TestClient`) | porté (réponses des dialogues transposées en lectures) | 6 |
| `tests/dsn.rs` (`mox_ascii_dsn`, `mox_utf8_dsn`) | Mox | `b32f0de` | MIT | `dsn/dsn_test.go` (`TestDSN`) | porté (messages et vérifications des parties transposés) | 6 |

« Porté » : code repris et adapté. « Modèle » : fonctionnement repris, code réécrit. « Copié » :
fichier repris tel quel. Les mentions de droit d'auteur et de licence des fichiers portés sont
conservées dans les fichiers ; les fichiers copiés du corpus, qui n'en portent pas, relèvent de
l'avis `LICENSES/MIT-mail-parser.txt`. Les cas d'essai transposés de Mox relèvent de l'avis
`LICENSES/MIT-Mox.txt` (copie de `LICENSE.MIT` de Mox) ; les dialogues des RFC sont de courts
extraits cités. Texte de la licence du crate : `LICENSES/AGPL-3.0-only.txt` (copie de celui de
`crates/lyxal_mail`).

## 4. Syntaxe SMTP : modèle plutôt que portage (lot 5)

Le plan du lot 5 (§4) prévoyait de porter `smtp-proto` « presque tel quel ». Après lecture de la
source (copie triée, commit `3adead9`, 9 fichiers, aucun `LicenseRef-SEL`), le code a été **écrit
pour Lyxal OS** en reprenant le fonctionnement de Stalwart et de Mox, parce que la source
contredit des décisions du plan :

* `request/parser.rs` saute tout CR où qu'il soit et accepte LF seul comme fin de commande ;
  `request/receiver.rs` lit plusieurs commandes d'un même tampon (décision S7 : CRLF strict ;
  `STARTTLS` et `BDAT` : aucune lecture au-delà de la frontière) ;
* l'UTF-8 invalide est converti avec perte (`from_utf8_lossy`) dans les adresses ;
* `<Postmaster>` est rendu comme un chemin vide, confondu avec `<>` (plan §7.3 : `postmaster` est
  résolu) ;
* le texte des réponses n'est pas assaini (`response/generate.rs`).

Mox a servi de modèle pour la grammaire des chemins, les tolérances (espaces après `FROM:`,
espaces en fin de ligne, texte après une adresse littérale de `EHLO`), la longueur de la partie
locale (128) et la détection des fins de ligne isolées ; la décision S7 est plus stricte que Mox
(tout LF isolé est refusé). Les fichiers écrits portent `SPDX-License-Identifier: AGPL-3.0-only`
sans mention de droit d'auteur de Stalwart, aucun code n'étant recopié.

## 5. Client SMTP, `AUTH` et avis : modèle (lot 6, décision E1)

Écrits pour Lyxal OS comme au lot 5 : aucune ligne de Stalwart ni de Mox n'est recopiée. Écarts
voulus à la source :

* `response/parser.rs` de Stalwart accepte un LF seul comme fin de ligne de réponse ; le
  `ReplyReader` exige CRLF (comme le serveur, décision S7) et borne lignes et nombre de lignes ;
* Mox (`DataWrite`) refuse, comme le `DotStuffer`, les CR et LF isolés, mais refuse aussi un
  contenu sans CRLF final ; le `DotStuffer` l'écrit en flux et ajoute ce CRLF (sans effet sur
  DKIM, RFC 6376 §3.4.3) ;
* Mox (`dsn.go`) n'écrit que les en-têtes du message d'origine et ne lit pas `RET`, `ENVID` ;
  `DsnBuilder` joint le message entier sous `RET=FULL` (256 Kio au plus) et écrit
  `Original-Envelope-Id` ;
* Mox (`parse.go`) refuse un avis à un champ répété, sans `Reporting-MTA` ou à l'action
  inconnue ; `parse_dsn` garde le premier champ, accepte l'absence du groupe du message et
  ignore (en les comptant) les groupes de destinataire illisibles ;
* l'échange `AUTH` de Stalwart (`inbound/auth.rs`) accepte un `authzid` quelconque et le confie
  à l'annuaire ; `AuthExchange` refuse un `authzid` différent de `authcid` (plan §3.2).

Les cas d'essai de Mox transposés (`client_test.go`, `dsn_test.go`) relèvent de l'avis
`LICENSES/MIT-Mox.txt`.
