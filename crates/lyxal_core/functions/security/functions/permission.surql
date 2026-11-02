-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/security/functions/permission.surql
-- Fonction : fn::security_permission
--
-- Construit une permission générique ressource/action.
--
-- Paramètres
--   $resource   : string
--   $action     : string
--   $effect     : string
--   $conditions : option<object>
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions security)
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : $clean_resource = "" OR $clean_action = ""
--   CORE_UNSUPPORTED_OPTION : !((["allow","deny"]) CONTAINS ($clean_effect))
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::security_permission(
    $resource: string,
    $action: string,
    $effect: string,
    $conditions: option<object>
) -> object {
    LET $clean_resource = string::lowercase(string::trim($resource));
    LET $clean_action = string::lowercase(string::trim($action));
    LET $clean_effect = string::lowercase(string::trim($effect));

    IF $clean_resource = "" OR $clean_action = "" {
        THROW "CORE_INVALID_ARGUMENT";
    };

    IF !((["allow","deny"]) CONTAINS ($clean_effect)) {
        THROW "CORE_UNSUPPORTED_OPTION";
    };

    RETURN {
        resource: $clean_resource,
        action: $clean_action,
        effect: $clean_effect,
        conditions: IF $conditions IS NONE { {} } ELSE { $conditions }
    };
}
COMMENT "Construit une permission générique ressource/action."
PERMISSIONS FULL;
