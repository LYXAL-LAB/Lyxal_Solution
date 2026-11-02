-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/engine_trace.surql
-- Fonction : fn::utils_engine_trace
--
-- Construit une trace de débogage d'une étape { field, rule, input, output,
-- ok, details, started_at, completed_at, duration } ; details porte
-- l'erreur, le constat ou toute autre information du domaine.
--
-- Paramètres
--   $field        : string
--   $rule         : string
--   $input        : any
--   $output       : any
--   $ok           : bool
--   $details      : option<object>
--   $started_at   : datetime
--   $completed_at : datetime
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions utils)
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : $completed_at antérieur à $started_at
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_engine_trace(
    $field: string,
    $rule: string,
    $input: any,
    $output: any,
    $ok: bool,
    $details: option<object>,
    $started_at: datetime,
    $completed_at: datetime
) -> object {
    IF $completed_at < $started_at { THROW "CORE_INVALID_ARGUMENT"; };
    RETURN {
        field: string::trim($field),
        rule: string::lowercase(string::trim($rule)),
        input: $input,
        output: $output,
        ok: $ok,
        details: $details ?? {},
        started_at: $started_at,
        completed_at: $completed_at,
        duration: $completed_at - $started_at
    };
}
COMMENT "Construit une trace de débogage d'une étape { field, rule, input, output, ok, details, started_at, completed_at, duration } ; details porte l'erreur, le constat ou toute autre information du domaine."
PERMISSIONS FULL;
