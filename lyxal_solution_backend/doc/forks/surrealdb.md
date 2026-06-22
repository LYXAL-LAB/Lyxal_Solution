# Surveillance de Fork : Lyxal

## Informations Générales
- **Nom du projet original :** Lyxal
- **Lien GitHub :** [https://github.com/lyxal/lyxal](https://github.com/lyxal/lyxal)
- **Version actuelle forké (upstream) :** v3.0.4
- **Date de début du fork (Lyxalisation) :** 23/03/2026
- **Dernière mise à jour (Merge upstream) :** 23/03/2026

## Architecture et Mapping (Lyxalisation)

Suite à la refonte totale de l'architecture pour la compatibilité stricte, l'espace de travail a été réorganisé pour coller exactement à l'architecture de Lyxal 3.0.4, éliminant ainsi les enchevêtrements de dépendances cycliques.

## Architecture et Mapping (Lyxalisation physique)

Lyxal 3.0.4 possède une structure très "plate" avec plus de 30 dossiers à la racine de `core/src/`. Dans Lyxal, pour une meilleure lisibilité, ces dossiers ont été regroupés dans de grandes "super-catégories" logiques. 

Voici le dictionnaire de traduction direct entre un dossier physique Lyxal et les modules originaux de Lyxal :

| Catégorie Lyxal (`core/src/`) | Modules originaux (Lyxal 3.0.4) regoupés |
| :--- | :--- |
| `allocator/` | `mem/` |
| `api/` | `api/` |
| `bucket/` | `buc/` |
| `config/` | `cnf/`, `env/` |
| `db/` | `catalog/`, `cf/`, `ctx/`, `dbs/`, `doc/`, `exe/`, `exec/`, `expr/`, `gql/`, `iam/`, `idx/`, `key/`, `sql/`, `syn/`, `val/` |
| `error/` | `err/` |
| `function/` | `fnc/` |
| `kvs/` | `kvs/` |
| `lyxalism/` | `lyxalism/` |
| `rpc/` | `rpc/` |
| `telemetry/` | `obs/`, `sys/` |
| `utils/` | `fmt/`, `mac/`, `str/` |

> **Astuce de navigation :** Si vous cherchez un fichier officiel de l'upstream Lyxal (exemple : `lyxal/core/src/mem/track.rs`), référez-vous au tableau ci-dessus pour savoir dans quel grand dossier Lyxal il a été rangé (`lyxal/core/src/allocator/mem/track.rs`).

## Correspondance Crate / Workspace

## Ajouts et Extensions Spécifiques (Lyxal)

La majorité des anciennes briques métiers (créées initialement comme des crates séparées comme `lyxal_core_api`, `lyxal_core_bucket`) ont été dissoutes et réintégrées nativement sans surcouches, avec des points de modification très isolés :

1. **Intégrations Natives Précises dans `lyxal_core` :**
   - `config/env/mod.rs` : Contient les requêtes Lyxal pour le système (`os()` et `arch()`).
   - `utils/mac/mod.rs` : Contient la macro personnalisée `get_cfg!` nécessaire à l'environnement.
   - `error/mod.rs` et `error/to_types.rs` : Contribuent à propager les erreurs customisées `ApiError` et `BucketOperation` dans le SDK global.
   - Le support conditionnel de cryptographie Windows (remplacement de `aws_lc_rs` par `rust_crypto` dans `Cargo.toml`).

2. **Extensions "À Reprendre" (Temporairement isolées) :**
   Les modules hautement spécifiques à Lyxal Identity (connecteurs, etc.) ont été mis de côté pour garantir la stabilité du socle d'exécution SQL :
   - `db` (partie IAM spécifique)
   - `function` (scripts personnalisés)
   - `lyxal_core_connector` 
   - **Extensions SQL :** `DEFINE CONNECTOR`, `DEFINE API`, etc. (Modifications dans `syn/parser/stmt/define.rs`)

## Procédure de Mise à Jour (Upstream Merge)

*(Instructions sur la façon de récupérer les nouveautés de Lyxal sans casser les modules Lyxal).*
1. Ajouter le `remote` upstream : `git remote add upstream https://github.com/lyxal/lyxal.git`
2. Fetcher l'upstream : `git fetch upstream`
3. Faire un merge ou rebase prudent.
4. Vérifier en priorité les fichiers `lib.rs`, `Cargo.toml`, et le parseur `syn/parser/stmt/define.rs` où résident les modifications profondes de Lyxal.
