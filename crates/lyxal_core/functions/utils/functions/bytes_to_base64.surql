-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_bytes_to_base64
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_bytes_to_base64(
    $value: bytes
) -> string {
    RETURN encoding::base64::encode($value);
}
COMMENT "Encode des octets en Base64."
PERMISSIONS FULL;
