-- =====================================================================================
-- TABLE: society_activity_hierarchical_level
-- Description: Niveaux hiérarchiques des nomenclatures (section, division, groupe...)
-- Module: Base
-- =====================================================================================

DEFINE TABLE IF NOT EXISTS society_activity_hierarchical_level TYPE NORMAL SCHEMAFULL
    COMMENT 'Niveaux hiérarchiques des nomenclatures d\'activités'
    PERMISSIONS FOR SELECT FULL
    FOR CREATE, UPDATE, DELETE NONE;

-- =====================================================================================
-- CHAMPS
-- =====================================================================================

DEFINE FIELD IF NOT EXISTS code ON TABLE society_activity_hierarchical_level
    TYPE string
    COMMENT 'Code unique du niveau hiérarchique (ex: section, division)';

DEFINE FIELD IF NOT EXISTS name_i18n_key ON TABLE society_activity_hierarchical_level
    TYPE record<i18n_key>
    COMMENT 'Clé i18n pour le nom du niveau hiérarchique';

DEFINE FIELD IF NOT EXISTS description_i18n_key ON TABLE society_activity_hierarchical_level
    TYPE record<i18n_key>
    COMMENT 'Clé i18n pour la description du niveau hiérarchique';

DEFINE FIELD IF NOT EXISTS level_number ON TABLE society_activity_hierarchical_level
    TYPE int
    COMMENT 'Numéro du niveau dans la hiérarchie (1=le plus haut, 5=le plus bas)';

DEFINE FIELD IF NOT EXISTS is_terminal ON TABLE society_activity_hierarchical_level
    TYPE bool
    DEFAULT false
    COMMENT 'Indique si c\'est un niveau terminal (assigné aux entreprises)';

DEFINE FIELD IF NOT EXISTS sort_order ON TABLE society_activity_hierarchical_level
    TYPE int
    DEFAULT 0
    COMMENT 'Ordre de tri (pour affichage)';

-- =====================================================================================
-- INDEX
-- =====================================================================================

DEFINE INDEX IF NOT EXISTS code_idx ON TABLE society_activity_hierarchical_level FIELDS code UNIQUE
    COMMENT 'Index unique sur le code de niveau';

DEFINE INDEX IF NOT EXISTS level_number_idx ON TABLE society_activity_hierarchical_level 
    FIELDS level_number
    COMMENT 'Index sur le numéro de niveau';