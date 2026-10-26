-- ============================================================================
-- TABLE  : ingestion_unit_alias
-- MODULE : lyxal_pipeline_ingestion
-- RÔLE   : Table de liaison dynamique des unités de mesure vers base_unite
-- ============================================================================

DEFINE TABLE OVERWRITE ingestion_unit_alias
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
    COMMENT "Correspondance des unités brutes vers le référentiel universel base_unite";

DEFINE FIELD OVERWRITE raw_alias ON TABLE ingestion_unit_alias
    TYPE string
    VALUE string::uppercase(string::trim($value))
    ASSERT string::len($value) >= 1
    COMMENT "Unité brute fournisseur ou code UN/CEFACT (ex: M2, SQM, MTK, C62)";

DEFINE FIELD OVERWRITE canonical_unit ON TABLE ingestion_unit_alias
    TYPE string
    VALUE string::uppercase(string::trim($value))
    ASSERT string::len($value) >= 1
    COMMENT "Code canonique officiel dans base_unite (ex: M2, PCE, M, ML, KG)";

DEFINE FIELD OVERWRITE comment ON TABLE ingestion_unit_alias
    TYPE option<string>
    COMMENT "Commentaire explicatif ou norme UN/CEFACT correspondante";

DEFINE FIELD OVERWRITE created_at ON TABLE ingestion_unit_alias
    TYPE option<datetime>
    DEFAULT time::now()
    COMMENT "Horodatage de création";

DEFINE FIELD OVERWRITE updated_at ON TABLE ingestion_unit_alias
    TYPE option<datetime>
    DEFAULT time::now()
    COMMENT "Horodatage de dernière modification";

DEFINE INDEX OVERWRITE idx_unit_raw_alias ON TABLE ingestion_unit_alias FIELDS raw_alias UNIQUE;
DEFINE INDEX OVERWRITE idx_unit_canonical ON TABLE ingestion_unit_alias FIELDS canonical_unit;
