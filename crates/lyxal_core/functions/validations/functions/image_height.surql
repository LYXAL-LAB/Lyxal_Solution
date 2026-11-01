-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/image_height.surql
-- Fonction : fn::validation_image_height
--
-- Valide une hauteur d'image en pixels : entier compris entre deux bornes
-- incluses.
--
-- Paramètres
--   $value      : any — valeur à contrôler
--   $min_height : int — hauteur minimale (>= 1)
--   $max_height : int — hauteur maximale (>= $min_height)
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
--   CORE_INVALID_ARGUMENT : $min_height < 1 ou $min_height > $max_height
--
-- Exemple (dans une fonction de module)
--   LET $check = fn::validation_image_height($params.height, 16, 8192);
--   IF !$check.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $check.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_image_height(
    $value: any,
    $min_height: int,
    $max_height: int
) -> object {
    IF $min_height < 1 OR $min_height > $max_height { THROW "CORE_INVALID_ARGUMENT"; };
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_int($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "int", actual: type::of($value) } };
    };
    IF $value < $min_height { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SMALL", details: { min: $min_height } }; };
    IF $value > $max_height { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LARGE", details: { max: $max_height } }; };
    RETURN { valid: true, value: $value, code: NONE, details: {} };
}
COMMENT "Valide une hauteur d'image bornée. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
