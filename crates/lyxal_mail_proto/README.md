# `lyxal_mail_proto` — syntaxes du courrier

**État : lot 4 du programme courrier.** Crate Rust membre du workspace, sous licence
`AGPL-3.0-only`. Il contient un seul module, `mime` : la lecture d'un message. Les syntaxes des
protocoles arrivent avec les lots qui les servent (voir [`ROADMAP.md`](ROADMAP.md)).

Le programme courrier, agendas et contacts (architecture, 23 lots, décisions F1 à F5 et P1 à P15
du CTO) est décrit par `implementation_plan.md` à la racine du dépôt ; le plan du lot 4 par
`crates/lyxal_mail/implementation_plan.md` (§13).

## Objet

Crate **Rust pur, sans base de données ni logique métier** (comme `lyxal_parsing`) : il lit les
langages du courrier et rend des types Lyxal, rien d'autre. Il n'écoute aucun port, n'ouvre
aucune session, ne touche pas à SurrealDB et ne décide d'aucune règle (accepter un destinataire,
ranger un message) : tout cela appartient à [`lyxal_mail`](../lyxal_mail/README.md). Pas de
`tokio`, pas de cryptographie, aucune clé lue.

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
* `fuzz/` : cible `cargo fuzz` `mime_parse`, paquet hors du workspace, préparée au lot 4 et
  lancée au lot 21 (`cargo +nightly fuzz run mime_parse`).

## Licence

`license = "AGPL-3.0-only"` dans son propre `Cargo.toml` (décision P2), et non la licence
`MIT OR Apache-2.0` du workspace : le crate recevra le code porté des crates de Stalwart
(`smtp-proto`, `imap-proto`, `sieve`, `smtp-report`, `jmap-proto`, publiés sous
`AGPL-3.0-only OR LicenseRef-SEL`, option AGPL retenue) à partir du lot 5. Les parties de
Stalwart sous `LicenseRef-SEL` seule ne sont jamais utilisées (décision F5). Au lot 4, aucun code
n'est porté ; le corpus d'essai repris de `mail-parser` reste sous MIT
(`LICENSES/MIT-mail-parser.txt`). Exception nommée dans `deny.toml` ; aucun paquet sous licence
permissive ne dépend de ce crate (`scripts/ci/check_agpl_isolation.py`).

## Dépendances

`mail-parser` 1.0.1 (`Apache-2.0 OR MIT` ; dépendances `encodify`, `hashify`, `memchr`,
`simdutf8`, `encoding_rs`), `time`,
`thiserror` ; en essai, `proptest`. Aucun crate Lyxal, aucune crate cryptographique.

Consommateurs : `lyxal_mail` (dépôt d'un message, lot 4) et `apps/lyxal-groupware`. `lyxal-server`
ne le lie pas.

## Documents

* [`SOURCES.md`](SOURCES.md) — provenance : sources figées, tri du code propriétaire, éléments repris.
* [`ROADMAP.md`](ROADMAP.md) — lots à venir, essais réels à faire.
* Étude des sources : [`crates/lyxal_mail/RECHERCHE_SOURCES.md`](../lyxal_mail/RECHERCHE_SOURCES.md).
