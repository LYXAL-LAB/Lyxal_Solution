DEFINE TABLE IF NOT EXISTS system_tag TYPE NORMAL SCHEMAFULL
  COMMENT 'Tags pour classification (avec couleur optionnelle)'
  PERMISSIONS
    FOR CREATE, DELETE, UPDATE, SELECT
    WHERE array::contains($auth.permissions, 'lyxal_admin') 
    OR array::contains($auth.permissions, 'lyxal_system');

  DEFINE FIELD IF NOT EXISTS name ON system_tag 
  TYPE string
  ASSERT string::len(string::trim($value)) > 0 AND $value MATCHES /^[a-z0-9_]+$/
  COMMENT 'Nom/code unique du tag (ex: module_crm)';

  DEFINE FIELD IF NOT EXISTS key.name ON system_tag 
  TYPE record<i18n_key>
  REFERENCE ON DELETE REJECT
  VALUE type::thing('i18n_key', $value)
  COMMENT 'Clé i18n du libellé du tag';

  DEFINE FIELD IF NOT EXISTS parent_tag ON system_tag 
  TYPE option<record<system_tag>>
  REFERENCE ON DELETE REJECT
  VALUE IF $value != NONE THEN type::thing('system_tag', $value) ELSE NONE END
  COMMENT 'Tag parent';

  DEFINE FIELD IF NOT EXISTS tag_pattern ON system_tag 
  TYPE record<system_tag_pattern>
  REFERENCE ON DELETE REJECT
  VALUE type::thing('system_tag_pattern', $value)
  COMMENT 'Pattern tag';

  DEFINE FIELD IF NOT EXISTS key.description ON system_tag 
  TYPE record<i18n_key>
  REFERENCE ON DELETE REJECT
  VALUE type::thing('i18n_key', $value)
  COMMENT 'Clé i18n de la description du tag';

  DEFINE FIELD IF NOT EXISTS color ON system_tag 
  TYPE option<string>
  COMMENT 'Code couleur hex ou nom (optionnel, ex: CODE DAISYui, "#2196F3" ou "blue")';

  DEFINE FIELD IF NOT EXISTS display_order ON system_tag 
  TYPE int 
  DEFAULT 0
  COMMENT 'Ordre d\'affichage des tags (0 par défaut)';

  DEFINE FIELD IF NOT EXISTS is_protected ON system_tag 
  TYPE bool 
  DEFAULT false
  COMMENT 'Indique si ce tag est protégé pour le système';

  DEFINE FIELD IF NOT EXISTS is_active ON system_tag 
  TYPE bool 
  DEFAULT true
  COMMENT 'Indique si ce tag est actif';

  DEFINE FIELD IF NOT EXISTS inherit_permissions ON system_tag 
  TYPE bool 
  DEFAULT true
  COMMENT 'Hérite automatiquement des ACL du parent';

  DEFINE FIELD IF NOT EXISTS icon ON system_tag 
  TYPE option<string>
  COMMENT "Icône du tag (nom ou URL)";
  
  DEFINE FIELD IF NOT EXISTS expires_at ON system_tag 
  TYPE option<datetime>
  COMMENT "Date d'expiration du tag";

  DEFINE FIELD IF NOT EXISTS etag ON system_tag 
  TYPE int
  DEFAULT 1
  COMMENT 'Version du tag';

  DEFINE FIELD IF NOT EXISTS timestamp ON system_tag 
  TYPE datetime
  DEFAULT time::now()
  COMMENT 'Timestamp de création du tag';

  DEFINE FIELD IF NOT EXISTS updated_at ON system_tag 
  TYPE datetime
  VALUE time::now()
  COMMENT 'Timestamp de mise à jour du tag';

  DEFINE FIELD IF NOT EXISTS last_used_at ON system_tag 
  TYPE datetime
  COMMENT 'Timestamp de dernière utilisation du tag';

  DEFINE FIELD IF NOT EXISTS usage_count ON system_tag 
  TYPE int
  DEFAULT 0
  ASSERT $value >= 0
  COMMENT 'Compteur d\'utilisations (dénormalisation)';

  DEFINE FIELD IF NOT EXISTS payload ON system_tag 
  FLEXIBLE
  TYPE option<object>
  DEFAULT {}
  COMMENT 'Payload du tag';

  -- Define indexes
  DEFINE INDEX IF NOT EXISTS idx_tag_name_unique ON system_tag 
  FIELDS name UNIQUE
  COMMENT 'Index sur le nom du tag (unique)';

  DEFINE INDEX IF NOT EXISTS idx_tag_parent_tag ON system_tag 
  FIELDS parent_tag
  COMMENT 'Index sur le tag parent';

  DEFINE INDEX IF NOT EXISTS idx_tag_is_active ON system_tag 
  FIELDS is_active
  COMMENT 'Index sur le statut actif du tag';

  DEFINE INDEX IF NOT EXISTS idx_tag_is_protected ON system_tag 
  FIELDS is_protected
  COMMENT 'Index sur le statut protégé du tag';

  DEFINE INDEX IF NOT EXISTS idx_tag_pattern ON system_tag 
  FIELDS tag_pattern
  COMMENT 'Index sur le pattern du tag';

  DEFINE INDEX IF NOT EXISTS idx_tag_last_used_at ON system_tag 
  FIELDS last_used_at
  COMMENT 'Index sur la dernière utilisation';

  DEFINE INDEX IF NOT EXISTS idx_tag_usage_count ON system_tag 
  FIELDS usage_count
  COMMENT 'Index sur le compteur d\'utilisations';

  DEFINE INDEX IF NOT EXISTS idx_tag_display_order ON system_tag 
  FIELDS display_order
  COMMENT 'Index sur l\'ordre d\'affichage';

  DEFINE INDEX IF NOT EXISTS idx_tag_key_name ON system_tag 
  FIELDS key.name
  COMMENT 'Index sur la clé i18n du libellé du tag';
