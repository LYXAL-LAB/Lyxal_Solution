-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_pipeline_stats
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_pipeline_stats(
    $pipeline: array<object>
) -> object {
    RETURN {
        total:array::len($pipeline),
        detection_steps:array::len(array::filter($pipeline,|$s|string::starts_with($s.rule,"detect_"))),
        redaction_steps:array::len(array::filter($pipeline,|$s|string::starts_with($s.rule,"redact_"))),
        permission_steps:array::len(array::filter($pipeline,|$s|$s.rule="permission_check"))
    };
}
COMMENT "Calcule les statistiques d'un pipeline Security."
PERMISSIONS FULL;
