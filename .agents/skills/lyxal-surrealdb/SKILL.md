---
name: lyxal-surrealdb
description: >-
  Use this skill when writing, reviewing, migrating, or testing SurrealQL schemas, functions, events, permissions, transactions, or seeds for Lyxal OS on SurrealDB 3.2.0 and the Rust surrealdb SDK.
---

# Lyxal OS — Ingénierie, Migrations & Sécurité SurrealDB 3.2.0 (`lyxal-surrealdb`)

> **Source normative** : Ce Skill applique les standards SurrealQL définis dans [`.agents/AGENTS.md`](../../AGENTS.md), [`.agents/rules/lyxal_standards_and_checklist.md`](../../rules/lyxal_standards_and_checklist.md) et l'audit architectural [`docs/architecture/AUDIT_SURREALDB_RELATION_TABLES.md`](../../../docs/architecture/AUDIT_SURREALDB_RELATION_TABLES.md).

---

## Quand déclencher ce Skill

Activer ce Skill dès que la tâche implique :
- L'écriture ou la modification de fichiers `.surql` (`schema/`, `functions/`, `events/`, `migrations/`, `error/`, `seeds/`) ;
- L'analyse de compatibilité syntaxique SurrealDB 3.2.0 ou d'interopérabilité avec le crate Rust `surrealdb = "2.2"` (`Surreal<Any>`) ;
- La conception de règles RLS (`PERMISSIONS`), de verrous moteurs (`DEFINE EVENT ... THROW`), de transactions ou de migrations déterministes.

---

## 1. Socle Technique Réel du Dépôt (Vérifié)

1. **Moteur cible de référence** : **SurrealDB 3.2.0** (binaire local [`surreal.exe`](../../../surreal.exe) `3.2.0 for windows on x86_64`, persistant ou mémoire `mem://`).
2. **SDK Rust** : `surrealdb = { version = "2.2", features = ["protocol-ws", "protocol-http", "kv-mem"] }` dans [`Cargo.toml`](../../../Cargo.toml), consommé exclusivement via `Surreal<Any>` et [`lyxal_surreal::LyxalSurrealCall`](../../../lyxal_surreal/src/call.rs).
3. **Bibliothèque standard `lyxal_core` (Couche 0 — 799 primitives validées sur SurrealDB 3.2.0)** :
   - Située dans [`crates/lyxal_core`](../../../crates/lyxal_core) (`339` validations, `170` sanitize, `170` security, `120` utils).
   - Par exception de bibliothèque standard de bas niveau, les primitives pures de `lyxal_core` (`fn::validation_*`, `fn::sanitize_*`, `fn::security_*`, `fn::utils_*`) utilisent des **signatures positionnelles typées** et signalent les violations de contrat par `THROW "<CODE>"`.
4. **Contrats de retour universels des modules métiers et services** (définis dans [`crates/lyxal_error/functions/service/`](../../../crates/lyxal_error/functions/service/)) :
   - Succès : [`fn::result_ok($data)`](../../../crates/lyxal_error/functions/service/result_ok.surql) $\rightarrow$ `{ ok: true, data: $data, error: NONE }`
   - Échec : [`fn::error_result($code, $language, $details)`](../../../crates/lyxal_error/functions/service/error_result.surql) $\rightarrow$ `{ ok: false, data: NONE, error: fn::error_resolve(...) }`
   - **Interdit absolu** : `fn::result_error` n'existe pas et ne doit jamais être utilisé ni créé.

---

## 2. Contrôles de Syntaxe & Compatibilité SurrealQL 3.2.0

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
  - **Interdiction** de convertir une table existante (notamment les 13 tables gelées de `lyxal_catalogue` V1.1 et les 11 tables de `lyxal_pipeline_ingestion` V1.0.0) en `TYPE RELATION`.
  - Toute nouvelle table `TYPE RELATION IN ... OUT ... SCHEMAFULL` requiert une validation formelle préalable du CTO (cf. [`AUDIT_SURREALDB_RELATION_TABLES.md`](../../../docs/architecture/AUDIT_SURREALDB_RELATION_TABLES.md)).
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

### 2.5. Règles Strictes de Compatibilité SurrealDB 3.2.0 (Vérifiées sur `surreal.exe` 3.2.0)
Lors de l'écriture ou de la migration de fichiers `.surql` pour SurrealDB 3.2.0 :
1. **Types & Signatures** :
   - **`option<any>` est interdit** (`Parse error: Unexpected token 'ANY', expected a kind name`) $\rightarrow$ utiliser **`any`** (qui accepte nativement `NONE` et `NULL` tout en préservant `$val IS NONE` et `type::is_null($val)`).
2. **Fonctions Supprimées ou Inexistantes en 3.2.0** :
   - `array::contains($arr, $val)` est supprimé (`Invalid function/constant path`) $\rightarrow$ utiliser l'opérateur natif **`(($arr) CONTAINS ($val))`** ou **`!(($arr) CONTAINS ($val))`**.
   - `time::from::parts(...)` est supprimé $\rightarrow$ construire une chaîne ISO-8601 et la caster via `<datetime>string::concat(...)`.
   - `string::pad(...)`, `encoding::hex::*`, `encoding::uri::*`, `bytes::from_int(...)` n'existent pas $\rightarrow$ utiliser les primitives de `lyxal_core` (`fn::utils_to_hex`, `fn::utils_from_hex`, `fn::utils_encode_uri`, `fn::utils_decode_uri`, `fn::utils_number_format`).
   - `type::thing($tb, $id)` $\rightarrow$ remplacer par `type::record($tb, $id)` ou `<record<table>>$id`.
   - `type::is::*` est supprimé/invalide en 3.2.0 $\rightarrow$ remplacer impérativement par `type::is_*` (ex. `type::is_string`, `type::is_record`, `type::is_datetime`, `type::is_object`) ou par l'opérateur direct `$val IS <type>`.
3. **Sémantique des Tranches (`slice`) et Découpages (`split`) en 3.2.0** :
   - `string::slice($s, $start, $end)` et `array::slice($a, $start, $end)` prennent un **index de fin exclusif `$end`** (et **non** une longueur).
   - `string::split("abc", "")` retourne `["", "a", "b", "c", ""]` (chaînes vides aux deux extrémités).
4. **Portée des Variables (`LET`) et Opérateur d'Égalité en Début de Bloc** :
   - Toute réaffectation sans `LET` (`$x = ...`) échoue au parsing (`Parameter declarations without 'let' are deprecated`), et `LET $x = ...` à l'intérieur d'un bloc `FOR` ou `IF` est **strictement local au bloc** $\rightarrow$ privilégier `array::fold` ou `array::map` pour accumuler un état.
   - Une comparaison `$a = $b` placée en tête d'un bloc `{ $a = $b }` est interprétée comme une affectation sans `LET` $\rightarrow$ utiliser **`==`** (`{ $a == $b }`).
5. **Littéraux de Chaînes, Échappements & Moteur Regex Rust** :
   - Tout antislash d'expression régulière dans un littéral `"..."` doit être doublé (`"\\s+"`, `"\\."`, `"\\p{L}"`, `"\\x00"`, et `"\\\\"` pour un antislash littéral dans une classe `[...]`).
   - Le moteur `regex` Rust de SurrealDB 3.2.0 **ne supporte pas les backreferences** (`\1`, `\2`), et `string::replace($s, <regex>..., "$1")` n'expanse pas les groupes capturants `$1`.
6. **Import CLI (`surreal.exe import`)** :
   - En SurrealDB 3.2.0, tout fichier importé via `surreal.exe import` doit débuter par l'instruction `OPTION IMPORT;`.
7. **Signatures Runtime de la Bibliothèque Standard SurrealDB 3.2.0 (Vérifiées en Lot 4)** :
   - `array::reduce($arr, $fn)` prend **uniquement 2 arguments** en 3.2.0 (sans valeur initiale). Dès qu'un accumulateur initial `$init` est requis, utiliser **`array::fold($arr, $init, |$acc, $x| ...)`**.
   - `array::sort::asc($arr)` et `array::sort::desc($arr)` prennent **uniquement 1 argument** en 3.2.0 (pas de second argument de champ `$field`). Pour trier un tableau d'objets par clé, utiliser `fn::utils_collection_sort_by($arr, $field, $direction)`.
   - `math::min($arr)` et `math::max($arr)` n'acceptent que `array<number>` et rejettent `array<duration>`. En outre, le type `duration` est **non signé** en 3.2.0 (`-1ms` est rejeté et `$a - $b` échoue à l'exécution si `$a < $b` $\rightarrow$ comparer `$a >= $b` avant soustraction).
   - `math::log($x, $base)` requiert **obligatoirement 2 arguments** (`float`, `float`) en 3.2.0.
   - `encoding::base64::encode($bytes)` requiert un argument de type **`bytes`** (`<bytes>$str`) et retourne un base64 sans padding `=` en 3.2.0.
   - `$token` est une **variable système protégée** en 3.2.0 (`'token' is a protected variable and cannot be set`) : ne jamais nommer une variable locale `LET $token = ...`.
   - Un intervalle `0..$n` doit être explicitement converti en tableau via **`<array>(0..$n)`** avant d'être passé à `array::all`, `array::fold` ou `array::map`.

---

## 3. Migrations, Seeds & Prévention de Perte de Données

1. **Immuabilité des Migrations (`migrations/XXXX_nom.surql`)** :
   - Le moteur [`MigrationRunner`](../../../crates/lyxal_runtime/src/migration/runner.rs) de `lyxal_runtime` calcule et vérifie un `MigrationChecksum` sur chaque fichier de migration.
   - **Règle absolue** : Ne jamais modifier un fichier de migration déjà appliqué ou gelé. Toute évolution passe par un nouveau fichier incrémental (`0002_...surql`).
   - Interdiction formelle des instructions destructives (`REMOVE TABLE`, `REMOVE FIELD`, `DELETE` non borné) sans plan de migration validé par le CTO.
2. **Idempotence Non Destructive des Seeds & Erreurs (`seeds/*.surql`, `error/**/*.surql`)** :
   - Ne jamais écraser ni supprimer des données existantes ou personnalisées lors de la réexécution d'un seed.
   - Standard recommandé (modèle [`crates/lyxal_pipeline_ingestion/error/ingestion/error_definitions.surql`](../../../crates/lyxal_pipeline_ingestion/error/ingestion/error_definitions.surql)) :
     ```surql
     IF !record::exists(error_definition:<CODE>) THEN (
         CREATE error_definition:<CODE> CONTENT {
             code: "<CODE>",
             ...
         }
     ) END;
     ```

---

## 4. Protocole de Test Reproductible SurrealDB 3.2.0

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
   - **Cas de sécurité RLS / Guard** : Tentative d'accès inter-tenant (`tenant_id` tiers) ou d'écriture non autorisée rejetée par les permissions ou le verrou `DEFINE EVENT`.

