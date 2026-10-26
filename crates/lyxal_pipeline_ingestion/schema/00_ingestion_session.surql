-- ============================================================================
-- TABLE  : ingestion_session
-- MODULE : lyxal_pipeline_ingestion
-- RÔLE   : Sessions des identités authentifiées du pipeline d'ingestion (Record Users)
-- ============================================================================

DEFINE TABLE OVERWRITE ingestion_session
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE id = $auth.id
        FOR create, update, delete NONE
    COMMENT "Table de session sécurisée des Record Users du pipeline d'ingestion";

DEFINE FIELD OVERWRITE role ON TABLE ingestion_session
    TYPE string
    ASSERT $value IN ["ingestion_agent", "qualification_agent", "steward_admin", "catalogue_sync_agent"]
    COMMENT "Rôle de l'identité : ingestion_agent, qualification_agent, steward_admin, catalogue_sync_agent";

DEFINE FIELD OVERWRITE agent_id ON TABLE ingestion_session
    TYPE string
    COMMENT "Identifiant unique de l'agent ou du service (ex: service:pipeline-worker-01)";

DEFINE FIELD OVERWRITE scope ON TABLE ingestion_session
    TYPE option<array<string>>
    DEFAULT []
    COMMENT "Scopes d'habilitation explicites (ex: ingestion:batch:write, ingestion:staged:qualify, ingestion:manifest:approve, catalogue:sync:write)";

DEFINE FIELD OVERWRITE updated_at ON TABLE ingestion_session
    TYPE datetime
    VALUE time::now()
    COMMENT "Horodatage de dernière activité de session";
