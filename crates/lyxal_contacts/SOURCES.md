# `lyxal_contacts` — provenance des sources

Registre de provenance exigé par les décisions F4 et P2 du programme courrier, agendas et
contacts. **Règle : tout élément porté d'un projet extérieur est inscrit ici** — fichier ou
dossier de Lyxal, projet d'origine, commit, licence, chemin d'origine — dans le même changement
que le code. Un élément absent de ce registre ne doit pas exister dans le crate.

## 1. Sources figées (décision C2)

Les sources ne sont pas versées dans le dépôt. `scripts/sources/fetch_sources.sh` les clone dans
`.sources/<nom>/` (dossier ignoré par Git), vérifie le commit reçu et n'exécute rien de ce
qu'il récupère. Changer de commit est un changement comme un autre : plan, registre mis à jour,
validation du CTO (décision P14).

| Nom local | Projet | Adresse | Commit figé | Licence | Usage pour ce crate |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `stalwart` | Stalwart 1.1.1 | <https://github.com/stalwartlabs/stalwart> | `3adead91f3c87e7415b58c9ed8e6ec05a5dda521` | `AGPL-3.0-only OR LicenseRef-SEL` (option AGPL retenue) | Source principale : `crates/dav/src/card`, `crates/groupware/src/contact`, `crates/jmap` (contacts) |
| `rustical` | RustiCal 0.19.1 | <https://github.com/lennart-k/rustical> | `0698bb6b89b51207652eb60973a86364c3446ecb` | `AGPL-3.0-or-later` | Complément : `crates/carddav` |
| `sabre_dav` | sabre/dav | <https://github.com/sabre-io/dav> | `be1d58d6bce7ca33313b02909f9088c93c35db02` | BSD-3-Clause | Complément : `lib/CardDAV` (modèle de données et tests) |

## 2. Code propriétaire de Stalwart : jamais utilisé (décisions F5 et C3)

Seule la copie de travail triée par `scripts/sources/strip_sel.py` sert de source. Le rapport
complet (tous les crates, fichiers supprimés, vérification, contrôle croisé avec le script de
l'éditeur) est dans [`crates/lyxal_mail/SOURCES.md`](../lyxal_mail/SOURCES.md). Résultat pour les
crates de Stalwart qui alimentent ce crate (commit `3adead9`, tri du 18 novembre 2026) :

| Crate Stalwart | Fichiers supprimés (`LicenseRef-SEL` seule) | Lignes de ces fichiers | Fichiers avec extraits | Extraits retirés | Lignes d'extraits retirées | Fichiers `.rs` après tri | Lignes `.rs` après tri | Usage prévu dans Lyxal |
| :--- | -: | -: | -: | -: | -: | -: | -: | :--- |
| `dav` | 0 | 0 | 8 | 23 | 245 | 49 | 21 866 | `lyxal_dav`, `lyxal_calendar`, `lyxal_contacts` |
| `groupware` | 0 | 0 | 2 | 3 | 37 | 49 | 25 938 | `lyxal_calendar`, `lyxal_contacts` |
| `jmap` | 2 | 893 | 20 | 81 | 1 004 | 152 | 52 558 | `lyxal_mail` ; agendas et contacts : `lyxal_calendar`, `lyxal_contacts` |
| **Total** | **2** | **893** | **30** | **107** | **1 286** | **250** | **100 362** | |

Extraits retirés dans les fichiers de contacts :

* `crates/dav/src/card/update.rs` : 3 extrait(s), 30 ligne(s)

`crates/groupware/src/contact` ne contient aucun extrait propriétaire.

## 3. Éléments portés

Aucun à ce jour (crate à créer). Chaque lot ajoute ses lignes.

| Élément de Lyxal (fichier ou dossier) | Projet | Commit | Licence | Chemin d'origine | Nature (porté / modèle) | Lot |
| :--- | :--- | :--- | :--- | :--- | :--- | :- |
| — | — | — | — | — | — | — |

« Porté » : code repris et adapté. « Modèle » : fonctionnement repris, code réécrit. Les
mentions de droit d'auteur et de licence des fichiers portés sont conservées dans les fichiers.
