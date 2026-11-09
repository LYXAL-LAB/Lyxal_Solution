-- ============================================================================
-- FONCTION : fn::ingestion_operator
-- MODULE   : lyxal_pipeline_ingestion
-- RÔLE     : Opérateur de la session lyxal_auth, enregistré dans les journaux du pipeline
-- ============================================================================
-- Lu dans la session (fn::auth_context), jamais dans les paramètres : identité de la session
-- (`auth_identity:<clé>`), sinon application du compte de service (`auth_application:<clé>`) ;
-- session système de l'hôte : `system`. Session inutilisable : NONE (aucune écriture ne passe
-- alors les permissions des tables).

DEFINE FUNCTION OVERWRITE fn::ingestion_operator($params: object) -> option<string> {
    LET $context = fn::auth_context({});
    IF !$context.ok { RETURN NONE; };
    IF $context.data.system { RETURN "system"; };
    IF $context.data.identity IS NOT NONE { RETURN <string> $context.data.identity; };
    IF $context.data.application IS NOT NONE { RETURN <string> $context.data.application; };
    RETURN NONE;
} COMMENT "Opérateur de la session lyxal_auth, lu dans la session : « auth_identity:<clé> », sinon « auth_application:<clé> » (compte de service), « system » pour la session système de l'hôte ; NONE si la session n'est pas utilisable"
PERMISSIONS FULL;
