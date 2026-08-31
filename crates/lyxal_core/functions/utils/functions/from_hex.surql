-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_from_hex
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_from_hex(
    $value: string
) -> bytes {
    RETURN encoding::hex::decode($value);
}
COMMENT "Décode une chaîne hexadécimale en octets."
PERMISSIONS FULL;
