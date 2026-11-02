-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/engine_record.surql
-- Fonction : fn::utils_engine_record
--
-- Ajoute à l'état un enregistrement propre au domaine { path, rule, kind,
-- data } (ex. constat ou décision de sécurité), sans arrêter le pipeline ;
-- les règles du moteur (each, object, one_of) propagent les enregistrements
-- des sous-états.
--
-- Paramètres
--   $state : object
--   $rule  : string
--   $kind  : string
--   $data  : any
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions utils)
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : genre (kind) vide
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_engine_record(
    $state: object,
    $rule: string,
    $kind: string,
    $data: any
) -> object {
    IF string::trim($kind) = "" { THROW "CORE_INVALID_ARGUMENT"; };
    RETURN object::extend($state, {
        records: array::append($state.records, { path: $state.path, rule: $rule, kind: string::trim($kind), data: $data })
    });
}
COMMENT "Ajoute à l'état un enregistrement propre au domaine { path, rule, kind, data } (ex. constat ou décision de sécurité), sans arrêter le pipeline ; les règles du moteur (each, object, one_of) propagent les enregistrements des sous-états."
PERMISSIONS FULL;
