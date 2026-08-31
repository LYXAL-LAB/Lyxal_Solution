-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_optimizer_validate
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_optimizer_validate(
    $pipeline: array<object>
) -> array<object> {
    IF array::any($pipeline,|$step|$step.rule="redact_object")
       AND array::any(
            $pipeline,
            |$step|$step.rule IN [
                "redact_email",
                "redact_phone",
                "redact_card",
                "redact_secret"
            ]
       ) {
        THROW "SECURITY_OPTIMIZER_AMBIGUOUS_REDACTION";
    };

    RETURN $pipeline;
}
COMMENT "Vérifie la cohérence d'un pipeline avant optimisation."
PERMISSIONS FULL;
