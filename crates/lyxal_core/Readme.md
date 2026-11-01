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

### Contrat d'erreur — en cours de migration

* **Actuel** : les fonctions signalent une donnée invalide par `THROW`, souvent avec un code construit à partir du paramètre `$field` (ex. `EMAIL_REQUIRED`). Un `THROW` interrompt la fonction du module appelant (`AUDIT.md`, P1-1).
* **Cible** (lot 3 du plan, décision CTO Q1) : `fn::validation_*` renvoient `{ valid, value, code, details }` ; `fn::sanitize_*` transforment sans lever ; seul un argument invalide (erreur de programmation) lève `THROW` avec un code fixe `CORE_*`. Le module appelant choisit son propre code d'erreur et répond via `fn::error_result` (§5.3).

---

## Utilisation par les modules

Aucun module ne l'appelle encore. L'adoption se fera à la reprise de chaque module, une fois le contrat cible en place. Les modules `lyxal_error`, `lyxal_event`, `lyxal_pipeline_ingestion` et `lyxal_catalogue` le déclarent déjà comme dépendance (`>=0.1.0`).

---

## Tests

* `scripts/ci/test_lyxal_core.py` charge les 781 fonctions dans un serveur SurrealDB 3.3.4 jetable, vérifie qu'elles sont toutes définies, puis exécute chaque fichier de tests.
* **Deux formats coexistent pendant la reprise** :
  * **format « assertions »** (fichiers commençant par `-- lyxal-test: assertions`) : chaque bloc `-- test:` contient une instruction qui doit renvoyer `true`, ou lever l'erreur annoncée par `-- attendu-erreur: <CODE>` ; tout écart fait échouer la CI (détails : `implementation_plan.md` §5) ;
  * **ancien format** : le résultat attendu n'est qu'un commentaire ; le script vérifie seulement l'absence d'erreur moteur inattendue. Les fichiers passent au format « assertions » au fil du lot 3.
* `scripts/ci/test_lyxal_core_selftest.py` vérifie que le banc accepte les bons tests et rejette les mauvais.
* `scripts/ci/validate_surql.sh` vérifie la syntaxe de tout le SurrealQL du dépôt.
* Les deux scripts font partie de la CI (job « SurrealQL ») et de `scripts/ci/ci_local.sh`.
