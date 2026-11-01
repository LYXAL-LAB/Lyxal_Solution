-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/uuid_v7.surql
-- Fonction : fn::validation_uuid_v7
--
-- Valide qu'une valeur est un UUID de version 7 (variante RFC 9562), natif
-- ou, si autorisé, sous forme de chaîne.
--
-- Paramètres
--   $value        : any — valeur à contrôler
--   $allow_string : bool — true pour accepter aussi une chaîne au format UUID
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = la valeur d'origine (UUID natif ou chaîne, inchangée), code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_FORMAT
--
-- Exemple (dans une fonction de module)
--   LET $check = fn::validation_uuid_v7($params.event_id, false);
--   IF !$check.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $check.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_uuid_v7(
    $value: any,
    $allow_string: bool
) -> object {
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_uuid($value) AND !($allow_string AND type::is_string($value)) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "uuid", actual: type::of($value) } };
    };
    IF !string::matches(
        string::lowercase(<string> $value),
        "^[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$"
    ) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "uuid_v7" } }; };
    RETURN { valid: true, value: $value, code: NONE, details: {} };
}
COMMENT "Valide qu'une valeur est un UUID v7, natif ou chaîne si autorisé. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
