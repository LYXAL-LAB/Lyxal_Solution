# Feuille de route — `lyxal_mail_proto`

Évolutions à venir du crate. Son état (lecture MIME, lot 4 ; syntaxe SMTP, lot 5 ; client SMTP,
`AUTH` et avis de non-remise, lot 6) est décrit par le [`README.md`](README.md), la provenance
de ses sources par [`SOURCES.md`](SOURCES.md). Le programme est décrit par
`implementation_plan.md` à la racine du dépôt ; chaque lot a son propre plan, validé par le CTO
avant toute ligne de code (`.agents/AGENTS.md` §3).

## Lots du programme, dans l'ordre

| Lot | Contenu pour ce crate | Source | Prérequis |
| :- | :--- | :--- | :--- |
| 7 — Transport sûr et rapports | Formats des rapports DMARC et TLS-RPT ; paramètre `REQUIRETLS` de `MAIL FROM` lu (refusé au lot 6, décision E26) | Stalwart `smtp-report` | lot 6 |
| 8 — IMAP | Syntaxe IMAP4rev2 et rev1, extensions | Stalwart `imap-proto` | lots 1, 4 |
| 9 — Recherche et POP3 | Syntaxe POP3 | Stalwart `pop3` | lot 8 |
| 10 — Sieve | Interprète Sieve et extensions, syntaxe ManageSieve | Stalwart `sieve`, `managesieve` | lots 5, 8 |
| 12 — JMAP courrier | Types JMAP (cœur, courrier) | Stalwart `jmap-proto` | lots 6, 8 |
| 21 — Durcissement et conformité | Fuzzing des analyseurs, corrections | Bancs de Mox transposés | lots 12, 20 |
| 22 — Essais réels et clôture | Audit `lyxal-audit`, `README.md` et `SOURCES.md` définitifs | — | lot 21, moyens P11 |

## Lecture MIME : points ouverts (lot 4)

* **Sujet de base** : celui de `mail-parser` (`thread_name`) ; à comparer à la RFC 5256 §2.1
  (suffixe `(fwd)`, crochets `[...]` en tête) au lot 8 (`THREAD`, `SORT`).
* **Dates** : seule la date de `Date` est lue (`sent_at`) ; la date de réception est celle du
  dépôt (`lyxal_mail`).
* **Fuzzing** : cible `fuzz/` préparée, lancée au lot 21.

## Syntaxe SMTP : points ouverts (lot 5)

* **LF isolé** : refusé partout (décision S7), plus strictement que Mox, qui l'accepte loin d'un
  point parce que des messages réels en contiennent ; à confirmer par les essais réels (lot 5,
  `crates/lyxal_mail/ROADMAP.md`) avant la mise en service.
* **Parties locales UTF-8** : gardées telles que reçues, sans normalisation NFC (Mox normalise) ;
  sans effet au lot 5 (les adresses de Lyxal sont ASCII, plan §8) ; à revoir avec le lot 13.
* **`LMTP`** : `LHLO` reconnu et refusé ; aucune syntaxe propre tant qu'aucun besoin n'existe
  (plan du lot 5, §2).
* **Fuzzing** : cibles `smtp_request` et `smtp_data` lancées 60 s à leur création, longuement au
  lot 21.

## Client SMTP, `AUTH` et avis : points ouverts (lot 6)

* **Longueur des lignes de réponse** : 512 octets, CRLF compris (RFC 5321 §4.5.3.1.5) ; une
  ligne plus longue d'un serveur distant est une erreur de protocole. À confirmer par les essais
  réels avant la mise en service (serveurs qui dépasseraient la limite).
* **`AUTH=`** (RFC 4954 §5) : lu par la syntaxe ; refusé sur le port 25 (`AUTH` non annoncé) ;
  son sort sur le dépôt authentifié est décidé par la session de `lyxal_mail` (sous-lot 6e).
* **Champs `Original-Envelope-Id` et `Original-Recipient` écrits décodés** (xtext retiré), comme
  le lisent les avis réels de Postfix : lecture des RFC 3461 §4.2, §4.4 et 3464 §2.2.1, §2.3.1
  faite de mémoire, à revérifier.
* **Lecture tolérante des avis** : formes de Postfix et de Mox couvertes par les essais ; avis
  de Gmail, Outlook.com, Yahoo et Exim à confronter aux essais réels. Seule la première partie
  `delivery-status` de l'arbre est lue (un avis qui en joint plusieurs n'est lu qu'en partie).
* **Fuzzing** : cibles `smtp_reply` et `dsn_parse` lancées 60 s à leur création, longuement au
  lot 21.

## Chiffrement des boîtes (décision C7)

Ce crate ne chiffre rien et ne lit aucune clé. Contrainte à tenir dès sa création : ses types
ne supposent jamais que le contenu d'un message est lisible par le serveur (niveaux B et C du
chiffrement, voir [`crates/lyxal_mail/ROADMAP.md`](../lyxal_mail/ROADMAP.md)).

## Essais réels à faire

Les tests automatiques n'appellent aucun service réel. Les essais réels se font sur ordre du
CTO, avec les moyens qu'il fournit (décision P11) ; secrets rangés dans `lyxal_secrets`, jamais
dans le dépôt ni dans une conversation. Chaque lot ajoute ici ses essais ; un essai réussi est
retiré de la liste et noté dans le `README.md`.

| Préalable (moyens P11) | Action | Résultat attendu |
| :--- | :--- | :--- |
| Boîtes d'essai chez Gmail, Outlook.com et Yahoo | Lire avec ce crate des messages réels reçus de ces fournisseurs (lecture MIME du lot 4) | Aucun message refusé ; pièces jointes et jeux de caractères rendus à l'identique |
| Logiciels réels : Thunderbird, Apple Mail, Outlook | Enregistrer leurs dialogues IMAP et SMTP contre le serveur d'essai (lots 5 et 8) | Toutes les commandes reçues sont reconnues ; aucune réponse refusée par le logiciel |
| Boîtes d'essai chez Gmail, Outlook.com et Yahoo ; serveurs Postfix et Exim d'essai | Envoyer vers une adresse inexistante de chacun et lire l'avis reçu par `parse_dsn` ; dialogues d'envoi enregistrés relus par `ReplyReader` (lot 6) | Chaque destinataire en échec lu avec son action et son code étendu ; aucune réponse refusée par le lecteur |
| Scripts Sieve réels exportés d'un autre serveur | Compiler et exécuter à blanc (lot 10) | Scripts acceptés ou refusés avec une erreur précise |
