-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_runtime_id
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_runtime_id(
    $prefix: string,
    $length: int
) -> string {
    IF $length < 8 OR $length > 128 {
        THROW "UTILS_INVALID_RUNTIME_ID_LENGTH";
    };

    LET $clean_prefix = string::lowercase(string::trim($prefix));
    LET $id = rand::id($length);

    RETURN IF $clean_prefix = "" {
        $id
    } ELSE {
        string::concat($clean_prefix,"_",$id)
    };
}
COMMENT "Génère un identifiant runtime préfixé."
PERMISSIONS FULL;
