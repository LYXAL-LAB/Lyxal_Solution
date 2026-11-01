# Plan d'implémentation — Reprise de `lyxal_core`

> **Statut** : VALIDÉ PAR LE CTO (2026-11-01) — exécution en cours (voir le tableau d'avancement de [`AUDIT.md`](AUDIT.md)).
> **Source** : [`AUDIT.md`](AUDIT.md) (audit du 2026-11-01) et décisions CTO Q1 à Q4.
> **Régime** : pré-production « Zéro Dette » (`.agents/AGENTS.md` §0) — ruptures de contrat autorisées, aucun appelant à préserver (aucun module n'appelle aujourd'hui le Core). Ce plan et `AUDIT.md` seront supprimés une fois la reprise exécutée et fusionnée.

---

## 1. Décisions CTO appliquées

| # | Décision |
| :- | :--- |
| Q1 | Contrat « résultat renvoyé » : les validations renvoient un résultat, les sanitize transforment, `THROW` réservé aux erreurs de programmation avec codes fixes `CORE_*`. |
| Q2 | Moteur unique : les familles pipeline / optimiseur / débogage / benchmark / exécution / schéma / SDK, réimplémentées dans `validations`, `sanitize` et `security`, sont regroupées en un seul moteur générique. Aucune primitive supprimée pour cause de non-usage. |
| Q3 | Suppression de 18 fonctions `security` (16 « demandes » crypto ou coffre sans consommateur + 2 fonctions qui lèvent toujours une erreur) ; le reste du domaine est conservé. Les 4 fonctions ajoutées aux 14 initiales (`encrypt_string`, `encrypt_object`, `secret_export`, `secret_import`) ont été validées par le CTO lors du lot 1. |
| Q4 | Tests réécrits au format « valeur attendue vérifiée », après les changements de contrat (chaque fonction est testée dans le lot qui la réécrit). |

## 2. Contrat cible des primitives (Q1)

### 2.1. `fn::validation_*` — renvoient un résultat, ne lèvent pas pour une donnée invalide

```surql
-- Signature : plus de paramètre $field (il ne servait qu'à fabriquer le code d'erreur)
fn::validation_email($value: any, $max_length: option<int>) -> object

-- Résultat
{
    valid: bool,
    value: any,        -- valeur normalisée si valid = true, NONE sinon
    code: option<string>,  -- NONE si valide, sinon "CORE_VALIDATION_<CAUSE>" (catalogue fermé)
    details: object    -- contexte (longueurs, bornes, motif attendu…), {} si rien
}
```

Utilisation depuis un module (le module choisit **son** code d'erreur, préfixé par le module, et répond selon §5.3) :

```surql
LET $email = fn::validation_email($params.email, 254);
IF !$email.valid {
    RETURN fn::error_result("AUTH_EMAIL_INVALID", $params.language, { reason: $email.code });
};
```

### 2.2. `fn::sanitize_*` — transforment, sans lever pour une donnée

* Entrée `NONE` → renvoie `NONE` (propagation).
* Entrée du bon type → valeur transformée.
* Entrée d'un mauvais type → erreur de programmation (la donnée aurait dû être validée avant) : `THROW "CORE_SANITIZE_INVALID_TYPE"`.

### 2.3. `fn::security_*` et `fn::utils_*`

Même principe : un résultat ou une valeur ; `THROW` uniquement pour un argument invalide.

### 2.4. Erreurs de programmation (`THROW`)

* Codes **fixes**, préfixés `CORE_` (module propriétaire `lyxal_core`, §5.5), en nombre réduit : `CORE_INVALID_ARGUMENT`, `CORE_SANITIZE_INVALID_TYPE`, `CORE_UNSUPPORTED_OPTION`, etc. Plus aucun code construit dynamiquement.
* Leurs définitions master data sont portées par **`lyxal_error`** (propriétaire de la table `error_definition`, qui dépend déjà de `lyxal_core`) dans `crates/lyxal_error/error/core/core_definitions.surql`, au format idempotent `IF !record::exists(...) THEN ( CREATE ... ) END;`. Le Core n'acquiert aucune dépendance.
* Le catalogue des codes de résultat `CORE_VALIDATION_*` est documenté dans `crates/lyxal_core/Readme.md` (ce sont des motifs transmis en `details`, pas des erreurs renvoyées telles quelles par une API).

## 3. Moteur unique (Q2)

* **Constat** (AUDIT.md P1-2) : 245 fonctions de mécanique dans `validations` (99), `sanitize` (71) et `security` (75), mêmes noms et même rôle, corps divergents (similarité 0,49 à 0,74).
* **Cible** : un seul moteur dans `utils` (`fn::utils_engine_*`), bâti sur les primitives de pipeline génériques déjà présentes (`fn::utils_pipeline_chain`, `_map`, `_filter`, `_reduce`…). Chaque domaine ne fournit plus que ses **étapes** (ex. une étape de validation `email`, une étape de sanitize `trim`), appelées par le moteur.
* Les familles `utils_runtime_*` (identifiants, horodatages, informations d'exécution) et `utils_cache_*` sont des primitives génériques déjà uniques : elles restent en place.
* **Point de contrôle CTO** : avant d'écrire le moteur, le lot 4 commence par une **note de conception** ajoutée à ce plan (inventaire famille par famille, tableau des divergences, comportement retenu pour chacune, API cible). Aucune ligne du moteur n'est écrite avant sa validation.

## 4. Suppressions `security` (Q3)

| Fonction supprimée | Raison |
| :--- | :--- |
| `security_encrypt`, `security_encrypt_file`, `security_decrypt` | « Demande » de chiffrement sans consommateur |
| `security_hmac_sign`, `security_hmac_verify` | « Demande » HMAC sans consommateur ; `hmac_verify` évalué comme vrai même avec une signature falsifiée |
| `security_key_generate`, `security_key_derive`, `security_key_wrap`, `security_key_unwrap` | « Demande » de gestion de clés sans consommateur |
| `security_token_sign`, `security_token_verify` | « Demande » de signature / vérification sans consommateur ; même piège de vérification |
| `security_secret_compare` | « Demande » de comparaison à temps constant sans consommateur ; même piège |
| `security_encrypt_string`, `security_encrypt_object` | Emballent `security_encrypt` (supprimée) : même « demande » de chiffrement |
| `security_secret_export`, `security_secret_import` | « Demande » adressée à un « coffre Rust » inexistant (`requires_native_vault`) |
| `security_hash_argon2` | Lève toujours `SECURITY_NATIVE_PASSWORD_HASH_REQUIRED` |
| `security_signature_verify` | Lève toujours `SECURITY_UNSUPPORTED_SIGNATURE_ALGORITHM` |

* Les fonctions qui citent ces 18 fonctions (commentaires, exemples, `*_info`) sont mises à jour.
* **`security_secret_generate`** — vérifié au lot 1 : `rand::id` tire ses caractères de `rand::rng()` (ChaCha12 réensemencé par le système, `surrealdb-runtime` / `surrealdb-expr` 3.3.5), générateur cryptographiquement sûr, **sauf** si le serveur est démarré avec `SURREAL_RAND_SEED` (mode déterministe de test). Fonction conservée, condition inscrite dans son `COMMENT`.

### 4 bis. Suppressions `validations` JSON (décision CTO du lot 3)

| Fonction supprimée | Raison |
| :--- | :--- |
| `validation_json`, `validation_json_string`, `validation_json_array_string`, `validation_json_object_string` | Incompatibles avec le contrat Q1 : `encoding::json::decode` lève une erreur moteur sur un JSON invalide et SurrealDB 3.3.4 n'offre aucun moyen de le détecter sans lever. Le décodage JSON est un parsing, qui reste en Rust (§10) : le code Rust décode avec `serde_json` avant `call_fn`. Une primitive SurrealQL pourra être recréée si un module en exprime le besoin (§5.7.7). |

### 4 ter. Suppressions `validations` en double (décision CTO du lot 3)

| Fonction supprimée | Fonction qui la couvre |
| :--- | :--- |
| `validation_array_not_empty` | `validation_array_non_empty` (même rôle, nommage aligné sur `object_non_empty`) |
| `validation_array_records` | `validation_array_of_records` (ajoute le contrôle d'existence facultatif) |
| `validation_array_strings` | `validation_array_of_strings` (ajoute le nettoyage et les longueurs) |
| `validation_record_type` | `validation_record_id` (accepte une liste de tables) |
| `validation_hash` | `validation_checksum` (mêmes algorithmes, plus crc32) |
| `validation_ipv4`, `validation_ipv6` | `validation_ip` avec la version `"ipv4"` ou `"ipv6"` |
| `validation_job_name`, `validation_transition_name`, `validation_workflow_name`, `validation_workflow_step_name` | `validation_snake_case_name` (nouvelle fonction, même motif snake_case, validée par le CTO) |
| `validation_surql_namespace`, `validation_surql_database`, `validation_surql_table`, `validation_surql_event` | `validation_identifier` (même motif `[A-Za-z_][A-Za-z0-9_]*`, bornes min/max) |

Raison : une responsabilité = un endroit (`.agents/AGENTS.md` §5.1). Aucun appelant.

## 5. Format des tests (Q4)

Format mis en place au lot 2 dans `scripts/ci/test_lyxal_core.py` (auto-testé par `scripts/ci/test_lyxal_core_selftest.py`) :

```surql
-- lyxal-test: assertions

-- test: adresse valide, espaces retirés
RETURN fn::validation_email("  contact@example.com ", 254)
    == { valid: true, value: "contact@example.com", code: NONE, details: {} };

-- test: adresse invalide
RETURN fn::validation_email("pas-un-email", 254).code == "CORE_VALIDATION_EMAIL_FORMAT";

-- test: longueur maximale négative
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_email("contact@example.com", -1);
```

* La ligne `-- lyxal-test: assertions` (dans les 30 premières lignes) fait passer le fichier au nouveau format.
* Chaque bloc `-- test: <description>` contient **exactement une** instruction, exécutée seule. Elle doit renvoyer `true`, ou lever exactement l'erreur annoncée par `-- attendu-erreur: <CODE>`. Tout autre résultat (`false`, une autre valeur, une autre erreur, une erreur non annoncée, plusieurs instructions, une instruction hors bloc, aucun bloc) fait échouer la CI, avec le nom du bloc.
* Les fichiers sans la ligne de format gardent l'ancienne vérification (pas d'erreur moteur inattendue) jusqu'à leur lot ; ce mode disparaît au lot 5.

## 6. Lots d'exécution (une PR par lot, CI verte obligatoire)

| Lot | Contenu | Vérification |
| :- | :--- | :--- |
| 1 | **Nettoyage** : suppression des 18 fonctions (Q3) et décision sur `secret_generate` ; version `0.1.0` + mise à jour des 5 appelants (`manifest.toml` de `lyxal_error`, `lyxal_event`, `lyxal_pipeline_ingestion`, `lyxal_catalogue`, et `lyxal_pipeline_ingestion/src/module.rs`) ; suppression de `CHANGELOG.md` ; `Readme.md` décrivant l'état actuel ; `validations/test/` → `validations/tests/` (et le script de CI) ; chemins des en-têtes de fichiers corrigés (P2-3). Les exemples de commentaires (P2-4) sont réécrits au lot 3, avec le changement de signature de chaque fonction. | `ci_local.sh` vert ; 781 fonctions définies. |
| 2 | **Outillage de tests** : nouveau format (§5) dans `test_lyxal_core.py`, avec ses propres tests (un fichier au nouveau format qui échoue doit faire échouer le script). | Script testé sur des cas qui passent et des cas qui échouent. |
| 3 | **Contrat Q1**, par familles de 40 à 80 fonctions (plusieurs PR) : `validations` (types et chaînes, puis dates et durées, puis tableaux, objets et références), `sanitize`, puis le reste de `security` et `utils`. Suppression de `$field`, nouveau résultat, codes `CORE_*`, exemples de commentaires corrigés (P2-4) ; **tests réécrits dans la même PR** ; master data `CORE_*` dans `lyxal_error` dès la première PR qui en a besoin. | Chaque fonction réécrite a des tests au nouveau format, tous verts. |
| 4 | **Moteur unique Q2** : note de conception (§3) soumise au CTO, puis moteur `fn::utils_engine_*`, migration des étapes de chaque domaine, suppression des copies par domaine ; tests au nouveau format. | Mêmes garanties ; plus aucune famille de mécanique en double. |
| 5 | **Clôture** : plus aucun fichier de test à l'ancien format (le mode « pas d'erreur inattendue » est retiré du script), statistiques du `Readme.md` et des skills mises à jour (le « 799 primitives validées » disparaît), suppression de `AUDIT.md` et de ce plan. | `ci_local.sh` vert ; audit de contrôle (skill `lyxal-audit`) sans écart P0/P1. |

## 7. Fonctions Core, erreurs, crypto

* **Fonctions `lyxal_core` réutilisées** : primitives de pipeline de `utils` comme base du moteur unique (lot 4).
* **Fonctions nouvelles** : `fn::utils_engine_*` (lot 4, API définie dans la note de conception).
* **Codes d'erreur** : codes fixes `CORE_*` pour les erreurs de programmation, définis dans `lyxal_error/error/core/` ; catalogue `CORE_VALIDATION_*` documenté dans le Readme du Core.
* **Crypto** : aucune nouvelle primitive ; suppression des 18 fonctions qui empiétaient sur `lyxal_crypto`.

## 8. Hors périmètre

* L'adoption du Core par les modules existants (`lyxal_error`, `lyxal_event`, `lyxal_pipeline_ingestion`…) : elle se fera à la reprise de chacun.
* Les fonctions SurrealQL des autres modules.

## 9. Checklist §13 (extraits pertinents)

* [x] Responsabilité au bon endroit : la crypto quitte le Core pour rester dans `lyxal_crypto` ; la mécanique n'existe plus qu'une fois.
* [x] Aucune dépendance circulaire : le Core reste sans dépendance ; les définitions `CORE_*` vivent dans `lyxal_error`, qui dépend déjà du Core.
* [x] Codes d'erreur préfixés par le module propriétaire (`CORE_*`), plus aucun code dynamique.
* [x] Zéro dette : `$field`, codes dynamiques, copies de mécanique, `CHANGELOG.md` et documents de reprise supprimés en fin de reprise.
* [ ] Validation explicite du CTO.
