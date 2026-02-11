-- ============================================================
-- TABLE: daily_active_users
-- SOURCE: daily_active_users.sql
-- ============================================================

DEFINE IF NOT EXISTS TABLE daily_active_users TYPE NORMAL SCHEMAFULL
COMMENT "Statistiques des utilisateurs actifs quotidiens (DAU)"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS

DEFINE FIELD IF NOT EXISTS id ON TABLE daily_active_users 
    TYPE string;

DEFINE FIELD IF NOT EXISTS tenant_id ON TABLE daily_active_users 
    TYPE string;

DEFINE FIELD IF NOT EXISTS user_id ON TABLE daily_active_users 
    TYPE string;

DEFINE FIELD IF NOT EXISTS date ON TABLE daily_active_users 
    TYPE datetime
    DEFAULT time::now();

-- INDEX & CONTRAINTES

-- Unique (user_id, date) -> Un utilisateur compte pour 1 DAU par jour
DEFINE INDEX IF NOT EXISTS idx_unique_user_date ON TABLE daily_active_users 
    FIELDS user_id, date UNIQUE;

DEFINE INDEX IF NOT EXISTS idx_id ON TABLE daily_active_users 
    FIELDS tenant_id, id;

DEFINE INDEX IF NOT EXISTS idx_date ON TABLE daily_active_users 
    FIELDS tenant_id, date;
