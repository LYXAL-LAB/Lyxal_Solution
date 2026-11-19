# `lyxal_dav` — socle WebDAV, iCalendar et vCard (à créer)

**État : à créer.** Ce dossier ne contient que des documents : pas de `Cargo.toml`, pas de code.
Le crate n'est pas membre du workspace. Il est inscrit « à créer » dans `.agents/AGENTS.md` §6
(Noyau Technique, après `lyxal_notification`) et dans
[`docs/14-roadmap/ROADMAP_NOYAU.md`](../../docs/14-roadmap/ROADMAP_NOYAU.md). Aucun code avant le
plan de lot validé par le CTO (`.agents/AGENTS.md` §3).

Le programme courrier, agendas et contacts (architecture, 23 lots, décisions F1 à F5 et P1 à P15
du CTO) est décrit par `implementation_plan.md` à la racine du dépôt.

## Objet

Crate **Rust pur, sans base de données ni logique métier** (comme `lyxal_parsing`) : la couche
de protocole commune aux agendas et aux contacts.

| Partie | Contenu |
| :--- | :--- |
| XML WebDAV, CalDAV, CardDAV | Lecture des requêtes (`PROPFIND`, `PROPPATCH`, `REPORT`, `MKCOL`, `MKCALENDAR`, `ACL`…), écriture des réponses `207 Multi-Status` |
| Mécanique DAV | Propriétés, préconditions (`If-Match`, `If-None-Match`), jetons de synchronisation, « principals », droits, découverte |
| iCalendar | Lecture et écriture des événements, tâches, alarmes, fuseaux ; développement **borné** des récurrences |
| vCard | Lecture et écriture, versions 3 et 4 |

Ce qu'il ne fait pas : stocker un agenda ou un contact, décider d'un droit, envoyer une
invitation. Les données et les règles sont dans [`lyxal_calendar`](../lyxal_calendar/README.md)
et [`lyxal_contacts`](../lyxal_contacts/README.md). Pourquoi un crate à part : `lyxal_contacts`
réutilise la couche DAV sans dépendre des agendas, et un crate sans base se teste seul.

## Licence

Le crate déclarera `license = "AGPL-3.0-only"` dans son propre `Cargo.toml` (décision P2), et
non la licence `MIT OR Apache-2.0` du workspace : son code est porté de crates de Stalwart
(`dav-proto`, `dav/common`, `dav/principal`, `calcard` dans sa version du dépôt Stalwart),
publiés sous `AGPL-3.0-only OR LicenseRef-SEL` — option AGPL retenue ; le code de RustiCal
(`AGPL-3.0-or-later`) s'y combine ; les parties reprises de sabre/dav (BSD-3-Clause) gardent
leurs mentions. Les parties de Stalwart sous `LicenseRef-SEL` seule (propriétaire) ne sont
jamais utilisées (décision F5). Chaque élément porté est inscrit dans [`SOURCES.md`](SOURCES.md).

## Lots du programme qui le construisent

| Lot | Apport à ce crate |
| :- | :--- |
| 14 — Formats agenda et contact | Création du crate ; iCalendar, vCard, récurrences bornées, fuseaux |
| 15 — Socle WebDAV | XML, propriétés, `PROPFIND` / `REPORT`, principals, droits, synchronisation par jeton, découverte |
| 16, 17, 19 | Compléments demandés par CalDAV, le partage et CardDAV |
| 21 — Durcissement | Fuzzing (XML hostile, fichiers d'agenda hors norme) |

Les lots 14 et 15 ne dépendent pas du courrier : le CTO peut les avancer après le lot 3
(décision P9).

## Dépendances prévues

Aucun crate Lyxal à base de données. Externes : `quick-xml` 0.42 et `jiff` 0.2 (déjà dans le
dépôt) ; les dépendances propres aux crates portés sont relevées dans le plan de chaque lot et
contrôlées par `cargo deny check licenses`.

Consommateurs : `lyxal_calendar`, `lyxal_contacts`, et `apps/lyxal-groupware` (hôte dédié,
décision P3). Aucun crate existant ne dépend de ce crate, et `lyxal-server` ne le lie pas.

## Documents

* [`SOURCES.md`](SOURCES.md) — provenance : sources figées, tri du code propriétaire, éléments portés.
* [`ROADMAP.md`](ROADMAP.md) — lots à venir, essais réels à faire.
* Étude des sources : [`crates/lyxal_calendar/RECHERCHE_SOURCES.md`](../lyxal_calendar/RECHERCHE_SOURCES.md).
