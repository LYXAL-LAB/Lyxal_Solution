-- ============================================================
-- TABLE: provider (CATALOGUE APPS)
-- Namespace: LYXAL_CONNECT / Database: CORE
-- ============================================================

DEFINE TABLE IF NOT EXISTS provider SCHEMAFULL
    PERMISSIONS 
    FOR SELECT WHERE $auth.role = 'admin' OR $auth.role = 'service'
    FOR CREATE, UPDATE, DELETE NONE; 

-- CHAMPS
DEFINE FIELD IF NOT EXISTS name ON TABLE provider TYPE string;
DEFINE FIELD IF NOT EXISTS slug ON TABLE provider TYPE string; -- "google", "slack"

DEFINE FIELD IF NOT EXISTS auth_config ON TABLE provider TYPE object;
-- Ex: { type: "oauth2", auth_url: "...", token_url: "...", client_id: "...", client_secret: "..." }

DEFINE FIELD IF NOT EXISTS api_spec ON TABLE provider TYPE string; 
-- Contenu OpenAPI (Swagger) au format JSON ou YAML stringifié.

DEFINE FIELD IF NOT EXISTS created_at ON TABLE provider TYPE datetime DEFAULT time::now();

-- INDEX
DEFINE INDEX IF NOT EXISTS idx_slug ON TABLE provider COLUMNS slug UNIQUE;

