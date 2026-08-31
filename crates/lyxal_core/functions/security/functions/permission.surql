-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_permission
-- Version  : 1.0.0
-- Statut   : Stable
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
        THROW "SECURITY_INVALID_PERMISSION";
    };

    IF !array::contains(["allow","deny"], $clean_effect) {
        THROW "SECURITY_INVALID_PERMISSION_EFFECT";
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
