-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_secret_compare
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_secret_compare(
    $left_reference: string,
    $right_candidate: string
) -> object {
    RETURN {
        operation: "constant_time_secret_compare",
        left_reference: string::trim($left_reference),
        right_candidate: $right_candidate,
        requires_native_crypto: true,
        constant_time_required: true
    };
}
COMMENT "Prépare une comparaison de secret constante en temps pour le moteur Rust."
PERMISSIONS FULL;
