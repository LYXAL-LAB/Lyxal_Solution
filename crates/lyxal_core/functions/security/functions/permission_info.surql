-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/security/functions/permission_info.surql
-- Fonction : fn::security_permission_info
--
-- Retourne les statistiques d'un ensemble de permissions.
--
-- Paramètres
--   $permissions : array<object>
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions security)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::security_permission_info(
    $permissions: array<object>
) -> object {
    LET $allows = array::filter(
        $permissions,
        |$permission| $permission.effect = "allow"
    );

    LET $denies = array::filter(
        $permissions,
        |$permission| $permission.effect = "deny"
    );

    RETURN {
        total: array::len($permissions),
        allow_count: array::len($allows),
        deny_count: array::len($denies),
        resources: array::distinct(
            array::map($permissions, |$permission| $permission.resource)
        ),
        actions: array::distinct(
            array::map($permissions, |$permission| $permission.action)
        )
    };
}
COMMENT "Retourne les statistiques d'un ensemble de permissions."
PERMISSIONS FULL;
