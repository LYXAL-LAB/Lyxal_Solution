-- =================================================================================================
-- TABLE: society_activity_code_correspondence
-- Type: RELATION (IN society_activity_code OUT society_activity_code)
-- Description: Correspondances entre codes d'activité de différentes nomenclatures
-- =================================================================================================

DEFINE TABLE IF NOT EXISTS society_activity_code_correspondence TYPE RELATION SCHEMAFULL  
    IN society_activity_code 
    OUT society_activity_code
    COMMENT 'Correspondances entre codes d\'activité'
    PERMISSIONS FOR SELECT FULL
    FOR CREATE, UPDATE, DELETE NONE;

-- =================================================================================================
-- CHAMPS
-- =================================================================================================

DEFINE FIELD IF NOT EXISTS correspondence_type ON TABLE society_activity_code_correspondence 
    TYPE record<society_activity_code_correspondence_type>
    COMMENT 'Type de correspondance entre les codes';

DEFINE FIELD IF NOT EXISTS confidence_level ON TABLE society_activity_code_correspondence 
    TYPE option<float>
    ASSERT $value == NONE OR ($value >= 0 AND $value <= 1)
    COMMENT 'Niveau de confiance de la correspondance (0.0 à 1.0)';

DEFINE FIELD IF NOT EXISTS notes ON TABLE society_activity_code_correspondence 
    TYPE option<string>
    COMMENT 'Notes explicatives sur la correspondance';

DEFINE FIELD IF NOT EXISTS official_source ON TABLE society_activity_code_correspondence 
    TYPE option<string>
    COMMENT 'Source officielle de la correspondance (INSEE, Eurostat, ONU)';

DEFINE FIELD IF NOT EXISTS bidirectional ON TABLE society_activity_code_correspondence 
    TYPE bool
    DEFAULT true
    COMMENT 'Si true, la correspondance est valide dans les deux sens';

-- =================================================================================================
-- INDEX
-- =================================================================================================

DEFINE INDEX IF NOT EXISTS correspondence_type_idx ON TABLE society_activity_code_correspondence 
    FIELDS correspondence_type
    COMMENT 'Index sur le type de correspondance';