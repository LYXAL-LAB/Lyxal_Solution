# Feuille de route — `lyxal_mail_proto`

Évolutions à venir du crate. Son état (lecture MIME, lot 4 ; syntaxe SMTP, lot 5) est décrit par le
[`README.md`](README.md), la provenance de ses sources par [`SOURCES.md`](SOURCES.md). Le programme est décrit par
`implementation_plan.md` à la racine du dépôt ; chaque lot a son propre plan, validé par le CTO
avant toute ligne de code (`.agents/AGENTS.md` §3).

## Lots du programme, dans l'ordre

| Lot | Contenu pour ce crate | Source | Prérequis |
| :- | :--- | :--- | :--- |
| 6 — Envoi | Lecture des réponses SMTP pour le client d'envoi (lecteur des essais `tests/smtp_support/` sorti en code) ; paramètres `AUTH=` et DSN acceptés quand `AUTH` et `DSN` sont annoncés ; extension `AUTH` (mécanismes, réponses initiales jamais gardées) | Stalwart `smtp-proto` (`response/parser.rs`), Mox | lot 5 |
| 7 — Transport sûr et rapports | Formats des rapports DMARC et TLS-RPT | Stalwart `smtp-report` | lot 6 |
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
| Scripts Sieve réels exportés d'un autre serveur | Compiler et exécuter à blanc (lot 10) | Scripts acceptés ou refusés avec une erreur précise |
