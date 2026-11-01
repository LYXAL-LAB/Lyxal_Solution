-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/geometry.surql
-- Fonction : fn::validation_geometry
--
-- Valide une géométrie SurrealDB (GeoJSON), facultativement d'un des
-- sous-types autorisés et géométriquement valide (geo::is_valid).
--
-- Paramètres
--   $value         : any — valeur à contrôler
--   $allowed_types : option<array<string>> — sous-types autorisés parmi ["point", "line", "polygon", "multipoint", "multiline", "multipolygon", "collection"], NONE pour tous
--   $require_valid : bool — true pour exiger une géométrie valide (geo::is_valid)
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = la géométrie d'origine, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_NOT_ALLOWED
--     CORE_VALIDATION_FORMAT
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : liste vide ou sous-type inconnu
--
-- Exemple (dans une fonction de module)
--   LET $area = fn::validation_geometry($params.area, ["polygon", "multipolygon"], true);
--   IF !$area.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $area.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_geometry(
    $value: any,
    $allowed_types: option<array<string>>,
    $require_valid: bool
) -> object {
    LET $allowed = IF $allowed_types IS NONE { NONE } ELSE { array::map($allowed_types, |$item| string::lowercase(string::trim($item))) };
    IF $allowed IS NOT NONE AND (array::len($allowed) = 0 OR array::any($allowed, |$item| $item NOT IN ["point", "line", "polygon", "multipoint", "multiline", "multipolygon", "collection"])) { THROW "CORE_INVALID_ARGUMENT"; };
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_geometry($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "geometry", actual: type::of($value) } };
    };
    LET $kind = string::replace(string::replace(type::of($value), "geometry<", ""), ">", "");
    IF $allowed IS NOT NONE AND $kind NOT IN $allowed { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_ALLOWED", details: { allowed: $allowed, actual: $kind } }; };
    IF $require_valid AND !geo::is_valid($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "valid_geometry" } }; };
    RETURN { valid: true, value: $value, code: NONE, details: {} };
}
COMMENT "Valide une géométrie, son sous-type et sa validité. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
