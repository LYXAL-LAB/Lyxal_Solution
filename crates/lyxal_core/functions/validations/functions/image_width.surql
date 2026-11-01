-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/image_width.surql
-- Fonction : fn::validation_image_width
--
-- Valide une largeur d'image en pixels : entier compris entre deux bornes
-- incluses.
--
-- Paramètres
--   $value     : any — valeur à contrôler
--   $min_width : int — largeur minimale (>= 1)
--   $max_width : int — largeur maximale (>= $min_width)
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = l'entier d'origine, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_TOO_SMALL
--     CORE_VALIDATION_TOO_LARGE
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : $min_width < 1 ou $min_width > $max_width
--
-- Exemple (dans une fonction de module)
--   LET $check = fn::validation_image_width($params.width, 16, 8192);
--   IF !$check.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $check.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_image_width(
    $value: any,
    $min_width: int,
    $max_width: int
) -> object {
    IF $min_width < 1 OR $min_width > $max_width { THROW "CORE_INVALID_ARGUMENT"; };
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_int($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "int", actual: type::of($value) } };
    };
    IF $value < $min_width { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SMALL", details: { min: $min_width } }; };
    IF $value > $max_width { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LARGE", details: { max: $max_width } }; };
    RETURN { valid: true, value: $value, code: NONE, details: {} };
}
COMMENT "Valide une largeur d'image bornée. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
