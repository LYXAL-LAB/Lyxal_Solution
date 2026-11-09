# Plan détaillé — lot 1 `lyxal_i18n` : référentiel des langues et choix de la langue

Lot 1 du programme `lyxal_i18n` (`implementation_plan.md` à la racine, décisions Q1 à Q7
validées par le CTO le 9 novembre 2026). Aucune ligne de code avant la validation de ce plan
(`.agents/AGENTS.md` §3). Plan supprimé une fois exécuté.

## 1. Objectif

* Créer le crate `lyxal_i18n` (structure canonique, hébergé par `lyxal-server`).
* Référentiel des langues issu de CLDR 49 : toutes les langues CLDR, `fr` (défaut) et `en`
  actives.
* Choisir la langue d'une requête parmi des candidats (`fn::i18n_locale_resolve`).
* L'hôte utilise ce choix pour les messages d'erreur, à la place de son code actuel.
* Langue par défaut d'une organisation (`auth_organization.locale`).

## 2. Fonctions `lyxal_core` réutilisées et extension (Q6)

* Réutilisées : `fn::validation_object_execute`, règles `locale`, `boolean`, `integer`, `enum`.
* **Extension (Q6)** : au lieu d'ajouter une règle `language_tag` à côté de `locale`, j'étends la
  règle **`locale`** existante. Deux règles pour le même besoin seraient un doublon (§5.1).
  * Formes acceptées : `langue[-Script][-RÉGION]`, avec la langue sur 2 ou 3 lettres, le script
    sur 4 lettres et la région sur 2 lettres ou 3 chiffres (`es-419`).
  * Forme canonique renvoyée : `zh-Hant-TW`, `es-419`.
  * Les appelants actuels (`lyxal_notification`, `lyxal_auth`) ne changent pas : tout ce qu'ils
    acceptaient reste accepté.
  * Banc `locale.test.surql` étendu.
* Aucune autre fonction générique manquante.

## 3. Génération du référentiel (CLDR 49)

* Script `scripts/i18n/generate_locales.py`. Il lit les paquets officiels `cldr-json` 49.0.0
  (`cldr-core`, `cldr-localenames-full`, `cldr-misc-full`), téléchargés à version fixée depuis le
  registre npm. Il écrit `crates/lyxal_i18n/seeds/i18n_locale.surql`, qui est versionné.
* Pour chaque langue de `availableLocales.full` (657 langues), le script relève :
  * l'étiquette ;
  * le nom en anglais et le nom dans la langue elle-même (`cldr-localenames-full`) ;
  * le sens d'écriture (`cldr-misc-full`, `layout`) ;
  * les catégories de pluriel, cardinales et ordinales (`plurals.json`, `ordinals.json`) ;
  * la **chaîne de repli** : parent explicite de `parentLocales.json`, sinon troncature du
    dernier élément, jusqu'à la langue seule. Exemples : `es-MX → es-419 → es`, `pt-AO → pt-PT
    → pt`.
* Le script n'est lancé qu'à une montée de version de CLDR. Le CI rejoue le seed, il ne régénère
  rien (pas de réseau en CI).
* Licence Unicode-3.0 : mention dans le `README.md` du crate.

## 4. Modèle (SurrealQL)

### `i18n_settings` (enregistrement unique `i18n_settings:installation`)

| Champ | Type | Règle |
| :--- | :--- | :--- |
| `default_locale` | `record<i18n_locale>` | langue active ; défaut `fr` |
| `source_locale` | `record<i18n_locale>` | langue des textes sources des clés (lot 2) ; défaut `fr` |
| `updated_at` | `datetime` | `VALUE time::now()` |

### `i18n_locale` (identifiant = étiquette : `i18n_locale:⟨fr-CA⟩`)

| Champ | Type | Règle |
| :--- | :--- | :--- |
| `tag` | `string` | `READONLY`, forme canonique |
| `language`, `script`, `region` | `string`, `option<string>` | `READONLY` |
| `name_en`, `name_native` | `string` | |
| `direction` | `"ltr"` ou `"rtl"` | |
| `plural_cardinal`, `plural_ordinal` | `array<string>` | parmi `zero`, `one`, `two`, `few`, `many`, `other` |
| `fallback` | `array<string>` | chaîne de repli, sans l'étiquette elle-même |
| `active` | `bool` | défaut `false` |
| `cldr_version` | `string` | `"49"` |

**Permissions.**

* `select` : ouvert, référentiel public.
* `create` et `delete` : `NONE` (seed et session système uniquement).
* `update` : permission `i18n.locale.manage`. Seul `active` est modifiable ; les autres champs
  sont protégés par `PERMISSIONS FOR update NONE`.

**Gardes (`DEFINE EVENT`).**

* La langue par défaut ne peut pas être désactivée (`I18N_LOCALE_DEFAULT_REQUIRED`).
* `i18n_settings` ne peut désigner qu'une langue active.

## 5. Fonctions publiques (`fn::i18n_*($params: object)`)

Toutes passent par le moteur de validation de `lyxal_core`, prennent un `language` (règle
`language_code`, défaut `fr`), renvoient `fn::result_ok` ou `fn::error_result` et vérifient
leur écriture principale (`I18N_WRITE_FORBIDDEN`).

| Fonction | Paramètres | Résultat | Droits |
| :--- | :--- | :--- | :--- |
| `i18n_locale_list` | `active?: bool`, `search?: string` (étiquette ou nom), `limit` (1 à 1000, défaut 100), `start` | `{ items: [Locale], total }` | tous |
| `i18n_locale_get` | `locale` | `Locale` ou `I18N_LOCALE_NOT_FOUND` | tous |
| `i18n_locale_activate` | `locale` | `Locale` ; publie `i18n.locale.activated` | `i18n.locale.manage` |
| `i18n_locale_deactivate` | `locale` | `Locale` ; publie `i18n.locale.deactivated` ; refusé pour la langue par défaut | `i18n.locale.manage` |
| `i18n_settings_get` | — | `{ default_locale, source_locale }` | tous |
| `i18n_settings_update` | `default_locale?`, `source_locale?` | idem ; langue inactive refusée (`I18N_LOCALE_INACTIVE`) | `i18n.locale.manage` |
| `i18n_locale_resolve` | `candidates: array<string>` (0 à 20) | `{ locale, language, fallback, matched }` | tous |

**Algorithme de `i18n_locale_resolve`.** Pour chaque candidat, dans l'ordre :

1. forme canonique par la règle `locale` ; un candidat invalide est ignoré ;
2. si la langue est active, elle est retenue ;
3. sinon, la chaîne de repli du candidat est parcourue : celle du référentiel, ou la troncature
   si l'étiquette n'y figure pas. Le premier élément actif est retenu (correspondance « lookup »
   de la RFC 4647) ;
4. sans résultat après tous les candidats : langue par défaut de l'installation, avec
   `matched: false`.

Le résultat donne :

* `locale` : étiquette retenue ;
* `language` : langue seule (`fr`), valeur à passer au paramètre `language` des fonctions
  existantes ;
* `fallback` : chaîne de repli complète, jusqu'à la langue par défaut.

## 6. Permissions, rôles, master data, événements

* Permission `i18n.locale.manage` (installation), accordée au rôle d'administration de
  l'installation (seed `seeds/i18n_auth.surql`, même forme que `catalogue_auth.surql`).
* Erreurs (`error/locale/`, master data `fr` et `en`) :
  * `I18N_INVALID_PARAMETERS`
  * `I18N_LOCALE_NOT_FOUND`
  * `I18N_LOCALE_INACTIVE`
  * `I18N_LOCALE_DEFAULT_REQUIRED`
  * `I18N_PERMISSION_DENIED`
  * `I18N_WRITE_FORBIDDEN`
* Événements : `i18n.locale.activated` et `i18n.locale.deactivated`, avec `{ locale }`, publiés
  par `DEFINE EVENT` via `fn::event_publish` (échec → `THROW`).

## 7. Rust (`crates/lyxal_i18n/src/`)

* `I18nStore` (`Surreal<Any>`, `LyxalSurrealCall`) : un wrapper d'une ligne par fonction
  publique.
* Types :
  * `Locale` (`SurrealValue`) ;
  * `LocaleListParams` / `LocaleList` ;
  * `LocaleGetParams` ;
  * `LocaleActivateParams` ;
  * `SettingsUpdateParams` / `Settings` ;
  * `LocaleResolveParams { candidates: Vec<String>, language: Option<String> }` /
    `ResolvedLocale { locale, language, fallback, matched }`.
* `accept_language::candidates(header: &str) -> Vec<String>` : entrées triées par poids
  décroissant, ordre d'origine à poids égal, `q=0` et `*` écartés, 20 entrées au plus. Lecture
  seule, sans validation des étiquettes (faite par SurrealQL).
* Module hébergé par un `ManifestModule` : le lot 1 n'a ni worker ni sonde propre.

## 8. Autres modules (rupture coordonnée)

### `lyxal_auth`

* Champ `auth_organization.locale` (`option<string>`, règle `locale`).
* `fn::auth_organization_create` et `fn::auth_organization_update` acceptent `locale`.
* `Organization`, `OrganizationCreateParams` et `OrganizationUpdateParams` portent
  `locale: Option<String>`.
* `lyxal_auth` ne dépend pas de `lyxal_i18n` : l'activation de la langue n'est pas vérifiée à
  l'écriture, une langue inactive est ignorée à la résolution.

### `lyxal_error`

* `default_language` : défaut `"fr"`, comme `fn::error_resolve`.
* ASSERT aligné sur la règle `language_code` (deux lettres).
* `fn::error_resolve` est inchangée.

### `apps/lyxal-server`

* `language()` est remplacée par `locale()`. Elle rassemble les candidats dans l'ordre suivant :
  1. `locale` de l'identité du jeton ;
  2. `locale` de l'organisation active ;
  3. entrées de `Accept-Language` ;
  4. la langue par défaut, ajoutée par `fn::i18n_locale_resolve` lui-même.

  Elle appelle ensuite `fn::i18n_locale_resolve` (session système) et rend `language`.
* `language_code` est supprimée, de même que le `"fr"` codé en dur.
* Une panne pendant la lecture reste propagée (correction Codex du lot 7).
* `build.rs` et `src/modules/` : `lyxal_i18n` installé avant `lyxal_auth`, son seed de
  permissions après.

**Écart à signaler (ordre des candidats).** Le plan du programme (§1.2) place la langue
explicite de l'appel en premier, puis l'utilisateur, l'organisation et enfin `Accept-Language`.
Les routes de l'hôte n'ont pas de paramètre de langue : la préférence de l'utilisateur vient
donc en premier. Aujourd'hui, `Accept-Language` passe avant le trait de l'identité ; le lot 1
inverse cet ordre, conformément au programme validé.

## 9. Tests

* **Banc SurrealQL `crates/lyxal_i18n/tests/`** :
  * `langues.test.surql` : liste, recherche, lecture, activation, désactivation, garde de la
    langue par défaut, écritures refusées sans permission ou sous une autre identité.
  * `resolution.test.surql` :
    * `fr-CA` sans `fr-CA` actif donne `fr` ;
    * `es-MX` avec seulement `es-419` actif donne `es-419` ;
    * `zh-Hant-TW`, `zh_hant_tw` et une étiquette invalide ignorée ;
    * liste vide → langue par défaut avec `matched: false` ;
    * plus de 20 candidats refusés.
  * `parametres.test.surql` : réglages, langue inactive refusée.
* **`lyxal_core`** : `locale.test.surql` (script, région à 3 chiffres, refus de `fr-Latn-FR-x`).
* **`lyxal_auth`** : `locale` d'organisation (création, modification, valeur invalide).
* **Rust** : `accept_language` (poids, égalités, `q=0`, `*`, entrées mal formées, limite de 20).
* **Hôte** (`tests/it/auth_routes.rs`) :
  * même erreur rendue en `en` pour un `Accept-Language: de;q=0.5, en;q=0.8` (`de` inactif) ;
  * en `fr` pour une identité `locale: fr-CA` malgré un `Accept-Language: en` ;
  * langue de l'organisation active utilisée quand l'identité n'en a pas.
* Installation et rejeu du seed (657 langues) sur SurrealDB 3.3.4 ; `scripts/ci/ci_local.sh`.

## 10. Documentation

* `crates/lyxal_i18n/README.md` (état du lot 1, sources, licence CLDR) et `ROADMAP.md` (lots 2 à 6,
  contenus métiers traduits de Q7).
* `RECHERCHE_SOURCES.md` conservé jusqu'au lot 6.
* `.agents/AGENTS.md` §6 et `ROADMAP_NOYAU.md` : `lyxal_i18n` n'est plus « à créer », il dépend de
  `lyxal_auth`.
* `README.md` de `lyxal_auth` (langue d'organisation, choix de la langue des erreurs) et de
  `lyxal_core` (règle `locale`).

## 11. Questions au CTO

| # | Question | Recommandation |
| :- | :--- | :--- |
| E1 | Q6 réalisée en **étendant la règle `locale`** plutôt qu'en ajoutant `language_tag` | Oui : une seule règle, aucun appelant cassé |
| E2 | Ordre des candidats : identité, organisation, puis `Accept-Language` (aujourd'hui `Accept-Language` d'abord) | Oui, conforme au programme validé |
| E3 | Générateur en Python (`scripts/i18n/`), comme les outils de CI, plutôt qu'en Rust | Oui : outil lancé à la main à chaque version de CLDR, sans effet sur le binaire |
