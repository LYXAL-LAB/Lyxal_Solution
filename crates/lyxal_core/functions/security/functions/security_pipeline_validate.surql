-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_pipeline_validate
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_pipeline_validate(
    $pipeline: array<object>
) -> array<object> {
    IF array::any($pipeline,|$s|$s.rule="redact_object")
       AND array::any($pipeline,|$s|$s.rule IN ["redact_email","redact_phone","redact_card"]) {
        THROW "SECURITY_PIPELINE_AMBIGUOUS_REDACTION";
    };
    RETURN $pipeline;
}
COMMENT "Vérifie la cohérence d'un pipeline Security."
PERMISSIONS FULL;
