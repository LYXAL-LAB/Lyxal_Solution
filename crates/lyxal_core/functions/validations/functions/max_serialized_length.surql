-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/max_serialized_length.surql
-- Fonction : fn::validation_max_serialized_length
--
-- Valide qu'un objet ou un tableau, une fois écrit en JSON
-- (encoding::json::encode), ne dépasse pas une longueur maximale en
-- caractères : borne la taille d'une donnée libre avant son enregistrement.
--
-- Paramètres
--   $value      : any — valeur à contrôler (objet ou tableau)
--   $max_length : int — longueur maximale du texte JSON (>= 0)
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = la valeur d'origine, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_TOO_LONG
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : $max_length < 0
--
-- Exemple (dans une fonction de module)
--   LET $check = fn::validation_max_serialized_length($params.data, 8192);
--   IF !$check.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $check.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_max_serialized_length(
    $value: any,
    $max_length: int
) -> object {
    IF $max_length < 0 { THROW "CORE_INVALID_ARGUMENT"; };
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_object($value) AND !type::is_array($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "object|array", actual: type::of($value) } };
    };
    LET $length = string::len(encoding::json::encode($value));
    IF $length > $max_length { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LONG", details: { max_length: $max_length, length: $length } }; };
    RETURN { valid: true, value: $value, code: NONE, details: {} };
}
COMMENT "Valide qu'un objet ou un tableau écrit en JSON ne dépasse pas une longueur maximale (en caractères). Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
