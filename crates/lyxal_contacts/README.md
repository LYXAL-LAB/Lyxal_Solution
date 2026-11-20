# `lyxal_contacts` — contacts et CardDAV (à créer)

**État : à créer.** Ce dossier ne contient que des documents : pas de `Cargo.toml`, pas de code.
Le crate n'est pas membre du workspace. Il est inscrit « à créer » dans `.agents/AGENTS.md` §6
(Noyau Technique, après `lyxal_notification`) et dans
[`docs/14-roadmap/ROADMAP_NOYAU.md`](../../docs/14-roadmap/ROADMAP_NOYAU.md). Aucun code avant le
plan de lot validé par le CTO (`.agents/AGENTS.md` §3).

Le programme courrier, agendas et contacts (architecture, 23 lots, décisions F1 à F5 et P1 à P15
du CTO) est décrit par `implementation_plan.md` à la racine du dépôt.

## Objet

Module du Noyau Technique (SurrealQL et Rust) : les **carnets d'adresses** et les **contacts**
des identités et des organisations de Lyxal OS, servis en **CardDAV** (décision F1).

| Partie | Contenu |
| :--- | :--- |
| Données et règles (SurrealQL) | Carnets, contacts (texte vCard reçu conservé tel quel et projections indexées : nom, adresses e-mail, groupes), journal de synchronisation, partages ; droits par organisation ; erreurs `CONTACTS_*` |
| CardDAV (Rust) | Carnets, contacts, recherche (`addressbook-query`), lecture groupée, synchronisation par jeton, vCard 3 et 4 |
| JMAP | JSContact et méthodes JMAP des contacts |

Un carnet d'adresses n'est pas un agenda : une responsabilité, un propriétaire (`AGENTS.md`
§5.1). La couche de protocole (XML DAV, vCard) est dans [`lyxal_dav`](../lyxal_dav/README.md).
Le HTTP est écouté par l'hôte dédié `apps/lyxal-groupware` (décision P3), pas par
`lyxal-server`. Adresses de la forme `/dav/<organisation>/…`.

## Licence

Le crate déclarera `license = "AGPL-3.0-only"` dans son propre `Cargo.toml` (décision P2), et
non la licence `MIT OR Apache-2.0` du workspace : son code est porté de Stalwart (`dav/card`,
`groupware/contact`, publiés sous `AGPL-3.0-only OR LicenseRef-SEL` — option AGPL retenue) ; le
code de RustiCal (`AGPL-3.0-or-later`) s'y combine ; les parties reprises de sabre/dav
(BSD-3-Clause) gardent leurs mentions. Les parties de Stalwart sous `LicenseRef-SEL` seule
(propriétaire) ne sont jamais utilisées (décision F5). Chaque élément porté est inscrit dans
[`SOURCES.md`](SOURCES.md).

## Lots du programme qui le construisent

| Lot | Apport à ce crate |
| :- | :--- |
| 19 — CardDAV | Création du module : carnets, contacts, recherche, synchronisation, partage |
| 20 — JMAP agendas et contacts | JSContact, méthodes JMAP |
| 21, 22 — Durcissement, essais réels, clôture | Conformité, essais sur appareils réels, audit |

Prérequis : lots 1 (mots de passe d'application, réalisé), 3 (hôte), 14 et 15 (`lyxal_dav`).
Le lot 19 ne dépend pas du courrier (décision P9).

## Dépendances prévues

| Vers | Usage |
| :--- | :--- |
| `lyxal_dav` | XML DAV, vCard |
| `lyxal_core`, `lyxal_error`, `lyxal_surreal` | Entrées validées par le Core (§5.7.8), erreurs `CONTACTS_*`, wrappers `store.call_fn` |
| `lyxal_crypto` | Empreintes (ETag) ; chiffrement au repos (niveau A) |
| `lyxal_auth` | Identités, organisations, permissions `contacts.*`, mots de passe d'application |
| `lyxal_scheduler` | Purge du journal de synchronisation |
| `lyxal_event`, `lyxal_runtime` | Événement `contacts.card.changed`, module, sondes de santé |

Ce crate ne dépend ni de `lyxal_calendar` ni de `lyxal_mail`.

## Documents

* [`SOURCES.md`](SOURCES.md) — provenance : sources figées, tri du code propriétaire, éléments portés.
* [`ROADMAP.md`](ROADMAP.md) — lots à venir, essais réels à faire.
* Étude des sources : [`crates/lyxal_calendar/RECHERCHE_SOURCES.md`](../lyxal_calendar/RECHERCHE_SOURCES.md).
