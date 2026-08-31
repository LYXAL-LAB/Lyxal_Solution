-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_schema_version
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_schema_version(
    $value: string
) -> string {
    LET $v = string::lowercase(string::trim($value));
    LET $v = string::replace($v,<regex>"^version","");
    LET $v = string::replace($v,<regex>"^v?([1-9][0-9]*)$","v$1");
    RETURN $v;
}
COMMENT "Normalise une version de schéma vers vN."
PERMISSIONS FULL;
