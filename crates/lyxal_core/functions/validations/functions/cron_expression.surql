-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/cron_expression.surql
-- Fonction : fn::validation_cron_expression
--
-- Valide la forme d'une expression cron (5 champs, ou 6 si les secondes sont
-- autorisées ; macros @daily… seulement si autorisées). La valeur renvoyée
-- est en minuscules ; les plages de chaque champ ne sont pas vérifiées.
--
-- Paramètres
--   $value         : any — valeur à contrôler
--   $allow_seconds : bool — accepter un 6e champ (secondes)
--   $allow_macros  : bool — accepter les macros @yearly, @monthly, @weekly, @daily, @hourly…
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = l'expression en minuscules, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_BLANK
--     CORE_VALIDATION_NOT_ALLOWED
--     CORE_VALIDATION_FORMAT
--
-- Exemple (dans une fonction de module)
--   LET $schedule = fn::validation_cron_expression($params.cron, false, true);
--   IF !$schedule.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $schedule.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_cron_expression(
    $value: any,
    $allow_seconds: bool,
    $allow_macros: bool
) -> object {
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_string($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: type::of($value) } };
    };
    LET $clean = string::lowercase(string::trim($value));
    IF $clean = "" { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} }; };
    LET $is_macro = string::starts_with($clean, "@");
    LET $fields = string::split($clean, " ");
    IF $is_macro AND !$allow_macros {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_ALLOWED", details: { reason: "macro" } };
    };
    IF $is_macro AND $clean NOT IN ["@yearly", "@annually", "@monthly", "@weekly", "@daily", "@midnight", "@hourly"] {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "cron_expression" } };
    };
    IF !$is_macro AND (array::len($fields) NOT IN IF $allow_seconds { [5, 6] } ELSE { [5] }
        OR array::any($fields, |$item| !string::matches($item, "^[0-9a-z*/?,#-]+$"))) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "cron_expression" } };
    };
    RETURN { valid: true, value: $clean, code: NONE, details: {} };
}
COMMENT "Valide la forme d'une expression cron (5 champs, ou 6 si les secondes sont autorisées ; macros @daily… seulement si autorisées). La valeur renvoyée est en minuscules ; les plages de chaque champ ne sont pas vérifiées. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
