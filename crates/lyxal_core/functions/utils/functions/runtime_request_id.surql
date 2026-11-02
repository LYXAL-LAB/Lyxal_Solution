-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/runtime_request_id.surql
-- Fonction : fn::utils_runtime_request_id
--
-- Génère un identifiant de requête.
--
-- Paramètres
--   $service : string
--
-- Valeur renvoyée : string (contrat : crates/lyxal_core/Readme.md, fonctions utils)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_runtime_request_id(
    $service: string
) -> string {
    LET $clean = string::lowercase(string::trim($service));

    RETURN string::concat(
        IF $clean = "" { "request" } ELSE { $clean },
        "_",
        <string>rand::uuid::v7()
    );
}
COMMENT "Génère un identifiant de requête."
PERMISSIONS FULL;
