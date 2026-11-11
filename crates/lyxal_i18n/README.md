# Lyxal I18n

Module du Noyau Technique de Lyxal OS : **langues, traductions et formats régionaux** :
référentiel des langues issu d'Unicode CLDR, choix de la langue d'une requête, clés et
traductions avec surcharges par organisation, rendu des messages, des nombres, des dates et des
montants, échange des textes par fichier. Les règles sur les données vivent dans SurrealDB (fonctions `fn::i18n_*`) ; le rendu
est en Rust (ICU4X), car SurrealDB n'a pas ICU. Sources et choix :
[`MODELE_SOURCES.md`](MODELE_SOURCES.md) ; évolutions à venir dans [`ROADMAP.md`](ROADMAP.md).

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
| `i18n_key` | clé (`i18n_key:⟨base.unite_m⟩`) : espace de noms, nom en segments séparés par des points, contexte pour le traducteur, paramètres attendus `[{ name, type }]` (`string`, `number`, `datetime`), longueur maximale |
| `i18n_translation` | texte d'une clé dans une langue, identifié par `[clé, langue, portée]` : texte de l'installation (`tenant` absent) ou surcharge d'une organisation ; syntaxe `icu_mf1` ou `plain`, état `translated` ou `reviewed`, `outdated`, empreinte du texte source |
| `i18n_missing_key` | clés demandées par l'hôte ou un worker mais non déclarées |

* **Texte source** : traduction de l'installation dans la langue source de l'espace de noms
  (`is_source`). Créé avec la clé, il ne se supprime pas tant que la clé existe : une clé déclarée
  a toujours un texte.
* **Surcharge d'une organisation** : même table avec `tenant` ; elle ne change que le texte, est
  lue par la seule organisation concernée et part avec elle (`REFERENCE ON DELETE CASCADE`).
* **Identifiants fixés par le contenu** : la base refuse (`I18N_WRITE_FORBIDDEN`) un espace de
  noms, une clé ou un texte créé sous un identifiant qui ne correspond pas à sa clé, sa langue
  et sa portée ; une surcharge ne peut donc pas occuper l'emplacement d'un texte de
  l'installation ou d'une autre organisation.
* **États** (modèle Tolgee) : non traduit (aucune ligne), `translated`, `reviewed`.
* **Obsolescence** : quand le texte source change, la base marque `outdated` les autres textes
  de la clé et les ramène à `translated` ; un texte obsolète ne peut pas être marqué relu. Une
  nouvelle écriture, même du même texte, lève l'obsolescence. La règle vaut aussi pour une
  modification directe du texte, hors `fn::i18n_translation_set`. `outdated` et `source_hash` sont
  posés par la base, jamais par une session.
* **Droits** : espaces de noms, clés et textes de l'installation par `i18n.translation.manage`
  (rôle `platform_admin`) ; surcharges de son organisation par
  `i18n.organization.translation.manage` (rôle `organization_admin`) ; lecture ouverte, sauf les
  surcharges, lues par leur organisation. `i18n.translation.read` (aucun rôle : comptes de
  service, comme le worker d'envoi de `lyxal_notification`) lit et résout les textes de toute
  organisation, sans rien écrire.

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

### Modules qui utilisent les clés

| Module | Espace de noms | Usage |
| :--- | :--- | :--- |
| `lyxal_base` | `base` | libellé des unités (`base.unite_<code>`) et des types d'unités (`base.unite_type_<code>`), rendu par `fn::base_unite_get`, `_list` et `fn::base_unite_type_get`, `_list` |
| `lyxal_notification` | `notification` | phrases des e-mails du système, appelées par `t("clé")` dans les gabarits et lues à la réservation d'un envoi |

Ces modules créent leurs clés dans leurs propres seeds et n'appellent que les fonctions
publiques de `lyxal_i18n`.

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
| `i18n_export` | **locale**, `namespace`, `tenant`, `limit` (500), `start` | `{ items: [{ key, namespace, description, params, max_length, source_locale, source_text, source_syntax, text, syntax, state, outdated, overridden }], total }` | lecture de la portée |
| `i18n_import` | **locale**, **entries** `[{ key, text, syntax }]` (500 au plus), `tenant`, `overwrite_reviewed`, `dry_run` | `{ created, updated, unchanged, skipped: [{ key, reason }], invalid: [{ key, problems }] }` | écriture de la portée |
| `i18n_translation_scan` | `limit` (500), `start` | `{ items: [{ key, locale, tenant, text, syntax }], total }` : tous les textes, toutes portées | `i18n.translation.manage` |

`key` est la clé complète (`base.unite_m`) ; `tenant` est une organisation
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
`fn::i18n_translation_target`, `fn::i18n_resolve_scope`, `fn::i18n_resolve_text`,
`fn::i18n_import_entry`.

## 5. Événements

Publiés par `DEFINE EVENT` via `fn::event_publish` (une publication refusée annule la
modification) :

| Événement | Charge utile | Quand |
| :--- | :--- | :--- |
| `i18n.locale.activated`, `i18n.locale.deactivated` | `{ locale }` | changement d'activation |
| `i18n.translation.updated` | `{ key, locale, tenant }` | texte créé ou réécrit |
| `i18n.translation.outdated` | `{ key, count }` | texte source modifié : un événement, avec le nombre de textes devenus obsolètes |
| `i18n.key.missing` | `{ key, locale }` | première demande d'une clé non déclarée par la session système |

## 6. Rendu (Rust, `format/`)

`Formatter::new(locale)` rend pour une langue, avec les données CLDR de **toutes** les langues
embarquées par ICU4X (une langue sans données propres suit son repli) :

| Méthode | Exemple (`fr`) |
| :--- | :--- |
| `format_message(text, syntax, args, zone)` | `{n, plural, one {# article} other {# articles}}` avec `n = 3` → `3 articles` |
| `check_message(text, syntax)` | vérifie qu'un texte est lisible, sans le rendre |
| `format_number(value)` | `1 234 567,89` |
| `format_percent(value)` | `0.256` → `25,6 %` |
| `format_currency(amount, code)` | `1 234,50 €` (code ISO 4217 ; le montant est affiché avec les décimales fournies) |
| `format_date(instant, zone, style)` | `29 mars 2026, 03:30` à `Europe/Paris` ; `DateStyle::Date`, `Time` ou `DateTime`, longueurs `Short`, `Medium`, `Long` |

Éléments d'un message `icu_mf1` pris en charge : `{nom}` (texte tel quel, nombre et date mis en
forme), `number` (défaut, `integer`, `percent`), `date` et `time` (`short`, `medium`, `long`),
`plural` et `selectordinal` (catégories CLDR de la langue, valeurs exactes `=N`, `offset`, `#`),
`select`, apostrophes d'échappement. Les squelettes (`::…`), les autres styles et les types non
listés sont refusés. Un texte `plain` est rendu tel quel.

* **Arguments** (`MessageArgs`) : texte, nombre décimal exact (`integer`, ou `decimal("1234.56")`
  depuis son écriture, jamais depuis un flottant), instant (`jiff::Timestamp`).
* **Fuseaux horaires** : identifiants IANA par `jiff` ; base du système si elle existe, copie
  embarquée sinon (`timezone_database_origin`).
* **Erreurs** (`FormatError::code`, master data `error/rendu/`) : `I18N_MESSAGE_INVALID` (avec la
  position), `I18N_ARGUMENT_MISSING`, `I18N_ARGUMENT_TYPE`, `I18N_LOCALE_UNSUPPORTED`,
  `I18N_TIMEZONE_UNKNOWN`, `I18N_CURRENCY_UNKNOWN`, `I18N_NUMBER_INVALID`. Aucun texte incomplet
  n'est renvoyé.
* **Écart connu avec le contrôle de la base** : la base refuse une accolade fermante isolée
  (`a } b`), que le rendu traite comme du texte, comme ICU.
* `icu_experimental` (montants et pourcentages, API instable) n'est utilisé que dans
  `format/experimental.rs`.

`Translator::translate({ key, locale, tenant, args, zone })` appelle `fn::i18n_resolve`, puis
rend le texte avec le `Formatter` de la langue du texte **retenu** : un texte de repli suit les
pluriels et les formats de sa propre langue. Clé non déclarée : la clé, `missing: true`, sans
erreur. Les `Formatter` sont gardés en cache par langue (64 au plus).

## 7. Échange par fichier (Rust, `exchange/`)

`Exchange` exporte, importe et contrôle les textes. Un fichier porte **une langue** et **une
portée** (installation, ou une organisation), données par l'appelant, jamais lues dans le
fichier.

| Format | Forme |
| :--- | :--- |
| `FileFormat::Json` | objet à plat `{ "base.unite_m": "Mètre" }`, textes en ICU MessageFormat 1 : le format d'échange de Tolgee, FormatJS et Crowdin. Seules les clés traduites sont écrites |
| `FileFormat::Xliff` | XLIFF 2.0 : un `<file>` par espace de noms, un `<unit id="clé">` par clé, `<source>`, `<target>` si la clé est traduite, état (`initial`, `translated`, `reviewed`), contexte en `<notes>`. Texte seul : un élément en ligne (`<ph>`…) fait rejeter l'unité. Les textes sources doivent avoir la même langue (un espace de noms à la fois sinon) |

* **Import** (`Exchange::import`) :
  1. lecture par `lyxal_parsing` ; un fichier mal formé n'écrit rien, un enregistrement illisible
     est listé dans `rejected` ;
  2. chaque texte est vérifié par `Formatter::check_message` (syntaxe complète) : un texte refusé
     va dans `invalid` et n'est pas envoyé à la base ;
  3. envoi par paquets de 500 à `fn::i18n_import`, qui applique ses règles entrée par entrée :

     | Cas | Effet |
     | :--- | :--- |
     | clé non déclarée | ignorée (`key_not_found`) : un import ne crée pas de clé |
     | texte identique à celui de la base | inchangé |
     | texte à l'état `reviewed` | ignoré (`reviewed`), sauf `overwrite_reviewed` |
     | texte refusé par `fn::i18n_message_check` | `invalid`, non écrit |
     | sinon | créé ou modifié par `fn::i18n_translation_set` |

  Les entrées sont indépendantes ; `dry_run` rend le rapport sans rien écrire. Un import ne
  touche que sa portée.
* **Contrôle** (`Exchange::check`) : tous les textes (`fn::i18n_translation_scan`) sont vérifiés
  par le rendu dans leur langue ; rien n'est modifié.
* Commandes de `lyxal-server` (session système) :

  ```text
  lyxal-server i18n export --locale <langue> --output <fichier> [--format json|xliff] [--namespace <clé>] [--tenant <organisation>]
  lyxal-server i18n import --locale <langue> --file <fichier> [--format json|xliff] [--tenant <organisation>] [--overwrite-reviewed] [--dry-run]
  lyxal-server i18n check
  ```

  `import` et `check` sortent en erreur (`SERVER_COMMAND_FAILED`) si un texte est invalide ou
  illisible, pour un usage en intégration continue.

## 8. Rust, module et sonde

* `I18nStore` (`Surreal<Any>`, `LyxalSurrealCall`) : un appel typé par fonction publique ;
  modèles dans `models/`.
* `accept_language::candidates(header)` : étiquettes par poids décroissant (ordre d'origine à
  poids égal), sans `*` ni poids nul, 20 au plus ; aucune validation (faite par SurrealQL).
* `I18nModule` (`LyxalModule`) et `I18nHealthCheck`, enregistrés par `lyxal-server` : réglages
  lisibles, langue par défaut active et rendue, fuseau `Europe/Paris` connu. Le message donne la
  version CLDR du référentiel, celle des données d'ICU4X (`ICU_CLDR_VERSION`) et l'origine de la
  base des fuseaux. Aucun worker.
* Lecture des fichiers par `lyxal_parsing` (`JsonLayout::Document`, `XmlReader`).
* `lyxal_notification` utilise `Formatter` pour ses filtres `format_number`, `format_currency`
  et `format_date`.

## 9. Vérification

* Banc SurrealQL `tests/` : `langues`, `parametres`, `resolution`, `cles`, `traductions`,
  `controles`, `resolution_cles`, `echange`.
* Tests Rust :
  * `format/tests.rs` : pluriels CLDR (`fr`, `en`, `ar`, `pl`, `ru`, `ja`), ordinaux, valeurs
    exactes, décalage, imbrication, apostrophes, arguments manquants ou mal typés, messages
    invalides avec leur position, changements d'heure, fuseau inconnu, nombres et montants par
    langue, mêmes verdicts que le contrôle de la base, codes d'erreur définis en master data ;
  * `accept_language` ;
  * `tests/it/` (base embarquée) : chaque fonction par `I18nStore`, `Translator`, sonde de santé,
    échange (aller-retour JSON et XLIFF, caractères à échapper, texte relu protégé, fichier
    illisible, texte refusé par le rendu, contrôle de tous les textes).
* Hôte : choix de la langue (`auth_routes.rs`), sonde saine au démarrage (`startup.rs`), lecture
  des commandes `i18n` (`cli.rs`).

## 10. Licences

Données Unicode CLDR 49 sous licence Unicode-3.0 (seed généré, données d'ICU4X). Dépendances
du rendu : ICU4X (`icu`, `icu_experimental`, `fixed_decimal`, Unicode-3.0), `jiff` et `jiff-icu`
(MIT ou Unlicense), `formatjs_icu_messageformat_parser` (MIT). Tolgee, Weblate et Pontoon servent
de modèle de conception seulement, sans code repris.
