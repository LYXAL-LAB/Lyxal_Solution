-- =============================================================================
-- TABLE: system_tag_alias
-- =============================================================================
-- DESCRIPTION: Alias des tags
-- 
-- ### Synonymes et alias
-- Description** : Plusieurs noms pour le même tag
-- **Utilité** : Migration, multilingue, compatibilité
--
-- Fonctions à implémenter prochainement :
-- - fn::system_tag_alias_resolve_system($alias, $pattern_id) / fn::system_tag_alias_resolve($alias, $pattern_id)
--   Résoudre un alias vers le tag canonique (avec ou sans scope de pattern).
-- - fn::system_tag_alias_upsert_system($alias, $tag_id, $pattern_id) / fn::system_tag_alias_upsert($alias, $tag_id, $pattern_id)
--   Créer/mettre à jour un alias (en forçant unicité pattern+alias et normalisation).
-- - fn::system_tag_alias_deactivate_system($alias, $pattern_id) / fn::system_tag_alias_deactivate($alias, $pattern_id)
--   Désactiver un alias.
-- - fn::system_tag_alias_list_for_tag_system($tag_id) / fn::system_tag_alias_list_for_tag($tag_id)
--   Lister les alias pour un tag.
-- - fn::system_tag_alias_list_for_pattern_system($pattern_id) / fn::system_tag_alias_list_for_pattern($pattern_id)
--   Lister les alias d'un pattern donné.
-- =============================================================================
DEFINE TABLE IF NOT EXISTS system_tag_alias TYPE NORMAL SCHEMAFULL
COMMENT 'Alias des tags'
PERMISSIONS
  FOR select WHERE array::contains($auth.permissions, 'lyxal_admin') OR array::contains($auth.permissions, 'lyxal_system'),
  FOR create WHERE array::contains($auth.permissions, 'lyxal_admin') OR array::contains($auth.permissions, 'lyxal_system'),
  FOR update WHERE array::contains($auth.permissions, 'lyxal_admin') OR array::contains($auth.permissions, 'lyxal_system'),
  FOR delete WHERE array::contains($auth.permissions, 'lyxal_admin') OR array::contains($auth.permissions, 'lyxal_system');

-- Références
DEFINE FIELD IF NOT EXISTS target_tag ON system_tag_alias
TYPE record<system_tag>
VALUE type::thing('system_tag', $value)
REFERENCE ON DELETE REJECT
COMMENT "Tag canonique ciblé par l'alias (obligatoire)";

DEFINE FIELD IF NOT EXISTS pattern_tag ON system_tag_alias
TYPE option<record<system_tag_pattern>>
VALUE IF $value != NONE THEN type::thing('system_tag_pattern', $value) ELSE NONE END
REFERENCE ON DELETE REJECT
COMMENT "Scope facultatif de l'alias (pattern)";

-- Alias
DEFINE FIELD IF NOT EXISTS alias ON system_tag_alias
TYPE string
VALUE string::lower(string::trim($value))
ASSERT string::len($value) > 0 AND string::len($value) <= 150
COMMENT "Nom alternatif (synonyme) normalisé (trim + lower)";

DEFINE FIELD IF NOT EXISTS is_active ON system_tag_alias
TYPE bool
DEFAULT true
COMMENT "Activation de l'alias";

-- Audit / technique
DEFINE FIELD IF NOT EXISTS etag ON system_tag_alias
TYPE int
DEFAULT 1
COMMENT "Contrôle optimiste (version)";

DEFINE FIELD IF NOT EXISTS created_at ON system_tag_alias
TYPE datetime
VALUE time::now()
COMMENT "Date de création";

DEFINE FIELD IF NOT EXISTS updated_at ON system_tag_alias
TYPE datetime
VALUE time::now()
COMMENT "Date de mise à jour";

DEFINE FIELD IF NOT EXISTS created_by ON system_tag_alias
TYPE option<record<base_user>>
VALUE IF $value != NONE THEN type::thing('base_user', $value) ELSE NONE END
REFERENCE ON DELETE REJECT
COMMENT "Créé par";

DEFINE FIELD IF NOT EXISTS updated_by ON system_tag_alias
TYPE option<record<base_user>>
VALUE IF $value != NONE THEN type::thing('base_user', $value) ELSE NONE END
REFERENCE ON DELETE REJECT
COMMENT "Mis à jour par";

DEFINE FIELD IF NOT EXISTS payload ON system_tag_alias
FLEXIBLE
TYPE option<object>
DEFAULT {}
COMMENT "Données additionnelles";

-- Index
DEFINE INDEX IF NOT EXISTS idx_tag_alias_unique ON system_tag_alias
FIELDS pattern_tag, alias UNIQUE
COMMENT "Unicité par (pattern, alias). Si pattern absent, alias global unique (logique applicative)";

DEFINE INDEX IF NOT EXISTS idx_tag_alias_target_tag ON system_tag_alias
FIELDS target_tag
COMMENT "Recherche par tag canonique";

DEFINE INDEX IF NOT EXISTS idx_tag_alias_is_active ON system_tag_alias
FIELDS is_active
COMMENT "Filtrage par état d'activation";

DEFINE INDEX IF NOT EXISTS idx_tag_alias_updated_at ON system_tag_alias
FIELDS updated_at
COMMENT "Tri par date de mise à jour";