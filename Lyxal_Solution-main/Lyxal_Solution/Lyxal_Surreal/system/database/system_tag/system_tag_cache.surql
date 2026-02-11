-- =============================================================================
-- TABLE: system_tag_cache
-- =============================================================================
-- DESCRIPTION: Mise en cache des tags fréquemment utilisés
-- 
-- Fonctions à implémenter prochainement :
-- - fn::system_tag_cache_purge_expired_system() / fn::system_tag_cache_purge_expired()
--   Purger les entrées dont expire_at est dépassé.
-- - fn::system_tag_cache_touch_system($tag_id) / fn::system_tag_cache_touch($tag_id)
--   Incrémenter usage_count et mettre à jour last_used_at pour un tag.
-- - fn::system_tag_cache_mark_hot_system($tag_id, $state) / fn::system_tag_cache_mark_hot($tag_id, $state)
--   Marquer/démarquer un tag comme « hot » (state string attendu: 'true' | 'false').
-- - fn::system_tag_cache_rebuild_for_pattern_system($pattern_id) / fn::system_tag_cache_rebuild_for_pattern($pattern_id)
--   Reconstruire/rafraîchir les entrées de cache pour un pattern donné.
-- =============================================================================
DEFINE TABLE IF NOT EXISTS system_tag_cache TYPE NORMAL SCHEMAFULL
COMMENT 'Cache des tags'
PERMISSIONS
  FOR select WHERE array::contains($auth.permissions, 'lyxal_admin') OR array::contains($auth.permissions, 'lyxal_system'),
  FOR create WHERE array::contains($auth.permissions, 'lyxal_admin') OR array::contains($auth.permissions, 'lyxal_system'),
  FOR update WHERE array::contains($auth.permissions, 'lyxal_admin') OR array::contains($auth.permissions, 'lyxal_system'),
  FOR delete WHERE array::contains($auth.permissions, 'lyxal_admin') OR array::contains($auth.permissions, 'lyxal_system');

-- Références
DEFINE FIELD IF NOT EXISTS tag ON system_tag_cache
TYPE record<system_tag>
VALUE type::thing('system_tag', $value)
REFERENCE ON DELETE REJECT
COMMENT "Tag mis en cache (obligatoire)";

DEFINE FIELD IF NOT EXISTS pattern_tag ON system_tag_cache
TYPE option<record<system_tag_pattern>>
VALUE IF $value != NONE THEN type::thing('system_tag_pattern', $value) ELSE NONE END
REFERENCE ON DELETE REJECT
COMMENT "Pattern associé (facultatif)";

-- Métriques de cache
DEFINE FIELD IF NOT EXISTS usage_count ON system_tag_cache
TYPE int
DEFAULT 0
ASSERT $value >= 0
COMMENT "Compteur d'utilisations (accès/attaches)";

DEFINE FIELD IF NOT EXISTS last_used_at ON system_tag_cache
TYPE datetime
DEFAULT time::now()
COMMENT "Dernière utilisation référencée";

DEFINE FIELD IF NOT EXISTS is_hot ON system_tag_cache
TYPE bool
DEFAULT false
COMMENT "Marqueur de tag 'chaud' (accès élevé)";

DEFINE FIELD IF NOT EXISTS expire_at ON system_tag_cache
TYPE option<datetime>
COMMENT "Date d'expiration facultative de l'entrée de cache";

-- Audit / technique
DEFINE FIELD IF NOT EXISTS etag ON system_tag_cache
TYPE int
DEFAULT 1
COMMENT "Contrôle optimiste (version)";

DEFINE FIELD IF NOT EXISTS created_at ON system_tag_cache
TYPE datetime
VALUE time::now()
COMMENT "Date de création de l'entrée cache";

DEFINE FIELD IF NOT EXISTS updated_at ON system_tag_cache
TYPE datetime
VALUE time::now()
COMMENT "Date de mise à jour de l'entrée cache";

DEFINE FIELD IF NOT EXISTS created_by ON system_tag_cache
TYPE option<record<base_user>>
VALUE IF $value != NONE THEN type::thing('base_user', $value) ELSE NONE END
REFERENCE ON DELETE REJECT
COMMENT "Créé par";

DEFINE FIELD IF NOT EXISTS updated_by ON system_tag_cache
TYPE option<record<base_user>>
VALUE IF $value != NONE THEN type::thing('base_user', $value) ELSE NONE END
REFERENCE ON DELETE REJECT
COMMENT "Mis à jour par";

DEFINE FIELD IF NOT EXISTS payload ON system_tag_cache
FLEXIBLE
TYPE option<object>
DEFAULT {}
COMMENT "Données additionnelles spécifiques au cache";

-- Index
DEFINE INDEX IF NOT EXISTS idx_tag_cache_tag ON system_tag_cache 
FIELDS tag UNIQUE
COMMENT "Un cache par tag";

DEFINE INDEX IF NOT EXISTS idx_tag_cache_pattern_tag ON system_tag_cache 
FIELDS pattern_tag
COMMENT "Filtrage par pattern";

DEFINE INDEX IF NOT EXISTS idx_tag_cache_usage_count ON system_tag_cache 
FIELDS usage_count
COMMENT "Tri/filtrage par volume d'utilisation";

DEFINE INDEX IF NOT EXISTS idx_tag_cache_last_used_at ON system_tag_cache 
FIELDS last_used_at
COMMENT "Tri par dernière utilisation";

DEFINE INDEX IF NOT EXISTS idx_tag_cache_is_hot ON system_tag_cache 
FIELDS is_hot
COMMENT "Filtrage des tags 'chauds'";