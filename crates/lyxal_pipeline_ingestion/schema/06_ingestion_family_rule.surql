-- ============================================================================
-- TABLE  : ingestion_family_rule
-- MODULE : lyxal_pipeline_ingestion
-- RÔLE   : Définition dynamique des familles de produits BTP sans recompilation
-- ============================================================================

DEFINE TABLE OVERWRITE ingestion_family_rule
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
    COMMENT "Familles de produits configurables pour le moteur de regroupement technique";

DEFINE FIELD OVERWRITE code ON TABLE ingestion_family_rule
    TYPE string
    VALUE string::uppercase(string::trim($value))
    ASSERT string::len($value) >= 2
    COMMENT "Identifiant unique de la famille technique (ex: CLOISON_PLAQUE_PLATRE)";

DEFINE FIELD OVERWRITE label ON TABLE ingestion_family_rule
    TYPE string
    VALUE string::trim($value)
    ASSERT string::len($value) >= 2
    COMMENT "Libellé descriptif de la famille";

DEFINE FIELD OVERWRITE keywords ON TABLE ingestion_family_rule
    TYPE array<string>
    DEFAULT []
    COMMENT "Mots-clés discriminants pour rattacher les libellés commerciaux à la famille";

DEFINE FIELD OVERWRITE standard_unit ON TABLE ingestion_family_rule
    TYPE option<string>
    COMMENT "Unité canonique standard recommandée (référence base_unite, ex: M2, ML, PCE)";

DEFINE FIELD OVERWRITE created_at ON TABLE ingestion_family_rule
    TYPE option<datetime>
    DEFAULT time::now()
    COMMENT "Horodatage de création";

DEFINE FIELD OVERWRITE updated_at ON TABLE ingestion_family_rule
    TYPE option<datetime>
    DEFAULT time::now()
    COMMENT "Horodatage de dernière mise à jour";

DEFINE INDEX OVERWRITE idx_family_rule_code ON TABLE ingestion_family_rule FIELDS code UNIQUE;
