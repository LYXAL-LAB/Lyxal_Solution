-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/engine_request.surql
-- Fonction : fn::utils_engine_request
--
-- Enveloppe de requête d'exécution { request_id (UUID v7), operation,
-- payload, context, received_at }, commune à tous les domaines.
--
-- Paramètres
--   $operation : string
--   $payload   : any
--   $context   : option<object>
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions utils)
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : opération vide
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_engine_request(
    $operation: string,
    $payload: any,
    $context: option<object>
) -> object {
    IF string::trim($operation) = "" { THROW "CORE_INVALID_ARGUMENT"; };
    RETURN {
        request_id: rand::uuid::v7(),
        operation: string::lowercase(string::trim($operation)),
        payload: $payload,
        context: $context ?? {},
        received_at: time::now()
    };
}
COMMENT "Enveloppe de requête d'exécution { request_id (UUID v7), operation, payload, context, received_at }, commune à tous les domaines."
PERMISSIONS FULL;
