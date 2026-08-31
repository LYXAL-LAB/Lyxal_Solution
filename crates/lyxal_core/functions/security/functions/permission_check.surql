-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_permission_check
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_permission_check(
    $permissions: array<object>,
    $resource: string,
    $action: string,
    $context: option<object>
) -> object {
    LET $clean_resource = string::lowercase(string::trim($resource));
    LET $clean_action = string::lowercase(string::trim($action));

    LET $matching = array::filter(
        $permissions,
        |$permission|
            $permission.resource = $clean_resource
            AND $permission.action = $clean_action
    );

    LET $denied = array::any(
        $matching,
        |$permission| $permission.effect = "deny"
    );

    LET $allowed = array::any(
        $matching,
        |$permission| $permission.effect = "allow"
    );

    RETURN {
        resource: $clean_resource,
        action: $clean_action,
        allowed: $allowed AND !$denied,
        explicit_deny: $denied,
        matching_permissions: $matching,
        context: IF $context IS NONE { {} } ELSE { $context }
    };
}
COMMENT "Évalue une permission avec priorité au deny explicite."
PERMISSIONS FULL;
