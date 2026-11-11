# `lyxal_i18n` — modèle et sources

Sources open source dont `lyxal_i18n` reprend une bibliothèque ou un modèle, sources écartées,
et décisions du CTO qui fixent la conception du module. L'état du module est décrit par son
[`README.md`](README.md), ses évolutions par sa [`ROADMAP.md`](ROADMAP.md).

Versions des crates relevées sur crates.io le 9 novembre 2026 ; la version utilisée est fixée
par `Cargo.lock`.

## 1. Principe d'assemblage

Même règle que `lyxal_storage` et `lyxal_parsing` :

* **Dépendance** : bibliothèque Rust prise telle quelle, version fixée par `Cargo.lock`, licence
  permissive (Apache-2.0, MIT, BSD, Unicode-3.0) ;
* **Modèle** : architecture d'un projet étudiée et transcrite (SurrealQL pour les données et les
  règles, Rust pour le rendu) ; un projet GPL ou AGPL n'est jamais copié.

## 2. Sources retenues

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
| Contrôles et glossaire | Weblate | GPL-3.0 | **Modèle seulement** (aucun code) : contrôles de cohérence |
| Relecture, Fluent | Pontoon (Mozilla) | BSD-3 | **Modèle** de relecture |
| Import, export | JSON (MF1) et XLIFF 2 | normes | lecture par `lyxal_parsing` (JSON, XML) |

Données ICU4X : celles de toutes les langues sont embarquées (`compiled_data`), soit 3,8 Mo
mesurés sur un exécutable d'essai ; aucun sous-ensemble de langues n'est généré.

## 3. Sources écartées

| Projet | Raison |
| :--- | :--- |
| Unicode MessageFormat 2.0 | norme stable depuis mars 2025, mais aucun formateur Rust mûr (ICU4X n'en a pas ; `mf2` 3.0.0 : un seul auteur) ; le champ `syntax` de chaque traduction permet le passage plus tard |
| Project Fluent (`fluent` 0.17) | sorties rares, format peu pris en charge par les outils de traduction ; Mozilla converge vers MF2 |
| `rust-i18n` | traductions compilées dans le binaire : incompatible avec des traductions en base et par organisation |
| `unic-langid` | remplacé par `icu_locale` |
| `rusty-money` | format des montants non conforme à CLDR |
| `chrono-tz` | base tz compilée dans le binaire, mise à jour seulement par nouvelle version ; `jiff` lit la base du système ou une copie embarquée |
| Traduora | AGPL-3.0, activité faible |

## 4. Points de vigilance

* **Versions CLDR** : chaque version peut changer un rendu (CLDR 49 : semaine ISO par défaut,
  cycle horaire). La version est figée dans le référentiel généré
  (`scripts/i18n/generate_locales.py`) et dans les données d'ICU4X ; une montée de version est
  un chantier à part.
* **`icu_experimental`** : API instable ; le formatage des montants est isolé dans
  `src/format/experimental.rs`.
* **Base tz** : plusieurs versions par an. L'origine de la base utilisée est exposée par la sonde
  de santé du module.
* **Frontière SurrealQL / Rust** : SurrealDB n'a pas ICU. La base contrôle les paramètres et les
  formes de pluriel à l'écriture ; la syntaxe complète d'un message n'est vérifiée qu'en Rust.

## 5. Décisions du CTO

| Sujet | Décision |
| :--- | :--- |
| Format des messages | **ICU MessageFormat 1** (sous-ensemble) ; le champ `syntax` de chaque texte permet de passer plus tard à MessageFormat 2 |
| Fuseaux horaires | `lyxal_i18n` **affiche** une date dans un fuseau donné ; les conversions et les préférences de fuseau reviennent au futur module décrit dans `Lyxal_timezone/` |
| Messages d'erreur | `lyxal_error` **garde ses traductions** dans ses définitions : il est sous `lyxal_i18n` dans la hiérarchie, et les erreurs de `lyxal_i18n` en ont besoin |
| Contrôle des messages | En SurrealQL : paramètres et formes de pluriel à l'écriture ; syntaxe complète vérifiée par Rust à l'import et au rendu (`I18N_MESSAGE_INVALID`), et par la commande `i18n check` |
| Langues | `fr` (défaut) et `en` actives ; toutes les langues de CLDR dans le référentiel, activables sans recompiler ; le rendu embarque les données de toutes les langues |
| Étiquettes de langue | La règle `locale` de `lyxal_core` accepte `langue[-Script][-RÉGION]` (`zh-Hant-TW`, `es-419`) ; aucune règle séparée |
| Choix de la langue | `lyxal_i18n` reçoit une liste de candidats et garde la première langue active ; il ne lit ni l'identité ni l'organisation |
| Repli d'une clé | Langues parentes de CLDR, puis langue par défaut de l'installation, puis langue source ; pour chaque langue, la surcharge de l'organisation avant le texte de l'installation ; clé non déclarée : la clé elle-même, signalée, jamais un texte vide |
| Surcharges | Une organisation modifie le texte d'une clé, jamais la clé ; les clés appartiennent à l'installation |
| Échange par fichier | JSON à plat (MessageFormat 1) et XLIFF 2.0 en texte seul ; une clé non déclarée est ignorée, un texte relu n'est écrasé que sur demande explicite |
| Unités de mesure | Le libellé est une clé de l'espace de noms `base` ; l'abréviation n'est pas traduite |
| E-mails | Un seul gabarit par étape, dont les phrases sont des clés appelées par `t("clé")` (modèle de Novu) ; la langue de l'envoi est celle du destinataire, sinon de son organisation, sinon de l'installation |
| Contenus métiers | La traduction des données métier (libellés du catalogue, de l'ingestion) est hors du périmètre actuel ; elle est inscrite à la feuille de route |
