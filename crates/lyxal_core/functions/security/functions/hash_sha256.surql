-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_hash_sha256
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_hash_sha256(
    $value: string
) -> string {
    RETURN crypto::sha256($value);
}
COMMENT "Calcule l'empreinte SHA-256 native d'une chaîne."
PERMISSIONS FULL;
