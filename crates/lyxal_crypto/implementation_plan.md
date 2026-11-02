# Plan d'implémentation — reprise de `lyxal_crypto`

> **Statut : soumis au CTO.** Aucune modification avant validation explicite (§3).
> Constats : `AUDIT.md` (C-01 à C-05). Supprimé avec `AUDIT.md` à la clôture (§0.3.4).

Aucun changement de code ni d'API publique n'est proposé : le code est conforme. L'API reste
celle décrite au §11.3 et dans `API_CONTRACT.md`.

## 1. Décisions demandées

| # | Question | Recommandation |
| :- | :--- | :--- |
| Q1 | **`ENVELOPE_FORMAT_V1.md`** : le fichier se déclare « archive historique, non pris en charge ». Le §11.3 indique que l'ancien format `enc:v1` « est conservé pour mémoire historique ». | **Supprimer le fichier.** Le §0 prime sur les règles d'historique, et la mémoire du format reste dans Git. `AGENTS.md` n'est pas modifié (consigne CTO) : sa phrase reste vraie au sens où le format n'est plus produit et reste retrouvable dans l'historique. *Alternative* : garder le fichier tel quel. |
| Q2 | **Outils hors CI (C-04)** : vérification des bornes de traits (`tools/check_contracts.py` et `tools/contracts/`), vecteurs vérifiés par OpenSSL (`tools/check_fixtures.py`), campagnes de fuzz (`fuzz/`, `tools/run_fuzz.py`). | **Garder ces outils comme vérifications manuelles**, documentées dans le README avec leurs prérequis (module Python `cryptography`, Rust nightly et `cargo-fuzz`). Ils testent le crate sans en dépendre et ne sont pas du code mort. Supprimer `validation/` et `tools/validate.py`, qui ne font qu'archiver une exécution passée. *Alternative* : brancher `check_fixtures.py` dans la CI, ce qui ajoute le module Python `cryptography` à l'image de CI. |

## 2. Changements

Documentation uniquement, aucun code Rust touché :

* **Suppressions** (C-02) : `CHANGELOG.md`, `MIGRATION_GUIDE.md`, `roadmap.md`,
  `validation/`, `tools/validate.py`, et `ENVELOPE_FORMAT_V1.md` selon Q1.
* **Réécriture à l'état actuel** (C-03) :
  * `README.md` : rôle, API, exemple exécutable (il sert de doctest via
    `#![doc = include_str!("../README.md")]`), vérifications automatiques et manuelles (Q2) ;
  * `API_CONTRACT.md` et `ENVELOPE_FORMAT_V2.md` : retrait des statuts « phase B » et
    « réception CTO en attente » ; contenu technique inchangé ;
  * `SECURITY.md` et `fuzz/README.md` : retrait des renvois vers `IMPLEMENTATION_REPORT.md`
    (absent) et `validation/`.
* **Harmonisation** (C-05) : documentation Rust de `src/hash.rs` en anglais, comme les autres
  fichiers de `src/` (6 commentaires).
* **`lyxal_booking`** (C-01) : note de reprise dans `lyxal_booking/implementation_plan.md`,
  listant l'ancienne API encore appelée et son remplacement :
  * `encrypt_secret` / `decrypt_secret` → `seal` / `open` ;
  * `from_bytes` → `import(SecretBytes)` ;
  * `cipher::*` → module privé, plus accessible ;
  * `Zeroizing` → `SecretBytes` / `SecretString`.

  Elle signale aussi que le plan Cal.rs existant s'appuie sur une fonction devenue privée.

## 3. Vérification

* `cargo test -p lyxal_crypto` : tests et doctests, dont l'exemple du README.
* `cargo clippy` et `cargo doc` en `-D warnings`.
* `scripts/ci/ci_local.sh`.
* Recherche dans le dépôt des liens vers les fichiers supprimés.

## 4. Lots

| Lot | Contenu |
| :- | :--- |
| 1 | Suppressions, réécriture des documents, harmonisation de `hash.rs`, note `lyxal_booking`. |
| 2 | Clôture : audit de contrôle, suppression de `AUDIT.md` et de ce plan. |

## 5. Checklist §13 (extraits)

* Cryptographie : aucune primitive ajoutée, aucune dépendance ajoutée, API figée inchangée.
* Zéro dette : documents historiques supprimés, aucun alias, version `0.1.0`.
* Validation CTO : décisions Q1 et Q2.
