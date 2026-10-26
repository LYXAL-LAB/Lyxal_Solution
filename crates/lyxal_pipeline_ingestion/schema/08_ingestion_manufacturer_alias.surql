-- ============================================================================
-- TABLE  : ingestion_manufacturer_alias
-- MODULE : lyxal_pipeline_ingestion
-- RÔLE   : Alias et résolution des dénominations de fabricants industriels
-- ============================================================================

DEFINE TABLE OVERWRITE ingestion_manufacturer_alias
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE (
            ($token != NONE AND ($token.role IN ["ingestion_agent", "qualification_agent", "steward_admin", "catalogue_sync_agent"]))
            OR ($auth != NONE AND ($auth.role IN ["ingestion_agent", "qualification_agent", "steward_admin", "catalogue_sync_agent"]))
        )
        FOR create WHERE (
            ($token != NONE AND $token.role = "steward_admin")
            OR ($auth != NONE AND $auth.role = "steward_admin")
        )
        FOR update WHERE (
            ($token != NONE AND $token.role = "steward_admin")
            OR ($auth != NONE AND $auth.role = "steward_admin")
        )
        FOR delete NONE
    COMMENT "Table de correspondance des alias fabricants vers l'identité canonique";

DEFINE FIELD OVERWRITE raw_alias ON TABLE ingestion_manufacturer_alias
    TYPE string
    VALUE string::uppercase(string::trim($value))
    ASSERT string::len($value) >= 1
    COMMENT "Dénomination brute telle qu'extraite du flux fournisseur";

DEFINE FIELD OVERWRITE canonical_name ON TABLE ingestion_manufacturer_alias
    TYPE string
    VALUE string::uppercase(string::trim($value))
    ASSERT string::len($value) >= 1
    COMMENT "Nom canonique normalisé du fabricant ou de la filiale (ex: PLACO, ISOVER, WEBER)";

DEFINE FIELD OVERWRITE holding_or_group ON TABLE ingestion_manufacturer_alias
    TYPE option<string>
    COMMENT "Holding ou groupe industriel de rattachement (ex: SAINT-GOBAIN)";

DEFINE FIELD OVERWRITE is_verified ON TABLE ingestion_manufacturer_alias
    TYPE bool
    DEFAULT true
    COMMENT "Indique si l'entité est formellement vérifiée et distinguée";

DEFINE FIELD OVERWRITE created_at ON TABLE ingestion_manufacturer_alias
    TYPE option<datetime>
    DEFAULT time::now()
    COMMENT "Horodatage de création";

DEFINE FIELD OVERWRITE updated_at ON TABLE ingestion_manufacturer_alias
    TYPE option<datetime>
    DEFAULT time::now()
    COMMENT "Horodatage de dernière modification";

DEFINE INDEX OVERWRITE idx_mfg_raw_alias ON TABLE ingestion_manufacturer_alias FIELDS raw_alias UNIQUE;
DEFINE INDEX OVERWRITE idx_mfg_canonical ON TABLE ingestion_manufacturer_alias FIELDS canonical_name;
