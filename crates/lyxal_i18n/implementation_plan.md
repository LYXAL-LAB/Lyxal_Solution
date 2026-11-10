# Plan détaillé — lot 2 `lyxal_i18n` : traductions

Lot 2 du programme `lyxal_i18n` (`implementation_plan.md` à la racine, décisions Q1 à Q7).
État du lot 1 : [`README.md`](README.md). Aucune ligne de code avant la validation de ce plan
(`.agents/AGENTS.md` §3). Plan supprimé une fois exécuté.

## 1. Objectif

* Espaces de noms, clés et traductions en base, avec surcharges par organisation.
* États de relecture, indicateur « obsolète » quand le texte source change.
* Contrôles à l'écriture : paramètres et formes de pluriel (décision Q4).
* Résolution d'une clé avec repli (`fn::i18n_resolve`, `fn::i18n_resolve_many`).
* Aucun consommateur n'est basculé dans ce lot (lot 5) ; le rendu des messages est le lot 3.

## 2. Fonctions `lyxal_core` réutilisées

* Moteur `fn::validation_object_execute` ; règles `snake_case_name`, `lyxal_module_name`,
  `lyxal_event_name` (voir L3), `locale`, `record`, `required_string`, `optional_string`, `enum`,
  `boolean`, `integer`, `array_objects`, `array_of_strings`, `array_length`, `array_unique`,
  `identifier` ; `fn::sanitize_lowercase` pour les recherches.
* Empreinte du texte source : `crypto::blake3` de SurrealDB, comme les autres modules.
* Aucune extension du Core demandée, sauf décision contraire sur L3.

## 3. Modèle

### `i18n_namespace` (identifiant = clé : `i18n_namespace:base`)

| Champ | Type | Règle |
| :--- | :--- | :--- |
| `key` | `string` | `READONLY`, `snake_case`, 1 à 64 caractères |
| `module` | `string` | module propriétaire (`lyxal_base`) |
| `description` | `option<string>` | 1024 caractères au plus |
| `source_locale` | `record<i18n_locale>` | langue des textes sources ; par défaut celle des réglages ; `READONLY` |
| `created_at`, `updated_at` | `datetime` | |

### `i18n_key`

| Champ | Type | Règle |
| :--- | :--- | :--- |
| `namespace` | `record<i18n_namespace>` | `REFERENCE ON DELETE REJECT`, `READONLY` |
| `name` | `string` | segments en minuscules séparés par des points (`unite.metre`), 128 caractères au plus, `READONLY` |
| `full_key` | `string` | calculé : `<espace>.<nom>` (`base.unite.metre`) ; index unique |
| `description` | `option<string>` | contexte pour le traducteur |
| `params` | `array<object>` | paramètres attendus `{ name, type }`, 20 au plus ; `type` parmi `string`, `number`, `datetime` |
| `max_length` | `option<int>` | 1 à 10 000 |
| `created_at`, `updated_at` | `datetime` | |

### `i18n_translation`

| Champ | Type | Règle |
| :--- | :--- | :--- |
| `key` | `record<i18n_key>` | `REFERENCE ON DELETE CASCADE`, `READONLY` |
| `locale` | `record<i18n_locale>` | `READONLY` |
| `tenant` | `option<record<auth_organization>>` | `NONE` : installation ; `REFERENCE ON DELETE CASCADE`, `READONLY` |
| `scope_key` | `string` | calculé : `installation` ou clé de l'organisation ; index unique (`key`, `locale`, `scope_key`) |
| `text` | `string` | 1 à 10 000 caractères |
| `syntax` | `string` | `icu_mf1` (défaut) ou `plain` (texte rendu tel quel, sans paramètre) |
| `state` | `string` | `translated` ou `reviewed` |
| `outdated` | `bool` | posé par la base quand le texte source change |
| `source_hash` | `string` | empreinte du texte source au moment de l'écriture |
| `updated_by` | `option<record<auth_identity>>` | `REFERENCE ON DELETE UNSET` |
| `created_at`, `updated_at` | `datetime` | |

* **Texte source** : la traduction de l'installation dans la langue source de l'espace de noms.
  Elle est créée avec la clé et ne peut pas être supprimée. Une clé a donc toujours un texte.
* **État `untranslated`** : absence de ligne ; `fn::i18n_translation_list` le restitue.
* **Surcharge d'organisation** : ligne avec `tenant` ; elle ne change que le texte.

### `i18n_missing_key`

Clé demandée mais non déclarée : `full_key`, `locale`, `first_seen_at`, `last_seen_at`. Unique sur
(`full_key`, `locale`). Écrite seulement par la session système (voir L2), supprimée quand la clé
est créée.

### Permissions

| Table | Lecture | Écriture |
| :--- | :--- | :--- |
| `i18n_namespace`, `i18n_key` | ouverte | `i18n.translation.manage` |
| `i18n_translation` de l'installation | ouverte | `i18n.translation.manage` |
| `i18n_translation` d'une organisation | session système, `i18n.translation.manage`, ou session dont l'organisation active est ce `tenant` | `i18n.translation.manage`, ou `i18n.organization.translation.manage` sur ce `tenant` |
| `i18n_missing_key` | `i18n.translation.manage` | session système |

`outdated`, `source_hash` et `scope_key` ne sont pas modifiables par une session
(`PERMISSIONS FOR update NONE`, valeurs posées par la base).

Nouvelles permissions (seed `i18n_auth.surql`) : `i18n.translation.manage` (installation, rôle
`platform_admin`) et `i18n.organization.translation.manage` (organisation, rôle
`organization_admin`).

## 4. Contrôle d'un message (Q4)

Fonction interne `fn::i18n_message_inspect($text)` : lit un message MessageFormat 1 caractère
par caractère (les accolades alternent : argument, puis sous-message), en tenant compte des
apostrophes d'échappement. Elle renvoie `{ balanced, arguments: [{ name, kind, selectors }] }`,
où `kind` vaut `none`, `number`, `date`, `time`, `plural`, `selectordinal` ou `select`.

`fn::i18n_message_check` applique ensuite, pour un texte `icu_mf1` :

| Contrôle | Résultat |
| :--- | :--- |
| accolades non équilibrées, nom ou type d'argument invalide | refus |
| argument absent des `params` de la clé | refus |
| type incompatible (`plural`, `selectordinal`, `number` : `number` ; `date`, `time` : `datetime`) | refus |
| `plural`, `selectordinal`, `select` sans branche `other` | refus |
| catégorie de pluriel inconnue de la langue cible (`few` en français) | refus |
| catégorie de la langue cible absente (`many` en français) | avertissement (voir L1) |
| paramètre de la clé non utilisé | avertissement |
| longueur supérieure à `max_length` | refus |

Un texte `plain` ne subit que le contrôle de longueur. Un refus renvoie
`I18N_TRANSLATION_INVALID` avec `details.problems` ; les avertissements sont renvoyés dans
`data.warnings`. La syntaxe complète reste vérifiée par Rust au rendu (lot 3).

## 5. Fonctions publiques (`fn::i18n_*($params: object)`)

| Fonction | Paramètres | Résultat | Droits |
| :--- | :--- | :--- | :--- |
| `i18n_namespace_create` | **key**, **module**, `description`, `source_locale` | espace de noms | `i18n.translation.manage` |
| `i18n_namespace_list` | `limit`, `start` | `{ items, total }` | tous |
| `i18n_key_create` | **namespace**, **name**, **source_text**, `syntax`, `description`, `params`, `max_length` | `{ key, warnings }` (clé et texte source créés ensemble) | `i18n.translation.manage` |
| `i18n_key_update` | **key**, `description`, `params`, `max_length` | clé ; le texte source est recontrôlé avec les nouveaux paramètres | `i18n.translation.manage` |
| `i18n_key_delete` | **key** | `{ deleted, translations }` | `i18n.translation.manage` |
| `i18n_key_list` | `namespace`, `search`, `limit`, `start` | `{ items, total }` | tous |
| `i18n_translation_set` | **key**, **locale**, **text**, `syntax`, `tenant` | `{ translation, warnings }` ; état `translated`, `outdated` remis à faux | selon `tenant` |
| `i18n_translation_review` | **key**, **locale**, **reviewed**, `tenant` | traduction ; refusé si obsolète (`I18N_TRANSLATION_OUTDATED`) | selon `tenant` |
| `i18n_translation_delete` | **key**, **locale**, `tenant` | `{ deleted }` ; refusé pour le texte source (`I18N_SOURCE_REQUIRED`) | selon `tenant` |
| `i18n_translation_list` | **locale**, `namespace`, `tenant`, `state`, `outdated`, `search`, `limit`, `start` | `{ items: [{ key, source_text, text, state, outdated, overridden }], total }` | lecture |
| `i18n_resolve` | **key**, **locale**, `tenant` | `{ key, text, syntax, locale, overridden, missing }` | tous |
| `i18n_resolve_many` | **keys** (500 au plus), **locale**, `tenant` | tableau du même objet, dans l'ordre demandé | tous |
| `i18n_missing_key_list` | `limit`, `start` | `{ items, total }` | `i18n.translation.manage` |

`key` désigne la clé complète (`base.unite.metre`). `tenant` : pour une écriture, l'organisation
surchargée ; pour une résolution, l'organisation dont les surcharges s'appliquent, par défaut
l'organisation active de l'appelant. Seule la session système peut résoudre pour une autre
organisation.

**Résolution.** Chaîne des langues : la langue demandée et son repli CLDR
(`fn::i18n_locale_chain`), puis la langue par défaut et son repli, puis la langue source de
l'espace de noms. Pour chaque langue : surcharge de l'organisation, puis texte de l'installation.
Le texte source garantit un résultat pour toute clé déclarée. Clé non déclarée : `text` = la clé,
`missing: true`.

## 6. Événements et gardes (`DEFINE EVENT`)

* `i18n.translation.updated` `{ key, locale, tenant }` : création ou changement de texte.
* **Obsolescence** : quand le texte source change, la base pose `outdated = true` sur les autres
  traductions de la clé dont l'empreinte diffère et ramène leur état à `translated`. Un seul
  événement `i18n.translation.outdated` `{ key, count }` par changement.
* `i18n.key.missing` `{ key, locale }` : à la création d'une ligne `i18n_missing_key`, donc une
  fois par clé et par langue.
* Gardes : le texte source ne se supprime pas tant que la clé existe ; une langue source d'un
  espace de noms ne se désactive pas (complète la garde du lot 1).

## 7. Master data d'erreurs (`error/traductions/`)

`I18N_NAMESPACE_NOT_FOUND`, `I18N_NAMESPACE_EXISTS`, `I18N_KEY_NOT_FOUND`, `I18N_KEY_EXISTS`,
`I18N_TRANSLATION_NOT_FOUND`, `I18N_TRANSLATION_INVALID`, `I18N_TRANSLATION_OUTDATED`,
`I18N_SOURCE_REQUIRED`. Les codes du lot 1 sont réutilisés (`I18N_INVALID_PARAMETERS`,
`I18N_PERMISSION_DENIED`, `I18N_WRITE_FORBIDDEN`, `I18N_LOCALE_NOT_FOUND`).

## 8. Rust (`crates/lyxal_i18n/src/`)

* `models/translation.rs` : `Namespace`, `NamespaceCreateParams`, `TranslationKey`, `KeyParam`,
  `KeyCreateParams` / `KeyCreated`, `KeyUpdateParams`, `KeyDeleteParams` / `KeyDeleted`,
  `KeyListParams` / `KeyList`, `Translation`, `TranslationSetParams` / `TranslationSet`,
  `TranslationReviewParams`, `TranslationDeleteParams` / `TranslationDeleted`,
  `TranslationListParams` / `TranslationList`, `ResolveParams`, `ResolveManyParams`,
  `ResolvedText`, `MissingKeyListParams` / `MissingKeyList`.
* `I18nStore` : un wrapper d'une ligne par fonction publique.
* Aucun worker, aucune sonde ; aucun changement de l'hôte dans ce lot.

## 9. Tests

* **Banc SurrealQL** :
  * `cles.test.surql` : espaces de noms, clés, doublons, paramètres, suppression en cascade, droits.
  * `traductions.test.surql` :
    * écriture, relecture, suppression ; texte source protégé ;
    * surcharge d'une organisation : prioritaire pour elle, invisible et non modifiable pour
      une autre ; supprimée avec l'organisation ;
    * obsolescence après changement du texte source, levée par une nouvelle écriture ;
    * écritures refusées sans permission ; champs `outdated` et `source_hash` non modifiables.
  * `controles.test.surql` : chaque ligne du tableau du §4, apostrophes d'échappement, pluriels de
    `fr`, `en`, `ar` et `pl`.
  * `resolution_cles.test.surql` : repli `fr-CA → fr`, langue par défaut, langue source, clé
    manquante (ligne et événement uniques sous session système, rien sous session utilisateur),
    `resolve_many` dans l'ordre demandé, résolution pour une autre organisation refusée.
* **Rust** : désérialisation des résultats sur base embarquée (`tests/it/`).
* `scripts/ci/ci_local.sh`.

## 10. Documentation

`README.md` (modèle, contrôles, résolution, fonctions, événements), `ROADMAP.md` (lot 2 retiré),
plan du programme à la racine (ligne **2** « Réalisé »).

## 11. Questions au CTO

| # | Question | Recommandation |
| :- | :--- | :--- |
| L1 | Formes de pluriel. Le programme prévoyait d'exiger **toutes** les formes de la langue cible. En français, la forme `many` ne sert qu'aux millions : l'exiger bloquerait presque toutes les traductions | `other` obligatoire, forme inconnue de la langue refusée, forme manquante signalée par un **avertissement** (MessageFormat utilise alors `other`) |
| L2 | Clé manquante. Enregistrer chaque clé inconnue demandée par n'importe quelle session permettrait de remplir la base avec des clés au hasard | Ligne et événement `i18n.key.missing` seulement pour les appels de la **session système** (hôte, workers) ; une session utilisateur reçoit `missing: true` sans rien écrire |
| L3 | Format du nom d'une clé (`unite.metre`). La règle `lyxal_event_name` de `lyxal_core` a exactement ce format (segments en minuscules séparés par des points), mais son nom parle d'événements | La réutiliser, sans créer une règle jumelle dans le Core |
| L4 | Syntaxe `plain` en plus de `icu_mf1`, pour les textes sans paramètre qui contiennent des accolades (exemples, formules) | Oui |
