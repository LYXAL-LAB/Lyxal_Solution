# `lyxal_i18n` — recherche de sources open source

Document de travail du programme `lyxal_i18n` (crate du Noyau Technique). Il est réduit aux sources retenues à la clôture du programme (lot 6 du plan
`implementation_plan.md` à la racine).

Recherche du 9 novembre 2026. Les versions des crates viennent de l'API crates.io à cette date ;
les autres informations de recherches web. Les pages de cldr.unicode.org, docs.rs,
docs.tolgee.io et GitHub n'étaient pas joignables depuis l'environnement de recherche : leurs
contenus sont revérifiés au plan détaillé de chaque lot.

## 1. Besoin

`lyxal_i18n` fournit à tous les modules :

* le **référentiel des langues** de l'installation (langues actives, langue par défaut, chaînes de
  repli) ;
* les **traductions** par clé, avec surcharges par organisation ;
* le **choix de la langue** d'une requête ;
* le **rendu** des messages (pluriels, paramètres) et des **formats régionaux** (dates, nombres,
  devises).

Existant dans le dépôt (inventaire du 9 novembre 2026) :

| Consommateur | Aujourd'hui |
| :--- | :--- |
| `lyxal_error` | 305 définitions, `translations: { fr, en }` dans chaque définition ; repli dans `fn::error_resolve` (langue demandée, puis `default_language`) ; `default_language` vaut `"en"` par défaut dans le schéma mais `"fr"` dans la résolution |
| Paramètre `language` | 214 fonctions publiques : règle `language_code` (2 lettres), défaut `"fr"` |
| `lyxal_base` | libellés des unités en français seul ; étape 2 de sa feuille de route : « libellés traduits » |
| `lyxal_notification` | une version de gabarit par langue (`notification_template_locale`) ; repli langue → langue sans région → défaut du gabarit → défaut du module ; sa V2 prévoit les clés `lyxal_i18n` |
| `lyxal_auth` | traits `locale` et `timezone` de l'identité ; aucune langue par défaut d'organisation |
| `lyxal-server` | langue des erreurs : `Accept-Language` (première entrée seulement, poids ignorés), puis `locale` de l'identité, puis `fr` |
| `lyxal_core` | règles `language_code`, `locale` (langue + région seulement, pas de script), `timezone` (format seul), `currency_code`, `country_code_iso2/3` ; `fn::utils_number_format` est le seul formateur |
| `lyxal_pipeline_ingestion` | devise `"EUR"` par défaut, virgule décimale traitée au cas par cas |
| `Lyxal_timezone/` | cahier des charges d'un futur module de fuseaux horaires ; il exclut les traductions (`lyxal_i18n`) |

## 2. Principe d'assemblage

Même règle que `lyxal_storage` et `lyxal_parsing` :

* **Dépendance** : bibliothèque Rust prise telle quelle, version fixée par `Cargo.lock`, licence
  permissive (Apache-2.0, MIT, BSD, Unicode-3.0) ;
* **Modèle** : architecture d'un projet étudiée et transcrite (SurrealQL pour les données et les
  règles, Rust pour le rendu) ; un projet GPL ou AGPL n'est jamais copié.

## 3. Sources retenues

| Brique | Source | Licence, version | Usage |
| :--- | :--- | :--- | :--- |
| Étiquettes de langue | BCP 47 (RFC 5646), correspondance RFC 4647, `Accept-Language` RFC 9110 §12.5.4 | normes | **Modèle** : forme canonique `fr-CA`, `zh-Hant-TW` |
| Données des langues (noms, pluriels, langues parentes, formats) | Unicode CLDR 49 (22 octobre 2026) | Unicode-3.0 | **Données**, lues par ICU4X ; version figée et montée volontairement |
| Lecture des étiquettes, repli CLDR | `icu_locale` 2.4.0 (ICU4X) | Unicode-3.0, actif | **Dépendance** |
| Pluriels | `icu_plurals` 2.4.0, `fixed_decimal` 0.7.3 | Unicode-3.0 | **Dépendance** |
| Dates, nombres | `icu_datetime`, `icu_decimal` 2.4.0 | Unicode-3.0, API stable | **Dépendance** |
| Devises | `icu_experimental` 0.7.0 | Unicode-3.0, **API instable** | **Dépendance** cachée derrière un type de `lyxal_i18n` |
| Tri selon la langue | `icu_collator` 2.4.0 | Unicode-3.0 | **Dépendance** (SurrealDB ne trie pas selon la langue) |
| Format des messages | ICU MessageFormat 1 (sous-ensemble : argument, `plural`, `selectordinal`, `select`, `number`, `date`, `time`) | norme de fait (Tolgee, Crowdin, FormatJS) | **Modèle** ; lecteur `formatjs_icu_messageformat_parser` 2.0.1 (MIT) en **dépendance**, rendu écrit avec ICU4X |
| Fuseaux horaires (affichage) | base IANA tz ; `jiff` 0.2.41 | domaine public ; MIT OR Unlicense, très actif | **Dépendance** pour afficher une date dans un fuseau |
| Gestion des traductions | Tolgee | Apache-2.0 (hors dossiers `ee/`) | **Modèle principal** : espaces de noms, clés, traductions par langue, états, indicateur « obsolète », contrôles, paramètres universels |
| Contrôles et glossaire | Weblate | GPL-3.0 | **Modèle seulement** (aucun code) : contrôles de cohérence, plus tard glossaire et mémoire de traduction |
| Relecture, Fluent | Pontoon (Mozilla) | BSD-3 | **Modèle** de relecture |
| Import, export | JSON (MF1) et XLIFF 2 | normes | lecture par `lyxal_parsing` (JSON, XML) |

Données ICU4X : générées pour les seules langues utiles (`icu4x-datagen --format baked`), au lieu
de toutes les langues (plusieurs Mo).

## 4. Sources écartées

| Projet | Raison |
| :--- | :--- |
| Unicode MessageFormat 2.0 | norme stable depuis mars 2025, mais aucun formateur Rust mûr (ICU4X n'en a pas ; `mf2` 3.0.0 : un seul auteur). Suivi : le champ `syntax` de chaque traduction permet le passage plus tard |
| Project Fluent (`fluent` 0.17) | sorties rares, format peu pris en charge par les outils de traduction ; Mozilla converge vers MF2 |
| `rust-i18n` | traductions compilées dans le binaire : incompatible avec des traductions en base et par organisation |
| `unic-langid` | remplacé par `icu_locale` |
| `rusty-money` | format des montants non conforme à CLDR |
| `chrono-tz` | base tz compilée dans le binaire, mise à jour seulement par nouvelle version ; `jiff` lit la base du système ou une copie embarquée |
| Traduora | AGPL-3.0, activité faible |

## 5. Points de vigilance

* **Versions CLDR** : chaque version peut changer un rendu (CLDR 49 : semaine ISO par défaut,
  cycle horaire). Version figée dans les données générées, montée par un lot dédié.
* **`icu_experimental`** : API instable ; le formatage des devises est isolé dans un seul module.
* **Base tz** : 2026 a eu six versions (2026a à 2026f). La version utilisée est exposée par la
  sonde de santé du module.
* **Frontière SurrealQL / Rust** : SurrealDB n'a pas ICU. La syntaxe complète d'un message n'est
  vérifiable qu'en Rust (question Q4 du plan).
