-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/security/functions/policy.surql
-- Fonction : fn::security_policy
--
-- Construit une politique de permissions versionnée.
--
-- Paramètres
--   $name           : string
--   $version        : string
--   $permissions    : array<object>
--   $default_effect : string
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions security)
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : !string::matches($clean_version,"^v[1-9][0-9]*$")
--   CORE_UNSUPPORTED_OPTION : !((["allow","deny"]) CONTAINS ($effect))
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::security_policy(
    $name: string,
    $version: string,
    $permissions: array<object>,
    $default_effect: string
) -> object {
    LET $clean_name = string::lowercase(string::trim($name));
    LET $clean_version = string::lowercase(string::trim($version));
    LET $effect = string::lowercase(string::trim($default_effect));

    IF !string::matches($clean_version,"^v[1-9][0-9]*$") {
        THROW "CORE_INVALID_ARGUMENT";
    };

    IF !((["allow","deny"]) CONTAINS ($effect)) {
        THROW "CORE_UNSUPPORTED_OPTION";
    };

    RETURN {
        name: $clean_name,
        version: $clean_version,
        permissions: $permissions,
        default_effect: $effect
    };
}
COMMENT "Construit une politique de permissions versionnée."
PERMISSIONS FULL;
