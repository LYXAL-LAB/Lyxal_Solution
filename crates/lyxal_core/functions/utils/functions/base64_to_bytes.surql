-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_base64_to_bytes
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_base64_to_bytes(
    $value: string
) -> bytes {
    RETURN encoding::base64::decode($value);
}
COMMENT "Décode une chaîne Base64 en octets."
PERMISSIONS FULL;
