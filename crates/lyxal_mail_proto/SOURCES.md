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
| `mail-parser` | <https://crates.io/crates/mail-parser> | version 1.0.1 (dépendance, non copiée) | Apache-2.0 OR MIT | Lecture des messages |

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

## 3. Éléments portés

Aucun à ce jour (crate à créer). Chaque lot ajoute ses lignes.

| Élément de Lyxal (fichier ou dossier) | Projet | Commit | Licence | Chemin d'origine | Nature (porté / modèle) | Lot |
| :--- | :--- | :--- | :--- | :--- | :--- | :- |
| — | — | — | — | — | — | — |

« Porté » : code repris et adapté. « Modèle » : fonctionnement repris, code réécrit. Les
mentions de droit d'auteur et de licence des fichiers portés sont conservées dans les fichiers.
