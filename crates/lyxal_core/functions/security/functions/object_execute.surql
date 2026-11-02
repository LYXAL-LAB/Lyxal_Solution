-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/security/functions/object_execute.surql
-- Fonction : fn::security_object_execute
--
-- Applique un schéma du moteur dont les pipelines utilisent le catalogue
-- security à un objet, champ par champ (ex. masquer email et téléphone,
-- détecter une injection dans un commentaire) ; renvoie { value, findings,
-- score, decisions, allowed, errors }.
--
-- Paramètres
--   $value     : object
--   $schema    : object
--   $max_steps : int
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions security)
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT / CORE_UNSUPPORTED_OPTION : schéma invalide (fn::utils_engine_schema) ou champ d'un type inattendu
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::security_object_execute(
    $value: object,
    $schema: object,
    $max_steps: int
) -> object {
    LET $normalized = fn::utils_engine_schema($schema, fn::security_step_catalog(), $max_steps);
    RETURN fn::security_step_result(
        fn::utils_engine_run_object(fn::utils_engine_state($value, "", NONE), $normalized, |$current, $step| fn::security_step_apply($current, $step))
    );
}
COMMENT "Applique un schéma du moteur dont les pipelines utilisent le catalogue security à un objet, champ par champ (ex. masquer email et téléphone, détecter une injection dans un commentaire) ; renvoie { value, findings, score, decisions, allowed, errors }."
PERMISSIONS FULL;
