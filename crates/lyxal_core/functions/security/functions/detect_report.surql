-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_detect_report
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_detect_report(
    $subject: string,
    $results: array<object>
) -> object {
    LET $detected = array::filter(
        $results,
        |$result| $result.detected
    );

    LET $score = fn::security_detect_score($results);

    RETURN {
        subject: string::trim($subject),
        detected: array::len($detected) > 0,
        score: $score,
        level: IF $score = 0 {
            "none"
        } ELSE IF $score < 30 {
            "low"
        } ELSE IF $score < 60 {
            "medium"
        } ELSE IF $score < 90 {
            "high"
        } ELSE {
            "critical"
        },
        findings: $detected,
        generated_at: time::now()
    };
}
COMMENT "Produit un rapport consolidé de détection."
PERMISSIONS FULL;
