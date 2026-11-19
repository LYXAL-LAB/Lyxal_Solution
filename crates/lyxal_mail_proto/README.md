# `lyxal_mail_proto` — syntaxes du courrier (à créer)

**État : à créer.** Ce dossier ne contient que des documents : pas de `Cargo.toml`, pas de code.
Le crate n'est pas membre du workspace. Il est inscrit « à créer » dans `.agents/AGENTS.md` §6
(Noyau Technique, après `lyxal_notification`) et dans
[`docs/14-roadmap/ROADMAP_NOYAU.md`](../../docs/14-roadmap/ROADMAP_NOYAU.md). Aucun code avant le
plan de lot validé par le CTO (`.agents/AGENTS.md` §3).

Le programme courrier, agendas et contacts (architecture, 23 lots, décisions F1 à F5 et P1 à P15
du CTO) est décrit par `implementation_plan.md` à la racine du dépôt.

## Objet

Crate **Rust pur, sans base de données ni logique métier** (comme `lyxal_parsing`) : il lit et
écrit les langages du courrier, et rien d'autre.

| Partie | Contenu |
| :--- | :--- |
| SMTP / LMTP | Commandes, réponses, extensions |
| IMAP | Commandes et réponses IMAP4rev2 et rev1, extensions |
| POP3, ManageSieve | Commandes et réponses |
| Sieve | Interprète des filtres (compilation et exécution, sans effet de bord : les actions sont rendues à l'appelant) |
| Rapports | Formats des rapports DMARC et TLS-RPT |
| JMAP | Types des requêtes et des réponses |
| Messages | Lecture MIME par la bibliothèque `mail-parser` (dépendance) |

Ce qu'il ne fait pas : écouter un port, ouvrir une session, toucher à SurrealDB, décider d'une
règle (accepter un destinataire, ranger un message). Tout cela appartient à
[`lyxal_mail`](../lyxal_mail/README.md).

## Licence

Le crate déclarera `license = "AGPL-3.0-only"` dans son propre `Cargo.toml` (décision P2), et
non la licence `MIT OR Apache-2.0` du workspace : son code est porté de crates de Stalwart
(`smtp-proto`, `imap-proto`, `sieve`, `smtp-report`, `jmap-proto`), publiés sous
`AGPL-3.0-only OR LicenseRef-SEL`. Lyxal retient l'option AGPL de cette double licence. Les
parties de Stalwart sous `LicenseRef-SEL` seule (licence Entreprise, propriétaire) ne sont
jamais utilisées (décision F5). Chaque élément porté est inscrit dans [`SOURCES.md`](SOURCES.md).

## Lots du programme qui le construisent

| Lot | Apport à ce crate |
| :- | :--- |
| 4 — Socle courrier | Création du crate ; lecture MIME (`mail-parser`) |
| 5 — Réception SMTP | Syntaxe SMTP / LMTP |
| 7 — Transport sûr et rapports | Formats des rapports DMARC et TLS |
| 8 — IMAP | Syntaxe IMAP |
| 9 — Recherche et POP3 | Syntaxe POP3 |
| 10 — Sieve | Interprète Sieve, syntaxe ManageSieve |
| 12 — JMAP courrier | Types JMAP |
| 21 — Durcissement | Fuzzing des analyseurs |

## Dépendances prévues

Aucun crate Lyxal à base de données. Dépendances externes à arrêter dans le plan de chaque lot
(décision P7) : `mail-parser` 1.0 (Apache-2.0 OR MIT), et les dépendances propres aux crates
portés, relevées et contrôlées par `cargo deny check licenses` avant chaque fusion.

Consommateurs : `lyxal_mail`, et `apps/lyxal-groupware` (hôte dédié, décision P3). Aucun crate
existant ne dépend de ce crate, et `lyxal-server` ne le lie pas.

## Documents

* [`SOURCES.md`](SOURCES.md) — provenance : sources figées, tri du code propriétaire, éléments portés.
* [`ROADMAP.md`](ROADMAP.md) — lots à venir, essais réels à faire.
* Étude des sources : [`crates/lyxal_mail/RECHERCHE_SOURCES.md`](../lyxal_mail/RECHERCHE_SOURCES.md).
