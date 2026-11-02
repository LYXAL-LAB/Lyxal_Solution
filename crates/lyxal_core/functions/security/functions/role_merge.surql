-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/security/functions/role_merge.surql
-- Fonction : fn::security_role_merge
--
-- Fusionne deux définitions de rôle.
--
-- Paramètres
--   $base     : object
--   $override : object
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions security)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::security_role_merge(
    $base: object,
    $override: object
) -> object {
    RETURN {
        name: IF $override.name IS NONE { $base.name } ELSE { $override.name },
        permissions: fn::security_permission_merge(
            IF $base.permissions IS NONE { [] } ELSE { $base.permissions },
            IF $override.permissions IS NONE { [] } ELSE { $override.permissions }
        ),
        inherits: array::distinct(
            array::concat(
                IF $base.inherits IS NONE { [] } ELSE { $base.inherits },
                IF $override.inherits IS NONE { [] } ELSE { $override.inherits }
            )
        ),
        enabled: IF $override.enabled IS NONE { $base.enabled } ELSE { $override.enabled }
    };
}
COMMENT "Fusionne deux définitions de rôle."
PERMISSIONS FULL;
