# Audit de conformité — `lyxal_core`

> **Document de travail de la reprise du module** (régime zéro dette, `.agents/AGENTS.md` §0) : il décrit l'état constaté avant la reprise et sert de point de reprise entre sessions. Il sera supprimé à la fin de la reprise, une fois les corrections fusionnées.
> **Date** : 2026-11-01 · **Méthode** : skill `lyxal-audit`, lecture seule, analyse automatisée des 1 598 fichiers + essais réels sur SurrealDB 3.3.4.

---

## 0. Où en est la reprise ? (à mettre à jour à chaque étape)

| Étape | État |
| :--- | :--- |
| 1. Audit (ce document) | ✅ terminé |
| 2. Décisions CTO (§7) | ✅ Q1 résultat renvoyé · Q2 moteur unique · Q3 suppression des 18 fonctions · Q4 tests après Q1–Q3 |
| 3. [`implementation_plan.md`](implementation_plan.md) | ✅ validé par le CTO |
| 4. Exécution par lots (PR) | Lot 1 (nettoyage) ✅ PR #6 · Lot 2 (outillage de tests) ✅ PR #7 · Lot 3 (contrat Q1) ⏳ famille « types, nombres et chaînes » (44 fonctions) ✅ PR #8, 4 validateurs JSON supprimés (plan §4 bis) ✅ PR #9 ; famille « dates et durées » (21 fonctions) ✅ PR #10 ; famille « tableaux, objets et références » (29 fonctions) ✅ PR #11 ; 4 doublons supprimés (plan §4 ter) ; famille « formats techniques » (44 fonctions) en cours ; restent les formats métier (≈ 61 fonctions), `sanitize`, `security`, `utils` · lots 4 et 5 à venir |
| 5. Suppression de ce document | — |

---

## 1. Périmètre audité

* **Module** : `crates/lyxal_core`, `manifest.toml` version `1.0.0`.
* **Niveau** : Fondation transversale (couche 0), SurrealQL uniquement, sans crate Rust ni dépendance.
* **Fichiers** : `manifest.toml` ; 799 fonctions (`functions/{validations,sanitize,security,utils}/functions/`) ; 799 fichiers de test (`functions/validations/test/`, `functions/{sanitize,security,utils}/tests/`) ; `Readme.md` ; `CHANGELOG.md` ; `functions/validations/Readme.md`.

| Domaine | Fonctions |
| :--- | ---: |
| `validations` (`fn::validation_*`) | 339 |
| `sanitize` (`fn::sanitize_*`) | 170 |
| `security` (`fn::security_*`) | 170 |
| `utils` (`fn::utils_*`) | 120 |

## 2. Synthèse & verdict

**NON CONFORME** — aucun écart P0 (pas de faille de sécurité, pas d'import crypto, pas d'erreur masquée), mais 4 écarts P1.

Contexte : **aucun module du dépôt n'appelle aujourd'hui une fonction du Core** (0 / 799), alors que `lyxal_error`, `lyxal_event`, `lyxal_pipeline_ingestion` et `lyxal_catalogue` le déclarent comme dépendance. L'absence d'usage n'est **pas** un défaut en soi (de nombreux modules restent à développer), mais elle s'explique en grande partie par P1-1 : le contrat d'erreur du Core n'est pas exploitable depuis une fonction de module.

## 3. Écarts constatés

### P1-1 — Contrat d'erreur incompatible avec les modules

* **Règles** : §5.3 (contrat de retour `fn::result_ok` / `fn::error_result`), §5.5 (codes préfixés par le module propriétaire, master data).
* **Constat** :
  * Les primitives signalent les erreurs par `THROW`. En SurrealQL, un `THROW` interrompt toute la requête : la fonction de module appelante ne peut ni l'intercepter, ni répondre via `fn::error_result`.
  * **1 412 instructions `THROW` construisent leur code à partir d'un argument de l'appelant**, ex. `functions/sanitize/functions/trim.surql` : `THROW string::concat($clean_field, "_REQUIRED")`. Ces codes (`EMAIL_REQUIRED`, `email_INVALID_FORMAT`…) ne sont ni préfixés par un module ni définissables en master data.
  * **0 des 341 codes fixes** (`VALIDATION_*` ×220, `SECURITY_*` ×52, `SANITIZE_*` ×37, `UTILS_*` ×31, `CONFIGURATION_*` ×1) n'a de définition `error_definition` dans le dépôt. Leur préfixe ne désigne pas non plus le module propriétaire (`lyxal_core`).
* **Preuve (essai réel, SurrealDB 3.3.4)** : une fonction de module `fn::demo_create_user($params)` qui appelle `fn::validation_email($params.email, "email")` avec `"pas-un-email"` échoue en bloc sur `An error occurred: email_INVALID_FORMAT`, sans `LyxalResult`. Côté Rust, `LyxalSurrealCall::call_fn` reçoit une erreur base de données générique (`LyxalSurrealError::Database`), pas une erreur métier (`LyxalCallError::Business`).

### P1-2 — Même mécanique réimplémentée dans chaque domaine, avec des comportements divergents

* **Règles** : §5.1 (une responsabilité = un endroit), §5.7.6 (pas de variante locale d'une même primitive).
* **Constat** : 275 fonctions (34 %) forment une mécanique de traitement générique — pipelines d'étapes, optimiseur, débogage, benchmark, exécution (« runtime »), « SDK », compilation et cache de schémas. Cette mécanique est **réimplémentée séparément dans chaque domaine**, avec les mêmes noms mais des corps qui ont divergé :

| Famille | Fonctions | Noms présents dans ≥ 2 domaines | Similarité moyenne des corps |
| :--- | ---: | ---: | ---: |
| `benchmark` | 30 | 10 | 0,62 |
| `debug` | 30 | 10 | 0,68 |
| `optimizer` | 30 | 10 | 0,63 |
| `pipeline` | 50 | 12 | 0,49 |
| `runtime` | 40 | 10 | 0,54 |
| `sdk` | 30 | 7 | 0,52 |
| `schema` | 49 | 10 | 0,65 |
| `cache` | 26 | 3 | 0,74 |

* **Exemple de divergence** : `fn::sanitize_pipeline_merge($left, $right, $max_steps)` limite le nombre d'étapes (`SANITIZE_PIPELINE_TOO_MANY_STEPS`), `fn::security_pipeline_merge($left, $right)` ne le fait pas.
* Ces fonctions ne sont **pas** inutiles : le constat porte sur la duplication, pas sur l'absence d'usage.

### P1-3 — 12 « demandes » crypto sans consommateur, dont des vérifications qui ne vérifient rien

* **Règle** : §11.3 (`lyxal_crypto` est le crate cryptographique officiel et unique).
* **Périmètre exact** : le domaine `security` (170 fonctions) est **utile dans son ensemble** — empreintes non secrètes (`hash_sha256`, `hash_blake3`, `hash_verify` pour SHA-256/BLAKE3), construction et analyse de jetons (`token_claims`, `token_parse`, `token_expiration`), masquage (`redact_*`), détection d'attaques (`detect_*`), permissions, rôles et politiques, nonces et fenêtres anti-rejeu. L'écart ne concerne que **12 fonctions** qui renvoient une « demande » (`{ operation, …, requires_native_crypto: true }`) au lieu d'un résultat : `encrypt`, `encrypt_file`, `decrypt`, `hmac_sign`, `hmac_verify`, `key_generate`, `key_derive`, `key_wrap`, `key_unwrap`, `token_sign`, `token_verify`, `secret_compare`, ainsi que 2 fonctions qui lèvent toujours une erreur (`security_hash_argon2`, `security_signature_verify`).
* **Pourquoi c'est un problème** :
  * aucun code Rust ne lit ces demandes (`lyxal_crypto` n'accède pas à SurrealDB, par contrat) : le contrat n'aboutit nulle part ;
  * **piège de sécurité démontré** (SurrealDB 3.3.4) : `RETURN IF fn::security_hmac_verify("message", "SIGNATURE-FALSIFIEE", "cle_ref", "hmac-sha256") { "ACCEPTÉ" } ELSE { "REFUSÉ" }` renvoie **`ACCEPTÉ`** — l'objet de demande non vide est évalué comme vrai. Une fonction nommée `*_verify` qui ne vérifie pas, appelée naïvement, accepte une signature falsifiée. Même risque pour `token_verify` et `secret_compare`.
* `fn::security_secret_generate` produit des secrets avec `rand::id` : générateur non établi comme cryptographiquement sûr (cf. §5).

### P1-4 — Tests sans assertions

* **Règle** : Contrôle 8 (preuves de tests).
* **Constat** : **797 fichiers de test sur 799 ne contiennent aucune assertion**. Le résultat attendu est un commentaire (`-- Résultat attendu : "contact@example.com"`), présent dans 190 fichiers seulement (760 instructions). La CI (`scripts/ci/test_lyxal_core.py`) prouve que les 2 557 instructions s'exécutent sans erreur moteur inattendue, **pas** qu'elles renvoient la bonne valeur ni le bon code d'erreur. L'affirmation « 799 primitives validées » des skills est donc à nuancer.

### P2 — Mineurs (régime zéro dette, cohérence)

| ID | Constat | Fichier(s) |
| :--- | :--- | :--- |
| P2-1 | Version `1.0.0` (§0 : `0.y.z`). Les dépendants exigent `>=1.0.0` : `crates/{lyxal_error,lyxal_event,lyxal_pipeline_ingestion,lyxal_catalogue}/manifest.toml` et `crates/lyxal_pipeline_ingestion/src/module.rs`. | `manifest.toml` |
| P2-2 | Documents historiques : `CHANGELOG.md`, historique de vérification 3.2.0 dans `Readme.md`. | `CHANGELOG.md`, `Readme.md` |
| P2-3 | Dossier de tests `validations/test/` au lieu de `tests/` ; en-têtes de fichiers aux chemins erronés (`core/validation/…`). | `functions/validations/test/`, en-têtes |
| P2-4 | Exemples en commentaire citant des fonctions inexistantes (`validation_range`, `validation_point`, `validation_exists_compound`…) ou des modules métiers (`booking_create_team`, `crm_create_contact`, `identity_create_user`). | commentaires d'en-tête |

## 4. Correspondance DTO Rust ↔ SurrealQL

Sans objet : pas de crate Rust ; signatures positionnelles typées admises par contrat pour le Core (skill `lyxal-audit`, Contrôle 2.3).

## 5. Points non vérifiés faute de preuves

* **Exactitude des valeurs renvoyées** : non prouvée (P1-4) ; 609 fichiers de test n'indiquent même pas de résultat attendu.
* **`rand::id`** (`security_secret_generate`) : caractère cryptographiquement sûr non vérifié.
* **Appel par un utilisateur non administrateur** (permissions de session, `PERMISSIONS FULL` sur toutes les fonctions) : non testé.

## 6. Éléments conformes & preuves

* `manifest.toml` synchronisé avec le disque : 799 fonctions listées, toutes présentes, aucune oubliée ; les tests ne sont pas des ressources (normal).
* Une fonction par fichier, nom de fichier = nom de fonction, préfixe de domaine respecté, aucun doublon, `DEFINE FUNCTION OVERWRITE` partout.
* `COMMENT` et type de retour sur **100 %** des fonctions ; signatures entièrement typées.
* Aucune fonction ne dépasse 300 lignes **de code** (les fichiers longs, jusqu'à 870 lignes, sont des en-têtes de documentation).
* Aucun `result_error`, aucun appel vers une couche supérieure (`lyxal_error`, modules), aucune écriture en base ; seules `validation_exists` et `validation_unique` lisent une table passée en paramètre.
* SurrealDB 3.3.4 : `scripts/ci/validate_surql.sh` → 1 598 fichiers valides ; `scripts/ci/test_lyxal_core.py` → 799 fonctions définies, 2 557 instructions, 1 585 OK, 963 `THROW`, 9 rejets JSON, 0 erreur inattendue (job « SurrealQL » de la CI vert sur `main`).

## 7. Plan correctif proposé — décisions CTO

* **Q1 — Contrat d'erreur (P1-1)** — ✅ **décidé : résultat renvoyé.** `validation_*` renvoient un résultat (booléen, ou `{ valid, code, details }`) ; `sanitize_*` transforment sans lever ; seul un argument invalide (erreur de programmation) lève `THROW` avec un code fixe `CORE_*` défini en master data ; le module appelant choisit son propre code (`<MODULE>_…`) et répond via `fn::error_result`.
* **Q2 — Mécanique dupliquée (P1-2)** — ✅ **décidé : moteur unique.** Chaque famille (pipeline, optimiseur, débogage, benchmark, exécution, schéma, cache, SDK) est regroupée en un seul moteur générique dans `utils`, paramétré par le domaine ; chaque domaine ne garde que ses étapes propres. Aucune primitive n'est supprimée pour cause de non-usage.
* **Q3 — Crypto (P1-3)** — ✅ **décidé : suppression de 18 fonctions** (les 14 ci-dessous, plus `encrypt_string`, `encrypt_object`, `secret_export` et `secret_import`, de même nature, validées au lot 1). Supprimer uniquement les 12 « demandes » et les 2 fonctions qui lèvent toujours une erreur (la crypto reste dans `lyxal_crypto`, appelée par le Rust avant ou après `call_fn`) ; conserver les ≈ 156 autres fonctions du domaine ; revoir `security_secret_generate`.
* **Q4 — Tests (P1-4)** — ✅ **décidé : après Q1–Q3.** Réécriture au format « valeur attendue vérifiée » (la CI échoue au moindre écart).
* **Puis P2** : version `0.1.0` + mise à jour des 5 appelants ; suppression de `CHANGELOG.md` ; `Readme.md` décrivant l'état actuel ; `test/` → `tests/` ; en-têtes et exemples corrigés.

Vu l'ampleur (Q1 touche le contrat de la plupart des fonctions), la reprise sera découpée en plusieurs PR.

## Annexe — Reproduire les contrôles

* Validation et suite du Core : `scripts/ci/validate_surql.sh` et `python3 -I scripts/ci/test_lyxal_core.py` (binaire `surreal` 3.3.4 via `LYXAL_SURREAL_BIN` ou le `PATH`).
* Usage du Core dans le dépôt : `grep -rE 'fn::(validation|sanitize|security|utils)_' crates apps --include=*.surql --include=*.rs` hors `crates/lyxal_core`.
* Codes d'erreur dynamiques : `grep -rc 'THROW string::concat' crates/lyxal_core/functions/*/functions`.
