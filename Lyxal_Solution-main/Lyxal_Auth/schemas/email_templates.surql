-- ============================================================
-- TABLE: email_templates
-- SOURCE: email_templates.sql
-- ============================================================

DEFINE IF NOT EXISTS TABLE email_templates TYPE NORMAL SCHEMAFULL
COMMENT "Modèles d'emails personnalisés"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS

DEFINE FIELD IF NOT EXISTS tenant_id ON TABLE email_templates 
    TYPE string;

DEFINE FIELD IF NOT EXISTS id ON TABLE email_templates 
    TYPE string;

DEFINE FIELD IF NOT EXISTS language_tag ON TABLE email_templates 
    TYPE string;

DEFINE FIELD IF NOT EXISTS template_type ON TABLE email_templates 
    TYPE string
    COMMENT "Type de template (ex: SignIn, VerificationCode)";

DEFINE FIELD IF NOT EXISTS details ON TABLE email_templates 
    TYPE object
    COMMENT "Contenu du template (Subject, Body...)";

DEFINE FIELD IF NOT EXISTS created_at ON TABLE email_templates 
    TYPE datetime
    DEFAULT time::now();

-- INDEX & CONTRAINTES

-- Unique (tenant_id, language_tag, template_type)
DEFINE INDEX IF NOT EXISTS idx_unique_template ON TABLE email_templates 
    FIELDS tenant_id, language_tag, template_type UNIQUE;

DEFINE INDEX IF NOT EXISTS idx_lang ON TABLE email_templates 
    FIELDS tenant_id, language_tag;

DEFINE INDEX IF NOT EXISTS idx_type ON TABLE email_templates 
    FIELDS tenant_id, template_type;
