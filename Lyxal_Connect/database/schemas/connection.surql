-- ============================================================
-- TABLE: connection (LIEN UTILISATEUR -> APP)
-- Namespace: NS_USER_{UUID} / Database: MAIN
-- ============================================================

DEFINE TABLE IF NOT EXISTS connection SCHEMAFULL
    PERMISSIONS NONE; -- Accès via backend uniquement

-- CHAMPS
DEFINE FIELD IF NOT EXISTS provider_slug ON TABLE connection TYPE string; -- "google"

DEFINE FIELD IF NOT EXISTS status ON TABLE connection 
    TYPE string 
    DEFAULT 'active' 
    ASSERT $value INSIDE ['active', 'expired', 'revoked'];

-- TOKENS (CHIFFRÉS)
DEFINE FIELD IF NOT EXISTS encrypted_tokens ON TABLE connection TYPE string;
-- Contient { access_token, refresh_token, expires_at } chiffré.

DEFINE FIELD IF NOT EXISTS scopes ON TABLE connection TYPE array;
DEFINE FIELD IF NOT EXISTS scopes.* ON TABLE connection TYPE string;

DEFINE FIELD IF NOT EXISTS metadata ON TABLE connection TYPE object DEFAULT {};
-- Ex: { email: "jean@gmail.com", avatar: "..." }

DEFINE FIELD IF NOT EXISTS created_at ON TABLE connection TYPE datetime DEFAULT time::now();
DEFINE FIELD IF NOT EXISTS updated_at ON TABLE connection TYPE datetime DEFAULT time::now() VALUE time::now();

-- INDEX
DEFINE INDEX IF NOT EXISTS idx_provider ON TABLE connection COLUMNS provider_slug;

