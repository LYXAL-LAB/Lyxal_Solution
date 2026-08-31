-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_policy
-- Version  : 1.0.0
-- Statut   : Stable
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
        THROW "SECURITY_INVALID_POLICY_VERSION";
    };

    IF !array::contains(["allow","deny"],$effect) {
        THROW "SECURITY_INVALID_POLICY_DEFAULT_EFFECT";
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
