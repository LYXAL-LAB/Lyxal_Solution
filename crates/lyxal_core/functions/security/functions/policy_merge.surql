-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_policy_merge
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_policy_merge(
    $left: object,
    $right: object,
    $name: string,
    $version: string
) -> object {
    RETURN fn::security_policy(
        $name,
        $version,
        fn::security_permission_merge(
            $left.permissions,
            $right.permissions
        ),
        IF $right.default_effect IS NONE {
            $left.default_effect
        } ELSE {
            $right.default_effect
        }
    );
}
COMMENT "Fusionne deux politiques de permissions."
PERMISSIONS FULL;
