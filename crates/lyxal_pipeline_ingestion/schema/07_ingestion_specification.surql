-- ============================================================================
-- TABLE  : ingestion_specification
-- MODULE : lyxal_pipeline_ingestion
-- RÔLE   : Spécifications techniques patronnes et tolérances configurables
-- ============================================================================

DEFINE TABLE OVERWRITE ingestion_specification
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
    COMMENT "Spécifications techniques patronnes pour l'équivalence fonctionnelle";

DEFINE FIELD OVERWRITE technical_identity_key ON TABLE ingestion_specification
    TYPE string
    VALUE string::uppercase(string::trim($value))
    ASSERT string::len($value) >= 3
    COMMENT "Clé d'identité technique unique (ex: SPEC_GEN_PLAQUE_BA13_2500x1200)";

DEFINE FIELD OVERWRITE family_code ON TABLE ingestion_specification
    TYPE string
    VALUE string::uppercase(string::trim($value))
    ASSERT string::len($value) >= 2
    COMMENT "Famille de rattachement (référence ingestion_family_rule.code)";

DEFINE FIELD OVERWRITE generic_title ON TABLE ingestion_specification
    TYPE string
    VALUE string::trim($value)
    ASSERT string::len($value) >= 3
    COMMENT "Désignation générique normalisée";

DEFINE FIELD OVERWRITE nominal_dimensions ON TABLE ingestion_specification
    TYPE option<object> FLEXIBLE
    COMMENT "Dimensions physiques nominales (length_mm, width_mm, height_mm)";

DEFINE FIELD OVERWRITE tolerances ON TABLE ingestion_specification
    TYPE option<object> FLEXIBLE
    DEFAULT {
        length_tol_mm: 5.0,
        width_tol_mm: 5.0,
        height_tol_mm: 1.0,
        weight_tol_pct: 5.0
    }
    COMMENT "Tolérances métrologiques configurables pour le rapprochement";

DEFINE FIELD OVERWRITE nominal_weight ON TABLE ingestion_specification
    TYPE option<float>
    COMMENT "Poids nominal unitaire";

DEFINE FIELD OVERWRITE standard_norm ON TABLE ingestion_specification
    TYPE option<string>
    COMMENT "Norme obligatoire (ex: NF EN 520, NF C 15-100)";

DEFINE FIELD OVERWRITE fire_rating ON TABLE ingestion_specification
    TYPE option<string>
    COMMENT "Classement réaction au feu (ex: A1, A2-s1,d0)";

DEFINE FIELD OVERWRITE required_features ON TABLE ingestion_specification
    TYPE option<object> FLEXIBLE
    DEFAULT {}
    COMMENT "Caractéristiques techniques obligatoires (ex: edge_type, thermal_lambda)";

DEFINE FIELD OVERWRITE created_at ON TABLE ingestion_specification
    TYPE option<datetime>
    DEFAULT time::now()
    COMMENT "Horodatage de création";

DEFINE FIELD OVERWRITE updated_at ON TABLE ingestion_specification
    TYPE option<datetime>
    DEFAULT time::now()
    COMMENT "Horodatage de dernière modification";

DEFINE INDEX OVERWRITE idx_spec_tech_key ON TABLE ingestion_specification FIELDS technical_identity_key UNIQUE;
DEFINE INDEX OVERWRITE idx_spec_family ON TABLE ingestion_specification FIELDS family_code;
