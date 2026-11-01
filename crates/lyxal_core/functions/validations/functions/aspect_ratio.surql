-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/aspect_ratio.surql
-- Fonction : fn::validation_aspect_ratio
--
-- Valide le rapport largeur / hauteur d'une image : deux entiers strictement
-- positifs dont le rapport (decimal) est compris entre deux bornes incluses.
--
-- Paramètres
--   $width     : any — largeur
--   $height    : any — hauteur
--   $min_ratio : decimal — rapport minimal (> 0)
--   $max_ratio : decimal — rapport maximal (>= $min_ratio)
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = { width, height, ratio }, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_TOO_SMALL
--     CORE_VALIDATION_TOO_LARGE
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : $min_ratio <= 0 ou $min_ratio > $max_ratio
--
-- Exemple (dans une fonction de module)
--   LET $ratio = fn::validation_aspect_ratio($params.width, $params.height, 1dec, 2dec);
--   IF !$ratio.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $ratio.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_aspect_ratio(
    $width: any,
    $height: any,
    $min_ratio: decimal,
    $max_ratio: decimal
) -> object {
    IF $min_ratio <= 0dec OR $min_ratio > $max_ratio { THROW "CORE_INVALID_ARGUMENT"; };
    IF $width IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: { bound: "width" } }; };
    IF type::is_null($width) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: { bound: "width" } }; };
    IF !type::is_int($width) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { bound: "width", expected: "int", actual: type::of($width) } };
    };
    IF $width < 1 { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SMALL", details: { bound: "width", min: 1 } }; };
    IF $height IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: { bound: "height" } }; };
    IF type::is_null($height) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: { bound: "height" } }; };
    IF !type::is_int($height) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { bound: "height", expected: "int", actual: type::of($height) } };
    };
    IF $height < 1 { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SMALL", details: { bound: "height", min: 1 } }; };
    LET $ratio = <decimal> $width / <decimal> $height;
    IF $ratio < $min_ratio { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SMALL", details: { bound: "ratio", min: $min_ratio, ratio: $ratio } }; };
    IF $ratio > $max_ratio { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LARGE", details: { bound: "ratio", max: $max_ratio, ratio: $ratio } }; };
    RETURN { valid: true, value: { width: $width, height: $height, ratio: $ratio }, code: NONE, details: {} };
}
COMMENT "Valide le rapport largeur / hauteur d'une image. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
