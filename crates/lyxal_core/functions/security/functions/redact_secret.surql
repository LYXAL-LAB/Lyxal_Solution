-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/security/functions/redact_secret.surql
-- Fonction : fn::security_redact_secret
--
-- Masque un secret en réutilisant la primitive Security Secrets.
--
-- Paramètres
--   $value         : string
--   $visible_start : int
--   $visible_end   : int
--
-- Valeur renvoyée : string (contrat : crates/lyxal_core/Readme.md, fonctions security)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::security_redact_secret(
    $value: string,
    $visible_start: int,
    $visible_end: int
) -> string {
    RETURN fn::security_secret_mask(
        $value,
        $visible_start,
        $visible_end,
        "*"
    );
}
COMMENT "Masque un secret en réutilisant la primitive Security Secrets."
PERMISSIONS FULL;
