-- ============================================================
-- TABLE: domains
-- SOURCE: domains.sql
-- ============================================================

DEFINE IF NOT EXISTS TABLE domains TYPE NORMAL SCHEMAFULL
COMMENT "Domaines personnalisés pour le tenant"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS

DEFINE FIELD IF NOT EXISTS tenant_id ON TABLE domains 
    TYPE string;

DEFINE FIELD IF NOT EXISTS id ON TABLE domains 
    TYPE string;

DEFINE FIELD IF NOT EXISTS domain ON TABLE domains 
    TYPE string;

DEFINE FIELD IF NOT EXISTS status ON TABLE domains 
    TYPE string
    DEFAULT 'PendingVerification'
    COMMENT "Statut du domaine (PendingVerification, Verified...)";

DEFINE FIELD IF NOT EXISTS error_message ON TABLE domains 
    TYPE option<string>;

DEFINE FIELD IF NOT EXISTS dns_records ON TABLE domains 
    TYPE array
    DEFAULT []
    COMMENT "Enregistrements DNS requis pour la vérification";

DEFINE FIELD IF NOT EXISTS cloudflare_data ON TABLE domains 
    TYPE option<object>;

DEFINE FIELD IF NOT EXISTS updated_at ON TABLE domains 
    TYPE datetime
    DEFAULT time::now();

DEFINE FIELD IF NOT EXISTS created_at ON TABLE domains 
    TYPE datetime
    DEFAULT time::now();

-- INDEX & CONTRAINTES

-- Unique (tenant_id, domain)
DEFINE INDEX IF NOT EXISTS idx_unique_domain ON TABLE domains 
    FIELDS tenant_id, domain UNIQUE;

DEFINE INDEX IF NOT EXISTS idx_id ON TABLE domains 
    FIELDS tenant_id, id;
