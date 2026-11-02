-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/security/functions/token_info.surql
-- Fonction : fn::security_token_info
--
-- Construit les métadonnées publiques d'un token.
--
-- Paramètres
--   $token_id   : uuid
--   $token_type : string
--   $issued_at  : datetime
--   $expires_at : datetime
--   $status     : string
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions security)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::security_token_info(
    $token_id: uuid,
    $token_type: string,
    $issued_at: datetime,
    $expires_at: datetime,
    $status: string
) -> object {
    RETURN {
        token_id: $token_id,
        token_type: string::lowercase(string::trim($token_type)),
        issued_at: $issued_at,
        expires_at: $expires_at,
        status: string::lowercase(string::trim($status)),
        expired: $expires_at <= time::now(),
        contains_secret: false
    };
}
COMMENT "Construit les métadonnées publiques d'un token."
PERMISSIONS FULL;
