-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/semantic_version.surql
-- Fonction : fn::validation_semantic_version
--
-- Valide une version SemVer 2.0 (MAJEUR.MINEUR.CORRECTIF, pré-version et
-- métadonnées facultatives) ; préfixe « v » accepté seulement si autorisé.
--
-- Paramètres
--   $value          : any — valeur à contrôler
--   $allow_v_prefix : bool — accepter le préfixe « v » (ex. v1.2.3)
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = la chaîne sans espaces périphériques, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_BLANK
--     CORE_VALIDATION_FORMAT
--
-- Exemple (dans une fonction de module)
--   LET $version = fn::validation_semantic_version($params.version, false);
--   IF !$version.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $version.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_semantic_version(
    $value: any,
    $allow_v_prefix: bool
) -> object {
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_string($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: type::of($value) } };
    };
    LET $clean = string::trim($value);
    IF $clean = "" { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} }; };
    IF !string::matches($clean, IF $allow_v_prefix { "^v?(0|[1-9][0-9]*)\\.(0|[1-9][0-9]*)\\.(0|[1-9][0-9]*)(-[0-9A-Za-z-]+(\\.[0-9A-Za-z-]+)*)?(\\+[0-9A-Za-z-]+(\\.[0-9A-Za-z-]+)*)?$" } ELSE { "^(0|[1-9][0-9]*)\\.(0|[1-9][0-9]*)\\.(0|[1-9][0-9]*)(-[0-9A-Za-z-]+(\\.[0-9A-Za-z-]+)*)?(\\+[0-9A-Za-z-]+(\\.[0-9A-Za-z-]+)*)?$" }) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "semantic_version" } };
    };
    RETURN { valid: true, value: $clean, code: NONE, details: {} };
}
COMMENT "Valide une version SemVer 2.0 (MAJEUR.MINEUR.CORRECTIF, pré-version et métadonnées facultatives) ; préfixe « v » accepté seulement si autorisé. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
