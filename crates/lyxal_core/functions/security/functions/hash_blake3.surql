-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_hash_blake3
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_hash_blake3(
    $value: string
) -> string {
    RETURN crypto::blake3($value);
}
COMMENT "Calcule l'empreinte BLAKE3 native d'une chaîne."
PERMISSIONS FULL;
