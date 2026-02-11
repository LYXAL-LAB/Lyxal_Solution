-- =====================================================================================
-- TABLE: society_activity_status
-- Description: États administratifs des unités légales (Active, Cessée)
-- Module: Base
-- =====================================================================================

DEFINE TABLE IF NOT EXISTS society_activity_status TYPE NORMAL SCHEMAFULL
    COMMENT 'États administratifs des unités légales'
    PERMISSIONS FOR SELECT FULL
    FOR CREATE, UPDATE, DELETE NONE;

-- =====================================================================================
-- CHAMPS
-- =====================================================================================

DEFINE FIELD IF NOT EXISTS code ON TABLE society_activity_status
    TYPE string
    COMMENT 'Code officiel INSEE (A, C)';

DEFINE FIELD IF NOT EXISTS name_i18n_key ON TABLE society_activity_status
    TYPE record<i18n_key>
    COMMENT 'Clé i18n pour le libellé du statut';

DEFINE FIELD IF NOT EXISTS description_i18n_key ON TABLE society_activity_status
    TYPE record<i18n_key>
    COMMENT 'Clé i18n pour la description du statut';

DEFINE FIELD IF NOT EXISTS is_active ON TABLE society_activity_status
    TYPE bool
    COMMENT 'Indique si l\'entreprise est active';

DEFINE FIELD IF NOT EXISTS sort_order ON TABLE society_activity_status
    TYPE int
    DEFAULT 0
    COMMENT 'Ordre de tri';

-- =====================================================================================
-- INDEX
-- =====================================================================================

DEFINE INDEX IF NOT EXISTS code_idx ON TABLE society_activity_status FIELDS code UNIQUE
    COMMENT 'Index unique sur le code de statut';