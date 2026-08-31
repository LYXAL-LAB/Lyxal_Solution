-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_sdk_permission
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_sdk_permission(
    $permissions: array<object>,
    $resource: string,
    $action: string,
    $context: option<object>
) -> object {
    RETURN {
        sdk:fn::security_sdk_version(),
        decision:fn::security_permission_check(
            $permissions,
            $resource,
            $action,
            $context
        )
    };
}
COMMENT "Évalue une permission via le SDK."
PERMISSIONS FULL;
