-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_optimizer_merge
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_optimizer_merge(
    $left: array<object>,
    $right: array<object>
) -> array<object> {
    RETURN fn::security_optimizer_remove_duplicates(
        array::concat($left,$right)
    );
}
COMMENT "Fusionne deux pipelines Security et retire les doublons."
PERMISSIONS FULL;
