-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_to_hex
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_to_hex(
    $value: bytes
) -> string {
    RETURN encoding::hex::encode($value);
}
COMMENT "Encode des octets en hexadécimal."
PERMISSIONS FULL;
