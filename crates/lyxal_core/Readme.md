# Lyxal Core

> Bibliothèque standard SurrealQL de Lyxal OS — SurrealDB 3.3.4.
> **Reprise en cours** : voir [`AUDIT.md`](AUDIT.md) (état constaté) et [`implementation_plan.md`](implementation_plan.md) (lots en cours). Ce Readme décrit l'état actuel ; il est mis à jour à chaque lot.

---

## Présentation

**Lyxal Core** est la couche 0 de Lyxal OS : des fonctions SurrealQL génériques, sans logique métier, sans table et sans dépendance, destinées à être réutilisées par tous les modules (`.agents/AGENTS.md` §5.7).

Le Core ne contient jamais :

- de logique métier ;
- de tables métier ;
- de workflow ;
- de règle fonctionnelle propre à un module.

Ces éléments appartiennent aux modules. Le Core fournit les briques ; les modules fournissent le métier.

---

## Organisation

```text
lyxal_core/
├── manifest.toml            (id lyxal_core, version 0.1.0, 781 fonctions déclarées)
├── Readme.md
├── AUDIT.md                 (document de reprise, supprimé en fin de reprise)
├── implementation_plan.md   (document de reprise, supprimé en fin de reprise)
└── functions/
    ├── validations/   functions/ (339) · tests/ (339)   fn::validation_*
    ├── sanitize/      functions/ (170) · tests/ (170)   fn::sanitize_*
    ├── security/      functions/ (152) · tests/ (152)   fn::security_*
    └── utils/         functions/ (120) · tests/ (120)   fn::utils_*
```

Chaque fonction a son fichier (`functions/<domaine>/functions/<nom>.surql`) et son fichier de tests (`functions/<domaine>/tests/<nom>.test.surql`).

| Domaine | Rôle |
| :--- | :--- |
| `validations` | Vérifier qu'une donnée respecte un contrat (chaînes, nombres, UUID, e-mails, URL, tableaux, objets, dates, durées, géométries…). |
| `sanitize` | Normaliser une donnée (espaces, casse, slug, Unicode, téléphone, e-mail, tableaux, objets ; nettoyage HTML lexical léger, qui ne remplace pas un parseur DOM anti-XSS). |
| `security` | Primitives de sécurité pures : empreintes non secrètes (SHA-256, BLAKE3), jetons (construction des claims, analyse), masquage (`redact_*`), détection d'attaques (`detect_*`), permissions, rôles, politiques, nonces et fenêtres anti-rejeu. |
| `utils` | Fonctions techniques génériques : tableaux, objets, chaînes, nombres, dates, collections, conversions, cache, informations d'exécution, pipelines. |

**Cryptographie** : chiffrement, HMAC, dérivation et gestion de clés, hachage de mots de passe sont exclusivement réalisés en Rust par `lyxal_crypto` (§11.3), appelé par le code Rust avant ou après `call_fn`. Le Core n'en contient aucune.

`fn::security_secret_generate` utilise `rand::id`, sûr en SurrealDB 3.3 (`rand::rng()`, ChaCha12) **sauf** si le serveur est démarré avec `SURREAL_RAND_SEED` (mode déterministe de test). Pour du matériel cryptographique, utiliser `lyxal_crypto`.

---

## Contrat des fonctions

Toutes les fonctions sont déclarées sous la forme :

```surql
DEFINE FUNCTION OVERWRITE fn::<domaine>_<nom>(<paramètres typés>) -> <type> { ... }
COMMENT "..."
PERMISSIONS FULL;
```

Les primitives du Core utilisent des **signatures positionnelles typées** (exception au `$params: object` des modules, skill `lyxal-audit` Contrôle 2.3).

### Contrat des validations — migration en cours (lot 3)

Les fonctions `fn::validation_*` ne lèvent plus d'erreur pour une donnée invalide : elles renvoient un résultat que le module appelant exploite avec **son** code d'erreur (décision CTO Q1, `implementation_plan.md` §2).

```surql
-- Résultat de toute fonction fn::validation_* migrée
{ valid: bool, value: any, code: option<string>, details: object }
--   valid = true  → value = valeur normalisée (ex. chaîne sans espaces), code = NONE, details = {}
--   valid = false → value = NONE, code = "CORE_VALIDATION_<CAUSE>", details = contexte (bornes, longueur…)

-- Utilisation dans une fonction de module
LET $name = fn::validation_required_string($params.name, 1, 100);
IF !$name.valid {
    RETURN fn::error_result("TEAM_NAME_INVALID", $params.language, { reason: $name.code, details: $name.details });
};
-- $name.value contient la chaîne nettoyée
```

* Il n'y a plus de paramètre `$field` : le nom du champ n'est connu que du module.
* Les paramètres facultatifs (`option<…>`) doivent être passés explicitement (`NONE`).
* **Avancement** : famille « types, nombres et chaînes » migrée (44 fonctions : `boolean`, `integer`, `number`, `decimal`, `float`, `bytes`, `value_type`, `allowed_types`, `uuid`, `uuid_v7`, `ulid`, `positive_number`, `negative_number`, `non_negative_number`, `non_zero`, `even`, `odd`, `multiple_of`, `percentage`, `integer_range`, `compare`, `required_if`, `required_unless`, `required_string`, `optional_string`, `not_blank`, `min_length`, `max_length`, `alphanumeric`, `ascii`, `lowercase`, `uppercase`, `contains`, `starts_with`, `ends_with`, `forbidden_values`, `reserved_words`, `regex`, `enum`, `enum_any`, `slug`, `identifier`, `hexadecimal`, `base64`). Les autres fonctions gardent l'ancien contrat (`THROW` d'un code construit à partir de `$field`, `AUDIT.md` P1-1) jusqu'à leur PR.

#### Catalogue des codes `CORE_VALIDATION_*`

Ce sont des **motifs** de rejet, transmis par le module dans les `details` de sa propre erreur ; ils ne sont pas renvoyés tels quels par une API et n'ont donc pas de définition master data.

| Code | Motif | `details` |
| :--- | :--- | :--- |
| `CORE_VALIDATION_REQUIRED` | valeur absente (`NONE`) | `{}` (`{ bound }` pour un intervalle) |
| `CORE_VALIDATION_NULL` | valeur `NULL` | `{}` (`{ bound }` pour un intervalle) |
| `CORE_VALIDATION_TYPE` | type inattendu | `{ expected, actual }` |
| `CORE_VALIDATION_BLANK` | chaîne vide après nettoyage | `{}` |
| `CORE_VALIDATION_TOO_SHORT` | longueur inférieure au minimum | `{ min_length, length }` |
| `CORE_VALIDATION_TOO_LONG` | longueur supérieure au maximum | `{ max_length, length }` |
| `CORE_VALIDATION_TOO_SMALL` | valeur inférieure au minimum | `{ min }` (+ `exclusive: true` si borne exclue) |
| `CORE_VALIDATION_TOO_LARGE` | valeur supérieure au maximum | `{ max }` (+ `exclusive: true` si borne exclue) |
| `CORE_VALIDATION_FORMAT` | format non respecté | `{ expected }`, `{ pattern }`, `{ contains_any }`, `{ starts_with_any }` ou `{ ends_with_any }` |
| `CORE_VALIDATION_NOT_ALLOWED` | valeur hors de la liste autorisée | `{ allowed }` |
| `CORE_VALIDATION_FORBIDDEN` | valeur interdite ou mot réservé | `{}` |
| `CORE_VALIDATION_NOT_MULTIPLE` | entier non multiple du diviseur | `{ divisor }` |
| `CORE_VALIDATION_PARITY` | parité inattendue | `{ expected }` (`"even"` ou `"odd"`) |
| `CORE_VALIDATION_ZERO` | valeur nulle interdite | `{}` |
| `CORE_VALIDATION_COMPARISON` | comparaison non vérifiée | `{ operator }` |
| `CORE_VALIDATION_RANGE_ORDER` | bornes d'un intervalle inversées (ou égales si interdit) | `{ min_value, max_value, allow_equal }` |

Le catalogue est fermé : un nouveau motif s'ajoute ici dans la PR qui l'introduit.

#### Erreurs de programmation (`THROW`)

Seul un argument invalide fourni par le code appelant (borne négative, bornes inversées, liste vide, option inconnue) interrompt la fonction, avec un code fixe défini dans `crates/lyxal_error/error/core/core_definitions.surql` :

| Code | Cas |
| :--- | :--- |
| `CORE_INVALID_ARGUMENT` | argument de configuration invalide |
| `CORE_UNSUPPORTED_OPTION` | option inconnue (ex. opérateur de `fn::validation_compare`) |

Un motif d'expression régulière syntaxiquement invalide (`fn::validation_regex`) provoque l'erreur du moteur (`string::matches`) : SurrealDB 3.3.4 n'offre aucun moyen de le détecter sans lever.

---

## Utilisation par les modules

Aucun module ne l'appelle encore. L'adoption se fera à la reprise de chaque module, une fois le contrat cible en place. Les modules `lyxal_error`, `lyxal_event`, `lyxal_pipeline_ingestion` et `lyxal_catalogue` le déclarent déjà comme dépendance (`>=0.1.0`).

---

## Tests

* `scripts/ci/test_lyxal_core.py` charge les 781 fonctions dans un serveur SurrealDB 3.3.4 jetable, vérifie qu'elles sont toutes définies, puis exécute chaque fichier de tests.
* **Deux formats coexistent pendant la reprise** :
  * **format « assertions »** (fichiers commençant par `-- lyxal-test: assertions`) : chaque bloc `-- test:` contient une instruction qui doit renvoyer `true`, ou lever l'erreur annoncée par `-- attendu-erreur: <CODE>` ; tout écart fait échouer la CI (détails : `implementation_plan.md` §5) ;
  * **ancien format** : le résultat attendu n'est qu'un commentaire ; le script vérifie seulement l'absence d'erreur moteur inattendue. Les fichiers passent au format « assertions » au fil du lot 3 (44 fichiers aujourd'hui, ceux des fonctions migrées).
* `scripts/ci/test_lyxal_core_selftest.py` vérifie que le banc accepte les bons tests et rejette les mauvais.
* `scripts/ci/validate_surql.sh` vérifie la syntaxe de tout le SurrealQL du dépôt.
* Les deux scripts font partie de la CI (job « SurrealQL ») et de `scripts/ci/ci_local.sh`.
