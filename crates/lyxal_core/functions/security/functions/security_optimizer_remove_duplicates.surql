-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_optimizer_remove_duplicates
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_optimizer_remove_duplicates(
    $pipeline: array<object>
) -> array<object> {
    RETURN array::fold(
        $pipeline,
        [],
        |$result,$step| {
            LET $exists = array::any(
                $result,
                |$existing|
                    $existing.rule = $step.rule
                    AND $existing.options = $step.options
            );

            IF $exists {
                $result
            } ELSE {
                array::append($result,$step)
            }
        }
    );
}
COMMENT "Supprime les étapes Security strictement dupliquées."
PERMISSIONS FULL;
