# `lyxal_mail` — provenance des sources

Registre de provenance exigé par les décisions F4 et P2 du programme courrier, agendas et
contacts ; ce document porte aussi le rapport complet du tri du code propriétaire de Stalwart, commun aux cinq crates. **Règle : tout élément porté d'un projet extérieur est inscrit ici** — fichier ou
dossier de Lyxal, projet d'origine, commit, licence, chemin d'origine — dans le même changement
que le code. Un élément absent de ce registre ne doit pas exister dans le crate.

## 1. Sources figées (décision C2)

Les sources ne sont pas versées dans le dépôt. `scripts/sources/fetch_sources.sh` les clone dans
`.sources/<nom>/` (dossier ignoré par Git), vérifie le commit reçu et n'exécute rien de ce
qu'il récupère. Changer de commit est un changement comme un autre : plan, registre mis à jour,
validation du CTO (décision P14).

| Nom local | Projet | Adresse | Commit figé | Version | Licence déclarée par le projet |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `stalwart` | Stalwart | <https://github.com/stalwartlabs/stalwart> | `3adead91f3c87e7415b58c9ed8e6ec05a5dda521` | 1.1.1 (16 nov. 2026) | `AGPL-3.0-only OR LicenseRef-SEL` — option AGPL retenue ; parties `LicenseRef-SEL` seule jamais utilisées |
| `mox` | Mox | <https://github.com/mjl-/mox> | `b32f0def9763b2644ad7bd1e8b3894786e80858b` | après v0.0.17 (27 oct. 2026) | MIT (`LICENSE.MIT`) ; liste des suffixes publics sous MPL-2.0 |
| `rustical` | RustiCal | <https://github.com/lennart-k/rustical> | `0698bb6b89b51207652eb60973a86364c3446ecb` | 0.19.1 | `AGPL-3.0-or-later` |
| `sabre_dav` | sabre/dav | <https://github.com/sabre-io/dav> | `be1d58d6bce7ca33313b02909f9088c93c35db02` | après 4.7.1 (1er nov. 2026) | BSD-3-Clause |

Bibliothèques prises en **dépendances** (crates.io, non copiées) : `mail-parser` 1.0.1,
`mail-builder` 2.0.1, `mail-send` 0.7.0, `mail-auth` 0.15.1 — toutes `Apache-2.0 OR MIT`. Elles
entreront dans `Cargo.lock` avec le lot qui les ajoute ; `cargo deny check licenses` contrôle
l'arbre (`deny.toml` à la racine).

Les quatre clones ont été faits et vérifiés par le script le 18 novembre 2026, depuis GitHub
(et, pour l'essai de l'option `--from`, depuis un miroir local).

## 2. Code propriétaire de Stalwart : jamais utilisé (décisions F5 et C3)

`scripts/sources/strip_sel.py`, lancé par `fetch_sources.sh` après le clone, retire de la copie
de travail `.sources/stalwart/` :

* les **fichiers** sous `LicenseRef-SEL` seule (ligne `SPDX-License-Identifier: LicenseRef-SEL`
  hors de tout extrait) : ils sont supprimés ;
* les **extraits** sous `LicenseRef-SEL` dans les fichiers à double licence (blocs
  `SPDX-SnippetBegin` … `SPDX-SnippetEnd`) : leurs lignes sont retirées.

Seule cette copie triée sert de source aux lots suivants. Le dossier `.git` du clone garde les
objets d'origine : après toute commande Git qui restaure des fichiers, relancer
`fetch_sources.sh`, qui refait le tri et la vérification.

### 2.1. Rapport par crate (commit `3adead9`, tri du 18 novembre 2026)

| Crate Stalwart | Fichiers supprimés (`LicenseRef-SEL` seule) | Lignes de ces fichiers | Fichiers avec extraits | Extraits retirés | Lignes d'extraits retirées | Fichiers `.rs` après tri | Lignes `.rs` après tri | Usage prévu dans Lyxal |
| :--- | -: | -: | -: | -: | -: | -: | -: | :--- |
| `calcard` | 0 | 0 | 0 | 0 | 0 | 74 | 43 166 | `lyxal_dav` |
| `common` | 20 | 5 696 | 38 | 166 | 1 804 | 213 | 60 624 | en partie (`network` : hôte et `lyxal_mail`) |
| `coordinator` | 0 | 0 | 1 | 1 | 13 | 13 | 1 031 | non repris |
| `crypto` | 0 | 0 | 0 | 0 | 0 | 47 | 9 696 | non repris à ce jour (niveau B : `rpgp`, décision C7) |
| `dav` | 0 | 0 | 8 | 23 | 245 | 49 | 21 866 | `lyxal_dav`, `lyxal_calendar`, `lyxal_contacts` |
| `dav-proto` | 0 | 0 | 0 | 0 | 0 | 28 | 8 894 | `lyxal_dav` |
| `directory` | 0 | 0 | 2 | 2 | 16 | 20 | 3 993 | non repris (comptes : `lyxal_auth`) |
| `email` | 0 | 0 | 8 | 22 | 159 | 51 | 15 232 | `lyxal_mail` (modèle) |
| `groupware` | 0 | 0 | 2 | 3 | 37 | 49 | 25 938 | `lyxal_calendar`, `lyxal_contacts` |
| `http` | 1 | 301 | 5 | 19 | 262 | 16 | 6 301 | modèle |
| `http-proto` | 0 | 0 | 0 | 0 | 0 | 5 | 752 | non repris |
| `imap` | 0 | 0 | 3 | 4 | 46 | 43 | 14 327 | `lyxal_mail` |
| `imap-proto` | 0 | 0 | 0 | 0 | 0 | 51 | 8 771 | `lyxal_mail_proto` |
| `jmap` | 2 | 893 | 20 | 81 | 1 004 | 152 | 52 558 | `lyxal_mail` ; agendas et contacts : `lyxal_calendar`, `lyxal_contacts` |
| `jmap-proto` | 0 | 0 | 1 | 1 | 12 | 60 | 18 023 | `lyxal_mail_proto` |
| `jmap-tools` | 0 | 0 | 0 | 0 | 0 | 15 | 3 853 | non repris |
| `main` | 0 | 0 | 2 | 13 | 79 | 3 | 1 625 | non repris |
| `managesieve` | 0 | 0 | 1 | 1 | 9 | 17 | 1 999 | `lyxal_mail`, `lyxal_mail_proto` |
| `nlp` | 0 | 0 | 0 | 0 | 0 | 24 | 8 278 | `lyxal_mail` |
| `pop3` | 0 | 0 | 0 | 0 | 0 | 13 | 2 091 | `lyxal_mail`, `lyxal_mail_proto` |
| `registry` | 0 | 0 | 11 | 1 447 | 23 866 | 37 | 104 519 | non repris (configuration de Stalwart) |
| `s3` | 0 | 0 | 0 | 0 | 0 | 8 | 1 755 | non repris |
| `scim` | 17 | 4 565 | 0 | 0 | 0 | 0 | 0 | hors programme (tout est propriétaire) |
| `scim-proto` | 16 | 4 024 | 0 | 0 | 0 | 0 | 0 | hors programme (tout est propriétaire) |
| `services` | 0 | 0 | 15 | 46 | 862 | 42 | 13 805 | modèle (tâches de fond) |
| `sieve` | 0 | 0 | 0 | 0 | 0 | 100 | 24 113 | `lyxal_mail_proto` |
| `smtp` | 1 | 76 | 6 | 25 | 227 | 65 | 24 272 | `lyxal_mail` |
| `smtp-proto` | 0 | 0 | 0 | 0 | 0 | 9 | 4 393 | `lyxal_mail_proto` |
| `smtp-report` | 0 | 0 | 0 | 0 | 0 | 14 | 3 891 | `lyxal_mail_proto` |
| `spam-filter` | 5 | 1 000 | 2 | 3 | 21 | 31 | 10 122 | `lyxal_mail` |
| `store` | 4 | 736 | 22 | 98 | 890 | 128 | 38 099 | modèle seulement (décision P4) |
| `telemetry` | 0 | 0 | 0 | 0 | 0 | 26 | 3 609 | non repris |
| `text-extract` | 0 | 0 | 0 | 0 | 0 | 117 | 22 762 | `lyxal_mail` |
| `trc` | 0 | 0 | 3 | 111 | 2 324 | 25 | 15 705 | non repris (journal de Stalwart) |
| `types` | 0 | 0 | 0 | 0 | 0 | 27 | 9 112 | non repris |
| `utils` | 0 | 0 | 1 | 1 | 12 | 35 | 5 506 | non repris |
| **Total** | **66** | **17 291** | **151** | **2 067** | **31 888** | **1 607** | **590 681** | |

Avant tri : 639 860 lignes de Rust (mesure du programme, §3.1). Retiré : 66 fichiers
entiers et 2 067 extraits dans 151 fichiers à double licence, soit
49 179 lignes. Après tri : 1 607 fichiers `.rs`, 590 681 lignes.

Le programme (§3.1) comptait « 2 070 extraits » : ce nombre est celui des lignes
`SPDX-License-Identifier: LicenseRef-SEL` hors en-tête de fichier. Trois d'entre elles sont dans
un fichier lui-même entièrement propriétaire (`store/src/backend/composite/sharded_blob.rs`),
supprimé en entier : il reste 2 067 extraits dans les fichiers gardés.

Crates sans aucune partie propriétaire : `calcard`, `crypto`, `dav-proto`, `http-proto`,
`imap-proto`, `jmap-tools`, `nlp`, `pop3`, `s3`, `sieve`, `smtp-proto`, `smtp-report`,
`telemetry`, `text-extract`, `types`. Hors du dossier `crates/` : aucune.

### 2.2. Fichiers supprimés (66)

* `crates/common/src/enterprise/` : `alerts.rs`, `config.rs`, `license.rs`, `logo.rs`, `mod.rs`
* `crates/common/src/enterprise/ai/` : `anthropic.rs`, `config.rs`, `error.rs`, `gemini.rs`, `limits.rs`, `mod.rs`, `ollama.rs`, `openai.rs`, `schema.rs`, `transport.rs`, `typesafe.rs`, `verdict.rs`
* `crates/common/src/telemetry/metrics/` : `store.rs`, `test_data.rs`
* `crates/common/src/telemetry/tracers/` : `store.rs`
* `crates/http/src/api/` : `telemetry.rs`
* `crates/jmap/src/registry/mapping/` : `archived_item.rs`, `telemetry.rs`
* `crates/scim-proto/src/` : `attributes.rs`, `etag.rs`, `filter.rs`, `json.rs`, `lib.rs`, `path.rs`
* `crates/scim-proto/src/message/` : `bulk.rs`, `error.rs`, `list.rs`, `mod.rs`, `patch.rs`, `search.rs`
* `crates/scim-proto/src/schema/` : `group.rs`, `mod.rs`, `spc.rs`, `user.rs`
* `crates/scim/src/` : `auth.rs`, `bulk.rs`, `context.rs`, `discovery.rs`, `error.rs`, `lib.rs`, `request.rs`
* `crates/scim/src/groups/` : `get.rs`, `mod.rs`, `patch.rs`, `set.rs`
* `crates/scim/src/query/` : `cursor.rs`, `mod.rs`
* `crates/scim/src/users/` : `get.rs`, `mod.rs`, `patch.rs`, `set.rs`
* `crates/smtp/src/queue/` : `tenant.rs`
* `crates/spam-filter/src/analysis/ai/` : `context.rs`, `facts.rs`, `gate.rs`, `mod.rs`, `verdict.rs`
* `crates/store/src/backend/composite/` : `mod.rs`, `read_replica.rs`, `sharded_blob.rs`, `sharded_lookup.rs`

Ce que couvrent ces fichiers : licence et marque de l'édition Entreprise, IA (modèles et
anti-spam), alertes et télémétrie en direct, SCIM, réplicas et répartition du stockage, quotas
par organisation de la file (`queue/tenant.rs`), restauration des éléments supprimés
(`archived_item.rs`).

### 2.3. Extraits retirés dans les crates qui alimentent `lyxal_mail`

* `crates/smtp/src/inbound/data.rs` : 1 extrait(s), 6 ligne(s)
* `crates/smtp/src/queue/encrypt.rs` : 1 extrait(s), 6 ligne(s)
* `crates/smtp/src/queue/mod.rs` : 2 extrait(s), 12 ligne(s)
* `crates/smtp/src/queue/spool.rs` : 6 extrait(s), 50 ligne(s)
* `crates/smtp/src/reporting/analysis.rs` : 9 extrait(s), 109 ligne(s)
* `crates/smtp/src/reporting/index.rs` : 6 extrait(s), 44 ligne(s)
* `crates/imap/src/op/acl.rs` : 1 extrait(s), 24 ligne(s)
* `crates/imap/src/op/append.rs` : 1 extrait(s), 6 ligne(s)
* `crates/imap/src/op/copy_move.rs` : 2 extrait(s), 16 ligne(s)
* `crates/managesieve/src/op/putscript.rs` : 1 extrait(s), 9 ligne(s)
* `crates/email/src/message/copy.rs` : 9 extrait(s), 65 ligne(s)
* `crates/email/src/message/delete.rs` : 2 extrait(s), 16 ligne(s)
* `crates/email/src/message/delivery.rs` : 1 extrait(s), 10 ligne(s)
* `crates/email/src/message/ingest.rs` : 4 extrait(s), 35 ligne(s)
* `crates/email/src/message/ingest_metadata.rs` : 2 extrait(s), 11 ligne(s)
* `crates/email/src/message/index/metadata.rs` : 2 extrait(s), 11 ligne(s)
* `crates/email/src/message/index/mod.rs` : 1 extrait(s), 5 ligne(s)
* `crates/email/src/message/ingest/group.rs` : 1 extrait(s), 6 ligne(s)
* `crates/spam-filter/src/analysis/mod.rs` : 1 extrait(s), 6 ligne(s)
* `crates/spam-filter/src/analysis/score.rs` : 2 extrait(s), 15 ligne(s)
* `crates/jmap/src/api/acl.rs` : 2 extrait(s), 32 ligne(s)
* `crates/jmap/src/api/mod.rs` : 1 extrait(s), 6 ligne(s)
* `crates/jmap/src/blob/download.rs` : 2 extrait(s), 31 ligne(s)
* `crates/jmap/src/email/copy.rs` : 2 extrait(s), 15 ligne(s)
* `crates/jmap/src/file/mod.rs` : 2 extrait(s), 12 ligne(s)
* `crates/jmap/src/principal/get.rs` : 2 extrait(s), 18 ligne(s)
* `crates/jmap/src/principal/query.rs` : 3 extrait(s), 18 ligne(s)
* `crates/jmap/src/registry/get.rs` : 12 extrait(s), 102 ligne(s)
* `crates/jmap/src/registry/mod.rs` : 1 extrait(s), 22 ligne(s)
* `crates/jmap/src/registry/query.rs` : 3 extrait(s), 49 ligne(s)
* `crates/jmap/src/registry/set.rs` : 17 extrait(s), 208 ligne(s)
* `crates/jmap/src/registry/mapping/action.rs` : 2 extrait(s), 30 ligne(s)
* `crates/jmap/src/registry/mapping/domain.rs` : 2 extrait(s), 21 ligne(s)
* `crates/jmap/src/registry/mapping/index_queue.rs` : 2 extrait(s), 12 ligne(s)
* `crates/jmap/src/registry/mapping/mod.rs` : 4 extrait(s), 27 ligne(s)
* `crates/jmap/src/registry/mapping/oauth_client.rs` : 1 extrait(s), 6 ligne(s)
* `crates/jmap/src/registry/mapping/principal.rs` : 4 extrait(s), 120 ligne(s)
* `crates/jmap/src/registry/mapping/queued_message.rs` : 9 extrait(s), 134 ligne(s)
* `crates/jmap/src/registry/mapping/report.rs` : 7 extrait(s), 63 ligne(s)
* `crates/jmap/src/registry/mapping/task.rs` : 3 extrait(s), 78 ligne(s)

La liste complète, fichier par fichier, est dans `.sources/reports/stalwart_sel.json` après un
passage de `fetch_sources.sh`.

### 2.4. Vérification

* Après tri : **0** ligne `SPDX-License-Identifier: LicenseRef-SEL` et **0** extrait
  propriétaire restants (`strip_sel.py --check`, code de sortie 0).
* Mentions de `LicenseRef-SEL` qui restent, admises et comptées par le script :
  1 609 mentions de la **double licence**
  (`AGPL-3.0-only OR LicenseRef-SEL` : en-têtes SPDX des fichiers gardés, champ `license` de
  `Cargo.toml`, `api/v1/openapi.yml`) — ces en-têtes ne sont pas modifiés ; `README.md` (notice
  de licence du projet, 1 mention) ; `resources/scripts/ossify.py` (script de tri de l'éditeur,
  qui cite le marqueur, 3 mentions). Toute autre mention fait échouer la vérification.
* **Contrôle croisé avec le script de l'éditeur.** `resources/scripts/ossify.py` (Stalwart,
  `AGPL-3.0-only`) a été lu, pas exécuté (aucun code des clones n'est lancé). Ses règles sont
  réécrites dans `strip_sel.py` (option `--compare-ossify`) : appliquées au commit figé, elles
  donnent **le même résultat fichier par fichier** (0 différence sur 1 805 fichiers examinés).
  Écarts de méthode : `ossify.py` ne lit que les `.rs` et ne regarde que le premier commentaire
  du fichier ; il vide la racine d'un crate entièrement propriétaire (`scim/src/lib.rs`,
  `scim-proto/src/lib.rs`) au lieu de la supprimer ; il ne signale pas un extrait non fermé.
  Aucun de ces cas ne change le résultat sur ce commit.
* Limite : le tri suit les marqueurs posés par l'éditeur. Du code propriétaire qui ne porterait
  aucun marqueur ne serait pas détecté. Après tri, il reste hors extrait 182 attributs qui
  citent la fonctionnalité Cargo `enterprise` : 172 `not(feature = "enterprise")` (code de la
  version libre) et 10 conditions positives, sous en-tête de double licence, dans
  `common` (5), `store` (2), `services` (1), `main` (1) et `common/telemetry` (1) — aucun
  dans les crates de protocole. Le plan de chaque lot qui porte un de ces fichiers les relève.
* Test du script : `python3 -I scripts/sources/tests/test_strip_sel.py` (arbre synthétique),
  lancé par `scripts/ci/ci_local.sh` et par la CI.

## 3. Éléments portés

Aucun à ce jour (crate à créer). Chaque lot ajoute ses lignes.

| Élément de Lyxal (fichier ou dossier) | Projet | Commit | Licence | Chemin d'origine | Nature (porté / modèle) | Lot |
| :--- | :--- | :--- | :--- | :--- | :--- | :- |
| — | — | — | — | — | — | — |

« Porté » : code repris et adapté. « Modèle » : fonctionnement repris, code réécrit. Les
mentions de droit d'auteur et de licence des fichiers portés sont conservées dans les fichiers.
