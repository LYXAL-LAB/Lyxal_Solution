# Lyxal I18n

Module du Noyau Technique de Lyxal OS : **langues, traductions et formats régionaux**. Lot 1 :
référentiel des langues issu d'Unicode CLDR et choix de la langue d'une requête. Les règles
vivent dans SurrealDB (fonctions `fn::i18n_*`) ; le crate Rust fournit les appels typés
(`I18nStore`) et la lecture de `Accept-Language`. Sources et choix :
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

## 3. Fonctions publiques (`fn::i18n_*($params: object)`)

| Fonction | Paramètres | Résultat | Droits |
| :--- | :--- | :--- | :--- |
| `i18n_locale_list` | `active`, `search` (début de l'étiquette ou partie d'un nom), `limit` (1 à 1000, 100), `start` | `{ items, total }` | tous |
| `i18n_locale_get` | **locale** | langue ou `I18N_LOCALE_NOT_FOUND` | tous |
| `i18n_locale_activate` | **locale** | langue ; publie `i18n.locale.activated` | `i18n.locale.manage` |
| `i18n_locale_deactivate` | **locale** | langue ; publie `i18n.locale.deactivated` ; refusé pour la langue par défaut ou source | `i18n.locale.manage` |
| `i18n_settings_get` | — | `{ default_locale, source_locale }` | tous |
| `i18n_settings_update` | `default_locale`, `source_locale` | idem ; langue inconnue ou inactive refusée | `i18n.locale.manage` |
| `i18n_locale_resolve` | `candidates` (0 à 20) | `{ locale, language, fallback, matched }` | tous |

Toutes acceptent `language` (langue des messages d'erreur sur deux ou trois lettres, comme celle
que renvoie `fn::i18n_locale_resolve` ; `fr` par défaut), valident leurs
entrées par le moteur de `lyxal_core` et vérifient leur écriture principale
(`I18N_WRITE_FORBIDDEN`). Erreurs : `I18N_INVALID_PARAMETERS`, `I18N_PERMISSION_DENIED`,
`I18N_WRITE_FORBIDDEN`, `I18N_LOCALE_NOT_FOUND`, `I18N_LOCALE_INACTIVE`,
`I18N_LOCALE_DEFAULT_REQUIRED`.

## 4. Événements

`i18n.locale.activated` et `i18n.locale.deactivated`, `payload: { locale }`, publiés par
`DEFINE EVENT` via `fn::event_publish` (une publication refusée annule la modification).

## 5. Rust

* `I18nStore` (`Surreal<Any>`, `LyxalSurrealCall`) : un appel typé par fonction publique ;
  modèles `Locale`, `LocaleList(Params)`, `LocaleGetParams`, `Settings(UpdateParams)`,
  `LocaleResolveParams`, `ResolvedLocale`.
* `accept_language::candidates(header)` : étiquettes par poids décroissant (ordre d'origine à
  poids égal), sans `*` ni poids nul, 20 au plus ; aucune validation (faite par SurrealQL).
* Hébergé par `lyxal-server` comme module de manifeste (ni worker ni sonde propre).

## 6. Vérification

* Banc SurrealQL `tests/` (`langues`, `parametres`, `resolution`) : chaque fonction publique,
  données CLDR, repli, droits, garde, événements.
* Tests Rust de `accept_language` ; routes de l'hôte (`apps/lyxal-server/tests/it/auth_routes.rs`) :
  poids, langue de l'identité puis de l'organisation avant `Accept-Language`, langue par défaut.

## 7. Licences

Données Unicode CLDR 49 sous licence Unicode-3.0 (seed généré). Tolgee, Weblate et Pontoon
servent de modèle de conception seulement, sans code repris.
