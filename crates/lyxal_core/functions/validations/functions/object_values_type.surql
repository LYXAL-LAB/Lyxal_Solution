-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/object_values_type.surql
-- Fonction : fn::validation_object_values_type
--
-- Valide que toutes les valeurs d'un objet ont le même type (type::of) ;
-- l'objet vide est accepté seulement si autorisé.
--
-- Paramètres
--   $value         : any — valeur à contrôler
--   $expected_type : string — type attendu des valeurs, tel que renvoyé par type::of
--   $allow_empty   : bool — true pour accepter un objet vide
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = l'objet d'origine, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_EMPTY
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : $expected_type vide
--
-- Exemple (dans une fonction de module)
--   LET $labels = fn::validation_object_values_type($params.labels, "string", true);
--   IF !$labels.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $labels.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_object_values_type(
    $value: any,
    $expected_type: string,
    $allow_empty: bool
) -> object {
    LET $expected = string::lowercase(string::trim($expected_type));
    IF $expected = "" { THROW "CORE_INVALID_ARGUMENT"; };
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_object($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "object", actual: type::of($value) } };
    };
    IF !$allow_empty AND object::is_empty($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_EMPTY", details: {} }; };
    IF array::any(object::values($value), |$item| string::lowercase(type::of($item)) != $expected) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { scope: "value", expected: $expected } };
    };
    RETURN { valid: true, value: $value, code: NONE, details: {} };
}
COMMENT "Valide le type de toutes les valeurs d'un objet. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
