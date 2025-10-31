-- =============================================================================
-- TABLE: system_tag_acl
-- =============================================================================
-- DESCRIPTION: Permissions granulaires par tag (utilisateur/groupe/rôle)
-- 
-- Fonctions à implémenter prochainement :
-- - fn::system_tag_acl_upsert_system($tag_id, $principal, $type, $allow_view, $allow_use, $allow_modify) / fn::system_tag_acl_upsert(...)
-- - fn::system_tag_acl_list_for_tag_system($tag_id) / fn::system_tag_acl_list_for_tag($tag_id)
-- - fn::system_tag_acl_effective_for_user_system($user_id, $tag_id) / fn::system_tag_acl_effective_for_user($user_id, $tag_id)
-- - fn::system_tag_acl_delete_system($acl_id) / fn::system_tag_acl_delete($acl_id)
-- =============================================================================
DEFINE TABLE IF NOT EXISTS system_tag_acl TYPE NORMAL SCHEMAFULL
COMMENT 'ACL par tag (user/groupe/rôle)'
PERMISSIONS
  FOR select, create, update, delete
  WHERE array::contains($auth.permissions, 'lyxal_admin') OR array::contains($auth.permissions, 'lyxal_system');

-- Référence tag
DEFINE FIELD IF NOT EXISTS tag ON system_tag_acl
TYPE record<system_tag>
VALUE type::thing('system_tag', $value)
REFERENCE ON DELETE REJECT
COMMENT 'Tag concerné';

-- Principaux (un seul des trois doit être non NONE)
DEFINE FIELD IF NOT EXISTS principal_user ON system_tag_acl
TYPE option<record<base_user>>
VALUE IF $value != NONE THEN type::thing('base_user', $value) ELSE NONE END
REFERENCE ON DELETE REJECT
COMMENT 'Utilisateur cible (optionnel)';

DEFINE FIELD IF NOT EXISTS principal_group ON system_tag_acl
TYPE option<record<base_user_group>>
VALUE IF $value != NONE THEN type::thing('base_user_group', $value) ELSE NONE END
REFERENCE ON DELETE REJECT
COMMENT 'Groupe cible (optionnel)';

DEFINE FIELD IF NOT EXISTS principal_role ON system_tag_acl
TYPE option<record<base_user_role>>
VALUE IF $value != NONE THEN type::thing('base_user_role', $value) ELSE NONE END
REFERENCE ON DELETE REJECT
COMMENT 'Rôle cible (optionnel)';

DEFINE FIELD IF NOT EXISTS allow_view ON system_tag_acl TYPE bool DEFAULT false;
DEFINE FIELD IF NOT EXISTS allow_use ON system_tag_acl TYPE bool DEFAULT false;
DEFINE FIELD IF NOT EXISTS allow_modify ON system_tag_acl TYPE bool DEFAULT false;

DEFINE FIELD IF NOT EXISTS is_active ON system_tag_acl TYPE bool DEFAULT true;

-- Audit / technique
DEFINE FIELD IF NOT EXISTS etag ON system_tag_acl TYPE int DEFAULT 1;
DEFINE FIELD IF NOT EXISTS created_at ON system_tag_acl TYPE datetime VALUE time::now();
DEFINE FIELD IF NOT EXISTS updated_at ON system_tag_acl TYPE datetime VALUE time::now();
DEFINE FIELD IF NOT EXISTS created_by ON system_tag_acl TYPE option<record<base_user>> VALUE IF $value != NONE THEN type::thing('base_user', $value) ELSE NONE END REFERENCE ON DELETE REJECT;
DEFINE FIELD IF NOT EXISTS updated_by ON system_tag_acl TYPE option<record<base_user>> VALUE IF $value != NONE THEN type::thing('base_user', $value) ELSE NONE END REFERENCE ON DELETE REJECT;
DEFINE FIELD IF NOT EXISTS payload ON system_tag_acl FLEXIBLE TYPE option<object> DEFAULT {};

-- Indexes
DEFINE INDEX IF NOT EXISTS idx_tag_acl_tag ON system_tag_acl FIELDS tag;
DEFINE INDEX IF NOT EXISTS idx_tag_acl_principals ON system_tag_acl FIELDS principal_user, principal_group, principal_role;
DEFINE INDEX IF NOT EXISTS idx_tag_acl_active ON system_tag_acl FIELDS is_active;
DEFINE INDEX IF NOT EXISTS idx_tag_acl_updated_at ON system_tag_acl FIELDS updated_at;

-- Unicité logique (assurée en fn): un seul principal non NONE par ligne, et unique par (tag, principal)

