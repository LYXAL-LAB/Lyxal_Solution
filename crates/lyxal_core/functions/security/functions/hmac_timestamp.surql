-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/security/functions/hmac_timestamp.surql
-- Fonction : fn::security_hmac_timestamp
--
-- Transforme un datetime en timestamp Unix textuel pour une signature.
--
-- Paramètres
--   $value : datetime
--
-- Valeur renvoyée : string (contrat : crates/lyxal_core/Readme.md, fonctions security)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::security_hmac_timestamp(
    $value: datetime
) -> string {
    RETURN <string>time::unix($value);
}
COMMENT "Transforme un datetime en timestamp Unix textuel pour une signature."
PERMISSIONS FULL;
