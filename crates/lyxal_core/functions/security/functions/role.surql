-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_role
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_role(
    $name: string,
    $permissions: array<object>,
    $inherits: array<string>,
    $enabled: bool
) -> object {
    LET $clean_name = string::lowercase(string::trim($name));

    IF !string::matches(
        $clean_name,
        "^[a-z][a-z0-9_]*(?:::[a-z][a-z0-9_]*)*$"
    ) {
        THROW "SECURITY_INVALID_ROLE_NAME";
    };

    RETURN {
        name: $clean_name,
        permissions: $permissions,
        inherits: array::distinct(
            array::map(
                $inherits,
                |$role| string::lowercase(string::trim($role))
            )
        ),
        enabled: $enabled
    };
}
COMMENT "Construit un rôle générique."
PERMISSIONS FULL;
