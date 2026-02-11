### Tables translate — Inventaire et dépendances

#### Tables
- `builder_i18n_key`
  - Champs: description, created_at, updated_at, etag
  - Dépendances: aucune
  - Référencée par: `builder_i18n_translation.in`

- `builder_i18n_translation` (RELATION)
  - Champs: in (record<builder_i18n_key>), out (record<i18n_language>), text, created_at, updated_at, etag
  - Index: UNIQUE(in, out)
  - Dépendances: `builder_i18n_key` (in), `i18n_language` (out)

#### Index vérifiés
- `builder_i18n_translation`: i18n_translation_unique (in, out) UNIQUE


