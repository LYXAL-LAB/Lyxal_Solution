-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_schema_version
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_schema_version(
    $value:string
)->string{
 LET $v=string::lowercase(string::trim($value));
 RETURN string::replace($v,<regex>"^v?([1-9][0-9]*)$","v$1");
}
COMMENT "Normalise une version de schéma vers vN."
PERMISSIONS FULL;
