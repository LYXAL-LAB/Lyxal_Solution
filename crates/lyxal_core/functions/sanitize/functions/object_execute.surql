-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/sanitize/functions/object_execute.surql
-- Fonction : fn::sanitize_object_execute
--
-- Nettoie un objet champ par champ selon un schéma du moteur ({ fields: {
-- <champ>: { pipeline, default } }, unknown_keys }) dont les pipelines
-- utilisent le catalogue sanitize. NONE renvoie NONE.
--
-- Paramètres
--   $value     : any
--   $schema    : object
--   $max_steps : int
--
-- Valeur renvoyée : any (contrat : crates/lyxal_core/Readme.md, fonctions sanitize)
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT / CORE_UNSUPPORTED_OPTION : schéma invalide (fn::utils_engine_schema)
--   CORE_SANITIZE_INVALID_TYPE : valeur qui n'est pas un objet, champ requis absent ou NULL non autorisé (la donnée aurait dû être validée avant)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::sanitize_object_execute(
    $value: any,
    $schema: object,
    $max_steps: int
) -> any {
    IF $value IS NONE { RETURN NONE; };
    IF !type::is_object($value) { THROW "CORE_SANITIZE_INVALID_TYPE"; };
    LET $normalized = fn::utils_engine_schema($schema, fn::sanitize_step_catalog(), $max_steps);
    LET $state = fn::utils_engine_run_object(fn::utils_engine_state($value, "", NONE), $normalized, |$current, $step| fn::sanitize_step_apply($current, $step));
    IF array::len($state.issues) > 0 { THROW "CORE_SANITIZE_INVALID_TYPE"; };
    RETURN $state.value;
}
COMMENT "Nettoie un objet champ par champ selon un schéma du moteur ({ fields: { <champ>: { pipeline, default } }, unknown_keys }) dont les pipelines utilisent le catalogue sanitize. NONE renvoie NONE."
PERMISSIONS FULL;
