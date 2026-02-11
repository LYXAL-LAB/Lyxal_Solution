-- ============================================================
-- TABLE: tenant_module
-- DESCRIPTION: Active un module SaaS pour un tenant donné.
-- ============================================================

DEFINE TABLE tenant_module SCHEMAFULL;

-- CHAMPS
DEFINE FIELD tenant           ON TABLE tenant_module TYPE record<tenant>;
DEFINE FIELD module_id        ON TABLE tenant_module TYPE record<saas_registry>; -- Lien fort vers le catalogue
DEFINE FIELD status           ON TABLE tenant_module TYPE string DEFAULT 'active';
DEFINE FIELD activated_at     ON TABLE tenant_module TYPE datetime DEFAULT time::now();

-- INDEX
-- Un module ne peut être activé qu'une seule fois par tenant
DEFINE INDEX idx_tenant_module ON TABLE tenant_module COLUMNS tenant, module_id UNIQUE;
