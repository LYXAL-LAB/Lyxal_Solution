---
name: lyxal-audit
description: >-
  Use this skill when the user asks to audit, review, or verify the architectural, Rust, SurrealQL, DTO mapping, SurrealDB 3.2.0 compatibility, cryptographic, runtime, or security compliance of one or more Lyxal OS modules against the CTO governance rules.
---

# Lyxal OS — Audit de Conformité & Preuves Vérifiables (`lyxal-audit`)

> **Source normative** : Cet audit évalue un module par rapport aux règles impératives définies dans [`.agents/AGENTS.md`](../../AGENTS.md) et [`.agents/rules/lyxal_standards_and_checklist.md`](../../rules/lyxal_standards_and_checklist.md). Ne pas dupliquer le texte de ces règles dans le rapport : les citer par section et produire la preuve sur le code réel.
> **Règle d'intégrité** : Un audit s'exécute en **lecture seule stricte**. Ne jamais déclarer un module « conforme » ou « production-ready » sans preuves vérifiables (fichiers, numéros de lignes et résultats de contrôles réellement exécutés).

---

## Quand déclencher ce Skill

Activer ce Skill dès que l'utilisateur demande :
- Un audit de conformité d'un module existant ou nouvellement créé (`crates/lyxal_*`, `lyxal_surreal`, `apps/lyxal-server`) ;
- Une revue de code, de DTOs ou de schémas avant validation CTO ou passage en staging/production ;
- La vérification de la Checklist Obligatoire Antigravity (Section 13 de [`.agents/rules/lyxal_standards_and_checklist.md`](../../rules/lyxal_standards_and_checklist.md)).

---

## Matrice de Sévérité des Écarts

| Niveau | Définition | Exemples |
| :--- | :--- | :--- |
| **P0 — Bloquant Critique** | Violation directe d'une règle d'inviolabilité, de sécurité, de cryptographie, de contrat d'API ou d'intégrité des données. Interdit toute validation. | Usage de `fn::result_error`, import direct d'une crate crypto (`sha2`, `blake3`, `argon2`, `hmac`, `aes-gcm`, `hkdf`) dans un module métier, `rand::thread_rng()`, `panic!` dans le transport, `raw_query()` public ou métier, masquage silencieux d'erreur (`unwrap_or_default` / `None` sur erreur DB), absence de `PERMISSIONS` ou faille d'isolation `tenant_id`, couplage direct entre deux modules métiers. |
| **P1 — Majeur** | Écart structurel, contractuel ou de compatibilité dégradant la maintenabilité, l'exécution runtime, l'idempotence ou la compatibilité SurrealDB 3.2.0. | Divergence de champ entre DTO Rust `*Params` et `$params.<champ>` SurrealQL, construction SurrealQL dépréciée/incompatible 3.2.0 (`type::thing(`, `type::is::`), signature SurrealQL métier sans `$params: object` unique, fonction > 300 lignes, `manifest.toml` désynchronisé des fichiers réels sur disque, seed `CREATE` non idempotent ou destructif, tuple anonyme dans un contrat Rust public, worker avec `tokio::spawn` sauvage hors `LyxalWorker` / `CancellationToken`, handler `lyxal_event` non idempotent. |
| **P2 — Mineur / Qualité** | Manquement documentaire ou cosmétique sans impact fonctionnel immédiat. | Absence de `COMMENT "..."` en SurrealQL ou `///` sur un type Rust public, nommage d'index non standardisé, couverture de cas limites incomplète dans les tests. |

---

## Procédure d'Audit Obligatoire (8 Contrôles)

> **Distinction Normative** : Les points marqués **[OBLIGATOIRE]** conditionnent le verdict de conformité. Les points marqués **[RECOMMANDATION]** relèvent de l'amélioration continue (P2) et ne bloquent pas un jalon s'ils sont isolés.

### Contrôle 1 — Conformité Structurelle & `manifest.toml` [OBLIGATOIRE]
1. Lire `<module>/manifest.toml` et vérifier sa conformité avec [`crates/lyxal_runtime/src/manifest/model.rs`](../../../crates/lyxal_runtime/src/manifest/model.rs) (`manifest_version = 1`, `id`, `name`, `version`, `[runtime]`, `[[dependencies]]`, `capabilities`, `[resources]`).
2. Vérifier que **chaque fichier** listé dans `[resources]` (`schemas`, `migrations`, `functions`, `events`, `seeds`, `error_definitions`) existe réellement sur disque, et qu'aucun fichier `.surql` du module n'a été oublié dans `manifest.toml`.
3. Vérifier l'absence de dépendance circulaire dans `Cargo.toml` et `manifest.toml`.

### Contrôle 2 — Exceptions Architecturales des Crates de Fondation [OBLIGATOIRE]
Avant d'exiger l'implémentation de `LyxalModule` ou `LyxalSurrealCall`, situer le crate audité dans le graphe DAG des dépendances ([`.agents/AGENTS.md` §5.2 & §6](../../AGENTS.md)) :
1. **Inspection préalable du graphe Cargo** :
   - Examiner `Cargo.toml` du crate audité et de ses dépendants (`lyxal_error` $\leftarrow$ `lyxal_surreal` / `lyxal_crypto` $\leftarrow$ `lyxal_event` / `lyxal_runtime` $\leftarrow$ modules métiers).
   - **Interdiction absolue** de recommander l'ajout d'une dépendance vers `lyxal_runtime` ou `lyxal_surreal` dans un crate de fondation situé en dessous d'eux (`lyxal_error`, `lyxal_crypto`, `lyxal_surreal`), car cela créerait une dépendance circulaire (**P0**).
2. **Conventions spécifiques des crates de fondation** :
   - **`lyxal_error`** : crate racine de contrat d'erreur (`LyxalResult<T>`, `LyxalErrorPayload`) sans dépendance vers `lyxal_surreal` ni `lyxal_runtime`. Il expose ses constantes de requêtes (`FN_*_QUERY`) et ses structures DTO (`*Params`), consommées par `lyxal_surreal::LyxalSurrealCall` dans les couches supérieures.
   - **`lyxal_surreal`** : propriétaire unique de `Surreal<Any>` et du trait [`LyxalSurrealCall`](../../../lyxal_surreal/src/call.rs) (`call_fn`). C'est le seul crate autorisé à encapsuler `.query("RETURN fn::...($params)").bind(("params", params)).take(0)`.
   - **`lyxal_crypto`** : fondation cryptographique pure en mémoire (contrat figé [`API_CONTRACT.md`](../../../crates/lyxal_crypto/API_CONTRACT.md)), sans accès base de données (`Surreal<Any>`) ni dépendance `lyxal_runtime`.
3. **Signatures positionnelles contractuelles de `lyxal_core` et du noyau d'erreur** :
   - Reconnaître comme conformes par contrat architectural :
     - Les **799 primitives pures de `crates/lyxal_core`** (`fn::validation_*`, `fn::sanitize_*`, `fn::security_*`, `fn::utils_*`), qui constituent la bibliothèque standard SurrealQL de Couche 0 et utilisent des signatures positionnelles typées + `THROW "<CODE>"` ;
     - Les **3 fonctions positionnelles universelles du noyau d'erreur** appelées au cœur des expressions SurrealQL de toute la suite :
       - `fn::result_ok($data: any) -> object`
       - `fn::error_result($code: string, $language: option<string>, $details: option<object>) -> object`
       - `fn::error_resolve($code: string, $language: option<string>, $details: option<object>) -> object`
   - Toutes les **autres** fonctions publiques d'un module (y compris les fonctions CRUD et statistiques de `lyxal_error` telles que `fn::error_definition_*`, `fn::error_mapping_*`, `fn::error_statistics_*`) restent soumises à la signature stricte `$params: object` unique.
4. **Non-exemption des règles de sécurité et de qualité** :
   - Ces exceptions de topologie DAG ne dispensent **jamais** un crate de fondation des contrôles sur les erreurs silencieuses, l'absence de `panic!`/`.unwrap()` en production, la correspondance exacte DTO $\leftrightarrow$ SurrealQL, la compatibilité SurrealDB 3.2.0, l'idempotence des seeds ou les permissions SurrealQL.

### Contrôle 3 — Conformité SurrealQL (`schema/`, `functions/`, `events/`, `error/`, `seeds/`) [OBLIGATOIRE]
Inspecter les fichiers `.surql` du module pour contrôler :
1. **Interdiction absolue de `fn::result_error`** : rechercher toute occurrence de `result_error` (violation **P0** — seul `fn::error_result($code, $language, $details)` est autorisé).
2. **Signatures & Contrats des fonctions publiques** :
   - `DEFINE FUNCTION OVERWRITE fn::<module>_<action>($params: object)` (hors les 3 primitives positionnelles du Contrôle 2.3) ;
   - Retour exclusif via `fn::result_ok(...)` ou `fn::error_result(...)` ;
   - Présence de `COMMENT "..."` en fin de fonction [RECOMMANDATION P2 si manquant isolément, OBLIGATOIRE avant gel d'API] ;
   - Longueur $\le 300$ lignes par fonction.
3. **Schémas & Sécurité RLS** :
   - `DEFINE TABLE OVERWRITE <module>_<table_name> TYPE NORMAL SCHEMAFULL PERMISSIONS ... COMMENT "..."` ;
   - Vérification que toute table `TYPE RELATION` éventuelle a fait l'objet d'une validation CTO explicite (cf. [`AUDIT_SURREALDB_RELATION_TABLES.md`](../../../docs/architecture/AUDIT_SURREALDB_RELATION_TABLES.md)) ;
   - Vérification des permissions (`$token` / `$auth`, isolation stricte de `tenant_id`, verrous `DEFINE EVENT ... Guard` sur les tables critiques).
4. **Événements (`events/*.surql`)** :
   - Les `DEFINE EVENT` de publication passent exclusivement par `fn::event_publish({...})` sans effet de bord direct sur un autre module.
5. **Master Data d'Erreurs & Seeds** :
   - Utilisation exclusive de `CREATE` ;
   - Idempotence des seeds au rejeu (protection `IF !record::exists(...) THEN { CREATE ... } END;` ou contrôle préalable d'existence) ;
   - Préfixe strict `<MODULE>_*` sur tous les codes d'erreurs ;
   - Vérification que chaque code passé à `fn::error_result("<CODE>", ...)` dans `functions/` possède bien sa définition dans `error/` ou `seeds/error_definitions.surql`.

### Contrôle 4 — Vérification Croisée DTO Rust $\leftrightarrow$ SurrealQL (`*Params` vs `$params`) [OBLIGATOIRE]
Pour **chaque** fonction SurrealQL prenant `$params: object` et possédant une structure Rust d'entrée (`*Params`) :
1. **Identification du couple** : associer `fn::<module>_<action>($params: object)` à sa structure Rust `*Params` (et sa constante `FN_*_QUERY` ou son wrapper `store.call_fn("<module>_<action>", params)`).
2. **Analyse de la sérialisation Serde réelle** :
   - Examiner les attributs `#[serde(rename = "...")]`, `#[serde(rename_all = "...")]`, `#[serde(flatten)]` et `#[serde(skip_serializing_if = "Option::is_none")]` ;
   - Noter si un `Option<T>` sans `skip_serializing_if` envoie `null` ou si `NONE` est attendu côté SurrealDB.
3. **Comparaison champ par champ avec `$params.<champ>`** :
   - Relever toutes les propriétés `$params.<prop>` lues dans le corps SurrealQL ;
   - Vérifier les alias explicites ou fallbacks éventuels dans SurrealQL (ex. : `$params.foo ?? $params.bar`) avant de conclure à un écart : **ne jamais classer une différence de nom comme un défaut si un alias ou une transformation explicite la prend en charge** ;
   - Contrôler les champs obligatoires vs optionnels, les valeurs par défaut (`?? 'fr'`, `DEFAULT`) et la compatibilité des types (ex. : `String` vs `RecordId`, `i64`/`u32` vs `int`, `Value` vs `object`/`array`).
4. **Production obligatoire du Tableau de Correspondance DTO $\leftrightarrow$ SurrealQL** :
   Inclure dans le rapport d'audit un tableau explicite classant les champs selon 4 statuts :
   - **Conformes** : nom sérialisé et type alignés entre `*Params` et `$params.<champ>` ;
   - **Absents côté Rust** : lus par `$params.<champ>` en SurrealQL mais absents de `*Params` ;
   - **Supplémentaires côté Rust** : sérialisés par `*Params` mais jamais lus en SurrealQL ;
   - **Incompatibles (P0/P1)** : divergence de nom sans alias (ex. `external_code` vs `$params.source_code`) ou incompatibilité de type provoquant un `NONE` inattendu ou une erreur d'exécution.

### Contrôle 5 — Compatibilité SurrealDB 3.2.0 [OBLIGATOIRE]
Lorsque le workspace cible **SurrealDB 3.2.0** (binaire local [`c:\Users\HP\Desktop\Lyxal_OS\surreal.exe`](../../../surreal.exe) v3.2.0, cf. `.agents/skills/lyxal-surrealdb/SKILL.md`) mais que les tests Cargo embarqués utilisent un SDK d'une autre génération (ex. `surrealdb = "2.2"` dans `Cargo.toml`) :
1. **Détection des constructions à risque de rupture 2.x $\rightarrow$ 3.2.0** :
   - Exécuter `c:\Users\HP\Desktop\Lyxal_OS\surreal.exe validate` sur les fichiers `.surql` du module et rechercher systématiquement :
     - `option<any>` (rejeté au parsing en 3.2.0 $\rightarrow$ utiliser `any`) ;
     - `array::contains(` (supprimé en 3.2.0 $\rightarrow$ utiliser `(($a) CONTAINS ($b))`) ;
     - `time::from::parts(`, `string::pad(`, `encoding::hex::*`, `encoding::uri::*`, `bytes::from_int(` (inexistants en 3.2.0) ;
     - `type::thing(` (remplacé en SurrealDB 3.x par `type::record($table, $id)` / construction de `record<T>`) ;
     - `type::is::*` (ex. `type::is::string($x)` $\rightarrow$ `type::is_string($x)` ou `$x IS string`) ;
     - Séquences d'échappement regex à simple antislash dans `"..."` (`Invalid escape sequence`), backreferences `\1`/`\2`, réaffectations de variables sans `LET` ou comparaisons `$a = $b` en tête de bloc `{ ... }` ;
     - Signatures runtime 3.2.0 : `array::reduce` à 3 arguments ($\rightarrow$ `array::fold`), `array::sort::asc`/`desc` à 2 arguments, `math::min`/`max` sur `array<duration>`, soustraction de `duration` pouvant être négative, `math::log` à 1 argument, `encoding::base64::encode` sur `string` sans cast `<bytes>`, affectation `LET $token = ...` (variable protégée), ou `0..$n` non casté en `<array>(0..$n)` ;
     - `IF ... THEN ( ... ) END` vs `IF ... { ... }` dans les blocs procéduraux et `DEFINE EVENT`.
2. **Interdiction des remplacements mécaniques non vérifiés** :
   - Avant de recommander le remplacement d'une fonction SurrealQL, vérifier la sémantique exacte de l'expression cible (gestion de `NONE` vs `NULL`, comportement lorsque le premier argument de `type::record` contient déjà le préfixe `table:id`, compatibilité avec le SDK Rust si les tests tournent encore sur `surrealdb = "2.2"`).
3. **Séparation stricte entre analyse statique, test SDK 2.x et preuve serveur 3.2.0** :
   - Un test `cargo test` passant sur `surrealdb = "2.2"` (`mem://`) prouve la logique sur le moteur 2.2 embarqué, mais **ne constitue jamais une preuve de compatibilité SurrealDB 3.2.0**.
   - **Règle absolue** : Ne jamais déclarer la compatibilité SurrealDB 3.2.0 comme « validée » tant que les scripts `.surql` n'ont pas été effectivement exécutés contre un binaire ou serveur SurrealDB `3.2.0`. Tant que ce test sur serveur 3.2.0 n'a pas eu lieu, le documenter obligatoirement dans la section **« 4. Points non vérifiés faute de preuves »**.

### Contrôle 6 — Conformité Rust (`src/`) [OBLIGATOIRE]
Si le module comporte un crate Rust, inspecter `Cargo.toml` et `src/**/*.rs` :
1. **Transport & Appels SurrealDB** (selon le niveau du crate vérifié au Contrôle 2) :
   - Pour un module métier : store enveloppant `Surreal<Any>` et implémentant [`lyxal_surreal::LyxalSurrealCall`](../../../lyxal_surreal/src/call.rs), wrappers 1-ligne `store.call_fn("...", params).await` ;
   - Aucun `.query(...).bind(...).take(0)` métier en dehors de `LyxalSurrealCall::call_fn` ;
   - Aucun `raw_query()` public (`pub`) ou utilisé pour de la logique métier ;
   - Zéro `panic!`, `.unwrap()` ou `.expect()` sur les chemins d'exécution runtime/réseau/base de données ;
   - Zéro masquage silencieux d'erreur (pas de conversion d'erreur DB/désérialisation en `None` ou `Vec::new()`).
2. **Modèles (`src/models/`)** :
   - Ségrégation `pub` vs `pub(crate)` ; aucun secret/hash dans les structures publiques ou sérialisables (`Serialize`) ;
   - Redaction `[REDACTED]` dans `fmt::Debug` pour tout secret ;
   - Aucun tuple anonyme dans les signatures publiques.
3. **Intégration `lyxal_runtime` & `lyxal_event`** (pour les modules métiers rattachés au Runtime) :
   - Implémentation de [`LyxalModule`](../../../crates/lyxal_runtime/src/module.rs) (`descriptor(&self) -> &ModuleDescriptor`, `install(&self, ctx: &ModuleContext)`, `start(&self, ctx: &ModuleContext)`, `stop(&self, ctx: &ModuleContext)`) ;
   - Aucun `tokio::spawn` non supervisé : utilisation exclusive de [`LyxalWorker`](../../../crates/lyxal_runtime/src/worker/definition.rs) (`descriptor(&self) -> &WorkerDescriptor`, `run(&self, ctx: WorkerContext)`) et respect de `ctx.cancellation` / `ctx.is_cancelled()` ;
   - Implémentation de [`ModuleHealthCheck`](../../../crates/lyxal_runtime/src/health/check.rs) (`module_id(&self)`, `check(&self, ctx: &ModuleContext) -> Result<HealthCheckResult, RuntimeError>`) si le module expose une sonde de santé ;
   - Implémentation de [`Event`](../../../crates/lyxal_event/src/handler/event.rs) (`EVENT_TYPE`), [`Handler<E>`](../../../crates/lyxal_event/src/handler/handler.rs) idempotent et [`EventConsumerModule`](../../../crates/lyxal_runtime/src/event_engine/registration.rs) si consommateur d'événements.
   - *(Pour un audit approfondi de ces mécanismes, activer conjointement le Skill [`lyxal-runtime-integration`](../lyxal-runtime-integration/SKILL.md)).*

### Contrôle 7 — Conformité Cryptographique (`lyxal_crypto`) [OBLIGATOIRE]
1. Inspecter `Cargo.toml` et les imports `use` dans `src/` :
   - **Violation P0** si un module métier importe directement `argon2`, `bcrypt`, `hmac`, `sha2`, `blake3`, `aes_gcm`, `hkdf` ou utilise `rand::thread_rng()`.
   - Toute opération cryptographique dans un module métier doit passer par `lyxal_crypto` (`hash`, `password`, `hmac`, `kdf`, `CryptoEngine` avec `SecretContext` / `EncryptedEnvelope`) et `rand_core::OsRng`.

### Contrôle 8 — Exécution des Contrôles & Preuves de Tests [OBLIGATOIRE]
1. Distinguer avec une rigueur absolue dans le rapport :
   - **Contrôles statiques effectués** (lecture intégrale des fichiers, vérification des graphes, croisement DTO $\leftrightarrow$ SurrealQL) ;
   - **Tests réellement exécutés et réussis** (commande exacte, code retour `0`, nombre de tests passés et moteur utilisé) ;
   - **Tests réellement exécutés et échoués** (commande exacte, trace d'erreur) ;
   - **Tests impossibles à exécuter ou non exécutés** (blocage sandbox `CreateProcessSecurityEnvironment`, absence d'instance SurrealDB 3.2.0 active, etc.).
2. **Ne jamais déclarer `cargo check`, `cargo test` ou une validation SurrealDB 3.2.0 réussie sans résultat d'exécution effectif.**

---

## Format Obligatoire du Rapport d'Audit CTO

Toujours structurer le livrable d'audit selon ces 7 sections :

1. **Périmètre Audité & Position dans le Graphe** : Module(s), version du `manifest.toml`, niveau architectural (Fondation / Noyau / Métier / Hôte), liste des fichiers inspectés.
2. **Synthèse Exécutive & Verdict** : `CONFORME`, `CONFORME AVEC RÉSERVES (P2)`, ou `NON CONFORME (P0/P1 bloquants)`.
3. **Écarts Constatés (P0 / P1 / P2)** :
   - Tableau indiquant pour chaque écart : `ID & Sévérité`, `Règle applicable`, `Fichier & Lignes` (liens cliquables `[fichier](file:///...#Lxx-Lyy)`), `Preuve constatée`, `Correction recommandée`.
4. **Tableau de Correspondance DTO Rust (`*Params`) $\leftrightarrow$ SurrealQL (`$params`)** :
   - Tableau exhaustif listant par fonction : `Fonction SurrealQL`, `Struct Rust`, `Champs conformes`, `Champs absents`, `Champs supplémentaires`, `Champs incompatibles`.
5. **Points Non Vérifiés Faute de Preuves (Tests & Compatibilité SurrealDB 3.2.0)** :
   - Distinction explicite entre tests exécutés/réussis, tests échoués, contrôles statiques et vérifications nécessitant un serveur SurrealDB 3.2.0.
6. **Éléments Conformes & Preuves Validées** :
   - Résumé factuel avec références de fichiers/lignes des contrôles validés.
7. **Plan Correctif Proposé (soumis à validation CTO)** :
   - Ordre de résolution priorisé (P0 $\rightarrow$ P1 $\rightarrow$ P2) sans modifier les fichiers tant que le CTO n'a pas donné son accord.
