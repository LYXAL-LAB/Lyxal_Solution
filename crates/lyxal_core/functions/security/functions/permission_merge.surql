-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_permission_merge
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_permission_merge(
    $left: array<object>,
    $right: array<object>
) -> array<object> {
    RETURN array::fold(
        array::concat($left,$right),
        [],
        |$result,$permission| {
            LET $exists = array::any(
                $result,
                |$existing|
                    $existing.resource = $permission.resource
                    AND $existing.action = $permission.action
                    AND $existing.effect = $permission.effect
                    AND $existing.conditions = $permission.conditions
            );

            IF $exists {
                $result
            } ELSE {
                array::append($result,$permission)
            }
        }
    );
}
COMMENT "Fusionne deux ensembles de permissions sans doublons stricts."
PERMISSIONS FULL;
