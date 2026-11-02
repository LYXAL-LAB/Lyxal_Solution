-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/security/functions/secret_rotate.surql
-- Fonction : fn::security_secret_rotate
--
-- Construit un plan de rotation de secret par références.
--
-- Paramètres
--   $current_reference : string
--   $new_reference     : string
--   $valid_from        : datetime
--   $grace_period      : duration
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions security)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::security_secret_rotate(
    $current_reference: string,
    $new_reference: string,
    $valid_from: datetime,
    $grace_period: duration
) -> object {

    RETURN {
        current_reference: string::trim($current_reference),
        new_reference: string::trim($new_reference),
        valid_from: $valid_from,
        previous_valid_until: $valid_from + $grace_period,
        status: "scheduled"
    };
}
COMMENT "Construit un plan de rotation de secret par références."
PERMISSIONS FULL;
