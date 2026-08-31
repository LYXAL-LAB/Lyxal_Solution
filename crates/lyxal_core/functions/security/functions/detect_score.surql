-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_detect_score
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_detect_score(
    $results: array<object>
) -> int {
    LET $total = array::fold(
        $results,
        0,
        |$score,$result| $score + $result.score
    );

    RETURN IF $total > 100 { 100 } ELSE { $total };
}
COMMENT "Agrège les scores de détection sur une échelle de 0 à 100."
PERMISSIONS FULL;
