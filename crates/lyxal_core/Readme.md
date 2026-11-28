# Lyxal Core

> Bibliothèque standard SurrealQL de Lyxal OS — SurrealDB 3.3.4.

---

## Présentation

**Lyxal Core** est la couche 0 de Lyxal OS : des fonctions SurrealQL génériques, sans logique métier, sans table et sans dépendance, destinées à être réutilisées par tous les modules (`.agents/AGENTS.md` §5.7).

Le Core ne contient jamais :

- de logique métier ;
- de tables métier ;
- de workflow ;
- de règle fonctionnelle propre à un module.

Ces éléments appartiennent aux modules. Le Core fournit les briques ; les modules fournissent le métier.

Évolutions prévues : [`ROADMAP.md`](ROADMAP.md).

---

## Organisation

```text
lyxal_core/
├── manifest.toml            (id lyxal_core, version 0.1.0, 488 fonctions déclarées)
├── Readme.md
└── functions/
    ├── validations/   functions/ (200) · tests/ (200)   fn::validation_*
    ├── sanitize/      functions/ (98) · tests/ (98)     fn::sanitize_*
    ├── security/      functions/ (71) · tests/ (71)     fn::security_*
    └── utils/         functions/ (119) · tests/ (119)   fn::utils_*
```

Chaque fonction a son fichier (`functions/<domaine>/functions/<nom>.surql`) et son fichier de tests (`functions/<domaine>/tests/<nom>.test.surql`).

| Domaine | Rôle |
| :--- | :--- |
| `validations` | Vérifier qu'une donnée respecte un contrat : chaînes, nombres, UUID, e-mails, URL, tableaux, objets, dates, durées, formats techniques et métier. |
| `sanitize` | Normaliser une donnée déjà validée : espaces, casse, slug, Unicode, téléphone, e-mail, tableaux, objets, URL, chemins, et nettoyage HTML et Markdown lexical (qui ne remplace pas un parseur anti-XSS). |
| `security` | Primitives de sécurité pures : empreintes non secrètes (SHA-256, SHA-512, BLAKE3), forme canonique des requêtes HMAC, jetons (claims, analyse), masquage (`redact_*`), détection d'attaques (`detect_*`), permissions, rôles, politiques, nonces, fenêtres anti-rejeu, journal d'audit chaîné. |
| `utils` | Fonctions techniques génériques (tableaux, collections, comparaisons, dates, nombres, objets, chaînes, encodages, CSV, cache, métadonnées d'exécution) et le **moteur unique** `fn::utils_engine_*`, qui exécute les pipelines de tous les domaines. |

**Cryptographie** : chiffrement, signature HMAC, dérivation et gestion de clés, hachage de mots de passe sont exclusivement réalisés en Rust par `lyxal_crypto` (`.agents/rules/lyxal_standards_and_checklist.md` §11.3), appelé par le code Rust avant ou après `call_fn`. Le Core n'en contient aucune.

`fn::security_secret_generate` et `fn::security_nonce` utilisent `rand::id`, sûr en SurrealDB 3.3 (`rand::rng()`, ChaCha12) **sauf** si le serveur est démarré avec `SURREAL_RAND_SEED` (mode déterministe de test). Pour du matériel cryptographique, utiliser `lyxal_crypto`.

---

## Contrat des fonctions

Toutes les fonctions sont déclarées sous la forme :

```surql
DEFINE FUNCTION OVERWRITE fn::<domaine>_<nom>(<paramètres typés>) -> <type> { ... }
COMMENT "..."
PERMISSIONS FULL;
```

Les primitives du Core utilisent des **signatures positionnelles typées** (exception au `$params: object` des modules, skill `lyxal-audit` Contrôle 2.3). Les paramètres facultatifs (`option<…>`) se passent explicitement (`NONE`). Aucune fonction ne prend de paramètre `$field` : le nom du champ n'est connu que du module appelant.

### Fonctions `validations`

Une fonction `fn::validation_*` ne lève pas d'erreur pour une donnée invalide : elle renvoie un résultat que le module appelant exploite avec **son** code d'erreur.

```surql
-- Résultat de toute fonction fn::validation_*
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

* Une « date » est un datetime à minuit UTC.
* `details.scope` précise ce qui est en cause quand ce n'est pas la valeur elle-même : `"item"` (un élément d'un tableau), `"key"` (une clé d'objet), `"value"` (une valeur d'objet) ou `"group"` (un groupe de champs). `details.bound` désigne la borne en cause d'un intervalle.
* Un identifiant SurrealQL de table, namespace, base ou événement se valide avec `fn::validation_identifier`.
* Un nom DNS d'enregistrement ou de cible se valide avec `fn::validation_dns_name($value, $allow_underscore, $allow_wildcard, $zone)` (règle `dns_name` du moteur) : labels de service à tiret bas (`_dmarc`, `sel._domainkey`, `_mta-sts`, `_smtp._tls`, `_acme-challenge`), que `fn::validation_domain` refuse (`string::is_domain`) ; joker `*` en premier label sur option ; `$zone` (ou `NONE`) exige l'apex ou un sous-nom de cette zone, et une zone mal formée lève `CORE_INVALID_ARGUMENT`. Valeur rendue en minuscules, sans point final.
* La taille d'un objet ou d'un tableau libre (données d'un abonné, métadonnées…) se borne avec `fn::validation_max_serialized_length($value, $max_length)` (règle `max_serialized_length` du moteur) : longueur en caractères de son texte JSON (`encoding::json::encode`).
* Un motif d'expression régulière syntaxiquement invalide (`fn::validation_regex`) provoque l'erreur du moteur (`string::matches`) : SurrealDB 3.3.4 n'offre aucun moyen de le détecter sans lever.

#### Catalogue des codes `CORE_VALIDATION_*`

Ce sont des **motifs** de rejet, transmis par le module dans les `details` de sa propre erreur ; ils ne sont pas renvoyés tels quels par une API et n'ont donc pas de définition master data.

| Code | Motif | `details` |
| :--- | :--- | :--- |
| `CORE_VALIDATION_REQUIRED` | valeur absente (`NONE`) | `{}` (`{ bound }` pour un intervalle) |
| `CORE_VALIDATION_NULL` | valeur `NULL` | `{}` (`{ bound }` pour un intervalle) |
| `CORE_VALIDATION_TYPE` | type inattendu | `{ expected, actual }` |
| `CORE_VALIDATION_BLANK` | chaîne vide après nettoyage | `{}` |
| `CORE_VALIDATION_TOO_SHORT` | longueur (ou nombre de mots, d'initiales) inférieure au minimum | `{ min_length, length }`, `{ min_words, words }`, `{ min_count, count }` ou `{ min_segments, segments }` |
| `CORE_VALIDATION_TOO_LONG` | longueur (ou nombre de mots, d'initiales) supérieure au maximum | `{ max_length, length }`, `{ max_words, words }`, `{ max_count, count }` ou `{ max_segments, segments }` |
| `CORE_VALIDATION_TOO_SMALL` | valeur (nombre, date, durée) inférieure au minimum | `{ min }` (+ `exclusive` si borne exclue) ; pour un écart ou un âge : `{ min_<nom>, <nom> }` (ex. `{ min_days, days }`) ; `bound` pour une borne d'intervalle |
| `CORE_VALIDATION_TOO_LARGE` | valeur (nombre, date, durée) supérieure au maximum | `{ max }` (+ `exclusive` si borne exclue) ; pour un écart ou un âge : `{ max_<nom>, <nom> }` ; `bound` pour une borne d'intervalle |
| `CORE_VALIDATION_FORMAT` | format non respecté (dont date avec heure : `{ expected: "date" }`) | `{ expected }` (+ `bound`), `{ pattern }`, `{ contains_any }`, `{ starts_with_any }` ou `{ ends_with_any }` |
| `CORE_VALIDATION_NOT_ALLOWED` | valeur hors de la liste autorisée, variante exclue par l'appelant, ou clé d'objet inconnue (moteur) | `{ allowed }`, `{ allowed_prefixes }`, `{ scope: "key", key }`, ou `{ reason }` : `"weekend"`, `"holiday"`, `"subdomain"`, `"single_label"`, `"scheme"`, `"port"`, `"parameters"`, `"wildcard"`, `"encrypted"`, `"macro"`, `"weak"`, `"ipv4"`, `"ipv6"`, `"hostname"`, `"extension"`, `"underscore"`, `"zone"` |
| `CORE_VALIDATION_FORBIDDEN` | valeur interdite, mot ou nom réservé (rôle, paramètre SurrealQL, champ `id`) | `{}` |
| `CORE_VALIDATION_NOT_MULTIPLE` | entier non multiple du diviseur | `{ divisor }` |
| `CORE_VALIDATION_PARITY` | parité inattendue | `{ expected }` (`"even"` ou `"odd"`) |
| `CORE_VALIDATION_ZERO` | valeur nulle interdite | `{}` |
| `CORE_VALIDATION_EMPTY` | tableau ou objet vide | `{}` (`{ scope: "item" }` pour un objet vide dans un tableau) |
| `CORE_VALIDATION_DUPLICATE` | tableau contenant un doublon | `{}` |
| `CORE_VALIDATION_COMBINATION` | combinaison de champs non autorisée, ou aucune branche `one_of` valide (moteur) | `{ present, max }`, `{ present, total }`, `{ allowed }` ou `{ scope: "group", attempts }` |
| `CORE_VALIDATION_NOT_FOUND` | enregistrement ou valeur introuvable en base | `{}` (`{ scope: "item" }` pour un élément) |
| `CORE_VALIDATION_ALREADY_EXISTS` | valeur déjà utilisée en base | `{}` |
| `CORE_VALIDATION_COMPARISON` | comparaison non vérifiée | `{ operator }` |
| `CORE_VALIDATION_RANGE_ORDER` | bornes d'un intervalle inversées (ou égales si interdit) | `{ min_value, max_value, allow_equal }` ou `{ start, end, allow_equal }` (+ `allow_overnight` pour une plage horaire) |

Le catalogue est fermé : un nouveau motif s'ajoute ici dans la PR qui l'introduit.

### Fonctions `sanitize`

Une fonction `fn::sanitize_*` transforme une valeur **déjà validée** ; elle ne renvoie pas de résultat `{ valid, … }` :

* entrée `NONE` → renvoie `NONE` (un champ facultatif absent traverse la chaîne de nettoyage) ;
* entrée `NULL` ou d'un type inattendu → `THROW "CORE_SANITIZE_INVALID_TYPE"` ;
* argument de configuration invalide → `CORE_INVALID_ARGUMENT` ou `CORE_UNSUPPORTED_OPTION` ;
* exceptions documentées : `fn::sanitize_array` et `fn::sanitize_object` renvoient `[]` et `{}` pour `NONE` ou `NULL`, car elles servent à fournir une collection par défaut.

```surql
LET $email = fn::validation_email($params.email, 254);
IF !$email.valid { RETURN fn::error_result("AUTH_EMAIL_INVALID", $params.language, { reason: $email.code }); };
LET $clean = fn::sanitize_email($email.value);
```

Une liste de caractères se retire ou se remplace avec `fn::sanitize_replace_chars($value, $remove, $replace)` (règle `replace_chars` du moteur, options `remove` et `replace`, l'une au moins) : `remove` est un tableau de caractères à retirer, `replace` un tableau de couples `{ from, to }` (un caractère vers une chaîne de 8 caractères au plus) ; les suppressions sont appliquées d'abord, puis les remplacements dans l'ordre ; aucune expression régulière, casse respectée ; une liste mal formée lève `CORE_INVALID_ARGUMENT`.

Le nettoyage HTML et Markdown est **lexical** (expressions régulières) : il ne remplace pas un parseur HTML anti-XSS. `string::replace` de SurrealDB 3.3.4 ne gère pas les groupes de capture (« $1 ») : les fonctions qui doivent garder une partie du motif (liens Markdown…) découpent le texte.

### Fonctions `security` et `utils`

Elles gardent des **paramètres typés** et renvoient une valeur ou un objet. Seul un argument invalide les interrompt (`CORE_INVALID_ARGUMENT` ou `CORE_UNSUPPORTED_OPTION`).

* Les comparaisons d'empreintes (`fn::security_hash_verify`) ne sont pas à temps constant : pour un secret, la comparaison se fait dans `lyxal_crypto`.
* La détection d'attaques est heuristique (score de 0 à 100).
* L'empreinte du journal d'audit (`fn::security_audit_entry`, `fn::security_audit_verify`) porte sur la représentation SurrealQL de l'événement, qui conserve les types (la durée `1s` et la chaîne `"1s"` diffèrent).
* Les nombres et l'arrondi de `utils` s'appuient sur `sanitize` (`fn::sanitize_round`) ; l'égalité profonde est l'opérateur `==` de SurrealQL.
* `fn::utils_to_csv` applique les guillemets RFC 4180. La lecture d'un CSV est du parsing : elle se fait en Rust (`.agents/rules/lyxal_standards_and_checklist.md` §10).
* Les conversions `fn::utils_ensure_bool`, `ensure_number`, `decode_uri` et `from_hex` lèvent `CORE_INVALID_ARGUMENT` sur une donnée non convertible : elles s'appliquent à une donnée déjà validée.

### Conditions (`fn::utils_condition_*`)

Règle générique, sans métier, pour décider si une valeur (un objet en général) remplit une condition : abonnements conditionnels, conditions d'étape, choix d'un fournisseur, déclencheurs sur événement.

| Fonction | Rôle |
| :--- | :--- |
| `fn::utils_condition_check($condition, $limits)` | contrôle la forme sans évaluer ; renvoie `{ valid, code, details: { path, reason }, rules, depth }`, sans lever pour une condition invalide (le module renvoie sa propre erreur) |
| `fn::utils_condition_evaluate($value, $condition, $limits)` | évalue ; renvoie `{ matched, error }` ; une forme invalide lève `CORE_CONDITION_INVALID` |

* Forme : `{ all: [...] }`, `{ any: [...] }` (groupes non vides), `{ not: {...} }`, ou règle `{ field: "payload.montant", op: "gt", value: 1000 }`. Le champ est un chemin à points lu par `fn::utils_object_get_path`.
* Opérateurs : `eq`, `ne` (égalité profonde `==`) ; `lt`, `lte`, `gt`, `gte`, `between` (bornes incluses) sur deux nombres, deux chaînes ou deux dates (`fn::utils_compare_numbers`, `_strings` sensible à la casse, `_dates`) ; `in`, `not_in` (liste de 1 à 100 valeurs) ; `contains` (sous-chaîne ou élément d'un tableau) ; `starts_with`, `ends_with` ; `exists`, `missing` (ni `NONE` ni `NULL`) ; `empty` (absent, `""`, `[]`, `{}`).
* Champ absent : la règle est fausse, sans erreur (vraie pour `ne`, `not_in`, `missing`, `empty`). Types incompatibles : règle fausse avec `error: { field, op, reason: "type_mismatch" }` ; sa négation reste fausse.
* `all` s'arrête au premier échec, `any` au premier succès.
* Limites `{ max_depth, max_rules }` : profondeur 5 et 50 règles par défaut, réglables jusqu'à 10 et 200 (au-delà : `CORE_INVALID_ARGUMENT`). Dépassement : `too_deep` ou `too_many_rules`.

```surql
-- À l'enregistrement
LET $check = fn::utils_condition_check($params.condition, NONE);
IF !$check.valid { RETURN fn::error_result("<MODULE>_CONDITION_INVALID", $language, $check.details); };
-- À l'usage
LET $ok = fn::utils_condition_evaluate({ subscriber: $subscriber, payload: $payload }, $condition, NONE).matched;
```

### Erreurs de programmation (`THROW`)

Seul un argument invalide fourni par le code appelant (borne négative, bornes inversées, liste vide, option inconnue) interrompt une fonction, avec un code fixe défini dans `crates/lyxal_core/error/core_definitions.surql` (déclaré dans le manifeste, installé après le schéma de `lyxal_error`) :

| Code | Cas |
| :--- | :--- |
| `CORE_INVALID_ARGUMENT` | argument de configuration invalide |
| `CORE_UNSUPPORTED_OPTION` | option inconnue (ex. opérateur de `fn::validation_compare`, règle absente d'un catalogue) |
| `CORE_SANITIZE_INVALID_TYPE` | valeur NULL ou de mauvais type transmise à une fonction `fn::sanitize_*` (la donnée aurait dû être validée avant) |
| `CORE_CONDITION_INVALID` | condition de forme invalide transmise à `fn::utils_condition_evaluate` (à contrôler à son enregistrement par `fn::utils_condition_check`) |

L'en-tête de chaque fichier de fonction liste ses cas de `THROW`.

---

## Moteur unique `fn::utils_engine_*`

Un seul moteur exécute les pipelines de tous les domaines. Il ne connaît aucune règle métier : chaque domaine lui passe une **closure** qui applique une étape (SurrealQL ne permet pas d'appeler une fonction d'après son nom, mais une fonction accepte une closure en paramètre).

### Utilisation par domaine

| Domaine | Catalogue | Points d'entrée | Résultat |
| :--- | :--- | :--- | :--- |
| `validations` | `fn::validation_step_catalog()` : 178 règles, une par validateur à une seule valeur | `fn::validation_pipeline_execute($value, $pipeline, $max_steps)`, `fn::validation_object_execute($value, $schema, $max_steps)` ; sans catalogue : `fn::validation_fields_execute($value, $fields, $unknown_keys)` (contrôles par fermetures, ci-dessous) ; pour les lots du worker : `fn::validation_checks_report($value, $checks)` (résultats déjà calculés, ci-dessous) | rapport `{ valid, value, errors, warnings, by_field }` ; ne lève jamais pour une donnée invalide |
| `sanitize` | `fn::sanitize_step_catalog()` : 94 règles, une par fonction de valeurs (sauf `date_range`), plus `default` | `fn::sanitize_pipeline_execute($value, $pipeline, $max_steps)`, `fn::sanitize_object_execute($value, $schema, $max_steps)` | valeur nettoyée ; donnée non nettoyable → `CORE_SANITIZE_INVALID_TYPE` |
| `security` | `fn::security_step_catalog()` : 22 règles (masquage et empreintes, détections, `permission_check`) | `fn::security_pipeline_execute($value, $pipeline, $max_steps)`, `fn::security_object_execute($value, $schema, $max_steps)` | `{ value, findings, score, decisions, allowed, errors }` |

* Une étape s'écrit `{ rule, options }` ; les options sont les paramètres de la fonction appelée. `required` (dans le catalogue) liste les options obligatoires.
* `validations` : un paramètre `option<…>` du validateur vaut NONE par défaut, les autres sont obligatoires. Les validateurs qui comparent plusieurs valeurs (`compare`, `date_range`, `time_range`, `coordinates`…) s'appellent directement. `fn::validation_dsl_compile($dsl)` convertit une description DSL (`required`, `nullable`, `default`, `type`, `min_length`, `max_length`, `min`, `max`, `pattern`, `enum`) en schéma du moteur ; la normalisation (trim, casse) relève de `sanitize`.
* Noms renommés, car `object` est une règle du moteur : `fn::validation_object` s'appelle `is_object`, et `fn::sanitize_object` s'appelle `object_or_empty`.

```surql
-- Valider puis nettoyer un objet
LET $schema = { fields: { email: { pipeline: [{ rule: "email", options: { max_length: 254 } }], required: true } }, unknown_keys: "strip" };
LET $report = fn::validation_object_execute($params, $schema, 20);
IF !$report.valid { RETURN fn::error_result("CONTACT_INVALID", $params.language, { fields: $report.by_field }); };
LET $clean = fn::sanitize_object_execute($report.value, { fields: { email: { pipeline: [{ rule: "lowercase" }] } } }, 20);
```

### Contrôles par fermetures : `fn::validation_fields_execute`

En SurrealDB 3.3, une définition de fonction est relue et réanalysée à chaque transaction, et
l'appel d'une fonction qui ne fait que lire charge tout son graphe d'appels :
`fn::validation_object_execute` fait charger les 178 validateurs du catalogue même si un seul
sert (7 à 9 ms au premier appel d'une transaction, puis 1,5 ms par objet). Pour une fonction
appelée souvent, `fn::validation_fields_execute($value, $fields, $unknown_keys)` valide le même
objet avec des contrôles remis par l'appelant, qui ne nomme que les validateurs qu'il utilise :

```surql
LET $report = fn::validation_fields_execute($params, {
    account: { checks: [|$v: any| fn::validation_record($v, "mail_account")], required: true },
    size: { checks: [|$v: any| fn::validation_integer($v, 1, 5368709120)], required: true },
    language: { checks: [|$v: any| fn::validation_language_code($v, false, NONE)], default: "fr" }
}, "reject");
IF !$report.valid { RETURN fn::error_result("MAIL_INVALID_PARAMETERS", NONE, { fields: $report.by_field }); };
```

* **Champ** : `{ checks, required, nullable, default }`, comme un champ de schéma du moteur, où
  `checks` (tableau de fermetures) remplace `pipeline`. Champ absent : valeur par défaut, sinon
  `CORE_VALIDATION_REQUIRED` s'il est exigé ; `NULL` : `CORE_VALIDATION_NULL` sauf `nullable`.
* **Contrôle** : une fermeture qui reçoit la valeur du champ (normalisée par le contrôle
  précédent) et rend le résultat d'un validateur (`{ valid, value, code, details }`). Les
  contrôles d'un champ s'arrêtent à la première erreur.
* **Objet imbriqué** : le contrôle rend le rapport d'un autre appel de la fonction ; ses erreurs
  passent sous le chemin du champ (`reception.spf`).
* **Éléments d'un tableau** : le contrôle rend un tableau de résultats ou de rapports, un par
  élément (`|$v: any| array::map($v, |$item: any| fn::validation_fields_execute($item, { … }, "reject"))`) ;
  leurs erreurs passent sous l'élément (`items[0].content`). La forme du tableau (type,
  longueur) se contrôle avant, par `fn::validation_array_length` par exemple.
* **Clés inconnues** (`$unknown_keys`) : `reject`, `strip` ou `keep`, comme `unknown_keys` d'un schéma.
* **Rapport** : `{ valid, value, errors, warnings, by_field }`, celui de
  `fn::validation_object_execute` pour les mêmes contrôles ; seul `errors[].rule` diffère (une
  fermeture n'a pas de nom de règle) : `required`, `nullable`, `unknown_keys`, `is_object`, ou
  `checks[<rang>]`, rang du contrôle en erreur.
* **Erreurs de programmation** : `CORE_INVALID_ARGUMENT` (aucun champ, définition invalide, clé
  de définition inconnue, contrôle qui ne rend pas un résultat), `CORE_UNSUPPORTED_OPTION`
  (`$unknown_keys` inconnu). Un contrôle qui n'est pas une fermeture est refusé par la base à
  son appel.
* **Limites** : pas de `when` ni de `one_of` (une fermeture écrit la condition), pas de catalogue,
  d'optimiseur ni de traces. Lire une valeur la recopie, fermetures comprises : une définition
  qui porte de grandes fermetures (objets imbriqués) coûte plus cher à chaque lecture, et pour
  les éléments d'un grand lot le coût monte avec la taille du lot.

Mesures (`scripts/bench/delivery/bench_delivery.py --only appels`, SurrealDB 3.3.4 en mémoire,
machine de développement à 4 cœurs, médianes de 100 transactions, premier appel de la
transaction puis deuxième) :

| Cas | `fn::validation_object_execute` | `fn::validation_fields_execute` | Validateurs appelés directement |
| :--- | :-: | :-: | :-: |
| Un champ (`record`) | 8,7 puis 1,3 ms | 0,7 puis 0,3 ms | — |
| Les 4 champs de `fn::mail_delivery_begin` | 10,2 puis 2,6 ms | 1,3 puis 0,8 ms | 0,3 puis 0,1 ms |

### Résultats déjà calculés : `fn::validation_checks_report`

Chaque contrôle de `fn::validation_fields_execute` est un appel de fermeture, qui recopie ses
variables : pour les éléments d'un lot, le coût par élément monte avec la taille du lot et celle
des valeurs. Une fonction du worker appelée par lots (éléments de `fn::mail_delivery_commit`)
appelle donc elle-même les validateurs, un par champ, et remet leurs résultats à
`fn::validation_checks_report($value, $checks)`, qui en fait le rapport sans aucune fermeture
quand tout est satisfait. Forme réservée à ces fonctions, sur décision du CTO (`.agents/AGENTS.md`
§5.7.8) ; ailleurs, `fn::validation_fields_execute`.

```surql
DEFINE FUNCTION OVERWRITE fn::stock_move_check($move: any) -> object {
    LET $labels = fn::validation_array_of_strings(IF $move.labels IS NONE { [] } ELSE { $move.labels }, true, NONE, 64);
    RETURN fn::validation_checks_report($move, {
        item: fn::validation_record($move.item, "stock_item"),
        quantity: fn::validation_integer($move.quantity, 1, 100000),
        note: fn::validation_optional_string($move.note, NONE, 500),
        labels: IF $labels.valid { fn::validation_array_length($labels.value, NONE, 20) } ELSE { $labels }
    });
};
-- Dans la fonction publique : la forme du tableau d'abord, puis un rapport par élément
LET $sized = fn::validation_array_length($params.moves, 1, 32);
LET $report = fn::validation_checks_report($params, {
    moves: IF $sized.valid { array::map($sized.value, |$move: any| fn::stock_move_check($move)) } ELSE { $sized },
    language: fn::validation_language_code(IF $params.language IS NONE { "fr" } ELSE { $params.language }, false, NONE)
});
IF !$report.valid { RETURN fn::error_result("STOCK_INVALID_PARAMETERS", NONE, { fields: $report.by_field }); };
```

* **`$checks`** : `{ <champ>: résultat }`, où le résultat a l'une des formes que rend un contrôle
  de `fn::validation_fields_execute` : résultat d'un validateur (`{ valid, value, code, details }`),
  rapport d'un objet imbriqué (erreurs sous le chemin du champ, `reception.spf`), ou tableau de
  l'un ou de l'autre (erreurs sous l'élément, `items[0].content`).
* **Champ exigé, facultatif, par défaut** : écrits par l'appelant. Un validateur appelé sur une
  valeur absente rend `CORE_VALIDATION_REQUIRED` et sur `NULL` `CORE_VALIDATION_NULL`, comme
  l'exécuteur ; un champ facultatif se contrôle par un validateur qui accepte `NONE`
  (`fn::validation_optional_string`) ou sur sa valeur par défaut
  (`IF $v IS NONE { <défaut> } ELSE { $v }` ; `??` remplacerait aussi `NULL`, que l'exécuteur
  refuse). Plusieurs contrôles d'un champ s'enchaînent par `IF $premier.valid { … } ELSE { $premier }`.
* **Clés inconnues** : toute clé de `$value` absente de `$checks` est refusée
  (`CORE_VALIDATION_NOT_ALLOWED`) ; il n'y a pas de mode `strip` ni `keep`.
* **Rapport** : `{ valid, value, errors, warnings, by_field }`, celui de
  `fn::validation_fields_execute` en mode `reject` pour les mêmes contrôles (mêmes codes, mêmes
  chemins, même `by_field` ; `errors[].rule` vaut `check`, `unknown_keys` ou `is_object`). `errors`
  et `warnings` sont gardés pour que le rapport se remette tel quel, comme résultat d'un champ, à
  l'une ou l'autre des deux fonctions ; ils ne coûtent rien quand tout est satisfait. `value` :
  valeurs normalisées ; un champ en erreur garde la valeur reçue.
* **Erreurs de programmation** : `CORE_INVALID_ARGUMENT` (`$checks` vide, résultat d'un champ qui
  n'est ni un résultat de validateur ni un rapport).

### Fonctionnement

* **Pipeline** : `fn::utils_engine_pipeline($steps, $catalog, $max_steps)` contrôle et normalise un pipeline contre un catalogue `[{ rule, cost, required, idempotent }]`.
* **État** : `{ value, issues, warnings, records, stop, path, parent }` (`fn::utils_engine_state`).
  * `fn::utils_engine_issue` ajoute une erreur et arrête le pipeline en cours.
  * `fn::utils_engine_warning` ajoute un avertissement.
  * `fn::utils_engine_record` ajoute une donnée propre au domaine (constat, décision).
* **Exécution** : `fn::utils_engine_run($state, $pipeline, $apply)`, où `$apply` est une closure `|$state, $step| …` qui renvoie le nouvel état ; `fn::utils_engine_run_batch` pour plusieurs valeurs.
* **Règles du moteur**, disponibles dans tout domaine :
  * `each` : sous-pipeline appliqué à chaque élément d'un tableau ;
  * `object` : schéma imbriqué ;
  * `when` : branche selon la valeur ou un champ voisin (`field`, `equals` ou `in`, `then`, `else`) ;
  * `one_of` : branches essayées dans l'ordre, arrêt à la première sans erreur.
* **Schéma** : `{ fields: { <champ>: { pipeline, required, nullable, default } }, unknown_keys: "reject" | "strip" | "keep" }`, contrôlé par `fn::utils_engine_schema` et appliqué par `fn::utils_engine_run_object`. `fn::utils_engine_schema_hash` en donne une empreinte (clé de cache, avec `fn::utils_cache_*`).
* **Rapport** : `fn::utils_engine_report` et `fn::utils_engine_report_merge` ; `by_field` regroupe les codes par chemin (`"$"` pour la racine).
* **Optimiseur** : `fn::utils_engine_optimize($pipeline, $catalog)` supprime une étape identique à la précédente si le catalogue déclare sa règle idempotente. C'est une liste fermée : `trim`, `trim_left`, `trim_right`, `lowercase`, `uppercase`, `collapse_whitespace` et `default` en `sanitize`, aucune en `validations` et `security`. L'optimiseur ne réordonne jamais les étapes.
* **Débogage** : `fn::utils_engine_trace`, `_debug_session`, `_debug_add`, `_debug_failed`, `_debug_slowest`, `_debug_summary`.
* **Mesure** : `fn::utils_engine_benchmark_sample`, `_run`, `_stats` (taux de réussite, min, max, moyenne, p50, p95, p99, débit), `_compare` (régression sur la moyenne ou le p95), `_report`.
* **Requête et réponse d'exécution** : `fn::utils_engine_request` et `fn::utils_engine_response`.

### Coût d'exécution

SurrealQL est interprété : chaque comparaison, appel de closure ou de fonction coûte de l'ordre
de la microseconde, et lire une variable en recopie la valeur (un catalogue de 178 règles coûte
environ 65 µs à chaque lecture). Le moteur limite donc le travail, sans changer son contrat :

* **Catalogue réduit** : `fn::utils_engine_schema` et `fn::utils_engine_pipeline` ne transmettent
  aux pipelines imbriqués qu'un catalogue réduit aux règles dont le nom figure dans le texte du
  schéma ou des étapes (catalogue de plus de 32 règles, noms faits de `[a-z0-9_]` ; sinon le
  catalogue entier). Une règle citée y figure toujours : contrôles et erreurs sont inchangés.
* **Définitions identiques normalisées une fois** : dans un schéma, deux champs de même
  définition (même représentation SurrealQL, types compris) partagent une normalisation ; une
  définition dont le texte contient « | » (fermeture possible) est toujours normalisée seule.
* **Aiguillage en deux niveaux** dans `fn::validation_step_apply` et `fn::sanitize_step_apply` :
  initiale de la règle, puis règle (une quinzaine de comparaisons au plus, au lieu de 177).
* **Opérations natives** plutôt que des closures (projections `$etats.issues`, filtres
  `[WHERE …]`, `array::complement`, `array::transpose`), valeurs lues une fois, appels imbriqués
  placés dans des `LET` ; une règle du domaine va directement à la closure `$apply`.
* **Tri** : `fn::utils_collection_sort_by` trie nativement (`array::sort::asc` / `desc`, n log n)
  des triplets `[clé, rang, élément]` ; le rang garde l'ordre d'origine des clés égales (tri
  stable) ; les éléments sans clé (NONE ou NULL) restent en fin, dans leur ordre d'origine.

Mesures (`scripts/bench/core/bench_core_engine.py`, SurrealDB 3.3.4 en mémoire, machine de
développement à 4 cœurs, durée d'un appel mesurée dans le serveur, médiane de 30 appels, 3 pour
le tri de l'ancienne version) ; « avant » : `--ref a1d358f0f`.

| Cas | Avant | Après |
| :--- | ---: | ---: |
| `fn::validation_object_execute`, 3 champs | 6,9 ms | 2,3 ms |
| `fn::validation_object_execute`, paramètres de `fn::mail_message_create` (schéma du module courrier, enveloppe typée comprise) | 100 ms | 17,4 ms |
| `fn::validation_pipeline_execute`, tableau de 3 chaînes (`each`) | 4,6 ms | 1,6 ms |
| `fn::sanitize_object_execute`, 2 champs | 2,7 ms | 1,4 ms |
| `fn::security_object_execute`, 2 champs | 2,2 ms | 1,4 ms |
| `fn::utils_collection_sort_by`, 1 000 objets | 6 900 ms | 15 ms |
| `fn::utils_collection_sort_by`, 10 000 objets | plus de 180 s (arrêté) | 160 ms |

La validation des paramètres de dépôt d'un message reste au-dessus de 10 ms : environ 8 ms de
normalisation du schéma (25 pipelines distincts) et 9 ms d'exécution (une centaine d'états et
d'étapes, chacun recopiant sa valeur et l'objet parent), soit 40 à 60 µs par étape. Aller
au-delà demanderait de ne plus normaliser le schéma à chaque appel (schéma normalisé gardé par
le module appelant), ce que le contrat actuel ne prévoit pas.

---

## Utilisation par les modules

Aucun module ne l'appelle encore. L'adoption se fera à la reprise de chaque module. Les modules `lyxal_error`, `lyxal_event`, `lyxal_pipeline_ingestion` et `lyxal_catalogue` le déclarent déjà comme dépendance (`>=0.1.0`).

---

## Tests

`scripts/ci/test_lyxal_core.py` démarre un serveur SurrealDB 3.3.4 jetable et :

1. charge les 488 fonctions et vérifie qu'elles sont toutes définies ;
2. vérifie que chaque fonction a son fichier `<nom>.test.surql`, et inversement ;
3. exécute chaque fichier de tests.

Tous les fichiers de tests sont au format « assertions » :

```surql
-- lyxal-test: assertions

-- test: adresse valide, espaces retirés
RETURN fn::validation_email("  contact@example.com ", 254)
    == { valid: true, value: "contact@example.com", code: NONE, details: {} };

-- test: adresse invalide
RETURN fn::validation_email("pas-un-email", 254).code == "CORE_VALIDATION_FORMAT";

-- test: longueur maximale négative
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_email("contact@example.com", -1);
```

* La ligne `-- lyxal-test: assertions` figure dans les 30 premières lignes ; un fichier sans elle fait échouer la CI.
* Chaque bloc `-- test: <description>` contient **exactement une** instruction, exécutée seule. Elle doit renvoyer `true`, ou lever exactement l'erreur annoncée par `-- attendu-erreur: <CODE>`.
* Tout autre résultat fait échouer la CI, avec le nom du bloc : `false`, une autre valeur, une autre erreur, une erreur non annoncée, plusieurs instructions, une instruction hors bloc, aucun bloc.

Autres scripts :

* `scripts/ci/test_lyxal_core_selftest.py` vérifie que le banc accepte les bons tests et rejette les mauvais (fixtures dans `scripts/ci/fixtures/lyxal_core_tests/`).
* `scripts/ci/validate_surql.sh` vérifie la syntaxe de tout le SurrealQL du dépôt et refuse toute déclaration `LET` d'un nom de variable réservé par SurrealDB 4.0 (`$event`, `$before`, `$after`, `$value`, `$input`, `$parent`, `$self`, `$this`).
* Les trois scripts font partie de la CI (job « SurrealQL ») et de `scripts/ci/ci_local.sh`.
