-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_redact_array
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_redact_array(
    $value: array<any>,
    $indexes: array<int>
) -> array<any> {
    RETURN array::map(
        $value,
        |$item,$index| IF array::contains($indexes,$index) {
            "***REDACTED***"
        } ELSE {
            $item
        }
    );
}
COMMENT "Masque les éléments d'un tableau selon leurs index."
PERMISSIONS FULL;
