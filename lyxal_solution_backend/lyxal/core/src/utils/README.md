# lyxal_core_utils

## Rôle
Crate utilitaire regroupant les **macros fondamentales**, les **utilitaires de formatage SQL** et les **parseurs de chaînes** utilisés dans l'ensemble de Lyxal Solution.

## Ce qu'il contient

### `mac/` — Macros Fondamentales
Macros déclaratives utilisées dans tout le projet :

| Macro | Rôle |
|---|---|
| `lazy_env_parse!` | Parse paresseusement une variable d'environnement avec valeur par défaut |
| `map!` | Crée un `BTreeMap` à partir de valeurs clé/valeur |
| `mrg!` | Fusionne deux `BTreeMap` |
| `fail!` | Retourne une erreur `Unreachable` avec le fichier et la ligne |
| `bytes!` | Convertit du texte en `Vec<u8>` avec retour à la ligne |
| `yield_now!` | Rend la main au runtime Tokio |
| `get_cfg!` | Détecte la plateforme cible (OS, architecture) |
| `catch!` | Rollback automatique de transaction en cas d'erreur |
| `run!` | Commit ou rollback automatique de transaction |

### `fmt/` — Formatage SQL
Utilitaires de formatage pour la génération de requêtes SQL lisibles :
- `Fmt::comma_separated()` — Formate une liste séparée par des virgules.
- `Fmt::pretty_comma_separated()` — Idem avec indentation pour le pretty-printing.
- `CoverStmts` — Entoure automatiquement les sous-requêtes de parenthèses.
- `Float` — Formate les flottants avec gestion de `NaN` et `Infinity`.
- Fonctions d'échappement : `EscapeIdent`, `QuoteStr`, `EscapeObjectKey`.

### `str/` — Parseurs de Chaînes
Traits d'extension pour parser des suffixes humains :
- `ParseBytes` — Parse des tailles avec suffixes (`"10MiB"`, `"1GiB"` → `usize`).
- `ParseDuration` — Parse des durées avec suffixes (`"30s"`, `"5m"` → `Duration`).

## Pourquoi un crate séparé ?
Ces utilitaires sont tellement fondamentaux qu'ils sont importés par `lyxal_db`, `lyxal_core_config`, `lyxal_core_error` et `lyxal_server`. Les isoler évite les dépendances circulaires et permet une compilation incrémentale ultra-rapide.

## Utilisé par
Tous les crates du workspace.
