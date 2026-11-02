-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/engine_state.surql
-- Fonction : fn::utils_engine_state
--
-- Crée l'état d'exécution transmis aux étapes : { value, issues, warnings,
-- records, stop, path, parent }. records accueille les données propres au
-- domaine (fn::utils_engine_record), propagées par les règles du moteur.
--
-- Paramètres
--   $value  : any
--   $path   : string
--   $parent : any
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions utils)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_engine_state(
    $value: any,
    $path: string,
    $parent: any
) -> object {
    RETURN { value: $value, issues: [], warnings: [], records: [], stop: false, path: string::trim($path), parent: $parent };
}
COMMENT "Crée l'état d'exécution transmis aux étapes : { value, issues, warnings, records, stop, path, parent }. records accueille les données propres au domaine (fn::utils_engine_record), propagées par les règles du moteur."
PERMISSIONS FULL;
