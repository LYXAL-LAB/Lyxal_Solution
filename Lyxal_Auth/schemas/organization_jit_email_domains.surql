-- ============================================================
-- TABLE: organization_jit_email_domains
-- SOURCE: organization_jit_email_domains.sql
-- ============================================================

DEFINE IF NOT EXISTS TABLE organization_jit_email_domains TYPE NORMAL SCHEMAFULL
COMMENT "Domaines email pour provisionnement JIT dans une organisation"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS

DEFINE FIELD IF NOT EXISTS tenant_id ON TABLE organization_jit_email_domains 
    TYPE string;

DEFINE FIELD IF NOT EXISTS organization_id ON TABLE organization_jit_email_domains 
    TYPE string;
-- Reference organizations

DEFINE FIELD IF NOT EXISTS email_domain ON TABLE organization_jit_email_domains 
    TYPE string;

-- INDEX & CONTRAINTES

-- PK Composite (tenant_id, organization_id, email_domain)
DEFINE INDEX IF NOT EXISTS idx_pk_composite ON TABLE organization_jit_email_domains 
    FIELDS tenant_id, organization_id, email_domain UNIQUE;
