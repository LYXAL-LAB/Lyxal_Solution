-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/object_keys.surql
-- Fonction : fn::validation_object_keys
--
-- Valide les clés d'un objet : présence des clés obligatoires et,
-- facultativement, absence de clé hors de la liste autorisée.
--
-- Paramètres
--   $value         : any — valeur à contrôler
--   $required_keys : option<array<string>> — clés obligatoires, NONE pour aucune
--   $allowed_keys  : option<array<string>> — clés autorisées (doit contenir les clés obligatoires), NONE pour toutes
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = l'objet d'origine, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_NOT_ALLOWED
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : clé vide, ou clé obligatoire absente des clés autorisées
--
-- Exemple (dans une fonction de module)
--   LET $address = fn::validation_object_keys($params.address, ["city"], ["street", "city", "postal_code"]);
--   IF !$address.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $address.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_object_keys(
    $value: any,
    $required_keys: option<array<string>>,
    $allowed_keys: option<array<string>>
) -> object {
    LET $required = IF $required_keys IS NONE { [] } ELSE { array::map($required_keys, |$key| string::trim($key)) };
    LET $allowed = IF $allowed_keys IS NONE { NONE } ELSE { array::map($allowed_keys, |$key| string::trim($key)) };
    IF array::any($required, |$key| $key = "")
        OR ($allowed IS NOT NONE AND array::any($allowed, |$key| $key = ""))
        OR ($allowed IS NOT NONE AND array::any($required, |$key| $key NOT IN $allowed)) { THROW "CORE_INVALID_ARGUMENT"; };
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_object($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "object", actual: type::of($value) } };
    };
    LET $keys = object::keys($value);
    LET $missing = array::filter($required, |$key| $key NOT IN $keys);
    IF array::len($missing) > 0 { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: { scope: "key", keys: $missing } }; };
    LET $unknown = IF $allowed IS NONE { [] } ELSE { array::filter($keys, |$key| $key NOT IN $allowed) };
    IF array::len($unknown) > 0 { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_ALLOWED", details: { scope: "key", keys: $unknown } }; };
    RETURN { valid: true, value: $value, code: NONE, details: {} };
}
COMMENT "Valide les clés obligatoires et autorisées d'un objet. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
