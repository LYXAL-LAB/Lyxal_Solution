-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/security/functions/hmac_payload.surql
-- Fonction : fn::security_hmac_payload
--
-- Canonise un payload avant calcul HMAC.
--
-- Paramètres
--   $payload      : any
--   $content_type : string
--
-- Valeur renvoyée : string (contrat : crates/lyxal_core/Readme.md, fonctions security)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::security_hmac_payload(
    $payload: any,
    $content_type: string
) -> string {
    LET $type = string::lowercase(string::trim($content_type));
    RETURN IF $type = "application/json" {
        encoding::json::encode($payload)
    } ELSE IF type::is_string($payload) {
        $payload
    } ELSE {
        encoding::json::encode($payload)
    };
}
COMMENT "Canonise un payload avant calcul HMAC."
PERMISSIONS FULL;
