-- =============================================================================
-- TABLE: system_tag_pattern
-- =============================================================================
-- BUT & RÔLE
-- - Définir des familles/contextes de tags via un préfixe (ex: state_, product_, product_category_)
-- - Structurer une taxonomie : hiérarchie parent/enfant de patterns
-- - Porter l’exclusivité fonctionnelle via `is_exclusive` (un seul tag actif par contexte/pattern)
-- - Centraliser l’i18n (key.name / key.description) pour libellés et descriptions de famille
-- - Remplace la notion de "group" (exclusivité portée par le pattern plutôt que par une table séparée)
-- 
-- FONCTIONS À IMPLÉMENTER PROCHAINEMENT
-- - CRUD
--   - fn::system_tag_pattern_create_system($name, $key_name_id, $key_description_id, $parent_id, $is_exclusive) / fn::system_tag_pattern_create(...)
--   - fn::system_tag_pattern_get_system($pattern_id) / fn::system_tag_pattern_get($pattern_id)
--   - fn::system_tag_pattern_list_system() / fn::system_tag_pattern_list()
--   - fn::system_tag_pattern_update_system($pattern_id, $etag, $name, $key_name_id, $key_description_id, $parent_id, $is_exclusive) / fn::system_tag_pattern_update(...)
--   - fn::system_tag_pattern_delete_system($pattern_id) / fn::system_tag_pattern_delete($pattern_id)
-- - fn::system_tag_pattern_resolve_by_prefix_system($prefix) / fn::system_tag_pattern_resolve_by_prefix($prefix)
--   Résoudre un préfixe (ou nom de pattern) vers le record pattern.
-- - fn::system_tag_pattern_list_children_system($pattern_id) / fn::system_tag_pattern_list_children($pattern_id)
--   Lister les patterns enfants (navigation hiérarchique).
-- - fn::system_tag_pattern_validate_tag_name_system($pattern_id, $tag_name) / fn::system_tag_pattern_validate_tag_name($pattern_id, $tag_name)
--   Vérifier la conformité d’un nom de tag par rapport au pattern (préfixe, format).
-- - fn::system_tag_pattern_enforce_exclusivity_system($pattern_id, $target_table, $target_id, $new_tag_id)
--   Appliquer l’exclusivité : détacher les autres tags de ce pattern sur la même cible.
-- - fn::system_tag_pattern_stats_system($pattern_id) / fn::system_tag_pattern_stats($pattern_id)
--   Statistiques d’usage (déléguées à system_tag_history + agrégations).
-- 
-- REMARQUES D'IMPLÉMENTATION
-- - DEFINE FUNCTION IF NOT EXISTS, RETURN (pas SELECT), IF { } ELSE { } modernes
-- - i18n: retours et logs avec messages.key/messages.vars, fallback côté UI
-- - Logging: system_log (result 'error' pour validations, 'failure' pour échecs d'exécution), run_id propagé
-- - Validations: snake_case, préfixe conforme au pattern, parent existant, etag pour update, REJECT delete si tags rattachés
-- 
-- ÉVÉNEMENTS À CONSIDÉRER
-- - Sur attache de tag (côté fonctions resources): si pattern.is_exclusive = true, désactiver/détacher les autres tags du même pattern
-- - Sur création/mise à jour d’un tag : valider le rattachement `tag_pattern` et la conformité du nom (préfixe + snake_case)
-- - Sur suppression d’un pattern : empêcher si des tags y sont encore rattachés (ou migration préalable)
-- 
-- NOTES
-- - i18n : `key.name`/`key.description` obligatoires pour UI-ready
-- - Sécurité : permissions admin/system, validations côté fn avant mutations
-- - Performances : indexes sur name, key.name/description, parent_pattern, is_exclusive
-- =============================================================================
DEFINE TABLE IF NOT EXISTS system_tag_pattern TYPE NORMAL SCHEMAFULL
  COMMENT 'Pattern tags pour classification'
  PERMISSIONS
    FOR CREATE, DELETE, UPDATE, SELECT
    WHERE array::contains($auth.permissions, 'lyxal_admin') 
    OR array::contains($auth.permissions, 'lyxal_system');

  DEFINE FIELD IF NOT EXISTS name ON system_tag_pattern 
  TYPE string
  ASSERT string::len(string::trim($value)) > 0
  COMMENT 'Nom/code unique du pattern tag (ex: module, produit_famille, etc.)';

  DEFINE FIELD IF NOT EXISTS key.name ON system_tag_pattern 
  TYPE record<i18n_key>
  REFERENCE ON DELETE REJECT
  VALUE type::thing('i18n_key', $value)
  COMMENT 'Clé i18n du libellé du pattern tag';

  DEFINE FIELD IF NOT EXISTS key.description ON system_tag_pattern 
  TYPE record<i18n_key>
  REFERENCE ON DELETE REJECT
  VALUE type::thing('i18n_key', $value)
  COMMENT 'Clé i18n de la description du pattern tag';

  DEFINE FIELD IF NOT EXISTS parent_pattern ON system_tag_pattern 
  TYPE option<record<system_tag_pattern>>
  REFERENCE ON DELETE REJECT
  VALUE IF $value != NONE THEN type::thing('system_tag_pattern', $value) ELSE NONE END
  COMMENT 'Pattern tag parent';

  DEFINE FIELD IF NOT EXISTS is_protected ON system_tag_pattern 
  TYPE bool 
  DEFAULT false
  COMMENT 'Indique si ce pattern tag est protégé';

  DEFINE FIELD IF NOT EXISTS is_active ON system_tag_pattern 
  TYPE bool 
  DEFAULT true
  COMMENT 'Indique si ce pattern tag est actif';

  DEFINE FIELD IF NOT EXISTS is_exclusive ON system_tag_pattern 
  TYPE bool 
  DEFAULT false
  COMMENT 'Indique si les tags rattachés à ce pattern sont exclusifs (un seul actif par contexte)';

  DEFINE FIELD IF NOT EXISTS etag ON system_tag_pattern 
  TYPE int
  DEFAULT 1
  COMMENT 'Version du pattern tag';

  DEFINE FIELD IF NOT EXISTS timestamp ON system_tag_pattern 
  TYPE datetime
  DEFAULT time::now()
  COMMENT 'Timestamp de création du pattern tag';

  DEFINE FIELD IF NOT EXISTS updated_at ON system_tag_pattern 
  TYPE datetime
  VALUE time::now()
  COMMENT 'Timestamp de mise à jour du pattern tag';

  DEFINE FIELD IF NOT EXISTS created_by ON system_tag_pattern 
  TYPE option<record<base_user>>
  REFERENCE ON DELETE REJECT
  VALUE IF $value != NONE THEN type::thing('base_user', $value) ELSE NONE END
  COMMENT 'Utilisateur qui a créé le pattern tag';

  DEFINE FIELD IF NOT EXISTS payload ON system_tag_pattern
  FLEXIBLE 
  TYPE option<object>
  DEFAULT {}
  COMMENT 'Payload du pattern tag';

  -- Define indexes
  DEFINE INDEX IF NOT EXISTS idx_tag_pattern_name_unique ON system_tag_pattern 
  FIELDS name UNIQUE
  COMMENT 'Index sur le nom du pattern tag (unique)';

  DEFINE INDEX IF NOT EXISTS idx_tag_pattern_parent_pattern ON system_tag_pattern 
  FIELDS parent_pattern
  COMMENT 'Index sur le pattern tag parent';

  DEFINE INDEX IF NOT EXISTS idx_tag_pattern_payload ON system_tag_pattern 
  FIELDS payload
  COMMENT 'Index sur le payload du pattern tag';

  DEFINE INDEX IF NOT EXISTS idx_tag_pattern_key_name ON system_tag_pattern
  FIELDS key.name
  COMMENT 'Index sur la clé i18n du libellé du pattern tag';

  DEFINE INDEX IF NOT EXISTS idx_tag_pattern_key_description ON system_tag_pattern
  FIELDS key.description
  COMMENT 'Index sur la clé i18n de la description du pattern tag';

  DEFINE INDEX IF NOT EXISTS idx_tag_pattern_is_exclusive ON system_tag_pattern 
  FIELDS is_exclusive
  COMMENT 'Index sur l\'exclusivité du pattern';