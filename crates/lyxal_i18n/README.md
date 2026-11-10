# Lyxal I18n

Module du Noyau Technique de Lyxal OS : **langues, traductions et formats régionaux**. Réalisé :
référentiel des langues issu d'Unicode CLDR, choix de la langue d'une requête, clés et
traductions avec surcharges par organisation. Les règles vivent dans SurrealDB (fonctions
`fn::i18n_*`) ; le crate Rust fournit les appels typés (`I18nStore`) et la lecture de
`Accept-Language`. Le rendu des messages (pluriels, dates, nombres) est le lot suivant. Sources et choix :
[`RECHERCHE_SOURCES.md`](RECHERCHE_SOURCES.md) ; lots suivants dans [`ROADMAP.md`](ROADMAP.md).

## 1. Modèle

| Table | Contenu |
| :--- | :--- |
| `i18n_locale` | une langue par étiquette BCP 47 canonique (`i18n_locale:⟨fr-CA⟩`) : langue, script, région, nom en anglais et dans la langue, sens d'écriture, catégories de pluriel cardinal et ordinal, chaîne de repli CLDR, `active`, version CLDR |
| `i18n_settings` | enregistrement `i18n_settings:installation` : langue par défaut et langue source (toutes deux actives) |

* **Référentiel** : 924 langues de CLDR 49 (langues publiées et langues « par défaut » comme
  `fr-FR` ou `zh-Hant-TW`) ; les variantes (`ca-ES-valencia`) sont écartées. Seed généré par
  `scripts/i18n/generate_locales.py` à partir des paquets officiels `cldr-json`, à relancer
  seulement à une montée de version de CLDR.
* **Chaîne de repli** : langues parentes de CLDR, pas une simple troncature
  (`es-MX → es-419 → es`, `en-AU → en-001 → en`) ; un script peu probable ne se replie pas sur
  la langue seule (`zh-Hant` ne se replie pas sur `zh`, écrit en Hans).
* **Langues actives** : `fr` (par défaut, source) et `en` à l'installation. Seul `active` se
  modifie ; les données CLDR sont protégées par les permissions des champs. La langue par défaut
  et la langue source ne se désactivent pas (fonction et garde de la base,
  `I18N_LOCALE_DEFAULT_REQUIRED`).
* **Droits** : lecture ouverte ; activation et réglages par la permission d'installation
  `i18n.locale.manage`, accordée au rôle `platform_admin` de `lyxal_auth`.

## 2. Choix de la langue

`fn::i18n_locale_resolve({ candidates })` reçoit au plus 20 étiquettes par ordre de préférence.
Pour chaque candidat, mis sous forme canonique (règle `locale` de `lyxal_core`, invalides
ignorés), la première langue active de sa chaîne de repli est retenue (correspondance « lookup »
de la RFC 4647 ; troncature pour une étiquette hors référentiel). Sans résultat : langue par
défaut, `matched: false`. Résultat : `{ locale, language, fallback, matched }`, où `language`
est la langue seule (ISO 639, deux ou trois lettres : `fil`, `haw`) et `fallback` la chaîne de
repli jusqu'à la langue par défaut. L'hôte passe `language` à `fn::error_result`, qui retombe sur
la langue de repli de la définition pour une langue sans traduction.

L'hôte (`lyxal-server`) rassemble les candidats : trait `locale` de l'identité du jeton, langue
de son organisation active (`auth_organization.locale`), puis `Accept-Language` trié par poids
(`accept_language::candidates`). `lyxal_i18n` ne lit ni l'identité ni l'organisation.

## 3. Clés et traductions

| Table | Contenu |
| :--- | :--- |
| `i18n_namespace` | espace de noms d'un module (`i18n_namespace:base`) : module propriétaire, langue source (active, non désactivable) |
| `i18n_key` | clé (`i18n_key:⟨base.unite.metre⟩`) : espace de noms, nom en segments séparés par des points, contexte pour le traducteur, paramètres attendus `[{ name, type }]` (`string`, `number`, `datetime`), longueur maximale |
| `i18n_translation` | texte d'une clé dans une langue, identifié par `[clé, langue, portée]` : texte de l'installation (`tenant` absent) ou surcharge d'une organisation ; syntaxe `icu_mf1` ou `plain`, état `translated` ou `reviewed`, `outdated`, empreinte du texte source |
| `i18n_missing_key` | clés demandées par l'hôte ou un worker mais non déclarées |

* **Texte source** : traduction de l'installation dans la langue source de l'espace de noms
  (`is_source`). Créé avec la clé, il ne se supprime pas tant que la clé existe : une clé déclarée
  a toujours un texte.
* **Surcharge d'une organisation** : même table avec `tenant` ; elle ne change que le texte, est
  lue par la seule organisation concernée et part avec elle (`REFERENCE ON DELETE CASCADE`).
* **États** (modèle Tolgee) : non traduit (aucune ligne), `translated`, `reviewed`.
* **Obsolescence** : quand le texte source change, la base marque `outdated` les autres textes
  de la clé et les ramène à `translated` ; un texte obsolète ne peut pas être marqué relu. Une
  nouvelle écriture, même du même texte, lève l'obsolescence. `outdated` et `source_hash` sont
  posés par la base, jamais par une session.
* **Droits** : espaces de noms, clés et textes de l'installation par `i18n.translation.manage`
  (rôle `platform_admin`) ; surcharges de son organisation par
  `i18n.organization.translation.manage` (rôle `organization_admin`) ; lecture ouverte, sauf les
  surcharges.

### Contrôle d'un texte

À chaque écriture, un texte `icu_mf1` est lu caractère par caractère par la base
(`fn::i18n_message_inspect` : arguments, branches, apostrophes d'échappement), puis contrôlé
(`fn::i18n_message_check`). La syntaxe complète reste vérifiée par le rendu Rust.

| Contrôle | Résultat |
| :--- | :--- |
| accolades non équilibrées (`unbalanced_braces`), nom d'argument invalide (`invalid_argument`), type hors de `number`, `date`, `time`, `plural`, `selectordinal`, `select` (`unsupported_type`) | refus |
| argument absent des paramètres de la clé (`unknown_argument`) | refus |
| type incompatible avec le paramètre (`type_mismatch`) | refus |
| `plural`, `selectordinal` ou `select` sans branche `other` (`missing_other`) | refus |
| catégorie de pluriel inconnue de la langue cible (`unknown_category`) | refus |
| longueur supérieure à celle de la clé (`too_long`) | refus |
| catégorie de la langue cible absente (`missing_category`), paramètre non utilisé (`unused_parameter`) | avertissement |

Un refus renvoie `I18N_TRANSLATION_INVALID` (`details.problems`) ; les avertissements sont dans
`data.warnings`. Un texte `plain` ne subit que le contrôle de longueur.

### Résolution d'une clé

`fn::i18n_resolve({ key, locale, tenant })` parcourt la langue demandée et son repli CLDR, puis
la langue par défaut et son repli, puis la langue source de l'espace de noms. Pour chaque
langue : surcharge de l'organisation, puis texte de l'installation (une langue plus précise
passe donc avant une surcharge dans une langue moins précise). L'organisation est celle de
`tenant`, par défaut l'organisation active de l'appelant ; seule la session système résout pour
une autre organisation. Résultat : `{ key, text, syntax, locale, overridden, missing }`.

Clé non déclarée : `text` vaut la clé, `missing: true`. La clé n'est notée dans
`i18n_missing_key` (et l'événement `i18n.key.missing` publié, une fois par clé et par langue) que
pour un appel de la session système ; elle en sort quand la clé est déclarée.

## 4. Fonctions publiques (`fn::i18n_*($params: object)`)

| Fonction | Paramètres | Résultat | Droits |
| :--- | :--- | :--- | :--- |
| `i18n_locale_list` | `active`, `search` (début de l'étiquette ou partie d'un nom), `limit` (1 à 1000, 100), `start` | `{ items, total }` | tous |
| `i18n_locale_get` | **locale** | langue ou `I18N_LOCALE_NOT_FOUND` | tous |
| `i18n_locale_activate` | **locale** | langue ; publie `i18n.locale.activated` | `i18n.locale.manage` |
| `i18n_locale_deactivate` | **locale** | langue ; publie `i18n.locale.deactivated` ; refusé pour la langue par défaut, la langue source ou celle d'un espace de noms | `i18n.locale.manage` |
| `i18n_settings_get` | — | `{ default_locale, source_locale }` | tous |
| `i18n_settings_update` | `default_locale`, `source_locale` | idem ; langue inconnue ou inactive refusée | `i18n.locale.manage` |
| `i18n_locale_resolve` | `candidates` (0 à 20) | `{ locale, language, fallback, matched }` | tous |
| `i18n_namespace_create` | **key**, **module**, `description`, `source_locale` | espace de noms | `i18n.translation.manage` |
| `i18n_namespace_list` | `limit`, `start` | `{ items, total }` | tous |
| `i18n_key_create` | **namespace**, **name**, **source_text**, `syntax`, `description`, `params`, `max_length` | `{ key, warnings }` | `i18n.translation.manage` |
| `i18n_key_update` | **key**, `description`, `params`, `max_length`, `clear` (`description`, `max_length`) | clé ; champ absent conservé ; texte source recontrôlé | `i18n.translation.manage` |
| `i18n_key_delete` | **key** | `{ deleted, translations }` | `i18n.translation.manage` |
| `i18n_key_list` | `namespace`, `search`, `limit`, `start` | `{ items, total }` | tous |
| `i18n_translation_set` | **key**, **locale**, **text**, `syntax`, `tenant` | `{ translation, warnings }` | selon `tenant` |
| `i18n_translation_review` | **key**, **locale**, **reviewed**, `tenant` | texte | selon `tenant` |
| `i18n_translation_delete` | **key**, **locale**, `tenant` | `{ deleted }` | selon `tenant` |
| `i18n_translation_list` | **locale**, `namespace`, `tenant`, `state`, `outdated`, `search`, `limit`, `start` | `{ items: [{ key, source_text, text, state, outdated, overridden }], total }` | lecture de la portée |
| `i18n_resolve` | **key**, **locale**, `tenant` | `{ key, text, syntax, locale, overridden, missing }` | tous |
| `i18n_resolve_many` | **keys** (500 au plus), **locale**, `tenant` | tableau du même objet, dans l'ordre demandé | tous |
| `i18n_missing_key_list` | `limit`, `start` | `{ items: [{ key, locale, first_seen_at, last_seen_at }], total }` | `i18n.translation.manage` |

`key` est la clé complète (`base.unite.metre`) ; `tenant` est une organisation
(`auth_organization:<clé>`). Toutes acceptent `language` (langue des messages d'erreur sur deux
ou trois lettres, comme celle que renvoie `fn::i18n_locale_resolve` ; `fr` par défaut), valident
leurs entrées par le moteur de `lyxal_core` et vérifient leur écriture principale
(`I18N_WRITE_FORBIDDEN`).

Erreurs : `I18N_INVALID_PARAMETERS`, `I18N_PERMISSION_DENIED`, `I18N_WRITE_FORBIDDEN`,
`I18N_LOCALE_NOT_FOUND`, `I18N_LOCALE_INACTIVE`, `I18N_LOCALE_DEFAULT_REQUIRED`,
`I18N_NAMESPACE_NOT_FOUND`, `I18N_NAMESPACE_EXISTS`, `I18N_KEY_NOT_FOUND`, `I18N_KEY_EXISTS`,
`I18N_TRANSLATION_NOT_FOUND`, `I18N_TRANSLATION_INVALID`, `I18N_TRANSLATION_OUTDATED`,
`I18N_SOURCE_REQUIRED`.

Fonctions internes au module : `fn::i18n_locale_set_active`, `fn::i18n_locale_chain`,
`fn::i18n_can_read`, `fn::i18n_can_translate`, `fn::i18n_message_*`,
`fn::i18n_translation_target`, `fn::i18n_resolve_scope`, `fn::i18n_resolve_text`.

## 5. Événements

Publiés par `DEFINE EVENT` via `fn::event_publish` (une publication refusée annule la
modification) :

| Événement | Charge utile | Quand |
| :--- | :--- | :--- |
| `i18n.locale.activated`, `i18n.locale.deactivated` | `{ locale }` | changement d'activation |
| `i18n.translation.updated` | `{ key, locale, tenant }` | texte créé ou réécrit |
| `i18n.translation.outdated` | `{ key, count }` | texte source modifié : un événement, avec le nombre de textes devenus obsolètes |
| `i18n.key.missing` | `{ key, locale }` | première demande d'une clé non déclarée par la session système |

## 6. Rust

* `I18nStore` (`Surreal<Any>`, `LyxalSurrealCall`) : un appel typé par fonction publique ;
  modèles dans `models/` (`Locale`, `Settings`, `ResolvedLocale`, `Namespace`, `TranslationKey`,
  `KeyParam`, `Translation`, `TranslationRow`, `ResolvedText`, `MessageIssue`, `MissingKey` et
  leurs paramètres).
* `accept_language::candidates(header)` : étiquettes par poids décroissant (ordre d'origine à
  poids égal), sans `*` ni poids nul, 20 au plus ; aucune validation (faite par SurrealQL).
* Hébergé par `lyxal-server` comme module de manifeste (ni worker ni sonde propre).

## 7. Vérification

* Banc SurrealQL `tests/` : `langues`, `parametres`, `resolution` (lot 1) ; `cles`,
  `traductions`, `controles`, `resolution_cles` : chaque fonction, droits par portée, isolation
  entre organisations, obsolescence, contrôles par langue (`fr`, `en`, `ar`, `pl`), repli, clé
  manquante, événements.
* Tests Rust : `accept_language` ; `tests/it/` appelle chaque fonction par `I18nStore` sur base
  embarquée ; routes de l'hôte (`apps/lyxal-server/tests/it/auth_routes.rs`) pour le choix de
  la langue.

## 8. Licences

Données Unicode CLDR 49 sous licence Unicode-3.0 (seed généré). Tolgee, Weblate et Pontoon
servent de modèle de conception seulement, sans code repris.
