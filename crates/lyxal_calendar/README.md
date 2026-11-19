# `lyxal_calendar` — agendas et CalDAV (à créer)

**État : à créer.** Ce dossier ne contient que des documents : pas de `Cargo.toml`, pas de code.
Le crate n'est pas membre du workspace. Il est inscrit « à créer » dans `.agents/AGENTS.md` §6
(Noyau Technique, après `lyxal_notification`) et dans
[`docs/14-roadmap/ROADMAP_NOYAU.md`](../../docs/14-roadmap/ROADMAP_NOYAU.md). Aucun code avant le
plan de lot validé par le CTO (`.agents/AGENTS.md` §3).

Le programme courrier, agendas et contacts (architecture, 23 lots, décisions F1 à F5 et P1 à P15
du CTO) est décrit par `implementation_plan.md` à la racine du dépôt.

## Objet

Module du Noyau Technique (SurrealQL et Rust) : les **agendas** des identités et des
organisations de Lyxal OS, servis en **CalDAV complet** (décision F1).

| Partie | Contenu |
| :--- | :--- |
| Données et règles (SurrealQL) | Agendas, vues par utilisateur (nom, couleur, niveau d'accès), objets (texte iCalendar reçu conservé tel quel et projections indexées), journal de synchronisation, partages, boîtes de planification ; droits par organisation ; erreurs `CALENDAR_*` |
| CalDAV (Rust) | Agendas, événements, recherche par période, lecture groupée, synchronisation par jeton, propriétés Apple, restitution à l'octet près |
| Tâches, partage, disponibilités | `VTODO`, `VJOURNAL`, partage en lecture et en écriture, délégation, `free-busy-query`, alarmes et rappels |
| Planification | Boîtes `schedule-inbox` / `schedule-outbox`, invitations internes, invitations par e-mail (envoi et réception), réponses, contre-propositions |
| JMAP | JSCalendar et méthodes JMAP des agendas |

Les calendriers d'exceptions de `lyxal_scheduler` (jours fériés) ne sont pas des agendas : les
deux restent séparés. La couche de protocole (XML DAV, iCalendar) est dans
[`lyxal_dav`](../lyxal_dav/README.md). Le HTTP est écouté par l'hôte dédié
`apps/lyxal-groupware` (décision P3), pas par `lyxal-server`. Adresses de la forme
`/dav/<organisation>/…`.

## Licence

Le crate déclarera `license = "AGPL-3.0-only"` dans son propre `Cargo.toml` (décision P2), et
non la licence `MIT OR Apache-2.0` du workspace : son code est porté de Stalwart
(`dav/calendar`, `groupware/calendar`, `groupware/scheduling`, publiés sous
`AGPL-3.0-only OR LicenseRef-SEL` — option AGPL retenue) ; le code de RustiCal
(`AGPL-3.0-or-later`) s'y combine ; les parties reprises de sabre/dav (BSD-3-Clause) gardent
leurs mentions. Les parties de Stalwart sous `LicenseRef-SEL` seule (propriétaire) ne sont
jamais utilisées (décision F5) ; les organisations multiples et leurs quotas sont écrits pour
Lyxal. Chaque élément porté est inscrit dans [`SOURCES.md`](SOURCES.md).

## Lots du programme qui le construisent

| Lot | Apport à ce crate |
| :- | :--- |
| 16 — CalDAV | Création du module : agendas, événements, recherche par période, lecture groupée, propriétés Apple |
| 17 — Tâches, partage, disponibilités | `VTODO`, `VJOURNAL`, partage, délégation, `free-busy-query`, alarmes et rappels |
| 18 — Planification | iTIP / iMIP : invitations internes et par e-mail, réponses, contre-propositions |
| 20 — JMAP agendas et contacts | JSCalendar, méthodes JMAP |
| 21, 22 — Durcissement, essais réels, clôture | Conformité, essais sur appareils réels, audit |

Prérequis : lots 1 (mots de passe d'application), 3 (hôte), 14 et 15 (`lyxal_dav`) ; le lot 18
exige le courrier (lots 5 et 6). Les lots 16 et 17 ne dépendent pas du courrier (décision P9).

## Dépendances prévues

| Vers | Usage |
| :--- | :--- |
| `lyxal_dav` | XML DAV, iCalendar, récurrences bornées, fuseaux |
| `lyxal_mail` | Invitations par e-mail : envoi par son contrat public de dépôt ; réception en s'abonnant à `mail.message.received` (pièce `text/calendar`) |
| `lyxal_core`, `lyxal_error`, `lyxal_surreal` | Entrées validées par le Core (§5.7.8), erreurs `CALENDAR_*`, wrappers `store.call_fn` |
| `lyxal_crypto` | Empreintes (ETag) ; chiffrement au repos (niveau A) |
| `lyxal_auth` | Identités, organisations, permissions `calendar.*`, mots de passe d'application |
| `lyxal_scheduler` | Purge du journal de synchronisation, rappels |
| `lyxal_event`, `lyxal_runtime` | Événements `calendar.*`, module, workers, sondes de santé |
| `lyxal_storage` | Pièces jointes gérées, plus tard |

`lyxal_mail` ne connaît pas les agendas : aucun cycle. `lyxal_notification` consomme
`calendar.alarm.due` sans lien Cargo.

## Documents

* [`RECHERCHE_SOURCES.md`](RECHERCHE_SOURCES.md) — étude des sources (normes, serveurs, bibliothèques, clients).
* [`SOURCES.md`](SOURCES.md) — provenance : sources figées, tri du code propriétaire, éléments portés.
* [`ROADMAP.md`](ROADMAP.md) — lots à venir, essais réels à faire.
