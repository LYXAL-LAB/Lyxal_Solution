-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_hash_sha512
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_hash_sha512(
    $value: string
) -> string {
    RETURN crypto::sha512($value);
}
COMMENT "Calcule l'empreinte SHA-512 native d'une chaîne."
PERMISSIONS FULL;
