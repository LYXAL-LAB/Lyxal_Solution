-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/unknown_keys_policy.surql
-- Fonction : fn::validation_unknown_keys_policy
--
-- Applique une politique aux clés d'un objet absentes de la liste autorisée
-- : "allow" (acceptées), "reject" (refusées) ou "strip" (retirées de la
-- valeur renvoyée).
--
-- Paramètres
--   $value        : any — valeur à contrôler
--   $allowed_keys : array<string> — clés autorisées
--   $policy       : string — "allow", "reject" ou "strip", insensible à la casse
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = l'objet (sans les clés inconnues si $policy = "strip"), code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_NOT_ALLOWED
--
-- Erreurs de programmation (THROW)
--   CORE_UNSUPPORTED_OPTION : politique inconnue
--
-- Exemple (dans une fonction de module)
--   LET $input = fn::validation_unknown_keys_policy($params.input, ["name", "email"], "strip");
--   IF !$input.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $input.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_unknown_keys_policy(
    $value: any,
    $allowed_keys: array<string>,
    $policy: string
) -> object {
    LET $mode = string::lowercase(string::trim($policy));
    IF $mode NOT IN ["allow", "reject", "strip"] { THROW "CORE_UNSUPPORTED_OPTION"; };
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_object($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "object", actual: type::of($value) } };
    };
    LET $unknown = array::filter(object::keys($value), |$key| $key NOT IN $allowed_keys);
    IF $mode = "reject" AND array::len($unknown) > 0 { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_ALLOWED", details: { scope: "key", keys: $unknown } }; };
    IF $mode = "strip" {
        RETURN { valid: true, value: object::from_entries(array::filter(object::entries($value), |$entry| $entry[0] IN $allowed_keys)), code: NONE, details: {} };
    };
    RETURN { valid: true, value: $value, code: NONE, details: {} };
}
COMMENT "Applique la politique allow / reject / strip aux clés inconnues d'un objet. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
