-- ============================================================
-- TABLE: tenant_domain
-- DESCRIPTION: Mappage entre un nom de domaine (ex: acme.com) et un tenant.
-- C'est la clé du routage "Marque Blanche".
-- ============================================================

DEFINE TABLE tenant_domain SCHEMAFULL;

-- CHAMPS
DEFINE FIELD domain           ON TABLE tenant_domain TYPE string; -- ex: "app.acme.com"
DEFINE FIELD tenant           ON TABLE tenant_domain TYPE record<tenant>;
DEFINE FIELD is_primary       ON TABLE tenant_domain TYPE bool DEFAULT false;
DEFINE FIELD verified         ON TABLE tenant_domain TYPE bool DEFAULT false; -- SSL/DNS vérifié ?

DEFINE FIELD created_at       ON TABLE tenant_domain TYPE datetime DEFAULT time::now();

-- INDEX
DEFINE INDEX idx_domain ON TABLE tenant_domain COLUMNS domain UNIQUE;

