-- ============================================================================
-- TABLE  : ingestion_substitution_rule
-- MODULE : lyxal_pipeline_ingestion
-- RÔLE   : Règles de substitution contextualisées, justifiées et révocables
-- ============================================================================

DEFINE TABLE OVERWRITE ingestion_substitution_rule
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
    COMMENT "Règles de substitution Niveau 4 strictement contextualisées à un système constructif et révocables";

DEFINE FIELD OVERWRITE rule_id ON TABLE ingestion_substitution_rule
    TYPE string
    VALUE string::uppercase(string::trim($value))
    ASSERT string::len($value) >= 3
    COMMENT "Identifiant unique de la règle (ex: RULE_SUBST_PLACO_KNAUF_72_48)";

DEFINE FIELD OVERWRITE source_mfg ON TABLE ingestion_substitution_rule
    TYPE string
    VALUE string::uppercase(string::trim($value))
    ASSERT string::len($value) >= 1
    COMMENT "Fabricant source";

DEFINE FIELD OVERWRITE source_ref ON TABLE ingestion_substitution_rule
    TYPE string
    VALUE string::trim($value)
    ASSERT string::len($value) >= 1
    COMMENT "Référence catalogue source";

DEFINE FIELD OVERWRITE target_mfg ON TABLE ingestion_substitution_rule
    TYPE string
    VALUE string::uppercase(string::trim($value))
    ASSERT string::len($value) >= 1
    COMMENT "Fabricant cible substituable";

DEFINE FIELD OVERWRITE target_ref ON TABLE ingestion_substitution_rule
    TYPE string
    VALUE string::trim($value)
    ASSERT string::len($value) >= 1
    COMMENT "Référence catalogue cible";

DEFINE FIELD OVERWRITE system_scope ON TABLE ingestion_substitution_rule
    TYPE string
    VALUE string::uppercase(string::trim($value))
    ASSERT string::len($value) >= 3
    COMMENT "Périmètre restreint du système constructif (ex: SYSTEME_CLOISON_DISTRIBUTION_72_48)";

DEFINE FIELD OVERWRITE certification_body ON TABLE ingestion_substitution_rule
    TYPE string
    VALUE string::uppercase(string::trim($value))
    ASSERT string::len($value) >= 2
    COMMENT "Organisme certificateur officiel (ex: CSTB, CERQUAL, AFNOR)";

DEFINE FIELD OVERWRITE certification_ref ON TABLE ingestion_substitution_rule
    TYPE string
    VALUE string::trim($value)
    ASSERT string::len($value) >= 3
    COMMENT "Référence du procès-verbal ou de l'avis technique (ex: Avis Technique n° 9/21-1050_V1)";

DEFINE FIELD OVERWRITE valid_until ON TABLE ingestion_substitution_rule
    TYPE datetime
    COMMENT "Date d'expiration de la certification";

DEFINE FIELD OVERWRITE is_revoked ON TABLE ingestion_substitution_rule
    TYPE bool
    DEFAULT false
    COMMENT "Indique si la règle a été formellement révoquée";

DEFINE FIELD OVERWRITE revocation_reason ON TABLE ingestion_substitution_rule
    TYPE option<string>
    COMMENT "Motif explicite et traçable de la révocation";

DEFINE FIELD OVERWRITE created_at ON TABLE ingestion_substitution_rule
    TYPE option<datetime>
    DEFAULT time::now()
    COMMENT "Horodatage de création";

DEFINE FIELD OVERWRITE updated_at ON TABLE ingestion_substitution_rule
    TYPE option<datetime>
    DEFAULT time::now()
    COMMENT "Horodatage de dernière modification";

DEFINE INDEX OVERWRITE idx_subst_rule_id ON TABLE ingestion_substitution_rule FIELDS rule_id UNIQUE;
DEFINE INDEX OVERWRITE idx_subst_source_target ON TABLE ingestion_substitution_rule FIELDS source_mfg, source_ref, target_mfg, target_ref;
