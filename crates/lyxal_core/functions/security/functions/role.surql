-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/security/functions/role.surql
-- Fonction : fn::security_role
--
-- Construit un rôle générique.
--
-- Paramètres
--   $name        : string
--   $permissions : array<object>
--   $inherits    : array<string>
--   $enabled     : bool
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions security)
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : !string::matches( $clean_name, "^[a-z][a-z0-9_]*(?:::[a-z][a-z0-9_]*)*$" )
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
        THROW "CORE_INVALID_ARGUMENT";
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
