-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/ensure_string.surql
-- Fonction : fn::utils_ensure_string
--
-- Normalise une valeur vers une chaîne.
--
-- Paramètres
--   $value         : any
--   $default_value : string
--
-- Valeur renvoyée : string (contrat : crates/lyxal_core/Readme.md, fonctions utils)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_ensure_string(
    $value: any,
    $default_value: string
) -> string {
    RETURN IF $value IS NONE OR type::is_null($value) {
        $default_value
    } ELSE IF type::is_string($value) {
        $value
    } ELSE {
        <string>$value
    };
}
COMMENT "Normalise une valeur vers une chaîne."
PERMISSIONS FULL;
