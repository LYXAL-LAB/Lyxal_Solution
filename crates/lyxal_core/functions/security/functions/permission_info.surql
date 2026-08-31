-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_permission_info
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_permission_info(
    $permissions: array<object>
) -> object {
    LET $allows = array::filter(
        $permissions,
        |$permission| $permission.effect = "allow"
    );

    LET $denies = array::filter(
        $permissions,
        |$permission| $permission.effect = "deny"
    );

    RETURN {
        total: array::len($permissions),
        allow_count: array::len($allows),
        deny_count: array::len($denies),
        resources: array::distinct(
            array::map($permissions, |$permission| $permission.resource)
        ),
        actions: array::distinct(
            array::map($permissions, |$permission| $permission.action)
        )
    };
}
COMMENT "Retourne les statistiques d'un ensemble de permissions."
PERMISSIONS FULL;
