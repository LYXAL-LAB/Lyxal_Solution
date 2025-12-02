-- ============================================================
-- TABLE: hooks
-- SOURCE: hooks.sql
-- ============================================================

DEFINE IF NOT EXISTS TABLE hooks TYPE NORMAL SCHEMAFULL
COMMENT "Webhooks pour l'intégration d'événements"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS

DEFINE FIELD IF NOT EXISTS tenant_id ON TABLE hooks 
    TYPE string;

DEFINE FIELD IF NOT EXISTS id ON TABLE hooks 
    TYPE string;

DEFINE FIELD IF NOT EXISTS name ON TABLE hooks 
    TYPE string
    DEFAULT '';

DEFINE FIELD IF NOT EXISTS event ON TABLE hooks 
    TYPE option<string>
    COMMENT "Deprecated: Utiliser events";

DEFINE FIELD IF NOT EXISTS events ON TABLE hooks 
    TYPE array
    DEFAULT []
    COMMENT "Liste des événements déclencheurs";

DEFINE FIELD IF NOT EXISTS config ON TABLE hooks 
    TYPE object
    COMMENT "Configuration du webhook (URL, Headers...)";

DEFINE FIELD IF NOT EXISTS signing_key ON TABLE hooks 
    TYPE string
    DEFAULT '';

DEFINE FIELD IF NOT EXISTS enabled ON TABLE hooks 
    TYPE bool
    DEFAULT true;

DEFINE FIELD IF NOT EXISTS created_at ON TABLE hooks 
    TYPE datetime
    DEFAULT time::now();

-- INDEX & CONTRAINTES

DEFINE INDEX IF NOT EXISTS idx_id ON TABLE hooks 
    FIELDS tenant_id, id;
