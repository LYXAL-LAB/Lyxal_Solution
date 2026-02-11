## Spécification i18n (Langue, Locale, Formats)

### Objectifs
- Centraliser les conventions d'affichage (dates/heures, nombres, monnaies, adresses) par locale.
- Supprimer les entrées libres via des tables d'énumération référencées.
- Réutiliser des clés i18n (`i18n_key`) pour les libellés (UI) afin d'éviter la duplication.

### Pivots
- Langue: ISO 639‑1 (ex: `fr`, `en`) via `i18n_language`.
- Locale: BCP 47 (ex: `fr-FR`, `en-GB`) via `i18n_locale`.
- Les traductions de texte passent par `i18n_key` + `i18n_translation` vers une langue.

---

### Tables principales

1) i18n_language
- Rôle: référentiel des langues (ISO 639‑1/2). Champ `key.name` pour un libellé i18n réutilisable.
- Champs clés: `code`, `name`, `nativeName`, `direction (ltr/rtl)`, `snowballSupported`, `isActive`, `key.name`.
- Index: unicité sur `code`.

2) i18n_locale
- Rôle: profil complet par locale (langue + conventions régionales).
- Champs clés:
  - Identité: `code` (BCP 47), `language` (-> i18n_language)
  - Date/heure: `datetimeFormat` (-> i18n_datetime_format)
  - Nombres: `decimalSeparator` (-> i18n_decimal_separator), `thousandSeparator` (-> i18n_thousand_separator)
  - Monétaire: `currency` (-> base_currency), `currencySymbolPosition` (-> i18n_currency_symbol_position), `spaceBetweenSymbolAndAmount`
  - Divers: `timezone` (-> base_timezone), `addressFormat` (-> base_address_format), `displayName`, `nativeDisplayName`, `isActive`
- Notes de modélisation: toutes les références utilisent `REFERENCE ON DELETE REJECT` + `VALUE type::thing(...)`.

3) i18n_datetime_format
- Rôle: profils mutualisés de formats date/heure.
- Champs clés:
  - `code` (identifiant du profil),
  - `dateFormat` (-> i18n_date_pattern),
  - `timeFormat` (-> i18n_time_pattern),
  - `weekStartDay` (-> i18n_week_start),
  - `timeNotation` (-> i18n_time_notation, 12h/24h).

---

### Tables d'énumération (entrées contrôlées)

- i18n_date_pattern: `pattern` (CLDR/UTS#35), `skeleton` (optionnel), `key.name`.
- i18n_time_pattern: `pattern` (CLDR/UTS#35), `skeleton` (optionnel), `key.name`.
- i18n_week_start: `code` (1..7), `key.name`.
- i18n_time_notation: `code` (12h/24h), `key.name`.
- i18n_decimal_separator: `code` ("," | "."), `key.name`.
- i18n_thousand_separator: `code` (" " | "," | "."), `key.name`.

Toutes exposent des clés i18n (`key.name`) pour l'affichage UI, et des index d'unicité sur leur `code`/`pattern`.

---

### Traductions (texte)
- i18n_key: dictionnaire des clés i18n (unique sur `key`).
- i18n_translation: relation `i18n_key -> i18n_language` avec `text`.
- Requêtes UI: ex: `name_i18n->i18n_translation` filtré par `out = type::thing('i18n_language', 'FR')`.

---

### Orchestration (déploiement)
- `fn::i18n_tables_deploy_initialise` / `fn::i18n_tables_deploy` créent dans cet ordre:
  1) i18n_language
  2) i18n_datetime_format
  3) i18n_locale
  4) i18n_key
  5) i18n_translation
  6) i18n_time_notation
  7) i18n_date_pattern
  8) i18n_time_pattern
  9) i18n_week_start
  10) i18n_decimal_separator
  11) i18n_thousand_separator
- Les seeds (facultatifs) sont définis séparément; ici seules les tables sont requises.

---

### Lignes directrices
- Pivot locales: BCP 47 (sélection d'une locale).
- Pivot langues: ISO 639‑1 (résolution des traductions et plural rules).
- Timezone: reste séparé (choix utilisateur/organisation), `i18n_locale.timezone` est optionnelle.
- Respecter CLDR (UTS #35) pour `pattern/skeleton` de date/heure.

---

### Évolutions possibles
- Script (ISO 15924), système de calendrier, collation/tri, système d'unités (metric/imperial), numbering system (CLDR), règles de première semaine, week‑end, temperatureUnit, paperSize, parentLocale (fallback).


