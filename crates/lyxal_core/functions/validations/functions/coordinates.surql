-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/coordinates.surql
-- Fonction : fn::validation_coordinates
--
-- Valide un couple de coordonnées GPS en degrés décimaux : latitude (-90 à
-- 90) et longitude (-180 à 180).
--
-- Paramètres
--   $latitude  : any — latitude
--   $longitude : any — longitude
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = { latitude, longitude }, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_TOO_SMALL
--     CORE_VALIDATION_TOO_LARGE
--
-- Exemple (dans une fonction de module)
--   LET $position = fn::validation_coordinates($params.lat, $params.lng);
--   IF !$position.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $position.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_coordinates(
    $latitude: any,
    $longitude: any
) -> object {
    IF $latitude IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: { bound: "latitude" } }; };
    IF type::is_null($latitude) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: { bound: "latitude" } }; };
    IF !type::is_number($latitude) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { bound: "latitude", expected: "number", actual: type::of($latitude) } };
    };
    IF $latitude < -90 { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SMALL", details: { bound: "latitude", min: -90 } }; };
    IF $latitude > 90 { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LARGE", details: { bound: "latitude", max: 90 } }; };
    IF $longitude IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: { bound: "longitude" } }; };
    IF type::is_null($longitude) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: { bound: "longitude" } }; };
    IF !type::is_number($longitude) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { bound: "longitude", expected: "number", actual: type::of($longitude) } };
    };
    IF $longitude < -180 { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SMALL", details: { bound: "longitude", min: -180 } }; };
    IF $longitude > 180 { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LARGE", details: { bound: "longitude", max: 180 } }; };
    RETURN { valid: true, value: { latitude: $latitude, longitude: $longitude }, code: NONE, details: {} };
}
COMMENT "Valide un couple latitude / longitude. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
