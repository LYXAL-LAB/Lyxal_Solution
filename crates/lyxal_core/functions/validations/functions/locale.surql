-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/locale.surql
-- Fonction : fn::validation_locale
--
-- Valide une locale langue[-RÉGION] (« fr », « fr-FR », « fr_FR ») ; la
-- région est exigée si demandé. La valeur renvoyée est normalisée en « fr-FR
-- ».
--
-- Paramètres
--   $value          : any — valeur à contrôler
--   $require_region : bool — true pour exiger la région
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = la locale normalisée (« fr » ou « fr-FR »), code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_BLANK
--     CORE_VALIDATION_FORMAT
--
-- Exemple (dans une fonction de module)
--   LET $locale = fn::validation_locale($params.locale, false);
--   IF !$locale.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $locale.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_locale(
    $value: any,
    $require_region: bool
) -> object {
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_string($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: type::of($value) } };
    };
    LET $clean = string::trim($value);
    IF $clean = "" { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} }; };
    LET $parts = string::split(string::replace($clean, "_", "-"), "-");
    LET $language = string::lowercase($parts[0]);
    LET $region = IF array::len($parts) = 2 { string::uppercase($parts[1]) } ELSE { NONE };
    IF array::len($parts) > 2 OR !string::matches($language, "^[a-z]{2,3}$") OR ($region IS NOT NONE AND !string::matches($region, "^[A-Z]{2}$")) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "locale" } };
    };
    IF $require_region AND $region IS NONE {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "locale", require_region: true } };
    };
    RETURN { valid: true, value: IF $region IS NONE { $language } ELSE { $language + "-" + $region }, code: NONE, details: {} };
}
COMMENT "Valide une locale langue[-RÉGION] (« fr », « fr-FR », « fr_FR ») ; la région est exigée si demandé. La valeur renvoyée est normalisée en « fr-FR ». Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
