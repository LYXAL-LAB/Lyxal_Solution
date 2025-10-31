-- =================================================================================================
-- TABLE: society_activity_code_correspondence_type
-- Description: Types de correspondances entre codes d'activité (exact, partial, etc.)
-- =================================================================================================

DEFINE TABLE IF NOT EXISTS society_activity_code_correspondence_type TYPE NORMAL SCHEMAFULL
    COMMENT 'Types de correspondances entre codes d\'activité'
    PERMISSIONS FOR SELECT FULL
    FOR CREATE, UPDATE, DELETE NONE;

-- =================================================================================================
-- CHAMPS
-- =================================================================================================

DEFINE FIELD IF NOT EXISTS code ON TABLE society_activity_code_correspondence_type 
    TYPE string
    COMMENT 'Code du type de correspondance (ex: exact, partial)';

DEFINE FIELD IF NOT EXISTS name_i18n_key ON TABLE society_activity_code_correspondence_type 
    TYPE record<i18n_key>
    COMMENT 'Clé i18n pour le nom du type';

DEFINE FIELD IF NOT EXISTS description_i18n_key ON TABLE society_activity_code_correspondence_type 
    TYPE record<i18n_key>
    COMMENT 'Clé i18n pour la description du type';

DEFINE FIELD IF NOT EXISTS sort_order ON TABLE society_activity_code_correspondence_type 
    TYPE int
    DEFAULT 0
    COMMENT 'Ordre de tri pour l\'affichage';

-- =================================================================================================
-- INDEX
-- =================================================================================================

DEFINE INDEX IF NOT EXISTS code_idx ON TABLE society_activity_code_correspondence_type 
    FIELDS code 
    UNIQUE
    COMMENT 'Index unique sur le code';