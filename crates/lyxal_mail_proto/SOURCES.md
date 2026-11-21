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
| `mail-parser` | <https://crates.io/crates/mail-parser> | version 1.0.1 (dépendance ; commit du paquet `a56d5f1dc0050a9de123df926081e436334ba9e5`) ; corpus d'essai copié de la version 0.11.9 (commit `918cc0c891f5e2a0009ccab4e935e91f68c673be`) | Apache-2.0 OR MIT | Lecture des messages (lot 4) ; corpus d'essai (§3) |

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

`mail-parser` 1.0.1 exige Rust 1.98 : le workspace y est passé au lot 4 (décision du CTO du
21 novembre 2026). Arbre ajouté : `mail-parser` 1.0.1, `encodify` 1.0.2, `hashify` 0.3.2
(`Apache-2.0 OR MIT`), `memchr`, `simdutf8` et `encoding_rs` (déjà présents) ; contrôlé par
`cargo deny check licenses`.

## 3. Éléments repris

Aucun code de Stalwart ni de Mox au lot 4 : la lecture MIME est écrite pour Lyxal OS autour de
la dépendance `mail-parser`. Chaque lot ajoute ses lignes.

| Élément de Lyxal (fichier ou dossier) | Projet | Commit | Licence | Chemin d'origine | Nature (porté / modèle / copié) | Lot |
| :--- | :--- | :--- | :--- | :--- | :--- | :- |
| `tests/corpus/mail-parser/rfc/*.eml` (10 messages) | `mail-parser` | 0.11.9 (`918cc0c`) | `Apache-2.0 OR MIT`, option MIT retenue (avis : `LICENSES/MIT-mail-parser.txt`) | `resources/eml/rfc/*.eml` | copié (données d'essai, sans modification) | 4 |
| `tests/corpus/mail-parser/malformed/*.eml` (23 messages) | `mail-parser` | 0.11.9 (`918cc0c`) | idem | `resources/eml/malformed/*.eml` | copié (données d'essai, sans modification) | 4 |

« Porté » : code repris et adapté. « Modèle » : fonctionnement repris, code réécrit. « Copié » :
fichier repris tel quel. Les mentions de droit d'auteur et de licence des fichiers portés sont
conservées dans les fichiers ; les fichiers copiés du corpus, qui n'en portent pas, relèvent de
l'avis `LICENSES/MIT-mail-parser.txt`. Texte de la licence du crate : `LICENSES/AGPL-3.0-only.txt`
(copie de celui de `crates/lyxal_mail`).
