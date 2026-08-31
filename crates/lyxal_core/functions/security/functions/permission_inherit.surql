-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_permission_inherit
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_permission_inherit(
    $parent_permissions: array<object>,
    $child_permissions: array<object>
) -> array<object> {
    RETURN fn::security_permission_merge(
        $parent_permissions,
        $child_permissions
    );
}
COMMENT "Construit les permissions héritées d'un parent et d'un enfant."
PERMISSIONS FULL;
