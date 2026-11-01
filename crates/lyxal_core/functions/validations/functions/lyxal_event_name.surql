-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/lyxal_event_name.surql
-- Fonction : fn::validation_lyxal_event_name
--
-- Valide un nom d'événement Lyxal (segments [a-z][a-z0-9_]* séparés par des
-- points, ex. booking.created) ; nombre de segments borné, valeur renvoyée
-- en minuscules.
--
-- Paramètres
--   $value        : any — valeur à contrôler
--   $min_segments : int — nombre minimal de segments (>= 1)
--   $max_segments : int — nombre maximal de segments (>= $min_segments)
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = le nom en minuscules, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_BLANK
--     CORE_VALIDATION_FORMAT
--     CORE_VALIDATION_TOO_SHORT
--     CORE_VALIDATION_TOO_LONG
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : $min_segments < 1 ou $min_segments > $max_segments
--
-- Exemple (dans une fonction de module)
--   LET $event = fn::validation_lyxal_event_name($params.event_type, 2, 4);
--   IF !$event.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $event.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_lyxal_event_name(
    $value: any,
    $min_segments: int,
    $max_segments: int
) -> object {
    IF $min_segments < 1 OR $min_segments > $max_segments { THROW "CORE_INVALID_ARGUMENT"; };
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_string($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: type::of($value) } };
    };
    LET $clean = string::lowercase(string::trim($value));
    IF $clean = "" { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} }; };
    LET $segments = array::len(string::split($clean, "."));
    IF !string::matches($clean, "^[a-z][a-z0-9_]*(?:\\.[a-z][a-z0-9_]*)*$") {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "lyxal_event_name" } };
    };
    IF $segments < $min_segments {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SHORT", details: { min_segments: $min_segments, segments: $segments } };
    };
    IF $segments > $max_segments {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LONG", details: { max_segments: $max_segments, segments: $segments } };
    };
    RETURN { valid: true, value: $clean, code: NONE, details: {} };
}
COMMENT "Valide un nom d'événement Lyxal (segments [a-z][a-z0-9_]* séparés par des points, ex. booking.created) ; nombre de segments borné, valeur renvoyée en minuscules. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
