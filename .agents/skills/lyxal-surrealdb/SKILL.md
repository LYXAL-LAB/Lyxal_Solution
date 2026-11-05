---
name: lyxal-surrealdb
description: >-
  Use this skill when writing, reviewing, migrating, or testing SurrealQL schemas, functions, events, permissions, transactions, or seeds for Lyxal OS on SurrealDB 3.3.4 and the Rust surrealdb SDK.
---

# Lyxal OS — Ingénierie, Migrations & Sécurité SurrealDB 3.3.4 (`lyxal-surrealdb`)

> **Source normative** : Ce Skill applique les standards SurrealQL définis dans [`.agents/AGENTS.md`](../../AGENTS.md), [`.agents/rules/lyxal_standards_and_checklist.md`](../../rules/lyxal_standards_and_checklist.md) et l'audit architectural [`docs/01-architecture/AUDIT_SURREALDB_RELATION_TABLES.md`](../../../docs/01-architecture/AUDIT_SURREALDB_RELATION_TABLES.md).

---

## Quand déclencher ce Skill

Activer ce Skill dès que la tâche implique :
- L'écriture ou la modification de fichiers `.surql` (`schema/`, `functions/`, `events/`, `migrations/`, `error/`, `seeds/`) ;
- L'analyse de compatibilité syntaxique SurrealDB 3.3.4 ou d'interopérabilité avec le crate Rust `surrealdb` 3.3 (`Surreal<Any>`, trait `SurrealValue`) ;
- La conception de règles RLS (`PERMISSIONS`), de verrous moteurs (`DEFINE EVENT ... THROW`), de transactions ou de migrations déterministes.

---

## 1. Socle Technique Réel du Dépôt (Vérifié)

1. **Moteur cible de référence** : **SurrealDB 3.3.4** (binaire `surreal` 3.3.4, non versionné dans le dépôt : chemin fourni par la variable d'environnement `LYXAL_SURREAL_BIN`, à défaut `surreal` dans le `PATH` ; `surreal.exe` sous Windows ; persistant ou mémoire `mem://`).
2. **SDK Rust** : `surrealdb = { version = "3.3", features = ["protocol-ws", "protocol-http", "kv-mem"] }` et `surrealdb-types = "3.3"` dans [`Cargo.toml`](../../../Cargo.toml), consommé exclusivement via `Surreal<Any>` et [`lyxal_surreal::LyxalSurrealCall`](../../../crates/lyxal_surreal/src/call.rs). Le moteur embarqué des tests (`mem://`) est donc un moteur 3.3.x : un test `cargo test` exécute réellement le SurrealQL en 3.3. Les types natifs (`Datetime`, `RecordId`, `SurrealValue`, `ToSql`, `Value`) sont ré-exportés par `lyxal_surreal`.
3. **Bibliothèque standard `lyxal_core` (Couche 0 — 480 primitives, contrat complet : `crates/lyxal_core/Readme.md`)** :
   - Située dans [`crates/lyxal_core`](../../../crates/lyxal_core) (`195` validations, `97` sanitize, `71` security, `117` utils). Toutes passent `surreal validate` en 3.3.4 ; leurs valeurs sont vérifiées par des tests au format « assertions » (`crates/lyxal_core/Readme.md`, section « Tests »).
   - Par exception de bibliothèque standard de bas niveau, les primitives pures de `lyxal_core` (`fn::validation_*`, `fn::sanitize_*`, `fn::security_*`, `fn::utils_*`) utilisent des **signatures positionnelles typées**. Une validation renvoie `{ valid, value, code, details }` sans lever pour une donnée invalide ; seul un argument invalide du code appelant lève un code fixe (`CORE_INVALID_ARGUMENT`, `CORE_UNSUPPORTED_OPTION`, `CORE_SANITIZE_INVALID_TYPE`). Les pipelines passent par le moteur unique `fn::utils_engine_*`.
4. **Contrats de retour universels des modules métiers et services** (définis dans [`crates/lyxal_error/functions/service/`](../../../crates/lyxal_error/functions/service/)) :
   - Succès : [`fn::result_ok($data)`](../../../crates/lyxal_error/functions/service/result_ok.surql) $\rightarrow$ `{ ok: true, data: $data, error: NONE }`
   - Échec : [`fn::error_result($code, $language, $details)`](../../../crates/lyxal_error/functions/service/error_result.surql) $\rightarrow$ `{ ok: false, data: NONE, error: fn::error_resolve(...) }`
   - **Interdit absolu** : `fn::result_error` n'existe pas et ne doit jamais être utilisé ni créé.

---

## 2. Contrôles de Syntaxe & Compatibilité SurrealQL 3.3.4

Avant d'écrire ou de recommander une construction SurrealQL, appliquer ces règles vérifiées sur les modules de référence ([`lyxal_error`](../../../crates/lyxal_error), [`lyxal_catalogue`](../../../crates/lyxal_catalogue) et [`lyxal_pipeline_ingestion`](../../../crates/lyxal_pipeline_ingestion)) :

### 2.1. Tables & Relations (`schema/*.surql`)
- **Déclaration standard** :
  ```surql
  DEFINE TABLE OVERWRITE <module>_<entite>
      TYPE NORMAL
      SCHEMAFULL
      PERMISSIONS
          FOR select WHERE ...
          FOR create WHERE ...
          FOR update WHERE ...
          FOR delete WHERE ...
      COMMENT "...";
  ```
- **`TYPE NORMAL` vs `TYPE RELATION`** :
  - Toujours utiliser `TYPE NORMAL` avec des champs `TYPE record<cible> REFERENCE` par défaut.
  - **Interdiction** de convertir une table existante (notamment les 13 tables de `lyxal_catalogue` et les 11 tables de `lyxal_pipeline_ingestion`) en `TYPE RELATION`.
  - Toute nouvelle table `TYPE RELATION IN ... OUT ... SCHEMAFULL` requiert une validation formelle préalable du CTO (cf. [`AUDIT_SURREALDB_RELATION_TABLES.md`](../../../docs/01-architecture/AUDIT_SURREALDB_RELATION_TABLES.md)).
- **Champs optionnels et tableaux typés** :
  - Utiliser `TYPE option<string>`, `TYPE option<decimal>`, `TYPE option<datetime>`, `TYPE option<record<...>>`.
  - Pour les tableaux d'objets structurés, déclarer à la fois `DEFINE FIELD OVERWRITE items ON TABLE ... TYPE option<array<object>> DEFAULT [];`, `DEFINE FIELD OVERWRITE items[*] ON TABLE ... TYPE object;` et chaque sous-champ `items[*].champ`.
  - Pour les objets extensibles contrôlés : `TYPE object FLEXIBLE DEFAULT {}`.

### 2.2. Permissions RLS & Isolation Multi-Tenant
- Supporter systématiquement la double résolution d'identité dans les clauses `PERMISSIONS` et dans les fonctions :
  - Jeton JWT / Token (`$token != NONE AND $token.role = ... AND $token.tenant_id = ...`) ;
  - Session Record Auth (`$token == NONE AND $auth != NONE AND $auth.role = ... AND $auth.tenant_id = ...`).
- Protéger les champs d'audit et de propriété contre toute altération après création :
  - `tenant_id` : `READONLY`, vérifié à la création et verrouillé contre toute mutation (`$after.tenant_id != $before.tenant_id` $\rightarrow$ `THROW`).
  - `created_at` : `TYPE datetime DEFAULT time::now() READONLY`.
  - `updated_at` : `TYPE datetime VALUE time::now()`.

### 2.3. Fonctions Métier (`functions/**/*.surql`)
- Signature unique : `DEFINE FUNCTION OVERWRITE fn::<module>_<action>($params: object) { ... } COMMENT "...";`.
- Cast explicite et sécurisé des identifiants d'enregistrement :
  - `LET $id = <record<table_cible>> $params.id;`
  - Lecture unitaire directe : `LET $rec = (SELECT * FROM ONLY $id);`
- Vérification d'existence avant création pour retourner une erreur métier déterministe (`fn::error_result("<MODULE>_..._ALREADY_EXISTS", $language, {...})`) au lieu de laisser échouer un index unique brut.

### 2.4. Verrous Moteurs (`DEFINE EVENT ... Guard`) vs Événements Métier (`lyxal_event`)
Distinguer strictement deux usages de `DEFINE EVENT` dans Lyxal OS :
1. **Gardien d'intégrité local sur la table même** (ex. [`evt_catalogue_item_guard`](../../../crates/lyxal_catalogue/schema/02_catalogue_item.surql#L296-L453)) :
   - Valide les invariants critiques sur `$before` / `$after` et lève `THROW "<CODE>: ..."` pour annuler la transaction en cas de violation directe hors fonction.
   - Ne modifie jamais la table d'un autre module.
2. **Publication d'événement de domaine asynchrone** (ex. [`events/01_events.surql`](../../../crates/lyxal_pipeline_ingestion/events/01_events.surql)) :
   - Appelle exclusivement `fn::event_publish({ event_id: rand::uuid::v7(), event_type: "<module>.<entite>.<action>", producer: "lyxal_<module>", payload: {...}, metadata: {...} })`.

### 2.5. Règles Strictes de Compatibilité SurrealDB 3.3.4 (Vérifiées sur le binaire `surreal` 3.3.4 ; établies initialement sur 3.2.0)
Lors de l'écriture ou de la migration de fichiers `.surql` pour SurrealDB 3.3.4 :
1. **Types & Signatures** :
   - **`option<any>` est interdit** (`Parse error: Unexpected token 'ANY', expected a kind name`) $\rightarrow$ utiliser **`any`** (qui accepte nativement `NONE` et `NULL` tout en préservant `$val IS NONE` et `type::is_null($val)`).
2. **Fonctions Supprimées ou Inexistantes en 3.3.4** :
   - `array::contains($arr, $val)` est supprimé (`Invalid function/constant path`) $\rightarrow$ utiliser l'opérateur natif **`(($arr) CONTAINS ($val))`** ou **`!(($arr) CONTAINS ($val))`**.
   - `time::from::parts(...)` est supprimé $\rightarrow$ construire une chaîne ISO-8601 et la caster via `<datetime>string::concat(...)`.
   - `string::pad(...)`, `encoding::hex::*`, `encoding::uri::*`, `bytes::from_int(...)` n'existent pas $\rightarrow$ utiliser les primitives de `lyxal_core` (`fn::utils_to_hex`, `fn::utils_from_hex`, `fn::utils_encode_uri`, `fn::utils_decode_uri`, `fn::utils_string_pad_center`, `fn::utils_number_format`).
   - `type::thing($tb, $id)` $\rightarrow$ remplacer par `type::record($tb, $id)` ou `<record<table>>$id`.
   - `type::is::*` est supprimé/invalide en 3.3.4 $\rightarrow$ remplacer impérativement par `type::is_*` (ex. `type::is_string`, `type::is_record`, `type::is_datetime`, `type::is_object`) ou par l'opérateur direct `$val IS <type>`.
3. **Sémantique des Tranches (`slice`) et Découpages (`split`) en 3.3.4** :
   - `string::slice($s, $start, $end)` et `array::slice($a, $start, $end)` prennent un **index de fin exclusif `$end`** (et **non** une longueur).
   - `string::split("abc", "")` retourne `["", "a", "b", "c", ""]` (chaînes vides aux deux extrémités).
4. **Portée des Variables (`LET`) et Opérateur d'Égalité en Début de Bloc** :
   - Toute réaffectation sans `LET` (`$x = ...`) échoue au parsing (`Parameter declarations without 'let' are deprecated`), et `LET $x = ...` à l'intérieur d'un bloc `FOR` ou `IF` est **strictement local au bloc** $\rightarrow$ privilégier `array::fold` ou `array::map` pour accumuler un état.
   - Une comparaison `$a = $b` placée en tête d'un bloc `{ $a = $b }` est interprétée comme une affectation sans `LET` $\rightarrow$ utiliser **`==`** (`{ $a == $b }`).
5. **Littéraux de Chaînes, Échappements & Moteur Regex Rust** :
   - Tout antislash d'expression régulière dans un littéral `"..."` doit être doublé (`"\\s+"`, `"\\."`, `"\\p{L}"`, `"\\x00"`, et `"\\\\"` pour un antislash littéral dans une classe `[...]`).
   - Le moteur `regex` Rust de SurrealDB 3.3.4 **ne supporte pas les backreferences** (`\1`, `\2`), et `string::replace($s, <regex>..., "$1")` n'expanse pas les groupes capturants `$1`.
6. **Import CLI (`surreal import`)** :
   - En SurrealDB 3.3.4, tout fichier importé via `surreal import` doit débuter par l'instruction `OPTION IMPORT;`.
7. **Signatures Runtime de la Bibliothèque Standard SurrealDB 3.3.4 (Vérifiées en Lot 4 sur 3.2.0, revérifiées sur 3.3.4)** :
   - `array::reduce($arr, $fn)` prend **uniquement 2 arguments** en 3.3.4 (sans valeur initiale). Dès qu'un accumulateur initial `$init` est requis, utiliser **`array::fold($arr, $init, |$acc, $x| ...)`**.
   - `array::sort::asc($arr)` et `array::sort::desc($arr)` prennent **uniquement 1 argument** en 3.3.4 (pas de second argument de champ `$field`). Pour trier un tableau d'objets par clé, utiliser `fn::utils_collection_sort_by($arr, $field, $direction)`.
   - `math::min($arr)` et `math::max($arr)` n'acceptent que `array<number>` et rejettent `array<duration>`. En outre, le type `duration` est **non signé** en 3.3.4 (`-1ms` est rejeté et `$a - $b` échoue à l'exécution si `$a < $b` $\rightarrow$ comparer `$a >= $b` avant soustraction).
   - `math::log($x, $base)` requiert **obligatoirement 2 arguments** (`float`, `float`) en 3.3.4.
   - `encoding::base64::encode($bytes)` requiert un argument de type **`bytes`** (`<bytes>$str`) et retourne un base64 sans padding `=` en 3.3.4.
   - `$token` est une **variable système protégée** en 3.3.4 (`'token' is a protected variable and cannot be set`) : ne jamais nommer une variable locale `LET $token = ...`.
   - Un intervalle `0..$n` doit être explicitement converti en tableau via **`<array>(0..$n)`** avant d'être passé à `array::all`, `array::fold` ou `array::map`.
8. **Indexation `UNIQUE` et Valeurs `NONE` / `NULL` en 3.3.4** :
   - **Changement de comportement par rapport à 3.2.0** : sur SurrealDB 3.3.4, un index `UNIQUE` (simple ou composite, ex: `DEFINE INDEX idx ON TABLE delivery FIELDS subscription, delivery_seq UNIQUE`) **n'entre plus en conflit** lorsque plusieurs enregistrements ont `delivery_seq = NONE` ou `NULL` ; seules les valeurs renseignées identiques lèvent `Database index ... already contains ...`. En 3.2.0, ces valeurs `NONE` levaient une violation `IndexExists`.
   - Les index non-uniques existants (`DEFINE INDEX ... FIELDS sub, seq`) et la garantie d'unicité par fonction transactionnelle atomique (ex: `fn::event_delivery_assign_seq` avec compteur incrémenté sur `event_subscription_progress`) **restent la norme** : ils sont corrects en 3.3.4 et ne doivent pas être convertis en `UNIQUE` sans `implementation_plan.md` validé par le CTO.


### 2.6. Contrat Rust ↔ SurrealDB avec le SDK 3.3 (constaté lors de la migration 2.x → 3.3)
1. **`SurrealValue` remplace `serde`** pour tout ce qui traverse la frontière base de données (`bind`, `take`, `call_fn`) : `#[derive(SurrealValue)]` sur les `XxxParams` / `XxxResult` / lignes de persistance. `serde` ne reste que pour les types aussi exposés en JSON (API HTTP, payloads d'événements). Un type peut dériver les deux. Hors du SDK (crate dépendant seulement de `surrealdb-types`), préciser `#[surreal(crate = "surrealdb_types")]`. Un générique doit porter la contrainte sur la structure (`struct LyxalResult<T: SurrealValue>`).
2. **Attributs** : `#[surreal(default)]`, `#[surreal(default = "fn")]`, `#[surreal(rename_all = "...")]`. Pas d'`alias` ni de `with` (et aucun alias de compatibilité en régime pré-production).
3. **Énumérations unitaires** : par défaut le derive encode `Pending` en `{pending: {}}`. Pour stocker une chaîne (`'pending'`), utiliser `#[surreal(untagged, rename_all = "snake_case")]` (ou la casse voulue).
4. **`NONE` ≠ `NULL`** : un `Option<T>` accepte `NONE` et **refuse `NULL`**. Les contrats `fn::result_ok` / `fn::error_result` renvoient `NONE`. Ne jamais passer une structure par `serde_json::to_value(...)` avant de l'envoyer : un champ vide deviendrait `NULL`. Transmettre le type natif.
5. **Types stricts** : un champ `datetime` se lit en `Datetime` (plus de conversion implicite vers `String`) ; un champ `TYPE string` refuse un `uuid` natif — en 3.x, `rand::uuid::v7()` renvoie un `uuid` : le convertir (`<string> rand::uuid::v7()`) s'il est stocké en chaîne. Une table `SCHEMAFULL` **refuse** un champ non déclaré (la 2.x l'ignorait) : déclarer tout champ écrit par le code.
6. **`RecordId`** : plus de `Display` ni de `FromStr`. Texte : `id.to_sql()` (trait `ToSql`) ; construction : `RecordId::new(table, key)` ou `RecordId::parse_simple("table:key")`.
7. **Table absente** : `SELECT` ou `select()` sur une table qui n'existe pas encore renvoie une **erreur** (la 2.x renvoyait une liste vide).
8. **Erreurs typées, jamais par texte** : `err.is_not_found()`, `err.is_already_exists()`, `err.is_validation()`, etc. Ne jamais classer une erreur en cherchant un mot dans son message.
9. **Zéro erreur masquée** : jamais `take(0).unwrap_or_default()` ni `.ok()` sur une lecture ; toute réponse multi-instructions (transaction) est vérifiée par `response.check()`.

---

## 3. Migrations, Seeds & Prévention de Perte de Données

0. **Régime pré-production en vigueur ([`AGENTS.md` §0](../../AGENTS.md))** : tant que le CTO n'a pas déclaré la première mise en production, chaque module n'a **qu'un seul fichier** `migrations/0001_initial.surql`, qui décrit le schéma cible et **est réécrit en place**. Pas de `0002_...` correctif. Les bases de développement sont recréées à partir de zéro. Les instructions destructives ne sont pas nécessaires et restent interdites dans les migrations. La règle 1 ci-dessous ne s'applique qu'après la mise en production.
1. **Immuabilité des Migrations (`migrations/XXXX_nom.surql`)** — *après mise en production* :
   - Le moteur [`MigrationRunner`](../../../crates/lyxal_runtime/src/migration/runner.rs) de `lyxal_runtime` calcule et vérifie un `MigrationChecksum` sur chaque fichier de migration.
   - **Règle absolue** : Ne jamais modifier un fichier de migration déjà appliqué ou gelé. Toute évolution passe par un nouveau fichier incrémental (`0002_...surql`).
   - Interdiction formelle des instructions destructives (`REMOVE TABLE`, `REMOVE FIELD`, `DELETE` non borné) sans plan de migration validé par le CTO.
2. **Idempotence Non Destructive des Seeds & Erreurs (`seeds/*.surql`, `error/**/*.surql`)** :
   - Ne jamais écraser ni supprimer des données existantes ou personnalisées lors de la réexécution d'un seed.
   - Standard recommandé (modèle [`crates/lyxal_pipeline_ingestion/error/lots/error_lots.surql`](../../../crates/lyxal_pipeline_ingestion/error/lots/error_lots.surql)) :
     ```surql
     IF !record::exists(error_definition:<CODE>) THEN (
         CREATE error_definition:<CODE> CONTENT {
             code: "<CODE>",
             ...
         }
     ) END;
     ```

---

## 4. Protocole de Test Reproductible SurrealDB 3.3.4

Outillage versionné dans `scripts/ci/` : `install_surreal.sh` (binaire 3.3.4 exact), `validate_surql.sh` (`surreal validate` de tout le workspace), `test_lyxal_core.py` (suite `lyxal_core`), `test_lyxal_modules.py` (tests `tests/*.test.surql` de chaque module, installé depuis son manifeste dans une base neuve, blocs exécutés sous des identités JWT simulées : `-- identité <nom>: {claims}`, `-- en tant que: <nom>`, `-- préparation:` ; format en tête du script, exemple : `crates/lyxal_catalogue/tests/`), `test_all.sh` (tests Rust + serveurs de test), `ci_local.sh` (tout, comme la CI).

Pour valider un schéma, une fonction ou une migration :

1. **Ordre de chargement strict** (reproduisant `SchemaImporter` de `lyxal_runtime`) :
   - Fondations requises (`lyxal_core`, `lyxal_error/schema/*.surql`, `lyxal_error/functions/service/*.surql`, `lyxal_base/schema/*.surql`) ;
   - Schémas du module (`schema/00_...surql` $\rightarrow$ `schema/NN_...surql`) ;
   - Définitions d'erreurs et seeds (`error/**/*.surql`, `seeds/*.surql`) ;
   - Fonctions (`functions/**/*.surql`) et événements (`events/*.surql`).
2. **Matrice minimale de tests à fournir** :
   - **Cas nominal** : Vérification que la fonction retourne `{ ok: true, data: ..., error: NONE }`.
   - **Cas d'erreurs métier** : Vérification que chaque validation retourne `{ ok: false, data: NONE, error: { code: "<MODULE>_...", ... } }`.
   - **Cas d'idempotence & unicité** : Double appel ou double exécution des seeds sans erreur ni doublon.
   - **Cas de sécurité RLS / Guard** : Tentative d'accès inter-tenant (`tenant_id` tiers) ou d'écriture non autorisée rejetée par les permissions ou le verrou `DEFINE EVENT`. Une écriture filtrée par les permissions ne lève pas d'erreur (`CREATE` → `[]`, `UPDATE ONLY` / `DELETE ONLY` → `NONE`) : la fonction doit renvoyer `<MODULE>_WRITE_FORBIDDEN`, et le test le vérifie sous une session d'utilisateur d'enregistrement (claim `id`), seule session où les permissions de table s'appliquent.
   - **Comptage** : `count(SELECT ...)`, jamais `(SELECT count() ...)[0].count` (vaut `NONE` sans ligne).

