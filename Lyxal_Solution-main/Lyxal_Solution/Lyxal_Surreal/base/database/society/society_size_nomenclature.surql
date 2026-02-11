DEFINE TABLE IF NOT EXISTS society_size_nomenclature TYPE NORMAL SCHEMAFULL
    COMMENT 'Nomenclature des tailles de sociétés'
    PERMISSIONS
        FOR select FULL
        FOR create, update, delete NONE;

DEFINE FIELD IF NOT EXISTS code ON TABLE society_size_nomenclature
    TYPE string
    ASSERT $value != ""
    COMMENT 'Code unique de la nomenclature (ex: TEFET, EUROSTAT, SBA_US)';

DEFINE FIELD IF NOT EXISTS description_i18n_key ON TABLE society_size_nomenclature
    TYPE record<i18n_key>
    COMMENT 'Clé i18n pour la description de la nomenclature';

DEFINE FIELD IF NOT EXISTS pays_reference ON TABLE society_size_nomenclature
    TYPE option<record<country>>
    COMMENT 'Pays de référence (NONE pour nomenclatures internationales)';

DEFINE FIELD IF NOT EXISTS period_start ON TABLE society_size_nomenclature
    TYPE option<int>
    COMMENT 'Année de début d\'utilisation';

DEFINE FIELD IF NOT EXISTS period_end ON TABLE society_size_nomenclature
    TYPE option<int>
    COMMENT 'Année de fin d\'utilisation (null si toujours active)';

DEFINE FIELD IF NOT EXISTS is_active ON TABLE society_size_nomenclature
    TYPE bool
    DEFAULT true
    COMMENT 'Indique si la nomenclature est toujours en vigueur';

DEFINE INDEX IF NOT EXISTS code_idx ON TABLE society_size_nomenclature 
    FIELDS code, pays_reference UNIQUE
    COMMENT 'Index unique sur le code + pays de référence';

DEFINE INDEX IF NOT EXISTS period_idx ON TABLE society_size_nomenclature 
    FIELDS period_start, period_end, pays_reference
    COMMENT 'Index sur les périodes d''utilisation';

DEFINE INDEX IF NOT EXISTS active_idx ON TABLE society_size_nomenclature 
    FIELDS is_active, pays_reference
    COMMENT 'Index sur les nomenclatures actives';