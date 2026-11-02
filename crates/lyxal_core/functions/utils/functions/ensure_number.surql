-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/ensure_number.surql
-- Fonction : fn::utils_ensure_number
--
-- Normalise une valeur vers un nombre.
--
-- Paramètres
--   $value         : any
--   $default_value : number
--
-- Valeur renvoyée : number (contrat : crates/lyxal_core/Readme.md, fonctions utils)
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : valeur non convertible (nombre ou chaîne décimale attendus)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_ensure_number(
    $value: any,
    $default_value: number
) -> number {
    RETURN IF $value IS NONE OR type::is_null($value) {
        $default_value
    } ELSE IF type::is_number($value) {
        $value
    } ELSE IF type::is_string($value)
        AND string::matches(string::trim($value),"^-?[0-9]+(?:\\.[0-9]+)?$")
    {
        <number>string::trim($value)
    } ELSE {
        THROW "CORE_INVALID_ARGUMENT"
    };
}
COMMENT "Normalise une valeur vers un nombre."
PERMISSIONS FULL;
