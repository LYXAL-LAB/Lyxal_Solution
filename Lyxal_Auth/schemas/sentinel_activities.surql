-- ============================================================
-- TABLE: sentinel_activities
-- SOURCE: sentinel_activities.sql
-- ============================================================

DEFINE IF NOT EXISTS TABLE sentinel_activities TYPE NORMAL SCHEMAFULL
COMMENT "Journal d'activité Sentinel (Sécurité)"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS

DEFINE FIELD IF NOT EXISTS tenant_id ON TABLE sentinel_activities 
    TYPE string;

DEFINE FIELD IF NOT EXISTS id ON TABLE sentinel_activities 
    TYPE string;

DEFINE FIELD IF NOT EXISTS target_type ON TABLE sentinel_activities 
    TYPE string;

DEFINE FIELD IF NOT EXISTS target_hash ON TABLE sentinel_activities 
    TYPE string;

DEFINE FIELD IF NOT EXISTS action ON TABLE sentinel_activities 
    TYPE string;

DEFINE FIELD IF NOT EXISTS action_result ON TABLE sentinel_activities 
    TYPE string
    ASSERT $value INSIDE ['Success', 'Failed'];

DEFINE FIELD IF NOT EXISTS payload ON TABLE sentinel_activities 
    TYPE object;

DEFINE FIELD IF NOT EXISTS decision ON TABLE sentinel_activities 
    TYPE string
    ASSERT $value INSIDE ['Undecided', 'Allowed', 'Blocked', 'Challenge'];

DEFINE FIELD IF NOT EXISTS decision_expires_at ON TABLE sentinel_activities 
    TYPE datetime
    DEFAULT time::now();

DEFINE FIELD IF NOT EXISTS created_at ON TABLE sentinel_activities 
    TYPE datetime
    DEFAULT time::now();

-- INDEX & CONTRAINTES

DEFINE INDEX IF NOT EXISTS idx_id ON TABLE sentinel_activities 
    FIELDS tenant_id, id;

DEFINE INDEX IF NOT EXISTS idx_target ON TABLE sentinel_activities 
    FIELDS tenant_id, target_type, target_hash;

DEFINE INDEX IF NOT EXISTS idx_full_log ON TABLE sentinel_activities 
    FIELDS tenant_id, target_type, target_hash, action, action_result, decision;
