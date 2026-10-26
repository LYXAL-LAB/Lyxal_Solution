-- ============================================================================
-- TABLE  : catalogue_session
-- MODULE : lyxal_catalogue
-- RÔLE   : Sessions des utilisateurs et services authentifiés pour application du RLS
-- ============================================================================

DEFINE TABLE OVERWRITE catalogue_session
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE id = $auth.id
        FOR create, update, delete NONE
    COMMENT "Table de session des Record Users pour application du Row-Level Security (RLS)";

DEFINE FIELD OVERWRITE role ON TABLE catalogue_session
    TYPE string
    COMMENT "Rôle de l'identité authentifiée (catalogue_sync_agent ou tenant_user)";

DEFINE FIELD OVERWRITE tenant_id ON TABLE catalogue_session
    TYPE option<string>
    COMMENT "Identifiant de l'organisation cliente pour les sessions locataires";

DEFINE FIELD OVERWRITE scope ON TABLE catalogue_session
    TYPE option<array<string>>
    DEFAULT []
    COMMENT "Périmètres d'habilitation (ex: catalogue:sync:write)";

DEFINE FIELD OVERWRITE updated_at ON TABLE catalogue_session
    TYPE datetime
    VALUE time::now()
    COMMENT "Date de dernière authentification";
