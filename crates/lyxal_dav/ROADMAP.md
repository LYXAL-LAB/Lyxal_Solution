# Feuille de route — `lyxal_dav`

Évolutions à venir du crate (à créer). Son objet est décrit par le [`README.md`](README.md), la
provenance de ses sources par [`SOURCES.md`](SOURCES.md). Le programme est décrit par
`implementation_plan.md` à la racine du dépôt ; chaque lot a son propre plan, validé par le CTO
avant toute ligne de code (`.agents/AGENTS.md` §3).

## Lots du programme, dans l'ordre

| Lot | Contenu pour ce crate | Sources principales | Prérequis |
| :- | :--- | :--- | :--- |
| 14 — Formats agenda et contact | Création du crate (`Cargo.toml` sous `AGPL-3.0-only`, exception nommée dans `deny.toml`) ; iCalendar, vCard, récurrences bornées, fuseaux | Stalwart `calcard` | lot 0 |
| 15 — Socle WebDAV | XML, propriétés, `PROPFIND` / `REPORT`, principals, droits, synchronisation par jeton, découverte ; méthodes DAV dans l'hôte | Stalwart `dav-proto`, `dav/common` ; RustiCal `dav`, `xml` ; sabre/dav | lots 1, 3, 14 |
| 16 — CalDAV | Rapports CalDAV, propriétés Apple, restitution à l'octet près | Stalwart `dav/calendar` | lot 15 |
| 17 — Tâches, partage, disponibilités | Droits complets, délégation, `free-busy-query` | idem ; RustiCal | lot 16 |
| 19 — CardDAV | Rapports CardDAV | Stalwart `dav/card` ; RustiCal `carddav` | lot 15 |
| 21 — Durcissement et conformité | Fuzzing, suites de conformité (CalDAVTester, `caldav-server-tester`, litmus en outils externes) | Tests de sabre/dav et de RustiCal transposés | lots 12, 20 |
| 22 — Essais réels et clôture | Audit `lyxal-audit`, documents définitifs | — | lot 21, moyens P11 |

## Chiffrement (décision C7)

Agendas et contacts : **niveau A seulement** (chiffrement au repos avec les clés de la
plateforme), car aucun logiciel CalDAV / CardDAV classique ne sait déchiffrer un événement ou
une fiche. Ce crate ne chiffre rien ; il n'a aucune contrainte à tenir pour les niveaux B et C,
qui concernent le courrier.

## Après le programme

Stockage de fichiers WebDAV (Stalwart `dav/file`), sur `lyxal_storage` ; WebDAV-Push
(brouillon) ; service de fuseaux RFC 7808.

## Essais réels à faire

Les tests automatiques n'appellent aucun service réel. Les essais réels se font sur ordre du
CTO, avec les moyens qu'il fournit (décision P11) ; secrets rangés dans `lyxal_secrets`, jamais
dans le dépôt ni dans une conversation. Chaque lot ajoute ici ses essais ; un essai réussi est
retiré de la liste et noté dans le `README.md`.

| Lot | Préalable (moyens P11) | Action | Résultat attendu |
| :- | :--- | :--- | :--- |
| 14 | Exports réels d'agendas et de carnets (iCloud, Google, Outlook, Thunderbird) | Lire puis réécrire chaque fichier | Aucun fichier refusé à tort ; propriétés inconnues (`X-APPLE-*`…) rendues telles quelles |
| 15 | Nom de domaine, DNS (enregistrements SRV de découverte), HTTPS ; iPhone, Mac, Android avec DAVx⁵, Thunderbird | Ajouter le compte par la seule adresse e-mail et un mot de passe d'application | Découverte automatique réussie sur chaque logiciel |
| 15 | Idem | Enregistrer les requêtes de chaque logiciel | Toutes les requêtes sont comprises ; aucune réponse refusée par le logiciel |
