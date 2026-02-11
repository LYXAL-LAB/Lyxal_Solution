-- =====================================================================================
-- TABLE: business_administrative_status
-- Description: États administratifs des unités légales (Active, Cessée)
-- Module: Business
-- =====================================================================================

DEFINE TABLE IF NOT EXISTS business_administrative_status SCHEMAFULL
    COMMENT 'États administratifs des unités légales';

-- =====================================================================================
-- CHAMPS
-- =====================================================================================

DEFINE FIELD IF NOT EXISTS code ON TABLE business_administrative_status
    TYPE string
    COMMENT 'Code officiel INSEE (A, C)';

DEFINE FIELD IF NOT EXISTS name_i18n_key ON TABLE business_administrative_status
    TYPE record<i18n_key>
    COMMENT 'Clé i18n pour le libellé du statut';

DEFINE FIELD IF NOT EXISTS description_i18n_key ON TABLE business_administrative_status
    TYPE record<i18n_key>
    COMMENT 'Clé i18n pour la description du statut';

DEFINE FIELD IF NOT EXISTS is_active ON TABLE business_administrative_status
    TYPE bool
    COMMENT 'Indique si l\'entreprise est active';

DEFINE FIELD IF NOT EXISTS sort_order ON TABLE business_administrative_status
    TYPE int
    DEFAULT 0
    COMMENT 'Ordre de tri';

-- =====================================================================================
-- INDEX
-- =====================================================================================

DEFINE INDEX IF NOT EXISTS code_idx ON TABLE business_administrative_status COLUMNS code UNIQUE
    COMMENT 'Index unique sur le code de statut';

-- =====================================================================================
-- PERMISSIONS (à adapter selon vos besoins)
-- =====================================================================================

-- DEFINE ACCESS POLICY read_all ON TABLE business_administrative_status
--     FOR select WHERE true;

