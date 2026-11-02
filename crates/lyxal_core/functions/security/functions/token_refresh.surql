-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/security/functions/token_refresh.surql
-- Fonction : fn::security_token_refresh
--
-- Construit une relation de rotation entre deux tokens.
--
-- Paramètres
--   $old_token_id    : uuid
--   $new_token_id    : uuid
--   $rotated_at      : datetime
--   $old_valid_until : datetime
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions security)
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : $old_valid_until < $rotated_at
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::security_token_refresh(
    $old_token_id: uuid,
    $new_token_id: uuid,
    $rotated_at: datetime,
    $old_valid_until: datetime
) -> object {
    IF $old_valid_until < $rotated_at {
        THROW "CORE_INVALID_ARGUMENT";
    };

    RETURN {
        old_token_id: $old_token_id,
        new_token_id: $new_token_id,
        rotated_at: $rotated_at,
        old_valid_until: $old_valid_until,
        status: "rotated"
    };
}
COMMENT "Construit une relation de rotation entre deux tokens."
PERMISSIONS FULL;
