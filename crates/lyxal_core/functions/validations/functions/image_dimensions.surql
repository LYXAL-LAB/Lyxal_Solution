-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/image_dimensions.surql
-- Fonction : fn::validation_image_dimensions
--
-- Valide les dimensions d'une image : largeur et hauteur entières bornées,
-- nombre total de pixels facultativement borné.
--
-- Paramètres
--   $width      : any — largeur
--   $height     : any — hauteur
--   $min_width  : int — largeur minimale (>= 1)
--   $max_width  : int — largeur maximale (>= $min_width)
--   $min_height : int — hauteur minimale (>= 1)
--   $max_height : int — hauteur maximale (>= $min_height)
--   $max_pixels : option<int> — nombre maximal de pixels (>= 1), NONE pour aucun
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = { width, height, pixels }, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_TOO_SMALL
--     CORE_VALIDATION_TOO_LARGE
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : borne < 1, borne minimale > borne maximale, ou $max_pixels < 1
--
-- Exemple (dans une fonction de module)
--   LET $size = fn::validation_image_dimensions($params.width, $params.height, 16, 8192, 16, 8192, 40000000);
--   IF !$size.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $size.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_image_dimensions(
    $width: any,
    $height: any,
    $min_width: int,
    $max_width: int,
    $min_height: int,
    $max_height: int,
    $max_pixels: option<int>
) -> object {
    IF $min_width < 1 OR $min_height < 1 OR $min_width > $max_width OR $min_height > $max_height
        OR ($max_pixels IS NOT NONE AND $max_pixels < 1) { THROW "CORE_INVALID_ARGUMENT"; };
    IF $width IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: { bound: "width" } }; };
    IF type::is_null($width) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: { bound: "width" } }; };
    IF !type::is_int($width) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { bound: "width", expected: "int", actual: type::of($width) } };
    };
    IF $width < $min_width { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SMALL", details: { bound: "width", min: $min_width } }; };
    IF $width > $max_width { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LARGE", details: { bound: "width", max: $max_width } }; };
    IF $height IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: { bound: "height" } }; };
    IF type::is_null($height) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: { bound: "height" } }; };
    IF !type::is_int($height) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { bound: "height", expected: "int", actual: type::of($height) } };
    };
    IF $height < $min_height { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SMALL", details: { bound: "height", min: $min_height } }; };
    IF $height > $max_height { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LARGE", details: { bound: "height", max: $max_height } }; };
    LET $pixels = $width * $height;
    IF $max_pixels IS NOT NONE AND $pixels > $max_pixels { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LARGE", details: { bound: "pixels", max: $max_pixels } }; };
    RETURN { valid: true, value: { width: $width, height: $height, pixels: $pixels }, code: NONE, details: {} };
}
COMMENT "Valide les dimensions d'une image. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
