-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fonction : fn::validation_report_by_field
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_report_by_field(
    $report: object,
    $field: string
) -> object {
    LET $clean_field = string::trim($field);
    IF $clean_field = "" { THROW "VALIDATION_INVALID_FIELD_NAME"; };
    RETURN {
        field: $clean_field,
        errors: array::filter($report.errors, |$e| $e.field = $clean_field),
        warnings: array::filter($report.warnings, |$w| $w.field = $clean_field)
    };
}
COMMENT "Extrait les erreurs et avertissements d'un champ."
PERMISSIONS FULL;
