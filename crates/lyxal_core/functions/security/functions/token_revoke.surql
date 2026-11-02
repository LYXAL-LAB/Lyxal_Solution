-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/security/functions/token_revoke.surql
-- Fonction : fn::security_token_revoke
--
-- Construit un événement de révocation de token.
--
-- Paramètres
--   $token_id   : uuid
--   $revoked_at : datetime
--   $reason     : string
--   $actor      : option<string>
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions security)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::security_token_revoke(
    $token_id: uuid,
    $revoked_at: datetime,
    $reason: string,
    $actor: option<string>
) -> object {
    RETURN {
        token_id: $token_id,
        status: "revoked",
        revoked_at: $revoked_at,
        reason: string::trim($reason),
        actor: IF $actor IS NONE { NONE } ELSE { string::trim($actor) }
    };
}
COMMENT "Construit un événement de révocation de token."
PERMISSIONS FULL;
