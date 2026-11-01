# Plan d'implémentation — Chantier 4 : banc de test commun & intégration continue (CI)

> **Statut** : EN ATTENTE DE VALIDATION CTO — aucune ligne de code modifiée.
> **Portée** : transverse (racine du workspace, `.github/`, `scripts/`, dossiers `tests/` des crates). Aucun contrat public, aucune fonction SurrealQL, aucun code de production modifié.
> **Régime** : pré-production « Zéro Dette » (`.agents/AGENTS.md` §0) — ce plan sera supprimé une fois exécuté et fusionné.

---

## 1. Objectif

Qu'une PR vers `main` ne puisse être fusionnée qu'après une preuve automatique que le workspace :

1. est formaté (`cargo fmt`) ;
2. passe `clippy -D warnings` (hors `lyxal_pipeline_ingestion`, en attente de sa reprise) ;
3. passe **tous** ses tests, y compris ceux qui exigent un vrai serveur SurrealDB 3.3.4 ;
4. ne contient que du SurrealQL valide en 3.3.4, et que la bibliothèque `lyxal_core` se comporte comme attendu.

Et que n'importe qui puisse rejouer exactement les mêmes vérifications en local avec une seule commande.

## 2. Constats (vérifiés le 2026-11-01)

| # | Constat |
| :- | :--- |
| C1 | Aucune CI : pas de dossier `.github/`. Toutes les vérifications des lots SDK 3.3 ont été faites à la main. |
| C2 | **73 fichiers de test = 73 exécutables** (chaque fichier de `tests/` est un programme séparé en Rust), dont ≈ 57 embarquent le moteur SurrealDB complet (`kv-mem`, conservé en production pour le futur mode hors ligne — décision CTO). Avec les infos de débogage, le dossier `target/` a atteint **23 Go** et le disque de la session a saturé deux fois. Un runner GitHub standard dispose d'environ 14 à 20 Go libres. |
| C3 | Répartition : `lyxal_runtime` 33 fichiers, `lyxal_crypto` 16, `lyxal_event` 10, `lyxal_pipeline_ingestion` 7, `lyxal_error` 3, `lyxal-server` 3, `lyxal_surreal` 1. |
| C4 | `rust-version = "1.80"` dans le `Cargo.toml` racine est **faux** : le SDK `surrealdb` 3.3 est en édition 2024 et utilise des constructions (`let` chaînés) qui exigent Rust ≥ 1.88. Aucune version de Rust n'est figée dans le dépôt. |
| C5 | Certains tests exigent un binaire ou un serveur SurrealDB : tests d'intégration de `lyxal_error` (lancent `surreal`), 6 tests « serveur réel » de `lyxal_pipeline_ingestion` (port 8001, identifiants via `LYXAL_STAGING_USER` / `LYXAL_STAGING_PASS`), test `ws://` + Root de `lyxal_surreal` et test de charge 1 000 événements de `lyxal_event` (ignorés par défaut). |
| C6 | Les vérifications SurrealQL faites pendant la migration (`surreal validate` sur 1 764 fichiers, rejeu des 2 557 instructions de tests de `lyxal_core`) reposent sur des scripts jetables, absents du dépôt. |
| C7 | `cargo fmt --all --check` passe déjà. `clippy -D warnings` passe sur tous les crates sauf `lyxal_pipeline_ingestion` (13 remarques préexistantes, traitées à sa reprise). |

## 3. Changements proposés

### 3.1. Un seul exécutable de tests par crate (réponse à C2)

Pour chaque crate, déplacer les fichiers de `tests/*.rs` dans `tests/it/` et créer `tests/it/main.rs` qui les déclare comme modules (`mod integration_publish_fanout;` …). Cargo produit alors **un** exécutable `it` par crate au lieu d'un par fichier.

* ≈ 73 exécutables → 7 ; espace disque et temps d'édition de liens divisés d'autant.
* Aucun test supprimé ni modifié dans sa logique : seuls les chemins des modules partagés changent (`mod common;` déclaré une fois dans `main.rs`, `use crate::common` dans les fichiers).
* **Point de vigilance** : les fichiers d'un même crate s'exécuteront désormais en parallèle dans le même processus (auparavant, Cargo lançait les exécutables l'un après l'autre). Les tests reposant sur un état global (ports fixes, verrous statiques, variables d'environnement) sont identifiés et vérifiés ; chaque `connect("mem://")` crée déjà une base isolée. En cas de conflit, le test concerné est sérialisé, sans être désactivé.

### 3.2. Profils de compilation (réponse à C2)

Dans le `Cargo.toml` racine :

```toml
[profile.dev]
debug = "line-tables-only"   # numéros de ligne conservés dans les traces, sans le reste des infos de débogage

[profile.dev.package."*"]
debug = false                # aucune info de débogage pour les dépendances (dont SurrealDB)
```

(`cargo test` utilise le profil `dev`.)

### 3.3. Version de Rust figée (réponse à C4)

* Ajouter `rust-toolchain.toml` à la racine qui fixe une version précise de Rust (proposition : la version stable utilisée pendant la migration, **1.97.0**), avec les composants `rustfmt` et `clippy`.
* Aligner `rust-version` du `Cargo.toml` racine sur cette même version : c'est la seule réellement testée.

### 3.4. Scripts de vérification versionnés (réponse à C6), dans `scripts/ci/`

| Script | Rôle |
| :--- | :--- |
| `install_surreal.sh` | Installe le binaire `surreal` **3.3.4** exact (script officiel `install.surrealdb.com --version v3.3.4`) et vérifie `surreal version`. |
| `validate_surql.sh` | `surreal validate` sur tous les `.surql` de `crates/` et `apps/` ; liste les fichiers en échec et sort en erreur s'il y en a un. |
| `test_lyxal_core.py` | Charge les 799 fonctions de `lyxal_core` dans un serveur 3.3.4, exécute ses 799 fichiers de tests et classe chaque instruction : retour `OK`, `THROW "<CODE>"` métier attendu, rejet JSON attendu, ou **erreur inattendue** (échec du script). |
| `clippy.sh` | `cargo clippy -p <crate> --no-deps --all-targets --all-features -D warnings` pour chaque crate du workspace, avec une liste d'exclusion explicite et commentée (aujourd'hui : `lyxal_pipeline_ingestion`, jusqu'à sa reprise). |
| `test_all.sh` | Démarre deux serveurs SurrealDB 3.3.4 en mémoire (recette sur le port 8001 avec des identifiants générés pour l'exécution ; serveur `ws://` pour les tests distants), lance `cargo test --workspace`, puis les tests ignorés qui exigent un serveur (`ws://` + Root, charge 1 000 événements), et arrête les serveurs. |
| `ci_local.sh` | Enchaîne tout dans le même ordre que la CI : une seule commande pour vérifier en local avant de pousser. |

Les identifiants des serveurs de test sont générés à chaque exécution : aucun secret GitHub n'est nécessaire, et le mot de passe par défaut écrit en clair dans un test de `lyxal_pipeline_ingestion` (défaut connu, cf. son README) n'est jamais utilisé.

### 3.5. Workflow GitHub Actions — `.github/workflows/ci.yml`

* **Déclencheurs** : `pull_request` vers `main`, `push` sur `main`, et lancement manuel (`workflow_dispatch`).
* **Annulation** des exécutions précédentes d'une même PR (`concurrency`).
* **Jobs** (en parallèle, sur `ubuntu-latest`) :

| Job | Contenu | Durée estimée |
| :--- | :--- | :--- |
| `fmt` | `cargo fmt --all --check` | < 1 min |
| `clippy` | `scripts/ci/clippy.sh` | 10–15 min à froid, 3–5 min avec cache |
| `test` | `install_surreal.sh` + `test_all.sh` | 15–25 min à froid, 5–10 min avec cache |
| `surql` | `install_surreal.sh` + `validate_surql.sh` + `test_lyxal_core.py` | 3–5 min |

* **Cache** de `~/.cargo` et `target/` entre exécutions (action `Swatinem/rust-cache`, version figée).
* **Espace disque** : contrôle de l'espace libre avant compilation ; avec 3.1 et 3.2 le besoin estimé passe sous les 8 Go. Si un runner manque malgré tout de place, suppression des outils préinstallés inutiles (SDK Android, .NET) en début de job.
* Les actions tierces sont référencées par une version précise.

## 4. Fonctions Core, SurrealQL, erreurs, crypto

* **Fonctions `lyxal_core` réutilisées / nouvelles** : aucune.
* **Fonctions SurrealQL nouvelles** : aucune.
* **Codes d'erreur master data** : aucun.
* **Besoin crypto** : aucun.

## 5. Lots d'exécution (un commit par lot)

| Lot | Contenu | Vérification |
| :- | :--- | :--- |
| 1 | Profils de compilation (3.2) + `rust-toolchain.toml` et `rust-version` (3.3). | `cargo test --workspace` ; mesure de la taille de `target/` avant / après. |
| 2 | Regroupement des tests en un exécutable par crate (3.1), crate par crate. | Même nombre de tests exécutés et réussis qu'avant (454 + tests ignorés) ; 3 exécutions consécutives sans échec intermittent. |
| 3 | Scripts `scripts/ci/` (3.4). | `ci_local.sh` passe dans la session. |
| 4 | Workflow `.github/workflows/ci.yml` (3.5). | Exécution réelle sur la PR : les 4 jobs passent. |

## 6. Questions au CTO

* **Q1 — Version de Rust** : figer **1.97.0** (la version avec laquelle toute la migration a été testée) et déclarer la même valeur en `rust-version` ? Alternative : rechercher la vraie version minimale (≥ 1.88) et la tester aussi en CI, au prix d'un job supplémentaire. Recommandation : 1.97.0, plus simple, montée de version explicite par la suite.
* **Q2 — Protection de `main`** : une fois la CI en place, rendre les 4 jobs **obligatoires** avant fusion (réglage *Branch protection rules* de GitHub, à faire par un administrateur du dépôt ; je ne peux pas le modifier). Recommandé.

## 7. Hors périmètre

* Les 13 remarques `clippy` et les défauts connus de `lyxal_pipeline_ingestion` (sa reprise).
* Les dossiers hors workspace (`lyxal_booking`, `lyxal_scheduler`, `Lyxal_Solution-main`, etc.) : ils ne sont ni compilés ni testés par la CI tant qu'ils ne sont pas intégrés au workspace.
* Déploiement, publication d'images Docker, tests de performance.

## 8. Checklist §13 (extraits pertinents)

* [x] Aucune primitive Core, aucune fonction SurrealQL, aucun contrat public modifié.
* [x] Aucun test supprimé ou désactivé ; aucun secret ajouté au dépôt.
* [x] Aucune dépendance de crate ajoutée.
* [ ] Validation explicite du CTO.
