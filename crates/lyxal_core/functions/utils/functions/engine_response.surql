-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/engine_response.surql
-- Fonction : fn::utils_engine_response
--
-- Enveloppe de réponse associée à une requête (fn::utils_engine_request) :
-- identifiant, opération, résultat, horodatages et durée.
--
-- Paramètres
--   $request      : object
--   $output       : any
--   $completed_at : datetime
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions utils)
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : $completed_at antérieur à la réception de la requête
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_engine_response(
    $request: object,
    $output: any,
    $completed_at: datetime
) -> object {
    IF $completed_at < $request.received_at { THROW "CORE_INVALID_ARGUMENT"; };
    RETURN {
        request_id: $request.request_id,
        operation: $request.operation,
        output: $output,
        received_at: $request.received_at,
        completed_at: $completed_at,
        duration: $completed_at - $request.received_at
    };
}
COMMENT "Enveloppe de réponse associée à une requête (fn::utils_engine_request) : identifiant, opération, résultat, horodatages et durée."
PERMISSIONS FULL;
