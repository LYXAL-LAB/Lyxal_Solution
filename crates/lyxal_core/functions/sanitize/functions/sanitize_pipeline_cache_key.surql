-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_pipeline_cache_key
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_pipeline_cache_key(
    $name: string,
    $version: string,
    $pipeline: array<object>
) -> string {
    LET $n = string::lowercase(string::trim($name));
    LET $v = string::lowercase(string::trim($version));
    IF !string::matches($n,"^[a-z][a-z0-9_]*(?:::[a-z][a-z0-9_]*)*$") {
        THROW "SANITIZE_INVALID_PIPELINE_NAME";
    };
    IF !string::matches($v,"^v[1-9][0-9]*$") {
        THROW "SANITIZE_INVALID_PIPELINE_VERSION";
    };
    RETURN string::concat($n,"@",$v,":",encoding::base64::encode(encoding::json::encode($pipeline)));
}
COMMENT "Construit une clé déterministe pour un pipeline."
PERMISSIONS FULL;
