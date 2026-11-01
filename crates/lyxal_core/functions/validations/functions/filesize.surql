-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/filesize.surql
-- Fonction : fn::validation_filesize
--
-- Valide une taille de fichier en octets : entier positif ou nul,
-- facultativement compris entre deux bornes incluses.
--
-- Paramètres
--   $value     : any — valeur à contrôler
--   $min_bytes : option<int> — taille minimale (>= 0), NONE pour aucune
--   $max_bytes : option<int> — taille maximale (>= 0), NONE pour aucune
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
--   CORE_INVALID_ARGUMENT : borne négative ou $min_bytes > $max_bytes
--
-- Exemple (dans une fonction de module)
--   LET $size = fn::validation_filesize($params.size, 1, 10485760);
--   IF !$size.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $size.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_filesize(
    $value: any,
    $min_bytes: option<int>,
    $max_bytes: option<int>
) -> object {
    IF ($min_bytes IS NOT NONE AND $min_bytes < 0) OR ($max_bytes IS NOT NONE AND $max_bytes < 0) { THROW "CORE_INVALID_ARGUMENT"; };
    IF $min_bytes IS NOT NONE AND $max_bytes IS NOT NONE AND $min_bytes > $max_bytes { THROW "CORE_INVALID_ARGUMENT"; };
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_int($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "int", actual: type::of($value) } };
    };
    LET $min = $min_bytes ?? 0;
    IF $value < $min { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SMALL", details: { min: $min } }; };
    IF $max_bytes IS NOT NONE AND $value > $max_bytes { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LARGE", details: { max: $max_bytes } }; };
    RETURN { valid: true, value: $value, code: NONE, details: {} };
}
COMMENT "Valide une taille de fichier bornée. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
