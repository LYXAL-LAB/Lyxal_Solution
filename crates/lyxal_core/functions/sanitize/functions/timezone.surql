-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_timezone
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_timezone(
    $value: string
) -> string {
    LET $v = string::trim($value);
    LET $v = string::replace($v, "UTC", "+00:00");
    LET $v = string::replace($v, "Z", "+00:00");
    RETURN $v;
}
COMMENT "Normalise lexicalement UTC et Z vers +00:00."
PERMISSIONS FULL;
