-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/ensure_bool.surql
-- Fonction : fn::utils_ensure_bool
--
-- Normalise une valeur courante vers un booléen.
--
-- Paramètres
--   $value         : any
--   $default_value : bool
--
-- Valeur renvoyée : bool (contrat : crates/lyxal_core/Readme.md, fonctions utils)
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : valeur non convertible (nombre, booléen ou true/false/1/0/yes/no/on/off attendus)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_ensure_bool(
    $value: any,
    $default_value: bool
) -> bool {
    IF $value IS NONE OR type::is_null($value) {
        RETURN $default_value;
    };

    IF type::is_bool($value) {
        RETURN $value;
    };

    IF type::is_number($value) {
        RETURN $value != 0;
    };

    IF type::is_string($value) {
        LET $clean = string::lowercase(string::trim($value));

        RETURN IF $clean IN ["true","1","yes","on"] {
            true
        } ELSE IF $clean IN ["false","0","no","off"] {
            false
        } ELSE {
            THROW "CORE_INVALID_ARGUMENT"
        };
    };

    THROW "CORE_INVALID_ARGUMENT";
}
COMMENT "Normalise une valeur courante vers un booléen."
PERMISSIONS FULL;
